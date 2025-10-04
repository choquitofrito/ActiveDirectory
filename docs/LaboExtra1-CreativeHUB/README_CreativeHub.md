# Laboratoire Active Directory: Agence CreativeHub

## Objectifs Pédagogiques

À la fin de ce laboratoire, les étudiants seront capables de:

1. **Comprendre la structure organisationnelle d'un Active Directory** en explorant une hiérarchie d'OUs représentant une vraie entreprise
2. **Gérer les comptes utilisateurs** et comprendre l'importance des attributs (email, titre, département)
3. **Utiliser les groupes de sécurité** pour organiser les permissions et distinguer entre groupes d'utilisateurs et groupes d'administrateurs
4. **Configurer et appliquer des Stratégies de Groupe (GPOs)** pour implémenter des politiques de sécurité adaptées à différents départements

## Scénario Entreprise

**CreativeHub** est une petite agence de marketing digital et design située en Belgique, comptant 18 employés répartis dans 4 départements. L'agence offre des services complets de communication digitale à ses clients:

### Contexte Business

- **Nom de l'entreprise**: CreativeHub
- **Secteur**: Marketing digital, design graphique, développement web, production vidéo
- **Taille**: 18 employés permanents
- **Clients**: PME belges et européennes nécessitant des services de communication digitale

### Structure Départementale

L'agence est organisée en 4 départements spécialisés:

#### 1. **Marketing** (5 employés)
Responsable de la stratégie digitale, gestion des réseaux sociaux, SEO/SEM, et création de contenu pour les clients.

**Employés**:
- **Camille Bernard** - Responsable Marketing Digital (Admin)
- **Amélie Dubois** - Community Manager
- **Bastien Martin** - Spécialiste SEO
- **Damien Petit** - Content Strategist
- **Élise Robert** - Social Media Analyst

#### 2. **Creative** (5 employés)
L'équipe créative produit tous les visuels, vidéos et designs pour les campagnes clients.

**Employés**:
- **Fabien Moreau** - Graphiste Senior (Admin)
- **Gabrielle Simon** - Directrice Artistique
- **Hugo Laurent** - Motion Designer
- **Inès Lefebvre** - Vidéaste
- **Julien Roux** - Designer UX/UI

#### 3. **Client Services** (4 employés)
Département gérant les relations clients, gestion de projets, et coordination entre les équipes techniques et créatives.

**Employés**:
- **Karine Garnier** - Chef de Projet Senior (Admin)
- **Laurent Faure** - Account Manager
- **Manon Girard** - Chef de Projet Junior
- **Nicolas André** - Directeur des Opérations

**Note de sécurité**: Ce département manipule des données clients sensibles (contrats, budgets, informations stratégiques) nécessitant des mesures de sécurité renforcées.

#### 4. **IT Support** (4 employés)
Équipe technique responsable du développement web, maintenance de l'infrastructure IT, et support aux autres départements.

**Employés**:
- **Olivier Mercier** - Développeur Web Full-Stack (Admin)
- **Pauline Blanc** - Administratrice Systèmes
- **Quentin Guerin** - Développeur Front-End
- **Rachid Dupont** - Responsable IT

### Besoins de Sécurité

1. **Protection des données clients**: Le département Client Services gère des informations sensibles nécessitant des restrictions d'accès (blocage USB)
2. **Contrôle des juniors**: Les employés juniors (stagiaires, nouvelles recrues) ont besoin de restrictions pour éviter les modifications système accidentelles
3. **Collaboration**: Tous les départements doivent accéder à des ressources partagées (projets clients, bibliothèque de ressources créatives)
4. **Gestion des permissions**: Chaque département a besoin d'administrateurs locaux pour gérer leurs équipes

---

## Durée Estimée

- **Exécution du script**: 10-15 minutes (avec confirmations interactives)
- **Exploration manuelle post-installation**: 20-30 minutes
- **Exercices pratiques suggérés**: 1-2 heures

**Total**: Environ 2 heures pour un laboratoire complet

---

## Prérequis

- Windows Server 2022 avec rôle **AD DS (Active Directory Domain Services)** installé
- Domaine **maxtec.be** déployé et fonctionnel
- PowerShell ISE ouvert en tant qu'**Administrateur**
- Module PowerShell **ActiveDirectory** disponible (installé automatiquement avec AD DS)
- Module PowerShell **GroupPolicy** disponible (installé automatiquement avec AD DS)

### Vérification des Prérequis

Avant d'exécuter le script, vérifiez que votre environnement est prêt:

```powershell
# Vérifier que le rôle AD DS est installé
Get-WindowsFeature -Name AD-Domain-Services

# Vérifier le domaine actuel
Get-ADDomain

# Vérifier les modules PowerShell
Get-Module -ListAvailable -Name ActiveDirectory, GroupPolicy

# Vérifier vos privilèges administratifs
whoami /groups | findstr "Admins"
```

---

## Structure Créée par le Script

### Arborescence des Unités Organisationnelles (OUs)

```
DC=maxtec,DC=be
└── OU=CreativeHub
    ├── OU=Marketing
    │   ├── OU=Users
    │   ├── OU=Computers
    │   └── OU=Groups
    ├── OU=Creative
    │   ├── OU=Users
    │   ├── OU=Computers
    │   └── OU=Groups
    ├── OU=ClientServices
    │   ├── OU=Users
    │   ├── OU=Computers
    │   └── OU=Groups
    └── OU=ITSupport
        ├── OU=Users
        ├── OU=Computers
        └── OU=Groups
```

**Total**: 1 OU racine + 4 OUs départementales + 12 sous-OUs = **17 Unités Organisationnelles**

### Utilisateurs

Le script crée **18 comptes utilisateurs** avec les attributs suivants:

| Nom Complet | Login (SAM) | Email | Département | Titre/Poste | Mot de passe |
|-------------|-------------|-------|-------------|-------------|--------------|
| **MARKETING** |
| Amélie Dubois | amelie | amelie@maxtec.be | Marketing | Community Manager | Password1! |
| Bastien Martin | bastien | bastien@maxtec.be | Marketing | Spécialiste SEO | Password1! |
| Camille Bernard | camille | camille@maxtec.be | Marketing | Responsable Marketing Digital | Password1! |
| Damien Petit | damien | damien@maxtec.be | Marketing | Content Strategist | Password1! |
| Élise Robert | elise | elise@maxtec.be | Marketing | Social Media Analyst | Password1! |
| **CREATIVE** |
| Fabien Moreau | fabien | fabien@maxtec.be | Creative | Graphiste Senior | Password1! |
| Gabrielle Simon | gabrielle | gabrielle@maxtec.be | Creative | Directrice Artistique | Password1! |
| Hugo Laurent | hugo | hugo@maxtec.be | Creative | Motion Designer | Password1! |
| Inès Lefebvre | ines | ines@maxtec.be | Creative | Vidéaste | Password1! |
| Julien Roux | julien | julien@maxtec.be | Creative | Designer UX/UI | Password1! |
| **CLIENT SERVICES** |
| Karine Garnier | karine | karine@maxtec.be | ClientServices | Chef de Projet Senior | Password1! |
| Laurent Faure | laurent | laurent@maxtec.be | ClientServices | Account Manager | Password1! |
| Manon Girard | manon | manon@maxtec.be | ClientServices | Chef de Projet Junior | Password1! |
| Nicolas André | nicolas | nicolas@maxtec.be | ClientServices | Directeur des Opérations | Password1! |
| **IT SUPPORT** |
| Olivier Mercier | olivier | olivier@maxtec.be | ITSupport | Développeur Web Full-Stack | Password1! |
| Pauline Blanc | pauline | pauline@maxtec.be | ITSupport | Administratrice Systèmes | Password1! |
| Quentin Guerin | quentin | quentin@maxtec.be | ITSupport | Développeur Front-End | Password1! |
| Rachid Dupont | rachid | rachid@maxtec.be | ITSupport | Responsable IT | Password1! |

**Tous les comptes**:
- Sont **activés** par défaut
- Utilisent le mot de passe: `Password1!`
- N'exigent **pas** de changement de mot de passe à la première connexion (pour faciliter les tests)
- Ont des adresses email au format `prenom@maxtec.be`

### Groupes de Sécurité

Le script crée **8 groupes de sécurité globaux** (Global Groups):

| Nom du Groupe | Type | Emplacement | Description | Membres |
|---------------|------|-------------|-------------|---------|
| **GG-CreativeHub-Marketing-Users** | Global Security | OU=Groups,OU=Marketing | Tous les utilisateurs Marketing | amelie, bastien, camille, damien, elise (5) |
| **GG-CreativeHub-Marketing-Admin** | Global Security | OU=Groups,OU=Marketing | Administrateurs Marketing | amelie (1er alphabétique) |
| **GG-CreativeHub-Creative-Users** | Global Security | OU=Groups,OU=Creative | Tous les utilisateurs Creative | fabien, gabrielle, hugo, ines, julien (5) |
| **GG-CreativeHub-Creative-Admin** | Global Security | OU=Groups,OU=Creative | Administrateurs Creative | fabien (1er alphabétique) |
| **GG-CreativeHub-ClientServices-Users** | Global Security | OU=Groups,OU=ClientServices | Tous les utilisateurs Client Services | karine, laurent, manon, nicolas (4) |
| **GG-CreativeHub-ClientServices-Admin** | Global Security | OU=Groups,OU=ClientServices | Administrateurs Client Services | karine (1er alphabétique) |
| **GG-CreativeHub-ITSupport-Users** | Global Security | OU=Groups,OU=ITSupport | Tous les utilisateurs IT Support | olivier, pauline, quentin, rachid (4) |
| **GG-CreativeHub-ITSupport-Admin** | Global Security | OU=Groups,OU=ITSupport | Administrateurs IT Support | olivier (1er alphabétique) |

**Convention de nommage**: `GG-[Entreprise]-[Département]-[Rôle]`
- **GG** = Global Group (groupe global)
- **Entreprise** = CreativeHub
- **Département** = Marketing, Creative, ClientServices, ITSupport
- **Rôle** = Users (tous les utilisateurs) ou Admin (administrateurs)

**Logique d'appartenance automatique**:
- TOUS les utilisateurs d'un département sont ajoutés au groupe `-Users`
- Le PREMIER utilisateur par ordre alphabétique devient automatiquement membre du groupe `-Admin`

### Stratégies de Groupe (GPOs)

Le script crée et configure **3 GPOs** démontrant des cas d'usage courants en entreprise:

#### GPO 1: **CreativeHub - Restrictions Utilisateurs Juniors**

**Objectif pédagogique**: Protéger le système contre les modifications accidentelles par des utilisateurs inexpérimentés

**Configuration**:
- **Désactive le Panneau de configuration** (`NoControlPanel=1`)
  - Clé de registre: `HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer`
- **Désactive l'invite de commandes** (`DisableCMD=2`)
  - Clé de registre: `HKCU\Software\Policies\Microsoft\Windows\System`

**Liée à**:
- `OU=Users,OU=Marketing,OU=CreativeHub,DC=maxtec,DC=be`
- `OU=Users,OU=Creative,OU=CreativeHub,DC=maxtec,DC=be`

**Raison business**: Les équipes Marketing et Creative ont souvent des stagiaires ou juniors qui ont besoin d'accéder aux applications métier (Adobe Creative Suite, outils marketing) mais ne doivent pas modifier les paramètres système.

#### GPO 2: **CreativeHub - Blocage USB Client Services**

**Objectif pédagogique**: Protéger les données sensibles contre l'exfiltration via périphériques USB

**Configuration**:
- **Bloque la lecture depuis périphériques USB** (`Deny_Read=1`)
- **Bloque l'écriture vers périphériques USB** (`Deny_Write=1`)
- Clé de registre: `HKLM\Software\Policies\Microsoft\Windows\RemovableStorageDevices\{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}`
- GUID `{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}` = Removable Disks (disques amovibles)

**Liée à**:
- `OU=Users,OU=ClientServices,OU=CreativeHub,DC=maxtec,DC=be`

**Raison business**: Le département Client Services manipule des contrats clients, informations budgétaires sensibles, et données stratégiques qui ne doivent jamais quitter l'infrastructure sécurisée de l'entreprise.

#### GPO 3: **CreativeHub - Lecteurs Réseau Partagés**

**Objectif pédagogique**: Faciliter l'accès aux ressources partagées via mappage de lecteurs réseau

**Configuration**:
- GPO créée mais nécessite configuration manuelle via Group Policy Preferences
- Lecteurs suggérés:
  - **P:** → `\\SERVEUR\Projets` (dossiers projets clients)
  - **R:** → `\\SERVEUR\Ressources` (bibliothèque d'assets créatifs, templates, logos clients)

**Liée à**:
- `OU=CreativeHub,DC=maxtec,DC=be` (tous les départements)

**Raison business**: Tous les employés doivent accéder facilement aux projets clients en cours et à la bibliothèque de ressources créatives partagées (images, vidéos, templates).

**Note importante**: Le mappage de lecteurs réseau via GPO nécessite:
1. Création des partages réseau sur le serveur de fichiers (à faire manuellement)
2. Configuration via **Group Policy Management Console (GPMC)** → User Configuration → Preferences → Windows Settings → Drive Maps

---

## Instructions d'Exécution

### Étape 1: Préparation

1. **Connectez-vous** au contrôleur de domaine Windows Server 2022 en tant qu'Administrateur du domaine
2. **Ouvrez PowerShell ISE** avec privilèges administratifs:
   - Clic droit sur "Windows PowerShell ISE" → **Exécuter en tant qu'administrateur**
3. **Copiez** le fichier `CreativeHub_Setup.ps1` sur le serveur (par exemple dans `C:\Labos\`)

### Étape 2: Exécution du Script

1. Dans PowerShell ISE, ouvrez le fichier `CreativeHub_Setup.ps1`:
   ```powershell
   # Si le fichier est dans C:\Labos\
   cd C:\Labos
   .\CreativeHub_Setup.ps1
   ```

2. **Ou** copiez-collez tout le contenu du script dans la fenêtre de script PowerShell ISE

3. Appuyez sur **F5** pour exécuter le script

4. Le script vous demandera confirmation avant chaque étape majeure:
   - **O** = Continuer avec cette étape
   - **N** = Sauter cette étape
   - **Q** = Quitter le script complètement

### Étape 3: Observation

Pendant l'exécution, observez la sortie console avec attention:

- **Texte vert** = Succès (objet créé)
- **Texte jaune** = Avertissement (objet existe déjà, ou action nécessitant attention)
- **Texte rouge** = Erreur
- **Texte cyan/bleu** = Informations générales
- **Texte gris** = Détails techniques

Le script affiche des messages détaillés pour chaque action, ce qui permet de comprendre ce qui se passe dans Active Directory.

### Étape 4: Vérification

À la fin de l'exécution, le script affiche un récapitulatif complet et exporte 3 fichiers CSV dans `C:\Labos\`:

- `CreativeHub_Utilisateurs.csv` - Liste complète des utilisateurs
- `CreativeHub_Groupes.csv` - Liste des groupes avec leurs membres
- `CreativeHub_OUs.csv` - Structure des Unités Organisationnelles

---

## Vérification Post-Exécution

### 1. Vérification Graphique (Interface Windows)

#### Vérifier les OUs et Utilisateurs

1. Ouvrez **Utilisateurs et ordinateurs Active Directory** (dsa.msc):
   - Menu Démarrer → Outils d'administration → Utilisateurs et ordinateurs Active Directory
   - Ou: `Win + R` → `dsa.msc` → Entrée

2. Développez l'arborescence:
   ```
   maxtec.be
   └── CreativeHub
       ├── Marketing
       │   ├── Users (5 utilisateurs)
       │   ├── Computers (vide)
       │   └── Groups (2 groupes)
       ├── Creative
       │   ├── Users (5 utilisateurs)
       │   ├── Computers (vide)
       │   └── Groups (2 groupes)
       ├── ClientServices
       │   ├── Users (4 utilisateurs)
       │   ├── Computers (vide)
       │   └── Groups (2 groupes)
       └── ITSupport
           ├── Users (4 utilisateurs)
           ├── Computers (vide)
           └── Groups (2 groupes)
   ```

3. **Double-cliquez** sur un utilisateur (par exemple: Amélie Dubois) pour voir ses propriétés:
   - Onglet **Général**: Nom, Email
   - Onglet **Compte**: Login (amelie), UPN (amelie@maxtec.be)
   - Onglet **Organisation**: Titre (Community Manager), Département (Marketing)
   - Onglet **Membre de**: Devrait montrer `GG-CreativeHub-Marketing-Users` et `GG-CreativeHub-Marketing-Admin`

#### Vérifier les Groupes

1. Dans le même outil, naviguez vers `OU=Groups,OU=Marketing,OU=CreativeHub`
2. Double-cliquez sur **GG-CreativeHub-Marketing-Users**
3. Onglet **Membres**: Devrait afficher les 5 utilisateurs Marketing
4. Vérifiez de même pour **GG-CreativeHub-Marketing-Admin** (devrait contenir seulement "amelie")

#### Vérifier les GPOs

1. Ouvrez **Gestion de stratégie de groupe** (gpmc.msc):
   - Menu Démarrer → Outils d'administration → Gestion de stratégie de groupe
   - Ou: `Win + R` → `gpmc.msc` → Entrée

2. Développez:
   ```
   Gestion de stratégie de groupe
   └── Forêt: maxtec.be
       └── Domaines
           └── maxtec.be
               └── CreativeHub
   ```

3. Sous **Objets de stratégie de groupe**, vous devriez voir:
   - CreativeHub - Restrictions Utilisateurs Juniors
   - CreativeHub - Blocage USB Client Services
   - CreativeHub - Lecteurs Réseau Partagés

4. Cliquez sur une GPO → Onglet **Étendue**:
   - Vérifiez les **Liaisons** (à quelles OUs la GPO est liée)
   - Vérifiez le **Filtrage de sécurité** (par défaut: Utilisateurs authentifiés)

5. Onglet **Paramètres** → Afficher tout:
   - Vous verrez les paramètres de registre configurés

### 2. Vérification PowerShell

#### Vérifier toutes les OUs créées

```powershell
# Lister toutes les OUs sous CreativeHub
Get-ADOrganizationalUnit -Filter * -SearchBase "OU=CreativeHub,DC=maxtec,DC=be" |
    Select-Object Name, DistinguishedName |
    Sort-Object DistinguishedName
```

**Résultat attendu**: 16 OUs (4 départements × 3 sous-OUs + 4 départements)

#### Vérifier tous les utilisateurs créés

```powershell
# Lister tous les utilisateurs avec leurs attributs
Get-ADUser -Filter * -SearchBase "OU=CreativeHub,DC=maxtec,DC=be" -Properties EmailAddress, Title, Department |
    Select-Object Name, SamAccountName, EmailAddress, Title, Department, Enabled |
    Sort-Object Department, Name |
    Format-Table -AutoSize
```

**Résultat attendu**: 18 utilisateurs avec tous les attributs remplis

#### Vérifier les groupes et leurs membres

```powershell
# Pour chaque groupe, afficher ses membres
Get-ADGroup -Filter * -SearchBase "OU=CreativeHub,DC=maxtec,DC=be" |
    ForEach-Object {
        Write-Host "`nGroupe: $($_.Name)" -ForegroundColor Cyan
        Write-Host "Description: $($_.Description)" -ForegroundColor Gray
        Get-ADGroupMember -Identity $_.Name |
            Select-Object Name, SamAccountName |
            Format-Table -AutoSize
    }
```

**Résultat attendu**: 8 groupes avec les membres corrects

#### Vérifier les appartenances d'un utilisateur spécifique

```powershell
# Voir tous les groupes auxquels Amélie appartient
Get-ADUser -Identity amelie -Properties MemberOf |
    Select-Object -ExpandProperty MemberOf
```

**Résultat attendu**:
- `CN=GG-CreativeHub-Marketing-Users,OU=Groups,OU=Marketing,OU=CreativeHub,DC=maxtec,DC=be`
- `CN=GG-CreativeHub-Marketing-Admin,OU=Groups,OU=Marketing,OU=CreativeHub,DC=maxtec,DC=be`

#### Vérifier les GPOs créées

```powershell
# Lister les GPOs CreativeHub
Get-GPO -All | Where-Object {$_.DisplayName -like "*CreativeHub*"} |
    Select-Object DisplayName, GpoStatus, CreationTime |
    Format-Table -AutoSize
```

**Résultat attendu**: 3 GPOs avec statut "AllSettingsEnabled"

#### Vérifier les liens GPO sur une OU spécifique

```powershell
# Voir quelles GPOs sont appliquées à l'OU Marketing Users
Get-GPInheritance -Target "OU=Users,OU=Marketing,OU=CreativeHub,DC=maxtec,DC=be" |
    Select-Object -ExpandProperty GpoLinks |
    Select-Object DisplayName, Enabled, Enforced, Order
```

**Résultat attendu**: GPO "CreativeHub - Restrictions Utilisateurs Juniors" liée et activée

#### Vérifier les paramètres d'une GPO spécifique

```powershell
# Voir les valeurs de registre configurées dans la GPO restrictions
Get-GPRegistryValue -Name "CreativeHub - Restrictions Utilisateurs Juniors" -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
```

**Résultat attendu**: `NoControlPanel` avec valeur `1`

### 3. Export de la Structure pour Documentation

#### Exporter tous les utilisateurs en CSV

```powershell
# Export enrichi avec toutes les propriétés utiles
Get-ADUser -Filter * -SearchBase "OU=CreativeHub,DC=maxtec,DC=be" -Properties * |
    Select-Object Name, SamAccountName, EmailAddress, Title, Department, Enabled, WhenCreated, DistinguishedName |
    Export-Csv -Path "C:\Labos\CreativeHub_Utilisateurs_Complet.csv" -NoTypeInformation -Encoding UTF8

Write-Host "Export réussi: C:\Labos\CreativeHub_Utilisateurs_Complet.csv" -ForegroundColor Green
```

#### Exporter les groupes avec détails des membres

```powershell
# Créer un rapport détaillé des groupes
$groupReport = @()

Get-ADGroup -Filter * -SearchBase "OU=CreativeHub,DC=maxtec,DC=be" | ForEach-Object {
    $group = $_
    $members = Get-ADGroupMember -Identity $group | Select-Object -ExpandProperty SamAccountName

    $groupReport += [PSCustomObject]@{
        NomGroupe = $group.Name
        Description = $group.Description
        Portee = $group.GroupScope
        Categorie = $group.GroupCategory
        NombreMembres = $members.Count
        ListeMembres = ($members -join ", ")
        DN = $group.DistinguishedName
    }
}

$groupReport | Export-Csv -Path "C:\Labos\CreativeHub_Groupes_Rapport.csv" -NoTypeInformation -Encoding UTF8

Write-Host "Export réussi: C:\Labos\CreativeHub_Groupes_Rapport.csv" -ForegroundColor Green
```

#### Générer un rapport GPO complet

```powershell
# Créer des rapports HTML pour chaque GPO CreativeHub
$gpoNames = @(
    "CreativeHub - Restrictions Utilisateurs Juniors",
    "CreativeHub - Blocage USB Client Services",
    "CreativeHub - Lecteurs Réseau Partagés"
)

foreach ($gpoName in $gpoNames) {
    $fileName = $gpoName -replace " ", "_" -replace "-", ""
    $reportPath = "C:\Labos\GPO_$fileName.html"

    Get-GPOReport -Name $gpoName -ReportType Html -Path $reportPath
    Write-Host "Rapport GPO généré: $reportPath" -ForegroundColor Green
}
```

---

## Concepts Clés Démontrés

Ce laboratoire illustre plusieurs concepts fondamentaux d'Active Directory:

### 1. **Hiérarchie Organisationnelle (OUs)**

- **Structure en arbre** reflétant l'organigramme de l'entreprise
- **Délégation**: Chaque département peut avoir des administrateurs distincts
- **Séparation Users/Computers/Groups**: Bonne pratique pour organiser les objets AD
- **Protection contre suppression**: Désactivée pour faciliter la gestion en labo (à activer en production)

### 2. **Gestion des Identités (Users)**

- **Attributs standardisés**: Prénom, Nom, Email, Titre, Département
- **Convention de nommage**: Login = prénom en minuscule (simple et mémorable)
- **UPN (User Principal Name)**: Format email moderne pour la connexion
- **Comptes activés**: Prêts à l'emploi pour des tests immédiats

### 3. **Groupes de Sécurité**

- **Portée Global (GG-)**: Utilisée pour regrouper des utilisateurs d'un même domaine
- **Distinction Users/Admin**: Séparation claire entre utilisateurs standards et administrateurs
- **Appartenance automatique**: Tous les utilisateurs d'un département dans le groupe `-Users`
- **Principe du moindre privilège**: Seul le premier utilisateur (alphabétiquement) devient Admin

### 4. **Stratégies de Groupe (GPOs)**

- **Configuration centralisée**: Modification de paramètres Windows sans intervention manuelle sur chaque PC
- **Ciblage par OU**: Différentes politiques pour différents départements (sécurité adaptée)
- **Paramètres de registre**: Utilisation de `Set-GPRegistryValue` pour configurer Windows
- **Héritage et liaison**: Comprendre comment les GPOs s'appliquent dans la hiérarchie AD

### 5. **Sécurité et Conformité**

- **Restriction USB**: Prévention de l'exfiltration de données sensibles
- **Limitation accès système**: Protection contre modifications accidentelles par juniors
- **Partages réseau**: Centralisation des données pour backup et contrôle d'accès

---

## Exercices Manuels Suggérés

Après avoir exécuté le script, les étudiants peuvent approfondir leur apprentissage avec ces exercices pratiques:

### Exercice 1: Gestion des Utilisateurs (Débutant)

**Durée**: 15 minutes

**Tâches**:

1. **Créer un nouvel utilisateur** dans le département Creative:
   - Nom: Sophie Durand
   - Login: sophie
   - Email: sophie@maxtec.be
   - Titre: Graphiste Junior
   - OU: `OU=Users,OU=Creative,OU=CreativeHub,DC=maxtec,DC=be`
   - Mot de passe: Password1!

2. **Ajouter Sophie aux groupes appropriés**:
   - `GG-CreativeHub-Creative-Users`

3. **Désactiver le compte** d'un employé qui part en congé (par exemple: Bastien Martin)

4. **Réactiver** le compte après simulation du retour

**Commandes PowerShell**:

```powershell
# Créer Sophie
New-ADUser -Name "Sophie Durand" -GivenName "Sophie" -Surname "Durand" `
    -SamAccountName "sophie" -UserPrincipalName "sophie@maxtec.be" `
    -EmailAddress "sophie@maxtec.be" -Title "Graphiste Junior" `
    -Department "Creative" `
    -Path "OU=Users,OU=Creative,OU=CreativeHub,DC=maxtec,DC=be" `
    -AccountPassword (ConvertTo-SecureString "Password1!" -AsPlainText -Force) `
    -Enabled $true

# Ajouter aux groupes
Add-ADGroupMember -Identity "GG-CreativeHub-Creative-Users" -Members sophie

# Désactiver Bastien
Disable-ADAccount -Identity bastien

# Vérifier le statut
Get-ADUser -Identity bastien | Select-Object Name, Enabled

# Réactiver Bastien
Enable-ADAccount -Identity bastien
```

### Exercice 2: Gestion des Groupes (Intermédiaire)

**Durée**: 20 minutes

**Tâches**:

1. **Créer un nouveau groupe** pour un projet inter-départemental:
   - Nom: `GG-CreativeHub-ProjetSpecial-Team`
   - Type: Global Security
   - OU: `OU=Groups,OU=Marketing,OU=CreativeHub,DC=maxtec,DC=be`

2. **Ajouter des membres** de différents départements:
   - Camille (Marketing)
   - Gabrielle (Creative)
   - Karine (Client Services)
   - Pauline (IT Support)

3. **Lister tous les membres** du groupe

4. **Retirer un membre** (par exemple: Pauline)

**Commandes PowerShell**:

```powershell
# Créer le groupe projet
New-ADGroup -Name "GG-CreativeHub-ProjetSpecial-Team" `
    -GroupScope Global -GroupCategory Security `
    -Path "OU=Groups,OU=Marketing,OU=CreativeHub,DC=maxtec,DC=be" `
    -Description "Équipe du projet spécial inter-départemental"

# Ajouter des membres
Add-ADGroupMember -Identity "GG-CreativeHub-ProjetSpecial-Team" `
    -Members camille, gabrielle, karine, pauline

# Lister les membres
Get-ADGroupMember -Identity "GG-CreativeHub-ProjetSpecial-Team" |
    Select-Object Name, SamAccountName, DistinguishedName |
    Format-Table -AutoSize

# Retirer Pauline
Remove-ADGroupMember -Identity "GG-CreativeHub-ProjetSpecial-Team" `
    -Members pauline -Confirm:$false
```

### Exercice 3: Modification des GPOs (Avancé)

**Durée**: 30 minutes

**Tâches**:

1. **Créer une nouvelle GPO** pour configurer un fond d'écran d'entreprise:
   - Nom: `CreativeHub - Fond Ecran Corporate`
   - Configurer un fond d'écran via registre
   - Lier à l'OU CreativeHub

2. **Modifier la GPO USB** pour autoriser uniquement la lecture (pas l'écriture)

3. **Créer un rapport GPO** en HTML pour documenter toutes les GPOs CreativeHub

**Commandes PowerShell**:

```powershell
# Créer nouvelle GPO pour fond d'écran
New-GPO -Name "CreativeHub - Fond Ecran Corporate" `
    -Comment "Définit le fond d'écran corporate pour tous les utilisateurs"

# Configurer le chemin du fond d'écran (exemple)
# Note: Le fichier image doit être accessible via un partage réseau
Set-GPRegistryValue -Name "CreativeHub - Fond Ecran Corporate" `
    -Key "HKCU\Control Panel\Desktop" `
    -ValueName "Wallpaper" `
    -Type String `
    -Value "\\SERVEUR\Ressources\CreativeHub_Wallpaper.jpg"

# Empêcher modification du fond d'écran
Set-GPRegistryValue -Name "CreativeHub - Fond Ecran Corporate" `
    -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop" `
    -ValueName "NoChangingWallpaper" `
    -Type DWord `
    -Value 1

# Lier à l'OU racine
New-GPLink -Name "CreativeHub - Fond Ecran Corporate" `
    -Target "OU=CreativeHub,DC=maxtec,DC=be" `
    -LinkEnabled Yes

# Modifier GPO USB pour autoriser lecture seulement
# (Supprimer la restriction de lecture, garder seulement l'écriture bloquée)
Remove-GPRegistryValue -Name "CreativeHub - Blocage USB Client Services" `
    -Key "HKLM\Software\Policies\Microsoft\Windows\RemovableStorageDevices\{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}" `
    -ValueName "Deny_Read"

# Générer rapport HTML de toutes les GPOs
Get-GPO -All | Where-Object {$_.DisplayName -like "*CreativeHub*"} | ForEach-Object {
    $fileName = "C:\Labos\GPO_" + ($_.DisplayName -replace " ", "_") + ".html"
    Get-GPOReport -Name $_.DisplayName -ReportType Html -Path $fileName
    Write-Host "Rapport créé: $fileName" -ForegroundColor Green
}
```

### Exercice 4: Test sur Client Windows (Pratique Réelle)

**Durée**: 30 minutes

**Prérequis**: 1 machine cliente Windows 10/11 jointe au domaine maxtec.be

**Tâches**:

1. **Se connecter** sur un client Windows avec le compte `amelie` (mot de passe: Password1!)

2. **Vérifier que les GPOs sont appliquées**:
   - Essayer d'ouvrir le Panneau de configuration (devrait être bloqué)
   - Essayer d'ouvrir l'invite de commandes (devrait être bloqué)

3. **Forcer la mise à jour des GPOs**:
   ```cmd
   gpupdate /force
   ```

4. **Vérifier les GPOs appliquées**:
   ```cmd
   gpresult /r
   ```

5. **Générer un rapport GPO détaillé**:
   ```cmd
   gpresult /h C:\rapport_gpo_amelie.html
   ```
   Puis ouvrir le fichier HTML dans un navigateur

6. **Se connecter avec un compte IT Support** (par exemple: rachid) et vérifier:
   - Le Panneau de configuration est accessible (GPO restrictions ne s'applique pas à IT Support)
   - Les périphériques USB fonctionnent normalement (GPO USB ne s'applique qu'à Client Services)

**Questions de réflexion**:
- Pourquoi Amélie ne peut-elle pas accéder au Panneau de configuration, mais Rachid le peut?
- Comment vérifier quelles GPOs s'appliquent à un utilisateur spécifique?
- Quel est le délai d'application des GPOs? (Réponse: 90 minutes par défaut, ou immédiat avec `gpupdate /force`)

### Exercice 5: Délégation de Permissions (Expert)

**Durée**: 45 minutes

**Objectif**: Permettre à Camille (Admin Marketing) de gérer les utilisateurs de son département sans être Administrateur de Domaine

**Tâches**:

1. **Déléguer le contrôle** de l'OU Marketing à Camille:
   - Ouvrir "Utilisateurs et ordinateurs Active Directory"
   - Clic droit sur `OU=Marketing,OU=CreativeHub`
   - Sélectionner "Délégation de contrôle..."
   - Ajouter l'utilisateur `camille`
   - Accorder les permissions: "Créer, supprimer et gérer les comptes utilisateur"

2. **Tester la délégation**:
   - Se connecter sur le serveur avec le compte `camille`
   - Ouvrir PowerShell (pas besoin d'être Admin)
   - Essayer de créer un utilisateur dans `OU=Users,OU=Marketing` (devrait réussir)
   - Essayer de créer un utilisateur dans `OU=Users,OU=Creative` (devrait échouer)

3. **Vérifier les permissions** avec PowerShell:

```powershell
# Voir les ACLs sur l'OU Marketing
(Get-Acl -Path "AD:\OU=Marketing,OU=CreativeHub,DC=maxtec,DC=be").Access |
    Where-Object {$_.IdentityReference -like "*camille*"} |
    Format-List
```

**Résultat attendu**: Camille peut gérer les utilisateurs de Marketing, mais pas d'autres départements.

---

## Dépannage

### Problèmes Courants et Solutions

| Symptôme | Cause Probable | Solution |
|----------|----------------|----------|
| **"Access denied" ou "Accès refusé"** | PowerShell ISE non lancé en tant qu'Administrateur | Fermer PowerShell ISE, clic droit → "Exécuter en tant qu'administrateur", relancer le script |
| **"Module ActiveDirectory not found"** | Module AD non chargé ou rôle AD DS non installé | Exécuter: `Import-Module ActiveDirectory` ou vérifier l'installation du rôle AD DS |
| **"OU already exists" pour toutes les OUs** | Script déjà exécuté précédemment | C'est normal si vous relancez le script. Appuyez sur 'N' pour sauter les étapes déjà faites, ou exécutez `CreativeHub_Cleanup.ps1` pour tout supprimer |
| **GPOs créées mais paramètres non appliqués sur les clients** | Délai de rafraîchissement GPO pas encore écoulé | Sur le client: exécuter `gpupdate /force` en tant qu'administrateur, puis redémarrer la session |
| **"The specified domain does not exist"** | Domaine maxtec.be non trouvé | Vérifier que vous êtes sur le contrôleur de domaine et que le domaine est fonctionnel: `Get-ADDomain` |
| **Utilisateurs créés mais pas dans les groupes** | Étape 5 du script sautée ou erreur | Relancer le script et répondre 'O' à l'étape 5, ou ajouter manuellement avec `Add-ADGroupMember` |
| **GPO liée mais ne s'applique pas à un utilisateur** | Filtrage de sécurité ou permissions insuffisantes | Vérifier dans GPMC: Onglet Délégation → S'assurer que "Utilisateurs authentifiés" a les permissions "Lecture" et "Appliquer la stratégie de groupe" |
| **Impossible de se connecter avec un compte utilisateur sur un client** | Compte pas encore répliqué, ou client pas joint au domaine | Attendre 5 minutes pour la réplication, vérifier que le client est bien joint au domaine: `nltest /dsgetdc:maxtec.be` |

### Commandes de Diagnostic

#### Vérifier l'état du domaine

```powershell
# Informations sur le domaine
Get-ADDomain | Format-List

# Vérifier le niveau fonctionnel
Get-ADDomain | Select-Object DomainMode, ForestMode

# Lister tous les contrôleurs de domaine
Get-ADDomainController -Filter * | Select-Object Name, IPv4Address, OperatingSystem
```

#### Vérifier les rôles Active Directory

```powershell
# Vérifier que le rôle AD DS est installé
Get-WindowsFeature -Name AD-Domain-Services

# Vérifier les rôles FSMO (maîtres d'opérations)
Get-ADDomain | Select-Object InfrastructureMaster, RIDMaster, PDCEmulator
Get-ADForest | Select-Object SchemaMaster, DomainNamingMaster
```

#### Vérifier les privilèges de l'utilisateur actuel

```powershell
# Voir avec quel compte vous êtes connecté
whoami

# Voir vos groupes (vérifier si vous êtes Admins du Domaine)
whoami /groups

# Vérifier les permissions sur une OU spécifique
(Get-Acl -Path "AD:\OU=CreativeHub,DC=maxtec,DC=be").Access | Format-Table IdentityReference, ActiveDirectoryRights
```

#### Vérifier la réplication AD

```powershell
# Vérifier l'état de la réplication
repadmin /replsummary

# Forcer la réplication
repadmin /syncall /AdeP
```

#### Tester la connectivité réseau avec le domaine

```powershell
# Tester la résolution DNS du domaine
nslookup maxtec.be

# Vérifier le contrôleur de domaine utilisé
nltest /dsgetdc:maxtec.be

# Tester la connexion LDAP
Test-ComputerSecureChannel -Verbose
```

---

## Nettoyage et Recommencement

### Option 1: Script de Nettoyage Automatique

Si vous souhaitez **supprimer complètement** la structure CreativeHub pour recommencer le laboratoire depuis le début:

1. Exécutez le script `CreativeHub_Cleanup.ps1`
2. Tapez **SUPPRIMER** en majuscules pour confirmer
3. Le script supprime automatiquement (dans l'ordre):
   - Tous les liens GPO
   - Toutes les GPOs CreativeHub
   - Tous les utilisateurs
   - Tous les groupes
   - Toutes les OUs (des plus profondes aux plus superficielles)

**Commande**:
```powershell
cd C:\Labos
.\CreativeHub_Cleanup.ps1
```

### Option 2: Nettoyage Manuel Sélectif

Si vous voulez supprimer uniquement certains éléments:

#### Supprimer un utilisateur spécifique

```powershell
# Supprimer Sophie Durand (créée dans l'exercice 1)
Remove-ADUser -Identity sophie -Confirm:$false
```

#### Supprimer un groupe spécifique

```powershell
# Supprimer le groupe projet (créé dans l'exercice 2)
Remove-ADGroup -Identity "GG-CreativeHub-ProjetSpecial-Team" -Confirm:$false
```

#### Supprimer une GPO spécifique

```powershell
# Supprimer d'abord les liens
Remove-GPLink -Name "CreativeHub - Fond Ecran Corporate" -Target "OU=CreativeHub,DC=maxtec,DC=be"

# Puis supprimer la GPO
Remove-GPO -Name "CreativeHub - Fond Ecran Corporate"
```

#### Supprimer une OU et tout son contenu

```powershell
# ATTENTION: Cela supprime TOUT dans l'OU (utilisateurs, groupes, sous-OUs)
$ouPath = "OU=Marketing,OU=CreativeHub,DC=maxtec,DC=be"

# Désactiver la protection
Set-ADOrganizationalUnit -Identity $ouPath -ProtectedFromAccidentalDeletion $false

# Supprimer avec tout le contenu (-Recursive)
Remove-ADOrganizationalUnit -Identity $ouPath -Recursive -Confirm:$false
```

### Option 3: Réinitialisation Complète du Domaine (Extrême)

**⚠️ ATTENTION: Utilisez uniquement en environnement de test!**

Si vous voulez **réinitialiser complètement le domaine Active Directory**:

1. Rétrogradez le contrôleur de domaine:
   ```powershell
   Uninstall-ADDSDomainController -DemoteOperationMasterRole -RemoveApplicationPartitions
   ```

2. Réinstallez AD DS et recréez le domaine maxtec.be

**Note**: Cette option est très rarement nécessaire. Le script `CreativeHub_Cleanup.ps1` devrait suffire dans 99% des cas.

---

## Fichiers Générés

Le laboratoire CreativeHub génère les fichiers suivants:

| Fichier | Emplacement | Description | Généré par |
|---------|-------------|-------------|------------|
| `CreativeHub_Utilisateurs.csv` | `C:\Labos\` | Liste de tous les utilisateurs avec propriétés | Script setup (étape 7) |
| `CreativeHub_Groupes.csv` | `C:\Labos\` | Liste des groupes avec membres | Script setup (étape 7) |
| `CreativeHub_OUs.csv` | `C:\Labos\` | Structure des OUs | Script setup (étape 7) |
| `GPO_*.html` | `C:\Labos\` | Rapports HTML des GPOs (optionnel) | Commandes de vérification |
| `CreativeHub_Utilisateurs_Complet.csv` | `C:\Labos\` | Export enrichi utilisateurs (optionnel) | Commandes de vérification |
| `CreativeHub_Groupes_Rapport.csv` | `C:\Labos\` | Rapport détaillé groupes (optionnel) | Commandes de vérification |

Tous ces fichiers sont en encodage **UTF-8** et peuvent être ouverts avec Excel, LibreOffice, ou tout éditeur de texte.

---

## Ressources Complémentaires

### Documentation Officielle Microsoft

- [Active Directory Domain Services Overview](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview)
- [New-ADOrganizationalUnit Cmdlet](https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-adorganizationalunit?view=windowsserver2022-ps)
- [New-ADUser Cmdlet](https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-aduser?view=windowsserver2025-ps)
- [New-ADGroup Cmdlet](https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-adgroup?view=windowsserver2022-ps)
- [Group Policy Management with PowerShell](https://learn.microsoft.com/en-us/powershell/module/grouppolicy/)
- [Set-GPRegistryValue Cmdlet](https://learn.microsoft.com/en-us/powershell/module/grouppolicy/set-gpregistryvalue?view=windowsserver2022-ps)

### Guides Pratiques

- [Best Practices for Organizing Active Directory](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/creating-an-organizational-unit-design)
- [Group Policy Best Practices](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/group-policy/group-policy-best-practices)
- [Active Directory Security Best Practices](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/best-practices-for-securing-active-directory)

---

## Évolutions Possibles du Laboratoire

Pour approfondir ce laboratoire dans le futur, vous pourriez:

1. **Ajouter des partages réseau réels**:
   - Créer `\\SERVEUR\Projets` et `\\SERVEUR\Ressources`
   - Configurer des permissions NTFS basées sur les groupes AD
   - Compléter la GPO de mappage de lecteurs avec Drive Maps Preferences

2. **Implémenter une politique de mots de passe renforcée**:
   - Fine-Grained Password Policy pour exiger des mots de passe plus complexes pour les admins
   - Historique des mots de passe, durée de vie maximale, etc.

3. **Ajouter des ordinateurs aux OUs Computers**:
   - Joindre des machines Windows 10/11 au domaine
   - Les déplacer dans les bonnes OUs (par département)
   - Créer des GPOs spécifiques aux ordinateurs (configuration logicielle, pare-feu, etc.)

4. **Créer des scripts de connexion (Logon Scripts)**:
   - Scripts PowerShell qui s'exécutent à la connexion de l'utilisateur
   - Mapper des imprimantes réseau selon le département
   - Afficher un message de bienvenue personnalisé

5. **Implémenter des quotas de stockage**:
   - Configurer des quotas sur les dossiers personnels utilisateurs
   - Utiliser File Server Resource Manager (FSRM)

6. **Audit et journalisation**:
   - Activer l'audit des connexions réussies/échouées
   - Audit des modifications d'objets AD (création/suppression utilisateurs)
   - Générer des rapports de sécurité

7. **Scénarios de panne et récupération**:
   - Simuler la corruption d'un compte utilisateur
   - Restaurer un objet supprimé depuis la corbeille AD
   - Gérer un compte verrouillé (lockout)

---

## Notes Pédagogiques pour Formateurs

### Public Cible

Ce laboratoire est conçu pour des **étudiants débutants** avec:
- 4 jours (28 heures) de formation AD déjà effectués
- Compréhension théorique des concepts de base (OUs, users, groups, GPOs)
- PEU ou PAS d'expérience pratique en administration système
- Certains étudiants peuvent n'avoir AUCUN background technique

### Points d'Attention

1. **Encourager la lecture du script**: Insistez pour que les étudiants LISENT les commentaires du script avant de l'exécuter, pour comprendre la logique

2. **Confirmation interactive**: Le mécanisme de confirmation étape par étape permet:
   - De ralentir les étudiants pressés qui sautent les explications
   - De donner du temps pour poser des questions
   - D'éviter la création accidentelle complète si une erreur est détectée

3. **Vérification systématique**: Après chaque étape majeure, encouragez les étudiants à:
   - Vérifier visuellement dans la console GUI (dsa.msc, gpmc.msc)
   - Exécuter les commandes PowerShell de vérification
   - Comparer leurs résultats avec les captures d'écran de la documentation

4. **Gestion des erreurs**: Si des erreurs apparaissent:
   - Ne pas paniquer (messages en rouge ne signifient pas toujours échec total)
   - Lire le message d'erreur attentivement (souvent très explicite)
   - Vérifier les prérequis (permissions, modules, domaine)

5. **Adaptation au contexte réel**: Expliquez que ce labo est une SIMPLIFICATION:
   - En production, on ne désactive jamais la protection contre suppression accidentelle des OUs
   - Les mots de passe seraient générés aléatoirement et complexes
   - Les GPOs seraient testées d'abord sur une OU pilote avant déploiement général

### Suggestions de Timing

Pour une session de 2 heures:

- **0-10 min**: Introduction au scénario CreativeHub, lecture du README
- **10-25 min**: Exécution du script avec confirmations (étapes 1-7)
- **25-45 min**: Vérification guidée (GUI + PowerShell) de la structure créée
- **45-75 min**: Exercice 1 (gestion utilisateurs) + Exercice 2 (gestion groupes)
- **75-100 min**: Exercice 4 (test sur client Windows) - le plus important!
- **100-115 min**: Questions/réponses, dépannage des problèmes rencontrés
- **115-120 min**: Nettoyage avec Cleanup.ps1 (optionnel)

### Points de Discussion

Questions à poser pendant le labo pour stimuler la réflexion:

1. **Pourquoi séparer Users/Computers/Groups** dans des OUs distinctes? (Réponse: Facilite l'application de GPOs ciblées, délégation de permissions granulaire)

2. **Pourquoi utiliser des groupes globaux (GG-) et non des groupes locaux?** (Réponse: Les groupes globaux regroupent des utilisateurs d'un même domaine, préparation pour architecture AGDLP en environnement multi-domaines)

3. **Quelle est la différence entre désactiver un compte et le supprimer?** (Réponse: Désactivation = temporaire, données conservées; Suppression = permanent, perte de SID)

4. **Pourquoi la GPO USB est liée uniquement à Client Services?** (Réponse: Sécurité des données, mais les créatifs ont besoin d'USB pour transférer gros fichiers vidéo/design)

5. **Que se passe-t-il si deux GPOs ont des paramètres contradictoires?** (Réponse: Ordre de priorité: Local > Site > Domain > OU, et "Enforced" écrase tout)

---

## Support et Contributions

### Questions Fréquentes (FAQ)

**Q: Puis-je utiliser ce laboratoire avec un autre nom de domaine?**
R: Oui, mais vous devrez modifier la variable `$domainDN` dans le script (lignes 75 et 124) pour remplacer `DC=maxtec,DC=be` par votre domaine.

**Q: Le script fonctionne-t-il sur Windows Server 2019?**
R: Oui, les cmdlets PowerShell utilisées sont compatibles avec Server 2019, 2016 et même 2012 R2.

**Q: Puis-je modifier les noms des départements?**
R: Oui, modifiez le tableau `$departments` (lignes 105, 176, 211, etc.) et adaptez la section de création des utilisateurs.

**Q: Comment ajouter plus d'utilisateurs?**
R: Ajoutez des entrées dans le tableau `$users` (lignes 122-161) en suivant le même format.

**Q: Les GPOs fonctionnent-elles immédiatement?**
R: Non, les GPOs sont appliquées lors du prochain rafraîchissement (90 min par défaut) ou immédiatement avec `gpupdate /force` sur le client.

---

## Licence et Attribution

Ce laboratoire est fourni à des fins **éducatives uniquement**.

- **Utilisation**: Libre pour formations, cours, et apprentissage personnel
- **Modification**: Vous êtes encouragés à adapter ce labo à vos besoins spécifiques
- **Attribution**: Si vous partagez ou republiez ce contenu, mentionnez la source originale

---

## Contact et Feedback

Si vous rencontrez des problèmes avec ce laboratoire ou avez des suggestions d'amélioration, veuillez:

1. Vérifier d'abord la section **Dépannage** ci-dessus
2. Exécuter les **Commandes de Diagnostic** pour identifier la cause
3. Consulter les **logs PowerShell** (sortie console du script)
4. Contacter votre formateur ou administrateur système

---

**Bonne chance avec votre laboratoire Active Directory CreativeHub!** 🚀

Ce laboratoire vous donne une expérience pratique réaliste de la gestion d'Active Directory dans un contexte d'entreprise moderne. Les compétences acquises ici sont directement transférables à l'administration de vrais environnements AD en production.
