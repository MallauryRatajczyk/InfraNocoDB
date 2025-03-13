provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

resource "google_compute_address" "static_ip_nocodb" { #Créer une IP Statique
  name   = var.static_ip
  region = var.gcp_region
}

# Supprime l'ancienne clé SSH pour éviter l'erreur `WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!`
resource "null_resource" "clear_ssh_known_hosts" {
  provisioner "local-exec" {
    command = "ssh-keygen -f ~/.ssh/known_hosts -R ${google_compute_address.static_ip_nocodb.address}"
  }

  triggers = {
    always_run = "${timestamp()}" # Force l'exécution à chaque `terraform apply`
  }
}

# Création d'une VM pour héberger NocoDB
resource "google_compute_instance" "nocodb-instance" {
  count        = var.instance.count
  name         = var.instance.count > 1 ? "${var.instance.name}-${count.index}" : var.instance.name
  hostname     = var.hostname
  machine_type = var.ci_runner_instance_type
  project      = var.gcp_project
  zone         = var.gcp_zone
  tags         = concat(var.firewall[0].tags, var.firewall[1].tags) #Les tags pour le réseau

  metadata = {
    # Utilisation d'une clé SSH persistante (au lieu d'en générer une à chaque `terraform apply`)
    ssh-keys = "${var.ssh_user}:${file("${var.ssh_key_file}.pub")}"
  }

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
      nat_ip = google_compute_address.static_ip_nocodb.address
    }
  }

  /* scheduling {
      preemptible       = true
      automatic_restart = false
    }*/ #Permet si activé de fermer automatiquement la VM si les ressources sont demandées ailleurs et de ne pas redémarrer automatiquement
}

resource "google_compute_firewall" "allow_node_exporter" {
  name    = var.firewall[0].name
  network = var.network

  allow {
    protocol = "tcp"
    ports    = var.firewall[0].ports
  }

  source_ranges = var.firewall[0].source_ranges
  target_tags   = var.firewall[0].tags
}

resource "google_compute_firewall" "allow_custom_port" {
  name    = var.firewall[1].name
  network = var.network

  allow {
    protocol = "tcp"
    ports    = var.firewall[1].ports
  }

  source_ranges = var.firewall[1].source_ranges
  target_tags   = var.firewall[1].tags
}

output "instance_ip" {
  value       = google_compute_address.static_ip_nocodb.address
  description = "Adresse IP publique de la VM"
}

# Création du fichier d'inventaire pour Ansible
resource "local_file" "ansible_inventory" {
  content  = <<EOT
[servers]
nocodb-instance ansible_host=${google_compute_address.static_ip_nocodb.address}

[all:vars]
ansible_user=${var.ssh_user}
ansible_ssh_private_key_file=${var.ssh_key_file}
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
EOT
  filename = "Ansible/inventory.ini"
}
