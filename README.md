# Projet Data Modeling - Master Data Management (MDM)

Projet de Master Data Management pour le Groupe Santé Horizon, consolidant les données de 3 cliniques hétérogènes.

## Architecture

- **PostgreSQL MDM Hub** : Base de données pour les Golden Tables (port 5432)
- **Airflow** : Orchestration des pipelines ETL (port 8081)
- **OpenMetadata** : Data Catalogue et Data Quality (port 8585)
- **Kafka & Zookeeper** : Streaming temps réel (ports 9092, 2181)

## Démarrage rapide

### 1. Démarrer les services de base

```powershell
# Windows
.\scripts\start-services.ps1

# Linux/Mac
chmod +x scripts/start-services.sh
./scripts/start-services.sh
```

### 2. Démarrer OpenMetadata (Phase 4)

     ```powershell
# Windows - Initialiser la base de données Airflow
.\scripts\init-openmetadata-airflow.ps1

# Lancer la migration (une seule fois)
     docker-compose --profile openmetadata-init up openmetadata-migrate

# Démarrer OpenMetadata
docker-compose --profile openmetadata up -d
     ```

### 3. Accéder aux services

- **Airflow** : http://localhost:8081 (admin/admin)
- **OpenMetadata** : http://localhost:8585 (admin@open-metadata.org/admin)
- **PostgreSQL MDM Hub** : localhost:5432 (postgres/root)

## Documentation

- [Installation et démarrage](docs/02-installation-et-demarrage.md)
- [Configuration OpenMetadata](docs/03-openmetadata-options.md)
- [Dépannage Airflow](docs/04-depannage-airflow.md)
- [Phase 4 : Data Catalogue & Quality](docs/05-phase-4-data-catalogue-quality.md)

## Structure du projet

```
projet-data-modeling/
├── airflow/              # Configuration Airflow
│   ├── dags/            # DAGs Airflow
│   ├── config/          # Scripts de configuration
│   └── logs/            # Logs Airflow
├── data/                # Données sources (CSV)
├── sql/                 # Scripts SQL
├── scripts/             # Scripts utilitaires
├── talend_jobs/         # Jobs Talend exportés
└── docs/                # Documentation
