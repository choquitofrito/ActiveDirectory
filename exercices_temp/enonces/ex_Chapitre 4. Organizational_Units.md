# SUBJECTS

## Organizational Units (OUs) and AD Structure
### **Lesson 2.1: Understanding OUs in AD**
- Purpose of OUs in an AD hierarchy
- Best practices for structuring OUs
- Delegation of administrative tasks using OUs

### **Lesson 3.2: Creating and Managing OUs**
- Creating OUs using ADUC
- Moving users and computers between OUs

### **Lesson 3.3: Delegation of Control**
- Assigning permissions to administrators or helpdesk teams
- Understanding the **Delegation Wizard**

# EXERCICES:

### Exercice 1 : Structure de Base
1. Créer les OUs géographiques et départementales (au moins une zone géographique)

```
computerelectronics.be (Domain Root)
├── EU
│   ├── Comptabilite
│   │   ├── Users
│   │   └── Computers
│   │   └── Groups
│   ├── RH
│   │   ├── Users
│   │   └── Computers
│   │   └── Groups
│   └── Ventes
│       ├── Users
│       └── Computers
│       └── Groups
├── US
│   ├── Comptabilité
│   │   ├── Users
│   │   └── Computers
│   │   └── Groups
│   ├── RH
│   │   ├── Users
│   │   └── Computers
│   │   └── Groups
│   └── Ventes
│       ├── Users
│       └── Computers
│       └── Groups
├── Dev
│   ├── Applications
│   ├── Databases
│   └── Servers
│   └── Groups
└── Prod
    ├── Applications
    ├── Databases
    └── Servers
    └── Groups
```

### Exercice 2 : Organisation des Objets et Groupes

1. Créer des utilisateurs test pour chaque région :
   - 2 utilisateurs pour EU/Comptabilite
   - 2 utilisateurs pour US/Ventes
   - 1 administrateur pour DEV/Applications

2. Créer des ordinateurs test :
   - ws-compta-01 pour EU/Comptabilite
   - ws-ventes-01 pour US/Ventes
   - srv-app-01 pour DEV/Applications

3. Organiser les objets (si vous ne les avez pas créés directement dans les OU)
   - Placer les utilisateurs dans les OUs Users appropriées
   - Placer les ordinateurs dans les OUs Computers appropriées
   - Ajouter les utilisateurs aux groupes globaux correspondants
   - Ajouter les groupes globaux aux groupes domain local selon les besoins


### Exercice 3 : Délégation Simple
1. Créer les groupes de support dans l'OU Groups de EU/Comptabilite :
   - `GG-EU-Comptabilite-Support` (groupe global pour l'équipe support comptabilité)
   - `DL-EU-Comptabilite-Password` (groupe domain local pour la délégation, qui a les **permissions de réinitialisation de mot de passe**)

2. Déléguer les droits en utilisant le `Wizard de délégation de contrôle` :
   - Sélectionner l'OU "EU/Comptabilite/Users"
   - Sélectionner le groupe "DL-EU-Comptabilite-Password"
   - Cocher "Réinitialiser les mots de passe utilisateur"
   - Cliquer sur "Terminer"

3. Configurer les groupes :
   - Ajouter `GG-EU-Comptabilite-Support` comme membre de `DL-EU-Comptabilite-Password`
   - Ajouter un utilisateur test au groupe `GG-EU-Comptabilite-Support`

4. Tester la délégation avec l'utilisateur test: 
   - Utiliser l'utilisateur test pour réinitialiser le mot de passe d'un utilisateur du groupe `GG-EU-Comptabilite-Support`
   - 

**Structure de la délégation**:
```plaintext
OU "EU/Comptabilite/Users" (avec droits délégués)
  ├─ DL-EU-Comptabilite-Password (groupe local avec permissions)
      └─ GG-EU-Comptabilite-Support (groupe global)
          └─ Utilisateurs support comptabilité
```

### Exercice 4 : Délégation Départementale
1. Créer les groupes d'administration pour EU/Comptabilité :
   - `GG-EU-Comptabilite-Admins` dans Global Groups
   - `DL-EU-Comptabilite-OU-Admin` dans Domain Local Groups

2. Configurer la délégation pour l'OU EU/Comptabilité :
   - Sélectionner l'OU "EU/Comptabilité"
   - Attribuer au groupe "DL-EU-Comptabilite-OU-Admin" :
     * Création/suppression d'utilisateurs
     * Réinitialisation des mots de passe
     * Gestion des groupes

3. Configurer les groupes :
   - Ajouter`GG-EU-Comptabilite-Admins` à `DL-EU-Comptabilite-OU-Admin`
   - Ajouter un utilisateur test à `GG-EU-Comptabilite-Admins`

4. Tester et documenter les accès

### Exercice 5 : Gestion Quotidienne
1. Simuler des scénarios de gestion :
   - Déplacer un utilisateur de EU/Comptabilité vers EU/Ventes
   - Mettre à jour les appartenances aux groupes
   - Vérifier les délégations après le déplacement

2. Maintenir la structure :
   - Vérifier les appartenances aux groupes
   - Valider les délégations
   - Documenter les changements
3. Auditer les permissions

#### Exercice 6 : Maintenance
1. Vérifier la structure des OUs
2. Nettoyer les délégations obsolètes
3. Mettre à jour la documentation