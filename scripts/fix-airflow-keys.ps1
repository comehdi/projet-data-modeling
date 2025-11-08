# =====================================================
# Script pour générer et configurer les clés Airflow
# =====================================================

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Génération des clés Airflow" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Générer FERNET_KEY
Write-Host "Génération de FERNET_KEY..." -ForegroundColor Yellow
$fernetKey = docker run --rm apache/airflow:2.8.0 python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())" 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "Erreur lors de la génération de FERNET_KEY" -ForegroundColor Red
    Write-Host "Utilisation d'une clé par défaut..." -ForegroundColor Yellow
    $fernetKey = "dummy_fernet_key_replace_me"
} else {
    $fernetKey = $fernetKey.Trim()
    Write-Host "✓ FERNET_KEY générée" -ForegroundColor Green
}

# Générer SECRET_KEY (32 caractères aléatoires)
Write-Host "Génération de SECRET_KEY..." -ForegroundColor Yellow
$secretKey = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | ForEach-Object {[char]$_})
Write-Host "✓ SECRET_KEY générée" -ForegroundColor Green

Write-Host ""
Write-Host "Clés générées :" -ForegroundColor Cyan
Write-Host "  FERNET_KEY: $($fernetKey.Substring(0, [Math]::Min(20, $fernetKey.Length)))..." -ForegroundColor Gray
Write-Host "  SECRET_KEY: $($secretKey.Substring(0, [Math]::Min(20, $secretKey.Length)))..." -ForegroundColor Gray
Write-Host ""

# Mettre à jour docker-compose.yml
Write-Host "Mise à jour de docker-compose.yml..." -ForegroundColor Yellow

$composeFile = "docker-compose.yml"
$content = Get-Content $composeFile -Raw

# Remplacer les clés vides dans airflow-webserver
$content = $content -replace "AIRFLOW__CORE__FERNET_KEY=", "AIRFLOW__CORE__FERNET_KEY=$fernetKey"
$content = $content -replace "AIRFLOW__WEBSERVER__SECRET_KEY=", "AIRFLOW__WEBSERVER__SECRET_KEY=$secretKey"

# Remplacer dans airflow-scheduler
$content = $content -replace "(?s)(airflow-scheduler:.*?AIRFLOW__CORE__FERNET_KEY=)(?=.*?AIRFLOW__CORE__DAGS_ARE_PAUSED)", "`$1$fernetKey"

# Remplacer dans airflow-init
$content = $content -replace "(?s)(airflow-init:.*?AIRFLOW__CORE__FERNET_KEY=)(?=.*?AIRFLOW__CORE__SECURITY)", "`$1$fernetKey"

Set-Content -Path $composeFile -Value $content -NoNewline

Write-Host "✓ docker-compose.yml mis à jour" -ForegroundColor Green
Write-Host ""
Write-Host "Prochaines étapes :" -ForegroundColor Cyan
Write-Host "  1. Arrêter les services : docker-compose down" -ForegroundColor Gray
Write-Host "  2. Supprimer le volume Airflow (optionnel) : docker volume rm projet-data-modeling_airflow_db_data" -ForegroundColor Gray
Write-Host "  3. Réinitialiser Airflow : docker-compose --profile init up airflow-init" -ForegroundColor Gray
Write-Host "  4. Redémarrer : docker-compose up -d" -ForegroundColor Gray
Write-Host ""

