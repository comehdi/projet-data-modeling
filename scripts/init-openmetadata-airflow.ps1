# =====================================================
# Script PowerShell d'initialisation de la base de données Airflow
# pour OpenMetadata Ingestion
# =====================================================

Write-Host "Initialisation de la base de données Airflow pour OpenMetadata Ingestion..." -ForegroundColor Cyan

# Attendre que la base de données soit prête
Write-Host "Vérification de la disponibilité de la base de données OpenMetadata..." -ForegroundColor Yellow
$maxRetries = 30
$retryCount = 0
$dbReady = $false

while ($retryCount -lt $maxRetries -and -not $dbReady) {
    try {
        $result = docker exec openmetadata-db psql -U postgres -c '\q' 2>&1
        if ($LASTEXITCODE -eq 0) {
            $dbReady = $true
            Write-Host "  ✅ Base de données prête" -ForegroundColor Green
        } else {
            Start-Sleep -Seconds 2
            $retryCount++
        }
    } catch {
        Start-Sleep -Seconds 2
        $retryCount++
    }
}

if (-not $dbReady) {
    Write-Host "  ❌ La base de données n'est pas prête après $maxRetries tentatives" -ForegroundColor Red
    exit 1
}

# Créer la base de données airflow_db si elle n'existe pas
Write-Host "Création de la base de données airflow_db..." -ForegroundColor Yellow
$dbExists = docker exec openmetadata-db psql -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'airflow_db'" 2>&1
if ($dbExists -match "1") {
    Write-Host "  ✅ La base de données airflow_db existe déjà" -ForegroundColor Green
} else {
    docker exec openmetadata-db psql -U postgres -c "CREATE DATABASE airflow_db;" 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Base de données airflow_db créée" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Erreur lors de la création de la base de données" -ForegroundColor Red
        exit 1
    }
}

# Créer l'utilisateur airflow_user si il n'existe pas
Write-Host "Création de l'utilisateur airflow_user..." -ForegroundColor Yellow
$userExists = docker exec openmetadata-db psql -U postgres -tc "SELECT 1 FROM pg_roles WHERE rolname = 'airflow_user'" 2>&1
if ($userExists -match "1") {
    Write-Host "  ✅ L'utilisateur airflow_user existe déjà" -ForegroundColor Green
} else {
    docker exec openmetadata-db psql -U postgres -c "CREATE USER airflow_user WITH PASSWORD 'airflow_pass';" 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Utilisateur airflow_user créé" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Erreur lors de la création de l'utilisateur" -ForegroundColor Red
        exit 1
    }
}

# Donner les permissions à l'utilisateur
Write-Host "Configuration des permissions..." -ForegroundColor Yellow
docker exec openmetadata-db psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE airflow_db TO airflow_user;" 2>&1 | Out-Null
docker exec openmetadata-db psql -U postgres -d airflow_db -c "GRANT ALL ON SCHEMA public TO airflow_user;" 2>&1 | Out-Null

Write-Host ""
Write-Host "✅ Base de données Airflow initialisée avec succès!" -ForegroundColor Green

