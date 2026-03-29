# Script de vérification - Exercice 01 : Exploration de la Structure AD
# Exécuter ce script pour vérifier si l'exercice est correctement complété
# Exécution : .\verif_exercice_01.ps1

Import-Module ActiveDirectory -ErrorAction SilentlyContinue

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Vérification Exercice 01 - Exploration Structure" -ForegroundColor Cyan
Write-Host "MonitoringTech SPRL - maxtec.be" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$erreurs = 0
$avertissements = 0

# -----------------------------------------------
# Test 1 : OU racine MONITORING existe
# -----------------------------------------------
Write-Host "`nTest 1 : OU racine MONITORING" -ForegroundColor Yellow
try {
    $ouRacine = Get-ADOrganizationalUnit -Filter { Name -eq "MONITORING" } -SearchBase "DC=maxtec,DC=be"
    if ($ouRacine) {
        Write-Host "  OK - OU MONITORING trouvée : $($ouRacine.DistinguishedName)" -ForegroundColor Green
    } else {
        Write-Host "  ECHEC - OU MONITORING introuvable dans DC=maxtec,DC=be" -ForegroundColor Red
        $erreurs++
    }
} catch {
    Write-Host "  ERREUR - $($_.Exception.Message)" -ForegroundColor Red
    $erreurs++
}

# -----------------------------------------------
# Test 2 : 4 départements présents
# -----------------------------------------------
Write-Host "`nTest 2 : Présence des 4 départements" -ForegroundColor Yellow
$departements = @("ITOperations", "Security", "RH", "Finance")
foreach ($dept in $departements) {
    try {
        $ou = Get-ADOrganizationalUnit -Filter { Name -eq $dept } `
            -SearchBase "OU=MONITORING,DC=maxtec,DC=be" -ErrorAction Stop
        Write-Host "  OK - Département $dept trouvé" -ForegroundColor Green
    } catch {
        Write-Host "  ECHEC - Département $dept introuvable" -ForegroundColor Red
        $erreurs++
    }
}

# -----------------------------------------------
# Test 3 : Chaque département a 5 utilisateurs
# -----------------------------------------------
Write-Host "`nTest 3 : Nombre d'utilisateurs par département (5 attendus)" -ForegroundColor Yellow
foreach ($dept in $departements) {
    try {
        $count = (Get-ADUser -Filter * -SearchBase "OU=Users,OU=$dept,OU=MONITORING,DC=maxtec,DC=be" -ErrorAction Stop).Count
        if ($count -eq 5) {
            Write-Host "  OK - $dept : $count utilisateur(s)" -ForegroundColor Green
        } else {
            Write-Host "  AVERTISSEMENT - $dept : $count utilisateur(s) (attendu : 5)" -ForegroundColor Yellow
            $avertissements++
        }
    } catch {
        Write-Host "  ECHEC - Impossible de lire les utilisateurs de $dept : $($_.Exception.Message)" -ForegroundColor Red
        $erreurs++
    }
}

# -----------------------------------------------
# Test 4 : Comptes de service présents
# -----------------------------------------------
Write-Host "`nTest 4 : Comptes de service dans OU=ServiceAccounts" -ForegroundColor Yellow
$comptesService = @("svc_monitoring", "svc_backup", "svc_audit", "svc_replication")
foreach ($svc in $comptesService) {
    try {
        $user = Get-ADUser -Identity $svc -ErrorAction Stop
        Write-Host "  OK - Compte $svc trouvé (Actif : $($user.Enabled))" -ForegroundColor Green
    } catch {
        Write-Host "  ECHEC - Compte $svc introuvable" -ForegroundColor Red
        $erreurs++
    }
}

# -----------------------------------------------
# Test 5 : Groupes GG- présents
# -----------------------------------------------
Write-Host "`nTest 5 : Groupes de sécurité GG- par département" -ForegroundColor Yellow
foreach ($dept in $departements) {
    $groupeUsers = "GG-MONITORING-$dept-Users"
    $groupeAdmin = "GG-MONITORING-$dept-Admin"

    foreach ($groupe in @($groupeUsers, $groupeAdmin)) {
        try {
            $grp = Get-ADGroup -Identity $groupe -ErrorAction Stop
            if ($grp.GroupScope -eq "Global") {
                Write-Host "  OK - $groupe (portée : Global)" -ForegroundColor Green
            } else {
                Write-Host "  AVERTISSEMENT - $groupe existe mais portée : $($grp.GroupScope) (attendu : Global)" -ForegroundColor Yellow
                $avertissements++
            }
        } catch {
            Write-Host "  ECHEC - Groupe $groupe introuvable" -ForegroundColor Red
            $erreurs++
        }
    }
}

# -----------------------------------------------
# Test 6 : Sous-OUs (Users, Computers, Groups) par département
# -----------------------------------------------
Write-Host "`nTest 6 : Sous-OUs (Users, Computers, Groups) par département" -ForegroundColor Yellow
$sousOUs = @("Users", "Computers", "Groups")
foreach ($dept in $departements) {
    foreach ($sousOU in $sousOUs) {
        try {
            $ou = Get-ADOrganizationalUnit -Filter { Name -eq $sousOU } `
                -SearchBase "OU=$dept,OU=MONITORING,DC=maxtec,DC=be" -ErrorAction Stop
            Write-Host "  OK - OU=$sousOU sous $dept trouvée" -ForegroundColor Green
        } catch {
            Write-Host "  ECHEC - OU=$sousOU sous $dept introuvable" -ForegroundColor Red
            $erreurs++
        }
    }
}

# -----------------------------------------------
# Résumé final
# -----------------------------------------------
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "RÉSUMÉ DE LA VÉRIFICATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($erreurs -eq 0 -and $avertissements -eq 0) {
    Write-Host "EXERCICE 01 RÉUSSI ! Tous les critères sont satisfaits." -ForegroundColor Green
} elseif ($erreurs -eq 0) {
    Write-Host "EXERCICE 01 PARTIELLEMENT RÉUSSI : $avertissements avertissement(s)." -ForegroundColor Yellow
    Write-Host "Consultez les avertissements ci-dessus." -ForegroundColor Yellow
} else {
    Write-Host "EXERCICE 01 INCOMPLET : $erreurs erreur(s) et $avertissements avertissement(s)." -ForegroundColor Red
    Write-Host "Consultez les points ECHEC ci-dessus et corrigez-les." -ForegroundColor Yellow
}
Write-Host "========================================" -ForegroundColor Cyan
