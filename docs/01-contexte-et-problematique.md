# Phase 1.1 : Contexte & Problématique

## Contexte

**Groupe Santé Horizon** est un groupe hospitalier formé par le rachat et la fusion de trois cliniques indépendantes :

- **Clinique A** : Spécialisée en chirurgie et médecine générale, située en zone urbaine
- **Clinique B** : Centre de soins ambulatoires avec un laboratoire d'analyses intégré
- **Clinique C** : Clinique spécialisée en cardiologie et médecine préventive

Chacune de ces cliniques possède son propre système d'information (SI) hétérogène :
- **Clinique A** : Système HIS (Hospital Information System) propriétaire
- **Clinique B** : Système de gestion de laboratoire (LABSYS) + système de facturation
- **Clinique C** : Système de dossiers médicaux électroniques (EMR) + système de planification

## Problématique : Perte de la Maîtrise des Données

La fusion de ces trois entités a créé une situation critique de **perte de maîtrise des données maîtres**, avec des conséquences opérationnelles, médicales et financières graves.

### Exemple 1 : Patient - Problème de Duplication

**Scénario** : Monsieur Jean Dupont est un patient qui a consulté dans les trois cliniques.

- **Dans la Clinique A** : Enregistré comme "Dupont, Jean" (ID: P-101), né le 01/05/1980, adresse "15 Rue de la Paix, Paris", allergie à la pénicilline
- **Dans la Clinique B** : Enregistré comme "Dupond, Jean" (ID: P-45), date de naissance 1980/05/01, adresse "15 Rue de la Paix 75001", pas d'allergie enregistrée
- **Dans la Clinique C** : Enregistré comme "DUPONT Jean" (ID: PAT-789), né le 1 mai 1980, adresse "15 rue de la Paix", allergie à la pénicilline et aux sulfamides

**Conséquences** :
- ❌ **Risque médical** : L'allergie aux sulfamides n'est pas visible dans tous les systèmes, risque d'erreur médicale grave
- ❌ **Facturation impossible** : Impossible de consolider les factures du patient, perte de revenus
- ❌ **Suivi médical fragmenté** : Historique médical incomplet, décisions cliniques basées sur des informations partielles
- ❌ **Conformité RGPD** : Difficulté à répondre aux demandes d'accès aux données personnelles

### Exemple 2 : Praticien - Problème de Traçabilité

**Scénario** : Le Docteur Martin est un cardiologue qui intervient dans plusieurs cliniques.

- **Dans la Clinique A** : "Dr. Martin, Pierre" (ID: DOC-123), statut "externe", spécialité "Cardiologie", rattaché au service "Cardiologie"
- **Dans la Clinique B** : "Martin, P." (ID: PRAC-456), statut "interne", spécialité "Cardio", service "Médecine"
- **Dans la Clinique C** : "MARTIN Pierre" (ID: MED-789), statut "consultant", spécialité "Cardiologie", pas de service défini

**Conséquences** :
- ❌ **Planification impossible** : Impossible de savoir où le Dr. Martin opère réellement, conflits d'horaires
- ❌ **Gestion RH** : Statut ambigu (interne vs externe vs consultant), problèmes de rémunération
- ❌ **Référentiel unique absent** : Impossible de créer un annuaire médical consolidé
- ❌ **Analyse de performance** : Impossible de mesurer l'activité réelle du praticien

### Exemple 3 : Services - Problème de Cohérence

**Scénario** : Le service de "Cardiologie" existe dans les trois cliniques avec des nomenclatures différentes.

- **Clinique A** : "Cardiologie" (CODE: CARD-01), département "Médecine", manager "Dr. Durand"
- **Clinique B** : "Service Cardiologie" (CODE: SRV-CARD), département "Clinique", manager "M. Martin"
- **Clinique C** : "Cardio" (CODE: C001), pas de département, manager "P. Martin"

**Conséquences** :
- ❌ **Reporting consolidé impossible** : Impossible d'agréger les statistiques par service
- ❌ **Facturation erronée** : Codes de services différents, erreurs de facturation
- ❌ **Gestion des ressources** : Impossible d'optimiser l'allocation des ressources entre sites

### Exemple 4 : Localisations - Problème de Référentiel

**Scénario** : Les chambres et unités de soins ne sont pas référencées de manière cohérente.

- **Clinique A** : Chambre "101" dans le bâtiment "A", étage "1"
- **Clinique B** : Chambre "CH-101" dans le bâtiment "Principal", niveau "RDC"
- **Clinique C** : Chambre "1.01" dans le bâtiment "Nord", étage "1er"

**Conséquences** :
- ❌ **Logistique chaotique** : Difficultés pour la gestion des lits et des transferts
- ❌ **Maintenance impossible** : Impossible de tracer les équipements par localisation
- ❌ **Planification des interventions** : Erreurs dans l'assignation des salles d'opération

## Solution : Master Data Management (MDM)

Pour résoudre ces problèmes, nous mettons en place un **système MDM** qui :

1. **Consolide** les données maîtres des trois systèmes sources
2. **Déduplique** les enregistrements pour créer des "Golden Records"
3. **Standardise** les formats et nomenclatures
4. **Trace** l'origine des données via `source_system_ids`
5. **Maintient** la qualité et la cohérence des données maîtres

### Domaines MDM Identifiés

- **MDM_Patient** : Le "Qui" - Client/Bénéficiaire des soins
- **MDM_Praticien** : Le "Qui" - Fournisseur de service médical
- **MDM_Service** : Le "Quoi" - Catalogue des services/produits
- **MDM_Location** : Le "Où" - Référentiel géographique et logistique


