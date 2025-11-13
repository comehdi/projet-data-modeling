# Configurer un Service Pipeline dans OpenMetadata pour voir les DAGs Airflow

## Problème
Le DAG `mdm_pipeline` est visible dans l'Airflow (port 8080) mais n'apparaît pas dans OpenMetadata UI sous "Pipelines".

## Solution : Configurer un Service Pipeline

Pour que OpenMetadata découvre automatiquement les DAGs Airflow, vous devez configurer un **Service Pipeline** qui pointe vers votre Airflow.

### Étapes dans OpenMetadata UI

1. **Ouvrez OpenMetadata**
   - URL : http://localhost:8585
   - Email : `admin@open-metadata.org`
   - Password : `admin`

2. **Créer un nouveau Service Pipeline**
   - Allez dans **Settings** (⚙️) > **Services** > **Pipelines**
   - Cliquez sur **"Add New Service"**
   - Sélectionnez **"Airflow"**

3. **Configurer la connexion**
   - **Name** : `MDM Airflow Pipeline Service` (ou un nom de votre choix)
   - **Description** : `Service Pipeline pour découvrir les DAGs MDM depuis l'Airflow OpenMetadata`
   - **Host and Port** : `openmetadata-ingestion:8080` (nom du conteneur Docker et port interne)
   - **Username** : `admin`
   - **Password** : `admin`
   - **Connection Options** (optionnel) :
     ```
     timeout=10
     ```

4. **Tester la connexion**
   - Cliquez sur **"Test Connection"**
   - Vous devriez voir un message de succès

5. **Sauvegarder**
   - Cliquez sur **"Save"**

6. **Vérifier la découverte**
   - Allez dans **Explore** > **Pipelines**
   - Vous devriez maintenant voir le DAG `mdm_pipeline` dans la liste
   - Cliquez dessus pour voir les détails

### Alternative : Via l'API (si l'UI ne fonctionne pas)

Si vous préférez configurer via l'API, vous pouvez utiliser cette commande :

```powershell
# Note: Cette méthode nécessite un token d'authentification
# Il est plus simple d'utiliser l'UI OpenMetadata
```

### Vérification

Après la configuration, vous devriez voir :
- Le service Pipeline dans **Settings** > **Services** > **Pipelines**
- Le DAG `mdm_pipeline` dans **Explore** > **Pipelines**
- Les détails du DAG (tâches, schedule, etc.) en cliquant dessus

### Notes importantes

- Le service Pipeline doit pointer vers `openmetadata-ingestion:8080` (nom du conteneur Docker)
- OpenMetadata découvrira automatiquement tous les DAGs actifs dans cet Airflow
- Les DAGs en pause (`is_paused: true`) peuvent ne pas apparaître immédiatement
- La découverte peut prendre quelques secondes après la sauvegarde

### Dépannage

Si le DAG n'apparaît toujours pas :

1. **Vérifier que le DAG est actif dans Airflow**
   ```powershell
   # Ouvrez http://localhost:8080 et vérifiez que mdm_pipeline est actif
   ```

2. **Vérifier la connexion du service Pipeline**
   - Dans OpenMetadata UI : **Settings** > **Services** > **Pipelines** > votre service
   - Cliquez sur **"Test Connection"** pour vérifier

3. **Forcer une nouvelle découverte**
   - Dans le service Pipeline, cliquez sur **"Ingest"** ou **"Run Ingestion"**
   - Attendez la fin de l'ingestion

4. **Vérifier les logs**
   ```powershell
   docker logs openmetadata-server --tail 100 | Select-String -Pattern "pipeline|airflow" -CaseSensitive:$false
   ```

