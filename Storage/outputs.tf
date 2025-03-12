output "storage_instance_ips" {
  value = google_sql_database_instance.postgres_instance.public_ip
}
