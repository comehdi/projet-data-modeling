# =====================================================
# Script pour créer le topic Kafka new_patient_registrations
# Phase 5.1 : Implémenter le Flux Temps Réel (Kafka)
# =====================================================

param(
    [string]$TopicName = "new_patient_registrations",
    [int]$Partitions = 1,
    [int]$ReplicationFactor = 1
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Création du topic Kafka" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier que Kafka est démarré
Write-Host "1. Vérification de l'état de Kafka..." -ForegroundColor Yellow
$kafkaStatus = docker ps --filter "name=kafka" --format "{{.Status}}"

if (-not $kafkaStatus) {
    Write-Host "  ❌ Kafka n'est pas démarré. Démarrage..." -ForegroundColor Red
    docker-compose up -d kafka
    Write-Host "  Attente de 15 secondes pour que Kafka soit prêt..." -ForegroundColor Gray
    Start-Sleep -Seconds 15
} else {
    Write-Host "  ✅ Kafka est démarré : $kafkaStatus" -ForegroundColor Green
}
Write-Host ""

# Vérifier que Zookeeper est démarré
Write-Host "2. Vérification de l'état de Zookeeper..." -ForegroundColor Yellow
$zookeeperStatus = docker ps --filter "name=zookeeper" --format "{{.Status}}"

if (-not $zookeeperStatus) {
    Write-Host "  ❌ Zookeeper n'est pas démarré. Démarrage..." -ForegroundColor Red
    docker-compose up -d zookeeper
    Write-Host "  Attente de 10 secondes pour que Zookeeper soit prêt..." -ForegroundColor Gray
    Start-Sleep -Seconds 10
} else {
    Write-Host "  ✅ Zookeeper est démarré : $zookeeperStatus" -ForegroundColor Green
}
Write-Host ""

# Attendre que Kafka soit vraiment prêt
Write-Host "3. Attente de la disponibilité de Kafka..." -ForegroundColor Yellow
$maxRetries = 10
$retryCount = 0
$kafkaReady = $false

while ($retryCount -lt $maxRetries -and -not $kafkaReady) {
    try {
        $result = docker exec kafka kafka-broker-api-versions --bootstrap-server localhost:9092 2>&1
        if ($LASTEXITCODE -eq 0) {
            $kafkaReady = $true
            Write-Host "  ✅ Kafka est prêt" -ForegroundColor Green
        }
    } catch {
        # Ignorer l'erreur
    }
    
    if (-not $kafkaReady) {
        $retryCount++
        Write-Host "  Attente... ($retryCount/$maxRetries)" -ForegroundColor Gray
        Start-Sleep -Seconds 3
    }
}

if (-not $kafkaReady) {
    Write-Host "  ❌ Kafka n'est pas prêt après $maxRetries tentatives" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Vérifier si le topic existe déjà
Write-Host "4. Vérification de l'existence du topic '$TopicName'..." -ForegroundColor Yellow
$topicExists = docker exec kafka kafka-topics --list --bootstrap-server localhost:9092 2>&1 | Select-String -Pattern "^$TopicName$"

if ($topicExists) {
    Write-Host "  ⚠️  Le topic '$TopicName' existe déjà" -ForegroundColor Yellow
    Write-Host "  Voulez-vous le supprimer et le recréer ? (O/N)" -ForegroundColor Yellow
    $response = Read-Host
    
    if ($response -eq "O" -or $response -eq "o" -or $response -eq "Y" -or $response -eq "y") {
        Write-Host "  Suppression du topic existant..." -ForegroundColor Gray
        docker exec kafka kafka-topics --delete --topic $TopicName --bootstrap-server localhost:9092
        Start-Sleep -Seconds 2
    } else {
        Write-Host "  ✅ Utilisation du topic existant" -ForegroundColor Green
        exit 0
    }
} else {
    Write-Host "  ℹ️  Le topic '$TopicName' n'existe pas encore" -ForegroundColor Gray
}
Write-Host ""

# Créer le topic
Write-Host "5. Création du topic '$TopicName'..." -ForegroundColor Yellow
Write-Host "   Partitions: $Partitions" -ForegroundColor Gray
Write-Host "   Replication Factor: $ReplicationFactor" -ForegroundColor Gray

$createTopicCmd = "kafka-topics --create --topic $TopicName --bootstrap-server localhost:9092 --partitions $Partitions --replication-factor $ReplicationFactor"
$createResult = docker exec kafka $createTopicCmd 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✅ Topic créé avec succès" -ForegroundColor Green
} else {
    Write-Host "  ❌ Erreur lors de la création du topic :" -ForegroundColor Red
    Write-Host "  $createResult" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Vérifier que le topic est bien créé
Write-Host "6. Vérification de la création..." -ForegroundColor Yellow
Start-Sleep -Seconds 2

$topics = docker exec kafka kafka-topics --list --bootstrap-server localhost:9092 2>&1
$topicFound = $topics | Select-String -Pattern "^$TopicName$"

if ($topicFound) {
    Write-Host "  ✅ Le topic '$TopicName' est bien créé" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Le topic n'apparaît pas dans la liste" -ForegroundColor Yellow
}
Write-Host ""

# Afficher les détails du topic
Write-Host "7. Détails du topic..." -ForegroundColor Yellow
$topicDetails = docker exec kafka kafka-topics --describe --topic $TopicName --bootstrap-server localhost:9092 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "  $topicDetails" -ForegroundColor Gray
} else {
    Write-Host "  ⚠️  Impossible d'obtenir les détails du topic" -ForegroundColor Yellow
}
Write-Host ""

# Résumé
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Résumé" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Topic créé : $TopicName" -ForegroundColor Green
Write-Host "   Partitions: $Partitions" -ForegroundColor White
Write-Host "   Replication Factor: $ReplicationFactor" -ForegroundColor White
Write-Host ""
Write-Host "📋 Commandes utiles :" -ForegroundColor Cyan
Write-Host "   Lister les topics :" -ForegroundColor Yellow
Write-Host "     docker exec kafka kafka-topics --list --bootstrap-server localhost:9092" -ForegroundColor Gray
Write-Host ""
Write-Host "   Consulter le topic (consumer) :" -ForegroundColor Yellow
Write-Host "     docker exec -it kafka kafka-console-consumer --topic $TopicName --from-beginning --bootstrap-server localhost:9092" -ForegroundColor Gray
Write-Host ""
Write-Host "   Publier dans le topic (producer) :" -ForegroundColor Yellow
Write-Host "     docker exec -it kafka kafka-console-producer --topic $TopicName --bootstrap-server localhost:9092" -ForegroundColor Gray
Write-Host ""
Write-Host "   Détails du topic :" -ForegroundColor Yellow
Write-Host "     docker exec kafka kafka-topics --describe --topic $TopicName --bootstrap-server localhost:9092" -ForegroundColor Gray
Write-Host ""

