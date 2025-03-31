# 👤 Chapitre 5 : Gestion des Utilisateurs

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
1. 👤 Gérer les identités utilisateurs
2. 📝 Appliquer les standards de nommage
3. 🔐 Implémenter les stratégies de sécurité
4. ⚙️ Administrer les droits d'accès

---

## 1. 👤 Identités Numériques

### 💻 Concepts Fondamentaux

Un compte utilisateur Active Directory représente une **identité numérique unique** dans `computerelectronics.be` permettant :

- 🌐 **Identification** unique (ex: `sophie.lambert`)
- 🔐 **Contrôle d'accès** aux ressources
- 📂 **Gestion des informations** utilisateur

> 💡 **Exemple** : Connexion de Sophie Lambert

1. 💻 Connexion au poste de travail
2. 🔑 Vérification des identifiants
3. 🔓 Accès aux ressources autorisées

**Rôles du compte** :
- 🔑 **Point d'accès** au domaine
- 🔒 **Élément de sécurité**
- ⚙️ **Composant de gestion**

### 📝 Standards de Nommage

#### 🌐 Convention SamAccountName

> 📝 Le **SamAccountName** est l'identifiant unique de l'utilisateur dans le domaine.

### 🌐 Format Standard

```plaintext
prenom.nom  # Format de base
```

### 💡 Exemples d'Identifiants

```plaintext
💰 clark.kent              # Comptabilité
👥 sophie.lambert          # RH
💰 jean.martin.compta      # Comptabilité
👥 jean.martin.rh          # RH
🇫🇷 jean.martin.compta.fr   # France
🇧🇪 jean.martin.compta.be   # Belgique
```

### ⚙️ Règles de Nommage

- 🖊️ Minuscules uniquement
- ❗️ Point comme seul caractère spécial
- 🔍 En cas d'homonymes :
  1. 🏢 Ajout du département (`.compta`, `.rh`)
  2. 📍 Ajout d'identifiants :
     - 🌐 Pays (`.fr`, `.be`)
     - 💼 Fonction (`.senior`, `.junior`)
     - 🏢 Site (`.bxl`, `.anvers`)
- ❌ Pas de chiffres

### 💻 UPN (User Principal Name)

> 💡 Format de connexion type email, unique dans la forêt AD

#### 📝 Structure
```plaintext
📧 Format  : login@domaine
👤 Exemple : clark.kent@computerelectronics.be
```

#### 🔄 Évolution des Formats
```plaintext
🗘️ Ancien  : COMPUTERELECTRONICS\clark.kent
✨ Nouveau : clark.kent@computerelectronics.be
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


## 3. 👤 Gestion des Comptes

### ➕ Création de Compte

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

### Informations Essentielles

#### **Onglet Général** :

   - Description : Comptable Senior 
   - Service Comptabilité
   - Bureau : Bâtiment A - 2e étage
   - Téléphone : +32 2 123 45 67

> 💡 Ces informations sont essentielles pour la gestion des services (messagerie, ressources, etc.)

#### 🔑 Paramètres du Compte

##### 🕐 Heures d'Accès
- 🔓 Par défaut : 24/7
- 🔒 Restriction : 7h-19h (semaine)

##### 💻 Postes de Travail
- 🔓 Défaut : Tous les postes
- 🔒 Exemple : `ws-compta-01, ws-compta-02`

### 💻 Profils Utilisateurs

#### 📂 Types de Profils
```plaintext
💻 Local     : C:\Users\username
🔄 Itinérant : \\srv-profiles\profiles\%username%
💡 Exemple   : \\srv-profiles\profiles\clark.kent
```
   > ℹ️ **Note**: Par défaut, ce champ est vide car Windows crée automatiquement des profils locaux (C:\Users\username). 
   > On ne le configure que si on veut implémenter des **profils itinérants** (roaming profiles) qui suivent l'utilisateur d'un poste à l'autre.
      
   ⚠️ **Attention**: Les profils itinérants peuvent :
   - ⏳ Ralentir les connexions (synchronisation du profil)
   - 💾 Consommer beaucoup d'espace disque sur le serveur
   - 🔗 Augmenter le trafic réseau
     
   📁 **Un profil utilisateur contient** :
   - 📂 **Documents personnels** : Mes Documents, Bureau, Téléchargements
   - ⚙️ **Paramètres Windows** : Fond d'écran, thème, barre des tâches
   - 💻 **Paramètres d'applications** : Configurations Outlook, navigateur
   - 🔑 **Clés de registre** : HKEY_CURRENT_USER
   - 📂 **AppData** : Données des applications
     * 💻 `\AppData\Local` : Données spécifiques à la machine (cache, temp)
     * 🔄 `\AppData\Roaming` : Données qui suivent l'utilisateur entre les machines
   - 💻 **Script de connexion** : Si on veut lancer une suite d'opérations lors de la connexion 
     ```plaintext
     📚 \\srv-scripts\dept\compta\logon.bat
     ```

#### ⚙️ Recommandations
- ⚠️ Attention aux profils itinérants
- 💻 Préférer les profils locaux
- 🔒 Sécuriser les comptes sensibles



## 4. ⚙️ Bonnes Pratiques

### 🔐 Sécurité des Comptes

#### 🔑 Politique de Mots de Passe
```plaintext
💾 Longueur   : 12 caractères minimum
🔒 Complexité : Maj + Min + Chiffres + Symboles
🕐 Validité   : 90 jours maximum
📃 Historique : 24 derniers mots de passe
```

#### 🔍 Surveillance
```plaintext
📅 Mensuel     : Vérification des comptes
📆 Trimestriel : Audit des privilèges
⏰ Continu     : Alertes de connexion
```

### 🔄 Cycle de Vie

#### 📄 Gestion des Départs
```plaintext
1. 🔒 Désactivation du compte
2. 💾 Conservation des données
3. 🗑 Suppression planifiée
```

#### ⚠️ Points Importants
- 🔐 Préférer la désactivation
- 📝 Documenter les suppressions
- 📃 Conserver l'historique

## 5. 👥 Gestion des Groupes

### 📂 Concepts Fondamentaux

> 💡 Un groupe AD est un conteneur pour gérer :
- 👤 Utilisateurs
- 💻 Ordinateurs
- 📂 Autres groupes

#### 🔐 Principe du Moindre Privilège
```plaintext
🔐 1. Permissions → Groupes (jamais aux utilisateurs)
📂 2. Groupes → Permissions minimales
🔗 3. Contrôle via groupes imbriqués (AGDLP/AGLP)
```

### 📂 Types de Groupes

#### 🔐 Groupes de Sécurité

> 💡 **Objectif** : Gestion des droits d'accès

##### 📄 Exemples
```plaintext
📂 DL-EU-Comptabilite-Lecture  # Lecture comptable
🔑 GG-EU-RH-Admin             # Admin RH
🔧 GG-EU-Support              # Support IT
```

#### 📧 Groupes de Distribution

> 💡 **Objectif** : Listes de diffusion email

##### 📄 Exemples
```plaintext
💬 DL-EU-Info                 # Info générale
💳 DL-EU-Comptabilite-Contact # Contacts
👑 DL-EU-RH-Managers         # Managers
```

> ⚠️ Les groupes de distribution ne gèrent pas les permissions

### 🌐 Étendues des Groupes

#### 🌍 Domaine Local (DL-)

##### 💡 Caractéristiques
- 🔑 Attribution des droits
- 🌐 Limité au domaine actuel
- 📂 Gestion des ressources

##### 📄 Exemples
```plaintext
🔑 DL-EU-Serveurs-Admin      # Admin
📂 DL-EU-Comptabilite-Lecture # Lecture
🔧 DL-EU-RH-Modif           # Modif
```

#### 🌎 Global (GG-)

##### 💡 Caractéristiques
- 🌐 Organisation métier
- 🌎 Visible dans la forêt
- 👥 Regroupe par rôle

##### 📄 Exemples
```plaintext
💳 GG-EU-Comptabilite-Users  # Comptables
👑 GG-EU-RH-Managers        # Managers
🔧 GG-EU-IT-Support        # Support
```

#### 🌏 Universel (U-)

##### 💡 Caractéristiques
- 🌐 Accès multi-forêts
- 🔄 Impact réplication
- ⚠️ Usage restreint

##### 📄 Exemples
```plaintext
👑 U-Direction              # Direction
📂 U-Projet-Global          # Projets
🔑 U-Admin-Global           # Admin
```

#### 📝 Convention de Nommage
```plaintext
💡 Format : [Etendue]-[Location]-[Département]-[Fonction]

📄 Exemples:
- 📂 DL-EU-Comptabilite-Modif
- 👥 GG-EU-RH-Users
- 🔑 U-Global-Admin
```

### ➕ Création des Groupes

#### 💻 Via l'Interface ADUC

##### ➕ Nouveau Groupe
```plaintext
1. 💻 Ouvrir ADUC
2. 📂 Aller dans Users
3. ➕ Clic droit > Nouveau > Groupe
4. 📝 Informations :
   - 📄 Nom : GG-EU-Comptabilite-Users
   - 🌐 Étendue : Global
   - 🔐 Type : Sécurité
```

#### 👥 Gestion des Membres

##### ➕ Ajout d'Utilisateurs
```plaintext
1. 📂 Groupe → Double-clic
2. 👥 Onglet Membres → Ajouter
3. ➕ Sélectionner :
   - 👤 clark.kent
   - 👤 sophie.lambert
   - ✅ Vérifier les ajouts
```

> ⚠️ Vérifiez toujours la liste après modification

### 📝 Conventions de Nommage

#### 💡 Format Standard
```plaintext
📂 [Type]-[Location]-[Service]-[Fonction]
```

#### 📄 Exemples
```plaintext
👥 GG-EU-Comptabilite-Users  # Comptables
📂 DL-EU-RH-Lecture         # Lecture RH
🔑 U-Global-IT-Admin        # Admin IT
```

### 🔗 Stratégie AGDLP

> 💡 **Principe** : Jamais de droits directs aux utilisateurs

#### 📂 Hiérarchie
```plaintext
👤 A  → Account     (Utilisateur)
🌐 G  → Global      (Fonction)
📂 DL → Local       (Droits)
🔐 P  → Permissions
```

#### 💻 Exemple ERP

> 📚 Pour plus de détails, voir [Chapitre 4 - UO, section 9.2](Chapitre%204.%20Unites_Organisationelles.md#92-utilisation-des-groupes)

#### ⭐ Avantages

##### 🔄 Changement de Service
```plaintext
➖ Retirer de GG-EU-RH-Managers
➕ Ajouter à GG-EU-Compta-Managers
   - Droits automatiquement mis à jour
   ```

2. **Nouvel employé** :
   ```plaintext
   - Ajouter à GG-EU-[Dept]-Users
   - Hérite auto des droits DL-EU-[Dept]-*
   ```

#### 🔧 Maintenance
```plaintext
📂 Structure claire
✅ Moins d'erreurs
📈 Évolutivité
```

### 🔗 Règles d'Imbrication

#### ⚠️ Limitations
```plaintext
🌐 Groupe Global :
- ✅ Peut : Globaux (même domaine)

🌍 Groupe Local :
- ❌ Non : Globaux (autre domaine)

🌏 Groupe Universel :
- ❌ Non : Globaux (autre domaine)
```

### 🔐 Sécurité et Maintenance

#### 💡 Règles de Base
```plaintext
🌐 Groupes Globaux (GG-) :
- 👥 Groupes de gestion uniquement
- ❌ Pas de permissions directes
💡 Ex: GG-EU-RH-Managers

🌍 Groupes Locaux (DL-) :
- 🔑 Reçoivent les permissions
- 🔗 Contiennent les groupes globaux
💡 Ex: DL-EU-RH-Modif
```

## 6. 🔑 Droits vs Permissions

### 🔐 Droits Utilisateur

> 💡 **Définition** : Actions système autorisées

#### ⚙️ Caractéristiques
```plaintext
🌐 Portée : Niveau système
⚙️ Gestion : Via GPO
💡 Exemples :
- 🔓 Se connecter localement
- ⏰ Arrêter le système
- 🔑 Changer mot de passe
- 💾 Exécuter les backups
```

### 🔐 Permissions

> 💡 **Définition** : Contrôle d'accès aux ressources

#### ⚙️ Caractéristiques
```plaintext
🌐 Portée : Niveau objet
🔐 Gestion : Via ACL
📂 Objets :
- 📄 Fichiers
- 📂 Dossiers
- 🖨 Imprimantes

🔑 Actions :
- 📖 Lecture
- ✏️ Écriture
- 🔧 Modification
```

### 🔑 Droits par Défaut

#### 👤 Utilisateur Standard

- 🔓 Se connecter localement
- ⏰ Arrêter le système
- 🔑 Changer le mot de passe
- 🔧 Tâches de maintenance

#### 🔗 Accumulation des Droits
- 💡 Un **utilisateur accumule les droits des groupes auxquels il appartient**
- ⚠️ On **ne dénie** pas de droits utilisateur 
- 🔑 L'appartenance à des groupes privilégiés augmente les droits (ex: `Domain Admins`)

<br>

## 7. 📂 Groupes Intégrés AD

### 7.1 👥 Groupes Essentiels

> 💡 Il existe 3 groupes intégrés essentiels dans Active Directory :

#### 🔐 Domain Admins
- 👑 Administrateurs du domaine
- 🔓 Accès total aux ressources
- 👥 Membres du groupe Administrators

##### 💻 Actions Principales
- ⚙️ Création des contrôleurs de domaine
- 🔐 Modification des stratégies de sécurité

#### 🌍 Enterprise Admins
- 🌐 Administration de la forêt
- 🔗 Relations d'approbation
- ⚙️ Configuration des sites

##### 💻 Actions Principales
- 📂 Ajout de domaines dans la forêt
- 🌐 Configuration des sites AD

#### 📚 Schema Admins
- 📂 Modification du **schéma** AD
- 🔐 Groupe très sensible
- ⚠️ Usage restreint

##### 💻 Actions Principales
- 📂 Ajout d'attributs utilisateurs
- 💻 Extension pour Exchange Server

### 7.2 🔐 Groupes de Sécurité

#### 👤 Account Operators
- 📂 Création de comptes
- 👥 Gestion des groupes
- ⚠️ Pas d'accès admin

##### 💻 Actions Principales
- 👤 Création de comptes
- 👥 Ajout aux groupes

#### 💾 Backup Operators
- 💾 Sauvegarde des fichiers
- 🔐 Accès NTFS étendu
- 📖 Lecture domaine

##### 💻 Actions Principales
- 💾 Sauvegarde des serveurs
- 💾 Restauration de données


## 8. 📂 Organisation des Groupes

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














