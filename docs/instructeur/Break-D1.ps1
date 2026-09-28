<#
.SYNOPSIS
    Dépannage D1 - "Le lecteur réseau a disparu pour l'IT" : injecte les pannes GPO.

.DESCRIPTION
    Pannes possibles (paramètre -Fautes) :
      Ordinateur : le poste est déplacé dans le conteneur CN=Computers (plus aucune GPO d'OU côté ordinateur).
      Lien       : tous les liens de la GPO du lecteur réseau sont désactivés (Set-GPLink -LinkEnabled No).
      Filtrage   : filtrage de sécurité "à moitié fait" : GroupeFiltrage reçoit Appliquer, et
                   Utilisateurs authentifiés perd TOUT droit (y compris Lecture). Depuis MS16-072,
                   les GPO utilisateur sont lues dans le contexte de l'ordinateur : sans Lecture pour
                   les ordinateurs, la GPO n'est plus appliquée.

    L'état initial est enregistré dans C:\Instructeur\Etat\ pour Restore-D1.ps1.
    Idempotent : relancer le script ne modifie pas l'état déjà enregistré.

.PARAMETER GpoName
    Nom de la GPO de mappage du lecteur IT-Admin (GPO-1 §4.1 le nomme GPO-Mappage-IT-Admin).
    Défaut : GPO-Mappage-IT-Admin. Vérifiez le nom réel chez l'étudiant avec Get-GPO -All.

.EXAMPLE
    .\Break-D1.ps1 -WhatIf
    .\Break-D1.ps1 -GpoName "GPO-Mappage-IT" -Fautes Lien,Filtrage
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$GpoName        = 'GPO-Mappage-IT-Admin',
    [string]$Ordinateur     = 'ws-IT-01',
    [string]$GroupeFiltrage = 'GG-EU-IT-Admin',
    [ValidateSet('Ordinateur', 'Lien', 'Filtrage')]
    [string[]]$Fautes       = @('Ordinateur', 'Lien', 'Filtrage')
)

. "$PSScriptRoot\Commun.ps1"
Assert-DomaineLab
Import-Module GroupPolicy -ErrorAction Stop

$nomEtat = "D1-$GpoName"
$etat = Read-Etat $nomEtat

Write-Host "`n=== Break-D1 : GPO '$GpoName' / poste '$Ordinateur' ===" -ForegroundColor Cyan

$gpo = Get-GPO -Name $GpoName -ErrorAction SilentlyContinue
if (-not $gpo -and ($Fautes -contains 'Lien' -or $Fautes -contains 'Filtrage')) {
    Write-Host "  GPO '$GpoName' introuvable. GPO existantes :" -ForegroundColor Red
    Get-GPO -All | Sort-Object DisplayName | ForEach-Object { Write-Note "- $($_.DisplayName)" }
    Write-Host "  Relancez avec -GpoName '<nom exact>'." -ForegroundColor Red
    return
}
if ($gpo) { Assert-GpoNonCritique $gpo }

# --- Panne 1 : poste dans CN=Computers ---------------------------------------
if ($Fautes -contains 'Ordinateur') {
    $pc = Get-ADComputer -Filter "Name -eq '$Ordinateur'"
    if (-not $pc) {
        Write-Host "  Ordinateur '$Ordinateur' introuvable : panne 'Ordinateur' ignorée." -ForegroundColor Yellow
    } else {
        $conteneur = (Get-ADDomain).ComputersContainer
        $parent = $pc.DistinguishedName.Substring($pc.DistinguishedName.IndexOf(',') + 1)
        if ($parent -eq $conteneur) {
            Write-Deja "$Ordinateur est déjà dans $conteneur"
        } elseif ($PSCmdlet.ShouldProcess($Ordinateur, "Déplacer vers $conteneur")) {
            if (-not $etat.ContainsKey('OrdinateurOU')) { $etat['OrdinateurOU'] = $parent; $etat['Ordinateur'] = $Ordinateur }
            Move-ADObject -Identity $pc.DistinguishedName -TargetPath $conteneur
            Save-Etat $nomEtat $etat
            Write-Faute "$Ordinateur déplacé de $parent vers $conteneur"
        }
    }
}

# --- Panne 2 : liens désactivés ----------------------------------------------
if ($Fautes -contains 'Lien') {
    $liens = @(Get-LiensGpo -GpoName $GpoName)
    if ($liens.Count -eq 0) {
        Write-Host "  La GPO n'est liée nulle part : panne 'Lien' sans objet." -ForegroundColor Yellow
    }
    foreach ($l in $liens) {
        if (-not $l.Enabled) {
            Write-Deja "lien déjà désactivé sur $($l.Target)"
        } elseif ($PSCmdlet.ShouldProcess($l.Target, "Désactiver le lien de '$GpoName'")) {
            $cibles = @()
            if ($etat.ContainsKey('LiensDesactives')) { $cibles = @($etat['LiensDesactives']) }
            if ($cibles -notcontains $l.Target) { $cibles += $l.Target }
            $etat['LiensDesactives'] = $cibles
            Set-GPLink -Name $GpoName -Target $l.Target -LinkEnabled No | Out-Null
            Save-Etat $nomEtat $etat
            Write-Faute "lien désactivé sur $($l.Target)"
        }
    }
}

# --- Panne 3 : filtrage de sécurité sans Lecture pour les ordinateurs ---------
if ($Fautes -contains 'Filtrage') {
    $au = Get-NomLocalise -Sid 'S-1-5-11' -SansDomaine
    $permAu = Get-GPPermission -Name $GpoName -TargetName $au -TargetType Group -ErrorAction SilentlyContinue
    if (-not $permAu) {
        Write-Deja "'$au' n'a déjà plus aucun droit sur la GPO"
    } elseif ($PSCmdlet.ShouldProcess($GpoName, "Filtrer sur $GroupeFiltrage et retirer '$au'")) {
        if (-not $etat.ContainsKey('PermissionAU')) {
            $etat['PermissionAU'] = [string]$permAu.Permission
            $permGrp = Get-GPPermission -Name $GpoName -TargetName $GroupeFiltrage -TargetType Group -ErrorAction SilentlyContinue
            $etat['GroupeFiltrage'] = $GroupeFiltrage
            $etat['GroupeAvaitDroit'] = [bool]$permGrp
        }
        Set-GPPermission -Name $GpoName -TargetName $GroupeFiltrage -TargetType Group -PermissionLevel GpoApply | Out-Null
        Set-GPPermission -Name $GpoName -TargetName $au -TargetType Group -PermissionLevel None -Replace | Out-Null
        Save-Etat $nomEtat $etat
        Write-Faute "filtrage : $GroupeFiltrage = Appliquer, '$au' supprimé (plus de Lecture)"
    }
}

Write-Host "`nSymptômes attendus (après gpupdate /force + reconnexion sur $Ordinateur) :" -ForegroundColor Cyan
Write-Note "- le lecteur réseau de la GPO '$GpoName' n'apparaît plus ;"
Write-Note "- les GPO ordinateur d'OU (message de connexion, verrouillage) ne s'appliquent plus au poste."
Write-Note "Réparation formateur : .\Restore-D1.ps1 -GpoName '$GpoName'"
