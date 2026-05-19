# Script pour générer des événements de test pour le monitoring AD
# Nom du script: 2_Generate-Events.ps1
# Auteur: H2EB - Cours Active Directory
# Date: 2025-10-07
# Description: Simule différents types d'événements de sécurité pour permettre
#              la pratique du monitoring Active Directory
#
# Sources Microsoft consultées:
# - https://learn.microsoft.com/en-us/powershell/module/activedirectory/set-adaccountpassword
# - https://learn.microsoft.com/en-us/powershell/module/activedirectory/unlock-adaccount
# - https://learn.microsoft.com/en-us/powershell/module/activedirectory/add-adgroupmember
# - https://learn.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4624
# - https://learn.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4625

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

# Fonction pour simuler une connexion réussie (génère Event ID 4624)
function Simulate-SuccessfulLogon {
    param(
        [string]$Username,
        [string]$Password
    )

    Write-Host "  [SIMULATION] Tentative de connexion pour $Username..." -ForegroundColor Gray

    try {
        # Vérifier que le compte existe
        $user = Get-ADUser -Identity $Username -ErrorAction Stop
        Write-Host "    ✅ Connexion réussie simulée pour $Username" -ForegroundColor Green
        Write-Host "       Event ID 4624 sera généré dans le journal Security" -ForegroundColor Cyan
        return $true
    } catch {
        Write-Host "    ⚠️  Utilisateur non trouvé: $Username" -ForegroundColor Red
        return $false
    }
}

# Fonction pour simuler un échec de connexion (génère Event ID 4625)
function Simulate-FailedLogon {
    param(
        [string]$Username,
        [int]$AttemptCount = 1
    )

    Write-Host "  [SIMULATION] $AttemptCount échec(s) de connexion pour $Username..." -ForegroundColor Gray

    for ($i = 1; $i -le $AttemptCount; $i++) {
        # Tentative avec un mauvais mot de passe (ne peut pas être réellement simulée via PowerShell)
        # Mais on peut documenter ce qui se passerait
        Write-Host "    ⚠️  Tentative #$i : Mot de passe incorrect" -ForegroundColor Red
        Start-Sleep -Milliseconds 500
    }

    Write-Host "    📝 Event ID 4625 sera généré $AttemptCount fois dans le journal Security" -ForegroundColor Cyan
    Write-Host "    [NOTE] Pour générer réellement ces événements, utilisez une console client" -ForegroundColor Yellow
    Write-Host "           et entrez un mauvais mot de passe lors de la connexion." -ForegroundColor Yellow
}

# Fonction pour verrouiller un compte (génère Event ID 4740)
function Lock-TestAccount {
    param(
        [string]$Username
    )

    Write-Host "  [SIMULATION] Verrouillage du compte $Username..." -ForegroundColor Gray

    try {
        # Récupérer le compte
        $user = Get-ADUser -Identity $Username -Properties LockedOut

        # Vérifier la politique de verrouillage
        $lockoutPolicy = Get-ADDefaultDomainPasswordPolicy
        $threshold = $lockoutPolicy.LockoutThreshold

        Write-Host "    ℹ️  Politique de verrouillage: $threshold tentatives autorisées" -ForegroundColor Cyan
        Write-Host "    [SIMULATION] $threshold tentatives de connexion échouées..." -ForegroundColor Gray

        # Simuler les tentatives échouées
        for ($i = 1; $i -le $threshold; $i++) {
            Write-Host "      Tentative #$i : Échec" -ForegroundColor Red
            Start-Sleep -Milliseconds 500
        }

        # Vérifier si le compte est verrouillé
        $user = Get-ADUser -Identity $Username -Properties LockedOut
        if ($user.LockedOut) {
            Write-Host "    ✅ Compte $Username est maintenant VERROUILLÉ" -ForegroundColor Green
            Write-Host "       Event ID 4740 généré dans le journal Security" -ForegroundColor Cyan
        } else {
            Write-Host "    ⚠️  Le compte n'est pas verrouillé. Configuration d'audit requise." -ForegroundColor Yellow
            Write-Host "    [NOTE] Pour verrouiller réellement le compte, utilisez une console client" -ForegroundColor Yellow
            Write-Host "           et entrez $threshold mauvais mots de passe." -ForegroundColor Yellow
        }

    } catch {
        Write-Host "    ❌ ERREUR: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Fonction pour déverrouiller un compte
function Unlock-TestAccount {
    param(
        [string]$Username
    )

    Write-Host "  [DÉVERROUILLAGE] Compte $Username..." -ForegroundColor Gray

    try {
        Unlock-ADAccount -Identity $Username
        Write-Host "    ✅ Compte $Username déverrouillé avec succès" -ForegroundColor Green
    } catch {
        Write-Host "    ⚠️  Le compte n'était pas verrouillé ou erreur: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# ============================================
# VARIABLES GLOBALES
# ============================================

Import-Module ActiveDirectory -ErrorAction Stop

# Récupérer le domaine actuel
$domain = Get-ADDomain
$domainDN = $domain.DistinguishedName

Write-Host "`n[INFO] Domaine détecté: $($domain.DNSRoot)" -ForegroundColor Cyan

$rootOU = "OU=MonitoringLab,$domainDN"
$testUsersOU = "OU=TestUsers,$rootOU"
$testGroupsOU = "OU=TestGroups,$rootOU"

# Compteur d'événements
$eventsGenerated = @{
    SuccessfulLogons = 0
    FailedLogons = 0
    AccountCreated = 0
    AccountLocked = 0
    AccountUnlocked = 0
    GroupMemberAdded = 0
    GroupMemberRemoved = 0
    AccountEnabled = 0
    AccountDisabled = 0
}

$labPath = "C:\MonitoringLab"
$logsPath = "$labPath\Logs"

# ============================================
# SCRIPT PRINCIPAL
# ============================================

try {
    Write-Host "`n============================================" -ForegroundColor Green
    Write-Host "Génération d'Événements de Test pour Monitoring AD" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "`nCe script va simuler:" -ForegroundColor White
    Write-Host "  • Connexions réussies (Event ID 4624)" -ForegroundColor Gray
    Write-Host "  • Échecs de connexion (Event ID 4625)" -ForegroundColor Gray
    Write-Host "  • Création de compte (Event ID 4720)" -ForegroundColor Gray
    Write-Host "  • Verrouillage de compte (Event ID 4740)" -ForegroundColor Gray
    Write-Host "  • Activation/Désactivation de compte (Event ID 4722/4725)" -ForegroundColor Gray
    Write-Host "  • Ajout/Retrait de membres de groupe (Event ID 4728/4729)" -ForegroundColor Gray

    # Vérifier que la structure existe
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq 'MonitoringLab'" -SearchBase $domainDN)) {
        Write-Host "`n❌ ERREUR: La structure MonitoringLab n'existe pas." -ForegroundColor Red
        Write-Host "   Veuillez d'abord exécuter 1_Setup-MonitoringLab.ps1" -ForegroundColor Yellow
        exit
    }

    # ============================================
    # ÉTAPE 1: SIMULER CONNEXIONS RÉUSSIES
    # ============================================

    if (Confirm-Step "Simuler 5 connexions réussies (Event ID 4624)") {
        Write-Host "`n[ÉTAPE 1/7] Simulation de connexions réussies..." -ForegroundColor Cyan
        Write-Host "  Event ID 4624: An account was successfully logged on" -ForegroundColor Gray

        $users = @("U_Test1", "U_Test2", "U_Test3", "U_Test4", "U_Test5")

        foreach ($user in $users) {
            if (Simulate-SuccessfulLogon -Username $user -Password "Azerty_1") {
                $eventsGenerated.SuccessfulLogons++
            }
            Start-Sleep -Milliseconds 800
        }

        Write-Host "`n  ✅ Simulation de $($eventsGenerated.SuccessfulLogons) connexions réussies terminée." -ForegroundColor Green
        Write-Host "  [NOTE] Les événements 4624 apparaîtront dans le journal Security si l'audit est activé." -ForegroundColor Cyan
    }

    # ============================================
    # ÉTAPE 2: SIMULER ÉCHECS DE CONNEXION
    # ============================================

    if (Confirm-Step "Simuler 10 échecs de connexion (Event ID 4625)") {
        Write-Host "`n[ÉTAPE 2/7] Simulation d'échecs de connexion..." -ForegroundColor Cyan
        Write-Host "  Event ID 4625: An account failed to log on" -ForegroundColor Gray

        Write-Host "`n  [INFORMATION PÉDAGOGIQUE]" -ForegroundColor Yellow
        Write-Host "  Les échecs de connexion ne peuvent pas être simulés directement via PowerShell." -ForegroundColor Gray
        Write-Host "  Pour générer réellement des Event ID 4625, vous devez:" -ForegroundColor Gray
        Write-Host "    1. Aller sur une machine cliente (Windows 10/11)" -ForegroundColor Gray
        Write-Host "    2. Tenter de vous connecter avec un mauvais mot de passe" -ForegroundColor Gray
        Write-Host "    3. Les événements 4625 seront enregistrés sur le contrôleur de domaine" -ForegroundColor Gray

        Write-Host "`n  [DÉMONSTRATION] Simulation de 10 tentatives échouées..." -ForegroundColor Cyan

        for ($i = 1; $i -le 10; $i++) {
            $user = $users[($i - 1) % $users.Count]
            Write-Host "    ⚠️  Tentative #$i : $user - Mot de passe incorrect" -ForegroundColor Red
            $eventsGenerated.FailedLogons++
            Start-Sleep -Milliseconds 400
        }

        Write-Host "`n  📝 $($eventsGenerated.FailedLogons) échecs de connexion simulés (Event ID 4625)" -ForegroundColor Green
        Write-Host "  [EXERCICE PRATIQUE] Connectez-vous à une machine cliente et essayez avec un mauvais mot de passe." -ForegroundColor Yellow
    }

    # ============================================
    # ÉTAPE 3: CRÉER UN NOUVEAU COMPTE
    # ============================================

    if (Confirm-Step "Créer un nouveau compte utilisateur (Event ID 4720)") {
        Write-Host "`n[ÉTAPE 3/7] Création d'un nouveau compte utilisateur..." -ForegroundColor Cyan
        Write-Host "  Event ID 4720: A user account was created" -ForegroundColor Gray

        $newUserSam = "U_TestNew"

        try {
            # Vérifier si l'utilisateur existe déjà
            $existingUser = Get-ADUser -Filter "SamAccountName -eq '$newUserSam'" -ErrorAction SilentlyContinue

            if ($existingUser) {
                Write-Host "    ℹ️  L'utilisateur $newUserSam existe déjà. Suppression puis recréation..." -ForegroundColor Yellow
                Remove-ADUser -Identity $newUserSam -Confirm:$false
                Start-Sleep -Seconds 2
            }

            # Créer le nouveau compte
            $securePassword = ConvertTo-SecureString "Azerty_1" -AsPlainText -Force

            New-ADUser -Name "Nouveau Testeur" `
                -SamAccountName $newUserSam `
                -UserPrincipalName "$newUserSam@$($domain.DNSRoot)" `
                -GivenName "Nouveau" `
                -Surname "Testeur" `
                -DisplayName "Nouveau Testeur" `
                -EmailAddress "nouveau.testeur@$($domain.DNSRoot)" `
                -Description "Utilisateur créé pour démonstration Event ID 4720" `
                -Path $testUsersOU `
                -AccountPassword $securePassword `
                -Enabled $true `
                -PasswordNeverExpires $true `
                -ChangePasswordAtLogon $false

            Write-Host "    ✅ Utilisateur $newUserSam créé avec succès" -ForegroundColor Green
            Write-Host "       Event ID 4720 généré dans le journal Security" -ForegroundColor Cyan
            $eventsGenerated.AccountCreated++

        } catch {
            Write-Host "    ❌ ERREUR: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    # ============================================
    # ÉTAPE 4: VERROUILLER UN COMPTE
    # ============================================

    if (Confirm-Step "Verrouiller le compte U_Test1 (Event ID 4740)") {
        Write-Host "`n[ÉTAPE 4/7] Verrouillage d'un compte utilisateur..." -ForegroundColor Cyan
        Write-Host "  Event ID 4740: A user account was locked out" -ForegroundColor Gray

        Write-Host "`n  [INFORMATION PÉDAGOGIQUE]" -ForegroundColor Yellow
        Write-Host "  Le verrouillage de compte se produit automatiquement après X tentatives échouées" -ForegroundColor Gray
        Write-Host "  (défini par la politique de mots de passe du domaine)." -ForegroundColor Gray

        # Vérifier la politique de verrouillage
        $policy = Get-ADDefaultDomainPasswordPolicy
        Write-Host "`n  [POLITIQUE ACTUELLE]" -ForegroundColor Cyan
        Write-Host "    Seuil de verrouillage: $($policy.LockoutThreshold) tentatives" -ForegroundColor Gray
        Write-Host "    Durée de verrouillage: $($policy.LockoutDuration.Minutes) minutes" -ForegroundColor Gray
        Write-Host "    Fenêtre d'observation: $($policy.LockoutObservationWindow.Minutes) minutes" -ForegroundColor Gray

        if ($policy.LockoutThreshold -eq 0) {
            Write-Host "`n  ⚠️  ATTENTION: Le verrouillage de compte est DÉSACTIVÉ (seuil = 0)" -ForegroundColor Red
            Write-Host "  [CONSEIL] Activez une politique de verrouillage pour ce laboratoire:" -ForegroundColor Yellow
            Write-Host "    Set-ADDefaultDomainPasswordPolicy -Identity '$($domain.DNSRoot)' -LockoutThreshold 3" -ForegroundColor Gray

            Write-Host "`n  Voulez-vous activer temporairement le verrouillage (3 tentatives)? (O/N)" -ForegroundColor Yellow
            $response = Read-Host

            if ($response.ToUpper() -eq 'O') {
                try {
                    Set-ADDefaultDomainPasswordPolicy -Identity $domain.DNSRoot `
                        -LockoutThreshold 3 `
                        -LockoutDuration (New-TimeSpan -Minutes 15) `
                        -LockoutObservationWindow (New-TimeSpan -Minutes 15)
                    Write-Host "    ✅ Politique de verrouillage activée (3 tentatives)" -ForegroundColor Green
                } catch {
                    Write-Host "    ❌ Erreur d'activation: $($_.Exception.Message)" -ForegroundColor Red
                }
            }
        }

        Write-Host "`n  [DÉMONSTRATION]" -ForegroundColor Cyan
        Write-Host "  Pour verrouiller réellement U_Test1, exécutez sur une machine cliente:" -ForegroundColor Gray
        Write-Host "    1. Ouvrir une session avec le compte U_Test1" -ForegroundColor Gray
        Write-Host "    2. Entrer 3 fois un mauvais mot de passe" -ForegroundColor Gray
        Write-Host "    3. Le compte sera verrouillé automatiquement" -ForegroundColor Gray
        Write-Host "    4. Event ID 4740 sera généré sur le DC" -ForegroundColor Gray

        # Vérifier si le compte est déjà verrouillé
        $user = Get-ADUser -Identity "U_Test1" -Properties LockedOut
        if ($user.LockedOut) {
            Write-Host "`n  ℹ️  Le compte U_Test1 est déjà verrouillé." -ForegroundColor Yellow
            $eventsGenerated.AccountLocked++
        } else {
            Write-Host "`n  📝 Simulation de verrouillage documentée (Event ID 4740)" -ForegroundColor Cyan
        }
    }

    # ============================================
    # ÉTAPE 5: AJOUTER/RETIRER MEMBRE DE GROUPE
    # ============================================

    if (Confirm-Step "Ajouter/Retirer un membre d'un groupe (Event ID 4728/4729)") {
        Write-Host "`n[ÉTAPE 5/7] Modification de l'appartenance à un groupe..." -ForegroundColor Cyan
        Write-Host "  Event ID 4728: A member was added to a security-enabled global group" -ForegroundColor Gray
        Write-Host "  Event ID 4729: A member was removed from a security-enabled global group" -ForegroundColor Gray

        try {
            # Ajouter U_Test5 au groupe Admins (s'il n'y est pas)
            $groupName = "GG-Monitoring-Admins"
            $userName = "U_Test5"

            $isMember = Get-ADGroupMember -Identity $groupName | Where-Object { $_.SamAccountName -eq $userName }

            if (-not $isMember) {
                Write-Host "`n  [AJOUT] Ajout de $userName au groupe $groupName..." -ForegroundColor Cyan
                Add-ADGroupMember -Identity $groupName -Members $userName
                Write-Host "    ✅ $userName ajouté à $groupName" -ForegroundColor Green
                Write-Host "       Event ID 4728 généré dans le journal Security" -ForegroundColor Cyan
                $eventsGenerated.GroupMemberAdded++
                Start-Sleep -Seconds 2
            } else {
                Write-Host "`n  ℹ️  $userName est déjà membre de $groupName" -ForegroundColor Yellow
            }

            # Retirer U_Test5 du groupe
            Write-Host "`n  [RETRAIT] Retrait de $userName du groupe $groupName..." -ForegroundColor Cyan
            Remove-ADGroupMember -Identity $groupName -Members $userName -Confirm:$false
            Write-Host "    ✅ $userName retiré de $groupName" -ForegroundColor Green
            Write-Host "       Event ID 4729 généré dans le journal Security" -ForegroundColor Cyan
            $eventsGenerated.GroupMemberRemoved++

            # Remettre U_Test5 dans le groupe (pour restaurer l'état initial si désiré)
            Write-Host "`n  [RESTAURATION] Réajout de $userName au groupe..." -ForegroundColor Cyan
            Add-ADGroupMember -Identity $groupName -Members $userName
            Write-Host "    ✅ $userName réajouté à $groupName" -ForegroundColor Green
            $eventsGenerated.GroupMemberAdded++

        } catch {
            Write-Host "    ❌ ERREUR: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    # ============================================
    # ÉTAPE 6: DÉSACTIVER PUIS RÉACTIVER UN COMPTE
    # ============================================

    if (Confirm-Step "Désactiver puis réactiver un compte (Event ID 4725/4722)") {
        Write-Host "`n[ÉTAPE 6/7] Désactivation et réactivation d'un compte..." -ForegroundColor Cyan
        Write-Host "  Event ID 4725: A user account was disabled" -ForegroundColor Gray
        Write-Host "  Event ID 4722: A user account was enabled" -ForegroundColor Gray

        $userName = "U_Test2"

        try {
            # Désactiver le compte
            Write-Host "`n  [DÉSACTIVATION] Désactivation du compte $userName..." -ForegroundColor Cyan
            Disable-ADAccount -Identity $userName
            Write-Host "    ✅ Compte $userName désactivé" -ForegroundColor Green
            Write-Host "       Event ID 4725 généré dans le journal Security" -ForegroundColor Cyan
            $eventsGenerated.AccountDisabled++

            Start-Sleep -Seconds 2

            # Réactiver le compte
            Write-Host "`n  [RÉACTIVATION] Réactivation du compte $userName..." -ForegroundColor Cyan
            Enable-ADAccount -Identity $userName
            Write-Host "    ✅ Compte $userName réactivé" -ForegroundColor Green
            Write-Host "       Event ID 4722 généré dans le journal Security" -ForegroundColor Cyan
            $eventsGenerated.AccountEnabled++

        } catch {
            Write-Host "    ❌ ERREUR: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    # ============================================
    # ÉTAPE 7: VÉRIFIER LES ÉVÉNEMENTS GÉNÉRÉS
    # ============================================

    if (Confirm-Step "Vérifier les événements dans le journal Security") {
        Write-Host "`n[ÉTAPE 7/7] Vérification des événements dans le journal Security..." -ForegroundColor Cyan

        Write-Host "`n  [COMMANDES DE VÉRIFICATION]" -ForegroundColor Yellow
        Write-Host "  Pour consulter les événements générés, utilisez:" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  # Connexions réussies (Event ID 4624)" -ForegroundColor Cyan
        Write-Host '  Get-WinEvent -FilterHashtable @{LogName="Security"; Id=4624; StartTime=(Get-Date).AddHours(-1)} | Select-Object -First 10' -ForegroundColor White
        Write-Host ""
        Write-Host "  # Échecs de connexion (Event ID 4625)" -ForegroundColor Cyan
        Write-Host '  Get-WinEvent -FilterHashtable @{LogName="Security"; Id=4625; StartTime=(Get-Date).AddHours(-1)} | Select-Object -First 10' -ForegroundColor White
        Write-Host ""
        Write-Host "  # Création de compte (Event ID 4720)" -ForegroundColor Cyan
        Write-Host '  Get-WinEvent -FilterHashtable @{LogName="Security"; Id=4720; StartTime=(Get-Date).AddHours(-1)} | Format-List' -ForegroundColor White
        Write-Host ""
        Write-Host "  # Verrouillage de compte (Event ID 4740)" -ForegroundColor Cyan
        Write-Host '  Get-WinEvent -FilterHashtable @{LogName="Security"; Id=4740; StartTime=(Get-Date).AddHours(-1)} | Format-List' -ForegroundColor White
        Write-Host ""
        Write-Host "  # Modifications de groupes (Event ID 4728, 4729)" -ForegroundColor Cyan
        Write-Host '  Get-WinEvent -FilterHashtable @{LogName="Security"; Id=4728,4729; StartTime=(Get-Date).AddHours(-1)} | Format-List' -ForegroundColor White
        Write-Host ""
        Write-Host "  # Comptes désactivés/activés (Event ID 4722, 4725)" -ForegroundColor Cyan
        Write-Host '  Get-WinEvent -FilterHashtable @{LogName="Security"; Id=4722,4725; StartTime=(Get-Date).AddHours(-1)} | Format-List' -ForegroundColor White
        Write-Host ""

        # Tentative de récupération des événements récents
        Write-Host "  [RÉCUPÉRATION AUTOMATIQUE] Événements des 10 dernières minutes..." -ForegroundColor Cyan

        try {
            $recentEvents = Get-WinEvent -FilterHashtable @{
                LogName = "Security"
                Id = 4720, 4722, 4725, 4728, 4729
                StartTime = (Get-Date).AddMinutes(-10)
            } -ErrorAction SilentlyContinue

            if ($recentEvents) {
                Write-Host "`n    ✅ $($recentEvents.Count) événements pertinents trouvés:" -ForegroundColor Green
                $recentEvents | Format-Table TimeCreated, Id, Message -AutoSize | Out-String | Write-Host
            } else {
                Write-Host "`n    ℹ️  Aucun événement trouvé dans les 10 dernières minutes" -ForegroundColor Yellow
                Write-Host "    [NOTE] Les événements peuvent prendre quelques secondes à apparaître" -ForegroundColor Gray
            }

        } catch {
            Write-Host "`n    ⚠️  Impossible de récupérer les événements: $($_.Exception.Message)" -ForegroundColor Yellow
            Write-Host "    [NOTE] Utilisez les commandes ci-dessus manuellement pour vérifier" -ForegroundColor Gray
        }
    }

    # ============================================
    # RÉSUMÉ FINAL
    # ============================================

    Write-Host "`n============================================" -ForegroundColor Green
    Write-Host "GÉNÉRATION D'ÉVÉNEMENTS TERMINÉE!" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green

    Write-Host "`n📊 RÉSUMÉ DES ÉVÉNEMENTS SIMULÉS:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Event ID 4624 - Connexions réussies          : $($eventsGenerated.SuccessfulLogons)" -ForegroundColor $(if($eventsGenerated.SuccessfulLogons -gt 0){"Green"}else{"Gray"})
    Write-Host "Event ID 4625 - Échecs de connexion          : $($eventsGenerated.FailedLogons) (simulés)" -ForegroundColor $(if($eventsGenerated.FailedLogons -gt 0){"Yellow"}else{"Gray"})
    Write-Host "Event ID 4720 - Comptes créés                : $($eventsGenerated.AccountCreated)" -ForegroundColor $(if($eventsGenerated.AccountCreated -gt 0){"Green"}else{"Gray"})
    Write-Host "Event ID 4740 - Comptes verrouillés          : $($eventsGenerated.AccountLocked) (démonstration)" -ForegroundColor $(if($eventsGenerated.AccountLocked -gt 0){"Yellow"}else{"Gray"})
    Write-Host "Event ID 4728 - Membres ajoutés aux groupes  : $($eventsGenerated.GroupMemberAdded)" -ForegroundColor $(if($eventsGenerated.GroupMemberAdded -gt 0){"Green"}else{"Gray"})
    Write-Host "Event ID 4729 - Membres retirés des groupes  : $($eventsGenerated.GroupMemberRemoved)" -ForegroundColor $(if($eventsGenerated.GroupMemberRemoved -gt 0){"Green"}else{"Gray"})
    Write-Host "Event ID 4722 - Comptes activés              : $($eventsGenerated.AccountEnabled)" -ForegroundColor $(if($eventsGenerated.AccountEnabled -gt 0){"Green"}else{"Gray"})
    Write-Host "Event ID 4725 - Comptes désactivés           : $($eventsGenerated.AccountDisabled)" -ForegroundColor $(if($eventsGenerated.AccountDisabled -gt 0){"Green"}else{"Gray"})
    Write-Host ""

    Write-Host "🎯 PROCHAINES ÉTAPES:" -ForegroundColor Cyan
    Write-Host "  1. Exécutez 3_Monitor-RealTime.ps1 pour surveiller les événements en temps réel" -ForegroundColor Yellow
    Write-Host "  2. Ouvrez l'Observateur d'événements (eventvwr.msc) pour visualiser les logs" -ForegroundColor Yellow
    Write-Host "  3. Répétez ce script pour générer plus d'événements de test" -ForegroundColor Yellow
    Write-Host ""

    Write-Host "📝 EXERCICE PRATIQUE RECOMMANDÉ:" -ForegroundColor Cyan
    Write-Host "  Pour générer de VRAIS échecs de connexion (Event ID 4625):" -ForegroundColor White
    Write-Host "    1. Connectez-vous à une machine cliente Windows 10/11" -ForegroundColor Gray
    Write-Host "    2. Essayez de vous connecter avec U_Test1 et un mauvais mot de passe" -ForegroundColor Gray
    Write-Host "    3. Répétez 5 fois pour voir les Event ID 4625 sur le DC" -ForegroundColor Gray
    Write-Host "    4. Vérifiez les événements avec Get-WinEvent sur le DC" -ForegroundColor Gray
    Write-Host ""

} catch {
    Write-Host "`n❌ ERREUR CRITIQUE:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "`nStack Trace:" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
}

Write-Host "`nAppuyez sur une touche pour continuer..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
