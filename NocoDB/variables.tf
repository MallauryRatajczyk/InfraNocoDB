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
  default = "nocodb.local"
}

variable "ssh_user" {
  type    = string
  default = "Mallaury"
}

variable "ssh_key_file" {
  type    = string
  default = "~/.ssh/google_compute_engine"
}

variable "static_ip" {
  type    = string
  default = "static-ip-nocodb"
}

variable "instance_name" {
  type    = string
  default = "nocodb-instance"
}

variable "disk_name" {
  type    = string
  default = "monitoring-data-disk"
}

variable "firewall" {
  type = list(object({
    name          = string
    tags          = list(string)
    source_ranges = list(string)
    ports         = list(string)
  }))
  default = [{
    name          = "allow-node-exporter"
    tags          = ["node-exporter"]
    source_ranges = ["34.163.103.61/32"]
    ports         = ["9100"]
    }, {
    name          = "allow-custom-port"
    tags          = ["custom-port"]
    source_ranges = ["34.155.139.235/32"]
    ports         = ["32222"]
  }]
}