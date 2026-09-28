<#
.SYNOPSIS
    Dépannage D3 - "Accès refusé au dossier Ventes" : AGDLP cassé sur \\dns1\Ventes-Documents.

.DESCRIPTION
    Part de l'état final de l'exercice AGDLP (groupes DL-Ventes-Documents-Lecture / -Modification /
    -ControleTotal dans OU=Groups,OU=Resources,OU=EU ; partage Ventes-Documents).
    Avec -Preparer, crée cet état s'il manque (utile si l'étudiant n'a pas terminé l'exercice).

    Pannes possibles (paramètre -Fautes) :
      Etendue : DL-Ventes-Documents-Modification est supprimé puis recréé en étendue GLOBALE
                (même nom, même membre). Nouveau SID : l'ACE NTFS de l'ancien groupe devient un
                SID orphelin, valentin perd tout accès (il n'est pas dans GG-EU-Ventes-Users).
      Refus   : un Refuser explicite (Lecture et exécution) pour GG-EU-Ventes-Users sur le
                sous-dossier Contrats. Double faute : un GG dans l'ACL + un Deny.
      Ticket  : GG-EU-Compta-Users retiré de DL-Ventes-Documents-Lecture. Quand l'étudiant le
                remet, cindy reste refusée tant qu'elle garde son ancien ticket Kerberos.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$Chemin = 'C:\Shares\Ventes-Documents',
    [switch]$Preparer,
    [ValidateSet('Etendue', 'Refus', 'Ticket')]
    [string[]]$Fautes = @('Etendue', 'Refus', 'Ticket')
)

. "$PSScriptRoot\Commun.ps1"
Assert-DomaineLab

$nb        = (Get-ADDomain).NetBIOSName
$ouRes     = 'OU=Resources,OU=EU,DC=maxtec,DC=be'
$ouGroupes = "OU=Groups,$ouRes"
$dlLect    = 'DL-Ventes-Documents-Lecture'
$dlModif   = 'DL-Ventes-Documents-Modification'
$dlCT      = 'DL-Ventes-Documents-ControleTotal'
$nomEtat   = 'D3-Ventes-Documents'
$etat      = Read-Etat $nomEtat

function Add-RegleNtfs {
    param([string]$Dossier, [string]$Compte, [string]$Droits, [string]$Type = 'Allow')
    $acl = (Get-Item $Dossier).GetAccessControl('Access')
    $regle = New-Object System.Security.AccessControl.FileSystemAccessRule(
        $Compte, $Droits, 'ContainerInherit,ObjectInherit', 'None', $Type)
    $acl.AddAccessRule($regle)
    (Get-Item $Dossier).SetAccessControl($acl)
}

Write-Host "`n=== Break-D3 : $Chemin ===" -ForegroundColor Cyan

# --- Préparation : état final de l'exercice AGDLP ----------------------------
if ($Preparer -and $PSCmdlet.ShouldProcess($Chemin, 'Créer l''état final de l''exercice AGDLP si nécessaire')) {
    foreach ($ou in @(@{N='Resources';P='OU=EU,DC=maxtec,DC=be'}, @{N='Groups';P=$ouRes})) {
        if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq 'OU=$($ou.N),$($ou.P)'")) {
            New-ADOrganizationalUnit -Name $ou.N -Path $ou.P -ProtectedFromAccidentalDeletion $false
        }
    }
    $def = @(
        @{N=$dlLect;  M=@('GG-EU-Ventes-Users','GG-EU-Compta-Users'); D='ReadAndExecute'},
        @{N=$dlModif; M=@('GG-EU-Ventes-Admin');                      D='Modify'},
        @{N=$dlCT;    M=@('GG-EU-IT-Admin');                          D='FullControl'}
    )
    foreach ($g in $def) {
        if (-not (Get-ADGroup -Filter "Name -eq '$($g.N)'")) {
            New-ADGroup -Name $g.N -GroupScope DomainLocal -GroupCategory Security -Path $ouGroupes
        }
        $membres = @(Get-ADGroupMember $g.N | Select-Object -ExpandProperty SamAccountName)
        foreach ($m in $g.M) { if ($membres -notcontains $m) { Add-ADGroupMember -Identity $g.N -Members $m } }
    }
    if (-not (Test-Path $Chemin)) { New-Item -ItemType Directory -Path $Chemin -Force | Out-Null }
    $acl = (Get-Item $Chemin).GetAccessControl('Access')
    if (-not $acl.AreAccessRulesProtected) {
        $acl.SetAccessRuleProtection($true, $true)           # désactiver l'héritage, convertir en explicite
        (Get-Item $Chemin).SetAccessControl($acl)
        $acl = (Get-Item $Chemin).GetAccessControl('Access')
        foreach ($sid in @('S-1-5-32-545', 'S-1-5-11')) {   # Utilisateurs, Utilisateurs authentifiés
            $acl.PurgeAccessRules((New-Object System.Security.Principal.SecurityIdentifier $sid))
        }
        (Get-Item $Chemin).SetAccessControl($acl)
        foreach ($g in $def) { Add-RegleNtfs -Dossier $Chemin -Compte "$nb\$($g.N)" -Droits $g.D }
    }
    if (-not (Get-SmbShare -Name 'Ventes-Documents' -ErrorAction SilentlyContinue)) {
        New-SmbShare -Name 'Ventes-Documents' -Path $Chemin -ChangeAccess (Get-NomLocalise -Sid 'S-1-1-0') | Out-Null
    }
    Write-Note "état AGDLP de départ en place"
}

if (-not (Test-Path $Chemin) -or -not (Get-ADGroup -Filter "Name -eq '$dlModif'")) {
    Write-Host "  L'état final de l'exercice AGDLP est absent. Relancez avec -Preparer." -ForegroundColor Red
    return
}

# --- Panne 1 : DL recréé en Global -------------------------------------------
if ($Fautes -contains 'Etendue') {
    $g = Get-ADGroup -Identity $dlModif -Properties Description
    if ($g.GroupScope -eq 'Global') {
        Write-Deja "$dlModif est déjà en étendue Global"
    } elseif ($PSCmdlet.ShouldProcess($dlModif, 'Supprimer et recréer en étendue Global')) {
        $membres = @(Get-ADGroupMember $dlModif | Select-Object -ExpandProperty DistinguishedName)
        $parent = $g.DistinguishedName.Substring($g.DistinguishedName.IndexOf(',') + 1)
        # État enregistré AVANT l'opération destructive : si la suite échoue, Restore-D3 sait quoi recréer
        if (-not $etat.ContainsKey('AncienSid')) { $etat['AncienSid'] = $g.SID.Value }
        $etat['DlParent']  = $parent
        $etat['DlMembres'] = $membres
        Save-Etat $nomEtat $etat
        Remove-ADGroup -Identity $g -Confirm:$false -ErrorAction Stop
        $p = @{ Name = $dlModif; GroupScope = 'Global'; GroupCategory = 'Security'; Path = $parent; ErrorAction = 'Stop' }
        if ($g.Description) { $p['Description'] = $g.Description }
        New-ADGroup @p
        if ($membres.Count -gt 0) { Add-ADGroupMember -Identity $dlModif -Members $membres -ErrorAction Stop }
        Write-Faute "$dlModif recréé en Global (ancien SID $($etat['AncienSid']) orphelin dans l'ACL)"
    }
}

# --- Panne 2 : Deny explicite sur un sous-dossier ----------------------------
if ($Fautes -contains 'Refus') {
    $sous = Join-Path $Chemin 'Contrats'
    if ($PSCmdlet.ShouldProcess($sous, 'Refuser Lecture pour GG-EU-Ventes-Users')) {
        if (-not (Test-Path $sous)) {
            New-Item -ItemType Directory -Path $sous -Force | Out-Null
            Set-Content -Path (Join-Path $sous 'Contrat-Client-2026-014.txt') -Value 'Contrat cadre - client Brasserie Dumont' -Encoding UTF8
        }
        $ggSid = (Get-ADGroup 'GG-EU-Ventes-Users').SID.Value
        $acl = (Get-Item $sous).GetAccessControl('Access')
        $deja = $acl.GetAccessRules($true, $false, [System.Security.Principal.SecurityIdentifier]) |
            Where-Object { $_.IdentityReference.Value -eq $ggSid -and $_.AccessControlType -eq 'Deny' }
        if ($deja) {
            Write-Deja "Deny déjà présent sur $sous"
        } else {
            Add-RegleNtfs -Dossier $sous -Compte "$nb\GG-EU-Ventes-Users" -Droits 'ReadAndExecute' -Type 'Deny'
            $etat['DenySur'] = $sous
            Save-Etat $nomEtat $etat
            Write-Faute "Deny Lecture pour GG-EU-Ventes-Users sur $sous"
        }
    }
}

# --- Panne 3 : Compta retirée du DL de lecture -------------------------------
if ($Fautes -contains 'Ticket') {
    $membres = @(Get-ADGroupMember $dlLect | Select-Object -ExpandProperty SamAccountName)
    if ($membres -notcontains 'GG-EU-Compta-Users') {
        Write-Deja "GG-EU-Compta-Users n'est pas membre de $dlLect"
    } elseif ($PSCmdlet.ShouldProcess($dlLect, 'Retirer GG-EU-Compta-Users')) {
        Remove-ADGroupMember -Identity $dlLect -Members 'GG-EU-Compta-Users' -Confirm:$false
        $etat['ComptaRetiree'] = $true
        Save-Etat $nomEtat $etat
        Write-Faute "GG-EU-Compta-Users retiré de $dlLect"
    }
}

Write-Host "`nSymptômes attendus (depuis le client, \\dns1\Ventes-Documents) :" -ForegroundColor Cyan
Write-Note "- valentin (seulement GG-EU-Ventes-Admin) : accès refusé au partage ;"
Write-Note "- vanessa / victor : racine OK, dossier Contrats refusé ;"
Write-Note "- cindy : accès refusé (et toujours refusé juste après la correction, tant qu'elle n'a pas"
Write-Note "  fermé sa session ou purgé ses tickets)."
Write-Note "Pour que la panne 'Ticket' morde : faites ouvrir le partage par cindy AVANT la correction."
Write-Note "Réparation formateur : .\Restore-D3.ps1"
