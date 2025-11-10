# Phase 4 : Gouvernance, Data Catalogue & Data Quality

## Objectif
Documenter votre travail et prouver la qualité des données en utilisant OpenMetadata. C'est le cœur des piliers **Data Catalogue** et **Data Quality**.

---

## Étape 4.1 : Créer le Data Catalogue

### 4.1.1 : Connexion à OpenMetadata

1. **Accéder à l'interface OpenMetadata**
   - URL : http://localhost:8585
   - Email : `admin@open-metadata.org`
   - Password : `admin`

2. **Vérifier que les services sont actifs**
   ```powershell
   docker ps --filter "name=openmetadata" --format "table {{.Names}}\t{{.Status}}"
   ```

### 4.1.2 : Connecter OpenMetadata à la base PostgreSQL MDM Hub

1. Dans OpenMetadata, aller dans **Settings** (⚙️) > **Services** > **Databases**

2. Cliquer sur **Add New Service** > **PostgreSQL**

3. Remplir le formulaire de connexion :
   - **Name** : `MDM Clinique Hub`
   - **Description** : `Base de données Master Data Management pour Groupe Santé Horizon`
   - **Host** : `postgres-mdm-hub` (nom du conteneur Docker)
   - **Port** : `5432` (port interne Docker)
   - **Database** : `mdm_clinique`
   - **Username** : `postgres`
   - **Password** : `root`
   - **Connection Options** (optionnel) : 
     ```
     connectTimeout=10
     ```

4. Cliquer sur **Test Connection** pour vérifier la connexion

5. Cliquer sur **Save**

### 4.1.3 : Ingérer les 4 tables MDM

Une fois la connexion établie, OpenMetadata va scanner automatiquement la base de données. Si les tables n'apparaissent pas automatiquement :

1. Aller dans **Settings** > **Services** > **Databases** > **MDM Clinique Hub**

2. Cliquer sur **Ingest** ou **Run Ingestion**

3. Sélectionner les tables à ingérer :
   - ✅ `mdm_patient`
   - ✅ `mdm_praticien`
   - ✅ `mdm_service`
   - ✅ `mdm_location`

4. Lancer l'ingestion

5. Vérifier que les 4 tables apparaissent dans **Explore** > **Tables**

---

## Étape 4.2 : Créer le Dictionnaire de Données

### 4.2.1 : Attribuer un Owner à chaque table

Pour chaque table MDM, attribuer le membre du groupe responsable :

1. Aller dans **Explore** > **Tables** > Sélectionner une table (ex: `mdm_patient`)

2. Cliquer sur **Edit** (icône crayon) en haut à droite

3. Dans l'onglet **Details** :
   - **Owner** : Cliquer sur **+ Add Owner**
   - Sélectionner ou créer l'utilisateur correspondant au membre du groupe
   - Exemple : 
     - `mdm_patient` → Owner : Membre 1 (Vous)
     - `mdm_praticien` → Owner : Membre 2
     - `mdm_service` → Owner : Membre 3
     - `mdm_location` → Owner : Membre 4

4. Cliquer sur **Save**

### 4.2.2 : Ajouter des Tags

1. Dans la page de la table, section **Tags**

2. Cliquer sur **+ Add Tag**

3. Ajouter les tags suivants :
   - `Master Data` (obligatoire pour toutes les tables MDM)
   - `PII` (Personally Identifiable Information) pour `mdm_patient` et `mdm_praticien`
   - `Sensitive` pour les données sensibles
   - `Golden Record` (pour indiquer que ce sont les enregistrements de référence)

4. Cliquer sur **Save**

### 4.2.3 : Documenter chaque colonne

Pour chaque table, éditer le schéma et ajouter des descriptions claires pour chaque colonne :

#### Table : `mdm_patient`

| Colonne | Description |
|---------|-------------|
| `master_patient_id` | Identifiant unique universel (UUID) du patient dans le système MDM. Clé primaire générée automatiquement. |
| `golden_first_name` | Prénom unifié et normalisé du patient. Source de vérité pour toutes les applications. |
| `golden_last_name` | Nom de famille unifié et normalisé du patient. Source de vérité pour toutes les applications. |
| `golden_date_of_birth` | Date de naissance unifiée du patient au format DATE. Source de vérité pour le calcul de l'âge. |
| `golden_phone` | Numéro de téléphone unifié du patient au format E.164. Source de vérité pour les communications. |
| `golden_email` | Adresse email unifiée du patient. Source de vérité pour les communications électroniques. |
| `golden_address` | Adresse postale complète unifiée du patient. Source de vérité pour l'envoi de courrier. |
| `allergy_list_consolidated` | Liste consolidée de toutes les allergies du patient, agrégée depuis toutes les sources. Format : texte séparé par virgules. |
| `source_system_ids` | JSON contenant les identifiants originaux du patient dans chaque système source (clinique A, B, C). Format : `{"clinique_a": "101", "clinique_b": "P-45", "clinique_c": "PAT-789"}` |
| `last_updated_at` | Timestamp de la dernière mise à jour de l'enregistrement golden. Utilisé pour la traçabilité. |

#### Table : `mdm_praticien`

| Colonne | Description |
|---------|-------------|
| `master_praticien_id` | Identifiant unique universel (UUID) du praticien dans le système MDM. Clé primaire générée automatiquement. |
| `golden_first_name` | Prénom unifié et normalisé du praticien. |
| `golden_last_name` | Nom de famille unifié et normalisé du praticien. |
| `golden_specialty` | Spécialité médicale unifiée du praticien. Source de vérité pour le catalogage. |
| `golden_license_number` | Numéro de licence professionnelle unifié. Source de vérité pour la vérification des autorisations. |
| `golden_email` | Adresse email professionnelle unifiée du praticien. |
| `golden_phone` | Numéro de téléphone professionnel unifié du praticien. |
| `status_consolidated` | Statut consolidé du praticien (ex: interne, externe, consultant). |
| `source_system_ids` | JSON contenant les identifiants originaux du praticien dans chaque système source. |
| `last_updated_at` | Timestamp de la dernière mise à jour. |

#### Table : `mdm_service`

| Colonne | Description |
|---------|-------------|
| `master_service_id` | Identifiant unique universel (UUID) du service/acte médical dans le système MDM. |
| `golden_service_name` | Nom unifié et normalisé du service médical. Source de vérité pour le catalogage. |
| `golden_service_code` | Code unifié du service (ex: code CCAM, NABM). Source de vérité pour la facturation. |
| `golden_category` | Catégorie unifiée du service (ex: Consultation, Examen, Intervention). |
| `golden_description` | Description unifiée et complète du service. |
| `golden_price` | Prix unifié du service en euros. Source de vérité pour la facturation. |
| `source_system_ids` | JSON contenant les identifiants originaux du service dans chaque système source. |
| `last_updated_at` | Timestamp de la dernière mise à jour. |

#### Table : `mdm_location`

| Colonne | Description |
|---------|-------------|
| `master_location_id` | Identifiant unique universel (UUID) du site/location dans le système MDM. |
| `golden_location_name` | Nom unifié et normalisé du site (ex: "Clinique A - Bâtiment Principal"). |
| `golden_location_type` | Type unifié du site (ex: Clinique, Laboratoire, Bureau administratif). |
| `golden_address` | Adresse postale complète unifiée du site. |
| `golden_city` | Ville unifiée du site. |
| `golden_postal_code` | Code postal unifié du site. |
| `golden_country` | Pays unifié du site (par défaut: France). |
| `golden_phone` | Numéro de téléphone principal unifié du site. |
| `source_system_ids` | JSON contenant les identifiants originaux du site dans chaque système source. |
| `last_updated_at` | Timestamp de la dernière mise à jour. |

**Comment ajouter les descriptions dans OpenMetadata :**

1. Aller dans la page de la table
2. Cliquer sur **Edit Schema** (ou **Edit** > **Schema**)
3. Pour chaque colonne, cliquer sur l'icône **Edit** (crayon)
4. Remplir le champ **Description**
5. Cliquer sur **Save**

---

## Étape 4.3 : Configurer les Métriques de Data Quality

### 4.3.1 : Accéder à Data Quality

1. Aller dans **Explore** > **Tables** > Sélectionner une table (ex: `mdm_patient`)

2. Cliquer sur l'onglet **Data Quality**

3. Cliquer sur **Add Test Suite** ou **Configure Tests**

### 4.3.2 : Créer les Test Suites

Pour chaque table MDM, créer les tests suivants :

#### Tests pour `mdm_patient`

1. **Test de Complétude**
   - **Test Name** : `patient_dob_not_null`
   - **Test Type** : `columnValuesToBeNotNull`
   - **Column** : `golden_date_of_birth`
   - **Description** : Vérifie que la date de naissance n'est jamais NULL (obligatoire pour le calcul de l'âge)

   - **Test Name** : `patient_last_name_not_null`
   - **Test Type** : `columnValuesToBeNotNull`
   - **Column** : `golden_last_name`
   - **Description** : Vérifie que le nom de famille n'est jamais NULL (obligatoire pour l'identification)

2. **Test de Validité**
   - **Test Name** : `patient_phone_format_valid`
   - **Test Type** : `columnValuesToMatchRegex`
   - **Column** : `golden_phone`
   - **Regex Pattern** : `^(\+33|0)[1-9](\d{2}){4}$`
   - **Description** : Vérifie que le numéro de téléphone respecte le format français (E.164 ou format national)

   - **Test Name** : `patient_email_format_valid`
   - **Test Type** : `columnValuesToMatchRegex`
   - **Column** : `golden_email`
   - **Regex Pattern** : `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`
   - **Description** : Vérifie que l'email respecte un format valide

3. **Test d'Unicité**
   - **Test Name** : `patient_id_unique`
   - **Test Type** : `columnValuesToBeUnique`
   - **Column** : `master_patient_id`
   - **Description** : Vérifie que chaque patient a un identifiant unique (clé primaire)

4. **Test de Cohérence**
   - **Test Name** : `patient_count_reasonable`
   - **Test Type** : `tableRowCountToBeBetween`
   - **Min Value** : `1`
   - **Max Value** : `1000000`
   - **Description** : Vérifie que le nombre de patients est raisonnable (entre 1 et 1 million)

#### Tests pour `mdm_praticien`

1. **Complétude**
   - `praticien_last_name_not_null` : `columnValuesToBeNotNull` sur `golden_last_name`
   - `praticien_license_not_null` : `columnValuesToBeNotNull` sur `golden_license_number`

2. **Validité**
   - `praticien_email_format_valid` : `columnValuesToMatchRegex` sur `golden_email` avec pattern email

3. **Unicité**
   - `praticien_id_unique` : `columnValuesToBeUnique` sur `master_praticien_id`

4. **Cohérence**
   - `praticien_count_reasonable` : `tableRowCountToBeBetween` entre 1 et 10000

#### Tests pour `mdm_service`

1. **Complétude**
   - `service_name_not_null` : `columnValuesToBeNotNull` sur `golden_service_name`
   - `service_code_not_null` : `columnValuesToBeNotNull` sur `golden_service_code`

2. **Validité**
   - `service_price_positive` : `columnValuesToBeBetween` sur `golden_price` entre 0 et 100000

3. **Unicité**
   - `service_id_unique` : `columnValuesToBeUnique` sur `master_service_id`

4. **Cohérence**
   - `service_count_reasonable` : `tableRowCountToBeBetween` entre 1 et 100000

#### Tests pour `mdm_location`

1. **Complétude**
   - `location_name_not_null` : `columnValuesToBeNotNull` sur `golden_location_name`
   - `location_address_not_null` : `columnValuesToBeNotNull` sur `golden_address`

2. **Validité**
   - `location_postal_code_format` : `columnValuesToMatchRegex` sur `golden_postal_code` avec pattern `^\d{5}$` (5 chiffres)

3. **Unicité**
   - `location_id_unique` : `columnValuesToBeUnique` sur `master_location_id`

4. **Cohérence**
   - `location_count_reasonable` : `tableRowCountToBeBetween` entre 1 et 10000

### 4.3.3 : Lancer les tests

1. Une fois tous les tests configurés, cliquer sur **Run Tests** ou **Execute Test Suite**

2. Attendre l'exécution des tests (quelques secondes à quelques minutes selon le volume de données)

3. Vérifier les résultats dans le **Data Quality Dashboard**

4. **Objectif** : Avoir **100% de succès** sur tous les tests, prouvant que votre Data Wrangling a fonctionné correctement

### 4.3.4 : Interpréter les résultats

- ✅ **Success (Vert)** : Le test a réussi, la qualité des données est bonne
- ❌ **Failed (Rouge)** : Le test a échoué, il y a un problème de qualité à corriger
- ⚠️ **Warning (Jaune)** : Le test a généré un avertissement

**Si un test échoue :**
1. Cliquer sur le test pour voir les détails
2. Identifier les lignes problématiques
3. Corriger le job Talend si nécessaire
4. Relancer le pipeline Airflow
5. Réexécuter les tests

---

## Résumé des livrables Phase 4

À la fin de cette phase, vous devez avoir :

1. ✅ **Data Catalogue créé** : Les 4 tables MDM visibles dans OpenMetadata
2. ✅ **Owners attribués** : Chaque table a un owner (membre du groupe)
3. ✅ **Tags ajoutés** : Tags `Master Data`, `PII`, `Sensitive`, `Golden Record`
4. ✅ **Dictionnaire de données complet** : Toutes les colonnes documentées avec des descriptions claires
5. ✅ **Tests de Data Quality configurés** : Au moins 3-4 tests par table (Complétude, Validité, Unicité, Cohérence)
6. ✅ **Dashboard Data Quality à 100%** : Tous les tests passent avec succès

---

## Commandes utiles

```powershell
# Vérifier l'état d'OpenMetadata
docker ps --filter "name=openmetadata"

# Vérifier les logs d'OpenMetadata
docker logs openmetadata_server --tail 50

# Vérifier la connexion à la base MDM
docker exec postgres-mdm-hub psql -U postgres -d mdm_clinique -c "\dt"

# Compter les lignes dans chaque table MDM
docker exec postgres-mdm-hub psql -U postgres -d mdm_clinique -c "SELECT 'mdm_patient' as table_name, COUNT(*) as count FROM mdm_patient UNION ALL SELECT 'mdm_praticien', COUNT(*) FROM mdm_praticien UNION ALL SELECT 'mdm_service', COUNT(*) FROM mdm_service UNION ALL SELECT 'mdm_location', COUNT(*) FROM mdm_location ORDER BY table_name;"
```

---

## Prochaines étapes

Une fois la Phase 4 complète, vous pouvez passer à la **Phase 5 (Bonus)** : Streaming avec Kafka et rédaction du rapport final.

