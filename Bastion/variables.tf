variable "gcp_project" {
  type    = string
  default = "project-quickdata"
}

variable "gcp_zone" {
  type    = string
  default = "europe-west9-b"
}

variable "gcp_region" {
  type    = string
  default = "europe-west9"
}

variable "ci_runner_instance_type" {
  type    = string
  default = "e2-medium"
}

variable "hostname" {
  type    = string
  default = "bastion.local"
}

variable "ssh_user" {
  type    = string
  default = "engineer"
}

variable "ssh_key_file" {
  type    = string
  default = "~/.ssh/google_compute_engine"
}

variable "static_ip" {
  type    = string
  default = "static-ip-bastion"
}

variable "instance_name" {
  type    = string
  default = "bastion-instance"
}

variable "tags" {
  type    = list(string)
  default = ["bastion"]
}

variable "firewall" {
  type    = string
  default = "allow-bastion"
}

variable "network" {
  type    = string
  default = "default"
}

variable "nocodb" {
  type    = string
  default = "34.163.251.126"
}

variable "monitoring" {
  type    = string
  default = "34.163.103.61"
}