#!/usr/bin/env bash
# =====================================================
# Script d'initialisation de la base de données Airflow
# pour OpenMetadata Ingestion
# =====================================================

set -e

echo "Initialisation de la base de données Airflow pour OpenMetadata Ingestion..."

# Attendre que la base de données soit prête
until docker exec openmetadata-db psql -U postgres -c '\q' 2>/dev/null; do
  echo "En attente de la base de données OpenMetadata..."
  sleep 2
done

# Créer la base de données airflow_db si elle n'existe pas
docker exec openmetadata-db psql -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'airflow_db'" | grep -q 1 || \
  docker exec openmetadata-db psql -U postgres -c "CREATE DATABASE airflow_db;"

# Créer l'utilisateur airflow_user si il n'existe pas
docker exec openmetadata-db psql -U postgres -tc "SELECT 1 FROM pg_roles WHERE rolname = 'airflow_user'" | grep -q 1 || \
  docker exec openmetadata-db psql -U postgres -c "CREATE USER airflow_user WITH PASSWORD 'airflow_pass';"

# Donner les permissions à l'utilisateur
docker exec openmetadata-db psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE airflow_db TO airflow_user;"
docker exec openmetadata-db psql -U postgres -d airflow_db -c "GRANT ALL ON SCHEMA public TO airflow_user;"

echo "✅ Base de données Airflow initialisée avec succès!"

