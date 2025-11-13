# Projet Data Modeling - Master Data Management (MDM)

**Groupe Santé Horizon** - Consolidation des données de 3 cliniques hétérogènes

[![Docker](https://img.shields.io/badge/Docker-20.10+-blue.svg)](https://www.docker.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-green.svg)](https://www.postgresql.org/)
[![Airflow](https://img.shields.io/badge/Airflow-2.8+-orange.svg)](https://airflow.apache.org/)
[![OpenMetadata](https://img.shields.io/badge/OpenMetadata-1.10.5-purple.svg)](https://open-metadata.org/)
[![Kafka](https://img.shields.io/badge/Kafka-7.5.0-black.svg)](https://kafka.apache.org/)

## 📋 Table des matières

- [Vue d'ensemble](#vue-densemble)
- [Architecture](#architecture)
- [Phases du projet](#phases-du-projet)
- [Prérequis](#prérequis)
- [Installation et démarrage](#installation-et-démarrage)
- [Accès aux services](#accès-aux-services)
- [Documentation](#documentation)
- [Structure du projet](#structure-du-projet)
- [Scripts utilitaires](#scripts-utilitaires)
- [Dépannage](#dépannage)

## 🎯 Vue d'ensemble

Ce projet implémente une solution complète de **Master Data Management (MDM)** pour le **Groupe Santé Horizon**, un groupe hospitalier formé par la fusion de trois cliniques indépendantes avec des systèmes d'information hétérogènes.

### Problématique

La fusion de ces trois entités a créé une situation critique de **perte de maîtrise des données maîtres** :
- **Duplication de patients** : Un même patient enregistré 3 fois avec des informations différentes
- **Données incohérentes** : Formats différents, valeurs manquantes, doublons
- **Risques médicaux** : Allergies non visibles dans tous les systèmes
- **Facturation impossible** : Impossible de consolider les factures

### Solution

Mise en place d'un **MDM Hub** centralisé avec :
- **4 Golden Tables** : Patient, Praticien, Service, Location
- **Pipelines ETL** : Nettoyage, déduplication, consolidation
- **Orchestration** : Airflow pour les batchs quotidiens
- **Streaming** : Kafka pour le temps réel
- **Gouvernance** : OpenMetadata pour le catalogue et la qualité

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Groupe Santé Horizon                      │
│                  Master Data Management Hub                   │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
   ┌────▼────┐          ┌─────▼─────┐         ┌────▼────┐
   │ Clinique│          │ Clinique  │         │ Clinique │
   │    A    │          │    B      │         │    C     │
   │  (HIS)  │          │ (LABSYS)  │         │  (EMR)   │
   └────┬────┘          └─────┬─────┘         └────┬────┘
        │                     │                     │
        └─────────────────────┼─────────────────────┘
                              │
                    ┌─────────▼─────────┐
                    │   Talend ETL Jobs │
                    │  (Data Wrangling) │
                    └─────────┬─────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
   ┌────▼────┐          ┌─────▼─────┐         ┌────▼────┐
   │ Airflow │          │ PostgreSQL│         │  Kafka  │
   │ (Batch) │          │  MDM Hub │         │(Stream) │
   └────┬────┘          └─────┬─────┘         └────┬────┘
        │                     │                     │
        └─────────────────────┼─────────────────────┘
                              │
                    ┌─────────▼─────────┐
                    │   OpenMetadata     │
                    │ (Data Catalogue &  │
                    │   Data Quality)    │
                    └────────────────────┘
```

### Services Docker

| Service | Port | Description |
|---------|------|-------------|
| **PostgreSQL MDM Hub** | 5432 | Base de données pour les Golden Tables |
| **Airflow** | 8081 | Orchestration des pipelines ETL (batch) |
| **OpenMetadata Server** | 8585 | Data Catalogue et Data Quality |
| **OpenMetadata Ingestion** | 8080 | Airflow interne pour l'ingestion |
| **Kafka** | 9092 | Streaming temps réel |
| **Zookeeper** | 2181 | Coordination pour Kafka |
| **Elasticsearch** | 9200 | Indexation pour OpenMetadata |

## 📚 Phases du projet

### Phase 1 : Cadrage, Conception & Répartition ✅

**Objectif** : Définir le périmètre, le contexte et la structure des Golden Tables.

- **1.1** : Contexte & Problématique
- **1.2** : Répartition des domaines MDM (Patient, Praticien, Service, Location)
- **1.3** : Conception des tables maîtres (schémas SQL)

📖 [Documentation Phase 1](docs/01-contexte-et-problematique.md)

### Phase 2 : Mise en Place de l'Environnement ✅

**Objectif** : Lancer toute l'infrastructure technique avec Docker.

- **2.1** : Création du `docker-compose.yml`
- **2.2** : Définition des services (PostgreSQL, Airflow, OpenMetadata, Kafka)
- **2.3** : Lancement et initialisation

📖 [Documentation Phase 2](docs/02-installation-et-demarrage.md)

### Phase 3 : Data Wrangling & Intégration ✅

**Objectif** : Construire les pipelines ETL qui nettoient, transforment et chargent les données.

- **3.1** : Simulation des données sources (CSV avec données "messy")
- **3.2** : Construction des jobs Talend (nettoyage, déduplication, consolidation)
- **3.3** : Orchestration batch avec Airflow (DAG `mdm_pipeline`)

### Phase 4 : Gouvernance, Data Catalogue & Data Quality ✅

**Objectif** : Documenter le travail et prouver la qualité des données avec OpenMetadata.

- **4.1** : Création du Data Catalogue
- **4.2** : Création du Dictionnaire de Données
- **4.3** : Configuration des métriques de Data Quality

📖 [Documentation Phase 4](docs/05-phase-4-data-catalogue-quality.md)

### Phase 5 : Bonus - Streaming & Rapport ✅

**Objectif** : Montrer une maîtrise avancée avec le streaming temps réel.

- **5.1** : Implémentation du flux temps réel (Kafka)
- **5.2** : Rédaction du rapport & exposé

📖 [Documentation Phase 5](docs/05-phase-5-kafka-streaming.md)

## 🔧 Prérequis

- **Docker** version 20.10 ou supérieure
- **Docker Compose** version 2.0 ou supérieure
- **8 GB de RAM** minimum (16 GB recommandé)
- **20 GB d'espace disque** libre
- **PowerShell** (Windows) ou **Bash** (Linux/Mac)

### Vérification des prérequis

```bash
# Vérifier Docker
docker --version

# Vérifier Docker Compose
docker-compose --version
```

## 🚀 Installation et démarrage

### 1. Cloner ou télécharger le projet

```bash
cd projet-data-modeling
```

### 2. Démarrer les services de base

#### Méthode 1 : Commandes de base (manuel)

**Linux/Mac/Windows (Git Bash)** :
```bash
# 1. Initialiser Airflow (première fois uniquement)
docker-compose --profile init up airflow-init

# 2. Démarrer tous les services de base
docker-compose up -d postgres-mdm-hub zookeeper kafka airflow-db airflow-redis

# 3. Attendre que les services soient prêts (10-15 secondes)
# Vérifier les logs si nécessaire
docker-compose logs -f postgres-mdm-hub

# 4. Démarrer Airflow (webserver et scheduler)
docker-compose up -d airflow-webserver airflow-scheduler

# 5. Vérifier que tous les services sont démarrés
docker-compose ps
```

**Windows (PowerShell)** :
```powershell
# 1. Initialiser Airflow (première fois uniquement)
docker-compose --profile init up airflow-init

# 2. Démarrer tous les services de base
docker-compose up -d postgres-mdm-hub zookeeper kafka airflow-db airflow-redis

# 3. Attendre que les services soient prêts (10-15 secondes)
Start-Sleep -Seconds 15
# Vérifier les logs si nécessaire
docker-compose logs -f postgres-mdm-hub

# 4. Démarrer Airflow (webserver et scheduler)
docker-compose up -d airflow-webserver airflow-scheduler

# 5. Vérifier que tous les services sont démarrés
docker-compose ps
```

**Vérification** : Vérifiez que tous les services sont démarrés :
```bash
docker-compose ps
```

Vous pouvez accéder à :
- **Airflow** : http://localhost:8081 (admin/admin)
- **PostgreSQL MDM Hub** : localhost:5432 (postgres/root)

**Note** : Si vous rencontrez des erreurs avec les scripts, utilisez ces commandes de base.

#### Méthode 2 : Utiliser les scripts (recommandé)

**Windows (PowerShell)** :
```powershell
.\scripts\start-services.ps1
```

**Linux/Mac** :
```bash
chmod +x scripts/start-services.sh
./scripts/start-services.sh
```

### 3. Démarrer OpenMetadata (Phase 4)

#### Méthode 1 : Commandes de base (manuel)

**Linux/Mac/Windows (Git Bash)** :
```bash
# 1. Démarrer les services de base nécessaires (PostgreSQL et Elasticsearch)
docker-compose --profile openmetadata up -d openmetadata-db elasticsearch

# 2. Attendre que les services soient prêts (20-30 secondes)
sleep 20
# Vérifier les logs
docker-compose --profile openmetadata logs -f openmetadata-db

# 3. Initialiser la base de données Airflow pour OpenMetadata
# Créer la base de données et l'utilisateur
docker exec openmetadata-db psql -U postgres -c "CREATE DATABASE airflow_db;"
docker exec openmetadata-db psql -U postgres -c "CREATE USER airflow_user WITH PASSWORD 'airflow_pass';"
docker exec openmetadata-db psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE airflow_db TO airflow_user;"

# 4. Lancer la migration OpenMetadata (une seule fois)
docker-compose --profile openmetadata-init up openmetadata-migrate

# 5. Démarrer tous les services OpenMetadata
docker-compose --profile openmetadata up -d

# 6. Vérifier que les services sont démarrés
docker-compose --profile openmetadata ps
```

**Windows (PowerShell)** :
```powershell
# 1. Démarrer les services de base nécessaires (PostgreSQL et Elasticsearch)
docker-compose --profile openmetadata up -d openmetadata-db elasticsearch

# 2. Attendre que les services soient prêts (20-30 secondes)
Start-Sleep -Seconds 30
# Vérifier les logs
docker-compose --profile openmetadata logs -f openmetadata-db

# 3. Initialiser la base de données Airflow pour OpenMetadata
# Créer la base de données et l'utilisateur
docker exec openmetadata-db psql -U postgres -c "CREATE DATABASE airflow_db;"
docker exec openmetadata-db psql -U postgres -c "CREATE USER airflow_user WITH PASSWORD 'airflow_pass';"
docker exec openmetadata-db psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE airflow_db TO airflow_user;"

# 4. Lancer la migration OpenMetadata (une seule fois)
docker-compose --profile openmetadata-init up openmetadata-migrate

# 5. Démarrer tous les services OpenMetadata
docker-compose --profile openmetadata up -d

# 6. Vérifier que les services sont démarrés
docker-compose --profile openmetadata ps
```

**Vérification** : Vérifiez que les services OpenMetadata sont démarrés :
```bash
docker-compose --profile openmetadata ps
```

Vous pouvez accéder à OpenMetadata à l'adresse : http://localhost:8585

**Note** : Si vous rencontrez des erreurs avec les scripts, utilisez ces commandes de base.

#### Méthode 2 : Utiliser les scripts (recommandé)

**Windows (PowerShell)** :
```powershell
# Initialiser la base de données Airflow pour OpenMetadata
.\scripts\init-openmetadata-airflow.ps1

# Lancer la migration (une seule fois)
docker-compose --profile openmetadata-init up openmetadata-migrate

# Démarrer OpenMetadata
docker-compose --profile openmetadata up -d
```

**Linux/Mac** :
```bash
# Initialiser la base de données Airflow
chmod +x scripts/init-openmetadata-airflow.sh
./scripts/init-openmetadata-airflow.sh

# Lancer la migration (une seule fois)
docker-compose --profile openmetadata-init up openmetadata-migrate

# Démarrer OpenMetadata
docker-compose --profile openmetadata up -d
```

### 4. Créer le topic Kafka (Phase 5)

#### Méthode 1 : Commandes de base (manuel)

**Linux/Mac/Windows (Git Bash)** :
```bash
# 1. Vérifier que Kafka est démarré
docker ps --filter "name=kafka"

# 2. Attendre que Kafka soit prêt (10-15 secondes)
sleep 15
# Vérifier les logs si nécessaire
docker-compose logs -f kafka

# 3. Créer le topic
docker exec kafka kafka-topics --create \
  --topic new_patient_registrations \
  --bootstrap-server localhost:9092 \
  --partitions 1 \
  --replication-factor 1

# 4. Vérifier que le topic est créé
docker exec kafka kafka-topics --list --bootstrap-server localhost:9092

# 5. Afficher les détails du topic
docker exec kafka kafka-topics --describe \
  --topic new_patient_registrations \
  --bootstrap-server localhost:9092
```

**Windows (PowerShell)** :
```powershell
# 1. Vérifier que Kafka est démarré
docker ps --filter "name=kafka"

# 2. Attendre que Kafka soit prêt (10-15 secondes)
Start-Sleep -Seconds 15
# Vérifier les logs si nécessaire
docker-compose logs -f kafka

# 3. Créer le topic
docker exec kafka kafka-topics --create `
  --topic new_patient_registrations `
  --bootstrap-server localhost:9092 `
  --partitions 1 `
  --replication-factor 1

# 4. Vérifier que le topic est créé
docker exec kafka kafka-topics --list --bootstrap-server localhost:9092

# 5. Afficher les détails du topic
docker exec kafka kafka-topics --describe `
  --topic new_patient_registrations `
  --bootstrap-server localhost:9092
```

**Vérification** : Vérifiez que le topic est créé :
```bash
docker exec kafka kafka-topics --list --bootstrap-server localhost:9092
```

Vous devriez voir `new_patient_registrations` dans la liste.

**Note** : Si vous rencontrez des erreurs avec les scripts, utilisez ces commandes de base.

#### Méthode 2 : Utiliser les scripts (recommandé)

**Windows (PowerShell)** :
```powershell
.\scripts\create-kafka-topic.ps1
```

**Linux/Mac** :
```bash
chmod +x scripts/create-kafka-topic.sh
./scripts/create-kafka-topic.sh
```

## 🌐 Accès aux services

Une fois les services démarrés, vous pouvez accéder à :

| Service | URL | Identifiants |
|---------|-----|--------------|
| **PostgreSQL MDM Hub** | `localhost:5432` | User: `postgres`<br>Password: `root`<br>Database: `mdm_clinique` |
| **Airflow** | http://localhost:8081 | User: `admin`<br>Password: `admin` |
| **OpenMetadata** | http://localhost:8585 | Email: `admin@open-metadata.org`<br>Password: `admin` |
| **OpenMetadata Ingestion** | http://localhost:8080 | User: `admin`<br>Password: `admin` |
| **Kafka** | `localhost:9092` | - |
| **Zookeeper** | `localhost:2181` | - |
| **Elasticsearch** | http://localhost:9200 | - |

## 📖 Documentation

### Documentation principale

- **[Phase 1 : Contexte & Problématique](docs/01-contexte-et-problematique.md)** - Contexte du projet et problématique MDM
- **[Phase 2 : Installation et Démarrage](docs/02-installation-et-demarrage.md)** - Guide d'installation complet
- **[Phase 4 : Data Catalogue & Quality](docs/05-phase-4-data-catalogue-quality.md)** - Configuration OpenMetadata
- **[Phase 5 : Kafka Streaming](docs/05-phase-5-kafka-streaming.md)** - Implémentation du streaming temps réel

### Guides de configuration

- **[Configuration OpenMetadata](docs/03-openmetadata-options.md)** - Options et configuration avancée
- **[Dépannage Airflow](docs/04-depannage-airflow.md)** - Résolution des problèmes courants
- **[Configurer Pipeline Service](docs/configurer-pipeline-service-openmetadata.md)** - Configuration du service Pipeline
- **[Ingestion complète avec données](docs/ingestion-complete-avec-donnees.md)** - Guide d'ingestion avec données

### Guides de dépannage

- **[Corriger Elasticsearch et Service](docs/corriger-elasticsearch-et-service.md)** - Résolution des problèmes Elasticsearch
- **[Corriger Lineage Pipeline Database](docs/corriger-lineage-pipeline-database.md)** - Résolution des problèmes de lineage
- **[Relancer ingestion colonnes vides](docs/relancer-ingestion-colonnes-vides.md)** - Résolution des tables sans colonnes

## 📁 Structure du projet

```
projet-data-modeling/
├── airflow/                      # Configuration Airflow
│   ├── dags/                    # DAGs Airflow
│   │   └── mdm_pipeline.py      # DAG principal pour les jobs Talend
│   ├── config/                  # Scripts de configuration
│   │   └── init-talend.sh       # Script d'initialisation Talend
│   └── logs/                    # Logs Airflow
├── data/                        # Données sources (CSV)
│   ├── clinique_A_patients.csv
│   ├── clinique_B_patients.csv
│   └── ...
├── sql/                         # Scripts SQL
│   ├── 00-enable-pg-stat-statements.sql
│   └── 01-create-tables.sql     # Création des Golden Tables
├── scripts/                     # Scripts utilitaires
│   ├── start-services.ps1      # Démarrage des services (Windows)
│   ├── start-services.sh        # Démarrage des services (Linux/Mac)
│   ├── create-kafka-topic.ps1   # Création du topic Kafka (Windows)
│   ├── create-kafka-topic.sh    # Création du topic Kafka (Linux/Mac)
│   ├── init-openmetadata-airflow.ps1
│   └── ...
├── talend_jobs/                 # Jobs Talend exportés
│   ├── job_master_patient/
│   ├── job_master_praticien/
│   └── ...
├── docs/                        # Documentation
│   ├── 01-contexte-et-problematique.md
│   ├── 02-installation-et-demarrage.md
│   ├── 05-phase-4-data-catalogue-quality.md
│   └── 05-phase-5-kafka-streaming.md
├── docker-compose.yml           # Configuration Docker Compose
└── README.md                    # Ce fichier
```

## 🛠️ Scripts utilitaires

### Démarrage et arrêt

- `start-services.ps1` / `start-services.sh` - Démarrer tous les services
- `start-all-services.ps1` - Démarrer tous les services avec vérifications
- `stop-services.sh` - Arrêter tous les services

### OpenMetadata

- `init-openmetadata-airflow.ps1` / `init-openmetadata-airflow.sh` - Initialiser Airflow pour OpenMetadata
- `start-openmetadata.ps1` / `start-openmetadata.sh` - Démarrer OpenMetadata

### Kafka

- `create-kafka-topic.ps1` / `create-kafka-topic.sh` - Créer le topic Kafka

### Vérification

- `check-status.ps1` - Vérifier l'état de tous les services
- `verify-setup.ps1` - Vérifier la configuration complète

## 🔍 Dépannage

### Problèmes courants

#### Les services ne démarrent pas

```bash
# Vérifier les logs
docker-compose logs -f

# Vérifier l'état des services
docker-compose ps

# Redémarrer un service spécifique
docker-compose restart <service-name>
```

#### OpenMetadata ne se connecte pas à Airflow

Voir [Corriger Lineage Pipeline Database](docs/corriger-lineage-pipeline-database.md)

#### Tables vides dans OpenMetadata

Voir [Relancer ingestion colonnes vides](docs/relancer-ingestion-colonnes-vides.md)

#### Erreurs Elasticsearch

Voir [Corriger Elasticsearch et Service](docs/corriger-elasticsearch-et-service.md)

### Commandes utiles

```bash
# Voir les logs d'un service
docker-compose logs -f <service-name>

# Redémarrer tous les services
docker-compose restart

# Arrêter tous les services
docker-compose down

# Arrêter et supprimer les volumes (⚠️ supprime les données)
docker-compose down -v

# Vérifier l'utilisation des ressources
docker stats
```

## 📊 Golden Tables

Le projet implémente 4 tables maîtres (Golden Tables) :

1. **MDM_Patient** - Patients consolidés
2. **MDM_Praticien** - Praticiens consolidés
3. **MDM_Service** - Services/Actes consolidés
4. **MDM_Location** - Sites/Locations consolidés

Chaque table contient :
- Des champs "golden" normalisés et consolidés
- Un identifiant maître unique (UUID)
- Des métadonnées de traçabilité (`source_system_ids`, `last_updated_at`)

## 🎓 Utilisation pédagogique

Ce projet est conçu pour :
- Comprendre les concepts de **Master Data Management (MDM)**
- Pratiquer le **Data Wrangling** avec Talend
- Apprendre l'**orchestration** avec Airflow
- Découvrir la **gouvernance des données** avec OpenMetadata
- Implémenter le **streaming temps réel** avec Kafka

## 📝 Notes importantes

- **Ports** : Assurez-vous que les ports 5432, 8080, 8081, 8585, 9092, 2181, 9200 sont libres
- **Ressources** : OpenMetadata et Elasticsearch nécessitent au moins 2 GB de RAM chacun
- **Persistance** : Les données sont stockées dans des volumes Docker et persistent après redémarrage
- **Profils Docker Compose** : Utilisez `--profile openmetadata` pour démarrer OpenMetadata séparément

## 🤝 Contribution

Ce projet est un projet académique. Pour toute question ou suggestion, veuillez créer une issue.

## 📄 Licence

Ce projet est destiné à un usage éducatif dans le cadre du cours de Data Modeling.

---

**Groupe Santé Horizon** - Master Data Management Hub  
*Consolidation des données de 3 cliniques hétérogènes*
