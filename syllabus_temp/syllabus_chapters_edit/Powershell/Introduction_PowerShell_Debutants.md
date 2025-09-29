# Introduction à PowerShell pour les administrateurs Active Directory débutants

> 📚 **Dans ce chapitre:**
> 1. 🔹 [Premiers pas avec PowerShell](#1-premiers-pas-avec-powershell)
>    - Qu'est-ce que PowerShell?
>    - La console et l'environnement
> 2. 🔹 [Commandes de base](#2-commandes-de-base)
>    - Cmdlets essentielles
>    - Obtenir de l'aide
> 3. 🔹 [Travailler avec Active Directory](#3-travailler-avec-active-directory)
>    - Commandes AD simples
>    - Recherche d'objets
> 4. 🔹 [Automatisation simple](#4-automatisation-simple)
>    - Création de scripts basiques
>    - Exemples pratiques
> 5. 🔹 [Aller plus loin](#5-aller-plus-loin)
>    - Ressources d'apprentissage
>    - Prochaines étapes

---

## 📙 Objectifs Pédagogiques

À la fin de ce chapitre, vous serez capable de :
1. Comprendre ce qu'est PowerShell et son utilité pour l'administration AD
2. Exécuter des commandes PowerShell simples pour gérer Active Directory
3. Créer des scripts basiques pour automatiser des tâches répétitives
4. Savoir où trouver de l'aide et des ressources pour continuer votre apprentissage

---

## 1. 🔹 Premiers pas avec PowerShell

### 1.1. Qu'est-ce que PowerShell?

PowerShell est un outil créé par Microsoft qui permet d'automatiser des tâches sur Windows. Imaginez-le comme une "super console de commande" qui vous permet de contrôler votre système et vos applications comme Active Directory.

> 💡 **Analogie**: Si l'interface graphique d'Active Directory est comme conduire une voiture avec un volant et des pédales, PowerShell est comme avoir accès au moteur directement - plus technique mais beaucoup plus puissant!

#### Pourquoi utiliser PowerShell pour Active Directory?

- **Gain de temps**: Automatiser des tâches répétitives
- **Précision**: Moins d'erreurs humaines
- **Puissance**: Accès à des fonctionnalités avancées
- **Documentation**: Les commandes servent aussi de documentation

### 1.2. Ouvrir et utiliser PowerShell

Pour commencer à utiliser PowerShell avec Active Directory:

1. Cliquez sur le menu Démarrer
2. Tapez "PowerShell"
3. Cliquez-droit sur "Windows PowerShell" et sélectionnez "Exécuter en tant qu'administrateur"

Vous verrez une fenêtre avec un fond bleu et une invite de commande comme celle-ci:
```
PS C:\Windows\system32>
```

C'est ici que vous allez taper vos commandes.

## 2. 🔹 Commandes de base

### 2.1. Structure des commandes PowerShell

Les commandes PowerShell (appelées "cmdlets") suivent toujours une structure simple:

```
Verbe-Nom -Paramètre Valeur
```

Par exemple:
```powershell
Get-Service -Name "DNS"
```

Cette commande utilise:
- Le verbe `Get` (obtenir)
- Le nom `Service` (service)
- Le paramètre `-Name` (nom)
- La valeur `"DNS"` (le service DNS)

### 2.2. Commandes essentielles pour débuter

Voici quelques commandes de base à connaître:

| Commande | Description | Exemple |
|----------|-------------|---------|
| `Get-Command` | Liste les commandes disponibles | `Get-Command -Name *user*` |
| `Get-Help` | Affiche l'aide d'une commande | `Get-Help Get-Service` |
| `Get-Module` | Liste les modules chargés | `Get-Module -ListAvailable` |
| `Import-Module` | Charge un module | `Import-Module ActiveDirectory` |

### 2.3. Obtenir de l'aide

PowerShell dispose d'un système d'aide intégré très complet. Pour l'utiliser:

```powershell
# Aide basique sur une commande
Get-Help Get-ADUser

# Aide détaillée avec exemples
Get-Help Get-ADUser -Examples

# Aide en ligne (ouvre la documentation dans le navigateur)
Get-Help Get-ADUser -Online
```

> 💡 **Astuce**: Si vous ne savez pas quelle commande utiliser, essayez `Get-Command` avec un mot-clé:
> ```powershell
> Get-Command *user*
> ```

## 3. 🔹 Travailler avec Active Directory

### 3.1. Préparation: Importer le module AD

Avant de pouvoir utiliser les commandes Active Directory, vous devez charger le module correspondant:

```powershell
Import-Module ActiveDirectory
```

Si cette commande ne fonctionne pas, c'est probablement parce que les outils d'administration AD ne sont pas installés. Vous pouvez les installer via le Gestionnaire de serveur.

### 3.2. Commandes AD simples

#### Afficher les informations d'un utilisateur

```powershell
# Obtenir les informations de base d'un utilisateur
Get-ADUser -Identity "sophie.lambert"

# Obtenir des informations plus détaillées
Get-ADUser -Identity "sophie.lambert" -Properties *
```

#### Lister tous les utilisateurs d'un département

```powershell
# Lister tous les utilisateurs du département Comptabilité
Get-ADUser -Filter {Department -eq "Comptabilité"} -Properties Department
```

#### Afficher les membres d'un groupe

```powershell
# Lister les membres du groupe "GG-EU-Compta-Utilisateurs"
Get-ADGroupMember -Identity "GG-EU-Compta-Utilisateurs"
```

#### Lister les ordinateurs

```powershell
# Lister tous les ordinateurs du domaine
Get-ADComputer -Filter *

# Lister les ordinateurs du département Comptabilité
Get-ADComputer -Filter {Name -like "ws-compta*"}
```

### 3.3. Exercices simples

**Exercice 1**: Affichez les informations de votre propre compte utilisateur.
```powershell
Get-ADUser -Identity $env:USERNAME
```

**Exercice 2**: Listez tous les groupes dont vous êtes membre.
```powershell
Get-ADPrincipalGroupMembership -Identity $env:USERNAME
```

**Exercice 3**: Trouvez tous les utilisateurs dont le nom commence par "s".
```powershell
Get-ADUser -Filter {Name -like "s*"}
```

## 4. 🔹 Automatisation simple

### 4.1. Votre premier script PowerShell

Un script PowerShell est simplement un fichier texte avec l'extension `.ps1` qui contient une série de commandes.

Voici comment créer votre premier script:

1. Ouvrez le Bloc-notes ou un autre éditeur de texte
2. Copiez les lignes suivantes:

```powershell
# Mon premier script PowerShell pour AD
Write-Host "Rapport des utilisateurs récemment créés" -ForegroundColor Green

# Obtenir la date d'il y a 7 jours
$dateLimite = (Get-Date).AddDays(-7)

# Trouver les utilisateurs créés depuis cette date
$nouveauxUtilisateurs = Get-ADUser -Filter {Created -ge $dateLimite} -Properties Created

# Afficher les résultats
Write-Host "Utilisateurs créés dans les 7 derniers jours:" -ForegroundColor Yellow
$nouveauxUtilisateurs | Format-Table Name, SamAccountName, Created
```

3. Enregistrez le fichier sous le nom `RapportNouveauxUtilisateurs.ps1`
4. Exécutez-le dans PowerShell avec la commande:

```powershell
.\RapportNouveauxUtilisateurs.ps1
```

### 4.2. Explication ligne par ligne

Analysons ce script:

```powershell
# Mon premier script PowerShell pour AD
```
Ceci est un commentaire. Les lignes commençant par `#` sont ignorées lors de l'exécution.

```powershell
Write-Host "Rapport des utilisateurs récemment créés" -ForegroundColor Green
```
Cette ligne affiche un texte en vert dans la console.

```powershell
$dateLimite = (Get-Date).AddDays(-7)
```
Ici, nous créons une variable `$dateLimite` qui contient la date d'il y a 7 jours.

```powershell
$nouveauxUtilisateurs = Get-ADUser -Filter {Created -ge $dateLimite} -Properties Created
```
Cette ligne recherche tous les utilisateurs créés après notre date limite et stocke le résultat dans la variable `$nouveauxUtilisateurs`.

```powershell
Write-Host "Utilisateurs créés dans les 7 derniers jours:" -ForegroundColor Yellow
$nouveauxUtilisateurs | Format-Table Name, SamAccountName, Created
```
Ces lignes affichent un titre en jaune, puis les résultats sous forme de tableau.

### 4.3. Exercices guidés

**Exercice 4**: Modifiez le script précédent pour afficher les utilisateurs créés dans les 30 derniers jours.

**Exercice 5**: Créez un script qui liste tous les ordinateurs qui ne se sont pas connectés depuis 30 jours.
```powershell
# Rapport des ordinateurs inactifs
$dateLimite = (Get-Date).AddDays(-30)
$ordinateursInactifs = Get-ADComputer -Filter {LastLogonDate -le $dateLimite} -Properties LastLogonDate
Write-Host "Ordinateurs inactifs depuis plus de 30 jours:" -ForegroundColor Yellow
$ordinateursInactifs | Format-Table Name, LastLogonDate
```

## 5. 🔹 Exemples pratiques pour Active Directory

### 5.1. Création d'un utilisateur

```powershell
# Création d'un nouvel utilisateur
New-ADUser -Name "Pierre Durand" `
    -GivenName "Pierre" `
    -Surname "Durand" `
    -SamAccountName "pierre.durand" `
    -UserPrincipalName "pierre.durand@maxtec.be" `
    -Path "OU=Utilisateurs,OU=Comptabilité,OU=EU,DC=maxtec,DC=be" `
    -AccountPassword (ConvertTo-SecureString "Password1!" -AsPlainText -Force) `
    -Enabled $true `
    -ChangePasswordAtLogon $true
```

> 💡 **Astuce**: Le symbole `` ` `` (accent grave) à la fin d'une ligne permet de continuer la commande sur la ligne suivante pour plus de lisibilité.

### 5.2. Ajout d'un utilisateur à un groupe

```powershell
# Ajouter l'utilisateur au groupe des comptables
Add-ADGroupMember -Identity "GG-EU-Compta-Utilisateurs" -Members "pierre.durand"
```

### 5.3. Création d'une unité d'organisation

```powershell
# Créer une nouvelle OU pour les stagiaires
New-ADOrganizationalUnit -Name "Stagiaires" `
    -Path "OU=Comptabilité,OU=EU,DC=maxtec,DC=be" `
    -ProtectedFromAccidentalDeletion $true
```

### 5.4. Déplacement d'un utilisateur

```powershell
# Déplacer un utilisateur vers l'OU des stagiaires
Move-ADObject -Identity "CN=Pierre Durand,OU=Utilisateurs,OU=Comptabilité,OU=EU,DC=maxtec,DC=be" `
    -TargetPath "OU=Stagiaires,OU=Comptabilité,OU=EU,DC=maxtec,DC=be"
```

## 6. 🔹 Mini-projets pour débutants

Voici quelques mini-projets simples pour pratiquer:

### 6.1. Rapport des comptes utilisateurs

Créez un script qui génère un rapport CSV des utilisateurs avec leurs informations principales:

```powershell
# Rapport des utilisateurs
$utilisateurs = Get-ADUser -Filter * -Properties Name, EmailAddress, Department, Title, Enabled

# Sélectionner les propriétés à exporter
$rapport = $utilisateurs | Select-Object Name, SamAccountName, EmailAddress, Department, Title, Enabled

# Exporter vers CSV
$rapport | Export-Csv -Path "C:\Rapports\utilisateurs.csv" -NoTypeInformation

Write-Host "Rapport généré avec succès: C:\Rapports\utilisateurs.csv" -ForegroundColor Green
```

### 6.2. Vérification des comptes verrouillés

Créez un script qui vérifie et affiche les comptes verrouillés:

```powershell
# Vérification des comptes verrouillés
$comptesVerrouilles = Search-ADAccount -LockedOut

if ($comptesVerrouilles.Count -eq 0) {
    Write-Host "Aucun compte verrouillé trouvé." -ForegroundColor Green
} else {
    Write-Host "Comptes verrouillés:" -ForegroundColor Red
    $comptesVerrouilles | Format-Table Name, SamAccountName
    
    # Option pour déverrouiller
    $reponse = Read-Host "Voulez-vous déverrouiller ces comptes? (O/N)"
    if ($reponse -eq "O") {
        $comptesVerrouilles | Unlock-ADAccount
        Write-Host "Comptes déverrouillés avec succès." -ForegroundColor Green
    }
}
```

### 6.3. Audit des groupes vides

Créez un script qui identifie les groupes sans membres:

```powershell
# Audit des groupes vides
$tousLesGroupes = Get-ADGroup -Filter *
$groupesVides = @()

foreach ($groupe in $tousLesGroupes) {
    $membres = Get-ADGroupMember -Identity $groupe.DistinguishedName -ErrorAction SilentlyContinue
    if ($membres.Count -eq 0) {
        $groupesVides += $groupe
    }
}

Write-Host "Groupes sans membres:" -ForegroundColor Yellow
$groupesVides | Format-Table Name, GroupCategory, GroupScope
```

## 7. 🔹 Bonnes pratiques pour débutants

1. **Commencez petit**: Maîtrisez les commandes de base avant de créer des scripts complexes
2. **Utilisez l'aide**: `Get-Help` est votre meilleur ami
3. **Testez en environnement de test**: Ne testez jamais vos scripts en production
4. **Commentez votre code**: Expliquez ce que fait chaque section
5. **Sauvegardez avant de modifier**: Exportez les données avant de les modifier
6. **Utilisez -WhatIf**: Ajoutez `-WhatIf` aux commandes qui modifient des objets pour voir ce qui se passerait sans l'exécuter réellement

## 8. 🔹 Ressources pour continuer l'apprentissage

- **Documentation Microsoft**: [PowerShell Documentation](https://docs.microsoft.com/fr-fr/powershell/)
- **Forums**: [PowerShell.org](https://powershell.org/), [Reddit PowerShell](https://www.reddit.com/r/PowerShell/)
- **Livres**: "PowerShell pour les débutants" (disponible en français)
- **Vidéos**: Nombreux tutoriels sur YouTube en français

## 📝 Exercices pratiques

1. Créez un script qui liste tous les utilisateurs du département Ventes.

2. Modifiez le script pour exporter la liste dans un fichier CSV.

3. Créez un script qui affiche tous les ordinateurs qui n'ont pas été utilisés depuis 14 jours.

4. Créez un script qui liste tous les groupes et le nombre de membres dans chacun.

5. Créez un script qui vérifie si un utilisateur spécifique existe dans AD, et si non, le crée.

---

## 🔑 Points clés à retenir

- PowerShell est un outil puissant pour automatiser l'administration d'Active Directory
- Les commandes PowerShell suivent une structure Verbe-Nom cohérente
- Commencez par des commandes simples avant de créer des scripts complexes
- Utilisez toujours `Get-Help` quand vous ne savez pas comment utiliser une commande
- La pratique régulière est la clé pour maîtriser PowerShell
