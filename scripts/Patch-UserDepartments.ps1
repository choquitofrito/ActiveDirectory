# Patch-UserDepartments.ps1
# Renseigne l'attribut Department pour les utilisateurs existants du lab Maxtec
# À exécuter si le lab a été créé sans l'attribut Department

Import-Module ActiveDirectory

$users = @(
    @{SamAccountName = "vanessa";  Department = "Ventes"},
    @{SamAccountName = "valeria";  Department = "Ventes"},
    @{SamAccountName = "victor";   Department = "Ventes"},
    @{SamAccountName = "valentin"; Department = "Ventes"},
    @{SamAccountName = "richard";  Department = "RH"},
    @{SamAccountName = "rebecca";  Department = "RH"},
    @{SamAccountName = "rene";     Department = "RH"},
    @{SamAccountName = "charlotte";Department = "Comptabilite"},
    @{SamAccountName = "cindy";    Department = "Comptabilite"},
    @{SamAccountName = "charles";  Department = "Comptabilite"},
    @{SamAccountName = "ivan";     Department = "IT"},
    @{SamAccountName = "ines";     Department = "IT"},
    @{SamAccountName = "irene";    Department = "IT"}
)

Write-Host "Mise à jour de l'attribut Department..." -ForegroundColor Cyan

foreach ($u in $users) {
    try {
        Set-ADUser -Identity $u.SamAccountName -Department $u.Department
        Write-Host "  OK: $($u.SamAccountName) → $($u.Department)" -ForegroundColor Green
    } catch {
        Write-Host "  ERREUR: $($u.SamAccountName) — $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`nVérification:" -ForegroundColor Cyan
Get-ADUser -Filter * -SearchBase "OU=EU,DC=maxtec,DC=be" -Properties Department |
    Select-Object Name, SamAccountName, Department |
    Sort-Object Department, Name |
    Format-Table -AutoSize
