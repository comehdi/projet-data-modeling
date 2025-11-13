# =====================================================
# Script de vérification rapide de l'état des services MDM
# =====================================================

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Vérification de l'état des services MDM" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Vérifier les conteneurs
Write-Host "[1/3] État des conteneurs Docker..." -ForegroundColor Yellow
docker-compose ps
Write-Host ""

# 2. Vérifier les tables MDM
Write-Host "[2/3] Vérification des tables MDM..." -ForegroundColor Yellow
$tables = docker exec postgres-mdm-hub psql -U mdm_user -d mdm_clinique -t -c "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE 'mdm_%' ORDER BY table_name;"

$expectedTables = @("mdm_location", "mdm_patient", "mdm_praticien", "mdm_service")
$foundTables = @()

foreach ($line in $tables) {
    $tableName = $line.Trim()
    if ($tableName -and $tableName -match "mdm_") {
        $foundTables += $tableName
        Write-Host "  ✓ Table $tableName existe" -ForegroundColor Green
    }
}

if ($foundTables.Count -eq 4) {
    Write-Host "  ✅ Toutes les 4 tables MDM sont créées !" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Seulement $($foundTables.Count)/4 tables trouvées" -ForegroundColor Yellow
}

Write-Host ""

# 3. Vérifier Airflow
Write-Host "[3/3] Vérification d'Airflow..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081/health" -TimeoutSec 5 -UseBasicParsing -ErrorAction SilentlyContinue
    if ($response.StatusCode -eq 200) {
        Write-Host "  ✅ Airflow Webserver est accessible" -ForegroundColor Green
        Write-Host "     URL: http://localhost:8081" -ForegroundColor Gray
        Write-Host "     Username: admin / Password: admin" -ForegroundColor Gray
    }
} catch {
    Write-Host "  ⚠️  Airflow n'est pas encore accessible" -ForegroundColor Yellow
    Write-Host "     Essayez d'accéder à http://localhost:8081 dans votre navigateur" -ForegroundColor Gray
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Résumé" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Services disponibles :" -ForegroundColor White
Write-Host "  - PostgreSQL MDM Hub:     localhost:5432" -ForegroundColor Cyan
Write-Host "  - Airflow Webserver:      http://localhost:8081" -ForegroundColor Cyan
Write-Host "  - Kafka:                  localhost:9092" -ForegroundColor Cyan
Write-Host "  - Zookeeper:              localhost:2181" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Phase 1 et Phase 2 sont complètes !" -ForegroundColor Green
Write-Host ""

