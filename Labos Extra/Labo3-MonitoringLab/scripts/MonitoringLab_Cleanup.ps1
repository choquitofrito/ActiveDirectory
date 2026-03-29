# Script de nettoyage du laboratoire Monitoring Active Directory
# Nom du script: MonitoringLab_Cleanup.ps1
# Auteur: H2EB - Cours Active Directory
# Date: 2025-10-07
# Description: Supprime complètement la structure du laboratoire Monitoring
#
# ATTENTION: Ce script supprime DÉFINITIVEMENT:
#   - Toutes les GPOs créées
#   - Tous les utilisateurs (y compris comptes de service)
#   - Tous les groupes de sécurité
#   - Tous les ordinateurs
#   - Toutes les OUs et sous-OUs
#   - Réinitialise les politiques d'audit

# ============================================
# FONCTIONS UTILITAIRES
# ============================================

Import-Module ActiveDirectory
Import-Module GroupPolicy

$domainDN = "DC=maxtec,DC=be"
$rootOU = "OU=MONITORING,$domainDN"

# ============================================
# CONFIRMATION DE SÉCURITÉ
# ============================================

Write-Host "============================================" -ForegroundColor Red
Write-Host "  NETTOYAGE LABORATOIRE MONITORING AD      " -ForegroundColor Red
Write-Host "============================================" -ForegroundColor Red
Write-Host ""
Write-Host "⚠️  ATTENTION: Ce script va SUPPRIMER DÉFINITIVEMENT:" -ForegroundColor Yellow
Write-Host "  - Toutes les GPOs MONITORING-*" -ForegroundColor Gray
Write-Host "  - Tous les utilisateurs dans OU=MONITORING" -ForegroundColor Gray
Write-Host "  - Tous les groupes GG-MONITORING-*" -ForegroundColor Gray
Write-Host "  - Tous les ordinateurs MON-*" -ForegroundColor Gray
Write-Host "  - Toutes les OUs sous OU=MONITORING" -ForegroundColor Gray
Write-Host "  - Réinitialisera les politiques d'audit" -ForegroundColor Gray
Write-Host ""

$confirmation = Read-Host "Êtes-vous ABSOLUMENT sûr de vouloir continuer? Tapez 'SUPPRIMER' pour confirmer"

if ($confirmation -ne "SUPPRIMER") {
    Write-Host "`n❌ Annulation du nettoyage. Aucune modification effectuée." -ForegroundColor Yellow
    exit
}

Write-Host "`n✅ Confirmation reçue. Début du nettoyage..." -ForegroundColor Green

try {
    # ============================================
    # ÉTAPE 1: SUPPRESSION DES GPOs
    # ============================================

    Write-Host "`n[ÉTAPE 1] Suppression des GPOs..." -ForegroundColor Cyan

    $gpos = Get-GPO -All | Where-Object {$_.DisplayName -like "MONITORING*"}

    if ($gpos) {
        foreach ($gpo in $gpos) {
            try {
                # Supprimer tous les liens GPO d'abord
                $links = Get-ADOrganizationalUnit -Filter * | Get-GPInheritance |
                    Where-Object {$_.GpoLinks.DisplayName -contains $gpo.DisplayName}

                foreach ($link in $links) {
                    Remove-GPLink -Name $gpo.DisplayName -Target $link.Path -ErrorAction SilentlyContinue
                }

                # Supprimer la GPO elle-même
                Remove-GPO -Name $gpo.DisplayName -Confirm:$false
                Write-Host "  [SUPPRIMÉ] GPO: $($gpo.DisplayName)" -ForegroundColor Green
            } catch {
                Write-Host "  [ERREUR] Impossible de supprimer GPO $($gpo.DisplayName): $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "  [INFO] Aucune GPO MONITORING trouvée." -ForegroundColor Yellow
    }

    # ============================================
    # ÉTAPE 2: SUPPRESSION DES ORDINATEURS
    # ============================================

    Write-Host "`n[ÉTAPE 2] Suppression des ordinateurs..." -ForegroundColor Cyan

    $computers = Get-ADComputer -Filter * -SearchBase $rootOU -ErrorAction SilentlyContinue

    if ($computers) {
        foreach ($computer in $computers) {
            try {
                Remove-ADComputer -Identity $computer.DistinguishedName -Confirm:$false
                Write-Host "  [SUPPRIMÉ] Ordinateur: $($computer.Name)" -ForegroundColor Green
            } catch {
                Write-Host "  [ERREUR] Impossible de supprimer $($computer.Name): $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "  [INFO] Aucun ordinateur trouvé dans $rootOU" -ForegroundColor Yellow
    }

    # ============================================
    # ÉTAPE 3: SUPPRESSION DES UTILISATEURS
    # ============================================

    Write-Host "`n[ÉTAPE 3] Suppression des utilisateurs..." -ForegroundColor Cyan

    $users = Get-ADUser -Filter * -SearchBase $rootOU -ErrorAction SilentlyContinue

    if ($users) {
        foreach ($user in $users) {
            try {
                Remove-ADUser -Identity $user.DistinguishedName -Confirm:$false
                Write-Host "  [SUPPRIMÉ] Utilisateur: $($user.SamAccountName)" -ForegroundColor Green
            } catch {
                Write-Host "  [ERREUR] Impossible de supprimer $($user.SamAccountName): $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "  [INFO] Aucun utilisateur trouvé dans $rootOU" -ForegroundColor Yellow
    }

    # ============================================
    # ÉTAPE 4: SUPPRESSION DES GROUPES
    # ============================================

    Write-Host "`n[ÉTAPE 4] Suppression des groupes de sécurité..." -ForegroundColor Cyan

    $groups = Get-ADGroup -Filter * -SearchBase $rootOU -ErrorAction SilentlyContinue

    if ($groups) {
        foreach ($group in $groups) {
            try {
                Remove-ADGroup -Identity $group.DistinguishedName -Confirm:$false
                Write-Host "  [SUPPRIMÉ] Groupe: $($group.Name)" -ForegroundColor Green
            } catch {
                Write-Host "  [ERREUR] Impossible de supprimer $($group.Name): $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "  [INFO] Aucun groupe trouvé dans $rootOU" -ForegroundColor Yellow
    }

    # ============================================
    # ÉTAPE 5: SUPPRESSION DES OUs
    # ============================================

    Write-Host "`n[ÉTAPE 5] Suppression des Unités Organisationnelles..." -ForegroundColor Cyan

    # Récupérer toutes les OUs sous MONITORING, triées par profondeur (plus profondes en premier)
    $ous = Get-ADOrganizationalUnit -Filter * -SearchBase $rootOU -ErrorAction SilentlyContinue |
        Sort-Object -Property DistinguishedName -Descending

    if ($ous) {
        foreach ($ou in $ous) {
            try {
                # S'assurer que la protection contre suppression accidentelle est désactivée
                Set-ADOrganizationalUnit -Identity $ou.DistinguishedName -ProtectedFromAccidentalDeletion $false -ErrorAction SilentlyContinue

                Remove-ADOrganizationalUnit -Identity $ou.DistinguishedName -Confirm:$false -Recursive
                Write-Host "  [SUPPRIMÉ] OU: $($ou.Name)" -ForegroundColor Green
            } catch {
                Write-Host "  [ERREUR] Impossible de supprimer OU $($ou.Name): $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }

    # Supprimer l'OU racine MONITORING
    try {
        if (Test-Path "AD:\$rootOU") {
            Set-ADOrganizationalUnit -Identity $rootOU -ProtectedFromAccidentalDeletion $false -ErrorAction SilentlyContinue
            Remove-ADOrganizationalUnit -Identity $rootOU -Confirm:$false -Recursive
            Write-Host "  [SUPPRIMÉ] OU racine: MONITORING" -ForegroundColor Green
        }
    } catch {
        Write-Host "  [ERREUR] Impossible de supprimer OU racine MONITORING: $($_.Exception.Message)" -ForegroundColor Red
    }

    # ============================================
    # ÉTAPE 6: RÉINITIALISATION POLITIQUES D'AUDIT
    # ============================================

    Write-Host "`n[ÉTAPE 6] Réinitialisation des politiques d'audit..." -ForegroundColor Cyan

    # Désactiver toutes les politiques d'audit avancées
    $auditCategories = @(
        "Logon",
        "Logoff",
        "Credential Validation",
        "User Account Management",
        "Security Group Management",
        "Computer Account Management",
        "Audit Policy Change",
        "Authentication Policy Change",
        "Sensitive Privilege Use",
        "Directory Service Access",
        "Directory Service Changes",
        "File Share"
    )

    foreach ($category in $auditCategories) {
        try {
            $cmd = "auditpol /set /subcategory:`"$category`" /success:disable /failure:disable"
            Invoke-Expression $cmd | Out-Null
            Write-Host "  [DÉSACTIVÉ] Audit: $category" -ForegroundColor Green
        } catch {
            Write-Host "  [ERREUR] Impossible de désactiver audit $category" -ForegroundColor Red
        }
    }

    # ============================================
    # ÉTAPE 7: RÉINITIALISATION POLITIQUE MOTS DE PASSE (OPTIONNEL)
    # ============================================

    Write-Host "`n[ÉTAPE 7] Réinitialisation politique mots de passe..." -ForegroundColor Cyan
    $resetPassword = Read-Host "  Voulez-vous réinitialiser la politique de mots de passe aux valeurs par défaut? (O/N)"

    if ($resetPassword.ToUpper() -eq "O") {
        try {
            Set-ADDefaultDomainPasswordPolicy -Identity "maxtec.be" `
                -MinPasswordLength 7 `
                -PasswordHistoryCount 24 `
                -MaxPasswordAge (New-TimeSpan -Days 42) `
                -MinPasswordAge (New-TimeSpan -Days 1) `
                -ComplexityEnabled $true `
                -LockoutThreshold 0 `
                -LockoutDuration (New-TimeSpan -Minutes 30) `
                -LockoutObservationWindow (New-TimeSpan -Minutes 30) `
                -ReversibleEncryptionEnabled $false

            Write-Host "  [RÉINITIALISÉ] Politique de mots de passe aux valeurs par défaut Windows" -ForegroundColor Green
        } catch {
            Write-Host "  [ERREUR] Impossible de réinitialiser la politique: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "  [IGNORÉ] Conservation de la politique de mots de passe actuelle" -ForegroundColor Yellow
    }

    # ============================================
    # ÉTAPE 8: NETTOYAGE FICHIERS CSV
    # ============================================

    Write-Host "`n[ÉTAPE 8] Nettoyage des fichiers CSV d'export..." -ForegroundColor Cyan
    $cleanupCSV = Read-Host "  Voulez-vous supprimer les fichiers CSV exportés? (O/N)"

    if ($cleanupCSV.ToUpper() -eq "O") {
        $csvFiles = @(
            "C:\Labos\MonitoringLab_Utilisateurs.csv",
            "C:\Labos\MonitoringLab_Groupes.csv",
            "C:\Labos\MonitoringLab_Ordinateurs.csv",
            "C:\Labos\MonitoringLab_GPOs.csv"
        )

        foreach ($file in $csvFiles) {
            if (Test-Path $file) {
                Remove-Item -Path $file -Force
                Write-Host "  [SUPPRIMÉ] $file" -ForegroundColor Green
            }
        }
    } else {
        Write-Host "  [IGNORÉ] Conservation des fichiers CSV dans C:\Labos\" -ForegroundColor Yellow
    }

    # ============================================
    # RÉSUMÉ FINAL
    # ============================================

    Write-Host "`n============================================" -ForegroundColor Green
    Write-Host "  NETTOYAGE TERMINÉ AVEC SUCCÈS!           " -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "✅ Éléments supprimés:" -ForegroundColor Cyan
    Write-Host "  - GPOs de monitoring" -ForegroundColor Gray
    Write-Host "  - Ordinateurs (DCs, serveurs, stations)" -ForegroundColor Gray
    Write-Host "  - Utilisateurs et comptes de service" -ForegroundColor Gray
    Write-Host "  - Groupes de sécurité GG-MONITORING-*" -ForegroundColor Gray
    Write-Host "  - Structure complète des OUs" -ForegroundColor Gray
    Write-Host "  - Politiques d'audit avancées" -ForegroundColor Gray
    Write-Host ""
    Write-Host "📋 Vous pouvez maintenant:" -ForegroundColor Yellow
    Write-Host "  1. Re-exécuter MonitoringLab_Setup.ps1 pour recréer le labo" -ForegroundColor White
    Write-Host "  2. Créer un nouveau laboratoire différent" -ForegroundColor White
    Write-Host "  3. Vérifier la suppression avec: Get-ADOrganizationalUnit -Filter * | Where-Object {$_.Name -eq 'MONITORING'}" -ForegroundColor White
    Write-Host ""

} catch {
    Write-Host "`n❌ ERREUR CRITIQUE LORS DU NETTOYAGE:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "`nStack Trace:" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    Write-Host "`n⚠️  Le nettoyage peut être incomplet. Vérifiez manuellement les objets restants." -ForegroundColor Yellow
}
