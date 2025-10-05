# Script de vérification - Exercice 01 : Transfert de Patient
# Exécuter ce script pour vérifier si l'exercice est correctement complété

Import-Module ActiveDirectory

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Vérification Exercice 01" -ForegroundColor Cyan
Write-Host "Transfert de Patient" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$errors = 0
$basePath = "C:\Temp\Dossiers_Patients"  # Ajustez si nécessaire
$patients = @("Patient_001_Dupont", "Patient_012_Martin", "Patient_027_Bernard")

# Test 1: Vérifier que les dossiers patients existent
Write-Host "`nTest 1: Vérification des dossiers patients" -ForegroundColor Yellow
try {
    if (-not (Test-Path $basePath)) {
        Write-Host "  ⚠️  AVERTISSEMENT: Chemin $basePath introuvable. Essai du partage réseau..." -ForegroundColor Yellow
        $basePath = "\\SRV-MEDICARE\Dossiers_Patients"
        if (-not (Test-Path $basePath)) {
            Write-Host "  ✗ ÉCHOUÉ: Aucun des chemins (C:\Temp ou partage réseau) n'existe" -ForegroundColor Red
            $errors++
        }
    }

    $missingFolders = @()
    foreach ($patient in $patients) {
        if (-not (Test-Path "$basePath\$patient")) {
            $missingFolders += $patient
        }
    }

    if ($missingFolders.Count -eq 0) {
        Write-Host "  ✓ RÉUSSI: Les 3 dossiers patients existent" -ForegroundColor Green
    } else {
        Write-Host "  ✗ ÉCHOUÉ: Dossiers manquants: $($missingFolders -join ', ')" -ForegroundColor Red
        $errors++
    }
} catch {
    Write-Host "  ✗ ERREUR: $($_.Exception.Message)" -ForegroundColor Red
    $errors++
}

# Test 2: Vérifier les permissions du Dr. Moreau (philippe)
Write-Host "`nTest 2: Vérification permissions Dr. Moreau (philippe)" -ForegroundColor Yellow
try {
    $philMissingAccess = @()
    foreach ($patient in $patients) {
        $folderPath = "$basePath\$patient"
        if (Test-Path $folderPath) {
            $acl = Get-Acl $folderPath
            $philAccess = $acl.Access | Where-Object {$_.IdentityReference -eq "MAXTEC\philippe"}

            if (-not $philAccess) {
                $philMissingAccess += $patient
            } else {
                $hasModify = $philAccess.FileSystemRights -match "Modify|FullControl"
                if (-not $hasModify) {
                    $philMissingAccess += "$patient (droits insuffisants)"
                }
            }
        }
    }

    if ($philMissingAccess.Count -eq 0) {
        Write-Host "  ✓ RÉUSSI: Dr. Moreau a accès Modify aux 3 dossiers" -ForegroundColor Green
    } else {
        Write-Host "  ✗ ÉCHOUÉ: Problème d'accès pour philippe sur: $($philMissingAccess -join ', ')" -ForegroundColor Red
        $errors++
    }
} catch {
    Write-Host "  ✗ ERREUR: $($_.Exception.Message)" -ForegroundColor Red
    $errors++
}

# Test 3: Vérifier que catherine n'a PLUS accès
Write-Host "`nTest 3: Vérification retrait accès Dr. Leblanc (catherine)" -ForegroundColor Yellow
try {
    $cathStillHasAccess = @()
    foreach ($patient in $patients) {
        $folderPath = "$basePath\$patient"
        if (Test-Path $folderPath) {
            $acl = Get-Acl $folderPath
            $cathAccess = $acl.Access | Where-Object {$_.IdentityReference -eq "MAXTEC\catherine"}

            if ($cathAccess) {
                $cathStillHasAccess += $patient
            }
        }
    }

    if ($cathStillHasAccess.Count -eq 0) {
        Write-Host "  ✓ RÉUSSI: Dr. Leblanc n'a plus accès aux dossiers" -ForegroundColor Green
    } else {
        Write-Host "  ✗ ÉCHOUÉ: catherine a encore accès à: $($cathStillHasAccess -join ', ')" -ForegroundColor Red
        $errors++
    }
} catch {
    Write-Host "  ✗ ERREUR: $($_.Exception.Message)" -ForegroundColor Red
    $errors++
}

# Test 4: Vérifier la documentation du transfert
Write-Host "`nTest 4: Vérification documentation RGPD" -ForegroundColor Yellow
try {
    $catherineDoc = Get-ADUser -Identity catherine -Properties Description | Select-Object -ExpandProperty Description

    if ($catherineDoc -and $catherineDoc -match "TRANSFERT.*PATIENTS?|transf[ée]r") {
        Write-Host "  ✓ RÉUSSI: Transfert documenté dans le compte catherine" -ForegroundColor Green
        Write-Host "    Documentation: $catherineDoc" -ForegroundColor Gray
    } else {
        Write-Host "  ✗ ÉCHOUÉ: Aucune documentation du transfert trouvée dans le compte catherine" -ForegroundColor Red
        Write-Host "    Description actuelle: $catherineDoc" -ForegroundColor Gray
        $errors++
    }
} catch {
    Write-Host "  ✗ ERREUR: $($_.Exception.Message)" -ForegroundColor Red
    $errors++
}

# Test 5: Détails des permissions (informatif)
Write-Host "`nTest 5: Détails des permissions (informatif)" -ForegroundColor Yellow
try {
    foreach ($patient in $patients) {
        $folderPath = "$basePath\$patient"
        if (Test-Path $folderPath) {
            Write-Host "`n  📁 Dossier: $patient" -ForegroundColor Cyan
            $acl = Get-Acl $folderPath
            $relevantAccess = $acl.Access | Where-Object {$_.IdentityReference -like "*catherine*" -or $_.IdentityReference -like "*philippe*"}

            if ($relevantAccess) {
                $relevantAccess | ForEach-Object {
                    $status = if ($_.IdentityReference -eq "MAXTEC\philippe") { "✓" } else { "✗" }
                    Write-Host "     $status $($_.IdentityReference): $($_.FileSystemRights) ($($_.AccessControlType))" -ForegroundColor Gray
                }
            } else {
                Write-Host "     (Aucune permission pour catherine ou philippe)" -ForegroundColor Gray
            }
        }
    }
} catch {
    Write-Host "  ⚠️  AVERTISSEMENT: Impossible d'afficher les détails ($($_.Exception.Message))" -ForegroundColor Yellow
}

# Résumé
Write-Host "`n========================================" -ForegroundColor Cyan
if ($errors -eq 0) {
    Write-Host "EXERCICE RÉUSSI! Tous les critères sont satisfaits." -ForegroundColor Green
    Write-Host "`n✅ Résumé:" -ForegroundColor Cyan
    Write-Host "   - Les 3 dossiers patients existent" -ForegroundColor Green
    Write-Host "   - Dr. Moreau (philippe) a accès Modify" -ForegroundColor Green
    Write-Host "   - Dr. Leblanc (catherine) n'a plus accès" -ForegroundColor Green
    Write-Host "   - Le transfert est documenté (RGPD)" -ForegroundColor Green
} else {
    Write-Host "EXERCICE INCOMPLET: $errors erreur(s) détectée(s)." -ForegroundColor Red
    Write-Host "Consultez les détails ci-dessus et corrigez les points échoués." -ForegroundColor Yellow
}
Write-Host "========================================" -ForegroundColor Cyan
