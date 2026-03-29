# Script de vérification - Exercice 1
# Exécuter ce script pour vérifier si l'exercice est correctement complété

Import-Module ActiveDirectory

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Vérification Exercice 1" -ForegroundColor Cyan
Write-Host "Création du compte Sophie Moreau" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$errors = 0
$warnings = 0

# Test 1: Vérifier que l'utilisateur sophie existe
Write-Host "`nTest 1: Existence de l'utilisateur 'sophie'" -ForegroundColor Yellow
try {
    $user = Get-ADUser -Identity sophie -Properties EmailAddress, Title, Department, DistinguishedName -ErrorAction Stop
    Write-Host "  ✓ RÉUSSI - L'utilisateur 'sophie' existe" -ForegroundColor Green
} catch {
    Write-Host "  ✗ ÉCHOUÉ: L'utilisateur 'sophie' n'existe pas" -ForegroundColor Red
    Write-Host "    Créez l'utilisateur avec le SAM 'sophie'" -ForegroundColor Yellow
    $errors++
    $user = $null
}

if ($user) {
    # Test 2: Vérifier l'emplacement (OU correcte)
    Write-Host "`nTest 2: Emplacement dans l'OU Creative\Users" -ForegroundColor Yellow
    $expectedOU = "OU=Users,OU=Creative,OU=CreativeHub,DC=maxtec,DC=be"
    if ($user.DistinguishedName -like "CN=*,$expectedOU") {
        Write-Host "  ✓ RÉUSSI - Sophie est dans l'OU correcte" -ForegroundColor Green
        Write-Host "    Emplacement: $($user.DistinguishedName)" -ForegroundColor Gray
    } else {
        Write-Host "  ✗ ÉCHOUÉ: Sophie n'est pas dans la bonne OU" -ForegroundColor Red
        Write-Host "    Emplacement actuel: $($user.DistinguishedName)" -ForegroundColor Yellow
        Write-Host "    Emplacement attendu: CN=Sophie Moreau,$expectedOU" -ForegroundColor Yellow
        $errors++
    }

    # Test 3: Vérifier l'adresse email
    Write-Host "`nTest 3: Configuration de l'adresse email" -ForegroundColor Yellow
    if ($user.EmailAddress -eq "sophie@maxtec.be") {
        Write-Host "  ✓ RÉUSSI - Email configuré: sophie@maxtec.be" -ForegroundColor Green
    } else {
        Write-Host "  ✗ ÉCHOUÉ: Email incorrect ou manquant" -ForegroundColor Red
        Write-Host "    Email actuel: $($user.EmailAddress)" -ForegroundColor Yellow
        Write-Host "    Email attendu: sophie@maxtec.be" -ForegroundColor Yellow
        $errors++
    }

    # Test 4: Vérifier la fonction (Title)
    Write-Host "`nTest 4: Configuration de la fonction (Title)" -ForegroundColor Yellow
    if ($user.Title -eq "Graphiste Junior") {
        Write-Host "  ✓ RÉUSSI - Fonction: Graphiste Junior" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ AVERTISSEMENT: Fonction incorrecte ou manquante" -ForegroundColor Yellow
        Write-Host "    Fonction actuelle: $($user.Title)" -ForegroundColor Yellow
        Write-Host "    Fonction attendue: Graphiste Junior" -ForegroundColor Yellow
        $warnings++
    }

    # Test 5: Vérifier le département
    Write-Host "`nTest 5: Configuration du département" -ForegroundColor Yellow
    if ($user.Department -eq "Creative") {
        Write-Host "  ✓ RÉUSSI - Département: Creative" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ AVERTISSEMENT: Département incorrect ou manquant" -ForegroundColor Yellow
        Write-Host "    Département actuel: $($user.Department)" -ForegroundColor Yellow
        Write-Host "    Département attendu: Creative" -ForegroundColor Yellow
        $warnings++
    }

    # Test 6: Vérifier que le compte est activé
    Write-Host "`nTest 6: Compte activé (Enabled)" -ForegroundColor Yellow
    $userEnabled = Get-ADUser -Identity sophie -Properties Enabled | Select-Object -ExpandProperty Enabled
    if ($userEnabled -eq $true) {
        Write-Host "  ✓ RÉUSSI - Le compte est activé" -ForegroundColor Green
    } else {
        Write-Host "  ✗ ÉCHOUÉ: Le compte est désactivé" -ForegroundColor Red
        Write-Host "    Activez le compte dans les propriétés utilisateur" -ForegroundColor Yellow
        $errors++
    }

    # Test 7: Vérifier l'appartenance au groupe GG-CreativeHub-Creative-Users
    Write-Host "`nTest 7: Appartenance au groupe Creative-Users" -ForegroundColor Yellow
    try {
        $groupMembers = Get-ADGroupMember -Identity "GG-CreativeHub-Creative-Users" -ErrorAction Stop
        $isMember = $groupMembers | Where-Object {$_.SamAccountName -eq "sophie"}

        if ($isMember) {
            Write-Host "  ✓ RÉUSSI - Sophie est membre du groupe GG-CreativeHub-Creative-Users" -ForegroundColor Green
        } else {
            Write-Host "  ✗ ÉCHOUÉ: Sophie n'est pas membre du groupe" -ForegroundColor Red
            Write-Host "    Ajoutez Sophie au groupe GG-CreativeHub-Creative-Users" -ForegroundColor Yellow
            $errors++
        }
    } catch {
        Write-Host "  ✗ ERREUR: Impossible de vérifier le groupe" -ForegroundColor Red
        Write-Host "    $($_.Exception.Message)" -ForegroundColor Yellow
        $errors++
    }
}

# Résumé final
Write-Host "`n========================================" -ForegroundColor Cyan
if ($errors -eq 0 -and $warnings -eq 0) {
    Write-Host "🎉 EXERCICE RÉUSSI ! PARFAIT !" -ForegroundColor Green
    Write-Host "Tous les critères sont satisfaits." -ForegroundColor Green
    Write-Host "`nSophie Moreau peut maintenant se connecter et accéder aux ressources Creative !" -ForegroundColor White
} elseif ($errors -eq 0 -and $warnings -gt 0) {
    Write-Host "✓ EXERCICE RÉUSSI (avec avertissements mineurs)" -ForegroundColor Green
    Write-Host "$warnings avertissement(s) détecté(s) - consultez les détails ci-dessus." -ForegroundColor Yellow
    Write-Host "Les éléments critiques sont corrects, mais certaines propriétés optionnelles manquent." -ForegroundColor Yellow
} else {
    Write-Host "❌ EXERCICE INCOMPLET" -ForegroundColor Red
    Write-Host "$errors erreur(s) critique(s) détectée(s)." -ForegroundColor Red
    Write-Host "Consultez les détails ci-dessus et corrigez les points échoués." -ForegroundColor Yellow
}
Write-Host "========================================" -ForegroundColor Cyan

# Afficher un résumé des propriétés de Sophie si elle existe
if ($user) {
    Write-Host "`nRésumé des propriétés de Sophie Moreau:" -ForegroundColor Cyan
    Write-Host "  Nom complet      : $($user.Name)" -ForegroundColor White
    Write-Host "  SAM Account      : $($user.SamAccountName)" -ForegroundColor White
    Write-Host "  Email            : $($user.EmailAddress)" -ForegroundColor White
    Write-Host "  Fonction         : $($user.Title)" -ForegroundColor White
    Write-Host "  Département      : $($user.Department)" -ForegroundColor White
    Write-Host "  Compte activé    : $userEnabled" -ForegroundColor White
    Write-Host "  Emplacement      : $($user.DistinguishedName)" -ForegroundColor Gray
}
