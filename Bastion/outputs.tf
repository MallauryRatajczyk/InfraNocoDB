
output "instance_ip" {
  value       = google_compute_address.static_ip_bastion.address
  description = "Adresse IP publique de la VM"
}

output "instance_name" {
  value = google_compute_instance.bastion-instance.name
}