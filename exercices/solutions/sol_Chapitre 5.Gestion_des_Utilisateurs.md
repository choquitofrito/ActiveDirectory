# Solutions - Gestion des Utilisateurs

## Série 1: Création et Configuration de Base

### Solution 1.1: Création d'un Nouvel Employé

1. Création du compte utilisateur pour Sophie Dubois:
```powershell
# Créer le compte utilisateur
New-ADUser -Name "Sophie Dubois" `
    -GivenName "Sophie" `
    -Surname "Dubois" `
    -SamAccountName "sophie.dubois" `
    -UserPrincipalName "sophie.dubois@computerelectronics.be" `
    -Path "OU=Comptabilité,DC=computerelectronics,DC=be" `
    -Description "Comptable Junior - Service Comptabilité" `
    -Office "Bâtiment A - 1er étage" `
    -OfficePhone "+32 2 123 45 68" `
    -AccountPassword (ConvertTo-SecureString "P@ssw0rd2025!" -AsPlainText -Force) `
    -Enabled $true `
    -ChangePasswordAtLogon $true
```

Alternative via l'interface graphique (ADUC):
1. Ouvrir ADUC
2. Naviguer vers l'OU "Comptabilité"
3. Clic droit → Nouveau → Utilisateur
4. Remplir les champs:
   - Prénom: Sophie
   - Nom: Dubois
   - Nom d'ouverture de session: sophie.dubois
   - Mot de passe: P@ssw0rd2025!
   - Cocher "L'utilisateur doit changer de mot de passe à la prochaine ouverture de session"
5. Dans les propriétés:
   - Onglet Général: Ajouter la description et le bureau
   - Onglet Téléphone: Ajouter le numéro

### Solution 1.2: Restrictions d'Accès

1. Configuration des restrictions de poste de travail:
```powershell
# Définir les restrictions de connexion
Set-ADUser -Identity "sophie.dubois" `
    -LogonWorkstations "ws-compta-01"
```

2. Configuration des plages horaires via ADUC:
1. Propriétés du compte de Sophie
2. Onglet "Compte"
3. Cliquer sur "Heures de connexion..."
4. Sélectionner la plage 8h-18h pour Lundi-Vendredi
5. Laisser les autres périodes en "Compte désactivé"

## Série 2: Sécurité et Audit

### Solution 2.2: Audit de Sécurité

1. Vérification des exemptions de mot de passe:
```powershell
Get-ADUser -Identity "sophie.dubois" -Properties PasswordNeverExpires | 
    Select-Object Name, PasswordNeverExpires
```

2. Configuration de l'expiration du compte:
```powershell
$expirationDate = (Get-Date).AddMonths(6)
Set-ADUser -Identity "sophie.dubois" -AccountExpirationDate $expirationDate
```

3. Activation de la journalisation:
```powershell
# Vérifier la politique d'audit actuelle
auditpol /get /category:"Logon/Logoff"

# Activer l'audit des échecs de connexion
auditpol /set /subcategory:"Logon" /failure:enable
```

## Série 3: Gestion de Fin de Cycle

### Solution 3.1: Désactivation d'un Compte

1. Désactivation du compte:
```powershell
$dateDesactivation = Get-Date -Format "yyyy-MM-dd"
$dateSuppression = (Get-Date).AddDays(90).ToString("yyyy-MM-dd")
$description = "Compte désactivé le $dateDesactivation - Départ de l'entreprise - Suppression prévue: $dateSuppression"

Set-ADUser -Identity "jan.vandenbergh" `
    -Enabled $false `
    -Description $description
```

2. Vérification de la désactivation:
```powershell
Get-ADUser -Identity "jan.vandenbergh" -Properties Enabled, Description |
    Select-Object Name, Enabled, Description
```

### Solution 3.2: Nettoyage des Accès

1. Identification et retrait des groupes:
```powershell
# Obtenir la liste des groupes
$groups = Get-ADPrincipalGroupMembership -Identity "jan.vandenbergh" |
    Where-Object {$_.Name -ne "Domain Users"}

# Créer le rapport
$report = @{
    "Groupes" = $groups | Select-Object -ExpandProperty Name
    "DateRetrait" = Get-Date
    "CheminFichiers" = "\\computerelectronics.be\users\jan.vandenbergh"
}

# Retirer des groupes
foreach ($group in $groups) {
    Remove-ADGroupMember -Identity $group -Members "jan.vandenbergh" -Confirm:$false
}

# Exporter le rapport
$report | ConvertTo-Json | Out-File "C:\Rapports\jan_vandenbergh_access_report.json"
```

## Série 4: Gestion des Cas Spéciaux

### Solution 4.1: Gestion des Homonymes

1. Création des comptes avec différenciation:
```powershell
# Compte pour le Recruteur Senior
New-ADUser -Name "Karim Benali (Senior)" `
    -GivenName "Karim" `
    -Surname "Benali" `
    -SamAccountName "karim.benali1" `
    -UserPrincipalName "karim.benali1@computerelectronics.be" `
    -Description "Recruteur Senior - Service RH" `
    -Path "OU=RH,DC=computerelectronics,DC=be"

# Compte pour l'Assistant RH
New-ADUser -Name "Karim Benali (Assistant)" `
    -GivenName "Karim" `
    -Surname "Benali" `
    -SamAccountName "karim.benali2" `
    -UserPrincipalName "karim.benali2@computerelectronics.be" `
    -Description "Assistant RH" `
    -Path "OU=RH,DC=computerelectronics,DC=be"
```

### Solution 4.2: Compte Temporaire

1. Création du compte consultant:
```powershell
$expirationDate = (Get-Date).AddDays(90)

New-ADUser -Name "EXT-Marek Wojcik" `
    -GivenName "Marek" `
    -Surname "Wojcik" `
    -SamAccountName "ext.marek.wojcik" `
    -UserPrincipalName "ext.marek.wojcik@computerelectronics.be" `
    -Description "EXT - Consultant Audit - Expire le $($expirationDate.ToString('yyyy-MM-dd'))" `
    -AccountExpirationDate $expirationDate `
    -LogonWorkstations "ws-compta-01" `
    -Path "OU=Consultants,DC=computerelectronics,DC=be"

# Configuration des heures de connexion via ADUC
# (à faire manuellement car pas de cmdlet PowerShell directe)
```

## Série 5: Maintenance et Audit

### Solution 5.1: Vérification des Comptes Inactifs

1. Script de vérification des comptes inactifs:
```powershell
# Obtenir la date d'il y a 90 jours
$inactiveDate = (Get-Date).AddDays(-90)

# Rechercher les comptes inactifs
$inactiveAccounts = Get-ADUser -Filter {
    Enabled -eq $true -and LastLogonTimeStamp -lt $inactiveDate
} -Properties LastLogonTimeStamp, Description |
Select-Object Name, SamAccountName, @{
    Name='LastLogon';
    Expression={[DateTime]::FromFileTime($_.LastLogonTimeStamp)}
}

# Exporter les résultats
$inactiveAccounts | Export-Csv -Path "C:\Rapports\comptes_inactifs.csv" -NoTypeInformation
```

### Solution 5.2: Réinitialisation de Profil

1. Script de réinitialisation de profil:
```powershell
# Paramètres
$username = "utilisateur.problematique"
$oldProfile = "C:\Users\$username"
$backupPath = "C:\Backups\$username"
$newProfile = "C:\Users\$username.new"

# 1. Sauvegarde des données
Copy-Item -Path "$oldProfile\Documents" -Destination "$backupPath\Documents" -Recurse
Copy-Item -Path "$oldProfile\Desktop" -Destination "$backupPath\Desktop" -Recurse
Copy-Item -Path "$oldProfile\Favorites" -Destination "$backupPath\Favorites" -Recurse

# 2. Suppression du profil existant dans le registre
$userSID = (Get-ADUser $username).SID.Value
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$userSID" -Name ProfileImagePath

# 3. Création du nouveau profil
# Le nouveau profil sera créé automatiquement à la prochaine connexion

# 4. Restauration des données
# À effectuer après la première connexion réussie
```

Note: Ces solutions incluent à la fois des commandes PowerShell et des étapes via l'interface graphique ADUC. Pour les environnements de production, il est recommandé d'automatiser autant que possible via PowerShell pour la cohérence et la reproductibilité.
