# Types de Colonnes Talend pour les Fichiers CSV

Ce document liste les types de colonnes à utiliser dans Talend pour chaque fichier CSV.

## 📋 Patients (MDM_Patient)

### Clinique A - `clinique_A_patients.csv`
| Colonne | Type Talend | Description | Exemple |
|---------|-------------|-------------|---------|
| `id` | **String** | Identifiant patient (peut contenir des lettres) | P-123 |
| `nom` | **String** | Nom de famille | Dupont |
| `prenom` | **String** | Prénom | Jean |
| `ddn` | **String** | Date de naissance (format: DD-MM-YYYY) | 01-05-1980 |
| `tel` | **String** | Téléphone (format: 0612345678) | 0612345678 |
| `allergies` | **String** | Liste d'allergies (peut être vide) | pénicilline, aspirine |

**Note pour Talend** : 
- `ddn` doit être converti en **Date** avec `TalendDate.parseDate("dd-MM-yyyy", row.ddn)`
- `tel` peut être vide (String nullable)

---

### Clinique B - `clinique_B_patients.csv`
| Colonne | Type Talend | Description | Exemple |
|---------|-------------|-------------|---------|
| `id` | **String** | Identifiant patient | PAT-45 |
| `nom` | **String** | Nom de famille | Dupond |
| `prenom` | **String** | Prénom | Jean |
| `date_naissance` | **String** | Date de naissance (format: YYYY/MM/DD) | 1980/05/01 |
| `telephone` | **String** | Téléphone (format: +33 6 12 34 56 78) ou NULL | +33 6 12 34 56 78 |
| `infos` | **String** | Informations diverses (allergies, peut être NULL) | pénicilline |

**Note pour Talend** :
- `date_naissance` doit être converti en **Date** avec `TalendDate.parseDate("yyyy/MM/dd", row.date_naissance)`
- `telephone` et `infos` peuvent être NULL (String nullable)

---

### Clinique C - `clinique_C_patients.csv`
| Colonne | Type Talend | Description | Exemple |
|---------|-------------|-------------|---------|
| `id` | **String** | Identifiant patient (numérique) | 1234 |
| `nom` | **String** | Nom de famille (peut être en majuscules) | DUPONT |
| `prenom` | **String** | Prénom (peut être en majuscules) | JEAN |
| `date_naissance` | **String** | Date de naissance (format: DD/MM/YYYY) | 01/05/1980 |
| `telephone` | **String** | Téléphone (format: 06.12.34.56.78) | 06.12.34.56.78 |
| `allergies_connues` | **String** | Liste d'allergies (peut être vide) | pénicilline, latex |

**Note pour Talend** :
- `date_naissance` doit être converti en **Date** avec `TalendDate.parseDate("dd/MM/yyyy", row.date_naissance)`
- `nom` et `prenom` doivent être normalisés (UPPERCASE → Title Case)

---

## 👨‍⚕️ Praticiens (MDM_Praticien)

### Clinique A - `clinique_A_praticiens.csv`
| Colonne | Type Talend | Description | Exemple |
|---------|-------------|-------------|---------|
| `id` | **String** | Identifiant praticien | DOC-123 |
| `nom` | **String** | Nom de famille | Martin |
| `prenom` | **String** | Prénom | Jean |
| `specialite` | **String** | Spécialité médicale | Cardiologie |
| `tel` | **String** | Téléphone professionnel | 0612345678 |
| `email` | **String** | Email professionnel | jean.martin@clinique-a.fr |
| `statut` | **String** | Statut (actif, inactif, en mission) | actif |

---

### Clinique B - `clinique_B_praticiens.csv`
| Colonne | Type Talend | Description | Exemple |
|---------|-------------|-------------|---------|
| `id` | **String** | Identifiant praticien | MED-45 |
| `nom` | **String** | Nom de famille | MARTIN |
| `prenom` | **String** | Prénom | marie |
| `specialite_medicale` | **String** | Spécialité médicale | Cardiologie |
| `telephone` | **String** | Téléphone (peut être NULL) | +33 6 12 34 56 78 |
| `email_pro` | **String** | Email professionnel (peut être NULL) | marie.martin@clinique-b.com |
| `status` | **String** | Statut | actif |

---

### Clinique C - `clinique_C_praticiens.csv`
| Colonne | Type Talend | Description | Exemple |
|---------|-------------|-------------|---------|
| `id` | **String** | Identifiant praticien | 1234 |
| `nom` | **String** | Nom (peut être en majuscules) | DUBOIS |
| `prenom` | **String** | Prénom (peut être en majuscules) | MARIE |
| `specialite` | **String** | Spécialité médicale | Pédiatrie |
| `telephone` | **String** | Téléphone | 06.12.34.56.78 |
| `email` | **String** | Email professionnel | marie.dubois@clinique-c.fr |
| `etat` | **String** | État (actif, inactif, en mission) | actif |

---

## 🏥 Services (MDM_Service)

### Clinique A - `clinique_A_services.csv`
| Colonne | Type Talend | Description | Exemple |
|---------|-------------|-------------|---------|
| `code` | **String** | Code du service | CARD-01 |
| `nom` | **String** | Nom du service | Cardiologie |
| `departement` | **String** | Département de rattachement | Cardiologie |
| `responsable` | **String** | Responsable du service | Dr. Martin |
| `tel` | **String** | Téléphone du service | 0112345678 |
| `email` | **String** | Email du service | card-01@clinique-a.fr |
| `categorie` | **String** | Catégorie (Clinique, Support, Administratif) | Clinique |

---

### Clinique B - `clinique_B_services.csv`
| Colonne | Type Talend | Description | Exemple |
|---------|-------------|-------------|---------|
| `code_service` | **String** | Code du service | C001 |
| `nom_service` | **String** | Nom du service | Service de Cardiologie |
| `dept` | **String** | Département | Cardiologie |
| `manager` | **String** | Manager du service | Dr. Martin |
| `telephone` | **String** | Téléphone (peut être NULL) | +33 1 12 34 56 78 |
| `email_service` | **String** | Email (peut être NULL) | c001@clinique-b.com |
| `type` | **String** | Type (Clinique, Support, Administratif) | Clinique |

---

### Clinique C - `clinique_C_services.csv`
| Colonne | Type Talend | Description | Exemple |
|---------|-------------|-------------|---------|
| `code` | **String** | Code du service | CARD |
| `nom` | **String** | Nom (peut être en majuscules) | CARDIOLOGIE |
| `departement` | **String** | Département | Cardiologie |
| `responsable` | **String** | Responsable | Dr. Martin |
| `telephone` | **String** | Téléphone | 01.12.34.56.78 |
| `email` | **String** | Email | card@clinique-c.fr |
| `categorie` | **String** | Catégorie | Clinique |

---

## 📍 Localisations (MDM_Location)

### Clinique A - `clinique_A_locations.csv`
| Colonne | Type Talend | Description | Exemple |
|---------|-------------|-------------|---------|
| `id` | **String** | Identifiant localisation | LOC-123 |
| `site` | **String** | Nom du site | Clinique Horizon Paris |
| `batiment` | **String** | Bâtiment | Bâtiment A |
| `etage` | **String** | Étage (peut être vide) | 1er étage |
| `salle` | **String** | Numéro de salle/chambre (peut être vide) | CH-101 |
| `adresse` | **String** | Adresse | 15 rue de la Santé |
| `ville` | **String** | Ville | Paris |
| `code_postal` | **String** | Code postal | 75014 |
| `type` | **String** | Type (Site, Unité, Chambre, etc.) | Chambre |

---

### Clinique B - `clinique_B_locations.csv`
| Colonne | Type Talend | Description | Exemple |
|---------|-------------|-------------|---------|
| `id` | **String** | Identifiant localisation | CH-45 |
| `nom_site` | **String** | Nom du site | CLINIQUE HORIZON PARIS |
| `batiment` | **String** | Bâtiment | Batiment A |
| `niveau` | **String** | Niveau/Étage (peut être NULL) | 1er étage |
| `numero` | **String** | Numéro (peut être NULL) | CH-101 |
| `adresse_complete` | **String** | Adresse complète | 15 rue de la Santé, 75014 Paris |
| `type_localisation` | **String** | Type | Chambre |

---

### Clinique C - `clinique_C_locations.csv`
| Colonne | Type Talend | Description | Exemple |
|---------|-------------|-------------|---------|
| `id` | **String** | Identifiant localisation | 1234 |
| `site` | **String** | Nom du site (peut être en majuscules) | CLINIQUE HORIZON PARIS |
| `batiment` | **String** | Bâtiment | Bâtiment A |
| `etage` | **String** | Étage (peut être vide) | 1er étage |
| `chambre` | **String** | Chambre/Salle (peut être vide) | CH-101 |
| `adresse` | **String** | Adresse | 15 rue de la Santé |
| `code_postal` | **String** | Code postal | 75014 |
| `ville` | **String** | Ville | Paris |
| `type` | **String** | Type | Chambre |

---

## 🔧 Conversions Nécessaires dans Talend

### Dates
- **Clinique A** : `TalendDate.parseDate("dd-MM-yyyy", row.ddn)`
- **Clinique B** : `TalendDate.parseDate("yyyy/MM/dd", row.date_naissance)`
- **Clinique C** : `TalendDate.parseDate("dd/MM/yyyy", row.date_naissance)`

### Normalisation des Noms
- Utiliser `StringHandling.UPCASE()` puis `StringHandling.CAPITALIZE()` pour normaliser
- Exemple : `StringHandling.CAPITALIZE(StringHandling.UPCASE(row.nom))`

### Téléphones
- Nettoyer les espaces, points, tirets
- Standardiser au format E.164 : `+33XXXXXXXXX`

### Valeurs NULL
- Utiliser `tFilterRow` pour exclure les lignes avec des champs obligatoires NULL
- Exemple : `row.date_naissance != null && !row.date_naissance.isEmpty()`

---

## 📝 Notes Importantes

1. **Tous les types sont String** dans les fichiers CSV bruts
2. **Les conversions** doivent être faites dans `tMap` après la lecture
3. **Les valeurs NULL** sont représentées par des chaînes vides `""` dans certains fichiers
4. **Les formats varient** entre les cliniques (dates, téléphones, noms de colonnes)
5. **Les doublons** sont intentionnels - même personne/service dans plusieurs fichiers avec des variations

