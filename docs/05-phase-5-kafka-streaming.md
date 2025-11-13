# Phase 5 : Bonus - Streaming & Rapport

## Étape 5.1 : Implémenter le Flux Temps Réel (Kafka)

### Objectif

Montrer que votre MDM peut gérer les batchs (via Airflow) et le temps réel (via Kafka) pour les nouvelles inscriptions de patients.

### 1. Préparer Kafka : Créer votre Topic

#### Méthode 1 : Via le script automatique (Recommandé)

**Windows (PowerShell)** :
```powershell
.\scripts\create-kafka-topic.ps1
```

**Linux/Mac (Bash)** :
```bash
chmod +x scripts/create-kafka-topic.sh
./scripts/create-kafka-topic.sh
```

#### Méthode 2 : Création manuelle

**Option A : Via le conteneur Kafka directement**

```bash
# Entrer dans le conteneur Kafka
docker exec -it kafka bash

# Une fois à l'intérieur du conteneur, créer le topic
kafka-topics --create \
  --topic new_patient_registrations \
  --bootstrap-server localhost:9092 \
  --partitions 1 \
  --replication-factor 1

# Vérifier que le topic est créé
kafka-topics --list --bootstrap-server localhost:9092

# Taper exit pour quitter le conteneur
exit
```

**Option B : Depuis l'hôte (sans entrer dans le conteneur)**

```powershell
# Windows (PowerShell)
docker exec kafka kafka-topics --create `
  --topic new_patient_registrations `
  --bootstrap-server localhost:9092 `
  --partitions 1 `
  --replication-factor 1

# Vérifier
docker exec kafka kafka-topics --list --bootstrap-server localhost:9092
```

```bash
# Linux/Mac (Bash)
docker exec kafka kafka-topics --create \
  --topic new_patient_registrations \
  --bootstrap-server localhost:9092 \
  --partitions 1 \
  --replication-factor 1

# Vérifier
docker exec kafka kafka-topics --list --bootstrap-server localhost:9092
```

### 2. Vérifier que le topic est créé

```powershell
# Lister tous les topics
docker exec kafka kafka-topics --list --bootstrap-server localhost:9092

# Afficher les détails du topic
docker exec kafka kafka-topics --describe --topic new_patient_registrations --bootstrap-server localhost:9092
```

**Résultat attendu** :
```
Topic: new_patient_registrations
TopicId: xxxxx
PartitionCount: 1
ReplicationFactor: 1
Configs:
```

### 3. Tester le topic (Optionnel mais recommandé)

#### Publier un message (Producer)

Dans un terminal :
```powershell
# Windows (PowerShell)
docker exec -it kafka kafka-console-producer --topic new_patient_registrations --bootstrap-server localhost:9092
```

```bash
# Linux/Mac (Bash)
docker exec -it kafka kafka-console-producer --topic new_patient_registrations --bootstrap-server localhost:9092
```

Tapez un message de test (ex: `{"id": "123", "nom": "Test", "prenom": "Patient"}`) et appuyez sur Entrée.

Pour quitter, tapez `Ctrl+C`.

#### Consulter les messages (Consumer)

Dans un autre terminal :
```powershell
# Windows (PowerShell)
docker exec -it kafka kafka-console-consumer --topic new_patient_registrations --from-beginning --bootstrap-server localhost:9092
```

```bash
# Linux/Mac (Bash)
docker exec -it kafka kafka-console-consumer --topic new_patient_registrations --from-beginning --bootstrap-server localhost:9092
```

Vous devriez voir le message que vous avez publié.

Pour quitter, tapez `Ctrl+C`.

### 4. Prêt pour le Job Talend

Une fois le topic créé, vous pouvez créer votre job Talend qui :
1. Écoute le topic `new_patient_registrations` avec `tKafkaInput`
2. Nettoie les données avec `tMap`
3. Fait un lookup dans la table `MDM_Patient` pour voir si le patient existe
4. Insère ou met à jour dans `MDM_Patient` avec `tDBOutput`

### Commandes utiles

#### Lister tous les topics
```powershell
docker exec kafka kafka-topics --list --bootstrap-server localhost:9092
```

#### Détails d'un topic
```powershell
docker exec kafka kafka-topics --describe --topic new_patient_registrations --bootstrap-server localhost:9092
```

#### Supprimer un topic
```powershell
docker exec kafka kafka-topics --delete --topic new_patient_registrations --bootstrap-server localhost:9092
```

#### Compter les messages dans un topic
```powershell
docker exec kafka kafka-run-class kafka.tools.GetOffsetShell --broker-list localhost:9092 --topic new_patient_registrations
```

### Notes importantes

1. **Confluent Platform vs Apache Kafka** :
   - Ce projet utilise **Confluent Platform** (image `confluentinc/cp-kafka`)
   - Les commandes sont `kafka-topics` (sans `.sh`)
   - Pour Apache Kafka standard, les commandes seraient `kafka-topics.sh`

2. **Ports** :
   - **Kafka** : `localhost:9092` (depuis l'hôte)
   - **Kafka interne** : `kafka:29092` (depuis les autres conteneurs Docker)
   - **Zookeeper** : `localhost:2181`

3. **Auto-création de topics** :
   - `KAFKA_AUTO_CREATE_TOPICS_ENABLE: "true"` est activé dans `docker-compose.yml`
   - Kafka créera automatiquement le topic si un producer/consumer y accède
   - Mais il est recommandé de créer le topic explicitement avec les bonnes configurations

4. **Persistence** :
   - Les données Kafka sont stockées dans le volume `kafka_data`
   - Les topics et messages persistent même après un redémarrage des conteneurs

### Prochaines étapes

1. ✅ Topic `new_patient_registrations` créé
2. 🔄 Créer le job Talend `job_stream_patient`
3. 🔄 Configurer `tKafkaInput` pour écouter le topic
4. 🔄 Implémenter la logique de nettoyage et de lookup
5. 🔄 Tester le flux complet

