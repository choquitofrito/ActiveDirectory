## 1. Introduction aux OUs

### 1.1 Objectif et Rôle des OUs dans Active Directory

Une **OU est un conteneur AD qui permet de regrouper des objets AD** (utilisateurs, groupes, ordinateurs, etc.)

Les OU permettent de créer une organisation hiérarchique et administrative des ressources. Vous pouvez voir une OU comme **un dossier qui contient des objets AD** (encore un arbre!)

### 1.2. Structure d'une Unité d'Organisation (OU)

Une **OU** (**Organizational Unit**) est un **objet** de l'Active Directory conçu pour organiser les objets de manière **hiérarchique** et **flexible**.

La structure d'une OU ressemble à l'arbre de d'un système de fichiers, **où une OU apparaît comme un dossier** qui peut contenir des objets AD:

  - utilisateurs
  - groupes
  - ordinateurs
  - autres OUs
  - autres objets AD
  
Contrairement aux containers, les OUs sont utilisées principalement pour appliquer des **stratégies de groupe** (**GPO**) et gérer la **délégation des permissions**.

### 1.3. Gestion des objets 

On peut deplacer les objets entre les OU, ce qui permet une gestion plus flexible de la structure de l'AD.

Sur une **OU**, on peut appliquer des **GPO** (Group Policy Object, on les verra plus tard)

**Example**: Une OU `Comptabilité` peut avoir une GPO qui limite l'accès aux périphériques USB (droits), tandis qu'une OU `IT` permet leur utilisation.


## 2. Création et Gestion des OUs

Considerons la création de OUs pour l'entreprise `computerelectronics.be`.


### 2.1. Organisation par Département

Pour computerelectronics.be, nous utilisons une structure départementale :

- **Domaine Racine (computerelectronics.be)**: Cela demeure l'OU de niveau supérieur.


- **OUs basées sur l'emplacement (EU, US)**: Nous maintenons les OUs UE et US pour refléter la segmentation géographique du réseau.
- **OUs départementales (Comptabilité, RH, Ventes)**: Dans chaque emplacement, nous créons des OUs pour les trois départements.
- **OUs des utilisateurs et des ordinateurs**: A l'intérieur de chaque OU départementale, nous séparons les utilisateurs et les ordinateurs. C'est une bonne pratique pour appliquer des paramètres de stratégie de groupe différents.
- **OUs basées sur l'environnement (DEV, PROD)**: Nous gardons les OUs DEV et PROD pour gérer les ressources de développement et de production. Étant donné que ces ressources sont probablement centrées sur les serveurs, nous les organisons en catégories "Applications", "Bases de données" et "Serveurs".

```
computerelectronics.be (Domain Root)
├── Groups
│   ├── Global Groups
│   └── Domain Local Groups
├── EU
│   ├── Comptabilité
│   │   ├── Users
│   │   └── Computers
│   ├── RH
│   │   ├── Users
│   │   └── Computers
│   └── Ventes
│       ├── Users
│       └── Computers
├── US
│   ├── Comptabilité
│   │   ├── Users
│   │   └── Computers
│   ├── RH
│   │   ├── Users
│   │   └── Computers
│   └── Ventes
│       ├── Users
│       └── Computers
├── DEV
│   ├── Applications
│   ├── Databases
│   └── Servers
└── PROD
    ├── Applications
    ├── Databases
    └── Servers
```



#### 2.1.2 Bonnes Pratiques de Nommage

- Éviter les caractères spéciaux
- Utiliser des noms descriptifs
- Maintenir une cohérence dans la nomenclature
- Exemple : "Comptabilite" plutôt que "COMPTA" 

### 2.2 Création via 

#### 2.2.1 Procédure de Création

1. Ouvrir `Utilisateurs et ordinateurs d'Active Directory`
2. Clic droit sur le domaine ou l'OU parent
3. Nouveau -> Unité d'organisation
4. Saisir le nom selon les conventions

## 3. Conteneurs par Défaut vs OUs

### 3.1 Différences Fondamentales

Les **conteneurs par défaut** (Users, Computers) et les **OUs** ont des différences importantes :

- **Unités d'Organisation** :
  - **Créées manuellement selon les besoins**
    * Exemple : Création d'une OU "Stagiaires" lors de l'arrivée d'une nouvelle vague de stagiaires
  - Peuvent recevoir des **GPOs**
    * Exemple : Application d'une GPO de mises à jour automatiques sur l'OU "Stagiaires"
  - Permettent la **délégation** d'administration
    * Exemple : L'User responsable RH peut gérer les utilisateurs dans l'OU "Users" du departement RH
  - Offrent une **flexibilité** organisationnelle
    * Exemple : Déplacement facile d'un utilisateur de l'OU "Ventes" vers l'OU "Comptabilité" lors d'un changement de poste

- **Conteneurs par défaut** :
  - Créés automatiquement avec l'AD
  - Ne peuvent pas recevoir de GPOs
  - Ne permettent pas la délégation d'administration
  - Stockent les objets par défaut


## 4. Principes de Conception des OUs

### 4.1 Facteurs Clés

La conception d'une structure d'OUs doit prendre en compte :

1. **Limites Administratives** :
   - Qui gère quoi ?
   - Quelles sont les responsabilités de chaque équipe ?

2. **Besoins en GPO** :
   - Quelles politiques doivent être appliquées ?
   - À quels groupes d'objets ?

3. **Exigences de Sécurité** :
   - Quels sont les niveaux d'accès requis ?
   - Quelles sont les ressources sensibles ?

4. **Organisation Géographique vs Fonctionnelle** :
   - Structure par lieu ou par fonction ?
   - Hybride des deux approches ?

### 4.2 Meilleures Pratiques

- Garder la structure simple
- Éviter les niveaux d'imbrication excessifs
- Aligner la structure avec l'organisation
- Prévoir la croissance future

## 5. Délégation de Contrôle

### 5.1. Principe de la Délégation

La **délégation** nous permet **d'attribuer des droits administratifs spécifiques sur des OUs à des utilisateurs ou groupes**.

Exemple: L'administrateur du service RH peut gérer les utilisateurs dans l'OU "Users" du département RH.

### 5.2 Types de Permissions Délégables

1. **Gestion des Comptes** :
   - Création/suppression d'utilisateurs
   - Réinitialisation des mots de passe
   - Modification des propriétés des comptes

2. **Gestion des Groupes** :
   - Création/suppression de groupes
   - Modification des membres
   - Gestion des propriétés

3. **Gestion des Ordinateurs** :
   - Ajout/suppression d'ordinateurs
   - Configuration des propriétés
   - Réinitialisation des comptes

### 5.3 Bonnes Pratiques de Délégation

- Utiliser des groupes plutôt que des utilisateurs individuels

**Exemple**: Pour déléguer la gestion des utilisateurs de l'OU "RH" :

1. Créer un **groupe global** "GG-RH-Admins" contenant les utilisateurs RH qui seront administrateurs
2. Créer un **groupe domain local** "DL-RH-OU-Admins"
3. Ajouter "GG-RH-Admins" comme membre de "DL-RH-OU-Admins"
4. Dans les propriétés de l'OU "RH" :
   - Aller dans "Délégation de contrôle"
   - Sélectionner le groupe "DL-RH-OU-Admins"
   - Déléguer les droits : "Créer, supprimer et gérer les comptes utilisateur"

- Appliquer le principe du moindre privilège
- Documenter les délégations
- Auditer régulièrement les permissions

## 6. Héritage dans les OUs

### 6.1 Concept d'Héritage

L'héritage dans AD détermine comment les paramètres et les permissions se propagent à travers la hiérarchie des OUs.

### 6.2 Types d'Héritage

1. **Héritage des GPOs** :
   - Les paramètres de stratégie se propagent vers le bas
   - Possibilité de bloquer l'héritage
   - Option de forcer l'héritage

2. **Héritage des Permissions** :
   - Les ACLs se propagent aux objets enfants
   - Permissions explicites vs héritées
   - Blocage et remplacement des permissions


# 7. Groupes vs OUs

### 7.1 Différences Fondamentales

| Groupes | OUs |
|---------|-----|
| Pour gérer les **permissions** | Pour gérer la **structure** et les **stratégies** |
| Peuvent être membres d'autres groupes | Ne peuvent pas contenir d'autres OUs du même type |
| Peuvent recevoir des permissions | Peuvent recevoir des GPOs |
| Flexibles et réutilisables | Hiérarchiques et organisationnels |

### 7.2 Quand Utiliser des Groupes

1. **Pour l'accès aux ressources**
   - Exemple : Le groupe "GG-Compta-Finance" a accès au dossier "Rapports Financiers"
   - Exemple : Le groupe "GG-RH-Managers" a accès à l'application de gestion des salaires

2. **Pour des rôles spécifiques**
   - Exemple : "GG-Helpdesk" pour les techniciens du support
   - Exemple : "GG-Devs" pour les développeurs

3. **Pour des projets temporaires**
   - Exemple : "GG-Projet-Migration2024" pour une équipe projet
   - Exemple : "GG-Audit-Q1" pour un audit temporaire

### 7.3 Quand Utiliser des OUs

1. **Pour la structure organisationnelle**
   - Exemple : OU "Comptabilité" contenant tous les utilisateurs et ordinateurs du service
   - Exemple : OU "Ventes" avec sous-OUs "Europe" et "Amérique"

2. **Pour l'application de GPOs** (on **ne peut pas** appliquer des GPOs **sur les groupes**!)
   - Exemple : OU "Ordinateurs-Dev" avec GPO de développement
   - Exemple : OU "Ordinateurs-Production" avec GPO de sécurité renforcée

3. **Pour la délégation administrative**
   - Exemple : OU "RH" avec délégation au responsable RH
   - Exemple : OU "IT" avec délégation aux administrateurs système

### 7.4 Combinaison des Deux Approches

**Exemple 1 : Gestion des Stagiaires**
- OU "Stagiaires" pour appliquer des GPOs spécifiques
- Groupes pour la gestion des accès :
  * "GG-Stagiaires" : groupe global contenant tous les stagiaires
  * "GG-Stagiaires-IT" : groupe global pour les stagiaires IT

Cet exemple peut être implémenté de deux façons :

1. **Stratégie AGLP** (plus simple) :
   * Les utilisateurs sont dans les groupes globaux (GG-)
   * Les groupes globaux reçoivent directement les permissions

2. **Stratégie AGDLP** (plus flexible) :
   * Ajouter des groupes domain local :
     - "DL-Stagiaires-Docs" pour l'accès aux documents
     - "DL-Stagiaires-Apps" pour l'accès aux applications
   * Les GG sont membres des DL
   * Les DL reçoivent les permissions

**Exemple 2 : Département Commercial**
- OU "Ventes" pour la structure et les GPOs
  * Sous-OU "Vendeurs"
  * Sous-OU "Managers"

1. **Stratégie AGLP** :
   - Groupes globaux avec permissions directes :
     * "GG-Ventes-Lecture" : accès en lecture aux catalogues
     * "GG-Ventes-Edition" : accès en écriture aux devis
     * "GG-Ventes-Admin" : accès complet au CRM

2. **Stratégie AGDLP** :
   - Groupes globaux pour les rôles :
     * "GG-Ventes-Vendeurs"
     * "GG-Ventes-Managers"
   - Groupes domain local pour les permissions :
     * "DL-Ventes-Catalogues" : accès aux catalogues
     * "DL-Ventes-Devis" : gestion des devis
     * "DL-Ventes-CRM" : accès au CRM

**Exemple 3 : Structure computerelectronics.be**
- Structure des OUs :
  * OU "Groups" à la racine :
    - Sous-OU "Global Groups" pour les GG
    - Sous-OU "Domain Local Groups" pour les DL
    - Cette structure centralise la gestion des groupes
  * OUs géographiques (EU/US) :
    - Sous-OUs départementales (Comptabilité, RH, Ventes)
    - Chaque département avec Users et Computers
    - GPOs spécifiques par région et département
  * OUs environnement (DEV/PROD) :
    - Applications, Databases, Servers
    - GPOs spécifiques par environnement

1. **Stratégie AGLP** (groupes dans OU "Groups") :
   - Dans "Global Groups" :
     * "GG-EU-Compta-Users" : utilisateurs Comptabilité Europe
     * "GG-US-Compta-Users" : utilisateurs Comptabilité USA
     * "GG-DEV-Apps-Admin" : administrateurs applications DEV
     * "GG-PROD-DB-Users" : utilisateurs bases de données PROD

2. **Stratégie AGDLP** (groupes dans OU "Groups") :
   - Dans "Global Groups" :
     * "GG-EU-Compta-Users"
     * "GG-DEV-Apps-Admins"
   - Dans "Domain Local Groups" :
     * "DL-EU-Compta-Share" : partages Comptabilité Europe
     * "DL-DEV-Apps-Admin" : administration applications DEV
     * "DL-Global-Resources" : ressources communes



**Exemple 4 : Projet Multi-Départemental**
- OUs existantes : "Compta", "IT", "RH"

1. **Stratégie AGLP** :
   - Groupe global avec accès directs :
     * "GG-Projet-ERP" : membres de différentes OUs avec accès aux ressources du projet

2. **Stratégie AGDLP** :
   - Groupes globaux par rôle :
     * "GG-Projet-ERP-Dev" : développeurs
     * "GG-Projet-ERP-Test" : testeurs
   - Groupes domain local par ressource :
     * "DL-Projet-ERP-Code" : accès au code source
     * "DL-Projet-ERP-Docs" : accès à la documentation
     * "DL-Projet-ERP-Test" : accès aux environnements de test

### 7.5 Bonnes Pratiques

1. **Structure Claire**
   - OUs pour l'organisation hiérarchique
   - Groupes pour les permissions

2. **Éviter la Redondance**
   - Ne pas créer d'OU pour des accès temporaires
   - Ne pas créer de groupes pour la structure

3. **Maintenance**
   - Documenter la logique d'utilisation
   - Réviser régulièrement les membres des groupes
   - Vérifier la pertinence des GPOs sur les OUs


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