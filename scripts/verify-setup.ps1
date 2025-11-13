# =====================================================
# Script PowerShell de vérification de l'environnement MDM
# Vérifie que tous les services de Phase 1 et Phase 2 fonctionnent
# =====================================================

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Vérification de l'environnement MDM" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$errors = @()
$warnings = @()

# =====================================================
# 1. Vérifier Docker
# =====================================================
Write-Host "[1/8] Vérification de Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "  ✓ Docker installé: $dockerVersion" -ForegroundColor Green
    
    docker info | Out-Null
    Write-Host "  ✓ Docker est en cours d'exécution" -ForegroundColor Green
} catch {
    $errors += "Docker n'est pas installé ou n'est pas en cours d'exécution"
    Write-Host "  ✗ Erreur: Docker n'est pas disponible" -ForegroundColor Red
    exit 1
}

# =====================================================
# 2. Vérifier Docker Compose
# =====================================================
Write-Host "[2/8] Vérification de Docker Compose..." -ForegroundColor Yellow
try {
    $composeVersion = docker-compose --version
    Write-Host "  ✓ Docker Compose installé: $composeVersion" -ForegroundColor Green
} catch {
    $errors += "Docker Compose n'est pas installé"
    Write-Host "  ✗ Erreur: Docker Compose n'est pas disponible" -ForegroundColor Red
}

# =====================================================
# 3. Vérifier les fichiers de configuration
# =====================================================
Write-Host "[3/8] Vérification des fichiers de configuration..." -ForegroundColor Yellow
$requiredFiles = @(
    "docker-compose.yml",
    "sql/01-create-tables.sql"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "  ✓ $file existe" -ForegroundColor Green
    } else {
        $errors += "Fichier manquant: $file"
        Write-Host "  ✗ Fichier manquant: $file" -ForegroundColor Red
    }
}

# =====================================================
# 4. Démarrer les services
# =====================================================
Write-Host "[4/8] Démarrage des services..." -ForegroundColor Yellow

# Vérifier si c'est la première fois (Airflow)
$airflowDbExists = docker volume ls -q | Select-String "projet-data-modeling_airflow_db_data"

if (-not $airflowDbExists) {
    Write-Host "  ℹ️  Première initialisation d'Airflow..." -ForegroundColor Cyan
    Write-Host "     Exécution de: docker-compose --profile init up airflow-init" -ForegroundColor Gray
    docker-compose --profile init up airflow-init 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Airflow initialisé" -ForegroundColor Green
    } else {
        $warnings += "L'initialisation d'Airflow a peut-être échoué, mais on continue..."
        Write-Host "  ⚠️  Avertissement lors de l'initialisation d'Airflow" -ForegroundColor Yellow
    }
}

# Démarrer tous les services
Write-Host "  ℹ️  Démarrage de tous les services..." -ForegroundColor Cyan
docker-compose up -d 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Services démarrés" -ForegroundColor Green
} else {
    $errors += "Erreur lors du démarrage des services Docker"
    Write-Host "  ✗ Erreur lors du démarrage des services" -ForegroundColor Red
}

# Attendre que les services soient prêts
Write-Host "  ℹ️  Attente du démarrage des services (30 secondes)..." -ForegroundColor Cyan
Start-Sleep -Seconds 30

# =====================================================
# 5. Vérifier l'état des conteneurs
# =====================================================
Write-Host "[5/8] Vérification de l'état des conteneurs..." -ForegroundColor Yellow

$expectedContainers = @(
    "postgres-mdm-hub",
    "airflow-db",
    "airflow-redis",
    "airflow-webserver",
    "airflow-scheduler",
    "kafka",
    "zookeeper"
)
# Note: OpenMetadata services are excluded as they run separately

$runningContainers = docker ps --format "{{.Names}}"

foreach ($container in $expectedContainers) {
    if ($runningContainers -match $container) {
        $status = docker inspect --format='{{.State.Status}}' $container 2>&1
        if ($status -eq "running") {
            Write-Host "  ✓ $container est en cours d'exécution" -ForegroundColor Green
        } else {
            $errors += "$container n'est pas en cours d'exécution (statut: $status)"
            Write-Host "  ✗ $container n'est pas en cours d'exécution (statut: $status)" -ForegroundColor Red
        }
    } else {
        $warnings += "$container n'est pas démarré"
        Write-Host "  ⚠️  $container n'est pas démarré" -ForegroundColor Yellow
    }
}

# =====================================================
# 6. Vérifier PostgreSQL MDM Hub
# =====================================================
Write-Host "[6/8] Vérification de PostgreSQL MDM Hub..." -ForegroundColor Yellow

# Attendre que PostgreSQL soit prêt
$maxRetries = 10
$retryCount = 0
$postgresReady = $false

while ($retryCount -lt $maxRetries -and -not $postgresReady) {
    try {
        $result = docker exec postgres-mdm-hub pg_isready -U mdm_user -d mdm_clinique 2>&1
        if ($result -match "accepting connections") {
            $postgresReady = $true
            Write-Host "  ✓ PostgreSQL est prêt" -ForegroundColor Green
        }
    } catch {
        # Continue
    }
    
    if (-not $postgresReady) {
        $retryCount++
        Start-Sleep -Seconds 3
    }
}

if (-not $postgresReady) {
    $errors += "PostgreSQL n'est pas prêt après plusieurs tentatives"
    Write-Host "  ✗ PostgreSQL n'est pas prêt" -ForegroundColor Red
} else {
    # Vérifier que les tables existent
    Write-Host "  ℹ️  Vérification des tables MDM..." -ForegroundColor Cyan
    $tablesQuery = "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE 'MDM_%' ORDER BY table_name;"
    $tablesResult = docker exec postgres-mdm-hub psql -U mdm_user -d mdm_clinique -t -c $tablesQuery 2>&1
    
    $expectedTables = @("MDM_Patient", "MDM_Praticien", "MDM_Service", "MDM_Location")
    $foundTables = @()
    
    foreach ($line in $tablesResult) {
        $tableName = $line.Trim()
        if ($tableName -and $tableName -match "MDM_") {
            $foundTables += $tableName
        }
    }
    
    foreach ($table in $expectedTables) {
        if ($foundTables -contains $table) {
            Write-Host "    ✓ Table $table existe" -ForegroundColor Green
        } else {
            $errors += "Table manquante: $table"
            Write-Host "    ✗ Table manquante: $table" -ForegroundColor Red
        }
    }
    
    # Vérifier le nombre de colonnes pour chaque table
    Write-Host "  ℹ️  Vérification de la structure des tables..." -ForegroundColor Cyan
    foreach ($table in $expectedTables) {
        if ($foundTables -contains $table) {
            $columnQuery = "SELECT COUNT(*) FROM information_schema.columns WHERE table_name = '$table';"
            $columnCount = docker exec postgres-mdm-hub psql -U mdm_user -d mdm_clinique -t -c $columnQuery 2>&1
            $columnCount = $columnCount.Trim()
            if ($columnCount -match "^\d+$" -and [int]$columnCount -gt 0) {
                Write-Host "    ✓ $table a $columnCount colonnes" -ForegroundColor Green
            }
        }
    }
}

# =====================================================
# 7. Vérifier Airflow
# =====================================================
Write-Host "[7/8] Vérification d'Airflow..." -ForegroundColor Yellow

# Vérifier que le webserver répond
$maxRetries = 15
$retryCount = 0
$airflowReady = $false

while ($retryCount -lt $maxRetries -and -not $airflowReady) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8081/health" -TimeoutSec 5 -UseBasicParsing -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $airflowReady = $true
            Write-Host "  ✓ Airflow Webserver est accessible" -ForegroundColor Green
        }
    } catch {
        # Continue
    }
    
    if (-not $airflowReady) {
        $retryCount++
        Start-Sleep -Seconds 4
    }
}

if (-not $airflowReady) {
    $warnings += "Airflow Webserver n'est pas encore accessible (peut prendre plus de temps)"
    Write-Host "  ⚠️  Airflow Webserver n'est pas encore accessible" -ForegroundColor Yellow
    Write-Host "     URL: http://localhost:8081 (admin/admin)" -ForegroundColor Gray
} else {
    Write-Host "  ✓ Airflow est accessible sur http://localhost:8081" -ForegroundColor Green
    Write-Host "    Identifiants: admin / admin" -ForegroundColor Gray
}

# =====================================================
# 8. Vérifier Kafka et Zookeeper
# =====================================================
Write-Host "[8/8] Vérification de Kafka et Zookeeper..." -ForegroundColor Yellow

# Vérifier Zookeeper
try {
    $zkResult = docker exec zookeeper nc -z localhost 2181 2>&1
    Write-Host "  ✓ Zookeeper est accessible" -ForegroundColor Green
} catch {
    $warnings += "Zookeeper n'est pas accessible"
    Write-Host "  ⚠️  Zookeeper n'est pas accessible" -ForegroundColor Yellow
}

# Vérifier Kafka
$maxRetries = 5
$retryCount = 0
$kafkaReady = $false

while ($retryCount -lt $maxRetries -and -not $kafkaReady) {
    try {
        $kafkaResult = docker exec kafka kafka-broker-api-versions --bootstrap-server localhost:9092 2>&1
        if ($LASTEXITCODE -eq 0) {
            $kafkaReady = $true
            Write-Host "  ✓ Kafka est accessible" -ForegroundColor Green
        }
    } catch {
        # Continue
    }
    
    if (-not $kafkaReady) {
        $retryCount++
        Start-Sleep -Seconds 3
    }
}

if (-not $kafkaReady) {
    $warnings += "Kafka n'est pas encore accessible"
    Write-Host "  ⚠️  Kafka n'est pas encore accessible" -ForegroundColor Yellow
}

# =====================================================
# Résumé
# =====================================================
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Résumé de la vérification" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

if ($errors.Count -eq 0) {
    Write-Host "✅ Tous les tests critiques ont réussi !" -ForegroundColor Green
} else {
    Write-Host "❌ $($errors.Count) erreur(s) critique(s) détectée(s):" -ForegroundColor Red
    foreach ($error in $errors) {
        Write-Host "   - $error" -ForegroundColor Red
    }
}

if ($warnings.Count -gt 0) {
    Write-Host ""
    Write-Host "⚠️  $($warnings.Count) avertissement(s):" -ForegroundColor Yellow
    foreach ($warning in $warnings) {
        Write-Host "   - $warning" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Services disponibles:" -ForegroundColor Cyan
Write-Host "  - PostgreSQL MDM Hub:     localhost:5432" -ForegroundColor White
Write-Host "    User: mdm_user, Password: mdm_password, DB: mdm_clinique" -ForegroundColor Gray
Write-Host "  - Airflow Webserver:      http://localhost:8081" -ForegroundColor White
Write-Host "    User: admin, Password: admin" -ForegroundColor Gray
Write-Host "  - Kafka:                  localhost:9092" -ForegroundColor White
Write-Host "  - Zookeeper:              localhost:2181" -ForegroundColor White
Write-Host ""

Write-Host "Commandes utiles:" -ForegroundColor Cyan
Write-Host "  - Voir les logs:          docker-compose logs -f" -ForegroundColor Gray
Write-Host "  - Voir l'état:            docker-compose ps" -ForegroundColor Gray
Write-Host "  - Arrêter:                docker-compose down" -ForegroundColor Gray
Write-Host "  - Se connecter à PostgreSQL:" -ForegroundColor Gray
Write-Host "    docker exec -it postgres-mdm-hub psql -U mdm_user -d mdm_clinique" -ForegroundColor DarkGray
Write-Host ""

if ($errors.Count -eq 0) {
    Write-Host "✅ Phase 1 et Phase 2 sont opérationnelles !" -ForegroundColor Green
    exit 0
} else {
    Write-Host "❌ Des problèmes ont été détectés. Veuillez les corriger." -ForegroundColor Red
    exit 1
}

