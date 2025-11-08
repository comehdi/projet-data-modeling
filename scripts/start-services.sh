#!/bin/bash
# =====================================================
# Script de démarrage des services MDM
# =====================================================

set -e

echo "=========================================="
echo "Démarrage des services MDM"
echo "=========================================="

# Vérifier que Docker est en cours d'exécution
if ! docker info > /dev/null 2>&1; then
    echo "Erreur: Docker n'est pas en cours d'exécution"
    exit 1
fi

# Initialiser Airflow (première fois uniquement)
echo "Initialisation d'Airflow (si nécessaire)..."
docker-compose --profile init up airflow-init

# Démarrer tous les services
echo "Démarrage de tous les services..."
docker-compose up -d

echo ""
echo "=========================================="
echo "Services démarrés !"
echo "=========================================="
echo ""
echo "Services disponibles :"
echo "  - PostgreSQL MDM Hub:     localhost:5432"
echo "  - OpenMetadata Server:    http://localhost:8585"
echo "  - Airflow Webserver:      http://localhost:8080 (admin/admin)"
echo "  - Kafka:                  localhost:9092"
echo "  - Zookeeper:              localhost:2181"
echo ""
echo "Pour voir les logs :"
echo "  docker-compose logs -f"
echo ""
echo "Pour arrêter les services :"
echo "  docker-compose down"

