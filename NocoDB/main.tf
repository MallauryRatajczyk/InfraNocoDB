provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}
 resource "null_resource" "clear_ssh_known_hosts" {
   provisioner "local-exec" {
     command = "ssh-keygen -f ~/.ssh/known_hosts -R ${google_compute_address.static_ip_nocodb.address}"
   }
   triggers = {
     always_run = "${timestamp()}" # Force l'exécution à chaque `terraform apply`
   }
 }

resource "google_compute_address" "static_ip_nocodb" { #Créer une IP Statique
  name   = var.static_ip
  region = var.gcp_region
}

resource "google_compute_instance" "nocodb-instance" {
  name         = "nocodb-instance"
  hostname     = var.hostname
  machine_type = var.ci_runner_instance_type
  project      = var.gcp_project
  zone         = var.gcp_zone
  tags         = ["gcp-ssh", "nocodb", "bastion"] #Pourquoi Bastion ?
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
    network = var.network
    subnetwork = var.subnet_nocodb
    access_config {
      nat_ip = google_compute_address.static_ip_nocodb.address
    }
  }
}

#  resource "google_compute_firewall" "allow_gcp_ssh2" {
#     name    = "allow-gcp-ssh2"
#     network = var.vpc_name
#     allow {
#       protocol = "tcp"
#       ports    = ["22"]  # Ouverture du port SSH (22)
#     }

#     source_ranges = ["0.0.0.0/0"]
#     target_tags   = ["gcp-ssh"]
#   }

resource "google_compute_firewall" "allow_ssh_from_bastion" {
  name    = "allow-ssh-from-bastion"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["22", "32222", "8080"]
  }

  source_ranges = ["10.10.2.0/24"]  # Plage IP de Bastion
  target_tags   = ["nocodb"]  # Tag de la VM NocoDB
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

  source_ranges = ["34.155.139.235/32","10.10.2.2/32"]
  target_tags   = ["proxy-port"]
}

resource "local_file" "ansible_inventory" {
  content  = <<EOT
[servers]
nocodb-instance ansible_host=${google_compute_address.static_ip_nocodb.address}

[all:vars]
ansible_user=${var.ansible_user}
ansible_ssh_private_key_file=${var.ssh_key_file}
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
ansible_database_ip=${var.database_ip}
EOT
  filename = "${path.module}/Ansible/inventory.ini"
}

