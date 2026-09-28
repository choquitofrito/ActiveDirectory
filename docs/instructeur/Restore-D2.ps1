<#
.SYNOPSIS
    Dépannage D2 - remet le compte dans son état d'origine.

.DESCRIPTION
    Supprime la PSO de dépannage, déverrouille le compte, restaure logonHours et userWorkstations
    (valeurs enregistrées par Break-D2, sinon : aucune restriction).
    L'audit "Gestion des comptes d'utilisateur" reste activé (c'est un réglage souhaitable sur un DC).
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$Utilisateur = 'ines'
)

. "$PSScriptRoot\Commun.ps1"
Assert-DomaineLab

$nomEtat = "D2-$Utilisateur"
$etat = Read-Etat $nomEtat
# Avec un état enregistré, on ne restaure QUE les attributs que Break-D2 a modifiés
$hayEtat = $etat.Count -gt 0
$nomPso = "PSO-Depannage-$Utilisateur"
Write-Host "`n=== Restore-D2 : compte '$Utilisateur' ===" -ForegroundColor Cyan

# 1. PSO de dépannage
$pso = Get-ADFineGrainedPasswordPolicy -Filter "Name -eq '$nomPso'"
if ($pso) {
    if ($PSCmdlet.ShouldProcess($nomPso, 'Supprimer la PSO')) {
        Remove-ADFineGrainedPasswordPolicy -Identity $pso -Confirm:$false
        Write-Repare "PSO $nomPso supprimée"
    }
} else { Write-Deja "pas de PSO $nomPso" }

# 2. Verrouillage
$u = Get-ADUser -Identity $Utilisateur -Properties LockedOut, logonHours, userWorkstations
if ($u.LockedOut) {
    if ($PSCmdlet.ShouldProcess($Utilisateur, 'Déverrouiller')) {
        Unlock-ADAccount -Identity $Utilisateur
        Write-Repare "$Utilisateur déverrouillé"
    }
} else { Write-Deja "$Utilisateur n'est pas verrouillé" }

# 3. Horaires
if ($etat.ContainsKey('LogonHours')) {
    $lh = [string]$etat['LogonHours']
    if ($lh) {
        if ($PSCmdlet.ShouldProcess($Utilisateur, 'Restaurer logonHours d''origine')) {
            Set-ADUser -Identity $Utilisateur -Replace @{ logonHours = [byte[]][Convert]::FromBase64String($lh) } -ErrorAction Stop
            Write-Repare "logonHours restauré (valeur d'origine)"
        }
    } elseif ($u.logonHours -and $PSCmdlet.ShouldProcess($Utilisateur, 'Effacer logonHours (connexion 24 h/24)')) {
        Set-ADUser -Identity $Utilisateur -Clear logonHours -ErrorAction Stop
        Write-Repare "logonHours effacé (aucune restriction à l'origine)"
    }
} elseif (-not $hayEtat -and $u.logonHours) {
    if ($PSCmdlet.ShouldProcess($Utilisateur, 'Effacer logonHours (connexion 24 h/24)')) {
        Set-ADUser -Identity $Utilisateur -Clear logonHours -ErrorAction Stop
        Write-Repare "logonHours effacé (état standard du lab)"
    }
} else { Write-Deja "horaires : rien à restaurer" }

# 4. Postes autorisés
if ($etat.ContainsKey('UserWorkstations')) {
    $uw = [string]$etat['UserWorkstations']
    if ($uw) {
        if ($u.userWorkstations -ne $uw -and $PSCmdlet.ShouldProcess($Utilisateur, "userWorkstations = $uw")) {
            Set-ADUser -Identity $Utilisateur -LogonWorkstations $uw -ErrorAction Stop
            Write-Repare "userWorkstations restauré ($uw)"
        }
    } elseif ($u.userWorkstations -and $PSCmdlet.ShouldProcess($Utilisateur, 'Effacer userWorkstations')) {
        Set-ADUser -Identity $Utilisateur -Clear userWorkstations -ErrorAction Stop
        Write-Repare "userWorkstations effacé (tous les postes, comme à l'origine)"
    }
} elseif (-not $hayEtat -and $u.userWorkstations) {
    if ($PSCmdlet.ShouldProcess($Utilisateur, 'Effacer userWorkstations')) {
        Set-ADUser -Identity $Utilisateur -Clear userWorkstations -ErrorAction Stop
        Write-Repare "userWorkstations effacé (état standard du lab)"
    }
} else { Write-Deja "postes autorisés : rien à restaurer" }

if (-not $WhatIfPreference) { Remove-Etat $nomEtat }
