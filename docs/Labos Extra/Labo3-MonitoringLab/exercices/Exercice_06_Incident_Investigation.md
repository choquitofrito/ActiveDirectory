# Exercice 06 : Investigation d'Incident de Sécurité

## Niveau de Difficulté

Avancé

## Objectifs Pédagogiques

- Conduire une investigation forensique d'un incident AD en suivant une méthodologie structurée
- Corréler des événements de sécurité issus de plusieurs sources pour reconstruire une chronologie
- Prendre des mesures de remédiation appropriées et rédiger un rapport d'incident

## Durée Estimée

90 minutes

## Prérequis

- Tous les exercices précédents complétés
- Script `2_Generate-Events.ps1` exécuté pour peupler les journaux
- Bonne maîtrise des Event IDs (Exercice 02)

## Contexte / Scénario

!!! example "Scénario d'incident"
    **ALERTE SÉCURITÉ - Lundi matin, 08h47**

    Vous recevez un email du système de supervision automatique :

    > **ALERTE CRITIQUE** : Activité anormale détectée sur le compte `svc_monitoring`
    >
    > - Multiples connexions réussies entre 02h00 et 04h30 du matin
    > - Accès à des ressources du département Finance non habituels
    > - Tentative de modification des membres du groupe `GG-MONITORING-Finance-Admin`
    > - Origine de connexion inhabituelle : adresse IP `192.168.100.250` (non répertoriée)
    >
    > **Action requise** : Investigation immédiate

    Votre mission est d'investiguer cet incident, de déterminer ce qui s'est passé, de sécuriser l'environnement et de rédiger un rapport d'incident.

---

## Phase 1 : Confinement Immédiat

!!! danger "Priorité absolue"
    Avant toute investigation, sécurisez l'environnement pour arrêter l'attaque en cours.

### Tâche 1.1 : Désactiver le compte compromis

Sans instructions pas-à-pas, vous devez :

- Localiser le compte `svc_monitoring` dans AD
- Le désactiver immédiatement
- Documenter l'heure et la raison de la désactivation dans la description du compte

!!! tip "Rappel"
    ```powershell
    # Pour désactiver un compte
    Disable-ADAccount -Identity "svc_monitoring"
    # Pour ajouter une note dans la description
    Set-ADUser -Identity "svc_monitoring" -Description "COMPROMIS - Désactivé le $(Get-Date -Format 'dd/MM/yyyy HH:mm') par [votre nom] - Investigation en cours"
    ```

### Tâche 1.2 : Vérifier l'état du groupe Finance Admin

Vérifiez si des modifications non autorisées ont été apportées au groupe `GG-MONITORING-Finance-Admin` :

```powershell
# Lister les membres actuels du groupe
Get-ADGroupMember "GG-MONITORING-Finance-Admin" |
    Select-Object Name, SamAccountName, objectClass
```

!!! success "Résultat attendu"
    Vous pouvez voir si des membres inattendus (notamment `svc_monitoring`) ont été ajoutés au groupe. Si c'est le cas, retirez-les immédiatement.

### Tâche 1.3 : Réinitialiser le mot de passe du compte compromis

Même désactivé, réinitialisez le mot de passe pour empêcher toute réactivation non autorisée :

```powershell
$newPwd = ConvertTo-SecureString "M0nitor!ngT3ch@2026#NOUVEAU" -AsPlainText -Force
Set-ADAccountPassword -Identity "svc_monitoring" -NewPassword $newPwd -Reset
```

---

## Phase 2 : Investigation et Collecte de Preuves

!!! info "Méthodologie d'investigation"
    Une investigation forensique suit toujours cet ordre :

    1. Collecter les preuves sans les altérer
    2. Établir une chronologie des événements
    3. Identifier le vecteur d'attaque
    4. Évaluer l'étendue des dommages
    5. Identifier le responsable (si possible)

### Tâche 2.1 : Collecter les événements de connexion du compte suspect

Vous devez extraire TOUS les événements liés au compte `svc_monitoring` des dernières 48 heures.

**Objectif** : Identifier :

- Toutes les connexions réussies (4624) avec cet identifiant
- Tous les échecs de connexion (4625)
- Les connexions avec credentials explicites (4648)
- L'adresse IP source de chaque connexion

**Votre mission** : Écrire une commande PowerShell qui :

1. Récupère les événements des dernières 48 heures
2. Filtre sur les Event IDs 4624, 4625, 4648
3. Extrait le nom du compte, l'heure, l'IP source
4. Affiche les résultats triés par heure

!!! tip "Indice - Structure de base"
    ```powershell
    $debut = (Get-Date).AddHours(-48)
    $events = Get-WinEvent -LogName Security |
        Where-Object { $_.TimeCreated -gt $debut -and $_.Id -in @(4624, 4625, 4648) }

    foreach ($event in $events) {
        $xml = [xml]$event.ToXml()
        $data = $xml.Event.EventData.Data
        $compte = ($data | Where-Object { $_.Name -eq "TargetUserName" }).'#text'
        $ip = ($data | Where-Object { $_.Name -eq "IpAddress" }).'#text'

        if ($compte -like "*svc_monitoring*") {
            # Afficher les informations...
        }
    }
    ```

### Tâche 2.2 : Identifier les accès aux ressources Finance

Recherchez dans les journaux tous les accès au dossier `C:\FinanceData` (configuré dans l'exercice 05) effectués entre 02h00 et 05h00 :

```powershell
# Template de requête - à adapter
$debut = (Get-Date).Date.AddDays(-1).AddHours(2)  # Hier à 02h00
$fin = (Get-Date).Date.AddDays(-1).AddHours(5)    # Hier à 05h00

Get-WinEvent -LogName Security -MaxEvents 10000 |
    Where-Object { $_.Id -eq 4663 -and $_.TimeCreated -ge $debut -and $_.TimeCreated -le $fin } |
    ForEach-Object {
        $xml = [xml]$_.ToXml()
        $data = $xml.Event.EventData.Data
        $fichier = ($data | Where-Object { $_.Name -eq "ObjectName" }).'#text'
        $user = ($data | Where-Object { $_.Name -eq "SubjectUserName" }).'#text'
        if ($fichier -like "*Finance*") {
            Write-Host "$($_.TimeCreated) | $user | $fichier"
        }
    }
```

### Tâche 2.3 : Rechercher les modifications de groupes

Vérifiez si des modifications de groupes ont été effectuées par ou pour le compte `svc_monitoring` :

**Event IDs à chercher** :

- 4728 : Membre ajouté à un groupe de sécurité global
- 4729 : Membre retiré d'un groupe de sécurité global
- 4732 : Membre ajouté à un groupe de sécurité local

```powershell
$groupModifs = Get-WinEvent -LogName Security -MaxEvents 5000 |
    Where-Object { $_.Id -in @(4728, 4729, 4732) }

foreach ($event in $groupModifs) {
    $xml = [xml]$event.ToXml()
    $data = $xml.Event.EventData.Data
    $membre = ($data | Where-Object { $_.Name -eq "MemberName" }).'#text'
    $groupe = ($data | Where-Object { $_.Name -eq "TargetUserName" }).'#text'
    $parCompte = ($data | Where-Object { $_.Name -eq "SubjectUserName" }).'#text'

    Write-Host "[$($event.Id)] $($event.TimeCreated) | Groupe: $groupe | Membre: $membre | Par: $parCompte"
}
```

### Tâche 2.4 : Établir la chronologie de l'incident

À partir de vos recherches, construisez manuellement une chronologie en complétant ce tableau :

| Heure | Event ID | Description | Compte | IP Source |
|-------|----------|-------------|--------|-----------|
| ?     | ?        | ?           | svc_monitoring | 192.168.100.250 |
| ?     | ?        | ?           | ?      | ?         |

!!! tip "Astuce"
    Exportez vos résultats dans un fichier CSV pour faciliter l'analyse :
    ```powershell
    # Export en CSV
    $resultats | Export-Csv "C:\Temp\investigation_svc_monitoring.csv" -NoTypeInformation -Encoding UTF8
    ```

---

## Phase 3 : Évaluation de l'Impact

### Tâche 3.1 : Inventaire des ressources accessibles

Déterminez quelles ressources le compte `svc_monitoring` avait normalement accès et comparez avec les accès observés pendant l'incident :

```powershell
# Voir les groupes d'appartenance du compte (y compris les groupes ajoutés pendant l'attaque)
Write-Host "=== Groupes d'appartenance de svc_monitoring ===" -ForegroundColor Cyan
Get-ADPrincipalGroupMembership "svc_monitoring" |
    Select-Object Name, GroupScope, GroupCategory |
    Format-Table -AutoSize
```

### Tâche 3.2 : Vérifier les autres comptes de service

Vérifiez si les autres comptes de service présentent des anomalies similaires :

```powershell
$comptesService = @("svc_backup", "svc_audit", "svc_replication")
foreach ($cpt in $comptesService) {
    $info = Get-ADUser $cpt -Properties LastLogonDate, BadLogonCount, LockedOut, Enabled
    Write-Host "Compte: $($info.SamAccountName) | Actif: $($info.Enabled) | Dernière connexion: $($info.LastLogonDate) | Tentatives échouées: $($info.BadLogonCount)"
}
```

---

## Phase 4 : Remédiation

### Tâche 4.1 : Nettoyer les modifications non autorisées

Si `svc_monitoring` a été ajouté à des groupes auxquels il ne doit pas appartenir, retirez-le :

```powershell
# Template - adaptez selon vos découvertes
# Remove-ADGroupMember -Identity "GG-MONITORING-Finance-Admin" -Members "svc_monitoring" -Confirm:$false
```

### Tâche 4.2 : Renforcer la sécurité des comptes de service

Suite à cet incident, implémentez les mesures préventives suivantes :

1. Activez `svc_monitoring` uniquement après avoir changé son mot de passe par un mot de passe fort
2. Ajoutez une restriction horaire de connexion pour les comptes de service (uniquement pendant les heures de bureau)
3. Documentez les permissions légitimes de chaque compte de service

**Restriction horaire** (indice) :

```powershell
# Les comptes de service ne devraient se connecter qu'en heures de bureau
# Plage autorisée : Lundi-Vendredi, 07h00-20h00
$logonHours = New-Object byte[] 21
# Heures de connexion autorisées (tableau de 21 octets représentant 168 heures)
# 07h00-20h00, Lundi à Vendredi uniquement
# Note: La configuration précise des LogonHours nécessite une manipulation bit par bit
# Pour simplification, utilisez ADUC > Propriétés > Compte > Horaires de connexion
Set-ADUser -Identity "svc_monitoring" -LogonHours $logonHours
```

!!! warning "Attention"
    La configuration des horaires de connexion via PowerShell est complexe (manipulation de bits). Il est plus simple de le faire via ADUC : cliquez sur le compte > Propriétés > onglet Compte > bouton **Horaires de connexion**.

---

## Phase 5 : Rapport d'Incident

### Tâche 5.1 : Rédiger le rapport d'incident

Rédigez un rapport d'incident structuré contenant les sections suivantes (dans un fichier texte ou PowerShell) :

```
RAPPORT D'INCIDENT DE SÉCURITÉ
===============================
Date de l'incident : [date]
Détecté par : [vous]
Heure de détection : [heure]
Heure de confinement : [heure]

1. RÉSUMÉ EXÉCUTIF
   [2-3 phrases décrivant l'incident en termes simples]

2. CHRONOLOGIE
   [Tableau avec heure, événement, source]

3. ÉTENDUE DE L'IMPACT
   [Quels systèmes/données ont été affectés ?]

4. VECTEUR D'ATTAQUE
   [Comment l'attaquant a-t-il compromis le compte ?]

5. MESURES DE CONFINEMENT
   [Actions prises pour arrêter l'attaque]

6. REMÉDIATION
   [Actions correctives effectuées]

7. RECOMMANDATIONS
   [Mesures préventives pour éviter une récurrence]
```

---

## Vérification de la Réussite

### Commandes PowerShell de Vérification

```powershell
Import-Module ActiveDirectory
Write-Host "=== Vérification Exercice 06 ===" -ForegroundColor Cyan
$erreurs = 0

# Test 1: Compte svc_monitoring désactivé
$svc = Get-ADUser "svc_monitoring" -Properties Enabled, Description
if (-not $svc.Enabled) {
    Write-Host "svc_monitoring désactivé : OK" -ForegroundColor Green
} else {
    Write-Host "svc_monitoring encore ACTIF - doit être désactivé !" -ForegroundColor Red
    $erreurs++
}

# Test 2: Description mise à jour (doit contenir "COMPROMIS" ou "Investigation")
if ($svc.Description -like "*COMPROMIS*" -or $svc.Description -like "*investigation*") {
    Write-Host "Description documentée : OK" -ForegroundColor Green
} else {
    Write-Host "Description non documentée - ajoutez une note d'investigation" -ForegroundColor Yellow
}

# Test 3: svc_monitoring retiré de Finance Admin (si applicable)
try {
    $financeAdminMembers = Get-ADGroupMember "GG-MONITORING-Finance-Admin" |
        Select-Object -ExpandProperty SamAccountName
    if ($financeAdminMembers -notcontains "svc_monitoring") {
        Write-Host "svc_monitoring absent de GG-MONITORING-Finance-Admin : OK" -ForegroundColor Green
    } else {
        Write-Host "svc_monitoring toujours dans GG-MONITORING-Finance-Admin !" -ForegroundColor Red
        $erreurs++
    }
} catch {
    Write-Host "Groupe GG-MONITORING-Finance-Admin introuvable (normal si jamais modifié)" -ForegroundColor Yellow
}

# Test 4: Vérifier que les autres comptes de service sont toujours actifs
$autresComptes = @("svc_backup", "svc_audit", "svc_replication")
foreach ($cpt in $autresComptes) {
    $u = Get-ADUser $cpt -Properties Enabled
    if ($u.Enabled) {
        Write-Host "$cpt actif : OK" -ForegroundColor Green
    } else {
        Write-Host "$cpt est DÉSACTIVÉ - vérifier si intentionnel" -ForegroundColor Yellow
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
if ($erreurs -eq 0) {
    Write-Host "PHASE DE CONFINEMENT RÉUSSIE!" -ForegroundColor Green
    Write-Host "Poursuivez avec la remédiation et le rapport d'incident." -ForegroundColor Yellow
} else {
    Write-Host "CONFINEMENT INCOMPLET : $erreurs point(s) à corriger" -ForegroundColor Red
}
```

### Critères de Réussite

- [ ] Le compte `svc_monitoring` est désactivé
- [ ] La description du compte documente la raison et la date de désactivation
- [ ] Vous avez collecté et analysé les événements des Event IDs 4624, 4625, 4648
- [ ] Vous avez vérifié les modifications de groupes (4728, 4729)
- [ ] Vous avez établi une chronologie de l'incident
- [ ] Les membres non autorisés ont été retirés des groupes Finance
- [ ] Un rapport d'incident a été rédigé avec les 7 sections demandées

---

## Solution Complète (Pour Instructeur)

### Script d'investigation complet

```powershell
# Solution complète - Investigation Incident Exercice 06

# === PHASE 1 : CONFINEMENT ===
Write-Host "`n=== PHASE 1 : CONFINEMENT ===" -ForegroundColor Red

# Désactiver le compte compromis
Disable-ADAccount -Identity "svc_monitoring"
Set-ADUser -Identity "svc_monitoring" `
    -Description "COMPROMIS - Désactivé le $(Get-Date -Format 'dd/MM/yyyy HH:mm') - Investigation Exercice 06"

# Réinitialiser le mot de passe
$newPwd = ConvertTo-SecureString "M0nitor!ngT3ch@2026#SecuredNew" -AsPlainText -Force
Set-ADAccountPassword -Identity "svc_monitoring" -NewPassword $newPwd -Reset

Write-Host "Compte svc_monitoring désactivé et mot de passe réinitialisé." -ForegroundColor Green

# Vérifier et nettoyer les groupes
try {
    $financeAdminMembers = Get-ADGroupMember "GG-MONITORING-Finance-Admin" |
        Select-Object -ExpandProperty SamAccountName
    if ($financeAdminMembers -contains "svc_monitoring") {
        Remove-ADGroupMember -Identity "GG-MONITORING-Finance-Admin" `
            -Members "svc_monitoring" -Confirm:$false
        Write-Host "svc_monitoring retiré de GG-MONITORING-Finance-Admin." -ForegroundColor Green
    }
} catch {
    Write-Host "Groupe Finance-Admin non modifié (normal)." -ForegroundColor Gray
}

# === PHASE 2 : INVESTIGATION ===
Write-Host "`n=== PHASE 2 : INVESTIGATION ===" -ForegroundColor Yellow

$debut48h = (Get-Date).AddHours(-48)
$eventIds = @(4624, 4625, 4648, 4728, 4729, 4663)

$tousEvenements = Get-WinEvent -LogName Security -MaxEvents 50000 -ErrorAction SilentlyContinue |
    Where-Object { $_.TimeCreated -gt $debut48h -and $_.Id -in $eventIds }

Write-Host "Total événements récupérés : $($tousEvenements.Count)" -ForegroundColor Cyan

$chronologie = foreach ($event in $tousEvenements) {
    $xml = [xml]$event.ToXml()
    $data = $xml.Event.EventData.Data

    $compte = ($data | Where-Object { $_.Name -eq "TargetUserName" }).'#text'
    if (-not $compte) { $compte = ($data | Where-Object { $_.Name -eq "SubjectUserName" }).'#text' }
    $ip = ($data | Where-Object { $_.Name -eq "IpAddress" }).'#text'
    $objet = ($data | Where-Object { $_.Name -eq "ObjectName" }).'#text'

    if ($compte -like "*svc_monitoring*" -or $objet -like "*Finance*") {
        [PSCustomObject]@{
            Heure    = $event.TimeCreated.ToString("dd/MM/yyyy HH:mm:ss")
            EventID  = $event.Id
            Compte   = $compte
            IP       = $ip
            Objet    = $objet
            Message  = $event.Message.Substring(0, [Math]::Min(100, $event.Message.Length))
        }
    }
}

Write-Host "`n=== CHRONOLOGIE DE L'INCIDENT ===" -ForegroundColor Cyan
$chronologie | Sort-Object Heure | Format-Table -AutoSize

# Exporter en CSV
$chronologie | Sort-Object Heure |
    Export-Csv "C:\Temp\rapport_incident_svc_monitoring.csv" -NoTypeInformation -Encoding UTF8
Write-Host "Rapport exporté dans C:\Temp\rapport_incident_svc_monitoring.csv" -ForegroundColor Green

# === PHASE 3 : RÉACTIVATION SÉCURISÉE ===
Write-Host "`n=== PHASE 3 : RÉACTIVATION (après validation) ===" -ForegroundColor Green
Write-Host "Pour réactiver le compte après investigation :" -ForegroundColor Yellow
Write-Host "  Enable-ADAccount -Identity 'svc_monitoring'" -ForegroundColor Gray
Write-Host "  Set-ADUser -Identity 'svc_monitoring' -Description 'Compte réactivé le $(Get-Date -Format dd/MM/yyyy) après investigation'" -ForegroundColor Gray
```

---

## Points Clés à Retenir

- Le confinement doit toujours précéder l'investigation : on arrête la menace avant de chercher à comprendre ce qui s'est passé
- Une bonne chronologie est la base de tout rapport d'incident : elle permet de comprendre la séquence des événements et de démontrer l'étendue de la compromission
- Les comptes de service sont des cibles privilégiées car ils ont souvent des droits étendus et des mots de passe qui n'expirent pas
- Un rapport d'incident bien rédigé est essentiel pour la conformité légale, l'assurance cyber, et la prévention de récurrence

## Dépannage (Erreurs Courantes)

| Erreur Possible | Cause | Solution |
|-----------------|-------|----------|
| Peu d'événements dans les journaux | Journal trop petit ou effacé | Exécuter `2_Generate-Events.ps1` pour peupler les journaux |
| `Disable-ADAccount` échoue | Droits insuffisants | Utiliser un compte Domain Admin |
| Chronologie incomplète | Audit non activé avant l'incident | Normal en lab : l'audit doit être préconfiguré pour tracer l'historique |
| Rapport CSV vide | Aucun événement lié à svc_monitoring | Générer des événements de test avec le script dédié du lab |

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
