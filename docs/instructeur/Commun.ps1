# Fonctions communes aux scripts Break-*/Restore-* (formateur uniquement)
# Chargé par dot-sourcing :  . "$PSScriptRoot\Commun.ps1"
# Compatible Windows PowerShell 5.1. À exécuter sur le DC (dns1) en administrateur du domaine.

$script:DomaineLab  = 'maxtec.be'
$script:DossierEtat = 'C:\Instructeur\Etat'

function Assert-DomaineLab {
    # Garde-fou : on ne casse rien en dehors du domaine du lab
    Import-Module ActiveDirectory -ErrorAction Stop
    $dns = (Get-ADDomain -ErrorAction Stop).DNSRoot
    if ($dns -ne $script:DomaineLab) {
        throw "Domaine détecté : '$dns'. Ces scripts sont réservés au domaine $($script:DomaineLab). Arrêt."
    }
}

function Assert-GpoNonCritique {
    # Refuse de casser la Default Domain Policy ou la Default Domain Controllers Policy
    param([Parameter(Mandatory)]$Gpo)
    $critiques = @('31B2F340-016D-11D2-945F-00C04FB984F9', '6AC1786C-016F-11D2-945F-00C04FB984F9')
    if ($critiques -contains $Gpo.Id.ToString().ToUpper()) {
        throw "La GPO '$($Gpo.DisplayName)' est une GPO par défaut du domaine : refus."
    }
}

function Assert-CompteNonPrivilegie {
    # Refuse de casser un compte administrateur (RID 500, ou protégé par AdminSDHolder)
    param([Parameter(Mandatory)][string]$SamAccountName)
    $u = Get-ADUser -Identity $SamAccountName -Properties adminCount -ErrorAction Stop
    if ($u.SID.Value -like '*-500' -or $u.adminCount -eq 1) {
        throw "Le compte '$SamAccountName' est un compte privilégié : refus."
    }
}

function Get-CheminEtat {
    param([Parameter(Mandatory)][string]$Nom)
    $nomFichier = ($Nom -replace '[^A-Za-z0-9_-]', '_') + '.json'
    return (Join-Path $script:DossierEtat $nomFichier)
}

function Read-Etat {
    # Renvoie une hashtable (vide si aucun état enregistré)
    param([Parameter(Mandatory)][string]$Nom)
    $h = @{}
    $chemin = Get-CheminEtat $Nom
    if (Test-Path $chemin) {
        $obj = Get-Content $chemin -Raw | ConvertFrom-Json
        foreach ($p in $obj.PSObject.Properties) { $h[$p.Name] = $p.Value }
    }
    return $h
}

function Save-Etat {
    # Écrit l'état sur disque. -WhatIf:$false : l'appelant ne l'appelle qu'après une modification réelle.
    param([Parameter(Mandatory)][string]$Nom, [Parameter(Mandatory)][hashtable]$Etat)
    if (-not (Test-Path $script:DossierEtat)) {
        New-Item -ItemType Directory -Path $script:DossierEtat -Force -WhatIf:$false | Out-Null
    }
    $Etat | ConvertTo-Json -Depth 5 | Set-Content -Path (Get-CheminEtat $Nom) -Encoding UTF8 -WhatIf:$false
}

function Remove-Etat {
    param([Parameter(Mandatory)][string]$Nom)
    $chemin = Get-CheminEtat $Nom
    if (Test-Path $chemin) { Remove-Item $chemin -Force -WhatIf:$false }
}

function Get-NomLocalise {
    # Nom d'un principal bien connu dans la langue du système (ex. S-1-5-11 -> "Utilisateurs authentifiés")
    param([Parameter(Mandatory)][string]$Sid, [switch]$SansDomaine)
    $nt = (New-Object System.Security.Principal.SecurityIdentifier $Sid).Translate([System.Security.Principal.NTAccount]).Value
    if ($SansDomaine -and $nt.Contains('\')) { return $nt.Split('\')[1] }
    return $nt
}

function Get-LiensGpo {
    # Liste des cibles (DN) où une GPO est liée : racine du domaine + toutes les OUs
    param([Parameter(Mandatory)][string]$GpoName)
    $cibles = @((Get-ADDomain).DistinguishedName)
    $cibles += (Get-ADOrganizationalUnit -Filter * | Select-Object -ExpandProperty DistinguishedName)
    $liens = @()
    foreach ($c in $cibles) {
        $inh = Get-GPInheritance -Target $c -ErrorAction SilentlyContinue
        if ($inh) {
            $liens += $inh.GpoLinks | Where-Object { $_.DisplayName -eq $GpoName } |
                Select-Object @{n='Target';e={$c}}, Enabled
        }
    }
    return $liens
}

function Write-Faute  { param([string]$Texte) Write-Host "  [PANNE]    $Texte" -ForegroundColor Magenta }
function Write-Repare { param([string]$Texte) Write-Host "  [RÉPARÉ]   $Texte" -ForegroundColor Green }
function Write-Deja   { param([string]$Texte) Write-Host "  [INCHANGÉ] $Texte" -ForegroundColor Yellow }
function Write-Note   { param([string]$Texte) Write-Host "  $Texte" -ForegroundColor Gray }
