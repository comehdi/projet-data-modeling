# =====================================================
# Script PowerShell de démarrage des services MDM
# =====================================================

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Démarrage des services MDM" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier que Docker est en cours d'exécution
try {
    docker info | Out-Null
} catch {
    Write-Host "Erreur: Docker n'est pas en cours d'exécution" -ForegroundColor Red
    exit 1
}

# Vérifier si c'est la première fois
$airflowDbExists = docker volume ls -q | Select-String "projet-data-modeling_airflow_db_data"

if (-not $airflowDbExists) {
    Write-Host "Première initialisation d'Airflow..." -ForegroundColor Yellow
    docker-compose --profile init up airflow-init
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠️  Erreur lors de l'initialisation. Tentative avec initialisation automatique..." -ForegroundColor Yellow
    }
}

# Démarrer tous les services (sans OpenMetadata - géré séparément)
Write-Host "Démarrage des services de base..." -ForegroundColor Yellow
Write-Host "  Note: OpenMetadata n'est pas démarré (géré séparément)" -ForegroundColor Gray
docker-compose up -d

Write-Host ""
Write-Host "ℹ️  OpenMetadata n'est pas démarré avec ce projet." -ForegroundColor Yellow
Write-Host "   OpenMetadata doit être géré séparément pour éviter les conflits de ports." -ForegroundColor Gray
Write-Host "   Si vous souhaitez le démarrer via ce projet (non recommandé si déjà en cours) :" -ForegroundColor Gray
Write-Host "   docker-compose --profile openmetadata-init up openmetadata-migrate" -ForegroundColor DarkGray
Write-Host "   docker-compose --profile openmetadata up -d openmetadata-server" -ForegroundColor DarkGray

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "Services démarrés !" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Services disponibles :" -ForegroundColor Cyan
Write-Host "  - PostgreSQL MDM Hub:     localhost:5432"
$openmetadataRunning = docker-compose ps | Select-String "openmetadata-server"
if ($openmetadataRunning) {
    Write-Host "  - OpenMetadata Server:    http://localhost:8585"
}
Write-Host "  - Airflow Webserver:      http://localhost:8081 (admin/admin)"
Write-Host "  - Kafka:                  localhost:9092"
Write-Host "  - Zookeeper:              localhost:2181"
Write-Host ""
Write-Host "Pour voir les logs :" -ForegroundColor Yellow
Write-Host "  docker-compose logs -f"
Write-Host ""
Write-Host "Pour arrêter les services :" -ForegroundColor Yellow
Write-Host "  docker-compose down"

