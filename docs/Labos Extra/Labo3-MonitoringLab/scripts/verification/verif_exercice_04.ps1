# Script de vérification - Exercice 04 : Gestion des Comptes de Service
# Exécuter ce script pour vérifier si l'exercice est correctement complété
# Exécution : .\verif_exercice_04.ps1

Import-Module ActiveDirectory -ErrorAction SilentlyContinue

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Vérification Exercice 04 - Comptes de Service" -ForegroundColor Cyan
Write-Host "MonitoringTech SPRL - maxtec.be" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$erreurs = 0
$avertissements = 0
$baseOU = "OU=ServiceAccounts,OU=MONITORING,DC=maxtec,DC=be"
$comptesService = @("svc_monitoring", "svc_backup", "svc_audit", "svc_replication")

# -----------------------------------------------
# Test 1 : Descriptions mises à jour
# -----------------------------------------------
Write-Host "`nTest 1 : Descriptions des comptes de service" -ForegroundColor Yellow
foreach ($svc in $comptesService) {
    try {
        $user = Get-ADUser -Identity $svc -Properties Description -ErrorAction Stop
        if ($user.Description -and $user.Description.Length -gt 20) {
            Write-Host "  OK - $svc : Description présente ($($user.Description.Substring(0, [Math]::Min(60, $user.Description.Length)))...)" -ForegroundColor Green
        } else {
            Write-Host "  ECHEC - $svc : Description absente ou trop courte (attendu : > 20 caractères)" -ForegroundColor Red
            $erreurs++
        }
    } catch {
        Write-Host "  ERREUR - $svc introuvable : $($_.Exception.Message)" -ForegroundColor Red
        $erreurs++
    }
}

# -----------------------------------------------
# Test 2 : Adresses email configurées
# -----------------------------------------------
Write-Host "`nTest 2 : Adresses email des comptes de service" -ForegroundColor Yellow
foreach ($svc in $comptesService) {
    try {
        $user = Get-ADUser -Identity $svc -Properties EmailAddress -ErrorAction Stop
        if ($user.EmailAddress -and $user.EmailAddress -like "*@*") {
            Write-Host "  OK - $svc : $($user.EmailAddress)" -ForegroundColor Green
        } else {
            Write-Host "  AVERTISSEMENT - $svc : Adresse email absente" -ForegroundColor Yellow
            $avertissements++
        }
    } catch {
        Write-Host "  ERREUR - $($_.Exception.Message)" -ForegroundColor Red
        $erreurs++
    }
}

# -----------------------------------------------
# Test 3 : Groupe GG-MONITORING-ServiceAccounts
# -----------------------------------------------
Write-Host "`nTest 3 : Groupe GG-MONITORING-ServiceAccounts" -ForegroundColor Yellow
$groupName = "GG-MONITORING-ServiceAccounts"
try {
    $group = Get-ADGroup -Identity $groupName -Properties Members -ErrorAction Stop

    # Vérifier la portée
    if ($group.GroupScope -eq "Global") {
        Write-Host "  OK - Groupe $groupName existe (portée : Global)" -ForegroundColor Green
    } else {
        Write-Host "  ECHEC - Groupe $groupName : portée $($group.GroupScope) (attendu : Global)" -ForegroundColor Red
        $erreurs++
    }

    # Vérifier le type
    if ($group.GroupCategory -eq "Security") {
        Write-Host "  OK - Type : Sécurité" -ForegroundColor Green
    } else {
        Write-Host "  ECHEC - Type : $($group.GroupCategory) (attendu : Security)" -ForegroundColor Red
        $erreurs++
    }

    # Vérifier les membres
    $membres = Get-ADGroupMember -Identity $groupName -ErrorAction Stop
    $membresNoms = $membres | Select-Object -ExpandProperty SamAccountName

    foreach ($svc in $comptesService) {
        if ($membresNoms -contains $svc) {
            Write-Host "  OK - $svc est membre de $groupName" -ForegroundColor Green
        } else {
            Write-Host "  ECHEC - $svc n'est PAS membre de $groupName" -ForegroundColor Red
            $erreurs++
        }
    }

} catch {
    Write-Host "  ECHEC - Groupe $groupName introuvable" -ForegroundColor Red
    Write-Host "  Erreur : $($_.Exception.Message)" -ForegroundColor Red
    $erreurs++
}

# -----------------------------------------------
# Test 4 : svc_audit dans Event Log Readers
# -----------------------------------------------
Write-Host "`nTest 4 : svc_audit dans le groupe Event Log Readers" -ForegroundColor Yellow
try {
    $elrMembers = Get-ADGroupMember "Event Log Readers" -ErrorAction Stop |
        Select-Object -ExpandProperty SamAccountName

    if ($elrMembers -contains "svc_audit") {
        Write-Host "  OK - svc_audit est membre de Event Log Readers" -ForegroundColor Green
    } else {
        Write-Host "  ECHEC - svc_audit n'est PAS membre de Event Log Readers" -ForegroundColor Red
        $erreurs++
    }
} catch {
    Write-Host "  ERREUR - Impossible de vérifier Event Log Readers : $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  Conseil : Essayez avec le nom français 'Lecteurs du journal des événements'" -ForegroundColor Yellow
    $erreurs++
}

# -----------------------------------------------
# Test 5 : PasswordNeverExpires configuré
# -----------------------------------------------
Write-Host "`nTest 5 : Options de sécurité des comptes de service" -ForegroundColor Yellow
foreach ($svc in $comptesService) {
    try {
        $user = Get-ADUser -Identity $svc -Properties PasswordNeverExpires, CannotChangePassword -ErrorAction Stop

        if ($user.PasswordNeverExpires) {
            Write-Host "  OK - $svc : PasswordNeverExpires = True" -ForegroundColor Green
        } else {
            Write-Host "  ECHEC - $svc : PasswordNeverExpires = False (doit être True)" -ForegroundColor Red
            $erreurs++
        }

        if ($user.CannotChangePassword) {
            Write-Host "  OK - $svc : CannotChangePassword = True" -ForegroundColor Green
        } else {
            Write-Host "  AVERTISSEMENT - $svc : CannotChangePassword = False (recommandé : True)" -ForegroundColor Yellow
            $avertissements++
        }
    } catch {
        Write-Host "  ERREUR - $($_.Exception.Message)" -ForegroundColor Red
        $erreurs++
    }
}

# -----------------------------------------------
# Test 6 : Comptes de service dans la bonne OU
# -----------------------------------------------
Write-Host "`nTest 6 : Localisation des comptes dans OU=ServiceAccounts" -ForegroundColor Yellow
foreach ($svc in $comptesService) {
    try {
        $user = Get-ADUser -Identity $svc -Properties DistinguishedName -ErrorAction Stop
        if ($user.DistinguishedName -like "*ServiceAccounts*") {
            Write-Host "  OK - $svc est dans l'OU ServiceAccounts" -ForegroundColor Green
        } else {
            Write-Host "  AVERTISSEMENT - $svc n'est pas dans OU=ServiceAccounts : $($user.DistinguishedName)" -ForegroundColor Yellow
            $avertissements++
        }
    } catch {
        Write-Host "  ERREUR - $($_.Exception.Message)" -ForegroundColor Red
        $erreurs++
    }
}

# -----------------------------------------------
# Résumé final
# -----------------------------------------------
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "RÉSUMÉ DE LA VÉRIFICATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($erreurs -eq 0 -and $avertissements -eq 0) {
    Write-Host "EXERCICE 04 RÉUSSI ! Tous les critères sont satisfaits." -ForegroundColor Green
} elseif ($erreurs -eq 0) {
    Write-Host "EXERCICE 04 PARTIELLEMENT RÉUSSI : $avertissements avertissement(s)." -ForegroundColor Yellow
    Write-Host "Consultez les avertissements ci-dessus pour optimiser votre configuration." -ForegroundColor Yellow
} else {
    Write-Host "EXERCICE 04 INCOMPLET : $erreurs erreur(s) et $avertissements avertissement(s)." -ForegroundColor Red
    Write-Host "Consultez les points ECHEC ci-dessus et corrigez-les." -ForegroundColor Yellow
}
Write-Host "========================================" -ForegroundColor Cyan
