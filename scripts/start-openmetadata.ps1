# =====================================================
# Script PowerShell de démarrage d'OpenMetadata (standalone)
# =====================================================

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Démarrage d'OpenMetadata (standalone)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier que Docker est en cours d'exécution
try {
    docker info | Out-Null
} catch {
    Write-Host "Erreur: Docker n'est pas en cours d'exécution" -ForegroundColor Red
    exit 1
}

# Créer le répertoire pour les volumes si nécessaire
if (-not (Test-Path "docker-volume\db-data-postgres")) {
    New-Item -ItemType Directory -Path "docker-volume\db-data-postgres" -Force | Out-Null
}

# Démarrer OpenMetadata
Write-Host "Démarrage des services OpenMetadata..." -ForegroundColor Yellow
docker-compose -f docker-compose.openmetadata.yml up -d

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "OpenMetadata démarré !" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Services disponibles :" -ForegroundColor Cyan
Write-Host "  - OpenMetadata Server:    http://localhost:8585"
Write-Host "  - PostgreSQL:             localhost:5432"
Write-Host "  - Elasticsearch:          localhost:9200"
Write-Host ""
Write-Host "Identifiants de connexion :" -ForegroundColor Cyan
Write-Host "  Email: admin@open-metadata.org"
Write-Host "  Password: admin"
Write-Host ""
Write-Host "Pour voir les logs :" -ForegroundColor Yellow
Write-Host "  docker-compose -f docker-compose.openmetadata.yml logs -f"
Write-Host ""
Write-Host "Pour arrêter les services :" -ForegroundColor Yellow
Write-Host "  docker-compose -f docker-compose.openmetadata.yml down"

