# Partage de dossiers et permissions Active Directory

## 1. Introduction aux permissions

### 1.1. Qu'est-ce qu'un système de permissions ?

Un système de permissions **est un mécanisme de sécurité qui contrôle l'accès aux ressources en définissant qui peut faire quoi sur quelles ressources**. Dans Active Directory, il permet de :
- Protéger les données sensibles
- Contrôler les accès utilisateurs
- Gérer les droits de modification
- Maintenir la confidentialité des informations

### 1.2. Objectifs Pédagogiques

À la fin de ce chapitre, vous serez capable de :
1. Comprendre la différence entre permissions NTFS et permissions de partage
2. Configurer des partages réseau sécurisés
3. Gérer les permissions de manière granulaire
4. Implémenter les bonnes pratiques de sécurité

### 1.3. Les deux niveaux de permissions

#### Exemple concret
Sur le serveur `dns1.computerelectronics.be` (`192.168.0.2`), nous allons configurer un partage pour le département comptabilité. Le poste `ws-compta-01` (`192.168.0.101`) aura accès à ce partage.

#### Permissions NTFS (système de fichiers)
**Objectif** : Contrôle d'accès au niveau du système de fichiers

**Caractéristiques** :
- S'appliquent localement sur le serveur
- Offrent un contrôle granulaire des accès
- Restent actives même en accès local
- Permettent des permissions spécifiques (ex: Lecture, Écriture, Exécution)

**Exemple pratique** :
```
Dossier : D:\Comptabilite\Factures
Permission : Lecture seule pour le groupe 'GG-Comptabilite-STAGIAIRES'
Effet : Les stagiaires de la comptabilité peuvent lire mais pas modifier les factures
```

#### Permissions de partage (réseau)
**Objectif** : Contrôle d'accès au niveau du réseau

**Caractéristiques** :
- S'appliquent uniquement lors de l'accès réseau
- Offrent trois niveaux simples :
  * Lecture
  * Modification
  * Contrôle total
- Constituent la première barrière de sécurité

**Exemple pratique** :
```
Partage : \\serveur\comptabilite$
Permission : Modification pour le groupe 'GG-Comptabilite-USERS'
Effet : Les utilisateurs de la comptabilité peuvent modifier les fichiers via le réseau
```

> **Note importante** : La sécurité finale est déterminée par l'intersection des deux types de permissions. L'utilisateur obtient toujours le niveau de permission le plus restrictif entre NTFS et partage. Par exemple, si un utilisateur a un accès en Modification au niveau du partage mais en Lecture seule au niveau NTFS, il ne pourra que lire les fichiers.

## 2. Configuration d'un partage réseau

### 2.1. Qu'est-ce qu'un partage réseau ?

Un partage réseau **est un dossier ou une ressource rendu accessible à d'autres utilisateurs via le réseau**. Il permet de :
- Centraliser les données de l'entreprise
- Faciliter la collaboration entre services
- Contrôler l'accès aux ressources
- Simplifier la sauvegarde des données

### 2.2. Processus de configuration

#### Étape 1 : Préparation du dossier

**Objectif** : Créer une structure organisée pour les données partagées

**Procédure** :
1. Créez une arborescence logique :
   ```
   D:\
   └── Partages\
       ├── Comptabilité\
       │   ├── Factures\
       │   └── Rapports\
       ├── RH\
       ├── Ventes\
       └── Infrastructure\
   ```

#### Étape 2 : Configuration du partage

**Objectif** : Rendre le dossier accessible via le réseau

**Procédure** :
1. Clic droit sur le dossier -> Propriétés -> Partage
2. Partage avancé -> Cocher "Partager ce dossier"
3. Nom du partage : `Comptabilite$`
   > **Astuce** : Le $ à la fin rend le partage caché dans l'explorateur réseau

**Exemple de chemin UNC** :
```
\\serveur\Comptabilite$\Factures
```

#### Étape 3 : Configuration des permissions de partage

**Objectif** : Définir les accès réseau de base

**Procédure** :
1. Dans l'onglet Partage -> Autorisations
2. Configurer les groupes :
   ```
   Groupe             Permission    Justification
   ---------------    ----------    -------------
   Comptabilite-USERS       Modification  Travail quotidien
   RH-MANAGERS        Lecture       Consultation uniquement
   ```

#### Étape 4 : Configuration des permissions NTFS

**Objectif** : Affiner le contrôle d'accès au niveau fichier

**Procédure** :
1. Onglet Sécurité -> Modifier
2. Configurer les permissions :
   ```
   Groupe             Permissions                 Usage
   ---------------    -------------------------    ---------------
   Comptabilite-USERS       - Lecture                   Accès complet aux
                      - Écriture                  fichiers comptables
                      - Modification
   
   RH-MANAGERS        - Lecture                   Consultation des
                      - Afficher le contenu       rapports uniquement
   ```

> **Important** : Appliquez toujours le principe du moindre privilège. N'accordez que les permissions minimales nécessaires pour effectuer les tâches requises.

#### Permissions avancées
1. Paramètres avancés -> Ajouter
2. Sélectionner un principal (groupe AD)
3. Appliquer sur : "Ce dossier, les sous-dossiers et fichiers"

## 3. Exercice pratique - Partage départemental

### 3.1. Création de la structure

#### Préparation des dossiers
```
D:\Partages\
├── Comptabilite
│   ├── Public
│   └── Confidentiel
└── RH
    ├── Public
    └── Personnel
```

#### Création des groupes AD
```powershell
# Création des groupes de sécurité
New-ADGroup -Name "Comptabilite-Users" -GroupScope Global
New-ADGroup -Name "Comptabilite-Managers" -GroupScope Global
New-ADGroup -Name "RH-Users" -GroupScope Global
New-ADGroup -Name "RH-Managers" -GroupScope Global
```

### 3.2. Configuration des permissions

#### Dossier Comptabilité
Dossier Public :
- Comptabilite-Users : Modification
- RH-Users : Lecture

Dossier Confidentiel :
- Comptabilite-Managers : Contrôle total
- Comptabilite-Users : Lecture

#### Dossier RH
Dossier Public :
- Tous les utilisateurs du domaine : Lecture
- RH-Users : Modification

Dossier Personnel :
- RH-Managers : Contrôle total

### 3.3. Test des permissions

#### Vérification des accès
1. Connectez-vous avec un compte utilisateur standard
2. Tentez d'accéder aux différents dossiers
3. Vérifiez que les restrictions fonctionnent

#### Dépannage courant
```powershell
# Vérifier l'appartenance aux groupes
Get-ADPrincipalGroupMembership "utilisateur"

# Tester le chemin réseau
Test-Path "\\serveur\partage\dossier"

# Vérifier les journaux d'événements
Get-EventLog -LogName Security -Newest 10
```

## 4. Bonnes pratiques

### 4.1. Structure des dossiers
- Organisez par département
- Séparez public/privé
- Utilisez des noms clairs

### 4.2. Groupes de sécurité
- Créez des groupes par fonction
- Évitez les permissions utilisateur directes
- Documentez les groupes

### 4.3. Permissions
- Appliquez le principe du moindre privilège
- Héritez les permissions quand possible
- Évitez les permissions explicites "Refuser"

## 5. Exercice final - Migration de données

### 5.1. Scénario
Le service comptabilité doit migrer ses données vers un nouveau partage avec une structure améliorée.

#### Structure des dossiers
```
D:\Partages\Comptabilite_V2\
├── _Archives
├── Clients
│   ├── Actifs
│   └── Inactifs
├── Factures
│   ├── Emissions
│   └── Receptions
└── Rapports
```

#### Configuration des groupes et permissions
1. Création des groupes AD :
   - Comptabilite-ArchivesRO (lecture seule archives)
   - Comptabilite-FacturesRW (modification factures)
   - Comptabilite-RapportsRW (modification rapports)

2. Configuration des permissions :
   - Configurez les permissions NTFS et partage
   - Appliquez le principe du moindre privilège
   - Vérifiez l'héritage des permissions

#### Migration et validation
1. Migration des données :
   - Copiez les données avec robocopy
   - Préservez les permissions
   - Vérifiez l'intégrité des données

2. Validation finale :
   - Testez tous les accès utilisateurs
   - Vérifiez les permissions héritées
   - Confirmez avec les utilisateurs
