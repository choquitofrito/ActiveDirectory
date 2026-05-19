# Exercice 06 : Investigation d'Incident de Sécurité

## Niveau de Difficulté

Avancé

## Objectifs Pédagogiques

- Déclencher soi-même des événements réels dans le journal Security pour comprendre la trace qu'ils laissent
- Conduire une investigation forensique d'un incident AD en suivant une méthodologie structurée
- Corréler des événements de sécurité issus de plusieurs sources pour reconstruire une chronologie
- Prendre des mesures de remédiation appropriées et rédiger un rapport d'incident

## Durée Estimée

90 minutes (45 min déclenchement + 45 min investigation/rapport)

## Prérequis

- Tous les exercices précédents complétés (01–05)
- Audit AD activé (configuré par `MonitoringLab_Setup.ps1` à l'étape 7, et renforcé par les GPOs de l'exercice 03)
- Au moins deux fenêtres PowerShell ouvertes : une "attaquant" et une "investigateur"

## Contexte / Scénario

!!! example "Scénario pédagogique"
    Vous allez **jouer les deux rôles** dans cet exercice :

    - **Rôle A — L'attaquant** : vous effectuez une série d'actions suspectes en utilisant des credentials privilégiés. Chaque action laisse une trace dans le journal Security.
    - **Rôle B — L'investigateur** : 15 minutes après vos actions, vous "découvrez l'incident" et devez reconstruire ce qui s'est passé en lisant uniquement les journaux.

    L'intérêt : vous saurez exactement ce qu'un attaquant aurait fait, et vous vérifierez si l'audit configuré aux exercices précédents permet bien de retrouver toute la chronologie. Si une action manque dans les logs, c'est que l'audit n'est pas assez large — c'est une découverte précieuse.

!!! warning "Avant de commencer"
    Notez l'heure de début sur une feuille à part : `$($Date_debut = Get-Date)`. Vous en aurez besoin pour filtrer les événements dans la phase d'investigation.

---

## Phase 1 : Préparation (5 min)

### Tâche 1.1 : Vérifier que l'audit est actif

```powershell
# Doit montrer Success et/ou Failure activés pour ces sous-catégories
auditpol /get /subcategory:"User Account Management","Security Group Management","Logon" |
    Select-String "User Account|Security Group|Logon"
```

!!! success "Résultat attendu"
    Au minimum **User Account Management : Success and Failure**, **Security Group Management : Success and Failure**, et **Logon : Success and Failure**. Si l'un manque :

    ```powershell
    auditpol /set /subcategory:"User Account Management" /success:enable /failure:enable
    auditpol /set /subcategory:"Security Group Management" /success:enable /failure:enable
    auditpol /set /subcategory:"Logon" /success:enable /failure:enable
    ```

### Tâche 1.2 : Marquer le début de l'incident

```powershell
$Date_debut = Get-Date
Write-Host "Début de l'incident simulé : $Date_debut" -ForegroundColor Yellow
# Notez cette heure quelque part - vous en aurez besoin plus tard
```

---

## Phase 2 : Rôle A — Effectuer les actions suspectes (15 min)

Vous incarnez un attaquant qui a compromis un compte privilégié. Effectuez les actions suivantes **dans l'ordre**, en attendant 30 secondes entre chacune (pour qu'elles soient séparables dans la chronologie).

!!! danger "Ces actions sont réelles dans votre lab"
    Elles laisseront de vraies traces dans le journal Security. Faites-les uniquement sur ce lab MonitoringLab, pas sur un environnement de production.

### Action 1 — Échecs de connexion (Event ID 4625)

Vous tentez de "deviner" le mot de passe du compte `pascal` (CFO de Finance).

Depuis une fenêtre **cmd**, exécutez 3 fois (avec un mauvais mot de passe à chaque fois) :

```cmd
runas /user:maxtec\pascal cmd
```

Quand l'invite demande le mot de passe, entrez n'importe quel mauvais mot de passe et appuyez sur Entrée. La commande échouera — c'est le but. Recommencez 3 fois.

**Trace attendue** : 3 événements **4625** (Échec de connexion).

### Action 2 — Connexion réussie (Event ID 4624)

Vous trouvez enfin le bon mot de passe. Connectez-vous avec un compte existant — par exemple `alexandre` (Responsable Infrastructure) :

```cmd
runas /user:maxtec\alexandre cmd
```

Entrez le **bon** mot de passe (`Monitor2024!`). Une nouvelle fenêtre cmd s'ouvre sous ce compte.

**Trace attendue** : 1 événement **4624** (Connexion réussie) avec `LogonType=2` (interactive).

### Action 3 — Création d'un compte dormant (Event ID 4720)

Toujours sous le compte compromis (ou directement en Domain Admin pour simplifier l'exercice), créez un nouveau compte qui servira de porte dérobée :

```powershell
$pwd = ConvertTo-SecureString "Backdoor_2026!" -AsPlainText -Force
New-ADUser -Name "Compte Backup" `
    -SamAccountName "svc_backup_v2" `
    -UserPrincipalName "svc_backup_v2@maxtec.be" `
    -Path "OU=ServiceAccounts,OU=MONITORING,DC=maxtec,DC=be" `
    -AccountPassword $pwd `
    -Enabled $true `
    -PasswordNeverExpires $true `
    -Description "Compte temporaire - À supprimer après l'exercice"
```

**Trace attendue** : 1 événement **4720** (Compte utilisateur créé).

### Action 4 — Escalade de privilèges (Event ID 4728)

Vous ajoutez ce nouveau compte au groupe Finance Admin pour avoir accès aux données financières :

```powershell
Add-ADGroupMember -Identity "GG-MONITORING-Finance-Admin" -Members "svc_backup_v2"
```

**Trace attendue** : 1 événement **4728** (Membre ajouté à un groupe global de sécurité).

### Action 5 — Modification d'un compte existant (Event ID 4738)

Vous modifiez la description d'un compte légitime pour effacer vos traces :

```powershell
Set-ADUser -Identity "alexandre" -Description "Compte principal Infrastructure"
```

**Trace attendue** : 1 événement **4738** (Compte utilisateur modifié).

### Action 6 — Désactivation d'un compte sensible (Event ID 4725)

Vous désactivez le compte d'audit pour empêcher la détection :

```powershell
Disable-ADAccount -Identity "henri"
```

**Trace attendue** : 1 événement **4725** (Compte utilisateur désactivé).

### Synthèse de la Phase 2

Vous venez d'effectuer 6 actions distinctes qui couvrent les principales catégories d'événements de sécurité AD. La phase 3 commence maintenant : vous "découvrez" l'incident et devez tout reconstruire en lisant les logs.

---

## Phase 3 : Rôle B — Investigation (30 min)

!!! info "Méthodologie d'investigation"
    Une investigation forensique suit toujours cet ordre :

    1. Collecter les preuves sans les altérer
    2. Établir une chronologie des événements
    3. Identifier le vecteur d'attaque
    4. Évaluer l'étendue des dommages
    5. Identifier le responsable (si possible)

### Tâche 3.1 : Collecter TOUS les événements depuis l'heure de début

```powershell
# Récupérer tous les événements pertinents depuis le début de l'incident
$eventIds = @(4624, 4625, 4720, 4722, 4725, 4728, 4729, 4732, 4733, 4738, 4740)

$evenements = Get-WinEvent -FilterHashtable @{
    LogName   = "Security"
    Id        = $eventIds
    StartTime = $Date_debut
} | Sort-Object TimeCreated

Write-Host "Événements collectés : $($evenements.Count)" -ForegroundColor Cyan
```

!!! success "Résultat attendu"
    Vous devriez avoir au minimum **6 événements**, correspondant aux 6 actions de la phase 2 (souvent plus, car certaines actions génèrent plusieurs événements connexes).

### Tâche 3.2 : Construire la chronologie

```powershell
$chronologie = foreach ($event in $evenements) {
    $xml = [xml]$event.ToXml()
    $data = $xml.Event.EventData.Data

    $compte = ($data | Where-Object { $_.Name -eq "TargetUserName" }).'#text'
    $par    = ($data | Where-Object { $_.Name -eq "SubjectUserName" }).'#text'
    $ip     = ($data | Where-Object { $_.Name -eq "IpAddress" }).'#text'

    [PSCustomObject]@{
        Heure   = $event.TimeCreated.ToString("HH:mm:ss")
        EventID = $event.Id
        Cible   = $compte
        Par     = $par
        IP      = $ip
    }
}

$chronologie | Format-Table -AutoSize
```

!!! success "Résultat attendu"
    Un tableau ordonné dans le temps qui devrait montrer :

    | Heure | EventID | Description (à déduire) |
    |-------|---------|---|
    | T+0   | 4625 × 3 | Échecs de connexion sur `pascal` |
    | T+1m  | 4624    | Connexion réussie de `alexandre` |
    | T+2m  | 4720    | Création de `svc_backup_v2` |
    | T+3m  | 4728    | Ajout à `GG-MONITORING-Finance-Admin` |
    | T+4m  | 4738    | Modification d'`alexandre` |
    | T+5m  | 4725    | Désactivation de `henri` |

### Tâche 3.3 : Identifier les comptes touchés

```powershell
# Quels comptes ont été créés ou modifiés ?
$evenements | Where-Object { $_.Id -in @(4720, 4738, 4725, 4722) } |
    ForEach-Object {
        $xml = [xml]$_.ToXml()
        $cible = ($xml.Event.EventData.Data | Where-Object { $_.Name -eq "TargetUserName" }).'#text'
        Write-Host "Event $($_.Id) à $($_.TimeCreated.ToString('HH:mm:ss')) : $cible"
    }
```

### Tâche 3.4 : Identifier les groupes modifiés

```powershell
# Quels groupes ont vu leur composition changer ?
$evenements | Where-Object { $_.Id -in @(4728, 4729, 4732, 4733) } |
    ForEach-Object {
        $xml = [xml]$_.ToXml()
        $groupe = ($xml.Event.EventData.Data | Where-Object { $_.Name -eq "TargetUserName" }).'#text'
        $membre = ($xml.Event.EventData.Data | Where-Object { $_.Name -eq "MemberName" }).'#text'
        $action = if ($_.Id -in @(4728, 4732)) { "AJOUT" } else { "RETRAIT" }
        Write-Host "[$action] $($_.TimeCreated.ToString('HH:mm:ss')) | Groupe: $groupe | Membre: $membre"
    }
```

### Tâche 3.5 : Exporter la chronologie en CSV

```powershell
$chronologie | Export-Csv "C:\Labos\incident_$(Get-Date -Format 'yyyyMMdd_HHmm').csv" `
    -NoTypeInformation -Encoding UTF8
```

---

## Phase 4 : Remédiation (10 min)

À partir de votre chronologie, vous savez maintenant exactement ce qui s'est passé. Mettez en place les actions correctives.

### Tâche 4.1 : Neutraliser le compte porte dérobée

```powershell
# Désactiver immédiatement le compte créé pendant l'incident
Disable-ADAccount -Identity "svc_backup_v2"
Set-ADUser -Identity "svc_backup_v2" `
    -Description "COMPROMIS - Créé pendant incident le $(Get-Date -Format 'dd/MM/yyyy') - À supprimer après validation"

# Réinitialiser le mot de passe pour empêcher une réactivation
$newPwd = ConvertTo-SecureString "P0stIncident@$(Get-Random)!" -AsPlainText -Force
Set-ADAccountPassword -Identity "svc_backup_v2" -NewPassword $newPwd -Reset
```

### Tâche 4.2 : Nettoyer les appartenances aux groupes

```powershell
# Retirer le compte compromis du groupe Finance Admin
Remove-ADGroupMember -Identity "GG-MONITORING-Finance-Admin" `
    -Members "svc_backup_v2" -Confirm:$false
```

### Tâche 4.3 : Réactiver les comptes désactivés à tort

```powershell
# Si henri a été désactivé pendant l'incident, le réactiver
Enable-ADAccount -Identity "henri"
```

### Tâche 4.4 : Forcer le changement de mot de passe d'`alexandre`

Le compte qui a "été utilisé" doit être considéré comme compromis :

```powershell
Set-ADUser -Identity "alexandre" -ChangePasswordAtLogon $true
```

---

## Phase 5 : Rapport d'incident (10 min)

### Tâche 5.1 : Rédiger le rapport d'incident

Créez un fichier `C:\Labos\rapport_incident.txt` avec la structure suivante (utilisez vos données collectées dans la phase 3) :

```
RAPPORT D'INCIDENT DE SÉCURITÉ
===============================
Date de l'incident   : [date du jour]
Détecté par          : [votre nom / votre fonction]
Heure de détection   : [Date_debut + 15min, simulée]
Heure de confinement : [Get-Date au moment de la Phase 4]

1. RÉSUMÉ EXÉCUTIF
   [2-3 phrases : compte légitime compromis, création d'un compte
   dormant, escalade dans un groupe sensible, désactivation d'un
   compte d'audit pour brouiller les pistes.]

2. CHRONOLOGIE
   [Tableau extrait de la phase 3 — heure, Event ID, action, compte cible]

3. ÉTENDUE DE L'IMPACT
   - Comptes créés         : svc_backup_v2
   - Comptes modifiés      : alexandre (description), henri (désactivé)
   - Groupes modifiés      : GG-MONITORING-Finance-Admin (+ svc_backup_v2)
   - Données potentiellement accédées : à investiguer (cf. exercice 05)

4. VECTEUR D'ATTAQUE
   [Tentatives échouées sur pascal puis connexion réussie sur alexandre.
   Mot de passe d'alexandre vraisemblablement compromis (brute-force réussi,
   hameçonnage, ou autre source).]

5. MESURES DE CONFINEMENT
   - Compte svc_backup_v2 désactivé et mot de passe réinitialisé
   - Compte retiré de GG-MONITORING-Finance-Admin
   - Compte henri réactivé
   - Forçage du changement de mot de passe d'alexandre

6. REMÉDIATION
   [Actions effectuées dans la phase 4]

7. RECOMMANDATIONS
   - Renforcer la politique de mots de passe (déjà fait dans Ex. 03)
   - Activer l'authentification multi-facteurs sur les comptes Admin
   - Revoir l'audit pour s'assurer que TOUS les événements
     pertinents sont bien capturés (cf. tâche 3.1)
   - Mettre en place une alerte automatique sur les modifications
     du groupe Finance Admin (cf. exercice 04 — 4_Create-CustomAlerts.ps1)
```

---

## Nettoyage de l'exercice

Pour remettre le lab dans son état initial avant l'exercice :

```powershell
# Supprimer le compte créé pendant l'incident
Remove-ADUser -Identity "svc_backup_v2" -Confirm:$false

# Restaurer la description d'alexandre (si vous le souhaitez)
Set-ADUser -Identity "alexandre" -Description $null

Write-Host "Lab nettoyé." -ForegroundColor Green
```

---

## Vérification de la Réussite

### Commandes PowerShell de Vérification

```powershell
Import-Module ActiveDirectory
Write-Host "=== Vérification Exercice 06 ===" -ForegroundColor Cyan
$erreurs = 0

# Test 1 : Le compte svc_backup_v2 a été créé puis désactivé/supprimé
$bd = Get-ADUser -Filter { SamAccountName -eq "svc_backup_v2" } -ErrorAction SilentlyContinue
if ($bd -and -not $bd.Enabled) {
    Write-Host "svc_backup_v2 désactivé : OK" -ForegroundColor Green
} elseif (-not $bd) {
    Write-Host "svc_backup_v2 supprimé (nettoyage final) : OK" -ForegroundColor Green
} else {
    Write-Host "svc_backup_v2 toujours ACTIF — incomplet" -ForegroundColor Red
    $erreurs++
}

# Test 2 : svc_backup_v2 retiré du groupe Finance Admin
$finadm = Get-ADGroupMember "GG-MONITORING-Finance-Admin" |
    Select-Object -ExpandProperty SamAccountName
if ($finadm -notcontains "svc_backup_v2") {
    Write-Host "svc_backup_v2 absent de Finance-Admin : OK" -ForegroundColor Green
} else {
    Write-Host "svc_backup_v2 toujours dans Finance-Admin !" -ForegroundColor Red
    $erreurs++
}

# Test 3 : henri réactivé
$h = Get-ADUser "henri" -Properties Enabled
if ($h.Enabled) {
    Write-Host "henri réactivé : OK" -ForegroundColor Green
} else {
    Write-Host "henri est désactivé — vérifier si intentionnel" -ForegroundColor Yellow
}

# Test 4 : alexandre forcé à changer son mot de passe
$a = Get-ADUser "alexandre" -Properties pwdLastSet, PasswordExpired
if ($a.PasswordExpired) {
    Write-Host "alexandre doit changer son mot de passe au prochain logon : OK" -ForegroundColor Green
} else {
    Write-Host "alexandre n'est pas forcé de changer son mot de passe — ajouter -ChangePasswordAtLogon `$true" -ForegroundColor Yellow
}

# Test 5 : événements de la phase 2 retrouvés dans les logs
$nbEvts = (Get-WinEvent -FilterHashtable @{LogName="Security"; Id=@(4624,4625,4720,4725,4728,4738); StartTime=$Date_debut} -ErrorAction SilentlyContinue).Count
Write-Host "Événements collectés depuis Date_debut : $nbEvts (attendu ≥ 6)" -ForegroundColor $(if ($nbEvts -ge 6) { "Green" } else { "Yellow" })

Write-Host "`n========================================" -ForegroundColor Cyan
if ($erreurs -eq 0) {
    Write-Host "INVESTIGATION ET REMÉDIATION RÉUSSIES !" -ForegroundColor Green
} else {
    Write-Host "REMÉDIATION INCOMPLÈTE : $erreurs point(s) à corriger" -ForegroundColor Red
}
```

### Critères de Réussite

- [ ] Vous avez déclenché les 6 actions de la phase 2 (échecs de logon, connexion réussie, création, ajout groupe, modification, désactivation)
- [ ] Vous avez retrouvé chacune de ces actions dans le journal Security via PowerShell
- [ ] Vous avez construit une chronologie ordonnée des événements
- [ ] Vous avez exporté la chronologie en CSV
- [ ] Vous avez appliqué les 4 actions de remédiation (désactivation `svc_backup_v2`, retrait du groupe, réactivation `henri`, force-change du mdp d'`alexandre`)
- [ ] Vous avez rédigé un rapport d'incident avec les 7 sections demandées

---

## Points Clés à Retenir

- **L'audit doit être configuré AVANT l'incident**. Sans audit, les actions de l'attaquant n'auront pas laissé de trace — votre chronologie sera vide.
- **Le confinement précède l'investigation** : on désactive le compte compromis et on nettoie les modifications avant d'analyser l'incident en profondeur.
- **Une chronologie ordonnée** est la base de tout rapport d'incident. Elle permet de comprendre la séquence et démontrer l'étendue de la compromission.
- **Les "petites" modifications comptent** : un attaquant intelligent ne crée pas un compte "BACKDOOR_HAXOR" évident — il imite la nomenclature existante (`svc_backup_v2` ressemble à `svc_backup`).
- **Les comptes d'audit (henri) sont des cibles** : les désactiver fait disparaître les yeux de la sécurité. C'est pourquoi il faut alerter immédiatement sur leur désactivation.

## Dépannage (Erreurs Courantes)

| Erreur Possible | Cause | Solution |
|-----------------|-------|----------|
| Peu d'événements dans les journaux après la Phase 2 | Audit non activé | Tâche 1.1 — vérifier `auditpol /get` et relancer l'audit |
| `runas /user:maxtec\pascal` ne génère pas 4625 | Le DC n'écrit pas les échecs venant du DC lui-même de la même façon | Faire le test depuis un client joint au domaine, ou utiliser `Invoke-Command -Credential` |
| `Date_debut` perdu entre les phases | Variable PowerShell volatile | Notez l'heure sur papier OU exportez : `Get-Date \| Export-Clixml C:\Labos\debut.xml` |
| Événements anciens écrasés | Journal Security trop petit | Vérifier la GPO `MONITORING - Configuration Journaux Événements` (Ex. 03) : 2 GB attendus |
| Pas d'IP source dans les événements | Connexion locale ou via service | Normal pour les actions effectuées sur le DC lui-même — l'IP est vide ou `127.0.0.1` |

## Récapitulatif de la Progression

!!! info "Félicitations !"
    Vous avez complété les 6 exercices du Labo MonitoringLab. Vous maîtrisez maintenant :

    - L'exploration de la structure Active Directory
    - L'analyse des journaux d'événements de sécurité
    - La configuration de GPOs de sécurité et d'audit via GPMC
    - La gestion et sécurisation des comptes de service
    - La mise en place d'une politique d'audit personnalisée
    - La conduite d'une investigation d'incident de sécurité

    Ces compétences sont directement applicables dans un environnement professionnel réel.
