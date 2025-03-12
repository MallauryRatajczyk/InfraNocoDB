
output "monitoring_instance_ip" {
  value       = google_compute_address.static_ip_monitoring.address
  description = "Adresse IP publique de la VM"
}

output "monitoring_instance_name" {
  value = google_compute_instance.prometheus_grafana_instance.name
}