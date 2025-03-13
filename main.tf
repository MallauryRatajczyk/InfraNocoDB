locals {
  network = "${terraform.workspace}-network"
}

module "bastion" {
  source = "./Bastion"

  instance_name = "${terraform.workspace}-bastion-instance"
  static_ip     = "${terraform.workspace}-static-ip-bastion"
  network       = local.network

  ssh_key_file = var.ssh_key_file
  ssh_user     = var.ssh_user
}

module "monitoring" {
  source = "./Monitoring"

  instance_name = "${terraform.workspace}-monitoring-instance"
  static_ip     = "${terraform.workspace}-static-ip-monitoring"
  disk_name     = "${terraform.workspace}-monitoring-data-disk"
  network       = local.network

  ssh_key_file = var.ssh_key_file
  ssh_user     = var.ssh_user
}

module "nocodb" {
  source = "./NocoDB"

  instance = {
    name  = "${terraform.workspace}-nocodb"
    count = (terraform.workspace == "production") ? 2 : 1
  }
  static_ip = "${terraform.workspace}-static-ip-nocodb"
  disk_name = "${terraform.workspace}-monitoring-data-disk"
  network   = local.network

  ssh_key_file = var.ssh_key_file
  ssh_user     = var.ssh_user
}

module "storage" {
  source = "./Storage"

  database = {
    name     = "${terraform.workspace}-mydatabase"
    instance = "${terraform.workspace}-my-postgres-db"
    version  = "POSTGRES_15"
  }
  dump_bucket = "${terraform.workspace}-rocket-storage-bucket-name"
  topic       = "${terraform.workspace}-pg-dump-topic"
  scheduler_job = {
    name      = "${terraform.workspace}-pg-dump-schedule"
    schedule  = "0 2 * * *"
    time_zone = "Europe/Paris"
    region    = "europe-west2"
  }
  function_bucket = "${terraform.workspace}-rocket-cloud-function-bucket"
  dump_cloud_function = {
    name        = "${terraform.workspace}-pg-dump-function"
    entry_point = "dump_postgres"
    file_name   = "dump_postgres.py"
  }
  user = var.user
}

# [START storage_remote_backend_local_file]
resource "local_file" "backend" {
  file_permission = "0644"
  filename        = "./backend.tf"

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
