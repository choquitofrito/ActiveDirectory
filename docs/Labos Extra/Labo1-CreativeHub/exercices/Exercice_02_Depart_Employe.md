# Exercice 2 : Gérer le Départ d'un Employé

## Niveau de Difficulté
🟢 **Débutant** - Guidé étape par étape

## Objectifs Pédagogiques
- Désactiver un compte utilisateur (plutôt que de le supprimer)
- Modifier l'appartenance aux groupes de sécurité
- Comprendre l'importance de la conservation des comptes pour l'audit et la traçabilité

## Durée Estimée
15 minutes

## Prérequis
- Lab CreativeHub déployé avec succès
- Accès à "Utilisateurs et ordinateurs Active Directory" (dsa.msc)
- Connexion en tant qu'administrateur du domaine

## Contexte / Scénario
**Date**: Vendredi après-midi, 16h00

Nicolas André, le Directeur des Opérations, vous contacte :

> *"Bonjour,*
>
> *Manon Girard, notre Chef de Projet Junior, nous quitte pour une opportunité à l'étranger. Son dernier jour est aujourd'hui. Pour des raisons de sécurité et de conformité, nous devons immédiatement désactiver son accès au système.*
>
> *IMPORTANT : Ne supprimez PAS son compte ! Nous devons conserver l'historique de ses activités pour les audits de projets clients. Désactivez simplement son accès.*
>
> *De plus, retirez-la de tous les groupes de sécurité pour éviter tout accès résiduel.*
>
> *Merci de traiter cela en priorité.*
> *Nicolas*"

Votre mission : désactiver le compte de Manon tout en préservant les données historiques.

## Tâche à Réaliser

### Étape 1 : Localiser le Compte Utilisateur

1. Ouvrez **Utilisateurs et ordinateurs Active Directory** (dsa.msc)
2. Naviguez vers :
   - **maxtec.be** → **CreativeHub** → **ClientServices** → **Users**

3. Localisez **Manon Girard** dans la liste


!!! success "Résultat attendu"
    Vous voyez le compte de Manon parmi les 4 utilisateurs du département Client Services

### Étape 2 : Désactiver le Compte

1. **Clic droit** sur **Manon Girard**
2. Sélectionnez **Désactiver le compte**
3. Une fenêtre de confirmation apparaît, cliquez sur **Oui**
4. Un message confirme : "L'objet Manon Girard a été désactivé"


!!! success "Résultat attendu"
    L'icône du compte de Manon affiche maintenant une flèche vers le bas (↓), indiquant que le compte est désactivé

### Étape 3 : Vérifier la Désactivation

1. **Double-clic** sur **Manon Girard**
2. Allez dans l'onglet **Compte**
3. Vérifiez que la case **"Le compte est désactivé"** est cochée


!!! success "Résultat attendu"
    La case "Le compte est désactivé" est bien cochée

### Étape 4 : Ajouter une Description pour Documentation

1. Toujours dans les propriétés de Manon, allez dans l'onglet **Général**
2. Dans le champ **Description**, ajoutez :
   ```
   COMPTE DÉSACTIVÉ - Départ le 04/10/2025 - Remplacée par [À définir]
   ```

3. Cliquez sur **Appliquer**


!!! success "Résultat attendu"
    La description est enregistrée et sera visible dans les rapports

### Étape 5 : Retirer Manon du Groupe Users

1. Naviguez vers **CreativeHub** → **ClientServices** → **Groups**
2. **Double-clic** sur **GG-CreativeHub-ClientServices-Users**
3. Allez dans l'onglet **Membres**
4. Sélectionnez **Manon Girard** dans la liste
5. Cliquez sur **Supprimer**, puis confirmez avec **Oui**
6. Cliquez sur **OK**


!!! success "Résultat attendu"
    Manon n'apparaît plus dans la liste des membres du groupe ClientServices-Users

### Étape 6 : Vérifier qu'il n'y a pas d'Autres Appartenances

1. **Double-clic** sur **Manon Girard** (dans l'OU Users)
2. Allez dans l'onglet **Membre de**
3. Vérifiez les groupes listés


!!! success "Résultat attendu"
    Manon devrait uniquement être membre de **Domain Users** (groupe par défaut impossible à retirer)

### Étape 7 : Déplacer le Compte vers une OU "Comptes Désactivés" (Optionnel mais Recommandé)

**Note** : Pour cet exercice, nous allons créer une OU temporaire pour organiser les comptes désactivés.

1. **Clic droit** sur **OU=ClientServices**
2. Sélectionnez **Nouveau** → **Unité d'organisation**
3. Nom : `Comptes_Desactives`
4. Décochez "Protéger le conteneur contre la suppression accidentelle"
5. Cliquez sur **OK**
6. **Glissez-déposez** le compte de **Manon Girard** de l'OU **Users** vers l'OU **Comptes_Desactives**
7. Confirmez le déplacement


!!! success "Résultat attendu"
    Le compte de Manon se trouve maintenant dans l'OU Comptes_Desactives, facilitant la gestion des comptes inactifs

## Vérification de la Réussite

### Commandes PowerShell de Vérification

```powershell
Import-Module ActiveDirectory

# Vérifier que le compte est désactivé
Get-ADUser -Identity manon -Properties Enabled, Description |
    Select-Object Name, SamAccountName, Enabled, Description

# Vérifier les appartenances aux groupes
Write-Host "`nGroupes dont Manon est membre:" -ForegroundColor Cyan
Get-ADPrincipalGroupMembership -Identity manon |
    Select-Object Name
```

**OU** exécutez le script de vérification automatique :

```powershell
.\verif_exercice_02.ps1
```

### Critères de Réussite

- [ ] Le compte "manon" est désactivé (Enabled = False)
- [ ] Une description documentant le départ a été ajoutée
- [ ] Manon a été retirée du groupe `GG-CreativeHub-ClientServices-Users`
- [ ] Manon n'est membre d'aucun groupe de sécurité (sauf Domain Users)
- [ ] Le compte existe toujours (non supprimé)
- [ ] *Bonus* : Le compte a été déplacé vers une OU "Comptes_Desactives"

## Solution Complète (Pour Instructeur)

### Méthode GUI

Étapes détaillées fournies dans la section "Tâche à Réaliser" ci-dessus.

### Méthode PowerShell

```powershell
Import-Module ActiveDirectory

# Variables
$userSAM = "manon"
$description = "COMPTE DÉSACTIVÉ - Départ le 04/10/2025 - Remplacée par [À définir]"
$groupToRemove = "GG-CreativeHub-ClientServices-Users"

# 1. Désactiver le compte
Disable-ADAccount -Identity $userSAM
Write-Host "Compte '$userSAM' désactivé." -ForegroundColor Green

# 2. Ajouter une description
Set-ADUser -Identity $userSAM -Description $description
Write-Host "Description ajoutée au compte." -ForegroundColor Green

# 3. Retirer du groupe ClientServices-Users
Remove-ADGroupMember -Identity $groupToRemove -Members $userSAM -Confirm:$false
Write-Host "Utilisateur retiré du groupe $groupToRemove." -ForegroundColor Green

# 4. Créer l'OU Comptes_Desactives si elle n'existe pas (optionnel)
$desactivesOU = "OU=Comptes_Desactives,OU=ClientServices,OU=CreativeHub,DC=maxtec,DC=be"
try {
    Get-ADOrganizationalUnit -Identity $desactivesOU -ErrorAction Stop
    Write-Host "L'OU Comptes_Desactives existe déjà." -ForegroundColor Yellow
} catch {
    New-ADOrganizationalUnit -Name "Comptes_Desactives" `
        -Path "OU=ClientServices,OU=CreativeHub,DC=maxtec,DC=be" `
        -ProtectedFromAccidentalDeletion $false
    Write-Host "OU Comptes_Desactives créée." -ForegroundColor Green
}

# 5. Déplacer le compte vers l'OU Comptes_Desactives
$user = Get-ADUser -Identity $userSAM
Move-ADObject -Identity $user.DistinguishedName -TargetPath $desactivesOU
Write-Host "Compte déplacé vers l'OU Comptes_Desactives." -ForegroundColor Green

Write-Host "`nGestion du départ de Manon Girard terminée avec succès !" -ForegroundColor Green
```


## Points Clés à Retenir

- **Ne jamais supprimer un compte utilisateur immédiatement** : La désactivation préserve l'historique et permet une réactivation si nécessaire
- **Traçabilité** : Ajouter une description avec la date et la raison de la désactivation
- **Sécurité** : Retirer toutes les appartenances aux groupes pour éviter des accès résiduels
- **Organisation** : Déplacer les comptes désactivés vers une OU dédiée facilite la gestion
- **Politique de rétention** : En entreprise, définir une durée avant suppression définitive (ex: 90 jours, 6 mois, 1 an)
- **Domain Users** : Tous les utilisateurs AD sont membres de ce groupe par défaut, impossible de le retirer

## Dépannage (Erreurs Courantes)

| Erreur Possible | Cause | Solution |
|-----------------|-------|----------|
| "Impossible de désactiver le compte" | Compte déjà désactivé ou droits insuffisants | Vérifiez l'état actuel et vos permissions |
| "Impossible de retirer du groupe" | L'utilisateur n'est pas membre du groupe | Vérifiez d'abord l'appartenance avec l'onglet "Membre de" |
| "Domain Users ne peut pas être supprimé" | Tentative de retirer le groupe primaire | C'est normal, ce groupe est obligatoire pour tous les utilisateurs |
| Le compte ne s'affiche plus dans l'OU Users | Le compte a été déplacé ou supprimé | Cherchez dans les sous-OUs ou utilisez la fonction Rechercher |

## Exercice Suivant Suggéré

**Exercice 3** : Créer une stratégie de groupe (GPO) pour mapper un lecteur réseau projet
