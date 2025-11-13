# Ingestion complète avec données visibles dans OpenMetadata

## Objectif
Ingérer les tables PostgreSQL MDM dans OpenMetadata et voir les données (pas seulement les colonnes).

## Prérequis
- ✅ Database Service PostgreSQL configuré
- ✅ Pipeline Service Airflow configuré
- ✅ Données présentes dans PostgreSQL

## Étapes

### Étape 1 : Vérifier le Database Service

1. Ouvrez http://localhost:8585
2. Allez dans **Settings** > **Services** > **Databases**
3. Vérifiez que **"MDM Clinique Hub"** existe
   - Si non, créez-le :
     - **Add New Service** > **PostgreSQL**
     - **Name** : `MDM Clinique Hub`
     - **Host and Port** : `postgres-mdm-hub:5432`
     - **Database** : `mdm_clinique`
     - **Username** : `postgres`
     - **Password** : `root`
     - **Test Connection** > **Save**

### Étape 2 : Créer/Configurer le Pipeline d'Ingestion

1. Dans **Settings** > **Services** > **Databases** > **MDM Clinique Hub**
2. Cliquez sur l'onglet **"Ingestion Pipelines"**
3. Si aucun pipeline n'existe :
   - Cliquez sur **"Add Ingestion Pipeline"**
   - Sélectionnez **"Metadata"** (pour ingérer les tables et colonnes)
   - Cliquez sur **"Next"**
4. Si un pipeline existe déjà :
   - Cliquez sur le pipeline actif
   - Cliquez sur **"Edit"** (icône crayon)

### Étape 3 : Configurer l'Ingestion avec Data Profiler

Dans la configuration du pipeline :

1. **Sélection des tables** :
   - Dans **"Table Filter Pattern"**, sélectionnez :
     - ✅ `mdm_patient`
     - ✅ `mdm_praticien`
     - ✅ `mdm_service`
     - ✅ `mdm_location`
   - Ou utilisez le pattern : `mdm_.*` pour toutes les tables MDM

2. **Configuration avancée** (IMPORTANT pour voir les données) :
   - Faites défiler jusqu'à **"Advanced Configuration"**
   - Activez les options suivantes :
     - ✅ **Generate Sample Data** : `true` (pour voir les données d'échantillon)
     - **Profile Sample** : `100.0` (pour profiler 100% des données)
     - ✅ **Override Metadata** : `true` (pour forcer la réingestion)
     - ✅ **Force Entity Overwriting** : `true` (pour écraser les métadonnées existantes)

3. **Schedule** (optionnel) :
   - Configurez une planification si vous voulez des ingestions automatiques
   - Exemple : `Daily` à `02:00`

4. Cliquez sur **"Save"**

### Étape 4 : Lancer l'Ingestion

1. Dans l'onglet **"Ingestion Pipelines"**
2. Cliquez sur le pipeline que vous venez de configurer
3. Cliquez sur **"Run Now"** (ou **"Deploy"** puis **"Run Now"**)
4. Attendez la fin de l'exécution (1-2 minutes)
   - Vous pouvez suivre la progression dans l'onglet **"Runs"**
   - Le statut devrait passer à **"Success"** (vert)

### Étape 5 : Vérifier les Données

1. Allez dans **Explore** > **Databases** > **MDM Clinique Hub**
2. Cliquez sur **"mdm_clinique"** > **"public"**
3. Cliquez sur une table (ex: `mdm_patient`)
4. Vérifiez les onglets :
   - **Schema** : Les colonnes devraient être visibles ✅
   - **Sample Data** : Les données d'échantillon devraient être visibles ✅
   - **Profiler & Data Quality** : Les statistiques devraient être disponibles ✅

## Vérification des Données

### Dans PostgreSQL
```powershell
docker exec postgres-mdm-hub psql -U postgres -d mdm_clinique -c "SELECT 'mdm_patient' as table_name, COUNT(*) as row_count FROM mdm_patient UNION ALL SELECT 'mdm_praticien', COUNT(*) FROM mdm_praticien UNION ALL SELECT 'mdm_service', COUNT(*) FROM mdm_service UNION ALL SELECT 'mdm_location', COUNT(*) FROM mdm_location;"
```

Vous devriez voir :
- `mdm_patient` : ~145 lignes
- `mdm_praticien` : ~174 lignes
- `mdm_service` : ~27 lignes
- `mdm_location` : ~114 lignes

### Dans OpenMetadata UI

1. **Tables visibles** :
   - Explore > Databases > MDM Clinique Hub > mdm_clinique > public
   - Vous devriez voir les 4 tables MDM

2. **Colonnes visibles** :
   - Cliquez sur une table
   - Onglet **Schema** : Toutes les colonnes devraient être listées

3. **Données visibles** :
   - Onglet **Sample Data** : Les 10 premières lignes devraient être affichées
   - Onglet **Profiler & Data Quality** : Statistiques (min, max, moyenne, etc.)

## Dépannage

### Les tables n'apparaissent pas

1. Vérifiez que l'ingestion a réussi (onglet **"Runs"**)
2. Rafraîchissez la page (F5)
3. Vérifiez les logs d'ingestion pour les erreurs

### Les colonnes sont vides

1. Relancez l'ingestion avec **Override Metadata: true**
2. Vérifiez que les tables existent dans PostgreSQL
3. Consultez les logs d'ingestion

### Les données (Sample Data) ne s'affichent pas

1. Vérifiez que **Generate Sample Data: true** est activé
2. Vérifiez que **Profile Sample: 100.0** est configuré
3. Relancez l'ingestion
4. Attendez quelques secondes après l'ingestion (le profiler peut prendre du temps)
5. Rafraîchissez la page

### L'ingestion échoue

1. Vérifiez les logs dans l'onglet **"Runs"** > **"Show Logs"**
2. Vérifiez que PostgreSQL est accessible depuis OpenMetadata
3. Vérifiez les identifiants de connexion
4. Vérifiez que les tables existent dans PostgreSQL

## Résumé des Options Importantes

| Option | Valeur | Description |
|--------|--------|-------------|
| **Generate Sample Data** | `true` | Active l'affichage des données d'échantillon |
| **Profile Sample** | `100.0` | Pourcentage de données à profiler (100% = toutes) |
| **Override Metadata** | `true` | Force la réingestion même si les tables existent |
| **Force Entity Overwriting** | `true` | Écrase les métadonnées existantes |

## Notes

- **Sample Data** affiche les 10 premières lignes par défaut
- **Profiler** analyse les données et génère des statistiques
- L'activation du profiler peut prendre 1-2 minutes selon la taille des données
- Les données sont mises à jour à chaque ingestion

