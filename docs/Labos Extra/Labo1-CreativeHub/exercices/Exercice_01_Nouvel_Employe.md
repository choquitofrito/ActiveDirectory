# Exercice 1 : Bienvenue à notre Nouveau Graphiste !

## Niveau de Difficulté
🟢 **Débutant** - Guidé étape par étape

## Objectifs Pédagogiques
- Créer un compte utilisateur Active Directory via l'interface graphique
- Configurer les propriétés essentielles d'un utilisateur (nom, email, département)
- Ajouter un utilisateur à un groupe de sécurité existant

## Durée Estimée
15-20 minutes

## Prérequis
- Lab CreativeHub déployé avec succès
- Accès à "Utilisateurs et ordinateurs Active Directory" (dsa.msc)
- Connexion en tant qu'administrateur du domaine

## Contexte / Scénario
**Date**: Lundi matin, 9h00

Gabrielle Simon, la Directrice Artistique, vous envoie un email urgent :

> *"Bonjour l'équipe IT,*
>
> *Excellente nouvelle ! Nous avons embauché Sophie Moreau comme Graphiste Junior pour renforcer notre équipe Creative. Elle commence aujourd'hui à 10h et aura besoin d'accéder immédiatement à son poste de travail et aux ressources partagées du département.*
>
> *Pouvez-vous créer son compte avec les mêmes accès que les autres membres de l'équipe Creative ?*
>
> *Merci !*
> *Gabrielle*"

Votre mission : créer le compte utilisateur de Sophie avant son arrivée pour qu'elle puisse commencer à travailler sans délai.

## Tâche à Réaliser

### Étape 1 : Ouvrir la Console de Gestion AD

1. Sur le **contrôleur de domaine**, cliquez sur **Démarrer**
2. Tapez `dsa.msc` et appuyez sur **Entrée**
3. La console "Utilisateurs et ordinateurs Active Directory" s'ouvre

!!! success "Résultat attendu"
    
    Vous voyez l'arborescence du domaine maxtec.be avec l'OU CreativeHub

### Étape 2 : Naviguer vers l'Emplacement Correct

1. Dans le volet de gauche, déroulez :
   - **maxtec.be**
   - **CreativeHub**
   - **Creative**

2. Cliquez sur **Users**

!!! success "Résultat attendu"
    
    Le volet de droite affiche les 5 graphistes existants (Fabien, Gabrielle, Hugo, Inès, Julien)

### Étape 3 : Créer le Nouvel Utilisateur

1. **Clic droit** sur l'OU **Users** (dans le volet de gauche)
2. Sélectionnez **Nouveau** → **Utilisateur**
3. Dans la fenêtre qui s'ouvre, remplissez :
   - **Prénom** : `Sophie`
   - **Nom** : `Moreau`
   - **Nom complet** : `Sophie Moreau` (généré automatiquement)
   - **Nom d'ouverture de session de l'utilisateur** : `sophie`
   - Vérifiez que le suffixe est bien `@maxtec.be`

4. Cliquez sur **Suivant**


!!! success "Résultat attendu"
    Vous arrivez à la page de configuration du mot de passe

### Étape 4 : Configurer le Mot de Passe

1. **Mot de passe** : `Azerty_1`
2. **Confirmer le mot de passe** : `Azerty_1`
3. **Décochez** "L'utilisateur doit changer le mot de passe à la prochaine ouverture de session"
4. **Cochez** "Le mot de passe n'expire jamais" (pour l'environnement de lab uniquement !)
5. Cliquez sur **Suivant**, puis sur **Terminer**

!!! success "Résultat attendu"
    
    Sophie Moreau apparaît dans la liste des utilisateurs de l'OU Creative\Users

### Étape 5 : Configurer les Propriétés de l'Utilisateur

1. **Double-clic** sur **Sophie Moreau** dans la liste
2. Allez dans l'onglet **Général** :
   - **Adresse de messagerie** : `sophie@maxtec.be`

3. Allez dans l'onglet **Organisation** :
   - **Fonction** : `Graphiste Junior`
   - **Service** : `Creative`

4. Cliquez sur **Appliquer**, puis **OK**


!!! success "Résultat attendu"
    Les propriétés de Sophie sont enregistrées

### Étape 6 : Ajouter Sophie au Groupe de Sécurité

1. Naviguez vers **CreativeHub** → **Creative** → **Groups** (dans le volet de gauche)
2. **Double-clic** sur le groupe **GG-CreativeHub-Creative-Users**
3. Allez dans l'onglet **Membres**
4. Cliquez sur le bouton **Ajouter...**
5. Dans la zone "Entrez les noms des objets à sélectionner", tapez : `sophie`
6. Cliquez sur **Vérifier les noms** (le nom doit être souligné)
7. Cliquez sur **OK**, puis à nouveau sur **OK**


!!! success "Résultat attendu"
    Sophie Moreau apparaît dans la liste des membres du groupe GG-CreativeHub-Creative-Users

## Vérification de la Réussite

### Commandes PowerShell de Vérification

Ouvrez **PowerShell** et exécutez :

```powershell
# Charger le module Active Directory
Import-Module ActiveDirectory

# Vérifier que l'utilisateur existe
Get-ADUser -Identity sophie -Properties EmailAddress, Title, Department |
    Select-Object Name, SamAccountName, EmailAddress, Title, Department, Enabled

# Vérifier l'appartenance au groupe
Get-ADGroupMember -Identity "GG-CreativeHub-Creative-Users" |
    Where-Object {$_.SamAccountName -eq "sophie"} |
    Select-Object Name, SamAccountName
```

**OU** exécutez le script de vérification automatique :

```powershell
.\verif_exercice_01.ps1
```

### Critères de Réussite

- [ ] L'utilisateur "sophie" existe dans AD
- [ ] Sophie se trouve dans l'OU `OU=Users,OU=Creative,OU=CreativeHub,DC=maxtec,DC=be`
- [ ] L'email est configuré : `sophie@maxtec.be`
- [ ] La fonction est "Graphiste Junior"
- [ ] Le département est "Creative"
- [ ] Le compte est activé (Enabled = True)
- [ ] Sophie est membre du groupe `GG-CreativeHub-Creative-Users`

## Solution Complète (Pour Instructeur)

### Méthode GUI

Étapes détaillées fournies dans la section "Tâche à Réaliser" ci-dessus.

### Méthode PowerShell

```powershell
Import-Module ActiveDirectory

# Variables
$firstName = "Sophie"
$lastName = "Moreau"
$samAccountName = "sophie"
$userPath = "OU=Users,OU=Creative,OU=CreativeHub,DC=maxtec,DC=be"
$groupName = "GG-CreativeHub-Creative-Users"
$password = ConvertTo-SecureString "Azerty_1" -AsPlainText -Force

# Créer l'utilisateur
New-ADUser -Name "$firstName $lastName" `
    -GivenName $firstName `
    -Surname $lastName `
    -SamAccountName $samAccountName `
    -UserPrincipalName "$samAccountName@maxtec.be" `
    -EmailAddress "$samAccountName@maxtec.be" `
    -Title "Graphiste Junior" `
    -Department "Creative" `
    -Path $userPath `
    -AccountPassword $password `
    -Enabled $true `
    -PasswordNeverExpires $true `
    -ChangePasswordAtLogon $false

# Ajouter au groupe
Add-ADGroupMember -Identity $groupName -Members $samAccountName

Write-Host "Utilisateur Sophie Moreau créé et ajouté au groupe Creative-Users avec succès !" -ForegroundColor Green
```


## Points Clés à Retenir

- **Emplacement compte utilisateur** : Les utilisateurs doivent être créés dans l'OU correspondant à leur département (ici : `OU=Users,OU=Creative`)
- **Nom d'ouverture de session (SAM)** : Doit être unique dans tout le domaine (généralement prénom en minuscule)
- **UserPrincipalName (UPN)** : Format standard `utilisateur@domaine.com`, utilisé pour l'authentification
- **Groupes de sécurité** : Permettent de gérer les permissions et accès de manière centralisée
- **Propriétés organisationnelles** : Fonction et Service facilitent la gestion et le reporting

## Dépannage (Erreurs Courantes)

| Erreur Possible | Cause | Solution |
|-----------------|-------|----------|
| "Le nom d'ouverture de session spécifié existe déjà" | Un utilisateur avec le SAM "sophie" existe déjà | Utilisez un SAM différent (ex: sophie.moreau ou smoreau) |
| "Impossible de trouver l'objet" lors de l'ajout au groupe | Le nom n'a pas été vérifié correctement | Cliquez sur "Vérifier les noms" avant de valider |
| L'utilisateur n'apparaît pas dans la liste | Mauvaise OU sélectionnée ou besoin d'actualiser | Appuyez sur F5 pour actualiser l'affichage |
| "Accès refusé" lors de la création | Droits insuffisants | Connectez-vous avec un compte Administrateur du domaine |

## Exercice Suivant Suggéré

**Exercice 2** : Gérer le départ d'un employé (désactivation de compte et transfert d'accès)
