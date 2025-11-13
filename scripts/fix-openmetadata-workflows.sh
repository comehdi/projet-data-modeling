#!/usr/bin/env bash
# =====================================================
# Script pour corriger les workflows OpenMetadata
# Remplace localhost:8585 par openmetadata-server:8585
# =====================================================

set -e

CONTAINER_NAME="openmetadata-ingestion"
DAGS_DIR="/opt/airflow/dags"
CONFIGS_DIR="/opt/airflow/dag_generated_configs"

echo "Correction des workflows OpenMetadata..."

# Remplacer localhost:8585 par openmetadata-server:8585 dans les DAGs Python
if docker exec "$CONTAINER_NAME" find "$DAGS_DIR" -name "*.py" -type f 2>/dev/null | grep -q .; then
  echo "Correction des DAGs Python..."
  docker exec "$CONTAINER_NAME" find "$DAGS_DIR" -name "*.py" -type f -exec sed -i 's|http://localhost:8585|http://openmetadata-server:8585|g' {} \;
  docker exec "$CONTAINER_NAME" find "$DAGS_DIR" -name "*.py" -type f -exec sed -i "s|'localhost:8585'|'openmetadata-server:8585'|g" {} \;
  docker exec "$CONTAINER_NAME" find "$DAGS_DIR" -name "*.py" -type f -exec sed -i 's|"localhost:8585"|"openmetadata-server:8585"|g' {} \;
fi

# Remplacer localhost:8585 par openmetadata-server:8585 dans les fichiers de configuration JSON
if docker exec "$CONTAINER_NAME" find "$CONFIGS_DIR" -name "*.json" -type f 2>/dev/null | grep -q .; then
  echo "Correction des fichiers de configuration JSON..."
  docker exec "$CONTAINER_NAME" find "$CONFIGS_DIR" -name "*.json" -type f -exec sed -i 's|http://localhost:8585|http://openmetadata-server:8585|g' {} \;
  docker exec "$CONTAINER_NAME" find "$CONFIGS_DIR" -name "*.json" -type f -exec sed -i 's|localhost:8585|openmetadata-server:8585|g' {} \;
fi

echo "✅ Correction terminée!"

