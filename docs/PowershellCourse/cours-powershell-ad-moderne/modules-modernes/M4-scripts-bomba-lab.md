# Module 4 — Détecter les scripts dangereux

## Objectif

À la fin de ce module, vous saurez identifier les erreurs critiques cachées dans un script PowerShell AD avant de l'exécuter en production.

---

## Pourquoi ce module

La majorité des incidents AD majeurs viennent d'erreurs humaines de scripting, pas de pannes matérielles. Un script dangereux a typiquement les caractéristiques suivantes :

- Il semble légitime à première vue.
- Les commentaires sont rassurants.
- Il vient d'une source perçue comme fiable.
- Il contient une ou deux erreurs critiques cachées.
- Le problème n'apparaît qu'en production, jamais en dev.

L'objectif n'est pas d'avoir peur de PowerShell, mais d'apprendre à lire un script comme un auditeur sécurité.

---

## Cinq techniques de camouflage à connaître

### 1. Commentaires trompeurs

```powershell
# Script validé par l'équipe sécurité
# Testé sur environnement de dev
# Approuvé pour production

Get-ADUser -Filter * | Remove-ADUser -Confirm:$false
```

Le commentaire dit "validé". Le code dit "supprime tous les utilisateurs". Le commentaire ment.

### 2. Erreur subtile dans une ligne banale

```powershell
$users = Get-ADUser -Filter {Department -eq "Stagiaires"}
# … 50 lignes de code propre …
$users | Set-ADUser -Enabled $fase  # $false écrit $fase → $null
```

`$fase` est une variable inexistante, donc `$null`. PowerShell interprète `$null` comme `$false` dans ce contexte. Le script désactive silencieusement.

### 3. TODO rassurant

```powershell
# TODO: Tester sur environnement de dev d'abord
# TODO: Valider avec l'équipe avant prod
Remove-ADUser -Identity * -Confirm:$false
```

Les TODO ne bloquent pas l'exécution. Le script tourne quand même.

### 4. Apparence professionnelle

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

# Code qui semble parfait mais contient une erreur fatale...
```

Un en-tête bien formaté n'est pas un audit de sécurité.

### 5. Erreur de logique métier

```powershell
# Désactiver les comptes des employés qui partent
Get-ADUser -Filter {Department -eq "Départs"} |
    Set-ADUser -Enabled $false
```

Si le département "Départs" n'existe pas, le filtre renvoie 0 résultat. Le script "réussit" en ne faisant rien — et personne ne s'en rend compte.

---

## Lab 1 — Le nettoyeur innocent

```powershell
# Script de nettoyage des groupes vides
# Auteur: Administrateur Principal
# Date: 2024-11-28
# Objectif: Supprimer les groupes qui ne contiennent aucun membre

Import-Module ActiveDirectory

Write-Host "=== NETTOYAGE DES GROUPES VIDES ===" -ForegroundColor Green
Write-Host "Recherche des groupes sans membres..." -ForegroundColor Yellow

$tousLesGroupes = Get-ADGroup -Filter * -SearchBase "DC=maxtec,DC=be"

Write-Host "Total groupes trouvés: $($tousLesGroupes.Count)" -ForegroundColor Cyan

$groupesVides = @()

foreach ($groupe in $tousLesGroupes) {
    try {
        $membres = Get-ADGroupMember -Identity $groupe.SamAccountName -ErrorAction SilentlyContinue

        if ($membres.Count -eq 0) {
            $groupesVides += $groupe
            Write-Host "Groupe vide trouvé: $($groupe.Name)" -ForegroundColor Yellow
        }
    } catch {
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

    Write-Host "Nettoyage terminé" -ForegroundColor Green
} else {
    Write-Host "Aucun groupe vide trouvé." -ForegroundColor Green
}
```

### Exercice 4.1 — détecter les problèmes (10 min)

1. Lisez le script ligne par ligne.
2. Identifiez tous les problèmes (au moins 5).
3. Évaluez le risque sur maxtec.be.
4. Proposez 3 améliorations critiques.

### Analyse

**1. Absence de `-WhatIf` (critique)**

```powershell
Remove-ADGroup -Identity $groupeVide.SamAccountName -Confirm:$false
```

Suppression immédiate, irréversible.

**2. Logique métier erronée (grave)**

- Groupe vide ≠ groupe inutile.
- Certains groupes système sont vides par design.
- Certains groupes peuvent l'être temporairement.

**3. Aucune exclusion (critique)**

```powershell
$tousLesGroupes = Get-ADGroup -Filter * -SearchBase "DC=maxtec,DC=be"
```

Inclut tous les groupes du domaine, y compris les groupes système et privilégiés.

**4. Pas de vérification du type de groupe (grave)**

Aucune distinction entre Distribution / Sécurité, ni protection des groupes built-in.

**5. Gestion d'erreurs qui masque les problèmes (moyen)**

```powershell
} catch {
    continue
}
```

Les erreurs importantes sont silencieusement avalées.

**6. Aucun logging (moyen)**

Pas de trace de ce qui a été supprimé. Rollback impossible.

### Version sécurisée

```powershell
# Nettoyage des groupes vides — version sécurisée
param(
    [switch]$WhatIf = $true,
    [switch]$IncludeBuiltIn = $false
)

Import-Module ActiveDirectory

Write-Host "=== NETTOYAGE DES GROUPES VIDES ===" -ForegroundColor Cyan
Write-Host "Mode: $($WhatIf ? 'SIMULATION' : 'RÉEL')" -ForegroundColor $(if ($WhatIf) { 'Yellow' } else { 'Red' })

# Whitelist des groupes critiques à ne jamais supprimer
$groupesCritiques = @(
    "Admins du domaine", "Enterprise Admins", "Schema Admins",
    "Account Operators", "Backup Operators", "Server Operators",
    "Print Operators", "Replicator", "Domain Users", "Domain Computers",
    "Domain Controllers", "Cert Publishers", "Domain Guests"
)

$searchBase = if ($IncludeBuiltIn) { "DC=maxtec,DC=be" } else { "OU=EU,DC=maxtec,DC=be" }

try {
    $tousLesGroupes = Get-ADGroup -Filter * -SearchBase $searchBase -Properties GroupCategory, GroupScope

    Write-Host "Groupes analysés dans: $searchBase" -ForegroundColor Cyan
    Write-Host "Total groupes trouvés: $($tousLesGroupes.Count)" -ForegroundColor Cyan

    $groupesCandidats = @()

    foreach ($groupe in $tousLesGroupes) {
        if ($groupe.Name -in $groupesCritiques) {
            Write-Host "Ignoré (groupe critique): $($groupe.Name)" -ForegroundColor Green
            continue
        }

        try {
            $membres = Get-ADGroupMember -Identity $groupe.SamAccountName -ErrorAction Stop

            if ($membres.Count -eq 0) {
                $groupesCandidats += [PSCustomObject]@{
                    Name              = $groupe.Name
                    SamAccountName    = $groupe.SamAccountName
                    GroupCategory     = $groupe.GroupCategory
                    GroupScope        = $groupe.GroupScope
                    DistinguishedName = $groupe.DistinguishedName
                }

                Write-Host "Candidat: $($groupe.Name) ($($groupe.GroupCategory))" -ForegroundColor Yellow
            }
        } catch {
            Write-Warning "Erreur lecture groupe $($groupe.Name): $($_.Exception.Message)"
        }
    }

    if ($groupesCandidats.Count -eq 0) {
        Write-Host "Aucun groupe vide trouvé (hors groupes critiques)" -ForegroundColor Green
        return
    }

    Write-Host "`n=== RÉSUMÉ ===" -ForegroundColor Yellow
    $groupesCandidats | Format-Table Name, GroupCategory, GroupScope -AutoSize
    Write-Host "Total à supprimer: $($groupesCandidats.Count)" -ForegroundColor Yellow

    if (-not $WhatIf) {
        $confirmation = Read-Host "Confirmer suppression ? (tapez 'SUPPRIMER' pour confirmer)"
        if ($confirmation -ne "SUPPRIMER") {
            Write-Host "Opération annulée" -ForegroundColor Red
            return
        }
    }

    foreach ($groupe in $groupesCandidats) {
        $message = "Suppression groupe: $($groupe.Name) ($($groupe.GroupCategory))"

        if ($WhatIf) {
            Write-Host "SIMULATION: $message" -ForegroundColor Yellow
        } else {
            Write-Host "RÉEL: $message" -ForegroundColor Red

            Add-Content -Path "C:\Scripts\Logs\groupes-supprimes-$(Get-Date -Format 'yyyyMMdd').log" `
                        -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $($groupe.DistinguishedName)"
        }

        Remove-ADGroup -Identity $groupe.SamAccountName -Confirm:$false -WhatIf:$WhatIf
    }

    if ($WhatIf) {
        Write-Host "`nSimulation terminée. Pour exécuter: .\script.ps1 -WhatIf:`$false" -ForegroundColor Cyan
    } else {
        Write-Host "`nSuppression terminée. Log: C:\Scripts\Logs\" -ForegroundColor Green
    }

} catch {
    Write-Error "Erreur fatale: $($_.Exception.Message)"
}
```

---

## Lab 2 — L'organisateur de déménagement

```powershell
# Script de migration utilisateurs suite à réorganisation
# Auteur: Consultant Senior Migration AD
# Date: 2024-12-01
# Contexte: Fusion départements RH + Compta → "Administration"

Import-Module ActiveDirectory

Write-Host "=== MIGRATION ORGANISATIONNELLE ===" -ForegroundColor Green
Write-Host "Fusion RH + Compta → Administration" -ForegroundColor Yellow

$sourceOUs = @(
    "OU=RH,OU=EU,DC=maxtec,DC=be",
    "OU=Compta,OU=EU,DC=maxtec,DC=be"
)

$destinationOU = "OU=Administration,OU=EU,DC=maxtec,DC=be"

Write-Host "Migration vers: $destinationOU" -ForegroundColor Cyan

try {
    Get-ADOrganizationalUnit -Identity $destinationOU -ErrorAction Stop
    Write-Host "OU destination confirmée" -ForegroundColor Green
} catch {
    Write-Host "Création de l'OU destination..." -ForegroundColor Yellow
    New-ADOrganizationalUnit -Name "Administration" -Path "OU=EU,DC=maxtec,DC=be"
    Write-Host "OU destination créée" -ForegroundColor Green
}

foreach ($sourceOU in $sourceOUs) {
    Write-Host "`nTraitement de: $sourceOU" -ForegroundColor Yellow

    try {
        $utilisateurs = Get-ADUser -Filter * -SearchBase $sourceOU

        Write-Host "Utilisateurs trouvés: $($utilisateurs.Count)" -ForegroundColor Cyan

        foreach ($user in $utilisateurs) {
            Write-Host "Migration: $($user.Name)" -ForegroundColor Yellow

            Move-ADObject -Identity $user.DistinguishedName -TargetPath $destinationOU
            Set-ADUser -Identity $user.SamAccountName -Department "Administration"

            Write-Host "  $($user.Name) migré" -ForegroundColor Green
        }

    } catch {
        Write-Error "Erreur migration $sourceOU : $($_.Exception.Message)"
    }
}

Write-Host "`nMigration terminée" -ForegroundColor Green

# Nettoyage des anciennes OUs
Write-Host "`nNettoyage des anciennes OUs..." -ForegroundColor Yellow
foreach ($oldOU in $sourceOUs) {
    Write-Host "Suppression: $oldOU" -ForegroundColor Red
    Remove-ADOrganizationalUnit -Identity $oldOU -Recursive -Confirm:$false
}

Write-Host "Migration organisationnelle complète" -ForegroundColor Green
```

### Exercice 4.2 — analyse (15 min)

**Question** : si j'exécute ce script sur maxtec.be vendredi 17h, que se passe-t-il lundi matin ?

### Analyse

**1. Aucun `-WhatIf` (critique)**

Migration et suppressions exécutées directement.

**2. `Remove-ADOrganizationalUnit -Recursive` sans vérification (critique)**

```powershell
Remove-ADOrganizationalUnit -Identity $oldOU -Recursive -Confirm:$false
```

Supprime tout le contenu des OUs : groupes, GPOs, sous-OUs.

**3. Logique de nettoyage défaillante (grave)**

Le script suppose que la migration des utilisateurs a réussi. Si elle échoue partiellement, les OUs sont quand même supprimées.

**4. Groupes laissés en arrière (critique)**

Les utilisateurs sont déplacés, mais les groupes `GG-EU-RH-*` et `GG-EU-Compta-*` restent dans les OUs sources — et sont supprimés avec elles. Les permissions partent avec.

**5. Département forcé pour tout le monde (moyen)**

```powershell
Set-ADUser -Identity $user.SamAccountName -Department "Administration"
```

Écrase la granularité d'origine.

### Scénario de désastre

Vendredi 17h, exécution :

- Utilisateurs RH et Compta déplacés vers Administration.
- Groupes `GG-EU-RH-*` et `GG-EU-Compta-*` supprimés avec leurs OUs.
- GPOs liées aux OUs supprimées.

Lundi 8h :

- Les utilisateurs existent mais n'ont plus de droits.
- Les groupes de sécurité sont introuvables.
- Les applications métier ne répondent plus.
- Restauration depuis sauvegarde : plusieurs heures, voire le weekend.

---

## Lab 3 — Le "sécurisateur" de mots de passe

```powershell
# Script de sécurisation des mots de passe faibles
# Auteur: Équipe Cybersécurité
# Objectif: Forcer changement des mots de passe non-conformes

Import-Module ActiveDirectory

$motsDePasse = @(
    "password", "123456", "admin", "root", "user",
    "welcome", "temp", "test", "maxtec", "2024"
)

Write-Host "=== AUDIT MOTS DE PASSE ===" -ForegroundColor Red

foreach ($mdp in $motsDePasse) {
    Write-Host "Test mot de passe: $mdp" -ForegroundColor Cyan

    $users = Get-ADUser -Filter * -SearchBase "OU=EU,DC=maxtec,DC=be"

    foreach ($user in $users) {
        try {
            $credential = New-Object System.Management.Automation.PSCredential(
                "$($user.SamAccountName)@maxtec.be",
                (ConvertTo-SecureString $mdp -AsPlainText -Force)
            )

            $connection = New-Object System.DirectoryServices.DirectoryEntry(
                "LDAP://dns1.maxtec.be",
                $credential.UserName,
                $credential.GetNetworkCredential().Password
            )

            if ($connection.Name -ne $null) {
                Write-Host "TROUVÉ: $($user.Name) utilise '$mdp'" -ForegroundColor Red

                Set-ADUser -Identity $user.SamAccountName -ChangePasswordAtLogon $true
                Set-ADAccountPassword -Identity $user.SamAccountName -Reset -NewPassword (ConvertTo-SecureString "TempSecure123!" -AsPlainText -Force)

                Write-Host "Mot de passe réinitialisé pour $($user.Name)" -ForegroundColor Green
            }
        } catch {
            # Connexion échouée = mot de passe différent (normal)
        }
    }
}

Write-Host "Audit terminé" -ForegroundColor Green
```

### Exercice 4.3 — où est le piège ?

Ce script semble améliorer la sécurité. En réalité, c'est une attaque par force brute déguisée.

**1. Tentatives de connexion massives (critique)**

Le script teste systématiquement des mots de passe courants contre chaque compte. Sur un domaine de 500 utilisateurs et 10 mots de passe testés, ça fait 5 000 tentatives d'authentification.

**2. Verrouillage en chaîne (critique)**

La policy de domaine verrouille typiquement après 5 échecs. Conséquence : tous les comptes ayant un mot de passe différent des 10 testés se retrouvent verrouillés. C'est-à-dire la grande majorité.

**3. Pollution des logs sécurité (grave)**

Chaque tentative génère un événement de sécurité. Les vraies attaques deviennent invisibles dans le bruit.

**4. Risque légal (grave)**

Tester des mots de passe sans autorisation formelle peut violer la politique interne et le RGPD. Un audit de sécurité doit être autorisé par écrit.

### Approche correcte

```powershell
# Auditer les attributs AD, pas tester les mots de passe

# 1. Comptes à risque selon les propriétés AD
Get-ADUser -Filter * -Properties PasswordLastSet, PasswordNeverExpires |
    Where-Object {
        $_.PasswordNeverExpires -eq $true -or
        $_.PasswordLastSet -lt (Get-Date).AddDays(-90)
    }

# 2. Imposer la complexité via Group Policy (configuration manuelle)
# 3. Activer Azure AD Password Protection
# 4. Sensibiliser les utilisateurs
```

---

## Récapitulatif — sept signaux d'alarme

1. Absence de `-WhatIf` sur une commande destructive.
2. `-Recursive` sans vérification du contenu.
3. `-Filter *` sans limitation de scope.
4. Gestion d'erreurs qui masque les problèmes (`continue` ou `catch` vide).
5. Hardcoding de chemins ou de valeurs spécifiques.
6. Logique métier non validée.
7. `TODO` dans un script censé être prêt pour production.

## Checklist avant exécution

Avant d'exécuter un script :

- Les commandes destructives ont `-WhatIf` ?
- Le scope est limité (SearchBase / Filter précis) ?
- La gestion d'erreurs est robuste ?
- Les objets critiques sont exclus ?
- Les actions importantes sont loggées ?
- La logique métier est validée ?
- Un test sur un environnement non-critique est possible ?
- Un plan de rollback existe ?

## Habitudes à prendre

1. Lire chaque ligne, même si le script semble simple.
2. Questionner la logique métier avant la technique.
3. Chercher ce qui manque (exclusions, validations).
4. Tester d'abord avec `-WhatIf` ou un échantillon réduit.
5. Documenter ce que vous validez et pourquoi.

---

**Suite** : Module 5 — `-WhatIf`, pourquoi c'est non négociable.
