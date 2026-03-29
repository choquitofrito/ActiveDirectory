# Exercice 01 : Exploration de la Structure Active Directory

## Niveau de Difficulté

Débutant (Guidé)

## Objectifs Pédagogiques

- Naviguer dans la console Active Directory Users and Computers (ADUC) pour explorer une arborescence d'OUs
- Identifier et distinguer les différents types d'objets AD : utilisateurs, groupes, comptes de service, unités d'organisation
- Exécuter des commandes PowerShell de base pour interroger l'annuaire AD

## Durée Estimée

45 minutes

## Prérequis

- Script `MonitoringLab_Setup.ps1` exécuté avec succès sur le contrôleur de domaine
- Accès à la console du contrôleur de domaine avec un compte Administrateur
- Module ActiveDirectory disponible dans PowerShell

## Contexte / Scénario

!!! example "Scénario réel"
    Vous venez d'être recruté comme administrateur junior chez MonitoringTech SPRL. Votre responsable vous demande de vous familiariser avec la structure Active Directory existante avant de commencer à effectuer des modifications. Votre première mission est de réaliser un inventaire complet de ce qui a été mis en place.

---

## Tâches à Réaliser

### Partie 1 : Exploration via l'interface graphique (ADUC)

#### Étape 1 : Ouvrir la console ADUC

1. Cliquez sur **Démarrer**
2. Tapez `dsa.msc` dans la barre de recherche et appuyez sur **Entrée**

!!! success "Résultat attendu"
    La console "Utilisateurs et ordinateurs Active Directory" s'ouvre. Vous voyez le domaine `maxtec.be` dans le volet gauche.

#### Étape 2 : Localiser l'OU racine MonitoringTech

1. Dans le volet gauche, développez le noeud `maxtec.be`
2. Repérez et cliquez sur l'OU **MONITORING**

!!! success "Résultat attendu"
    Vous voyez l'OU MONITORING avec plusieurs sous-OUs correspondant aux départements.

#### Étape 3 : Explorer les départements

1. Développez l'OU **MONITORING** pour voir ses sous-OUs
2. Notez les 4 départements présents :
    - ITOperations
    - Security
    - RH
    - Finance
3. Cliquez sur le département **ITOperations** pour le développer
4. Explorez ses 3 sous-OUs : **Users**, **Computers**, **Groups**

!!! success "Résultat attendu"
    Chaque département contient exactement 3 sous-OUs : Users, Computers et Groups.

#### Étape 4 : Consulter les utilisateurs du département ITOperations

1. Cliquez sur `OU=Users` sous `ITOperations`
2. Observez le contenu dans le volet droit

!!! success "Résultat attendu"
    Le volet droit affiche les 5 utilisateurs du département ITOperations.

!!! tip "Astuce"
    Pour afficher plus de colonnes (Description, Email, etc.), cliquez sur **Affichage > Ajouter/Supprimer des colonnes**.

#### Étape 5 : Consulter les propriétés d'un utilisateur

1. Double-cliquez sur le premier utilisateur de la liste
2. Parcourez les onglets : **Général**, **Adresse**, **Compte**, **Membre de**
3. Notez à quel(s) groupe(s) cet utilisateur appartient (onglet **Membre de**)
4. Fermez la fenêtre de propriétés

!!! success "Résultat attendu"
    L'utilisateur est membre d'au moins un groupe dont le nom commence par `GG-MONITORING-ITOperations`.

#### Étape 6 : Explorer les groupes

1. Cliquez sur `OU=Groups` sous `ITOperations`
2. Double-cliquez sur le groupe **GG-MONITORING-ITOperations-Users** pour voir ses propriétés
3. Allez dans l'onglet **Membres** pour voir la liste des membres
4. Notez la portée du groupe (onglet **Général** : Portée du groupe)

!!! success "Résultat attendu"
    Le groupe est de portée **Globale** et contient les 5 utilisateurs du département.

#### Étape 7 : Explorer les comptes de service

1. Dans le volet gauche, développez `OU=ServiceAccounts` sous `OU=MONITORING`
2. Cliquez sur `OU=ServiceAccounts`
3. Observez les 4 comptes de service présents

!!! success "Résultat attendu"
    Vous voyez 4 comptes de service : `svc_monitoring`, `svc_backup`, `svc_audit`, `svc_replication`.

!!! info "Information"
    Les comptes de service sont des comptes AD spéciaux utilisés par des applications ou services Windows. Ils ne correspondent pas à des personnes physiques.

#### Étape 8 : Vérifier les propriétés d'un compte de service

1. Double-cliquez sur `svc_monitoring`
2. Observez l'onglet **Général** : notez la description
3. Allez dans l'onglet **Compte** : notez les options cochées
4. Fermez la fenêtre

!!! success "Résultat attendu"
    Le compte `svc_monitoring` a une description indiquant son rôle et les options du compte sont configurées pour un compte de service (ex. : le mot de passe n'expire pas).

---

### Partie 2 : Exploration via PowerShell

#### Étape 9 : Ouvrir PowerShell en tant qu'administrateur

1. Cliquez avec le bouton droit sur **Windows PowerShell** dans le menu Démarrer
2. Choisissez **Exécuter en tant qu'administrateur**

!!! success "Résultat attendu"
    Une fenêtre PowerShell s'ouvre avec le titre "Administrateur".

#### Étape 10 : Afficher l'arborescence des OUs

Copiez et exécutez la commande suivante :

```powershell
Get-ADOrganizationalUnit -Filter * -SearchBase "OU=MONITORING,DC=maxtec,DC=be" |
    Select-Object Name, DistinguishedName |
    Sort-Object DistinguishedName
```

!!! success "Résultat attendu"
    Une liste de toutes les OUs sous MONITORING s'affiche, avec leur nom et leur chemin complet (Distinguished Name).

#### Étape 11 : Compter les utilisateurs par département

Exécutez cette commande pour obtenir un résumé :

```powershell
$departements = @("ITOperations", "Security", "RH", "Finance")
foreach ($dept in $departements) {
    $count = (Get-ADUser -Filter * -SearchBase "OU=Users,OU=$dept,OU=MONITORING,DC=maxtec,DC=be").Count
    Write-Host "Département $dept : $count utilisateur(s)" -ForegroundColor Cyan
}
```

!!! success "Résultat attendu"
    Chaque département affiche exactement **5 utilisateurs**.

#### Étape 12 : Lister les comptes de service

```powershell
Get-ADUser -Filter * -SearchBase "OU=ServiceAccounts,OU=MONITORING,DC=maxtec,DC=be" |
    Select-Object Name, SamAccountName, Enabled, Description
```

!!! success "Résultat attendu"
    Les 4 comptes de service s'affichent avec leur nom, leur identifiant de connexion et leur statut.

#### Étape 13 : Afficher les groupes et leurs membres

```powershell
Get-ADGroup -Filter * -SearchBase "OU=MONITORING,DC=maxtec,DC=be" |
    Where-Object { $_.Name -like "GG-*" } |
    Select-Object Name, GroupScope |
    Sort-Object Name
```

!!! success "Résultat attendu"
    Une liste de tous les groupes dont le nom commence par `GG-` s'affiche. Tous sont de portée **Global**.

---

## Vérification de la Réussite

### Commandes PowerShell de Vérification

```powershell
# Vérification complète de la structure
Write-Host "=== Vérification Structure MonitoringLab ===" -ForegroundColor Cyan

# Nombre d'OUs
$ous = Get-ADOrganizationalUnit -Filter * -SearchBase "OU=MONITORING,DC=maxtec,DC=be"
Write-Host "Nombre d'OUs sous MONITORING : $($ous.Count)" -ForegroundColor Yellow

# Nombre total d'utilisateurs
$users = Get-ADUser -Filter * -SearchBase "OU=MONITORING,DC=maxtec,DC=be"
Write-Host "Nombre total d'utilisateurs : $($users.Count)" -ForegroundColor Yellow

# Nombre de groupes GG-
$groups = Get-ADGroup -Filter { Name -like "GG-*" } -SearchBase "OU=MONITORING,DC=maxtec,DC=be"
Write-Host "Nombre de groupes GG- : $($groups.Count)" -ForegroundColor Yellow

# Comptes de service
$svc = Get-ADUser -Filter * -SearchBase "OU=ServiceAccounts,OU=MONITORING,DC=maxtec,DC=be"
Write-Host "Comptes de service : $($svc.Count)" -ForegroundColor Yellow
```

### Critères de Réussite

- [ ] Vous avez localisé l'OU racine `MONITORING` dans la console ADUC
- [ ] Vous avez identifié les 4 départements (ITOperations, Security, RH, Finance)
- [ ] Vous avez vérifié que chaque département contient 5 utilisateurs
- [ ] Vous avez examiné les propriétés d'un utilisateur et de son groupe
- [ ] Vous avez localisé et examiné les 4 comptes de service
- [ ] Vous avez exécuté avec succès les commandes PowerShell de l'exploration

---

## Solution Complète (Pour Instructeur)

### Méthode GUI

L'exercice est entièrement guidé via l'interface graphique. Les étapes détaillées dans la section "Tâches à Réaliser" constituent la solution complète.

Points d'attention pour l'instructeur :
- Vérifier que les étudiants distinguent bien les OUs des conteneurs par défaut (CN=Users, CN=Computers)
- S'assurer que les étudiants repèrent la convention de nommage `GG-` des groupes
- Faire remarquer la différence entre comptes utilisateurs standards et comptes de service

### Méthode PowerShell

```powershell
# Inventaire complet de la structure MonitoringLab
Import-Module ActiveDirectory

# 1. Arborescence complète
Write-Host "`n--- OUs de MonitoringLab ---" -ForegroundColor Cyan
Get-ADOrganizationalUnit -Filter * -SearchBase "OU=MONITORING,DC=maxtec,DC=be" |
    Select-Object Name, DistinguishedName |
    Sort-Object DistinguishedName |
    Format-Table -AutoSize

# 2. Utilisateurs par département
Write-Host "`n--- Utilisateurs par Département ---" -ForegroundColor Cyan
$departements = @("ITOperations", "Security", "RH", "Finance")
foreach ($dept in $departements) {
    $users = Get-ADUser -Filter * -SearchBase "OU=Users,OU=$dept,OU=MONITORING,DC=maxtec,DC=be" `
        -Properties Description, EmailAddress
    Write-Host "`nDépartement : $dept ($($users.Count) utilisateurs)" -ForegroundColor Yellow
    $users | Select-Object Name, SamAccountName, Enabled | Format-Table -AutoSize
}

# 3. Groupes de sécurité
Write-Host "`n--- Groupes de Sécurité (GG-) ---" -ForegroundColor Cyan
Get-ADGroup -Filter * -SearchBase "OU=MONITORING,DC=maxtec,DC=be" |
    Where-Object { $_.Name -like "GG-*" } |
    ForEach-Object {
        $members = (Get-ADGroupMember $_.Name).Count
        [PSCustomObject]@{
            Nom = $_.Name
            Portée = $_.GroupScope
            Membres = $members
        }
    } | Format-Table -AutoSize

# 4. Comptes de service
Write-Host "`n--- Comptes de Service ---" -ForegroundColor Cyan
Get-ADUser -Filter * -SearchBase "OU=ServiceAccounts,OU=MONITORING,DC=maxtec,DC=be" `
    -Properties Description, PasswordNeverExpires, PasswordLastSet |
    Select-Object Name, SamAccountName, Enabled, Description, PasswordNeverExpires |
    Format-Table -AutoSize
```

---

## Points Clés à Retenir

- L'arborescence AD de MonitoringTech SPRL suit une hiérarchie logique : domaine > OU racine > départements > types d'objets
- La convention de nommage `GG-` pour les groupes globaux est obligatoire et permet de les identifier instantanément
- Les comptes de service (`svc_`) sont séparés des comptes utilisateurs normaux dans leur propre OU pour faciliter la gestion et l'audit
- PowerShell permet d'interroger l'AD de façon rapide et exhaustive, ce qui est essentiel pour l'administration quotidienne

## Dépannage (Erreurs Courantes)

| Erreur Possible | Cause | Solution |
|-----------------|-------|----------|
| "Le module ActiveDirectory n'est pas reconnu" | Le module RSAT AD n'est pas importé | Exécuter `Import-Module ActiveDirectory` en premier |
| L'OU MONITORING n'apparaît pas dans ADUC | Vue non actualisée | Appuyer sur F5 pour actualiser la console |
| La commande PowerShell retourne 0 résultats | Chemin (SearchBase) incorrect | Vérifier l'orthographe exacte du DistinguishedName |
| "Accès refusé" lors de la consultation | Compte utilisé sans droits suffisants | Se connecter avec un compte Administrateur du domaine |

## Exercice Suivant Suggéré

**Exercice 02 - Analyse des Événements de Sécurité** : Maintenant que vous connaissez la structure AD, vous allez apprendre à consulter les journaux d'événements Windows pour surveiller l'activité des utilisateurs et détecter des comportements suspects.
