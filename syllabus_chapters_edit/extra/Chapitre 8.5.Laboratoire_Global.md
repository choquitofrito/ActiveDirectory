# Laboratoire global d'intégration

## 1. 🔹 Présentation du scénario d'entreprise (30 min)

### Contexte de l'entreprise

Computer Electronics est une entreprise spécialisée dans la vente et la maintenance de matériel informatique. Suite à une récente expansion, l'entreprise doit restructurer son infrastructure Active Directory pour mieux refléter son organisation et améliorer la sécurité.

### Structure actuelle

- Domaine : computerelectronics.be
- Contrôleur de domaine principal : dns1.computerelectronics.be (192.168.0.2)
- Structure simple sans organisation claire
- Quelques utilisateurs et groupes créés de façon désorganisée
- Pas de stratégie de groupe cohérente

### Objectifs du projet

Vous êtes l'équipe d'administrateurs système chargée de :

1. Restructurer l'Active Directory selon les standards de l'entreprise
2. Mettre en place une gestion efficace des utilisateurs et des groupes
3. Implémenter des stratégies de groupe pour la sécurité et la configuration
4. Automatiser certaines tâches avec PowerShell

### Livrables attendus

À la fin de ce laboratoire, vous devrez avoir :

1. Une structure d'OUs conforme aux besoins de l'entreprise
2. Des utilisateurs et groupes correctement organisés
3. Des stratégies de groupe fonctionnelles
4. Des scripts PowerShell pour automatiser la gestion

## 2. 🔹 Détails du laboratoire pratique (2h30)

Le laboratoire est divisé en plusieurs parties qui peuvent être réalisées en équipe. Chaque équipe travaillera sur l'ensemble du projet.

### Partie 1 : Restructuration des OUs

#### Objectif
Créer une structure d'OUs qui reflète l'organisation géographique et départementale de l'entreprise.

#### Structure à mettre en place
```
computerelectronics.be
├── EU
│   ├── Comptabilité
│   │   ├── Utilisateurs
│   │   └── Ordinateurs
│   ├── RH
│   │   ├── Utilisateurs
│   │   └── Ordinateurs
│   ├── Ventes
│   │   ├── Utilisateurs
│   │   └── Ordinateurs
│   └── Groupes
└── US
    ├── Comptabilité
    │   ├── Utilisateurs
    │   └── Ordinateurs
    ├── RH
    │   ├── Utilisateurs
    │   └── Ordinateurs
    ├── Ventes
    │   ├── Utilisateurs
    │   └── Ordinateurs
    └── Groupes
```

#### Tâches
1. Créer les OUs principales (EU, US)
2. Créer les OUs départementales sous chaque zone géographique
3. Créer les sous-OUs pour les utilisateurs et les ordinateurs
4. Créer les OUs pour les groupes

#### Approche PowerShell
Vous pouvez utiliser l'interface graphique ou créer un script PowerShell comme celui-ci :

```powershell
# Exemple de script pour créer la structure d'OUs
$domainDN = (Get-ADDomain).DistinguishedName

# Créer les OUs géographiques
$regions = @("EU", "US")
$departements = @("Comptabilité", "RH", "Ventes")
$sousOUs = @("Utilisateurs", "Ordinateurs")

foreach ($region in $regions) {
    # Créer l'OU régionale
    New-ADOrganizationalUnit -Name $region -Path $domainDN -ProtectedFromAccidentalDeletion $true
    $regionDN = "OU=$region,$domainDN"
    
    # Créer l'OU Groupes
    New-ADOrganizationalUnit -Name "Groupes" -Path $regionDN -ProtectedFromAccidentalDeletion $true
    
    # Créer les OUs départementales
    foreach ($dept in $departements) {
        New-ADOrganizationalUnit -Name $dept -Path $regionDN -ProtectedFromAccidentalDeletion $true
        $deptDN = "OU=$dept,$regionDN"
        
        # Créer les sous-OUs
        foreach ($sousOU in $sousOUs) {
            New-ADOrganizationalUnit -Name $sousOU -Path $deptDN -ProtectedFromAccidentalDeletion $true
        }
    }
}
```

### Partie 2 : Création des utilisateurs et des groupes

#### Objectif
Créer les utilisateurs et les groupes selon les standards de l'entreprise.

#### Utilisateurs à créer
- **Comptabilité EU** : pierre.dupont (Comptable), marie.lambert (Responsable)
- **RH EU** : jean.martin (Assistant RH), sophie.dubois (Directrice RH)
- **Ventes EU** : thomas.leroy (Commercial), claire.moreau (Responsable)
- **Comptabilité US** : john.smith (Comptable), sarah.jones (Responsable)
- **RH US** : michael.brown (Assistant RH), emily.davis (Directrice RH)
- **Ventes US** : david.wilson (Commercial), jessica.taylor (Responsable)

#### Groupes à créer
- **Groupes globaux** : 
  - GG-EU-Comptabilité-Utilisateurs, GG-EU-Comptabilité-Managers
  - GG-EU-RH-Utilisateurs, GG-EU-RH-Managers
  - GG-EU-Ventes-Utilisateurs, GG-EU-Ventes-Managers
  - GG-US-Comptabilité-Utilisateurs, GG-US-Comptabilité-Managers
  - GG-US-RH-Utilisateurs, GG-US-RH-Managers
  - GG-US-Ventes-Utilisateurs, GG-US-Ventes-Managers

- **Groupes locaux de domaine** :
  - DL-EU-Rapports-Lecture, DL-EU-Rapports-Modification
  - DL-US-Rapports-Lecture, DL-US-Rapports-Modification

#### Tâches
1. Créer tous les utilisateurs dans les OUs appropriées
2. Créer tous les groupes dans les OUs de groupes
3. Ajouter les utilisateurs aux groupes appropriés
4. Configurer les propriétés des utilisateurs (titre, département, etc.)

#### Approche PowerShell
Vous pouvez utiliser l'interface graphique ou créer un script PowerShell comme celui-ci :

```powershell
# Exemple de script pour créer des utilisateurs à partir d'un CSV
$csvPath = "C:\Temp\utilisateurs.csv"

# Structure du CSV :
# Prenom,Nom,Departement,Titre,Region,EstManager
# Pierre,Dupont,Comptabilité,Comptable,EU,false
# Marie,Lambert,Comptabilité,Responsable,EU,true
# etc.

$utilisateurs = Import-Csv -Path $csvPath -Delimiter ","

foreach ($user in $utilisateurs) {
    $samAccountName = "$($user.Prenom.ToLower()).$($user.Nom.ToLower())"
    $ouPath = "OU=Utilisateurs,OU=$($user.Departement),OU=$($user.Region),DC=computerelectronics,DC=be"
    
    # Créer l'utilisateur
    New-ADUser -Name "$($user.Prenom) $($user.Nom)" `
        -GivenName $user.Prenom `
        -Surname $user.Nom `
        -SamAccountName $samAccountName `
        -UserPrincipalName "$samAccountName@computerelectronics.be" `
        -Path $ouPath `
        -AccountPassword (ConvertTo-SecureString "Password1!" -AsPlainText -Force) `
        -Enabled $true `
        -Department $user.Departement `
        -Title $user.Titre `
        -Company "Computer Electronics" `
        -EmailAddress "$samAccountName@computerelectronics.be"
    
    # Ajouter au groupe utilisateurs du département
    Add-ADGroupMember -Identity "GG-$($user.Region)-$($user.Departement)-Utilisateurs" -Members $samAccountName
    
    # Si manager, ajouter au groupe managers
    if ($user.EstManager -eq "true") {
        Add-ADGroupMember -Identity "GG-$($user.Region)-$($user.Departement)-Managers" -Members $samAccountName
    }
}
```

### Partie 3 : Configuration des stratégies de groupe

#### Objectif
Mettre en place des stratégies de groupe pour sécuriser et configurer l'environnement.

#### GPOs à créer
1. **GPO-Securite-MotDePasse** (niveau domaine)
   - Complexité du mot de passe activée
   - Longueur minimale : 8 caractères
   - Durée de validité : 90 jours

2. **GPO-Configuration-FondEcran** (niveau OUs EU et US)
   - Fond d'écran d'entreprise
   - Verrouillage de l'écran après 10 minutes

3. **GPO-Restrictions-Comptabilite** (niveau OU Comptabilité)
   - Désactivation de l'accès au panneau de configuration
   - Désactivation de l'installation de logiciels

4. **GPO-Configuration-Navigateur** (niveau OUs départementales)
   - Page d'accueil : https://intranet.computerelectronics.be
   - Proxy configuré selon la région

#### Tâches
1. Créer les GPOs avec les paramètres appropriés
2. Lier les GPOs aux OUs correspondantes
3. Tester l'application des GPOs
4. Documenter la configuration

#### Approche PowerShell
Vous pouvez utiliser l'interface graphique ou automatiser certaines tâches avec PowerShell :

```powershell
# Exemple de script pour créer et lier une GPO
# Créer la GPO de mot de passe
$gpoPwd = New-GPO -Name "GPO-Securite-MotDePasse" -Comment "Politique de mot de passe d'entreprise"

# Lier la GPO au domaine
New-GPLink -Name "GPO-Securite-MotDePasse" -Target "DC=computerelectronics,DC=be" -Order 1

# Créer la GPO de fond d'écran
$gpoWallpaper = New-GPO -Name "GPO-Configuration-FondEcran" -Comment "Configuration du fond d'écran d'entreprise"

# Lier la GPO aux OUs régionales
New-GPLink -Name "GPO-Configuration-FondEcran" -Target "OU=EU,DC=computerelectronics,DC=be" -Order 1
New-GPLink -Name "GPO-Configuration-FondEcran" -Target "OU=US,DC=computerelectronics,DC=be" -Order 1
```

### Partie 4 : Automatisation avec PowerShell

#### Objectif
Créer des scripts PowerShell pour automatiser des tâches d'administration courantes.

#### Scripts à développer
1. **Script de rapport d'audit**
   - Liste des utilisateurs par département
   - Dernière connexion des utilisateurs
   - Appartenance aux groupes

2. **Script de création d'utilisateurs en masse**
   - Importation depuis un CSV
   - Création des comptes
   - Ajout aux groupes appropriés

3. **Script de vérification des GPOs**
   - Liste des GPOs et leurs liens
   - Vérification des paramètres critiques

#### Exemple de script d'audit

```powershell
# Script d'audit des utilisateurs
$rapportPath = "C:\Temp\Audit_Utilisateurs_$(Get-Date -Format 'yyyyMMdd').csv"

# Obtenir tous les utilisateurs avec leurs propriétés
$utilisateurs = Get-ADUser -Filter * -Properties Department, LastLogonDate, Enabled, Title, Manager

# Préparer les données pour le rapport
$rapport = @()

foreach ($user in $utilisateurs) {
    # Obtenir les groupes de l'utilisateur
    $groupes = (Get-ADPrincipalGroupMembership $user.SamAccountName | 
                Where-Object { $_.Name -ne "Domain Users" } | 
                Select-Object -ExpandProperty Name) -join "; "
    
    # Obtenir le nom du manager si défini
    $managerName = ""
    if ($user.Manager) {
        $manager = Get-ADUser -Identity $user.Manager
        $managerName = $manager.Name
    }
    
    # Créer l'objet pour le rapport
    $userInfo = [PSCustomObject]@{
        Nom = $user.Name
        Compte = $user.SamAccountName
        Département = $user.Department
        Titre = $user.Title
        DernièreConnexion = if ($user.LastLogonDate) { $user.LastLogonDate } else { "Jamais" }
        Actif = $user.Enabled
        Groupes = $groupes
        Manager = $managerName
    }
    
    $rapport += $userInfo
}

# Exporter le rapport en CSV
$rapport | Export-Csv -Path $rapportPath -NoTypeInformation -Encoding UTF8

Write-Host "Rapport d'audit généré : $rapportPath" -ForegroundColor Green
```

## 3. 🔹 Présentation des solutions et discussion (30 min)

### Format de présentation

Chaque équipe présentera sa solution en mettant l'accent sur :
- Les choix d'implémentation
- Les défis rencontrés
- Les solutions trouvées
- L'utilisation de PowerShell vs interface graphique

### Points de discussion

1. **Comparaison des approches**
   - Avantages et inconvénients de l'interface graphique
   - Avantages et inconvénients de PowerShell
   - Quand utiliser l'une ou l'autre approche

2. **Bonnes pratiques identifiées**
   - Organisation des OUs
   - Nommage des objets
   - Gestion des GPOs
   - Documentation

3. **Application en environnement réel**
   - Comment adapter ces solutions à un environnement de production
   - Considérations de sécurité supplémentaires
   - Gestion des changements

## 4. 🔹 Ressources pour le laboratoire

### Fichiers fournis

- Template CSV pour l'importation d'utilisateurs
- Script de base pour la création d'OUs
- Documentation de référence pour les GPOs
- Diagramme de la structure cible

### Environnement technique

- 1 contrôleur de domaine (dns1.computerelectronics.be)
- 2 postes clients (ws-client-01, ws-client-02)
- Accès administrateur au domaine
- PowerShell avec modules AD et GroupPolicy

## 5. 🔹 Évaluation et suivi

### Critères d'évaluation

- Respect des standards de nommage
- Fonctionnalité des solutions
- Qualité des scripts PowerShell
- Travail d'équipe et communication

### Suivi post-formation

- Documentation complète fournie
- Scripts PowerShell commentés à emporter
- Ressources pour approfondir PowerShell
- Contact pour questions techniques

## 🔹 Conclusion du cours

Ce laboratoire global vous a permis de mettre en pratique l'ensemble des connaissances acquises durant cette formation sur Active Directory. Vous avez pu explorer différentes approches pour résoudre des problèmes concrets d'administration système, en combinant l'interface graphique traditionnelle et l'automatisation via PowerShell.

Les compétences développées vous permettront d'être plus efficaces dans votre travail quotidien d'administration Active Directory, en vous donnant les outils pour :
- Structurer efficacement votre environnement
- Gérer les utilisateurs et les groupes de manière cohérente
- Sécuriser votre infrastructure via les GPOs
- Automatiser les tâches répétitives

N'hésitez pas à continuer à explorer PowerShell et à développer vos propres scripts pour répondre aux besoins spécifiques de votre organisation.
