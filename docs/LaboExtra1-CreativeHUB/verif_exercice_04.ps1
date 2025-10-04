# Script de vérification - Exercice 4
# Exécuter ce script pour vérifier si l'exercice est correctement complété

Import-Module ActiveDirectory

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Vérification Exercice 4" -ForegroundColor Cyan
Write-Host "Groupe Projet SecureBank" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$errors = 0
$warnings = 0
$groupName = "GG-Projet-SecureBank"
$expectedMembers = @("karine", "nicolas", "gabrielle", "fabien", "camille")

# Test 1: Vérifier que le groupe existe
Write-Host "`nTest 1: Existence du groupe '$groupName'" -ForegroundColor Yellow
try {
    $group = Get-ADGroup -Identity $groupName -Properties Description, GroupScope, GroupCategory, DistinguishedName -ErrorAction Stop
    Write-Host "  ✓ RÉUSSI - Le groupe existe" -ForegroundColor Green
    Write-Host "    Nom          : $($group.Name)" -ForegroundColor Gray
    Write-Host "    Étendue      : $($group.GroupScope)" -ForegroundColor Gray
    Write-Host "    Type         : $($group.GroupCategory)" -ForegroundColor Gray
    Write-Host "    Emplacement  : $($group.DistinguishedName)" -ForegroundColor Gray
} catch {
    Write-Host "  ✗ ÉCHOUÉ: Le groupe '$groupName' n'existe pas" -ForegroundColor Red
    Write-Host "    Créez le groupe de sécurité via Utilisateurs et ordinateurs Active Directory" -ForegroundColor Yellow
    $errors++
    $group = $null
}

if ($group) {
    # Test 2: Vérifier que c'est un groupe de sécurité
    Write-Host "`nTest 2: Type de groupe (doit être Sécurité)" -ForegroundColor Yellow
    if ($group.GroupCategory -eq "Security") {
        Write-Host "  ✓ RÉUSSI - C'est un groupe de sécurité" -ForegroundColor Green
    } else {
        Write-Host "  ✗ ÉCHOUÉ: Le groupe est de type $($group.GroupCategory)" -ForegroundColor Red
        Write-Host "    Le groupe doit être de type 'Sécurité', pas 'Distribution'" -ForegroundColor Yellow
        $errors++
    }

    # Test 3: Vérifier l'étendue du groupe
    Write-Host "`nTest 3: Étendue du groupe (DomainLocal recommandé)" -ForegroundColor Yellow
    if ($group.GroupScope -eq "DomainLocal") {
        Write-Host "  ✓ EXCELLENT - Étendue DomainLocal (choix optimal)" -ForegroundColor Green
        Write-Host "    Parfait pour gérer des permissions sur des ressources locales du domaine" -ForegroundColor Gray
    } elseif ($group.GroupScope -eq "Global") {
        Write-Host "  ✓ ACCEPTABLE - Étendue Global" -ForegroundColor Green
        Write-Host "    ⚠ Note: DomainLocal serait plus approprié pour gérer des permissions sur des ressources" -ForegroundColor Yellow
        $warnings++
    } elseif ($group.GroupScope -eq "Universal") {
        Write-Host "  ⚠ AVERTISSEMENT - Étendue Universal" -ForegroundColor Yellow
        Write-Host "    Universal est utile pour les environnements multi-domaines" -ForegroundColor Yellow
        Write-Host "    Pour un domaine unique, DomainLocal ou Global est préférable" -ForegroundColor Yellow
        $warnings++
    } else {
        Write-Host "  ✗ ÉCHOUÉ: Étendue inconnue: $($group.GroupScope)" -ForegroundColor Red
        $errors++
    }

    # Test 4: Vérifier qu'une description existe
    Write-Host "`nTest 4: Description du groupe" -ForegroundColor Yellow
    if ($group.Description -and $group.Description -ne "") {
        Write-Host "  ✓ RÉUSSI - Description présente" -ForegroundColor Green
        Write-Host "    Description: $($group.Description)" -ForegroundColor Gray
    } else {
        Write-Host "  ⚠ AVERTISSEMENT: Aucune description" -ForegroundColor Yellow
        Write-Host "    Bonne pratique: Toujours documenter le but d'un groupe" -ForegroundColor Yellow
        $warnings++
    }

    # Test 5: Vérifier que le groupe n'est pas dans les conteneurs par défaut
    Write-Host "`nTest 5: Emplacement du groupe (OU appropriée)" -ForegroundColor Yellow
    if ($group.DistinguishedName -like "*OU=*") {
        if ($group.DistinguishedName -notlike "CN=Users,DC=*" -and $group.DistinguishedName -notlike "CN=Computers,DC=*") {
            Write-Host "  ✓ RÉUSSI - Le groupe est dans une OU personnalisée" -ForegroundColor Green
            Write-Host "    Emplacement: $($group.DistinguishedName)" -ForegroundColor Gray
        } else {
            Write-Host "  ⚠ AVERTISSEMENT: Le groupe est dans un conteneur par défaut" -ForegroundColor Yellow
            $warnings++
        }
    } else {
        Write-Host "  ⚠ AVERTISSEMENT: Le groupe n'est pas dans une OU" -ForegroundColor Yellow
        Write-Host "    Bonne pratique: Organiser les groupes dans des OUs" -ForegroundColor Yellow
        $warnings++
    }

    # Test 6: Vérifier le nombre de membres
    Write-Host "`nTest 6: Nombre de membres (doit être exactement 5)" -ForegroundColor Yellow
    try {
        $members = Get-ADGroupMember -Identity $groupName -ErrorAction Stop
        $memberCount = $members.Count

        if ($memberCount -eq 5) {
            Write-Host "  ✓ RÉUSSI - Le groupe contient exactement 5 membres" -ForegroundColor Green
        } elseif ($memberCount -lt 5) {
            Write-Host "  ✗ ÉCHOUÉ: Le groupe contient seulement $memberCount membre(s)" -ForegroundColor Red
            Write-Host "    Il devrait contenir 5 membres" -ForegroundColor Yellow
            $errors++
        } else {
            Write-Host "  ✗ ÉCHOUÉ: Le groupe contient $memberCount membres (trop)" -ForegroundColor Red
            Write-Host "    Il devrait contenir exactement 5 membres" -ForegroundColor Yellow
            $errors++
        }
    } catch {
        Write-Host "  ✗ ERREUR: Impossible de lire les membres du groupe" -ForegroundColor Red
        $errors++
        $members = @()
    }

    # Test 7: Vérifier que les bons membres sont présents
    Write-Host "`nTest 7: Vérification des membres attendus" -ForegroundColor Yellow

    $actualMembers = $members | Select-Object -ExpandProperty SamAccountName | Sort-Object
    $missingMembers = @()
    $extraMembers = @()

    Write-Host "  Membres attendus:" -ForegroundColor Gray
    foreach ($expectedMember in $expectedMembers | Sort-Object) {
        if ($actualMembers -contains $expectedMember) {
            Write-Host "    ✓ $expectedMember (présent)" -ForegroundColor Green
        } else {
            Write-Host "    ✗ $expectedMember (MANQUANT)" -ForegroundColor Red
            $missingMembers += $expectedMember
        }
    }

    # Vérifier s'il y a des membres en trop
    foreach ($actualMember in $actualMembers) {
        if ($expectedMembers -notcontains $actualMember) {
            $extraMembers += $actualMember
        }
    }

    if ($missingMembers.Count -eq 0 -and $extraMembers.Count -eq 0) {
        Write-Host "  ✓ RÉUSSI - Tous les membres corrects sont présents, sans membres supplémentaires" -ForegroundColor Green
    } else {
        if ($missingMembers.Count -gt 0) {
            Write-Host "  ✗ ÉCHOUÉ: Membres manquants: $($missingMembers -join ', ')" -ForegroundColor Red
            $errors++
        }
        if ($extraMembers.Count -gt 0) {
            Write-Host "  ⚠ AVERTISSEMENT: Membres en trop: $($extraMembers -join ', ')" -ForegroundColor Yellow
            $warnings++
        }
    }
}

# Résumé final
Write-Host "`n========================================" -ForegroundColor Cyan
if ($errors -eq 0 -and $warnings -eq 0) {
    Write-Host "🎉 EXERCICE RÉUSSI ! PARFAIT !" -ForegroundColor Green
    Write-Host "Tous les critères sont satisfaits." -ForegroundColor Green
    Write-Host "`nLe groupe SecureBank est prêt à être utilisé pour gérer les permissions du projet !" -ForegroundColor White
} elseif ($errors -eq 0 -and $warnings -gt 0) {
    Write-Host "✓ EXERCICE RÉUSSI (avec suggestions d'amélioration)" -ForegroundColor Green
    Write-Host "$warnings suggestion(s) détectée(s) - consultez les détails ci-dessus." -ForegroundColor Yellow
    Write-Host "Les éléments essentiels sont corrects." -ForegroundColor Green
} else {
    Write-Host "❌ EXERCICE INCOMPLET" -ForegroundColor Red
    Write-Host "$errors erreur(s) critique(s) détectée(s)." -ForegroundColor Red
    Write-Host "Consultez les détails ci-dessus et corrigez les points échoués." -ForegroundColor Yellow
}
Write-Host "========================================" -ForegroundColor Cyan

# Afficher le récapitulatif du groupe
if ($group) {
    Write-Host "`nRécapitulatif du groupe SecureBank:" -ForegroundColor Cyan
    Write-Host "  Nom              : $($group.Name)" -ForegroundColor White
    Write-Host "  Type             : $($group.GroupCategory)" -ForegroundColor White
    Write-Host "  Étendue          : $($group.GroupScope)" -ForegroundColor White
    Write-Host "  Description      : $($group.Description)" -ForegroundColor White
    Write-Host "  Nombre de membres: $($members.Count)" -ForegroundColor White
    Write-Host "  Emplacement      : $($group.DistinguishedName)" -ForegroundColor Gray

    if ($members.Count -gt 0) {
        Write-Host "`n  Membres actuels:" -ForegroundColor Cyan
        foreach ($member in ($members | Sort-Object Name)) {
            $userDetails = Get-ADUser -Identity $member.SamAccountName -Properties Department, Title
            Write-Host "    - $($member.Name) ($($member.SamAccountName)) - $($userDetails.Title), $($userDetails.Department)" -ForegroundColor White
        }
    }
}

Write-Host "`n💡 Prochaine étape:" -ForegroundColor Cyan
Write-Host "Ce groupe peut maintenant être utilisé pour:" -ForegroundColor White
Write-Host "  - Attribuer des permissions NTFS sur le dossier \\Serveur\Projets\SecureBank" -ForegroundColor Gray
Write-Host "  - Créer des restrictions d'accès via GPO" -ForegroundColor Gray
Write-Host "  - Gérer l'accès à des applications spécifiques au projet" -ForegroundColor Gray

Write-Host "`n📚 Rappel - Stratégie AGDLP (Bonnes Pratiques):" -ForegroundColor Cyan
Write-Host "  A (Accounts)       → Comptes utilisateurs" -ForegroundColor Gray
Write-Host "  G (Global Groups)  → Regrouper les utilisateurs par département/fonction" -ForegroundColor Gray
Write-Host "  DL (Domain Local)  → Groupes pour gérer les permissions sur ressources" -ForegroundColor Gray
Write-Host "  P (Permissions)    → Attribuer les droits aux groupes Domain Local" -ForegroundColor Gray
