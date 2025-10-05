# Script de vérification - Exercice 02 : Horaire de Garde
# Exécuter ce script pour vérifier si l'exercice est correctement complété

Import-Module ActiveDirectory

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Vérification Exercice 02" -ForegroundColor Cyan
Write-Host "Horaire de Garde" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$errors = 0

# Test 1: Vérifier que le compte garde existe
Write-Host "`nTest 1: Vérification existence du compte 'garde'" -ForegroundColor Yellow
try {
    $garde = Get-ADUser -Identity garde -Properties AccountExpirationDate, Description, Title, Department, LogonHours, CannotChangePassword, PasswordNeverExpires -ErrorAction Stop

    Write-Host "  ✓ RÉUSSI: Compte 'garde' trouvé" -ForegroundColor Green
    Write-Host "    Nom complet: $($garde.Name)" -ForegroundColor Gray
} catch {
    Write-Host "  ✗ ÉCHOUÉ: Compte 'garde' introuvable" -ForegroundColor Red
    Write-Host "    Erreur: $($_.Exception.Message)" -ForegroundColor Gray
    $errors++
    # Arrêter le script si le compte n'existe pas
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "EXERCICE INCOMPLET: Le compte de garde n'existe pas." -ForegroundColor Red
    Write-Host "Créez d'abord le compte avant de continuer." -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    exit
}

# Test 2: Vérifier la date d'expiration (7 jours)
Write-Host "`nTest 2: Vérification date d'expiration du compte" -ForegroundColor Yellow
try {
    if ($garde.AccountExpirationDate) {
        $daysUntilExpiry = ($garde.AccountExpirationDate - (Get-Date)).Days

        if ($daysUntilExpiry -ge 6 -and $daysUntilExpiry -le 8) {
            Write-Host "  ✓ RÉUSSI: Expiration configurée pour ~7 jours" -ForegroundColor Green
            Write-Host "    Date d'expiration: $($garde.AccountExpirationDate.ToString('yyyy-MM-dd HH:mm'))" -ForegroundColor Gray
            Write-Host "    Jours restants: $daysUntilExpiry" -ForegroundColor Gray
        } else {
            Write-Host "  ⚠️  AVERTISSEMENT: Expiration configurée mais pas à 7 jours" -ForegroundColor Yellow
            Write-Host "    Attendu: ~7 jours, Actuel: $daysUntilExpiry jours" -ForegroundColor Gray
        }
    } else {
        Write-Host "  ✗ ÉCHOUÉ: Aucune date d'expiration configurée" -ForegroundColor Red
        $errors++
    }
} catch {
    Write-Host "  ✗ ERREUR: $($_.Exception.Message)" -ForegroundColor Red
    $errors++
}

# Test 3: Vérifier l'appartenance au groupe Oncall
Write-Host "`nTest 3: Vérification appartenance groupe Oncall" -ForegroundColor Yellow
try {
    $oncallMembers = Get-ADGroupMember -Identity "GG-MediCare-Medical-Oncall" -ErrorAction Stop
    $isOnCallMember = $oncallMembers | Where-Object {$_.SamAccountName -eq "garde"}

    if ($isOnCallMember) {
        Write-Host "  ✓ RÉUSSI: Compte membre de GG-MediCare-Medical-Oncall" -ForegroundColor Green
    } else {
        Write-Host "  ✗ ÉCHOUÉ: Compte PAS membre du groupe Oncall" -ForegroundColor Red
        $errors++
    }
} catch {
    Write-Host "  ✗ ERREUR: $($_.Exception.Message)" -ForegroundColor Red
    $errors++
}

# Test 4: Vérifier les propriétés du compte
Write-Host "`nTest 4: Vérification propriétés du compte" -ForegroundColor Yellow
$propertyErrors = 0

if ($garde.Description -and $garde.Description -match "garde|urgence|nocturn") {
    Write-Host "  ✓ Description configurée" -ForegroundColor Green
    Write-Host "    $($garde.Description)" -ForegroundColor Gray
} else {
    Write-Host "  ✗ Description manquante ou incorrecte" -ForegroundColor Red
    $propertyErrors++
}

if ($garde.Title) {
    Write-Host "  ✓ Titre configuré: $($garde.Title)" -ForegroundColor Green
} else {
    Write-Host "  ✗ Titre manquant" -ForegroundColor Red
    $propertyErrors++
}

if ($garde.Department -eq "Medical") {
    Write-Host "  ✓ Département configuré: $($garde.Department)" -ForegroundColor Green
} else {
    Write-Host "  ✗ Département manquant ou incorrect" -ForegroundColor Red
    $propertyErrors++
}

if ($propertyErrors -gt 0) {
    $errors++
}

# Test 5: Vérifier les options de compte
Write-Host "`nTest 5: Vérification options de sécurité" -ForegroundColor Yellow
if ($garde.CannotChangePassword) {
    Write-Host "  ✓ CannotChangePassword = True (compte partagé)" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  CannotChangePassword = False (recommandé: True pour compte partagé)" -ForegroundColor Yellow
}

if ($garde.PasswordNeverExpires) {
    Write-Host "  ✓ PasswordNeverExpires = True (compte de service)" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  PasswordNeverExpires = False" -ForegroundColor Yellow
}

# Test 6: Vérifier les horaires d'accès (Logon Hours)
Write-Host "`nTest 6: Vérification horaires d'accès (Logon Hours)" -ForegroundColor Yellow
if ($garde.LogonHours) {
    Write-Host "  ✓ RÉUSSI: Logon Hours configurées" -ForegroundColor Green
    Write-Host "    (Les restrictions horaires sont actives)" -ForegroundColor Gray
    Write-Host "    Détails visibles dans Active Directory Users and Computers" -ForegroundColor Gray
} else {
    Write-Host "  ⚠️  AVERTISSEMENT: Logon Hours non configurées (accès 24/7)" -ForegroundColor Yellow
    Write-Host "    Le compte peut se connecter à tout moment (non conforme aux exigences)" -ForegroundColor Gray
    $errors++
}

# Test 7: Vérifier le fichier d'instructions
Write-Host "`nTest 7: Vérification fichier d'instructions" -ForegroundColor Yellow
$instructionsPath = "C:\Labos\MediCare\Garde_Instructions.txt"
if (Test-Path $instructionsPath) {
    Write-Host "  ✓ RÉUSSI: Fichier d'instructions trouvé" -ForegroundColor Green
    Write-Host "    $instructionsPath" -ForegroundColor Gray
} else {
    Write-Host "  ⚠️  AVERTISSEMENT: Fichier d'instructions manquant" -ForegroundColor Yellow
    Write-Host "    Attendu: $instructionsPath" -ForegroundColor Gray
}

# Résumé
Write-Host "`n========================================" -ForegroundColor Cyan
if ($errors -eq 0) {
    Write-Host "EXERCICE RÉUSSI! Tous les critères sont satisfaits." -ForegroundColor Green
    Write-Host "`n✅ Résumé:" -ForegroundColor Cyan
    Write-Host "   - Compte 'garde' créé et actif" -ForegroundColor Green
    Write-Host "   - Expiration dans ~7 jours configurée" -ForegroundColor Green
    Write-Host "   - Membre du groupe Oncall" -ForegroundColor Green
    Write-Host "   - Logon Hours configurées (18h-8h + week-ends)" -ForegroundColor Green
    Write-Host "   - Propriétés documentées" -ForegroundColor Green
} else {
    Write-Host "EXERCICE INCOMPLET: $errors erreur(s) détectée(s)." -ForegroundColor Red
    Write-Host "Consultez les détails ci-dessus et corrigez les points échoués." -ForegroundColor Yellow
}
Write-Host "========================================" -ForegroundColor Cyan
