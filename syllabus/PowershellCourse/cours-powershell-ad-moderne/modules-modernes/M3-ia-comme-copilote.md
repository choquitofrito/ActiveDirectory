# Module 3: L'IA comme Copilote - Prompts Sécurisés et Validation Critique
*Durée: 1h30 | Prérequis: Modules 1-2 complétés*

## 🎯 Objectif de ce Module
**À la fin**: Vous saurez utiliser l'IA (ChatGPT, Copilot, etc.) comme un copilote fiable pour PowerShell AD, pas comme un pilote automatique dangereux.

---

## 🤝 Nouvelle Philosophie: IA = Copilote, PAS Pilote

### ❌ APPROCHE DANGEREUSE
```
"ChatGPT, écris-moi un script pour nettoyer AD"
→ Copier-coller direct
→ Exécution aveugle
→ 🔥 DÉSASTRE GARANTI
```

### ✅ APPROCHE PROFESSIONNELLE 2025
```
"IA, aide-moi à comprendre et valider ce script AD"
→ Analysis critique ligne par ligne
→ Adaptation environnement maxtec.be
→ Tests avec -WhatIf
→ ✅ Sécurité garantie
```

---

## 🧠 Les 4 Types d'Utilisation IA pour PowerShell AD

### Type 1: 🔍 **Générer des Idées de Base**
**Bon pour**: Structure générale, syntaxe de base, concepts
**Risque**: Moyen
**Validation**: Obligatoire

### Type 2: 🔧 **Comprendre du Code Existant**
**Bon pour**: Expliquer scripts complexes, identifier risques
**Risque**: Faible
**Validation**: Recommandée

### Type 3: 🚨 **Détecter les Problèmes**
**Bon pour**: Code review, identifier erreurs, suggestions sécurité
**Risque**: Très faible
**Validation**: Optionnelle

### Type 4: ⚡ **Exécution Directe**
**Bon pour**: JAMAIS
**Risque**: EXTRÊME
**Validation**: IMPOSSIBLE

---

## 🎯 Démonstration Live: Session ChatGPT Sécurisée

### Scénario Réel
*L'instructeur ouvre ChatGPT devant la classe*

**Ticket**: "Trouver tous les utilisateurs du département RH qui n'ont pas changé leur mot de passe depuis 6 mois"

### 🔥 PROMPT NAÏF (NE PAS FAIRE)
```
"écris un script powershell pour trouver les utilisateurs RH avec vieux mots de passe"
```

**Problème**: Trop vague, pas de contexte sécurité

### ✅ PROMPT PROFESSIONNEL
```
"Aide-moi à créer un script PowerShell pour Active Directory avec ces exigences:

CONTEXTE:
- Domaine: maxtec.be
- Recherche: utilisateurs département RH
- Critère: mot de passe non changé depuis 6 mois
- Environnement: Production (sécurité critique)

EXIGENCES SÉCURITÉ:
- INCLUS -WhatIf et validation d'erreurs
- Limiter scope avec SearchBase
- Affichage clair des résultats
- Pas de modifications, seulement lecture
- Commentaires explicatifs

EXEMPLE STRUCTURE OU: OU=RH,OU=EU,DC=maxtec,DC=be

Génère le script avec toutes les sécurités."
```

### 🤖 Réponse IA (Exemple)
```powershell
# Script de recherche utilisateurs RH - Mots de passe anciens
# Généré avec assistance IA - À VALIDER AVANT USAGE
# Domaine: maxtec.be

Import-Module ActiveDirectory

# Configuration
$dateLimit = (Get-Date).AddDays(-180)  # 6 mois
$searchBase = "OU=RH,OU=EU,DC=maxtec,DC=be"

Write-Host "=== RECHERCHE UTILISATEURS RH - MOTS DE PASSE ANCIENS ===" -ForegroundColor Cyan
Write-Host "Date limite: $dateLimit" -ForegroundColor Yellow
Write-Host "Search Base: $searchBase" -ForegroundColor Yellow

try {
    # Vérifier que le module AD est disponible
    if (-not (Get-Module ActiveDirectory)) {
        throw "Module ActiveDirectory non disponible"
    }

    # Vérifier que l'OU existe
    try {
        Get-ADOrganizationalUnit -Identity $searchBase -ErrorAction Stop
        Write-Host "✅ OU RH trouvée" -ForegroundColor Green
    } catch {
        throw "OU non trouvée: $searchBase"
    }

    # Rechercher utilisateurs RH avec propriétés nécessaires
    $utilisateursRH = Get-ADUser -Filter * -SearchBase $searchBase `
                      -Properties PasswordLastSet, Department, LastLogonDate, Enabled `
                      -ErrorAction Stop

    Write-Host "Utilisateurs RH trouvés: $($utilisateursRH.Count)" -ForegroundColor Cyan

    # Filtrer ceux avec mot de passe ancien
    $utilisateursMotDePasseAncien = $utilisateursRH | Where-Object {
        $_.PasswordLastSet -lt $dateLimit -and
        $_.Enabled -eq $true -and
        $_.PasswordLastSet -ne $null
    }

    # Afficher résultats
    if ($utilisateursMotDePasseAncien.Count -eq 0) {
        Write-Host "✅ Aucun utilisateur RH avec mot de passe > 6 mois" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Utilisateurs RH avec mot de passe > 6 mois:" -ForegroundColor Yellow
        Write-Host "================================================" -ForegroundColor Yellow

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

Write-Host "=== RECHERCHE TERMINÉE ===" -ForegroundColor Cyan
```

---

## 🔍 Validation Critique du Script IA

### ✅ Points Forts Identifiés
1. **Gestion d'erreurs** avec try-catch
2. **Vérifications préalables** (module, OU)
3. **SearchBase spécifique** à maxtec.be
4. **Affichage formaté** des résultats
5. **Pas de modifications** (read-only)

### ⚠️ Points à Améliorer
1. **Hardcodé**: SearchBase fixe (et si structure différente ?)
2. **Filtre Department**: Pas utilisé (redondance avec SearchBase)
3. **Null check**: PasswordLastSet peut être null pour certains comptes

### 🔧 Améliorations Suggérées
```powershell
# Amélioration 1: Paramètres flexibles
param(
    [string]$SearchBase = "OU=RH,OU=EU,DC=maxtec,DC=be",
    [int]$JoursLimite = 180
)

# Amélioration 2: Meilleur filtre
$utilisateursMotDePasseAncien = $utilisateursRH | Where-Object {
    $_.PasswordLastSet -ne $null -and
    $_.PasswordLastSet -lt $dateLimit -and
    $_.Enabled -eq $true
}

# Amélioration 3: Exclusions comptes service
$utilisateursMotDePasseAncien = $utilisateursRH | Where-Object {
    $_.PasswordLastSet -ne $null -and
    $_.PasswordLastSet -lt $dateLimit -and
    $_.Enabled -eq $true -and
    $_.SamAccountName -notlike "*svc*" -and
    $_.SamAccountName -notlike "*service*"
}
```

---

## 🎯 Exercice Pratique 3.1: Votre Premier Prompt Professionnel

### Mission
Créez un prompt pour générer un script qui trouve tous les utilisateurs IT de maxtec.be verrouillés.

### Template à Compléter
```
"Aide-moi à créer un script PowerShell pour Active Directory avec ces exigences:

CONTEXTE:
- Domaine: [À COMPLÉTER]
- Recherche: [À COMPLÉTER]
- Critère: [À COMPLÉTER]
- Environnement: [À COMPLÉTER]

EXIGENCES SÉCURITÉ:
- [À COMPLÉTER]
- [À COMPLÉTER]
- [À COMPLÉTER]

EXEMPLE STRUCTURE OU: [À COMPLÉTER]

Génère le script avec toutes les sécurités."
```

### Solution Suggérée
```
"Aide-moi à créer un script PowerShell pour Active Directory avec ces exigences:

CONTEXTE:
- Domaine: maxtec.be
- Recherche: utilisateurs département IT
- Critère: comptes verrouillés (LockedOut = True)
- Environnement: Production (sécurité critique)

EXIGENCES SÉCURITÉ:
- INCLUS gestion d'erreurs et validation
- Limiter scope avec SearchBase
- Affichage des détails de verrouillage
- Option -WhatIf pour déverrouillage
- Commentaires explicatifs

EXEMPLE STRUCTURE OU: OU=IT,OU=EU,DC=maxtec,DC=be

Génère le script avec toutes les sécurités et option de déverrouillage."
```

---

## 🛡️ Les 5 Règles d'Or pour Utiliser l'IA Sécurisée

### Règle #1: **Contexte Précis = Réponse Précise**
```
❌ "script powershell utilisateurs"
✅ "script PowerShell AD pour maxtec.be, utilisateurs département Ventes,
   recherche comptes expirés, production, avec -WhatIf"
```

### Règle #2: **Toujours Demander les Sécurités**
**Phrases magiques à inclure**:
- "INCLUS -WhatIf et validation d'erreurs"
- "environnement production, sécurité critique"
- "avec commentaires explicatifs"
- "gestion d'erreurs robuste"

### Règle #3: **Valider Ligne par Ligne**
```powershell
# ✅ BON: Comprendre chaque ligne
Get-ADUser -Filter {Department -eq "IT"} -Properties LockedOut

# ❌ MAUVAIS: Je ne comprends pas mais ça marche
Get-ADUser -Filter * | ?{$_.LockedOut} | %{Unlock-ADAccount $_}
```

### Règle #4: **Adapter à Votre Environnement**
```powershell
# ❌ Script générique de l'IA
-SearchBase "OU=Users,DC=contoso,DC=com"

# ✅ Adapté à maxtec.be
-SearchBase "OU=IT,OU=EU,DC=maxtec,DC=be"
```

### Règle #5: **Tester d'Abord, Exécuter Ensuite**
```powershell
# TOUJOURS commencer par:
Get-ADUser -Filter {Department -eq "IT"} -WhatIf  # Même si pas nécessaire
Get-ADUser -Filter {Department -eq "IT"} | Select-Object Name  # Voir le résultat
# PUIS exécuter la vraie commande
```

---

## 🎭 Cas d'Usage Avancés: L'IA comme Détecteur de Problèmes

### Scénario: Analyser un Script Suspect

**Prompt de Sécurité**:
```
"Analyse ce script PowerShell AD ligne par ligne et identifie tous les risques de sécurité, erreurs potentielles, et améliorations nécessaires:

[COLLER LE SCRIPT ICI]

Focus sur:
- Commandes dangereuses sans -WhatIf
- Filtres trop larges
- Gestion d'erreurs manquante
- Hardcoding problématique
- Risques pour environnement production

Donne une note de sécurité /10 et explique comment corriger."
```

### Exemple d'Analyse
**Script à analyser**:
```powershell
Get-ADUser -Filter * | Where-Object {$_.Department -eq "IT"} | Set-ADUser -Title "Informaticien"
```

**Réponse IA attendue**:
```
ANALYSE SÉCURITÉ: 3/10 ⚠️

RISQUES IDENTIFIÉS:
1. 🚨 CRITIQUE: Get-ADUser -Filter * charge TOUS les utilisateurs du domaine
2. 🚨 CRITIQUE: Set-ADUser sans -WhatIf = modifications directes
3. ⚠️  MOYEN: Pas de gestion d'erreurs
4. ⚠️  MOYEN: Pas de vérification préalable

CORRECTIONS NÉCESSAIRES:
1. Utiliser SearchBase pour limiter scope
2. Ajouter -WhatIf obligatoire
3. Vérifier département avant modification
4. Ajouter try-catch

SCRIPT CORRIGÉ:
[Script amélioré avec sécurités]
```

---

## 🎯 Exercice Pratique 3.2: IA Detective

### Mission
Utilisez l'IA pour analyser ce script "bomba" et identifier tous les problèmes:

```powershell
# Script trouvé sur un forum
Get-ADGroup -Filter {Name -like "GG-*"} | ForEach-Object {
    $membres = Get-ADGroupMember -Identity $_.Name
    if ($membres.Count -eq 0) {
        Remove-ADGroup -Identity $_.Name -Confirm:$false
    }
}
```

### Questions pour l'IA
1. "Que fait exactement ce script ?"
2. "Quels sont les risques si je l'exécute sur maxtec.be ?"
3. "Comment le rendre sécurisé ?"

### Réponse Attendue
**Risques majeurs**:
- Suppression de groupes sans -WhatIf
- Pas de vérification si groupes critiques
- Logic flaw: groupes vides ≠ groupes inutiles
- Aucune sauvegarde avant suppression

---

## 💡 Prompts Prêts à Utiliser (Templates)

### 🔍 **Template Diagnostic**
```
"Aide-moi à diagnostiquer un problème Active Directory:

SITUATION: [Décrire le problème]
DOMAINE: maxtec.be
UTILISATEUR/GROUPE CONCERNÉ: [Nom]
SYMPTÔMES: [Ce qui ne marche pas]

Génère un script de diagnostic PowerShell avec:
- Commandes pour identifier la cause
- Vérifications étape par étape
- Affichage clair des résultats
- Pas de modifications, seulement lecture
- Commentaires explicatifs"
```

### 🔧 **Template Action Sécurisée**
```
"Crée un script PowerShell AD pour cette action:

ACTION: [Ce que je veux faire]
CIBLE: [Utilisateurs/Groupes concernés]
ENVIRONNEMENT: maxtec.be, production critique

SÉCURITÉS OBLIGATOIRES:
- -WhatIf par défaut
- Validation avant exécution
- Gestion d'erreurs robuste
- Logging des actions
- Possibilité d'annulation

Structure OU: OU=[dept],OU=EU,DC=maxtec,DC=be"
```

### 🔍 **Template Code Review**
```
"Analyse ce script PowerShell AD et donne un audit complet:

[COLLER SCRIPT]

FOCUS SÉCURITÉ:
- Risques pour production
- Commandes dangereuses
- Améliorations nécessaires
- Note sécurité /10
- Version corrigée

ENVIRONNEMENT: maxtec.be, domaine production"
```

---

## 🎓 Récapitulatif: Maîtriser l'IA comme Copilote

### ✅ Ce Que Vous Savez Maintenant
1. **Prompts précis** = réponses utilisables
2. **Validation critique** de chaque script généré
3. **Adaptation environnement** obligatoire
4. **L'IA détecte** les problèmes mieux que nous
5. **-WhatIf reste roi** même avec l'IA

### 🚨 Ce Qu'Il Faut Retenir
- **L'IA = suggestions**, vous = décision finale
- **Jamais de copier-coller aveugle**
- **Toujours tester** avant production
- **L'IA peut se tromper** sur votre contexte spécifique

### 🎯 Votre Nouvelle Workflow
1. **Réfléchir** au problème
2. **Prompts précis** avec contexte sécurité
3. **Valider** ligne par ligne
4. **Adapter** à maxtec.be
5. **Tester** avec -WhatIf
6. **Documenter** ce qui fonctionne

---

*☕ **PAUSE OBLIGATOIRE 10 minutes** - Essayez vos propres prompts*

---

**🎯 Prochaine étape**: Module 4 - Scripts Bombes Lab (Détecter Erreurs Mortelles Cachées)