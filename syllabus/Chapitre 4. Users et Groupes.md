# 4. Gestion des Utilisateurs et Groupes dans Active Directory

## 1. Le Compte Utilisateur dans l'Environnement Enterprise

Un compte utilisateur Active Directory **représente une identité numérique unique dans l'infrastructure computerelectronics.be**. Il constitue :

- Le **point d'accès principal** aux ressources du domaine
- Un élément de la **structure de sécurité** de l'entreprise
- Une **composante critique** de la gestion des identités

### 1.1. Rôle dans Notre Infrastructure

Dans notre structure multi-sites, un compte utilisateur permet de :

- **Authentifier** l'utilisateur sur le domaine `computerelectronics.be`
- **Autoriser** l'accès aux ressources selon la localisation (EU/US)
- **Appliquer** des stratégies basées sur le département
- **Suivre** l'utilisation des ressources par région

### 1.2. Objectifs du Chapitre

À la fin de ce module, vous serez capable de :

1. **Créer et gérer** des comptes utilisateurs adaptés à notre structure
   - Utilisation de l'interface graphique (ADUC)
   - Automatisation avec PowerShell

2. **Implémenter** les standards de sécurité
   - Politiques de mot de passe
   - Restrictions d'accès géographiques
   - Contrôles départementaux

3. **Maintenir** l'organisation des comptes
   - Placement correct dans les OUs
   - Application des conventions de nommage
   - Documentation des modifications


## 2. Création et Configuration des Comptes Utilisateurs

### 2.1. Standards de Nommage

#### Convention Officielle
- Format : `prenom.nom` ou `p.nom`
- Exemples :
  ```
  clark.kent
  sophie.lambert
  ```
- **Important** : Toujours en minuscules, sans caractères spéciaux

#### UPN (User Principal Name)
- Format : `login@computerelectronics.be`
- Pas de sous-domaines dans l'UPN
- Exemple : `clark.kent@computerelectronics.be`



- Création d’un compte utilisateur
- Joindre un ordinateur à un domaine AD


## 4. Bonnes pratiques de gestion des comptes

### 3.1. Qu'est-ce qu'une bonne pratique ?

Une bonne pratique **est une méthode ou une approche qui a démontré sa fiabilité et son efficacité dans la gestion des comptes utilisateurs**. Elle permet de :
- Maintenir la sécurité du système
- Assurer la cohérence de l'administration
- Faciliter la maintenance à long terme
- Réduire les risques d'erreurs

### 3.2. Standards de nommage

#### Convention de nommage
- **Format standard** : `[prénom].[nom]` ou `[initiale_prénom][nom]`
- **Exemples** :
  - jean.dupont
  - jdupont

#### Règles à suivre
- Utiliser uniquement des caractères alphanumériques
- Éviter les caractères spéciaux et les espaces
- Maintenir une longueur raisonnable (max 20 caractères)
- Utiliser uniquement des minuscules

### 3.3. Sécurité des comptes

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

### 3.4. Documentation et audit

#### Documentation requise
- Procédures de création/modification standardisées
- Registre des actions effectuées
- Justification des exceptions aux règles

#### Audit régulier
- Revue trimestrielle des comptes inactifs
- Vérification des droits d'accès
- Contrôle des exceptions

> **Important** : Ces bonnes pratiques doivent être adaptées aux politiques de sécurité de votre organisation.



## 4. Introduction aux groupes

### 4.1. Qu'est-ce qu'un groupe Active Directory ?

Un groupe Active Directory **est un conteneur qui permet de rassembler et de gérer plusieurs objets (utilisateurs, ordinateurs ou autres groupes) comme une seule entité**. Il permet de :
- Gérer les permissions pour plusieurs utilisateurs simultanément
- Simplifier l'administration des accès
- Organiser les utilisateurs par fonction ou service
- Réduire la complexité de la gestion des droits

### 4.2. Objectifs Pédagogiques

À la fin de ce chapitre, vous serez capable de :
1. Comprendre et utiliser les différents types de groupes (sécurité et distribution)
2. Maîtriser les étendues de groupe (domaine local, global, universel)
3. Créer et gérer des groupes via l'interface graphique et PowerShell
4. Implémenter les bonnes pratiques de gestion des groupes

> **Note** : La gestion efficace des groupes est essentielle pour maintenir une structure de sécurité cohérente dans Active Directory.

### 4.3. Types de groupes

#### Qu'est-ce qui détermine le type d'un groupe ?
Le type d'un groupe **définit sa fonction principale dans l'infrastructure Active Directory**. Il existe deux types principaux :

#### Groupes de sécurité
**Objectif principal** : Gestion des accès et des permissions

**Caractéristiques** :
- Peuvent recevoir des permissions sur les ressources
- Gèrent l'accès aux dossiers, imprimantes, etc.
- Peuvent contenir tous types d'objets AD

**Exemple pratique** :
```
Groupe : GG-COMPTA-ACCES (Groupe Global)
Type : Sécurité
Utilisation : Regroupe les utilisateurs de la comptabilité
OU : Comptabilité/Utilisateurs
```

#### Groupes de distribution
**Objectif principal** : Communication et messagerie

**Caractéristiques** :
- Dédiés à la messagerie électronique
- Ne peuvent pas recevoir de permissions
- Utilisés avec Exchange Server

**Exemple pratique** :
```
Groupe : INFO-NEWSLETTER
Type : Distribution
Utilisation : Envoi de newsletters internes
```

### 4.4. Étendues de groupe

#### Qu'est-ce que l'étendue d'un groupe ?
L'étendue d'un groupe **détermine sa portée d'utilisation dans l'infrastructure Active Directory**. Elle influence où le groupe peut être utilisé et qui peut en être membre.

#### Domaine local
**Objectif** : Attribuer des permissions dans un domaine spécifique

**Caractéristiques** :
- Utilisés pour les permissions locales
- Acceptent des membres de n'importe quel domaine
- Portée limitée à leur domaine

**Exemple pratique** :
```
Groupe : DL-SERVEUR-ADMIN
Portée : Domaine local
Utilisation : Accès administratif aux serveurs
OU : Infrastructure/AdminComptes
```

#### Global
**Objectif** : Organiser les utilisateurs par fonction ou service

**Caractéristiques** :
- Membres limités à un seul domaine
- Utilisables dans tout l'arbre de domaines
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












