# Script pour créer l'infrastructure de monitoring Active Directory
# Nom du script: 1_Setup-MonitoringLab.ps1
# Auteur: H2EB - Cours Active Directory
# Date: 2025-10-07
# Description: Configure l'environnement de laboratoire pour le monitoring AD avec
#              OUs, utilisateurs de test, groupes et configuration d'audit
#
# Sources Microsoft consultées:
# - https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-aduser
# - https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-adorganizationalunit
# - https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-adgroup
# - https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/auditpol-set

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

# ============================================
# VARIABLES GLOBALES
# ============================================

Import-Module ActiveDirectory -ErrorAction Stop

# Récupérer le domaine actuel dynamiquement
$domain = Get-ADDomain
$domainDN = $domain.DistinguishedName
$domainNetBIOS = $domain.NetBIOSName

Write-Host "`n[INFO] Domaine détecté: $($domain.DNSRoot)" -ForegroundColor Cyan
Write-Host "[INFO] Distinguished Name: $domainDN" -ForegroundColor Cyan

$rootOU = "OU=MonitoringLab,$domainDN"
$testUsersOU = "OU=TestUsers,$rootOU"
$testGroupsOU = "OU=TestGroups,$rootOU"
$serviceAccountsOU = "OU=ServiceAccounts,$rootOU"

# Mot de passe par défaut pour tous les comptes
$defaultPassword = "Password1!"
$securePassword = ConvertTo-SecureString $defaultPassword -AsPlainText -Force

# Créer le répertoire pour les scripts et logs si nécessaire
$labPath = "C:\MonitoringLab"
$exportPath = "$labPath\Exports"
$logsPath = "$labPath\Logs"
$scriptsPath = "$labPath\Scripts"

# ============================================
# SCRIPT PRINCIPAL
# ============================================

try {
    Write-Host "`n============================================" -ForegroundColor Green
    Write-Host "Configuration du Laboratoire de Monitoring AD" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "`nCe script va créer:" -ForegroundColor White
    Write-Host "  - Structure d'OUs pour le laboratoire" -ForegroundColor Gray
    Write-Host "  - 5 utilisateurs de test (U_Test1 à U_Test5)" -ForegroundColor Gray
    Write-Host "  - 3 groupes de sécurité globaux" -ForegroundColor Gray
    Write-Host "  - 1 compte de service (SVC_Monitoring)" -ForegroundColor Gray
    Write-Host "  - Configuration de l'audit des événements de sécurité" -ForegroundColor Gray
    Write-Host "  - Dossiers pour scripts et logs: $labPath" -ForegroundColor Gray

    # ============================================
    # ÉTAPE 1: CRÉER LES DOSSIERS LOCAUX
    # ============================================

    if (Confirm-Step "Créer les dossiers locaux pour le laboratoire") {
        Write-Host "`n[ÉTAPE 1/6] Création des dossiers locaux..." -ForegroundColor Cyan

        $folders = @($labPath, $exportPath, $logsPath, $scriptsPath)
        foreach ($folder in $folders) {
            if (-not (Test-Path $folder)) {
                New-Item -Path $folder -ItemType Directory -Force | Out-Null
                Write-Host "  ✅ Créé: $folder" -ForegroundColor Green
            } else {
                Write-Host "  ℹ️  Existe déjà: $folder" -ForegroundColor Yellow
            }
        }

        Write-Host "`n[INFO] Dossiers créés avec succès." -ForegroundColor Green
    }

    # ============================================
    # ÉTAPE 2: CRÉER LA STRUCTURE D'OUs
    # ============================================

    if (Confirm-Step "Créer la structure d'unités organisationnelles") {
        Write-Host "`n[ÉTAPE 2/6] Création de la structure d'OUs..." -ForegroundColor Cyan

        # Créer l'OU racine
        if (-not (Test-OUExists $rootOU)) {
            New-ADOrganizationalUnit -Name "MonitoringLab" -Path $domainDN -ProtectedFromAccidentalDeletion $false
            Write-Host "  ✅ OU créée: MonitoringLab" -ForegroundColor Green
        } else {
            Write-Host "  ℹ️  OU existe déjà: MonitoringLab" -ForegroundColor Yellow
        }

        # Créer les sous-OUs
        $subOUs = @(
            @{Name="TestUsers"; Path=$rootOU; Description="Utilisateurs de test pour monitoring"},
            @{Name="TestGroups"; Path=$rootOU; Description="Groupes de sécurité pour monitoring"},
            @{Name="ServiceAccounts"; Path=$rootOU; Description="Comptes de service pour monitoring"}
        )

        foreach ($ou in $subOUs) {
            $ouDN = "OU=$($ou.Name),$($ou.Path)"
            if (-not (Test-OUExists $ouDN)) {
                New-ADOrganizationalUnit -Name $ou.Name -Path $ou.Path `
                    -Description $ou.Description `
                    -ProtectedFromAccidentalDeletion $false
                Write-Host "  ✅ OU créée: $($ou.Name)" -ForegroundColor Green
            } else {
                Write-Host "  ℹ️  OU existe déjà: $($ou.Name)" -ForegroundColor Yellow
            }
        }

        Write-Host "`n[INFO] Structure d'OUs créée avec succès." -ForegroundColor Green
    }

    # ============================================
    # ÉTAPE 3: CRÉER LES UTILISATEURS DE TEST
    # ============================================

    if (Confirm-Step "Créer les utilisateurs de test (U_Test1 à U_Test5)") {
        Write-Host "`n[ÉTAPE 3/6] Création des utilisateurs de test..." -ForegroundColor Cyan

        # Utilisateurs de test avec prénoms français
        $testUsers = @(
            @{Sam="U_Test1"; FirstName="Antoine"; LastName="Martin"; Description="Utilisateur de test pour simulation d'événements"},
            @{Sam="U_Test2"; FirstName="Sophie"; LastName="Bernard"; Description="Utilisateur de test pour simulation d'événements"},
            @{Sam="U_Test3"; FirstName="Lucas"; LastName="Dubois"; Description="Utilisateur de test pour simulation d'événements"},
            @{Sam="U_Test4"; FirstName="Emma"; LastName="Lambert"; Description="Utilisateur de test pour verrouillage de compte"},
            @{Sam="U_Test5"; FirstName="Thomas"; LastName="Rousseau"; Description="Utilisateur de test pour modifications de groupes"}
        )

        foreach ($user in $testUsers) {
            if (-not (Test-UserExists $user.Sam)) {
                $displayName = "$($user.FirstName) $($user.LastName)"
                $email = "$($user.FirstName.ToLower()).$($user.LastName.ToLower())@$($domain.DNSRoot)"

                New-ADUser -Name $displayName `
                    -SamAccountName $user.Sam `
                    -UserPrincipalName "$($user.Sam)@$($domain.DNSRoot)" `
                    -GivenName $user.FirstName `
                    -Surname $user.LastName `
                    -DisplayName $displayName `
                    -EmailAddress $email `
                    -Description $user.Description `
                    -Path $testUsersOU `
                    -AccountPassword $securePassword `
                    -Enabled $true `
                    -PasswordNeverExpires $true `
                    -ChangePasswordAtLogon $false

                Write-Host "  ✅ Utilisateur créé: $($user.Sam) ($displayName)" -ForegroundColor Green
            } else {
                Write-Host "  ℹ️  Utilisateur existe déjà: $($user.Sam)" -ForegroundColor Yellow
            }
        }

        Write-Host "`n[INFO] Utilisateurs de test créés avec succès." -ForegroundColor Green
        Write-Host "[INFO] Mot de passe par défaut: $defaultPassword" -ForegroundColor Cyan
    }

    # ============================================
    # ÉTAPE 4: CRÉER LES GROUPES DE SÉCURITÉ
    # ============================================

    if (Confirm-Step "Créer les groupes de sécurité globaux") {
        Write-Host "`n[ÉTAPE 4/6] Création des groupes de sécurité..." -ForegroundColor Cyan

        # Groupes globaux avec préfixe GG- (OBLIGATOIRE)
        $testGroups = @(
            @{Name="GG-Monitoring-Users"; Description="Utilisateurs standards pour monitoring AD"; Scope="Global"},
            @{Name="GG-Monitoring-Admins"; Description="Administrateurs pour monitoring AD"; Scope="Global"},
            @{Name="GG-Monitoring-Services"; Description="Comptes de service pour monitoring AD"; Scope="Global"}
        )

        foreach ($group in $testGroups) {
            if (-not (Test-GroupExists $group.Name)) {
                New-ADGroup -Name $group.Name `
                    -SamAccountName $group.Name `
                    -GroupScope $group.Scope `
                    -GroupCategory Security `
                    -Description $group.Description `
                    -Path $testGroupsOU

                Write-Host "  ✅ Groupe créé: $($group.Name)" -ForegroundColor Green
            } else {
                Write-Host "  ℹ️  Groupe existe déjà: $($group.Name)" -ForegroundColor Yellow
            }
        }

        # Ajouter automatiquement les utilisateurs aux groupes
        Write-Host "`n  [Ajout des membres aux groupes...]" -ForegroundColor Cyan

        # Ajouter tous les utilisateurs de test au groupe Users
        $allTestUsers = Get-ADUser -Filter * -SearchBase $testUsersOU
        foreach ($user in $allTestUsers) {
            try {
                Add-ADGroupMember -Identity "GG-Monitoring-Users" -Members $user -ErrorAction SilentlyContinue
                Write-Host "    ✅ $($user.SamAccountName) ajouté à GG-Monitoring-Users" -ForegroundColor Green
            } catch {
                Write-Host "    ℹ️  $($user.SamAccountName) est déjà membre de GG-Monitoring-Users" -ForegroundColor Yellow
            }
        }

        # Ajouter le premier utilisateur (alphabétiquement) au groupe Admins
        $firstUser = $allTestUsers | Sort-Object SamAccountName | Select-Object -First 1
        if ($firstUser) {
            try {
                Add-ADGroupMember -Identity "GG-Monitoring-Admins" -Members $firstUser -ErrorAction SilentlyContinue
                Write-Host "    ✅ $($firstUser.SamAccountName) ajouté à GG-Monitoring-Admins (premier utilisateur)" -ForegroundColor Green
            } catch {
                Write-Host "    ℹ️  $($firstUser.SamAccountName) est déjà membre de GG-Monitoring-Admins" -ForegroundColor Yellow
            }
        }

        Write-Host "`n[INFO] Groupes de sécurité créés avec succès." -ForegroundColor Green
    }

    # ============================================
    # ÉTAPE 5: CRÉER LE COMPTE DE SERVICE
    # ============================================

    if (Confirm-Step "Créer le compte de service SVC_Monitoring") {
        Write-Host "`n[ÉTAPE 5/6] Création du compte de service..." -ForegroundColor Cyan

        $svcAccount = "SVC_Monitoring"
        if (-not (Test-UserExists $svcAccount)) {
            New-ADUser -Name $svcAccount `
                -SamAccountName $svcAccount `
                -UserPrincipalName "$svcAccount@$($domain.DNSRoot)" `
                -DisplayName "Service de Monitoring AD" `
                -Description "Compte de service pour monitoring Active Directory" `
                -Path $serviceAccountsOU `
                -AccountPassword $securePassword `
                -Enabled $true `
                -PasswordNeverExpires $true `
                -CannotChangePassword $true `
                -ChangePasswordAtLogon $false

            Write-Host "  ✅ Compte de service créé: $svcAccount" -ForegroundColor Green

            # Ajouter au groupe de services
            try {
                Add-ADGroupMember -Identity "GG-Monitoring-Services" -Members $svcAccount -ErrorAction SilentlyContinue
                Write-Host "  ✅ $svcAccount ajouté à GG-Monitoring-Services" -ForegroundColor Green
            } catch {
                Write-Host "  ℹ️  $svcAccount est déjà membre de GG-Monitoring-Services" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  ℹ️  Compte de service existe déjà: $svcAccount" -ForegroundColor Yellow
        }

        Write-Host "`n[INFO] Compte de service créé avec succès." -ForegroundColor Green
    }

    # ============================================
    # ÉTAPE 6: CONFIGURER L'AUDIT DES ÉVÉNEMENTS
    # ============================================

    if (Confirm-Step "Configurer l'audit des événements de sécurité") {
        Write-Host "`n[ÉTAPE 6/6] Configuration de l'audit des événements..." -ForegroundColor Cyan
        Write-Host "  [Configuration via auditpol.exe selon documentation Microsoft]" -ForegroundColor Gray

        # Configuration de l'audit selon documentation Microsoft
        # Source: https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/auditpol-set

        try {
            # Audit des événements de connexion (Event ID 4624, 4625)
            & auditpol /set /subcategory:"Logon" /success:enable /failure:enable
            Write-Host "  ✅ Audit Logon configuré (succès + échecs)" -ForegroundColor Green

            # Audit de la gestion des comptes (Event ID 4720, 4722, 4725)
            & auditpol /set /subcategory:"User Account Management" /success:enable /failure:enable
            Write-Host "  ✅ Audit User Account Management configuré" -ForegroundColor Green

            # Audit de la gestion des groupes (Event ID 4728, 4729)
            & auditpol /set /subcategory:"Security Group Management" /success:enable /failure:enable
            Write-Host "  ✅ Audit Security Group Management configuré" -ForegroundColor Green

            # Audit des verrouillages de compte (Event ID 4740)
            & auditpol /set /subcategory:"User Account Management" /success:enable /failure:enable
            Write-Host "  ✅ Audit Account Lockout configuré" -ForegroundColor Green

            # Audit des modifications Active Directory
            & auditpol /set /subcategory:"Directory Service Changes" /success:enable /failure:enable
            Write-Host "  ✅ Audit Directory Service Changes configuré" -ForegroundColor Green

            Write-Host "`n  [Vérification de la configuration d'audit...]" -ForegroundColor Cyan
            Write-Host ""
            & auditpol /get /category:"Logon/Logoff","Account Management","DS Access" | Out-String | Write-Host

            Write-Host "`n[INFO] Configuration de l'audit terminée avec succès." -ForegroundColor Green
            Write-Host "[INFO] Les événements de sécurité seront maintenant enregistrés dans le journal Security." -ForegroundColor Cyan
        } catch {
            Write-Host "  ⚠️  ERREUR lors de la configuration de l'audit: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "  [NOTE] Assurez-vous d'exécuter ce script en tant qu'Administrateur." -ForegroundColor Yellow
        }
    }

    # ============================================
    # EXPORTATION CSV (OPTIONNEL)
    # ============================================

    Write-Host "`n============================================" -ForegroundColor Green
    Write-Host "EXPORTATION DES DONNÉES" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green

    if (Confirm-Step "Exporter les utilisateurs et groupes en CSV") {
        Write-Host "`n[EXPORT] Exportation des données vers CSV..." -ForegroundColor Cyan

        # Export des utilisateurs
        try {
            Get-ADUser -Filter * -SearchBase $rootOU -Properties EmailAddress, Description, Enabled, whenCreated |
                Select-Object Name, SamAccountName, EmailAddress, Description, Enabled, whenCreated |
                Export-Csv -Path "$exportPath\utilisateurs_monitoring.csv" -NoTypeInformation -Encoding UTF8
            Write-Host "  ✅ Utilisateurs exportés: $exportPath\utilisateurs_monitoring.csv" -ForegroundColor Green
        } catch {
            Write-Host "  ⚠️  Erreur d'export des utilisateurs: $($_.Exception.Message)" -ForegroundColor Red
        }

        # Export des groupes avec membres
        try {
            $groupsData = @()
            $groups = Get-ADGroup -Filter * -SearchBase $testGroupsOU -Properties Description, whenCreated

            foreach ($group in $groups) {
                $members = Get-ADGroupMember -Identity $group | Select-Object -ExpandProperty SamAccountName
                $groupsData += [PSCustomObject]@{
                    GroupName = $group.Name
                    Description = $group.Description
                    MemberCount = $members.Count
                    Members = ($members -join "; ")
                    Created = $group.whenCreated
                }
            }

            $groupsData | Export-Csv -Path "$exportPath\groupes_monitoring.csv" -NoTypeInformation -Encoding UTF8
            Write-Host "  ✅ Groupes exportés: $exportPath\groupes_monitoring.csv" -ForegroundColor Green
        } catch {
            Write-Host "  ⚠️  Erreur d'export des groupes: $($_.Exception.Message)" -ForegroundColor Red
        }

        Write-Host "`n[INFO] Exportation terminée." -ForegroundColor Green
    }

    # ============================================
    # RÉSUMÉ FINAL
    # ============================================

    Write-Host "`n============================================" -ForegroundColor Green
    Write-Host "CONFIGURATION TERMINÉE AVEC SUCCÈS!" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green

    Write-Host "`n📊 RÉSUMÉ DE LA CONFIGURATION:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Structure AD créée:" -ForegroundColor White
    Write-Host "  ├── OU=MonitoringLab,$domainDN" -ForegroundColor Gray
    Write-Host "  │   ├── OU=TestUsers (5 utilisateurs)" -ForegroundColor Gray
    Write-Host "  │   ├── OU=TestGroups (3 groupes)" -ForegroundColor Gray
    Write-Host "  │   └── OU=ServiceAccounts (1 compte service)" -ForegroundColor Gray
    Write-Host ""

    Write-Host "Utilisateurs créés:" -ForegroundColor White
    $users = Get-ADUser -Filter * -SearchBase $testUsersOU | Select-Object -ExpandProperty SamAccountName
    foreach ($u in $users) {
        Write-Host "  • $u" -ForegroundColor Gray
    }
    Write-Host ""

    Write-Host "Groupes créés:" -ForegroundColor White
    Write-Host "  • GG-Monitoring-Users (tous les utilisateurs de test)" -ForegroundColor Gray
    Write-Host "  • GG-Monitoring-Admins (U_Test1 uniquement)" -ForegroundColor Gray
    Write-Host "  • GG-Monitoring-Services (SVC_Monitoring)" -ForegroundColor Gray
    Write-Host ""

    Write-Host "Dossiers locaux:" -ForegroundColor White
    Write-Host "  • $labPath (racine du laboratoire)" -ForegroundColor Gray
    Write-Host "  • $exportPath (exports CSV)" -ForegroundColor Gray
    Write-Host "  • $logsPath (fichiers de logs)" -ForegroundColor Gray
    Write-Host "  • $scriptsPath (scripts PowerShell)" -ForegroundColor Gray
    Write-Host ""

    Write-Host "Audit configuré pour:" -ForegroundColor White
    Write-Host "  • Événements de connexion (4624, 4625)" -ForegroundColor Gray
    Write-Host "  • Gestion des comptes (4720, 4722, 4725)" -ForegroundColor Gray
    Write-Host "  • Gestion des groupes (4728, 4729)" -ForegroundColor Gray
    Write-Host "  • Verrouillages de compte (4740)" -ForegroundColor Gray
    Write-Host "  • Modifications Active Directory" -ForegroundColor Gray
    Write-Host ""

    Write-Host "🎯 PROCHAINES ÉTAPES:" -ForegroundColor Cyan
    Write-Host "  1. Exécutez 2_Generate-Events.ps1 pour simuler des événements" -ForegroundColor Yellow
    Write-Host "  2. Exécutez 3_Monitor-RealTime.ps1 pour surveiller en temps réel" -ForegroundColor Yellow
    Write-Host "  3. Exécutez 4_Create-CustomAlerts.ps1 pour configurer les alertes" -ForegroundColor Yellow
    Write-Host "  4. Exécutez 5_Generate-SecurityReport.ps1 pour générer un rapport" -ForegroundColor Yellow
    Write-Host ""

    Write-Host "📝 INFORMATION IMPORTANTE:" -ForegroundColor Cyan
    Write-Host "  Mot de passe par défaut: $defaultPassword" -ForegroundColor White
    Write-Host "  Tous les comptes sont activés et prêts à l'emploi." -ForegroundColor Gray
    Write-Host ""

} catch {
    Write-Host "`n❌ ERREUR CRITIQUE:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "`nStack Trace:" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    Write-Host "`nLe script a été interrompu. Vérifiez les erreurs ci-dessus." -ForegroundColor Yellow
}

Write-Host "`nAppuyez sur une touche pour continuer..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
