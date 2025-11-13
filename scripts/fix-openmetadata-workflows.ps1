# =====================================================
# Script PowerShell pour corriger les workflows OpenMetadata
# Remplace localhost:8585 par openmetadata-server:8585
# =====================================================

$CONTAINER_NAME = "openmetadata-ingestion"
$DAGS_DIR = "/opt/airflow/dags"
$CONFIGS_DIR = "/opt/airflow/dag_generated_configs"

Write-Host "Correction des workflows OpenMetadata..." -ForegroundColor Cyan

# Remplacer localhost:8585 par openmetadata-server:8585 dans les DAGs Python
Write-Host "Correction des DAGs Python..." -ForegroundColor Yellow
$pyFiles = docker exec $CONTAINER_NAME find $DAGS_DIR -name "*.py" -type f 2>&1
if ($pyFiles -and $pyFiles -notmatch "No such file") {
    foreach ($file in $pyFiles) {
        if ($file -and $file.Trim()) {
            docker exec $CONTAINER_NAME sed -i 's|http://localhost:8585|http://openmetadata-server:8585|g' $file.Trim() 2>&1 | Out-Null
            docker exec $CONTAINER_NAME sed -i "s|'localhost:8585'|'openmetadata-server:8585'|g" $file.Trim() 2>&1 | Out-Null
            docker exec $CONTAINER_NAME sed -i 's|"localhost:8585"|"openmetadata-server:8585"|g' $file.Trim() 2>&1 | Out-Null
        }
    }
}

# Remplacer localhost:8585 par openmetadata-server:8585 dans les fichiers de configuration JSON
Write-Host "Correction des fichiers de configuration JSON..." -ForegroundColor Yellow
$jsonFiles = docker exec $CONTAINER_NAME find $CONFIGS_DIR -name "*.json" -type f 2>&1
if ($jsonFiles -and $jsonFiles -notmatch "No such file") {
    foreach ($file in $jsonFiles) {
        if ($file -and $file.Trim()) {
            docker exec $CONTAINER_NAME sed -i 's|http://localhost:8585|http://openmetadata-server:8585|g' $file.Trim() 2>&1 | Out-Null
            docker exec $CONTAINER_NAME sed -i 's|localhost:8585|openmetadata-server:8585|g' $file.Trim() 2>&1 | Out-Null
        }
    }
}

Write-Host "✅ Correction terminée!" -ForegroundColor Green

