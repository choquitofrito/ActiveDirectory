# Les concepts de base PowerShell pour Active Directory

Ce chapitre vous introduira aux concepts fondamentaux de PowerShell dans le contexte d'Active Directory. Vous n'avez pas besoin d'être développeur pour comprendre et utiliser ces concepts !

## 1. 🔹 Les variables : vos boîtes de rangement numériques

Une variable est simplement un conteneur qui stocke une information. Pensez-y comme à une boîte étiquetée où vous rangez temporairement des données.

### Création d'une variable

```powershell
# Créer une variable pour stocker un nom d'utilisateur
$nomUtilisateur = "jean.dupont"

# Afficher le contenu de la variable (plusieurs méthodes)
$nomUtilisateur                      # Méthode 1: Simplement taper le nom de la variable
Write-Host $nomUtilisateur           # Méthode 2: Utiliser Write-Host (affichage formaté)
Write-Output $nomUtilisateur         # Méthode 3: Utiliser Write-Output (pour le pipeline, on le verra plus tard)
echo $nomUtilisateur                 # Méthode 4: Utiliser l'alias 'echo' (comme Write-Output)
```

> Remarquez le symbole `$` qui indique qu'il s'agit d'une variable.

### Exercice 1.1 : Créez votre première variable

1. Créez une variable `$monDomaine` contenant le nom de votre domaine AD
2. Affichez son contenu
3. Modifiez sa valeur et affichez-la à nouveau

### Exercice 1.2 : Variables et concaténation

1. Créez une variable `$prenom` contenant votre prénom
2. Créez une variable `$nom` contenant votre nom de famille
3. Créez une variable `$nomComplet` qui combine les deux avec un espace entre eux (indice : utilisez `$prenom + " " + $nom`)
4. Créez une variable `$loginAD` qui serait votre identifiant AD au format `prenom.nom` (comme "jean.dupont")
5. Affichez un message qui dit "Bonjour [nomComplet], votre login est [loginAD]"


### Variables et commandes AD

Les variables sont particulièrement utiles pour stocker les résultats de vos commandes AD :

```powershell
# Stocker un utilisateur dans une variable
$utilisateur = Get-ADUser -Identity "jean.dupont" -Properties *
```

**Note**: ceci était une rechercher par identifiant. 

> **Le paramètre -Identity** : Ce paramètre permet de spécifier quel objet AD vous voulez manipuler. Il accepte plusieurs formats d'identification. Par exemple... si on a le groupe "GG-EU-IT-Users", on peut le trouver de plusieurs manières en utilisant le paramètre -Identity :
> - **Nom** : Simplement le nom du groupe (ex: -Identity "GG-EU-IT-Users")
> - **SamAccountName** : L'identifiant unique du groupe dans le domaine (ex: -Identity "GG-EU-IT-Users")
> - **DistinguishedName** : Le chemin complet dans l'AD (ex: -Identity "CN=GG-EU-IT-Users,OU=Groups,OU=EU,DC=computerelectronics,DC=be")
> - **GUID** : L'identifiant unique global (ex: -Identity "123e4567-e89b-12d3-a456-426614174000")
>

```powershell
# Maintenant on peut accéder facilement à ses propriétés (créez de valeurs pour les champs manquants dans AD, car le script est simplifié et crée des utilisateurs qui n'ont pas toutes les propriétés)
Write-Host $utilisateur.Surname
Write-Host $utilisateur.GivenName
Write-Host $utilisateur.Email
```
   > **Note sur la langue** : Même si votre interface AD est en français, les noms des propriétés dans PowerShell sont toujours en anglais. Utilisez donc `GivenName` (prénom), `Surname` (nom de famille), `Title` (titre), etc. Ces noms sont standardisés et ne changent pas avec la langue de l'interface.


### Exercice 1.3 : Manipuler un utilisateur via une variable

1. Utilisez le code suivant pour demander à l'utilisateur de saisir un nom d'utilisateur :
   
   ```powershell
   # Demander le nom d'utilisateur à rechercher (Read-Host attendra la saisie de l'utilisateur)
   $nomUtilisateurRecherche = Read-Host "Entrez le nom d'utilisateur à rechercher"
   
   # Récupérer l'utilisateur dans une variable (recherche par SamAccountName) et obtenir les propriétés GivenName, Surname et Title
   $utilisateurTrouve = Get-ADUser -Filter {SamAccountName -eq $nomUtilisateurRecherche} -Properties GivenName, Surname, Title
   
   # Vérifier si l'utilisateur existe
   if ($utilisateurTrouve) {
       Write-Host "Utilisateur trouvé !"
       Write-Host "Prénom : $($utilisateurTrouve.GivenName)"
       Write-Host "Nom : $($utilisateurTrouve.Surname)"
       Write-Host "Titre : $($utilisateurTrouve.Title)"
   } else {
       Write-Host "Aucun utilisateur trouvé avec ce nom."
   }
   ```
   
   > **Important** : Modifier les valeurs dans une variable n'a aucun effet sur l'objet réel dans Active Directory. Par exemple, si vous faites `$utilisateurTrouve.Title = "Nouveau Titre"`, cela change uniquement la valeur dans votre variable locale, pas dans AD. Pour modifier réellement un objet AD, vous devez utiliser des commandes spécifiques comme `Set-ADUser` que nous verrons plus tard.
   >


2. Modifiez ce script pour afficher également le département et la date de création du compte (remplissez les champs manquants dans AD)
3. Ajoutez une condition pour afficher un message spécial si l'utilisateur fait partie du département "IT"


## 2. 🔹 Les tableaux : vos collections d'objets

Un tableau est une collection d'éléments. Imaginez un classeur avec plusieurs tiroirs numérotés.

### Création d'un tableau simple

```powershell
# Créer un tableau de noms d'utilisateurs (attention à la notation de @ et parenthèses)
$utilisateurs = @("jean.dupont", "marie.martin", "pierre.durand")

# Afficher le premier élément (les indices commencent à 0)
$utilisateurs[0]

# Afficher le dernier élément
$utilisateurs[-1]

# Afficher tout le tableau (plusieurs méthodes)
$utilisateurs                 # Méthode 1: Simplement taper le nom du tableau
$utilisateurs | ForEach-Object { Write-Host $_ }  # Méthode 2: Afficher chaque élément sur une ligne

```

### Exercice 2.1 : Créez et manipulez un tableau

1. Créez un tableau contenant les noms des départements de votre entreprise
2. Affichez le deuxième département
3. Ajoutez un quatrième département avec `$tableauDepts += "Nouveau Dept"`

### Tableaux d'objets AD

En PowerShell, les résultats de nombreuses commandes sont automatiquement des tableaux :

```powershell
# Récupérer tous les utilisateurs du département Comptabilité
$comptabilite = Get-ADUser -Filter {Department -eq "Comptabilité"} -Properties Department

# Combien d'utilisateurs avons-nous ?
$comptabilite.Count

# Accéder au premier utilisateur
$comptabilite[0].Name
```

### Exercice 2.2 : Manipuler des collections d'objets AD

1. Récupérez tous les groupes dont le nom contient "GG-EU" (utiliser `Filter` et `like`)
2. Affichez le nombre de groupes trouvés
3. Affichez uniquement le nom du premier et du dernier groupe

## 3. 🔹 Les boucles : répéter des actions

Les boucles permettent de répéter une action pour chaque élément d'une collection. C'est comme traiter un dossier de documents un par un.

### La boucle ForEach

```powershell
# Pour chaque utilisateur dans le département Comptabilité
foreach ($user in $comptabilite) {
    # Afficher son nom et son titre
    Write-Host ("Nom: " + $user.Name + ", Titre: " + $user.Title)
}
```

> Le bloc `{ }` contient les actions à répéter pour chaque élément.

### Exercice 3.1 : Votre première boucle

1. Récupérez tous les utilisateurs du département "Ventes"
2. Créez une boucle qui affiche pour chacun : "L'utilisateur [Nom] a pour email [Email]"
3. Modifiez votre boucle pour n'afficher que les utilisateurs dont le nom commence par "D"

### Boucle avec le pipeline (la barre verticale `|`)

PowerShell offre une syntaxe plus concise avec le pipeline `|` et `ForEach-Object` :

```powershell
# Même résultat que la boucle précédente
Get-ADUser -Filter {Department -eq "Comptabilité"} -Properties Department, Title | 
    ForEach-Object {
        Write-Host "Nom: $($_.Name), Titre: $($_.Title)"
    }
```

> Le symbole `$_` représente l'élément actuel dans la boucle.

### Exercice 3.2 : Utiliser le pipeline

1. Utilisez le pipeline pour lister tous les groupes de sécurité
2. Pour chaque groupe, affichez son nom et le nombre de membres
3. Bonus : triez les résultats par nombre de membres (indice : `Sort-Object`)

## 4. 🔹 Les conditions : prendre des décisions

Les conditions permettent d'exécuter du code uniquement si certains critères sont remplis. C'est comme suivre un arbre de décision.

### Structure If-Else

```powershell
# Vérifier si un utilisateur est membre d'un groupe spécifique
$user = Get-ADUser -Identity "jean.dupont"
$groupe = "GG-EU-RH-Users"

if (Get-ADGroupMember -Identity $groupe | Where-Object {$_.SamAccountName -eq $user.SamAccountName}) {
    Write-Host "$($user.Name) est membre du groupe $groupe"
} else {
    Write-Host "$($user.Name) n'est PAS membre du groupe $groupe"
}
```

### Exercice 4.1 : Conditions simples

1. Récupérez un utilisateur de votre choix
2. Vérifiez s'il a une adresse email renseignée
3. Affichez un message approprié selon le cas

### Conditions multiples

```powershell
# Vérifier le statut d'un utilisateur
$user = Get-ADUser -Identity "marie.martin" -Properties Enabled, LockedOut

if ($user.Enabled -eq $false) {
    Write-Host "Le compte est désactivé"
} elseif ($user.LockedOut -eq $true) {
    Write-Host "Le compte est verrouillé"
} else {
    Write-Host "Le compte est actif et utilisable"
}
```

### Exercice 4.2 : Analyse d'utilisateurs

1. Créez un script qui analyse un utilisateur et indique :
   - Si son compte est activé ou désactivé
   - S'il est membre du groupe "GG-EU-IT-Admins"
   - Si son mot de passe n'expire jamais

## 5. 🔹 Mini-projet : Rapport d'audit AD

Combinons tous ces concepts dans un mini-projet utile !

### Objectif
Créer un rapport qui liste tous les utilisateurs d'un département spécifique, avec leur statut de compte et leurs groupes principaux.

```powershell
# Demander le département à l'utilisateur
$departement = Read-Host "Entrez le nom du département à auditer"

# Récupérer les utilisateurs
$users = Get-ADUser -Filter {Department -eq $departement} -Properties Department, Enabled, MemberOf

# Vérifier si des utilisateurs ont été trouvés
if ($users.Count -eq 0) {
    Write-Host "Aucun utilisateur trouvé dans le département $departement"
} else {
    # Afficher un en-tête
    Write-Host "=== RAPPORT D'AUDIT : DÉPARTEMENT $departement ==="
    Write-Host "Nombre d'utilisateurs : $($users.Count)"
    Write-Host "----------------------------------------"
    
    # Pour chaque utilisateur
    foreach ($user in $users) {
        # Statut du compte
        $statut = if ($user.Enabled) {"ACTIF"} else {"DÉSACTIVÉ"}
        
        # Afficher les informations de base
        Write-Host "UTILISATEUR : $($user.Name) - $statut"
        
        # Récupérer et afficher les 3 premiers groupes
        $groupes = Get-ADPrincipalGroupMembership -Identity $user.SamAccountName | Select-Object -First 3
        Write-Host "  Groupes principaux :"
        foreach ($groupe in $groupes) {
            Write-Host "    - $($groupe.Name)"
        }
        
        Write-Host "----------------------------------------"
    }
}
```

### Exercice final : Personnalisez le rapport

1. Adaptez le script pour qu'il affiche également :
   - La date de dernière connexion (LastLogonDate)
   - Si le mot de passe expire ou non
2. Ajoutez une condition pour mettre en évidence les comptes inactifs depuis plus de 30 jours
3. Bonus : Permettez de filtrer les utilisateurs par leur statut (actif/inactif)

## 5. 🔹 Ressources supplémentaires

- Utilisez `Get-Help` pour obtenir de l'aide sur n'importe quelle commande
- La commande `Get-Member` vous montre toutes les propriétés et méthodes d'un objet
- N'hésitez pas à expérimenter dans la console PowerShell, c'est sans danger tant que vous n'utilisez que des commandes Get-*
