variable "ssh_key_file" {
  type = string
}

variable "ssh_user" {
  type = string
}

variable "user" {
  type = object({
    name     = string
    password = string
  })
  sensitive = true
}