## 1. Introduction aux OUs

### 1.1 Objectif et Rôle des OUs dans Active Directory

Une **OU est un conteneur AD qui permet de regrouper des objets AD** (utilisateurs, groupes, ordinateurs, etc.)

Les OU permettent de créer une organisation hiérarchique et administrative des ressources. Vous pouvez voir une OU comme **un dossier qui contient des objets AD** (encore un arbre!)

### 1.2. Structure d'une Unité d'Organisation (OU)

Une **OU** (**Organizational Unit**) est un **objet** de l'Active Directory conçu pour organiser les objets de manière **hiérarchique** et **flexible**.

La structure d'une OU ressemble à l'arbre de d'un système de fichiers, **où une OU apparaît comme un dossier** qui peut contenir des objets AD:

  - utilisateurs
  - groupes
  - ordinateurs
  - autres OUs
  - autres objets AD
  
Contrairement aux containers, les OUs sont utilisées principalement pour appliquer des **stratégies de groupe** (**GPO**) et gérer la **délégation des permissions**.

### 1.3. Gestion des objets 

On peut deplacer les objets entre les OU, ce qui permet une gestion plus flexible de la structure de l'AD.

Sur une **OU**, on peut appliquer des **GPO** (Group Policy Object, on les verra plus tard)

**Example**: Une OU `Comptabilité` peut avoir une GPO qui limite l'accès aux périphériques USB (droits), tandis qu'une OU `IT` permet leur utilisation.


## 2. Création et Gestion des OUs

Considerons la création de OUs pour l'entreprise `computerelectronics.be`.


### 2.1. Organisation par Département

Pour computerelectronics.be, nous utilisons une structure départementale :

- **Domaine Racine (computerelectronics.be)**: Cela demeure l'OU de niveau supérieur.


- **OUs basées sur l'emplacement (EU, US)**: Nous maintenons les OUs UE et US pour refléter la segmentation géographique du réseau.
- **OUs départementales (Comptabilité, RH, Ventes)**: Dans chaque emplacement, nous créons des OUs pour les trois départements.
- **OUs des utilisateurs et des ordinateurs**: A l'intérieur de chaque OU départementale, nous séparons les utilisateurs et les ordinateurs. C'est une bonne pratique pour appliquer des paramètres de stratégie de groupe différents.
- **OUs basées sur l'environnement (DEV, PROD)**: Nous gardons les OUs DEV et PROD pour gérer les ressources de développement et de production. Étant donné que ces ressources sont probablement centrées sur les serveurs, nous les organisons en catégories "Applications", "Bases de données" et "Serveurs".

```
computerelectronics.be (Domain Root)
├── EU
│   ├── Comptabilité
│   │   ├── Users
│   │   └── Computers
│   ├── RH
│   │   ├── Users
│   │   └── Computers
│   └── Ventes
│       ├── Users
│       └── Computers
├── US
│   ├── Comptabilité
│   │   ├── Users
│   │   └── Computers
│   ├── RH
│   │   ├── Users
│   │   └── Computers
│   └── Ventes
│       ├── Users
│       └── Computers
├── DEV
│   ├── Applications
│   ├── Databases
│   └── Servers
└── PROD
    ├── Applications
    ├── Databases
    └── Servers
```



#### 2.1.2 Bonnes Pratiques de Nommage

- Éviter les caractères spéciaux
- Utiliser des noms descriptifs
- Maintenir une cohérence dans la nomenclature
- Exemple : "Comptabilite" plutôt que "COMPTA" 

### 2.2 Création via 

#### 2.2.1 Procédure de Création

1. Ouvrir `Utilisateurs et ordinateurs d'Active Directory`
2. Clic droit sur le domaine ou l'OU parent
3. Nouveau -> Unité d'organisation
4. Saisir le nom selon les conventions

## Exercices

### Exercice 1 : Structure de Base
1. Créer les OUs principales :
   - Comptabilité
   - RH
   - Ventes

2. Dans chaque OU départementale, créer :
   - OU "Utilisateurs"
   - OU "Ordinateurs"

3. Vérifier la protection contre la suppression


### Exercice 2 : Organisation des Objets
1. Créer des utilisateurs test
2. Créer des ordinateurs test
3. Organiser les objets dans les OUs appropriées


### Exercice 3 : Délégation Simple
1. Créer un groupe "Support_Technique"
2. Déléguer le droit de réinitialisation de mot de passe en utilisant le `Wizard de délégation de contrôle` :
	* Sélectionner l'OU "Utilisateurs"
	* Sélectionner le groupe "Support_Technique"
	* Cocher la case "Réinitialiser le mot de passe"
	* Cliquer sur "Terminer"
3. Tester la délégation en demandant à un membre du groupe de réinitialiser le mot de passe d'un utilisateur

### Exercice 4 : Délégation Départementale
1. Créer des groupes d'administration par département
2. Configurer les délégations appropriées
3. Documenter la structure mise en place
4. Valider les accès

#### Exercice 5 : Gestion Quotidienne
1. Déplacer des utilisateurs entre départements
2. Gérer les accès délégués
3. Auditer les permissions

#### Exercice 6 : Maintenance
1. Vérifier la structure des OUs
2. Nettoyer les délégations obsolètes
3. Mettre à jour la documentation