# Initialisation du provider Google Cloud
provider "google" {
  credentials = file(var.credentials_file)  # Remplace ce chemin par ton fichier de clé JSON
  project     = var.gcp_project  # Remplace par l'ID de ton projet Google Cloud
  region      = var.gcp_region
  zone        = var.gcp_zone       # Remplace par ta région préférée
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
  tags         = ["prometheus", "grafana"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"  # Utilisation d'une image debian
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    #subnetwork = google_compute_subnetwork.default.name
    access_config {
      // Permet à l'instance d'avoir une adresse IP externe
    }
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    # Mettre à jour l'instance
    apt-get update -y
    apt-get upgrade -y

    # Installer Docker
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker

    # Télécharger et exécuter Prometheus et Grafana via Docker Compose
    mkdir /home/debian/docker
    cd /home/debian/docker

    # Créer le fichier docker-compose.yml
    cat > docker-compose.yml <<EOF
    version: '3'

    services:
      prometheus:
        image: prom/prometheus
        container_name: prometheus
        ports:
          - "9090:9090"
        volumes:
          - ./prometheus.yml:/etc/prometheus/prometheus.yml

      grafana:
        image: grafana/grafana
        container_name: grafana
        ports:
          - "3000:3000"
        environment:
          - GF_SECURITY_ADMIN_PASSWORD=admin
        depends_on:
          - prometheus
    EOF

    # Lancer Docker Compose
    docker-compose up -d
  EOT
}
resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = "true"
}