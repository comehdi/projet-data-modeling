# =====================================================
# Script pour relancer l'ingestion OpenMetadata
# =====================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Relance de l'ingestion OpenMetadata" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Trouver le DAG ID du pipeline d'ingestion
Write-Host "1. Recherche du pipeline d'ingestion..." -ForegroundColor Yellow
$dagId = docker exec openmetadata-ingestion sh -lc "curl -s -u admin:admin http://localhost:8080/api/v1/dags?limit=100 | python -c 'import json,sys;dags=[d for d in json.load(sys.stdin)[\"dags\"] if \"MDM Clinique Hub\" in d.get(\"dag_display_name\",\"\") or d.get(\"dag_display_name\",\"\").startswith(\"Metadata Agent\")];print(dags[0][\"dag_id\"] if dags else \"\")'"

if ([string]::IsNullOrEmpty($dagId)) {
    Write-Host "  ❌ Pipeline d'ingestion non trouvé" -ForegroundColor Red
    Write-Host "  Vérifiez que le service 'MDM Clinique Hub' est configuré dans OpenMetadata" -ForegroundColor Yellow
    exit 1
}

Write-Host "  ✅ Pipeline trouvé: $dagId" -ForegroundColor Green
Write-Host ""

# 2. Déclencher un nouveau run
Write-Host "2. Déclenchement d'un nouveau run..." -ForegroundColor Yellow
$response = docker exec openmetadata-ingestion sh -lc "curl -s -u admin:admin -X POST -H 'Content-Type: application/json' -d '{}' http://localhost:8080/api/v1/dags/$dagId/dagRuns"

if ($response -match '"dag_run_id"') {
    Write-Host "  ✅ Run déclenché avec succès" -ForegroundColor Green
    $runId = ($response | ConvertFrom-Json).dag_run_id
    Write-Host "  Run ID: $runId" -ForegroundColor Gray
} else {
    Write-Host "  ❌ Erreur lors du déclenchement" -ForegroundColor Red
    Write-Host "  Réponse: $response" -ForegroundColor Gray
    exit 1
}

Write-Host ""

# 3. Attendre que le run se termine
Write-Host "3. Attente de la fin de l'exécution..." -ForegroundColor Yellow
$maxWait = 60  # Maximum 60 secondes
$waited = 0
$interval = 3

while ($waited -lt $maxWait) {
    Start-Sleep -Seconds $interval
    $waited += $interval
    
    $status = docker exec openmetadata-ingestion sh -lc "curl -s -u admin:admin http://localhost:8080/api/v1/dags/$dagId/dagRuns/$runId" | ConvertFrom-Json
    
    if ($status.state -eq "success") {
        Write-Host "  ✅ Ingestion terminée avec succès" -ForegroundColor Green
        break
    } elseif ($status.state -eq "failed") {
        Write-Host "  ❌ Ingestion échouée" -ForegroundColor Red
        Write-Host "  Consultez les logs dans OpenMetadata UI ou via:" -ForegroundColor Yellow
        Write-Host "    docker logs openmetadata-ingestion --tail 100" -ForegroundColor Gray
        exit 1
    } else {
        Write-Host "  ⏳ État: $($status.state) (attente: ${waited}s)" -ForegroundColor Gray
    }
}

if ($waited -ge $maxWait) {
    Write-Host "  ⚠️  Timeout atteint, mais le run continue en arrière-plan" -ForegroundColor Yellow
}

Write-Host ""

# 4. Afficher un résumé
Write-Host "4. Résumé:" -ForegroundColor Yellow
Write-Host "  - Pipeline: $dagId" -ForegroundColor White
Write-Host "  - Run ID: $runId" -ForegroundColor White
Write-Host "  - État: $($status.state)" -ForegroundColor White
Write-Host ""

Write-Host "Pour voir les logs détaillés:" -ForegroundColor Cyan
Write-Host "  docker exec openmetadata-ingestion sh -lc 'ls -t /opt/airflow/logs/dag_id=$dagId/run_id=*/task_id=ingestion_task/attempt=1.log | head -1 | xargs tail -100'" -ForegroundColor Gray
Write-Host ""

Write-Host "Pour vérifier dans OpenMetadata UI:" -ForegroundColor Cyan
Write-Host "  1. Allez dans http://localhost:8585" -ForegroundColor White
Write-Host "  2. Settings > Services > Databases > MDM Clinique Hub" -ForegroundColor White
Write-Host "  3. Onglet 'Ingestion Pipelines' > Cliquez sur le pipeline" -ForegroundColor White
Write-Host "  4. Vérifiez l'onglet 'Runs' pour voir les logs" -ForegroundColor White
Write-Host ""

