# =====================================================
# Script pour déclencher le DAG mdm_pipeline
# =====================================================

Write-Host "Déclenchement du DAG mdm_pipeline..." -ForegroundColor Cyan
Write-Host ""

# Déclencher le DAG
$result = docker exec airflow-webserver airflow dags trigger mdm_pipeline 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ DAG déclenché avec succès!" -ForegroundColor Green
    Write-Host $result
} else {
    Write-Host "❌ Erreur lors du déclenchement" -ForegroundColor Red
    Write-Host $result
    exit 1
}

Write-Host ""
Write-Host "Vérification du statut..." -ForegroundColor Yellow
Start-Sleep -Seconds 2

# Afficher le dernier run
Write-Host ""
Write-Host "Dernier run créé:" -ForegroundColor Yellow
docker exec airflow-webserver airflow dags list-runs -d mdm_pipeline --no-backfill 2>&1 | Select-Object -Last 1

Write-Host ""
Write-Host "Pour suivre l'exécution:" -ForegroundColor Green
Write-Host "  1. Interface web: http://localhost:8081 (admin/admin)" -ForegroundColor White
Write-Host "  2. Logs en temps réel:" -ForegroundColor White
Write-Host "     docker-compose logs -f airflow-scheduler" -ForegroundColor Gray
Write-Host ""
Write-Host "Pour vérifier les données insérées:" -ForegroundColor Green
Write-Host "  docker exec postgres-mdm-hub psql -U postgres -d mdm_clinique -c `"SELECT 'mdm_patient' as table_name, COUNT(*) as count FROM mdm_patient UNION ALL SELECT 'mdm_praticien', COUNT(*) FROM mdm_praticien UNION ALL SELECT 'mdm_service', COUNT(*) FROM mdm_service UNION ALL SELECT 'mdm_location', COUNT(*) FROM mdm_location;`"" -ForegroundColor Gray

