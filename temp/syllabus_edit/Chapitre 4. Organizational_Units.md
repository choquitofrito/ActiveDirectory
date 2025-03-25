# 1. Organizational Units (OUs)

## 1. Introduction aux OUs

### 1.1. Qu'est-ce qu'une OU ?

Une Unité d'Organisation (OU) **est un conteneur dans Active Directory qui permet d'organiser les objets de manière administrative**. Ces **objets** peuvent être :
- Des comptes **utilisateurs**
- Des **ordinateurs**
- Des **groupes**
- Des **imprimantes**
- D'autres **OUs** (imbrication)

### 1.2. Objectifs Pédagogiques

À la fin de ce chapitre, vous serez capable de :
1. Créer et organiser une structure d'OUs
2. Déléguer des droits d'administration
3. Gérer la sécurité des OUs
4. Implémenter les bonnes pratiques

### 1.3. Quand utiliser les Sous-domaines DNS ou les OUs

## 2. Structure des OUs pour computerelectronics.be

### 2.1. Planification

Notre structure d'OUs doit refléter l'organisation de l'entreprise tout en facilitant l'administration. Voici la structure complète :

```
computerelectronics.be
├── Administration
│   ├── AdminComptes
│   └── Serveurs
│       ├── DCs
│       ├── Services_EU
│       └── Services_US
├── Europe
│   ├── Comptabilité
│   │   ├── Utilisateurs
│   │   └── Ordinateurs
│   ├── RH
│   │   ├── Utilisateurs
│   │   └── Ordinateurs
│   └── Ventes
│       ├── Utilisateurs
│       └── Ordinateurs
├── USA
│   ├── Comptabilité
│   │   ├── Utilisateurs
│   │   └── Ordinateurs
│   ├── RH
│   │   ├── Utilisateurs
│   │   └── Ordinateurs
│   └── Ventes
│       ├── Utilisateurs
│       └── Ordinateurs
└── Environnements
    ├── Développement
    │   ├── Applications
    │   └── Serveurs
    └── Production
        ├── Applications
        └── Serveurs
```

**Points clés :**

1. **Séparation géographique**
   - Europe et USA ont des structures identiques
   - Facilite la délégation par région

2. **Administration centralisée**
   - OU Administration pour les comptes privilégiés
   - Serveurs organisés par région

3. **Environnements isolés**
   - Développement et Production séparés
   - Correspond aux zones DNS dédiées

**IMPORTANT :** 
- La structure OU est indépendante de la hiérarchie DNS
- Un ordinateur dans l'OU `Europe/Comptabilité/Ordinateurs` peut avoir le nom DNS `ws-compta-01.computerelectronics.be`
- Les OUs facilitent l'administration, les zones DNS gèrent la résolution de noms

## 3. Exercices Pratiques

### Exercice 1 : Création de la Structure de Base

#### Objectif
Mettre en place la structure d'OUs pour la région Europe et l'administration centrale.

#### Étapes
1. Créer l'OU `Administration`
   - Sous-OUs : `AdminComptes` et `Serveurs`
   - Dans `Serveurs`, créer : `DCs` et `Services_EU`

2. Créer l'OU `Europe`
   - Créer les départements : `Comptabilité`, `RH`, `Ventes`
   - Dans chaque département : `Utilisateurs` et `Ordinateurs`

3. Déplacer les objets existants
   - Déplacer `dns1` vers `Administration/Serveurs/DCs`
   - Déplacer `ws01` vers `Europe/Comptabilité/Ordinateurs`
   - Déplacer l'utilisateur `clark.kent` vers `Europe/Comptabilité/Utilisateurs`
   - Déplacer l'utilisateur `sophie.lambert` vers `Europe/RH/Utilisateurs`

**Note sur la convention de nommage des utilisateurs :**
- Format : `prenom.nom` (tout en minuscules)
- Exemple : `clark.kent`, `sophie.lambert`
- Pas de caractères spéciaux sauf le point
- Pas de chiffres sauf si nécessaire pour différencier

<details>
<summary>Solution Exercice 1</summary>

```powershell
# 1. Création de l'administration
New-ADOrganizationalUnit -Name "Administration" -Path "DC=computerelectronics,DC=be"
New-ADOrganizationalUnit -Name "AdminComptes" -Path "OU=Administration,DC=computerelectronics,DC=be"
New-ADOrganizationalUnit -Name "Serveurs" -Path "OU=Administration,DC=computerelectronics,DC=be"
New-ADOrganizationalUnit -Name "DCs" -Path "OU=Serveurs,OU=Administration,DC=computerelectronics,DC=be"
New-ADOrganizationalUnit -Name "Services_EU" -Path "OU=Serveurs,OU=Administration,DC=computerelectronics,DC=be"

# 2. Création de la structure Europe
New-ADOrganizationalUnit -Name "Europe" -Path "DC=computerelectronics,DC=be"
$departments = @('Comptabilité', 'RH', 'Ventes')
foreach ($dept in $departments) {
    $deptPath = "OU=Europe,DC=computerelectronics,DC=be"
    New-ADOrganizationalUnit -Name $dept -Path $deptPath
    New-ADOrganizationalUnit -Name "Utilisateurs" -Path "OU=$dept,$deptPath"
    New-ADOrganizationalUnit -Name "Ordinateurs" -Path "OU=$dept,$deptPath"
}

# 3. Déplacement des objets
# Déplacer le DC
Get-ADComputer "dns1" | Move-ADObject -TargetPath "OU=DCs,OU=Serveurs,OU=Administration,DC=computerelectronics,DC=be"

# Déplacer les postes de travail
Get-ADComputer "ws01" | Move-ADObject -TargetPath "OU=Ordinateurs,OU=Comptabilité,OU=Europe,DC=computerelectronics,DC=be"

# Déplacer les utilisateurs
Get-ADUser "clark.kent" | Move-ADObject -TargetPath "OU=Utilisateurs,OU=Comptabilité,OU=Europe,DC=computerelectronics,DC=be"
Get-ADUser "sophie.lambert" | Move-ADObject -TargetPath "OU=Utilisateurs,OU=RH,OU=Europe,DC=computerelectronics,DC=be"
```
</details>

### Exercice 2 : Délégation d'Administration

#### Objectif
Configurer les droits d'administration pour les responsables régionaux.

#### Étapes
1. Créer un groupe `EU_Admins` dans `Administration/AdminComptes`
2. Déléguer les droits suivants sur l'OU `Europe` :
   - Création/suppression d'utilisateurs
   - Réinitialisation des mots de passe
   - Gestion des groupes
3. Restreindre l'accès aux autres OUs

<details>
<summary>Solution Exercice 2</summary>

```powershell
# 1. Création du groupe d'administration
New-ADGroup -Name "EU_Admins" \
           -Path "OU=AdminComptes,OU=Administration,DC=computerelectronics,DC=be" \
           -GroupScope Global \
           -GroupCategory Security

# 2. Délégation des droits (via l'interface graphique)
# Clic droit sur OU Europe > Déléguer le contrôle
# Sélectionner EU_Admins et attribuer les droits
```
</details>

### Exercice 3 : Préparation Multi-Sites

#### Objectif
Préparer la structure pour le déploiement aux USA.

#### Étapes
1. Créer l'OU `USA` avec la même structure qu'`Europe`
2. Ajouter `Services_US` dans `Administration/Serveurs`
3. Créer les GPOs de base pour chaque région

<details>
<summary>Solution Exercice 3</summary>

```powershell
# 1. Création de la structure USA (réutilisation du script Europe)
$usPath = "DC=computerelectronics,DC=be"
New-ADOrganizationalUnit -Name "USA" -Path $usPath

$departments = @('Comptabilité', 'RH', 'Ventes')
foreach ($dept in $departments) {
    $deptPath = "OU=USA,$usPath"
    New-ADOrganizationalUnit -Name $dept -Path $deptPath
    New-ADOrganizationalUnit -Name "Utilisateurs" -Path "OU=$dept,$deptPath"
    New-ADOrganizationalUnit -Name "Ordinateurs" -Path "OU=$dept,$deptPath"
}

# 2. Ajout Services_US
New-ADOrganizationalUnit -Name "Services_US" \
    -Path "OU=Serveurs,OU=Administration,DC=computerelectronics,DC=be"
```
</details>

**Note importante :** Dans la pratique, nous nous concentrerons d'abord sur la structure Europe pour nos exercices, mais il est essentiel de comprendre comment l'infrastructure peut être étendue à d'autres régions.

### Exercice 4 : Protection de la Structure

#### Objectif
Mettre en place des mesures de protection pour éviter la suppression ou modification accidentelle des OUs.

#### Étapes
1. Activer la protection contre la suppression pour :
   - Toutes les OUs régionales (Europe, USA)
   - L'OU Administration et ses sous-OUs
   - Les OUs contenant des serveurs critiques

2. Documenter la structure avec PowerShell
   - Générer un rapport de la hiérarchie des OUs
   - Lister les protections activées
   - Exporter la configuration pour sauvegarde

<details>
<summary>Solution Exercice 4</summary>

```powershell
# 1. Activation de la protection
$criticalOUs = @(
    "OU=Europe,DC=computerelectronics,DC=be",
    "OU=USA,DC=computerelectronics,DC=be",
    "OU=Administration,DC=computerelectronics,DC=be",
    "OU=Serveurs,OU=Administration,DC=computerelectronics,DC=be"
)

foreach ($ou in $criticalOUs) {
    Set-ADObject -Identity $ou -ProtectedFromAccidentalDeletion $true
    Write-Host "Protection activée pour: $ou"
}

# 2. Génération du rapport
$report = @()
Get-ADOrganizationalUnit -Filter * | ForEach-Object {
    $report += [PSCustomObject]@{
        'OU' = $_.DistinguishedName
        'Protected' = $_.ProtectedFromAccidentalDeletion
        'Created' = $_.Created
        'Modified' = $_.Modified
    }
}

# Export au format CSV
$report | Export-Csv -Path "C:\Temp\OU_Structure_Report.csv" -NoTypeInformation -Encoding UTF8
```
</details>

### Exercice 5 : Migration d'Objets

#### Scénario
Le service comptabilité de la région Europe déménage physiquement aux USA. Vous devez :
1. Déplacer les utilisateurs et ordinateurs
2. Maintenir les accès et permissions
3. Mettre à jour la documentation

#### Étapes
1. Préparer la migration
   - Vérifier les GPOs liées
   - Identifier les groupes et permissions
   - Planifier le déplacement des objets

2. Exécuter la migration
   - Déplacer les objets vers la nouvelle OU
   - Mettre à jour les appartenances aux groupes
   - Vérifier les accès

<details>
<summary>Solution Exercice 5</summary>

```powershell
# 1. Analyse pré-migration
$sourceOU = "OU=Comptabilité,OU=Europe,DC=computerelectronics,DC=be"
$targetOU = "OU=Comptabilité,OU=USA,DC=computerelectronics,DC=be"

# Liste des objets à migrer
$users = Get-ADUser -Filter * -SearchBase "OU=Utilisateurs,$sourceOU"
$computers = Get-ADComputer -Filter * -SearchBase "OU=Ordinateurs,$sourceOU"

# 2. Migration des objets
foreach ($user in $users) {
    # Déplacement de l'utilisateur
    Move-ADObject -Identity $user.DistinguishedName `
                 -TargetPath "OU=Utilisateurs,$targetOU"
    
    Write-Host "Utilisateur migré: $($user.Name)"
}

foreach ($computer in $computers) {
    # Déplacement de l'ordinateur
    Move-ADObject -Identity $computer.DistinguishedName `
                 -TargetPath "OU=Ordinateurs,$targetOU"
    
    Write-Host "Ordinateur migré: $($computer.Name)"
}

# 3. Vérification post-migration
$movedUsers = Get-ADUser -Filter * -SearchBase "OU=Utilisateurs,$targetOU"
$movedComputers = Get-ADComputer -Filter * -SearchBase "OU=Ordinateurs,$targetOU"

Write-Host "\nRésumé de la migration:"
Write-Host "Utilisateurs migrés: $($movedUsers.Count)"
Write-Host "Ordinateurs migrés: $($movedComputers.Count)"
```
</details>

Pour de divisions départementales, on va créer des OUs et pas de sous-domains.

Cette structure nous permettra de :
1. Organiser les ordinateurs par département
2. Regrouper les utilisateurs par service
3. Appliquer des stratégies différentes selon les besoins


### 2.2. Exercice pratique - Création de la structure de base

1. **Objectif** : Créer la structure d'OUs pour notre laboratoire
2. **Outils** : Utilisateurs et ordinateurs Active Directory (dsa.msc)
3. **Note importante** : 
   - Par défaut, Active Directory crée certains conteneurs prédéfinis, dont 'Computers'
   - Ces conteneurs par défaut ne sont pas des OUs et ont des fonctionnalités limitées
   - Nous allons créer notre propre structure d'OUs pour une meilleure organisation
4. **Étapes** :
   ```
   a. Ouvrez 'Utilisateurs et ordinateurs Active Directory'
   b. Cliquez-droit sur le domaine -> Nouveau -> Unité d'organisation
   c. Créez les OUs départementales (Comptabilité, RH, Ventes)
   d. Dans chaque OU départementale, créez une sous-OU 'Ordinateurs'
   ```
5. **Validation** : 
   - Vérifiez que la structure correspond au schéma
   - Ne pas confondre avec le conteneur 'Computers' par défaut

### 2.3. Exercice pratique - Délégation d'administration

1. **Scénario** : Le responsable RH doit pouvoir gérer les comptes et ordinateurs de son service
2. **Objectif** : Déléguer les droits d'administration sur l'OU 'RH' 
3. **Étapes** :
   ```
   a. Créez un compte pour le responsable RH (voir chapitre 3.5)
   b. Cliquez-droit sur l'OU RH -> Déléguer le contrôle
   c. Sélectionnez le compte du responsable RH
   d. Accordez les droits de :
      - Création/suppression de comptes utilisateur dans 'RH/Utilisateurs'
      - Réinitialisation des mots de passe
      - Gestion des ordinateurs dans 'RH/Ordinateurs'
   ```
4. **Test** : 
   - Connectez-vous avec le compte RH
   - Vérifiez que vous pouvez gérer les utilisateurs et les ordinateurs
   - Vérifiez que vous ne pouvez pas accéder aux autres départements

### 2.4. Exercice pratique - Migration d'objets

1. **Scénario** : Un utilisateur change de département (Comptabilité → RH)
2. **Objectif** : Déplacer le compte utilisateur et son poste de travail
3. **Étapes** :
   ```
   a. Identifiez l'utilisateur dans 'Comptabilité/Utilisateurs'
   b. Identifiez son poste de travail dans 'Comptabilité/Ordinateurs'
   c. Déplacez le compte utilisateur vers 'RH/Utilisateurs'
   d. Déplacez le poste de travail vers 'RH/Ordinateurs'
   e. Vérifiez que les stratégies de groupe s'appliquent correctement
   ```
4. **Validation** : 
   - L'utilisateur doit avoir accès aux ressources RH
   - L'ordinateur doit avoir les configurations du département RH

## 3. Bonnes pratiques pour la gestion des OUs

1. **Nommage cohérent**
   - Utilisez des noms descriptifs et professionnels (Utilisateurs, Ordinateurs)
   - Évitez les caractères spéciaux sauf les accents nécessaires (é)
   - Gardez une convention de nommage cohérente avec la langue choisie

2. **Structure logique**
   - Limitez la profondeur à 3-4 niveaux maximum
   - Groupez par fonction plutôt que par localisation
   - Pensez à la facilité de délégation

3. **Sécurité**
   - Appliquez le principe du moindre privilège
   - Documentez toutes les délégations
   - Auditez régulièrement les permissions
   - Gérez les accès aux ressources partagées (voir chapitre [3.1 Gestion des Utilisateurs, Groupes et Permissions](3.1.User_Groups_and_Permissions.md#4-permissions-et-partages))

## 4. Exercice final - Restructuration complète

**Scénario** : L'entreprise souhaite déplacer les comptes administratifs dans une nouvelle OU dédiée

1. **Planification**
   - Identifiez tous les comptes administratifs
   - Planifiez la nouvelle structure sous Infrastructure/AdminComptes
   - Listez les groupes de sécurité nécessaires

2. **Implémentation**
   ```
   a. Dans Infrastructure/AdminComptes, créez les sous-OUs :
      - AdminDomaine (pour les administrateurs AD)
      - AdminDépartements (pour les responsables de service)
   b. Créez les groupes de sécurité correspondants
   c. Migrez les comptes administratifs
   d. Mettez à jour les délégations de contrôle
   ```

3. **Test et validation**
   - Vérifiez les permissions
   - Testez la création de comptes
   - Confirmez l'application des stratégies

4. **Documentation**
   - Mettez à jour le schéma d'OUs
   - Documentez les nouvelles délégations
   - Notez les stratégies appliquées
    ├── IT
    └── Standard Users
```

### 2.2. Création des OUs

1. Ouvrez "Utilisateurs et ordinateurs Active Directory" :
   ```
   Gestionnaire de serveur -> Outils -> Utilisateurs et ordinateurs Active Directory
   ```

2. Créez les OUs principales :
   - Clic droit sur `computerelectronics.be` -> Nouveau -> Unité d'organisation
   - Créez dans l'ordre :
     ```
     OU=Computers
     OU=Users
     ```

3. Créez les sous-OUs :
   - Dans `Computers` :
     ```
     OU=Clients
     OU=Servers
     ```
   - Dans `Users` :
     ```
     OU=IT
     OU=Standard Users
     ```

## 3. Exercices Pratiques

### 3.1. Organisation des Objets

1. Déplacez les objets existants :
   - Déplacez le DC `dns1` vers `Computers/Servers`
   - Déplacez `ws-compta-01` et `ws-rh-01` vers `Computers/Clients`

2. Créez des utilisateurs de test :
   - Dans `Users/IT` :
     ```
     CN=Admin IT,OU=IT,OU=Users,DC=computerelectronics,DC=be
     ```
   - Dans `Users/Standard Users` :
     ```
     CN=User1,OU=Standard Users,OU=Users,DC=computerelectronics,DC=be
     CN=User2,OU=Standard Users,OU=Users,DC=computerelectronics,DC=be
     ```

### 3.2. Délégation d'Administration

1. Donnez des droits à l'Admin IT :
   - Clic droit sur OU=Standard Users -> Déléguer le contrôle
   - Ajoutez l'utilisateur Admin IT
   - Sélectionnez :
     - Réinitialiser les mots de passe utilisateur
     - Créer, supprimer et gérer les comptes d'utilisateurs

2. Test de délégation :
   - Connectez-vous en tant qu'Admin IT
   - Essayez de créer un nouvel utilisateur dans Standard Users
   - Réinitialisez le mot de passe d'un utilisateur existant

## 4. Bonnes Pratiques

1. Protection des OUs :
   ```powershell
   Set-ADOrganizationalUnit -Identity "OU=IT,OU=Users,DC=computerelectronics,DC=be" -ProtectedFromAccidentalDeletion $true
   ```

2. Nommage :
   - Utilisez des noms courts mais descriptifs
   - Évitez les caractères spéciaux
   - Maintenez une convention cohérente
