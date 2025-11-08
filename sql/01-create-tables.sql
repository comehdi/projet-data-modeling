-- =====================================================
-- Script de création des tables MDM pour Groupe Santé Horizon
-- Base de données : mdm_clinique
-- Phase 1.3 : Conception des Tables Maîtres (Golden Tables)
-- =====================================================

-- Extension pour les UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- Table 1 : MDM_Patient
-- Description : Table des patients consolidés à partir de multiples systèmes
--                (hospitalisation, facturation, laboratoire...)
-- Clé primaire : master_patient_id (UUID)
-- =====================================================
CREATE TABLE MDM_Patient (
    master_patient_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    golden_first_name VARCHAR(100) NOT NULL,
    golden_last_name VARCHAR(100) NOT NULL,
    golden_date_of_birth DATE NOT NULL,
    golden_gender VARCHAR(10),
    golden_phone VARCHAR(20),
    golden_email VARCHAR(100),
    golden_address VARCHAR(255),
    blood_type VARCHAR(10),
    allergies TEXT,
    source_system_ids JSONB,         -- { "HIS": "P123", "LABSYS": "L456", "EMR": "PAT-789" }
    last_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE MDM_Patient IS 'Table des patients consolidés (Golden Records)';
COMMENT ON COLUMN MDM_Patient.master_patient_id IS 'Identifiant unique du patient consolidé (UUID)';
COMMENT ON COLUMN MDM_Patient.golden_first_name IS 'Prénom normalisé et consolidé du patient';
COMMENT ON COLUMN MDM_Patient.golden_last_name IS 'Nom de famille normalisé et consolidé du patient';
COMMENT ON COLUMN MDM_Patient.golden_date_of_birth IS 'Date de naissance consolidée (format standardisé)';
COMMENT ON COLUMN MDM_Patient.golden_gender IS 'Genre du patient (M/F/Autre)';
COMMENT ON COLUMN MDM_Patient.golden_phone IS 'Numéro de téléphone unifié au format E.164';
COMMENT ON COLUMN MDM_Patient.golden_email IS 'Adresse email consolidée et validée';
COMMENT ON COLUMN MDM_Patient.golden_address IS 'Adresse postale complète consolidée';
COMMENT ON COLUMN MDM_Patient.blood_type IS 'Groupe sanguin du patient';
COMMENT ON COLUMN MDM_Patient.allergies IS 'Liste consolidée de toutes les allergies identifiées';
COMMENT ON COLUMN MDM_Patient.source_system_ids IS 'Traçabilité : IDs du patient dans les systèmes sources (JSON)';
COMMENT ON COLUMN MDM_Patient.last_updated_at IS 'Date et heure de la dernière mise à jour du golden record';

-- =====================================================
-- Table 2 : MDM_Praticien
-- Description : Table consolidée des praticiens et professionnels de santé
-- Clé primaire : master_practitioner_id (UUID)
-- =====================================================
CREATE TABLE MDM_Praticien (
    master_practitioner_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    golden_first_name VARCHAR(100) NOT NULL,
    golden_last_name VARCHAR(100) NOT NULL,
    golden_specialty VARCHAR(100) NOT NULL,
    golden_phone VARCHAR(20),
    golden_email VARCHAR(100),
    golden_status VARCHAR(20),          -- actif, inactif, en mission
    golden_department VARCHAR(100),     -- rattachement principal
    source_system_ids JSONB,            -- { "HIS": "DOC-123", "RH": "EMP-456", "EMR": "MED-789" }
    last_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE MDM_Praticien IS 'Table consolidée des praticiens et professionnels de santé';
COMMENT ON COLUMN MDM_Praticien.master_practitioner_id IS 'Identifiant unique du praticien consolidé (UUID)';
COMMENT ON COLUMN MDM_Praticien.golden_first_name IS 'Prénom normalisé du praticien';
COMMENT ON COLUMN MDM_Praticien.golden_last_name IS 'Nom normalisé du praticien';
COMMENT ON COLUMN MDM_Praticien.golden_specialty IS 'Spécialité médicale consolidée';
COMMENT ON COLUMN MDM_Praticien.golden_phone IS 'Numéro de téléphone professionnel unifié';
COMMENT ON COLUMN MDM_Praticien.golden_email IS 'Adresse email professionnelle consolidée';
COMMENT ON COLUMN MDM_Praticien.golden_status IS 'Statut consolidé : actif, inactif, en mission';
COMMENT ON COLUMN MDM_Praticien.golden_department IS 'Département/service de rattachement principal';
COMMENT ON COLUMN MDM_Praticien.source_system_ids IS 'Traçabilité : IDs du praticien dans les systèmes sources (RH, planification, annuaire médical)';
COMMENT ON COLUMN MDM_Praticien.last_updated_at IS 'Date et heure de la dernière mise à jour';

-- =====================================================
-- Table 3 : MDM_Service
-- Description : Liste consolidée des services hospitaliers
-- Clé primaire : master_service_id (UUID)
-- =====================================================
CREATE TABLE MDM_Service (
    master_service_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    golden_service_code VARCHAR(20) NOT NULL UNIQUE,
    golden_service_name VARCHAR(150) NOT NULL,
    golden_department VARCHAR(100),
    golden_manager VARCHAR(100),
    golden_phone VARCHAR(20),
    golden_email VARCHAR(100),
    service_category VARCHAR(50),   -- ex: "Clinique", "Support", "Administratif"
    source_system_ids JSONB,       -- { "HIS": "CARD-01", "RH": "SRV-CARD", "Facturation": "C001" }
    last_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE MDM_Service IS 'Liste consolidée des services hospitaliers, unifiée à partir de plusieurs référentiels';
COMMENT ON COLUMN MDM_Service.master_service_id IS 'Identifiant unique du service consolidé (UUID)';
COMMENT ON COLUMN MDM_Service.golden_service_code IS 'Code unique normalisé du service (référentiel unifié)';
COMMENT ON COLUMN MDM_Service.golden_service_name IS 'Nom complet normalisé du service';
COMMENT ON COLUMN MDM_Service.golden_department IS 'Département de rattachement';
COMMENT ON COLUMN MDM_Service.golden_manager IS 'Responsable du service (nom consolidé)';
COMMENT ON COLUMN MDM_Service.golden_phone IS 'Numéro de téléphone du service';
COMMENT ON COLUMN MDM_Service.golden_email IS 'Adresse email du service';
COMMENT ON COLUMN MDM_Service.service_category IS 'Catégorie du service : Clinique, Support, Administratif';
COMMENT ON COLUMN MDM_Service.source_system_ids IS 'Traçabilité : Codes du service dans les systèmes sources (RH, médical, facturation)';
COMMENT ON COLUMN MDM_Service.last_updated_at IS 'Date et heure de la dernière mise à jour';

-- =====================================================
-- Table 4 : MDM_Location
-- Description : Table de référence pour toutes les localisations
-- Clé primaire : master_location_id (UUID)
-- =====================================================
CREATE TABLE MDM_Location (
    master_location_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    golden_site_name VARCHAR(150) NOT NULL,
    golden_building VARCHAR(100),
    golden_floor VARCHAR(50),
    golden_room VARCHAR(50),
    golden_address VARCHAR(255),
    golden_city VARCHAR(100),
    golden_postal_code VARCHAR(20),
    golden_country VARCHAR(100) DEFAULT 'France',
    location_type VARCHAR(50),      -- Site / Unité / Chambre / Salle d'opération
    source_system_ids JSONB,       -- { "HIS": "CH-101", "Maintenance": "LOC-456" }
    last_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE MDM_Location IS 'Table de référence pour toutes les localisations (sites, bâtiments, unités, chambres...)';
COMMENT ON COLUMN MDM_Location.master_location_id IS 'Identifiant unique de la localisation consolidée (UUID)';
COMMENT ON COLUMN MDM_Location.golden_site_name IS 'Nom du site/clinique consolidé';
COMMENT ON COLUMN MDM_Location.golden_building IS 'Bâtiment normalisé';
COMMENT ON COLUMN MDM_Location.golden_floor IS 'Étage/niveau normalisé';
COMMENT ON COLUMN MDM_Location.golden_room IS 'Numéro de chambre/salle normalisé';
COMMENT ON COLUMN MDM_Location.golden_address IS 'Adresse postale complète du site';
COMMENT ON COLUMN MDM_Location.golden_city IS 'Ville';
COMMENT ON COLUMN MDM_Location.golden_postal_code IS 'Code postal';
COMMENT ON COLUMN MDM_Location.golden_country IS 'Pays (par défaut : France)';
COMMENT ON COLUMN MDM_Location.location_type IS 'Type de localisation : Site, Unité, Chambre, Salle d''opération';
COMMENT ON COLUMN MDM_Location.source_system_ids IS 'Traçabilité : Identifiants de la localisation dans les systèmes sources';
COMMENT ON COLUMN MDM_Location.last_updated_at IS 'Date et heure de la dernière mise à jour';

-- =====================================================
-- Index pour améliorer les performances
-- =====================================================

-- Index sur les noms pour la recherche et le matching
CREATE INDEX idx_patient_name ON MDM_Patient(golden_last_name, golden_first_name);
CREATE INDEX idx_patient_dob ON MDM_Patient(golden_date_of_birth);
CREATE INDEX idx_patient_phone ON MDM_Patient(golden_phone);

CREATE INDEX idx_praticien_name ON MDM_Praticien(golden_last_name, golden_first_name);
CREATE INDEX idx_praticien_specialty ON MDM_Praticien(golden_specialty);
CREATE INDEX idx_praticien_status ON MDM_Praticien(golden_status);

CREATE INDEX idx_service_code ON MDM_Service(golden_service_code);
CREATE INDEX idx_service_name ON MDM_Service(golden_service_name);

CREATE INDEX idx_location_site ON MDM_Location(golden_site_name);
CREATE INDEX idx_location_type ON MDM_Location(location_type);

-- Index GIN pour les recherches JSONB
CREATE INDEX idx_patient_source_ids ON MDM_Patient USING GIN (source_system_ids);
CREATE INDEX idx_praticien_source_ids ON MDM_Praticien USING GIN (source_system_ids);
CREATE INDEX idx_service_source_ids ON MDM_Service USING GIN (source_system_ids);
CREATE INDEX idx_location_source_ids ON MDM_Location USING GIN (source_system_ids);

