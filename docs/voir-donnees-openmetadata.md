# Comment voir les données dans OpenMetadata

## Problème
Les colonnes sont visibles dans OpenMetadata, mais les lignes (données) ne s'affichent pas.

## Solution : Activer le Data Profiler

OpenMetadata ne montre pas les données par défaut - il faut activer le **Data Profiler** pour voir les données d'échantillon.

### Méthode 1 : Via l'interface OpenMetadata (Recommandé)

1. **Ouvrez OpenMetadata**
   - URL : http://localhost:8585
   - Email : `admin@open-metadata.org`
   - Password : `admin`

2. **Accédez au pipeline d'ingestion**
   - Allez dans **Settings** (⚙️) > **Services** > **Databases**
   - Cliquez sur **MDM Clinique Hub**
   - Cliquez sur l'onglet **"Ingestion Pipelines"**
   - Cliquez sur le pipeline actif (celui avec le statut "Deployed")

3. **Modifiez la configuration**
   - Cliquez sur **"Edit"** (icône crayon)
   - Faites défiler jusqu'à **"Advanced Configuration"**
   - Activez les options suivantes :
     - ✅ **Generate Sample Data** : `true`
     - **Profile Sample** : `100.0` (pour profiler 100% des données)
   - Cliquez sur **"Save"**

4. **Relancez l'ingestion**
   - Cliquez sur **"Run Now"** pour relancer l'ingestion
   - Attendez la fin de l'exécution (1-2 minutes)
   - Vous pouvez suivre la progression dans l'onglet **"Runs"**

5. **Vérifiez les données**
   - Allez dans **Explore** > **Databases** > **MDM Clinique Hub** > **mdm_clinique** > **public**
   - Cliquez sur une table (ex: `mdm_patient`)
   - Allez dans l'onglet **"Sample Data"** ou **"Profiler & Data Quality"**
   - Vous devriez maintenant voir les données d'échantillon

### Méthode 2 : Via l'onglet Queries (Alternative)

Si vous ne voulez pas activer le profiler, vous pouvez exécuter des requêtes SQL directement :

1. **Ouvrez une table dans OpenMetadata**
   - Allez dans **Explore** > **Databases** > **MDM Clinique Hub** > **mdm_clinique** > **public**
   - Cliquez sur une table (ex: `mdm_patient`)

2. **Exécutez une requête SQL**
   - Allez dans l'onglet **"Queries"**
   - Cliquez sur **"Add Query"**
   - Entrez une requête SQL, par exemple :
     ```sql
     SELECT * FROM mdm_patient LIMIT 10;
     ```
   - Cliquez sur **"Run"**
   - Les résultats s'afficheront dans l'interface

### Vérification que les données existent dans PostgreSQL

Avant d'activer le profiler, vérifiez que les données sont bien présentes dans PostgreSQL :

```powershell
docker exec postgres-mdm-hub psql -U postgres -d mdm_clinique -c "SELECT 'mdm_patient' as table_name, COUNT(*) as row_count FROM mdm_patient UNION ALL SELECT 'mdm_praticien', COUNT(*) FROM mdm_praticien UNION ALL SELECT 'mdm_service', COUNT(*) FROM mdm_service UNION ALL SELECT 'mdm_location', COUNT(*) FROM mdm_location;"
```

Vous devriez voir :
- `mdm_patient` : ~145 lignes
- `mdm_praticien` : ~174 lignes
- `mdm_service` : ~27 lignes
- `mdm_location` : ~114 lignes

### Si les données ne sont pas dans PostgreSQL

Si les tables sont vides dans PostgreSQL, vous devez exécuter les jobs Talend :

1. **Vérifiez que le DAG est actif**
   ```powershell
   docker exec airflow-webserver airflow dags list | grep mdm_pipeline
   ```

2. **Déclenchez le DAG**
   ```powershell
   docker exec airflow-webserver airflow dags trigger mdm_pipeline
   ```

3. **Suivez l'exécution**
   - Interface web : http://localhost:8081 (admin/admin)
   - Ou via les logs :
     ```powershell
     docker-compose logs -f airflow-scheduler
     ```

4. **Vérifiez les données après l'exécution**
   - Utilisez la commande de vérification ci-dessus

## Notes importantes

- **Le Data Profiler** analyse les données et génère des statistiques (min, max, moyenne, etc.)
- **Sample Data** affiche un échantillon des données (par défaut, les 10 premières lignes)
- **Profile Sample** contrôle le pourcentage de données à analyser (100% = toutes les données)
- L'activation du profiler peut prendre 1-2 minutes selon la taille des données
- Les données d'échantillon sont mises à jour à chaque ingestion

## Dépannage

### L'onglet "Sample Data" n'apparaît pas

1. Vérifiez que l'ingestion avec le profiler a réussi
2. Rafraîchissez la page (F5)
3. Attendez quelques secondes - le profiler peut prendre du temps
4. Vérifiez les logs d'ingestion dans l'onglet "Runs"

### Les données ne s'affichent toujours pas

1. Vérifiez que les données existent dans PostgreSQL (voir ci-dessus)
2. Vérifiez que `Generate Sample Data` est bien activé dans la configuration
3. Relancez l'ingestion avec `Override Metadata: true` et `Force Entity Overwriting: true`
4. Consultez les logs d'ingestion pour voir les erreurs éventuelles

