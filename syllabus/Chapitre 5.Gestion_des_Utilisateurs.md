# Chapitre 5: Gestion des Utilisateurs

> 📚 **Dans ce chapitre:**
> 1. 👤 [Identités Numériques](#1-introduction-aux-comptes-utilisateurs)
>    - Concepts de base
>    - Conventions de nommage
> 2. ⚙️ [Administration ADUC](#2-utilisateurs-et-ordinateurs-active-directory)
>    - Configuration des comptes
>    - Gestion des accès
> 3. 🔐 [Sécurité et Groupes](#5-gestion-des-groupes)
>    - Stratégies de sécurité
>    - Organisation des accès

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

Un compte utilisateur Active Directory représente une **identité numérique unique** dans `computerelectronics.be` permettant :

- **Identification** unique (ex: `sophie.lambert`)
- **Contrôle d'accès** aux ressources
- **Gestion des informations** utilisateur

> **Exemple** : Connexion de Sophie Lambert

1. Connexion au poste de travail
2. Vérification des identifiants
3. Accès aux ressources autorisées


### 📝 Standards de Nommage

#### 🌐 Convention SamAccountName

Un utilisateur a deux identifiants possibles:

- **SamAccountName**, qui est l'identifiant unique de l'utilisateur dans le domaine, dont le format de base est **prenom.nom**

```plaintext
💰 clark.kent              # Comptabilité
👥 sophie.lambert          # RH
💰 jean.martin.compta      # Comptabilité
👥 jean.martin.rh          # RH
🇫🇷 jean.martin.compta.fr   # France
🇧🇪 jean.martin.compta.be   # Belgique
```
- **UPN** (User Principal Name), dont le format de base est **prenom.nom@domaine**
 
Pour tous les deux, suivez ces règles:

- Minuscules uniquement
- Point comme seul caractère spécial
- En cas d'homonymes :
  1. Ajout du département (`.compta`, `.rh`)
  2. Ajout d'identifiants :
     - 🌐 Pays (`.fr`, `.be`)
     - 💼 Fonction (`.senior`, `.junior`)
     - 🏢 Site (`.bxl`, `.anvers`)
- Pas de chiffres



## 2. Utilisateurs et Ordinateurs Active Directory (ADUC)

**"Utilisateurs et Ordinateurs Active Directory"** (**ADUC**) est une console de gestion permettant de gérer les **utilisateurs, groupes, ordinateurs et unités d'organisation (OU)** dans un domaine AD.

Vous pouvez l'ouvrir de plusieur formes: tapez `Utilisateurs et ordinateurs Active Directory` depuis le menu Démarrer ou via `dsa.msc`. C'est la méthode traditionnelle de gérer l'AD.
Ou même `Gestionnaire de serveur`->`Outils`->`Utilisateurs et ordinateurs Active Directory`.

 C'est la méthode traditionnelle pour gérer l'AD, mais il y a aussi la **méthode moderne via l'interface web de l'AD** (`Gestionnaire de serveur`->`Outils`->`Centre d'administration d'AD`).


Dans les deux outils vous avez accès aux **éléments suivants**:

- **Structure du domaine AD** : Affiche plusieurs containers d'objects (ex: Users, Computers, Domain Controllers) et les **Unités d'organisation (OU)** (dont on en a pas pour l'instant).

- **Objets du domaine AD** , entre autres :
  - **Utilisateurs** : Comptes des utilisateurs du domaine AD et leurs propriétés.
  - **Ordinateurs** : Machines jointes au domaine AD.
  - **Contrôleurs de domaine** : Liste des DC du domaine AD.

Par défaut, il y a plusieurs **conteneurs** (**ce ne sont pas des OU**, mais des conteneurs d'objets) :
 :
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

> 💡 Processus pour ajouter un nouveau collaborateur

#### 💻 Accès à la Console
1. 🖥️ Ouvrir ADUC via :
   - ⚙️ `Gestionnaire de serveur`
   - 🔧 `Outils`
   - 👤 `Utilisateurs et ordinateurs AD`

#### ➕ Assistant de Création
1. 📂 Clic droit sur `Users`
2. ➕ `Nouveau` > `Utilisateur`

#### 📝 Informations de Base
- 👤 Prénom : Clark
- 👤 Nom : Kent
- 🌐 Login : clark.kent
- 📧 UPN : clark.kent@computerelectronics.be


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

### 3.4. Informations Essentielles

#### **Onglet Général** :

   - Description : Comptable Senior 
   - Service Comptabilité
   - Bureau : Bâtiment A - 2e étage
   - Téléphone : +32 2 123 45 67

> 💡 Ces informations sont essentielles pour la gestion des services (messagerie, ressources, etc.)

#### 🔑 Paramètres du Compte

##### Heures d'accès
- Par défaut : 24/7
- Restriction : 7h-19h (semaine)

##### Postes de travail
- Défaut : Tous les postes
- Exemple : `ws-compta-01, ws-compta-02`

### Profils utilisateurs

#### Types de profils
```plaintext
Local     : C:\Users\username
Itinérant : \\srv-profiles\profiles\%username%
Exemple   : \\srv-profiles\profiles\clark.kent
```
   > **Note** : Par défaut, ce champ est vide car Windows crée automatiquement des profils locaux (C:\Users\username). 
   > On ne le configure que si on veut implémenter des **profils itinérants** (roaming profiles) qui suivent l'utilisateur d'un poste à l'autre.
      
   **Attention** : Les profils itinérants peuvent :
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
     ```plaintext
     \\srv-scripts\dept\compta\logon.bat
     ```

#### Recommandations
- Attention aux profils itinérants
- Préférer les profils locaux
- Sécuriser les comptes sensibles

## 4. Gestion des Groupes

### Concepts Fondamentaux

> Un groupe du domaine AD est un conteneur pour gérer :
- Utilisateurs
- Ordinateurs (c'est possible aussi!)
- Autres groupes


### Types de groupe: les groupes de sécurité

Il y a deux types de groupes : **groupes de sécurité** (qui gèrent les privilèges) et **groupes de distribution** (qui sont liés uniquement à l'envoi d'emails).

On utilisera uniquement des groupes de sécurité.

##### 📄 Exemples
```plaintext
DL-EU-Comptabilite-Lecture  # Lecture comptable
GG-EU-RH-Admin             # Admin RH
GG-EU-Support              # Support IT
```


### 🌐 Types des Groupes selon son étendue

Les groupes se classifient en 3 étendues: **Domaine Local**, **Global** et Universel.
Nous utiliserons que les deux premiers types.

Format standard pour les groupes :
```plaintext
[Type etendue]-[Location]-[Service]-[Fonction]
DL-EU-Comptabilite-Lecture  # Lecture comptable
GG-EU-RH-Admin             # Admin RH
GG-EU-Support              # Support IT
```

#### 🌍 Domaine Local (DL-)

##### 💡 Caractéristiques
- Servent à attribuer des droits (ex: `Admin`, `Lecture`, `Modif`)
- Limité **au domaine AD actuel** (`computerelectronics.be` dans notre cas)
- Gestion des ressources

##### 📄 Exemples
```plaintext
DL-EU-Serveurs-Admin      # Admin
DL-EU-Comptabilite-Lecture # Lecture
DL-EU-RH-Modif           # Modif
```

#### 🌎 Global (GG-)

##### 💡 Caractéristiques
- Servent à structurer l'entreprise (ex: groupes pour les `Comptables`, `Managers`, `Support`)
- Visible dans toute la forêt AD
- Regroupe par rôle

##### 📄 Exemples
```plaintext
GG-EU-Comptabilite-Users  # Comptables
GG-EU-RH-Managers        # Managers
GG-EU-IT-Support        # Support
```

**IMPORTANT**: Ces fonctions des groupes ont lieu dans le contexte d'une grande entreprise, mais dans notre labo ce seront les groupes globaux qui recevront les droits pour ne pas créer une couche en plus. On verra ça plus tard, dans la strategie AGDP.



#### 🌏 Universel (U-)

##### 💡 Caractéristiques
- Accès **multi-forêts**
- Impact réplication
- Usage restreint

##### 📄 Exemples
```plaintext
U-Direction              # Direction générale
U-Projet-Global          # Projets multi-sites
U-Admin-Global           # Administration globale
```

## 5. Comment est-qu'on donne des droits aux utilisateurs ?

La **regle d'or** est de ne jamais attribuer de droits (ex: acceder à un dossier partagé, changer son mot de passe) directement aux utilisateurs. Alors on donnera les droits aux **groupes**.

#### Exemple pratique

Ceci est un exemple de test pour comprendre le fonctionnement de base des permissions.

Nous allons créer un dossier partagé `IT-docs` sur le serveur (`C:\Partage-IT`. Son chemin de réseau sera `\\dns2\Partage-IT`).

**Nous devons choisir maintenant qui aura accès à ce dossier (qui aura le **droit**  d'accès) et avec quels **permissions** (modifier, lire, créer de fichiers à l'intérieur, etc.)**

Pour cela nous sommes obligés de **comprendre les deux niveaux de permissions**.

## 5.1. Les deux niveaux des sécurité


#### Exemple concret
Sur le serveur `dns1.computerelectronics.be` (`192.168.0.2`), nous allons configurer un partage pour le département IT. Le poste `ws-IT-01`  aura accès à ce partage.


#### Permissions et droits de partage (réseau)
**Objectif** : Contrôle **d'accès au dossier partagé** (qui à le droit d'accéder au dossier partagé et avec quels permissions-autorisations - lecture, écriture, controle total)

**Caractéristiques** :
- S'appliquent uniquement lors de l'accès réseau
- Offrent trois niveaux simples :
  * Lecture
  * Modification
  * Contrôle total
- Constituent la **première barrière de sécurité**

**Exemple pratique** :
```
Partage : \\serveur\IT$
Permission : Modification pour le groupe 'GG-IT-Users'
Effet : Les utilisateurs de l'IT peuvent modifier les fichiers via le réseau
```

> **Note importante** : La sécurité finale est **déterminée par l'intersection des deux types de permissions**. L'**utilisateur obtient toujours le niveau de permission le plus restrictif entre NTFS (ci-dessous) et partage**. Par exemple, si un utilisateur a un accès en Modification au niveau du partage mais en Lecture seule au niveau NTFS, il ne pourra que lire les fichiers.


#### Permissions NTFS (système de fichiers)
**Objectif** : Contrôle d'accès **au niveau du système de fichiers**, pas du réseau

**Caractéristiques** :
- S'appliquent localement sur le serveur
- Offrent un **contrôle granulaire** (fin) des accès
- Restent actives même en accès local
- Permettent des permissions spécifiques (ex: Lecture, Écriture, Exécution)

**Exemple pratique** :
```
Dossier : D:\IT\Doc-Reseau
Permission : Lecture seule pour le groupe 'GG-EU-IT-stagiaires'
Effet : Les stagiaires de l'IT peuvent lire mais pas modifier les documents du dossier
```
#### Accumulation des Droits :
- Un utilisateur hérite des droits de tous ses groupes
- Les droits sont **cumulatifs**, **on ne peut pas les retirer**
- L'appartenance à des groupes privilégiés (comme `Domain Admins`) étend les droits


<br>



## Règles d'Imbrication

Limitations par type de groupe :

```plaintext
Groupe Global :
- Peut contenir : Groupes globaux du même domaine AD

Groupe Local de Domaine :
- Ne peut pas contenir : Groupes globaux d'autres domaines

Groupe Universel :
- Ne peut pas contenir : Groupes globaux d'autres domaines
```

## Sécurité et Maintenance

Règles fondamentales par type de groupe :

```plaintext
Groupes Globaux (GG-) :
- Utilisés pour la gestion des utilisateurs
- Ne doivent pas recevoir de permissions directes
Exemple : GG-EU-RH-Managers

Groupes Locaux de Domaine (DL-) :
- Reçoivent les permissions sur les ressources
- Contiennent les groupes globaux appropriés
Exemple : DL-EU-RH-Modif
```


## 7. Groupes Intégrés AD

### 7.1 Groupes Essentiels

Active Directory inclut trois groupes intégrés essentiels :

#### Domain Admins
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

### 7.2 Groupes de Sécurité

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


## 8. Organisation des Groupes

> 💡 Deux stratégies principales :

#### 🏢 Structure par Département
```plaintext
📂 DL-EU-Dossier-Partage-RW
  ├─ 💳 GG-EU-Compta-Users  # Comptabilité
  ├─ 💰 GG-EU-Ventes-Users  # Ventes
  └─ 👥 GG-EU-RH-Users     # RH
```

#### 💼 Structure par Fonction
```plaintext
📂 DL-EU-Dossier-Partage-RW
  ├─ 👑 GG-EU-Managers   # Direction
  └─ 👤 GG-EU-Employees  # Personnel
```














