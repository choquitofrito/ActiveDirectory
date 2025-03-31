# Chapitre 5 : Gestion des Utilisateurs

> 📚 **Dans ce chapitre:**
> 1. 👤 [Comptes Utilisateurs](#1-introduction-aux-comptes-utilisateurs)
>    - Concepts fondamentaux
>    - Standards de nommage
> 2. 💻 [Gestion avec ADUC](#2-utilisateurs-et-ordinateurs-active-directory)
>    - Création et configuration
>    - Recherche et modification
> 3. 👥 [Groupes et Stratégies](#5-gestion-des-groupes)
>    - Types de groupes
>    - AGDLP vs AGLP

---

## 📙 Objectifs Pédagogiques

À la fin de ce chapitre, vous serez capable de :
1. Créer et gérer des comptes utilisateurs
2. Appliquer les standards de nommage
3. Implémenter les stratégies de groupes AGDLP/AGLP
4. Gérer efficacement les droits et permissions

---

## 1. Introduction aux Comptes Utilisateurs

### 1.1. Concepts Fondamentaux

Un compte utilisateur Active Directory **représente une identité numérique unique** dans l'infrastructure `computerelectronics.be`. Cette identité permet de :

- **Identifier** l'utilisateur de manière unique (ex: `sophie.lambert` du service RH)
- **Contrôler** l'accès aux ressources (dossiers, applications, imprimantes)
- **Stocker** les informations de l'utilisateur (département, rôle, etc.)

**Exemple pratique** : Connexion de Sophie Lambert

1. Utilisation du compte pour se connecter au poste de travail
2. Vérification de l'identité et des droits par le système
3. Accès automatique aux ressources autorisées

**Le compte utilisateur est** :
- Le **point d'accès principal** aux ressources du domaine
- Un élément de la **structure de sécurité** de l'entreprise
- Un **composant critique** de la gestion des identités

### 1.2. Standards de Nommage

#### Convention de Nommage (SamAccountName)

Le **SamAccountName** est l'identifiant unique de l'utilisateur dans le domaine. Pour garantir l'uniformité et éviter les conflits, nous suivons une convention standardisée.

**Format standard** : `prenom.nom`

**Exemples** :
```plaintext
clark.kent              # Comptabilité
sophie.lambert          # RH
jean.martin.compta      # Comptabilité (cas d'homonymie)
jean.martin.rh          # RH (cas d'homonymie)
jean.martin.compta.fr   # Comptabilité France
jean.martin.compta.be   # Comptabilité Belgique
```

**Règles de nommage** :
- Uniquement en minuscules
- Pas de caractères spéciaux sauf le point
- En cas d'homonymes :
  1. Ajouter le département (`.compta`, `.rh`)
  2. Si nécessaire, ajouter un identifiant :
     - Localisation (`.fr`, `.be`)
     - Fonction (`.senior`, `.junior`)
     - Site (`.bxl`, `.anvers`)
- Ne jamais utiliser de chiffres


### 1.3. UPN (User Principal Name)

L'UPN est un format de connexion similaire à une adresse email, **unique dans toute la forêt AD**.

**Structure** :
```plaintext
Format  : login@domaine
Exemple : clark.kent@computerelectronics.be
```

**Comparaison des formats** :
```plaintext
Ancien : COMPUTERELECTRONICS\clark.kent
Nouveau : clark.kent@computerelectronics.be
```

**Avantages** :
- **Unicité** : Garantie dans toute la forêt AD
- **Simplicité** : Format familier type email
- **Standardisation** : Domaine principal `computerelectronics.be`


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

#### Profil Utilisateur (Onglet Profil)

**Chemin du profil** :
```plaintext
Local    : C:\Users\username
Itinérant : \\srv-profiles\profiles\%username%
Exemple  : \\srv-profiles\profiles\clark.kent
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

**Points d'attention** :
- Les profils itinérants peuvent impacter les performances
- Privilégier les profils locaux par défaut
- Restreindre les heures/postes pour les comptes sensibles



## 4. Bonnes Pratiques de Gestion

### 4.1. Sécurité des Comptes

**Politique de mot de passe** :
```plaintext
Longueur   : 12 caractères minimum
Complexité : Maj + Min + Chiffres + Symboles
Validité   : 90 jours maximum
Historique : 24 derniers mots de passe
```

**Surveillance** :
```plaintext
Mensuel    : Vérification des comptes inactifs
Trimestriel : Audit des privilèges élevés
Continu    : Alertes de connexions suspectes
```

### 4.2. Cycle de Vie des Comptes

**Gestion des départs** :
```plaintext
1. Désactivation immédiate du compte
2. Conservation temporaire des données
3. Suppression après période de rétention
```

**Important** :
- Privilégier la désactivation à la suppression
- Documenter toute suppression définitive
- Maintenir un historique des actions

## 5. Gestion des Groupes

### 5.1. Concepts de Base

**Définition** : Un groupe AD est un conteneur pour gérer collectivement :
- Utilisateurs
- Ordinateurs
- Autres groupes

**Principe du moindre privilège** :
```plaintext
1. Permissions -> Groupes (jamais aux utilisateurs)
2. Groupes -> Permissions minimales nécessaires
3. Contrôle via groupes imbriqués (AGDLP/AGLP)
```

### 5.2. Types de Groupes

#### Groupes de Sécurité

**Objectif** : Gestion des droits d'accès

**Exemples** :
```plaintext
DL-EU-Comptabilite-Lecture  # Lecture dossiers comptables
GG-EU-RH-Admin             # Administration RH
GG-EU-Support              # Support technique
```

#### Groupes de Distribution

**Objectif** : Listes de diffusion email

**Exemples** :
```plaintext
DL-EU-Info                 # Diffusion générale
DL-EU-Comptabilite-Contact # Contacts comptabilité
DL-EU-RH-Managers         # Managers RH
```

**Important** : Les groupes de distribution ne gèrent pas les permissions

### 5.3. Étendues de Groupe

#### Domaine Local (DL-)

**Caractéristiques** :
- Attribution finale des droits
- Limité au domaine `computerelectronics.be`
- Utilisé pour les permissions sur ressources

**Exemples** :
```plaintext
DL-EU-Serveurs-Admin      # Admin serveurs
DL-EU-Comptabilite-Lecture # Lecture comptabilité
DL-EU-RH-Modif           # Modification RH
```

#### Global (GG-)

**Caractéristiques** :
- Organisation par fonction métier
- Créé dans un domaine, visible dans la forêt
- Regroupe les utilisateurs par rôle

**Exemples** :
```plaintext
GG-EU-Comptabilite-Users  # Comptables
GG-EU-RH-Managers        # Managers RH
GG-EU-IT-Support        # Support IT
```

#### Universel (U-)

**Caractéristiques** :
- Accessible dans toutes les forêts
- Impact sur la réplication AD
- Utilisation limitée

**Exemples** :
```plaintext
U-Direction              # Direction générale
U-Projet-Global          # Projets multi-domaines
U-Admin-Global           # Administration globale
```

**Convention de nommage** :
```plaintext
Format : [Etendue]-[Location]-[Département]-[Fonction]
Exemples:
- DL-EU-Comptabilite-Modif
- GG-EU-RH-Users
- U-Global-Admin
```

### 5.3. Création et Gestion des Groupes


#### Via l'Interface Graphique

1. **Création d'un groupe**
   ```
   - Ouvrir Console d'administration d'AD
   - Naviguer vers Users
   - Clic droit > Nouveau > Groupe
   - Remplir les informations :
      - Nom : GG-EU-Comptabilite-Users
      - Étendue : Global
      - Type : Sécurité
```

#### Gestion des Membres

**Ajout d'utilisateurs** :
```plaintext
1. Groupe -> Double-clic
2. Onglet Membres -> Ajouter
3. Sélectionner utilisateurs :
   - clark.kent
   - sophie.lambert
   - Vérifier les membres ajoutés
```
Vérifiez toujours la liste des membres après les modifications


### 5.4. Convention de Nommage

**Format standard** :
```plaintext
[Type]-[Location]-[Service]-[Fonction]
```

**Exemples** :
```plaintext
GG-EU-Comptabilite-Users  # Comptables EU
DL-EU-RH-Lecture         # Lecture RH
U-Global-IT-Admin        # Admin IT global
```

### 5.5. Stratégie AGDLP

**Principe** : Ne jamais attribuer de droits directement aux utilisateurs

**Hiérarchie** :
```plaintext
A  -> Account  (Utilisateur)
G  -> Global   (Fonction)
DL -> Local    (Droits)
P  -> Permissions
```

**Exemple** : Gestion de projet ERP

> Pour des exemples détaillés d'implémentation AGDLP dans différents contextes, voir le [Chapitre 4 - Unités Organisationnelles, section 9.2](Chapitre%204.%20Unites_Organisationelles.md#92-utilisation-des-groupes).

**Avantages** :

1. **Changement de département** :
   ```plaintext
   - Retirer de GG-EU-RH-Managers
   - Ajouter à GG-EU-Compta-Managers
   - Droits automatiquement mis à jour
   ```

2. **Nouvel employé** :
   ```plaintext
   - Ajouter à GG-EU-[Dept]-Users
   - Hérite auto des droits DL-EU-[Dept]-*
   ```

3. **Maintenance** :
   ```plaintext
   - Structure claire
   - Moins d'erreurs
   - Évolutivité
   ```

### 5.6. Règles d'Imbrication

**Limitations** :
```plaintext
Groupe Global :
- Peut contenir : Globaux (même domaine)

Groupe Local :
- Ne peut pas contenir : Globaux (autre domaine)

Groupe Universel :
- Ne peut pas contenir : Globaux (autre domaine)
```

### 5.7 Sécurité et Maintenance

**Règles de base** :
```plaintext
Groupes Globaux (GG-) :
- Groupes de gestion uniquement
- Pas de permissions directes
Exemple : GG-EU-RH-Managers

Groupes Locaux (DL-) :
- Reçoivent les permissions
- Contiennent les groupes globaux
Exemple : DL-EU-RH-Modif
```

## 6. Droits vs Permissions

### Droits Utilisateur

**Définition** : Actions système autorisées

**Caractéristiques** :
```plaintext
Portée : Niveau système
Gestion : Via GPO
Exemples :
- Se connecter localement
- Arrêter le système
- Changer mot de passe
- Exécuter les backups
```

### Permissions

**Définition** : Contrôle d'accès aux ressources

**Caractéristiques** :
```plaintext
Portée : Niveau objet
Gestion : Via ACL
Objets :
- Fichiers
- Dossiers
- Imprimantes

Actions :
- Lecture
- Écriture
- Modification
```

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
DL-EU-Dossier-Partage-RW
  ├─ GG-EU-Compta-Users <-- groupe global pour les users de Comptabilité
  ├─ GG-EU-Ventes-Users <-- groupe global pour les users de Ventes
  └─ GG-EU-RH-Users <-- groupe global pour les users de RH
```

#### Structure par Fonction
```plaintext
DL-EU-Dossier-Partage-RW
  ├─ GG-EU-Managers
  └─ GG-EU-Employees
```














