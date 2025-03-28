# 1. Introduction aux OUs

## 1. Objectif et Rôle des OUs dans Active Directory

Une **OU est un conteneur AD qui permet de regrouper des objets AD** (utilisateurs, groupes, ordinateurs, etc.)

Les OU permettent de créer une organisation hiérarchique et administrative des ressources. Vous pouvez voir une OU comme **un dossier qui contient des objets AD** (encore un arbre!)

# 2. Structure d'une Unité d'Organisation (OU)

Une **OU** (**Organizational Unit**) est un **objet** de l'Active Directory conçu pour organiser les objets de manière **hiérarchique** et **flexible**.

La structure d'une OU ressemble à l'arbre de d'un système de fichiers, **où une OU apparaît comme un dossier** qui peut contenir des objets AD:

  - utilisateurs
  - groupes
  - ordinateurs
  - autres OUs
  - autres objets AD
  
Contrairement aux containers, les OUs sont utilisées principalement pour appliquer des **stratégies de groupe** (**GPO**) et gérer la **délégation des permissions**.


# 3. Procédure de Création

1. Ouvrir `Utilisateurs et ordinateurs d'Active Directory`
2. Clic droit sur le domaine ou l'OU parent
3. Nouveau -> Unité d'organisation
4. Saisir le nom selon les conventions

Si vous cochez l'option Proteger contre la suppression, vous ne pourrez plus supprimer l'OU.
Pour ce faire, allez dans la section suivante

# 4. Elimination d'une OU protegée

1. Retirer la protection contre la suppression :

- Ouvrir "Active Directory Users and Computers" (ADUC) - l'ancienne console
- Cliquer sur **View** dans le menu et assure-toi que l'option **Advanced Features** est activée. Cela permet de voir les paramètres de protection.

2. **Trouver l'OU** protégée et **désactiver la protection** contre la suppression :
  - Cliquer droit sur l'OU et sélectionner **Properties**.
  - Dans la fenêtre des propriétés, va à l'onglet **Object**.
  - Décoche l'option **Protect object from accidental deletion**.
  - Clique sur OK pour appliquer les modifications.

3. **Supprimer l'OU** 


# 5. Gestion des objets 

On peut deplacer les objets entre les OU, ce qui permet une gestion plus flexible de la structure de l'AD.

Sur une **OU**, on peut appliquer des **GPO** (Group Policy Object, on les verra plus tard)

**Example**: Une OU `Comptabilité` peut avoir une GPO qui limite l'accès aux périphériques USB (droits), tandis qu'une OU `IT` permet leur utilisation.


# 6. Création et Gestion des OUs

Considerons la création de OUs pour l'entreprise `computerelectronics.be`.

## 6.1. Organisation par Département

Pour computerelectronics.be, nous utilisons une structure départementale :

- **Domaine Racine (computerelectronics.be)**: Cela demeure l'OU de niveau supérieur.


- **OUs basées sur l'emplacement (EU, US)**: Nous maintenons les OUs UE et US pour refléter la segmentation géographique du réseau.
- **OUs départementales (Comptabilité, RH, Ventes)**: Dans chaque emplacement, nous créons des OUs pour les trois départements.
- **OUs des utilisateurs et des ordinateurs**: A l'intérieur de chaque OU départementale, nous séparons les utilisateurs et les ordinateurs. C'est une bonne pratique pour appliquer des paramètres de stratégie de groupe différents.
- **OUs basées sur l'environnement (DEV, PROD)**: Nous gardons les OUs DEV et PROD pour gérer les ressources de développement et de production. Étant donné que ces ressources sont probablement centrées sur les serveurs, nous les organisons en catégories "Applications", "Bases de données" et "Serveurs".

```
computerelectronics.be (Domain Root)
├── EU
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



## 6.2 Bonnes Pratiques de Nommage et de Structure des OUs

- **Éviter** les caractères **spéciaux**
- Utiliser des **noms descriptifs**
- Maintenir **une cohérence** dans la nomenclature
**Exemple** : `Comptabilite` plutôt que "COMPTA" 

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



## 6.3. Conteneurs par Défaut vs OUs


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


## 6.4. Principes de Conception des OUs

### 6.4.1. Facteurs Clés

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

### 6.4.2. Meilleures Pratiques

- Garder la structure simple
- Éviter les niveaux d'imbrication excessifs
- Aligner la structure avec l'organisation
- Prévoir la croissance future

# 7. Délégation de Contrôle

## 7.1. Principe de la Délégation

La **délégation** nous permet **d'attribuer des droits administratifs d'une certaine OUs à des utilisateurs ou groupes**.

**Exemple**: Dans l'OU **EU/RH/Users**, nous pouvons donner au groupe `DL-EU-RH-Admins` le droit de :
- Réinitialiser les mots de passe
- Gérer les propriétés des comptes

On veut que les admins peuvent faire ces actions sur les utilisateurs de l'OU EU/RH/Users (ex: `GG-EU-RH-Users`).

Les administrateurs RH seront membres du groupe `GG-EU-RH-Admins`: groupe global des administrateurs du departement RH

Ces administrateurs pourraient recevoir les droits de gestion des comptes des Utilisateurs de l'OU EU/RH/Users, mais les bon pratiques de AGDLP nous recommande de ne pas le faire (voir AGDLP dans le chapitre `5. Gestion des Utilisateurs`)
On creera un groupe local `DL-EU-RH-Admins` , qui est celui qui possede les droits: **la OU delegue les droits sur ce groupe**, et on a **qu'a joindre le groupe `GG-EU-RH-Admins` à ce groupe local DL-EU-RH-Admins**

Les users de DL-EU-RH-Admins pourront reinitialiser les mots de passe des comptes des `GG-EU-RH-Users`.

Cela permet une gestion décentralisée sans donner accès à d'autres départements.

## 7.2. Types de Permissions Délégables

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


## 7.3. Configuration et Test de la Délégation

1. **Configuration de la Délégation** :
   - Dans `Utilisateurs et ordinateurs Active Directory`
   - Clic droit sur l'OU EU/RH/Users
   - Sélectionner `Déléguer le contrôle`
   - Suivre l'Assistant de délégation de contrôle:
     * Sélectionner le groupe `DL-EU-RH-Admins`
     * Choisir les tâches:
       - Réinitialiser les mots de passe
       - Lire toutes les informations utilisateur
       - Modifier les propriétés des comptes

2. **Préparation du Test** :
   - Créer un utilisateur test dans l'OU EU/RH/Users (ex: test.user)
   - Créer un compte admin RH test (ex: admin.rh)
   - Ajouter admin.rh au groupe `GG-EU-RH-Admins`
   - Ajouter `GG-EU-RH-Admins` au groupe `DL-EU-RH-Admins`

3. **Vérification des Droits** :
   - Se déconnecter complètement
   - Se connecter avec le compte admin.rh
   - Ouvrir `Utilisateurs et ordinateurs Active Directory`
   - Essayer de réinitialiser le mot de passe de test.user
   - Vérifier qu'on peut modifier les propriétés du compte

4. **Test des Limitations** :
   - Vérifier qu'admin.rh ne peut pas:
     * Accéder aux autres OUs
     * Créer/supprimer des groupes
     * Modifier les GPOs

5. **Validation Finale** :
   - Se connecter avec test.user et le nouveau mot de passe
   - Vérifier que les modifications des propriétés sont effectives

## 7.4. Bonnes Pratiques de Délégation

- Appliquer **le principe du moindre privilège**
- **Documenter** les délégations
- **Auditer** régulièrement les permissions (voir le chapitre 5. Gestion des Utilisateurs)

# 8. Héritage dans les OUs

## 8.1 Concept d'Héritage

L'héritage dans AD détermine **comment les paramètres et les permissions se propagent à travers la hiérarchie** des OUs.

## 8.2 Types d'Héritage

1. **Héritage des GPOs** :
   - Les paramètres de stratégie se propagent vers le bas (vers les OUs enfants)
   - Possibilité de bloquer l'héritage
   - Option de forcer l'héritage

2. **Héritage des Permissions** :
   - Les ACLs (gestion des droits d'acces comme par exemple pouvoir modifier un dossier) se propagent aux objets enfants
   - Permissions explicites vs héritées
   - Blocage et remplacement des permissions


# 9. Groupes vs OUs

## 9.1 Différences Fondamentales

| Groupes | OUs |
|---------|-----|
| Pour gérer les **permissions** | Pour gérer la **structure** et les **politiques GPO** |
| Peuvent être membres d'autres groupes | Ne peuvent pas contenir d'autres OUs du même type |
| Peuvent recevoir des permissions | Peuvent recevoir des GPOs |
| Flexibles et réutilisables | Hiérarchiques et organisationnels |

## 9.2 Quand Utiliser des Groupes

1. **Pour l'accès aux ressources**
   - Exemple : Le groupe `GG-EU-Compta-Finance` a accès au dossier partagé via le groupe `DL-EU-Compta-Finance`
   - Exemple : Le groupe `GG-EU-RH-Managers` a accès à l'application de gestion des salaires via le groupe `DL-EU-RH-Salaires`

2. **Pour des rôles spécifiques**
   - Exemple : `GG-EU-IT-Helpdesk` pour les techniciens du support
   - Exemple : `GG-EU-IT-Devs` pour les développeurs

3. **Pour des projets temporaires**
   - Exemple : `GG-EU-Projet-Migration2024` pour une équipe projet
   - Exemple : `GG-EU-Audit-Q1` pour un audit temporaire

## 9.3 Quand Utiliser des OUs

1. **Pour la structure organisationnelle**
   - Exemple : OU **EU/Comptabilite** contenant les sous-OUs **Users** et **Computers**

2. **Pour l'application des politiques GPOs** (on **ne peut pas** appliquer des GPOs **sur les groupes**!)
   - Exemple : OU **EU/Comptabilite/Computers** avec GPO qui désactive l'accès aux périphériques USB (protection des données financières)
   - Exemple : OU **EU/RH/Users** avec GPO qui force le verrouillage d'écran après 5 minutes (protection des données sensibles)

3. **Pour la délégation administrative**
   - Exemple : OU **EU/Ventes** avec délégation au groupe `DL-EU-Ventes-Admins`
   - Exemple : OU **EU/IT** avec délégation au groupe `DL-EU-IT-Admins`

## 9.4 Combinaison des Deux Approches

**Exemple 1 : Gestion des Stagiaires**
- **OU** **EU/Stagiaires** **pour appliquer des GPOs spécifiques** (politiques, on les verra plus tard dans le chapitre 6). À l'interirieur de l'OU, de **groupes** pour gérer les accès .
  
  * **GG-Stagiaires** : groupe global contenant tous les stagiaires
  * **GG-Stagiaires-IT** : groupe global pour les stagiaires IT

Cet exemple peut être implémenté de deux façons :

1. **Stratégie AGLP** (plus simple, pour de petites organisations) :
   * Les utilisateurs sont dans les groupes globaux (GG-)
   * Les groupes globaux reçoivent directement les permissions

2. **Stratégie AGDLP** (plus flexible, pour de grandes organisations) :
   * Ajouter des groupes domain local :
     - **DL-Stagiaires-Docs** pour l'accès aux documents
     - **DL-Stagiaires-Apps** pour l'accès aux applications
   * Les GG sont membres des DL
   * Les DL reçoivent les permissions

**Exemple 2 : Département Commercial**
- OU **EU/Ventes** pour la structure et les GPOs
  * Sous-OU **Users**
  * Sous-OU **Computers**

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


**Exemple 3 : Projet Multi-Départemental**
- OUs existantes : "Compta", "IT", "RH"

1. **Stratégie AGLP** :
   - Groupe global avec accès directs :
     * **GG-Projet-ERP** : membres de différentes OUs avec accès aux ressources du projet

2. **Stratégie AGDLP** :
   - Groupes globaux par rôle :
     * **GG-Projet-ERP-Dev** : développeurs
     * **GG-Projet-ERP-Test** : testeurs
   - Groupes domain local par ressource :
     * **DL-Projet-ERP-Code** : accès au code source
     * "DL-Projet-ERP-Docs" : accès à la documentation
     * "DL-Projet-ERP-Test" : accès aux environnements de test



