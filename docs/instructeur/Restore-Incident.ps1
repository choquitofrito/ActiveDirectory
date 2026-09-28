<#
.SYNOPSIS
    Projet final, étape 6 - annule les pannes de Break-Incident.ps1.
    À lancer après l'évaluation si le binôme n'a pas tout réparé (idempotent : sans effet sinon).
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$GpoName      = 'GPO-Logistique-Utilisateurs',
    [string]$Ordinateur   = 'ws-LOG-01',
    [string]$OUOrdinateur = 'OU=Computers,OU=Logistique,OU=EU,DC=maxtec,DC=be',
    [string]$Utilisateur  = 'louis'
)

. "$PSScriptRoot\Commun.ps1"
Assert-DomaineLab

# Reprend les paramètres utilisés par Break-Incident (sauf ceux passés explicitement ici)
$etat = Read-Etat 'Incident'
foreach ($cle in 'GpoName', 'Ordinateur', 'Utilisateur') {
    if ($etat.ContainsKey($cle) -and -not $PSBoundParameters.ContainsKey($cle)) {
        Set-Variable -Name $cle -Value $etat[$cle]
    }
}
Write-Host "Restauration de l'incident : GPO '$GpoName', poste '$Ordinateur', compte '$Utilisateur'" -ForegroundColor Cyan

& "$PSScriptRoot\Restore-D1.ps1" -GpoName $GpoName -Ordinateur $Ordinateur -OUOrdinateur $OUOrdinateur -WhatIf:$WhatIfPreference
& "$PSScriptRoot\Restore-D2.ps1" -Utilisateur $Utilisateur -WhatIf:$WhatIfPreference
if (-not $WhatIfPreference) { Remove-Etat 'Incident' }
