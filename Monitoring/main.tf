# Initialisation du provider Google Cloud
provider "google" {
  #credentials = file(var.credentials_file)  # Remplace ce chemin par ton fichier de clé JSON
  project     = var.gcp_project    # Remplace par l'ID de ton projet Google Cloud
  region      = var.gcp_region     # Remplace par ta région préférée
  zone        = var.gcp_zone       # Remplace par ta région préférée
}
resource "google_compute_address" "static_ip_monitoring" { #Créer une IP Statique
  name   = "static-ip-monitoring"                          #Nom de l'ip statique
  region = var.gcp_region
  lifecycle {             #Empêche la suppression de l'ip statique
  prevent_destroy = true  
  }

}
resource "null_resource" "clear_ssh_known_hosts" {
  provisioner "local-exec" {
    command = "ssh-keygen -f ~/.ssh/known_hosts -R ${google_compute_address.static_ip_monitoring.address}"
  }

  triggers = {
    always_run = "${timestamp()}"  # Force l'exécution à chaque terraform apply
  }
}

# Définir le réseau et la sous-réseau pour l'instance
# resource "google_compute_network" "default" {
#   name = "default"
#}

# resource "google_compute_subnetwork" "default" {
#   name          = "default-subnetwork"
#   region        = var.gcp_region # Remplace par ta région
#   network       = google_compute_network.default.name
#   ip_cidr_range = "10.0.0.0/24"
# }

# Créer une instance de machine virtuelle (Compute Engine)
resource "google_compute_instance" "prometheus_grafana_instance" {
  name         = "monitoring"  # Remplace par le nom de l'instance souhaitée
  machine_type = var.ci_runner_instance_type # Choisis une taille d'instance adaptée
  zone         = var.gcp_zone  # Remplace par la zone que tu préfères
  hostname = var.gcp_hostname
  #tags         = ["prometheus", "grafana"]
  tags = ["http-server", "https-server"]

  boot_disk {                                               #C'est de ce disque que la VM démarre
    initialize_params {
        image = "debian-cloud/debian-12-bookworm-v20250212"
        size  = 20
        type  = "pd-standard"
    } # On peut ajouter d'autre disque pour stocker les données
  }

  network_interface {
    network    = "default"
    access_config {
      // Si vide, IP aléatoire mais crée automatiquement
      nat_ip = google_compute_address.static_ip_monitoring.address #Utilise l'ip statique définit plus haut
    }
  }
  

  metadata = { #Définit les métadonnées de l'instance    
   ssh-keys = "jordan.nankoo:${file("${var.ssh_key_file}.pub")}"
  }

  # Attacher le disque persistant sans la détruire
  attached_disk {
    source      = google_compute_disk.monitoring_data_disk.id #Spécifie le disque à attacher
    mode        = "READ_WRITE"            #spécifie les permissions d’accès du disque au moment où il est attaché à une instance virtuelle (VM)
    device_name = "monitoring-data-disk"  #Nom du disque dans la VM
  }
}

resource "google_compute_disk" "monitoring_data_disk" {     #Créer un disque persistant séparé de la VM
  name  = "monitoring-data-disk"
  type  = "pd-standard"                                     # Type du disque : "pd-standard" ou "pd-ssd"
  zone  = var.gcp_zone                                      # Remplace par ta zone GCP
  size  = 50                                                # Taille en Go

  lifecycle {                                               #Empêche terraform de supprimer le disque
    prevent_destroy = true
  }
}


#   metadata_startup_script = <<-EOT
#     #!/bin/bash
#     # Mettre à jour l'instance
#     apt-get update -y
#     apt-get upgrade -y

#     # Installer Docker
#     apt-get install -y docker.io
#     systemctl start docker
#     systemctl enable docker

#     # Télécharger et exécuter Prometheus et Grafana via Docker Compose
#     mkdir /home/debian/docker
#     cd /home/debian/docker

#     # Créer le fichier docker-compose.yml
#     cat > docker-compose.yml <<EOF
#     version: '3'

#     services:
#       prometheus:
#         image: prom/prometheus
#         container_name: prometheus
#         ports:
#           - "9090:9090"
#         volumes:
#           - ./prometheus.yml:/etc/prometheus/prometheus.yml

#       grafana:
#         image: grafana/grafana
#         container_name: grafana
#         ports:
#           - "3000:3000"
#         environment:
#           - GF_SECURITY_ADMIN_PASSWORD=admin
#         depends_on:
#           - prometheus
#     EOF

#     # Lancer Docker Compose
#     docker-compose up -d
#   EOT
 
# resource "google_compute_network" "vpc_network" {
#   name                    = "terraform-network"
#   auto_create_subnetworks = "true"
# }
# resource "google_compute_firewall" "allow_ssh" {
#   name    = "allow-ssh"
#   network = "default"

#   allow {
#     protocol = "tcp"
#     ports    = ["22"]
#   }

#   source_ranges = ["0.0.0.0/0"]
#   target_tags   = ["ssh"]
# }
resource "google_compute_firewall" "allow_http_https_ssh" { #Configuration du firewall
  name    = "jordan-http-https-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080", "22", "3000", "9090"] #8080 a enlevé une fois le reverse proxy de configurer
  }

  source_ranges = ["0.0.0.0/0"] # Qui a accès à la VM
  target_tags   = ["http-server", "https-server"] #accessible uniquement par ceux ayant le tag
}

  output "instance_ip" {
   value = google_compute_address.static_ip_monitoring.address
   description = "Adresse IP publique de la VM"
 }


  resource "local_file" "ansible_inventory" {     #Créer un fichier inventory.ini pour Ansible
   content = <<EOT
 [servers]
 monitoring ansible_host=${google_compute_address.static_ip_monitoring.address}

 [all:vars]
 ansible_user=jordan.nankoo
 ansible_ssh_private_key_file=${var.ssh_key_file}
 EOT

 #ansible_user est le nom d'utilisateur par défaut de la VM
   filename = "Monitoring/Ansible/inventory.ini"
 }

