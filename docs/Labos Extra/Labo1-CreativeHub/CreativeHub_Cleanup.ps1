# Script de nettoyage de la structure Active Directory - Agence CreativeHub
# Nom du script: CreativeHub_Cleanup.ps1
# Auteur: Laboratoire Active Directory - Formation Débutants
# Date: 2025-10-04
# Description: Supprime complètement la structure AD CreativeHub pour permettre de recommencer le labo
#
# ATTENTION: Ce script supprime définitivement tous les objets AD créés par le script CreativeHub_Setup.ps1
# Utilisez ce script uniquement si vous voulez recommencer le laboratoire depuis le début.

# ============================================
# FONCTIONS UTILITAIRES
# ============================================

function Confirm-Deletion {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Red
    Write-Host " AVERTISSEMENT - SUPPRESSION DÉFINITIVE" -ForegroundColor Red
    Write-Host "============================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Ce script va SUPPRIMER DÉFINITIVEMENT:" -ForegroundColor Yellow
    Write-Host "  - Tous les utilisateurs de CreativeHub (18 comptes)" -ForegroundColor Yellow
    Write-Host "  - Tous les groupes de sécurité (8 groupes)" -ForegroundColor Yellow
    Write-Host "  - Toutes les Unités Organisationnelles (13 OUs)" -ForegroundColor Yellow
    Write-Host "  - Toutes les Stratégies de Groupe CreativeHub (3 GPOs)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Cette action est IRRÉVERSIBLE!" -ForegroundColor Red
    Write-Host ""

    $confirmation = Read-Host "Tapez 'SUPPRIMER' en majuscules pour confirmer la suppression complète"

    if ($confirmation -ne "SUPPRIMER") {
        Write-Host ""
        Write-Host "Opération annulée par l'utilisateur." -ForegroundColor Green
        Write-Host "Aucune modification n'a été effectuée." -ForegroundColor Green
        exit
    }

    Write-Host ""
    Write-Host "Confirmation reçue. Démarrage de la suppression..." -ForegroundColor Yellow
    Write-Host ""
}

# ============================================
# VARIABLES GLOBALES
# ============================================

Import-Module ActiveDirectory

$domainDN = "DC=maxtec,DC=be"
$rootOU = "OU=CreativeHub,$domainDN"

# ============================================
# SCRIPT PRINCIPAL
# ============================================

try {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host " NETTOYAGE STRUCTURE AD - AGENCE CREATIVEHUB" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan

    # Demander confirmation avant de continuer
    Confirm-Deletion

    # ============================================
    # ÉTAPE 1: SUPPRESSION DES LIENS GPO
    # ============================================

    Write-Host "[ÉTAPE 1] Suppression des liens GPO..." -ForegroundColor Cyan

    $gpoNames = @(
        "CreativeHub - Restrictions Utilisateurs Juniors",
        "CreativeHub - Blocage USB Client Services",
        "CreativeHub - Lecteurs Réseau Partagés"
    )

    foreach ($gpoName in $gpoNames) {
        try {
            $gpo = Get-GPO -Name $gpoName -ErrorAction SilentlyContinue
            if ($gpo) {
                Write-Host "  Suppression des liens pour la GPO: $gpoName" -ForegroundColor White

                # Récupérer tous les liens de cette GPO
                [xml]$gpoReport = Get-GPOReport -Name $gpoName -ReportType Xml
                $links = $gpoReport.GPO.LinksTo

                if ($links) {
                    foreach ($link in $links) {
                        try {
                            Remove-GPLink -Name $gpoName -Target $link.SOMPath -ErrorAction SilentlyContinue
                            Write-Host "    Lien supprimé: $($link.SOMPath)" -ForegroundColor Gray
                        } catch {
                            Write-Host "    Impossible de supprimer le lien: $($link.SOMPath)" -ForegroundColor Yellow
                        }
                    }
                } else {
                    Write-Host "    Aucun lien à supprimer." -ForegroundColor Gray
                }
            }
        } catch {
            Write-Host "  Impossible de traiter la GPO $gpoName : $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }

    # ============================================
    # ÉTAPE 2: SUPPRESSION DES GPOs
    # ============================================

    Write-Host "`n[ÉTAPE 2] Suppression des Stratégies de Groupe..." -ForegroundColor Cyan

    foreach ($gpoName in $gpoNames) {
        try {
            $gpo = Get-GPO -Name $gpoName -ErrorAction SilentlyContinue
            if ($gpo) {
                Remove-GPO -Name $gpoName -Confirm:$false
                Write-Host "  GPO supprimée: $gpoName" -ForegroundColor Green
            } else {
                Write-Host "  GPO '$gpoName' non trouvée (déjà supprimée)." -ForegroundColor Yellow
            }
        } catch {
            Write-Host "  ERREUR lors de la suppression de la GPO '$gpoName': $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    # ============================================
    # ÉTAPE 3: SUPPRESSION DES UTILISATEURS
    # ============================================

    Write-Host "`n[ÉTAPE 3] Suppression des utilisateurs..." -ForegroundColor Cyan

    try {
        $users = Get-ADUser -Filter * -SearchBase $rootOU

        if ($users) {
            foreach ($user in $users) {
                Remove-ADUser -Identity $user -Confirm:$false
                Write-Host "  Utilisateur supprimé: $($user.SamAccountName) ($($user.Name))" -ForegroundColor Green
            }
            Write-Host "  Total: $($users.Count) utilisateur(s) supprimé(s)." -ForegroundColor White
        } else {
            Write-Host "  Aucun utilisateur trouvé dans CreativeHub." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  ERREUR lors de la suppression des utilisateurs: $($_.Exception.Message)" -ForegroundColor Red
    }

    # ============================================
    # ÉTAPE 4: SUPPRESSION DES GROUPES
    # ============================================

    Write-Host "`n[ÉTAPE 4] Suppression des groupes de sécurité..." -ForegroundColor Cyan

    try {
        $groups = Get-ADGroup -Filter * -SearchBase $rootOU

        if ($groups) {
            foreach ($group in $groups) {
                Remove-ADGroup -Identity $group -Confirm:$false
                Write-Host "  Groupe supprimé: $($group.Name)" -ForegroundColor Green
            }
            Write-Host "  Total: $($groups.Count) groupe(s) supprimé(s)." -ForegroundColor White
        } else {
            Write-Host "  Aucun groupe trouvé dans CreativeHub." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  ERREUR lors de la suppression des groupes: $($_.Exception.Message)" -ForegroundColor Red
    }

    # ============================================
    # ÉTAPE 5: SUPPRESSION DES OUs (ORDRE INVERSE)
    # ============================================

    Write-Host "`n[ÉTAPE 5] Suppression des Unités Organisationnelles..." -ForegroundColor Cyan
    Write-Host "  (Les sous-OUs doivent être supprimées avant les OUs parentes)" -ForegroundColor Gray

    try {
        # Vérifier si l'OU racine existe
        $rootOUExists = Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$rootOU'" -ErrorAction SilentlyContinue

        if ($rootOUExists) {
            # Récupérer toutes les OUs sous CreativeHub et les trier par profondeur (les plus profondes d'abord)
            $ous = Get-ADOrganizationalUnit -Filter * -SearchBase $rootOU |
                   Sort-Object -Property DistinguishedName -Descending

            foreach ($ou in $ous) {
                try {
                    # Désactiver la protection contre la suppression accidentelle
                    Set-ADOrganizationalUnit -Identity $ou.DistinguishedName -ProtectedFromAccidentalDeletion $false

                    # Supprimer l'OU
                    Remove-ADOrganizationalUnit -Identity $ou.DistinguishedName -Confirm:$false
                    Write-Host "  OU supprimée: $($ou.Name)" -ForegroundColor Green
                } catch {
                    Write-Host "  ERREUR lors de la suppression de l'OU '$($ou.Name)': $($_.Exception.Message)" -ForegroundColor Red
                }
            }

            # Supprimer l'OU racine CreativeHub
            Write-Host "`n  Suppression de l'OU racine CreativeHub..." -ForegroundColor White
            Set-ADOrganizationalUnit -Identity $rootOU -ProtectedFromAccidentalDeletion $false
            Remove-ADOrganizationalUnit -Identity $rootOU -Confirm:$false
            Write-Host "  OU racine 'CreativeHub' supprimée avec succès." -ForegroundColor Green

        } else {
            Write-Host "  L'OU racine 'CreativeHub' n'existe pas (déjà supprimée)." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  ERREUR lors de la suppression des OUs: $($_.Exception.Message)" -ForegroundColor Red
    }

    # ============================================
    # RÉCAPITULATIF FINAL
    # ============================================

    Write-Host "`n============================================" -ForegroundColor Green
    Write-Host " NETTOYAGE TERMINÉ AVEC SUCCÈS!" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "La structure Active Directory CreativeHub a été complètement supprimée." -ForegroundColor White
    Write-Host ""
    Write-Host "Vous pouvez maintenant:" -ForegroundColor White
    Write-Host "  1. Relancer le script CreativeHub_Setup.ps1 pour recréer la structure" -ForegroundColor Gray
    Write-Host "  2. Vérifier dans 'Utilisateurs et ordinateurs Active Directory' que CreativeHub a disparu" -ForegroundColor Gray
    Write-Host "  3. Vérifier dans GPMC que les GPOs CreativeHub ont été supprimées" -ForegroundColor Gray
    Write-Host ""
    Write-Host "NOTE: Les fichiers CSV dans C:\Labos n'ont pas été supprimés." -ForegroundColor Cyan
    Write-Host "Vous pouvez les conserver comme référence ou les supprimer manuellement." -ForegroundColor Cyan
    Write-Host ""

} catch {
    Write-Host "`n============================================" -ForegroundColor Red
    Write-Host " ERREUR CRITIQUE" -ForegroundColor Red
    Write-Host "============================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Une erreur s'est produite lors du nettoyage:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Stack Trace:" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    Write-Host ""
    Write-Host "Le nettoyage peut être partiellement incomplet." -ForegroundColor Yellow
    Write-Host "Vérifiez manuellement l'état de la structure AD dans la console." -ForegroundColor Yellow
    Write-Host ""
}
