variable "gcp_project" {
  type        = string
  default     = "project-quickdata"
}
variable "gcp_zone" {
  type        = string
  default     = "europe-west9-b"
}

variable "gcp_region" {
  type        = string
  default     = "europe-west9"
}

variable "ci_runner_instance_type" {
  type        = string
  default     = "e2-micro"
}
variable "hostname" {
  type        = string
  default     = "sql.local"
}
