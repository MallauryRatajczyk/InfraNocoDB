provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

resource "google_compute_address" "static_ip_nocodb" { #Créer une IP Statique
  name   = "static-ip-nocodb"
  region = var.gcp_region
}

# 🔹 Supprime l'ancienne clé SSH pour éviter l'erreur `WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!`
resource "null_resource" "clear_ssh_known_hosts" {
  provisioner "local-exec" {
    command = "ssh-keygen -f ~/.ssh/known_hosts -R ${google_compute_address.static_ip_nocodb.address}"
  }

  triggers = {
    always_run = "${timestamp()}" # Force l'exécution à chaque `terraform apply`
  }
}

resource "google_compute_instance" "nocodb-instance" { #Création d'une VM pour héberger NocoDB
  name         = "nocodb-instance"
  hostname     = var.hostname
  machine_type = var.ci_runner_instance_type
  project      = var.gcp_project
  zone         = var.gcp_zone
  tags         = ["node-exporter", "custom-port"] #Les tags pour le réseau

  metadata = {
    # Utilisation d'une clé SSH persistante (au lieu d'en générer une à chaque `terraform apply`)
    ssh-keys = "${var.ansible_user}:${file("${var.ssh_key_file}.pub")}"
  }

  boot_disk { #C'est de ce disque que la VM démarre
    initialize_params {
      image = "debian-cloud/debian-12-bookworm-v20250212"
      size  = 20
      type  = "pd-standard"
    } # On peut ajouter d'autres disques pour stocker les données
  }

  network_interface {
    network = "default"
    access_config {
      // Si vide, IP aléatoire mais crée automatiquement
      nat_ip = google_compute_address.static_ip_nocodb.address #Utilise l'IP statique définit plus haut
    }
  }

  /* scheduling {
      preemptible       = true
      automatic_restart = false
    }*/ #Permet si activé de fermer automatiquement la VM si les ressources sont demandées ailleurs et de ne pas redémarrer automatiquement
}

# resource "google_compute_firewall" "allow_reverse_proxy" { #Configuration du firewall
#   name    = "allow-reverse-proxy"
#   network = "default"

#   allow {
#     protocol = "tcp"
#     ports    = ["32222", "5432", "9100"]
#   }
#   source_ranges = ["34.155.139.235/32", "0.0.0.0/0"] # Seul le reverse proxy peut y accéder
# }
resource "google_compute_firewall" "allow_node_exporter" {
  name    = "allow-node-exporter"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["9100"]
  }

  source_ranges = ["34.163.103.61/32"]
  target_tags   = ["node-exporter"]
}

resource "google_compute_firewall" "allow_custom_port" {
  name    = "allow-custom-port"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["32222"]
  }

  source_ranges = ["34.155.139.235/32"]
  target_tags   = ["custom-port"]
}

output "instance_ip" {
  value       = google_compute_address.static_ip_nocodb.address
  description = "Adresse IP publique de la VM"
}

resource "local_file" "ansible_inventory" { # Création du fichier d'inventaire pour Ansible
  content  = <<EOT
[servers]
nocodb-instance ansible_host=${google_compute_address.static_ip_nocodb.address}

[all:vars]
ansible_user=engineer
ansible_ssh_private_key_file=${var.ssh_key_file}
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
EOT
  filename = "Ansible/inventory.ini"
}
