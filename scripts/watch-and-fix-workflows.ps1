# =====================================================
# Script pour surveiller et corriger automatiquement
# les workflows OpenMetadata
# =====================================================

$CONTAINER_NAME = "openmetadata-ingestion"
$DAGS_DIR = "/opt/airflow/dags"
$CONFIGS_DIR = "/opt/airflow/dag_generated_configs"

Write-Host "Surveillance des workflows OpenMetadata..." -ForegroundColor Cyan
Write-Host "Appuyez sur Ctrl+C pour arrêter" -ForegroundColor Yellow

while ($true) {
    # Corriger les DAGs Python
    $pyFiles = docker exec $CONTAINER_NAME find $DAGS_DIR -name "*.py" -type f -newermt "1 minute ago" 2>&1
    if ($pyFiles -and $pyFiles -notmatch "No such file") {
        foreach ($file in $pyFiles) {
            if ($file -and $file.Trim()) {
                $content = docker exec $CONTAINER_NAME cat $file.Trim() 2>&1
                if ($content -match "localhost:8585") {
                    Write-Host "Correction de $file..." -ForegroundColor Yellow
                    docker exec $CONTAINER_NAME sed -i 's|http://localhost:8585|http://openmetadata-server:8585|g' $file.Trim() 2>&1 | Out-Null
                    docker exec $CONTAINER_NAME sed -i "s|'localhost:8585'|'openmetadata-server:8585'|g" $file.Trim() 2>&1 | Out-Null
                    docker exec $CONTAINER_NAME sed -i 's|"localhost:8585"|"openmetadata-server:8585"|g' $file.Trim() 2>&1 | Out-Null
                }
            }
        }
    }

    # Corriger les fichiers JSON
    $jsonFiles = docker exec $CONTAINER_NAME find $CONFIGS_DIR -name "*.json" -type f -newermt "1 minute ago" 2>&1
    if ($jsonFiles -and $jsonFiles -notmatch "No such file") {
        foreach ($file in $jsonFiles) {
            if ($file -and $file.Trim()) {
                $content = docker exec $CONTAINER_NAME cat $file.Trim() 2>&1
                if ($content -match "localhost:8585") {
                    Write-Host "Correction de $file..." -ForegroundColor Yellow
                    docker exec $CONTAINER_NAME sed -i 's|http://localhost:8585|http://openmetadata-server:8585|g' $file.Trim() 2>&1 | Out-Null
                    docker exec $CONTAINER_NAME sed -i 's|localhost:8585|openmetadata-server:8585|g' $file.Trim() 2>&1 | Out-Null
                }
            }
        }
    }

    Start-Sleep -Seconds 5
}

