# Projet MDM - Groupe Santé Horizon

## 📋 Vue d'ensemble

Ce projet implémente un système de **Master Data Management (MDM)** pour le **Groupe Santé Horizon**, un groupe hospitalier formé par la fusion de trois cliniques indépendantes avec des systèmes d'information hétérogènes.

## 🎯 Objectif

Créer un référentiel unique et consolidé des données maîtres (patients, praticiens, services, localisations) pour garantir la cohérence, la qualité et la traçabilité des données critiques du groupe.

## 📁 Structure du Projet

```
projet-data-modeling/
├── docs/
│   └── 01-contexte-et-problematique.md    # Phase 1.1 : Contexte et problématique
├── sql/
│   └── 01-create-tables.sql                # Phase 1.3 : Scripts de création des tables MDM
├── docker-compose.yml                       # Phase 2 : Configuration Docker (à venir)
├── talend/                                  # Phase 3 : Jobs Talend (à venir)
├── airflow/                                 # Phase 3 : DAGs Airflow (à venir)
└── README.md                                # Ce fichier
```

## 🏗️ Architecture MDM

### Domaines MDM

Le projet couvre 4 domaines de données maîtres :

1. **MDM_Patient** 👤
   - Le "Qui" - Client/Bénéficiaire des soins
   - Consolidation des données patients depuis les systèmes HIS, LABSYS, EMR

2. **MDM_Praticien** 👨‍⚕️
   - Le "Qui" - Fournisseur de service médical
   - Consolidation depuis les systèmes RH, planification, annuaire médical

3. **MDM_Service** 🏥
   - Le "Quoi" - Catalogue des services/produits
   - Consolidation depuis les référentiels RH, médical, facturation

4. **MDM_Location** 🧭
   - Le "Où" - Référentiel géographique et logistique
   - Consolidation des sites, bâtiments, unités, chambres

## 📊 Base de Données

- **Base de données** : `mdm_clinique` (PostgreSQL)
- **Tables** : 4 tables maîtres (Golden Tables)
  - `MDM_Patient`
  - `MDM_Praticien`
  - `MDM_Service`
  - `MDM_Location`

## 🚀 Phases du Projet

### ✅ Phase 1 : Cadrage, Conception & Répartition (Semaine 1)
- [x] Étape 1.1 : Contexte & Problématique
- [x] Étape 1.2 : Répartition des Domaines MDM
- [x] Étape 1.3 : Conception des Tables Maîtres (Golden Tables)

### ⏳ Phase 2 : Mise en Place de l'Environnement (1 Jour)
- [ ] Étape 2.1 : Créer docker-compose.yml
- [ ] Étape 2.2 : Définir les services (PostgreSQL, OpenMetadata, Airflow, Kafka)
- [ ] Étape 2.3 : Lancer et initialiser

### ⏳ Phase 3 : Data Wrangling & Intégration (Semaine 2-3)
- [ ] Étape 3.1 : Simuler les données sources (CSV)
- [ ] Étape 3.2 : Construire les Jobs Talend
- [ ] Étape 3.3 : Orchestrer avec Airflow

### ⏳ Phase 4 : Gouvernance, Data Catalogue & Data Quality (Semaine 4)
- [ ] Étape 4.1 : Créer le Data Catalogue (OpenMetadata)
- [ ] Étape 4.2 : Créer le Dictionnaire de Données
- [ ] Étape 4.3 : Configurer les Métriques de Data Quality

### ⏳ Phase 5 : Bonus - Streaming & Rapport (Semaine 5)
- [ ] Étape 5.1 : Implémenter le flux temps réel (Kafka)
- [ ] Étape 5.2 : Rédiger le Rapport & l'Exposé

## 📝 Installation et Utilisation

### Prérequis

- PostgreSQL 12+
- Docker & Docker Compose (pour les phases suivantes)
- Talend Open Studio (pour la Phase 3)
- Python 3.8+ avec Airflow (pour la Phase 3)

### Création des Tables

1. Connectez-vous à PostgreSQL :
```bash
psql -U postgres -d mdm_clinique
```

2. Exécutez le script SQL :
```sql
\i sql/01-create-tables.sql
```

Ou directement :
```bash
psql -U postgres -d mdm_clinique -f sql/01-create-tables.sql
```

## 📚 Documentation

- [Contexte et Problématique](docs/01-contexte-et-problematique.md) : Description détaillée du contexte du projet et des problèmes à résoudre

## 👥 Équipe

- **Membre 1** : MDM_Patient
- **Membre 2** : MDM_Praticien
- **Membre 3** : MDM_Service
- **Membre 4** : MDM_Location

## 📄 Licence

Projet académique - Groupe Santé Horizon

