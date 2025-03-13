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
variable "ansible_user" {
  type    = string
  default = "engineer"
}

variable "ssh_key_file" {
  type    = string
  default = "~/.ssh/google_compute_engine"
}

variable "vpc_name" {
  description = "Nom du réseau VPC"
  type        = string
  default     = "rocketvpc"  
}

variable "subnet_nocodb" {
  description = "Nom du sous-réseau de NocoDB"
  type        = string
  default     = "subnet-nocodb"  
}
