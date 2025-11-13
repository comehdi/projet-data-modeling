# =====================================================
# Script pour forcer une réingestion complète dans OpenMetadata
# =====================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Forcer une réingestion complète" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Trouver le fichier de configuration
Write-Host "1. Recherche du fichier de configuration..." -ForegroundColor Yellow
$configFile = docker exec openmetadata-ingestion sh -lc "ls /opt/airflow/dag_generated_configs/*.json | head -1"

if ([string]::IsNullOrEmpty($configFile)) {
    Write-Host "  ❌ Fichier de configuration non trouvé" -ForegroundColor Red
    exit 1
}

Write-Host "  ✅ Configuration trouvée: $configFile" -ForegroundColor Green
Write-Host ""

# 2. Sauvegarder la configuration actuelle
Write-Host "2. Sauvegarde de la configuration actuelle..." -ForegroundColor Yellow
docker exec openmetadata-ingestion sh -lc "cp $configFile ${configFile}.backup"
Write-Host "  ✅ Sauvegarde créée: ${configFile}.backup" -ForegroundColor Green
Write-Host ""

# 3. Modifier la configuration pour forcer l'override
Write-Host "3. Modification de la configuration pour forcer l'override..." -ForegroundColor Yellow
$pythonScript = @"
import json
import sys

# Lire la configuration
with open('$configFile', 'r') as f:
    config = json.load(f)

# Forcer l'override et la réingestion complète
config['sourceConfig']['config']['overrideMetadata'] = True
config['openMetadataServerConnection']['forceEntityOverwriting'] = True

# Écrire la configuration modifiée
with open('$configFile', 'w') as f:
    json.dump(config, f, indent=2)

print('Configuration modifiée avec succès')
"@

docker exec openmetadata-ingestion sh -lc "python -c `"$pythonScript`""

if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✅ Configuration modifiée" -ForegroundColor Green
} else {
    Write-Host "  ❌ Erreur lors de la modification" -ForegroundColor Red
    exit 1
}

Write-Host ""

# 4. Relancer l'ingestion
Write-Host "4. Relance de l'ingestion..." -ForegroundColor Yellow
$dagId = "e02a3b57-dd5c-4417-a76e-4b59333f1270"
$response = docker exec openmetadata-ingestion sh -lc "curl -s -u admin:admin -X POST -H 'Content-Type: application/json' -d '{}' http://localhost:8080/api/v1/dags/$dagId/dagRuns"

if ($response -match '"dag_run_id"') {
    Write-Host "  ✅ Ingestion relancée" -ForegroundColor Green
    $runId = ($response | ConvertFrom-Json).dag_run_id
    Write-Host "  Run ID: $runId" -ForegroundColor Gray
} else {
    Write-Host "  ❌ Erreur lors du déclenchement" -ForegroundColor Red
    Write-Host "  Réponse: $response" -ForegroundColor Gray
    exit 1
}

Write-Host ""

# 5. Attendre la fin
Write-Host "5. Attente de la fin de l'exécution (peut prendre 30-60 secondes)..." -ForegroundColor Yellow
$maxWait = 90
$waited = 0
$interval = 5

while ($waited -lt $maxWait) {
    Start-Sleep -Seconds $interval
    $waited += $interval
    
    $statusJson = docker exec openmetadata-ingestion sh -lc "curl -s -u admin:admin http://localhost:8080/api/v1/dags/$dagId/dagRuns/$runId"
    $status = $statusJson | ConvertFrom-Json
    
    if ($status.state -eq "success") {
        Write-Host "  ✅ Ingestion terminée avec succès" -ForegroundColor Green
        break
    } elseif ($status.state -eq "failed") {
        Write-Host "  ❌ Ingestion échouée" -ForegroundColor Red
        Write-Host "  Consultez les logs pour plus de détails" -ForegroundColor Yellow
        break
    } else {
        Write-Host "  ⏳ État: $($status.state) (attente: ${waited}s)" -ForegroundColor Gray
    }
}

Write-Host ""

# 6. Vérifier les résultats
Write-Host "6. Vérification des résultats..." -ForegroundColor Yellow
$latestLog = docker exec openmetadata-ingestion sh -lc "ls -t /opt/airflow/logs/dag_id=$dagId/run_id=*/task_id=ingestion_task/attempt=1.log 2>/dev/null | head -1 | xargs tail -20 | grep -E 'Processed|Updated|Filtered|Success' -i"

Write-Host "  Résultats de l'ingestion:" -ForegroundColor White
$latestLog | ForEach-Object { Write-Host "    $_" -ForegroundColor Gray }

Write-Host ""

Write-Host "✅ Réingestion complète terminée!" -ForegroundColor Green
Write-Host ""
Write-Host "Pour vérifier dans OpenMetadata UI:" -ForegroundColor Cyan
Write-Host "  1. Allez dans http://localhost:8585" -ForegroundColor White
Write-Host "  2. Explore > Databases > MDM Clinique Hub > mdm_clinique > public" -ForegroundColor White
Write-Host "  3. Cliquez sur une table et vérifiez l'onglet 'Schema' pour les colonnes" -ForegroundColor White
Write-Host ""

