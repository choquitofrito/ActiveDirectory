# Chapitre 7: Gestion des Utilisateurs

## 🧭 Navigation du Cours
[⏮️ Chapitre Précédent: Unités d'Organisation](Chapitre%206.Unites_Organisation.md) | [🏠 Retour au Syllabus](index.md) | [⏭️ Chapitre Suivant: Group Policy Objects](Chapitre%208.Group%20Policy%20Objects.md)


!!! example "Exercices associés"
    Après la théorie, passez à la pratique :

    - **[Exercices Gestion Utilisateurs](Labo%20et%20Exercices/Exercices:%20Gestion_des_Utilisateurs.md)** - Création, restrictions, audit et gestion du cycle de vie
    - **[Exercice AGDLP - Partage de fichiers](Labo%20et%20Exercices/Exercices:%20AGDLP_Partage_Fichiers.md)** - La bonne pratique pour les permissions sur un dossier partagé

!!! info "📚 Dans ce chapitre:"

    1. [Identités Numériques](#1-identites-numeriques)
       - Concepts de base
       - Conventions de nommage

    2. [Administration ADUC](#2-utilisateurs-et-ordinateurs-active-directory-aduc)
       - Configuration des comptes
       - Gestion des accès

    3. [Sécurité et Groupes](#4-gestion-des-groupes)
       - Portées de groupe
       - Partage, NTFS et AGDLP

    4. [Délégation de Contrôle](#8-delegation-de-controle)
       - Résumé (le détail est au chapitre 6)

---

## 📙 Objectifs Pédagogiques

À la fin de ce chapitre, vous serez capable de :

1. Créer un compte utilisateur conforme aux conventions du lab (`SamAccountName`, UPN, OU, `Department`)
2. Choisir la portée d'un groupe (global, domaine local, universel) à partir du tableau des membres possibles
3. Partager `C:\Shares\IT-docs` et combiner permissions de partage et NTFS pour obtenir l'accès voulu, puis prédire l'accès effectif d'un utilisateur
4. Expliquer AGDLP et dire pourquoi l'exercice IT-docs (permissions directes aux `GG-`) n'est qu'une simplification

---

## 1. Identités Numériques

### Concepts Fondamentaux

Un compte utilisateur Active Directory représente une **identité numérique unique** (un objet) dans `maxtec.be` permettant :

!!! info "Fonctionnalités d'un compte utilisateur"
    
    - **Identification** unique (ex: `ivan`)
    - **Contrôle d'accès** aux ressources
    - **Gestion des informations** utilisateur

!!! tip "Analogie"

    Un compte utilisateur fonctionne comme un badge d'entreprise : il dit qui vous êtes, et les groupes dont il est membre disent quelles portes il ouvre.

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

!!! tip "En résumé"

    SamAccountName = nom court (`ivan`, utilisé aussi sous la forme `MAXTEC\ivan`), UPN = format adresse e-mail (`ivan@maxtec.be`)

Pour tous les deux, suivez ces règles:

- Minuscules uniquement
- Pas de caractères spéciaux
- En cas d'homonymes, on peut ajouter un identifiant supplémentaire
- Pas de chiffres sauf si nécessaire pour distinguer des homonymes

### Comptes Administrateurs : Bonne Pratique

Dans un environnement réel, un administrateur système ne travaille pas avec un seul compte. Il en a **deux** :

| Compte | Groupes | Usage |
|--------|---------|-------|
| `irene` | `GG-EU-IT-Users` (dans le lab, `irene` est seulement dans `GG-EU-IT-Admin`) | Travail quotidien : email, Teams, navigation |
| `irene-adm` | `GG-EU-IT-Admin` | Tâches administratives uniquement |

La même personne, deux comptes distincts. Pour une tâche admin, elle ouvre une session séparée ou utilise `runas`.

!!! warning "Pourquoi ne pas mettre le même compte dans les deux groupes ?"

    Si `irene` est membre à la fois de `GG-EU-IT-Users` ET `GG-EU-IT-Admin`, elle a les droits admin **en permanence**, y compris quand elle lit ses e-mails ou navigue sur le web.

    Conséquence : un malware ou un lien de phishing ouvert depuis cette session dispose des **mêmes privilèges admin**.

    C'est l'un des **premiers constats d'un audit de sécurité AD** : comptes à privilèges excessifs.

!!! danger "Tiering : où un compte admin a le droit de se connecter"

    La séparation des comptes ne suffit pas : il faut aussi limiter **où** chaque compte ouvre une session. Un compte **admin du domaine ne se connecte jamais sur un poste utilisateur** (ni `ws-IT-01`, ni `ws-RH-01`) : ses identifiants resteraient en mémoire sur une machine moins protégée, prêts à être volés. Il ne s'utilise que sur les DC et les postes d'administration dédiés. Voir [Chapitre 11 : Sécurité AD](Chapitre%2011.Securite_AD.md).

!!! tip "Principe du moindre privilège"
    
    Chaque compte ne doit avoir que les droits **strictement nécessaires** à ce qu'il fait à cet instant. C'est le principe fondamental de sécurité en AD.

!!! note "Dans notre labo"
    
    Pour simplifier, on utilisera un seul compte par personne (et `irene` n'est pas administratrice du domaine). Mais gardez ce modèle à l'esprit : dans un environnement de production, **toute personne avec des droits admin devrait avoir deux comptes séparés**.

## 🎯 Checkpoint: Concepts des Comptes

!!! info "Vérification de compréhension"
    
    Avant de créer vos premiers utilisateurs:
    
    - [ ] Savoir qu'un compte utilisateur est une identité numérique
    - [ ] Comprendre SamAccountName vs UPN
    - [ ] Connaitre les règles de nommage (minuscules, pas de caractères spéciaux)
    - [ ] Savoir que le format standard est "prenom" et "prenom@maxtec.be"
    - [ ] Comprendre pourquoi un admin devrait avoir deux comptes séparés



## 2. Utilisateurs et Ordinateurs Active Directory (ADUC)

**"Utilisateurs et Ordinateurs Active Directory"** (**ADUC**) est une console de gestion permettant de gérer les **utilisateurs, groupes, ordinateurs et unités d'organisation (OU)** dans un domaine AD.

Vous pouvez l'ouvrir de plusieurs façons : tapez `Utilisateurs et ordinateurs Active Directory` depuis le menu Démarrer ou via `dsa.msc`. C'est la méthode traditionnelle de gérer l'AD.
Ou même `Gestionnaire de serveur`->`Outils`->`Utilisateurs et ordinateurs Active Directory`.

Il existe aussi une console plus récente, le **Centre d'administration Active Directory** (ADAC, `dsac.exe` : `Gestionnaire de serveur` → `Outils` → `Centre d'administration Active Directory`). C'est une application Windows (construite sur PowerShell), **pas une interface web**. Elle donne accès à des fonctions absentes d'ADUC : corbeille AD, stratégies de mot de passe affinées, et l'historique des commandes PowerShell qu'elle exécute.


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
    
    1. **Clic droit sur l'OU `EU > Comptabilite > Users`** (pas sur le conteneur `Users` par défaut, où aucune GPO d'OU ne s'applique)
    2. **Nouveau** > **Utilisateur**

    #### **Informations de Base**

    - **Prénom** : Charles
    - **Nom** : Cornet
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
        
        Vous devez taper le début du nom de l'utilisateur, par exemple `reb` pour `rebecca`.
    
    #### **Méthode 2 : Recherche traditionnelle**
    Ouvrir `Utilisateurs et ordinateurs Active Directory` depuis le menu Démarrer ou via `dsa.msc`. Faites clique droit sur `Users` et sélectionnez `Rechercher un utilisateur`. 



### 3.3. Modification des Propriétés

Après la création du compte, il est important de configurer les **propriétés supplémentaires** pour faciliter les tâches de gestion.

### 3.4. Informations Essentielles

!!! info "Configuration des propriétés utilisateur"
    
    #### **Onglet Général**
    
    | Champ | Exemple |
    |-------|---------|
    | Description | Comptable |
    | Service (`Department`) | Comptabilite (sans accent, comme le nom de l'OU) |
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
    - Exemple : `ws-RH-01`

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
    GG-EU-RH-Admin         # Admin RH
    GG-EU-IT-Users          # Utilisateurs IT
    ```


!!! info "Portée (étendue) des groupes"

    Les groupes ont 3 portées : **Domaine local**, **Global** et **Universel**.
    Dans le lab (un seul domaine), nous utilisons surtout les deux premières.

!!! example "Format standard pour les groupes"
    
    ```plaintext
    [Type etendue]-[Location]-[Service]-[Fonction]
    DL-Comptabilite-Lecture  # Lecture comptable
    GG-EU-RH-Admin         # Admin RH
    GG-EU-IT-Users          # Utilisateurs IT
    ```

### Tableau de référence des portées

Ce tableau reprend la documentation Microsoft. Il répond à trois questions : qui peut entrer dans le groupe, dans quoi le groupe peut entrer, et où il peut recevoir des permissions.

| Portée | Membres possibles | Peut être membre de | Peut recevoir des permissions |
|---|---|---|---|
| **Global** (`GG-`) | Comptes et autres groupes globaux **du même domaine** | Groupes universels de la forêt ; groupes globaux du même domaine ; groupes domaine local de n'importe quel domaine de la forêt (ou d'un domaine approuvant) | Dans n'importe quel domaine de la forêt, ou d'un domaine/forêt approuvant |
| **Domaine local** (`DL-`) | Comptes et groupes globaux de **n'importe quel domaine** (y compris approuvé ou d'une autre forêt) ; groupes universels de la forêt ; autres groupes domaine local **du même domaine** | Autres groupes domaine local du même domaine ; groupes locaux des machines du même domaine | **Uniquement dans son propre domaine** |
| **Universel** (`UG-`) | Comptes, groupes globaux et universels de **n'importe quel domaine de la même forêt** | Autres groupes universels de la forêt ; groupes domaine local et groupes locaux de la forêt (ou d'une forêt approuvante) | Dans n'importe quel domaine de la forêt (ou d'une forêt approuvante) |

Lecture pratique :

- **Global** = « qui ? » : on y met les personnes d'un même rôle ou département.
- **Domaine local** = « quel accès à quelle ressource ? » : c'est lui qui reçoit la permission sur le dossier.
- **Universel** = regrouper des groupes globaux de **plusieurs domaines de la même forêt**. Sa liste de membres est répliquée dans le **catalogue global**, d'où un coût de réplication : à réserver aux forêts multi-domaines.

### 🌍 Domaine Local (DL-)

!!! info "Caractéristiques"

    - Servent à attribuer des droits sur une ressource (ex: `Admin`, `Lecture`, `Modification`)
    - Ne peuvent recevoir des permissions **que dans leur propre domaine** (`maxtec.be`)
    - Peuvent contenir des groupes globaux de n'importe quel domaine

!!! example "Exemples de groupes Domaine Local"
    
    ```plaintext
    DL-Serveurs-Admin      # Admin
    DL-Comptabilite-Lecture # Lecture
    DL-RH-Modification     # Modification
    ```

### 🌎 Global (GG-)

!!! info "Caractéristiques"
    
    - Servent à regrouper les personnes par rôle ou département (ex: `Comptables`, `Managers`, `Support`)
    - Ne contiennent que des comptes et groupes globaux **du même domaine**
    - Peuvent être utilisés (membres d'un DL, permissions) dans toute la forêt

!!! example "Exemples de groupes Global"
    
    ```plaintext
    GG-EU-Compta-Users  # Comptables
    GG-EU-RH-Admin     # Managers RH
    GG-EU-IT-Users     # Utilisateurs IT
    ```

!!! note "Important : une simplification assumée dans le §5"

    Dans l'exemple `IT-docs` du §5, on donne les permissions **directement aux groupes globaux** (schéma « AGP » : Account → Global → Permission). C'est une simplification consciente pour se concentrer sur partage vs NTFS. La bonne pratique, AGDLP, est expliquée au [§5.2](#52-strategie-agdlp) et appliquée dans l'[exercice AGDLP](Labo%20et%20Exercices/Exercices:%20AGDLP_Partage_Fichiers.md).



### 🌏 Universel (UG-)

!!! info "Caractéristiques"

    - Membres venant de **n'importe quel domaine de la même forêt** (pas d'une autre forêt)
    - Liste des membres répliquée dans le catalogue global
    - Usage restreint aux forêts à plusieurs domaines

!!! example "Exemples de groupes Universel"

    ```plaintext
    UG-Direction              # Direction générale (plusieurs domaines)
    UG-Projet-Global          # Projet partagé entre domaines
    ```

## 5. Comment est-qu'on donne des droits aux utilisateurs ?

!!! warning "Règle d'or"
    
    La **règle d'or** est de ne jamais attribuer de droits (ex: accéder à un dossier partagé, changer son mot de passe) directement aux utilisateurs. Alors on donnera les droits aux **groupes**.

!!! example "Exemple pratique"
    
    Ceci est un exemple de test pour comprendre le fonctionnement de base des permissions.
    
    Nous allons créer un dossier partagé `IT-docs` sur le serveur (`C:\Shares\IT-docs`. Son chemin de réseau sera `\\dns1\IT-docs`).


!!! info "Préparation"
    
    Avant de commencer, assurez-vous d'avoir la structure complète de l'AD (si ce n'est pas le cas, lancez le script de Powershell).
    
    **Puis :**
    
    - Créez la OU pour le département IT (si elle n'existe pas encore)
    - Créez aussi un groupe pour les administrateurs de IT (ex: "GG-EU-IT-Admin") et un autre pour les utilisateurs (ex: "GG-EU-IT-Users")
    - Assurez-vous d'avoir un ordinateur (Virtual Machine client) qui porte le nom `ws-IT-01` et un autre `ws-RH-01`. Si ce n'est pas le cas, modifiez les noms des ordinateurs dans vos machines virtuelles et re-démarrez-les
    - Dans le serveur, allez dans `Utilisateurs et ordinateurs AD` et rajoutez des utilisateurs aux groupes (s'ils n'existent pas, créez-les):
        - `GG-EU-IT-Users` : Ivan, Ines
        - `GG-EU-IT-Admin` : Irene
        - `GG-EU-Ventes-Users` : Victor, Vanessa, Valeria
        - `GG-EU-Ventes-Admin` : Valentin
        - `GG-EU-RH-Users` : Rene, Rebecca
        - `GG-EU-RH-Admin` : Richard
        - `GG-EU-Compta-Users` : Charles, Cindy
        - `GG-EU-Compta-Admin` : Charlotte

!!! question "Objectif"
    
    **Nous devons choisir maintenant qui aura accès à ce dossier (qui aura le **droit** d'accès) et avec quels **permissions** (modifier, lire, créer de fichiers à l'intérieur, etc.)**
    
    Pour cela nous sommes obligés de **comprendre les deux niveaux de permissions**.

## 5.1. Les deux niveaux des sécurité

### Partage (réseau)

!!! info "Objectif"
    
    Contrôle **d'accès au dossier partagé** (qui à le droit d'accéder au dossier partagé et avec quels permissions-autorisations - lecture, écriture, controle total)

!!! example "Configuration du partage"
    
    1. Faites clique-droit sur le dossier `C:\Shares\IT-docs` et `Propriétés`
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

!!! info "Ce qui passe sur le réseau"

    L'accès à `\\dns1\IT-docs` utilise le protocole **SMB** sur le port **TCP 445**. Si l'accès échoue sans message clair, vérifiez d'abord que le port répond depuis le client :

    ```powershell
    Test-NetConnection dns1 -Port 445
    ```

    `TcpTestSucceeded : True` = le serveur écoute, le problème est ailleurs (permissions, nom). Par curiosité : depuis une machine Linux, le même partage s'ouvre avec `smbclient //dns1/IT-docs -U ivan@maxtec.be`. SMB n'est pas propre à Windows.

!!! question "Question de réflexion"
    
    Connectez-vous avec `irene` de `GG-EU-IT-Admin` et essayez de l'ouvrir le dossier. Qu'est-ce que vous observez ? Comment l'arranger ?

### Permissions NTFS (système de fichiers)

!!! info "Objectif"
    
    Contrôle d'accès **au niveau du système de fichiers**, pas du réseau

!!! info "Caractéristiques des permissions NTFS"
    
    - S'appliquent **toujours** : en local sur le serveur comme à travers le réseau
    - Les permissions de **partage**, elles, ne s'appliquent **que** pour un accès par le réseau (`\\dns1\IT-docs`)
    - Offrent plusieurs niveaux de permissions (autorisations) : Contrôle total, Modification, Lecture et exécution, Affichage du contenu du dossier, Lecture, Écriture
    - Constituent une **deuxième barrière de sécurité**


!!! warning "Note importante"
    
    Pour un accès **par le réseau**, la permission effective est **la plus restrictive des deux** (partage et NTFS). Pour un accès **local** (session ouverte sur le serveur), seul NTFS compte.
    
    Par exemple, si un utilisateur a un accès en **Modification** au niveau du partage mais en **Lecture seule** au niveau **NTFS**, il ne pourra que lire les fichiers.

Pour qu'un utilisateur ait des permissions il doit se trouver dans la liste de **Sécurité** ou inclut dans un groupe qui se trouve dans la liste de **Sécurité**

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
- Rajoutez les groupes `GG-EU-IT-Users` et `GG-EU-IT-Admin`. Rajoutez `Modification` (cochez la case) uniquement pour `GG-EU-IT-Admin`. Enlevez `Écriture` pour `GG-EU-IT-Users`
- Puis **appuyez sur ok pour revenir dans les propriétés du partage, onglet Sécurité**
- Cliquez sur `OK` et vous arriverez dans la fenetre d'Autorisations
- Cliquez sur `OK` pour quitter la fenetre d'Autorisations
- Cliquez sur `OK` pour quitter la fenetre de Propriétés

Connectez vous avez `ivan` de `GG-EU-IT-Users` et essayez de l'ouvrir le dossier.

Jonglez vous-mêmes avec les permissions (ex: donnez l'accès d'écriture mais pas de modification aux GG-EU-IT-Users, etc...)


**Caractéristiques des permissions NTFS** :

- S'appliquent à tout accès, local ou réseau
- Offrent un **contrôle granulaire** (fin, ciblé) des accès
- Sont les seules actives en accès local
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

Un dossier partagé `\\dns1\Documents-Communs` (exemple, non créé dans le lab) doit être accessible par **Comptabilite ET RH**.

### ❌ Sans AGDLP (compliqué)

!!! warning 
    
    Vous donnez les permissions directement aux 2 groupes globaux :

    - Permissions → `GG-EU-Compta-Users`
    - Permissions → `GG-EU-RH-Users`

    **Problème** : si Ventes doit aussi y accéder plus tard, il faut **modifier encore les permissions du dossier** (et de chaque dossier concerné).

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
        Lecture sur \\dns1\Documents-Communs
    ```

!!! tip "Avantages"
    
    Pour ajouter Ventes plus tard, il suffit d'ajouter `GG-EU-Ventes-Users` au groupe `DL-Documents-Communs-Lecture`. 
    
    **Les permissions ne changent jamais !**

### 📝 Résumé AGDLP

!!! info "Comprendre les rôles"
    
    - **Groupe Local de Domaine (DL-)** = "qui peut accéder à CETTE ressource"
    - **Groupes Globaux (GG-)** = "qui est dans CE département"
    
    **Principe** : Les groupes locaux reçoivent les permissions, les groupes globaux contiennent les utilisateurs.

!!! note "AGDLP, AGLP, AGP : ne pas confondre"

    - **AGDLP** : Account → Global → **Domain Local** → Permission. Le groupe domaine local reçoit la permission sur la ressource.
    - **AGLP** : même logique, mais avec un **groupe local de la machine** qui héberge la ressource (serveur hors domaine ou ancien modèle).
    - **AGP** : la permission est donnée directement au groupe global. C'est ce que nous avons fait pour `IT-docs` au §5, **volontairement**, pour simplifier. L'[exercice AGDLP](Labo%20et%20Exercices/Exercices:%20AGDLP_Partage_Fichiers.md) montre la bonne pratique.

    Ce n'est pas une question de taille d'entreprise : AGDLP est la recommandation même dans un seul domaine, parce qu'elle évite de retoucher les permissions de la ressource.

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

!!! danger "Account Operators et Backup Operators : à laisser vides"

    Ces deux groupes intégrés ont l'air « limités ». Ils ne le sont pas : ce sont de fait des groupes **Tier 0**, aussi sensibles que `Admins du domaine`.

    - **Account Operators** : peut créer et modifier la plupart des comptes et groupes du domaine, et **ouvrir une session sur les DC**.
    - **Backup Operators** : peut ouvrir une session sur les DC, sauvegarder et restaurer n'importe quel fichier en ignorant NTFS, donc **copier la base `NTDS.dit`** (tous les hachages de mots de passe du domaine).

    Bonne pratique : les laisser **vides** et utiliser la délégation d'OU (chapitre 6, §9) pour les besoins de gestion de comptes.

#### Account Operators
Groupe intégré de gestion des comptes :

- Création et modification de comptes et de groupes (hors groupes protégés)
- Ouverture de session locale sur les contrôleurs de domaine

#### Backup Operators
Groupe intégré pour les sauvegardes :

- Sauvegarde et restauration de tous les fichiers, en contournant les permissions NTFS
- Ouverture de session locale sur les contrôleurs de domaine


## 7. Organisation des Groupes

Deux façons de remplir un même groupe domaine local :

#### Structure par Département
```plaintext
DL-Dossier-Partage-Modification
  └─ GG-EU-Compta-Users  # Comptabilite
  └─ GG-EU-Ventes-Users  # Ventes
  └─ GG-EU-RH-Users      # RH
  └─ GG-EU-IT-Users      # Informatique
```

#### Structure par Fonction
```plaintext
DL-Dossier-Partage-Modification
  └─ GG-EU-Compta-Admin  # Responsables Comptabilite
  └─ GG-EU-RH-Admin      # Responsables RH
  └─ GG-EU-Ventes-Admin  # Responsables Ventes
  └─ GG-EU-IT-Admin      # Administrateurs IT
```



## Règles d'Imbrication de Groupes

Les règles complètes sont dans le [tableau de référence des portées](#tableau-de-reference-des-portees). À retenir pour un seul domaine :

```plaintext
Global        : contient des comptes et des groupes globaux du même domaine
Domaine local : contient des comptes, des globaux, des universels et d'autres DL du même domaine
Universel     : contient des comptes, des globaux et des universels de toute la forêt
Sens AGDLP    : compte → GG- → DL- (jamais l'inverse : un DL ne peut pas entrer dans un GG)
```

## 8. Délégation de Contrôle

La **délégation de contrôle** donne à un groupe des droits précis (réinitialiser des mots de passe, créer des comptes…) **sur une OU**, sans le rendre administrateur du domaine. Exemple Maxtec : `GG-EU-Compta-Admin` (Charlotte) peut réinitialiser les mots de passe des comptes de `EU/Comptabilite/Users`, et rien d'autre.

La procédure complète (assistant, test depuis le client avec RSAT ou `runas /netonly`, limites de la délégation) est au **[chapitre 6, §9 Délégation de contrôle](Chapitre%206.Unites_Organisation.md#9-delegation-de-controle)**. La mise en pratique est l'[exercice 12](Labo%20et%20Exercices/Exercices:%20Gestion_des_Utilisateurs.md#exercice-12-delegation-dadministration).

!!! warning "À retenir"

    - Déléguer au **groupe** (`GG-EU-Compta-Admin`), pas à l'utilisateur
    - Déléguer une **tâche précise** sur la plus petite OU possible ; éviter « Contrôle total »
    - Ne jamais déléguer sur la racine du domaine
    - Préférer la délégation aux groupes intégrés `Account Operators` / `Backup Operators` (§6.2)

## Sécurité et Maintenance

Règles fondamentales par type de groupe (en production ; le §5 fait volontairement une exception, voir §5.2) :

```plaintext
Groupes Globaux (GG-) :
- Regroupent les utilisateurs par rôle/département
- Ne reçoivent pas de permissions directes sur les ressources
Exemple : GG-EU-RH-Users, GG-EU-RH-Admin

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
    - [ ] Connaître la différence entre groupes globaux, domaine local et universels
    - [ ] Prédire l'accès effectif par le réseau quand partage et NTFS diffèrent
    - [ ] Savoir pourquoi `Account Operators` et `Backup Operators` doivent rester vides

---


### 🚀 Prochaine étape:
Les utilisateurs et les groupes sont en place. Le chapitre suivant configure leur environnement avec les **Group Policy Objects (GPOs)**.

## 🧭 Navigation
[⏮️ Chapitre Précédent: Unités d'Organisation](Chapitre%206.Unites_Organisation.md) | [🏠 Retour au Syllabus](index.md) | [⏭️ Chapitre 8: Group Policy Objects](Chapitre%208.Group%20Policy%20Objects.md)

---

**📚 Cours Active Directory - Gestion des utilisateurs**
