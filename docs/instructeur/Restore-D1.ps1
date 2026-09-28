<#
.SYNOPSIS
    Dépannage D1 - remet en état ce que Break-D1.ps1 a cassé.

.DESCRIPTION
    Utilise l'état enregistré par Break-D1 (C:\Instructeur\Etat\D1-<GpoName>.json).
    Sans fichier d'état, applique l'état standard du lab :
      - poste dans OU=Computers,OU=IT,OU=EU (paramètre -OUOrdinateur) ;
      - tous les liens de la GPO activés ;
      - Utilisateurs authentifiés = Appliquer (GpoApply), valeur par défaut d'une GPO neuve.
    Idempotent : ne modifie que ce qui n'est pas déjà dans l'état attendu.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$GpoName      = 'GPO-Mappage-IT-Admin',
    [string]$Ordinateur   = 'ws-IT-01',
    [string]$OUOrdinateur = 'OU=Computers,OU=IT,OU=EU,DC=maxtec,DC=be'
)

. "$PSScriptRoot\Commun.ps1"
Assert-DomaineLab
Import-Module GroupPolicy -ErrorAction Stop

$nomEtat = "D1-$GpoName"
$etat = Read-Etat $nomEtat
# Avec un état enregistré, on ne répare QUE les pannes que Break-D1 a réellement injectées
# (sinon on écraserait un filtrage ou un emplacement légitimes choisis par l'étudiant).
$hayEtat = $etat.Count -gt 0
if (-not $hayEtat) { Write-Host "  Aucun état enregistré : restauration vers l'état standard du lab." -ForegroundColor Yellow }

Write-Host "`n=== Restore-D1 : GPO '$GpoName' ===" -ForegroundColor Cyan

# 1. Poste
if (-not $hayEtat -or $etat.ContainsKey('OrdinateurOU')) {
    if ($etat.ContainsKey('OrdinateurOU')) { $OUOrdinateur = $etat['OrdinateurOU']; $Ordinateur = $etat['Ordinateur'] }
    $pc = Get-ADComputer -Filter "Name -eq '$Ordinateur'"
    if ($pc) {
        $parent = $pc.DistinguishedName.Substring($pc.DistinguishedName.IndexOf(',') + 1)
        if ($parent -eq $OUOrdinateur) {
            Write-Deja "$Ordinateur est dans $OUOrdinateur"
        } elseif ($PSCmdlet.ShouldProcess($Ordinateur, "Déplacer vers $OUOrdinateur")) {
            Move-ADObject -Identity $pc.DistinguishedName -TargetPath $OUOrdinateur -ErrorAction Stop
            Write-Repare "$Ordinateur replacé dans $OUOrdinateur"
        }
    }
} else { Write-Deja "poste : non cassé par Break-D1" }

$gpo = Get-GPO -Name $GpoName -ErrorAction SilentlyContinue
if ($gpo) {
    # 2. Liens (avec état : seulement ceux que Break-D1 a désactivés)
    if (-not $hayEtat -or $etat.ContainsKey('LiensDesactives')) {
        $aReactiver = $null
        if ($etat.ContainsKey('LiensDesactives')) { $aReactiver = @($etat['LiensDesactives']) }
        foreach ($l in @(Get-LiensGpo -GpoName $GpoName)) {
            if ($aReactiver -and ($aReactiver -notcontains $l.Target)) { continue }
            if ($l.Enabled) {
                Write-Deja "lien actif sur $($l.Target)"
            } elseif ($PSCmdlet.ShouldProcess($l.Target, "Activer le lien de '$GpoName'")) {
                Set-GPLink -Name $GpoName -Target $l.Target -LinkEnabled Yes -ErrorAction Stop | Out-Null
                Write-Repare "lien réactivé sur $($l.Target)"
            }
        }
    } else { Write-Deja "liens : non cassés par Break-D1" }

    # 3. Filtrage
    if (-not $hayEtat -or $etat.ContainsKey('PermissionAU')) {
        $au = Get-NomLocalise -Sid 'S-1-5-11' -SansDomaine
        $niveau = 'GpoApply'
        if ($etat.ContainsKey('PermissionAU')) { $niveau = $etat['PermissionAU'] }
        $permAu = Get-GPPermission -Name $GpoName -TargetName $au -TargetType Group -ErrorAction SilentlyContinue
        if ($permAu -and [string]$permAu.Permission -eq $niveau) {
            Write-Deja "'$au' = $niveau"
        } elseif ($PSCmdlet.ShouldProcess($GpoName, "'$au' = $niveau")) {
            Set-GPPermission -Name $GpoName -TargetName $au -TargetType Group -PermissionLevel $niveau -Replace -ErrorAction Stop | Out-Null
            Write-Repare "'$au' = $niveau"
        }
        # Le groupe de filtrage ajouté par Break-D1 est retiré seulement s'il n'avait aucun droit avant
        if ($etat.ContainsKey('GroupeAvaitDroit') -and -not $etat['GroupeAvaitDroit']) {
            $grp = $etat['GroupeFiltrage']
            if ($PSCmdlet.ShouldProcess($GpoName, "Retirer le droit ajouté pour $grp")) {
                Set-GPPermission -Name $GpoName -TargetName $grp -TargetType Group -PermissionLevel None -Replace -ErrorAction Stop | Out-Null
                Write-Repare "droit Appliquer retiré pour $grp (état d'origine)"
            }
        }
    } else { Write-Deja "filtrage : non cassé par Break-D1" }
} else {
    Write-Host "  GPO '$GpoName' introuvable : liens et filtrage non traités." -ForegroundColor Yellow
}

if (-not $WhatIfPreference) { Remove-Etat $nomEtat }
Write-Note "Sur le poste : gpupdate /force puis fermer/rouvrir la session."
