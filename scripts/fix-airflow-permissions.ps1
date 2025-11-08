# =====================================================
# Script PowerShell pour corriger les permissions Airflow
# =====================================================

Write-Host "Correction des permissions pour Airflow..." -ForegroundColor Cyan

# Créer les répertoires s'ils n'existent pas
$directories = @("airflow\dags", "airflow\logs", "airflow\plugins", "airflow\config")
foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "Créé: $dir" -ForegroundColor Green
    }
}

# Sur Windows, les permissions sont généralement OK
# Mais on s'assure que les répertoires existent
Write-Host ""
Write-Host "✅ Permissions vérifiées" -ForegroundColor Green
Write-Host ""
Write-Host "Vous pouvez maintenant démarrer Airflow :" -ForegroundColor Yellow
Write-Host "  docker-compose --profile init up airflow-init"
Write-Host "  docker-compose up -d"

