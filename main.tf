
module "bastion" {
  source = "./Bastion"

  instance_name = "${terraform.workspace}-bastion-instance"
  static_ip     = "${terraform.workspace}-static-ip-bastion"
  ssh_key_file  = var.ssh_key_file
  ssh_user      = var.ssh_user
}

module "monitoring" {
  source = "./Monitoring"

  instance_name = "${terraform.workspace}-monitoring-instance"
  static_ip     = "${terraform.workspace}-static-ip-monitoring"
  disk_name     = "${terraform.workspace}-monitoring-data-disk"
  ssh_key_file  = var.ssh_key_file
  ssh_user      = var.ssh_user
}

module "nocodb" {
  source = "./NocoDB"

  instance = {
    name  = "${terraform.workspace}-nocodb"
    count = (terraform.workspace == "production") ? 2 : 1
  }
  static_ip    = "${terraform.workspace}-static-ip-nocodb"
  disk_name    = "${terraform.workspace}-monitoring-data-disk"
  ssh_key_file = var.ssh_key_file
  ssh_user     = var.ssh_user
}

module "storage" {
  source = "./Storage"
  user   = var.user
}

# [START storage_remote_backend_local_file]
resource "local_file" "backend" {
  file_permission = "0644"
  filename        = "${path.module}/backend.tf"

  # You can store the template in a file and use the templatefile function for
  # more modularity, if you prefer, instead of storing the template inline as
  # we do here.
  content = <<-EOT
  terraform {
    backend "gcs" {
      bucket = "${module.storage.storage_bucket_name}"
      prefix = "${terraform.workspace}"
    }
  }
  EOT
}
