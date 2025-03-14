output "storage_instance_ip" {
  value = google_sql_database_instance.postgres_instance.public_ip_address
}

output "storage_bucket_name" {
  value = google_storage_bucket.my_bucket.name
}