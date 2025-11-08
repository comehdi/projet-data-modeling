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

# Démarrer tous les services (sans OpenMetadata par défaut)
echo "Démarrage des services de base..."
docker-compose up -d

# Demander si l'utilisateur veut lancer OpenMetadata
echo ""
read -p "Voulez-vous lancer OpenMetadata maintenant ? (o/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Oo]$ ]]; then
    echo "Initialisation d'OpenMetadata..."
    docker-compose --profile openmetadata-init up openmetadata-migrate
    echo "Démarrage du serveur OpenMetadata..."
    docker-compose --profile openmetadata up -d openmetadata-server
    echo ""
    echo "✅ OpenMetadata démarré !"
    echo "   URL: http://localhost:8585"
    echo "   Email: admin@open-metadata.org"
    echo "   Password: admin"
else
    echo ""
    echo "ℹ️  OpenMetadata n'a pas été démarré."
    echo "   Pour le démarrer plus tard :"
    echo "   docker-compose --profile openmetadata-init up openmetadata-migrate"
    echo "   docker-compose --profile openmetadata up -d openmetadata-server"
    echo ""
    echo "   Ou utilisez le script standalone :"
    echo "   ./scripts/start-openmetadata.sh"
fi

echo ""
echo "=========================================="
echo "Services démarrés !"
echo "=========================================="
echo ""
echo "Services disponibles :"
echo "  - PostgreSQL MDM Hub:     localhost:5435"
if docker-compose ps | grep -q "openmetadata-server"; then
    echo "  - OpenMetadata Server:    http://localhost:8585"
fi
echo "  - Airflow Webserver:      http://localhost:8081 (admin/admin)"
echo "  - Kafka:                  localhost:9092"
echo "  - Zookeeper:              localhost:2181"
echo ""
echo "Pour voir les logs :"
echo "  docker-compose logs -f"
echo ""
echo "Pour arrêter les services :"
echo "  docker-compose down"

