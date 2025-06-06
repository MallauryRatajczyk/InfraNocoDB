provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}
# 🔹 Supprime l'ancienne clé SSH pour éviter l'erreur `WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!`
resource "null_resource" "clear_ssh_known_hosts" {
  provisioner "local-exec" {
    command = "ssh-keygen -f ~/.ssh/known_hosts -R ${google_compute_address.static_ip_bastion.address}"
  }
  triggers = {
    always_run = "${timestamp()}" # Force l'exécution à chaque `terraform apply`
  }
}

resource "google_compute_address" "static_ip_bastion" { #Créer une IP Statique
  name   = "static-ip-bastion"
  region = var.gcp_region
}

resource "google_compute_instance" "bastion-instance" { #Création d'une VM pour héberger NocoDB
  name         = "bastion-instance"
  hostname     = var.hostname
  machine_type = var.ci_runner_instance_type
  project      = var.gcp_project
  zone         = var.gcp_zone
  tags         = ["bastion"] #Les tags pour le réseau
  allow_stopping_for_update = true
  metadata = {
    ssh-keys = "${var.ansible_user}:${file("${var.ssh_key_file}.pub")}"
  }

  boot_disk { 
    initialize_params {
      image = "debian-cloud/debian-12-bookworm-v20250212"
      size  = 20
      type  = "pd-standard"
    } 
  }

  network_interface {
    network    = var.vpc_name  
    subnetwork = var.subnet_bastion
    access_config {
      nat_ip = google_compute_address.static_ip_bastion.address 
    }
  }

  /* scheduling {
      preemptible       = true
      automatic_restart = false
    }*/ #Permet si activé de fermer automatiquement la VM si les ressources sont demandées ailleurs et de ne pas redémarrer automatiquement
}

# Configuration du firewall
resource "google_compute_firewall" "bastion_firewall" {
  name    = var.firewall
  network = var.network

   allow {
     protocol = "tcp"
     ports    = ["80", "443", "22"] 
   }

   source_ranges = ["0.0.0.0/0"] # Qui a accès à la VM
   target_tags   = ["bastion"]   #Accessible uniquement par ceux ayant le tag
 }

# Création du fichier d'inventaire pour Ansible
resource "local_file" "ansible_inventory" {
  content  = <<EOT
[servers]
bastion-instance ansible_host=${google_compute_address.static_ip_bastion.address}

[all:vars]
ansible_user=${var.ssh_user}
ansible_ssh_private_key_file=${var.ssh_key_file}
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
ansible_nocodb_ip=${var.nocodb}
ansible_monitoring=${var.monitoring}
ansible_bastion_dns=${var.dns}
EOT
  filename = "${path.module}/Ansible/inventory.ini"
}


