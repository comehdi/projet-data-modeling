# =====================================================
# Script de vérification du statut du DAG mdm_pipeline
# =====================================================

Write-Host "Vérification du DAG mdm_pipeline..." -ForegroundColor Cyan
Write-Host ""

# 1. Vérifier si le DAG est chargé
Write-Host "1. Liste des DAGs (recherche 'mdm'):" -ForegroundColor Yellow
docker exec airflow-webserver airflow dags list | Select-String -Pattern "mdm"

Write-Host ""
Write-Host "2. État du DAG:" -ForegroundColor Yellow
docker exec airflow-webserver airflow dags show mdm_pipeline 2>&1 | Select-Object -First 5

Write-Host ""
Write-Host "3. Derniers runs (échecs):" -ForegroundColor Yellow
docker exec airflow-webserver airflow dags list-runs -d mdm_pipeline --state failed --no-backfill 2>&1 | Select-Object -Last 3

Write-Host ""
Write-Host "4. Derniers runs (tous):" -ForegroundColor Yellow
docker exec airflow-webserver airflow dags list-runs -d mdm_pipeline --no-backfill 2>&1 | Select-Object -Last 3

Write-Host ""
Write-Host "5. Pour voir le DAG dans l'interface web:" -ForegroundColor Green
Write-Host "   - URL: http://localhost:8081" -ForegroundColor White
Write-Host "   - Identifiants: admin / admin" -ForegroundColor White
Write-Host "   - Cherche 'mdm_pipeline' dans la barre de recherche" -ForegroundColor White
Write-Host "   - Ou filtre par tag: mdm ou talend" -ForegroundColor White

Write-Host ""
Write-Host "6. Pour déclencher un nouveau run:" -ForegroundColor Green
Write-Host "   docker exec airflow-webserver airflow dags trigger mdm_pipeline" -ForegroundColor White

