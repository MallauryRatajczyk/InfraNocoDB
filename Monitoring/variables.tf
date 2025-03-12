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
  default     = "e2-medium"
}
variable "gcp_hostname" {
  type        = string
  default     = "monitoring.local"
}
variable "credentials_file" {
  type        = string
  default     = "/Users/karinenankoo/.config/gcloud/application_default_credentials.json"
}
variable "ssh_key_file" {
  type = string
  default = "~/.ssh/id_rsa"
}