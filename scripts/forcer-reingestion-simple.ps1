# =====================================================
# Script simple pour forcer une réingestion complète
# =====================================================

Write-Host "Forcer une réingestion complète dans OpenMetadata..." -ForegroundColor Cyan
Write-Host ""

# Trouver le DAG ID
$dagId = "e02a3b57-dd5c-4417-a76e-4b59333f1270"

# Relancer l'ingestion
Write-Host "Relance de l'ingestion..." -ForegroundColor Yellow
$response = docker exec openmetadata-ingestion sh -lc "curl -s -u admin:admin -X POST -H 'Content-Type: application/json' -d '{}' http://localhost:8080/api/v1/dags/$dagId/dagRuns"

if ($response -match '"dag_run_id"') {
    $runId = ($response | ConvertFrom-Json).dag_run_id
    Write-Host "✅ Ingestion relancée - Run ID: $runId" -ForegroundColor Green
    Write-Host ""
    Write-Host "Attente de la fin (30-60 secondes)..." -ForegroundColor Yellow
    
    Start-Sleep -Seconds 30
    
    # Vérifier le statut
    $statusJson = docker exec openmetadata-ingestion sh -lc "curl -s -u admin:admin http://localhost:8080/api/v1/dags/$dagId/dagRuns/$runId"
    $status = $statusJson | ConvertFrom-Json
    
    Write-Host "État: $($status.state)" -ForegroundColor $(if ($status.state -eq "success") { "Green" } else { "Yellow" })
    Write-Host ""
    
    # Afficher les logs récents
    Write-Host "Résultats de l'ingestion:" -ForegroundColor Cyan
    docker exec openmetadata-ingestion sh -lc "ls -t /opt/airflow/logs/dag_id=$dagId/run_id=*/task_id=ingestion_task/attempt=1.log 2>/dev/null | head -1 | xargs tail -15 | grep -E 'Processed|Updated|Filtered|Success' -i"
    
} else {
    Write-Host "❌ Erreur lors du déclenchement" -ForegroundColor Red
    Write-Host "Réponse: $response" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Pour vérifier dans OpenMetadata:" -ForegroundColor Cyan
Write-Host "  http://localhost:8585 > Explore > Databases > MDM Clinique Hub" -ForegroundColor White
Write-Host ""

