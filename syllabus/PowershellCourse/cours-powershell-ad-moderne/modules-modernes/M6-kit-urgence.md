# Module 6: Kit d'Urgence - Procédures "Break Glass" Quand Tout Explose
*Durée: 1h00 | Prérequis: Modules 1-5 complétés*

## 🎯 Objectif de ce Module
**À la fin**: Vous saurez garder votre sang-froid et appliquer des procédures structurées quand tout part en vrille un vendredi à 17h.

---

## 🚨 Réalité du Terrain: Quand Murphy Frappe

### La Loi de Murphy IT Version PowerShell
```
- Les erreurs arrivent TOUJOURS vendredi après 16h
- Plus c'est urgent, plus la probabilité d'erreur augmente
- Si quelque chose peut mal se passer avec un script, ça arrivera
- La sauvegarde que vous n'avez pas testée ne marchera pas
- Le script qui marche en dev explosera en prod
```

### 📊 Statistiques d'Urgence Réelles
```
🕐 Heure des incidents critiques AD:
   - 42% entre 16h-18h (fin de journée)
   - 23% le vendredi (effet weekend)
   - 67% pendant absence du responsable
   - 89% impliquent PowerShell mal utilisé
```

---

## 🆘 Procédure "Break Glass": Les 10 Étapes de Survie

### 🔴 **ÉTAPE 1: STOP - RESPIRER (30 secondes)**
```
⛔ ARRÊT TOTAL
🫁 Respirer profondément 3 fois
📱 Éteindre notifications Slack/Teams
🎯 "Je ne vais PAS paniquer"
```

**Pourquoi crucial**: Panique = mauvaises décisions = amplification du désastre

### 🔴 **ÉTAPE 2: ÉVALUER L'IMPACT (2 minutes)**
```powershell
# Questions vitales à se poser:
# - Combien d'utilisateurs affectés ?
# - Services critiques down ?
# - Données perdues ou juste inaccessibles ?
# - Fenêtre de récupération disponible ?

# Commands de diagnostic rapide maxtec.be
Get-ADDomain | Select-Object DNSRoot, DomainMode  # Domaine fonctionne ?
Get-ADUser -Filter * -ResultSetSize 10 | Select-Object Name, Enabled  # Users OK ?
Get-ADGroup -Filter {Name -like "GG-*"} -ResultSetSize 5  # Groupes OK ?
```

### 🔴 **ÉTAPE 3: DOCUMENTER CE QUI S'EST PASSÉ (1 minute)**
```bash
# Créer fichier incident IMMÉDIATEMENT
echo "INCIDENT $(date): $(whoami) sur $(hostname)" > incident.log
echo "Commande exécutée: [COPIER EXACTEMENT]" >> incident.log
echo "Erreur obtenue: [COPIER EXACTEMENT]" >> incident.log
echo "Impact observé: [DÉCRIRE]" >> incident.log
```

**Crucial**: Mémoire défaille sous stress. Document = truth source.

### 🔴 **ÉTAPE 4: NE PAS ESSAYER DE "RÉPARER" TOUT SEUL (30 secondes)**
```
❌ "Je vais vite corriger ça"
❌ "Personne n'a besoin de savoir"
❌ "Un autre script va arranger ça"
❌ "Je peux rollback rapidement"

✅ Alerter superviseur IMMÉDIATEMENT
✅ Documenter avant de toucher quoi que ce soit
✅ Demander aide AVANT d'aggraver
```

### 🔴 **ÉTAPE 5: VÉRIFIER BACKUPS DISPONIBLES (2 minutes)**
```powershell
# Vérifications critiques:
# - Sauvegarde AD récente ?
# - System State backup ?
# - VMware snapshots ?
# - Réplication fonctionnelle ?

# Commands de vérification
Get-WinEvent -LogName "Directory Service" -MaxEvents 10
# Chercher événements de réplication
```

### 🔴 **ÉTAPE 6: ISOLER LE PROBLÈME (3 minutes)**
```powershell
# Identifier périmètre exact de l'impact
# Exemple: Script a affecté quelle OU ?

$impactedOU = "OU=RH,OU=EU,DC=maxtec,DC=be"  # Exemple

# Vérifier état actuel
Get-ADUser -Filter * -SearchBase $impactedOU -Properties Enabled |
    Group-Object Enabled |
    Select-Object Name, Count

# Comparer avec OU non affectée
Get-ADUser -Filter * -SearchBase "OU=IT,OU=EU,DC=maxtec,DC=be" -Properties Enabled |
    Group-Object Enabled |
    Select-Object Name, Count
```

### 🔴 **ÉTAPE 7: COMMUNIQUER L'INCIDENT (2 minutes)**
```markdown
# Template message d'incident
📧 À: superviseur@maxtec.be, equipe-it@maxtec.be
📋 Sujet: INCIDENT AD CRITIQUE - $(date)

RÉSUMÉ:
- Heure: $(Get-Date)
- Admin: $(whoami)
- Impact: [X utilisateurs affectés / Y services down]
- Cause: Script PowerShell [nom du script]

ACTIONS EN COURS:
- Évaluation impact en cours
- Backups vérifiés
- Équipe alertée
- Réparation en attente validation

BESOIN:
- Validation approche de récupération
- Autorisation procédure break-glass
- [Autres besoins spécifiques]

Mise à jour suivante: dans 15 minutes
```

### 🔴 **ÉTAPE 8: PRÉPARER PLAN DE RÉCUPÉRATION (5 minutes)**
```powershell
# Exemple: Utilisateurs désactivés par erreur

# PLAN A: Réactivation sélective
$affectedUsers = Get-ADUser -Filter {Enabled -eq $false} -SearchBase "OU=RH,OU=EU,DC=maxtec,DC=be" -Properties WhenChanged |
    Where-Object {$_.WhenChanged -gt (Get-Date).AddHours(-1)}

# PLAN B: Restauration depuis backup
# - Temps estimé: 2-4h
# - Impact: Perte données dernières 24h
# - Validation: Nécessaire

# PLAN C: Reconstruction manuelle
# - Temps estimé: 6-8h
# - Ressources: Équipe complète
# - Risque: Erreurs humaines
```

### 🔴 **ÉTAPE 9: VALIDER AVANT D'EXÉCUTER (Toujours)**
```powershell
# JAMAIS exécuter réparation sans validation

# 1. Tester sur échantillon réduit
$testUser = $affectedUsers | Select-Object -First 1
Set-ADUser -Identity $testUser.SamAccountName -Enabled $true -WhatIf

# 2. Demander validation équipe
# 3. Documenter chaque action
# 4. Procéder par petits lots

foreach ($user in ($affectedUsers | Select-Object -First 5)) {
    Write-Host "Réactivation: $($user.Name)"
    Set-ADUser -Identity $user.SamAccountName -Enabled $true

    # Vérifier immédiatement
    $check = Get-ADUser -Identity $user.SamAccountName -Properties Enabled
    if ($check.Enabled) {
        Write-Host "✅ $($user.Name) réactivé" -ForegroundColor Green
    } else {
        Write-Host "❌ ÉCHEC $($user.Name)" -ForegroundColor Red
        break  # Arrêter si problème
    }
}
```

### 🔴 **ÉTAPE 10: POST-MORTEM OBLIGATOIRE (15 minutes)**
```markdown
# Template Post-Mortem

## INCIDENT REPORT - $(date)

### TIMELINE
- 17:02: Script exécuté
- 17:05: Erreur détectée
- 17:06: Incident déclaré
- 17:15: Impact évalué
- 17:45: Récupération commencée
- 18:30: Service restauré

### ROOT CAUSE
- Script source: [URL/fichier]
- Erreur: Absence -WhatIf sur commande critique
- Validation manquée: Filtre trop large

### IMPACT
- Utilisateurs affectés: X
- Services down: Y
- Durée: Z minutes
- Coût estimé: €W

### CORRECTIVE ACTIONS
1. [ ] Mise à jour procédure validation scripts
2. [ ] Formation équipe sur -WhatIf obligatoire
3. [ ] Amélioration système backup
4. [ ] Script review process

### LESSONS LEARNED
- -WhatIf n'est jamais optionnel
- Pression temps ≠ excuse pour skip validation
- Documentation incident = crucial
```

---

## 🎭 Simulation d'Urgence en Live

### Scenario: "Vendredi 17h12 - La Catastrophe"

**📧 Email paniqué reçu:**
```
De: marie.dubois@maxtec.be
À: admin@maxtec.be
Sujet: URGENT!!! Plus personne ne peut se connecter Ventes!!!

Aidez-nous ! Toute l'équipe Ventes est bloquée !
Réunion client dans 30 minutes !
```

### 🎪 **Jeu de Rôle: Classe = Équipe d'Urgence**

**Instructeur**: Admin en panique
**Étudiants**: Consultants urgence appelés

#### 🚨 **Séquence 1: Panique (2 min)**
```
Admin: "Oh non ! J'ai exécuté un script et maintenant..."
Équipe: [Applique ÉTAPE 1] "STOP. Respirer. Que s'est-il passé EXACTEMENT ?"
```

#### 🔍 **Séquence 2: Investigation (5 min)**
```
Équipe: [Applique ÉTAPE 2-3] "Montrez-nous le script et l'erreur"
Admin: "J'ai voulu ajouter un utilisateur à un groupe mais..."
```

**Script du Désastre Révélé:**
```powershell
# Ce qui était prévu
Add-ADGroupMember -Identity "GG-EU-Ventes-Users" -Members "nouvel.employe"

# Ce qui fut exécuté (typo fatale)
Remove-ADGroupMember -Identity "GG-EU-Ventes-Users" -Members (Get-ADGroupMember -Identity "GG-EU-Ventes-Users")
#     ↑ REMOVE au lieu de ADD !              ↑ TOUS les membres !
```

#### ⚡ **Séquence 3: Plan de Bataille (3 min)**
```
Équipe: [Applique ÉTAPES 4-8]
1. "Pas de panique, groupe vidé mais utilisateurs existent"
2. "Backup des groupes AD de ce matin ?"
3. "Liste des membres stockée ailleurs ?"
4. "Commençons par identifier qui était dans le groupe"
```

---

## 🛠️ Kit d'Urgence PowerShell AD

### 🚑 **Scripts de Diagnostic Rapide**
```powershell
# diagnostic-urgence-ad.ps1
param($SearchBase = "OU=EU,DC=maxtec,DC=be")

Write-Host "=== DIAGNOSTIC URGENCE AD ===" -ForegroundColor Red

# 1. État du domaine
Write-Host "`n1. ÉTAT DOMAINE:" -ForegroundColor Yellow
Get-ADDomain | Select-Object DNSRoot, DomainMode, InfrastructureMaster

# 2. Contrôleurs disponibles
Write-Host "`n2. CONTRÔLEURS:" -ForegroundColor Yellow
Get-ADDomainController -Filter * | Select-Object Name, IPv4Address, OperatingSystem

# 3. Échantillon utilisateurs
Write-Host "`n3. ÉCHANTILLON UTILISATEURS:" -ForegroundColor Yellow
Get-ADUser -Filter * -SearchBase $SearchBase -ResultSetSize 10 |
    Select-Object Name, Enabled, LastLogonDate |
    Format-Table -AutoSize

# 4. Groupes critiques
Write-Host "`n4. GROUPES CRITIQUES:" -ForegroundColor Yellow
$groupesCritiques = @("Admins du domaine", "GG-EU-IT-Admins", "GG-EU-Ventes-Users")
foreach ($groupe in $groupesCritiques) {
    try {
        $membres = Get-ADGroupMember -Identity $groupe -ErrorAction Stop
        Write-Host "✅ $groupe : $($membres.Count) membres" -ForegroundColor Green
    } catch {
        Write-Host "❌ $groupe : PROBLÈME!" -ForegroundColor Red
    }
}

# 5. Événements récents
Write-Host "`n5. ÉVÉNEMENTS RÉCENTS:" -ForegroundColor Yellow
Get-WinEvent -LogName Security -MaxEvents 5 |
    Where-Object {$_.Id -in @(4728, 4729, 4756, 4757)} |
    Select-Object TimeCreated, Id, LevelDisplayName, Message |
    Format-Table -Wrap
```

### 🔧 **Scripts de Récupération d'Urgence**
```powershell
# recuperation-groupe-vide.ps1
param(
    [Parameter(Mandatory)]
    [string]$GroupName,

    [switch]$WhatIf = $true
)

Write-Host "=== RÉCUPÉRATION GROUPE VIDÉ ===" -ForegroundColor Cyan
Write-Host "Groupe: $GroupName" -ForegroundColor Yellow
Write-Host "Mode: $($WhatIf ? 'SIMULATION' : 'RÉEL')" -ForegroundColor $(if($WhatIf){'Yellow'}else{'Red'})

# 1. Vérifier que groupe existe et est vide
try {
    $groupe = Get-ADGroup -Identity $GroupName -ErrorAction Stop
    $membres = Get-ADGroupMember -Identity $GroupName -ErrorAction Stop

    if ($membres.Count -gt 0) {
        Write-Host "⚠️  ATTENTION: Groupe n'est pas vide ($($membres.Count) membres)" -ForegroundColor Yellow
        Write-Host "Membres actuels:"
        $membres | Select-Object Name | Format-Table
        $continuer = Read-Host "Continuer quand même ? (oui/non)"
        if ($continuer -ne "oui") { exit }
    }
} catch {
    Write-Error "Groupe $GroupName non trouvé: $($_.Exception.Message)"
    exit
}

# 2. Chercher dans logs récents qui était membre
Write-Host "`nRecherche membres récents dans logs..." -ForegroundColor Yellow

# Rechercher événements de suppression groupe récents
$evenements = Get-WinEvent -LogName Security -MaxEvents 100 |
    Where-Object {
        $_.Id -eq 4729 -and  # Membre retiré d'un groupe
        $_.Message -match $GroupName -and
        $_.TimeCreated -gt (Get-Date).AddHours(-2)
    }

if ($evenements) {
    Write-Host "Événements de suppression trouvés:" -ForegroundColor Green
    $evenements | ForEach-Object {
        Write-Host "- $($_.TimeCreated): $($_.Message)" -ForegroundColor Cyan
    }
} else {
    Write-Host "❌ Aucun événement récent trouvé dans logs" -ForegroundColor Red
    Write-Host "Solutions alternatives:" -ForegroundColor Yellow
    Write-Host "1. Restaurer depuis backup AD" -ForegroundColor Yellow
    Write-Host "2. Reconstruction manuelle" -ForegroundColor Yellow
    Write-Host "3. Consulter documentation métier" -ForegroundColor Yellow
}
```

---

## 📞 **Contacts d'Urgence maxtec.be**
```markdown
### ESCALATION CHAIN

🔴 NIVEAU 1 - Support Local
- Admin Principal: richard@maxtec.be
- Tel: +33 1 XX XX XX XX
- Backup: irene@maxtec.be

🔴 NIVEAU 2 - Management IT
- Responsable IT: responsable.it@maxtec.be
- Tel: +33 1 YY YY YY YY
- Astreinte: +33 6 ZZ ZZ ZZ ZZ

🔴 NIVEAU 3 - Direction
- DG: directeur.general@maxtec.be
- DRH: marie.dubois@maxtec.be
- Uniquement si impact business critique

### SERVICES EXTERNES

🔧 Consultant AD Urgence
- SociétéX: +33 1 AA AA AA AA
- Tarif urgence: 200€/h
- Délai intervention: 2h

🔙 Service Backup
- Fournisseur: BackupCorp
- Hotline: +33 8 BB BB BB BB
- SLA restauration: 4h
```

---

## 🎯 Votre Checklist d'Urgence (À Plastifier)

### ⚡ **PHASE CRITIQUE (5 premières minutes)**
```
□ 1. STOP - Respirer 30 secondes
□ 2. Noter heure exacte incident
□ 3. Copier commande qui a causé problème
□ 4. Copier message d'erreur exact
□ 5. Évaluer nombre utilisateurs impactés
□ 6. Alerter superviseur SI impact > 10 users
□ 7. NE PAS essayer de réparer tout seul
```

### 🔧 **PHASE RÉCUPÉRATION (après validation)**
```
□ 8. Tester solution sur 1 utilisateur d'abord
□ 9. Procéder par lots de 5 maximum
□ 10. Vérifier chaque action avant suivante
□ 11. Documenter chaque étape
□ 12. Tenir équipe informée toutes les 15 min
□ 13. Préparer post-mortem dès résolution
```

---

## 🏆 Récapitulatif: Votre Nouveau Mindset de Crise

### 🧠 **Changements Mentaux Critiques**
1. **Panique = Ennemi #1** (plus dangereux que l'incident)
2. **Documentation = Survie** (mémoire défaille sous stress)
3. **Équipe = Force** (ego individuel = faiblesse)
4. **Validation = Toujours** (même en urgence)
5. **Post-mortem = Apprentissage** (pas blâme)

### 🎯 **Votre Mantra d'Urgence**
*"STOP - RESPIRER - DOCUMENTER - DEMANDER AIDE - VALIDER - AGIR"*

### 🏅 **Vous Êtes Maintenant...**
Un **Crisis PowerShell Warrior** certifié, capable de:
- ✅ Garder sang-froid sous pression maximale
- ✅ Suivre procédures structurées en chaos
- ✅ Communiquer efficacement en crise
- ✅ Récupérer sans aggraver la situation
- ✅ Transformer échec en apprentissage

---

## 🎓 **FIN DU COURS: Vous Êtes Prêt(e) pour le Monde Réel**

### Ce Que Vous Maîtrisez Maintenant
1. **Philosophie 2025**: IA + Validation critique
2. **Commands de Survie**: 10 commandes qui sauvent carrières
3. **Prompts Sécurisés**: Utilisation professionnelle IA
4. **Détection Bombes**: Identifier erreurs mortelles cachées
5. **Religion -WhatIf**: Sécurité avant vitesse
6. **Gestion Crise**: Procédures break-glass structurées

### 🎯 **Votre Mission Lundi Matin**
- Appliquer **-WhatIf** religieusement
- Valider **chaque script** trouvé online
- Documenter **vos actions** importantes
- Aider **collègues** avec cette philosophie
- Partager **cas d'usage** avec la communauté

---
