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
  default = "e2-micro"
}
variable "hostname" {
  type    = string
  default = "sql.local"
}

variable "user" {
  type = object({
    name     = string
    password = string
  })
  sensitive = true
}

variable "database" {
  type = object({
    name     = string
    instance = string
    version  = string
  })
  default = {
    name     = "mydatabase"
    instance = "my-postgres-db"
    version  = "POSTGRES_15"
  }
}

variable "dump_bucket" {
  type    = string
  default = "rocket-storage-bucket-name"
}

variable "topic" {
  type    = string
  default = "pg-dump-topic"
}

variable "scheduler_job" {
  type = object({
    name      = string
    schedule  = string
    time_zone = string
    region    = string
  })
  default = {
    name      = "pg-dump-schedule"
    schedule  = "0 2 * * *"
    time_zone = "Europe/Paris"
    region    = "europe-west2"
  }
}

variable "function_bucket" {
  type    = string
  default = "rocket-cloud-function-bucket"
}

variable "object_bucket" {
  type = object({
    name   = string
    source = string
  })
  default = {
    name   = "dump_postgres.zip"
    source = "./dump_postgres.zip"
  }
}

variable "dump_cloud_function" {
  type = object({
    name        = string
    entry_point = string
    file_name   = string
  })
  default = {
    name        = "pg-dump-function"
    entry_point = "dump_postgres"
    file_name   = "dump_postgres.py"
  }
}