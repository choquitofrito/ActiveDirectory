# 🚨 CAS D'HORREUR RÉEL: Le Vendredi Qui A Failli Ruiner Une Carrière

## 📅 Le Contexte
**Date**: Vendredi 13 octobre 2023, 16h45
**Lieu**: PME informatique, 120 employés
**Protagoniste**: Julien, admin junior avec 8 mois d'expérience
**Situation**: Bureau qui se vide, weekend qui approche, boss parti en réunion

---

## 🎯 La Mission "Urgente"

### Email de la DRH (16h30):
```
De: drh@entreprise.com
À: admin@entreprise.com
Sujet: URGENT - Nettoyage comptes stagiaires

Salut Julien,

Les stagiaires d'été partent aujourd'hui (5 personnes).
Peux-tu désactiver leurs comptes avant lundi ?

Leurs noms:
- Alexandre Durand
- Marie Petit
- Thomas Bernard
- Sophie Martin
- Lucas Moreau

Merci ! Bon weekend
Julie (DRH)
```

### Première Erreur de Julien
*"Facile, je vais faire ça rapidement avant de partir"*

---

## 💻 Le Script "Innocent"

Julien trouve ce script sur un forum PowerShell:

```powershell
# Script trouvé sur reddit.com/r/PowerShell
# Auteur: "ExpertAdmin2023"
# Upvotes: 47 👍

# Désactiver utilisateurs par liste
$stagiaires = @(
    "Alexandre.Durand",
    "Marie.Petit",
    "Thomas.Bernard",
    "Sophie.Martin",
    "Lucas.Moreau"
)

Write-Host "Désactivation des comptes stagiaires..." -ForegroundColor Yellow

foreach ($stagiaire in $stagiaires) {
    Write-Host "Désactivation: $stagiaire" -ForegroundColor Green
    Set-ADUser -Identity $stagiaire -Enabled $false
}

Write-Host "Terminé ! ✅" -ForegroundColor Green
```

### Réflexion de Julien
*"Script simple, from reddit avec beaucoup d'upvotes, ça devrait marcher"*

---

## ⚡ L'Exécution - 16h52

```powershell
PS C:\> .\desactiver-stagiaires.ps1
Désactivation des comptes stagiaires...
Désactivation: Alexandre.Durand
Set-ADUser : Cannot find an object with identity: 'Alexandre.Durand'
Désactivation: Marie.Petit
Désactivation: Thomas.Bernard
Set-ADUser : Cannot find an object with identity: 'Thomas.Bernard'
Désactivation: Sophie.Martin
Désactivation: Lucas.Moreau
Set-ADUser : Cannot find an object with identity: 'Lucas.Moreau'
Terminé ! ✅
```

### Réaction de Julien
*"Il y a des erreurs mais certains ont fonctionné. Je vais corriger..."*

---

## 🔥 La "Correction" Catastrophique - 16h58

Julien modifie le script pour "corriger" les erreurs:

```powershell
# "Amélioration" de Julien
$stagiaires = @(
    "Alexandre*",
    "Marie*",
    "Thomas*",
    "Sophie*",
    "Lucas*"
)

foreach ($stagiaire in $stagiaires) {
    Write-Host "Recherche et désactivation: $stagiaire" -ForegroundColor Yellow

    # ☠️ LA LIGNE MORTELLE:
    Get-ADUser -Filter {Name -like $stagiaire} | Set-ADUser -Enabled $false

    Write-Host "Fait pour $stagiaire ✅" -ForegroundColor Green
}
```

### L'Exécution Fatale - 17h01
```powershell
PS C:\> .\desactiver-stagiaires-v2.ps1
Recherche et désactivation: Alexandre*
Fait pour Alexandre* ✅
Recherche et désactivation: Marie*
Fait pour Marie* ✅
Recherche et désactivation: Thomas*
Fait pour Thomas* ✅
Recherche et désactivation: Sophie*
Fait pour Sophie* ✅
Recherche et désactivation: Lucas*
Fait pour Lucas* ✅
```

*"Parfait ! Aucune erreur cette fois. Je peux partir"*

---

## 💥 Le Désastre Se Révèle - Lundi 8h15

### Premier Appel - Service Commercial (8h17)
```
- Allô admin ? Marie Dubois ne peut pas se connecter !
- Elle dit que son compte est désactivé ?
- C'est notre directrice commerciale !
```

### Deuxième Appel - Comptabilité (8h22)
```
- Julien ! Sophie Leroux est bloquée !
- Elle peut pas faire la paie !
- C'est URGENT !
```

### Troisième Appel - DG (8h25)
```
- C'est quoi ce bordel ?!
- Alexandre Martin (DG adjoint) peut pas accéder !
- Réunion conseil d'admin dans 1h !
```

---

## 🔍 L'Enquête Forensique

### Les Vrais Dégâts
Julien vérifie ce qui s'est passé:

```powershell
# Qui a été désactivé vendredi ?
Get-ADUser -Filter {Enabled -eq $false} -Properties WhenChanged |
    Where-Object {$_.WhenChanged -gt (Get-Date "2023-10-13 16:00")} |
    Select-Object Name, SamAccountName, WhenChanged

Name                    SamAccountName      WhenChanged
----                    --------------      -----------
Alexandre Durand        alex.durand         13/10/2023 17:01:15
Alexandre Martin        alexandre.martin    13/10/2023 17:01:15    ← DG ADJOINT !
Marie Petit             marie.petit         13/10/2023 17:01:32
Marie Dubois            marie.dubois        13/10/2023 17:01:32    ← DIRECTRICE COMMERCIALE !
Thomas Bernard          thomas.bernard      13/10/2023 17:01:45
Thomas Duchemin         thomas.duchemin     13/10/2023 17:01:45    ← RESPONSABLE IT !
Sophie Martin           sophie.martin       13/10/2023 17:01:58
Sophie Leroux           sophie.leroux       13/10/2023 17:01:58    ← COMPTABLE CHEF !
Lucas Moreau            lucas.moreau        13/10/2023 17:02:12
Lucas Bertrand          lucas.bertrand      13/10/2023 17:02:12    ← DÉVELOPPEUR SENIOR !
```

### Le Pattern Mortel
Le wildcard `*` a matché:
- ✅ `Alexandre*` → Alexandre Durand (stagiaire)
- ☠️ `Alexandre*` → **Alexandre Martin (DG adjoint)**
- ✅ `Marie*` → Marie Petit (stagiaire)
- ☠️ `Marie*` → **Marie Dubois (directrice commerciale)**
- ✅ `Thomas*` → Thomas Bernard (stagiaire)
- ☠️ `Thomas*` → **Thomas Duchemin (responsable IT)**

**Résultat**: 5 stagiaires désactivés ✅ + 5 cadres dirigeants désactivés ☠️

---

## 🚑 La Course Contre la Montre

### 8h30 - Réactivation d'Urgence
```powershell
# Panic mode - réactivation sans réflexion
Get-ADUser -Filter {Enabled -eq $false} -Properties WhenChanged |
    Where-Object {$_.WhenChanged -gt (Get-Date "2023-10-13 16:00")} |
    Set-ADUser -Enabled $true

# ☠️ NOUVEAU PROBLÈME: Les vrais stagiaires aussi réactivés !
```

### 8h45 - Réunion de Crise
**Participants**: DG, DRH, Responsable IT, Julien
**Ambiance**: 🔥🔥🔥

**DG**: *"Comment un stagiaire peut désactiver mon compte ?!"*
**Resp IT**: *"Le script a utilisé des wildcards..."*
**DRH**: *"Mais j'avais donné les noms exacts !"*
**Julien**: *"Je... je pensais que... le script était fiable..."*

---

## 💰 Le Coût RÉEL du Désastre

### Impact Business
- **Réunion conseil d'administration** reportée → -€50,000 contrat
- **Paie en retard** → Mécontentement salarié + amendes administratives
- **Commercial bloqué** → 3 prospects perdus → -€120,000
- **Développement arrêté** → Livraison client retardée

### Coût Technique
- **Consultant externe urgent** weekend → €3,500
- **Heures sup équipe** → €1,200
- **Audit sécurité complet** → €8,000
- **Formation équipe** → €2,500

### Coût Humain
- **Stress Julien** → Arrêt maladie 1 semaine
- **Confiance équipe** → 6 mois pour récupérer
- **Réputation interne** → "L'admin qui a planté le système"

**TOTAL ESTIMÉ**: **€185,200** + réputation

---

## 🎓 Les Leçons Apprises

### Ce Que Julien Aurait DÛ Faire

#### 1. **Vérifier D'Abord**
```powershell
# TOUJOURS commencer par voir ce que ça va affecter
Get-ADUser -Filter {Name -like "Alexandre*"} | Select-Object Name, Title, Department
```

#### 2. **Utiliser des Identifiants Précis**
```powershell
# Utiliser SamAccountName ou DistinguishedName, pas Name avec wildcards
$stagiaires = @(
    "alex.durand",      # SamAccountName précis
    "marie.petit",      # Pas de wildcards
    "thomas.bernard"    # Identifiants exacts
)
```

#### 3. **-WhatIf Obligatoire**
```powershell
# JAMAIS exécuter directement
Get-ADUser -Identity "alex.durand" | Set-ADUser -Enabled $false -WhatIf
```

#### 4. **Validation Manuelle**
```powershell
# Demander confirmation pour chaque utilisateur critique
$utilisateur = Get-ADUser -Identity "alexandre.martin" -Properties Title
Write-Host "ATTENTION: $($utilisateur.Name) - $($utilisateur.Title)"
$confirmation = Read-Host "Confirmer désactivation ? (oui/non)"
if ($confirmation -ne "oui") {
    Write-Host "Opération annulée"
    continue
}
```

#### 5. **Environnement de Test**
```powershell
# Test d'abord sur environnement non-critique
if ($env:COMPUTERNAME -ne "PROD-DC01") {
    Write-Host "Test en cours sur environnement non-prod" -ForegroundColor Yellow
} else {
    Write-Error "Script de test ne doit pas tourner sur PROD!"
    exit
}
```

---

## 🔮 Script Sécurisé Final

Voici comment Julien aurait dû procéder:

```powershell
# Script de désactivation SÉCURISÉ
# Version: 2.0 - Post désastre
# Auteur: Julien (leçon apprise)

param(
    [switch]$WhatIf = $true  # -WhatIf par défaut !
)

# Liste PRÉCISE des comptes (vérifiée avec DRH)
$stagiaires = @(
    "alex.durand",
    "marie.petit",
    "thomas.bernard",
    "sophie.martin",
    "lucas.moreau"
)

Write-Host "=== DÉSACTIVATION COMPTES STAGIAIRES ===" -ForegroundColor Cyan
Write-Host "Mode: $($WhatIf ? 'SIMULATION' : 'RÉEL')" -ForegroundColor $(if($WhatIf){'Yellow'}else{'Red'})

foreach ($stagiaire in $stagiaires) {
    try {
        # Vérifier l'utilisateur existe
        $user = Get-ADUser -Identity $stagiaire -Properties Title, Department, Manager -ErrorAction Stop

        Write-Host "`n--- $($user.Name) ---" -ForegroundColor White
        Write-Host "SamAccountName: $($user.SamAccountName)"
        Write-Host "Titre: $($user.Title)"
        Write-Host "Département: $($user.Department)"

        # SÉCURITÉ: Vérifier que c'est bien un stagiaire
        if ($user.Title -notmatch "stagiaire|stage|intern" -and
            $user.Department -ne "Stagiaires") {
            Write-Warning "⚠️  ATTENTION: $($user.Name) ne semble pas être un stagiaire !"
            Write-Host "Titre: '$($user.Title)' - Département: '$($user.Department)'" -ForegroundColor Yellow
            $confirmation = Read-Host "Continuer quand même ? (tapez 'CONFIRMER' pour continuer)"
            if ($confirmation -ne "CONFIRMER") {
                Write-Host "❌ Opération annulée pour $($user.Name)" -ForegroundColor Red
                continue
            }
        }

        # Désactiver avec -WhatIf selon le paramètre
        Set-ADUser -Identity $stagiaire -Enabled $false -WhatIf:$WhatIf

        if ($WhatIf) {
            Write-Host "✅ SIMULATION: $($user.Name) serait désactivé" -ForegroundColor Yellow
        } else {
            Write-Host "✅ RÉEL: $($user.Name) désactivé" -ForegroundColor Green
        }

    } catch {
        Write-Error "❌ Erreur avec $stagiaire : $($_.Exception.Message)"
    }
}

if ($WhatIf) {
    Write-Host "`n🎯 SIMULATION TERMINÉE" -ForegroundColor Yellow
    Write-Host "Pour exécuter réellement: .\script.ps1 -WhatIf:`$false" -ForegroundColor Cyan
} else {
    Write-Host "`n✅ OPÉRATION RÉELLE TERMINÉE" -ForegroundColor Green
}
```

---

## 🎯 Morales de l'Histoire

### Pour les Admins
1. **-WhatIf n'est pas optionnel**, c'est de la survie professionnelle
2. **Wildcards + Active Directory = Danger mortel**
3. **Scripts internet = Adaptation obligatoire**
4. **Vendredi 17h = Moment le plus dangereux pour les changements**
5. **Vérification manuelle > Confiance aveugle**

### Pour les Organisations
1. **Environnement de test obligatoire**
2. **Procédures de validation pour changements AD**
3. **Backups et plans de rollback**
4. **Formation continue des admins**
5. **Code review même pour scripts "simples"**

### La Règle d'Or
> *"Si tu n'es pas sûr à 100% de ce que fait un script, commence par -WhatIf. Si tu es sûr à 100%, commence quand même par -WhatIf."*

---

**Épilogue**: Julien travaille toujours dans la même entreprise. Il est devenu le plus grand défenseur de -WhatIf de l'entreprise et raconte cette histoire à tous les nouveaux admins. Son bureau a une affiche: **"WWID: What Would -WhatIf Do?"**

Cette histoire est adaptée de plusieurs cas réels. Les noms et détails ont été modifiés, mais les erreurs et conséquences sont authentiques.