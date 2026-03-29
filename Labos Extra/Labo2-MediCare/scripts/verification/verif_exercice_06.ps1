# Vérification Exercice 06 : Délégation Chef de Service
Import-Module ActiveDirectory
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Vérification Exercice 06" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
$errors = 0
$nursingOU = "OU=Nursing,OU=MediCare,DC=maxtec,DC=be"
$acl = Get-Acl "AD:$nursingOU"
$annePerms = $acl.Access | Where-Object {$_.IdentityReference -like "*anne*"}
if ($annePerms) {
    Write-Host "`n✓ Délégation trouvée pour anne" -ForegroundColor Green
} else {
    Write-Host "`n✗ Aucune délégation pour anne" -ForegroundColor Red
    $errors++
}
if ($errors -eq 0) {
    Write-Host "`n✅ EXERCICE RÉUSSI!" -ForegroundColor Green
} else {
    Write-Host "`n✗ EXERCICE INCOMPLET" -ForegroundColor Red
}
