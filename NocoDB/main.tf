provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}
 resource "null_resource" "clear_ssh_known_hosts" {
   provisioner "local-exec" {
     command = "ssh-keygen -f ~/.ssh/known_hosts -R ${google_compute_address.static_ip_bastion.address}"
   }
   triggers = {
     always_run = "${timestamp()}" # Force l'exécution à chaque `terraform apply`
   }
 }

resource "google_compute_address" "static_ip_nocodb" { #Créer une IP Statique
  name   = "static-ip-nocodb"
  region = var.gcp_region
}

resource "google_compute_instance" "nocodb-instance" {
  name         = "nocodb-instance"
  hostname     = var.hostname
  machine_type = var.ci_runner_instance_type
  project      = var.gcp_project
  zone         = var.gcp_zone
  tags         = ["gcp-ssh", "nocodb"]
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
    subnetwork = var.subnet_nocodb
    access_config {
      nat_ip = google_compute_address.nocodb_ip.address
    }
  }
}

 resource "google_compute_firewall" "allow_gcp_ssh2" {
    name    = "allow-gcp-ssh2"
    network = var.vpc_name
    allow {
      protocol = "tcp"
      ports    = ["22"]  # Ouverture du port SSH (22)
    }

    source_ranges = ["35.235.240.0/20", "34.163.198.254/32"]
    target_tags   = ["gcp-ssh"]
  }

resource "google_compute_firewall" "allow_ssh_from_bastion" {
  name    = "allow-ssh-from-bastion"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["22", "65535"]
  }

  source_ranges = ["10.10.2.0/24"]  # Plage IP de Bastion
  target_tags   = ["nocodb"]  # Tag de la VM NocoDB
}

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

resource "google_compute_firewall" "allow_proxy_port" {
  name    = "allow-proxy-port"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["32222"]
  }

  source_ranges = ["34.155.139.235/32"]
  target_tags   = ["proxy-port"]
}
resource "local_file" "ansible_inventory" {
  content  = <<EOT
[servers]
nocodb-instance ansible_host=${google_compute_instance.nocodb-instance.network_interface.0.network_ip}

[all:vars]
ansible_user=engineer
ansible_ssh_private_key_file=${var.ssh_key_file}
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="gcloud compute ssh --project project-quickdata --zone europe-west9-b --tunnel-through-iap --ssh-flag=-A --ssh-flag=-oStrictHostKeyChecking=no --ssh-flag=-oUserKnownHostsFile=/dev/null engineer@nocodb-instance"'
EOT
  filename = "Ansible/inventory.ini"
}
