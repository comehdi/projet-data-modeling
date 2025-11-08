# =====================================================
# Script pour redémarrer Airflow avec les nouvelles clés
# =====================================================

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Redémarrage d'Airflow" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Arrêt des services Airflow..." -ForegroundColor Yellow
docker-compose stop airflow-webserver airflow-scheduler

Write-Host "Redémarrage des services Airflow..." -ForegroundColor Yellow
docker-compose up -d airflow-webserver airflow-scheduler

Write-Host ""
Write-Host "Attente du démarrage (30 secondes)..." -ForegroundColor Cyan
Start-Sleep -Seconds 30

Write-Host ""
Write-Host "Vérification de l'état..." -ForegroundColor Yellow
docker-compose ps airflow-webserver airflow-scheduler

Write-Host ""
Write-Host "✅ Airflow redémarré !" -ForegroundColor Green
Write-Host "   Accédez à : http://localhost:8081" -ForegroundColor Cyan
Write-Host "   Username: admin" -ForegroundColor Gray
Write-Host "   Password: admin" -ForegroundColor Gray
Write-Host ""
Write-Host "Si l'erreur persiste, vous devrez peut-être réinitialiser la base de données :" -ForegroundColor Yellow
Write-Host "   docker-compose down" -ForegroundColor Gray
Write-Host "   docker volume rm projet-data-modeling_airflow_db_data" -ForegroundColor Gray
Write-Host "   docker-compose --profile init up airflow-init" -ForegroundColor Gray
Write-Host "   docker-compose up -d" -ForegroundColor Gray
Write-Host ""

