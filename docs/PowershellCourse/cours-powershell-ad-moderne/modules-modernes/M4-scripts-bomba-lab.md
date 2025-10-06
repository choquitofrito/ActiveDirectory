# Module 4: Scripts Bomba Lab - Détecter les Erreurs Mortelles Cachées

## 🎯 Objectif de ce Module
**À la fin**: Vous serez un détecteur humain de scripts dangereux, capable d'identifier les erreurs mortelles avant qu'elles explosent en production.

---

## 💣 Philosophie du Module: Apprendre du Désastre AVANT qu'il Arrive

### Pourquoi ce Module Existe
```
📊 STATISTIQUES RÉELLES:
- 73% des pannes AD = erreurs humaines de script
- 89% des scripts dangereux = apparence légitimes
- 95% des désastres = évitables avec validation
- 100% des admins = ont une histoire d'horreur
```

### L'Art de la Détection

**Un script bomba parfait** :

- ✅ Semble légitime à première vue
- ✅ Commentaires rassurants
- ✅ Vient de source "fiable"
- ☠️ Contient 1-2 erreurs mortelles cachées
- ☠️ Explose seulement en production

---

## 🔬 Anatomie d'un Script Bomba

### Les 5 Techniques de Camouflage

#### 1. **Commentaires Trompeurs**

```powershell
# Script validé par l'équipe sécurité ✅
# Testé sur environnement de dev ✅
# Approuvé pour production ✅

Get-ADUser -Filter * | Remove-ADUser -Confirm:$false  # ☠️
```

#### 2. **Erreur Subtile dans une Ligne Innocente**
```powershell
# Script parfaitement normal...
$users = Get-ADUser -Filter {Department -eq "Stagiaires"}
# 50 lignes de code propre...
$users | Set-ADUser -Enabled $fase  # ☠️ $false écrit $fase
```

#### 3. **TODO Rassurant**
```powershell
# TODO: Tester sur environnement de dev d'abord
# TODO: Valider avec l'équipe avant prod
Remove-ADUser -Identity * -Confirm:$false  # ☠️ Mais exécuté quand même 😱
```

#### 4. **Apparence Professionnelle**
```powershell
<#
.SYNOPSIS
    Script de maintenance AD approuvé
.DESCRIPTION
    Nettoyage automatisé des comptes inactifs
.AUTHOR
    Équipe Infrastructure Senior
.VERSION
    2.1.5 - Production Ready
#>

# Code qui semble parfait mais contient erreur fatale...
```

#### 5. **Erreur de Logic Business**
```powershell
# Désactiver les comptes des employés qui partent
Get-ADUser -Filter {Department -eq "Départs"} |  # ☠️ Département qui n'existe pas
    Set-ADUser -Enabled $false
# Résultat: Aucun utilisateur trouvé, script "réussi" mais rien fait
```

---

## 🎪 Lab Pratique: Détecter les Bombes

### 🚨 **SCRIPT BOMBA #1: Le Nettoyeur Innocent**

```powershell
# Script de nettoyage des groupes vides
# Auteur: Administrateur Principal
# Date: 2024-11-28
# Objectif: Supprimer les groupes qui ne contiennent aucun membre

Import-Module ActiveDirectory

Write-Host "=== NETTOYAGE DES GROUPES VIDES ===" -ForegroundColor Green
Write-Host "Recherche des groupes sans membres..." -ForegroundColor Yellow

# Récupérer tous les groupes du domaine maxtec.be
$tousLesGroupes = Get-ADGroup -Filter * -SearchBase "DC=maxtec,DC=be"

Write-Host "Total groupes trouvés: $($tousLesGroupes.Count)" -ForegroundColor Cyan

$groupesVides = @()

# Vérifier chaque groupe pour voir s'il a des membres
foreach ($groupe in $tousLesGroupes) {
    try {
        $membres = Get-ADGroupMember -Identity $groupe.SamAccountName -ErrorAction SilentlyContinue

        if ($membres.Count -eq 0) {
            $groupesVides += $groupe
            Write-Host "Groupe vide trouvé: $($groupe.Name)" -ForegroundColor Yellow
        }
    } catch {
        # Ignorer les erreurs de lecture
        continue
    }
}

Write-Host "`nGroupes vides trouvés: $($groupesVides.Count)" -ForegroundColor Yellow

if ($groupesVides.Count -gt 0) {
    Write-Host "Suppression des groupes vides..." -ForegroundColor Red

    foreach ($groupeVide in $groupesVides) {
        Write-Host "Suppression: $($groupeVide.Name)" -ForegroundColor Red

        # TODO: Ajouter validation supplémentaire avant production
        Remove-ADGroup -Identity $groupeVide.SamAccountName -Confirm:$false
    }

    Write-Host "✅ Nettoyage terminé avec succès!" -ForegroundColor Green
} else {
    Write-Host "Aucun groupe vide trouvé." -ForegroundColor Green
}
```

#### 🕵️ **MISSION DÉTECTIVE 4.1**

**Temps limite**: 10 minutes

**Consignes**:
1. Lisez ce script ligne par ligne
2. Identifiez TOUS les problèmes (minimum 5)
3. Évaluez le risque si exécuté sur maxtec.be
4. Proposez 3 améliorations critiques

#### 💡 **SOLUTION DÉTAILLÉE**

**🚨 ERREURS CRITIQUES IDENTIFIÉES:**

1. **ABSENCE DE -WhatIf** (MORTEL)

   ```powershell
   Remove-ADGroup -Identity $groupeVide.SamAccountName -Confirm:$false  # ☠️
   ```
   **Risque**: Suppression immédiate et irréversible

2. **LOGIQUE BUSINESS ERRONÉE** (GRAVE)

   - Groupe vide ≠ Groupe inutile
   - Groupes système peuvent être vides temporairement
   - Groupes de sécurité peuvent être vides par design

3. **AUCUNE EXCLUSION** (MORTEL)

   ```powershell
   $tousLesGroupes = Get-ADGroup -Filter * -SearchBase "DC=maxtec,DC=be"  # ☠️
   ```
   **Risque**: Inclut groupes système critiques (Admins du domaine vide = supprimé)

4. **PAS DE VÉRIFICATION TYPE GROUPE** (GRAVE)

   - Pas de distinction Distribution vs Sécurité
   - Pas de vérification des groupes built-in

5. **GESTION D'ERREURS INSUFFISANTE** (MOYEN)

   ```powershell
   } catch {
       continue  # ☠️ Masque les erreurs importantes
   }
   ```

6. **ABSENCE DE LOGGING** (MOYEN)

   - Aucune trace de ce qui a été supprimé
   - Impossible de rollback

#### 🛠️ **VERSION SÉCURISÉE**

```powershell
# Script de nettoyage des groupes vides - VERSION SÉCURISÉE
param(
    [switch]$WhatIf = $true,  # -WhatIf par défaut !
    [switch]$IncludeBuiltIn = $false
)

Import-Module ActiveDirectory

Write-Host "=== NETTOYAGE SÉCURISÉ DES GROUPES VIDES ===" -ForegroundColor Cyan
Write-Host "Mode: $($WhatIf ? 'SIMULATION' : 'RÉEL')" -ForegroundColor $(if($WhatIf){'Yellow'}else{'Red'})

# Groupes à JAMAIS supprimer (whitelist sécurité)
$groupesCritiques = @(
    "Admins du domaine", "Enterprise Admins", "Schema Admins",
    "Account Operators", "Backup Operators", "Server Operators",
    "Print Operators", "Replicator", "Domain Users", "Domain Computers",
    "Domain Controllers", "Cert Publishers", "Domain Guests"
)

# SearchBase spécifique pour éviter les groupes système
$searchBase = if ($IncludeBuiltIn) { "DC=maxtec,DC=be" } else { "OU=EU,DC=maxtec,DC=be" }

try {
    # Récupérer groupes avec propriétés nécessaires
    $tousLesGroupes = Get-ADGroup -Filter * -SearchBase $searchBase -Properties GroupCategory, GroupScope

    Write-Host "Groupes analysés dans: $searchBase" -ForegroundColor Cyan
    Write-Host "Total groupes trouvés: $($tousLesGroupes.Count)" -ForegroundColor Cyan

    $groupesCandidats = @()

    foreach ($groupe in $tousLesGroupes) {
        # Vérifier si groupe critique
        if ($groupe.Name -in $groupesCritiques) {
            Write-Host "SKIP: Groupe critique protégé - $($groupe.Name)" -ForegroundColor Green
            continue
        }

        try {
            $membres = Get-ADGroupMember -Identity $groupe.SamAccountName -ErrorAction Stop

            if ($membres.Count -eq 0) {
                $groupesCandidats += [PSCustomObject]@{
                    Name = $groupe.Name
                    SamAccountName = $groupe.SamAccountName
                    GroupCategory = $groupe.GroupCategory
                    GroupScope = $groupe.GroupScope
                    DistinguishedName = $groupe.DistinguishedName
                }

                Write-Host "Candidat suppression: $($groupe.Name) ($($groupe.GroupCategory))" -ForegroundColor Yellow
            }

        } catch {
            Write-Warning "Erreur lecture groupe $($groupe.Name): $($_.Exception.Message)"
        }
    }

    if ($groupesCandidats.Count -eq 0) {
        Write-Host "✅ Aucun groupe vide trouvé (hors groupes critiques)" -ForegroundColor Green
        return
    }

    # Afficher résumé AVANT action
    Write-Host "`n=== RÉSUMÉ SUPPRESSION ===" -ForegroundColor Yellow
    $groupesCandidats | Format-Table Name, GroupCategory, GroupScope -AutoSize
    Write-Host "Total à supprimer: $($groupesCandidats.Count)" -ForegroundColor Yellow

    if (-not $WhatIf) {
        $confirmation = Read-Host "Confirmer suppression ? (tapez 'SUPPRIMER' pour confirmer)"
        if ($confirmation -ne "SUPPRIMER") {
            Write-Host "❌ Opération annulée par l'utilisateur" -ForegroundColor Red
            return
        }
    }

    # Suppression avec logging
    foreach ($groupe in $groupesCandidats) {
        $message = "Suppression groupe: $($groupe.Name) ($($groupe.GroupCategory))"

        if ($WhatIf) {
            Write-Host "SIMULATION: $message" -ForegroundColor Yellow
        } else {
            Write-Host "RÉEL: $message" -ForegroundColor Red

            # Log avant suppression
            Add-Content -Path "C:\Scripts\Logs\groupes-supprimes-$(Get-Date -Format 'yyyyMMdd').log" `
                        -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $($groupe.DistinguishedName)"
        }

        Remove-ADGroup -Identity $groupe.SamAccountName -Confirm:$false -WhatIf:$WhatIf
    }

    if ($WhatIf) {
        Write-Host "`n🎯 SIMULATION TERMINÉE" -ForegroundColor Yellow
        Write-Host "Pour exécuter: .\script.ps1 -WhatIf:`$false" -ForegroundColor Cyan
    } else {
        Write-Host "`n✅ SUPPRESSION TERMINÉE" -ForegroundColor Green
        Write-Host "Log sauvegardé dans: C:\Scripts\Logs\" -ForegroundColor Cyan
    }

} catch {
    Write-Error "Erreur fatale: $($_.Exception.Message)"
}
```

---

### 🚨 **SCRIPT BOMBA #2: L'Organisateur de Déménagement**

```powershell
# Script de migration utilisateurs suite réorganisation
# Auteur: Consultant Senior Migration AD
# Date: 2024-12-01
# Contexte: Fusion départements RH + Compta → "Administration"

Import-Module ActiveDirectory

Write-Host "=== MIGRATION ORGANISATIONNELLE ===" -ForegroundColor Green
Write-Host "Fusion RH + Compta → Administration" -ForegroundColor Yellow

# Configuration de la migration
$sourceOUs = @(
    "OU=RH,OU=EU,DC=maxtec,DC=be",
    "OU=Compta,OU=EU,DC=maxtec,DC=be"
)

$destinationOU = "OU=Administration,OU=EU,DC=maxtec,DC=be"

Write-Host "Migration vers: $destinationOU" -ForegroundColor Cyan

# Vérifier que l'OU destination existe
try {
    Get-ADOrganizationalUnit -Identity $destinationOU -ErrorAction Stop
    Write-Host "✅ OU destination confirmée" -ForegroundColor Green
} catch {
    Write-Host "Création de l'OU destination..." -ForegroundColor Yellow
    New-ADOrganizationalUnit -Name "Administration" -Path "OU=EU,DC=maxtec,DC=be"
    Write-Host "✅ OU destination créée" -ForegroundColor Green
}

# Migration des utilisateurs
foreach ($sourceOU in $sourceOUs) {
    Write-Host "`nTraitement de: $sourceOU" -ForegroundColor Yellow

    try {
        # Récupérer tous les utilisateurs de l'OU source
        $utilisateurs = Get-ADUser -Filter * -SearchBase $sourceOU

        Write-Host "Utilisateurs trouvés: $($utilisateurs.Count)" -ForegroundColor Cyan

        foreach ($user in $utilisateurs) {
            Write-Host "Migration: $($user.Name)" -ForegroundColor Yellow

            # Déplacer l'utilisateur vers la nouvelle OU
            Move-ADObject -Identity $user.DistinguishedName -TargetPath $destinationOU

            # Mettre à jour le département
            Set-ADUser -Identity $user.SamAccountName -Department "Administration"

            Write-Host "✅ $($user.Name) migré" -ForegroundColor Green
        }

    } catch {
        Write-Error "Erreur migration $sourceOU : $($_.Exception.Message)"
    }
}

Write-Host "`n🎯 MIGRATION TERMINÉE" -ForegroundColor Green
Write-Host "Tous les utilisateurs sont maintenant dans Administration" -ForegroundColor Green

# Nettoyage: supprimer les anciennes OUs vides
Write-Host "`nNettoyage des anciennes OUs..." -ForegroundColor Yellow
foreach ($oldOU in $sourceOUs) {
    Write-Host "Suppression: $oldOU" -ForegroundColor Red
    Remove-ADOrganizationalUnit -Identity $oldOU -Recursive -Confirm:$false
}

Write-Host "✅ Migration organisationnelle complète!" -ForegroundColor Green
```

#### 🕵️ **MISSION DÉTECTIVE 4.2**

**Temps limite**: 15 minutes

**Question cruciale**: "Si j'exécute ce script sur maxtec.be vendredi 17h, que se passe-t-il lundi matin ?"

#### 💀 **ANALYSE FORENSIQUE**

**🚨 ERREURS MORTELLES:**

1. **ABSENCE TOTALE DE -WhatIf** (CRITIQUE)

   - Migrations immédiatement irréversibles
   - Suppressions d'OUs avec -Recursive

2. **SUPPRESSION -RECURSIVE SANS VÉRIFICATION** (MORTEL)

   ```powershell
   Remove-ADOrganizationalUnit -Identity $oldOU -Recursive -Confirm:$false  # ☠️
   ```
   **Conséquence**: Supprime TOUT le contenu des OUs (groupes, politiques, sous-OUs)

3. **LOGIQUE DE NETTOYAGE DÉFAILLANTE** (GRAVE)

   - Script assume que migration = réussite
   - Supprime OUs même si migration partielle échouée

4. **PAS DE VÉRIFICATION GROUPES** (CRITIQUE)

   - Utilisateurs déplacés mais leurs groupes restent dans anciennes OUs
   - Rupture des permissions et accès

5. **DÉPARTEMENT HARDCODÉ** (MOYEN)

   ```powershell
   Set-ADUser -Identity $user.SamAccountName -Department "Administration"  # ☠️
   ```
   **Problème**: Force TOUS les users dans même département (perte granularité)

#### 🎭 **Scénario du Désastre**

**Vendredi 17h**: Script exécuté
- ✅ Users RH/Compta déplacés vers Administration
- ☠️ Groupes GG-EU-RH-*, GG-EU-Compta-* supprimés avec OUs
- ☠️ GPOs liées aux OUs supprimées
- ☠️ Toute structure organisationnelle perdue

**Lundi 8h**: Chaos
- Users existent mais n'ont plus aucun droit
- Groupes de sécurité introuvables
- Applications métier bloquées
- Sauvegarde complète nécessaire = weekend entier

---

### 🚨 **SCRIPT BOMBA #3: Le Sécurisateur de Mots de Passe**

```powershell
# Script de sécurisation des mots de passe faibles
# Auteur: Équipe Cybersécurité
# Objectif: Forcer changement des mots de passe non-conformes

Import-Module ActiveDirectory

$motsDePasse = @(
    "password", "123456", "admin", "root", "user",
    "welcome", "temp", "test", "maxtec", "2024"
)

Write-Host "=== AUDIT SÉCURITÉ MOTS DE PASSE ===" -ForegroundColor Red
Write-Host "Recherche des mots de passe faibles..." -ForegroundColor Yellow

foreach ($mdp in $motsDePasse) {
    Write-Host "Test mot de passe: $mdp" -ForegroundColor Cyan

    # Tester chaque utilisateur avec ce mot de passe
    $users = Get-ADUser -Filter * -SearchBase "OU=EU,DC=maxtec,DC=be"

    foreach ($user in $users) {
        try {
            # Tenter connexion avec mot de passe faible
            $credential = New-Object System.Management.Automation.PSCredential(
                "$($user.SamAccountName)@maxtec.be",
                (ConvertTo-SecureString $mdp -AsPlainText -Force)
            )

            # Test de connexion LDAP
            $connection = New-Object System.DirectoryServices.DirectoryEntry(
                "LDAP://dns1.maxtec.be",
                $credential.UserName,
                $credential.GetNetworkCredential().Password
            )

            if ($connection.Name -ne $null) {
                Write-Host "TROUVÉ: $($user.Name) utilise '$mdp'" -ForegroundColor Red

                # Forcer changement immédiat
                Set-ADUser -Identity $user.SamAccountName -ChangePasswordAtLogon $true
                Set-ADAccountPassword -Identity $user.SamAccountName -Reset -NewPassword (ConvertTo-SecureString "TempSecure123!" -AsPlainText -Force)

                Write-Host "✅ Mot de passe réinitialisé pour $($user.Name)" -ForegroundColor Green
            }
        } catch {
            # Connexion échouée = mot de passe différent (normal)
        }
    }
}

Write-Host "✅ Audit de sécurité terminé" -ForegroundColor Green
```

#### 🕵️ **MISSION DÉTECTIVE 4.3**
**Question piège**: "Ce script semble améliorer la sécurité. Où est le problème ?"

#### ⚡ **RÉVÉLATION CHOC**

**🚨 PROBLÈME CACHÉ MAJEUR:**

Ce script est une **ATTAQUE PAR BRUTE FORCE** déguisée !

1. **TENTATIVES DE CONNEXION MASSIVES** (CRITIQUE)
   - Teste systématiquement mots de passe courants
   - Génère des millions de tentatives de connexion
   - Peut déclencher verrouillages massifs de comptes

2. **LOGS DE SÉCURITÉ POLLUÉS** (GRAVE)
   - Chaque tentative = événement sécurité logged
   - Masque les vraies tentatives d'intrusion
   - SIEM/SOC saturé d'alertes

3. **DÉNI DE SERVICE POTENTIEL** (CRITIQUE)
   - Peut verrouiller TOUS les comptes utilisateurs
   - Surcharge contrôleur de domaine
   - Impact business catastrophique

4. **VIOLATION POLITIQUE SÉCURITÉ** (LÉGAL)
   - Test non autorisé de mots de passe
   - Peut violer réglementations (RGPD, etc.)
   - Risque disciplinaire/légal

#### 🛡️ **APPROCHE SÉCURISÉE ALTERNATIVE**

```powershell
# BONNE PRATIQUE: Audit sans test actif
# Utiliser outils Microsoft natifs

# 1. Analyser longueur/complexité via propriétés AD
Get-ADUser -Filter * -Properties PasswordLastSet, PasswordNeverExpires |
    Where-Object {
        $_.PasswordNeverExpires -eq $true -or
        $_.PasswordLastSet -lt (Get-Date).AddDays(-90)
    }

# 2. Utiliser Group Policy pour imposer complexity
# 3. Utiliser Azure AD Password Protection
# 4. Sensibiliser utilisateurs = éducation > force
```

---

## 🎓 Récapitulatif: Devenir Détecteur de Bombes

### 🔍 **Les 7 Signaux d'Alarme à Retenir**

1. **🚨 ABSENCE -WhatIf** sur commandes destructives
2. **🚨 -Recursive sans vérification** préalable
3. **🚨 -Filter \*** sans limitations scope
4. **⚠️ Gestion erreurs** qui masque problèmes
5. **⚠️ Hardcoding** paths/valeurs spécifiques
6. **⚠️ Logique business** non validée avec métier
7. **⚠️ "TODO" dans script** supposé prêt prod

### 🛠️ **Votre Checklist de Validation**

Avant d'exécuter TOUT script:

```
□ Commandes destructives ont -WhatIf ?
□ Scope limité avec SearchBase/Filter précis ?
□ Gestion d'erreurs robuste ?
□ Exclusions pour objets critiques ?
□ Logging des actions importantes ?
□ Validation business logic ?
□ Test possible sur environnement non-critique ?
□ Rollback plan en cas de problème ?
```

### 🎯 **Vos Nouvelles Habitudes**

1. **Lire CHAQUE ligne** même si script semble simple
2. **Questionner la logique** business avant technique
3. **Chercher ce qui manque** (exclusions, validations)
4. **Tester d'abord** avec -WhatIf ou échantillon réduit
5. **Documenter** ce que vous validez et pourquoi

---

*☕ **PAUSE OBLIGATOIRE 15 minutes** - Digérer les révélations*

---

**🎯 Prochaine étape**: Module 5 - -WhatIf Religieux (Pourquoi -WhatIf est Sacré)