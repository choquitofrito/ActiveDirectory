# Script de vérification - Exercice 9
# Exécuter ce script pour vérifier si l'exercice est correctement complété

Import-Module ActiveDirectory

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Vérification Exercice 9" -ForegroundColor Cyan
Write-Host "Gestion de Crise - Incident de Sécurité" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$errors = 0
$warnings = 0
$containmentScore = 0
$investigationScore = 0
$remediationScore = 0

$maliciousAccount = "support.temp"
$compromisedAccount = "olivier"

Write-Host "`n🔍 Analyse de l'état actuel du domaine..." -ForegroundColor Yellow

# PHASE 1: VÉRIFICATION DU CONTAINMENT
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "PHASE 1: CONTAINMENT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Test 1: Le compte malveillant est-il neutralisé ?
Write-Host "`nTest 1: Neutralisation du compte malveillant 'support.temp'" -ForegroundColor Yellow

try {
    $suspectAccount = Get-ADUser -Identity $maliciousAccount -Properties Enabled -ErrorAction Stop

    if ($suspectAccount.Enabled -eq $false) {
        Write-Host "  ✓ BON - Le compte est désactivé" -ForegroundColor Green
        $containmentScore += 2
    } else {
        Write-Host "  ✗ CRITIQUE - Le compte est toujours ACTIVÉ !" -ForegroundColor Red
        Write-Host "    ACTION IMMÉDIATE: Disable-ADAccount -Identity $maliciousAccount" -ForegroundColor Yellow
        $errors++
    }

    Write-Host "  ℹ Le compte existe toujours (normal si vous l'avez conservé pour forensics)" -ForegroundColor Cyan

} catch {
    Write-Host "  ✓ EXCELLENT - Le compte a été supprimé définitivement" -ForegroundColor Green
    Write-Host "    (Idéal après avoir exporté pour analyse forensique)" -ForegroundColor Gray
    $containmentScore += 3
}

# Test 2: Le compte malveillant est-il retiré de Admins du domaine ?
Write-Host "`nTest 2: Retrait du groupe Admins du domaine" -ForegroundColor Yellow

try {
    $domainAdmins = Get-ADGroupMember -Identity "Admins du domaine" -ErrorAction Stop
    $isMember = $domainAdmins | Where-Object {$_.SamAccountName -eq $maliciousAccount}

    if ($isMember) {
        Write-Host "  ✗ CRITIQUE - support.temp est TOUJOURS dans Admins du domaine !" -ForegroundColor Red
        Write-Host "    ACTION IMMÉDIATE: Remove-ADGroupMember -Identity 'Admins du domaine' -Members $maliciousAccount" -ForegroundColor Yellow
        $errors++
    } else {
        Write-Host "  ✓ RÉUSSI - support.temp n'est plus dans Admins du domaine" -ForegroundColor Green
        $containmentScore += 3
    }
} catch {
    Write-Host "  ✗ ERREUR: Impossible de vérifier Admins du domaine" -ForegroundColor Red
    $errors++
}

# Test 3: Le mot de passe d'Olivier a-t-il été réinitialisé ?
Write-Host "`nTest 3: Réinitialisation du mot de passe du compte compromis (olivier)" -ForegroundColor Yellow

try {
    $olivierAccount = Get-ADUser -Identity $compromisedAccount -Properties PasswordLastSet, pwdLastSet -ErrorAction Stop

    # Vérifier si le mot de passe a été modifié récemment (dans les dernières heures)
    $passwordAge = (Get-Date) - $olivierAccount.PasswordLastSet

    if ($passwordAge.TotalHours -le 2) {
        Write-Host "  ✓ RÉUSSI - Mot de passe réinitialisé récemment" -ForegroundColor Green
        Write-Host "    Dernière modification: $($olivierAccount.PasswordLastSet)" -ForegroundColor Gray
        $containmentScore += 2
    } else {
        Write-Host "  ⚠ AVERTISSEMENT - Le mot de passe n'a pas été modifié récemment" -ForegroundColor Yellow
        Write-Host "    Dernière modification: $($olivierAccount.PasswordLastSet)" -ForegroundColor Yellow
        Write-Host "    Le compte compromis devrait avoir un nouveau mot de passe" -ForegroundColor Yellow
        $warnings++
    }

    # Vérifier si l'utilisateur doit changer son mot de passe
    if ($olivierAccount.pwdLastSet -eq 0) {
        Write-Host "  ✓ RÉUSSI - L'utilisateur doit changer son mot de passe à la prochaine connexion" -ForegroundColor Green
        $containmentScore += 1
    } else {
        Write-Host "  ⚠ SUGGESTION - Forcer le changement de mot de passe pour plus de sécurité" -ForegroundColor Yellow
    }

} catch {
    Write-Host "  ✗ ERREUR: Impossible de vérifier le compte olivier" -ForegroundColor Red
    $errors++
}

# Test 4: Recherche d'autres comptes suspects
Write-Host "`nTest 4: Détection d'autres comptes suspects récents" -ForegroundColor Yellow

$recentAccounts = Get-ADUser -Filter * -Properties WhenCreated |
    Where-Object {$_.WhenCreated -gt (Get-Date).AddDays(-3) -and $_.SamAccountName -ne $maliciousAccount} |
    Select-Object Name, SamAccountName, WhenCreated, Enabled

if ($recentAccounts.Count -gt 0) {
    Write-Host "  Comptes créés dans les 3 derniers jours:" -ForegroundColor Gray

    $suspiciousFound = $false
    foreach ($account in $recentAccounts) {
        Write-Host "    - $($account.SamAccountName) (Créé: $($account.WhenCreated), Activé: $($account.Enabled))" -ForegroundColor Gray

        # Chercher des patterns suspects
        if ($account.SamAccountName -like "*temp*" -or
            $account.SamAccountName -like "*support*" -or
            $account.SamAccountName -like "*admin*" -or
            $account.SamAccountName -like "*backup*") {
            Write-Host "      ⚠ SUSPECT - Nom potentiellement malveillant" -ForegroundColor Red
            $suspiciousFound = $true
            $warnings++
        }
    }

    if (-not $suspiciousFound) {
        Write-Host "  ✓ Aucun compte suspect détecté parmi les comptes récents" -ForegroundColor Green
        $investigationScore += 2
    }
} else {
    Write-Host "  ✓ Aucun compte créé récemment (hors support.temp)" -ForegroundColor Green
    $investigationScore += 2
}

# PHASE 2: VÉRIFICATION DE L'INVESTIGATION
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "PHASE 2: INVESTIGATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Test 5: Audit du groupe Admins du domaine
Write-Host "`nTest 5: Audit complet du groupe Admins du domaine" -ForegroundColor Yellow

try {
    $domainAdmins = Get-ADGroupMember -Identity "Admins du domaine"
    Write-Host "  Membres actuels de Admins du domaine:" -ForegroundColor Gray

    foreach ($admin in $domainAdmins) {
        Write-Host "    - $($admin.SamAccountName)" -ForegroundColor Gray
    }

    # Vérifier qu'il n'y a pas trop de membres (bonne pratique)
    if ($domainAdmins.Count -le 3) {
        Write-Host "  ✓ BON - Nombre limité de Admins du domaine ($($domainAdmins.Count))" -ForegroundColor Green
        $investigationScore += 1
    } else {
        Write-Host "  ⚠ RECOMMANDATION - Trop de membres dans Admins du domaine ($($domainAdmins.Count))" -ForegroundColor Yellow
        Write-Host "    Bonne pratique: Maximum 2-3 comptes" -ForegroundColor Yellow
        $warnings++
    }

} catch {
    Write-Host "  ✗ ERREUR: Impossible d'auditer Admins du domaine" -ForegroundColor Red
    $errors++
}

# Test 6: Vérification des GPO (backdoor potentiel)
Write-Host "`nTest 6: Détection de GPO malveillantes" -ForegroundColor Yellow

try {
    Import-Module GroupPolicy -ErrorAction Stop

    $recentGPOs = Get-GPO -All |
        Where-Object {$_.ModificationTime -gt (Get-Date).AddDays(-2)} |
        Select-Object DisplayName, ModificationTime

    if ($recentGPOs.Count -gt 0) {
        Write-Host "  GPO modifiées dans les 2 derniers jours:" -ForegroundColor Gray

        foreach ($gpo in $recentGPOs) {
            Write-Host "    - $($gpo.DisplayName) (Modifiée: $($gpo.ModificationTime))" -ForegroundColor Gray
        }

        Write-Host "  ℹ Vérifiez manuellement ces GPO pour détecter des modifications suspectes" -ForegroundColor Cyan
        $investigationScore += 1

    } else {
        Write-Host "  ✓ EXCELLENT - Aucune GPO modifiée récemment" -ForegroundColor Green
        Write-Host "    Pas de persistance via GPO détectée" -ForegroundColor Gray
        $investigationScore += 2
    }

} catch {
    Write-Host "  ⚠ Module GroupPolicy non disponible - impossible de vérifier les GPO" -ForegroundColor Yellow
}

# PHASE 3: VÉRIFICATION DE LA REMEDIATION
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "PHASE 3: REMEDIATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Test 7: Le compte malveillant a-t-il été supprimé définitivement ?
Write-Host "`nTest 7: Suppression définitive du compte malveillant" -ForegroundColor Yellow

try {
    Get-ADUser -Identity $maliciousAccount -ErrorAction Stop | Out-Null
    Write-Host "  ℹ Le compte existe toujours (désactivé)" -ForegroundColor Cyan
    Write-Host "    Recommandation: Après avoir exporté pour forensics, supprimez avec:" -ForegroundColor Cyan
    Write-Host "    Remove-ADUser -Identity $maliciousAccount -Confirm:`$false" -ForegroundColor Gray
    $remediationScore += 1
} catch {
    Write-Host "  ✓ EXCELLENT - Le compte a été supprimé définitivement" -ForegroundColor Green
    $remediationScore += 3
}

# Test 8: Réinitialisation des mots de passe des comptes critiques
Write-Host "`nTest 8: Réinitialisation des comptes administrateurs critiques" -ForegroundColor Yellow

$criticalAccounts = @("rachid", "pauline") # Admins IT
$resetCount = 0

foreach ($account in $criticalAccounts) {
    try {
        $user = Get-ADUser -Identity $account -Properties PasswordLastSet -ErrorAction Stop
        $passwordAge = (Get-Date) - $user.PasswordLastSet

        if ($passwordAge.TotalHours -le 2) {
            Write-Host "  ✓ $account - Mot de passe réinitialisé récemment" -ForegroundColor Green
            $resetCount++
        } else {
            Write-Host "  ⚠ $account - Mot de passe non modifié récemment" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  ℹ $account - Compte introuvable (normal si pas dans votre lab)" -ForegroundColor Cyan
    }
}

if ($resetCount -gt 0) {
    Write-Host "  ✓ $resetCount compte(s) administrateur(s) sécurisé(s)" -ForegroundColor Green
    $remediationScore += 2
} else {
    Write-Host "  ℹ Recommandation: Réinitialisez les mots de passe de tous les comptes admin" -ForegroundColor Cyan
}

# Test 9: Documentation de l'incident
Write-Host "`nTest 9: Documentation de l'incident" -ForegroundColor Yellow

$logFiles = Get-ChildItem -Path "C:\Labos" -Filter "Incident_*.log" -ErrorAction SilentlyContinue
$reportFiles = Get-ChildItem -Path "C:\Labos" -Filter "Incident_Report_*.txt" -ErrorAction SilentlyContinue

if ($logFiles -or $reportFiles) {
    Write-Host "  ✓ EXCELLENT - Documentation d'incident trouvée:" -ForegroundColor Green

    if ($logFiles) {
        Write-Host "    Log trouvé: $($logFiles[0].Name)" -ForegroundColor Gray
        $remediationScore += 2
    }

    if ($reportFiles) {
        Write-Host "    Rapport trouvé: $($reportFiles[0].Name)" -ForegroundColor Gray
        $remediationScore += 3
    }
} else {
    Write-Host "  ⚠ IMPORTANT - Aucun fichier de documentation trouvé dans C:\Labos" -ForegroundColor Yellow
    Write-Host "    La documentation est ESSENTIELLE pour:" -ForegroundColor Yellow
    Write-Host "      - L'audit interne" -ForegroundColor Gray
    Write-Host "      - Les assurances" -ForegroundColor Gray
    Write-Host "      - La conformité RGPD" -ForegroundColor Gray
    Write-Host "      - L'analyse post-mortem" -ForegroundColor Gray
    $warnings++
}

# RÉSUMÉ FINAL
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "RÉSUMÉ DE LA GESTION DE CRISE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$totalScore = $containmentScore + $investigationScore + $remediationScore
$maxScore = 20

Write-Host "`nScores par phase:" -ForegroundColor Yellow
Write-Host "  Containment   : $containmentScore / 8" -ForegroundColor White
Write-Host "  Investigation : $investigationScore / 5" -ForegroundColor White
Write-Host "  Remediation   : $remediationScore / 7" -ForegroundColor White
Write-Host "  ──────────────────────" -ForegroundColor Gray
Write-Host "  TOTAL         : $totalScore / $maxScore" -ForegroundColor Cyan

# Évaluation de la performance
$percentage = ($totalScore / $maxScore) * 100

Write-Host "`n📊 Évaluation de la gestion de crise:" -ForegroundColor Cyan

if ($errors -eq 0 -and $percentage -ge 90) {
    Write-Host "🏆 EXCELLENTE GESTION DE CRISE ! ($([math]::Round($percentage, 0))%)" -ForegroundColor Green
    Write-Host "Vous avez géré cet incident de manière professionnelle et méthodique." -ForegroundColor Green
    Write-Host "L'environnement est sécurisé et documenté." -ForegroundColor Green

} elseif ($errors -eq 0 -and $percentage -ge 70) {
    Write-Host "✓ BONNE GESTION DE CRISE ($([math]::Round($percentage, 0))%)" -ForegroundColor Green
    Write-Host "Les actions critiques ont été effectuées correctement." -ForegroundColor Green
    if ($warnings -gt 0) {
        Write-Host "Quelques améliorations possibles (voir suggestions ci-dessus)." -ForegroundColor Yellow
    }

} elseif ($errors -eq 0 -and $percentage -ge 50) {
    Write-Host "⚠ GESTION ACCEPTABLE ($([math]::Round($percentage, 0))%)" -ForegroundColor Yellow
    Write-Host "L'incident a été contenu mais certaines étapes manquent." -ForegroundColor Yellow
    Write-Host "Revoyez les phases Investigation et Remediation." -ForegroundColor Yellow

} else {
    Write-Host "❌ GESTION INSUFFISANTE ($([math]::Round($percentage, 0))%)" -ForegroundColor Red
    Write-Host "$errors erreur(s) critique(s) détectée(s)." -ForegroundColor Red
    Write-Host "L'environnement n'est PAS encore sécurisé." -ForegroundColor Red
    Write-Host "Consultez les détails ci-dessus et complétez les actions manquantes." -ForegroundColor Yellow
}

Write-Host "========================================" -ForegroundColor Cyan

# Checklist de sécurité post-incident
Write-Host "`n✅ Checklist de sécurité post-incident:" -ForegroundColor Cyan

$checklist = @(
    @{Item="Compte malveillant désactivé ou supprimé"; Status=($containmentScore -ge 2)},
    @{Item="Privilèges Admins du domaine révoqués"; Status=($containmentScore -ge 5)},
    @{Item="Compte compromis (olivier) sécurisé"; Status=($containmentScore -ge 7)},
    @{Item="Audit des comptes récents effectué"; Status=($investigationScore -ge 2)},
    @{Item="Audit de Admins du domaine effectué"; Status=($investigationScore -ge 3)},
    @{Item="Vérification des GPO effectuée"; Status=($investigationScore -ge 4)},
    @{Item="Compte malveillant supprimé définitivement"; Status=($remediationScore -ge 2)},
    @{Item="Mots de passe admin réinitialisés"; Status=($remediationScore -ge 4)},
    @{Item="Incident documenté (log + rapport)"; Status=($remediationScore -ge 6)}
)

foreach ($check in $checklist) {
    if ($check.Status) {
        Write-Host "  ✓ $($check.Item)" -ForegroundColor Green
    } else {
        Write-Host "  ☐ $($check.Item)" -ForegroundColor Yellow
    }
}

# Recommandations de sécurité à long terme
Write-Host "`n🔒 Recommandations de sécurité à long terme:" -ForegroundColor Cyan
Write-Host "  1. Formation anti-phishing pour TOUS les employés" -ForegroundColor Yellow
Write-Host "  2. Activer l'authentification multi-facteurs (MFA)" -ForegroundColor Yellow
Write-Host "  3. Limiter les membres de Admins du domaine (max 2-3)" -ForegroundColor Yellow
Write-Host "  4. Activer l'audit avancé AD (connexions, modifications)" -ForegroundColor Yellow
Write-Host "  5. Implémenter un système de détection d'intrusion (IDS)" -ForegroundColor Yellow
Write-Host "  6. Procédure de vérification pour demandes urgentes" -ForegroundColor Yellow
Write-Host "  7. VPN obligatoire pour connexions externes" -ForegroundColor Yellow
Write-Host "  8. Sauvegardes régulières de l'AD" -ForegroundColor Yellow
Write-Host "  9. Plan de réponse à incident formalisé" -ForegroundColor Yellow
Write-Host "  10. Exercices de simulation réguliers (comme celui-ci !)" -ForegroundColor Yellow

# Timeline théorique de l'incident (référence)
Write-Host "`n📅 Timeline de référence de l'incident:" -ForegroundColor Cyan
Write-Host "  10/10/2025 22:05 - Connexion olivier depuis IP externe" -ForegroundColor Gray
Write-Host "  10/10/2025 22:15 - Création compte support.temp" -ForegroundColor Gray
Write-Host "  10/10/2025 22:17 - support.temp ajouté à Admins du domaine" -ForegroundColor Gray
Write-Host "  10/10/2025 23:47 - Accès fichiers SecureBank" -ForegroundColor Gray
Write-Host "  11/10/2025 07:30 - Email de rançon" -ForegroundColor Gray
Write-Host "  11/10/2025 14:37 - Détection incident" -ForegroundColor Gray
Write-Host "  11/10/2025 ~15:00 - Containment (vos actions)" -ForegroundColor Green

Write-Host "`n💡 Prochaines étapes dans un contexte réel:" -ForegroundColor Cyan
Write-Host "  1. Informer la direction et le service juridique" -ForegroundColor White
Write-Host "  2. Notifier les clients dont les données ont été accédées (RGPD)" -ForegroundColor White
Write-Host "  3. Déclaration à la CNIL (si données personnelles compromises)" -ForegroundColor White
Write-Host "  4. Éventuel dépôt de plainte pour intrusion" -ForegroundColor White
Write-Host "  5. Analyse forensique approfondie du poste d'Olivier" -ForegroundColor White
Write-Host "  6. Scanner tous les postes pour détecter d'éventuels malwares" -ForegroundColor White
Write-Host "  7. Mise en place des recommandations de sécurité" -ForegroundColor White
Write-Host "  8. Formation de sensibilisation pour toute l'entreprise" -ForegroundColor White

Write-Host "`n📚 Ressources pour approfondir:" -ForegroundColor Cyan
Write-Host "  - NIST Incident Response Guide: https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-61r2.pdf" -ForegroundColor Gray
Write-Host "  - Microsoft Security Best Practices: https://docs.microsoft.com/en-us/security/" -ForegroundColor Gray
Write-Host "  - ANSSI Guide Hygiène Informatique: https://www.ssi.gouv.fr/" -ForegroundColor Gray

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "FIN DE LA VÉRIFICATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($logFiles -or $reportFiles) {
    Write-Host "`n📁 Fichiers de documentation à conserver:" -ForegroundColor Yellow
    if ($logFiles) {
        Write-Host "  - $($logFiles[0].FullName)" -ForegroundColor White
    }
    if ($reportFiles) {
        Write-Host "  - $($reportFiles[0].FullName)" -ForegroundColor White
    }
}

Write-Host "`n🎓 Félicitations pour avoir complété cet exercice de crise !" -ForegroundColor Green
Write-Host "Vous avez développé des compétences critiques en gestion d'incidents de sécurité." -ForegroundColor White
