# Script de vérification - Exercice 2
# Exécuter ce script pour vérifier si l'exercice est correctement complété

Import-Module ActiveDirectory

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Vérification Exercice 2" -ForegroundColor Cyan
Write-Host "Gestion du départ de Manon Girard" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$errors = 0
$warnings = 0

# Test 1: Vérifier que l'utilisateur manon existe toujours
Write-Host "`nTest 1: Le compte 'manon' existe (non supprimé)" -ForegroundColor Yellow
try {
    $user = Get-ADUser -Identity manon -Properties Enabled, Description, DistinguishedName -ErrorAction Stop
    Write-Host "  ✓ RÉUSSI - Le compte existe toujours (bonne pratique)" -ForegroundColor Green
} catch {
    Write-Host "  ✗ ÉCHOUÉ: Le compte 'manon' a été supprimé" -ForegroundColor Red
    Write-Host "    ERREUR CRITIQUE: Ne jamais supprimer un compte utilisateur !" -ForegroundColor Red
    Write-Host "    Les comptes doivent être désactivés pour préserver l'historique." -ForegroundColor Yellow
    $errors++
    $user = $null
}

if ($user) {
    # Test 2: Vérifier que le compte est désactivé
    Write-Host "`nTest 2: Le compte est désactivé (Enabled = False)" -ForegroundColor Yellow
    if ($user.Enabled -eq $false) {
        Write-Host "  ✓ RÉUSSI - Le compte est désactivé" -ForegroundColor Green
    } else {
        Write-Host "  ✗ ÉCHOUÉ: Le compte est toujours activé" -ForegroundColor Red
        Write-Host "    Désactivez le compte via Clic droit > Désactiver le compte" -ForegroundColor Yellow
        $errors++
    }

    # Test 3: Vérifier qu'une description a été ajoutée
    Write-Host "`nTest 3: Description documentant le départ" -ForegroundColor Yellow
    if ($user.Description -and $user.Description -ne "") {
        Write-Host "  ✓ RÉUSSI - Description présente" -ForegroundColor Green
        Write-Host "    Description: $($user.Description)" -ForegroundColor Gray
    } else {
        Write-Host "  ⚠ AVERTISSEMENT: Aucune description n'a été ajoutée" -ForegroundColor Yellow
        Write-Host "    Bonne pratique: Documentez toujours la raison et la date de désactivation" -ForegroundColor Yellow
        $warnings++
    }

    # Test 4: Vérifier que Manon n'est plus membre du groupe ClientServices-Users
    Write-Host "`nTest 4: Retrait du groupe ClientServices-Users" -ForegroundColor Yellow
    try {
        $groupMembers = Get-ADGroupMember -Identity "GG-CreativeHub-ClientServices-Users" -ErrorAction Stop
        $isMember = $groupMembers | Where-Object {$_.SamAccountName -eq "manon"}

        if (-not $isMember) {
            Write-Host "  ✓ RÉUSSI - Manon n'est plus membre du groupe ClientServices-Users" -ForegroundColor Green
        } else {
            Write-Host "  ✗ ÉCHOUÉ: Manon est toujours membre du groupe" -ForegroundColor Red
            Write-Host "    Retirez Manon du groupe GG-CreativeHub-ClientServices-Users" -ForegroundColor Yellow
            $errors++
        }
    } catch {
        Write-Host "  ✗ ERREUR: Impossible de vérifier le groupe" -ForegroundColor Red
        Write-Host "    $($_.Exception.Message)" -ForegroundColor Yellow
        $errors++
    }

    # Test 5: Vérifier les appartenances aux groupes (doit être minimal)
    Write-Host "`nTest 5: Appartenances aux groupes minimales" -ForegroundColor Yellow
    try {
        $groups = Get-ADPrincipalGroupMembership -Identity manon -ErrorAction Stop
        $groupCount = $groups.Count

        Write-Host "    Groupes actuels: $($groups.Name -join ', ')" -ForegroundColor Gray

        if ($groupCount -eq 1 -and $groups.Name -eq "Domain Users") {
            Write-Host "  ✓ RÉUSSI - Manon n'appartient qu'au groupe Domain Users (obligatoire)" -ForegroundColor Green
        } elseif ($groupCount -le 2) {
            Write-Host "  ⚠ AVERTISSEMENT: Manon appartient à $groupCount groupe(s)" -ForegroundColor Yellow
            Write-Host "    Groupes: $($groups.Name -join ', ')" -ForegroundColor Yellow
            Write-Host "    Recommandation: Retirez tous les groupes sauf Domain Users" -ForegroundColor Yellow
            $warnings++
        } else {
            Write-Host "  ✗ ÉCHOUÉ: Manon appartient encore à trop de groupes ($groupCount)" -ForegroundColor Red
            Write-Host "    Groupes: $($groups.Name -join ', ')" -ForegroundColor Yellow
            Write-Host "    Retirez Manon de tous les groupes de sécurité" -ForegroundColor Yellow
            $errors++
        }
    } catch {
        Write-Host "  ✗ ERREUR: Impossible de vérifier les appartenances" -ForegroundColor Red
        $errors++
    }

    # Test 6 (Bonus): Vérifier si le compte a été déplacé vers une OU Comptes_Desactives
    Write-Host "`nTest 6 (BONUS): Déplacement vers OU Comptes_Desactives" -ForegroundColor Yellow
    if ($user.DistinguishedName -like "*OU=Comptes_Desactives*") {
        Write-Host "  ✓ EXCELLENT - Le compte a été déplacé vers l'OU Comptes_Desactives" -ForegroundColor Green
        Write-Host "    Emplacement: $($user.DistinguishedName)" -ForegroundColor Gray
        Write-Host "    Cela facilite la gestion des comptes inactifs !" -ForegroundColor Green
    } else {
        Write-Host "  ℹ INFO - Le compte est toujours dans l'OU Users" -ForegroundColor Cyan
        Write-Host "    Emplacement: $($user.DistinguishedName)" -ForegroundColor Gray
        Write-Host "    Bonne pratique: Créez une OU 'Comptes_Desactives' et déplacez-y les comptes inactifs" -ForegroundColor Cyan
    }
}

# Résumé final
Write-Host "`n========================================" -ForegroundColor Cyan
if ($errors -eq 0 -and $warnings -eq 0) {
    Write-Host "🎉 EXERCICE RÉUSSI ! PARFAIT !" -ForegroundColor Green
    Write-Host "Tous les critères sont satisfaits." -ForegroundColor Green
    Write-Host "`nManon Girard ne peut plus se connecter et ses accès ont été révoqués." -ForegroundColor White
    Write-Host "L'historique de son compte est préservé pour les audits." -ForegroundColor White
} elseif ($errors -eq 0 -and $warnings -gt 0) {
    Write-Host "✓ EXERCICE RÉUSSI (avec suggestions d'amélioration)" -ForegroundColor Green
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
    Write-Host "`nRésumé de l'état du compte Manon Girard:" -ForegroundColor Cyan
    Write-Host "  Nom complet      : $($user.Name)" -ForegroundColor White
    Write-Host "  SAM Account      : $($user.SamAccountName)" -ForegroundColor White
    Write-Host "  Compte activé    : $($user.Enabled)" -ForegroundColor White
    Write-Host "  Description      : $($user.Description)" -ForegroundColor White
    Write-Host "  Emplacement      : $($user.DistinguishedName)" -ForegroundColor Gray

    try {
        $groups = Get-ADPrincipalGroupMembership -Identity manon
        Write-Host "  Groupes          : $($groups.Name -join ', ')" -ForegroundColor White
    } catch {
        Write-Host "  Groupes          : Erreur de lecture" -ForegroundColor Red
    }
}

Write-Host "`n💡 Point de réflexion:" -ForegroundColor Cyan
Write-Host "Pourquoi désactiver plutôt que supprimer ?" -ForegroundColor White
Write-Host "  - Préserve l'historique des activités (logs, fichiers créés)" -ForegroundColor Gray
Write-Host "  - Permet la réactivation si l'employé revient" -ForegroundColor Gray
Write-Host "  - Nécessaire pour les audits de conformité" -ForegroundColor Gray
Write-Host "  - Évite les problèmes de permissions sur les fichiers orphelins" -ForegroundColor Gray
