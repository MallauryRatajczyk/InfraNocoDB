variable "gcp_project" {
  type        = string
  default     = "project-quickdata"
}

variable "region" {
  description = "La région où déployer les ressources"
  type        = string
  default     = "europe-west9"
}

variable "zones" {
  description = "Les zones dans la région pour le déploiement"
  type        = list(string)
  default     = ["europe-west9-b"]
}

variable "cidr_ranges" {
  description = "Les plages CIDR des sous-réseaux"
  type = map(string)
  default = {
    nocodb    = "10.10.1.0/24"
    bastion     = "10.10.2.0/24"
    storage  = "10.10.3.0/24"
    monitoring = "10.10.4.0/24"
  }
}

variable "vpc_name" {
  description = "VPC"
  type        = string
  default     = "rocketvpc"
}
