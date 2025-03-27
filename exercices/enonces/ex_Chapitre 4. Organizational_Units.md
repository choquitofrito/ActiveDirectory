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


## Exercices

### Exercice 1 : Structure de Base
1. Créer l'OU "Groups" avec ses sous-OUs :
   - Global Groups
   - Domain Local Groups

2. Créer les OUs géographiques :
   - EU
   - US

3. Dans chaque OU géographique, créer les OUs départementales :
   - Comptabilité
   - RH
   - Ventes

4. Dans chaque OU départementale, créer :
   - OU "Users"
   - OU "Computers"

5. Créer les OUs pour les environnements :
   - DEV avec sous-OUs (Applications, Databases, Servers)
   - PROD avec sous-OUs (Applications, Databases, Servers)

6. Vérifier la protection contre la suppression pour toutes les OUs


### Exercice 2 : Organisation des Objets et Groupes
1. Créer des groupes globaux et domain local :
   - Dans "Global Groups" :
     * GG-EU-Compta-Users
     * GG-US-Compta-Users
     * GG-DEV-Apps-Admin
   - Dans "Domain Local Groups" :
     * DL-EU-Compta-Share
     * DL-Global-Resources

2. Créer des utilisateurs test pour chaque région :
   - 2 utilisateurs pour EU/Comptabilité
   - 2 utilisateurs pour US/Ventes
   - 1 administrateur pour DEV/Applications

3. Créer des ordinateurs test :
   - ws-compta-01 pour EU/Comptabilité
   - ws-ventes-01 pour US/Ventes
   - srv-app-01 pour DEV/Applications

4. Organiser les objets :
   - Placer les utilisateurs dans les OUs Users appropriées
   - Placer les ordinateurs dans les OUs Computers appropriées
   - Ajouter les utilisateurs aux groupes globaux correspondants
   - Ajouter les groupes globaux aux groupes domain local selon les besoins


### Exercice 3 : Délégation Simple
1. Créer les groupes de support dans l'OU "Groups" :
   - "GG-Support-EU" dans Global Groups
   - "DL-Support-Users-Admin" dans Domain Local Groups

2. Déléguer les droits en utilisant le `Wizard de délégation de contrôle` :
   - Sélectionner l'OU "EU"
   - Sélectionner le groupe "DL-Support-Users-Admin"
   - Cocher "Réinitialiser les mots de passe utilisateur"
   - Cliquer sur "Terminer"

3. Configurer les groupes :
   - Ajouter "GG-Support-EU" comme membre de "DL-Support-Users-Admin"
   - Ajouter un utilisateur test au groupe "GG-Support-EU"

4. Tester la délégation avec l'utilisateur test

### Exercice 4 : Délégation Départementale
1. Créer les groupes d'administration pour EU/Comptabilité :
   - "GG-EU-Compta-Admins" dans Global Groups
   - "DL-EU-Compta-OU-Admin" dans Domain Local Groups

2. Configurer la délégation pour l'OU EU/Comptabilité :
   - Sélectionner l'OU "EU/Comptabilité"
   - Attribuer au groupe "DL-EU-Compta-OU-Admin" :
     * Création/suppression d'utilisateurs
     * Réinitialisation des mots de passe
     * Gestion des groupes

3. Configurer les groupes :
   - Ajouter "GG-EU-Compta-Admins" à "DL-EU-Compta-OU-Admin"
   - Ajouter un utilisateur test à "GG-EU-Compta-Admins"

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