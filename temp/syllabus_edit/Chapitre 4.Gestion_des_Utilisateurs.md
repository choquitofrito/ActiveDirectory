# 4. Gestion des Utilisateurs et Groupes dans Active Directory

## 1. Introduction aux Comptes Utilisateurs

### 1.1 Concepts Fondamentaux

Un compte utilisateur Active Directory **représente une identité numérique unique** dans l'infrastructure `computerelectronics.be`. Imaginez-le comme un badge d'entreprise qui :

- **Identifie** l'utilisateur de manière unique (comme Sophie Lambert du service RH)
- **Contrôle** l'accès aux ressources (comme l'ouverture de certaines portes)
- **Stocke** des informations sur l'utilisateur (comme son département, son rôle)

Par exemple, quand Sophie arrive au bureau :
1. Elle utilise son compte pour se connecter à son poste de travail
2. Le système vérifie son identité et ses droits
3. Elle accède automatiquement à ses dossiers et applications

Le compte utilisateur constitue ainsi :
- Le **point d'accès principal** aux ressources du domaine (ordinateurs, fichiers, imprimantes)
- Un élément de la **structure de sécurité** de l'entreprise (qui peut accéder à quoi)
- Une **composante critique** de la gestion des identités (qui est qui dans l'organisation)

### 1.2 Standards de Nommage

#### Convention de Nommage Officielle
Pour garantir l'uniformité et éviter les conflits, nous utilisons une convention de nommage standardisée :

- Format : `prenom.nom`
- Exemples :
  ```
  clark.kent        # Pour Clark Kent du service Comptabilité
  sophie.lambert    # Pour Sophie Lambert du service RH
  jean.martin2      # Si deux Jean Martin dans l'entreprise
  ```

- **Règles** :
  - Uniquement en minuscules (pour éviter les erreurs de frappe)
  - Pas de caractères spéciaux sauf le point (pour la compatibilité)
  - Pas de chiffres sauf si nécessaire pour différencier (cas des homonymes)

#### UPN (User Principal Name)

L'UPN est un format de connexion similaire à une adresse email, plus facile à retenir que l'ancien format DOMAIN\nom. 

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

> **Important** : Dans notre infrastructure, nous n'utilisons pas les sous-domaines (eu/us) dans l'UPN pour maintenir la cohérence et simplifier la gestion.


# 2. Utilisateurs et Ordinateurs Active Directory (ADUC)

Le **"Utilisateurs et Ordinateurs Active Directory"** (**ADUC**) est une console de gestion permettant de gérer les **utilisateurs, groupes, ordinateurs et unités d'organisation (OU)** dans un domaine Active Directory (AD).

Vous pouvez l'ouvrir de plusieur formes: tapez `Utilisateurs et ordinateurs Active Directory` depuis le menu Démarrer ou via `dsa.msc`... ou via `Gestionnaire de serveur`->`Outils`->`Utilisateurs et ordinateurs Active Directory`.

C'est la méthode traditionnelle, mais il y a aussi la **méthode moderne via l'interface web de l'AD** (`Gestionnaire de serveur`->`Outils`->`Centre d'administration d'AD`).

Dans les deux outils

- **Structure du domaine (hiérarchie des OU)** : Affiche les OU (containers d'objets, on les verra plus tard).
-
 **Objets du domaine** , entre autres :
  - **Utilisateurs** : Comptes des utilisateurs du domaine et leurs propriétés.
  - **Ordinateurs** : Machines jointes au domaine.
  - **Contrôleurs de domaine** : Liste des DC du domaine.

Par défaut, il y a plusieurs **conteneurs** (ce ne sont pas des OU, mais des conteneurs d'objets) :
 :
  - `Builtin` : Contient les groupes de sécurité par défaut (Administrateurs, Utilisateurs, etc.).
  - `Computers` : Emplacement par défaut des nouveaux ordinateurs ajoutés au domaine.
  - `Users` : Emplacement des nouveaux utilisateurs et groupes.
  - `Domain Controllers` : Contient tous les contrôleurs de domaine (on en a qu'un!)

- **Outils de recherche et de filtrage** : Permettent de trouver rapidement des utilisateurs, ordinateurs ou groupes.

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

1. **Accès à ADUC** :
   - Ouvrir `Utilisateurs et ordinateurs Active Directory` depuis le menu Démarrer ou via `dsa.msc`... ou via `Gestionnaire de serveur`->'Outils'->'Utilisateurs et ordinateurs Active Directory'

   - Naviguer vers l'OU appropriée (par exemple `OU=RH` pour un nouvel employé RH)

2. **Création du compte** :
   ```
   Clic droit sur l'OU > Nouveau > Utilisateur
   # L'assistant de création s'ouvre
   ```

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

Voici comment procéder :

1. **Accès à ADUC** :
   - Ouvrir `Utilisateurs et ordinateurs Active Directory` depuis le menu Démarrer ou via `dsa.msc`
   - Naviguer vers l'OU appropriée (par exemple `OU=RH` pour un employé RH)

2. **Recherche du compte** :
   


### 2.3. Modification des Propriétés

Après la création du compte, il est important de configurer les propriétés supplémentaires pour une bonne gestion :

#### Informations Essentielles

1. **Onglet Général** :
   ```
   Description : Comptable Senior - Service Comptabilité
   Bureau : Bâtiment A - 2e étage
   Téléphone : +32 2 123 45 67
   ```
   > Ces informations facilitent l'identification et la localisation de l'utilisateur

2. **Onglet Compte** :
   - **Heures de connexion** :
     * Par défaut : accès 24/7
     * Exemple restriction : 7h-19h en semaine
   - **Stations de travail** :
     * Par défaut : toutes les machines
     * Exemple restriction : `ws-compta-01, ws-compta-02`

3. **Onglet Profil** :
   - **Chemin du profil** : 
     ```
     \\srv-profiles\profiles\%username%
     # Exemple : \\srv-profiles\profiles\clark.kent
     ```
   - **Script de connexion** : 
     ```
     \\srv-scripts\dept\compta\logon.bat
     ```

> **Important** : Les restrictions horaires et de postes sont particulièrement utiles pour les comptes sensibles ou les prestataires externes


### 2.3 Désactivation et Suppression

La gestion de fin de cycle d'un compte utilisateur est une opération sensible qui doit suivre un processus strict.

#### Procédure de Désactivation

1. **Étape 1 : Désactivation du compte**
   ```
   ADUC > Propriétés du compte > Onglet Compte
   Cocher "Désactiver le compte"
   ```
   > La désactivation est préférable à la suppression car elle permet de réactiver le compte si nécessaire

2. **Étape 2 : Documentation**
   Dans la description du compte :
   ```
   [Désactivé le 25/03/2025]
   Motif : Départ de l'entreprise
   Rétention jusqu'au : 25/06/2025
   Ticket : INC0012345
   ```

3. **Étape 3 : Vérifications**
   - Révoquer les accès aux ressources
   - Vérifier les groupes d'appartenance
   - Sauvegarder les données importantes

> **Important** : La suppression définitive ne doit intervenir qu'après la période de rétention et une validation hiérarchique


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
   - Donner uniquement les droits nécessaires
   - Exemple :
     ```
     Un comptable junior :
     ✓ Accès lecture aux dossiers comptables
     ✓ Accès écriture à ses propres documents
     ✗ Accès aux salaires des employés
     ```

3. **Surveillance et Audit** :
   - Vérification mensuelle des comptes inactifs
   - Revue trimestrielle des privilèges élevés
   - Alerte sur les tentatives de connexion suspectes

### 3.2. Cycle de Vie des Comptes

1. **Création (Onboarding)** :
   ```
   ① Demande RH validée
   ② Création selon template départemental
   ③ Attribution des groupes standard
   ④ Vérification des accès
   ```

2. **Maintenance** :
   - Vérification trimestrielle des groupes
   - Mise à jour des informations utilisateur
   - Rotation des mots de passe

3. **Désactivation (Offboarding)** :
   ```
   ① Désactivation immédiate du compte
   ② Sauvegarde des données (30 jours)
   ③ Révocation des accès
   ④ Suppression après période de rétention
   ```

> **Note** : Ces pratiques doivent être documentées dans une procédure d'entreprise et révisées annuellement

Une bonne pratique **est une méthode ou une approche qui a démontré sa fiabilité et son efficacité dans la gestion des comptes utilisateurs**. Elle permet de :
- Maintenir la sécurité du système
- Assurer la cohérence de l'administration
- Faciliter la maintenance à long terme
- Réduire les risques d'erreurs

### 3.2. Sécurité des comptes

#### Politique de mot de passe
- Complexité minimale requise :
  - 12 caractères minimum
  - Mélange de majuscules, minuscules, chiffres
  - Au moins un caractère spécial
- Changement obligatoire à la première connexion
- Historique des mots de passe (éviter la réutilisation)

#### Gestion du cycle de vie
- **Création** : Vérification d'identité et autorisation
- **Modification** : Traçabilité des changements
- **Désactivation** : Préférer la désactivation à la suppression
- **Suppression** : Uniquement après période de rétention



## 4. Gestion des Groupes

Les groupes sont essentiels pour gérer efficacement les accès et les droits dans Active Directory. Ils permettent d'appliquer des permissions à plusieurs utilisateurs en même temps.

### 4.1 Types et Étendues de Groupes

#### Types de Groupes

1. **Groupes de Sécurité**
   - **Objectif** : Gérer les permissions et les droits d'accès dans le reseau
   - **Exemples** :
     ```
     GS-COMPTA-LECTURE    # Accès lecture aux dossiers comptables
     GS-RH-ADMIN         # Administration des ressources RH
     GS-IT-SUPPORT       # Équipe support informatique
     ```
   > Les groupes de sécurité sont les plus utilisés pour la gestion quotidienne

2. **Groupes de Distribution**
   - **Objectif** : Faciliter l'envoi d'emails à plusieurs destinataires
   - **Exemples** :
     ```
     DL-INFO-NEWSLETTER  # Liste de diffusion newsletter
     DL-DEPT-COMPTA      # Tous les employés de la comptabilité
     DL-MANAGERS         # Tous les managers de l'entreprise
     ```
   > Ces groupes sont uniquement pour la messagerie, pas pour les permissions

#### Étendues de Groupe

1. **Domaine Local** :
   - **Usage** : Attribution **finale des droits dans le domaine**
   - **Portée** : Créés et gérés dans **un seul domaine**
   - **Exemples** :
     ```
     DL-SERVEURS-ADMIN    # Administrateurs des serveurs
     DL-COMPTA-LECTURE    # Droits de lecture dossier comptabilité
     DL-RH-MODIF         # Peuvent modifier des données RH
     ```
   > Utilisés pour attribuer les permissions sur les ressources

2. **Global**
   - **Usage** : Organisation des utilisateurs **par fonction dans l'entreprise**
   - **Portée** : Créés et gérés dans **un seul domaine**
   - **Exemples** :
     ```
     GG-COMPTA-USERS     # Tous les comptables
     GG-RH-MANAGERS      # Managers des RH
     GG-IT-SUPPORT      # Équipe support niveau 1
     ```
   > Représentent généralement des rôles métier

3. **Universel**
   - **Usage** : Groupes **accessibles dans toute la forêt AD**
   - **Portée** : Tous les domaines de la forêt
   - **Exemples** :
     ```
     UG-DIRECTION       # Direction générale (tous sites)
     UG-PROJET-ISIB     # Équipe projet multi-domaines
     UG-ADMIN-GLOBAL    # Administrateurs globaux
     ```
   Les groupes universels sont accessibles dans toute la forêt AD, mais ils sont moins utilisés car ils impactent la réplication dans chaque domaine.
   
### 4.2 Création et Gestion des Groupes

La création et la gestion des groupes sont des tâches courantes qui nécessitent une attention particulière pour maintenir une structure cohérente.

#### Via l'Interface Graphique

1. **Création d'un groupe**
   ```
   ① Ouvrir ADUC (Utilisateurs et ordinateurs Active Directory)
   ② Naviguer vers l'OU cible (ex: OU=Groupes,OU=Comptabilité)
   ③ Clic droit > Nouveau > Groupe
   ④ Remplir les informations :
      - Nom : GG-COMPTA-USERS
      - Étendue : Global
      - Type : Sécurité
   ```
   > Le préfixe GG- indique un Groupe Global, suivant notre convention de nommage

2. **Ajout de membres**
   ```
   ① Double-clic sur le groupe
   ② Onglet Membres > Ajouter
   ③ Rechercher et sélectionner les utilisateurs :
      - clark.kent
      - sophie.lambert
   ④ Vérifier les membres ajoutés
   ```
   > Vérifiez toujours la liste des membres après les modifications

### 4.3 Bonnes Pratiques de Gestion

#### Convention de Nommage des Groupes

1. **Préfixes Standards**
   ```
   GG- : Groupe Global        # Ex: GG-COMPTA-USERS
   DL- : Domaine Local       # Ex: DL-SERVEUR-ACCES
   GU- : Groupe Universel    # Ex: GU-EUROPE-MANAGERS
   GS- : Groupe de Sécurité # Ex: GS-ADMIN-BACKUP
   ```
   > Le préfixe indique immédiatement la portée et le type du groupe

2. **Structure du Nom**
   ```
   Format : [Préfixe]-[Département]-[Fonction]

   Exemples :
   GG-COMPTA-USERS     # Utilisateurs du service comptabilité
   DL-RH-LECTURE      # Accès lecture aux documents RH
   GU-IT-ADMINS       # Administrateurs IT multi-sites
   ```
   > Une nomenclature cohérente facilite l'administration

#### Stratégie de Groupes Imbriqués (AGDLP)

1. **Principe AGDLP**
   ```
   Account → Global → DomainLocal → Permission

   Exemple concret :
   sophie.lambert → GG-COMPTA-USERS → DL-SERVEUR-ACCES → Permissions
   
   Détails :
   1. sophie.lambert est membre de GG-COMPTA-USERS
   2. GG-COMPTA-USERS est membre de DL-SERVEUR-ACCES
   3. DL-SERVEUR-ACCES a les permissions sur le serveur
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














