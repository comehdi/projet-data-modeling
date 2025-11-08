#!/bin/bash
# =====================================================
# Script d'arrêt des services MDM
# =====================================================

echo "=========================================="
echo "Arrêt des services MDM"
echo "=========================================="

docker-compose down

echo ""
echo "Services arrêtés."
echo ""
echo "Pour supprimer également les volumes (ATTENTION: supprime les données) :"
echo "  docker-compose down -v"

