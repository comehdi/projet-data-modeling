-- =====================================================
-- Script d'initialisation PostgreSQL pour OpenMetadata
-- Active l'extension pg_stat_statements pour les métriques de requêtes
-- =====================================================

-- Activer l'extension pg_stat_statements dans la base de données
-- Cette extension est nécessaire pour que OpenMetadata puisse collecter
-- des métriques sur les requêtes SQL exécutées
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Vérifier que l'extension est bien installée
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_extension WHERE extname = 'pg_stat_statements'
    ) THEN
        RAISE EXCEPTION 'L''extension pg_stat_statements n''a pas pu être installée';
    END IF;
END $$;

