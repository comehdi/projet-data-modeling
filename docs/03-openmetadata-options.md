# OpenMetadata - Configuration et Démarrage

OpenMetadata est maintenant **complètement intégré** dans le `docker-compose.yml` principal avec un **profil** pour pouvoir le lancer séparément si besoin.

## Architecture

OpenMetadata utilise deux Airflow distincts :
- **OpenMetadata Ingestion Airflow** : Port **8080** (pour les DAGs d'ingestion OpenMetadata)
- **Projet MDM Airflow** : Port **8081** (pour les jobs Talend du projet)

## Démarrer OpenMetadata

### Étape 1 : Initialiser la base de données Airflow pour l'ingestion

**Windows (PowerShell) :**
```powershell
# Initialiser la base de données Airflow pour OpenMetadata Ingestion
.\scripts\init-openmetadata-airflow.ps1
```

**Linux/Mac :**
```bash
# Rendre le script exécutable
chmod +x scripts/init-openmetadata-airflow.sh

# Initialiser la base de données Airflow pour OpenMetadata Ingestion
./scripts/init-openmetadata-airflow.sh
```

### Étape 2 : Lancer la migration OpenMetadata (une seule fois)

```bash
# Lancer la migration OpenMetadata (les services de base seront démarrés automatiquement)
docker-compose --profile openmetadata-init up openmetadata-migrate
```

**Note** : Le profil `openmetadata-init` inclut automatiquement `openmetadata-db` et `elasticsearch` nécessaires pour la migration.

### Étape 3 : Démarrer tous les services OpenMetadata

```bash
# Démarrer tous les services OpenMetadata
docker-compose --profile openmetadata up -d
```

Cela démarre :
- `openmetadata-db` : Base de données OpenMetadata (port 5433)
- `elasticsearch` : Elasticsearch pour la recherche (port 9200)
- `openmetadata-server` : Serveur OpenMetadata (port 8585)
- `openmetadata-ingestion` : Service d'ingestion avec Airflow interne (port 8080)

### Avantages
- Tous les services dans le même réseau Docker (`mdm-network`)
- Facilite la connexion entre services
- Gestion centralisée
- Pas de conflit de ports avec l'Airflow du projet MDM

## Configuration des ports

| Service | Port Externe | Port Interne | Description |
|---------|--------------|--------------|-------------|
| OpenMetadata Server | 8585 | 8585 | Interface web OpenMetadata |
| OpenMetadata Admin | 8586 | 8586 | Port d'administration |
| OpenMetadata Ingestion Airflow | 8080 | 8080 | Airflow pour les DAGs d'ingestion |
| Projet MDM Airflow | 8081 | 8080 | Airflow pour les jobs Talend |
| OpenMetadata PostgreSQL | 5433 | 5432 | Base de données OpenMetadata |
| PostgreSQL MDM Hub | 5432 | 5432 | Base de données MDM |
| Elasticsearch | 9200 | 9200 | Recherche OpenMetadata |

## Configuration des identifiants

Dans les deux cas, les identifiants par défaut sont :
- **Email** : `admin@open-metadata.org`
- **Password** : `admin`

## Connexion à la base de données MDM

Pour connecter OpenMetadata à votre base de données MDM (`mdm_clinique`), vous devrez :

1. Accéder à OpenMetadata : http://localhost:8585
2. Se connecter avec :
   - **Email** : `admin@open-metadata.org`
   - **Password** : `admin`
3. Aller dans **Settings** > **Services** > **Databases**
4. Cliquer sur **Add New Service** > **PostgreSQL**
5. Remplir le formulaire :
   - **Name** : `MDM Clinique Hub`
   - **Description** : `Base de données Master Data Management pour Groupe Santé Horizon`
   - **Host** : `postgres-mdm-hub` (nom du conteneur Docker)
   - **Port** : `5432` (port interne Docker)
   - **Database** : `mdm_clinique`
   - **Username** : `postgres`
   - **Password** : `root`
6. Cliquer sur **Test Connection** pour vérifier
7. Cliquer sur **Save**

## Configuration d'OpenMetadata pour utiliser l'Airflow d'ingestion

La connexion à l'Airflow d'ingestion est **automatiquement configurée** via les variables d'environnement dans `docker-compose.yml` :

- `PIPELINE_SERVICE_CLIENT_ENDPOINT: http://openmetadata-ingestion:8080`
- `AIRFLOW_USERNAME: admin`
- `AIRFLOW_PASSWORD: admin`

**Vous n'avez pas besoin de configurer manuellement la connexion Airflow dans l'interface OpenMetadata** - elle est déjà configurée au niveau du serveur.

Cependant, si vous souhaitez vérifier ou modifier la configuration dans l'interface :

1. Accéder à OpenMetadata : http://localhost:8585
2. Aller dans **Settings** > **Services** > **Pipelines**
3. Vous devriez voir le service Airflow déjà configuré
4. Si nécessaire, vous pouvez tester la connexion ou modifier les paramètres

**Note** : La configuration automatique utilise le nom du conteneur Docker (`openmetadata-ingestion`) au lieu de `localhost`, ce qui permet la communication entre conteneurs sur le réseau Docker.

## Dépannage

### Erreur "pull access denied"

Si vous obtenez une erreur de pull d'image, assurez-vous d'être connecté à Docker :
```bash
docker login docker.getcollate.io
```

### Erreur "Failed to trigger workflow due to airflow API returned Internal Server Error"

Si vous obtenez l'erreur `Failed to trigger workflow due to airflow API returned Internal Server Error` avec le message `Connection refused` sur `localhost:8585`, cela signifie que l'Airflow d'ingestion essaie de se connecter au serveur OpenMetadata via `localhost` au lieu d'utiliser le nom du conteneur Docker.

**Cause** : Lorsque OpenMetadata Server génère un workflow d'ingestion, il inclut l'URL du serveur OpenMetadata dans la configuration du workflow. Par défaut, cette URL est `localhost:8585`, ce qui ne fonctionne pas dans un environnement Docker.

**Solution** : Vérifiez que les variables d'environnement suivantes sont configurées dans `openmetadata-server` :

```bash
docker exec openmetadata-server env | grep -E "OPENMETADATA_SERVER_URL|SERVER_URL"
```

Vous devriez voir :
- `OPENMETADATA_SERVER_URL=http://openmetadata-server:8585` (pas `localhost`)
- `SERVER_URL=http://openmetadata-server:8585` (pas `localhost`)

Si ces variables ne sont pas présentes ou sont incorrectes, redémarrez le conteneur :

```bash
docker-compose --profile openmetadata restart openmetadata-server
```

**Note importante** : La variable clé `SERVER_HOST_API_URL` dans `openmetadata-server` contrôle l'URL utilisée dans les workflows générés. Cette variable doit pointer vers l'URL interne Docker (`http://openmetadata-server:8585/api`) pour que les workflows fonctionnent correctement.

**Après avoir modifié la configuration** : Vous devez **supprimer et recréer** le service de base de données dans OpenMetadata pour que le nouveau workflow utilise la bonne URL.

**Solution alternative** : Si le problème persiste, exécutez le script de correction des workflows :

```powershell
# Windows
.\scripts\fix-openmetadata-workflows.ps1

# Linux/Mac
chmod +x scripts/fix-openmetadata-workflows.sh
./scripts/fix-openmetadata-workflows.sh
```

Ce script remplace automatiquement `localhost:8585` par `openmetadata-server:8585` dans tous les workflows générés.

**Solution** : Vérifiez que les variables d'environnement suivantes sont configurées dans `openmetadata-ingestion` :

```bash
docker exec openmetadata-ingestion env | grep OPENMETADATA
```

Vous devriez voir :
- `OPENMETADATA_SERVER_URL=http://openmetadata-server:8585` (pas `localhost`)
- `OPENMETADATA_AUTH_PROVIDER=basic`
- `OPENMETADATA_USERNAME=admin@open-metadata.org`
- `OPENMETADATA_PASSWORD=admin`

Si ces variables ne sont pas présentes ou sont incorrectes, redémarrez le conteneur :

```bash
docker-compose --profile openmetadata restart openmetadata-ingestion
```

**Vérification de la connexion** :

```bash
# Tester la connexion depuis l'Airflow d'ingestion vers le serveur OpenMetadata
docker exec openmetadata-ingestion curl -s http://openmetadata-server:8585/api/v1/system/version
```

Cette commande doit retourner `{"version":"1.10.5",...}`

### Erreur "Failed to fetch queries, please validate if postgres instance has pg_stat_statements extension installed"

Si vous obtenez cette erreur lors de la configuration d'une connexion PostgreSQL dans OpenMetadata, cela signifie que l'extension `pg_stat_statements` n'est pas activée dans votre base de données PostgreSQL.

**Cause** : L'extension `pg_stat_statements` nécessite deux choses :
1. L'extension doit être créée dans la base de données
2. `shared_preload_libraries` doit contenir `pg_stat_statements` (nécessite un redémarrage)

**Solution** : La configuration est déjà incluse dans `docker-compose.yml` pour `postgres-mdm-hub`. Si vous utilisez une autre base de données PostgreSQL, vous devez :

1. **Créer l'extension** dans votre base de données :
```sql
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
```

2. **Configurer `shared_preload_libraries`** dans votre configuration PostgreSQL :
```conf
shared_preload_libraries = 'pg_stat_statements'
pg_stat_statements.max = 10000
pg_stat_statements.track = all
```

3. **Redémarrer PostgreSQL** pour que la configuration prenne effet.

**Vérification** :

```bash
# Vérifier que shared_preload_libraries contient pg_stat_statements
docker exec postgres-mdm-hub psql -U postgres -d mdm_clinique -c "SHOW shared_preload_libraries;"

# Vérifier que l'extension est installée
docker exec postgres-mdm-hub psql -U postgres -d mdm_clinique -c "SELECT extname, extversion FROM pg_extension WHERE extname = 'pg_stat_statements';"

# Tester que pg_stat_statements fonctionne
docker exec postgres-mdm-hub psql -U postgres -d mdm_clinique -c "SELECT * FROM pg_stat_statements LIMIT 1;"
```

**Note** : Pour `postgres-mdm-hub`, la configuration est automatique via `docker-compose.yml`. Si vous avez des problèmes, redémarrez le conteneur :

```bash
docker-compose restart postgres-mdm-hub
```

### Erreur "Failed to connect to Airflow"

Si vous obtenez l'erreur `Failed to connect to Airflow due to java.net.ConnectException`, vérifiez :

1. **Le service `openmetadata-ingestion` est démarré** :
   ```bash
   docker ps | grep openmetadata-ingestion
   ```

2. **La base de données Airflow est initialisée** :
   ```powershell
   # Windows
   .\scripts\init-openmetadata-airflow.ps1
   
   # Linux/Mac
   ./scripts/init-openmetadata-airflow.sh
   ```

3. **L'Airflow d'ingestion est accessible depuis le conteneur OpenMetadata Server** :
   ```bash
   docker exec openmetadata-server wget -q -O- http://openmetadata-ingestion:8080/api/v1/openmetadata/health
   ```
   Cette commande doit retourner `{"status": "healthy", "version": "1.9.11.6"}`

4. **Les variables d'environnement sont correctement configurées** :
   ```bash
   docker exec openmetadata-server env | grep PIPELINE_SERVICE_CLIENT_ENDPOINT
   docker exec openmetadata-server env | grep AIRFLOW_USERNAME
   ```
   - `PIPELINE_SERVICE_CLIENT_ENDPOINT` doit être `http://openmetadata-ingestion:8080` (pas `localhost`)
   - `AIRFLOW_USERNAME` doit être `admin`
   - `AIRFLOW_PASSWORD` doit être `admin`

5. **Redémarrer OpenMetadata Server après modification de la configuration** :
   ```bash
   docker-compose --profile openmetadata restart openmetadata-server
   ```

### Erreur de migration

Si la migration échoue, vous pouvez la relancer :
```bash
docker-compose --profile openmetadata-init up openmetadata-migrate
```

### Vérifier l'état des services

```bash
# Vérifier tous les services OpenMetadata
docker-compose ps | grep openmetadata

# Vérifier les logs d'OpenMetadata Server
docker logs openmetadata-server --tail 50

# Vérifier les logs d'OpenMetadata Ingestion
docker logs openmetadata-ingestion --tail 50
```

