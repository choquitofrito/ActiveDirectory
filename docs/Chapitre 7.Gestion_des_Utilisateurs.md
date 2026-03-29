# Chapitre 7: Gestion des Utilisateurs

## 🧭 Navigation du Cours
[⏮️ Chapitre Précédent: Unités d'Organisation](Chapitre%206.Unites_Organisation.md) | [🏠 Retour au Syllabus](index.md) | [⏭️ Chapitre Suivant: Group Policy Objects](Chapitre%208.Group%20Policy%20Objects.md)


!!! info "📚 Dans ce chapitre:"

    1. 👤 [Identités Numériques](#1-identités-numériques)
       - Concepts de base
       - Conventions de nommage
    2. ⚙️ [Administration ADUC](#2-utilisateurs-et-ordinateurs-active-directory-aduc)
       - Configuration des comptes
       - Gestion des accès
    3. 🔐 [Sécurité et Groupes](#4-gestion-des-groupes)
       - Stratégies de sécurité
       - Organisation des accès
    4. 🔑 [Délégation de Contrôle](#8-delegation-de-controle)
       - Concept et cas d'usage
       - Exemple pratique reset password

---

## 📙 Objectifs Pédagogiques

À la fin de ce chapitre, vous serez capable de :
1. Gérer les identités utilisateurs
2. Appliquer les standards de nommage
3. Implémenter les stratégies de sécurité
4. Administrer les permissions et les droits d'accès

---

## 1. Identités Numériques

### Concepts Fondamentaux

Un compte utilisateur Active Directory représente une **identité numérique unique** (un objet) dans `maxtec.be` permettant :

!!! info "Fonctionnalités d'un compte utilisateur"
    
    - **Identification** unique (ex: `ivan`)
    - **Contrôle d'accès** aux ressources
    - **Gestion des informations** utilisateur

!!! tip "Pour débutants"
    
    Pensez à un compte utilisateur comme une carte d'identité numérique qui dit qui vous êtes et ce que vous pouvez faire dans l'entreprise !

!!! example "Exemple : Connexion d'Ivan (Informatique)"
    
    1. Connexion au poste de travail
    2. Vérification des identifiants
    3. Accès aux ressources autorisées


### **Standards de Nommage**

#### **Convention SamAccountName**

Un utilisateur a deux identifiants possibles:

- **SamAccountName**, qui est l'identifiant unique de l'utilisateur dans le domaine, dont le format de base est **prenom**

```plaintext
charles              # Comptabilité
rene                # RH
cindy               # Comptabilité
rebecca             # RH
ivan                # Informatique
victor              # Ventes
```
- **UPN** (User Principal Name), dont le format de base est **prenom@domaine**

!!! tip "Pour débutants"
    
    SamAccountName = nom court (`ivan`), UPN = adresse email style (`ivan@maxtec.be`)

Pour tous les deux, suivez ces règles:

- Minuscules uniquement
- Pas de caractères spéciaux
- En cas d'homonymes, on peut ajouter un identifiant supplémentaire
- Pas de chiffres sauf si nécessaire pour distinguer des homonymes

## 🎯 Checkpoint: Concepts des Comptes

!!! info "Vérification de compréhension"
    
    Avant de créer vos premiers utilisateurs:
    
    - [ ] Savoir qu'un compte utilisateur est une identité numérique
    - [ ] Comprendre SamAccountName vs UPN
    - [ ] Connaitre les règles de nommage (minuscules, pas de caractères spéciaux)
    - [ ] Savoir que le format standard est "prenom" et "prenom@maxtec.be"



## 2. Utilisateurs et Ordinateurs Active Directory (ADUC)

**"Utilisateurs et Ordinateurs Active Directory"** (**ADUC**) est une console de gestion permettant de gérer les **utilisateurs, groupes, ordinateurs et unités d'organisation (OU)** dans un domaine AD.

Vous pouvez l'ouvrir de plusieur formes: tapez `Utilisateurs et ordinateurs Active Directory` depuis le menu Démarrer ou via `dsa.msc`. C'est la méthode traditionnelle de gérer l'AD.
Ou même `Gestionnaire de serveur`->`Outils`->`Utilisateurs et ordinateurs Active Directory`.

!!! tip "Pour débutants"
    
    ADUC = l'outil principal pour créer et gérer vos utilisateurs et groupes. C'est votre "tableau de bord" d'Active Directory !

 C'est la méthode traditionnelle pour gérer l'AD, mais il y a aussi la **méthode moderne via l'interface web de l'AD** (`Gestionnaire de serveur`->`Outils`->`Centre d'administration d'AD`).


!!! info "Éléments accessibles"
    
    Dans les deux outils vous avez accès aux **éléments suivants**:
    
    - **Structure du domaine AD** : Affiche plusieurs containers d'objects (ex: Users, Computers, Domain Controllers) et les **Unités d'organisation (OU)** (dont on en a pas pour l'instant).
    
    - **Objets du domaine AD** , entre autres :
      - **Utilisateurs** : Comptes des utilisateurs du domaine AD et leurs propriétés.
      - **Ordinateurs** : Machines jointes au domaine AD.
      - **Contrôleurs de domaine** : Liste des DC du domaine AD.

Par défaut, il y a plusieurs **conteneurs** (**ce ne sont pas des OU**, mais des conteneurs d'objets) :

- `Builtin` : Contient les groupes de sécurité par défaut (Administrateurs, Utilisateurs, etc.).
- `Computers` : Emplacement par défaut des nouveaux ordinateurs ajoutés au domaine.
- `Users` : Emplacement des nouveaux utilisateurs et groupes.
- `Domain Controllers` : Contient tous les contrôleurs de domaine (on en a qu'un!)

**Outils de recherche et de filtrage** : Permettent de trouver rapidement des utilisateurs, ordinateurs ou groupes.

### Principales tâches concernant les Utilisateurs, Groupes et OUs
- Créer, modifier et supprimer **utilisateurs, groupes et OU**.
- Gérer **les stratégies de sécurité et les droits d'accès**.
- Réinitialiser les mots de passe, activer/désactiver des comptes.
- Déplacer des objets entre **les OU**.
- Appliquer des **Stratégies de Groupe (GPO)** aux OU.


## 3. Gestion des Comptes

### 3.1. Création de Compte

!!! example "Processus pour ajouter un nouveau collaborateur"
    
    #### **Accès à la Console**
    
    1. Ouvrir **ADUC** via :
        - **Gestionnaire de serveur**
        - **Outils**
        - **Utilisateurs et ordinateurs AD**
    
    #### **Assistant de Création**
    
    1. **Clic droit sur `Users`**
    2. **Nouveau** > **Utilisateur**
    
    #### **Informations de Base**
    - **Prénom** : Charles
    - **Nom** : 
    - **Login** : charles
    - **UPN** : charles@maxtec.be
    
    #### **Configuration du mot de passe**
    - Choisir un mot de passe temporaire respectant la politique
    - **Cocher** "L'utilisateur doit changer son mot de passe à la prochaine ouverture de session"
    - **Décocher** "Le compte est désactivé" si l'utilisateur doit se connecter immédiatement

### 3.2. Recherche d'un Compte Utilisateur

!!! info "Méthodes de recherche"
    
    La **recherche d'un compte** utilisateur est une opération **fréquente**, par exemple pour modifier des paramètres ou consulter des informations.
    
    #### **Méthode 1 : Barre de recherche**
    Depuis la **nouvelle console** de gestion l'opération est très simple: dans **la barre de recherche** en haut de la fenêtre tapez le nom de l'utilisateur.
    
    !!! warning "Attention"
        
        Vous devez taper le début du nom de l'utilisateur, par exemple `clark` pour `clark.kent`.
    
    #### **Méthode 2 : Recherche traditionnelle**
    Ouvrir `Utilisateurs et ordinateurs Active Directory` depuis le menu Démarrer ou via `dsa.msc`. Faites clique droit sur `Users` et sélectionnez `Rechercher un utilisateur`. 



### 3.3. Modification des Propriétés

Après la création du compte, il est important de configurer les **propriétés supplémentaires** pour faciliter les tâches de gestion.

### 3.4. Informations Essentielles

!!! info "Configuration des propriétés utilisateur"
    
    #### **Onglet Général**
    
    | Champ | Exemple |
    |-------|---------|
    | Description | Comptable Senior |
    | Service | Comptabilité |
    | Bureau | Bâtiment A - 2e étage |
    | Téléphone | +32 2 123 45 67 |
    
    !!! tip "Information importante"
        
        Ces informations sont essentielles pour la gestion des services (messagerie, ressources, etc.)
    
    #### 🔑 Paramètres du Compte
    
    ##### **Heures d'accès**
    - Par défaut : 24/7
    - Restriction : 7h-19h (semaine)
    
    ##### **Postes de travail**
    - Défaut : Tous les postes
    - Exemple : `ws-compta-01.maxtec.be`

### Profils utilisateurs

!!! info "Types de profils"
    
    | Type | Chemin | Description |
    |------|--------|-------------|
    | **Local** | `C:\Users\username` | Profil stocké localement |
    | **Itinérant** | `\\srv-profiles\profiles\%username%` | Profil partagé sur le réseau |
    | **Exemple** | `\\srv-profiles\profiles\charles` | Exemple concret |

!!! note "Note"
    
    Par défaut, ce champ est vide car Windows crée automatiquement des profils locaux (C:\Users\username).
    
    On ne le configure que si on veut implémenter des **profils itinérants** (roaming profiles) qui suivent l'utilisateur d'un poste à l'autre.

!!! warning "Attention aux profils itinérants"
    
    Les profils itinérants peuvent :
    - Ralentir les connexions (synchronisation du profil)
    - Consommer beaucoup d'espace disque sur le serveur
    - Augmenter le trafic réseau

!!! info "Contenu d'un profil utilisateur"
    
    **Un profil utilisateur contient** :
    
    - **Documents personnels** : Mes Documents, Bureau, Téléchargements
    - **Paramètres Windows** : Fond d'écran, thème, barre des tâches
    - **Paramètres d'applications** : Configurations Outlook, navigateur
    - **Clés de registre** : HKEY_CURRENT_USER
    - **AppData** : Données des applications
        - `\AppData\Local` : Données spécifiques à la machine (cache, temp)
        - `\AppData\Roaming` : Données qui suivent l'utilisateur entre les machines
    - **Script de connexion** : Si on veut lancer une suite d'opérations lors de la connexion
        ```plaintext
        \\srv-scripts\dept\compta\logon.bat
        ```

!!! tip "Recommandations"
    
    - Attention aux profils itinérants
    - Préférer les profils locaux
    - Sécuriser les comptes sensibles

## 4. Gestion des Groupes

### Concepts Fondamentaux

!!! info "Concept des groupes"
    
    Un groupe du domaine AD est un conteneur pour gérer :
    - Utilisateurs
    - Ordinateurs (c'est possible aussi !)
    - Autres groupes


!!! info "Types de groupe: les groupes de sécurité"
    
    Il y a deux types de groupes : **groupes de sécurité** (qui gèrent les privilèges) et **groupes de distribution** (qui sont liés uniquement à l'envoi d'emails).
    
    On utilisera uniquement des groupes de sécurité.

!!! example "Exemples de groupes de sécurité"
    
    ```plaintext
    DL-Comptabilite-Lecture  # Lecture comptable
    GG-EU-RH-Admins         # Admin RH
    GG-EU-IT-Users          # Utilisateurs IT
    ```


!!! info "Types des Groupes selon son étendue"
    
    Les groupes se classifient en 3 étendues: **Domaine Local**, **Global** et Universel.
    Nous utiliserons que les deux premiers types.

!!! example "Format standard pour les groupes"
    
    ```plaintext
    [Type etendue]-[Location]-[Service]-[Fonction]
    DL-Comptabilite-Lecture  # Lecture comptable
    GG-EU-RH-Admins         # Admin RH
    GG-EU-IT-Users          # Utilisateurs IT
    ```

### 🌍 Domaine Local (DL-)

!!! info "Caractéristiques"
    
    - Servent à attribuer des droits (ex: `Admin`, `Lecture`, `Modif`)
    - Limité **au domaine AD actuel** (`maxtec.be` dans notre cas)
    - Gestion des ressources

!!! example "Exemples de groupes Domaine Local"
    
    ```plaintext
    DL-Serveurs-Admin      # Admin
    DL-Comptabilite-Lecture # Lecture
    DL-RH-Modif            # Modif
    ```

### 🌎 Global (GG-)

!!! info "Caractéristiques"
    
    - Servent à structurer l'entreprise (ex: groupes pour les `Comptables`, `Managers`, `Support`)
    - Visible dans toute la forêt AD
    - Regroupe par rôle

!!! example "Exemples de groupes Global"
    
    ```plaintext
    GG-EU-Compta-Users  # Comptables
    GG-EU-RH-Admins     # Managers RH
    GG-EU-IT-Users     # Utilisateurs IT
    ```

!!! note "Important"
    
    Ces fonctions des groupes ont lieu dans le contexte d'une grande entreprise, mais dans notre labo ce seront les groupes globaux qui recevront les droits pour ne pas créer une couche en plus. On verra ça plus en détail dans [la stratégie AGDLP](#52-strategie-agdlp).



### 🌏 Universel (U-)

!!! info "Caractéristiques"
    
    - Accès **multi-forêts**
    - Impact réplication
    - Usage restreint

!!! example "Exemples de groupes Universel"
    
    ```plaintext
    U-Direction              # Direction générale
    U-Projet-Global          # Projets multi-sites
    U-Admin-Global           # Administration globale
    ```

## 5. Comment est-qu'on donne des droits aux utilisateurs ?

!!! warning "Règle d'or"
    
    La **règle d'or** est de ne jamais attribuer de droits (ex: accéder à un dossier partagé, changer son mot de passe) directement aux utilisateurs. Alors on donnera les droits aux **groupes**.

!!! example "Exemple pratique"
    
    Ceci est un exemple de test pour comprendre le fonctionnement de base des permissions.
    
    Nous allons créer un dossier partagé `IT-docs` sur le serveur (`C:\IT-docs`. Son chemin de réseau sera `\\dns1\IT-docs`).


!!! info "Préparation"
    
    Avant de commencer, assurez-vous d'avoir la structure complète de l'AD (si ce n'est pas le cas, lancez le script de Powershell).
    
    **Puis :**
    
    - Créez la OU pour le département IT (si elle n'existe pas encore)
    - Créez aussi un groupe pour les administrateurs de IT (ex: "GG-EU-IT-Admins") et un autre pour les utilisateurs (ex: "GG-EU-IT-Users")
    - Assurez-vous d'avoir un ordinateur (Virtual Machine client) qui porte le nom `ws-IT-01` et un autre `ws-RH-01`. Si ce n'est pas le cas, modifiez les noms des ordinateurs dans vos machines virtuelles et re-démarrez-les
    - Dans le serveur, allez dans `Utilisateurs et ordinateurs AD` et rajoutez des utilisateurs aux groupes (s'ils n'existent pas, créez-les):
        - `GG-EU-IT-Users` : Ivan, Ines
        - `GG-EU-IT-Admins` : Irene
        - `GG-EU-Ventes-Users` : Victor, Vanessa, Valeria
        - `GG-EU-Ventes-Admins` : Valentin
        - `GG-EU-RH-Users` : Rene, Rebecca
        - `GG-EU-RH-Admins` : Richard
        - `GG-EU-Compta-Users` : Charles, Cindy
        - `GG-EU-Compta-Admins` : Charlotte

!!! question "Objectif"
    
    **Nous devons choisir maintenant qui aura accès à ce dossier (qui aura le **droit** d'accès) et avec quels **permissions** (modifier, lire, créer de fichiers à l'intérieur, etc.)**
    
    Pour cela nous sommes obligés de **comprendre les deux niveaux de permissions**.

## 5.1. Les deux niveaux des sécurité

### Partage (réseau)

!!! info "Objectif"
    
    Contrôle **d'accès au dossier partagé** (qui à le droit d'accéder au dossier partagé et avec quels permissions-autorisations - lecture, écriture, controle total)

!!! example "Configuration du partage"
    
    1. Faites clique-droit sur le dossier `C:\IT-docs` et `Propriétés`
    2. Cliquez sur `Partage` et `Partage avancé`
    3. Cochez `Partager ce dossier`
    4. Cliquez sur **Autorisations**
    
    !!! note "Premier niveau de sécurité"
        
        Dans ce menu on choisit **qui** aura le **droit d'accéder** au dossier et avec quelles **permissions**. C'est un **premier niveau de sécurité**.
    
    5. Effacez `Tout le monde`
    6. Ajoutez `GG-EU-IT-Users` avec les permissions de `Lecture` et `Modification`
    7. Cliquez sur `OK`, puis cliquez sur `OK`

!!! success "Résultat"
    
    Le dossier est partagé maintenant et visible par tout le monde, mais accésible uniquement par `GG-EU-IT-Users`.

!!! example "Tests d'accès"
    
    **Test 1 - Utilisateur autorisé :**
    
    1. Ouvrez une session dans machine client avec un User de `GG-EU-IT-Users` (ex: `ivan`)
    2. Ouvrez `Explorateur de fichiers`
    3. Allez dans `\\dns1\IT-docs`: il doit pouvoir ouvrir le dossier
    
    **Test 2 - Utilisateur non autorisé :**
    
    1. Ouvrez une session dans machine client avec un User de `GG-EU-Ventes-Users` (ex: `victor`)
    2. Ouvrez `Explorateur de fichiers`
    3. Allez dans `\\dns1\IT-docs`: **il voit le dossier mais il ne peut pas l'ouvrir** !

!!! question "Question de réflexion"
    
    Connectez-vous avec `irene` de `GG-EU-IT-Admins` et essayez de l'ouvrir le dossier. Qu'est-ce que vous observez ? Comment l'arranger ?

### Permissions NTFS (système de fichiers)

!!! info "Objectif"
    
    Contrôle d'accès **au niveau du système de fichiers**, pas du réseau

!!! info "Caractéristiques des permissions NTFS"
    
    - **S'appliquent uniquement si l'utilisateur peut déjà accéder au dossier partagé** 
    - Offrent plusieurs niveaux de permissions (autorisations): Contrôle total, Lecture, Écriture, Modification, Lecture et exécution, Affichage....
    - Constituent une **autre barrière de sécurité**


!!! warning "Note importante"
    
    La sécurité finale est **déterminée par l'intersection des deux types de permissions**. L'**utilisateur obtient toujours le niveau de permission le plus restrictif entre NTFS (ci-dessous) et partage**.
    
    Par exemple, si un utilisateur a un accès en **Modification** au niveau du partage mais en **Lecture seule** au niveau **NTFS**, il ne pourra que lire les fichiers.

Pour qu'un utilisateur ait des permissions il dot se trouver dans la liste de **Sécurité** ou inclut dans un groupe qui se trouve dans la liste de **Sécurité**

Modifions maintenant les permissions NTFS pour restreindre l'accès au contenu au dossier grâce aux permissions NTFS

- Faites clique-droit sur le dossier `IT-docs` et `Propriétés`
- Cliquez sur `Modifier`
- On voit `Utilisateurs` dans la liste. Ceci permettrai, au niveau du système de fichiers NTFS, d'accéder au dossier à tous les utilisateurs connectés au serveur

C'est vrai qu'**on a limité l'accès par le réseau, mais quand-même un utilisateur pourrait par exemple acceder au dossier s'il se connectait au serveur en local car il a de permissions NTFS et sur la connexion local on n'applique pas la restriction de partage réseau**!!

- On doit **supprimer les `Utilisateurs` de la liste**, mais on ne peut pas car il hérite les autorisations des groupes plus haut dans la liste
- Fermez la fenetre actuelle et cliquez sur `Avancé` dans les propriétés du dossier(onglet `Sécurité`)
- Cliquez sur `Desactiver l'héritage` et puis `Convertir....`. N'appuyez pas sur `Supprimer` car vous enlèverez les permissions des groupes! (solution dans le fichier [Annexe: Permissions](Labo%20et%20Exercices/Labo/Annexe.Permissions.md) si besoin!)
- Supprimez maintenant les groupes d'utilisateurs de la liste  
- Cochez `Remplacer toutes les entrées` pour que les sous dossiers et fichiers inclus (dans le futur) dans le dossier partagé reçoivent les mêmes permissions
- Cliquez sur `Ok` pour accepter et puis `OK` pour arriver à la fenetre des propriéteś (onglet Sécurité)
- Dans l'onglet `Sécurité`, cliquez `Modifier` > `Ajouter`
- Rajoutez les groupes `GG-EU-IT-Users` et `GG-EU-IT-Admins`. Rajoutez `Modification` (cochez la case) uniquement pour `GG-EU-IT-Admins`. Enlevez `Écriture` pour `GG-EU-IT-Users`
- Puis **appuyez sur ok pour revenir dans les propriétés du partage, onglet Sécurité**
- Cliquez sur `OK` et vous arriverez dans la fenetre d'Autorisations
- Cliquez sur `OK` pour quitter la fenetre d'Autorisations
- Cliquez sur `OK` pour quitter la fenetre de Propriétés

Connectez vous avez `ivan` de `GG-EU-IT-Users` et essayez de l'ouvrir le dossier.

Jonglez vous-mêmes avec les permissions (ex: donnez l'accès d'écriture mais pas de modification aux GG-EU-IT-Users, etc...)


**Caractéristiques des permissions NTFS** :
- S'appliquent localement sur le serveur
- Offrent un **contrôle granulaire** (fin, ciblé) des accès
- Restent actives même en accès local
- Permettent des permissions spécifiques (ex: Lecture, Écriture, Exécution)

#### Accumulation des Droits :
- Un utilisateur hérite des droits de tous ses groupes
- Les droits sont **cumulatifs** dans l'héritage (sauf si on refuse à la main dans l'onglet Sécurité)
- L'appartenance à des groupes privilégiés (comme `Admins du domaine`) étend les droits

## 5.2. Stratégie AGDLP

!!! tip "Best Practice Microsoft"
    
    **AGDLP** est la stratégie recommandée par Microsoft pour gérer les permissions de manière efficace et maintenable dans Active Directory.

### Qu'est-ce que AGDLP ?

**AGDLP** signifie :

- **A**ccounts (Comptes utilisateurs)
- **G**lobal groups (Groupes globaux)
- **D**omain **L**ocal groups (Groupes locaux de domaine)
- **P**ermissions (Permissions sur les ressources)

### Scénario : Dossier partagé "Documents Communs"

Vous avez un dossier partagé `\\SRV-FILES\Documents-Communs` qui doit être accessible par **Comptabilité ET RH**.

### ❌ Sans AGDLP (compliqué)

!!! warning 
    
    Tu devrais donner les permissions directement aux 2 groupes globaux :
    
    - Permissions → `GG-EU-Compta-Users`
    - Permissions → `GG-EU-RH-Users`
    
    **Problème** : Si tu ajoutes Ventes plus tard, tu dois **modifier les permissions du dossier encore**.

### ✅ Avec AGDLP (simple)

!!! success "Approche recommandée"
    
    ```plaintext
    ACCOUNTS (utilisateurs)
        ↓ membres de
    GLOBAL GROUPS (par département)
        GG-EU-Compta-Users
        GG-EU-RH-Users
        ↓ membres de
    DOMAIN LOCAL GROUP (par ressource)
        DL-Documents-Communs-Lecture
        ↓ reçoit
    PERMISSIONS (sur le dossier)
        Lecture sur \\SRV-FILES\Documents-Communs
    ```

!!! tip "Avantages"
    
    Pour ajouter Ventes plus tard, tu ajoutes simplement `GG-EU-Ventes-Users` au groupe `DL-Documents-Communs-Lecture`. 
    
    **Les permissions ne changent jamais !**

### 📝 Résumé AGDLP

!!! info "Comprendre les rôles"
    
    - **Groupe Local de Domaine (DL-)** = "qui peut accéder à CETTE ressource"
    - **Groupes Globaux (GG-)** = "qui est dans CE département"
    
    **Principe** : Les groupes locaux reçoivent les permissions, les groupes globaux contiennent les utilisateurs.

!!! note "Dans notre labo"
    
    Pour simplifier les exercices de base, nous utiliserons souvent directement les groupes globaux pour les permissions. Cependant, dans un environnement de production, **AGDLP est la meilleure pratique** à suivre.

---

## 6. Groupes Intégrés AD

### 6.1 Groupes Essentiels

Active Directory inclut trois groupes intégrés essentiels :

#### Admins du domaine
Groupe **d'administration principal** du domaine :
- Contrôle total sur le domaine
- Accès complet aux ressources
- Membre du groupe Administrators

Responsabilités principales :
- Gérer les contrôleurs de domaine
- Configurer les stratégies de sécurité

#### Enterprise Admins
Groupe **d'administration de la forêt** AD :
- Gère l'infrastructure globale
- Configure les relations entre domaines
- Administre les sites AD

Responsabilités principales :
- Étendre la forêt AD
- Gérer la topologie des sites

#### Schema Admins
Groupe **spécialisé** pour le schéma AD :
- Modifie la structure de l'annuaire
- Accès très restreint
- Utilisation ponctuelle

Responsabilités principales :
- Étendre le schéma AD
- Préparer AD pour Exchange

### 6.2 Groupes de Sécurité

#### Account Operators
Groupe pour la gestion des comptes :
- Création et modification de comptes
- Gestion des appartenances aux groupes
- Privilèges limités (pas d'accès administrateur)

Responsabilités principales :
- Gérer les comptes utilisateurs
- Administrer les groupes standard

#### Backup Operators
Groupe pour les opérations de sauvegarde :
- Accès en lecture à tous les fichiers
- Privilèges NTFS spéciaux
- Droits de lecture sur le domaine

Responsabilités principales :
- Exécuter les sauvegardes système
- Restaurer les données


## 7. Organisation des Groupes

> 💡 Deux stratégies principales :

#### 🏒 Structure par Département
```plaintext
📂 DL-Dossier-Partage-RW
  └─ 💳 GG-EU-Compta-Users  # Comptabilité
  └─ 💰 GG-EU-Ventes-Users  # Ventes
  └─ 👥 GG-EU-RH-Users     # RH
  └─ 💻 GG-EU-IT-Users     # Informatique
```

#### 💼 Structure par Fonction
```plaintext
📂 DL-Dossier-Partage-RW
  └─ 👑 GG-EU-Compta-Admins   # Administrateurs Comptabilité
  └─ 👑 GG-EU-RH-Admins      # Administrateurs RH
  └─ 👑 GG-EU-Ventes-Admins   # Administrateurs Ventes
  └─ 👑 GG-EU-IT-Admins      # Administrateurs IT
```



## Règles d'Imbrication de Groupes

Limitations par type de groupe :

```plaintext
Groupe Global :
- Peut contenir : Groupes globaux du même domaine AD

Groupe Local de Domaine :
- Ne peut pas contenir : Groupes globaux d'autres domaines

Groupe Universel :
- Ne peut pas contenir : Groupes globaux d'autres domaines
```

## 8. Délégation de Contrôle

### Concept de Délégation

!!! info "Qu'est-ce que la délégation ?"

    La **délégation de contrôle** permet de donner des **permissions administratives limitées** à des utilisateurs spécifiques sur certaines OUs, sans leur donner un accès complet au domaine.

!!! example "Cas d'usage typique"

    Charlotte (chef comptable) doit pouvoir **réinitialiser les mots de passe** et **débloquer les comptes** des employés de la comptabilité, mais elle ne doit **pas** avoir accès aux autres départements.

### Exemple Pratique : Délégation Reset Password

!!! warning "Prérequis"

    - Avoir une OU `EU-Comptabilite` créée
    - Avoir un utilisateur `charlotte` membre de `GG-EU-Compta-Admins`

#### Étapes de Configuration

1. **Ouvrir ADUC** (`dsa.msc`)
2. **Clic droit sur l'OU** `EU-Comptabilite`
3. Sélectionner **"Déléguer le contrôle..."**
4. Cliquer sur **Suivant** dans l'assistant

5. **Ajouter l'utilisateur ou groupe** :
   - Cliquer sur **Ajouter**
   - Taper `charlotte` (ou `GG-EU-Compta-Admins` pour déléguer au groupe entier)
   - Cliquer sur **OK** puis **Suivant**

6. **Sélectionner les tâches à déléguer** :
   - Cocher ✅ **"Réinitialiser les mots de passe utilisateur et forcer le changement de mot de passe à la prochaine ouverture de session"**
   - Cocher ✅ **"Lecture de toutes les informations utilisateur"** (optionnel mais recommandé)
   - Cliquer sur **Suivant**

7. **Terminer** l'assistant

#### Test de la Délégation

!!! example "Vérification"

    1. Connectez-vous à un poste avec `charlotte@maxtec.be`
    2. Ouvrir **ADUC** (`dsa.msc`)
    3. Naviguer vers `EU-Comptabilite`
    4. Clic droit sur un utilisateur (ex: `charles`)
    5. Sélectionner **"Réinitialiser le mot de passe"**

    ✅ Charlotte devrait pouvoir réinitialiser le mot de passe

    ❌ Si elle essaie de modifier un utilisateur dans `EU-RH`, elle recevra un **message d'erreur d'accès refusé**

### Tâches Courantes à Déléguer

!!! tip "Délégations fréquentes"

    | Tâche | Description | Utilisé par |
    |-------|-------------|-------------|
    | **Reset Password** | Réinitialiser mots de passe | Chefs de département |
    | **Créer/Supprimer Utilisateurs** | Gestion complète comptes | Responsables RH |
    | **Modifier Groupes** | Ajouter/retirer membres | Managers IT |
    | **Gérer Ordinateurs** | Joindre/retirer machines | Support technique |

!!! warning "Bonnes Pratiques"

    - ✅ Déléguer au **groupe** (`GG-EU-Compta-Admins`), pas à l'utilisateur individuel
    - ✅ Appliquer le **principe du moindre privilège** (donner uniquement les permissions nécessaires)
    - ✅ Documenter toutes les délégations effectuées
    - ❌ Ne jamais déléguer sur la racine du domaine
    - ❌ Éviter de donner "Contrôle total" sauf si absolument nécessaire

## Sécurité et Maintenance

Règles fondamentales par type de groupe :

```plaintext
Groupes Globaux (GG-) :
- Utilisés pour la gestion des utilisateurs
- Ne doivent pas recevoir de permissions directes
Exemple : GG-EU-RH-Users, GG-EU-RH-Admins

Groupes Locaux de Domaine (DL-) :
- Reçoivent les permissions sur les ressources
- Contiennent les groupes globaux appropriés
Exemple : DL-RH-Lecture, DL-RH-Modification
```

## 🎯 Checkpoint Final: Gestion des Utilisateurs

!!! info "Vérification finale"
    
    Avant de passer aux Group Policy Objects:
    
    - [ ] Savoir créer un utilisateur avec ADUC
    - [ ] Comprendre les standards de nommage (SamAccountName et UPN)
    - [ ] Savoir organiser les utilisateurs dans les UOs appropriées
    - [ ] Comprendre les concepts de groupes et leur utilisation
    - [ ] Connaitre la différence entre groupes globaux et locaux

---


### 🚀 Prochaine étape:
Vos utilisateurs sont créés et organisés! Il est maintenant temps d'apprendre à contrôler leurs environnements avec les **Group Policy Objects (GPOs)**!

> 💡 **Superbe travail:** Vous maîtrisez maintenant la gestion des identités dans Active Directory!

## 🧭 Navigation
[⏮️ Chapitre Précédent: Unités d'Organisation](Chapitre%206.Unites_Organisation.md) | [🏠 Retour au Syllabus](index.md) | [⏭️ Chapitre 8: Group Policy Objects](Chapitre%208.Group%20Policy%20Objects.md)

---

**📚 Cours Active Directory -  | 👨‍💻 Pour débutants**











