# Référence Rapide - Types Talend

## 🎯 Règle Générale
**Tous les champs CSV sont de type `String`** dans Talend lors de la lecture initiale.
Les conversions se font ensuite dans `tMap`.

---

## 📊 Patients

### Clinique A
```
id: String
nom: String
prenom: String
ddn: String → Date (format: "dd-MM-yyyy")
tel: String
allergies: String
```

### Clinique B
```
id: String
nom: String
prenom: String
date_naissance: String → Date (format: "yyyy/MM/dd")
telephone: String (nullable)
infos: String (nullable)
```

### Clinique C
```
id: String
nom: String (normaliser majuscules)
prenom: String (normaliser majuscules)
date_naissance: String → Date (format: "dd/MM/yyyy")
telephone: String
allergies_connues: String
```

---

## 👨‍⚕️ Praticiens

### Clinique A
```
id: String
nom: String
prenom: String
specialite: String
tel: String
email: String
statut: String
```

### Clinique B
```
id: String
nom: String
prenom: String
specialite_medicale: String
telephone: String (nullable)
email_pro: String (nullable)
status: String
```

### Clinique C
```
id: String
nom: String (normaliser)
prenom: String (normaliser)
specialite: String
telephone: String
email: String
etat: String
```

---

## 🏥 Services

### Clinique A
```
code: String
nom: String
departement: String
responsable: String
tel: String
email: String
categorie: String
```

### Clinique B
```
code_service: String
nom_service: String
dept: String
manager: String
telephone: String (nullable)
email_service: String (nullable)
type: String
```

### Clinique C
```
code: String
nom: String (normaliser)
departement: String
responsable: String
telephone: String
email: String
categorie: String
```

---

## 📍 Localisations

### Clinique A
```
id: String
site: String
batiment: String
etage: String (nullable)
salle: String (nullable)
adresse: String
ville: String
code_postal: String
type: String
```

### Clinique B
```
id: String
nom_site: String
batiment: String
niveau: String (nullable)
numero: String (nullable)
adresse_complete: String
type_localisation: String
```

### Clinique C
```
id: String
site: String (normaliser)
batiment: String
etage: String (nullable)
chambre: String (nullable)
adresse: String
code_postal: String
ville: String
type: String
```

---

## 🔄 Conversions Talend

### Date
```java
// Clinique A
TalendDate.parseDate("dd-MM-yyyy", row.ddn)

// Clinique B
TalendDate.parseDate("yyyy/MM/dd", row.date_naissance)

// Clinique C
TalendDate.parseDate("dd/MM/yyyy", row.date_naissance)
```

### Normalisation Nom
```java
StringHandling.CAPITALIZE(StringHandling.UPCASE(row.nom))
```

### Filtre NULL
```java
row.date_naissance != null && !row.date_naissance.isEmpty()
```

