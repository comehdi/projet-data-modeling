# Phase 2 : Installation et Démarrage

## Prérequis

- **Docker** version 20.10 ou supérieure
- **Docker Compose** version 2.0 ou supérieure
- Au moins **8 GB de RAM** disponibles
- Au moins **20 GB d'espace disque** libre

### Vérification des prérequis

```bash
# Vérifier Docker
docker --version

# Vérifier Docker Compose
docker-compose --version
```

## Installation

### 1. Cloner ou télécharger le projet

Assurez-vous d'être dans le répertoire du projet :
```bash
cd projet-data-modeling
```

### 2. Démarrer les services

#### Option A : Utiliser le script (recommandé)

Sur Linux/Mac :
```bash
chmod +x scripts/start-services.sh
./scripts/start-services.sh
```

Sur Windows (PowerShell) :
```powershell
docker-compose --profile init up airflow-init
docker-compose up -d
```

#### Option B : Commandes manuelles

```bash
# 1. Initialiser Airflow (première fois uniquement)
docker-compose --profile init up airflow-init

# 2. Démarrer tous les services
docker-compose up -d

# 3. Vérifier que tous les services sont démarrés
docker-compose ps
```

### 3. Vérifier l'état des services

```bash
# Voir les logs de tous les services
docker-compose logs -f

# Voir les logs d'un service spécifique
docker-compose logs -f postgres-mdm-hub
docker-compose logs -f openmetadata-server
docker-compose logs -f airflow-webserver
```

## Accès aux services

Une fois les services démarrés, vous pouvez accéder à :

| Service | URL | Identifiants |
|---------|-----|--------------|
| **PostgreSQL MDM Hub** | `localhost:5432` | User: `postgres`<br>Password: `root`<br>Database: `mdm_clinique` |
| **OpenMetadata** | http://localhost:8585 | Pas d'authentification (no-auth) |
| **Airflow** | http://localhost:8081 | User: `admin`<br>Password: `admin` |
| **Kafka** | `localhost:9092` | - |
| **Zookeeper** | `localhost:2181` | - |

## Initialisation de la base de données

Les tables MDM sont créées automatiquement au démarrage de PostgreSQL grâce au script SQL monté dans le volume.

Si vous devez réinitialiser manuellement :

```bash
# Se connecter à PostgreSQL
docker exec -it postgres-mdm-hub psql -U mdm_user -d mdm_clinique

# Ou depuis l'extérieur
psql -h localhost -U mdm_user -d mdm_clinique
# Password: mdm_password
```

Vérifier que les tables existent :
```sql
\dt
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
```

## Commandes utiles

### Arrêter les services

```bash
# Arrêt simple (conserve les données)
docker-compose down

# Arrêt avec suppression des volumes (ATTENTION: supprime toutes les données)
docker-compose down -v
```

### Redémarrer un service spécifique

```bash
docker-compose restart postgres-mdm-hub
docker-compose restart airflow-webserver
```

### Voir l'utilisation des ressources

```bash
docker stats
```

### Nettoyer les ressources Docker

```bash
# Supprimer les conteneurs arrêtés
docker container prune

# Supprimer les images non utilisées
docker image prune

# Nettoyage complet (ATTENTION: supprime tout)
docker system prune -a --volumes
```

## Dépannage

### Les services ne démarrent pas

1. Vérifier que les ports ne sont pas déjà utilisés :
```bash
# Windows
netstat -ano | findstr :5432
netstat -ano | findstr :8585
netstat -ano | findstr :8081

# Linux/Mac
lsof -i :5432
lsof -i :8585
lsof -i :8081
```

2. Vérifier les logs d'erreur :
```bash
docker-compose logs [nom-du-service]
```

3. Vérifier l'espace disque disponible :
```bash
docker system df
```

### PostgreSQL ne démarre pas

```bash
# Vérifier les logs
docker-compose logs postgres-mdm-hub

# Vérifier les volumes
docker volume ls
docker volume inspect projet-data-modeling_postgres_mdm_data
```

### Airflow ne démarre pas

```bash
# Réinitialiser la base de données Airflow
docker-compose down
docker volume rm projet-data-modeling_airflow_db_data
docker-compose --profile init up airflow-init
docker-compose up -d
```

### OpenMetadata ne démarre pas

Vérifier que Elasticsearch est démarré :
```bash
curl http://localhost:9200/_cluster/health
```

## Structure des volumes

Les données sont persistées dans des volumes Docker :

- `postgres_mdm_data` : Données de la base MDM
- `openmetadata_db_data` : Données d'OpenMetadata
- `elasticsearch_data` : Index Elasticsearch
- `airflow_db_data` : Métadonnées Airflow
- `kafka_data` : Données Kafka
- `zookeeper_data` : Données Zookeeper

Pour sauvegarder les volumes :
```bash
docker run --rm -v projet-data-modeling_postgres_mdm_data:/data -v $(pwd):/backup alpine tar czf /backup/postgres_backup.tar.gz /data
```

## Prochaines étapes

Une fois l'environnement démarré, vous pouvez :

1. **Phase 3** : Créer les fichiers CSV de données sources et les jobs Talend
2. **Phase 4** : Connecter OpenMetadata à la base de données MDM
3. **Phase 5** : Implémenter le streaming avec Kafka

