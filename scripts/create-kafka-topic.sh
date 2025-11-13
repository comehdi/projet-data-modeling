#!/bin/bash
# =====================================================
# Script pour créer le topic Kafka new_patient_registrations
# Phase 5.1 : Implémenter le Flux Temps Réel (Kafka)
# =====================================================

set -e

TOPIC_NAME=${1:-"new_patient_registrations"}
PARTITIONS=${2:-1}
REPLICATION_FACTOR=${3:-1}

echo "========================================"
echo "Création du topic Kafka"
echo "========================================"
echo ""

# Vérifier que Kafka est démarré
echo "1. Vérification de l'état de Kafka..."
if ! docker ps | grep -q "kafka"; then
    echo "  ❌ Kafka n'est pas démarré. Démarrage..."
    docker-compose up -d kafka
    echo "  Attente de 15 secondes pour que Kafka soit prêt..."
    sleep 15
else
    echo "  ✅ Kafka est démarré"
fi
echo ""

# Vérifier que Zookeeper est démarré
echo "2. Vérification de l'état de Zookeeper..."
if ! docker ps | grep -q "zookeeper"; then
    echo "  ❌ Zookeeper n'est pas démarré. Démarrage..."
    docker-compose up -d zookeeper
    echo "  Attente de 10 secondes pour que Zookeeper soit prêt..."
    sleep 10
else
    echo "  ✅ Zookeeper est démarré"
fi
echo ""

# Attendre que Kafka soit vraiment prêt
echo "3. Attente de la disponibilité de Kafka..."
max_retries=10
retry_count=0
kafka_ready=false

while [ $retry_count -lt $max_retries ] && [ "$kafka_ready" = false ]; do
    if docker exec kafka kafka-broker-api-versions --bootstrap-server localhost:9092 > /dev/null 2>&1; then
        kafka_ready=true
        echo "  ✅ Kafka est prêt"
    else
        retry_count=$((retry_count + 1))
        echo "  Attente... ($retry_count/$max_retries)"
        sleep 3
    fi
done

if [ "$kafka_ready" = false ]; then
    echo "  ❌ Kafka n'est pas prêt après $max_retries tentatives"
    exit 1
fi
echo ""

# Vérifier si le topic existe déjà
echo "4. Vérification de l'existence du topic '$TOPIC_NAME'..."
if docker exec kafka kafka-topics --list --bootstrap-server localhost:9092 2>&1 | grep -q "^${TOPIC_NAME}$"; then
    echo "  ⚠️  Le topic '$TOPIC_NAME' existe déjà"
    echo "  Voulez-vous le supprimer et le recréer ? (O/N)"
    read -r response
    
    if [ "$response" = "O" ] || [ "$response" = "o" ] || [ "$response" = "Y" ] || [ "$response" = "y" ]; then
        echo "  Suppression du topic existant..."
        docker exec kafka kafka-topics --delete --topic "$TOPIC_NAME" --bootstrap-server localhost:9092
        sleep 2
    else
        echo "  ✅ Utilisation du topic existant"
        exit 0
    fi
else
    echo "  ℹ️  Le topic '$TOPIC_NAME' n'existe pas encore"
fi
echo ""

# Créer le topic
echo "5. Création du topic '$TOPIC_NAME'..."
echo "   Partitions: $PARTITIONS"
echo "   Replication Factor: $REPLICATION_FACTOR"

if docker exec kafka kafka-topics --create \
    --topic "$TOPIC_NAME" \
    --bootstrap-server localhost:9092 \
    --partitions "$PARTITIONS" \
    --replication-factor "$REPLICATION_FACTOR"; then
    echo "  ✅ Topic créé avec succès"
else
    echo "  ❌ Erreur lors de la création du topic"
    exit 1
fi
echo ""

# Vérifier que le topic est bien créé
echo "6. Vérification de la création..."
sleep 2

if docker exec kafka kafka-topics --list --bootstrap-server localhost:9092 2>&1 | grep -q "^${TOPIC_NAME}$"; then
    echo "  ✅ Le topic '$TOPIC_NAME' est bien créé"
else
    echo "  ⚠️  Le topic n'apparaît pas dans la liste"
fi
echo ""

# Afficher les détails du topic
echo "7. Détails du topic..."
docker exec kafka kafka-topics --describe --topic "$TOPIC_NAME" --bootstrap-server localhost:9092 2>&1
echo ""

# Résumé
echo "========================================"
echo "Résumé"
echo "========================================"
echo ""
echo "✅ Topic créé : $TOPIC_NAME"
echo "   Partitions: $PARTITIONS"
echo "   Replication Factor: $REPLICATION_FACTOR"
echo ""
echo "📋 Commandes utiles :"
echo "   Lister les topics :"
echo "     docker exec kafka kafka-topics --list --bootstrap-server localhost:9092"
echo ""
echo "   Consulter le topic (consumer) :"
echo "     docker exec -it kafka kafka-console-consumer --topic $TOPIC_NAME --from-beginning --bootstrap-server localhost:9092"
echo ""
echo "   Publier dans le topic (producer) :"
echo "     docker exec -it kafka kafka-console-producer --topic $TOPIC_NAME --bootstrap-server localhost:9092"
echo ""
echo "   Détails du topic :"
echo "     docker exec kafka kafka-topics --describe --topic $TOPIC_NAME --bootstrap-server localhost:9092"
echo ""

