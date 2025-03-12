module "bastion" {
  source = "./Bastion"

  instance_name = "${terraform.workspace}-bastion-instance"
  static_ip     = "${terraform.workspace}-static-ip-bastion"
  ssh_key_file  = var.ssh_key_file
  ssh_user      = var.ssh_user
}

module "monitoring" {
  source       = "./Monitoring"
  ssh_key_file = var.ssh_key_file
  ssh_user     = var.ssh_user
}

module "nocodb" {
  source = "./NocoDB"
}

module "storage" {
  source = "./Storage"
  user   = var.user
}