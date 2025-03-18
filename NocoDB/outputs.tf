output "nocodb_instance_ip" {
  value       = google_compute_address.static_ip_nocodb.address
  description = "Adresse IP publique de la VM"
}

output "nocodb_instance_names" {
  value = google_compute_instance.nocodb-instance.*.name
}

output "nocodb_instance_private_ip" {
  value = google_compute_instance.nocodb-instance.*.network_interface.0.network_ip
}