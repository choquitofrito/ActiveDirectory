# Vérification Exercice 08 : Incident RGPD
Import-Module ActiveDirectory
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Vérification Exercice 08" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
$errors = 0
$reportPath = "C:\Labos\MediCare\Rapport_RGPD_Investigation.docx"
if (Test-Path $reportPath -Or (Test-Path "C:\Labos\MediCare\Rapport_RGPD_Investigation.txt")) {
    Write-Host "`n✓ Rapport RGPD trouvé" -ForegroundColor Green
} else {
    Write-Host "`n⚠️ Rapport RGPD manquant" -ForegroundColor Yellow
}
Write-Host "`n✅ Vérification terminée" -ForegroundColor Green
Write-Host "Consultez le rapport pour évaluation qualitative" -ForegroundColor Cyan
