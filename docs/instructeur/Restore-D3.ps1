<#
.SYNOPSIS
    Dépannage D3 - rétablit l'état AGDLP correct de \\dns1\Ventes-Documents.

.DESCRIPTION
    - DL-Ventes-Documents-Modification : étendue Domaine local (Global -> Universel -> Domaine local),
      membre GG-EU-Ventes-Admin, ACE Modification sur le dossier ;
    - ACE orphelines (SID de domaine non résolus) supprimées de la racine ;
    - Deny sur Contrats supprimé ;
    - GG-EU-Compta-Users remis dans DL-Ventes-Documents-Lecture (état final de l'exercice AGDLP, étape 8).
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$Chemin = 'C:\Shares\Ventes-Documents'
)

. "$PSScriptRoot\Commun.ps1"
Assert-DomaineLab

$nb      = (Get-ADDomain).NetBIOSName
$dlLect  = 'DL-Ventes-Documents-Lecture'
$dlModif = 'DL-Ventes-Documents-Modification'
$nomEtat = 'D3-Ventes-Documents'
$etat    = Read-Etat $nomEtat
$SidType = [System.Security.Principal.SecurityIdentifier]
Write-Host "`n=== Restore-D3 : $Chemin ===" -ForegroundColor Cyan

# 1. Étendue du DL (et recréation si Break-D3 s'est interrompu entre la suppression et la recréation)
$g = Get-ADGroup -Filter "Name -eq '$dlModif'"
if (-not $g) {
    if (-not $etat.ContainsKey('DlParent')) { throw "$dlModif introuvable et aucun état pour le recréer. Refaites l'étape AGDLP." }
    if ($PSCmdlet.ShouldProcess($dlModif, "Recréer en Domaine local dans $($etat['DlParent'])")) {
        New-ADGroup -Name $dlModif -GroupScope DomainLocal -GroupCategory Security -Path $etat['DlParent'] -ErrorAction Stop
        $m = @($etat['DlMembres'] | Where-Object { $_ })
        if ($m.Count -gt 0) { Add-ADGroupMember -Identity $dlModif -Members $m -ErrorAction Stop }
        Write-Repare "$dlModif recréé en Domaine local"
    }
    $g = Get-ADGroup -Filter "Name -eq '$dlModif'"
}
if (-not $g) {
    Write-Deja "(simulation) $dlModif serait recréé"
} elseif ($g.GroupScope -ne 'DomainLocal') {
    if ($PSCmdlet.ShouldProcess($dlModif, "Étendue $($g.GroupScope) -> DomainLocal")) {
        if ($g.GroupScope -eq 'Global') { Set-ADGroup -Identity $dlModif -GroupScope Universal }
        Set-ADGroup -Identity $dlModif -GroupScope DomainLocal
        Write-Repare "$dlModif repassé en Domaine local"
    }
} else { Write-Deja "$dlModif est en Domaine local" }

$membres = @()
if ($g) { $membres = @(Get-ADGroupMember $dlModif | Select-Object -ExpandProperty SamAccountName) }
if ($g -and $membres -notcontains 'GG-EU-Ventes-Admin' -and $PSCmdlet.ShouldProcess($dlModif, 'Ajouter GG-EU-Ventes-Admin')) {
    Add-ADGroupMember -Identity $dlModif -Members 'GG-EU-Ventes-Admin'
    Write-Repare "GG-EU-Ventes-Admin ajouté à $dlModif"
}

# 2. ACL de la racine : SID orphelins + ACE du DL
$acl = (Get-Item $Chemin).GetAccessControl('Access')
$modifie = $false
foreach ($r in @($acl.GetAccessRules($true, $false, $SidType))) {
    $sid = $r.IdentityReference
    $orphelin = $false
    if ($sid.Value -like 'S-1-5-21-*') {
        try { $null = $sid.Translate([System.Security.Principal.NTAccount]) } catch { $orphelin = $true }
    }
    if ($orphelin -or ($etat.ContainsKey('AncienSid') -and $sid.Value -eq $etat['AncienSid'])) {
        if ($PSCmdlet.ShouldProcess($Chemin, "Supprimer l'ACE orpheline $($sid.Value)")) {
            $acl.RemoveAccessRuleSpecific($r); $modifie = $true
            Write-Repare "ACE orpheline $($sid.Value) supprimée"
        }
    }
}
$dlSid = if ($g) { (Get-ADGroup $dlModif).SID.Value } else { '' }
$aModif = $acl.GetAccessRules($true, $false, $SidType) | Where-Object {
    $_.IdentityReference.Value -eq $dlSid -and $_.AccessControlType -eq 'Allow' -and
    (($_.FileSystemRights -band [System.Security.AccessControl.FileSystemRights]::Modify) -eq [System.Security.AccessControl.FileSystemRights]::Modify)
}
if ($g -and -not $aModif -and $PSCmdlet.ShouldProcess($Chemin, "Ajouter Modification pour $dlModif")) {
    $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule(
        "$nb\$dlModif", 'Modify', 'ContainerInherit,ObjectInherit', 'None', 'Allow')))
    $modifie = $true
    Write-Repare "ACE Modification ajoutée pour $dlModif"
}
if ($modifie) { (Get-Item $Chemin).SetAccessControl($acl) }

# 3. Deny sur Contrats
$sous = Join-Path $Chemin 'Contrats'
if (Test-Path $sous) {
    $ggSid = (Get-ADGroup 'GG-EU-Ventes-Users').SID.Value
    $aclS = (Get-Item $sous).GetAccessControl('Access')
    $refus = @($aclS.GetAccessRules($true, $false, $SidType) |
        Where-Object { $_.IdentityReference.Value -eq $ggSid })
    if ($refus.Count -gt 0) {
        if ($PSCmdlet.ShouldProcess($sous, 'Supprimer les ACE explicites de GG-EU-Ventes-Users')) {
            foreach ($r in $refus) { $aclS.RemoveAccessRuleSpecific($r) }
            (Get-Item $sous).SetAccessControl($aclS)
            Write-Repare "ACE explicites de GG-EU-Ventes-Users supprimées sur $sous"
        }
    } else { Write-Deja "aucune ACE explicite pour GG-EU-Ventes-Users sur $sous" }
}

# 4. Compta dans le DL de lecture
$membres = @(Get-ADGroupMember $dlLect | Select-Object -ExpandProperty SamAccountName)
if ($membres -notcontains 'GG-EU-Compta-Users') {
    if ($PSCmdlet.ShouldProcess($dlLect, 'Ajouter GG-EU-Compta-Users')) {
        Add-ADGroupMember -Identity $dlLect -Members 'GG-EU-Compta-Users'
        Write-Repare "GG-EU-Compta-Users remis dans $dlLect"
    }
} else { Write-Deja "GG-EU-Compta-Users est membre de $dlLect" }

if (-not $WhatIfPreference) { Remove-Etat $nomEtat }
Write-Note "Côté client : fermer/rouvrir les sessions de test (nouveaux jetons)."
