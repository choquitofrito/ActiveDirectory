# 4. Gestion des Utilisateurs et Groupes dans Active Directory

## 1. Introduction aux Comptes Utilisateurs

### 1.1. Concepts Fondamentaux

Un compte utilisateur Active Directory **représente une identité numérique unique** dans l'infrastructure `computerelectronics.be`. Cette identité: 

- **Identifie** l'utilisateur de manière unique (comme Sophie Lambert du service RH)
- **Contrôle** **l'accès aux ressources** (dossiers, applications, imprimantes, etc.)
- **Stocke** des informations sur l'utilisateur (comme son département, son rôle)

Par exemple, quand l'utilisateur Sophie Lambert arrive au bureau :

1. Elle utilise son compte pour se connecter à son poste de travail
2. Le système vérifie son identité et ses droits
3. Elle accède automatiquement à ses dossiers et applications

Le **compte** utilisateur **constitue** ainsi :
- Le **point d'accès principal** aux ressources du domaine (ordinateurs, fichiers, imprimantes)
- Un élément de la **structure de sécurité** de l'entreprise (qui peut accéder à quoi)
- Un **composant critique** de la gestion des identités (qui est qui dans l'organisation)

### 1.2. Standards de Nommage

#### Convention de Nommage Officielle pour le SAM (Identifiant unique)

Lors de la création d'un compte utilisateur, il est important de suivre une convention de nommage standardisée. Le **nom** qu'on choisit est le **SamAccountName** (Identifiant unique dans le domaine).

Pour garantir l'uniformité et éviter les conflits, nous utilisons une convention de nommage standardisée :

- Format : `prenom.nom`
- Exemples :
  
  ```
  clark.kent              # Pour Clark Kent du service Comptabilité
  sophie.lambert          # Pour Sophie Lambert du service RH
  jean.martin.compta      # Pour Jean Martin du service Comptabilité
  jean.martin.rh          # Pour Jean Martin du service RH
  jean.martin.compta.fr   # Pour Jean Martin (France) du service Comptabilité
  jean.martin.compta.be   # Pour Jean Martin (Belgique) du service Comptabilité
  ```

Les règles de nommage ne sont pas universelles, elles varient selon l'organisation.
On peur établir les notres.

**Règles** :
  - Uniquement en minuscules (pour éviter les erreurs de frappe)
  - Pas de caractères spéciaux sauf le point (pour la compatibilité)
  - En cas d'homonymes :
    1. Ajouter le département (ex: .compta, .rh)
    2. Si nécessaire, ajouter un autre identifiant distinctif :
       * Localisation (.fr, .be)
       * Fonction (.senior, .junior)
       * Site (.bxl, .anvers)
  - Ne jamais utiliser de chiffres


### 1.3. UPN (User Principal Name)

L'UPN est un format de connexion similaire à une adresse email, plus facile à retenir que l'ancien format DOMAIN\nom. Contrairement au SAM, **il est unique dans toute la forêt AD**.

**Structure de base** :
- Format : `login@domaine`
- Exemple : `clark.kent@computerelectronics.be`

**Utilisation pratique** :
```
Ancien format : COMPUTERELECTRONICS\clark.kent
Nouveau format : clark.kent@computerelectronics.be
```

**Points clés** :
- **Unicité** : Chaque UPN doit être unique dans toute la forêt AD
- **Simplicité** : Format familier type email, facile à mémoriser
- **Standardisation** : Utilisation du domaine principal (`computerelectronics.be`)

<br>



# 2. ADUC (Active Directory Users and Computers) et Console de Gestion Active Directory 

**"Utilisateurs et Ordinateurs Active Directory"** (**ADUC**) est une console de gestion permettant de gérer les **utilisateurs, groupes, ordinateurs et unités d'organisation (OU)** dans un domaine Active Directory (AD).

Vous pouvez l'ouvrir de plusieur formes: tapez `Utilisateurs et ordinateurs Active Directory` depuis le menu Démarrer ou via `dsa.msc`. C'est la méthode traditionnelle de gérer l'AD.
Ou même `Gestionnaire de serveur`->`Outils`->`Utilisateurs et ordinateurs Active Directory`.

 C'est la méthode traditionnelle pour gérer l'AD, mais il y a aussi la **méthode moderne via l'interface web de l'AD** (`Gestionnaire de serveur`->`Outils`->`Centre d'administration d'AD`).


Dans les deux outils vous avez accès aux **éléments suivants**:

- **Structure du domaine** : Affiche les containers d'object (ex: Users, Computers, Domain Controllers) et les **Unités d'organisation (OU)** (on en a pas).

 **Objets du domaine** , entre autres :
  - **Utilisateurs** : Comptes des utilisateurs du domaine et leurs propriétés.
  - **Ordinateurs** : Machines jointes au domaine.
  - **Contrôleurs de domaine** : Liste des DC du domaine.

Par défaut, il y a plusieurs **conteneurs** (**ce ne sont pas des OU**, mais des conteneurs d'objets) :
 :
  - `Builtin` : Contient les groupes de sécurité par défaut (Administrateurs, Utilisateurs, etc.).
  - `Computers` : Emplacement par défaut des nouveaux ordinateurs ajoutés au domaine.
  - `Users` : Emplacement des nouveaux utilisateurs et groupes.
  - `Domain Controllers` : Contient tous les contrôleurs de domaine (on en a qu'un!)

**Outils de recherche et de filtrage** : Permettent de trouver rapidement des utilisateurs, ordinateurs ou groupes.

### Principales tâches administratives
- Créer, modifier et supprimer **utilisateurs, groupes et OU**.
- Gérer **les stratégies de sécurité et les droits d'accès**.
- Réinitialiser les mots de passe, activer/désactiver des comptes.
- Déplacer des objets entre **les OU**.
- Appliquer des **Stratégies de Groupe (GPO)** aux OU.

### Cas d'utilisation
- **Gestion des utilisateurs et ordinateurs** : Ajouter, modifier et désactiver des comptes.
- **Organisation du domaine** : Structurer les utilisateurs et appareils avec des OU.
- **Permissions et sécurité** : Gérer les groupes et les droits d'accès.
- **Gestion des stratégies de groupe (GPO)** : Appliquer des règles aux utilisateurs et aux machines.


## 2. Gestion Pratique des Comptes Utilisateurs

### 2.1 Création d'un Compte Utilisateur

La création d'un compte utilisateur est une opération fréquente, par exemple lors de l'arrivée d'un nouveau collaborateur. Voici comment procéder :

1. **Ouvrir `Utilisateurs et ordinateurs Active Directory`** ou la nouvelle console de gestion.
   - `Gestionnaire de serveur`->'Outils'->'Utilisateurs et ordinateurs Active Directory'


2. **Création du compte** :

   Clic droit sur Users > Nouveau > Utilisateur
   L'assistant de création s'ouvre

3. **Informations requises** :
   - Prénom : Clark
   - Nom : Kent
   - Nom d'ouverture de session : clark.kent
   - UPN : clark.kent@computerelectronics.be

   > **Note** : Le nom d'ouverture de session est automatiquement suggéré selon notre convention

4. **Configuration du mot de passe** :
   - Choisir un mot de passe temporaire respectant la politique
   - **Cocher** "L'utilisateur doit changer son mot de passe à la prochaine ouverture de session"
   - **Décocher** "Le compte est désactivé" si l'utilisateur doit se connecter immédiatement

### 2.2. Recherche d'un Compte Utilisateur

La recherche d'un compte utilisateur est une opération fréquente, par exemple pour modifier des paramètres ou consulter des informations.

Depuis la nouvelle console de gestion, il est possible de rechercher un utilisateur en tapant sur la barre de recherche en haut de la fenêtre. 

Autrement, ouvrir `Utilisateurs et ordinateurs Active Directory` depuis le menu Démarrer ou via `dsa.msc`. Faites clique droit sur `Users` et sélectionnez `Rechercher un utilisateur`. 

Tapez le nom de l'utilisateur dans la barre de recherche. Attention: vous devez tapez le début du nom de l'utilisateur, par exemple `clark` pour `clark.kent`.


### 2.3. Modification des Propriétés

Après la création du compte, il est important de configurer les propriétés supplémentaires pour une bonne gestion :

#### Informations Essentielles

1. **Onglet Général** :

   Description : Comptable Senior - Service Comptabilité
   Bureau : Bâtiment A - 2e étage
   Téléphone : +32 2 123 45 67

Ces informations facilitent l'identification et la localisation de l'utilisateur, ce qui est utile pour les services de la société (ex: messagerie, accès aux ressources, etc...)

2. **Onglet Compte** :
  - **Heures de connexion** :
     * Par défaut : accès 24/7
     * Exemple restriction : 7h-19h en semaine
  - **Stations de travail** :
     * Par défaut : toutes les machines
     * Exemple restriction : `ws-compta-01, ws-compta-02`

3. **Onglet Profil** :
   - **Chemin du profil** : Chemin du dossier qui contient les paramètres de l'utilisateur et ses fichiers personnels
     ```
     \\srv-profiles\profiles\%username%
     # Exemple : \\srv-profiles\profiles\clark.kent
     ```
   **Note**: Par défaut, ce champ est vide car Windows crée automatiquement des profils locaux (C:\Users\username). 
   On ne le configure que si on veut implémenter des **profils itinérants** (roaming profiles) qui suivent l'utilisateur d'un poste à l'autre.
      
   **Attention**: Les profils itinérants peuvent :
     - Ralentir les connexions (synchronisation du profil)
     - Consommer beaucoup d'espace disque sur le serveur
     - Augmenter le trafic réseau
     
   **Un profil utilisateur contient** :
     - **Documents personnels** : Mes Documents, Bureau, Téléchargements
     - **Paramètres Windows** : Fond d'écran, thème, barre des tâches
     - **Paramètres d'applications** : Configurations Outlook, navigateur
     - **Clés de registre** : HKEY_CURRENT_USER
     - **AppData** : Données des applications
       * `\AppData\Local` : Données spécifiques à la machine (cache, temp)
       * `\AppData\Roaming` : Données qui suivent l'utilisateur entre les machines
   - **Script de connexion** : Si on veut lancer une suite d'opérations lors de la connexion 
     ```
     \\srv-scripts\dept\compta\logon.bat
     ```

**Important** : Les restrictions horaires et de postes sont particulièrement utiles pour les comptes sensibles ou les prestataires externes



## 3. Bonnes pratiques de gestion des comptes

### 3.1. Sécurité et Gestion des Accès

1. **Politique de mot de passe** :
   ```
   Longueur minimale : 12 caractères
   Complexité : Majuscules, minuscules, chiffres, symboles
   Durée maximale : 90 jours
   Historique : 24 derniers mots de passe
   ```

2. **Principe du moindre privilège** :
   - **Donner uniquement les droits d'accès nécessaires**
   - Exemple :
     ```
     Un comptable junior :
     - Accès lecture aux dossiers comptables
     - Accès écriture à ses propres documents
     - Pas d'accès aux salaires des employés
     ```

3. **Surveillance et Audit** :
   - Vérification mensuelle des comptes inactifs
   - Revue trimestrielle des privilèges élevés
   - Alerte sur les tentatives de connexion suspectes

4. **Desactivation et suppression** :
   - La désactivation est préférable à la suppression car elle permet de réactiver le compte si nécessaire. 
   - Si on elimine un compte il faudra documenter la procedure

## 4. Gestion des Groupes

Les groupes sont essentiels pour gérer efficacement les accès et les droits dans Active Directory. Ils permettent d'appliquer des permissions à plusieurs utilisateurs en même temps.

**Un groupe AD est un conteneur** qui peut contenir des utilisateurs, des groupes, des ordinateurs, etc.

Un group a un **type** et une **étendue**.

### 4.1. Types de Groupes

1. **Groupes de Sécurité**: Les groupes de sécurité sont les plus utilisés pour la gestion quotidienne
   
   - **Objectif** : Gérer les permissions et les droits d'accès dans le reseau
   - **Exemples** :
     ```
     S_Dl_Compta_Lecture    # Accès lecture aux dossiers comptables
     S_G_Rh_Admin         # Administration des ressources RH
     S_G_It_Support       # Équipe support informatique
     ```
   
2. **Groupes de Distribution**
   - **Objectif** : Faciliter l'envoi d'emails à plusieurs destinataires
   - **Exemples** :
     ```
     D_Dl_Info  # Liste de diffusion (Distribution List = DL) newsletter
     D_Dl_Compta_Contacts      # Liste de contacts comptables
     D_Dl_Managers         # Liste de managers
     ```
Ces groupes **sont uniquement pour la messagerie**, pas pour les permissions

### 4.2. Étendues de Groupe

1. **Domaine Local** :
   - **Usage** : Attribution **finale des droits dans le domaine**
   - **Portée** : Créés et gérés dans **un seul domaine**
   - **Exemples** :
     ```
     S_Dl_Serveurs_Admin    # Groupe Domaine Local Sécurité - Administrateurs des serveurs
     S_Dl_Compta_Lecture    # Groupe Domaine Local Sécurité - Droits lecture comptabilité
     S_Dl_Rh_Modif         # Groupe Domaine Local Sécurité - Modification données RH
     ```

On doit fixer de noms cohérents pour les groupes. Il n'y a pas de convention officielle, mais il est recommandé de suivre une **convention cohérente**. On va fixer la notre:

- **Group Type** d'abord: **S_** for Security or **D_** for Distribution.
- **Group Scope** ensuite: **DL_** for Domain Local, **G_** for Global, **U_** for Universal.



Utilisés pour attribuer les permissions sur les ressources

2. **Global**
   - **Usage** : Organisation des utilisateurs **par fonction dans l'entreprise**
   - **Portée** : Créés et gérés dans **un seul domaine**
   - **Exemples** :
     ```
     S_G_Compta_Users     # Tous les comptables
     S_G_Rh_Managers      # Managers des RH
     S_G_It_Support      # Équipe support niveau 1
     ```
Représentent généralement des rôles métier

3. **Universel**
   - **Usage** : Groupes **accessibles dans toute la forêt AD**
   - **Portée** : Tous les domaines de la forêt
   - **Exemples** :
     ```
     S_U_Direction       # Direction générale (tous sites)
     S_U_Projet_Isib     # Équipe projet multi-domaines
     S_U_Admin_Global    # Administrateurs globaux
     ```
Les groupes universels sont accessibles dans toute la forêt AD, mais ils sont moins utilisés car ils impactent la réplication dans chaque domaine.

### 4.2 Création et Gestion des Groupes

La création et la gestion des groupes sont des tâches courantes qui nécessitent une attention particulière pour maintenir une structure cohérente.

#### Via l'Interface Graphique

1. **Création d'un groupe**
   ```
   - Ouvrir Console d'administration d'AD
   - Naviguer vers Users
   - Clic droit > Nouveau > Groupe
   - Remplir les informations :
      - Nom : S_G_Compta_Users
      - Étendue : Global
      - Type : Sécurité
   ```

2. **Ajout de membres**
   ```
   - Double-clic sur le groupe
   - Onglet Membres > Ajouter
   - Rechercher et sélectionner les utilisateurs :
      - clark.kent
      - sophie.lambert
   - Vérifier les membres ajoutés
   ```
Vérifiez toujours la liste des membres après les modifications

### 4.3 Bonnes Pratiques de Gestion

#### Convention de Nommage des Groupes

On doit fixer nous même les conventions de noms de manière cohérente. Voici un exemple possible:

- Les préfixes indiquent clairement la portée ET le type du groupe

1. **Structure du Nom**
   ```
   Format : [Type]-[Group Scope]-[Name]

   Exemples :
   S_G_Compta_Users     # Utilisateurs du service comptabilité
   S_Dl_Rh_Lecture      # Accès lecture aux documents RH
   S_U_It_Admins       # Administrateurs IT multi-sites
   ```
- Une nomenclature cohérente facilite l'administration

#### Stratégie de Groupes Imbriqués (AGDLP)

1. **Principe AGDLP**
   ```
   Account → Global → DomainLocal → Permission

   Exemple concret :
   sophie.lambert → S_G_Compta_Users → S_Dl_Serveur_Acces → Permissions
   
   Détails :
   1. sophie.lambert est membre de S_G_Compta_Users
   2. S_G_Compta_Users est membre de S_Dl_Serveur_Acces
   3. S_Dl_Serveur_Acces a les permissions sur le serveur
   ```

2. **Avantages AGDLP**
   - Administration simplifiée
   - Meilleure sécurité
   - Facilite les audits

#### Sécurité et Maintenance

1. **Bonnes Pratiques**
   - Documenter le rôle de chaque groupe
   - Réviser les membres régulièrement
   - Éviter les permissions directes

2. **À Éviter**
   ```
   ✗ Permissions directes aux utilisateurs
   ✗ Groupes sans description
   ✗ Groupes avec trop de membres
   ✗ Noms de groupes non standardisés
   ```

3. **Audit Régulier**
   - Vérification trimestrielle des membres
   - Nettoyage des groupes vides
   - Documentation des changements

1. **Documentation**
   - Description claire dans AD
   - Propriétaire du groupe
   - Procédure de revue

2. **Audit Régulier**
   ```

3. **Gestion des Accès**
   - Principe du moindre privilège 
   - Révision périodique des membres
   - Processus d'approbation

> **Important** : Documenter toute modification de groupe dans le système de gestion des changements.

## 5. Propriétés et Attributs Utilisateur

### 5.1. Champs Obligatoires vs Optionnels

#### Champs Obligatoires
- Nom d'utilisateur (login)
- UPN (User Principal Name)
- Nom complet
- Mot de passe initial

#### Champs Recommandés
- Service/Département
- Localisation (EU/US)
- Adresse email
- Numéro de téléphone

### 5.2. Options de Compte

#### Paramètres de Base
- L'utilisateur doit changer son mot de passe à la prochaine ouverture de session
- L'utilisateur ne peut pas changer son mot de passe
- Le mot de passe n'expire jamais
- Le compte est désactivé

#### Paramètres Avancés
- Carte à puce requise pour l'ouverture de session interactive
- Le compte est approuvé pour la délégation
- Le compte est sensible et ne peut pas être délégué

### 5.3. Profils Utilisateur

#### Types de Profils
- Local
- Itinérant (Roaming)
- Obligatoire (Mandatory)

#### Configuration des Profils
```plaintext
# Exemple de chemin de profil itinérant
\\srv-profiles\profiles\%username%

# Exemple de script de connexion
\\srv-scripts\scripts\dept\start.bat
```

## 6. Droits vs Permissions

### 6.1. Comprendre la Différence

Les droits d'utilisateurs ne sont pas la même chose que les permissions.

#### Droits Utilisateur
- S'appliquent à l'échelle du système
- Définissent ce qu'un utilisateur peut faire sur un ordinateur
- Exemple : "Se connecter localement", "Arrêter le système"

#### Permissions
- S'appliquent aux objets (fichiers, dossiers, imprimantes)
- Définissent l'accès aux ressources
- Exemple : Lecture, écriture, modification

### 6.2. Droits Utilisateur par Défaut

#### Utilisateur Standard
```plaintext
- Se connecter localement
- Arrêter le système
- Changer le mot de passe
- Effectuer des tâches de maintenance
```

#### Accumulation des Droits
- Un utilisateur accumule les droits des groupes auxquels il appartient
- Pas de "déni" de droits utilisateur, c.a.d. si un utilisateur appartient à un groupe qui lui donne un droit, il aura ce droit 
- L'appartenance à des groupes privilégiés augmente les droits

## 7. Groupes Intégrés

### 7.1. Groupes Essentiels

Il existe 3 groupes intégrés essentiels dans Active Directory :

#### Domain Admins
- Administrateurs du domaine
- Accès total à toutes les ressources
- Membres du groupe local Administrators sur tous les ordinateurs

Exemples d'actions :
- Création et configuration des contrôleurs de domaine
- Modification des stratégies de sécurité du domaine

#### Enterprise Admins
- Administration de la forêt entière
- Création de relations d'approbation
- Configuration des sites et services

Exemples d'actions :
- Ajout d'un nouveau domaine dans la forêt
- Configuration des sites AD entre eu.computerelectronics.be et us.computerelectronics.be

#### Schema Admins
- Modification du **schéma** AD 
- Groupe très sensible
- Utilisation rare et contrôlée

Exemples d'actions :
- Ajout d'un nouvel attribut pour les comptes utilisateurs
- Extension du schéma pour supporter Exchange Server (messagerie)

### 7.2. Groupes de Sécurité Courants

#### Account Operators
- Création et gestion des comptes utilisateurs
- Gestion des groupes
- Ne peut pas gérer les comptes administratifs

Exemples d'actions :
- Création d'un compte pour un nouvel employé
- Ajout d'un utilisateur dans un groupe départemental

#### Backup Operators
- Sauvegarde et restauration de fichiers
- Contournement des permissions NTFS
- Accès en lecture à tout le domaine

Exemples d'actions :
- Sauvegarde complète d'un serveur de fichiers
- Restauration des données d'un utilisateur depuis une sauvegarde

### 7.3. Bonnes Pratiques

#### Règles d'Utilisation
- Limiter le nombre de membres dans les groupes privilégiés
- Utiliser des comptes dédiés pour l'administration
- Documenter toute modification des membres

#### Exemple de Structure
```plaintext
# Hiérarchie Administrative
Enterprise Admins
  └─ Domain Admins
      └─ Server Operators
          └─ Account Operators
```

## 8. Imbrication des Groupes

### 8.1. Règles d'Imbrication

#### Principes de Base
- Un groupe peut contenir d'autres groupes
- Les permissions se cumulent
- Respecter la hiérarchie AGDLP/AGLP

#### Limitations
```plaintext
# Autorisé
Global → Global
Global → Universal
Universal → Universal

# Non Autorisé
Universal → Global
Domain Local → Global/Universal
```

### 8.2. Modèles AGDLP/AGLP

#### AGDLP (Recommandé)
- Account
- Global Group (Rôle)
- Domain Local Group (Ressource)
- Permission

#### Exemple AGDLP
```plaintext
Utilisateur → GG-COMPTA-USERS → DL-SHARE-FINANCE-RW → Permissions
```

## 9. Stratégie de Groupes

### 9.1. RBAC (Role-Based Access Control)

#### Structure
- Groupes basés sur les fonctions
- Permissions attachées aux rôles
- Utilisateurs assignés aux rôles

#### Exemple RBAC
```plaintext
GG-FINANCE-MANAGER
  ├─ DL-FINANCE-REPORTS-RW
  ├─ DL-BUDGET-APPROVE
  └─ DL-STAFF-VIEW
```

### 9.2. Convention de Nommage des Groupes

#### Format Standard
```plaintext
[Type]-[Département]-[Fonction]-[Accès]

Exemples :
GG-COMPTA-USERS    (Groupe Global)
DL-SHARE-RW        (Domaine Local)
UG-ALL-STAFF       (Groupe Universel)
```

### 9.3. Organisation par Département vs Fonction

#### Structure par Département
```plaintext
GG-COMPTA-USERS
  ├─ DL-COMPTA-SHARE-RW
  └─ DL-COMPTA-PRINT

GG-RH-USERS
  ├─ DL-RH-SHARE-RW
  └─ DL-RH-PRINT
```

#### Structure par Fonction
```plaintext
GG-MANAGERS
  ├─ DL-REPORTS-RW
  └─ DL-BUDGET-APPROVE

GG-EMPLOYEES
  ├─ DL-SHARE-RO
  └─ DL-PRINT-BASIC
```
- Idéaux pour les groupes métier

**Exemple pratique** :
```
Groupe : GG-COMPTA-USERS
Portée : Global
Utilisation : Regroupe tous les utilisateurs comptables
OU : Comptabilité/Utilisateurs
```

#### Universel
**Objectif** : Gestion à l'échelle de la forêt

**Caractéristiques** :
- Membres de toute la forêt Active Directory
- Utilisables partout dans la forêt
- Impact sur la réplication (catalogue global)

**Exemple pratique** :
```
Groupe : U-DIRECTION
Portée : Universel
Utilisation : Accès direction dans toute l'entreprise
```

> **Important** : Le choix de l'étendue impacte directement les performances et la sécurité. Utilisez les groupes universels avec parcimonie en raison de leur impact sur la réplication.

## 2. Création et gestion des groupes

### 2.1. Création via l'interface graphique
#### Création d'un groupe
1. Ouvrez "Utilisateurs et ordinateurs Active Directory"
2. Clic droit sur l'OU -> Nouveau -> Groupe
3. Configurez :
   - Nom : COMPTA-Users
   - Étendue : Global
   - Type : Sécurité

#### Ajout de membres
1. Double-clic sur le groupe
2. Onglet "Membres"
3. Ajoutez les utilisateurs ou groupes


## 3. Stratégie de groupes recommandée

### 3.1. Modèle AGDLP

#### Composants
- **A** - Account (Compte utilisateur)
- **G** - Global Group (Groupe global - par fonction)
- **DL** - Domain Local Group (Groupe local - pour les ressources)
- **P** - Permissions (sur les ressources)

#### Exemple d'application
```
Utilisateur → Groupe Global → Groupe Local → Permissions
(spiderman) → (COMPTA-Users) → (COMPTA-Resources) → (Accès dossier)
```














