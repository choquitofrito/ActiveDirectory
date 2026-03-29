# Script de vérification - Exercice 05 : Audit Personnalisé Finance
# Exécuter ce script pour vérifier si l'exercice est correctement complété
# Exécution : .\verif_exercice_05.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Vérification Exercice 05 - Audit Personnalisé" -ForegroundColor Cyan
Write-Host "MonitoringTech SPRL - maxtec.be" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$erreurs = 0
$avertissements = 0

# -----------------------------------------------
# Test 1 : Structure de dossiers C:\FinanceData
# -----------------------------------------------
Write-Host "`nTest 1 : Structure de dossiers C:\FinanceData" -ForegroundColor Yellow
$dossiers = @(
    "C:\FinanceData",
    "C:\FinanceData\Rapports",
    "C:\FinanceData\Budgets",
    "C:\FinanceData\Confidential"
)

foreach ($d in $dossiers) {
    if (Test-Path $d) {
        Write-Host "  OK - Dossier $d existe" -ForegroundColor Green
    } else {
        Write-Host "  ECHEC - Dossier $d manquant" -ForegroundColor Red
        $erreurs++
    }
}

# -----------------------------------------------
# Test 2 : Fichiers de test dans Confidential
# -----------------------------------------------
Write-Host "`nTest 2 : Fichiers de test dans C:\FinanceData\Confidential" -ForegroundColor Yellow
if (Test-Path "C:\FinanceData\Confidential") {
    $fichiers = Get-ChildItem "C:\FinanceData\Confidential" -ErrorAction SilentlyContinue
    if ($fichiers.Count -ge 3) {
        Write-Host "  OK - $($fichiers.Count) fichier(s) présent(s) dans Confidential :" -ForegroundColor Green
        foreach ($f in $fichiers) {
            Write-Host "    - $($f.Name)" -ForegroundColor Gray
        }
    } else {
        Write-Host "  ECHEC - Seulement $($fichiers.Count) fichier(s) dans Confidential (minimum : 3)" -ForegroundColor Red
        $erreurs++
    }
} else {
    Write-Host "  ECHEC - Dossier Confidential inexistant (voir Test 1)" -ForegroundColor Red
    $erreurs++
}

# -----------------------------------------------
# Test 3 : ACL d'audit NTFS configurées
# -----------------------------------------------
Write-Host "`nTest 3 : ACL d'audit NTFS sur C:\FinanceData" -ForegroundColor Yellow
if (Test-Path "C:\FinanceData") {
    try {
        $acl = Get-Acl "C:\FinanceData" -ErrorAction Stop
        if ($acl.Audit -and $acl.Audit.Count -gt 0) {
            Write-Host "  OK - $($acl.Audit.Count) règle(s) d'audit NTFS configurée(s) :" -ForegroundColor Green
            foreach ($regle in $acl.Audit) {
                Write-Host "    - Identité : $($regle.IdentityReference) | Droits : $($regle.FileSystemRights) | Flags : $($regle.AuditFlags)" -ForegroundColor Gray
            }
        } else {
            Write-Host "  ECHEC - Aucune règle d'audit NTFS sur C:\FinanceData" -ForegroundColor Red
            Write-Host "  Conseil : Utilisez Set-Acl avec une FileSystemAuditRule ou configurez via les propriétés du dossier" -ForegroundColor Yellow
            $erreurs++
        }
    } catch {
        Write-Host "  ERREUR - $($_.Exception.Message)" -ForegroundColor Red
        $erreurs++
    }
} else {
    Write-Host "  IGNORÉ - Dossier C:\FinanceData inexistant" -ForegroundColor Yellow
    $avertissements++
}

# -----------------------------------------------
# Test 4 : auditpol - File System activé
# -----------------------------------------------
Write-Host "`nTest 4 : Politique d'audit système (auditpol - File System)" -ForegroundColor Yellow
try {
    $auditFileSystem = auditpol /get /subcategory:"File System" 2>$null
    if ($auditFileSystem -match "Success" -or $auditFileSystem -match "Failure") {
        Write-Host "  OK - Audit File System activé :" -ForegroundColor Green
        $auditFileSystem | Where-Object { $_ -match "File System" } |
            ForEach-Object { Write-Host "    $_" -ForegroundColor Gray }
    } else {
        Write-Host "  ECHEC - Audit File System non activé" -ForegroundColor Red
        Write-Host "  Correction : auditpol /set /subcategory:'File System' /success:enable /failure:enable" -ForegroundColor Yellow
        $erreurs++
    }
} catch {
    Write-Host "  ERREUR - $($_.Exception.Message)" -ForegroundColor Red
    $erreurs++
}

# -----------------------------------------------
# Test 5 : Événements 4663 générés (accès aux objets)
# -----------------------------------------------
Write-Host "`nTest 5 : Présence d'événements 4663 (accès aux objets)" -ForegroundColor Yellow
try {
    $events4663 = Get-WinEvent -LogName Security -MaxEvents 10000 -ErrorAction SilentlyContinue |
        Where-Object { $_.Id -eq 4663 }

    if ($events4663.Count -gt 0) {
        Write-Host "  OK - $($events4663.Count) événement(s) 4663 trouvé(s) dans le journal Security" -ForegroundColor Green

        # Rechercher spécifiquement des accès à FinanceData
        $accesFinance = $events4663 | ForEach-Object {
            $xml = [xml]$_.ToXml()
            $data = $xml.Event.EventData.Data
            $fichier = ($data | Where-Object { $_.Name -eq "ObjectName" }).'#text'
            if ($fichier -like "*FinanceData*") { $_ }
        }

        if ($accesFinance.Count -gt 0) {
            Write-Host "  OK - $($accesFinance.Count) accès à FinanceData enregistrés" -ForegroundColor Green
        } else {
            Write-Host "  AVERTISSEMENT - Aucun accès spécifique à C:\FinanceData enregistré" -ForegroundColor Yellow
            Write-Host "  Conseil : Accédez à des fichiers dans C:\FinanceData pour générer des événements" -ForegroundColor Yellow
            $avertissements++
        }
    } else {
        Write-Host "  AVERTISSEMENT - Aucun événement 4663 trouvé" -ForegroundColor Yellow
        Write-Host "  Cela peut être normal si les fichiers n'ont pas encore été accédés." -ForegroundColor Yellow
        Write-Host "  Conseil : Ouvrez un fichier dans C:\FinanceData, attendez et relancez ce test." -ForegroundColor Yellow
        $avertissements++
    }
} catch {
    Write-Host "  ERREUR - $($_.Exception.Message)" -ForegroundColor Red
    $erreurs++
}

# -----------------------------------------------
# Test 6 : auditpol complet - User Account Management
# -----------------------------------------------
Write-Host "`nTest 6 : Politique d'audit - Gestion des comptes (bonus)" -ForegroundColor Yellow
try {
    $auditAccMgmt = auditpol /get /subcategory:"User Account Management" 2>$null
    if ($auditAccMgmt -match "Success") {
        Write-Host "  OK - Audit User Account Management activé" -ForegroundColor Green
    } else {
        Write-Host "  AVERTISSEMENT - Audit User Account Management non activé" -ForegroundColor Yellow
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
    Write-Host "EXERCICE 05 RÉUSSI ! Tous les critères sont satisfaits." -ForegroundColor Green
} elseif ($erreurs -eq 0) {
    Write-Host "EXERCICE 05 PARTIELLEMENT RÉUSSI : $avertissements avertissement(s)." -ForegroundColor Yellow
    Write-Host "Consultez les avertissements et accédez à des fichiers Finance pour générer des événements." -ForegroundColor Yellow
} else {
    Write-Host "EXERCICE 05 INCOMPLET : $erreurs erreur(s) et $avertissements avertissement(s)." -ForegroundColor Red
    Write-Host "Consultez les points ECHEC ci-dessus et corrigez-les." -ForegroundColor Yellow
}
Write-Host "========================================" -ForegroundColor Cyan
