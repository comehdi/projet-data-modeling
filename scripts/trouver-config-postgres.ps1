# Trouver la configuration PostgreSQL
Write-Host "Recherche de la configuration PostgreSQL..." -ForegroundColor Cyan

$files = docker exec openmetadata-ingestion sh -lc "ls /opt/airflow/dag_generated_configs/*.json"

foreach ($file in $files) {
    $file = $file.Trim()
    if ([string]::IsNullOrEmpty($file)) { continue }
    
    $type = docker exec openmetadata-ingestion sh -lc "cat $file | python3 -c 'import json, sys; d=json.load(sys.stdin); print(d.get(\"sourceConfig\", {}).get(\"config\", {}).get(\"type\", \"unknown\"))'"
    
    Write-Host "Fichier: $(Split-Path -Leaf $file)" -ForegroundColor White
    Write-Host "  Type: $type" -ForegroundColor Gray
    
    if ($type -match "Postgres") {
        Write-Host "  ✅ Configuration PostgreSQL trouvée!" -ForegroundColor Green
        Write-Host "  Chemin: $file" -ForegroundColor Yellow
        $script:postgresConfig = $file
        break
    }
}

if ([string]::IsNullOrEmpty($script:postgresConfig)) {
    Write-Host "❌ Aucune configuration PostgreSQL trouvée" -ForegroundColor Red
    Write-Host "Vérifiez que vous avez configuré le service Database dans OpenMetadata UI" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "Configuration PostgreSQL: $script:postgresConfig" -ForegroundColor Green
}

