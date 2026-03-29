# Vérification Exercice 07 : Rotation de Spécialistes
Import-Module ActiveDirectory
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Vérification Exercice 07" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
$errors = 0
$users = @("amélie", "marc")
foreach ($u in $users) {
    $user = Get-ADUser -Identity $u -Properties ProfilePath -ErrorAction SilentlyContinue
    if ($user -and $user.ProfilePath) {
        Write-Host "`n✓ Roaming Profile configuré pour $u" -ForegroundColor Green
    } else {
        Write-Host "`n⚠️ Roaming Profile manquant pour $u" -ForegroundColor Yellow
    }
}
if ($errors -eq 0) {
    Write-Host "`n✅ EXERCICE RÉUSSI!" -ForegroundColor Green
} else {
    Write-Host "`n✗ EXERCICE INCOMPLET" -ForegroundColor Red
}
