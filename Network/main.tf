provider "google" {
  project = var.gcp_project # Remplace par l'ID de ton projet GCP
  region  = var.region         # Utilisation de la variable region définie précédemment
  zone    = var.zones[0]  # Spécifie la zone (tu peux aussi utiliser une variable ici)
}

resource "google_compute_network" "private_network" {
  name                    = var.vpc_name
  auto_create_subnetworks  = false
}

resource "google_compute_subnetwork" "subnet_nocodb" {
  name          = "subnet-nocodb"
  network       = google_compute_network.private_network.id
  ip_cidr_range = var.cidr_ranges["nocodb"]
  region        = var.region
}

resource "google_compute_subnetwork" "subnet_bastion" {
  name          = "subnet-bastion"
  network       = google_compute_network.private_network.id
  ip_cidr_range = var.cidr_ranges["bastion"]
  region        = var.region
}

resource "google_compute_subnetwork" "subnet_storage" {
  name          = "subnet-storage"
  network       = google_compute_network.private_network.id
  ip_cidr_range = var.cidr_ranges["storage"]
  region        = var.region
}

resource "google_compute_subnetwork" "subnet_monitoring" {
  name          = "subnet-monitoring"
  network       = google_compute_network.private_network.id
  ip_cidr_range = var.cidr_ranges["monitoring"]
  region        = var.region
}

resource "google_compute_firewall" "allow_internal_ping" {
  name    = "allow-internal-ping"
  network = google_compute_network.private_network.id

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24", "10.10.4.0/24"]
  target_tags   = ["nocodb", "bastion", "monitoring"]
}


output "network_id" {
  value = google_compute_network.private_network.id
}

output "subnet_nocodb" {
  value = google_compute_subnetwork.subnet_nocodb.id
}

output "subnet_bastion" {
  value = google_compute_subnetwork.subnet_bastion.id
}

output "subnet_storage" {
  value = google_compute_subnetwork.subnet_storage.id
}

