# Script de Création de Structure Active Directory

## 🧭 Navigation
[⏮️ Retour au Labo](../Labo_structure.md) | [🏠 Retour au Syllabus](../../../index.md)

---

!!! info "📋 À propos de ce script"
    
    Ce script PowerShell automatise la création complète de la structure Active Directory pour le laboratoire, incluant :
    
    - ✅ Unités d'Organisation (OUs)
    - ✅ Utilisateurs par département
    - ✅ Groupes de sécurité
    - ✅ Structure hiérarchique complète

!!! warning "⚠️ Prérequis"
    
    - Exécuter sur un contrôleur de domaine
    - Droits d'administrateur de domaine
    - Module Active Directory installé
    - Domaine `maxtec.be` configuré

---

## 📜 Code du Script

!!! tip "💡 Comment utiliser"
    
    1. **Copier le code** ci-dessous (utilisez le bouton de copie)
    2. **Sauvegarder** dans `C:\Scripts\creation_structure.ps1`
    3. **Exécuter** avec PowerShell en tant qu'administrateur
    4. **Suivre** les confirmations interactives

!!! note "Encodage du fichier"
    Windows PowerShell 5.1 lit un `.ps1` sans BOM comme de l'ANSI : les accents des messages s'affichent mal (`PrÃªt` au lieu de `Prêt`). Le script fonctionne quand même, mais pour un affichage propre enregistrez en **UTF-8 avec BOM** : dans VS Code, cliquez sur `UTF-8` dans la barre d'état > *Enregistrer avec l'encodage* > *UTF-8 with BOM*. PowerShell ISE le fait par défaut.

```powershell
# Script de création de la structure du lab Maxtec (OUs, utilisateurs, groupes)
# Fichier : C:\Scripts\creation_structure.ps1
# Idempotent : peut être relancé sans erreur (vérifie l'existence avant de créer)

# Demande de confirmation par étape
function Confirm-Step {
    param($stepName)
    Write-Host "`nPrêt à exécuter: $stepName" -ForegroundColor Yellow
    $response = Read-Host "Appuyez sur 'O' pour continuer, 'N' pour sauter cette étape, ou 'Q' pour quitter"
    if ($response.ToUpper() -eq 'Q') {
        Write-Host "Script arrêté par l'utilisateur." -ForegroundColor Red
        exit
    }
    return $response.ToUpper() -eq 'O'
}

# Tests d'existence ($null = ... pour ne pas renvoyer l'objet AD dans le résultat)
function Test-OUExists {
    param($ouDN)
    try { $null = Get-ADOrganizationalUnit -Identity $ouDN; return $true } catch { return $false }
}

function Test-UserExists {
    param($samAccountName)
    try { $null = Get-ADUser -Identity $samAccountName; return $true } catch { return $false }
}

function Test-GroupExists {
    param($groupName)
    try { $null = Get-ADGroup -Identity $groupName; return $true } catch { return $false }
}

Import-Module ActiveDirectory

# Garde-fou : ce script ne doit tourner que sur le domaine du lab
if ((Get-ADDomain).DNSRoot -ne 'maxtec.be') {
    Write-Host "Ce script est prévu pour le domaine maxtec.be. Arrêt." -ForegroundColor Red
    exit
}

$rootOU = "OU=EU,DC=maxtec,DC=be"
# Mot de passe de LAB uniquement. En production : Read-Host -AsSecureString et -ChangePasswordAtLogon $true
$defaultPassword = "Password1!"

try {
    Write-Host "Script de création de structure Active Directory" -ForegroundColor Green
    Write-Host "===========================================" -ForegroundColor Green

    # 1. OU racine EU
    if (Confirm-Step "Création de l'OU racine EU") {
        Write-Host "`nCréation de l'OU racine EU..." -ForegroundColor Cyan
        if (-not (Test-OUExists $rootOU)) {
            New-ADOrganizationalUnit -Name "EU" -Path "DC=maxtec,DC=be" -ProtectedFromAccidentalDeletion $false
            Write-Host "OU racine EU créée avec succès." -ForegroundColor Green
        } else {
            Write-Host "OU racine EU existe déjà." -ForegroundColor Yellow
        }
    }

    # 2. Départements et sous-OUs
    if (Confirm-Step "Création des départements et leurs sous-OUs") {
        $departments = @("Ventes", "RH", "Comptabilite", "IT")
        Write-Host "`nCréation des départements et leurs sous-OUs..." -ForegroundColor Cyan

        foreach ($dept in $departments) {
            Write-Host "Traitement du département $dept..." -NoNewline
            $ouPath = "OU=$dept,$rootOU"
            if (-not (Test-OUExists $ouPath)) {
                New-ADOrganizationalUnit -Name $dept -Path $rootOU -ProtectedFromAccidentalDeletion $false
                Write-Host "créé" -ForegroundColor Green
            } else {
                Write-Host "existe déjà" -ForegroundColor Yellow
            }

            foreach ($subOU in @("Users", "Computers", "Groups")) {
                Write-Host "  - Sous-OU $subOU..." -NoNewline
                $subOUPath = "OU=$subOU,$ouPath"
                if (-not (Test-OUExists $subOUPath)) {
                    New-ADOrganizationalUnit -Name $subOU -Path $ouPath -ProtectedFromAccidentalDeletion $false
                    Write-Host "créée" -ForegroundColor Green
                } else {
                    Write-Host "existe déjà" -ForegroundColor Yellow
                }
            }
        }
    }

    # 3. Utilisateurs (Department = nom de l'OU, sans accent, pour simplifier les filtres PowerShell)
    if (Confirm-Step "Création des utilisateurs") {
        Write-Host "`nCréation des utilisateurs..." -ForegroundColor Cyan
        $users = @(
            @{Name="Vanessa";   Surname="Vermeulen"; OU="Ventes";       Title="Commerciale"},
            @{Name="Valeria";   Surname="Verhoeven"; OU="Ventes";       Title="Commerciale"},
            @{Name="Victor";    Surname="Vandamme";  OU="Ventes";       Title="Commercial"},
            @{Name="Valentin";  Surname="Vanderlinden"; OU="Ventes";    Title="Responsable Ventes"},
            @{Name="Richard";   Surname="Renard";    OU="RH";           Title="Responsable RH"},
            @{Name="Rebecca";   Surname="Rousseau";  OU="RH";           Title="Gestionnaire RH"},
            @{Name="Rene";      Surname="Remy";      OU="RH";           Title="Gestionnaire RH"},
            @{Name="Charlotte"; Surname="Claes";     OU="Comptabilite"; Title="Responsable Comptabilite"},
            @{Name="Cindy";     Surname="Collard";   OU="Comptabilite"; Title="Comptable"},
            @{Name="Charles";   Surname="Cornet";    OU="Comptabilite"; Title="Comptable"},
            @{Name="Ivan";      Surname="Istace";    OU="IT";           Title="Technicien"},
            @{Name="Ines";      Surname="Installe";  OU="IT";           Title="Technicienne"},
            @{Name="Irene";     Surname="Iserbyt";   OU="IT";           Title="Administratrice systeme"}
        )
        $securePassword = ConvertTo-SecureString $defaultPassword -AsPlainText -Force

        foreach ($user in $users) {
            Write-Host "Création de l'utilisateur $($user.Name)..." -NoNewline
            $samAccountName = $user.Name.ToLower()
            if (-not (Test-UserExists $samAccountName)) {
                New-ADUser -Name $user.Name `
                          -GivenName $user.Name `
                          -Surname $user.Surname `
                          -DisplayName "$($user.Name) $($user.Surname)" `
                          -SamAccountName $samAccountName `
                          -UserPrincipalName "$samAccountName@maxtec.be" `
                          -EmailAddress "$samAccountName@maxtec.be" `
                          -Department $user.OU `
                          -Title $user.Title `
                          -Company "Maxtec" `
                          -Country "BE" `
                          -Path "OU=Users,OU=$($user.OU),$rootOU" `
                          -AccountPassword $securePassword `
                          -Enabled $true
                Write-Host "OK" -ForegroundColor Green
            } else {
                Write-Host "existe déjà" -ForegroundColor Yellow
            }
        }
    }

    # 4. Groupes globaux
    if (Confirm-Step "Création des groupes") {
        Write-Host "`nCréation des groupes..." -ForegroundColor Cyan
        $groups = @(
            @{Name="GG-EU-Ventes-Admin";OU="Ventes"},
            @{Name="GG-EU-Ventes-Users";OU="Ventes"},
            @{Name="GG-EU-RH-Admin";OU="RH"},
            @{Name="GG-EU-RH-Users";OU="RH"},
            @{Name="GG-EU-Compta-Admin";OU="Comptabilite"},
            @{Name="GG-EU-Compta-Users";OU="Comptabilite"},
            @{Name="GG-EU-IT-Admin";OU="IT"},
            @{Name="GG-EU-IT-Users";OU="IT"}
        )

        foreach ($group in $groups) {
            Write-Host "Traitement du groupe $($group.Name)..." -NoNewline
            if (-not (Test-GroupExists $group.Name)) {
                New-ADGroup -Name $group.Name -GroupScope Global -GroupCategory Security -Path "OU=Groups,OU=$($group.OU),$rootOU"
                Write-Host "créé" -ForegroundColor Green
            } else {
                Write-Host "existe déjà" -ForegroundColor Yellow
            }
        }
    }

    # 5. Membres des groupes - OPTIONNEL : répondez 'N' si vous faites la pratique à la main (Labo_structure)
    if (Confirm-Step "Ajout des membres aux groupes (optionnel, 'N' pour le faire à la main)") {
        Write-Host "`nAjout des membres..." -ForegroundColor Cyan
        $members = @{
            "GG-EU-Ventes-Users" = @("victor","vanessa","valeria")
            "GG-EU-Ventes-Admin" = @("valentin")
            "GG-EU-RH-Users"     = @("rene","rebecca")
            "GG-EU-RH-Admin"     = @("richard")
            "GG-EU-Compta-Users" = @("charles","cindy")
            "GG-EU-Compta-Admin" = @("charlotte")
            "GG-EU-IT-Users"     = @("ivan","ines")
            "GG-EU-IT-Admin"     = @("irene")
        }
        foreach ($g in $members.Keys) {
            $actuels = (Get-ADGroupMember -Identity $g).SamAccountName
            foreach ($m in $members[$g]) {
                if ($actuels -notcontains $m) {
                    Add-ADGroupMember -Identity $g -Members $m
                    Write-Host "$m -> $g" -ForegroundColor Green
                } else {
                    Write-Host "$m déjà membre de $g" -ForegroundColor Yellow
                }
            }
        }
    }

    Write-Host "`nStructure créée avec succès!" -ForegroundColor Green
}
catch {
    Write-Host "`nERREUR: Une erreur s'est produite lors de la création de la structure:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
}
```

---

## 🔧 Fonctionnalités du Script

!!! success "✨ Fonctionnalités avancées"
    
    **🔍 Vérifications intelligentes**
    
    - Vérifie l'existence avant création
    - Évite les doublons
    - Gestion d'erreurs complète
    
    **🎯 Confirmations interactives**
    
    - Confirmation par étape
    - Possibilité de sauter des étapes
    - Arrêt sécurisé à tout moment
    
    **📊 Feedback visuel**
    
    - Messages colorés par type d'action
    - Progression claire et détaillée
    - Rapport de succès/erreurs

!!! info "📋 Structure créée"
    
    **Départements :**
    
    - 🏢 **Ventes** : Vanessa, Valeria, Victor, Valentin
    - 👥 **RH** : Richard, Rebecca, René  
    - 💰 **Comptabilité** : Charlotte, Cindy, Charles
    - 💻 **IT** : Ivan, Ines, Irene
    
    Chaque compte a `GivenName`, `Surname`, `Department` (= nom de l'OU, sans accent), `Title`, `EmailAddress` et `Country = BE` renseignés : les requêtes PowerShell du chapitre 9 s'appuient dessus.

    **Groupes de sécurité :**
    
    - `GG-EU-Ventes-Admin` / `GG-EU-Ventes-Users`
    - `GG-EU-RH-Admin` / `GG-EU-RH-Users`
    - `GG-EU-Compta-Admin` / `GG-EU-Compta-Users`
    - `GG-EU-IT-Admin` / `GG-EU-IT-Users`

!!! warning "🛡️ Sécurité"
    
    - **Mot de passe par défaut** : `Password1!`
    - **⚠️ Important** : mot de passe identique pour tous et écrit en clair dans le script — acceptable en lab, jamais en production
    - **Protection** : OUs non protégées contre suppression accidentelle

---

## 🧭 Navigation
[⏮️ Retour au Labo](../Labo_structure.md) | [🏠 Retour au Syllabus](../../../index.md)

---

**📚 Cours Active Directory - Scripts PowerShell | 👨‍💻 Pour laboratoire**