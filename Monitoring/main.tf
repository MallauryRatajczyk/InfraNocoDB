# Initialisation du provider Google Cloud
provider "google" {
  project = var.gcp_project # Remplace par l'ID de ton projet Google Cloud
  region  = var.gcp_region  # Remplace par ta région préférée
  zone    = var.gcp_zone    # Remplace par ta région préférée
}

resource "google_compute_address" "static_ip_monitoring" {
  name   = var.static_ip
  region = var.gcp_region
  lifecycle {
    prevent_destroy = true # Empêche la suppression de l'ip statique
  }
}

resource "null_resource" "clear_ssh_known_hosts" {
  provisioner "local-exec" {
    command = "ssh-keygen -f ~/.ssh/known_hosts -R ${google_compute_address.static_ip_monitoring.address}"
  }

  triggers = {
    always_run = "${timestamp()}" # Force l'exécution à chaque terraform apply
  }
}

# Créer une instance de machine virtuelle (Compute Engine)
resource "google_compute_instance" "prometheus_grafana_instance" {
  name         = var.instance_name
  machine_type = var.ci_runner_instance_type
  zone         = var.gcp_zone
  hostname     = var.gcp_hostname
  tags         = var.tags

  # C'est de ce disque que la VM démarre
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12-bookworm-v20250212"
      size  = 20
      type  = "pd-standard"
    }
  }

  network_interface {
    network = var.network
    access_config {
      // Si vide, IP aléatoire mais crée automatiquement
      nat_ip = google_compute_address.static_ip_monitoring.address
    }
  }

  metadata = { #Définit les métadonnées de l'instance    
    ssh-keys = "${var.ssh_user}:${file("${var.ssh_key_file}.pub")}"
  }

  # Attacher le disque persistant sans la détruire
  attached_disk {
    source      = google_compute_disk.monitoring_data_disk.id # Spécifie le disque à attacher
    mode        = "READ_WRITE"                                # spécifie les permissions d’accès du disque au moment où il est attaché à une instance virtuelle (VM)
    device_name = var.disk_name                               # Nom du disque dans la VM
  }
}

# Créer un disque persistant séparé de la VM
resource "google_compute_disk" "monitoring_data_disk" {
  name = var.disk_name
  type = "pd-standard" # Type du disque : "pd-standard" ou "pd-ssd"
  zone = var.gcp_zone  # Remplace par ta zone GCP
  size = 20            # Taille en Go

  lifecycle {
    prevent_destroy = true # Empêche terraform de supprimer le disque
  }
}

resource "google_compute_firewall" "allow_http_https_ssh" { #Configuration du firewall
  name    = var.firewall
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080", "22", "3000", "9090", "9187"] # 8080 a enlevé une fois le reverse proxy de configurer
  }

  source_ranges = ["0.0.0.0/0"] # Qui a accès à la VM
  target_tags   = var.tags      # accessible uniquement par ceux ayant le tag
}

resource "local_file" "ansible_inventory" { #Créer un fichier inventory.ini pour Ansible
  content = <<EOT
 [servers]
 monitoring ansible_host=${google_compute_address.static_ip_monitoring.address}

 [all:vars]
 ansible_user=${var.ssh_user}
 ansible_ssh_private_key_file=${var.ssh_key_file}
 EOT

  #ansible_user est le nom d'utilisateur par défaut de la VM
  filename = "${path.module}/Ansible/inventory.ini"
}