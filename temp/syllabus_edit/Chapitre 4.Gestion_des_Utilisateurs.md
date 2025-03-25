# 5. Gestion des Utilisateurs Active Directory

## 1. Introduction et Concepts de Base

### 1.1. Le Compte Utilisateur dans l'Environnement Enterprise

Un compte utilisateur Active Directory **représente une identité numérique unique dans l'infrastructure computerelectronics.be**. Il constitue :

- Le **point d'accès principal** aux ressources du domaine
- Un élément de la **structure de sécurité** de l'entreprise
- Une **composante critique** de la gestion des identités

### 1.2. Rôle dans Notre Infrastructure

Dans notre structure multi-sites, un compte utilisateur permet de :

- **Authentifier** l'utilisateur sur le domaine `computerelectronics.be`
- **Autoriser** l'accès aux ressources selon la localisation (EU/US)
- **Appliquer** des stratégies basées sur le département
- **Suivre** l'utilisation des ressources par région

### 1.3. Objectifs du Chapitre

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


## 2. Création et Configuration des Comptes

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



## 4. Bonnes pratiques de gestion des comptes

### 4.1. Qu'est-ce qu'une bonne pratique ?

Une bonne pratique **est une méthode ou une approche qui a démontré sa fiabilité et son efficacité dans la gestion des comptes utilisateurs**. Elle permet de :
- Maintenir la sécurité du système
- Assurer la cohérence de l'administration
- Faciliter la maintenance à long terme
- Réduire les risques d'erreurs

### 4.2. Standards de nommage

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

### 4.3. Sécurité des comptes

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

### 4.4. Documentation et audit

#### Documentation requise
- Procédures de création/modification standardisées
- Registre des actions effectuées
- Justification des exceptions aux règles

#### Audit régulier
- Revue trimestrielle des comptes inactifs
- Vérification des droits d'accès
- Contrôle des exceptions

> **Important** : Ces bonnes pratiques doivent être adaptées aux politiques de sécurité de votre organisation.
