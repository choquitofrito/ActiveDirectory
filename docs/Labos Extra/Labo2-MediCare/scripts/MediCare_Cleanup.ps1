# Script de nettoyage - MediCare Clinic
# Nom du script: MediCare_Cleanup.ps1
# Auteur: H2EB Active Directory Lab Project
# Date: 2025-10-05
# Description: Supprime complètement la structure AD MediCare pour permettre une reconstruction
#              Ordre: GPOs → Utilisateurs → Groupes → OUs
#
# ⚠️  AVERTISSEMENT: Ce script supprime DÉFINITIVEMENT tous les objets MediCare
#                    Assurez-vous d'avoir sauvegardé toute donnée importante avant exécution

# ============================================
# FONCTIONS UTILITAIRES
# ============================================

# Fonction pour demander confirmation
function Confirm-Cleanup {
    Write-Host "`n⚠️  ATTENTION: Cette opération est IRRÉVERSIBLE!" -ForegroundColor Red
    Write-Host "Tous les objets suivants seront SUPPRIMÉS DÉFINITIVEMENT:" -ForegroundColor Yellow
    Write-Host "  • 5 stratégies de groupe (GPOs)" -ForegroundColor White
    Write-Host "  • 28 comptes utilisateurs" -ForegroundColor White
    Write-Host "  • 12 groupes de sécurité" -ForegroundColor White
    Write-Host "  • Toutes les OUs MediCare (16 OUs)" -ForegroundColor White
    Write-Host "  • Fichiers CSV exportés" -ForegroundColor White

    $confirmation = Read-Host "`nTapez 'SUPPRIMER' en majuscules pour confirmer, ou 'N' pour annuler"

    if ($confirmation -ne "SUPPRIMER") {
        Write-Host "`n✅ Nettoyage annulé. Aucune modification effectuée." -ForegroundColor Green
        exit
    }

    Write-Host "`n⚠️  Dernière confirmation requise!" -ForegroundColor Red
    $finalConfirm = Read-Host "Êtes-vous ABSOLUMENT SÛR? (O/N)"

    if ($finalConfirm.ToUpper() -ne "O") {
        Write-Host "`n✅ Nettoyage annulé. Aucune modification effectuée." -ForegroundColor Green
        exit
    }

    return $true
}

# ============================================
# VARIABLES GLOBALES
# ============================================

Import-Module ActiveDirectory
Import-Module GroupPolicy

$domainDN = "DC=maxtec,DC=be"
$rootOU = "OU=MediCare,$domainDN"
$exportPath = "C:\Labos"

# ============================================
# SCRIPT PRINCIPAL
# ============================================

try {
    Write-Host "============================================" -ForegroundColor Red
    Write-Host "  NETTOYAGE STRUCTURE MEDICARE - SUPPRESSION" -ForegroundColor Red
    Write-Host "============================================" -ForegroundColor Red

    # Demander confirmation
    if (-not (Confirm-Cleanup)) {
        exit
    }

    Write-Host "`n🗑️  Début du nettoyage..." -ForegroundColor Yellow

    # ============================================
    # ÉTAPE 1: SUPPRESSION DES GPOs
    # ============================================

    Write-Host "`n[ÉTAPE 1/5] Suppression des stratégies de groupe..." -ForegroundColor Cyan

    $gpoNames = @(
        "MediCare - Blocage USB Zones Médicales",
        "MediCare - Restrictions Bureau Administration",
        "MediCare - Lecteurs Médicaux Partagés"
    )

    foreach ($gpoName in $gpoNames) {
        try {
            $gpo = Get-GPO -Name $gpoName -ErrorAction SilentlyContinue
            if ($gpo) {
                Remove-GPO -Name $gpoName -Confirm:$false
                Write-Host "  ✅ GPO supprimée: $gpoName" -ForegroundColor Green
            } else {
                Write-Host "  ⚠️  GPO inexistante: $gpoName" -ForegroundColor DarkGray
            }
        } catch {
            Write-Host "  ❌ Erreur suppression GPO '$gpoName': $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    # Réinitialiser la politique de mot de passe du domaine aux valeurs par défaut
    Write-Host "`n  Réinitialisation de la politique de mot de passe du domaine..." -ForegroundColor Cyan
    try {
        Set-ADDefaultDomainPasswordPolicy -Identity "maxtec.be" `
            -MinPasswordLength 7 `
            -PasswordHistoryCount 24 `
            -MaxPasswordAge (New-TimeSpan -Days 42) `
            -MinPasswordAge (New-TimeSpan -Days 1) `
            -ComplexityEnabled $true `
            -LockoutThreshold 0 `
            -LockoutDuration (New-TimeSpan -Minutes 30) `
            -LockoutObservationWindow (New-TimeSpan -Minutes 30)
        Write-Host "  ✅ Politique de mot de passe réinitialisée aux valeurs par défaut" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠️  Impossible de réinitialiser la politique de mot de passe: $($_.Exception.Message)" -ForegroundColor Yellow
    }

    # Désactiver les audits configurés
    Write-Host "`n  Désactivation des audits de sécurité..." -ForegroundColor Cyan
    try {
        & auditpol /set /subcategory:"Logon" /success:disable /failure:disable 2>&1 | Out-Null
        & auditpol /set /subcategory:"User Account Management" /success:disable /failure:disable 2>&1 | Out-Null
        Write-Host "  ✅ Audits de sécurité désactivés" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠️  Impossible de désactiver les audits: $($_.Exception.Message)" -ForegroundColor Yellow
    }

    # ============================================
    # ÉTAPE 2: SUPPRESSION DES UTILISATEURS
    # ============================================

    Write-Host "`n[ÉTAPE 2/5] Suppression des utilisateurs..." -ForegroundColor Cyan

    $allUsers = Get-ADUser -Filter * -SearchBase $rootOU

    if ($allUsers) {
        foreach ($user in $allUsers) {
            try {
                Remove-ADUser -Identity $user.SamAccountName -Confirm:$false
                Write-Host "  ✅ Utilisateur supprimé: $($user.Name) ($($user.SamAccountName))" -ForegroundColor Green
            } catch {
                Write-Host "  ❌ Erreur suppression utilisateur '$($user.SamAccountName)': $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        Write-Host "`n  📊 Total: $($allUsers.Count) utilisateurs supprimés" -ForegroundColor Cyan
    } else {
        Write-Host "  ⚠️  Aucun utilisateur trouvé dans MediCare" -ForegroundColor DarkGray
    }

    # ============================================
    # ÉTAPE 3: SUPPRESSION DES GROUPES
    # ============================================

    Write-Host "`n[ÉTAPE 3/5] Suppression des groupes de sécurité..." -ForegroundColor Cyan

    $allGroups = Get-ADGroup -Filter * -SearchBase $rootOU

    if ($allGroups) {
        foreach ($group in $allGroups) {
            try {
                Remove-ADGroup -Identity $group.Name -Confirm:$false
                Write-Host "  ✅ Groupe supprimé: $($group.Name)" -ForegroundColor Green
            } catch {
                Write-Host "  ❌ Erreur suppression groupe '$($group.Name)': $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        Write-Host "`n  📊 Total: $($allGroups.Count) groupes supprimés" -ForegroundColor Cyan
    } else {
        Write-Host "  ⚠️  Aucun groupe trouvé dans MediCare" -ForegroundColor DarkGray
    }

    # ============================================
    # ÉTAPE 4: SUPPRESSION DES OUs
    # ============================================

    Write-Host "`n[ÉTAPE 4/5] Suppression des Unités Organisationnelles..." -ForegroundColor Cyan

    # Ordre de suppression: de la plus profonde à la plus superficielle
    $departments = @("Medical", "Nursing", "Administration", "IT")
    $subOUs = @("Users", "Computers", "Groups")

    # Supprimer d'abord les sous-OUs
    foreach ($dept in $departments) {
        foreach ($subOU in $subOUs) {
            $ouPath = "OU=$subOU,OU=$dept,$rootOU"
            try {
                $ou = Get-ADOrganizationalUnit -Identity $ouPath -ErrorAction SilentlyContinue
                if ($ou) {
                    # Désactiver la protection avant suppression
                    Set-ADOrganizationalUnit -Identity $ouPath -ProtectedFromAccidentalDeletion $false
                    Remove-ADOrganizationalUnit -Identity $ouPath -Confirm:$false
                    Write-Host "  ✅ Sous-OU supprimée: $dept/$subOU" -ForegroundColor Green
                }
            } catch {
                Write-Host "  ❌ Erreur suppression sous-OU '$ouPath': $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }

    # Supprimer ensuite les OUs départementales
    foreach ($dept in $departments) {
        $deptOU = "OU=$dept,$rootOU"
        try {
            $ou = Get-ADOrganizationalUnit -Identity $deptOU -ErrorAction SilentlyContinue
            if ($ou) {
                Set-ADOrganizationalUnit -Identity $deptOU -ProtectedFromAccidentalDeletion $false
                Remove-ADOrganizationalUnit -Identity $deptOU -Confirm:$false
                Write-Host "  ✅ OU départementale supprimée: $dept" -ForegroundColor Green
            }
        } catch {
            Write-Host "  ❌ Erreur suppression OU '$deptOU': $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    # Supprimer enfin l'OU racine MediCare
    try {
        $rootOUObj = Get-ADOrganizationalUnit -Identity $rootOU -ErrorAction SilentlyContinue
        if ($rootOUObj) {
            Set-ADOrganizationalUnit -Identity $rootOU -ProtectedFromAccidentalDeletion $false
            Remove-ADOrganizationalUnit -Identity $rootOU -Confirm:$false
            Write-Host "  ✅ OU racine supprimée: MediCare" -ForegroundColor Green
        }
    } catch {
        Write-Host "  ❌ Erreur suppression OU racine: $($_.Exception.Message)" -ForegroundColor Red
    }

    # ============================================
    # ÉTAPE 5: SUPPRESSION DES FICHIERS CSV
    # ============================================

    Write-Host "`n[ÉTAPE 5/5] Suppression des fichiers CSV exportés..." -ForegroundColor Cyan

    $csvFiles = @(
        "$exportPath\medicare_utilisateurs.csv",
        "$exportPath\medicare_groupes.csv",
        "$exportPath\medicare_ous.csv"
    )

    foreach ($csvFile in $csvFiles) {
        if (Test-Path $csvFile) {
            try {
                Remove-Item -Path $csvFile -Force
                Write-Host "  ✅ Fichier supprimé: $csvFile" -ForegroundColor Green
            } catch {
                Write-Host "  ❌ Erreur suppression fichier '$csvFile': $($_.Exception.Message)" -ForegroundColor Red
            }
        } else {
            Write-Host "  ⚠️  Fichier inexistant: $csvFile" -ForegroundColor DarkGray
        }
    }

    # ============================================
    # RÉSUMÉ FINAL
    # ============================================

    Write-Host "`n============================================" -ForegroundColor Green
    Write-Host "  NETTOYAGE TERMINÉ AVEC SUCCÈS!           " -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green

    Write-Host "`n✅ OPÉRATIONS EFFECTUÉES:" -ForegroundColor Cyan
    Write-Host "   • GPOs supprimées (3 stratégies manuelles)" -ForegroundColor White
    Write-Host "   • Politique de mot de passe réinitialisée" -ForegroundColor White
    Write-Host "   • Audits de sécurité désactivés" -ForegroundColor White
    Write-Host "   • Tous les utilisateurs MediCare supprimés" -ForegroundColor White
    Write-Host "   • Tous les groupes MediCare supprimés" -ForegroundColor White
    Write-Host "   • Toutes les OUs MediCare supprimées" -ForegroundColor White
    Write-Host "   • Fichiers CSV exportés supprimés" -ForegroundColor White

    Write-Host "`n🔄 PROCHAINES ÉTAPES:" -ForegroundColor Cyan
    Write-Host "   1. Vérifier dans 'Utilisateurs et ordinateurs Active Directory'" -ForegroundColor Gray
    Write-Host "      que l'OU 'MediCare' a bien disparu" -ForegroundColor Gray
    Write-Host "   2. Vérifier dans GPMC (gpmc.msc) que les GPOs MediCare ont été supprimées" -ForegroundColor Gray
    Write-Host "   3. Vous pouvez maintenant réexécuter MediCare_Setup.ps1 pour recréer la structure" -ForegroundColor Gray

    Write-Host "`n💡 CONSEIL:" -ForegroundColor Cyan
    Write-Host "   Si vous souhaitez reconstruire le laboratoire, exécutez:" -ForegroundColor Yellow
    Write-Host "   .\MediCare_Setup.ps1" -ForegroundColor White

    Write-Host "`n============================================`n" -ForegroundColor Green

} catch {
    Write-Host "`n❌ ERREUR CRITIQUE PENDANT LE NETTOYAGE:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "`nStack Trace:" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    Write-Host "`n⚠️  Le nettoyage peut être incomplet. Vérifiez manuellement dans AD." -ForegroundColor Yellow
}
