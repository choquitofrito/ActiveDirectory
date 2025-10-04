# Script de vérification - Exercice 5
# Exécuter ce script pour vérifier si l'exercice est correctement complété

Import-Module ActiveDirectory

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Vérification Exercice 5" -ForegroundColor Cyan
Write-Host "Réinitialisation Mot de Passe - Bastien" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$errors = 0
$warnings = 0
$userSAM = "bastien"

# Test 1: Vérifier que l'utilisateur existe
Write-Host "`nTest 1: Existence de l'utilisateur '$userSAM'" -ForegroundColor Yellow
try {
    $user = Get-ADUser -Identity $userSAM -Properties LockedOut, PasswordExpired, PasswordNeverExpires, PasswordLastSet, pwdLastSet, Description, AccountExpirationDate -ErrorAction Stop
    Write-Host "  ✓ RÉUSSI - L'utilisateur existe" -ForegroundColor Green
} catch {
    Write-Host "  ✗ ÉCHOUÉ: L'utilisateur '$userSAM' n'existe pas" -ForegroundColor Red
    $errors++
    $user = $null
}

if ($user) {
    # Test 2: Vérifier que le compte n'est pas verrouillé
    Write-Host "`nTest 2: Compte non verrouillé (LockedOut = False)" -ForegroundColor Yellow
    if ($user.LockedOut -eq $false) {
        Write-Host "  ✓ RÉUSSI - Le compte n'est pas verrouillé" -ForegroundColor Green
    } else {
        Write-Host "  ✗ ÉCHOUÉ: Le compte est toujours verrouillé" -ForegroundColor Red
        Write-Host "    Déverrouillez le compte avec: Unlock-ADAccount -Identity $userSAM" -ForegroundColor Yellow
        $errors++
    }

    # Test 3: Vérifier que le compte est activé
    Write-Host "`nTest 3: Compte activé (Enabled = True)" -ForegroundColor Yellow
    if ($user.Enabled -eq $true) {
        Write-Host "  ✓ RÉUSSI - Le compte est activé" -ForegroundColor Green
    } else {
        Write-Host "  ✗ ÉCHOUÉ: Le compte est désactivé" -ForegroundColor Red
        Write-Host "    Activez le compte via les propriétés utilisateur" -ForegroundColor Yellow
        $errors++
    }

    # Test 4: Vérifier que le mot de passe a été récemment modifié
    Write-Host "`nTest 4: Mot de passe récemment réinitialisé" -ForegroundColor Yellow
    if ($user.PasswordLastSet) {
        $timeSincePasswordSet = (Get-Date) - $user.PasswordLastSet
        Write-Host "    Dernière modification: $($user.PasswordLastSet)" -ForegroundColor Gray

        if ($timeSincePasswordSet.TotalMinutes -le 60) {
            Write-Host "  ✓ RÉUSSI - Le mot de passe a été modifié il y a $([math]::Round($timeSincePasswordSet.TotalMinutes, 0)) minutes" -ForegroundColor Green
        } elseif ($timeSincePasswordSet.TotalHours -le 24) {
            Write-Host "  ✓ ACCEPTABLE - Le mot de passe a été modifié il y a $([math]::Round($timeSincePasswordSet.TotalHours, 1)) heures" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ AVERTISSEMENT: Le mot de passe a été modifié il y a $([math]::Round($timeSincePasswordSet.TotalDays, 1)) jours" -ForegroundColor Yellow
            Write-Host "    Vérifiez si le mot de passe a bien été réinitialisé pour cet exercice" -ForegroundColor Yellow
            $warnings++
        }
    } else {
        Write-Host "  ⚠ AVERTISSEMENT: Impossible de déterminer la date de modification du mot de passe" -ForegroundColor Yellow
        $warnings++
    }

    # Test 5: Vérifier que l'utilisateur doit changer son mot de passe
    Write-Host "`nTest 5: L'utilisateur doit changer son mot de passe à la prochaine connexion" -ForegroundColor Yellow

    # pwdLastSet = 0 signifie que l'utilisateur doit changer son mot de passe
    $mustChangePassword = ($user.pwdLastSet -eq 0)

    if ($mustChangePassword) {
        Write-Host "  ✓ RÉUSSI - L'utilisateur doit changer son mot de passe" -ForegroundColor Green
        Write-Host "    pwdLastSet = 0 (indicateur de changement obligatoire)" -ForegroundColor Gray
    } else {
        Write-Host "  ✗ ÉCHOUÉ: L'utilisateur n'est pas forcé à changer son mot de passe" -ForegroundColor Red
        Write-Host "    pwdLastSet = $($user.pwdLastSet)" -ForegroundColor Yellow
        Write-Host "    Configurez avec: Set-ADUser -Identity $userSAM -ChangePasswordAtLogon `$true" -ForegroundColor Yellow
        $errors++
    }

    # Test 6: Vérifier qu'une description documentant l'incident a été ajoutée (bonus)
    Write-Host "`nTest 6 (BONUS): Documentation de l'incident dans la description" -ForegroundColor Yellow
    if ($user.Description -and $user.Description -ne "") {
        if ($user.Description -like "*INCIDENT*" -or $user.Description -like "*sécurité*" -or $user.Description -like "*compromis*" -or $user.Description -like "*réinitialisé*") {
            Write-Host "  ✓ EXCELLENT - L'incident a été documenté" -ForegroundColor Green
            Write-Host "    Description: $($user.Description)" -ForegroundColor Gray
        } else {
            Write-Host "  ℹ INFO - Une description existe mais ne mentionne pas l'incident" -ForegroundColor Cyan
            Write-Host "    Description actuelle: $($user.Description)" -ForegroundColor Gray
            Write-Host "    Bonne pratique: Documentez les incidents de sécurité" -ForegroundColor Cyan
        }
    } else {
        Write-Host "  ℹ INFO - Aucune description ajoutée" -ForegroundColor Cyan
        Write-Host "    Bonne pratique: Documentez toujours les incidents de sécurité" -ForegroundColor Cyan
        Write-Host "    Exemple: 'INCIDENT SÉCURITÉ 04/10/2025 - Compte compromis (phishing) - MDP réinitialisé'" -ForegroundColor Gray
    }

    # Test 7: Vérifier que le compte n'a pas d'expiration (sauf si configuré intentionnellement)
    Write-Host "`nTest 7: Date d'expiration du compte" -ForegroundColor Yellow
    if ($user.AccountExpirationDate) {
        Write-Host "  ℹ INFO - Le compte a une date d'expiration: $($user.AccountExpirationDate)" -ForegroundColor Cyan
        Write-Host "    Vérifiez si cela est intentionnel" -ForegroundColor Cyan
    } else {
        Write-Host "  ✓ Le compte n'a pas de date d'expiration" -ForegroundColor Green
    }
}

# Résumé final
Write-Host "`n========================================" -ForegroundColor Cyan
if ($errors -eq 0 -and $warnings -eq 0) {
    Write-Host "🎉 EXERCICE RÉUSSI ! PARFAIT !" -ForegroundColor Green
    Write-Host "Tous les critères sont satisfaits." -ForegroundColor Green
    Write-Host "`nLe compte de Bastien est sécurisé et prêt à être réutilisé." -ForegroundColor White
    Write-Host "Bastien pourra se reconnecter et devra immédiatement choisir un nouveau mot de passe." -ForegroundColor White
} elseif ($errors -eq 0 -and $warnings -gt 0) {
    Write-Host "✓ EXERCICE RÉUSSI (avec suggestions)" -ForegroundColor Green
    Write-Host "$warnings suggestion(s) d'amélioration - consultez les détails ci-dessus." -ForegroundColor Yellow
    Write-Host "Les éléments critiques sont corrects." -ForegroundColor Green
} else {
    Write-Host "❌ EXERCICE INCOMPLET" -ForegroundColor Red
    Write-Host "$errors erreur(s) critique(s) détectée(s)." -ForegroundColor Red
    Write-Host "Consultez les détails ci-dessus et corrigez les points échoués." -ForegroundColor Yellow
}
Write-Host "========================================" -ForegroundColor Cyan

# Afficher un résumé de l'état du compte
if ($user) {
    Write-Host "`nRésumé de l'état du compte de Bastien:" -ForegroundColor Cyan
    Write-Host "  Nom complet              : $($user.Name)" -ForegroundColor White
    Write-Host "  SAM Account              : $($user.SamAccountName)" -ForegroundColor White
    Write-Host "  Compte activé            : $($user.Enabled)" -ForegroundColor White
    Write-Host "  Compte verrouillé        : $($user.LockedOut)" -ForegroundColor White
    Write-Host "  Mot de passe modifié le  : $($user.PasswordLastSet)" -ForegroundColor White

    if ($user.pwdLastSet -eq 0) {
        Write-Host "  Doit changer MDP         : OUI (à la prochaine connexion)" -ForegroundColor Yellow
    } else {
        Write-Host "  Doit changer MDP         : NON" -ForegroundColor White
    }

    Write-Host "  Mot de passe n'expire pas: $($user.PasswordNeverExpires)" -ForegroundColor White
    Write-Host "  Description              : $($user.Description)" -ForegroundColor Gray
}

Write-Host "`n💡 Prochaines étapes dans un contexte réel:" -ForegroundColor Cyan
Write-Host "1. Communiquer le mot de passe temporaire à Bastien de manière SÉCURISÉE" -ForegroundColor White
Write-Host "   (Téléphone, SMS, en personne - JAMAIS par email)" -ForegroundColor Gray
Write-Host "2. Vérifier les logs de connexion pour identifier l'origine de l'attaque" -ForegroundColor White
Write-Host "3. Scanner le poste de travail de Bastien pour détecter d'éventuels malwares" -ForegroundColor White
Write-Host "4. Former Bastien à reconnaître les emails de phishing" -ForegroundColor White
Write-Host "5. Signaler l'incident au responsable de la sécurité" -ForegroundColor White

Write-Host "`n🔒 Rappel de sécurité:" -ForegroundColor Cyan
Write-Host "  - Un mot de passe fort contient : 12+ caractères, majuscules, minuscules, chiffres, symboles" -ForegroundColor Gray
Write-Host "  - Ne jamais réutiliser le même mot de passe sur plusieurs comptes" -ForegroundColor Gray
Write-Host "  - Activer l'authentification multi-facteurs (MFA) quand c'est possible" -ForegroundColor Gray
Write-Host "  - Vérifier toujours l'expéditeur avant de cliquer sur un lien dans un email" -ForegroundColor Gray

Write-Host "`n📊 Commande utile - Voir tous les comptes verrouillés:" -ForegroundColor Cyan
Write-Host "  Search-ADAccount -LockedOut | Select-Object Name, SamAccountName, LockedOut" -ForegroundColor Gray
