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



## 2. Utilisateurs et Ordinateurs Active Directory (ADUC)

**"Utilisateurs et Ordinateurs Active Directory"** (**ADUC**) est une console de gestion permettant de gérer les **utilisateurs, groupes, ordinateurs et unités d'organisation (OU)** dans un domaine Active Directory (AD).

Vous pouvez l'ouvrir de plusieur formes: tapez `Utilisateurs et ordinateurs Active Directory` depuis le menu Démarrer ou via `dsa.msc`. C'est la méthode traditionnelle de gérer l'AD.
Ou même `Gestionnaire de serveur`->`Outils`->`Utilisateurs et ordinateurs Active Directory`.

 C'est la méthode traditionnelle pour gérer l'AD, mais il y a aussi la **méthode moderne via l'interface web de l'AD** (`Gestionnaire de serveur`->`Outils`->`Centre d'administration d'AD`).


Dans les deux outils vous avez accès aux **éléments suivants**:

- **Structure du domaine** : Affiche plusieurs containers d'objects (ex: Users, Computers, Domain Controllers) et les **Unités d'organisation (OU)** (dont on en a pas pour l'instant).

- **Objets du domaine** , entre autres :
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


## 3. Gestion Pratique des Comptes Utilisateurs

### 3.1. Création d'un Compte Utilisateur

La création d'un compte utilisateur est une opération fréquente, par exemple lors de l'arrivée d'un nouveau collaborateur. Voici comment procéder :

1. Ouvrir **Utilisateurs et ordinateurs Active Directory** ou la nouvelle console de gestion:
   - `Gestionnaire de serveur`->'Outils'->'Utilisateurs et ordinateurs Active Directory'


2. **Création du compte** :

   Clic droit sur Users > Nouveau > Utilisateur
   L'assistant de création s'ouvre

3. **Informations requises** :
   - Prénom : Clark
   - Nom : Kent
   - Nom d'ouverture de session : clark.kent
   - UPN : clark.kent@computerelectronics.be

   
4. **Configuration du mot de passe** :
   - Choisir un mot de passe temporaire respectant la politique
   - **Cocher** "L'utilisateur doit changer son mot de passe à la prochaine ouverture de session"
   - **Décocher** "Le compte est désactivé" si l'utilisateur doit se connecter immédiatement

### 3.2. Recherche d'un Compte Utilisateur

La **recherche d'un compte** utilisateur est une opération **fréquente**, par exemple pour modifier des paramètres ou consulter des informations.

Depuis la **nouvelle console** de gestion l'opération est très simple: dans **la barre de recherche** en haut de la fenêtre tapez le nom de l'utilisateur. 

**Attention:** vous devez tapez le début du nom de l'utilisateur, par exemple `clark` pour `clark.kent`.

Autrement, ouvrir `Utilisateurs et ordinateurs Active Directory` depuis le menu Démarrer ou via `dsa.msc`. Faites clique droit sur `Users` et sélectionnez `Rechercher un utilisateur`. 



### 3.3. Modification des Propriétés

Après la création du compte, il est important de configurer les **propriétés supplémentaires** pour faciliter les tâches de gestion.

### Informations Essentielles

#### **Onglet Général** :

   - Description : Comptable Senior 
   - Service Comptabilité
   - Bureau : Bâtiment A - 2e étage
   - Téléphone : +32 2 123 45 67

Ces informations facilitent l'identification et la localisation de l'utilisateur, ce qui est utile pour les services de la société (ex: messagerie, accès aux ressources, etc...)

#### **Onglet Compte** :
  - **Heures de connexion** :
     * Par défaut : accès 24/7
     * Exemple restriction : 7h-19h en semaine
  - **Stations de travail** :
     * Par défaut : toutes les machines
     * Exemple de restriction : `ws-compta-01, ws-compta-02`

#### **Onglet Profil** :
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



## 4. Bonnes pratiques pour la gestion des comptes


1. **Politique de mot de passe** 
   ```
   Longueur minimale : 12 caractères
   Complexité : Majuscules, minuscules, chiffres, symboles
   Durée maximale : 90 jours
   Historique : 24 derniers mots de passe
   ```

2. **Surveillance et Audit** :
   - Vérification mensuelle des comptes inactifs
   - Revue trimestrielle des privilèges élevés
   - Alerte sur les tentatives de connexion suspectes

3. **Desactivation et suppression** :
   - La désactivation est préférable à la suppression car elle permet de réactiver le compte si nécessaire. 
   - Si on elimine un compte il faudra documenter la procedure

## 5. Gestion des Groupes

Les groupes sont essentiels pour gérer efficacement les accès et les droits dans Active Directory. Ils permettent d'appliquer des permissions à plusieurs utilisateurs en même temps.

**Un groupe AD est un conteneur** qui peut contenir **des utilisateurs, des groupes, des ordinateurs, etc**.

Un groupe a un **type** et une **étendue**.

**Important**: On suit toujours le **principe du moindre privilège**:
- Les **permissions** sont **données aux groupes**, jamais directement aux utilisateurs
- Chaque **groupe** ne **reçoit** que les **permissions strictement nécessaires** à sa fonction
- L'utilisation de **groupes imbriqués (AGDLP/AGLP) permet de mieux contrôler et auditer les permissions** (expliquée plus tard)

### 5.1. Types de Groupes

1. **Groupes de Sécurité**: Les groupes de sécurité sont les plus utilisés pour la gestion quotidienne
   
   - **Objectif** : Gérer les permissions et les droits d'accès dans le reseau
   - **Exemples** :
     ```
     S-DL-Compta-Lecture    # Accès lecture aux dossiers comptables
     S-G-RH-Admin         # Administration des ressources RH
     S-G-IT-Support       # Équipe support informatique
     ```
   
2. **Groupes de Distribution**
   - **Objectif** : Faciliter l'envoi d'emails à plusieurs destinataires
   - **Exemples** :
     ```
     D-DL-Info  # Liste de diffusion (Distribution List = DL) newsletter
     D-DL-Compta-Contacts      # Liste de contacts comptables
     D-DL-Managers         # Liste de managers
     ```
Ces groupes **sont uniquement pour la messagerie**, pas pour les permissions

### 5.2. Étendues de Groupe

Selon l'étendue de leurs accès, les groupes sont divisés en 3 catégories:

#### 1. Domaine Local (DL)
   - **Usage** : Attribution **finale des droits dans le domaine**
   - **Portée** : Créés et gérés dans **un seul domaine**
   - **Exemples** :
     ```
     S-DL-Serveurs-Admin    # Groupe Domaine Local Sécurité - Administrateurs des serveurs
     S-DL-Compta-Lecture    # Groupe Domaine Local Sécurité - Droits lecture comptabilité
     S-DL-RH-Modif         # Groupe Domaine Local Sécurité - Modification données RH
     ```

On doit fixer de noms cohérents pour les groupes. Il n'y a pas de convention officielle, mais il est recommandé de suivre une **convention cohérente**. On va fixer la notre:

- **Type** d'abord: **S-** for Security or **D-** for Distribution.
- **Etendue**: **DL-** for Domain Local, **G-** for Global, **U-** for Universal.



Utilisés pour attribuer les permissions sur les ressources

#### 2. Global (G)
   - **Usage** : Organisation des utilisateurs **par fonction dans l'entreprise**
   - **Portée** : Créés et gérés dans **un seul domaine**
   - **Exemples** :
     ```
     S-G-Compta-Users     # Tous les comptables
     S-G-RH-Managers      # Managers des RH
     S-G-IT-Support      # Équipe support niveau 1
     ```
Représentent généralement des rôles métier

#### 3. Universel (U)
   - **Usage** : Groupes **accessibles dans toute la forêt AD**
   - **Portée** : Tous les domaines de la forêt
   - **Exemples** :
     ```
     S-U-Direction       # Direction générale (tous sites)
     S-U-Projet-Isib     # Équipe projet multi-domaines
     S-U-Admin-Global    # Administrateurs globaux IT
     ```
Les groupes universels sont accessibles dans toute la forêt AD, mais ils sont moins utilisés car ils impactent la réplication dans chaque domaine.

### 5.3. Création et Gestion des Groupes


#### Via l'Interface Graphique

1. **Création d'un groupe**
   ```
   - Ouvrir Console d'administration d'AD
   - Naviguer vers Users
   - Clic droit > Nouveau > Groupe
   - Remplir les informations :
      - Nom : S-G-Compta-Users
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


### 5.4. Convention de Nommage des Groupes

On doit fixer nous même les conventions de noms de manière cohérente. Il n'y a pas de regles fixes mais il faut que la convention soit cohérente. Nous avons choisi celle-ci:

- Les préfixes indiquent clairement la portée ET le type du groupe

1. **Structure du Nom**

   **Format : [Type]-[Group Scope]-[Name]**

   Exemples :
   - `S-G-Compta-Users`     # Utilisateurs du service comptabilité
   - `S-DL-RH-Lecture`      # Accès lecture aux documents RH
   - `S-U-IT-Admins`       # Administrateurs IT multi-sites

- Une nomenclature cohérente facilite l'administration

### 5.5. Stratégie de Groupes Imbriqués (AGDLP/AGLP)

On suivra la stratégie **AGDLP/AGLP** (Account → Global Groups → Domain Local Groups → Permission) pour que la **gestion de groupes et de permissions** soit plus simple et plus efficace.

**On ne rajoutera jamais les permissions directement sur les comptes des utilisateurs**. Comment faire alors? 

#### AGDLP

**Exemple**: `John Connor` doit accéder aux dossiers du serveur de RH en lecture et modification.

1. `John Connor` possède un compte **Account**.
2. Il est un manager du departement RH, donc il est ajouté au groupe global (de fonction métier)`S-G-RH-Managers` - **Global Group**
3. Le groupe `S-G-RH-Managers` est ajouté au groupe `S-DL-RH-Modif` - **Domain Local Group**
4. Le groupe `S-DL-RH-Modif` **a les permissions** sur les dossiers du serveur de RH

Qu'est-ce que vous pensez qu'on gagne?

<details>
<summary>Reponse</summary>

- Si John Connor change de département, il suffit de le retirer du groupe `S-G-RH-Managers` et de l'ajouter au groupe `S-G-Compta-Managers`. Il aura alors les permissions sur les dossiers du serveur de comptabilité.

- Si John Connor est un nouvel employé, il suffit de le rajouter au groupe global qui correspond (ex: `S-G-Compta-Users`) et il aura les droits du département correspondant (car ce groupe global appartient lui-même à un certain groupe local de domaine, par exemple `S-DL-Compta-Modif`)

- Si `John Connor` part de l'entreprise, on ne doit pas chercher tous les ressources auxquels il avait accès manuellement. Le fait de le retirer du groupe global permet de nettoyer ses droits.

</details>

#### AGLP

Il existe une autre stratégie possible qu'on peut utiliser si on a qu'un seul domaine (voir notre labo): **AGLP** (Account → Global Groups → Permission)

Dans **AGLP**, on **donne les droits** directement aux **groupes globaux**. 

Voyez la différence:

#### Strategie AGDLP

| Account | Global Groups | Domain Local Groups |Permission|
|---|---|---|---|
|John Coltrane|S-G-Compta-Managers|S-DL-Compta-Modif|Lecture et modification des fichiers comptables |

#### Strategie AGLP

| Account | Global Groups |Permission|
|---|---|---|
|John Coltrane|S-G-Compta-Modif|Lecture et modification des fichiers comptables |

<br>

Ceci est plus simple mais moins flexible. Le **nommage** des **groupes globaux** **change**: ils doivent maintenant donner une idée des permissions.

#### Regles d'imbriquations

Un groupe peut contenir d'autres groupes d'autres types, mais on a les limitations suivantes:

- Un groupe global peut contenir un autre groupe global, mais il doit être dans le même domaine
- Un groupe local ne peut pas contenir un groupe global d'un autre domaine
- Un groupe universal ne peut pas contenir un groupe global d'un domaine 

### 5.6. Sécurité et Maintenance

- On **ne donne pas de permissions directement aux groupes globaux**: ils son pensés pour être des groupes de gestion (ex: `S-G-RH-Managers`)
- On **donne de permissions aux groupes locaux (DL)** (ex: `S-DL-RH-Modif`)


<br>

## 6. Droits (Privileges) vs Permissions

Les droits d'utilisateurs **ne sont pas la même chose que les permissions**.

### Droits Utilisateur
- Définissent **les actions qu'un utilisateur peut faire sur un ordinateur**
- S'appliquent à l'**échelle du système**

  **Exemple** : "Se connecter localement", "Arrêter le système", "Changer le mot de passe", "Lancer un backup"

Ils sont configurés dans les **Group Policy (GPO)** (on les verra plus tard)

### Permissions
- Définissent **qui peut acceder aux ressources  et les actions qu'il peut effectuer**
- S'**appliquent aux objets** (fichiers, dossiers, imprimantes)
- **Actions** possibles: **Lecture, écriture, Modification**

Quand on **partage** un ressource, on peut **aussi choisir** de donner des **permissions** aux utilisateurs.

Ils sont stockés dans les **Access Control Lists (ACL)**

### Droits Utilisateur par Défaut

#### Utilisateur Standard

- Se connecter localement
- Arrêter le système
- Changer le mot de passe
- Effectuer des tâches de maintenance

#### Accumulation des Droits
- Un **utilisateur accumule les droits des groupes auxquels il appartient**
- On **ne dénie** pas de droits utilisateur 
- L'appartenance à des groupes privilégiés augmente les droits (ex: `Domain Admins`)

<br>

## 7. Groupes Intégrés dans AD par Défaut

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
- Configuration des sites AD entre eu.monentreprise.be et us.monentreprise.be

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




## 8. Organisation par Département vs Fonction

Il y a deux stratégies principales pour organiser les groupes:

#### Structure par Département
```plaintext
S-DL-Dossier-Partage-RW
  ├─ S-G-Compta-Users <-- groupe global pour les users de Comptabilité
  ├─ S-G-Sales-Users <-- groupe global pour les users de Ventes
  └─ S-G-RH-Users <-- groupe global pour les users de RH
```

#### Structure par Fonction
```plaintext
S-DL-Dossier-Partage-RW
  ├─ S-G-Managers
  └─ S-G-Employees
```














