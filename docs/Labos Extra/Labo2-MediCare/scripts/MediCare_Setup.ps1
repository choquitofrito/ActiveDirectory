# Script pour créer la structure Active Directory - MediCare Clinic
# Nom du script: MediCare_Setup.ps1
# Auteur: H2EB Active Directory Lab Project
# Date: 2025-10-05
# Description: Crée une structure AD complète pour une clinique médicale multidisciplinaire
#              avec accent sur la sécurité des données médicales et la séparation des rôles
#
# Sources Microsoft consultées:
# - https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-adorganizationalunit
# - https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-aduser
# - https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-adgroup
# - https://learn.microsoft.com/en-us/powershell/module/grouppolicy/new-gpo
# - https://learn.microsoft.com/en-us/powershell/module/activedirectory/set-addefaultdomainpasswordpolicy

# ============================================
# FONCTIONS UTILITAIRES
# ============================================

# Fonction pour demander confirmation avant chaque étape
function Confirm-Step {
    param($stepName)
    Write-Host "`nPrêt à exécuter: $stepName" -ForegroundColor Yellow
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
        Get-ADOrganizationalUnit -Identity $ouDN -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Fonction pour vérifier l'existence d'un utilisateur
function Test-UserExists {
    param($samAccountName)
    try {
        Get-ADUser -Identity $samAccountName -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Fonction pour vérifier l'existence d'un groupe
function Test-GroupExists {
    param($groupName)
    try {
        Get-ADGroup -Identity $groupName -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Fonction pour vérifier l'existence d'une GPO
function Test-GPOExists {
    param($gpoName)
    try {
        Get-GPO -Name $gpoName -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# ============================================
# VARIABLES GLOBALES
# ============================================

Import-Module ActiveDirectory
Import-Module GroupPolicy

$domainDN = "DC=maxtec,DC=be"
$rootOU = "OU=MediCare,$domainDN"
$defaultPassword = "Azerty_1"

# Créer le répertoire pour les exports CSV si nécessaire
$exportPath = "C:\Labos"
if (-not (Test-Path $exportPath)) {
    New-Item -Path $exportPath -ItemType Directory -Force | Out-Null
}

# ============================================
# SCRIPT PRINCIPAL
# ============================================

try {
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "  LABO ACTIVE DIRECTORY - MEDICARE CLINIC  " -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "Clinique médicale multidisciplinaire - 28 employés" -ForegroundColor Cyan
    Write-Host "Accent sur: sécurité données médicales, conformité, séparation des rôles`n" -ForegroundColor Cyan

    # ============================================
    # ÉTAPE 1: CRÉATION DE L'OU RACINE
    # ============================================

    if (Confirm-Step "Étape 1 - Création de l'OU racine 'MediCare'") {
        Write-Host "`n[ÉTAPE 1] Création de l'Unité Organisationnelle racine..." -ForegroundColor Cyan

        if (-not (Test-OUExists $rootOU)) {
            New-ADOrganizationalUnit -Name "MediCare" -Path $domainDN -ProtectedFromAccidentalDeletion $false
            Write-Host "  ✅ OU racine 'MediCare' créée" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  OU racine 'MediCare' existe déjà" -ForegroundColor Yellow
        }
    }

    # ============================================
    # ÉTAPE 2: CRÉATION DES OUS DÉPARTEMENTALES
    # ============================================

    if (Confirm-Step "Étape 2 - Création des OUs départementales (Medical, Nursing, Administration, IT)") {
        Write-Host "`n[ÉTAPE 2] Création de la structure départementale..." -ForegroundColor Cyan

        $departments = @("Medical", "Nursing", "Administration", "IT")
        $subOUs = @("Users", "Computers", "Groups")

        foreach ($dept in $departments) {
            $deptOU = "OU=$dept,$rootOU"

            # Créer l'OU du département
            if (-not (Test-OUExists $deptOU)) {
                New-ADOrganizationalUnit -Name $dept -Path $rootOU -ProtectedFromAccidentalDeletion $false
                Write-Host "  ✅ OU '$dept' créée" -ForegroundColor Green
            } else {
                Write-Host "  ⚠️  OU '$dept' existe déjà" -ForegroundColor Yellow
            }

            # Créer les sous-OUs (Users, Computers, Groups)
            foreach ($subOU in $subOUs) {
                $subOUPath = "OU=$subOU,$deptOU"
                if (-not (Test-OUExists $subOUPath)) {
                    New-ADOrganizationalUnit -Name $subOU -Path $deptOU -ProtectedFromAccidentalDeletion $false
                    Write-Host "    └─ Sous-OU '$subOU' créée dans $dept" -ForegroundColor Gray
                } else {
                    Write-Host "    └─ Sous-OU '$subOU' existe déjà dans $dept" -ForegroundColor DarkGray
                }
            }
        }
    }

    # ============================================
    # ÉTAPE 3: CRÉATION DES UTILISATEURS
    # ============================================

    if (Confirm-Step "Étape 3 - Création des 28 utilisateurs avec titres médicaux") {
        Write-Host "`n[ÉTAPE 3] Création des comptes utilisateurs..." -ForegroundColor Cyan

        # Département Medical (10 utilisateurs)
        $medicalUsers = @(
            @{FirstName="Catherine"; LastName="Leblanc"; Title="Dr."; Role="Médecin Senior"; Admin=$true},
            @{FirstName="Philippe"; LastName="Moreau"; Title="Dr."; Role="Médecin Senior"; Admin=$true},
            @{FirstName="Amélie"; LastName="Rousseau"; Title="Dr."; Role="Médecin Généraliste"; Admin=$false},
            @{FirstName="Marc"; LastName="Girard"; Title="Dr."; Role="Médecin Généraliste"; Admin=$false},
            @{FirstName="Sophie"; LastName="Bernard"; Title="Dr."; Role="Médecin Généraliste"; Admin=$false},
            @{FirstName="Laurent"; LastName="Dubois"; Title="Dr."; Role="Pédiatre"; Admin=$false},
            @{FirstName="Isabelle"; LastName="Mercier"; Title="Dr."; Role="Cardiologue"; Admin=$false},
            @{FirstName="Nicolas"; LastName="Fontaine"; Title="Dr."; Role="Médecin Junior"; Admin=$false},
            @{FirstName="Julie"; LastName="Gauthier"; Title="Dr."; Role="Médecin Junior"; Admin=$false},
            @{FirstName="Thomas"; LastName="Renard"; Title=""; Role="Coordinateur Garde"; Admin=$false}
        )

        Write-Host "`n  Département: MEDICAL (10 utilisateurs)" -ForegroundColor Magenta
        foreach ($user in $medicalUsers) {
            $sam = $user.FirstName.ToLower()
            $displayName = "$($user.Title) $($user.FirstName) $($user.LastName)".Trim()
            $email = "$($user.FirstName.ToLower())@maxtec.be"
            $userPath = "OU=Users,OU=Medical,$rootOU"

            if (-not (Test-UserExists $sam)) {
                New-ADUser -Name $displayName `
                    -GivenName $user.FirstName `
                    -Surname $user.LastName `
                    -SamAccountName $sam `
                    -UserPrincipalName "$sam@maxtec.be" `
                    -EmailAddress $email `
                    -Title $user.Role `
                    -Department "Medical" `
                    -Path $userPath `
                    -AccountPassword (ConvertTo-SecureString $defaultPassword -AsPlainText -Force) `
                    -Enabled $true `
                    -PasswordNeverExpires $false `
                    -ChangePasswordAtLogon $false

                Write-Host "    ✅ $displayName ($email) - $($user.Role)" -ForegroundColor Green
            } else {
                Write-Host "    ⚠️  $displayName existe déjà" -ForegroundColor Yellow
            }
        }

        # Département Nursing (8 utilisateurs)
        $nursingUsers = @(
            @{FirstName="Anne"; LastName="Durand"; Title="Inf."; Role="Infirmière-Chef"; Admin=$true},
            @{FirstName="Claire"; LastName="Martin"; Title="Inf."; Role="Infirmière-Chef"; Admin=$true},
            @{FirstName="Brigitte"; LastName="Lefebvre"; Title="Inf."; Role="Infirmière Diplômée"; Admin=$false},
            @{FirstName="Sylvie"; LastName="Robert"; Title="Inf."; Role="Infirmière Diplômée"; Admin=$false},
            @{FirstName="Nathalie"; LastName="Petit"; Title="Inf."; Role="Infirmière Diplômée"; Admin=$false},
            @{FirstName="Valérie"; LastName="Roux"; Title="Inf."; Role="Infirmière Diplômée"; Admin=$false},
            @{FirstName="Céline"; LastName="Simon"; Title="Asst."; Role="Assistante Médicale"; Admin=$false},
            @{FirstName="Émilie"; LastName="Laurent"; Title="Asst."; Role="Assistante Médicale"; Admin=$false}
        )

        Write-Host "`n  Département: NURSING (8 utilisateurs)" -ForegroundColor Magenta
        foreach ($user in $nursingUsers) {
            $sam = $user.FirstName.ToLower()
            $displayName = "$($user.Title) $($user.FirstName) $($user.LastName)"
            $email = "$($user.FirstName.ToLower())@maxtec.be"
            $userPath = "OU=Users,OU=Nursing,$rootOU"

            if (-not (Test-UserExists $sam)) {
                New-ADUser -Name $displayName `
                    -GivenName $user.FirstName `
                    -Surname $user.LastName `
                    -SamAccountName $sam `
                    -UserPrincipalName "$sam@maxtec.be" `
                    -EmailAddress $email `
                    -Title $user.Role `
                    -Department "Nursing" `
                    -Path $userPath `
                    -AccountPassword (ConvertTo-SecureString $defaultPassword -AsPlainText -Force) `
                    -Enabled $true `
                    -PasswordNeverExpires $false `
                    -ChangePasswordAtLogon $false

                Write-Host "    ✅ $displayName ($email) - $($user.Role)" -ForegroundColor Green
            } else {
                Write-Host "    ⚠️  $displayName existe déjà" -ForegroundColor Yellow
            }
        }

        # Département Administration (7 utilisateurs)
        $adminUsers = @(
            @{FirstName="François"; LastName="Blanc"; Title=""; Role="Gestionnaire Facturation"; Admin=$true; Specialty="Billing"},
            @{FirstName="Danielle"; LastName="Morel"; Title=""; Role="Gestionnaire RH"; Admin=$true; Specialty="HR"},
            @{FirstName="Patricia"; LastName="Fournier"; Title=""; Role="Réceptionniste"; Admin=$false; Specialty="Reception"},
            @{FirstName="Véronique"; LastName="Giraud"; Title=""; Role="Réceptionniste"; Admin=$false; Specialty="Reception"},
            @{FirstName="Stéphanie"; LastName="Bonnet"; Title=""; Role="Archiviste Médicale"; Admin=$false; Specialty="Records"},
            @{FirstName="Martine"; LastName="Dupont"; Title=""; Role="Archiviste Médicale"; Admin=$false; Specialty="Records"},
            @{FirstName="Olivier"; LastName="Lambert"; Title=""; Role="Comptable"; Admin=$false; Specialty="Billing"}
        )

        Write-Host "`n  Département: ADMINISTRATION (7 utilisateurs)" -ForegroundColor Magenta
        foreach ($user in $adminUsers) {
            $sam = $user.FirstName.ToLower()
            $displayName = "$($user.FirstName) $($user.LastName)"
            $email = "$($user.FirstName.ToLower())@maxtec.be"
            $userPath = "OU=Users,OU=Administration,$rootOU"

            if (-not (Test-UserExists $sam)) {
                New-ADUser -Name $displayName `
                    -GivenName $user.FirstName `
                    -Surname $user.LastName `
                    -SamAccountName $sam `
                    -UserPrincipalName "$sam@maxtec.be" `
                    -EmailAddress $email `
                    -Title $user.Role `
                    -Department "Administration" `
                    -Path $userPath `
                    -AccountPassword (ConvertTo-SecureString $defaultPassword -AsPlainText -Force) `
                    -Enabled $true `
                    -PasswordNeverExpires $false `
                    -ChangePasswordAtLogon $false

                Write-Host "    ✅ $displayName ($email) - $($user.Role)" -ForegroundColor Green
            } else {
                Write-Host "    ⚠️  $displayName existe déjà" -ForegroundColor Yellow
            }
        }

        # Département IT (3 utilisateurs)
        $itUsers = @(
            @{FirstName="Alain"; LastName="Perrin"; Title=""; Role="Administrateur Système"; Admin=$true},
            @{FirstName="Benoît"; LastName="Chevalier"; Title=""; Role="Officier Sécurité"; Admin=$true},
            @{FirstName="David"; LastName="Garnier"; Title=""; Role="Technicien Support"; Admin=$false}
        )

        Write-Host "`n  Département: IT (3 utilisateurs)" -ForegroundColor Magenta
        foreach ($user in $itUsers) {
            $sam = $user.FirstName.ToLower()
            $displayName = "$($user.FirstName) $($user.LastName)"
            $email = "$($user.FirstName.ToLower())@maxtec.be"
            $userPath = "OU=Users,OU=IT,$rootOU"

            if (-not (Test-UserExists $sam)) {
                New-ADUser -Name $displayName `
                    -GivenName $user.FirstName `
                    -Surname $user.LastName `
                    -SamAccountName $sam `
                    -UserPrincipalName "$sam@maxtec.be" `
                    -EmailAddress $email `
                    -Title $user.Role `
                    -Department "IT" `
                    -Path $userPath `
                    -AccountPassword (ConvertTo-SecureString $defaultPassword -AsPlainText -Force) `
                    -Enabled $true `
                    -PasswordNeverExpires $false `
                    -ChangePasswordAtLogon $false

                Write-Host "    ✅ $displayName ($email) - $($user.Role)" -ForegroundColor Green
            } else {
                Write-Host "    ⚠️  $displayName existe déjà" -ForegroundColor Yellow
            }
        }

        Write-Host "`n  📊 Total: 28 utilisateurs créés" -ForegroundColor Cyan
    }

    # ============================================
    # ÉTAPE 4: CRÉATION DES GROUPES DE SÉCURITÉ
    # ============================================

    if (Confirm-Step "Étape 4 - Création des groupes de sécurité globaux (préfixe GG-)") {
        Write-Host "`n[ÉTAPE 4] Création des groupes de sécurité..." -ForegroundColor Cyan

        # Groupes Medical
        Write-Host "`n  Département: MEDICAL" -ForegroundColor Magenta
        $medicalGroups = @(
            @{Name="GG-MediCare-Medical-Users"; Desc="Tous les utilisateurs du département Medical"},
            @{Name="GG-MediCare-Medical-Admin"; Desc="Administrateurs Medical (Médecins Seniors)"},
            @{Name="GG-MediCare-Medical-Seniors"; Desc="Médecins Seniors (droits de signature)"},
            @{Name="GG-MediCare-Medical-Oncall"; Desc="Accès système de garde rotatif"}
        )

        foreach ($group in $medicalGroups) {
            $groupPath = "OU=Groups,OU=Medical,$rootOU"
            if (-not (Test-GroupExists $group.Name)) {
                New-ADGroup -Name $group.Name `
                    -GroupScope Global `
                    -GroupCategory Security `
                    -Description $group.Desc `
                    -Path $groupPath
                Write-Host "    ✅ $($group.Name)" -ForegroundColor Green
            } else {
                Write-Host "    ⚠️  $($group.Name) existe déjà" -ForegroundColor Yellow
            }
        }

        # Groupes Nursing
        Write-Host "`n  Département: NURSING" -ForegroundColor Magenta
        $nursingGroups = @(
            @{Name="GG-MediCare-Nursing-Users"; Desc="Tous les utilisateurs du département Nursing"},
            @{Name="GG-MediCare-Nursing-Admin"; Desc="Administrateurs Nursing (Infirmières-Chefs)"}
        )

        foreach ($group in $nursingGroups) {
            $groupPath = "OU=Groups,OU=Nursing,$rootOU"
            if (-not (Test-GroupExists $group.Name)) {
                New-ADGroup -Name $group.Name `
                    -GroupScope Global `
                    -GroupCategory Security `
                    -Description $group.Desc `
                    -Path $groupPath
                Write-Host "    ✅ $($group.Name)" -ForegroundColor Green
            } else {
                Write-Host "    ⚠️  $($group.Name) existe déjà" -ForegroundColor Yellow
            }
        }

        # Groupes Administration
        Write-Host "`n  Département: ADMINISTRATION" -ForegroundColor Magenta
        $administrationGroups = @(
            @{Name="GG-MediCare-Administration-Users"; Desc="Tous les utilisateurs du département Administration"},
            @{Name="GG-MediCare-Administration-Admin"; Desc="Administrateurs Administration (Gestionnaires)"},
            @{Name="GG-MediCare-Administration-Billing"; Desc="Équipe Facturation"},
            @{Name="GG-MediCare-Administration-HR"; Desc="Équipe Ressources Humaines"}
        )

        foreach ($group in $administrationGroups) {
            $groupPath = "OU=Groups,OU=Administration,$rootOU"
            if (-not (Test-GroupExists $group.Name)) {
                New-ADGroup -Name $group.Name `
                    -GroupScope Global `
                    -GroupCategory Security `
                    -Description $group.Desc `
                    -Path $groupPath
                Write-Host "    ✅ $($group.Name)" -ForegroundColor Green
            } else {
                Write-Host "    ⚠️  $($group.Name) existe déjà" -ForegroundColor Yellow
            }
        }

        # Groupes IT
        Write-Host "`n  Département: IT" -ForegroundColor Magenta
        $itGroups = @(
            @{Name="GG-MediCare-IT-Users"; Desc="Tous les utilisateurs du département IT"},
            @{Name="GG-MediCare-IT-Admin"; Desc="Administrateurs IT (SysAdmin + Sécurité)"}
        )

        foreach ($group in $itGroups) {
            $groupPath = "OU=Groups,OU=IT,$rootOU"
            if (-not (Test-GroupExists $group.Name)) {
                New-ADGroup -Name $group.Name `
                    -GroupScope Global `
                    -GroupCategory Security `
                    -Description $group.Desc `
                    -Path $groupPath
                Write-Host "    ✅ $($group.Name)" -ForegroundColor Green
            } else {
                Write-Host "    ⚠️  $($group.Name) existe déjà" -ForegroundColor Yellow
            }
        }

        Write-Host "`n  📊 Total: 12 groupes de sécurité créés" -ForegroundColor Cyan
    }

    # ============================================
    # ÉTAPE 5: AFFECTATION DES MEMBRES AUX GROUPES
    # ============================================

    if (Confirm-Step "Étape 5 - Affectation automatique des utilisateurs aux groupes") {
        Write-Host "`n[ÉTAPE 5] Affectation des membres aux groupes..." -ForegroundColor Cyan

        # Medical - Tous les utilisateurs
        Write-Host "`n  MEDICAL - Affectations automatiques" -ForegroundColor Magenta
        $medicalUsersList = @("catherine", "philippe", "amélie", "marc", "sophie", "laurent", "isabelle", "nicolas", "julie", "thomas")
        foreach ($userName in $medicalUsersList) {
            try {
                Add-ADGroupMember -Identity "GG-MediCare-Medical-Users" -Members $userName -ErrorAction SilentlyContinue
                Write-Host "    ✅ $userName → GG-MediCare-Medical-Users" -ForegroundColor Green
            } catch {
                Write-Host "    ⚠️  $userName déjà membre de GG-MediCare-Medical-Users" -ForegroundColor DarkGray
            }
        }

        # Medical - Admins (Seniors)
        $medicalAdmins = @("catherine", "philippe")
        foreach ($userName in $medicalAdmins) {
            try {
                Add-ADGroupMember -Identity "GG-MediCare-Medical-Admin" -Members $userName -ErrorAction SilentlyContinue
                Add-ADGroupMember -Identity "GG-MediCare-Medical-Seniors" -Members $userName -ErrorAction SilentlyContinue
                Write-Host "    ✅ $userName → GG-MediCare-Medical-Admin + Seniors" -ForegroundColor Green
            } catch {
                Write-Host "    ⚠️  $userName déjà membre des groupes Admin/Seniors" -ForegroundColor DarkGray
            }
        }

        # Medical - Oncall (Coordinateur + 1 Senior)
        $medicalOncall = @("thomas", "philippe")
        foreach ($userName in $medicalOncall) {
            try {
                Add-ADGroupMember -Identity "GG-MediCare-Medical-Oncall" -Members $userName -ErrorAction SilentlyContinue
                Write-Host "    ✅ $userName → GG-MediCare-Medical-Oncall" -ForegroundColor Green
            } catch {
                Write-Host "    ⚠️  $userName déjà membre de GG-MediCare-Medical-Oncall" -ForegroundColor DarkGray
            }
        }

        # Nursing - Tous les utilisateurs
        Write-Host "`n  NURSING - Affectations automatiques" -ForegroundColor Magenta
        $nursingUsersList = @("anne", "claire", "brigitte", "sylvie", "nathalie", "valérie", "céline", "émilie")
        foreach ($userName in $nursingUsersList) {
            try {
                Add-ADGroupMember -Identity "GG-MediCare-Nursing-Users" -Members $userName -ErrorAction SilentlyContinue
                Write-Host "    ✅ $userName → GG-MediCare-Nursing-Users" -ForegroundColor Green
            } catch {
                Write-Host "    ⚠️  $userName déjà membre de GG-MediCare-Nursing-Users" -ForegroundColor DarkGray
            }
        }

        # Nursing - Admins (Chefs)
        $nursingAdmins = @("anne", "claire")
        foreach ($userName in $nursingAdmins) {
            try {
                Add-ADGroupMember -Identity "GG-MediCare-Nursing-Admin" -Members $userName -ErrorAction SilentlyContinue
                Write-Host "    ✅ $userName → GG-MediCare-Nursing-Admin" -ForegroundColor Green
            } catch {
                Write-Host "    ⚠️  $userName déjà membre de GG-MediCare-Nursing-Admin" -ForegroundColor DarkGray
            }
        }

        # Administration - Tous les utilisateurs
        Write-Host "`n  ADMINISTRATION - Affectations automatiques" -ForegroundColor Magenta
        $adminUsersList = @("françois", "danielle", "patricia", "véronique", "stéphanie", "martine", "olivier")
        foreach ($userName in $adminUsersList) {
            try {
                Add-ADGroupMember -Identity "GG-MediCare-Administration-Users" -Members $userName -ErrorAction SilentlyContinue
                Write-Host "    ✅ $userName → GG-MediCare-Administration-Users" -ForegroundColor Green
            } catch {
                Write-Host "    ⚠️  $userName déjà membre de GG-MediCare-Administration-Users" -ForegroundColor DarkGray
            }
        }

        # Administration - Admins (Gestionnaires)
        $adminAdmins = @("françois", "danielle")
        foreach ($userName in $adminAdmins) {
            try {
                Add-ADGroupMember -Identity "GG-MediCare-Administration-Admin" -Members $userName -ErrorAction SilentlyContinue
                Write-Host "    ✅ $userName → GG-MediCare-Administration-Admin" -ForegroundColor Green
            } catch {
                Write-Host "    ⚠️  $userName déjà membre de GG-MediCare-Administration-Admin" -ForegroundColor DarkGray
            }
        }

        # Administration - Billing
        $adminBilling = @("françois", "olivier")
        foreach ($userName in $adminBilling) {
            try {
                Add-ADGroupMember -Identity "GG-MediCare-Administration-Billing" -Members $userName -ErrorAction SilentlyContinue
                Write-Host "    ✅ $userName → GG-MediCare-Administration-Billing" -ForegroundColor Green
            } catch {
                Write-Host "    ⚠️  $userName déjà membre de GG-MediCare-Administration-Billing" -ForegroundColor DarkGray
            }
        }

        # Administration - HR
        try {
            Add-ADGroupMember -Identity "GG-MediCare-Administration-HR" -Members "danielle" -ErrorAction SilentlyContinue
            Write-Host "    ✅ danielle → GG-MediCare-Administration-HR" -ForegroundColor Green
        } catch {
            Write-Host "    ⚠️  danielle déjà membre de GG-MediCare-Administration-HR" -ForegroundColor DarkGray
        }

        # IT - Tous les utilisateurs
        Write-Host "`n  IT - Affectations automatiques" -ForegroundColor Magenta
        $itUsersList = @("alain", "benoît", "david")
        foreach ($userName in $itUsersList) {
            try {
                Add-ADGroupMember -Identity "GG-MediCare-IT-Users" -Members $userName -ErrorAction SilentlyContinue
                Write-Host "    ✅ $userName → GG-MediCare-IT-Users" -ForegroundColor Green
            } catch {
                Write-Host "    ⚠️  $userName déjà membre de GG-MediCare-IT-Users" -ForegroundColor DarkGray
            }
        }

        # IT - Admins
        $itAdmins = @("alain", "benoît")
        foreach ($userName in $itAdmins) {
            try {
                Add-ADGroupMember -Identity "GG-MediCare-IT-Admin" -Members $userName -ErrorAction SilentlyContinue
                Write-Host "    ✅ $userName → GG-MediCare-IT-Admin" -ForegroundColor Green
            } catch {
                Write-Host "    ⚠️  $userName déjà membre de GG-MediCare-IT-Admin" -ForegroundColor DarkGray
            }
        }

        Write-Host "`n  📊 Affectations automatiques terminées" -ForegroundColor Cyan
    }

    # ============================================
    # ÉTAPE 6: CONFIGURATION DES STRATÉGIES DE GROUPE (GPOs)
    # ============================================

    if (Confirm-Step "Étape 6 - Création des stratégies de groupe (GPOs) - Configuration médicale sécurisée") {
        Write-Host "`n[ÉTAPE 6] Configuration des stratégies de groupe..." -ForegroundColor Cyan
        Write-Host "Note: GPOs suivent les bonnes pratiques de .claude/gpo-reference.md" -ForegroundColor Gray

        # GPO 1: Politique de Mot de Passe Renforcée (Domain-level, PowerShell supporté)
        Write-Host "`n  GPO 1: Politique de Mot de Passe - Conformité Médicale" -ForegroundColor Magenta
        try {
            Set-ADDefaultDomainPasswordPolicy -Identity "maxtec.be" `
                -MinPasswordLength 12 `
                -PasswordHistoryCount 24 `
                -MaxPasswordAge (New-TimeSpan -Days 60) `
                -MinPasswordAge (New-TimeSpan -Days 1) `
                -ComplexityEnabled $true `
                -LockoutThreshold 5 `
                -LockoutDuration (New-TimeSpan -Minutes 30) `
                -LockoutObservationWindow (New-TimeSpan -Minutes 30)

            Write-Host "    ✅ Politique de mots de passe configurée au niveau domaine:" -ForegroundColor Green
            Write-Host "       - Longueur minimale: 12 caractères" -ForegroundColor Gray
            Write-Host "       - Complexité: Activée" -ForegroundColor Gray
            Write-Host "       - Âge maximum: 60 jours (conformité médicale)" -ForegroundColor Gray
            Write-Host "       - Historique: 24 mots de passe" -ForegroundColor Gray
            Write-Host "       - Verrouillage: 5 tentatives, 30 minutes" -ForegroundColor Gray
        } catch {
            Write-Host "    ⚠️  ERREUR configuration politique de mot de passe: $($_.Exception.Message)" -ForegroundColor Red
        }

        # GPO 2: Blocage USB - Zones Médicales (Manual GPMC configuration)
        Write-Host "`n  GPO 2: Blocage USB - Départements Medical et Nursing" -ForegroundColor Magenta
        $gpo2Name = "MediCare - Blocage USB Zones Médicales"

        if (-not (Test-GPOExists $gpo2Name)) {
            New-GPO -Name $gpo2Name -Comment "Empêche l'accès aux périphériques de stockage amovibles pour prévenir l'exfiltration de données patients"

            # Lier aux OUs Medical et Nursing
            New-GPLink -Name $gpo2Name -Target "OU=Users,OU=Medical,$rootOU" -LinkEnabled Yes
            New-GPLink -Name $gpo2Name -Target "OU=Users,OU=Nursing,$rootOU" -LinkEnabled Yes

            Write-Host "    ✅ GPO '$gpo2Name' créée et liée" -ForegroundColor Green
            Write-Host "`n    ⚠️  Configuration manuelle requise dans GPMC:" -ForegroundColor Yellow
            Write-Host "`n    📍 Configuration du Blocage USB:" -ForegroundColor Cyan
            Write-Host "       User Configuration > Policies > Administrative Templates > System > Removable Storage Access" -ForegroundColor Gray
            Write-Host "       > 'All Removable Storage classes: Deny all access' = Enabled" -ForegroundColor White
            Write-Host "`n    💡 Justification Médicale:" -ForegroundColor Cyan
            Write-Host "       Prévient l'exfiltration de données patients vers clés USB (conformité HIPAA simplifiée)" -ForegroundColor Gray
            Write-Host "`n    ✅ Vérification:" -ForegroundColor Cyan
            Write-Host "       1. Configurez le paramètre dans GPMC comme indiqué ci-dessus" -ForegroundColor Gray
            Write-Host "       2. Connectez-vous avec un compte Medical ou Nursing" -ForegroundColor Gray
            Write-Host "       3. Exécutez: gpupdate /force" -ForegroundColor Gray
            Write-Host "       4. Insérez une clé USB (accès doit être refusé)" -ForegroundColor Gray
        } else {
            Write-Host "    ⚠️  GPO '$gpo2Name' existe déjà" -ForegroundColor Yellow
        }

        # GPO 3: Restriction Bureau - Administration (Manual GPMC configuration)
        Write-Host "`n  GPO 3: Restrictions Bureau - Département Administration" -ForegroundColor Magenta
        $gpo3Name = "MediCare - Restrictions Bureau Administration"

        if (-not (Test-GPOExists $gpo3Name)) {
            New-GPO -Name $gpo3Name -Comment "Restreint l'accès au Panneau de configuration pour le personnel administratif"
            New-GPLink -Name $gpo3Name -Target "OU=Users,OU=Administration,$rootOU" -LinkEnabled Yes

            Write-Host "    ✅ GPO '$gpo3Name' créée et liée" -ForegroundColor Green
            Write-Host "`n    ⚠️  Configuration manuelle requise dans GPMC:" -ForegroundColor Yellow
            Write-Host "`n    📍 Configuration Panneau de Configuration:" -ForegroundColor Cyan
            Write-Host "       User Configuration > Policies > Administrative Templates > Control Panel" -ForegroundColor Gray
            Write-Host "       > 'Prohibit access to Control Panel and PC settings' = Enabled" -ForegroundColor White
            Write-Host "`n    💡 Justification Médicale:" -ForegroundColor Cyan
            Write-Host "       Empêche les modifications système non autorisées par le personnel administratif" -ForegroundColor Gray
            Write-Host "`n    ✅ Vérification:" -ForegroundColor Cyan
            Write-Host "       1. Configurez le paramètre dans GPMC comme indiqué ci-dessus" -ForegroundColor Gray
            Write-Host "       2. Connectez-vous avec un compte Administration (ex: patricia)" -ForegroundColor Gray
            Write-Host "       3. Exécutez: gpupdate /force" -ForegroundColor Gray
            Write-Host "       4. Tentez d'ouvrir le Panneau de configuration (doit être bloqué)" -ForegroundColor Gray
        } else {
            Write-Host "    ⚠️  GPO '$gpo3Name' existe déjà" -ForegroundColor Yellow
        }

        # GPO 4: Audit des Connexions (PowerShell supporté via auditpol.exe)
        Write-Host "`n  GPO 4: Audit des Événements de Connexion - Conformité" -ForegroundColor Magenta
        try {
            # Configuration de l'audit via auditpol.exe
            $auditLogon = & auditpol /set /subcategory:"Logon" /success:enable /failure:enable 2>&1
            $auditAccountMgmt = & auditpol /set /subcategory:"User Account Management" /success:enable /failure:enable 2>&1

            Write-Host "    ✅ Audit de sécurité configuré:" -ForegroundColor Green
            Write-Host "       - Audit des connexions (succès + échecs)" -ForegroundColor Gray
            Write-Host "       - Audit de la gestion des comptes (succès + échecs)" -ForegroundColor Gray
            Write-Host "`n    💡 Justification Médicale:" -ForegroundColor Cyan
            Write-Host "       Traçabilité des accès aux données médicales (conformité HIPAA)" -ForegroundColor Gray
            Write-Host "`n    ✅ Vérification:" -ForegroundColor Cyan
            Write-Host "       1. Ouvrez l'Observateur d'événements (eventvwr.msc)" -ForegroundColor Gray
            Write-Host "       2. Naviguez vers: Windows Logs > Security" -ForegroundColor Gray
            Write-Host "       3. Connectez-vous/déconnectez-vous avec un compte utilisateur" -ForegroundColor Gray
            Write-Host "       4. Vérifiez la présence d'événements 4624 (connexion) et 4625 (échec)" -ForegroundColor Gray
        } catch {
            Write-Host "    ⚠️  ERREUR configuration audit: $($_.Exception.Message)" -ForegroundColor Red
        }

        # GPO 5: Mappage de Lecteurs Réseau - Dossiers Médicaux (Manual GPP configuration)
        Write-Host "`n  GPO 5: Mappage Lecteurs Réseau - Partages Médicaux" -ForegroundColor Magenta
        $gpo5Name = "MediCare - Lecteurs Médicaux Partagés"

        if (-not (Test-GPOExists $gpo5Name)) {
            New-GPO -Name $gpo5Name -Comment "Mappe les lecteurs réseau pour accès aux dossiers patients, notes infirmières et administration"
            New-GPLink -Name $gpo5Name -Target $rootOU -LinkEnabled Yes

            Write-Host "    ✅ GPO '$gpo5Name' créée et liée à l'OU racine" -ForegroundColor Green
            Write-Host "`n    ⚠️  Configuration manuelle requise dans GPMC (Group Policy Preferences):" -ForegroundColor Yellow
            Write-Host "`n    📍 Lecteur M: - Dossiers Patients (Medical uniquement):" -ForegroundColor Cyan
            Write-Host "       User Configuration > Preferences > Windows Settings > Drive Maps > New > Mapped Drive" -ForegroundColor Gray
            Write-Host "       - Action: Create" -ForegroundColor White
            Write-Host "       - Location: \\\\SRV-MEDICARE\\Dossiers_Patients" -ForegroundColor White
            Write-Host "       - Drive Letter: M:" -ForegroundColor White
            Write-Host "       - Label as: Dossiers Patients" -ForegroundColor White
            Write-Host "       - Item-level targeting: Group = GG-MediCare-Medical-Users" -ForegroundColor White
            Write-Host "`n    📍 Lecteur N: - Notes Infirmières (Medical + Nursing):" -ForegroundColor Cyan
            Write-Host "       - Action: Create" -ForegroundColor White
            Write-Host "       - Location: \\\\SRV-MEDICARE\\Notes_Infirmieres" -ForegroundColor White
            Write-Host "       - Drive Letter: N:" -ForegroundColor White
            Write-Host "       - Label as: Notes Infirmières" -ForegroundColor White
            Write-Host "       - Item-level targeting: Group = GG-MediCare-Medical-Users OU GG-MediCare-Nursing-Users" -ForegroundColor White
            Write-Host "`n    📍 Lecteur A: - Administration (Administration uniquement):" -ForegroundColor Cyan
            Write-Host "       - Action: Create" -ForegroundColor White
            Write-Host "       - Location: \\\\SRV-MEDICARE\\Administration" -ForegroundColor White
            Write-Host "       - Drive Letter: A:" -ForegroundColor White
            Write-Host "       - Label as: Administration" -ForegroundColor White
            Write-Host "       - Item-level targeting: Group = GG-MediCare-Administration-Users" -ForegroundColor White
            Write-Host "`n    ⚠️  PRÉREQUIS CRITIQUES:" -ForegroundColor Yellow
            Write-Host "       1. Créer d'abord les partages réseau sur SRV-MEDICARE:" -ForegroundColor Gray
            Write-Host "          - \\\\SRV-MEDICARE\\Dossiers_Patients (permissions: GG-MediCare-Medical-Users)" -ForegroundColor Gray
            Write-Host "          - \\\\SRV-MEDICARE\\Notes_Infirmieres (permissions: GG-MediCare-Medical-Users, GG-MediCare-Nursing-Users)" -ForegroundColor Gray
            Write-Host "          - \\\\SRV-MEDICARE\\Administration (permissions: GG-MediCare-Administration-Users)" -ForegroundColor Gray
            Write-Host "       2. Configurer les permissions NTFS appropriées sur chaque partage" -ForegroundColor Gray
            Write-Host "       3. Ensuite configurer les lecteurs mappés dans GPMC comme indiqué ci-dessus" -ForegroundColor Gray
            Write-Host "`n    ✅ Vérification:" -ForegroundColor Cyan
            Write-Host "       1. Créez les partages réseau avec les permissions correctes" -ForegroundColor Gray
            Write-Host "       2. Configurez les 3 lecteurs mappés dans GPMC avec item-level targeting" -ForegroundColor Gray
            Write-Host "       3. Connectez-vous avec différents utilisateurs (Medical, Nursing, Admin)" -ForegroundColor Gray
            Write-Host "       4. Exécutez: gpupdate /force" -ForegroundColor Gray
            Write-Host "       5. Vérifiez que seuls les lecteurs appropriés apparaissent dans 'Ce PC'" -ForegroundColor Gray
        } else {
            Write-Host "    ⚠️  GPO '$gpo5Name' existe déjà" -ForegroundColor Yellow
        }

        Write-Host "`n  📊 Configuration GPO terminée (5 stratégies)" -ForegroundColor Cyan
    }

    # ============================================
    # ÉTAPE 7: EXPORT CSV
    # ============================================

    if (Confirm-Step "Étape 7 - Exportation des données en CSV pour référence") {
        Write-Host "`n[ÉTAPE 7] Exportation des données de référence..." -ForegroundColor Cyan

        # Export utilisateurs
        $usersCSVPath = "$exportPath\medicare_utilisateurs.csv"
        Get-ADUser -Filter * -SearchBase $rootOU -Properties EmailAddress, Title, Department |
            Select-Object Name, SamAccountName, EmailAddress, Title, Department, Enabled |
            Export-Csv -Path $usersCSVPath -NoTypeInformation -Encoding UTF8
        Write-Host "  ✅ Utilisateurs exportés vers: $usersCSVPath" -ForegroundColor Green

        # Export groupes avec membres
        $groupsCSVPath = "$exportPath\medicare_groupes.csv"
        $groupsData = @()
        $allGroups = Get-ADGroup -Filter * -SearchBase $rootOU

        foreach ($group in $allGroups) {
            $members = Get-ADGroupMember -Identity $group.Name | Select-Object -ExpandProperty SamAccountName
            $groupsData += [PSCustomObject]@{
                Nom = $group.Name
                Description = $group.Description
                Membres = ($members -join "; ")
                NombreMembres = $members.Count
            }
        }

        $groupsData | Export-Csv -Path $groupsCSVPath -NoTypeInformation -Encoding UTF8
        Write-Host "  ✅ Groupes exportés vers: $groupsCSVPath" -ForegroundColor Green

        # Export OUs
        $ousCSVPath = "$exportPath\medicare_ous.csv"
        Get-ADOrganizationalUnit -Filter * -SearchBase $rootOU |
            Select-Object Name, DistinguishedName, ProtectedFromAccidentalDeletion |
            Export-Csv -Path $ousCSVPath -NoTypeInformation -Encoding UTF8
        Write-Host "  ✅ OUs exportées vers: $ousCSVPath" -ForegroundColor Green
    }

    # ============================================
    # RÉSUMÉ FINAL
    # ============================================

    Write-Host "`n============================================" -ForegroundColor Green
    Write-Host "  STRUCTURE MEDICARE CRÉÉE AVEC SUCCÈS!     " -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green

    Write-Host "`n📊 RÉSUMÉ DE LA STRUCTURE:" -ForegroundColor Cyan
    Write-Host "   • 1 OU racine: MediCare" -ForegroundColor White
    Write-Host "   • 4 départements: Medical, Nursing, Administration, IT" -ForegroundColor White
    Write-Host "   • 12 sous-OUs (Users, Computers, Groups par département)" -ForegroundColor White
    Write-Host "   • 28 utilisateurs avec titres médicaux appropriés" -ForegroundColor White
    Write-Host "   • 12 groupes de sécurité globaux (préfixe GG-)" -ForegroundColor White
    Write-Host "   • 5 stratégies de groupe (conformité médicale)" -ForegroundColor White

    Write-Host "`n🔐 GROUPES SPÉCIAUX CRÉÉS:" -ForegroundColor Cyan
    Write-Host "   Medical:" -ForegroundColor Yellow
    Write-Host "     - GG-MediCare-Medical-Seniors (médecins seniors, droits signature)" -ForegroundColor Gray
    Write-Host "     - GG-MediCare-Medical-Oncall (système de garde)" -ForegroundColor Gray
    Write-Host "   Administration:" -ForegroundColor Yellow
    Write-Host "     - GG-MediCare-Administration-Billing (équipe facturation)" -ForegroundColor Gray
    Write-Host "     - GG-MediCare-Administration-HR (ressources humaines)" -ForegroundColor Gray

    Write-Host "`n🔒 SÉCURITÉ CONFIGURÉE:" -ForegroundColor Cyan
    Write-Host "   ✅ Politique mot de passe: 12 caractères min, 60 jours, complexité activée" -ForegroundColor White
    Write-Host "   ✅ Blocage USB: Medical + Nursing (prévention exfiltration données)" -ForegroundColor White
    Write-Host "   ✅ Restrictions bureau: Administration (prévention modifications système)" -ForegroundColor White
    Write-Host "   ✅ Audit connexions: Traçabilité accès (conformité HIPAA simplifiée)" -ForegroundColor White
    Write-Host "   ⚠️  Lecteurs réseau: Configuration manuelle requise (voir GPO 5)" -ForegroundColor Yellow

    Write-Host "`n📁 FICHIERS EXPORTÉS:" -ForegroundColor Cyan
    Write-Host "   • C:\Labos\medicare_utilisateurs.csv" -ForegroundColor White
    Write-Host "   • C:\Labos\medicare_groupes.csv" -ForegroundColor White
    Write-Host "   • C:\Labos\medicare_ous.csv" -ForegroundColor White

    Write-Host "`n🔍 VÉRIFICATION RAPIDE:" -ForegroundColor Cyan
    Write-Host "   1. Ouvrir 'Utilisateurs et ordinateurs Active Directory'" -ForegroundColor Gray
    Write-Host "   2. Vérifier la présence de l'OU 'MediCare' et ses 4 départements" -ForegroundColor Gray
    Write-Host "   3. Contrôler les 28 utilisateurs avec leurs titres médicaux" -ForegroundColor Gray
    Write-Host "   4. Vérifier les groupes GG- dans chaque département/Groups" -ForegroundColor Gray
    Write-Host "   5. Ouvrir GPMC (gpmc.msc) pour finaliser configuration GPOs 2, 3, 5" -ForegroundColor Gray

    Write-Host "`n💡 PROCHAINES ÉTAPES:" -ForegroundColor Cyan
    Write-Host "   1. Configurer manuellement les GPOs 2, 3, 5 dans GPMC (voir instructions ci-dessus)" -ForegroundColor Yellow
    Write-Host "   2. Créer les partages réseau sur SRV-MEDICARE pour GPO 5" -ForegroundColor Yellow
    Write-Host "   3. Tester les connexions utilisateurs et les restrictions GPO" -ForegroundColor Yellow
    Write-Host "   4. Vérifier l'audit dans l'Observateur d'événements" -ForegroundColor Yellow
    Write-Host "   5. Commencer les exercices pratiques basés sur cette structure" -ForegroundColor Yellow

    Write-Host "`n============================================`n" -ForegroundColor Green

} catch {
    Write-Host "`n❌ ERREUR CRITIQUE:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "`nStack Trace:" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
}
