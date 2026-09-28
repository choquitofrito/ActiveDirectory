<#
.SYNOPSIS
    Dépannage D2 - "Ines ne peut plus se connecter" : verrouillage + horaires + postes autorisés.

.DESCRIPTION
    Pannes possibles (paramètre -Fautes) :
      Verrouillage : une stratégie de mot de passe affinée (PSO) avec seuil de 3 échecs est appliquée
                     au compte, puis le script provoque des échecs d'authentification jusqu'au verrouillage.
                     La PSO évite de toucher la Default Domain Policy (qui réécrirait la valeur) et
                     n'affecte que le compte visé.
      Horaires     : logonHours limité à 01:00-05:00 UTC tous les jours (profil "équipe de nuit").
      Postes       : userWorkstations = un poste inexistant (ws-IT-99).

    Active aussi l'audit "Gestion des comptes d'utilisateur" (succès) sur le DC pour que
    l'événement 4740 soit journalisé. auditpol est appelé avec le GUID de la sous-catégorie,
    indépendant de la langue du système.

.EXAMPLE
    .\Break-D2.ps1 -WhatIf
    .\Break-D2.ps1 -Utilisateur louis -Fautes Verrouillage,Postes
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$Utilisateur  = 'ines',
    [string]$PosteFactice = 'ws-IT-99',
    [ValidateSet('Verrouillage', 'Horaires', 'Postes')]
    [string[]]$Fautes     = @('Verrouillage', 'Horaires', 'Postes')
)

. "$PSScriptRoot\Commun.ps1"
Assert-DomaineLab

$nomEtat = "D2-$Utilisateur"
$etat = Read-Etat $nomEtat
$nomPso = "PSO-Depannage-$Utilisateur"

$null = Get-ADUser -Identity $Utilisateur -ErrorAction Stop   # le compte doit exister
Assert-CompteNonPrivilegie $Utilisateur
Write-Host "`n=== Break-D2 : compte '$Utilisateur' ===" -ForegroundColor Cyan

# --- Panne 1 : verrouillage (en premier : les échecs doivent être comptés avant les autres restrictions)
if ($Fautes -contains 'Verrouillage') {
    # Audit de la gestion des comptes (événement 4740). GUID = "User Account Management".
    if ($PSCmdlet.ShouldProcess('dns1', 'auditpol : Gestion des comptes d''utilisateur = succès')) {
        auditpol /set /subcategory:"{0CCE9235-69AE-11D9-BED3-505054503030}" /success:enable | Out-Null
    }

    $pso = Get-ADFineGrainedPasswordPolicy -Filter "Name -eq '$nomPso'"
    if (-not $pso) {
        if ($PSCmdlet.ShouldProcess($nomPso, "Créer une PSO (seuil 3) appliquée à $Utilisateur")) {
            # Valeurs de mot de passe alignées sur les défauts du domaine pour ne rien changer d'autre
            $dd = Get-ADDefaultDomainPasswordPolicy
            New-ADFineGrainedPasswordPolicy -Name $nomPso -Precedence 90 `
                -Description "Dépannage D2 (formateur) - à supprimer avec Restore-D2.ps1" `
                -LockoutThreshold 3 `
                -LockoutDuration (New-TimeSpan -Hours 2) `
                -LockoutObservationWindow (New-TimeSpan -Minutes 30) `
                -MinPasswordLength $dd.MinPasswordLength `
                -ComplexityEnabled $dd.ComplexityEnabled `
                -PasswordHistoryCount $dd.PasswordHistoryCount `
                -MaxPasswordAge $dd.MaxPasswordAge `
                -MinPasswordAge $dd.MinPasswordAge `
                -ReversibleEncryptionEnabled $false `
                -ProtectedFromAccidentalDeletion $false
            Add-ADFineGrainedPasswordPolicySubject -Identity $nomPso -Subjects $Utilisateur
            $etat['Pso'] = $nomPso
            Save-Etat $nomEtat $etat
            Write-Faute "PSO $nomPso créée (seuil 3, durée 2 h) et appliquée à $Utilisateur"
        }
    } else {
        Write-Deja "PSO $nomPso existe"
    }

    $u = Get-ADUser -Identity $Utilisateur -Properties LockedOut
    if ($u.LockedOut) {
        Write-Deja "$Utilisateur est déjà verrouillé"
    } elseif ($PSCmdlet.ShouldProcess($Utilisateur, 'Provoquer 5 échecs d''authentification')) {
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
        $ctx = New-Object System.DirectoryServices.AccountManagement.PrincipalContext(
            [System.DirectoryServices.AccountManagement.ContextType]::Domain, $script:DomaineLab)
        # Mots de passe faux tous différents (un mot de passe faux répété ou égal à un ancien
        # mot de passe n'incrémente pas toujours badPwdCount)
        for ($i = 1; $i -le 5; $i++) {
            try { $null = $ctx.ValidateCredentials($Utilisateur, "Faux-$i-$(Get-Random)!") } catch { }
        }
        $ctx.Dispose()
        Start-Sleep -Seconds 2
        $u = Get-ADUser -Identity $Utilisateur -Properties LockedOut, badPwdCount
        if ($u.LockedOut) {
            Write-Faute "$Utilisateur verrouillé (badPwdCount = $($u.badPwdCount))"
        } else {
            Write-Host "  $Utilisateur n'est PAS verrouillé (badPwdCount = $($u.badPwdCount))." -ForegroundColor Red
            Write-Host "  Vérifiez Get-ADUserResultantPasswordPolicy $Utilisateur, ou faites 4 essais" -ForegroundColor Red
            Write-Host "  de connexion avec un mauvais mot de passe depuis le client." -ForegroundColor Red
        }
    }
}

# Lecture des attributs de restriction de connexion
$u = Get-ADUser -Identity $Utilisateur -Properties logonHours, userWorkstations

# --- Panne 2 : horaires ------------------------------------------------------
if ($Fautes -contains 'Horaires') {
    # 21 octets = 7 jours x 3 octets, en UTC, en commençant le dimanche 00:00.
    # Chaque bit = 1 heure (bit 0 = première heure de l'octet). 0x1E = heures 1,2,3,4 -> 01:00-05:00 UTC.
    $heures = New-Object byte[] 21
    for ($j = 0; $j -lt 7; $j++) { $heures[$j * 3] = 0x1E }
    $actuel = $u.logonHours
    $identique = ($actuel -ne $null) -and ([Convert]::ToBase64String($actuel) -eq [Convert]::ToBase64String($heures))
    if ($identique) {
        Write-Deja "logonHours déjà restreint"
    } elseif ($PSCmdlet.ShouldProcess($Utilisateur, 'Restreindre logonHours à 01:00-05:00 UTC')) {
        if (-not $etat.ContainsKey('LogonHours')) {
            if ($actuel) { $etat['LogonHours'] = [Convert]::ToBase64String($actuel) } else { $etat['LogonHours'] = '' }
        }
        Set-ADUser -Identity $Utilisateur -Replace @{ logonHours = [byte[]]$heures }
        Save-Etat $nomEtat $etat
        Write-Faute "logonHours = 01:00-05:00 UTC (03:00-07:00 heure belge d'été)"
    }
}

# --- Panne 3 : postes autorisés ----------------------------------------------
if ($Fautes -contains 'Postes') {
    if ($u.userWorkstations -eq $PosteFactice) {
        Write-Deja "userWorkstations = $PosteFactice"
    } elseif ($PSCmdlet.ShouldProcess($Utilisateur, "Limiter la connexion au poste $PosteFactice")) {
        if (-not $etat.ContainsKey('UserWorkstations')) { $etat['UserWorkstations'] = [string]$u.userWorkstations }
        Set-ADUser -Identity $Utilisateur -LogonWorkstations $PosteFactice
        Save-Etat $nomEtat $etat
        Write-Faute "userWorkstations = $PosteFactice (poste inexistant)"
    }
}

Write-Host "`nSymptômes attendus pour $Utilisateur :" -ForegroundColor Cyan
Write-Note "- d'abord : compte verrouillé ;"
Write-Note "- après déverrouillage : refus lié aux horaires et/ou au poste autorisé (l'ordre des messages"
Write-Note "  peut varier ; l'étudiant doit trouver les deux)."

Write-Note "Réparation formateur : .\Restore-D2.ps1 -Utilisateur $Utilisateur"
