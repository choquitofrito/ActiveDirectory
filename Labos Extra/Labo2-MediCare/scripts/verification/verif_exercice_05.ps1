# Vérification Exercice 05 : Confidentialité Renforcée
Import-Module ActiveDirectory
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Vérification Exercice 05" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
$errors = 0
$gpoName = "MediCare - Sécurité Renforcée Médical"
if (Get-GPO -Name $gpoName -ErrorAction SilentlyContinue) {
    Write-Host "`n✓ GPO '$gpoName' trouvée" -ForegroundColor Green
} else {
    Write-Host "`n✗ GPO manquante" -ForegroundColor Red
    $errors++
}
if ($errors -eq 0) {
    Write-Host "`n✅ EXERCICE RÉUSSI!" -ForegroundColor Green
} else {
    Write-Host "`n✗ EXERCICE INCOMPLET" -ForegroundColor Red
}
