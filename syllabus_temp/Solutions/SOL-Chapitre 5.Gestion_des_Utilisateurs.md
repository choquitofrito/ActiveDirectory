# Solutions - Gestion des Utilisateurs

## Exercice 1: Création d'un Nouvel Employé

```powershell
# 1. Créer le compte utilisateur
New-ADUser -Name "Sophie Dubois" `
           -GivenName "Sophie" `
           -Surname "Dubois" `
           -SamAccountName "sophie.dubois" `
           -UserPrincipalName "sophie.dubois@maxtec.be" `
           -Path "OU=Users,OU=Comptabilité,OU=EU,DC=maxtec,DC=be" `
           -Description "Comptable Junior - Service Comptabilité" `
           -Office "Bâtiment A - 1er étage" `
           -OfficePhone "+32 2 123 45 68" `
           -Enabled $true `
           -ChangePasswordAtLogon $true

# 2. Définir le mot de passe temporaire
$password = ConvertTo-SecureString "P@ssw0rd2025!" -AsPlainText -Force
Set-ADAccountPassword -Identity "sophie.dubois" -NewPassword $password
```

## Exercice 2: Restrictions d'Accès

```powershell
# 1. Configurer les restrictions de poste de travail
Set-ADUser -Identity "sophie.dubois" -LogonWorkstations "ws-compta-01"

# 2. Définir les plages horaires
$logonHours = New-Object byte[] 21
# Configuration pour Lundi-Vendredi, 8h-18h
# Les heures sont en UTC, ajuster selon le fuseau horaire
$logonHours[0] = 0xFF  # Lundi
$logonHours[1] = 0xFF
$logonHours[2] = 0x03  # Fin à 18h
$logonHours[3] = 0xFF  # Mardi
$logonHours[4] = 0xFF
$logonHours[5] = 0x03
$logonHours[6] = 0xFF  # Mercredi
$logonHours[7] = 0xFF
$logonHours[8] = 0x03
$logonHours[9] = 0xFF  # Jeudi
$logonHours[10] = 0xFF
$logonHours[11] = 0x03
$logonHours[12] = 0xFF # Vendredi
$logonHours[13] = 0xFF
$logonHours[14] = 0x03

Set-ADUser -Identity "sophie.dubois" -LogonHours $logonHours
```

## Exercice 3: Audit de Sécurité

```powershell
# 1. Vérifier la politique de mot de passe
Get-ADDefaultDomainPasswordPolicy

# 2. Configurer l'expiration du compte dans 6 mois
$expirationDate = (Get-Date).AddMonths(6)
Set-ADAccountExpiration -Identity "sophie.dubois" -DateTime $expirationDate

# 3. Activer la journalisation des échecs de connexion
# Note: Ceci se fait via la stratégie de groupe, pas directement sur le compte
```

## Exercice 4: Désactivation d'un Compte

```powershell
# 1. Désactiver le compte
$dateDesactivation = Get-Date -Format "yyyy-MM-dd"
$dateSuppression = (Get-Date).AddDays(90).ToString("yyyy-MM-dd")
$description = "Désactivé le $dateDesactivation - Départ de l'entreprise - Suppression prévue le $dateSuppression"

Set-ADUser -Identity "jan.vandenbergh" `
           -Enabled $false `
           -Description $description

# 2. Vérifier la désactivation
Get-ADUser -Identity "jan.vandenbergh" -Properties Enabled, Description
```

## Exercice 5: Nettoyage des Accès

```powershell
# 1. Identifier les groupes
$user = Get-ADUser -Identity "jan.vandenbergh" -Properties MemberOf
$groups = $user.MemberOf | Get-ADGroup | Select-Object Name

# 2. Retirer des groupes sauf Domain Users
foreach ($group in $groups) {
    if ($group.Name -ne "Domain Users") {
        Remove-ADGroupMember -Identity $group.Name -Members "jan.vandenbergh" -Confirm:$false
    }
}

# 3. Générer le rapport
$report = @{
    "Utilisateur" = "jan.vandenbergh"
    "Groupes" = $groups
    "CheminPersonnel" = "\\fileserver\users\jan.vandenbergh"
}
$report | Export-Csv -Path "C:\Rapports\depart_jan_vandenbergh.csv" -NoTypeInformation
```

## Exercice 6: Gestion des Homonymes

```powershell
# 1. Créer les comptes avec différenciation
# Karim Benali Senior
New-ADUser -Name "Karim Benali (Senior)" `
           -GivenName "Karim" `
           -Surname "Benali" `
           -SamAccountName "karim.benali.sr" `
           -UserPrincipalName "karim.benali.sr@maxtec.be" `
           -Description "Recruteur Senior - Service RH" `
           -Path "OU=Users,OU=RH,OU=EU,DC=maxtec,DC=be" `
           -Enabled $true

# Karim Benali Junior
New-ADUser -Name "Karim Benali (Junior)" `
           -GivenName "Karim" `
           -Surname "Benali" `
           -SamAccountName "karim.benali.jr" `
           -UserPrincipalName "karim.benali.jr@maxtec.be" `
           -Description "Assistant RH" `
           -Path "OU=Users,OU=RH,OU=EU,DC=maxtec,DC=be" `
           -Enabled $true
```

## Exercice 7: Compte Temporaire

```powershell
# 1. Créer le compte consultant
$expirationDate = (Get-Date).AddDays(90)
New-ADUser -Name "Marek Wojcik" `
           -GivenName "Marek" `
           -Surname "Wojcik" `
           -SamAccountName "ext.marek.wojcik" `
           -UserPrincipalName "ext.marek.wojcik@maxtec.be" `
           -Description "EXT - Consultant Audit - Expire le $($expirationDate.ToString('yyyy-MM-dd'))" `
           -AccountExpirationDate $expirationDate `
           -LogonWorkstations "ws-compta-01" `
           -Path "OU=Consultants,OU=EU,DC=maxtec,DC=be" `
           -Enabled $true

# 2. Configurer les heures de connexion (9h-17h, jours ouvrés)
$logonHours = New-Object byte[] 21
# Configuration similaire à l'exercice 2 mais pour 9h-17h
```

## Exercice 8: Vérification des Comptes Inactifs

```powershell
# 1. Identifier les comptes inactifs
$inactiveDate = (Get-Date).AddDays(-30)
$inactiveAccounts = Get-ADUser -Filter {LastLogonDate -lt $inactiveDate} -Properties LastLogonDate, Description

# 2. Générer le rapport
$inactiveAccounts | Select-Object Name, SamAccountName, LastLogonDate, Description |
    Export-Csv -Path "C:\Rapports\comptes_inactifs.csv" -NoTypeInformation
```

## Exercice 9: Mise à Jour des Informations

```powershell
# 1. Mettre à jour les informations du service Comptabilité
Get-ADUser -Filter {Department -eq "Comptabilité"} | 
    Set-ADUser -Office "Bâtiment B - 3e étage"

# 2. Mettre à jour les numéros de téléphone
$users = Get-ADUser -Filter {Department -eq "Comptabilité"} -Properties telephoneNumber
foreach ($user in $users) {
    $newPhone = "+32 2 123 " + (Get-Random -Minimum 10 -Maximum 100).ToString()
    Set-ADUser -Identity $user.SamAccountName -OfficePhone $newPhone
}
```

## Exercice 10: Résolution des Problèmes de Connexion

```powershell
# 1. Vérifier l'état du compte
$user = Get-ADUser -Identity "sarah.elamrani" -Properties *
$status = @{
    "Verrouillé" = $user.LockedOut
    "Activé" = $user.Enabled
    "Expiré" = $user.AccountExpirationDate -lt (Get-Date)
    "DernièreConnexion" = $user.LastLogonDate
    "RestrictionsPostes" = $user.LogonWorkstations
    "HeuresConnexion" = $user.LogonHours
}

# 2. Déverrouiller si nécessaire
if ($user.LockedOut) {
    Unlock-ADAccount -Identity "sarah.elamrani"
}
```

## Exercice 11: Gestion des Profils Itinérants

```powershell
# 1. Créer le partage réseau
$path = "\\fileserver\RoamingProfiles$"
New-Item -Path $path -ItemType Directory
$acl = Get-Acl $path
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Domain Users","Modify","ContainerInherit,ObjectInherit","None","Allow")
$acl.AddAccessRule($accessRule)
Set-Acl $path $acl

# 2. Configurer les profils itinérants
$users = @("pierre.dubois", "marie.lambert", "ahmed.benali")
foreach ($user in $users) {
    $profilePath = "$path\$user"
    Set-ADUser -Identity $user -ProfilePath $profilePath
}

# 3. Configurer la limite de taille (via GPO)
# Créer une GPO "LimiteProfilsItinerants" et configurer:
# User Configuration\Policies\Administrative Templates\System\User Profiles
# "Limit profile size" = Enabled, 500 MB
```

## Exercice 12: Délégation d'Administration

```powershell
# 1. Créer le groupe d'administration déléguée
New-ADGroup -Name "GG-EU-RH-AdminDelegue" `
            -GroupCategory Security `
            -GroupScope Global `
            -Path "OU=Groups,OU=RH,OU=EU,DC=maxtec,DC=be"

# 2. Ajouter Claire au groupe
Add-ADGroupMember -Identity "GG-EU-RH-AdminDelegue" -Members "claire.martin"

# 3. Configurer la délégation sur l'OU RH
$ou = "OU=RH,OU=EU,DC=maxtec,DC=be"
$group = "GG-EU-RH-AdminDelegue"
$acl = Get-Acl -Path "AD:$ou"

# Droits pour créer/modifier les comptes
$objectGuid = New-Object Guid "bf9679c0-0de6-11d0-a285-00aa003049e2" # User objects
$ace = New-Object DirectoryServices.ActiveDirectoryAccessRule(
    [Security.Principal.SecurityIdentifier](Get-ADGroup $group).SID,
    "CreateChild,DeleteChild,ReadProperty,WriteProperty",
    "Allow",
    $objectGuid,
    "All"
)
$acl.AddAccessRule($ace)
Set-Acl -Path "AD:$ou" -AclObject $acl
```

## Exercice 13: Migration d'Utilisateurs

```powershell
# 1. Identifier et déplacer les utilisateurs
$sourceOU = "OU=Users,OU=IT,OU=EU,DC=maxtec,DC=be"
$targetOU = "OU=Users,OU=Ventes,OU=EU,DC=maxtec,DC=be"
$users = Get-ADUser -Filter {Department -eq "Support"} -SearchBase $sourceOU

foreach ($user in $users) {
    # Déplacer l'utilisateur
    Move-ADObject -Identity $user.DistinguishedName -TargetPath $targetOU
    
    # Mettre à jour le département
    Set-ADUser -Identity $user.SamAccountName -Department "Ventes"
    
    # Ajouter aux groupes Ventes
    Add-ADGroupMember -Identity "GG-EU-Ventes-Users" -Members $user.SamAccountName
}
```

## Exercice 14: Gestion des Comptes de Service

```powershell
# 1. Fonction pour créer un compte de service
function New-ServiceAccount {
    param(
        [string]$Name,
        [string]$Description,
        [string[]]$AllowedHosts
    )
    
    # Générer un mot de passe complexe
    $password = [System.Web.Security.Membership]::GeneratePassword(24,5)
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
    
    New-ADUser -Name $Name `
               -SamAccountName $Name `
               -UserPrincipalName "$Name@maxtec.be" `
               -Description $Description `
               -Path "OU=ServiceAccounts,DC=maxtec,DC=be" `
               -AccountPassword $securePassword `
               -Enabled $true `
               -PasswordNeverExpires $true `
               -CannotChangePassword $true `
               -LogonWorkstations ($AllowedHosts -join ",")
               
    # Sauvegarder les informations de manière sécurisée
    $info = @{
        "Account" = $Name
        "Password" = $password
        "Created" = Get-Date
        "AllowedHosts" = $AllowedHosts
    }
    $info | ConvertTo-Json | Out-File "C:\Secure\ServiceAccounts\$Name.json"
}

# 2. Créer les comptes
New-ServiceAccount -Name "svc-backup" `
                  -Description "Compte de service pour les sauvegardes" `
                  -AllowedHosts @("backup01","backup02")

New-ServiceAccount -Name "svc-monitoring" `
                  -Description "Compte de service pour la surveillance" `
                  -AllowedHosts @("monitor01","monitor02")

New-ServiceAccount -Name "svc-print" `
                  -Description "Compte de service pour l'impression" `
                  -AllowedHosts @("print01","print02")
```
