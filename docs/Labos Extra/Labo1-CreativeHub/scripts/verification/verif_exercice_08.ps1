# Script de vérification - Exercice 8
# Exécuter ce script pour vérifier si l'exercice est correctement complété

Import-Module ActiveDirectory
Import-Module GroupPolicy

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Vérification Exercice 8" -ForegroundColor Cyan
Write-Host "Troubleshooting GPO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$errors = 0
$warnings = 0

$gpoName = "CreativeHub - Restrictions Utilisateurs Juniors"
$groupName = "GG-CreativeHub-Juniors"
$expectedJuniors = @("elise", "damien", "julien")
$rootOU = "OU=CreativeHub,DC=maxtec,DC=be"

# Test 1: Vérifier que le groupe Juniors existe
Write-Host "`nTest 1: Existence du groupe GG-CreativeHub-Juniors" -ForegroundColor Yellow
try {
    $group = Get-ADGroup -Identity $groupName -ErrorAction Stop
    Write-Host "  ✓ RÉUSSI - Le groupe '$groupName' existe" -ForegroundColor Green
    Write-Host "    DN: $($group.DistinguishedName)" -ForegroundColor Gray
} catch {
    Write-Host "  ✗ ÉCHOUÉ: Le groupe '$groupName' n'existe pas" -ForegroundColor Red
    Write-Host "    Créez le groupe pour identifier les utilisateurs juniors" -ForegroundColor Yellow
    $errors++
    $group = $null
}

if ($group) {
    # Test 2: Vérifier les membres du groupe Juniors
    Write-Host "`nTest 2: Membres du groupe Juniors" -ForegroundColor Yellow
    try {
        $members = Get-ADGroupMember -Identity $groupName -ErrorAction Stop
        $membersSAM = $members | Select-Object -ExpandProperty SamAccountName

        Write-Host "  Membres actuels: $($membersSAM -join ', ')" -ForegroundColor Gray

        $missingJuniors = @()
        foreach ($expectedJunior in $expectedJuniors) {
            if ($membersSAM -contains $expectedJunior) {
                Write-Host "  ✓ $expectedJunior est membre" -ForegroundColor Green
            } else {
                Write-Host "  ✗ $expectedJunior est MANQUANT" -ForegroundColor Red
                $missingJuniors += $expectedJunior
            }
        }

        if ($missingJuniors.Count -eq 0) {
            Write-Host "  ✓ RÉUSSI - Tous les juniors attendus sont membres" -ForegroundColor Green
        } else {
            Write-Host "  ✗ ÉCHOUÉ: Juniors manquants: $($missingJuniors -join ', ')" -ForegroundColor Red
            Write-Host "    Ajoutez-les avec: Add-ADGroupMember -Identity $groupName -Members $($missingJuniors -join ',')" -ForegroundColor Yellow
            $errors++
        }

        # Vérifier qu'il n'y a pas de seniors dans le groupe
        $allUsers = @("hugo", "fabien", "gabrielle", "camille", "bastien", "amelie", "karine", "nicolas", "olivier", "pauline", "quentin", "rachid")
        $seniors = $allUsers | Where-Object {$expectedJuniors -notcontains $_}
        $wrongMembers = $membersSAM | Where-Object {$seniors -contains $_}

        if ($wrongMembers.Count -gt 0) {
            Write-Host "  ⚠ AVERTISSEMENT: Utilisateurs seniors incorrectement ajoutés au groupe" -ForegroundColor Yellow
            Write-Host "    Seniors détectés: $($wrongMembers -join ', ')" -ForegroundColor Yellow
            Write-Host "    Le groupe doit contenir UNIQUEMENT les juniors" -ForegroundColor Yellow
            $warnings++
        } else {
            Write-Host "  ✓ Aucun senior n'est incorrectement dans le groupe" -ForegroundColor Green
        }

    } catch {
        Write-Host "  ✗ ERREUR: Impossible de lire les membres du groupe" -ForegroundColor Red
        $errors++
    }
}

# Test 3: Vérifier que la GPO existe
Write-Host "`nTest 3: Existence de la GPO '$gpoName'" -ForegroundColor Yellow
try {
    $gpo = Get-GPO -Name $gpoName -ErrorAction Stop
    Write-Host "  ✓ RÉUSSI - La GPO existe" -ForegroundColor Green
    Write-Host "    GUID    : $($gpo.Id)" -ForegroundColor Gray
    Write-Host "    Statut  : $($gpo.GpoStatus)" -ForegroundColor Gray
} catch {
    Write-Host "  ✗ ÉCHOUÉ: La GPO '$gpoName' n'existe pas" -ForegroundColor Red
    Write-Host "    Vérifiez le nom de la GPO ou créez-la si nécessaire" -ForegroundColor Yellow
    $errors++
    $gpo = $null
}

if ($gpo) {
    # Test 4: Vérifier le FILTRAGE DE SÉCURITÉ (Security Filtering)
    Write-Host "`nTest 4: Filtrage de sécurité de la GPO" -ForegroundColor Yellow

    try {
        $permissions = Get-GPPermissions -Name $gpoName -All -ErrorAction Stop

        # Vérifier les permissions GpoApply
        $gpoApplyPermissions = $permissions | Where-Object {$_.Permission -eq "GpoApply"}

        Write-Host "  Entités avec permission GpoApply:" -ForegroundColor Gray
        foreach ($perm in $gpoApplyPermissions) {
            Write-Host "    - $($perm.Trustee.Name)" -ForegroundColor Gray
        }

        # Vérifier que "Authenticated Users" N'a PAS GpoApply
        $authUsersApply = $gpoApplyPermissions | Where-Object {$perm.Trustee.Name -eq "Authenticated Users"}
        if (-not $authUsersApply) {
            Write-Host "  ✓ RÉUSSI - 'Authenticated Users' n'a pas la permission GpoApply" -ForegroundColor Green
        } else {
            Write-Host "  ✗ ÉCHOUÉ: 'Authenticated Users' a encore la permission GpoApply" -ForegroundColor Red
            Write-Host "    La GPO s'appliquera à TOUS les utilisateurs, pas seulement aux juniors" -ForegroundColor Yellow
            Write-Host "    Retirez cette permission via GPMC ou avec Set-GPPermissions" -ForegroundColor Yellow
            $errors++
        }

        # Vérifier que le groupe Juniors A la permission GpoApply
        $juniorsApply = $gpoApplyPermissions | Where-Object {$_.Trustee.Name -like "*Juniors*"}
        if ($juniorsApply) {
            Write-Host "  ✓ RÉUSSI - Le groupe Juniors a la permission GpoApply" -ForegroundColor Green
            Write-Host "    La GPO ciblera uniquement les membres du groupe Juniors" -ForegroundColor Gray
        } else {
            Write-Host "  ✗ ÉCHOUÉ: Le groupe Juniors n'a pas la permission GpoApply" -ForegroundColor Red
            Write-Host "    La GPO ne s'appliquera pas au groupe cible !" -ForegroundColor Yellow
            Write-Host "    Ajoutez la permission: Set-GPPermissions -Name '$gpoName' -PermissionLevel GpoApply -TargetName '$groupName' -TargetType Group" -ForegroundColor Yellow
            $errors++
        }

        # Vérifier que le groupe a aussi la permission Lecture (Read)
        $juniorsRead = $permissions | Where-Object {
            $_.Trustee.Name -like "*Juniors*" -and
            ($_.Permission -eq "GpoRead" -or $_.Permission -eq "GpoApply")
        }

        if ($juniorsRead) {
            Write-Host "  ✓ Le groupe Juniors a les permissions de lecture nécessaires" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ AVERTISSEMENT: Permissions de lecture non détectées clairement" -ForegroundColor Yellow
            $warnings++
        }

    } catch {
        Write-Host "  ✗ ERREUR: Impossible de vérifier les permissions de la GPO" -ForegroundColor Red
        Write-Host "    $($_.Exception.Message)" -ForegroundColor Yellow
        $errors++
    }

    # Test 5: Vérifier les liens GPO
    Write-Host "`nTest 5: Liens de la GPO aux OUs" -ForegroundColor Yellow

    $expectedOUs = @(
        "OU=Users,OU=Creative,$rootOU",
        "OU=Users,OU=Marketing,$rootOU"
    )

    $linkErrors = 0
    foreach ($ouPath in $expectedOUs) {
        try {
            $inheritance = Get-GPInheritance -Target $ouPath -ErrorAction Stop
            $link = $inheritance.GpoLinks | Where-Object {$_.DisplayName -eq $gpoName}

            if ($link) {
                if ($link.Enabled -eq $true) {
                    Write-Host "  ✓ GPO liée ET activée sur $ouPath" -ForegroundColor Green
                } else {
                    Write-Host "  ✗ ÉCHOUÉ: GPO liée mais DÉSACTIVÉE sur $ouPath" -ForegroundColor Red
                    Write-Host "    Activez le lien avec: Set-GPLink -Name '$gpoName' -Target '$ouPath' -LinkEnabled Yes" -ForegroundColor Yellow
                    $linkErrors++
                }
            } else {
                Write-Host "  ✗ ÉCHOUÉ: GPO non liée à $ouPath" -ForegroundColor Red
                Write-Host "    Créez le lien avec: New-GPLink -Name '$gpoName' -Target '$ouPath' -LinkEnabled Yes" -ForegroundColor Yellow
                $linkErrors++
            }
        } catch {
            Write-Host "  ✗ ERREUR: Impossible de vérifier $ouPath" -ForegroundColor Red
            Write-Host "    $($_.Exception.Message)" -ForegroundColor Yellow
            $linkErrors++
        }
    }

    if ($linkErrors -gt 0) {
        $errors += $linkErrors
    } else {
        Write-Host "  ✓ RÉUSSI - GPO correctement liée aux 2 OUs" -ForegroundColor Green
    }

    # Test 6: Vérifier le contenu de la GPO (restrictions configurées)
    Write-Host "`nTest 6: Configuration des restrictions dans la GPO" -ForegroundColor Yellow

    try {
        [xml]$gpoReport = Get-GPOReport -Name $gpoName -ReportType Xml -ErrorAction Stop

        $hasNoControlPanel = $false
        $hasDisableCMD = $false

        # Parcourir les extensions de la GPO
        $userExtensions = $gpoReport.GPO.User.ExtensionData.Extension

        foreach ($extension in $userExtensions) {
            if ($extension.Policy) {
                foreach ($policy in $extension.Policy) {
                    # Rechercher NoControlPanel
                    if ($policy.Name -like "*Control Panel*" -or $policy.EditText -like "*NoControlPanel*") {
                        $hasNoControlPanel = $true
                    }
                    # Rechercher DisableCMD
                    if ($policy.Name -like "*Command Prompt*" -or $policy.Name -like "*invite de commandes*" -or $policy.EditText -like "*DisableCMD*") {
                        $hasDisableCMD = $true
                    }
                }
            }

            # Vérifier aussi dans RegistrySettings
            if ($extension.RegistrySettings) {
                foreach ($reg in $extension.RegistrySettings.Registry) {
                    if ($reg.Properties.name -eq "NoControlPanel") {
                        $hasNoControlPanel = $true
                    }
                    if ($reg.Properties.name -eq "DisableCMD") {
                        $hasDisableCMD = $true
                    }
                }
            }
        }

        if ($hasNoControlPanel) {
            Write-Host "  ✓ Restriction 'NoControlPanel' configurée" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ AVERTISSEMENT: Restriction 'NoControlPanel' non détectée" -ForegroundColor Yellow
            $warnings++
        }

        if ($hasDisableCMD) {
            Write-Host "  ✓ Restriction 'DisableCMD' configurée" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ AVERTISSEMENT: Restriction 'DisableCMD' non détectée" -ForegroundColor Yellow
            $warnings++
        }

    } catch {
        Write-Host "  ℹ INFO: Impossible d'analyser automatiquement le contenu de la GPO" -ForegroundColor Cyan
        Write-Host "    Vérifiez manuellement dans GPMC que les restrictions sont configurées" -ForegroundColor Cyan
    }
}

# Résumé final
Write-Host "`n========================================" -ForegroundColor Cyan

if ($errors -eq 0 -and $warnings -eq 0) {
    Write-Host "🎉 TROUBLESHOOTING RÉUSSI ! PARFAIT !" -ForegroundColor Green
    Write-Host "Tous les problèmes ont été correctement diagnostiqués et résolus." -ForegroundColor Green
    Write-Host "`nLa GPO s'appliquera maintenant UNIQUEMENT aux utilisateurs juniors !" -ForegroundColor White
    Write-Host "  ✓ Hugo (senior) n'aura PAS de restrictions" -ForegroundColor White
    Write-Host "  ✓ Julien (junior) aura les restrictions" -ForegroundColor White

} elseif ($errors -eq 0 -and $warnings -gt 0) {
    Write-Host "✓ TROUBLESHOOTING RÉUSSI (avec suggestions)" -ForegroundColor Green
    Write-Host "$warnings suggestion(s) d'amélioration - consultez les détails ci-dessus." -ForegroundColor Yellow
    Write-Host "Les éléments critiques sont corrects." -ForegroundColor Green

} else {
    Write-Host "❌ TROUBLESHOOTING INCOMPLET" -ForegroundColor Red
    Write-Host "$errors problème(s) critique(s) non résolu(s)." -ForegroundColor Red
    if ($warnings -gt 0) {
        Write-Host "$warnings avertissement(s) supplémentaire(s)." -ForegroundColor Yellow
    }
    Write-Host "Consultez les détails ci-dessus et corrigez les points échoués." -ForegroundColor Yellow
}

Write-Host "========================================" -ForegroundColor Cyan

# Récapitulatif de la configuration
Write-Host "`n📊 Récapitulatif de la configuration:" -ForegroundColor Cyan

if ($group) {
    Write-Host "`nGroupe Juniors:" -ForegroundColor Yellow
    Write-Host "  Nom    : $groupName" -ForegroundColor White
    try {
        $members = Get-ADGroupMember -Identity $groupName
        Write-Host "  Membres: $($members.Count)" -ForegroundColor White
        foreach ($member in $members) {
            $userInfo = Get-ADUser -Identity $member.SamAccountName -Properties Title, Department
            Write-Host "    - $($member.Name) ($($userInfo.Department) - $($userInfo.Title))" -ForegroundColor Gray
        }
    } catch {
        Write-Host "  Membres: Erreur de lecture" -ForegroundColor Red
    }
}

if ($gpo) {
    Write-Host "`nGPO:" -ForegroundColor Yellow
    Write-Host "  Nom     : $gpoName" -ForegroundColor White
    Write-Host "  Statut  : $($gpo.GpoStatus)" -ForegroundColor White

    try {
        $applyPerms = Get-GPPermissions -Name $gpoName -All | Where-Object {$_.Permission -eq "GpoApply"}
        Write-Host "  Cibles  : $($applyPerms.Trustee.Name -join ', ')" -ForegroundColor White
    } catch {
        Write-Host "  Cibles  : Erreur de lecture" -ForegroundColor Red
    }
}

Write-Host "`n🧪 Comment tester la solution:" -ForegroundColor Cyan
Write-Host "`n1. Sur le contrôleur de domaine:" -ForegroundColor White
Write-Host "   # Forcer la mise à jour des GPO (sur un client)" -ForegroundColor Gray
Write-Host "   gpupdate /force" -ForegroundColor Gray

Write-Host "`n2. Tester pour un utilisateur JUNIOR (Julien):" -ForegroundColor White
Write-Host "   # Voir les GPO appliquées" -ForegroundColor Gray
Write-Host "   gpresult /r /scope:user /user:julien" -ForegroundColor Gray
Write-Host "   # La GPO '$gpoName' DOIT apparaître" -ForegroundColor Gray

Write-Host "`n3. Tester pour un utilisateur SENIOR (Hugo):" -ForegroundColor White
Write-Host "   # Voir les GPO appliquées" -ForegroundColor Gray
Write-Host "   gpresult /r /scope:user /user:hugo" -ForegroundColor Gray
Write-Host "   # La GPO '$gpoName' NE DOIT PAS apparaître" -ForegroundColor Gray

Write-Host "`n4. Générer un rapport détaillé:" -ForegroundColor White
Write-Host "   gpresult /h C:\Temp\gpresult_julien.html /user:julien" -ForegroundColor Gray

Write-Host "`n📚 Leçons apprises:" -ForegroundColor Cyan
Write-Host "  1. Le filtrage de sécurité permet de cibler des groupes spécifiques" -ForegroundColor Gray
Write-Host "  2. Par défaut, les GPO s'appliquent à 'Authenticated Users'" -ForegroundColor Gray
Write-Host "  3. Un groupe doit avoir 'GpoApply' ET 'GpoRead' pour recevoir une GPO" -ForegroundColor Gray
Write-Host "  4. Les liens GPO peuvent être désactivés sans supprimer le lien" -ForegroundColor Gray
Write-Host "  5. Toujours tester avec gpresult après une modification de GPO" -ForegroundColor Gray

Write-Host "`n🔍 Méthodologie de troubleshooting GPO:" -ForegroundColor Cyan
Write-Host "  1. Vérifier que la GPO existe" -ForegroundColor Gray
Write-Host "  2. Vérifier les paramètres de la GPO" -ForegroundColor Gray
Write-Host "  3. Vérifier les liens GPO (existence et état)" -ForegroundColor Gray
Write-Host "  4. Vérifier le filtrage de sécurité" -ForegroundColor Gray
Write-Host "  5. Vérifier l'héritage et les blocages" -ForegroundColor Gray
Write-Host "  6. Forcer l'application avec gpupdate /force" -ForegroundColor Gray
Write-Host "  7. Tester avec gpresult" -ForegroundColor Gray
