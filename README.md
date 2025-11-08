# Projet MDM - Groupe Santé Horizon

## 📋 Vue d'ensemble

Ce projet implémente un système de **Master Data Management (MDM)** pour le **Groupe Santé Horizon**, un groupe hospitalier formé par la fusion de trois cliniques indépendantes avec des systèmes d'information hétérogènes.

## 🎯 Objectif

Créer un référentiel unique et consolidé des données maîtres (patients, praticiens, services, localisations) pour garantir la cohérence, la qualité et la traçabilité des données critiques du groupe.

## 📁 Structure du Projet

```
projet-data-modeling/
├── docs/
│   ├── 01-contexte-et-problematique.md     # Phase 1.1 : Contexte et problématique
│   └── 02-installation-et-demarrage.md     # Phase 2 : Guide d'installation
├── sql/
│   └── 01-create-tables.sql                # Phase 1.3 : Scripts de création des tables MDM
├── airflow/
│   ├── dags/                                # Phase 3 : DAGs Airflow
│   ├── logs/                                # Logs Airflow
│   ├── plugins/                             # Plugins Airflow
│   └── config/                              # Configuration Airflow
├── scripts/
│   ├── start-services.sh                    # Script de démarrage des services
│   ├── stop-services.sh                     # Script d'arrêt des services
│   └── init-database.sh                     # Script d'initialisation de la base
├── docker-compose.yml                       # Phase 2 : Configuration Docker
├── .gitignore                               # Fichiers à ignorer par Git
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

### ✅ Phase 2 : Mise en Place de l'Environnement (1 Jour)
- [x] Étape 2.1 : Créer docker-compose.yml
- [x] Étape 2.2 : Définir les services (PostgreSQL, OpenMetadata, Airflow, Kafka)
- [x] Étape 2.3 : Scripts d'initialisation et de démarrage

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

- **Docker** version 20.10 ou supérieure
- **Docker Compose** version 2.0 ou supérieure
- Au moins **8 GB de RAM** disponibles
- Au moins **20 GB d'espace disque** libre

### Démarrage rapide

1. **Démarrer tous les services** :
```bash
# Linux/Mac
chmod +x scripts/start-services.sh
./scripts/start-services.sh

# Windows (PowerShell)
.\scripts\start-services.ps1
# Ou manuellement :
docker-compose --profile init up airflow-init
docker-compose up -d
```

2. **OpenMetadata** (optionnel - deux options disponibles) :
   - **Option 1** : Intégré dans docker-compose (avec profil)
     ```powershell
     docker-compose --profile openmetadata-init up openmetadata-migrate
     docker-compose --profile openmetadata up -d openmetadata-server
     ```
   - **Option 2** : Standalone (comme votre TP1)
     ```powershell
     .\scripts\start-openmetadata.ps1
     # Ou
     docker-compose -f docker-compose.openmetadata.yml up -d
     ```
   - **Identifiants** : Email: `admin@open-metadata.org`, Password: `admin`

3. **Accéder aux services** :
   - **PostgreSQL MDM Hub** : `localhost:5432` (User: `mdm_user`, Password: `mdm_password`, DB: `mdm_clinique`)
   - **OpenMetadata** : http://localhost:8585
   - **Airflow** : http://localhost:8080 (User: `admin`, Password: `admin`)
   - **Kafka** : `localhost:9092`

4. **Vérifier l'état des services** :
```bash
docker-compose ps
docker-compose logs -f
```

### Arrêt des services

```bash
# Linux/Mac
./scripts/stop-services.sh

# Windows
docker-compose down
```

> 📖 **Documentation complète** : Voir [docs/02-installation-et-demarrage.md](docs/02-installation-et-demarrage.md) pour plus de détails.

## 📚 Documentation

- [Contexte et Problématique](docs/01-contexte-et-problematique.md) : Description détaillée du contexte du projet et des problèmes à résoudre
- [Installation et Démarrage](docs/02-installation-et-demarrage.md) : Guide complet pour installer et démarrer l'environnement Docker
- [Options OpenMetadata](docs/03-openmetadata-options.md) : Guide pour choisir entre OpenMetadata intégré ou standalone
- [Dépannage Airflow](docs/04-depannage-airflow.md) : Solutions aux problèmes courants avec Airflow

## 👥 Équipe

- **Membre 1** : MDM_Patient
- **Membre 2** : MDM_Praticien
- **Membre 3** : MDM_Service
- **Membre 4** : MDM_Location

## 📄 Licence

Projet académique - Groupe Santé Horizon

