```powershell
# Script pour créer la structure des OUs, utilisateurs et groupes
# Stocker ce script dans un fichier creation.ps1
# Auteur: Cascade
# Date: 2025-04-02

# Fonction pour demander confirmation
function Confirm-Step {
    param($stepName)
    Write-Host "
Prêt à exécuter: $stepName" -ForegroundColor Yellow
    $response = Read-Host "Appuyez sur 'O' pour continuer, 'N' pour sauter cette étape, ou 'Q' pour quitter"
    if ($response.ToUpper() -eq 'Q') {
        Write-Host "Script arrêté par l'utilisateur." -ForegroundColor Red
        exit
    }
    return $response.ToUpper() -eq 'O'
}

# Fonction pour vérifier l'existence d'une OU
function Test-OUExists {
    param($ouDN)
    try {
        Get-ADOrganizationalUnit -Identity $ouDN
        return $true
    } catch {
        return $false
    }
}

# Fonction pour vérifier l'existence d'un utilisateur
function Test-UserExists {
    param($samAccountName)
    try {
        Get-ADUser -Identity $samAccountName
        return $true
    } catch {
        return $false
    }
}

# Fonction pour vérifier l'existence d'un groupe
function Test-GroupExists {
    param($groupName)
    try {
        Get-ADGroup -Identity $groupName
        return $true
    } catch {
        return $false
    }
}

# Importer le module Active Directory
Import-Module ActiveDirectory

# Définir les variables globales
$rootOU = "OU=EU,DC=computerelectronics,DC=be"
$defaultPassword = "Password1!"

try {
    Write-Host "Script de création de structure Active Directory" -ForegroundColor Green
    Write-Host "===========================================" -ForegroundColor Green

    # 1. Créer l'OU racine EU
    if (Confirm-Step "Création de l'OU racine EU") {
        Write-Host "\nCréation de l'OU racine EU..." -ForegroundColor Cyan
        $ouDN = "OU=EU,DC=computerelectronics,DC=be"
        if (-not (Test-OUExists $ouDN)) {
            New-ADOrganizationalUnit -Name "EU" -Path "DC=computerelectronics,DC=be" -ProtectedFromAccidentalDeletion $false
            Write-Host "OU racine EU créée avec succès." -ForegroundColor Green
        } else {
            Write-Host "OU racine EU existe déjà." -ForegroundColor Yellow
        }
    }

    # 2. Créer les départements et leurs sous-OUs
    if (Confirm-Step "Création des départements et leurs sous-OUs") {
        $departments = @("Ventes", "RH", "Comptabilite")
        Write-Host "\nCréation des départements et leurs sous-OUs..." -ForegroundColor Cyan
        
        foreach ($dept in $departments) {
            Write-Host "Traitement du département $dept..." -NoNewline
            $ouPath = "OU=$dept,$rootOU"
            
            # Vérifier si le département existe
            if (-not (Test-OUExists $ouPath)) {
                New-ADOrganizationalUnit -Name $dept -Path $rootOU -ProtectedFromAccidentalDeletion $false
                Write-Host "créé" -ForegroundColor Green
            } else {
                Write-Host "existe déjà" -ForegroundColor Yellow
            }
            
            # Créer les sous-OUs
            foreach ($subOU in @("Users", "Computers", "Groups")) {
                Write-Host "  - Sous-OU $subOU..." -NoNewline
                $subOUPath = "OU=$subOU,$ouPath"
                if (-not (Test-OUExists $subOUPath)) {
                    New-ADOrganizationalUnit -Name $subOU -Path $ouPath -ProtectedFromAccidentalDeletion $false
                    Write-Host "créée" -ForegroundColor Green
                } else {
                    Write-Host "existe déjà" -ForegroundColor Yellow
                }
            }
        }
    }

    # 3. Créer les utilisateurs
    if (Confirm-Step "Création des utilisateurs") {
        Write-Host "\nCréation des utilisateurs..." -ForegroundColor Cyan
        $users = @(
            @{Name="Vanessa";Email="vanessa@computerelectronics.be";OU="Ventes"},
            @{Name="Valeria";Email="valeria@computerelectronics.be";OU="Ventes"},
            @{Name="Victor";Email="victor@computerelectronics.be";OU="Ventes"},
            @{Name="Valentin";Email="valentin@computerelectronics.be";OU="Ventes"},
            @{Name="Richard";Email="richard@computerelectronics.be";OU="RH"},
            @{Name="Rebecca";Email="rebecca@computerelectronics.be";OU="RH"},
            @{Name="Rene";Email="rene@computerelectronics.be";OU="RH"},
            @{Name="Charlotte";Email="charlotte@computerelectronics.be";OU="Comptabilite"},
            @{Name="Cindy";Email="cindy@computerelectronics.be";OU="Comptabilite"},
            @{Name="Charles";Email="charles@computerelectronics.be";OU="Comptabilite"}
        )

        foreach ($user in $users) {
            Write-Host "Création de l'utilisateur $($user.Name)..." -NoNewline
            $ouPath = "OU=Users,OU=$($user.OU),$rootOU"
            $securePassword = ConvertTo-SecureString $defaultPassword -AsPlainText -Force
            
            $samAccountName = $user.Name.ToLower()
            if (-not (Test-UserExists $samAccountName)) {
                New-ADUser -Name $user.Name `
                          -SamAccountName $samAccountName `
                          -UserPrincipalName $user.Email `
                          -Path $ouPath `
                          -AccountPassword $securePassword `
                          -Enabled $true
                Write-Host "OK" -ForegroundColor Green
            } else {
                Write-Host "Utilisateur existe déjà" -ForegroundColor Yellow
            }
        }
    }


    # 4. Créer les groupes
    if (Confirm-Step "Création des groupes") {
        Write-Host "\nCréation des groupes..." -ForegroundColor Cyan
        $groups = @(
            @{Name="GG-EU-Ventes-Admin";OU="Ventes"},
            @{Name="GG-EU-Ventes-Users";OU="Ventes"},
            @{Name="GG-EU-RH-Admin";OU="RH"},
            @{Name="GG-EU-RH-Users";OU="RH"},
            @{Name="GG-EU-Compta-Admin";OU="Comptabilite"},
            @{Name="GG-EU-Compta-Users";OU="Comptabilite"}
        )

        foreach ($group in $groups) {
            Write-Host "Traitement du groupe $($group.Name)..." -NoNewline
            $ouPath = "OU=Groups,OU=$($group.OU),$rootOU"
            if (-not (Test-GroupExists $group.Name)) {
                New-ADGroup -Name $group.Name -GroupScope Global -GroupCategory Security -Path $ouPath
                Write-Host "créé" -ForegroundColor Green
            } else {
                Write-Host "existe déjà" -ForegroundColor Yellow
            }
        }
    }

    Write-Host "\nStructure créée avec succès!" -ForegroundColor Green
}
catch {
    Write-Host "\nERREUR: Une erreur s'est produite lors de la création de la structure:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "Stack Trace:" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
}
```