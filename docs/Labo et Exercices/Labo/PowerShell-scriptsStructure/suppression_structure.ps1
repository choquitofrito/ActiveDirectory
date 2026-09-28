# Script de suppression de la structure du lab Maxtec
# Fichier : C:\Scripts\suppression_structure.ps1
# Supprime OU=EU et TOUT ce qu'elle contient (utilisateurs, groupes, ordinateurs, sous-OUs)

Import-Module ActiveDirectory

$rootOU = "OU=EU,DC=maxtec,DC=be"

# Garde-fou 1 : bon domaine
if ((Get-ADDomain).DNSRoot -ne 'maxtec.be') {
    Write-Host "Ce script est prévu pour le domaine maxtec.be. Arrêt." -ForegroundColor Red
    exit
}

# Garde-fou 2 : l'OU existe
try {
    $null = Get-ADOrganizationalUnit -Identity $rootOU
} catch {
    Write-Host "L'OU $rootOU n'existe pas : rien à supprimer." -ForegroundColor Yellow
    exit
}

# Inventaire de ce qui va disparaître
$objets = Get-ADObject -Filter * -SearchBase $rootOU
Write-Host "`nObjets qui seront supprimés :" -ForegroundColor Cyan
$objets | Group-Object ObjectClass | Select-Object Name, Count | Format-Table -AutoSize

# Simulation (-WhatIf) : rien n'est supprimé ici
Remove-ADOrganizationalUnit -Identity $rootOU -Recursive -WhatIf

# Confirmation explicite
$reponse = Read-Host "`nTapez SUPPRIMER pour confirmer (toute autre réponse annule)"
if ($reponse -cne 'SUPPRIMER') {
    Write-Host "Annulé. Aucune modification." -ForegroundColor Yellow
    exit
}

try {
    # Retirer la protection contre la suppression accidentelle sur TOUS les objets (OUs, mais aussi
    # utilisateurs ou groupes protégés pendant les exercices) : un seul objet protégé bloque -Recursive
    Get-ADObject -Filter * -SearchBase $rootOU -Properties ProtectedFromAccidentalDeletion |
        Where-Object { $_.ProtectedFromAccidentalDeletion } |
        Set-ADObject -ProtectedFromAccidentalDeletion $false -ErrorAction Stop

    Remove-ADOrganizationalUnit -Identity $rootOU -Recursive -Confirm:$false -ErrorAction Stop
    Write-Host "`nStructure supprimée." -ForegroundColor Green
    Write-Host "Les VMs clientes restent jointes au domaine mais leurs comptes ordinateur ont disparu :" -ForegroundColor Gray
    Write-Host "re-joignez-les (ou remettez-les en groupe de travail) après avoir relancé creation_structure." -ForegroundColor Gray
}
catch {
    Write-Host "`nERREUR : $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Objets restants dans l'OU :" -ForegroundColor Gray
    Get-ADObject -Filter * -SearchBase $rootOU -Properties ProtectedFromAccidentalDeletion -ErrorAction SilentlyContinue |
        Select-Object Name, ObjectClass, ProtectedFromAccidentalDeletion | Format-Table -AutoSize
}
