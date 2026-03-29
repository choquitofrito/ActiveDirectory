# Script pour créer la structure Active Directory - Laboratoire Monitoring
# Nom du script: MonitoringLab_Setup.ps1
# Auteur: H2EB - Cours Active Directory
# Date: 2025-10-07
# Description: Crée une infrastructure AD complète pour l'apprentissage du monitoring et de l'audit AD
#
# Sources Microsoft consultées:
# - https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/advanced-audit-policy-configuration
# - https://learn.microsoft.com/en-us/powershell/module/activedirectory/set-addefaultdomainpasswordpolicy
# - https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/auditpol-set
# - https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-adorganizationalunit
# - https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-aduser
# - https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-adgroup

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

# Fonction pour vérifier l'existence d'un ordinateur
function Test-ComputerExists {
    param($computerName)
    try {
        Get-ADComputer -Identity $computerName -ErrorAction Stop
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
$rootOU = "OU=MONITORING,$domainDN"
$defaultPassword = "Monitor2024!"

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
    Write-Host "  LABORATOIRE MONITORING ACTIVE DIRECTORY  " -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Ce script va créer:" -ForegroundColor Cyan
    Write-Host "  - Structure OU pour une entreprise de monitoring IT" -ForegroundColor Gray
    Write-Host "  - 20+ utilisateurs répartis dans 4 départements" -ForegroundColor Gray
    Write-Host "  - Groupes de sécurité avec préfixe GG-" -ForegroundColor Gray
    Write-Host "  - Comptes ordinateurs (DCs, serveurs, stations)" -ForegroundColor Gray
    Write-Host "  - Comptes de service pour monitoring" -ForegroundColor Gray
    Write-Host "  - Politiques d'audit avancées (via auditpol)" -ForegroundColor Gray
    Write-Host "  - GPOs pour journaux d'événements" -ForegroundColor Gray
    Write-Host ""

    # ============================================
    # ÉTAPE 1: CRÉATION DE LA STRUCTURE DES OUs
    # ============================================

    if (Confirm-Step "Étape 1 - Création de la structure des Unités Organisationnelles") {
        Write-Host "`n[ÉTAPE 1] Création de la structure des OUs..." -ForegroundColor Green

        # OU racine
        if (-not (Test-OUExists $rootOU)) {
            New-ADOrganizationalUnit -Name "MONITORING" -Path $domainDN -ProtectedFromAccidentalDeletion $false
            Write-Host "  [CRÉÉ] OU=MONITORING,$domainDN" -ForegroundColor Green
        } else {
            Write-Host "  [EXISTE] OU=MONITORING,$domainDN" -ForegroundColor Yellow
        }

        # Départements principaux
        $departments = @(
            @{Name="ITOperations"; Description="Équipe opérations informatiques"},
            @{Name="Security"; Description="Équipe sécurité et audit"},
            @{Name="RH"; Description="Ressources Humaines"},
            @{Name="Finance"; Description="Département financier"},
            @{Name="ServiceAccounts"; Description="Comptes de service système"},
            @{Name="Computers"; Description="Ordinateurs et serveurs"}
        )

        foreach ($dept in $departments) {
            $deptOU = "OU=$($dept.Name),$rootOU"
            if (-not (Test-OUExists $deptOU)) {
                New-ADOrganizationalUnit -Name $dept.Name -Path $rootOU -Description $dept.Description -ProtectedFromAccidentalDeletion $false
                Write-Host "  [CRÉÉ] $deptOU" -ForegroundColor Green
            } else {
                Write-Host "  [EXISTE] $deptOU" -ForegroundColor Yellow
            }

            # Sous-OUs pour départements normaux (pas pour ServiceAccounts ni Computers)
            if ($dept.Name -notin @("ServiceAccounts", "Computers")) {
                $subOUs = @("Users", "Computers", "Groups")
                foreach ($subOU in $subOUs) {
                    $subOUPath = "OU=$subOU,$deptOU"
                    if (-not (Test-OUExists $subOUPath)) {
                        New-ADOrganizationalUnit -Name $subOU -Path $deptOU -ProtectedFromAccidentalDeletion $false
                        Write-Host "    [CRÉÉ] $subOUPath" -ForegroundColor Green
                    } else {
                        Write-Host "    [EXISTE] $subOUPath" -ForegroundColor Yellow
                    }
                }
            }
        }

        # Sous-OUs spécifiques pour Computers
        $computerTypes = @("DomainControllers", "Servers", "Workstations")
        foreach ($type in $computerTypes) {
            $compOU = "OU=$type,OU=Computers,$rootOU"
            if (-not (Test-OUExists $compOU)) {
                New-ADOrganizationalUnit -Name $type -Path "OU=Computers,$rootOU" -ProtectedFromAccidentalDeletion $false
                Write-Host "  [CRÉÉ] $compOU" -ForegroundColor Green
            } else {
                Write-Host "  [EXISTE] $compOU" -ForegroundColor Yellow
            }
        }

        Write-Host "`n  Structure des OUs créée avec succès!" -ForegroundColor Green
    }

    # ============================================
    # ÉTAPE 2: CRÉATION DES UTILISATEURS
    # ============================================

    if (Confirm-Step "Étape 2 - Création des utilisateurs") {
        Write-Host "`n[ÉTAPE 2] Création des utilisateurs..." -ForegroundColor Green

        $users = @(
            # ITOperations (5 utilisateurs)
            @{FirstName="Alexandre"; LastName="Martin"; Dept="ITOperations"; Title="Responsable Infrastructure"; SAM="alexandre"},
            @{FirstName="Béatrice"; LastName="Dubois"; Dept="ITOperations"; Title="Administrateur Systèmes"; SAM="beatrice"},
            @{FirstName="Charles"; LastName="Lefebvre"; Dept="ITOperations"; Title="Ingénieur Réseau"; SAM="charles"},
            @{FirstName="Diane"; LastName="Bernard"; Dept="ITOperations"; Title="Technicien Support"; SAM="diane"},
            @{FirstName="Émile"; LastName="Rousseau"; Dept="ITOperations"; Title="Spécialiste Virtualisation"; SAM="emile"},

            # Security (5 utilisateurs)
            @{FirstName="Fabien"; LastName="Moreau"; Dept="Security"; Title="Responsable Sécurité (RSSI)"; SAM="fabien"},
            @{FirstName="Gabrielle"; LastName="Simon"; Dept="Security"; Title="Analyste Sécurité Senior"; SAM="gabrielle"},
            @{FirstName="Henri"; LastName="Laurent"; Dept="Security"; Title="Auditeur Systèmes"; SAM="henri"},
            @{FirstName="Isabelle"; LastName="Michel"; Dept="Security"; Title="Spécialiste Conformité"; SAM="isabelle"},
            @{FirstName="Julien"; LastName="Leroy"; Dept="Security"; Title="Analyste SOC"; SAM="julien"},

            # RH (5 utilisateurs)
            @{FirstName="Karine"; LastName="Fontaine"; Dept="RH"; Title="Directrice Ressources Humaines"; SAM="karine"},
            @{FirstName="Laurent"; LastName="Chevalier"; Dept="RH"; Title="Gestionnaire Paie"; SAM="laurent"},
            @{FirstName="Marie"; LastName="Girard"; Dept="RH"; Title="Responsable Recrutement"; SAM="marie"},
            @{FirstName="Nicolas"; LastName="Bonnet"; Dept="RH"; Title="Assistant RH"; SAM="nicolas"},
            @{FirstName="Olivia"; LastName="Dupont"; Dept="RH"; Title="Formatrice Interne"; SAM="olivia"},

            # Finance (5 utilisateurs)
            @{FirstName="Pascal"; LastName="Roux"; Dept="Finance"; Title="Directeur Financier (CFO)"; SAM="pascal"},
            @{FirstName="Quentin"; LastName="Garnier"; Dept="Finance"; Title="Contrôleur de Gestion"; SAM="quentin"},
            @{FirstName="Rachel"; LastName="Fabre"; Dept="Finance"; Title="Comptable Senior"; SAM="rachel"},
            @{FirstName="Sylvain"; LastName="Perrin"; Dept="Finance"; Title="Analyste Financier"; SAM="sylvain"},
            @{FirstName="Théa"; LastName="Morel"; Dept="Finance"; Title="Assistante Comptable"; SAM="thea"}
        )

        foreach ($user in $users) {
            $userOU = "OU=Users,OU=$($user.Dept),$rootOU"
            $userParams = @{
                Name = "$($user.FirstName) $($user.LastName)"
                GivenName = $user.FirstName
                Surname = $user.LastName
                SamAccountName = $user.SAM
                UserPrincipalName = "$($user.SAM)@maxtec.be"
                EmailAddress = "$($user.SAM)@maxtec.be"
                DisplayName = "$($user.FirstName) $($user.LastName)"
                Title = $user.Title
                Department = $user.Dept
                Path = $userOU
                AccountPassword = (ConvertTo-SecureString $defaultPassword -AsPlainText -Force)
                Enabled = $true
                ChangePasswordAtLogon = $false
            }

            if (-not (Test-UserExists $user.SAM)) {
                New-ADUser @userParams
                Write-Host "  [CRÉÉ] $($user.FirstName) $($user.LastName) ($($user.SAM)) - $($user.Title)" -ForegroundColor Green
            } else {
                Write-Host "  [EXISTE] $($user.FirstName) $($user.LastName) ($($user.SAM))" -ForegroundColor Yellow
            }
        }

        # Comptes de service pour monitoring
        Write-Host "`n  Création des comptes de service..." -ForegroundColor Cyan
        $serviceAccounts = @(
            @{Name="svc_monitoring"; Description="Compte service pour outils monitoring (PRTG/Nagios)"},
            @{Name="svc_backup"; Description="Compte service pour sauvegarde AD"},
            @{Name="svc_audit"; Description="Compte service pour collecte logs audit"},
            @{Name="svc_replication"; Description="Compte service pour vérification réplication AD"}
        )

        foreach ($svcAcct in $serviceAccounts) {
            $svcOU = "OU=ServiceAccounts,$rootOU"
            $svcParams = @{
                Name = $svcAcct.Name
                SamAccountName = $svcAcct.Name
                UserPrincipalName = "$($svcAcct.Name)@maxtec.be"
                DisplayName = $svcAcct.Name
                Description = $svcAcct.Description
                Path = $svcOU
                AccountPassword = (ConvertTo-SecureString "ServiceP@ss2024!" -AsPlainText -Force)
                Enabled = $true
                PasswordNeverExpires = $true
                CannotChangePassword = $true
            }

            if (-not (Test-UserExists $svcAcct.Name)) {
                New-ADUser @svcParams
                Write-Host "  [CRÉÉ] Compte service: $($svcAcct.Name)" -ForegroundColor Green
            } else {
                Write-Host "  [EXISTE] Compte service: $($svcAcct.Name)" -ForegroundColor Yellow
            }
        }

        Write-Host "`n  Tous les utilisateurs créés avec succès!" -ForegroundColor Green
    }

    # ============================================
    # ÉTAPE 3: CRÉATION DES GROUPES DE SÉCURITÉ
    # ============================================

    if (Confirm-Step "Étape 3 - Création des groupes de sécurité") {
        Write-Host "`n[ÉTAPE 3] Création des groupes de sécurité..." -ForegroundColor Green

        $groups = @(
            # Groupes ITOperations
            @{Name="GG-MONITORING-ITOperations-Users"; Description="Tous les utilisateurs IT Operations"; Dept="ITOperations"; Scope="Global"},
            @{Name="GG-MONITORING-ITOperations-Admin"; Description="Administrateurs IT Operations"; Dept="ITOperations"; Scope="Global"},

            # Groupes Security
            @{Name="GG-MONITORING-Security-Users"; Description="Tous les utilisateurs Sécurité"; Dept="Security"; Scope="Global"},
            @{Name="GG-MONITORING-Security-Admin"; Description="Administrateurs Sécurité"; Dept="Security"; Scope="Global"},
            @{Name="GG-MONITORING-SecurityAuditors"; Description="Auditeurs avec accès lecture seule aux logs"; Dept="Security"; Scope="Global"},

            # Groupes RH
            @{Name="GG-MONITORING-RH-Users"; Description="Tous les utilisateurs RH"; Dept="RH"; Scope="Global"},
            @{Name="GG-MONITORING-RH-Admin"; Description="Administrateurs RH"; Dept="RH"; Scope="Global"},

            # Groupes Finance
            @{Name="GG-MONITORING-Finance-Users"; Description="Tous les utilisateurs Finance"; Dept="Finance"; Scope="Global"},
            @{Name="GG-MONITORING-Finance-Admin"; Description="Administrateurs Finance"; Dept="Finance"; Scope="Global"},

            # Groupes spéciaux monitoring
            @{Name="GG-MONITORING-MonitoringAdmins"; Description="Administrateurs monitoring complet (accès total)"; Dept="ITOperations"; Scope="Global"},
            @{Name="GG-MONITORING-ServiceAccounts"; Description="Comptes de service pour monitoring"; Dept="ServiceAccounts"; Scope="Global"}
        )

        foreach ($group in $groups) {
            $groupOU = "OU=Groups,OU=$($group.Dept),$rootOU"
            # Exception pour les groupes spéciaux qui n'ont pas de sous-OU Groups
            if ($group.Dept -eq "ServiceAccounts") {
                $groupOU = "OU=ServiceAccounts,$rootOU"
            }

            $groupParams = @{
                Name = $group.Name
                GroupScope = $group.Scope
                GroupCategory = "Security"
                Description = $group.Description
                Path = $groupOU
            }

            if (-not (Test-GroupExists $group.Name)) {
                New-ADGroup @groupParams
                Write-Host "  [CRÉÉ] $($group.Name)" -ForegroundColor Green
            } else {
                Write-Host "  [EXISTE] $($group.Name)" -ForegroundColor Yellow
            }
        }

        Write-Host "`n  Tous les groupes créés avec succès!" -ForegroundColor Green
    }

    # ============================================
    # ÉTAPE 4: AJOUT DES MEMBRES AUX GROUPES
    # ============================================

    if (Confirm-Step "Étape 4 - Ajout des membres aux groupes") {
        Write-Host "`n[ÉTAPE 4] Ajout des membres aux groupes..." -ForegroundColor Green

        # Définition des appartenances
        $memberships = @{
            "ITOperations" = @{
                AllUsers = @("alexandre", "beatrice", "charles", "diane", "emile")
                Admins = @("alexandre") # Premier alphabétiquement
            }
            "Security" = @{
                AllUsers = @("fabien", "gabrielle", "henri", "isabelle", "julien")
                Admins = @("fabien") # Premier alphabétiquement
                Auditors = @("henri", "isabelle", "julien") # Auditeurs spécifiques
            }
            "RH" = @{
                AllUsers = @("karine", "laurent", "marie", "nicolas", "olivia")
                Admins = @("karine")
            }
            "Finance" = @{
                AllUsers = @("pascal", "quentin", "rachel", "sylvain", "thea")
                Admins = @("pascal")
            }
        }

        # Ajout des membres standards
        foreach ($dept in $memberships.Keys) {
            $usersGroup = "GG-MONITORING-$dept-Users"
            $adminsGroup = "GG-MONITORING-$dept-Admin"

            # Ajouter tous les utilisateurs au groupe Users
            foreach ($userSam in $memberships[$dept].AllUsers) {
                try {
                    Add-ADGroupMember -Identity $usersGroup -Members $userSam -ErrorAction Stop
                    Write-Host "  [AJOUTÉ] $userSam → $usersGroup" -ForegroundColor Green
                } catch {
                    if ($_.Exception.Message -like "*already a member*") {
                        Write-Host "  [EXISTE] $userSam → $usersGroup" -ForegroundColor Yellow
                    } else {
                        Write-Host "  [ERREUR] $userSam → $usersGroup : $($_.Exception.Message)" -ForegroundColor Red
                    }
                }
            }

            # Ajouter les admins au groupe Admin
            foreach ($adminSam in $memberships[$dept].Admins) {
                try {
                    Add-ADGroupMember -Identity $adminsGroup -Members $adminSam -ErrorAction Stop
                    Write-Host "  [AJOUTÉ] $adminSam → $adminsGroup (ADMIN)" -ForegroundColor Cyan
                } catch {
                    if ($_.Exception.Message -like "*already a member*") {
                        Write-Host "  [EXISTE] $adminSam → $adminsGroup" -ForegroundColor Yellow
                    } else {
                        Write-Host "  [ERREUR] $adminSam → $adminsGroup : $($_.Exception.Message)" -ForegroundColor Red
                    }
                }
            }
        }

        # Groupe spécial SecurityAuditors
        Write-Host "`n  Ajout des auditeurs au groupe SecurityAuditors..." -ForegroundColor Cyan
        foreach ($auditor in $memberships["Security"].Auditors) {
            try {
                Add-ADGroupMember -Identity "GG-MONITORING-SecurityAuditors" -Members $auditor -ErrorAction Stop
                Write-Host "  [AJOUTÉ] $auditor → GG-MONITORING-SecurityAuditors" -ForegroundColor Green
            } catch {
                if ($_.Exception.Message -like "*already a member*") {
                    Write-Host "  [EXISTE] $auditor → GG-MONITORING-SecurityAuditors" -ForegroundColor Yellow
                }
            }
        }

        # Groupe MonitoringAdmins (administrateurs IT + Responsable Sécurité)
        Write-Host "`n  Ajout des administrateurs monitoring..." -ForegroundColor Cyan
        $monitoringAdmins = @("alexandre", "beatrice", "fabien")
        foreach ($admin in $monitoringAdmins) {
            try {
                Add-ADGroupMember -Identity "GG-MONITORING-MonitoringAdmins" -Members $admin -ErrorAction Stop
                Write-Host "  [AJOUTÉ] $admin → GG-MONITORING-MonitoringAdmins" -ForegroundColor Green
            } catch {
                if ($_.Exception.Message -like "*already a member*") {
                    Write-Host "  [EXISTE] $admin → GG-MONITORING-MonitoringAdmins" -ForegroundColor Yellow
                }
            }
        }

        # Groupe ServiceAccounts
        Write-Host "`n  Ajout des comptes de service..." -ForegroundColor Cyan
        $svcAccounts = @("svc_monitoring", "svc_backup", "svc_audit", "svc_replication")
        foreach ($svc in $svcAccounts) {
            try {
                Add-ADGroupMember -Identity "GG-MONITORING-ServiceAccounts" -Members $svc -ErrorAction Stop
                Write-Host "  [AJOUTÉ] $svc → GG-MONITORING-ServiceAccounts" -ForegroundColor Green
            } catch {
                if ($_.Exception.Message -like "*already a member*") {
                    Write-Host "  [EXISTE] $svc → GG-MONITORING-ServiceAccounts" -ForegroundColor Yellow
                }
            }
        }

        Write-Host "`n  Toutes les appartenances configurées avec succès!" -ForegroundColor Green
    }

    # ============================================
    # ÉTAPE 5: CRÉATION DES ORDINATEURS
    # ============================================

    if (Confirm-Step "Étape 5 - Création des comptes ordinateurs") {
        Write-Host "`n[ÉTAPE 5] Création des comptes ordinateurs..." -ForegroundColor Green

        # Contrôleurs de domaine
        $domainControllers = @(
            @{Name="MON-DC01"; Description="Contrôleur de domaine principal"; Location="DataCenter Brussels"},
            @{Name="MON-DC02"; Description="Contrôleur de domaine secondaire"; Location="DataCenter Antwerp"}
        )

        Write-Host "`n  Création des contrôleurs de domaine..." -ForegroundColor Cyan
        foreach ($dc in $domainControllers) {
            $dcOU = "OU=DomainControllers,OU=Computers,$rootOU"
            if (-not (Test-ComputerExists $dc.Name)) {
                New-ADComputer -Name $dc.Name -SAMAccountName $dc.Name -Path $dcOU -Description $dc.Description -Location $dc.Location -Enabled $true
                Write-Host "  [CRÉÉ] $($dc.Name) - $($dc.Description)" -ForegroundColor Green
            } else {
                Write-Host "  [EXISTE] $($dc.Name)" -ForegroundColor Yellow
            }
        }

        # Serveurs
        $servers = @(
            @{Name="MON-SRV-MONITORING"; Description="Serveur monitoring PRTG/Nagios"; Location="DataCenter Brussels"},
            @{Name="MON-SRV-LOG"; Description="Serveur centralisation logs (SIEM)"; Location="DataCenter Brussels"},
            @{Name="MON-SRV-BACKUP"; Description="Serveur sauvegarde et récupération"; Location="DataCenter Antwerp"},
            @{Name="MON-SRV-FILE"; Description="Serveur fichiers départemental"; Location="DataCenter Brussels"}
        )

        Write-Host "`n  Création des serveurs..." -ForegroundColor Cyan
        foreach ($srv in $servers) {
            $srvOU = "OU=Servers,OU=Computers,$rootOU"
            if (-not (Test-ComputerExists $srv.Name)) {
                New-ADComputer -Name $srv.Name -SAMAccountName $srv.Name -Path $srvOU -Description $srv.Description -Location $srv.Location -Enabled $true
                Write-Host "  [CRÉÉ] $($srv.Name) - $($srv.Description)" -ForegroundColor Green
            } else {
                Write-Host "  [EXISTE] $($srv.Name)" -ForegroundColor Yellow
            }
        }

        # Stations de travail
        $workstations = @(
            @{Name="MON-WS-IT01"; Description="Poste Alexandre Martin (IT Ops)"; Location="Brussels Office - Floor 2"},
            @{Name="MON-WS-IT02"; Description="Poste Béatrice Dubois (IT Ops)"; Location="Brussels Office - Floor 2"},
            @{Name="MON-WS-SEC01"; Description="Poste Fabien Moreau (Security)"; Location="Brussels Office - Floor 3"},
            @{Name="MON-WS-SEC02"; Description="Poste Gabrielle Simon (Security)"; Location="Brussels Office - Floor 3"},
            @{Name="MON-WS-RH01"; Description="Poste Karine Fontaine (RH)"; Location="Brussels Office - Floor 1"},
            @{Name="MON-WS-FIN01"; Description="Poste Pascal Roux (Finance)"; Location="Brussels Office - Floor 1"}
        )

        Write-Host "`n  Création des stations de travail..." -ForegroundColor Cyan
        foreach ($ws in $workstations) {
            $wsOU = "OU=Workstations,OU=Computers,$rootOU"
            if (-not (Test-ComputerExists $ws.Name)) {
                New-ADComputer -Name $ws.Name -SAMAccountName $ws.Name -Path $wsOU -Description $ws.Description -Location $ws.Location -Enabled $true
                Write-Host "  [CRÉÉ] $($ws.Name) - $($ws.Description)" -ForegroundColor Green
            } else {
                Write-Host "  [EXISTE] $($ws.Name)" -ForegroundColor Yellow
            }
        }

        Write-Host "`n  Tous les ordinateurs créés avec succès!" -ForegroundColor Green
    }

    # ============================================
    # ÉTAPE 6: CONFIGURATION POLITIQUE DE MOTS DE PASSE
    # ============================================

    if (Confirm-Step "Étape 6 - Configuration de la politique de mots de passe du domaine") {
        Write-Host "`n[ÉTAPE 6] Configuration de la politique de mots de passe..." -ForegroundColor Green

        try {
            Set-ADDefaultDomainPasswordPolicy -Identity "maxtec.be" `
                -MinPasswordLength 12 `
                -PasswordHistoryCount 24 `
                -MaxPasswordAge (New-TimeSpan -Days 90) `
                -MinPasswordAge (New-TimeSpan -Days 1) `
                -ComplexityEnabled $true `
                -LockoutThreshold 5 `
                -LockoutDuration (New-TimeSpan -Minutes 30) `
                -LockoutObservationWindow (New-TimeSpan -Minutes 30) `
                -ReversibleEncryptionEnabled $false

            Write-Host "  [CONFIGURÉ] Politique de mots de passe du domaine:" -ForegroundColor Green
            Write-Host "    - Longueur minimale: 12 caractères" -ForegroundColor Gray
            Write-Host "    - Complexité: Activée (majuscules, minuscules, chiffres, symboles)" -ForegroundColor Gray
            Write-Host "    - Âge maximum: 90 jours" -ForegroundColor Gray
            Write-Host "    - Âge minimum: 1 jour" -ForegroundColor Gray
            Write-Host "    - Historique: 24 mots de passe mémorisés" -ForegroundColor Gray
            Write-Host "    - Seuil de verrouillage: 5 tentatives échouées" -ForegroundColor Gray
            Write-Host "    - Durée de verrouillage: 30 minutes" -ForegroundColor Gray
            Write-Host "    - Fenêtre d'observation: 30 minutes" -ForegroundColor Gray
        } catch {
            Write-Host "  [ERREUR] Configuration politique: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    # ============================================
    # ÉTAPE 7: CONFIGURATION DES POLITIQUES D'AUDIT
    # ============================================

    if (Confirm-Step "Étape 7 - Configuration des politiques d'audit avancées (auditpol)") {
        Write-Host "`n[ÉTAPE 7] Configuration des politiques d'audit..." -ForegroundColor Green
        Write-Host "  Source: https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/auditpol-set" -ForegroundColor Gray

        # Activation des audits via auditpol.exe
        $auditPolicies = @(
            @{Category="Logon"; Subcategory="Logon"; Success=$true; Failure=$true; Description="Connexions utilisateurs"},
            @{Category="Logon"; Subcategory="Logoff"; Success=$true; Failure=$false; Description="Déconnexions utilisateurs"},
            @{Category="Account Logon"; Subcategory="Credential Validation"; Success=$true; Failure=$true; Description="Validation credentials"},
            @{Category="Account Management"; Subcategory="User Account Management"; Success=$true; Failure=$true; Description="Gestion comptes utilisateurs"},
            @{Category="Account Management"; Subcategory="Security Group Management"; Success=$true; Failure=$true; Description="Gestion groupes de sécurité"},
            @{Category="Account Management"; Subcategory="Computer Account Management"; Success=$true; Failure=$true; Description="Gestion comptes ordinateurs"},
            @{Category="Policy Change"; Subcategory="Audit Policy Change"; Success=$true; Failure=$true; Description="Modifications politiques d'audit"},
            @{Category="Policy Change"; Subcategory="Authentication Policy Change"; Success=$true; Failure=$true; Description="Modifications politiques authentification"},
            @{Category="Privilege Use"; Subcategory="Sensitive Privilege Use"; Success=$true; Failure=$true; Description="Utilisation privilèges sensibles"},
            @{Category="DS Access"; Subcategory="Directory Service Access"; Success=$true; Failure=$true; Description="Accès AD DS"},
            @{Category="DS Access"; Subcategory="Directory Service Changes"; Success=$true; Failure=$false; Description="Modifications AD DS"},
            @{Category="Object Access"; Subcategory="File Share"; Success=$true; Failure=$true; Description="Accès partages fichiers"}
        )

        foreach ($policy in $auditPolicies) {
            $successFlag = if ($policy.Success) { "enable" } else { "disable" }
            $failureFlag = if ($policy.Failure) { "enable" } else { "disable" }

            try {
                $cmd = "auditpol /set /subcategory:`"$($policy.Subcategory)`" /success:$successFlag /failure:$failureFlag"
                Invoke-Expression $cmd | Out-Null
                Write-Host "  [CONFIGURÉ] $($policy.Subcategory) - $($policy.Description)" -ForegroundColor Green
                Write-Host "    Success: $successFlag | Failure: $failureFlag" -ForegroundColor Gray
            } catch {
                Write-Host "  [ERREUR] $($policy.Subcategory): $($_.Exception.Message)" -ForegroundColor Red
            }
        }

        Write-Host "`n  Politiques d'audit configurées avec succès!" -ForegroundColor Green
        Write-Host "  Les événements seront enregistrés dans le journal Sécurité Windows." -ForegroundColor Cyan
    }

    # ============================================
    # ÉTAPE 8: CRÉATION DES GPOs (SHELLS UNIQUEMENT)
    # ============================================

    if (Confirm-Step "Étape 8 - Création des GPOs de monitoring (configuration manuelle requise)") {
        Write-Host "`n[ÉTAPE 8] Création des GPOs de monitoring..." -ForegroundColor Green

        # GPO 1: Taille et rétention des journaux d'événements
        $gpo1 = "MONITORING - Configuration Journaux Événements"
        if (-not (Test-GPOExists $gpo1)) {
            New-GPO -Name $gpo1 -Comment "Configure la taille maximale et la rétention des journaux Sécurité, Application, Système"
            New-GPLink -Name $gpo1 -Target $rootOU -LinkEnabled Yes

            Write-Host "`n  [GPO CRÉÉE] $gpo1" -ForegroundColor Green
            Write-Host "  Liée à: $rootOU" -ForegroundColor Gray
            Write-Host "`n  ⚠️  CONFIGURATION MANUELLE REQUISE dans GPMC:" -ForegroundColor Yellow
            Write-Host "`n  📍 Étape 1 - Journal Sécurité (Security Log):" -ForegroundColor Cyan
            Write-Host "     Computer Config > Policies > Administrative Templates > Windows Components" -ForegroundColor Gray
            Write-Host "     > Event Log Service > Security" -ForegroundColor Gray
            Write-Host "     • Specify the maximum log file size (KB) = Enabled → 2097151 KB (2 GB)" -ForegroundColor White
            Write-Host "     • Control Event Log behavior when the log file reaches its maximum size = Enabled → Overwrite events as needed" -ForegroundColor White
            Write-Host "`n  📍 Étape 2 - Journal Application:" -ForegroundColor Cyan
            Write-Host "     Computer Config > Policies > Administrative Templates > Windows Components" -ForegroundColor Gray
            Write-Host "     > Event Log Service > Application" -ForegroundColor Gray
            Write-Host "     • Specify the maximum log file size (KB) = Enabled → 524288 KB (512 MB)" -ForegroundColor White
            Write-Host "`n  📍 Étape 3 - Journal Système:" -ForegroundColor Cyan
            Write-Host "     Computer Config > Policies > Administrative Templates > Windows Components" -ForegroundColor Gray
            Write-Host "     > Event Log Service > System" -ForegroundColor Gray
            Write-Host "     • Specify the maximum log file size (KB) = Enabled → 524288 KB (512 MB)" -ForegroundColor White
            Write-Host "`n  ✅ Vérification:" -ForegroundColor Cyan
            Write-Host "     1. Appliquer la GPO: gpupdate /force" -ForegroundColor Gray
            Write-Host "     2. Ouvrir Event Viewer (eventvwr.msc)" -ForegroundColor Gray
            Write-Host "     3. Clic droit sur Security Log > Properties → vérifier Max Log Size = 2 GB" -ForegroundColor Gray
            Write-Host "     4. PowerShell: Get-WinEvent -ListLog Security | Select-Object MaximumSizeInBytes" -ForegroundColor Gray
        } else {
            Write-Host "  [EXISTE] $gpo1" -ForegroundColor Yellow
        }

        # GPO 2: Restrictions accès ordinateurs sensibles (Security & Monitoring)
        $gpo2 = "MONITORING - Restrictions Stations Sensibles"
        if (-not (Test-GPOExists $gpo2)) {
            New-GPO -Name $gpo2 -Comment "Restreint accès USB et CMD pour stations Security et IT Ops"
            New-GPLink -Name $gpo2 -Target "OU=Computers,OU=Security,$rootOU" -LinkEnabled Yes
            New-GPLink -Name $gpo2 -Target "OU=Computers,OU=ITOperations,$rootOU" -LinkEnabled Yes

            Write-Host "`n  [GPO CRÉÉE] $gpo2" -ForegroundColor Green
            Write-Host "  Liée à: OU=Computers,OU=Security,$rootOU" -ForegroundColor Gray
            Write-Host "         OU=Computers,OU=ITOperations,$rootOU" -ForegroundColor Gray
            Write-Host "`n  ⚠️  CONFIGURATION MANUELLE REQUISE dans GPMC:" -ForegroundColor Yellow
            Write-Host "`n  📍 Bloquer périphériques USB amovibles:" -ForegroundColor Cyan
            Write-Host "     Computer Config > Policies > Administrative Templates > System" -ForegroundColor Gray
            Write-Host "     > Removable Storage Access" -ForegroundColor Gray
            Write-Host "     • All Removable Storage classes: Deny all access = Enabled" -ForegroundColor White
            Write-Host "`n  ✅ Vérification:" -ForegroundColor Cyan
            Write-Host "     1. Connecter une clé USB à un ordinateur du département Security/IT" -ForegroundColor Gray
            Write-Host "     2. Exécuter: gpupdate /force" -ForegroundColor Gray
            Write-Host "     3. La clé USB doit être bloquée avec message d'erreur" -ForegroundColor Gray
        } else {
            Write-Host "  [EXISTE] $gpo2" -ForegroundColor Yellow
        }

        # GPO 3: Verrouillage automatique session inactive
        $gpo3 = "MONITORING - Verrouillage Session Automatique"
        if (-not (Test-GPOExists $gpo3)) {
            New-GPO -Name $gpo3 -Comment "Verrouille automatiquement les sessions inactives après 10 minutes"
            New-GPLink -Name $gpo3 -Target $rootOU -LinkEnabled Yes

            Write-Host "`n  [GPO CRÉÉE] $gpo3" -ForegroundColor Green
            Write-Host "  Liée à: $rootOU" -ForegroundColor Gray
            Write-Host "`n  ⚠️  CONFIGURATION MANUELLE REQUISE dans GPMC:" -ForegroundColor Yellow
            Write-Host "`n  📍 Délai verrouillage automatique:" -ForegroundColor Cyan
            Write-Host "     Computer Config > Policies > Windows Settings > Security Settings" -ForegroundColor Gray
            Write-Host "     > Local Policies > Security Options" -ForegroundColor Gray
            Write-Host "     • Interactive logon: Machine inactivity limit = 600 secondes (10 minutes)" -ForegroundColor White
            Write-Host "`n  ✅ Vérification:" -ForegroundColor Cyan
            Write-Host "     1. Appliquer la GPO: gpupdate /force" -ForegroundColor Gray
            Write-Host "     2. Laisser une session inactive pendant 10 minutes" -ForegroundColor Gray
            Write-Host "     3. L'écran doit se verrouiller automatiquement" -ForegroundColor Gray
        } else {
            Write-Host "  [EXISTE] $gpo3" -ForegroundColor Yellow
        }

        Write-Host "`n  GPOs créées avec succès! Configuration manuelle requise dans GPMC." -ForegroundColor Green
    }

    # ============================================
    # ÉTAPE 9: EXPORT CSV POUR DOCUMENTATION
    # ============================================

    if (Confirm-Step "Étape 9 - Export des données en CSV pour documentation") {
        Write-Host "`n[ÉTAPE 9] Export des données en CSV..." -ForegroundColor Green

        # Export utilisateurs
        $csvUsers = "$exportPath\MonitoringLab_Utilisateurs.csv"
        Get-ADUser -Filter * -SearchBase $rootOU -Properties EmailAddress, Title, Department, Enabled |
            Select-Object Name, SamAccountName, EmailAddress, Title, Department, Enabled, DistinguishedName |
            Export-Csv -Path $csvUsers -NoTypeInformation -Encoding UTF8
        Write-Host "  [EXPORTÉ] $csvUsers" -ForegroundColor Green

        # Export groupes avec membres
        $csvGroups = "$exportPath\MonitoringLab_Groupes.csv"
        $groupData = @()
        $groups = Get-ADGroup -Filter * -SearchBase $rootOU
        foreach ($group in $groups) {
            $members = Get-ADGroupMember -Identity $group.Name | Select-Object -ExpandProperty SamAccountName
            $groupData += [PSCustomObject]@{
                GroupName = $group.Name
                Description = $group.Description
                GroupScope = $group.GroupScope
                Members = ($members -join "; ")
                MemberCount = $members.Count
            }
        }
        $groupData | Export-Csv -Path $csvGroups -NoTypeInformation -Encoding UTF8
        Write-Host "  [EXPORTÉ] $csvGroups" -ForegroundColor Green

        # Export ordinateurs
        $csvComputers = "$exportPath\MonitoringLab_Ordinateurs.csv"
        Get-ADComputer -Filter * -SearchBase $rootOU -Properties Description, Location, OperatingSystem |
            Select-Object Name, Description, Location, OperatingSystem, Enabled, DistinguishedName |
            Export-Csv -Path $csvComputers -NoTypeInformation -Encoding UTF8
        Write-Host "  [EXPORTÉ] $csvComputers" -ForegroundColor Green

        # Export GPOs
        $csvGPOs = "$exportPath\MonitoringLab_GPOs.csv"
        Get-GPO -All | Where-Object {$_.DisplayName -like "MONITORING*"} |
            Select-Object DisplayName, GpoStatus, CreationTime, ModificationTime, Description |
            Export-Csv -Path $csvGPOs -NoTypeInformation -Encoding UTF8
        Write-Host "  [EXPORTÉ] $csvGPOs" -ForegroundColor Green

        Write-Host "`n  Tous les fichiers CSV exportés dans: $exportPath" -ForegroundColor Green
    }

    # ============================================
    # RÉSUMÉ FINAL
    # ============================================

    Write-Host "`n============================================" -ForegroundColor Green
    Write-Host "  LABORATOIRE CRÉÉ AVEC SUCCÈS!            " -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "📊 Résumé de la structure créée:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Unités Organisationnelles:" -ForegroundColor Yellow
    Write-Host "    - 1 OU racine: MONITORING" -ForegroundColor Gray
    Write-Host "    - 4 départements: ITOperations, Security, RH, Finance" -ForegroundColor Gray
    Write-Host "    - 2 OUs spéciales: ServiceAccounts, Computers" -ForegroundColor Gray
    Write-Host "    - 15 sous-OUs (Users, Computers, Groups par département)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Utilisateurs:" -ForegroundColor Yellow
    Write-Host "    - 20 utilisateurs normaux (5 par département)" -ForegroundColor Gray
    Write-Host "    - 4 comptes de service (monitoring, backup, audit, replication)" -ForegroundColor Gray
    Write-Host "    - Mot de passe par défaut: $defaultPassword" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Groupes de Sécurité (tous avec préfixe GG-):" -ForegroundColor Yellow
    Write-Host "    - 8 groupes départementaux (Users + Admin par département)" -ForegroundColor Gray
    Write-Host "    - 3 groupes spéciaux (MonitoringAdmins, SecurityAuditors, ServiceAccounts)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Ordinateurs:" -ForegroundColor Yellow
    Write-Host "    - 2 contrôleurs de domaine (MON-DC01, MON-DC02)" -ForegroundColor Gray
    Write-Host "    - 4 serveurs (monitoring, logs, backup, fichiers)" -ForegroundColor Gray
    Write-Host "    - 6 stations de travail" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Politiques de Sécurité:" -ForegroundColor Yellow
    Write-Host "    - Politique de mots de passe: 12 car. min, complexité, 90 jours" -ForegroundColor Gray
    Write-Host "    - Verrouillage compte: 5 tentatives, 30 min de blocage" -ForegroundColor Gray
    Write-Host "    - 12 politiques d'audit avancées configurées via auditpol" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  GPOs (configuration manuelle requise):" -ForegroundColor Yellow
    Write-Host "    - Configuration Journaux Événements (taille 2 GB Security)" -ForegroundColor Gray
    Write-Host "    - Restrictions Stations Sensibles (blocage USB)" -ForegroundColor Gray
    Write-Host "    - Verrouillage Session Automatique (10 min inactivité)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Fichiers CSV exportés dans: C:\Labos\" -ForegroundColor Yellow
    Write-Host "    - MonitoringLab_Utilisateurs.csv" -ForegroundColor Gray
    Write-Host "    - MonitoringLab_Groupes.csv" -ForegroundColor Gray
    Write-Host "    - MonitoringLab_Ordinateurs.csv" -ForegroundColor Gray
    Write-Host "    - MonitoringLab_GPOs.csv" -ForegroundColor Gray
    Write-Host ""
    Write-Host "📋 Prochaines étapes:" -ForegroundColor Cyan
    Write-Host "  1. Ouvrir GPMC (gpmc.msc) et configurer les paramètres des GPOs" -ForegroundColor White
    Write-Host "  2. Tester les politiques d'audit en consultant l'Observateur d'événements" -ForegroundColor White
    Write-Host "  3. Vérifier la réplication AD entre MON-DC01 et MON-DC02" -ForegroundColor White
    Write-Host "  4. Explorer les exercices pratiques dans la documentation du labo" -ForegroundColor White
    Write-Host ""
    Write-Host "✅ Laboratoire prêt pour les exercices de monitoring AD!" -ForegroundColor Green
    Write-Host ""

} catch {
    Write-Host "`n❌ ERREUR CRITIQUE:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "`nStack Trace:" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
}
