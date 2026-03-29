# Script de vérification - Exercice 06 : Investigation d'Incident
# Exécuter ce script pour vérifier si l'exercice est correctement complété
# Exécution : .\verif_exercice_06.ps1

Import-Module ActiveDirectory -ErrorAction SilentlyContinue

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Vérification Exercice 06 - Investigation Incident" -ForegroundColor Cyan
Write-Host "MonitoringTech SPRL - maxtec.be" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$erreurs = 0
$avertissements = 0

# -----------------------------------------------
# Test 1 : Compte svc_monitoring désactivé
# -----------------------------------------------
Write-Host "`nTest 1 : Compte svc_monitoring - Phase de confinement" -ForegroundColor Yellow
try {
    $svc = Get-ADUser -Identity "svc_monitoring" -Properties Enabled, Description -ErrorAction Stop

    if (-not $svc.Enabled) {
        Write-Host "  OK - svc_monitoring est DÉSACTIVÉ (confinement effectué)" -ForegroundColor Green
    } else {
        Write-Host "  ECHEC - svc_monitoring est encore ACTIF - le compte doit être désactivé" -ForegroundColor Red
        $erreurs++
    }

    # Vérifier la documentation dans la description
    if ($svc.Description -and (
        $svc.Description -like "*COMPROMIS*" -or
        $svc.Description -like "*compromis*" -or
        $svc.Description -like "*investigation*" -or
        $svc.Description -like "*Investigation*" -or
        $svc.Description -like "*incident*"
    )) {
        Write-Host "  OK - Description documentée : $($svc.Description.Substring(0, [Math]::Min(80, $svc.Description.Length)))" -ForegroundColor Green
    } else {
        Write-Host "  AVERTISSEMENT - Description ne documente pas l'incident" -ForegroundColor Yellow
        Write-Host "  Description actuelle : $($svc.Description)" -ForegroundColor Gray
        Write-Host "  Attendu : mention de COMPROMIS, investigation, ou incident" -ForegroundColor Yellow
        $avertissements++
    }

} catch {
    Write-Host "  ERREUR - svc_monitoring introuvable : $($_.Exception.Message)" -ForegroundColor Red
    $erreurs++
}

# -----------------------------------------------
# Test 2 : Autres comptes de service toujours actifs
# -----------------------------------------------
Write-Host "`nTest 2 : Autres comptes de service (ne doivent pas être touchés)" -ForegroundColor Yellow
$autresComptes = @("svc_backup", "svc_audit", "svc_replication")
foreach ($cpt in $autresComptes) {
    try {
        $user = Get-ADUser -Identity $cpt -Properties Enabled -ErrorAction Stop
        if ($user.Enabled) {
            Write-Host "  OK - $cpt est actif (non affecté par l'incident)" -ForegroundColor Green
        } else {
            Write-Host "  AVERTISSEMENT - $cpt est DÉSACTIVÉ - vérifier si intentionnel" -ForegroundColor Yellow
            $avertissements++
        }
    } catch {
        Write-Host "  ERREUR - $cpt introuvable : $($_.Exception.Message)" -ForegroundColor Red
        $erreurs++
    }
}

# -----------------------------------------------
# Test 3 : svc_monitoring retiré de Finance Admin (si groupe existe)
# -----------------------------------------------
Write-Host "`nTest 3 : Nettoyage du groupe GG-MONITORING-Finance-Admin" -ForegroundColor Yellow
try {
    $financeAdmin = Get-ADGroup -Identity "GG-MONITORING-Finance-Admin" -ErrorAction Stop
    $membres = Get-ADGroupMember -Identity "GG-MONITORING-Finance-Admin" -ErrorAction Stop |
        Select-Object -ExpandProperty SamAccountName

    if ($membres -notcontains "svc_monitoring") {
        Write-Host "  OK - svc_monitoring est absent de GG-MONITORING-Finance-Admin" -ForegroundColor Green
    } else {
        Write-Host "  ECHEC - svc_monitoring est encore dans GG-MONITORING-Finance-Admin !" -ForegroundColor Red
        Write-Host "  Correction : Remove-ADGroupMember -Identity 'GG-MONITORING-Finance-Admin' -Members 'svc_monitoring' -Confirm:`$false" -ForegroundColor Yellow
        $erreurs++
    }
} catch {
    Write-Host "  INFO - Groupe GG-MONITORING-Finance-Admin introuvable" -ForegroundColor Gray
    Write-Host "  (Normal si le groupe n'existait pas avant l'incident ou a été nettoyé)" -ForegroundColor Gray
}

# -----------------------------------------------
# Test 4 : Mot de passe réinitialisé (impossible à vérifier directement)
# -----------------------------------------------
Write-Host "`nTest 4 : Réinitialisation du mot de passe svc_monitoring" -ForegroundColor Yellow
try {
    $svc = Get-ADUser -Identity "svc_monitoring" -Properties PasswordLastSet -ErrorAction Stop
    $hier = (Get-Date).AddHours(-24)

    if ($svc.PasswordLastSet -and $svc.PasswordLastSet -gt $hier) {
        Write-Host "  OK - Mot de passe réinitialisé récemment (le $($svc.PasswordLastSet.ToString('dd/MM/yyyy HH:mm')))" -ForegroundColor Green
    } else {
        Write-Host "  AVERTISSEMENT - Le mot de passe n'a pas été changé dans les 24 dernières heures" -ForegroundColor Yellow
        Write-Host "  Conseil : Set-ADAccountPassword -Identity 'svc_monitoring' -Reset" -ForegroundColor Yellow
        $avertissements++
    }
} catch {
    Write-Host "  ERREUR - $($_.Exception.Message)" -ForegroundColor Red
    $erreurs++
}

# -----------------------------------------------
# Test 5 : Événements d'investigation collectés
# -----------------------------------------------
Write-Host "`nTest 5 : Événements d'investigation disponibles dans les journaux" -ForegroundColor Yellow
try {
    $debut48h = (Get-Date).AddHours(-48)
    $eventIds = @(4624, 4625, 4648, 4728, 4729)

    $totalEvents = (Get-WinEvent -LogName Security -MaxEvents 50000 -ErrorAction SilentlyContinue |
        Where-Object { $_.TimeCreated -gt $debut48h -and $_.Id -in $eventIds }).Count

    if ($totalEvents -gt 0) {
        Write-Host "  OK - $totalEvents événement(s) d'authentification disponibles (48h)" -ForegroundColor Green
    } else {
        Write-Host "  AVERTISSEMENT - Peu d'événements disponibles pour l'investigation" -ForegroundColor Yellow
        Write-Host "  Conseil : Exécutez 2_Generate-Events.ps1 pour enrichir les journaux" -ForegroundColor Yellow
        $avertissements++
    }
} catch {
    Write-Host "  ERREUR - $($_.Exception.Message)" -ForegroundColor Red
    $erreurs++
}

# -----------------------------------------------
# Test 6 : Rapport d'incident exporté (optionnel mais recommandé)
# -----------------------------------------------
Write-Host "`nTest 6 : Rapport d'incident exporté (bonus)" -ForegroundColor Yellow
$rapportPossibles = @(
    "C:\Temp\rapport_incident_svc_monitoring.csv",
    "C:\Temp\rapport_incident.csv",
    "C:\rapport_incident.csv",
    "C:\rapport_incident.txt"
)

$rapportTrouve = $false
foreach ($rapport in $rapportPossibles) {
    if (Test-Path $rapport) {
        Write-Host "  OK - Rapport trouvé : $rapport" -ForegroundColor Green
        $rapportTrouve = $true
        break
    }
}

if (-not $rapportTrouve) {
    Write-Host "  AVERTISSEMENT - Aucun fichier de rapport exporté trouvé" -ForegroundColor Yellow
    Write-Host "  (Vérifiez si vous avez exporté le rapport en CSV ou texte)" -ForegroundColor Gray
    $avertissements++
}

# -----------------------------------------------
# Test 7 : Groupes d'appartenance de svc_monitoring vérifiés
# -----------------------------------------------
Write-Host "`nTest 7 : Groupes d'appartenance actuels de svc_monitoring" -ForegroundColor Yellow
try {
    $groupes = Get-ADPrincipalGroupMembership "svc_monitoring" -ErrorAction Stop |
        Select-Object -ExpandProperty Name

    Write-Host "  Info - Groupes actuels de svc_monitoring :" -ForegroundColor Gray
    foreach ($g in $groupes) {
        $couleur = if ($g -like "*Finance*Admin*") { "Red" } else { "Gray" }
        Write-Host "    - $g" -ForegroundColor $couleur
    }

    $groupesAdmin = $groupes | Where-Object { $_ -like "*Admin*" -and $_ -notlike "*GG-MONITORING-ITOp*" }
    if ($groupesAdmin.Count -gt 1) {
        Write-Host "  AVERTISSEMENT - svc_monitoring est membre de $($groupesAdmin.Count) groupe(s) admin" -ForegroundColor Yellow
        Write-Host "  Vérifiez si ces appartenances sont légitimes" -ForegroundColor Yellow
        $avertissements++
    } else {
        Write-Host "  OK - Appartenances aux groupes semblent normales" -ForegroundColor Green
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
    Write-Host "EXERCICE 06 RÉUSSI ! Toutes les phases d'incident sont complètes." -ForegroundColor Green
} elseif ($erreurs -eq 0) {
    Write-Host "EXERCICE 06 PARTIELLEMENT RÉUSSI : $avertissements avertissement(s)." -ForegroundColor Yellow
    Write-Host "La phase de confinement est complète. Finalisez les étapes optionnelles." -ForegroundColor Yellow
} else {
    Write-Host "EXERCICE 06 INCOMPLET : $erreurs erreur(s) et $avertissements avertissement(s)." -ForegroundColor Red
    Write-Host "La phase de confinement est incomplète. Consultez les points ECHEC." -ForegroundColor Yellow
}

Write-Host "`nRappel : La chronologie et le rapport d'incident (Parties 2 et 5)" -ForegroundColor Gray
Write-Host "sont des livrables textuels qui doivent être vérifiés manuellement." -ForegroundColor Gray
Write-Host "========================================" -ForegroundColor Cyan
