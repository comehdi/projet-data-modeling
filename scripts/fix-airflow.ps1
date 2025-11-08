# =====================================================
# Script PowerShell pour corriger les problèmes Airflow
# =====================================================

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Correction des problèmes Airflow" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Arrêter les services
Write-Host "Arrêt des services..." -ForegroundColor Yellow
docker-compose down

# Vérifier si l'utilisateur veut supprimer les volumes
Write-Host ""
$response = Read-Host "Voulez-vous supprimer les volumes Airflow pour une réinitialisation complète ? (o/n)"
if ($response -eq "o" -or $response -eq "O") {
    Write-Host "Suppression des volumes Airflow..." -ForegroundColor Yellow
    docker volume rm projet-data-modeling_airflow_db_data -ErrorAction SilentlyContinue
    Write-Host "✅ Volumes supprimés" -ForegroundColor Green
}

# Corriger les permissions
Write-Host ""
Write-Host "Vérification des répertoires..." -ForegroundColor Yellow
$directories = @("airflow\dags", "airflow\logs", "airflow\plugins", "airflow\config")
foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "  Créé: $dir" -ForegroundColor Green
    } else {
        Write-Host "  Existe: $dir" -ForegroundColor Gray
    }
}

# Initialiser Airflow
Write-Host ""
Write-Host "Initialisation d'Airflow..." -ForegroundColor Yellow
docker-compose --profile init up airflow-init

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Initialisation réussie !" -ForegroundColor Green
    Write-Host ""
    Write-Host "Démarrage des services..." -ForegroundColor Yellow
    docker-compose up -d
    
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "Airflow devrait maintenant fonctionner !" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Vérifiez l'état des services :" -ForegroundColor Cyan
    Write-Host "  docker-compose ps"
    Write-Host ""
    Write-Host "Voir les logs :" -ForegroundColor Cyan
    Write-Host "  docker-compose logs -f airflow-webserver"
    Write-Host ""
    Write-Host "Accéder à Airflow :" -ForegroundColor Cyan
    Write-Host "  http://localhost:8081"
    Write-Host "  Username: admin"
    Write-Host "  Password: admin"
} else {
    Write-Host ""
    Write-Host "❌ Erreur lors de l'initialisation" -ForegroundColor Red
    Write-Host ""
    Write-Host "Voir les logs pour plus de détails :" -ForegroundColor Yellow
    Write-Host "  docker-compose logs airflow-init"
}

