# Dépannage Airflow

## Problèmes courants et solutions

### 1. Erreur "airflow-webserver exited (1)"

#### Symptômes
```
✘ Container airflow-webserver Error
dependency failed to start: container airflow-webserver exited (1)
```

#### Solutions

**Solution 1 : Réinitialiser Airflow**
```powershell
# Arrêter tous les services
docker-compose down

# Supprimer les volumes Airflow (ATTENTION: supprime les données)
docker volume rm projet-data-modeling_airflow_db_data

# Corriger les permissions
.\scripts\fix-airflow-permissions.ps1

# Réinitialiser Airflow
docker-compose --profile init up airflow-init

# Redémarrer les services
docker-compose up -d
```

**Solution 2 : Vérifier les logs**
```powershell
docker-compose logs airflow-webserver
docker-compose logs airflow-init
```

**Solution 3 : Vérifier la base de données**
```powershell
# Vérifier que la base de données Airflow est accessible
docker exec -it airflow-db psql -U airflow -d airflow -c "\dt"
```

### 2. Erreur de permissions sur les volumes

#### Symptômes
```
Permission denied: /opt/airflow/dags
```

#### Solutions

**Sur Windows :**
Les permissions sont généralement OK, mais assurez-vous que les répertoires existent :
```powershell
.\scripts\fix-airflow-permissions.ps1
```

**Sur Linux/Mac :**
```bash
# Définir l'UID Airflow (généralement 50000)
export AIRFLOW_UID=50000

# Créer les répertoires avec les bonnes permissions
mkdir -p airflow/{dags,logs,plugins,config}
chown -R 50000:0 airflow/
```

### 3. Erreur "Database is not initialized"

#### Solution
```powershell
# Forcer la réinitialisation
docker-compose --profile init up airflow-init --force-recreate
```

### 4. Erreur de connexion à la base de données

#### Vérifications
```powershell
# Vérifier que la base de données est démarrée
docker-compose ps airflow-db

# Tester la connexion
docker exec -it airflow-db psql -U airflow -d airflow -c "SELECT 1;"
```

### 5. Le webserver ne démarre pas après l'initialisation

#### Solution
Assurez-vous que l'initialisation est complète avant de démarrer le webserver :
```powershell
# 1. Initialiser (attendre la fin)
docker-compose --profile init up airflow-init

# 2. Vérifier que c'est terminé
docker-compose ps airflow-init

# 3. Démarrer les autres services
docker-compose up -d
```

### 6. Erreur "FERNET_KEY" ou "SECRET_KEY"

Ces erreurs sont maintenant gérées automatiquement dans la configuration. Si elles persistent :

```powershell
# Arrêter les services
docker-compose down

# Supprimer les volumes
docker volume rm projet-data-modeling_airflow_db_data

# Redémarrer
docker-compose --profile init up airflow-init
docker-compose up -d
```

## Commandes utiles

### Voir les logs en temps réel
```powershell
docker-compose logs -f airflow-webserver
docker-compose logs -f airflow-scheduler
docker-compose logs -f airflow-init
```

### Redémarrer un service spécifique
```powershell
docker-compose restart airflow-webserver
docker-compose restart airflow-scheduler
```

### Accéder au shell d'un conteneur
```powershell
docker exec -it airflow-webserver bash
docker exec -it airflow-scheduler bash
```

### Vérifier l'état de la base de données
```powershell
docker exec -it airflow-db psql -U airflow -d airflow
```

Dans psql :
```sql
-- Voir les tables
\dt

-- Voir les utilisateurs
SELECT * FROM ab_user;

-- Voir les connexions
SELECT * FROM connection;
```

## Réinitialisation complète

Si rien ne fonctionne, réinitialisez complètement Airflow :

```powershell
# 1. Arrêter tous les services
docker-compose down

# 2. Supprimer les volumes Airflow
docker volume rm projet-data-modeling_airflow_db_data

# 3. Supprimer les fichiers locaux (optionnel)
Remove-Item -Recurse -Force airflow\logs\*
Remove-Item -Recurse -Force airflow\dags\*

# 4. Recréer les répertoires
.\scripts\fix-airflow-permissions.ps1

# 5. Réinitialiser
docker-compose --profile init up airflow-init

# 6. Démarrer les services
docker-compose up -d
```

## Vérification finale

Une fois tout démarré, vérifiez :

1. **Services en cours d'exécution** :
```powershell
docker-compose ps
```

2. **Accès au webserver** :
Ouvrez http://localhost:8080 dans votre navigateur
- Username: `admin`
- Password: `admin`

3. **Logs sans erreur** :
```powershell
docker-compose logs airflow-webserver | Select-String -Pattern "ERROR" -Context 2
```

