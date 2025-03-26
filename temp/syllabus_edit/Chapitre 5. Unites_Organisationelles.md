# Les Unités Organisationnelles (OUs)

## 1. Introduction aux OUs

### 1.1 Objectif et Rôle des OUs dans Active Directory

- Organisation hiérarchique des ressources
- Délégation des tâches administratives
- Application des stratégies de groupe (GPO)
- Simplification de la gestion des objets AD

### 1.2 Différences entre Containers et OUs

#### 1.2.1 Container d'utilisateurs (par exemple, CN=Users)

- Nature : Un container (par exemple, CN=Users) est un objet dans Active Directory qui contient d'autres objets, mais il n'est pas conçu pour être utilisé de manière aussi flexible que les OUs. Les containers sont utilisés principalement pour l'organisation par défaut.

- Gestion des objets : Les objets dans un container, comme les utilisateurs, sont gérés de manière centralisée, mais ne peuvent pas être déplacés facilement ou modifiés dans leur structure (contrairement aux OUs).

- GPO : Les Groupes de Politiques de Sécurité (GPOs) ne peuvent pas être appliqués directement sur un container. Seuls les objets au sein d'une OU peuvent avoir des stratégies de groupe appliquées.

- Réplication : Les containers sont répliqués à travers l'ensemble du domaine de la même manière que les autres objets d'AD, mais il y a moins de souplesse dans la gestion des objets comparé aux OUs.

- Limitation : On ne peut pas attribuer des permissions spécifiques aux containers pour restreindre l'accès ou contrôler l'administration de manière granulaire.

#### 1.2.2 Unité d'Organisation (OU)

- Nature : Une OU (Organizational Unit) est un objet de l'Active Directory conçu pour organiser les objets de manière hiérarchique et plus flexible. Elle peut contenir des utilisateurs, des groupes, des ordinateurs, et d'autres OUs. Contrairement aux containers, les OUs sont utilisées principalement pour appliquer des stratégies de groupe (GPO) et gérer la délégation des permissions.

- Gestion des objets : Les objets dans une OU peuvent être déplacés entre les OUs, ce qui permet une gestion plus flexible de la structure de l'AD.

- GPO : Les OUs permettent l'application de GPOs spécifiques, ce qui offre une gestion fine des politiques de sécurité et de configuration pour les objets à l'intérieur de l'OU.

- Délégation : Il est possible de déléguer des permissions sur une OU, permettant à des administrateurs spécifiques de gérer les objets dans une OU sans avoir à toucher à d'autres parties de l'Active Directory.

- Réplication : Les OUs, tout comme les containers, sont répliquées à travers l'Active Directory, mais la structure des OUs offre plus de souplesse pour organiser les objets et appliquer des configurations spécifiques.

#### 1.2.3 En résumé

- Un container est plus rigide et est principalement utilisé pour organiser les objets par défaut, sans possibilité d'appliquer des politiques spécifiques ou de déléguer des permissions facilement.

- Une OU est plus flexible et est idéale pour une gestion administrative avancée, permettant d'appliquer des GPOs, de déléguer des droits d'administration et de structurer l'Active Directory de manière plus ciblée et modulable.

## 2. Création et Gestion des OUs

### 2.1 Structure Recommandée

#### 2.1.1 Organisation par Département

Pour computerelectronics.be, nous utilisons une structure départementale :


## Explanation

- **Root Domain (computerelectronics.be)**: This remains the top-level OU.
- **Location-Based OUs (EU, US)**: We maintain the EU and US OUs to reflect the network's geographic segmentation.
- **Departmental OUs (Comptabilité, RH, Ventes)**: Within each location, we create OUs for the three departments.
- **User and Computer OUs**: Inside each departmental OU, we further separate users and computers. This is a best practice for applying different Group Policy settings.
- **Environment-Based OUs (DEV, PROD)**: We keep the DEV and PROD OUs for managing development and production resources. Since these are likely server-centric, we organize them into "Applications," "Databases," and "Servers" categories.


computerelectronics.be (Domain Root)
└── EU
    ├── Comptabilité
    │   ├── Users
    │   └── Computers
    ├── RH
    │   ├── Users
    │   └── Computers
    └── Ventes
        ├── Users
        └── Computers
└── US
    ├── Comptabilité
    │   ├── Users
    │   └── Computers
    ├── RH
    │   ├── Users
    │   └── Computers
    └── Ventes
        ├── Users
        └── Computers
└── DEV
    ├── Applications
    ├── Databases
    └── Servers
└── PROD
    ├── Applications
    ├── Databases
    └── Servers


## Benefits of This Structure

- **Clear Organization**: The structure clearly reflects both the network zones and the departmental organization.
- **Efficient Group Policy Management**: You can apply Group Policy settings at the location level (EU, US), department level (Comptabilité, RH, Ventes), or user/computer level.
- **Delegation of Administration**: You can easily delegate administrative control to department managers or regional IT staff.
- **Scalability**: The structure can easily be expanded as the organization grows.

## Additional Considerations

- **Naming Conventions**: Use consistent naming conventions for all OUs.
- **Group Policy Planning**: Plan your Group Policy strategy to effectively manage users and computers within each OU.
- **Security**: Ensure that appropriate permissions are set on each OU to control access.

This structure provides a robust and manageable OU framework for your network. Remember to adapt it to your specific organizational needs and requirements.

## How to Implement

1. **Open Active Directory Users and Computers**: On a domain controller, open the Active Directory Users and Computers console.
2. **Create the Root OUs**: Right-click on the domain name (computerelectronics.be) and select "New" -> "Organizational Unit." Create the "EU," "US," "DEV," and "PROD" OUs.
3. **Create Department OUs**: Inside the "EU" and "US" OUs, create the "Comptabilité," "RH," and "Ventes" OUs.
4. **Create User and Computer OUs**: Within each department OU, create "Users" and "Computers" OUs.
5. **Create Server OUs**: Inside the "DEV" and "PROD" OUs, create "Applications," "Databases," and "Servers" OUs.
6. **Move Objects**: Move existing user and computer accounts into their appropriate OUs.


#### 2.1.2 Bonnes Pratiques de Nommage

- Éviter les caractères spéciaux
- Utiliser des noms descriptifs
- Maintenir une cohérence dans la nomenclature
- Exemple : "Comptabilité" plutôt que "COMPTA" ou "Accounting"

### 2.2 Création via ADUC

#### 2.2.1 Procédure de Création

1. Ouvrir ADUC (Active Directory Users and Computers)
2. Clic droit sur le domaine ou l'OU parent
3. Nouveau → Unité d'organisation
4. Saisir le nom selon les conventions

#### 2.2.2 Gestion des OUs

- **Déplacement d'objets** :
  * Glisser-déposer entre OUs
  * Utilisation de PowerShell pour les déplacements en masse

- **Protection contre la suppression accidentelle** :
  * Activation de la protection
  * Vérification du statut de protection

- **Organisation des objets** :
  * Séparation utilisateurs/ordinateurs
  * Regroupement par fonction ou localisation

## 3. Délégation de Contrôle

### 3.1 Principes de la Délégation

#### 3.1.1 Concept et Avantages

- **Définition** : Attribution de droits administratifs spécifiques sur des OUs
- **Objectifs** :
  * Décentralisation de l'administration
  * Réduction de la charge des administrateurs principaux
  * Sécurité accrue par la séparation des rôles

#### 3.1.2 Niveaux de Délégation

1. **Administration Complète**
   - Tous les droits sur l'OU
   - Exemple : Chef du département RH pour l'OU RH

2. **Administration Limitée**
   - Droits spécifiques (création d'utilisateurs, réinitialisation de mots de passe)
   - Exemple : Support technique pour la réinitialisation des mots de passe

### 3.2 Configuration de la Délégation

#### 3.2.1 Utilisation de l'Assistant de Délégation

1. **Étapes de Configuration**
   ```
   Clic droit sur l'OU → Délégation de contrôle →
   Suivant → Sélectionner les utilisateurs/groupes →
   Choisir les tâches → Terminer
   ```

2. **Scénarios Pratiques**
   - Délégation pour le service RH :
     * Création/modification d'utilisateurs
     * Gestion des groupes
   - Délégation pour le support technique :
     * Réinitialisation des mots de passe
     * Gestion des ordinateurs

#### 3.2.2 Vérification et Maintenance

- Audit des délégations existantes
- Documentation des droits accordés
- Révision périodique des accès

## 4. Travaux Pratiques

### 4.1 Création de la Structure d'OUs

#### Exercice 1 : Structure de Base
1. Créer les OUs principales :
   - Comptabilité
   - RH
   - Ventes

2. Dans chaque OU départementale, créer :
   - OU "Utilisateurs"
   - OU "Ordinateurs"

3. Vérifier la protection contre la suppression

#### Exercice 2 : Organisation des Objets
1. Créer des utilisateurs test
2. Créer des ordinateurs test
3. Organiser les objets dans les OUs appropriées

### 4.2 Configuration des Délégations

#### Exercice 3 : Délégation Simple
1. Créer un groupe "Support_Technique"
2. Déléguer le droit de réinitialisation de mot de passe
3. Tester la délégation

#### Exercice 4 : Délégation Départementale
1. Créer des groupes d'administration par département
2. Configurer les délégations appropriées
3. Documenter la structure mise en place
4. Valider les accès

### 4.3 Scénarios Pratiques

#### Exercice 5 : Gestion Quotidienne
1. Déplacer des utilisateurs entre départements
2. Gérer les accès délégués
3. Auditer les permissions

#### Exercice 6 : Maintenance
1. Vérifier la structure des OUs
2. Nettoyer les délégations obsolètes
3. Mettre à jour la documentation