# Script de vérification - Exercice 6
# Exécuter ce script pour vérifier si l'exercice est correctement complété

Import-Module ActiveDirectory

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Vérification Exercice 6" -ForegroundColor Cyan
Write-Host "Délégation de Contrôle" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$errors = 0
$warnings = 0

# Variables
$domainDN = "DC=maxtec,DC=be"
$ouCreativeUsers = "OU=Users,OU=Creative,OU=CreativeHub,$domainDN"
$ouMarketingUsers = "OU=Users,OU=Marketing,OU=CreativeHub,$domainDN"

# Vérifier que les utilisateurs existent
Write-Host "`nVérification préliminaire des utilisateurs..." -ForegroundColor Yellow

try {
    $gabrielle = Get-ADUser -Identity gabrielle -ErrorAction Stop
    Write-Host "  ✓ Utilisateur 'gabrielle' trouvé" -ForegroundColor Green
} catch {
    Write-Host "  ✗ ERREUR: Utilisateur 'gabrielle' introuvable" -ForegroundColor Red
    $errors++
    $gabrielle = $null
}

try {
    $camille = Get-ADUser -Identity camille -ErrorAction Stop
    Write-Host "  ✓ Utilisateur 'camille' trouvé" -ForegroundColor Green
} catch {
    Write-Host "  ✗ ERREUR: Utilisateur 'camille' introuvable" -ForegroundColor Red
    $errors++
    $camille = $null
}

# Test 1: Vérifier les permissions de Gabrielle sur l'OU Creative
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Test 1: Permissions de Gabrielle (Creative)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($gabrielle) {
    try {
        $aclCreative = Get-Acl "AD:$ouCreativeUsers" -ErrorAction Stop
        $gabriellePermissions = $aclCreative.Access | Where-Object {
            $_.IdentityReference -like "*gabrielle*" -or
            $_.IdentityReference.Value -eq $gabrielle.SID.Value
        }

        if ($gabriellePermissions) {
            Write-Host "  ✓ Gabrielle a des permissions sur l'OU Creative\Users" -ForegroundColor Green
            Write-Host "`n  Détail des permissions:" -ForegroundColor Gray

            $hasResetPassword = $false
            $hasCreateUser = $false

            foreach ($perm in $gabriellePermissions) {
                Write-Host "    - $($perm.ActiveDirectoryRights) ($($perm.AccessControlType))" -ForegroundColor Gray

                # Vérifier si la permission de réinitialisation de mot de passe est présente
                if ($perm.ActiveDirectoryRights -like "*ExtendedRight*" -or
                    $perm.ActiveDirectoryRights -like "*GenericAll*" -or
                    $perm.ActiveDirectoryRights -like "*WriteDacl*") {
                    $hasResetPassword = $true
                }

                # Vérifier si la permission de création d'utilisateur est présente
                if ($perm.ActiveDirectoryRights -like "*CreateChild*" -or
                    $perm.ActiveDirectoryRights -like "*GenericAll*") {
                    $hasCreateUser = $true
                }
            }

            # Vérifier que Gabrielle PEUT réinitialiser les mots de passe
            Write-Host "`n  Analyse des droits:" -ForegroundColor Yellow
            if ($hasResetPassword) {
                Write-Host "    ✓ Gabrielle peut réinitialiser les mots de passe" -ForegroundColor Green
            } else {
                Write-Host "    ⚠ AVERTISSEMENT: Permission de réinitialisation de MDP non détectée clairement" -ForegroundColor Yellow
                Write-Host "      Cela peut être normal si les permissions sont implicites" -ForegroundColor Gray
                $warnings++
            }

            # Vérifier que Gabrielle NE PEUT PAS créer des utilisateurs
            if ($hasCreateUser) {
                Write-Host "    ⚠ ATTENTION: Gabrielle semble avoir le droit de créer des utilisateurs" -ForegroundColor Yellow
                Write-Host "      Selon les instructions, elle ne devrait PAS pouvoir créer d'utilisateurs" -ForegroundColor Yellow
                $warnings++
            } else {
                Write-Host "    ✓ Gabrielle ne peut pas créer d'utilisateurs (correct)" -ForegroundColor Green
            }

        } else {
            Write-Host "  ✗ ÉCHOUÉ: Aucune permission trouvée pour Gabrielle sur l'OU Creative\Users" -ForegroundColor Red
            Write-Host "    Utilisez l'Assistant Délégation de contrôle (Clic droit sur l'OU > Déléguer le contrôle)" -ForegroundColor Yellow
            $errors++
        }
    } catch {
        Write-Host "  ✗ ERREUR: Impossible de lire les permissions de l'OU Creative" -ForegroundColor Red
        Write-Host "    $($_.Exception.Message)" -ForegroundColor Yellow
        $errors++
    }
}

# Test 2: Vérifier les permissions de Camille sur l'OU Marketing
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Test 2: Permissions de Camille (Marketing)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($camille) {
    try {
        $aclMarketing = Get-Acl "AD:$ouMarketingUsers" -ErrorAction Stop
        $camillePermissions = $aclMarketing.Access | Where-Object {
            $_.IdentityReference -like "*camille*" -or
            $_.IdentityReference.Value -eq $camille.SID.Value
        }

        if ($camillePermissions) {
            Write-Host "  ✓ Camille a des permissions sur l'OU Marketing\Users" -ForegroundColor Green
            Write-Host "`n  Détail des permissions:" -ForegroundColor Gray

            $hasCreateUser = $false
            $hasWriteProperties = $false
            $hasResetPassword = $false

            foreach ($perm in $camillePermissions) {
                Write-Host "    - $($perm.ActiveDirectoryRights) ($($perm.AccessControlType))" -ForegroundColor Gray

                # Vérifier les permissions de création
                if ($perm.ActiveDirectoryRights -like "*CreateChild*" -or
                    $perm.ActiveDirectoryRights -like "*GenericAll*") {
                    $hasCreateUser = $true
                }

                # Vérifier les permissions d'écriture
                if ($perm.ActiveDirectoryRights -like "*WriteProperty*" -or
                    $perm.ActiveDirectoryRights -like "*GenericAll*" -or
                    $perm.ActiveDirectoryRights -like "*GenericWrite*") {
                    $hasWriteProperties = $true
                }

                # Vérifier les permissions de réinitialisation de MDP
                if ($perm.ActiveDirectoryRights -like "*ExtendedRight*" -or
                    $perm.ActiveDirectoryRights -like "*GenericAll*") {
                    $hasResetPassword = $true
                }
            }

            # Analyser les droits
            Write-Host "`n  Analyse des droits:" -ForegroundColor Yellow

            if ($hasCreateUser) {
                Write-Host "    ✓ Camille peut créer des utilisateurs" -ForegroundColor Green
            } else {
                Write-Host "    ✗ ÉCHOUÉ: Camille ne semble pas pouvoir créer d'utilisateurs" -ForegroundColor Red
                Write-Host "      Déléguez la tâche 'Créer, supprimer et gérer les comptes utilisateurs'" -ForegroundColor Yellow
                $errors++
            }

            if ($hasWriteProperties) {
                Write-Host "    ✓ Camille peut modifier les propriétés des utilisateurs" -ForegroundColor Green
            } else {
                Write-Host "    ⚠ AVERTISSEMENT: Permission de modification non détectée clairement" -ForegroundColor Yellow
                $warnings++
            }

            if ($hasResetPassword) {
                Write-Host "    ✓ Camille peut réinitialiser les mots de passe" -ForegroundColor Green
            } else {
                Write-Host "    ⚠ AVERTISSEMENT: Permission de réinitialisation de MDP non détectée clairement" -ForegroundColor Yellow
                $warnings++
            }

        } else {
            Write-Host "  ✗ ÉCHOUÉ: Aucune permission trouvée pour Camille sur l'OU Marketing\Users" -ForegroundColor Red
            Write-Host "    Utilisez l'Assistant Délégation de contrôle (Clic droit sur l'OU > Déléguer le contrôle)" -ForegroundColor Yellow
            $errors++
        }
    } catch {
        Write-Host "  ✗ ERREUR: Impossible de lire les permissions de l'OU Marketing" -ForegroundColor Red
        Write-Host "    $($_.Exception.Message)" -ForegroundColor Yellow
        $errors++
    }
}

# Test 3: Vérifier que les permissions ne s'étendent pas aux autres OUs
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Test 3: Isolation des permissions" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($gabrielle) {
    try {
        # Vérifier que Gabrielle n'a PAS de permissions sur Marketing
        $aclMarketing = Get-Acl "AD:$ouMarketingUsers" -ErrorAction Stop
        $gabrielleOnMarketing = $aclMarketing.Access | Where-Object {
            $_.IdentityReference -like "*gabrielle*" -or
            $_.IdentityReference.Value -eq $gabrielle.SID.Value
        }

        if (-not $gabrielleOnMarketing) {
            Write-Host "  ✓ Gabrielle n'a pas de permissions sur Marketing (bonne isolation)" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ AVERTISSEMENT: Gabrielle a des permissions sur Marketing" -ForegroundColor Yellow
            Write-Host "    Les permissions devraient être limitées à Creative uniquement" -ForegroundColor Yellow
            $warnings++
        }
    } catch {
        Write-Host "  ⚠ INFO: Impossible de vérifier l'isolation" -ForegroundColor Cyan
    }
}

if ($camille) {
    try {
        # Vérifier que Camille n'a PAS de permissions sur Creative
        $aclCreative = Get-Acl "AD:$ouCreativeUsers" -ErrorAction Stop
        $camilleOnCreative = $aclCreative.Access | Where-Object {
            $_.IdentityReference -like "*camille*" -or
            $_.IdentityReference.Value -eq $camille.SID.Value
        }

        if (-not $camilleOnCreative) {
            Write-Host "  ✓ Camille n'a pas de permissions sur Creative (bonne isolation)" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ AVERTISSEMENT: Camille a des permissions sur Creative" -ForegroundColor Yellow
            Write-Host "    Les permissions devraient être limitées à Marketing uniquement" -ForegroundColor Yellow
            $warnings++
        }
    } catch {
        Write-Host "  ⚠ INFO: Impossible de vérifier l'isolation" -ForegroundColor Cyan
    }
}

# Résumé final
Write-Host "`n========================================" -ForegroundColor Cyan
if ($errors -eq 0 -and $warnings -eq 0) {
    Write-Host "🎉 EXERCICE RÉUSSI ! PARFAIT !" -ForegroundColor Green
    Write-Host "Tous les critères sont satisfaits." -ForegroundColor Green
    Write-Host "`nLa délégation de contrôle est correctement configurée." -ForegroundColor White
    Write-Host "Gabrielle et Camille peuvent maintenant gérer leurs départements respectifs !" -ForegroundColor White
} elseif ($errors -eq 0 -and $warnings -gt 0) {
    Write-Host "✓ EXERCICE RÉUSSI (avec avertissements)" -ForegroundColor Green
    Write-Host "$warnings avertissement(s) détecté(s) - consultez les détails ci-dessus." -ForegroundColor Yellow
    Write-Host "Les éléments essentiels sont corrects." -ForegroundColor Green
    Write-Host "`nNote: L'analyse automatique des permissions AD est complexe." -ForegroundColor Cyan
    Write-Host "Testez manuellement les permissions pour une validation complète." -ForegroundColor Cyan
} else {
    Write-Host "❌ EXERCICE INCOMPLET" -ForegroundColor Red
    Write-Host "$errors erreur(s) critique(s) détectée(s)." -ForegroundColor Red
    Write-Host "Consultez les détails ci-dessus et corrigez les points échoués." -ForegroundColor Yellow
}
Write-Host "========================================" -ForegroundColor Cyan

# Guide de test manuel
Write-Host "`n💡 Comment tester manuellement la délégation:" -ForegroundColor Cyan
Write-Host "`n1. Test pour Gabrielle (Creative):" -ForegroundColor White
Write-Host "   a) Ouvrir PowerShell en tant qu'administrateur" -ForegroundColor Gray
Write-Host "   b) Exécuter:" -ForegroundColor Gray
Write-Host "      `$cred = Get-Credential -UserName 'MAXTEC\gabrielle'" -ForegroundColor Gray
Write-Host "      Set-ADAccountPassword -Identity fabien -NewPassword (ConvertTo-SecureString 'Test123!' -AsPlainText -Force) -Reset -Credential `$cred" -ForegroundColor Gray
Write-Host "   c) Si cela fonctionne : Délégation OK" -ForegroundColor Gray
Write-Host "   d) Tester création d'utilisateur (devrait échouer):" -ForegroundColor Gray
Write-Host "      New-ADUser -Name 'Test' -SamAccountName 'test' -Path '$ouCreativeUsers' -Credential `$cred" -ForegroundColor Gray
Write-Host "   e) Doit renvoyer 'Accès refusé'" -ForegroundColor Gray

Write-Host "`n2. Test pour Camille (Marketing):" -ForegroundColor White
Write-Host "   a) Ouvrir PowerShell en tant qu'administrateur" -ForegroundColor Gray
Write-Host "   b) Exécuter:" -ForegroundColor Gray
Write-Host "      `$cred = Get-Credential -UserName 'MAXTEC\camille'" -ForegroundColor Gray
Write-Host "      New-ADUser -Name 'Test Marketing' -GivenName 'Test' -Surname 'User' -SamAccountName 'testmkt' -Path '$ouMarketingUsers' -AccountPassword (ConvertTo-SecureString 'Temp123!' -AsPlainText -Force) -Enabled `$true -Credential `$cred" -ForegroundColor Gray
Write-Host "   c) Si cela fonctionne : Délégation OK" -ForegroundColor Gray
Write-Host "   d) Nettoyer après le test:" -ForegroundColor Gray
Write-Host "      Remove-ADUser -Identity testmkt -Confirm:`$false" -ForegroundColor Gray

Write-Host "`n📚 Rappel - Principe du Moindre Privilège:" -ForegroundColor Cyan
Write-Host "  - Accorder uniquement les permissions nécessaires" -ForegroundColor Gray
Write-Host "  - Limiter la portée des permissions (OUs spécifiques)" -ForegroundColor Gray
Write-Host "  - Facilite la gestion et réduit les risques de sécurité" -ForegroundColor Gray

Write-Host "`n🔐 Bonnes pratiques de délégation:" -ForegroundColor Cyan
Write-Host "  1. Préférer les groupes aux utilisateurs individuels" -ForegroundColor Gray
Write-Host "  2. Documenter toutes les délégations effectuées" -ForegroundColor Gray
Write-Host "  3. Auditer régulièrement les permissions déléguées" -ForegroundColor Gray
Write-Host "  4. Utiliser l'Assistant plutôt que manipuler les ACL manuellement" -ForegroundColor Gray
