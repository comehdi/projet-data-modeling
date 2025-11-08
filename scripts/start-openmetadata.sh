#!/bin/bash
# =====================================================
# Script de démarrage d'OpenMetadata (standalone)
# =====================================================

set -e

echo "=========================================="
echo "Démarrage d'OpenMetadata (standalone)"
echo "=========================================="

# Vérifier que Docker est en cours d'exécution
if ! docker info > /dev/null 2>&1; then
    echo "Erreur: Docker n'est pas en cours d'exécution"
    exit 1
fi

# Créer le répertoire pour les volumes si nécessaire
mkdir -p docker-volume/db-data-postgres

# Démarrer OpenMetadata
echo "Démarrage des services OpenMetadata..."
docker-compose -f docker-compose.openmetadata.yml up -d

echo ""
echo "=========================================="
echo "OpenMetadata démarré !"
echo "=========================================="
echo ""
echo "Services disponibles :"
echo "  - OpenMetadata Server:    http://localhost:8585"
echo "  - PostgreSQL:             localhost:5432"
echo "  - Elasticsearch:          localhost:9200"
echo ""
echo "Identifiants de connexion :"
echo "  Email: admin@open-metadata.org"
echo "  Password: admin"
echo ""
echo "Pour voir les logs :"
echo "  docker-compose -f docker-compose.openmetadata.yml logs -f"
echo ""
echo "Pour arrêter les services :"
echo "  docker-compose -f docker-compose.openmetadata.yml down"

