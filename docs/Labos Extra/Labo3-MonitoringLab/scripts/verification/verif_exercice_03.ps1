# Script de vérification - Exercice 03 : Configuration des GPOs
# Exécuter ce script pour vérifier si l'exercice est correctement complété
# Exécution : .\verif_exercice_03.ps1

Import-Module ActiveDirectory -ErrorAction SilentlyContinue
Import-Module GroupPolicy -ErrorAction SilentlyContinue

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Vérification Exercice 03 - Configuration GPOs" -ForegroundColor Cyan
Write-Host "MonitoringTech SPRL - maxtec.be" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$erreurs = 0
$avertissements = 0

# -----------------------------------------------
# Test 1 : Politique de mots de passe du domaine
# -----------------------------------------------
Write-Host "`nTest 1 : Politique de mots de passe du domaine" -ForegroundColor Yellow
try {
    $pwdPolicy = Get-ADDefaultDomainPasswordPolicy -Identity "maxtec.be" -ErrorAction Stop

    # Longueur minimale
    if ($pwdPolicy.MinPasswordLength -ge 12) {
        Write-Host "  OK - Longueur minimale : $($pwdPolicy.MinPasswordLength) caractères (>= 12)" -ForegroundColor Green
    } else {
        Write-Host "  ECHEC - Longueur minimale : $($pwdPolicy.MinPasswordLength) (attendu : >= 12)" -ForegroundColor Red
        $erreurs++
    }

    # Complexité
    if ($pwdPolicy.ComplexityEnabled) {
        Write-Host "  OK - Complexité : Activée" -ForegroundColor Green
    } else {
        Write-Host "  ECHEC - Complexité : Désactivée (doit être activée)" -ForegroundColor Red
        $erreurs++
    }

    # Seuil de verrouillage
    if ($pwdPolicy.LockoutThreshold -ge 3 -and $pwdPolicy.LockoutThreshold -le 10) {
        Write-Host "  OK - Seuil de verrouillage : $($pwdPolicy.LockoutThreshold) tentatives" -ForegroundColor Green
    } else {
        Write-Host "  AVERTISSEMENT - Seuil de verrouillage : $($pwdPolicy.LockoutThreshold) (recommandé : 3-10)" -ForegroundColor Yellow
        $avertissements++
    }

    # Durée de verrouillage
    $dureeLockout = $pwdPolicy.LockoutDuration.TotalMinutes
    if ($dureeLockout -ge 15) {
        Write-Host "  OK - Durée de verrouillage : $dureeLockout minutes (>= 15)" -ForegroundColor Green
    } else {
        Write-Host "  AVERTISSEMENT - Durée de verrouillage : $dureeLockout minutes (recommandé : >= 15)" -ForegroundColor Yellow
        $avertissements++
    }

    # Historique
    if ($pwdPolicy.PasswordHistoryCount -ge 10) {
        Write-Host "  OK - Historique : $($pwdPolicy.PasswordHistoryCount) mots de passe mémorisés" -ForegroundColor Green
    } else {
        Write-Host "  AVERTISSEMENT - Historique : $($pwdPolicy.PasswordHistoryCount) (recommandé : >= 10)" -ForegroundColor Yellow
        $avertissements++
    }

} catch {
    Write-Host "  ERREUR - $($_.Exception.Message)" -ForegroundColor Red
    $erreurs++
}

# -----------------------------------------------
# Test 2 : GPO "MonitoringTech - Audit Avancé" existe
# -----------------------------------------------
Write-Host "`nTest 2 : GPO 'MonitoringTech - Audit Avancé' existence" -ForegroundColor Yellow
try {
    $gpoAudit = Get-GPO -All -ErrorAction Stop |
        Where-Object { $_.DisplayName -like "*Audit*" -and $_.DisplayName -like "*MonitoringTech*" }

    if ($gpoAudit) {
        Write-Host "  OK - GPO Audit trouvée : $($gpoAudit.DisplayName)" -ForegroundColor Green
        Write-Host "  Info - Statut : $($gpoAudit.GpoStatus)" -ForegroundColor Gray
    } else {
        Write-Host "  AVERTISSEMENT - GPO d'audit 'MonitoringTech*Audit*' non trouvée" -ForegroundColor Yellow
        Write-Host "  Conseil : Le script de setup aurait dû créer cette GPO. Vérifiez GPMC." -ForegroundColor Yellow
        $avertissements++
    }
} catch {
    Write-Host "  ERREUR - Module GroupPolicy manquant ou accès refusé : $($_.Exception.Message)" -ForegroundColor Red
    $erreurs++
}

# -----------------------------------------------
# Test 3 : GPO liée à l'OU MONITORING
# -----------------------------------------------
Write-Host "`nTest 3 : Liens GPO sur OU=MONITORING" -ForegroundColor Yellow
try {
    $inheritance = Get-GPInheritance -Target "OU=MONITORING,DC=maxtec,DC=be" -ErrorAction Stop
    $liens = $inheritance.GpoLinks

    if ($liens.Count -gt 0) {
        Write-Host "  OK - $($liens.Count) GPO(s) liée(s) à OU=MONITORING :" -ForegroundColor Green
        foreach ($lien in $liens) {
            $statutLien = if ($lien.Enabled) { "Actif" } else { "Désactivé" }
            Write-Host "    - $($lien.DisplayName) (Lien : $statutLien)" -ForegroundColor Gray
        }
    } else {
        Write-Host "  AVERTISSEMENT - Aucune GPO liée à OU=MONITORING" -ForegroundColor Yellow
        $avertissements++
    }
} catch {
    Write-Host "  ERREUR - $($_.Exception.Message)" -ForegroundColor Red
    $erreurs++
}

# -----------------------------------------------
# Test 4 : Paramètres d'audit système (auditpol)
# -----------------------------------------------
Write-Host "`nTest 4 : Paramètres d'audit système (auditpol)" -ForegroundColor Yellow
try {
    $auditLogon = auditpol /get /subcategory:"Logon" 2>$null
    $auditAccMgmt = auditpol /get /subcategory:"User Account Management" 2>$null

    if ($auditLogon -match "Success") {
        Write-Host "  OK - Audit Ouverture de session : configuré" -ForegroundColor Green
    } else {
        Write-Host "  AVERTISSEMENT - Audit Ouverture de session : non configuré localement" -ForegroundColor Yellow
        Write-Host "  (Peut être configuré via GPO - normal si la GPO n'est pas encore appliquée)" -ForegroundColor Gray
        $avertissements++
    }

    if ($auditAccMgmt -match "Success") {
        Write-Host "  OK - Audit Gestion des comptes : configuré" -ForegroundColor Green
    } else {
        Write-Host "  AVERTISSEMENT - Audit Gestion des comptes : non configuré localement" -ForegroundColor Yellow
        $avertissements++
    }
} catch {
    Write-Host "  ERREUR lors de la vérification auditpol : $($_.Exception.Message)" -ForegroundColor Red
    $erreurs++
}

# -----------------------------------------------
# Test 5 : Toutes les GPOs MonitoringTech listées
# -----------------------------------------------
Write-Host "`nTest 5 : Inventaire des GPOs MonitoringTech" -ForegroundColor Yellow
try {
    $toutesGPOs = Get-GPO -All | Where-Object { $_.DisplayName -like "MonitoringTech*" }
    if ($toutesGPOs.Count -gt 0) {
        Write-Host "  OK - $($toutesGPOs.Count) GPO(s) MonitoringTech trouvée(s) :" -ForegroundColor Green
        foreach ($gpo in $toutesGPOs) {
            Write-Host "    - $($gpo.DisplayName) [ID: $($gpo.Id)]" -ForegroundColor Gray
        }
    } else {
        Write-Host "  AVERTISSEMENT - Aucune GPO 'MonitoringTech*' trouvée" -ForegroundColor Yellow
        $avertissements++
    }
} catch {
    Write-Host "  ERREUR - $($_.Exception.Message)" -ForegroundColor Red
    $erreurs++
}

# -----------------------------------------------
# Résumé final
# -----------------------------------------------
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "RÉSUMÉ DE LA VÉRIFICATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($erreurs -eq 0 -and $avertissements -eq 0) {
    Write-Host "EXERCICE 03 RÉUSSI ! Tous les critères sont satisfaits." -ForegroundColor Green
} elseif ($erreurs -eq 0) {
    Write-Host "EXERCICE 03 PARTIELLEMENT RÉUSSI : $avertissements avertissement(s)." -ForegroundColor Yellow
    Write-Host "La configuration GPMC (audit avancé, restrictions) ne peut pas etre vérifiée" -ForegroundColor Yellow
    Write-Host "automatiquement - vérification manuelle requise dans GPMC." -ForegroundColor Yellow
} else {
    Write-Host "EXERCICE 03 INCOMPLET : $erreurs erreur(s) et $avertissements avertissement(s)." -ForegroundColor Red
    Write-Host "Consultez les points ECHEC ci-dessus." -ForegroundColor Yellow
}

Write-Host "`nNote : La configuration de l'audit dans GPMC (Exercice 03, Partie 3+4)" -ForegroundColor Gray
Write-Host "doit être vérifiée manuellement car elle ne peut pas l'être via PowerShell." -ForegroundColor Gray
Write-Host "========================================" -ForegroundColor Cyan
