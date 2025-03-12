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
variable "gcp_hostname" {
  type    = string
  default = "monitoring.local"
}

variable "ssh_key_file" {
  type    = string
  default = "~/.ssh/id_rsa"
}

variable "ssh_user" {
  type    = string
  default = "jordan.nankoo"
}

variable "static_ip" {
  type    = string
  default = "static-ip-monitoring"
}

variable "instance_name" {
  type    = string
  default = "monitoring"
}

variable "tags" {
  type    = list(string)
  default = ["http-server", "https-server"]
}

variable "disk_name" {
  type    = string
  default = "monitoring-data-disk"
}

variable "firewall" {
  type    = string
  default = "jordan-http-https-ssh"
}