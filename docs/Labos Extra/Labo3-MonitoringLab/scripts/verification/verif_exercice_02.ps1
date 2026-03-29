# Script de vérification - Exercice 02 : Analyse des Événements de Sécurité
# Exécuter ce script pour vérifier si l'exercice est correctement complété
# Exécution : .\verif_exercice_02.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Vérification Exercice 02 - Analyse Événements" -ForegroundColor Cyan
Write-Host "MonitoringTech SPRL - maxtec.be" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$erreurs = 0
$avertissements = 0

# -----------------------------------------------
# Test 1 : Journal Security accessible
# -----------------------------------------------
Write-Host "`nTest 1 : Accessibilité du journal Security" -ForegroundColor Yellow
try {
    $testLog = Get-WinEvent -LogName Security -MaxEvents 1 -ErrorAction Stop
    Write-Host "  OK - Journal Security accessible" -ForegroundColor Green
} catch {
    Write-Host "  ECHEC - Journal Security inaccessible : $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  Conseil : Exécutez PowerShell en tant qu'Administrateur" -ForegroundColor Yellow
    $erreurs++
}

# -----------------------------------------------
# Test 2 : Événements 4624 présents (connexions réussies)
# -----------------------------------------------
Write-Host "`nTest 2 : Présence d'événements 4624 (connexions réussies)" -ForegroundColor Yellow
try {
    $events4624 = Get-WinEvent -LogName Security -MaxEvents 5000 -ErrorAction SilentlyContinue |
        Where-Object { $_.Id -eq 4624 }
    if ($events4624.Count -gt 0) {
        Write-Host "  OK - $($events4624.Count) événement(s) 4624 trouvé(s)" -ForegroundColor Green
    } else {
        Write-Host "  AVERTISSEMENT - Aucun événement 4624 trouvé" -ForegroundColor Yellow
        Write-Host "  Conseil : Exécutez le script 2_Generate-Events.ps1 pour peupler les journaux" -ForegroundColor Yellow
        $avertissements++
    }
} catch {
    Write-Host "  ERREUR - $($_.Exception.Message)" -ForegroundColor Red
    $erreurs++
}

# -----------------------------------------------
# Test 3 : Événements 4625 présents (échecs de connexion)
# -----------------------------------------------
Write-Host "`nTest 3 : Présence d'événements 4625 (échecs de connexion)" -ForegroundColor Yellow
try {
    $events4625 = Get-WinEvent -LogName Security -MaxEvents 5000 -ErrorAction SilentlyContinue |
        Where-Object { $_.Id -eq 4625 }
    if ($events4625.Count -gt 0) {
        Write-Host "  OK - $($events4625.Count) événement(s) 4625 trouvé(s)" -ForegroundColor Green
        Write-Host "  Info - Premiers échecs détectés :" -ForegroundColor Gray
        $events4625 | Select-Object -First 3 | ForEach-Object {
            Write-Host "    $($_.TimeCreated) - $($_.Message.Substring(0,[Math]::Min(80,$_.Message.Length)))" -ForegroundColor Gray
        }
    } else {
        Write-Host "  AVERTISSEMENT - Aucun événement 4625 trouvé" -ForegroundColor Yellow
        Write-Host "  Conseil : Exécutez le script 2_Generate-Events.ps1 pour générer des tentatives de connexion" -ForegroundColor Yellow
        $avertissements++
    }
} catch {
    Write-Host "  ERREUR - $($_.Exception.Message)" -ForegroundColor Red
    $erreurs++
}

# -----------------------------------------------
# Test 4 : Événements dans les dernières 24h
# -----------------------------------------------
Write-Host "`nTest 4 : Événements récents (dernières 24h)" -ForegroundColor Yellow
try {
    $hier = (Get-Date).AddHours(-24)
    $recents = Get-WinEvent -LogName Security -MaxEvents 10000 -ErrorAction SilentlyContinue |
        Where-Object { $_.TimeCreated -gt $hier }
    if ($recents.Count -gt 0) {
        Write-Host "  OK - $($recents.Count) événement(s) dans les dernières 24h" -ForegroundColor Green
    } else {
        Write-Host "  AVERTISSEMENT - Aucun événement récent dans les 24 dernières heures" -ForegroundColor Yellow
        $avertissements++
    }
} catch {
    Write-Host "  ERREUR - $($_.Exception.Message)" -ForegroundColor Red
    $erreurs++
}

# -----------------------------------------------
# Test 5 : Taille du journal de sécurité
# -----------------------------------------------
Write-Host "`nTest 5 : Taille du journal Security" -ForegroundColor Yellow
try {
    $logInfo = Get-WinEvent -ListLog Security -ErrorAction Stop
    $taillesMo = [Math]::Round($logInfo.MaximumSizeInBytes / 1MB, 1)
    if ($logInfo.MaximumSizeInBytes -ge 20MB) {
        Write-Host "  OK - Taille du journal : $taillesMo MB (recommandé : >= 20 MB)" -ForegroundColor Green
    } else {
        Write-Host "  AVERTISSEMENT - Taille du journal : $taillesMo MB (recommandé : >= 20 MB)" -ForegroundColor Yellow
        Write-Host "  Conseil : Clic droit sur 'Security' dans l'Observateur > Propriétés > Augmenter la taille" -ForegroundColor Yellow
        $avertissements++
    }
} catch {
    Write-Host "  ERREUR - $($_.Exception.Message)" -ForegroundColor Red
    $erreurs++
}

# -----------------------------------------------
# Test 6 : Rapport statistique des Event IDs
# -----------------------------------------------
Write-Host "`nTest 6 : Rapport statistique des Event IDs critiques" -ForegroundColor Yellow
try {
    $eventIds = @(4624, 4625, 4648, 4720, 4740)
    $stats = Get-WinEvent -LogName Security -MaxEvents 10000 -ErrorAction SilentlyContinue |
        Where-Object { $_.Id -in $eventIds } |
        Group-Object Id |
        Sort-Object Name

    if ($stats.Count -gt 0) {
        Write-Host "  OK - Statistiques des événements critiques :" -ForegroundColor Green
        foreach ($stat in $stats) {
            $description = switch ($stat.Name) {
                "4624" { "Connexion réussie" }
                "4625" { "Echec de connexion" }
                "4648" { "Connexion avec credentials explicites" }
                "4720" { "Création de compte" }
                "4740" { "Compte verrouillé" }
                default { "Autre" }
            }
            Write-Host "    Event $($stat.Name) ($description) : $($stat.Count) occurrence(s)" -ForegroundColor Gray
        }
    } else {
        Write-Host "  AVERTISSEMENT - Aucun événement critique trouvé" -ForegroundColor Yellow
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
    Write-Host "EXERCICE 02 RÉUSSI ! Tous les critères sont satisfaits." -ForegroundColor Green
} elseif ($erreurs -eq 0) {
    Write-Host "EXERCICE 02 PARTIELLEMENT RÉUSSI : $avertissements avertissement(s)." -ForegroundColor Yellow
    Write-Host "Exécutez 2_Generate-Events.ps1 pour enrichir les journaux si nécessaire." -ForegroundColor Yellow
} else {
    Write-Host "EXERCICE 02 INCOMPLET : $erreurs erreur(s) et $avertissements avertissement(s)." -ForegroundColor Red
    Write-Host "Consultez les points ECHEC ci-dessus." -ForegroundColor Yellow
}
Write-Host "========================================" -ForegroundColor Cyan
