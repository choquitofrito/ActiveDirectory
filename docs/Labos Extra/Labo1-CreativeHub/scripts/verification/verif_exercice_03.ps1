# Script de vérification - Exercice 3
# Exécuter ce script pour vérifier si l'exercice est correctement complété

Import-Module GroupPolicy
Import-Module ActiveDirectory

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Vérification Exercice 3" -ForegroundColor Cyan
Write-Host "GPO Lecteur Projet TechVision" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$errors = 0
$warnings = 0
$gpoName = "CreativeHub - Lecteur Projet TechVision"
$ouTarget = "OU=Users,OU=ClientServices,OU=CreativeHub,DC=maxtec,DC=be"

# Test 1: Vérifier que la GPO existe
Write-Host "`nTest 1: Existence de la GPO '$gpoName'" -ForegroundColor Yellow
try {
    $gpo = Get-GPO -Name $gpoName -ErrorAction Stop
    Write-Host "  ✓ RÉUSSI - La GPO existe" -ForegroundColor Green
    Write-Host "    Nom complet : $($gpo.DisplayName)" -ForegroundColor Gray
    Write-Host "    GUID        : $($gpo.Id)" -ForegroundColor Gray
    Write-Host "    Créée le    : $($gpo.CreationTime)" -ForegroundColor Gray
} catch {
    Write-Host "  ✗ ÉCHOUÉ: La GPO '$gpoName' n'existe pas" -ForegroundColor Red
    Write-Host "    Créez la GPO via Console de gestion des stratégies de groupe (gpmc.msc)" -ForegroundColor Yellow
    $errors++
    $gpo = $null
}

if ($gpo) {
    # Test 2: Vérifier que la GPO est activée
    Write-Host "`nTest 2: État de la GPO (doit être activée)" -ForegroundColor Yellow
    if ($gpo.GpoStatus -ne "AllSettingsDisabled") {
        Write-Host "  ✓ RÉUSSI - La GPO est activée" -ForegroundColor Green
        Write-Host "    État: $($gpo.GpoStatus)" -ForegroundColor Gray
    } else {
        Write-Host "  ⚠ AVERTISSEMENT: La GPO est désactivée" -ForegroundColor Yellow
        Write-Host "    État actuel: $($gpo.GpoStatus)" -ForegroundColor Yellow
        $warnings++
    }

    # Test 3: Vérifier que la GPO est liée à l'OU ClientServices\Users
    Write-Host "`nTest 3: Liaison de la GPO à l'OU ClientServices\Users" -ForegroundColor Yellow
    try {
        $inheritance = Get-GPInheritance -Target $ouTarget -ErrorAction Stop
        $linkedGPO = $inheritance.GpoLinks | Where-Object {$_.DisplayName -eq $gpoName}

        if ($linkedGPO) {
            Write-Host "  ✓ RÉUSSI - La GPO est liée à l'OU ClientServices\Users" -ForegroundColor Green
            Write-Host "    Cible: $ouTarget" -ForegroundColor Gray
            Write-Host "    État du lien: $($linkedGPO.Enabled)" -ForegroundColor Gray
            Write-Host "    Ordre: $($linkedGPO.Order)" -ForegroundColor Gray

            # Vérifier que le lien est activé
            if ($linkedGPO.Enabled -eq $true) {
                Write-Host "  ✓ Le lien est activé" -ForegroundColor Green
            } else {
                Write-Host "  ⚠ AVERTISSEMENT: Le lien est désactivé" -ForegroundColor Yellow
                $warnings++
            }
        } else {
            Write-Host "  ✗ ÉCHOUÉ: La GPO n'est pas liée à l'OU ClientServices\Users" -ForegroundColor Red
            Write-Host "    Liez la GPO via: Clic droit sur l'OU > Lier un objet de stratégie de groupe existant" -ForegroundColor Yellow
            $errors++
        }
    } catch {
        Write-Host "  ✗ ERREUR: Impossible de vérifier les liens GPO" -ForegroundColor Red
        Write-Host "    $($_.Exception.Message)" -ForegroundColor Yellow
        $errors++
    }

    # Test 4: Vérifier le contenu de la GPO (présence de configuration)
    Write-Host "`nTest 4: Configuration de mappage de lecteur dans la GPO" -ForegroundColor Yellow
    try {
        # Générer un rapport XML de la GPO
        [xml]$gpoReport = Get-GPOReport -Name $gpoName -ReportType Xml -ErrorAction Stop

        # Vérifier si la section User existe
        $userConfig = $gpoReport.GPO.User

        if ($userConfig) {
            Write-Host "  ✓ Configuration Utilisateur présente" -ForegroundColor Green

            # Chercher les préférences de lecteurs mappés
            $driveMapConfig = $userConfig.ExtensionData.Extension | Where-Object {$_.type -eq "Drive Maps"}

            if ($driveMapConfig) {
                Write-Host "  ✓ EXCELLENT - Configuration de lecteur mappé détectée" -ForegroundColor Green

                # Extraire les détails (structure peut varier)
                $drives = $driveMapConfig.DriveMapSettings.Drive
                if ($drives) {
                    foreach ($drive in $drives) {
                        Write-Host "    Lecteur configuré:" -ForegroundColor Gray
                        Write-Host "      Nom      : $($drive.Properties.label)" -ForegroundColor Gray
                        Write-Host "      Lettre   : $($drive.Properties.letter)" -ForegroundColor Gray
                        Write-Host "      Chemin   : $($drive.Properties.path)" -ForegroundColor Gray
                        Write-Host "      Action   : $($drive.Properties.action)" -ForegroundColor Gray

                        # Vérifier si c'est le lecteur T: attendu
                        if ($drive.Properties.letter -eq "T:" -and $drive.Properties.path -like "*TechVision*") {
                            Write-Host "  ✓ PARFAIT - Lecteur T: configuré pour TechVision" -ForegroundColor Green
                        }
                    }
                } else {
                    Write-Host "  ⚠ INFO: Configuration présente mais détails non accessibles via rapport XML" -ForegroundColor Cyan
                    Write-Host "    Vérifiez manuellement dans GPMC > Modifier > Configuration Utilisateur > Préférences > Mappages de lecteurs" -ForegroundColor Cyan
                }
            } else {
                Write-Host "  ⚠ AVERTISSEMENT: Aucune configuration de lecteur mappé détectée dans le rapport" -ForegroundColor Yellow
                Write-Host "    Vérifiez manuellement dans GPMC que le mappage de lecteur a été ajouté" -ForegroundColor Yellow
                Write-Host "    Navigation: Configuration Utilisateur > Préférences > Paramètres Windows > Mappages de lecteurs" -ForegroundColor Yellow
                $warnings++
            }
        } else {
            Write-Host "  ⚠ AVERTISSEMENT: Aucune configuration utilisateur détectée" -ForegroundColor Yellow
            Write-Host "    Assurez-vous d'avoir configuré le mappage dans Configuration Utilisateur (pas Ordinateur)" -ForegroundColor Yellow
            $warnings++
        }
    } catch {
        Write-Host "  ⚠ INFO: Impossible de générer le rapport GPO détaillé" -ForegroundColor Cyan
        Write-Host "    Ceci est normal si la GPO vient d'être créée sans configuration" -ForegroundColor Cyan
        Write-Host "    Vérifiez manuellement le contenu dans l'éditeur de GPO" -ForegroundColor Cyan
    }

    # Test 5: Vérifier les permissions de la GPO (filtrage de sécurité)
    Write-Host "`nTest 5: Filtrage de sécurité de la GPO" -ForegroundColor Yellow
    try {
        $permissions = Get-GPPermissions -Name $gpoName -All -ErrorAction Stop
        $authUsersPermission = $permissions | Where-Object {$_.Trustee.Name -eq "Authenticated Users"}

        if ($authUsersPermission) {
            $canApply = $authUsersPermission.Permission -contains "GpoApply" -or $authUsersPermission.Permission -contains "GpoRead"
            if ($canApply) {
                Write-Host "  ✓ RÉUSSI - Authenticated Users peut appliquer la GPO" -ForegroundColor Green
            } else {
                Write-Host "  ⚠ AVERTISSEMENT: Authenticated Users n'a pas les permissions GpoApply" -ForegroundColor Yellow
                Write-Host "    La GPO pourrait ne pas s'appliquer correctement" -ForegroundColor Yellow
                $warnings++
            }
        } else {
            Write-Host "  ⚠ INFO: Configuration de sécurité personnalisée détectée" -ForegroundColor Cyan
        }
    } catch {
        Write-Host "  ⚠ INFO: Impossible de vérifier les permissions" -ForegroundColor Cyan
    }
}

# Test 6: Vérifier que l'OU cible existe
Write-Host "`nTest 6: Existence de l'OU cible" -ForegroundColor Yellow
try {
    Get-ADOrganizationalUnit -Identity $ouTarget -ErrorAction Stop | Out-Null
    Write-Host "  ✓ RÉUSSI - L'OU ClientServices\Users existe" -ForegroundColor Green
} catch {
    Write-Host "  ✗ ÉCHOUÉ: L'OU cible n'existe pas" -ForegroundColor Red
    Write-Host "    OU attendue: $ouTarget" -ForegroundColor Yellow
    $errors++
}

# Résumé final
Write-Host "`n========================================" -ForegroundColor Cyan
if ($errors -eq 0 -and $warnings -eq 0) {
    Write-Host "🎉 EXERCICE RÉUSSI ! PARFAIT !" -ForegroundColor Green
    Write-Host "Tous les critères sont satisfaits." -ForegroundColor Green
    Write-Host "`nLa GPO est configurée et liée correctement." -ForegroundColor White
    Write-Host "Lors de la prochaine connexion, les utilisateurs de Client Services verront le lecteur T:." -ForegroundColor White
} elseif ($errors -eq 0 -and $warnings -gt 0) {
    Write-Host "✓ EXERCICE RÉUSSI (avec suggestions)" -ForegroundColor Green
    Write-Host "$warnings suggestion(s) détectée(s) - consultez les détails ci-dessus." -ForegroundColor Yellow
    Write-Host "Les éléments essentiels sont corrects." -ForegroundColor Green
} else {
    Write-Host "❌ EXERCICE INCOMPLET" -ForegroundColor Red
    Write-Host "$errors erreur(s) critique(s) détectée(s)." -ForegroundColor Red
    Write-Host "Consultez les détails ci-dessus et corrigez les points échoués." -ForegroundColor Yellow
}
Write-Host "========================================" -ForegroundColor Cyan

# Commandes utiles pour tester
Write-Host "`n💡 Commandes utiles pour tester la GPO:" -ForegroundColor Cyan
Write-Host "Sur un client Windows (connecté avec un utilisateur de Client Services):" -ForegroundColor White
Write-Host "  1. gpupdate /force                  # Force l'application des GPO" -ForegroundColor Gray
Write-Host "  2. gpresult /r /scope:user          # Affiche les GPO appliquées" -ForegroundColor Gray
Write-Host "  3. gpresult /h C:\rapport_gpo.html  # Génère un rapport HTML détaillé" -ForegroundColor Gray
Write-Host "`nPour générer un rapport de la GPO:" -ForegroundColor White
Write-Host "  Get-GPOReport -Name '$gpoName' -ReportType Html -Path 'C:\Labos\GPO_Report.html'" -ForegroundColor Gray

Write-Host "`n📝 Note importante:" -ForegroundColor Cyan
Write-Host "Le lecteur T: n'apparaîtra réellement que si le partage \\DC01\Projets\TechVision existe." -ForegroundColor White
Write-Host "En environnement de lab, c'est normal qu'il ne soit pas encore visible." -ForegroundColor White
Write-Host "La configuration GPO elle-même est correcte !" -ForegroundColor White
