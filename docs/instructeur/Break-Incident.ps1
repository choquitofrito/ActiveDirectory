<#
.SYNOPSIS
    Projet final, étape 6 - "Incident surprise" : injecte 2 pannes (type D1 + type D2) dans l'OU Logistique.

.DESCRIPTION
    Réutilise Break-D1.ps1 et Break-D2.ps1 avec les objets du projet.
    Par défaut :
      - GPO utilisateur Logistique : filtrage cassé (Utilisateurs authentifiés sans Lecture) ;
      - compte louis : verrouillé + limité à un poste inexistant.
    Variez les pannes d'un binôme à l'autre avec -FautesGpo / -FautesCompte.

.EXAMPLE
    .\Break-Incident.ps1 -WhatIf
    .\Break-Incident.ps1 -FautesGpo Lien -FautesCompte Horaires,Postes -Utilisateur lucas
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$GpoName        = 'GPO-Logistique-Utilisateurs',
    [string]$Ordinateur     = 'ws-LOG-01',
    [string]$GroupeFiltrage = 'GG-EU-Logistique-Users',
    [string]$Utilisateur    = 'louis',
    [ValidateSet('Ordinateur', 'Lien', 'Filtrage')]
    [string[]]$FautesGpo    = @('Filtrage'),
    [ValidateSet('Verrouillage', 'Horaires', 'Postes')]
    [string[]]$FautesCompte = @('Verrouillage', 'Postes'),
    [string]$PosteFactice   = 'ws-LOG-99'
)

. "$PSScriptRoot\Commun.ps1"
Assert-DomaineLab

Write-Host "`n##### Incident surprise - Logistique #####" -ForegroundColor Cyan
if ($FautesGpo.Count -gt 0) {
    & "$PSScriptRoot\Break-D1.ps1" -GpoName $GpoName -Ordinateur $Ordinateur -GroupeFiltrage $GroupeFiltrage `
        -Fautes $FautesGpo -WhatIf:$WhatIfPreference
}
if ($FautesCompte.Count -gt 0) {
    & "$PSScriptRoot\Break-D2.ps1" -Utilisateur $Utilisateur -PosteFactice $PosteFactice `
        -Fautes $FautesCompte -WhatIf:$WhatIfPreference
}
# Mémorise les paramètres pour que Restore-Incident annule exactement cette variante
if (-not $WhatIfPreference) {
    Save-Etat 'Incident' @{ GpoName = $GpoName; Ordinateur = $Ordinateur; Utilisateur = $Utilisateur }
}
Write-Host "`nNotez les pannes injectées pour ce binôme (feuille d'évaluation, critère Incident)." -ForegroundColor Cyan
