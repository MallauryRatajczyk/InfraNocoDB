provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
  zone    = var.gcp_zone
}

##########################################
#     Configuration Base de données      #
##########################################
# Configuration de l'instance SQL PostgreSQL
resource "google_sql_database_instance" "postgres_instance" {
  name                = var.database.instance
  database_version    = var.database.version
  region              = var.gcp_region
  deletion_protection = "false"

  settings {
    tier              = "db-f1-micro"
    availability_type = "REGIONAL" # Vous pouvez ajuster en fonction de vos besoins
    backup_configuration {
      enabled    = true
      start_time = "23:00"
    }

    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        name  = var.network
        value = "0.0.0.0/0" # Assurez-vous de la sécurité de votre base avec cette configuration ouverte
      }
    }
  }
}

# Configuration de la base de données PostgreSQL
resource "google_sql_database" "database" {
  name     = var.database.name
  instance = google_sql_database_instance.postgres_instance.name
}

# Création d'un utilisateur pour la base de données PostgreSQL
resource "google_sql_user" "users" {
  name     = var.user.name
  instance = google_sql_database_instance.postgres_instance.name
  password = var.user.password # Veillez à utiliser un mot de passe sécurisé
}

##########################################
#           Configuration Backup         #
##########################################
# Bucket for store dump
resource "google_storage_bucket" "my_bucket" {
  name          = var.dump_bucket
  location      = var.gcp_region
  storage_class = "COLDLINE" #Type de stockage (STANDARD, NEARLINE, COLDLINE, etc.) pourquoi codline a rajouter au dossier

  versioning { #Active la gestion des versions des fichiers
    enabled = true
  }
}

# TOPIC PUB/SUB for trigger
resource "google_pubsub_topic" "pg_dump_topic" {
  name = var.topic
}

resource "google_cloud_scheduler_job" "pg_dump_schedule" { #Définit une ressource Cloud Scheduler Job qui planifie une tâche récurrente.
  name        = var.scheduler_job.name
  description = "Scheduled job to trigger PostgreSQL dump"
  schedule    = var.scheduler_job.schedule
  time_zone   = var.scheduler_job.time_zone
  region      = var.scheduler_job.region

  pubsub_target {
    topic_name = google_pubsub_topic.pg_dump_topic.id #Définit une ressource Pub/Sub Topic nommée pg_dump_topic.
    data       = base64encode("Trigger dump")         # Ce topic servira à envoyer un message lorsqu'on veut déclencher l'exécution du pg_dump.
  }
}

# Bucket for storage of python file
resource "google_storage_bucket" "function_bucket" {
  name     = var.function_bucket
  location = var.gcp_region
}

resource "google_storage_bucket_object" "function_code" {
  name   = var.object_bucket.name
  bucket = google_storage_bucket.function_bucket.name
  source = var.object_bucket.source # Fichier ZIP contenant le code Python de la fonction
}

resource "google_cloudfunctions2_function" "pg_dump_function" {
  name        = var.dump_cloud_function.name
  location    = var.gcp_region
  description = "Function for dump"

  build_config {
    runtime     = "python310"
    entry_point = var.dump_cloud_function.entry_point
    environment_variables = {
      PG_HOST                = google_sql_database_instance.postgres_instance.public_ip_address
      PG_USER                = "${var.user.name}"
      PG_PASSWORD            = "${var.user.name}"
      PG_DB                  = "${var.database.name}"
      BUCKET_NAME            = google_storage_bucket.my_bucket.name
      GOOGLE_FUNCTION_SOURCE = "${var.dump_cloud_function.file_name}"
    }
    source {
      storage_source {
        bucket = google_storage_bucket.function_bucket.name
        object = google_storage_bucket_object.function_code.name
      }
    }
  }

  event_trigger {
    event_type   = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic = google_pubsub_topic.pg_dump_topic.id
  }
}