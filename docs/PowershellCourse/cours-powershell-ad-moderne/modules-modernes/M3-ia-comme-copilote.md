# Module 3 — L'IA comme copilote : prompts efficaces et validation critique
*Durée: 1h30 | Prérequis: Modules 1-2 complétés*

## Objectif

À la fin de ce module, vous saurez utiliser une IA (ChatGPT, Copilot, Claude…) comme un copilote fiable pour PowerShell AD — pas comme un pilote automatique aveugle.

---

## Le principe : copilote, pas pilote

L'approche à éviter :

```
"ChatGPT, écris-moi un script pour nettoyer AD"
→ Copier-coller direct
→ Exécution sans relecture
→ Désastre presque garanti
```

L'approche professionnelle :

```
"Aide-moi à comprendre et valider ce script AD"
→ Analyse ligne par ligne
→ Adaptation à l'environnement maxtec.be
→ Test avec -WhatIf
→ Exécution maîtrisée
```

---

## Quatre usages typiques

### Usage 1 — Générer une base de script

Bon pour : structure générale, syntaxe de base, point de départ.
Risque : moyen. Validation obligatoire.

### Usage 2 — Comprendre du code existant

Bon pour : expliquer un script complexe, identifier les risques.
Risque : faible. Validation recommandée.

### Usage 3 — Code review

Bon pour : repérer les erreurs, suggérer des améliorations sécurité.
Risque : très faible. Validation optionnelle.

### Usage 4 — Exécution directe sans relecture

À ne jamais faire. Risque maximal.

---

## Démo en direct — session ChatGPT

*L'instructeur ouvre ChatGPT devant la classe.*

**Ticket** : trouver tous les utilisateurs RH dont le mot de passe n'a pas changé depuis 6 mois.

### Prompt naïf — à éviter

```
écris un script powershell pour trouver les utilisateurs RH avec vieux mots de passe
```

Trop vague, aucun contexte de sécurité. La réponse sera générique et probablement inutilisable telle quelle.

### Prompt professionnel

```
Aide-moi à créer un script PowerShell pour Active Directory avec ces exigences:

CONTEXTE:
- Domaine: maxtec.be
- Recherche: utilisateurs département RH
- Critère: mot de passe non changé depuis 6 mois
- Environnement: production (sécurité critique)

EXIGENCES SÉCURITÉ:
- Inclus -WhatIf et validation d'erreurs
- Limiter le scope avec SearchBase
- Affichage clair des résultats
- Lecture seule, aucune modification
- Commentaires explicatifs

STRUCTURE OU: OU=RH,OU=EU,DC=maxtec,DC=be
```

### Réponse IA type

```powershell
# Script de recherche utilisateurs RH — Mots de passe anciens
# Généré avec assistance IA — à valider avant usage
# Domaine: maxtec.be

Import-Module ActiveDirectory

$dateLimit = (Get-Date).AddDays(-180)
$searchBase = "OU=RH,OU=EU,DC=maxtec,DC=be"

Write-Host "=== RECHERCHE UTILISATEURS RH — MOTS DE PASSE ANCIENS ===" -ForegroundColor Cyan
Write-Host "Date limite: $dateLimit" -ForegroundColor Yellow
Write-Host "Search Base: $searchBase" -ForegroundColor Yellow

try {
    if (-not (Get-Module ActiveDirectory)) {
        throw "Module ActiveDirectory non disponible"
    }

    try {
        Get-ADOrganizationalUnit -Identity $searchBase -ErrorAction Stop
        Write-Host "OU RH trouvée" -ForegroundColor Green
    } catch {
        throw "OU non trouvée: $searchBase"
    }

    $utilisateursRH = Get-ADUser -Filter * -SearchBase $searchBase `
                      -Properties PasswordLastSet, Department, LastLogonDate, Enabled `
                      -ErrorAction Stop

    Write-Host "Utilisateurs RH trouvés: $($utilisateursRH.Count)" -ForegroundColor Cyan

    $utilisateursMotDePasseAncien = $utilisateursRH | Where-Object {
        $_.PasswordLastSet -lt $dateLimit -and
        $_.Enabled -eq $true -and
        $_.PasswordLastSet -ne $null
    }

    if ($utilisateursMotDePasseAncien.Count -eq 0) {
        Write-Host "Aucun utilisateur RH avec mot de passe > 6 mois" -ForegroundColor Green
    } else {
        Write-Host "Utilisateurs RH avec mot de passe > 6 mois:" -ForegroundColor Yellow

        $utilisateursMotDePasseAncien | Select-Object `
            @{Name="Nom"; Expression={$_.Name}},
            @{Name="Login"; Expression={$_.SamAccountName}},
            @{Name="Dernier changement MDP"; Expression={$_.PasswordLastSet}},
            @{Name="Jours depuis changement"; Expression={((Get-Date) - $_.PasswordLastSet).Days}} |
            Format-Table -AutoSize

        Write-Host "Total concernés: $($utilisateursMotDePasseAncien.Count)" -ForegroundColor Red
    }

} catch {
    Write-Error "Erreur lors de l'exécution: $($_.Exception.Message)"
    Write-Host "Vérifiez les permissions et la connectivité AD" -ForegroundColor Yellow
}
```

---

## Validation critique du script généré

### Ce qui est bien

1. Gestion d'erreurs avec `try/catch`.
2. Vérifications préalables (module, OU).
3. SearchBase spécifique à maxtec.be.
4. Affichage formaté.
5. Lecture seule.

### Ce qui mérite attention

1. **SearchBase codée en dur** — et si la structure change ?
2. **Filtre Department** non utilisé — redondance avec SearchBase.
3. **Null check** — `PasswordLastSet` peut être `$null` pour certains comptes.

### Améliorations possibles

```powershell
# 1. Paramètres flexibles
param(
    [string]$SearchBase = "OU=RH,OU=EU,DC=maxtec,DC=be",
    [int]$JoursLimite = 180
)

# 2. Filtre plus robuste
$utilisateursMotDePasseAncien = $utilisateursRH | Where-Object {
    $_.PasswordLastSet -ne $null -and
    $_.PasswordLastSet -lt $dateLimit -and
    $_.Enabled -eq $true
}

# 3. Exclusion des comptes de service
$utilisateursMotDePasseAncien = $utilisateursRH | Where-Object {
    $_.PasswordLastSet -ne $null -and
    $_.PasswordLastSet -lt $dateLimit -and
    $_.Enabled -eq $true -and
    $_.SamAccountName -notlike "*svc*" -and
    $_.SamAccountName -notlike "*service*"
}
```

---

## Exercice 3.1 — votre premier prompt structuré

**Mission** : créer un prompt pour générer un script qui trouve tous les utilisateurs IT de maxtec.be verrouillés.

### Template à compléter

```
Aide-moi à créer un script PowerShell pour Active Directory avec ces exigences:

CONTEXTE:
- Domaine: [À COMPLÉTER]
- Recherche: [À COMPLÉTER]
- Critère: [À COMPLÉTER]
- Environnement: [À COMPLÉTER]

EXIGENCES SÉCURITÉ:
- [À COMPLÉTER]
- [À COMPLÉTER]
- [À COMPLÉTER]

STRUCTURE OU: [À COMPLÉTER]
```

### Solution

```
Aide-moi à créer un script PowerShell pour Active Directory avec ces exigences:

CONTEXTE:
- Domaine: maxtec.be
- Recherche: utilisateurs département IT
- Critère: comptes verrouillés (LockedOut = True)
- Environnement: production (sécurité critique)

EXIGENCES SÉCURITÉ:
- Gestion d'erreurs et validation
- Limiter le scope avec SearchBase
- Affichage des détails de verrouillage
- Option -WhatIf pour le déverrouillage
- Commentaires explicatifs

STRUCTURE OU: OU=IT,OU=EU,DC=maxtec,DC=be
```

---

## Cinq règles pour utiliser une IA avec PowerShell AD

### 1. Contexte précis = réponse précise

```
À éviter : "script powershell utilisateurs"
À préférer: "script PowerShell AD pour maxtec.be, utilisateurs département Ventes,
            recherche comptes expirés, production, avec -WhatIf"
```

### 2. Toujours demander les sécurités

Phrases utiles à inclure dans le prompt :

- "Inclus `-WhatIf` et validation d'erreurs"
- "Environnement production, sécurité critique"
- "Avec commentaires explicatifs"
- "Gestion d'erreurs robuste"

### 3. Valider ligne par ligne

```powershell
# Bon : on comprend chaque ligne
Get-ADUser -Filter {Department -eq "IT"} -Properties LockedOut

# Mauvais : on l'exécute parce que "ça marche"
Get-ADUser -Filter * | ?{$_.LockedOut} | %{Unlock-ADAccount $_}
```

### 4. Adapter à l'environnement

```powershell
# Script générique
-SearchBase "OU=Users,DC=contoso,DC=com"

# Adapté à maxtec.be
-SearchBase "OU=IT,OU=EU,DC=maxtec,DC=be"
```

### 5. Tester d'abord

```powershell
# Toujours commencer par observer
Get-ADUser -Filter {Department -eq "IT"} | Select-Object Name

# Puis exécuter la vraie commande
```

---

## L'IA comme outil de code review

### Prompt d'analyse de script

```
Analyse ce script PowerShell AD ligne par ligne et identifie tous les risques
de sécurité, erreurs potentielles, et améliorations nécessaires:

[COLLER LE SCRIPT ICI]

Focus sur:
- Commandes destructives sans -WhatIf
- Filtres trop larges
- Gestion d'erreurs manquante
- Hardcoding problématique
- Risques pour environnement production

Donne une note de sécurité /10 et explique comment corriger.
```

### Exemple d'analyse

**Script à analyser :**

```powershell
Get-ADUser -Filter * | Where-Object {$_.Department -eq "IT"} | Set-ADUser -Title "Informaticien"
```

**Réponse type :**

```
Note sécurité: 3/10

Risques identifiés:
1. Critique  — Get-ADUser -Filter * charge tous les utilisateurs du domaine
2. Critique  — Set-ADUser sans -WhatIf, modification directe
3. Moyen     — Pas de gestion d'erreurs
4. Moyen     — Pas de vérification préalable

Corrections nécessaires:
1. Utiliser SearchBase pour limiter le scope
2. Ajouter -WhatIf
3. Vérifier le département avant modification
4. Ajouter try/catch
```

---

## Exercice 3.2 — détecter les problèmes

Utilisez une IA pour analyser ce script et identifier les problèmes :

```powershell
Get-ADGroup -Filter {Name -like "GG-*"} | ForEach-Object {
    $membres = Get-ADGroupMember -Identity $_.Name
    if ($membres.Count -eq 0) {
        Remove-ADGroup -Identity $_.Name -Confirm:$false
    }
}
```

### Questions à poser à l'IA

1. Que fait exactement ce script ?
2. Quels sont les risques si je l'exécute sur maxtec.be ?
3. Comment le rendre sécurisé ?

### Risques attendus

- Suppression de groupes sans `-WhatIf`.
- Aucune vérification si certains groupes sont critiques.
- Erreur de logique : groupe vide ≠ groupe inutile.
- Aucune sauvegarde avant suppression.

---

## Templates de prompts prêts à utiliser

### Template diagnostic

```
Aide-moi à diagnostiquer un problème Active Directory:

SITUATION: [Décrire le problème]
DOMAINE: maxtec.be
UTILISATEUR/GROUPE CONCERNÉ: [Nom]
SYMPTÔMES: [Ce qui ne marche pas]

Génère un script de diagnostic PowerShell avec:
- Commandes pour identifier la cause
- Vérifications étape par étape
- Affichage clair des résultats
- Lecture seule
- Commentaires explicatifs
```

### Template action sécurisée

```
Crée un script PowerShell AD pour cette action:

ACTION: [Ce que je veux faire]
CIBLE: [Utilisateurs/Groupes concernés]
ENVIRONNEMENT: maxtec.be, production

SÉCURITÉS:
- -WhatIf par défaut
- Validation avant exécution
- Gestion d'erreurs
- Logging des actions
- Annulation possible

STRUCTURE OU: OU=[dept],OU=EU,DC=maxtec,DC=be
```

### Template code review

```
Analyse ce script PowerShell AD et donne un audit complet:

[COLLER SCRIPT]

FOCUS SÉCURITÉ:
- Risques pour production
- Commandes destructives
- Améliorations nécessaires
- Note sécurité /10
- Version corrigée

ENVIRONNEMENT: maxtec.be, domaine production
```

---

## Récapitulatif

### Ce que vous savez faire maintenant

1. Écrire des prompts précis qui produisent du code utilisable.
2. Valider de manière critique chaque script généré.
3. Adapter systématiquement à l'environnement cible.
4. Utiliser l'IA pour détecter les problèmes d'un script.
5. Garder `-WhatIf` comme réflexe, même avec l'IA.

### Points à retenir

- L'IA propose, vous décidez.
- Pas de copier-coller sans relecture.
- Toujours tester avant production.
- L'IA n'a pas votre contexte — elle se trompe sur les détails spécifiques.

### Workflow

1. Définir le problème.
2. Prompt précis avec contexte sécurité.
3. Valider ligne par ligne.
4. Adapter à maxtec.be.
5. Tester avec `-WhatIf`.
6. Documenter.

---

**Suite** : Module 4 — Détecter les scripts dangereux (erreurs cachées et pièges classiques).
