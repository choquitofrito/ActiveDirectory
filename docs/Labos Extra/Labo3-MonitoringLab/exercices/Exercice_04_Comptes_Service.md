# Exercice 04 : Gestion et Sécurisation des Comptes de Service

## Niveau de Difficulté

Intermédiaire

## Objectifs Pédagogiques

- Modifier les attributs des comptes de service pour renforcer leur sécurité
- Créer et gérer des groupes de sécurité pour les comptes de service
- Déléguer des permissions AD appropriées à des comptes de service sans leur donner des droits excessifs

## Durée Estimée

60 minutes

## Prérequis

- Exercices 01 à 03 complétés
- Connaissance des droits AD et des bonnes pratiques pour les comptes de service

## Contexte / Scénario

!!! example "Scénario réel"
    Lors d'un audit de sécurité, le consultant externe a identifié plusieurs problèmes avec les comptes de service de MonitoringTech SPRL :
    
    1. Les comptes de service n'ont pas de description suffisamment détaillée
    2. Le compte `svc_monitoring` a besoin du droit de lire les journaux d'événements à distance
    3. Le compte `svc_audit` doit être membre du groupe "Lecteurs du journal des événements" pour fonctionner
    4. Aucun groupe de sécurité ne regroupe les comptes de service pour faciliter leur gestion
    
    Votre mission est de corriger ces problèmes selon le principe du moindre privilège.

---

## Tâches à Réaliser

### Tâche 1 : Inventaire et mise à jour des descriptions

**Objectif** : Ajouter une description détaillée et une adresse email fonctionnelle à chaque compte de service.

**Contraintes** :

- `svc_monitoring` : "Compte de service - Application de monitoring réseau - Contact: monitoring@monitoringtech.be"
- `svc_backup` : "Compte de service - Solution de sauvegarde Veeam - Contact: backup@monitoringtech.be"
- `svc_audit` : "Compte de service - Agent d'audit de sécurité - Contact: audit@monitoringtech.be"
- `svc_replication` : "Compte de service - Réplication AD et bases de données - Contact: replication@monitoringtech.be"

**Indices** :

- Utilisez `Set-ADUser -Identity "svc_monitoring" -Description "..." -EmailAddress "..."`
- Ou via ADUC : clic droit > Propriétés > onglet Général

Vérification :

```powershell
Get-ADUser -Filter { SamAccountName -like "svc_*" } `
    -SearchBase "OU=ServiceAccounts,OU=MONITORING,DC=maxtec,DC=be" `
    -Properties Description, EmailAddress |
    Select-Object Name, SamAccountName, Description, EmailAddress |
    Format-Table -AutoSize -Wrap
```

!!! success "Résultat attendu"
    Les 4 comptes de service affichent une description et une adresse email.

---

### Tâche 2 : Vérifier le groupe de sécurité des comptes de service et ajuster sa description

**Contexte** : Le script de setup a déjà créé le groupe `GG-MONITORING-ServiceAccounts` dans l'OU `OU=ServiceAccounts,OU=MONITORING,DC=maxtec,DC=be` et y a ajouté les 4 comptes de service. Votre rôle ici est d'**auditer** ce groupe et de mettre sa description à jour.

**Objectif** :

1. Vérifier que le groupe `GG-MONITORING-ServiceAccounts` existe bien, est de portée Globale et de type Sécurité
2. Vérifier que les 4 comptes de service en sont membres
3. Ajuster sa description pour inclure le nom de l'entreprise et la date du dernier audit

**Contraintes** :

- Nom (à vérifier, pas à créer) : `GG-MONITORING-ServiceAccounts`
- Portée attendue : Global
- Type attendu : Security
- Description à appliquer : `"Groupe de sécurité - Tous les comptes de service MonitoringTech - Dernier audit : $(Get-Date -Format 'dd/MM/yyyy')"`
- Membres attendus : `svc_monitoring`, `svc_backup`, `svc_audit`, `svc_replication`

**Indices** :

- `Get-ADGroup` pour récupérer les propriétés du groupe existant
- `Get-ADGroupMember` pour lister les membres
- `Set-ADGroup -Description` pour mettre à jour la description
- Si un membre manque, utilisez `Add-ADGroupMember` pour l'ajouter
- Si le groupe n'existe pas (anomalie), c'est que le setup a échoué — relancez `MonitoringLab_Setup.ps1`

Vérification :

```powershell
# Vérifier l'existence et les propriétés
$group = Get-ADGroup "GG-MONITORING-ServiceAccounts" -Properties Description, Members
Write-Host "Groupe : $($group.Name)"
Write-Host "Portée : $($group.GroupScope) (attendu : Global)"
Write-Host "Type   : $($group.GroupCategory) (attendu : Security)"
Write-Host "Description : $($group.Description)"

# Vérifier les membres
$attendus = @("svc_monitoring", "svc_backup", "svc_audit", "svc_replication")
$presents = Get-ADGroupMember "GG-MONITORING-ServiceAccounts" |
    Select-Object -ExpandProperty SamAccountName
$manquants = $attendus | Where-Object { $_ -notin $presents }

if ($manquants) {
    Write-Host "Membres manquants : $($manquants -join ', ')" -ForegroundColor Red
} else {
    Write-Host "Tous les comptes de service sont bien membres." -ForegroundColor Green
}
```

!!! success "Résultat attendu"
    Le groupe existe avec portée Global, type Security, contient les 4 comptes de service, et sa description a été mise à jour avec la date du dernier audit.

---

### Tâche 3 : Ajouter svc_audit au groupe "Lecteurs du journal des événements"

**Objectif** : Le compte `svc_audit` doit pouvoir lire les journaux d'événements à distance. Ajoutez-le au groupe intégré **Lecteurs du journal des événements** (Event Log Readers).

**Contraintes** :

- N'accordez que ce droit minimal, pas les droits Administrateur
- Ce groupe se trouve dans `CN=Builtin,DC=maxtec,DC=be`

**Indices** :

- Nom du groupe en anglais : "Event Log Readers"
- Nom du groupe en français : "Lecteurs du journal des événements"
- Utilisez `Add-ADGroupMember -Identity "Event Log Readers" -Members "svc_audit"`

Vérification :

```powershell
$membres = Get-ADGroupMember "Event Log Readers" | Select-Object -ExpandProperty SamAccountName
if ($membres -contains "svc_audit") {
    Write-Host "svc_audit est bien membre de Event Log Readers" -ForegroundColor Green
} else {
    Write-Host "svc_audit n'est PAS membre de Event Log Readers" -ForegroundColor Red
}
```

!!! success "Résultat attendu"
    `svc_audit` est membre du groupe "Event Log Readers".

---

### Tâche 4 : Configurer les options de sécurité des comptes de service

**Objectif** : Vérifier et configurer les options de sécurité appropriées pour chaque compte de service.

**Contraintes pour tous les comptes de service** :

- Le mot de passe ne doit pas expirer (`PasswordNeverExpires = $true`)
- L'utilisateur ne doit pas pouvoir changer son mot de passe (`CannotChangePassword = $true`)
- Kerberos pré-authentification activée (option par défaut, ne pas désactiver)

!!! warning "Attention"
    Dans un environnement réel, il est recommandé d'utiliser des **gMSA** (Group Managed Service Accounts) plutôt que de désactiver l'expiration du mot de passe. Pour ce lab, nous utilisons des comptes standard pour simplifier l'apprentissage.

**Indice** :

```powershell
# Syntaxe pour modifier les options d'un compte
Set-ADUser -Identity "svc_monitoring" `
    -PasswordNeverExpires $true `
    -CannotChangePassword $true
```

Vérification :

```powershell
Get-ADUser -Filter { SamAccountName -like "svc_*" } `
    -SearchBase "OU=ServiceAccounts,OU=MONITORING,DC=maxtec,DC=be" `
    -Properties PasswordNeverExpires, CannotChangePassword, Enabled |
    Select-Object SamAccountName, Enabled, PasswordNeverExpires, CannotChangePassword |
    Format-Table -AutoSize
```

!!! success "Résultat attendu"
    Les 4 comptes affichent `PasswordNeverExpires = True` et `CannotChangePassword = True`.

---

### Tâche 5 : Documenter les comptes de service (rapport PowerShell)

**Objectif** : Générer un rapport complet de tous les comptes de service avec leurs propriétés et appartenances aux groupes.

**Contrainte** : Le rapport doit afficher pour chaque compte : nom, description, statut, email, groupes d'appartenance, dernière connexion.

**Indice** :

```powershell
# Combiner Get-ADUser avec Get-ADPrincipalGroupMembership
$svcComptes = Get-ADUser -Filter * `
    -SearchBase "OU=ServiceAccounts,OU=MONITORING,DC=maxtec,DC=be" `
    -Properties Description, EmailAddress, PasswordNeverExpires, LastLogonDate

foreach ($compte in $svcComptes) {
    $groupes = Get-ADPrincipalGroupMembership $compte.SamAccountName |
        Select-Object -ExpandProperty Name
    # Afficher les informations...
}
```

!!! success "Résultat attendu"
    Un rapport lisible s'affiche dans la console PowerShell avec toutes les informations demandées pour chaque compte de service.

---

## Vérification de la Réussite

### Commandes PowerShell de Vérification

```powershell
Import-Module ActiveDirectory
Write-Host "=== Vérification Exercice 04 ===" -ForegroundColor Cyan

# Test 1: Descriptions mises à jour
$svcUsers = Get-ADUser -Filter * `
    -SearchBase "OU=ServiceAccounts,OU=MONITORING,DC=maxtec,DC=be" `
    -Properties Description
$avecDescription = ($svcUsers | Where-Object { $_.Description -ne $null -and $_.Description -ne "" }).Count
Write-Host "Comptes de service avec description : $avecDescription/4" -ForegroundColor $(if ($avecDescription -eq 4) { "Green" } else { "Red" })

# Test 2: Groupe GG-MONITORING-ServiceAccounts
try {
    $group = Get-ADGroup "GG-MONITORING-ServiceAccounts" -Properties Members
    $memberCount = (Get-ADGroupMember $group).Count
    Write-Host "Groupe GG-MONITORING-ServiceAccounts : OK ($memberCount membres)" -ForegroundColor Green
} catch {
    Write-Host "Groupe GG-MONITORING-ServiceAccounts : INTROUVABLE" -ForegroundColor Red
}

# Test 3: svc_audit dans Event Log Readers
$elrMembers = Get-ADGroupMember "Event Log Readers" | Select-Object -ExpandProperty SamAccountName
if ($elrMembers -contains "svc_audit") {
    Write-Host "svc_audit dans Event Log Readers : OK" -ForegroundColor Green
} else {
    Write-Host "svc_audit dans Event Log Readers : ABSENT" -ForegroundColor Red
}
```

### Critères de Réussite

- [ ] Les 4 comptes de service ont une description détaillée et une adresse email
- [ ] Le groupe `GG-MONITORING-ServiceAccounts` existe avec portée Global
- [ ] Les 4 comptes de service sont membres de `GG-MONITORING-ServiceAccounts`
- [ ] `svc_audit` est membre du groupe "Event Log Readers"
- [ ] Les 4 comptes ont `PasswordNeverExpires = True`
- [ ] Vous avez généré le rapport de documentation des comptes de service

---

## Solution Complète (Pour Instructeur)

### Méthode PowerShell

```powershell
Import-Module ActiveDirectory
$baseOU = "OU=ServiceAccounts,OU=MONITORING,DC=maxtec,DC=be"

# Tâche 1 : Mise à jour des descriptions
$descriptions = @{
    "svc_monitoring"   = @{ Desc = "Compte de service - Application de monitoring réseau - Contact: monitoring@monitoringtech.be"; Email = "monitoring@monitoringtech.be" }
    "svc_backup"       = @{ Desc = "Compte de service - Solution de sauvegarde Veeam - Contact: backup@monitoringtech.be"; Email = "backup@monitoringtech.be" }
    "svc_audit"        = @{ Desc = "Compte de service - Agent d'audit de sécurité - Contact: audit@monitoringtech.be"; Email = "audit@monitoringtech.be" }
    "svc_replication"  = @{ Desc = "Compte de service - Réplication AD et bases de données - Contact: replication@monitoringtech.be"; Email = "replication@monitoringtech.be" }
}

foreach ($sam in $descriptions.Keys) {
    Set-ADUser -Identity $sam `
        -Description $descriptions[$sam].Desc `
        -EmailAddress $descriptions[$sam].Email `
        -PasswordNeverExpires $true `
        -CannotChangePassword $true
    Write-Host "Compte $sam mis à jour." -ForegroundColor Green
}

# Tâche 2 : Vérifier le groupe GG-MONITORING-ServiceAccounts et mettre sa description à jour
$groupName = "GG-MONITORING-ServiceAccounts"
$group = Get-ADGroup -Filter { Name -eq $groupName } -ErrorAction SilentlyContinue

if (-not $group) {
    Write-Host "ANOMALIE : le groupe $groupName n'existe pas. Relancez MonitoringLab_Setup.ps1." -ForegroundColor Red
} else {
    # Mettre à jour la description
    $newDesc = "Groupe de sécurité - Tous les comptes de service MonitoringTech - Dernier audit : $(Get-Date -Format 'dd/MM/yyyy')"
    Set-ADGroup -Identity $groupName -Description $newDesc
    Write-Host "Description du groupe $groupName mise à jour." -ForegroundColor Green

    # Vérifier que les 4 comptes de service sont bien membres ; ajouter ceux qui manquent
    $svcAccounts = @("svc_monitoring", "svc_backup", "svc_audit", "svc_replication")
    $presents = Get-ADGroupMember $groupName | Select-Object -ExpandProperty SamAccountName
    $manquants = $svcAccounts | Where-Object { $_ -notin $presents }

    if ($manquants) {
        Add-ADGroupMember -Identity $groupName -Members $manquants
        Write-Host "Comptes manquants ajoutés : $($manquants -join ', ')" -ForegroundColor Yellow
    } else {
        Write-Host "Tous les comptes de service sont déjà membres." -ForegroundColor Green
    }
}

# Tâche 3 : Ajouter svc_audit à Event Log Readers
Add-ADGroupMember -Identity "Event Log Readers" -Members "svc_audit"
Write-Host "svc_audit ajouté à Event Log Readers." -ForegroundColor Green
```

### Méthode GUI (ADUC)

Pour chaque compte de service :

1. ADUC > OU=ServiceAccounts > OU=MONITORING
2. Clic droit sur le compte > Propriétés
3. Onglet Général : remplir Description et Adresse email
4. Onglet Compte : cocher "Le mot de passe n'expire jamais"

Pour le groupe (déjà créé par le setup, vous ne devez que vérifier et ajuster) :

1. ADUC > OU=ServiceAccounts > localisez `GG-MONITORING-ServiceAccounts` > Propriétés
2. Onglet Général : vérifiez Portée = Globale et Type = Sécurité ; mettez à jour la Description avec la date du jour
3. Onglet Membres : vérifiez que les 4 comptes svc_ sont bien listés (sinon ajoutez les manquants)

Pour Event Log Readers :

1. ADUC > Builtin > Event Log Readers > Propriétés > Membres > Ajouter
2. Chercher "svc_audit" et l'ajouter

---

## Points Clés à Retenir

- Les comptes de service doivent toujours être documentés avec une description claire indiquant leur rôle et le responsable technique
- Le principe du moindre privilège s'applique aussi aux comptes de service : n'accordez que les droits strictement nécessaires
- Regrouper les comptes de service dans un groupe `GG-` permet de gérer leurs permissions collectivement
- `PasswordNeverExpires = $true` est acceptable pour les comptes de service, mais doit être compensé par des mots de passe très forts (ou l'utilisation de gMSA en production)

## Dépannage (Erreurs Courantes)

| Erreur Possible | Cause | Solution |
|-----------------|-------|----------|
| "Le groupe n'existe pas" lors de Add-ADGroupMember | Groupe pas encore créé | Exécuter d'abord la commande New-ADGroup |
| "Accès refusé" sur Set-ADUser | Droits insuffisants | Utiliser un compte Domain Admin |
| "Event Log Readers" introuvable | Nom en français | Utiliser le SID ou chercher "S-1-5-32-573" |
| Propriétés non sauvegardées via GUI | Oublié de cliquer OK/Appliquer | Toujours cliquer Appliquer avant de fermer |

## Exercice Suivant Suggéré

**Exercice 05 - Politique d'Audit Personnalisée** : Vous allez concevoir et implémenter une politique d'audit sur mesure pour surveiller les accès aux dossiers financiers sensibles de MonitoringTech SPRL.
