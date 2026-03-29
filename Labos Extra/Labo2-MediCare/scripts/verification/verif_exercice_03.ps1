# Script de vérification - Exercice 03 : Audit d'Accès Médical

Import-Module ActiveDirectory

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Vérification Exercice 03" -ForegroundColor Cyan
Write-Host "Audit d'Accès Médical" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$errors = 0
$vipFolder = "C:\Temp\Dossiers_Patients\Patient_VIP_Dupont"
$reportPath = "C:\Labos\MediCare\Rapport_Audit_VIP_Dupont.csv"

# Test 1: Dossier VIP existe
Write-Host "`nTest 1: Vérification dossier Patient_VIP_Dupont" -ForegroundColor Yellow
if (Test-Path $vipFolder) {
    $fileCount = (Get-ChildItem $vipFolder -File).Count
    Write-Host "  ✓ RÉUSSI: Dossier VIP trouvé avec $fileCount fichier(s)" -ForegroundColor Green
} else {
    Write-Host "  ✗ ÉCHOUÉ: Dossier VIP introuvable" -ForegroundColor Red
    $errors++
}

# Test 2: Audit NTFS activé
Write-Host "`nTest 2: Vérification audit NTFS" -ForegroundColor Yellow
if (Test-Path $vipFolder) {
    $acl = Get-Acl $vipFolder -Audit
    if ($acl.Audit -and $acl.Audit.Count -gt 0) {
        Write-Host "  ✓ RÉUSSI: Audit NTFS configuré" -ForegroundColor Green
        Write-Host "    $($acl.Audit.Count) règle(s) d'audit" -ForegroundColor Gray
    } else {
        Write-Host "  ✗ ÉCHOUÉ: Aucune règle d'audit trouvée" -ForegroundColor Red
        $errors++
    }
}

# Test 3: Événements 4663 présents
Write-Host "`nTest 3: Vérification événements d'audit (Event ID 4663)" -ForegroundColor Yellow
try {
    $events = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4663} -MaxEvents 500 -ErrorAction SilentlyContinue
    $relevantEvents = $events | Where-Object {$_.Message -like "*Patient_VIP_Dupont*"}

    if ($relevantEvents -and $relevantEvents.Count -gt 0) {
        Write-Host "  ✓ RÉUSSI: $($relevantEvents.Count) événement(s) trouvé(s)" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  AVERTISSEMENT: Aucun événement 4663 pour le dossier VIP" -ForegroundColor Yellow
        Write-Host "    Générez des accès au dossier (lecture/écriture fichiers)" -ForegroundColor Gray
    }
} catch {
    Write-Host "  ✗ ERREUR: $($_.Exception.Message)" -ForegroundColor Red
    $errors++
}

# Test 4: Rapport CSV généré
Write-Host "`nTest 4: Vérification rapport CSV" -ForegroundColor Yellow
if (Test-Path $reportPath) {
    $csvContent = Import-Csv $reportPath
    Write-Host "  ✓ RÉUSSI: Rapport CSV trouvé" -ForegroundColor Green
    Write-Host "    $($csvContent.Count) entrée(s) dans le rapport" -ForegroundColor Gray
    Write-Host "    Chemin: $reportPath" -ForegroundColor Gray
} else {
    Write-Host "  ✗ ÉCHOUÉ: Rapport CSV introuvable" -ForegroundColor Red
    Write-Host "    Attendu: $reportPath" -ForegroundColor Gray
    $errors++
}

# Résumé
Write-Host "`n========================================" -ForegroundColor Cyan
if ($errors -eq 0) {
    Write-Host "EXERCICE RÉUSSI! Tous les critères sont satisfaits." -ForegroundColor Green
} else {
    Write-Host "EXERCICE INCOMPLET: $errors erreur(s) détectée(s)." -ForegroundColor Red
}
Write-Host "========================================" -ForegroundColor Cyan
