import os
import json
import psycopg2
from google.cloud import secretmanager
from google.cloud import storage

def handler(request):
    # Récupérer les informations de connexion à la DB depuis Secret Manager
    secret_name = os.environ['DB_SECRET_NAME']
    bucket_name = os.environ['BUCKET_NAME']
    
    # Initialiser les clients GCP
    secret_client = secretmanager.SecretManagerServiceClient()
    storage_client = storage.Client()

    # Accéder aux secrets
    project_id = os.getenv('GCP_PROJECT_ID')
    secret_path = secret_client.secret_version_path(project_id, secret_name, "latest")
    secret_response = secret_client.access_secret_version(name=secret_path)
    secret_data = json.loads(secret_response.payload.data.decode("UTF-8"))

    # Paramètres de la base de données
    dbname = secret_data['dbname']
    user = secret_data['username']
    password = secret_data['password']
    host = secret_data['host']
    port = secret_data['port']

    # Connexion à la base de données PostgreSQL
    conn = psycopg2.connect(dbname=dbname, user=user, password=password, host=host, port=port)
    cur = conn.cursor()

    # Créer un dump de la base de données PostgreSQL
    dump_file = "/tmp/backup.sql"
    with open(dump_file, 'wb') as f:
        cur.copy_expert(f"COPY {dbname} TO STDOUT WITH CSV HEADER", f)
    
    # Sauvegarder le dump dans GCS
    bucket = storage_client.get_bucket(bucket_name)
    blob = bucket.blob(f"backup_{dbname}.sql")
    blob.upload_from_filename(dump_file)

    return "Backup successful"
