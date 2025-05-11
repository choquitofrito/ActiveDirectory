# Script pour configurer l'environnement de base pour les exercices
# À exécuter sur le contrôleur de domaine avec des privilèges d'administrateur

# Importer le module Active Directory
Import-Module ActiveDirectory

# Fonction pour créer une OU si elle n'existe pas déjà
function Create-OUIfNotExists {
    param(
        [string]$OUName,
        [string]$Path
    )
    
    try {
        $ouDN = "OU=$OUName,$Path"
        if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ouDN'" -ErrorAction SilentlyContinue)) {
            New-ADOrganizationalUnit -Name $OUName -Path $Path -ProtectedFromAccidentalDeletion $true
            Write-Host "OU '$OUName' créée avec succès" -ForegroundColor Green
        } else {
            Write-Host "OU '$OUName' existe déjà" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Erreur lors de la création de l'OU '$OUName': $_" -ForegroundColor Red
    }
}

# Fonction pour créer un utilisateur si il n'existe pas déjà
function Create-UserIfNotExists {
    param(
        [string]$FirstName,
        [string]$LastName,
        [string]$Department,
        [string]$Title,
        [string]$Path
    )
    
    $username = "$($FirstName.ToLower()).$($LastName.ToLower())"
    try {
        if (-not (Get-ADUser -Filter "SamAccountName -eq '$username'" -ErrorAction SilentlyContinue)) {
            $securePassword = ConvertTo-SecureString "P@ssw0rd2024!" -AsPlainText -Force
            
            New-ADUser `
                -SamAccountName $username `
                -UserPrincipalName "$username@maxtec.be" `
                -Name "$FirstName $LastName" `
                -GivenName $FirstName `
                -Surname $LastName `
                -Enabled $true `
                -ChangePasswordAtLogon $true `
                -DisplayName "$FirstName $LastName" `
                -Department $Department `
                -Title $Title `
                -Path $Path `
                -AccountPassword $securePassword
                
            Write-Host "Utilisateur '$username' créé avec succès" -ForegroundColor Green
        } else {
            Write-Host "Utilisateur '$username' existe déjà" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Erreur lors de la création de l'utilisateur '$username': $_" -ForegroundColor Red
    }
}

# Récupérer le DN du domaine
$domainDN = (Get-ADDomain).DistinguishedName

# 1. Créer les OUs principales
Write-Host "`nCréation des OUs départementales..." -ForegroundColor Cyan
Create-OUIfNotExists -OUName "Comptabilite" -Path $domainDN
Create-OUIfNotExists -OUName "RH" -Path $domainDN
Create-OUIfNotExists -OUName "Ventes" -Path $domainDN

# 2. Créer les utilisateurs de base
Write-Host "`nCréation des utilisateurs..." -ForegroundColor Cyan

# Comptabilité
Create-UserIfNotExists `
    -FirstName "Sophie" -LastName "Dubois" `
    -Department "Comptabilité" -Title "Comptable Junior" `
    -Path "OU=Comptabilite,$domainDN"

Create-UserIfNotExists `
    -FirstName "Jean" -LastName "Martin" `
    -Department "Comptabilité" -Title "Chef Comptable" `
    -Path "OU=Comptabilite,$domainDN"

# RH
Create-UserIfNotExists `
    -FirstName "Marie" -LastName "Laurent" `
    -Department "Ressources Humaines" -Title "Responsable RH" `
    -Path "OU=RH,$domainDN"

# Ventes
Create-UserIfNotExists `
    -FirstName "Pierre" -LastName "Durand" `
    -Department "Ventes" -Title "Commercial Senior" `
    -Path "OU=Ventes,$domainDN"

Write-Host "`nConfiguration de l'environnement terminée!" -ForegroundColor Green
Write-Host "Mot de passe temporaire pour tous les utilisateurs: P@ssw0rd2024!" -ForegroundColor Yellow
Write-Host "Les utilisateurs devront changer leur mot de passe à la première connexion." -ForegroundColor Yellow
