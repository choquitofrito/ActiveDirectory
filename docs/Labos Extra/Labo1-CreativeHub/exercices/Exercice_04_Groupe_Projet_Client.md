# Exercice 4 : Créer un Groupe de Sécurité pour un Projet Client Confidentiel

## Niveau de Difficulté
🟡 **Intermédiaire** - Tâche orientée objectif

## Objectifs Pédagogiques
- Créer et configurer un groupe de sécurité sans instructions détaillées
- Sélectionner le bon type de groupe (Global, Domain Local, Universal)
- Gérer l'appartenance multi-départements
- Appliquer le principe du "besoin d'en connaître" (need-to-know)

## Durée Estimée
20-25 minutes

## Prérequis
- Lab CreativeHub déployé avec succès
- Compréhension des groupes de sécurité AD
- Capacité à utiliser "Utilisateurs et ordinateurs Active Directory"

## Contexte / Scénario
**Date**: Mercredi matin

Nicolas André, Directeur des Opérations, vous envoie un message prioritaire :

> *"Bonjour,*
>
> *Nous venons de signer un contrat avec un client très important et extrêmement confidentiel : la banque 'SecureBank'. Ce projet nécessite une sécurité renforcée.*
>
> *Seules certaines personnes de notre agence doivent avoir accès aux fichiers de ce projet :*
>
> **Département Client Services** :
> - Karine Garnier (Chef de Projet Senior)
> - Nicolas André (Directeur des Opérations - moi-même)
>
> **Département Creative** :
> - Gabrielle Simon (Directrice Artistique)
> - Fabien Moreau (Graphiste Senior)
>
> **Département Marketing** :
> - Camille Bernard (Responsable Marketing Digital)
>
> *Créez un groupe de sécurité appelé 'GG-Projet-SecureBank' qui contiendra uniquement ces 5 personnes. Plus tard, nous utiliserons ce groupe pour gérer les permissions d'accès au dossier du projet.*
>
> *Important : Ce groupe doit pouvoir être utilisé pour attribuer des permissions sur des ressources locales (partages de fichiers).*
>
> *Merci,*
> *Nicolas*"

## Tâche à Réaliser

Votre mission est de créer un groupe de sécurité conforme aux besoins exprimés.

### Objectif Principal

Créer un groupe de sécurité nommé **GG-Projet-SecureBank** contenant exactement les 5 utilisateurs spécifiés.

### Contraintes

1. **Nom du groupe** : Exactement `GG-Projet-SecureBank`
2. **Type de groupe** : Groupe de **sécurité** (pas de distribution)
3. **Étendue du groupe** : Choisir l'étendue appropriée (Global, Domain Local, ou Universal)
   - *Indice* : Le groupe sera utilisé pour gérer des permissions sur des ressources locales du domaine

4. **Emplacement** : Le groupe doit être créé dans une OU appropriée
   - *Réflexion* : Où placer un groupe qui concerne plusieurs départements ?

5. **Description** : Ajouter une description claire expliquant le but du groupe
6. **Membres** : Ajouter les 5 utilisateurs spécifiés (et uniquement ceux-là)

### Membres à Ajouter

| Utilisateur | SAM Account | Département |
|-------------|-------------|-------------|
| Karine Garnier | karine | ClientServices |
| Nicolas André | nicolas | ClientServices |
| Gabrielle Simon | gabrielle | Creative |
| Fabien Moreau | fabien | Creative |
| Camille Bernard | camille | Marketing |

### Questions à Vous Poser

1. **Étendue du groupe** :
   - Global (pour regrouper des utilisateurs du même domaine) ?
   - Domain Local (pour gérer des permissions sur des ressources locales) ?
   - Universal (pour les environnements multi-domaines) ?

2. **Emplacement** :
   - Créer une nouvelle OU "Projets" sous CreativeHub ?
   - Placer dans un département existant ?
   - Utiliser l'OU Groups d'un département ?

### Indices (Si Nécessaire)

??? info "💡 Indice 1 : Étendue du groupe"
    Dans un environnement à domaine unique, la meilleure pratique Microsoft est :
    - **Groupes Globaux** : Pour regrouper des utilisateurs (ex: tous les utilisateurs d'un département)
    - **Groupes Domain Local** : Pour attribuer des permissions sur des ressources
    - **Stratégie AGDLP** : Ajouter les utilisateurs à un groupe Global, puis ce groupe Global à un groupe Domain Local qui a les permissions
    
    Pour cet exercice, comme le groupe contient directement des utilisateurs et sera utilisé pour des permissions locales, **Domain Local** est le choix approprié.
    

??? info "💡 Indice 2 : Emplacement du groupe"
    Comme le groupe concerne plusieurs départements, créez une nouvelle OU "Projets" ou "Groupes_Projets" sous l'OU racine CreativeHub :
    - `OU=Groupes_Projets,OU=CreativeHub,DC=maxtec,DC=be`
    
    Ou utilisez l'OU Groups d'un département (par exemple ClientServices puisque c'est le département qui pilote le projet).
    

??? info "💡 Indice 3 : Vérification des membres"
    Après avoir ajouté les membres, double-cliquez sur le groupe, allez dans l'onglet "Membres" et comptez : vous devez voir exactement 5 noms.
    
    Utilisez aussi PowerShell pour vérifier :
    ```powershell
    Get-ADGroupMember -Identity "GG-Projet-SecureBank" | Select-Object Name, SamAccountName
    ```


## Vérification de la Réussite

### Commandes PowerShell de Vérification

```powershell
Import-Module ActiveDirectory

# Vérifier le groupe
Get-ADGroup -Identity "GG-Projet-SecureBank" -Properties Description, GroupScope, GroupCategory |
    Select-Object Name, Description, GroupScope, GroupCategory, DistinguishedName

# Vérifier les membres
Write-Host "`nMembres du groupe:" -ForegroundColor Cyan
Get-ADGroupMember -Identity "GG-Projet-SecureBank" |
    Select-Object Name, SamAccountName, DistinguishedName |
    Sort-Object Name
```

**OU** exécutez le script de vérification automatique :

```powershell
.\verif_exercice_04.ps1
```

### Critères de Réussite

- [ ] Le groupe "GG-Projet-SecureBank" existe
- [ ] Type : Groupe de **sécurité** (Security)
- [ ] Étendue : **DomainLocal** (recommandé) ou Global (acceptable)
- [ ] Le groupe contient exactement **5 membres**
- [ ] Les 5 membres corrects sont présents : karine, nicolas, gabrielle, fabien, camille
- [ ] Une description explicite a été ajoutée
- [ ] Le groupe est dans une OU appropriée (pas dans les conteneurs par défaut Users ou Computers)

## Solution Complète (Pour Instructeur)

### Méthode GUI

#### Étape 1 : Créer une OU pour les groupes de projets (optionnel mais recommandé)

1. Ouvrir `dsa.msc`
2. Clic droit sur `OU=CreativeHub` → **Nouveau** → **Unité d'organisation**
3. Nom : `Groupes_Projets`
4. Décocher la protection contre la suppression accidentelle (pour le lab)
5. Cliquer sur OK

#### Étape 2 : Créer le groupe de sécurité

1. Naviguer vers `OU=Groupes_Projets,OU=CreativeHub` (ou l'emplacement choisi)
2. Clic droit → **Nouveau** → **Groupe**
3. Remplir :
   - **Nom du groupe** : `GG-Projet-SecureBank`
   - **Nom du groupe (pré-Windows 2000)** : `GG-Projet-SecureBank`
   - **Étendue du groupe** : Sélectionner **Domaine local**
   - **Type de groupe** : Sélectionner **Sécurité**

4. Cliquer sur OK

#### Étape 3 : Ajouter une description

1. Double-clic sur le groupe **GG-Projet-SecureBank**
2. Onglet **Général**
3. **Description** : `Accès au projet confidentiel SecureBank - Membres multi-départements`
4. Cliquer sur **Appliquer**

#### Étape 4 : Ajouter les membres

1. Onglet **Membres**
2. Cliquer sur **Ajouter...**
3. Taper : `karine; nicolas; gabrielle; fabien; camille`
4. Cliquer sur **Vérifier les noms** (tous les noms doivent être soulignés)
5. Cliquer sur **OK**, puis à nouveau **OK**

### Méthode PowerShell

```powershell
Import-Module ActiveDirectory

# Variables
$groupName = "GG-Projet-SecureBank"
$groupDescription = "Accès au projet confidentiel SecureBank - Membres multi-départements"
$rootOU = "OU=CreativeHub,DC=maxtec,DC=be"
$projectGroupsOU = "OU=Groupes_Projets,$rootOU"

# 1. Créer l'OU Groupes_Projets si elle n'existe pas
try {
    Get-ADOrganizationalUnit -Identity $projectGroupsOU -ErrorAction Stop | Out-Null
    Write-Host "L'OU Groupes_Projets existe déjà." -ForegroundColor Yellow
} catch {
    New-ADOrganizationalUnit -Name "Groupes_Projets" -Path $rootOU -ProtectedFromAccidentalDeletion $false
    Write-Host "OU Groupes_Projets créée." -ForegroundColor Green
}

# 2. Créer le groupe de sécurité
try {
    Get-ADGroup -Identity $groupName -ErrorAction Stop | Out-Null
    Write-Host "Le groupe $groupName existe déjà." -ForegroundColor Yellow
} catch {
    New-ADGroup -Name $groupName `
        -GroupScope DomainLocal `
        -GroupCategory Security `
        -Path $projectGroupsOU `
        -Description $groupDescription
    Write-Host "Groupe $groupName créé avec succès." -ForegroundColor Green
}

# 3. Ajouter les membres
$members = @("karine", "nicolas", "gabrielle", "fabien", "camille")

foreach ($member in $members) {
    try {
        Add-ADGroupMember -Identity $groupName -Members $member -ErrorAction Stop
        Write-Host "  $member ajouté au groupe" -ForegroundColor Green
    } catch {
        if ($_.Exception.Message -like "*already a member*") {
            Write-Host "  $member est déjà membre du groupe" -ForegroundColor Yellow
        } else {
            Write-Host "  ERREUR lors de l'ajout de $member : $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host "`nGroupe de sécurité SecureBank créé avec succès !" -ForegroundColor Green

# Vérification
Write-Host "`nMembres du groupe:" -ForegroundColor Cyan
Get-ADGroupMember -Identity $groupName | Select-Object Name, SamAccountName | Format-Table
```


## Points Clés à Retenir

### Types d'Étendue de Groupe (Group Scope)

| Étendue | Usage Principal | Peut Contenir | Peut Recevoir Permissions |
|---------|----------------|---------------|---------------------------|
| **Global** | Regrouper des utilisateurs d'un même domaine | Utilisateurs et groupes globaux du même domaine | Partout dans la forêt |
| **Domain Local** | Gérer des permissions sur des ressources locales | N'importe quel utilisateur ou groupe de la forêt | Uniquement dans le domaine local |
| **Universal** | Environnements multi-domaines | Utilisateurs et groupes de n'importe quel domaine | Partout dans la forêt |

### Stratégie AGDLP (Bonnes Pratiques Microsoft)

**A**ccounts → **G**lobal Groups → **D**omain **L**ocal Groups → **P**ermissions

1. Ajouter les **comptes utilisateurs** (Accounts) à des **groupes globaux**
2. Ajouter les **groupes globaux** à des **groupes domain local**
3. Attribuer les **permissions** aux **groupes domain local**

Pour cet exercice simplifié, nous avons utilisé directement un groupe Domain Local avec des utilisateurs, ce qui est acceptable pour de petites structures.

### Convention de Nommage

- **GG-** : Groupe Global
- **DL-** : Domain Local
- **UG-** : Universal Group

Le nom "GG-Projet-SecureBank" suggère un groupe Global, mais techniquement un groupe Domain Local aurait dû être nommé "DL-Projet-SecureBank". En entreprise, respectez la convention de nommage !

## Dépannage (Erreurs Courantes)

| Erreur Possible | Cause | Solution |
|-----------------|-------|----------|
| "Le groupe existe déjà" | Nom de groupe déjà utilisé | Vérifiez l'existence avec `Get-ADGroup -Filter {Name -eq "GG-Projet-SecureBank"}` |
| "Impossible de trouver l'utilisateur" | SAM Account incorrect | Vérifiez le nom exact avec `Get-ADUser -Filter {Name -like "*Garnier*"}` |
| Le groupe apparaît vide | Les membres n'ont pas été ajoutés correctement | Utilisez l'onglet "Membres" pour ajouter à nouveau |
| "Impossible d'ajouter au groupe" | L'utilisateur est peut-être déjà membre | Vérifiez d'abord avec `Get-ADGroupMember` |

## Pour Aller Plus Loin

### Scénario Réaliste

En production, vous créeriez probablement :

1. **Groupe Global** : `GG-Projet-SecureBank-Equipe` contenant les 5 utilisateurs
2. **Groupe Domain Local** : `DL-SecureBank-Lecture` pour les permissions en lecture
3. **Groupe Domain Local** : `DL-SecureBank-Modification` pour les permissions en écriture
4. Ajouter le groupe Global aux groupes Domain Local selon les besoins
5. Attribuer les permissions NTFS aux groupes Domain Local

### Commande Utile : Trouver Tous les Groupes d'un Utilisateur

```powershell
Get-ADPrincipalGroupMembership -Identity karine | Select-Object Name, GroupScope
```

## Exercice Suivant Suggéré

**Exercice 5** : Réinitialiser le mot de passe d'un utilisateur et forcer le changement à la prochaine connexion
