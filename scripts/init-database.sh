#!/bin/bash
# =====================================================
# Script d'initialisation de la base de données MDM
# =====================================================

set -e

echo "=========================================="
echo "Initialisation de la base de données MDM"
echo "=========================================="

# Attendre que PostgreSQL soit prêt
echo "Attente de la disponibilité de PostgreSQL..."
until PGPASSWORD=mdm_password psql -h localhost -U mdm_user -d mdm_clinique -c '\q' 2>/dev/null; do
  echo "PostgreSQL n'est pas encore prêt, attente de 2 secondes..."
  sleep 2
done

echo "PostgreSQL est prêt !"

# Exécuter le script de création des tables
echo "Création des tables MDM..."
PGPASSWORD=mdm_password psql -h localhost -U mdm_user -d mdm_clinique -f sql/01-create-tables.sql

echo "=========================================="
echo "Initialisation terminée avec succès !"
echo "=========================================="
echo ""
echo "Tables créées :"
echo "  - MDM_Patient"
echo "  - MDM_Praticien"
echo "  - MDM_Service"
echo "  - MDM_Location"
echo ""
echo "Vous pouvez maintenant vous connecter à la base de données :"
echo "  Host: localhost"
echo "  Port: 5432"
echo "  Database: mdm_clinique"
echo "  User: mdm_user"
echo "  Password: mdm_password"

