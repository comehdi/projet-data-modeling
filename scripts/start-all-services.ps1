# =====================================================
# Script pour démarrer tous les services du projet MDM
# =====================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Démarrage de tous les services MDM" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Services de base (PostgreSQL MDM, Kafka, Zookeeper, Airflow DB, Redis)
Write-Host "1. Démarrage des services de base..." -ForegroundColor Yellow
docker-compose up -d postgres-mdm-hub zookeeper kafka airflow-db airflow-redis

if ($LASTEXITCODE -ne 0) {
    Write-Host "  ❌ Erreur lors du démarrage des services de base" -ForegroundColor Red
    exit 1
}

Write-Host "  ✅ Services de base démarrés" -ForegroundColor Green
Write-Host "  Attente de la stabilisation (10 secondes)..." -ForegroundColor Gray
Start-Sleep -Seconds 10
Write-Host ""

# 2. Initialiser Airflow (si nécessaire)
Write-Host "2. Vérification de l'initialisation Airflow..." -ForegroundColor Yellow
$airflowDbExists = docker exec airflow-db psql -U airflow -d airflow -c "SELECT 1;" 2>&1 | Select-String -Pattern "1 row"

if (-not $airflowDbExists) {
    Write-Host "  Initialisation de la base de données Airflow..." -ForegroundColor Gray
    docker-compose up airflow-init
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ❌ Erreur lors de l'initialisation Airflow" -ForegroundColor Red
        exit 1
    }
    Write-Host "  ✅ Airflow initialisé" -ForegroundColor Green
} else {
    Write-Host "  ✅ Base de données Airflow déjà initialisée" -ForegroundColor Green
}
Write-Host ""

# 3. Démarrer Airflow (webserver et scheduler)
Write-Host "3. Démarrage d'Airflow..." -ForegroundColor Yellow
docker-compose up -d airflow-webserver airflow-scheduler

if ($LASTEXITCODE -ne 0) {
    Write-Host "  ❌ Erreur lors du démarrage d'Airflow" -ForegroundColor Red
    exit 1
}

Write-Host "  ✅ Airflow démarré" -ForegroundColor Green
Write-Host "  Attente de la stabilisation (15 secondes)..." -ForegroundColor Gray
Start-Sleep -Seconds 15
Write-Host ""

# 4. Initialiser OpenMetadata Airflow (si nécessaire)
Write-Host "4. Vérification de l'initialisation OpenMetadata Airflow..." -ForegroundColor Yellow
$omAirflowDbExists = docker exec openmetadata-db psql -U postgres -d airflow_db -c "SELECT 1;" 2>&1 | Select-String -Pattern "1 row"

if (-not $omAirflowDbExists) {
    Write-Host "  Initialisation de la base de données Airflow pour OpenMetadata..." -ForegroundColor Gray
    .\scripts\init-openmetadata-airflow.ps1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ❌ Erreur lors de l'initialisation OpenMetadata Airflow" -ForegroundColor Red
        exit 1
    }
    Write-Host "  ✅ OpenMetadata Airflow initialisé" -ForegroundColor Green
} else {
    Write-Host "  ✅ Base de données OpenMetadata Airflow déjà initialisée" -ForegroundColor Green
}
Write-Host ""

# 5. Démarrer OpenMetadata (db, elasticsearch)
Write-Host "5. Démarrage des services OpenMetadata de base..." -ForegroundColor Yellow
docker-compose --profile openmetadata up -d openmetadata-db elasticsearch

if ($LASTEXITCODE -ne 0) {
    Write-Host "  ❌ Erreur lors du démarrage des services OpenMetadata de base" -ForegroundColor Red
    exit 1
}

Write-Host "  ✅ Services OpenMetadata de base démarrés" -ForegroundColor Green
Write-Host "  Attente de la stabilisation (20 secondes)..." -ForegroundColor Gray
Start-Sleep -Seconds 20
Write-Host ""

# 6. Migration OpenMetadata (si nécessaire)
Write-Host "6. Vérification de la migration OpenMetadata..." -ForegroundColor Yellow
$omDbExists = docker exec openmetadata-db psql -U postgres -d openmetadata_db -c "SELECT 1 FROM information_schema.tables WHERE table_name = 'entity_relationship' LIMIT 1;" 2>&1 | Select-String -Pattern "1 row"

if (-not $omDbExists) {
    Write-Host "  Exécution de la migration OpenMetadata..." -ForegroundColor Gray
    docker-compose --profile openmetadata-init up openmetadata-migrate
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ❌ Erreur lors de la migration OpenMetadata" -ForegroundColor Red
        exit 1
    }
    Write-Host "  ✅ Migration OpenMetadata terminée" -ForegroundColor Green
} else {
    Write-Host "  ✅ Base de données OpenMetadata déjà migrée" -ForegroundColor Green
}
Write-Host ""

# 7. Démarrer tous les services OpenMetadata
Write-Host "7. Démarrage de tous les services OpenMetadata..." -ForegroundColor Yellow
docker-compose --profile openmetadata up -d

if ($LASTEXITCODE -ne 0) {
    Write-Host "  ❌ Erreur lors du démarrage des services OpenMetadata" -ForegroundColor Red
    exit 1
}

Write-Host "  ✅ Services OpenMetadata démarrés" -ForegroundColor Green
Write-Host "  Attente de la stabilisation (30 secondes)..." -ForegroundColor Gray
Start-Sleep -Seconds 30
Write-Host ""

# 8. Vérification de l'état des services
Write-Host "8. Vérification de l'état des services..." -ForegroundColor Yellow
Write-Host ""

$services = @(
    @{Name="postgres-mdm-hub"; Port=5432; Description="PostgreSQL MDM Hub"},
    @{Name="airflow-webserver"; Port=8081; Description="Airflow (Projet MDM)"},
    @{Name="openmetadata-server"; Port=8585; Description="OpenMetadata Server"},
    @{Name="openmetadata-ingestion"; Port=8080; Description="Airflow OpenMetadata"},
    @{Name="kafka"; Port=9092; Description="Kafka"},
    @{Name="openmetadata-elasticsearch"; Port=9200; Description="Elasticsearch"}
)

foreach ($service in $services) {
    $status = docker ps --filter "name=$($service.Name)" --format "{{.Status}}"
    if ($status) {
        Write-Host "  ✅ $($service.Description) - Port $($service.Port)" -ForegroundColor Green
        Write-Host "     Statut: $status" -ForegroundColor Gray
    } else {
        Write-Host "  ❌ $($service.Description) - Port $($service.Port)" -ForegroundColor Red
        Write-Host "     Service non démarré" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Résumé des URLs d'accès" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📊 Airflow (Projet MDM):" -ForegroundColor White
Write-Host "   http://localhost:8081" -ForegroundColor Gray
Write-Host "   Email: admin / Password: admin" -ForegroundColor Gray
Write-Host ""
Write-Host "📊 Airflow (OpenMetadata):" -ForegroundColor White
Write-Host "   http://localhost:8080" -ForegroundColor Gray
Write-Host "   Email: admin / Password: admin" -ForegroundColor Gray
Write-Host ""
Write-Host "📊 OpenMetadata:" -ForegroundColor White
Write-Host "   http://localhost:8585" -ForegroundColor Gray
Write-Host "   Email: admin@open-metadata.org / Password: admin" -ForegroundColor Gray
Write-Host ""
Write-Host "📊 PostgreSQL MDM Hub:" -ForegroundColor White
Write-Host "   localhost:5432" -ForegroundColor Gray
Write-Host "   User: postgres / Password: root" -ForegroundColor Gray
Write-Host ""
Write-Host "📊 Kafka:" -ForegroundColor White
Write-Host "   localhost:9092" -ForegroundColor Gray
Write-Host ""
Write-Host "Tous les services sont demarres!" -ForegroundColor Green
Write-Host ""

