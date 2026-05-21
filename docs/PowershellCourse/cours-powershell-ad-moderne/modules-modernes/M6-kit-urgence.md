# Module 6 — Gérer un incident AD : procédures "break-glass"
*Durée: 1h00 | Prérequis: Modules 1-5 complétés*

## Objectif

À la fin de ce module, vous saurez réagir de façon structurée à un incident PowerShell AD qui part en vrille — sans aggraver la situation.

---

## Quand un script se passe mal

Les incidents critiques arrivent rarement à un moment pratique. Statistiquement, ils surviennent en fin de journée, en fin de semaine, ou pendant l'absence du responsable. La cause principale est rarement matérielle : c'est presque toujours un script PowerShell mal validé.

Trois règles pour éviter d'empirer les choses :

- La panique est plus dangereuse que l'incident lui-même.
- La mémoire défaille sous stress, donc on documente immédiatement.
- Tenter de réparer seul à chaud est la deuxième cause d'aggravation.

---

## Les 10 étapes d'une procédure structurée

### 1. Arrêter et respirer (30 secondes)

Arrêt total de l'activité. Mettre les notifications en sourdine. Prendre quelques secondes pour redescendre. La panique mène aux mauvaises décisions, qui mènent à des dégâts plus larges.

### 2. Évaluer l'impact (2 minutes)

Questions à se poser :

- Combien d'utilisateurs affectés ?
- Quels services sont indisponibles ?
- Données perdues ou seulement inaccessibles ?
- Quelle fenêtre de récupération est disponible ?

Commandes de diagnostic rapide :

```powershell
Get-ADDomain | Select-Object DNSRoot, DomainMode                 # domaine OK ?
Get-ADUser -Filter * -ResultSetSize 10 | Select-Object Name, Enabled    # users OK ?
Get-ADGroup -Filter {Name -like "GG-*"} -ResultSetSize 5         # groupes OK ?
```

### 3. Documenter immédiatement (1 minute)

```bash
echo "INCIDENT $(date): $(whoami) sur $(hostname)" > incident.log
echo "Commande exécutée: [copier exactement]" >> incident.log
echo "Erreur obtenue: [copier exactement]" >> incident.log
echo "Impact observé: [décrire]" >> incident.log
```

La mémoire défaille sous stress. Le document est la seule source fiable une heure plus tard.

### 4. Ne pas réparer seul (30 secondes)

À éviter :

- *"Je vais vite corriger ça."*
- *"Personne n'a besoin de savoir."*
- *"Un autre script va arranger ça."*
- *"Je peux rollback rapidement."*

À faire :

- Alerter le superviseur immédiatement.
- Documenter avant de toucher quoi que ce soit.
- Demander de l'aide avant d'aggraver.

### 5. Vérifier les sauvegardes (2 minutes)

```powershell
# Quoi vérifier:
# - Sauvegarde AD récente ?
# - System State backup ?
# - Snapshots VMware ?
# - Réplication fonctionnelle ?

Get-WinEvent -LogName "Directory Service" -MaxEvents 10
```

### 6. Isoler le problème (3 minutes)

Identifier précisément le périmètre affecté.

```powershell
$impactedOU = "OU=RH,OU=EU,DC=maxtec,DC=be"

# État actuel
Get-ADUser -Filter * -SearchBase $impactedOU -Properties Enabled |
    Group-Object Enabled |
    Select-Object Name, Count

# Comparaison avec une OU non affectée
Get-ADUser -Filter * -SearchBase "OU=IT,OU=EU,DC=maxtec,DC=be" -Properties Enabled |
    Group-Object Enabled |
    Select-Object Name, Count
```

### 7. Communiquer (2 minutes)

```
À: superviseur@maxtec.be, equipe-it@maxtec.be
Sujet: INCIDENT AD - $(date)

RÉSUMÉ
- Heure: $(Get-Date)
- Admin: $(whoami)
- Impact: [X utilisateurs / Y services]
- Cause: Script PowerShell [nom]

EN COURS
- Évaluation impact
- Vérification backups
- Équipe alertée
- Réparation en attente de validation

BESOIN
- Validation approche de récupération
- Autorisation procédure break-glass

Prochaine mise à jour: dans 15 minutes
```

### 8. Préparer le plan de récupération (5 minutes)

Pour un cas typique — utilisateurs désactivés par erreur :

```powershell
# Plan A: réactivation sélective
$affectedUsers = Get-ADUser -Filter {Enabled -eq $false} `
                  -SearchBase "OU=RH,OU=EU,DC=maxtec,DC=be" `
                  -Properties WhenChanged |
    Where-Object { $_.WhenChanged -gt (Get-Date).AddHours(-1) }

# Plan B: restauration depuis backup
#   Temps estimé: 2-4h
#   Impact: perte des données des dernières 24h
#   Validation nécessaire

# Plan C: reconstruction manuelle
#   Temps estimé: 6-8h
#   Ressources: équipe complète
#   Risque: erreurs humaines
```

### 9. Valider avant d'exécuter

```powershell
# Toujours tester sur un échantillon réduit d'abord
$testUser = $affectedUsers | Select-Object -First 1
Set-ADUser -Identity $testUser.SamAccountName -Enabled $true -WhatIf

# Puis procéder par lots, en vérifiant chaque action
foreach ($user in ($affectedUsers | Select-Object -First 5)) {
    Write-Host "Réactivation: $($user.Name)"
    Set-ADUser -Identity $user.SamAccountName -Enabled $true

    $check = Get-ADUser -Identity $user.SamAccountName -Properties Enabled
    if ($check.Enabled) {
        Write-Host "  OK: $($user.Name)" -ForegroundColor Green
    } else {
        Write-Host "  ÉCHEC: $($user.Name)" -ForegroundColor Red
        break   # Arrêter dès qu'un cas échoue
    }
}
```

### 10. Post-mortem (15 minutes)

Pas pour blâmer — pour apprendre.

```markdown
## INCIDENT REPORT - $(date)

### Timeline
- 17:02: Script exécuté
- 17:05: Erreur détectée
- 17:06: Incident déclaré
- 17:15: Impact évalué
- 17:45: Récupération commencée
- 18:30: Service restauré

### Root cause
- Script source: [URL/fichier]
- Erreur: absence de -WhatIf sur commande critique
- Validation manquée: filtre trop large

### Impact
- Utilisateurs affectés: X
- Services down: Y
- Durée: Z minutes

### Corrective actions
- [ ] Mise à jour procédure validation scripts
- [ ] Formation équipe sur -WhatIf obligatoire
- [ ] Amélioration système backup
- [ ] Script review process

### Lessons learned
- -WhatIf n'est jamais optionnel
- Pression temps ≠ excuse pour skip validation
- Documentation incident = crucial
```

---

## Simulation en classe — vendredi 17h12

**Email reçu :**

```
De: marie.dubois@maxtec.be
À: admin@maxtec.be
Sujet: URGENT - Plus personne ne peut se connecter Ventes

Toute l'équipe Ventes est bloquée !
Réunion client dans 30 minutes !
```

### Jeu de rôle

**Instructeur** : admin en panique.
**Étudiants** : équipe d'urgence appelée.

**Phase 1 — Calme initial (2 min)**

```
Admin   : "J'ai exécuté un script et maintenant..."
Équipe  : [Étape 1] "Stop. Respirer. Que s'est-il passé exactement ?"
```

**Phase 2 — Investigation (5 min)**

```
Équipe  : [Étapes 2-3] "Montrez le script et l'erreur."
Admin   : "Je voulais ajouter un utilisateur à un groupe..."
```

Script du désastre :

```powershell
# Intention
Add-ADGroupMember -Identity "GG-EU-Ventes-Users" -Members "nouvel.employe"

# Exécuté (typo + chaîne mal pensée)
Remove-ADGroupMember -Identity "GG-EU-Ventes-Users" `
    -Members (Get-ADGroupMember -Identity "GG-EU-Ventes-Users")
# Remove au lieu de Add, et on retire tous les membres existants
```

**Phase 3 — Plan d'action (3 min)**

```
Équipe : [Étapes 4-8]
- "Pas de panique : le groupe est vidé, mais les utilisateurs existent toujours."
- "Backup AD de ce matin disponible ?"
- "Liste des membres disponible ailleurs (export précédent) ?"
- "On commence par identifier qui était dans le groupe."
```

---

## Kit d'urgence — scripts

### Diagnostic rapide

```powershell
# diagnostic-urgence-ad.ps1
param($SearchBase = "OU=EU,DC=maxtec,DC=be")

Write-Host "=== DIAGNOSTIC URGENCE AD ===" -ForegroundColor Red

Write-Host "`n1. ÉTAT DOMAINE:" -ForegroundColor Yellow
Get-ADDomain | Select-Object DNSRoot, DomainMode, InfrastructureMaster

Write-Host "`n2. CONTRÔLEURS:" -ForegroundColor Yellow
Get-ADDomainController -Filter * | Select-Object Name, IPv4Address, OperatingSystem

Write-Host "`n3. ÉCHANTILLON UTILISATEURS:" -ForegroundColor Yellow
Get-ADUser -Filter * -SearchBase $SearchBase -ResultSetSize 10 |
    Select-Object Name, Enabled, LastLogonDate |
    Format-Table -AutoSize

Write-Host "`n4. GROUPES CRITIQUES:" -ForegroundColor Yellow
$groupesCritiques = @("Admins du domaine", "GG-EU-IT-Admin", "GG-EU-Ventes-Users")
foreach ($groupe in $groupesCritiques) {
    try {
        $membres = Get-ADGroupMember -Identity $groupe -ErrorAction Stop
        Write-Host "  OK   - $groupe : $($membres.Count) membres" -ForegroundColor Green
    } catch {
        Write-Host "  FAIL - $groupe : $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n5. ÉVÉNEMENTS RÉCENTS:" -ForegroundColor Yellow
Get-WinEvent -LogName Security -MaxEvents 5 |
    Where-Object { $_.Id -in @(4728, 4729, 4756, 4757) } |
    Select-Object TimeCreated, Id, LevelDisplayName, Message |
    Format-Table -Wrap
```

### Récupération d'un groupe vidé

```powershell
# recuperation-groupe-vide.ps1
param(
    [Parameter(Mandatory)]
    [string]$GroupName,

    [switch]$WhatIf = $true
)

Write-Host "=== RÉCUPÉRATION GROUPE VIDÉ ===" -ForegroundColor Cyan
Write-Host "Groupe: $GroupName" -ForegroundColor Yellow
Write-Host "Mode: $($WhatIf ? 'SIMULATION' : 'RÉEL')" -ForegroundColor $(if ($WhatIf) { 'Yellow' } else { 'Red' })

# 1. Vérifier l'état actuel du groupe
try {
    $groupe = Get-ADGroup -Identity $GroupName -ErrorAction Stop
    $membres = Get-ADGroupMember -Identity $GroupName -ErrorAction Stop

    if ($membres.Count -gt 0) {
        Write-Host "Attention: le groupe n'est pas vide ($($membres.Count) membres)" -ForegroundColor Yellow
        $membres | Select-Object Name | Format-Table
        $continuer = Read-Host "Continuer ? (oui/non)"
        if ($continuer -ne "oui") { exit }
    }
} catch {
    Write-Error "Groupe $GroupName introuvable: $($_.Exception.Message)"
    exit
}

# 2. Chercher dans les logs récents les anciens membres
Write-Host "`nRecherche dans les logs..." -ForegroundColor Yellow

$evenements = Get-WinEvent -LogName Security -MaxEvents 100 |
    Where-Object {
        $_.Id -eq 4729 -and
        $_.Message -match $GroupName -and
        $_.TimeCreated -gt (Get-Date).AddHours(-2)
    }

if ($evenements) {
    Write-Host "Événements de suppression trouvés:" -ForegroundColor Green
    $evenements | ForEach-Object {
        Write-Host "  $($_.TimeCreated): $($_.Message)" -ForegroundColor Cyan
    }
} else {
    Write-Host "Aucun événement récent trouvé." -ForegroundColor Red
    Write-Host "Alternatives:" -ForegroundColor Yellow
    Write-Host "  - Restaurer depuis backup AD"
    Write-Host "  - Reconstruction manuelle"
    Write-Host "  - Consulter la documentation métier"
}
```

---

## Contacts d'urgence — maxtec.be

```
Niveau 1 — Support local
  Admin principal: richard@maxtec.be
  Backup: irene@maxtec.be

Niveau 2 — Management IT
  Responsable IT: responsable.it@maxtec.be
  Astreinte: +33 6 XX XX XX XX

Niveau 3 — Direction (impact business critique uniquement)
  DG: directeur.general@maxtec.be
  DRH: marie.dubois@maxtec.be

Services externes
  Consultant AD urgence: SociétéX (+33 1 AA AA AA AA, 200€/h, intervention 2h)
  Service backup: BackupCorp (+33 8 BB BB BB BB, SLA 4h)
```

---

## Checklist — premières minutes

**Phase critique (5 premières minutes)**

- [ ] Stop. Respirer 30 secondes.
- [ ] Noter l'heure exacte de l'incident.
- [ ] Copier la commande qui a causé le problème.
- [ ] Copier le message d'erreur exact.
- [ ] Évaluer le nombre d'utilisateurs impactés.
- [ ] Alerter le superviseur si impact > 10 utilisateurs.
- [ ] Ne pas essayer de réparer seul.

**Phase récupération (après validation)**

- [ ] Tester la solution sur 1 utilisateur d'abord.
- [ ] Procéder par lots de 5 maximum.
- [ ] Vérifier chaque action avant la suivante.
- [ ] Documenter chaque étape.
- [ ] Tenir l'équipe informée toutes les 15 minutes.
- [ ] Préparer le post-mortem dès résolution.

---

## Récapitulatif

Cinq principes :

1. **Panique = ennemi principal** — elle aggrave systématiquement la situation.
2. **Documentation = survie** — la mémoire défaille sous stress.
3. **L'équipe est une ressource** — l'ego individuel est une faiblesse.
4. **Valider même en urgence** — pas d'exception.
5. **Post-mortem pour apprendre**, pas pour blâmer.

Mantra : *stop — respirer — documenter — demander de l'aide — valider — agir.*

---

## Fin du cours

Ce que vous maîtrisez maintenant :

1. Une approche réaliste du travail PowerShell AD en 2025.
2. Les commandes essentielles du support niveau 1 et 2.
3. L'utilisation professionnelle d'une IA comme copilote.
4. La détection des scripts dangereux.
5. Le réflexe `-WhatIf` systématique.
6. Une procédure structurée en cas d'incident.

Pour le lundi qui suit :

- Appliquer `-WhatIf` systématiquement.
- Valider chaque script trouvé en ligne avant exécution.
- Documenter les actions importantes.
- Partager ces réflexes avec les collègues.
