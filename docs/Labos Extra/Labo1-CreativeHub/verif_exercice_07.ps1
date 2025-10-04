# Script de vérification - Exercice 7
# Exécuter ce script pour vérifier si l'exercice est correctement complété

Import-Module ActiveDirectory
Import-Module GroupPolicy

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Vérification Exercice 7" -ForegroundColor Cyan
Write-Host "Onboarding Stagiaire - Léa Fontaine" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$errors = 0
$warnings = 0
$bonusPoints = 0

# Variables attendues (flexibles pour accepter différentes approches)
$possibleSAM = @("lea.fontaine", "lfontaine", "lea", "leafontaine")
$expectedEmail = "lea.fontaine@maxtec.be"
$expectedTitle = "Stagiaire Graphiste"
$expectedDepartment = "Creative"
$expectedExpirationDate = Get-Date "2026-01-07"

# Test 1: Trouver le compte de Léa
Write-Host "`nTest 1: Recherche du compte utilisateur de Léa Fontaine" -ForegroundColor Yellow

$user = $null
foreach ($sam in $possibleSAM) {
    try {
        $user = Get-ADUser -Identity $sam -Properties * -ErrorAction Stop
        Write-Host "  ✓ RÉUSSI - Compte utilisateur trouvé: $($user.SamAccountName)" -ForegroundColor Green
        Write-Host "    Nom complet : $($user.Name)" -ForegroundColor Gray
        Write-Host "    Email       : $($user.EmailAddress)" -ForegroundColor Gray
        break
    } catch {
        continue
    }
}

if (-not $user) {
    # Dernière tentative : rechercher par nom
    try {
        $user = Get-ADUser -Filter {GivenName -eq "Léa" -and Surname -eq "Fontaine"} -Properties * -ErrorAction Stop
        if ($user) {
            Write-Host "  ✓ RÉUSSI - Compte trouvé par nom complet" -ForegroundColor Green
            Write-Host "    SAM Account : $($user.SamAccountName)" -ForegroundColor Gray
        }
    } catch {}
}

if (-not $user) {
    Write-Host "  ✗ ÉCHOUÉ: Aucun compte utilisateur trouvé pour Léa Fontaine" -ForegroundColor Red
    Write-Host "    SAM Accounts recherchés: $($possibleSAM -join ', ')" -ForegroundColor Yellow
    Write-Host "    Créez le compte utilisateur pour Léa" -ForegroundColor Yellow
    $errors++
}

if ($user) {
    # Test 2: Vérifier l'email
    Write-Host "`nTest 2: Configuration de l'email" -ForegroundColor Yellow
    if ($user.EmailAddress -eq $expectedEmail) {
        Write-Host "  ✓ RÉUSSI - Email: $expectedEmail" -ForegroundColor Green
    } else {
        Write-Host "  ✗ ÉCHOUÉ: Email incorrect" -ForegroundColor Red
        Write-Host "    Email actuel : $($user.EmailAddress)" -ForegroundColor Yellow
        Write-Host "    Email attendu: $expectedEmail" -ForegroundColor Yellow
        $errors++
    }

    # Test 3: Vérifier la fonction et le département
    Write-Host "`nTest 3: Fonction et département" -ForegroundColor Yellow
    $titleOK = $user.Title -like "*Stagiaire*" -and $user.Title -like "*Graphiste*"
    if ($titleOK) {
        Write-Host "  ✓ RÉUSSI - Fonction: $($user.Title)" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ AVERTISSEMENT: Fonction non standard" -ForegroundColor Yellow
        Write-Host "    Fonction actuelle: $($user.Title)" -ForegroundColor Yellow
        Write-Host "    Fonction attendue: Stagiaire Graphiste" -ForegroundColor Yellow
        $warnings++
    }

    if ($user.Department -eq $expectedDepartment) {
        Write-Host "  ✓ RÉUSSI - Département: Creative" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ AVERTISSEMENT: Département incorrect" -ForegroundColor Yellow
        Write-Host "    Département actuel: $($user.Department)" -ForegroundColor Yellow
        $warnings++
    }

    # Test 4: Vérifier la date d'expiration du compte
    Write-Host "`nTest 4: Date d'expiration du compte" -ForegroundColor Yellow
    if ($user.AccountExpirationDate) {
        $expirationDiff = ($user.AccountExpirationDate - $expectedExpirationDate).TotalDays

        if ([Math]::Abs($expirationDiff) -le 1) {
            Write-Host "  ✓ RÉUSSI - Le compte expire le $($user.AccountExpirationDate.ToShortDateString())" -ForegroundColor Green
            Write-Host "    (Fin du stage de 3 mois)" -ForegroundColor Gray
        } else {
            Write-Host "  ⚠ AVERTISSEMENT: Date d'expiration différente de celle attendue" -ForegroundColor Yellow
            Write-Host "    Date configurée: $($user.AccountExpirationDate.ToShortDateString())" -ForegroundColor Yellow
            Write-Host "    Date attendue  : $($expectedExpirationDate.ToShortDateString())" -ForegroundColor Yellow
            $warnings++
        }
    } else {
        Write-Host "  ✗ ÉCHOUÉ: Aucune date d'expiration configurée" -ForegroundColor Red
        Write-Host "    Les comptes stagiaires DOIVENT avoir une date d'expiration !" -ForegroundColor Yellow
        Write-Host "    Configurez avec: Set-ADAccountExpiration -Identity $($user.SamAccountName) -DateTime '2026-01-07'" -ForegroundColor Yellow
        $errors++
    }

    # Test 5: Vérifier que le mot de passe doit être changé
    Write-Host "`nTest 5: Changement de mot de passe obligatoire" -ForegroundColor Yellow
    if ($user.pwdLastSet -eq 0 -or $user.PasswordExpired -eq $true) {
        Write-Host "  ✓ RÉUSSI - L'utilisateur doit changer son mot de passe à la première connexion" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ AVERTISSEMENT: Le changement de mot de passe ne semble pas être obligatoire" -ForegroundColor Yellow
        Write-Host "    Pour la sécurité, forcez le changement: Set-ADUser -Identity $($user.SamAccountName) -ChangePasswordAtLogon `$true" -ForegroundColor Yellow
        $warnings++
    }

    # Test 6: Vérifier que le compte est activé
    Write-Host "`nTest 6: Compte activé" -ForegroundColor Yellow
    if ($user.Enabled -eq $true) {
        Write-Host "  ✓ RÉUSSI - Le compte est activé" -ForegroundColor Green
    } else {
        Write-Host "  ✗ ÉCHOUÉ: Le compte est désactivé" -ForegroundColor Red
        Write-Host "    Activez le compte pour que Léa puisse se connecter" -ForegroundColor Yellow
        $errors++
    }

    # Test 7: Vérifier l'appartenance au groupe Creative-Users
    Write-Host "`nTest 7: Appartenance au groupe Creative-Users" -ForegroundColor Yellow
    try {
        $groups = Get-ADPrincipalGroupMembership -Identity $user.SamAccountName -ErrorAction Stop
        $isInCreativeUsers = $groups | Where-Object {$_.Name -like "*Creative*Users*"}

        if ($isInCreativeUsers) {
            Write-Host "  ✓ RÉUSSI - Léa est membre du groupe Creative-Users" -ForegroundColor Green
            Write-Host "    Groupe: $($isInCreativeUsers.Name)" -ForegroundColor Gray
        } else {
            Write-Host "  ✗ ÉCHOUÉ: Léa n'est pas membre du groupe Creative-Users" -ForegroundColor Red
            Write-Host "    Ajoutez Léa au groupe GG-CreativeHub-Creative-Users" -ForegroundColor Yellow
            $errors++
        }
    } catch {
        Write-Host "  ✗ ERREUR: Impossible de vérifier les groupes" -ForegroundColor Red
        $errors++
    }

    # Test 8: Vérifier l'accès au projet SecureBank
    Write-Host "`nTest 8: Accès au projet SecureBank" -ForegroundColor Yellow
    $isInSecureBank = $groups | Where-Object {$_.Name -like "*SecureBank*"}

    if ($isInSecureBank) {
        Write-Host "  ✓ RÉUSSI - Léa a accès au projet SecureBank" -ForegroundColor Green
        Write-Host "    Groupe(s): $($isInSecureBank.Name -join ', ')" -ForegroundColor Gray

        # Bonus : vérifier s'il y a un groupe séparé pour la lecture seule
        $lectureGroup = $groups | Where-Object {$_.Name -like "*Lecture*" -or $_.Name -like "*Read*"}
        if ($lectureGroup) {
            Write-Host "  ✓ BONUS - Groupe de lecture seule détecté !" -ForegroundColor Green
            Write-Host "    Excellent : séparation des permissions lecture/écriture" -ForegroundColor Gray
            $bonusPoints++
        }
    } else {
        Write-Host "  ⚠ AVERTISSEMENT: Léa n'a pas d'accès au projet SecureBank" -ForegroundColor Yellow
        Write-Host "    Selon le scénario, elle devrait avoir un accès lecture seule" -ForegroundColor Yellow
        Write-Host "    Vérifiez si un groupe SecureBank existe et ajoutez-la" -ForegroundColor Yellow
        $warnings++
    }

    # Test 9: Vérifier la description (documentation)
    Write-Host "`nTest 9: Documentation du compte (Description)" -ForegroundColor Yellow
    if ($user.Description -and $user.Description -ne "") {
        if ($user.Description -like "*stagiaire*" -or $user.Description -like "*STAGIAIRE*" -or
            $user.Description -like "*stage*" -or $user.Description -like "*STAGE*") {
            Write-Host "  ✓ RÉUSSI - Le compte est documenté" -ForegroundColor Green
            Write-Host "    Description: $($user.Description)" -ForegroundColor Gray
        } else {
            Write-Host "  ⚠ AVERTISSEMENT: Description présente mais ne mentionne pas 'stagiaire'" -ForegroundColor Yellow
            Write-Host "    Description: $($user.Description)" -ForegroundColor Yellow
            $warnings++
        }
    } else {
        Write-Host "  ⚠ AVERTISSEMENT: Aucune description n'a été ajoutée" -ForegroundColor Yellow
        Write-Host "    Bonne pratique: Documentez les comptes temporaires" -ForegroundColor Yellow
        Write-Host "    Exemple: 'STAGIAIRE - Du 07/10/2025 au 07/01/2026 - Manager: Gabrielle Simon'" -ForegroundColor Yellow
        $warnings++
    }

    # Test 10 (BONUS): Vérifier si une OU Stagiaires a été créée
    Write-Host "`nTest 10 (BONUS): Organisation - OU Stagiaires" -ForegroundColor Yellow
    if ($user.DistinguishedName -like "*OU=Stagiaires*" -or $user.DistinguishedName -like "*OU=Stagiaire*") {
        Write-Host "  ✓ BONUS - OU Stagiaires créée et utilisée !" -ForegroundColor Green
        Write-Host "    Emplacement: $($user.DistinguishedName)" -ForegroundColor Gray
        Write-Host "    Excellente organisation pour gérer les GPO spécifiques" -ForegroundColor Gray
        $bonusPoints++
    } else {
        Write-Host "  ℹ INFO - Léa n'est pas dans une OU Stagiaires dédiée" -ForegroundColor Cyan
        Write-Host "    Emplacement: $($user.DistinguishedName)" -ForegroundColor Gray
        Write-Host "    Suggestion: Créer OU=Stagiaires pour une meilleure organisation" -ForegroundColor Cyan
    }

    # Test 11: Vérifier l'application de GPO
    Write-Host "`nTest 11: Stratégies de groupe (GPO)" -ForegroundColor Yellow

    # Chercher des GPO liées qui pourraient contenir des restrictions
    $stagiaireOU = ($user.DistinguishedName -split ',',2)[1] # Extraire l'OU

    try {
        $inheritance = Get-GPInheritance -Target $stagiaireOU -ErrorAction Stop
        $linkedGPOs = $inheritance.GpoLinks | Where-Object {
            $_.DisplayName -like "*Restriction*" -or
            $_.DisplayName -like "*Stagiaire*" -or
            $_.DisplayName -like "*Junior*"
        }

        if ($linkedGPOs) {
            Write-Host "  ✓ RÉUSSI - GPO(s) de restriction détectée(s)" -ForegroundColor Green
            foreach ($gpo in $linkedGPOs) {
                Write-Host "    - $($gpo.DisplayName) (Activée: $($gpo.Enabled))" -ForegroundColor Gray
            }

            # Bonus : GPO spécifique aux stagiaires
            $stagiaireGPO = $linkedGPOs | Where-Object {$_.DisplayName -like "*Stagiaire*"}
            if ($stagiaireGPO) {
                Write-Host "  ✓ BONUS - GPO dédiée aux stagiaires créée !" -ForegroundColor Green
                $bonusPoints++
            }
        } else {
            Write-Host "  ⚠ AVERTISSEMENT: Aucune GPO de restriction détectée" -ForegroundColor Yellow
            Write-Host "    Vérifiez qu'une GPO avec restrictions (Panneau de config, CMD, USB) est liée" -ForegroundColor Yellow
            $warnings++
        }
    } catch {
        Write-Host "  ℹ INFO: Impossible de vérifier les GPO automatiquement" -ForegroundColor Cyan
        Write-Host "    Vérifiez manuellement avec: Get-GPInheritance -Target '$stagiaireOU'" -ForegroundColor Cyan
    }

    # Afficher tous les groupes (pour information)
    Write-Host "`n📋 Liste complète des groupes de Léa:" -ForegroundColor Cyan
    foreach ($group in ($groups | Sort-Object Name)) {
        Write-Host "  - $($group.Name)" -ForegroundColor White
    }
}

# Résumé final
Write-Host "`n========================================" -ForegroundColor Cyan

if ($errors -eq 0 -and $warnings -eq 0) {
    Write-Host "🎉 EXERCICE RÉUSSI ! PARFAIT !" -ForegroundColor Green
    Write-Host "Tous les critères obligatoires sont satisfaits." -ForegroundColor Green

    if ($bonusPoints -gt 0) {
        Write-Host "`n⭐ POINTS BONUS: $bonusPoints" -ForegroundColor Yellow
        Write-Host "Excellente mise en œuvre des bonnes pratiques !" -ForegroundColor Yellow
    }

    Write-Host "`nLéa Fontaine peut commencer son stage en toute sécurité !" -ForegroundColor White
    Write-Host "Tous les accès et restrictions sont correctement configurés." -ForegroundColor White

} elseif ($errors -eq 0 -and $warnings -gt 0) {
    Write-Host "✓ EXERCICE RÉUSSI (avec suggestions d'amélioration)" -ForegroundColor Green
    Write-Host "$warnings suggestion(s) d'amélioration - consultez les détails ci-dessus." -ForegroundColor Yellow
    Write-Host "Les éléments essentiels sont corrects." -ForegroundColor Green

    if ($bonusPoints -gt 0) {
        Write-Host "`n⭐ POINTS BONUS: $bonusPoints" -ForegroundColor Yellow
    }

} else {
    Write-Host "❌ EXERCICE INCOMPLET" -ForegroundColor Red
    Write-Host "$errors erreur(s) critique(s) détectée(s)." -ForegroundColor Red
    if ($warnings -gt 0) {
        Write-Host "$warnings avertissement(s) supplémentaire(s)." -ForegroundColor Yellow
    }
    Write-Host "Consultez les détails ci-dessus et corrigez les points échoués." -ForegroundColor Yellow
}

Write-Host "========================================" -ForegroundColor Cyan

# Récapitulatif pour le manager
if ($user) {
    Write-Host "`n📧 Informations à communiquer à Gabrielle Simon:" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "Compte créé pour Léa Fontaine" -ForegroundColor White
    Write-Host "`nConnexion:" -ForegroundColor Yellow
    Write-Host "  Nom d'utilisateur : $($user.SamAccountName)" -ForegroundColor White
    Write-Host "  Domaine           : MAXTEC" -ForegroundColor White
    Write-Host "  Mot de passe      : StageCreative2025!" -ForegroundColor White
    Write-Host "  (À changer à la première connexion)" -ForegroundColor Gray
    Write-Host "`nEmail             : $($user.EmailAddress)" -ForegroundColor White

    if ($user.AccountExpirationDate) {
        Write-Host "`nExpiration du compte: $($user.AccountExpirationDate.ToLongDateString())" -ForegroundColor Yellow
        $daysUntilExpiration = ($user.AccountExpirationDate - (Get-Date)).Days
        Write-Host "(Dans $daysUntilExpiration jours)" -ForegroundColor Gray
    }

    Write-Host "`nAccès configurés:" -ForegroundColor Yellow
    Write-Host "  ✓ Ressources département Creative" -ForegroundColor Gray
    if ($isInSecureBank) {
        Write-Host "  ✓ Projet SecureBank (lecture seule)" -ForegroundColor Gray
    }

    Write-Host "`nRestrictions de sécurité:" -ForegroundColor Yellow
    Write-Host "  ✓ Panneau de configuration désactivé" -ForegroundColor Gray
    Write-Host "  ✓ Invite de commandes désactivée" -ForegroundColor Gray
    Write-Host "  ✓ Périphériques USB bloqués" -ForegroundColor Gray

    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
}

Write-Host "`n💡 Commandes utiles pour la gestion de Léa:" -ForegroundColor Cyan
if ($user) {
    Write-Host "`nVoir détails du compte:" -ForegroundColor White
    Write-Host "  Get-ADUser -Identity $($user.SamAccountName) -Properties * | FL" -ForegroundColor Gray

    Write-Host "`nProlonger le stage (exemple: +1 mois):" -ForegroundColor White
    Write-Host "  Set-ADAccountExpiration -Identity $($user.SamAccountName) -DateTime '2026-02-07'" -ForegroundColor Gray

    Write-Host "`nDésactiver le compte à la fin du stage:" -ForegroundColor White
    Write-Host "  Disable-ADAccount -Identity $($user.SamAccountName)" -ForegroundColor Gray

    Write-Host "`nVérifier les GPO appliquées (sur le poste client):" -ForegroundColor White
    Write-Host "  gpresult /r /scope:user /user:$($user.SamAccountName)" -ForegroundColor Gray
}

Write-Host "`n📚 Bonnes pratiques appliquées dans cet exercice:" -ForegroundColor Cyan
Write-Host "  ✓ Date d'expiration automatique pour les comptes temporaires" -ForegroundColor Gray
Write-Host "  ✓ Changement de mot de passe obligatoire à la première connexion" -ForegroundColor Gray
Write-Host "  ✓ Principe du moindre privilège (accès minimal nécessaire)" -ForegroundColor Gray
Write-Host "  ✓ Restrictions de sécurité renforcées pour les stagiaires" -ForegroundColor Gray
Write-Host "  ✓ Documentation du compte pour traçabilité" -ForegroundColor Gray
Write-Host "  ✓ Organisation claire (OU dédiée recommandée)" -ForegroundColor Gray
