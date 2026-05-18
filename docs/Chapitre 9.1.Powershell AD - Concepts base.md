# Chapitre 9.1: Les concepts de base PowerShell pour Active Directory

## 🧭 Navigation du Cours
[⏮️ Chapitre Précédent: Powershell AD - Introduction](Chapitre%209.0.Powershell%20AD%20-%20Introduction.md) | [🏠 Retour au Syllabus](index.md) | [⏭️ Chapitre Suivant: Powershell AD - Requêtes et Informations](Chapitre%209.2.Powershell%20AD%20-%20Requetes_et_Informations.md)

---

!!! info "📚 Dans ce chapitre"
    
    Ce chapitre vous introduira aux concepts fondamentaux de PowerShell dans le contexte d'Active Directory. Vous n'avez pas besoin d'être développeur pour comprendre et utiliser ces concepts !

---

!!! info "Fil rouge : Jour 2 chez Maxtec"
    
    Sophie vous confie une nouvelle tâche : construire un script d'audit réutilisable. Jusqu'ici vous avez tapé des commandes une par une ; aujourd'hui vous allez les enchaîner avec des **variables**, des **tableaux**, des **boucles** et des **conditions**. Chaque mission ci-dessous s'appuie sur la précédente.

---

## 1. 🔹 Les variables : des boîtes de rangement

!!! tip "Concept simple"
    
    Une variable est simplement un conteneur qui stocke une information. Pensez-y comme à une boîte étiquetée où vous rangez temporairement des données.

### Création d'une variable

```powershell
# Créer une variable pour stocker un nom d'utilisateur
$nomUtilisateur = "jean.dupont"

# Afficher le contenu de la variable (plusieurs méthodes)
Write-Host $nomUtilisateur           # Méthode 1: Utiliser Write-Host (affichage formaté)
$nomUtilisateur                      # Méthode 2: Simplement taper le nom de la variable
Write-Output $nomUtilisateur         # Méthode 3: Utiliser Write-Output (pour le pipeline, on le verra plus tard)
echo $nomUtilisateur                 # Méthode 4: Utiliser l'alias 'echo' (comme Write-Output)
```

!!! note "Symbole important"
    
    Remarquez le symbole `$` qui indique qu'il s'agit d'une variable.

### Mission 1.1 — Variable de contexte

!!! example "Objectif"
    
    La convention Maxtec pour les logins est `prenom.nom`. Construisez les variables de base dont vous aurez besoin dans les missions suivantes :
    
    1. Stockez `"maxtec.be"` dans `$domaine`
    2. Créez `$prenom` et `$nom` avec votre propre prénom/nom
    3. Déduisez `$login` au format `prenom.nom` en minuscules
    4. Déduisez `$email` au format `login@maxtec.be`
    5. Affichez un résumé : nom complet, login, email
    
    *Indice : `.ToLower()` convertit une chaîne en minuscules.*

??? success "Solution"
    
    ```powershell
    $domaine = "maxtec.be"
    $prenom  = "Jean"
    $nom     = "Dupont"
    
    $login   = $prenom.ToLower() + "." + $nom.ToLower()
    $email   = "$login@$domaine"
    
    Write-Host "$prenom $nom — login : $login — email : $email"
    ```
    
    À noter : dans une chaîne entre guillemets `"..."`, PowerShell évalue les variables directement (`"$login@$domaine"`). Pas besoin de concaténation.

### Mission 1.2 — Stocker un résultat AD dans une variable

!!! example "Objectif"
    
    Récupérez votre propre compte (ou un compte de test) et explorez ses propriétés via la variable :
    
    1. Stockez le résultat de `Get-ADUser -Identity $login -Properties *` dans `$monCompte`
    2. Affichez le `GivenName`, `Surname`, `Title` et `Department`
    3. Affichez la date de création (`WhenCreated`)
    4. Vérifiez si le compte est activé (`Enabled`)

??? success "Solution"
    
    ```powershell
    $login     = "jean.dupont"   # adaptez
    $monCompte = Get-ADUser -Identity $login -Properties *
    
    Write-Host "Prénom    : $($monCompte.GivenName)"
    Write-Host "Nom       : $($monCompte.Surname)"
    Write-Host "Titre     : $($monCompte.Title)"
    Write-Host "Service   : $($monCompte.Department)"
    Write-Host "Créé le   : $($monCompte.WhenCreated)"
    Write-Host "Activé    : $($monCompte.Enabled)"
    ```
    
    La syntaxe `$($variable.Propriete)` est nécessaire à l'intérieur d'une chaîne pour évaluer une propriété.


### Variables et commandes AD

!!! info "Utilisation pratique"
    
    Les variables sont particulièrement utiles pour stocker les résultats de vos commandes AD :

```powershell
# Stocker un utilisateur dans une variable avec toutes ses propriétés
$utilisateur = Get-ADUser -Identity "jean.dupont" -Properties *
$groupe = Get-ADGroup -Identity "CN=GG-EU-RH-Admin,OU=Groups,OU=RH,OU=EU,DC=maxtec,DC=be" -Properties *
```

!!! note "Recherche par identifiant"
    
    Ceci était une recherche par **identifiant**.

!!! tip "Le paramètre -Identity"
    
    Ce paramètre permet de spécifier quel objet AD vous voulez obtenir/modifier. Il accepte plusieurs formats d'identification. Par exemple... si on a le groupe "GG-EU-IT-Users", on peut le trouver de plusieurs manières en utilisant le paramètre -Identity :
    
    - **Nom** : Simplement le nom du groupe (ex: -Identity "GG-EU-IT-Users")
    - **SamAccountName** : L'identifiant unique du groupe dans le domaine (ex: -Identity "GG-EU-IT-Users")
    - **DistinguishedName** : Le chemin complet dans l'AD (ex: -Identity "CN=GG-EU-IT-Users,OU=Groups,OU=EU,DC=maxtec,DC=be")
    - **GUID** : L'identifiant unique global (ex: -Identity "123e4567-e89b-12d3-a456-426614174000")

```powershell
# Maintenant on peut accéder facilement à ses propriétés (créez de valeurs pour les champs manquants dans AD, car le script est simplifié et crée des utilisateurs qui n'ont pas toutes les propriétés)
Write-Host $utilisateur.Surname
Write-Host $utilisateur.GivenName
Write-Host $utilisateur.Email
```

!!! warning "Note sur la langue"
    
    Même si votre interface AD est en français, les noms des propriétés dans PowerShell sont toujours en anglais. Utilisez donc `GivenName` (prénom), `Surname` (nom de famille), `Title` (titre), etc. Ces noms sont standardisés et ne changent pas avec la langue de l'interface.


### Mais quelles sont les propriétés disponibles ???

!!! info "Découvrir les propriétés"
    
    Avant de pouvoir rechercher des informations spécifiques, il est important de connaître les attributs/propriétés disponibles. Ces propriétés sont aussi accessibles dans le menu `Propriétés` > `Editeur d'attributs` dans `Utilisateurs et groupes d'AD` (il faut activer l'option `Fonctionnalités avancées` dans le menu principal de `Utilisateurs et groupes d'AD`)


```powershell
Get-ADUser -Filter * -Properties * | Get-Member -MemberType Property
```



!!! tip "Recherche avec Filter"
    
    Avec **Filter** on peut rechercher des éléments à partir des valeurs de leurs propriétés. Par **exemple, on peut rechercher des utilisateurs par leur nom, leur titre, leur service** ('department' en anglais. La propriété est dans l'onglet `Organisation` dans les propriétés des utilisateurs), etc.

```powershell
# Exemple 1:  Rechercher les utilisateurs créés après le 1er janvier 2023
# La commande Select-Object permet de filtrer les propriétés d'un objet que l'on souhaite afficher. Dans ce cas, on ne veut afficher que le nom, le nom d'utilisateur et la date de création.
$date = Get-Date "01/01/2023"
# Sans Select-Object, PowerShell retourne TOUTES les pr opriétés disponibles (plus d'une quinzaine), ce qui rend la sortie verbeuse et moins ciblée. Comparez avec l'exemple 2 pour voir la différence.
Get-ADUser -Filter {WhenCreated -ge $date} -Properties WhenCreated


# Exemple 2: Même requête que l'exemple 1, mais avec Select-Object pour filtrer les propriétés
# Ici, on utilise le même filtre de date, mais Select-Object limite l'affichage à Name, SamAccountAccount et WhenCreated pour une sortie ciblée et efficace.
$date = Get-Date "01/01/2023"
Get-ADUser -Filter {WhenCreated -ge $date} -Properties WhenCreated | Select-Object Name, SamAccountName, WhenCreated

# Exemple 3: Même requête avec Format-Table . Select-Object afficher comme liste s'il y a plus de 4 propriétés. Si on veut un tableau, utilisez Format-Table
$date = Get-Date "01/01/2023"
Get-ADUser -Filter {WhenCreated -ge $date} -Properties WhenCreated | Select-Object Name, SamAccountName, WhenCreated | Format-Table 





```


## 2. 🔹 Les tableaux : vos collections d'objets

!!! tip "Concept simple"
    
    Un tableau est une collection d'éléments. Imaginez un classeur avec plusieurs tiroirs numérotés.

### Création d'un tableau simple

```powershell
# Créer un tableau de noms d'utilisateurs (attention à la notation de @ et parenthèses)
$utilisateurs = @("jean.dupont", "marie.martin", "pierre.durand")

# Afficher le premier élément (les indices commencent à 0)
$utilisateurs[0]

# Afficher le dernier élément
$utilisateurs[-1]
```

Vous pouvez rajouter, effacer, modifier et obtenir un élément d'un tableau :

```powershell
# Obtenir un élément (par exemple, le deuxième utilisateur)
$deuxiemeUtilisateur = $utilisateurs[1]
Write-Host "Deuxième utilisateur : $deuxiemeUtilisateur"

# Ajouter un élément à un tableau existant
$utilisateurs += "luc.lefevre"

# Modifier un élément (changer "pierre.durand" en "pierre.dupuis")

$index = $utilisateurs.IndexOf("pierre.durand")
if ($index -ge 0) {
    $utilisateurs[$index] = "pierre.dupuis"
}
```

!!! note "Note sur la suppression"
    Pour la suppression, il faut faire attention à la taille fixe du tableau. Nous n'aborderons pas cette opération ici, mais vous pouvez la rechercher dans la documentation PowerShell si nécessaire.


### Mission 2.1 — Tableau des départements

!!! example "Objectif"
    
    Sophie vous demande de préparer la liste des départements de Maxtec EU. Ce tableau servira dans la mission suivante pour boucler automatiquement dessus :
    
    1. Créez `$departements` avec : `RH`, `IT`, `Ventes`, `Comptabilité`, `Marketing`
    2. Affichez le premier et le dernier élément
    3. Ajoutez `"Logistique"` au tableau
    4. Affichez le nombre total d'éléments
    5. Vérifiez si `"RH"` est dans la liste (`.Contains()`)

??? success "Solution"
    
    ```powershell
    $departements = @("RH", "IT", "Ventes", "Comptabilité", "Marketing")
    
    Write-Host "Premier : $($departements[0])"
    Write-Host "Dernier : $($departements[-1])"
    
    $departements += "Logistique"
    
    Write-Host "Total : $($departements.Count)"
    
    if ($departements.Contains("RH")) {
        Write-Host "RH est dans la liste"
    }
    ```
    
    `[0]` = premier élément, `[-1]` = dernier. `$()` évalue une expression à l'intérieur d'une chaîne.



### Tableaux d'objets AD

En PowerShell, les résultats de nombreuses commandes sont automatiquement des tableaux, et la plupart de fois ils contiendront des objets :

```powershell
# Récupérer tous les utilisateurs du service Comptabilité: tableau d'objets ADUser
$utilisateursComptabilite = Get-ADUser -Filter *

# Combien d'utilisateurs avons-nous ? (nombre d'objets dans le tableau)
Write-Host $utilisateursComptabilite.Count

# Accéder au premier utilisateur (accès au premier objet du tableau)
Write-Host $utilisateursComptabilite[0].Name
```

### Mission 2.2 — Collections de groupes AD

!!! example "Objectif"
    
    1. Récupérez tous les groupes dont le nom contient `"GG-EU"` dans une variable `$groupesEU`
    2. Affichez leur nombre
    3. Affichez le nom du premier et du dernier groupe du tableau

??? success "Solution"
    
    ```powershell
    $groupesEU = Get-ADGroup -Filter {Name -like "*GG-EU*"}
    
    Write-Host "Groupes trouvés : $($groupesEU.Count)"
    Write-Host "Premier : $($groupesEU[0].Name)"
    Write-Host "Dernier : $($groupesEU[-1].Name)"
    ```

## 3. 🔹 Les boucles : répéter des actions

!!! tip "Concept simple"
    
    Les boucles permettent de répéter une action pour chaque élément d'une collection. C'est comme traiter un dossier de documents un par un.

### La boucle ForEach


```powershell
# Obtenir tous les utilisateurs
$utilisateurs = Get-ADUser -Filter *

# Afficher chaque élément avec une boucle
foreach ($utilisateur in $utilisateurs) {
    Write-Host $utilisateur
}
```

!!! note "Structure des boucles"
    
    Le bloc `{ }` contient les actions à répéter pour chaque élément.

!!! info "Pipeline et ForEach-Object"
    
    Voici une autre version qui utilise le pipeline. Le pipeline (`|`) permet de chaîner des commandes.
    
    Le symbole `$_` représente l'élément actuel dans la boucle.

```powershell
$utilisateurs | ForEach-Object { Write-Host $_ }  
# $_ est juste un alias pour l'élément actuel dans la boucle. On peut en plus accéder aux propriétés de l'élément, par exemple: $_.Name, $_.SamAccountName, $_.Title, etc.
$utilisateurs | ForEach-Object { Write-Host $_.Name }  
```

### Mission 3.1 — Boucle sur les départements

!!! example "Objectif"
    
    Sophie veut un rapport listant combien d'utilisateurs actifs se trouvent dans chaque département. Utilisez le tableau `$departements` de la mission 2.1 :
    
    1. Bouclez sur `$departements`
    2. Pour chaque département, comptez les utilisateurs actifs (`Enabled -eq $true`) filtrés par `Department`
    3. Affichez une ligne par département : `"IT : 5 utilisateurs actifs"`

??? success "Solution"
    
    ```powershell
    $departements = @("RH", "IT", "Ventes", "Comptabilité", "Marketing")
    
    foreach ($dept in $departements) {
        $count = (Get-ADUser -Filter "Department -eq '$dept' -and Enabled -eq 'True'").Count
        Write-Host "$dept : $count utilisateurs actifs"
    }
    ```
    
    Le filtre en chaîne `"Department -eq '$dept' -and Enabled -eq 'True'"` permet d'injecter une variable directement.

### Mission 3.2 — Membres par groupe (pipeline)

!!! example "Objectif"
    
    Sophie veut savoir quels groupes `GG-EU` ont le plus de membres. Utilisez le pipeline :
    
    1. Récupérez tous les groupes dont le nom commence par `"GG-EU"`
    2. Pour chaque groupe, récupérez le nombre de membres avec `Get-ADGroupMember`
    3. Affichez `Nom du groupe — X membre(s)`, trié du plus grand au plus petit
    
    *Indice : `Sort-Object -Descending` et `$_.Members.Count` ou `(Get-ADGroupMember -Identity $_.Name).Count`*

??? success "Solution"
    
    ```powershell
    Get-ADGroup -Filter {Name -like "GG-EU*"} | ForEach-Object {
        $nbMembres = (Get-ADGroupMember -Identity $_.Name).Count
        [PSCustomObject]@{
            Groupe  = $_.Name
            Membres = $nbMembres
        }
    } | Sort-Object Membres -Descending | Format-Table -AutoSize
    ```
    
    `[PSCustomObject]` crée un objet temporaire avec les champs qu'on veut afficher — plus propre que de concaténer des chaînes.

## 4. 🔹 Les conditions : prendre des décisions

Les conditions permettent d'exécuter du code uniquement si certains critères sont remplis. C'est comme suivre un arbre de décision.

### Structure If-Else

Les conditions `if` permettent d'exécuter du code uniquement si une condition est vraie. Voici quelques exemples simples :

```powershell
# Exemple 1: Condition simple
$estActif = $true
if ($estActif) {
    Write-Host "Le compte est actif"
}

# Exemple 2: Condition avec if/else
$nombreUtilisateurs = 5
if ($nombreUtilisateurs -gt 10) {
    Write-Host "Plus de 10 utilisateurs"
} else {
    Write-Host "10 utilisateurs ou moins"
}

# Exemple 3: Vérifier si un utilisateur existe
$nomUtilisateur = "jean.dupont"
if (Get-ADUser -Filter {SamAccountName -eq $nomUtilisateur} -ErrorAction SilentlyContinue) {
    Write-Host "L'utilisateur $nomUtilisateur existe"
} else {
    Write-Host "L'utilisateur $nomUtilisateur n'existe pas"
}

# Exemple 4: Vérifier si une valeur est vide
$description = ""
if ([string]::IsNullOrEmpty($description)) {
    Write-Host "La description est vide"
} else {
    Write-Host "La description contient: $description"
}
```

> Les opérateurs de comparaison courants sont: `-eq` (égal), `-ne` (différent), `-gt` (supérieur), `-lt` (inférieur), `-ge` (supérieur ou égal), `-le` (inférieur ou égal).

### Mission 4.1 — Vérification de compte

!!! example "Objectif"
    
    Récupérez un utilisateur de votre choix et vérifiez :
    
    1. S'il a une adresse email renseignée (`EmailAddress`)
    2. Si son compte est actif ou désactivé (`Enabled`)
    3. Affichez un message différent selon chaque cas
    
    *Si aucun utilisateur n'a d'email dans votre labo, ajoutez-en un manuellement dans la console AD avant de continuer.*

??? success "Solution"
    
    ```powershell
    $user = Get-ADUser -Identity "jean.dupont" -Properties EmailAddress, Enabled
    
    if ([string]::IsNullOrEmpty($user.EmailAddress)) {
        Write-Host "Pas d'email renseigné" -ForegroundColor Yellow
    } else {
        Write-Host "Email : $($user.EmailAddress)" -ForegroundColor Green
    }
    
    if ($user.Enabled) {
        Write-Host "Compte actif"
    } else {
        Write-Host "Compte désactivé" -ForegroundColor Red
    }
    ```

### Conditions multiples

```powershell
# Vérifier le statut d'un utilisateur
$user = Get-ADUser -Identity "Richard" -Properties Enabled, LockedOut

if ($user.Enabled -eq $false) {
    Write-Host "Le compte est désactivé"
} elseif ($user.LockedOut -eq $true) {
    Write-Host "Le compte est verrouillé"
} else {
    Write-Host "Le compte est actif et utilisable"
}
```

### Mission 4.2 — Script de diagnostic utilisateur

!!! example "Objectif"
    
    Écrivez un script qui demande un `SamAccountName` et affiche :
    
    - Compte activé ou désactivé
    - Membre du groupe `GG-EU-IT-Admin` : oui ou non
    - Mot de passe configuré pour ne jamais expirer : oui ou non (`PasswordNeverExpires`)

??? success "Solution"
    
    ```powershell
    $login = Read-Host "SamAccountName"
    $user  = Get-ADUser -Identity $login -Properties Enabled, PasswordNeverExpires
    
    Write-Host "Statut     : $(if ($user.Enabled) {'Actif'} else {'Désactivé'})"
    
    $estAdmin = Get-ADGroupMember -Identity "GG-EU-IT-Admin" |
                    Where-Object { $_.SamAccountName -eq $login }
    Write-Host "IT-Admin   : $(if ($estAdmin) {'Oui'} else {'Non'})"
    
    Write-Host "MDP permanent : $(if ($user.PasswordNeverExpires) {'Oui'} else {'Non'})"
    ```

### Exemple pratique : Rechercher un utilisateur

Voici un exemple de script qui combine variables, conditions et propriétés AD pour rechercher un utilisateur et afficher ses informations. Le script demande à l'utilisateur un SamAccountName et le cherche dans le domaine AD. Si l'utilisateur est trouvé, le script affiche ses informations. Si l'utilisateur appartient au groupe "GG-EU-Ventes-Users", le script affiche un message approprié.

```powershell
# Demander le nom d'utilisateur à rechercher
$nomUtilisateurRecherche = Read-Host "Entrez le SamAccountName de l'utilisateur à rechercher"

# Récupérer l'utilisateur Active Directory
$utilisateurTrouve = Get-ADUser -Filter "SamAccountName -eq '$nomUtilisateurRecherche'" -Properties GivenName, Surname, Title, Department, WhenCreated

# Vérifier si l'utilisateur existe
if ($utilisateurTrouve) {
   
    Write-Host "Utilisateur trouvé !" -ForegroundColor Green
    Write-Host "Prénom           : $($utilisateurTrouve.GivenName)"
    Write-Host "Nom              : $($utilisateurTrouve.Surname)"
    Write-Host "Titre            : $($utilisateurTrouve.Title)"
    Write-Host "Service          : $($utilisateurTrouve.Department)"
    Write-Host "Date de création : $($utilisateurTrouve.WhenCreated)"
    
    # Vérifier si l'utilisateur est membre d'un groupe
    $groupe = "GG-EU-Ventes-Users"
    $membre = Get-ADPrincipalGroupMembership -Identity $utilisateurTrouve | Where-Object { $_.Name -eq $groupe }
    
    if ($membre) {
        Write-Host "L'utilisateur appartient au groupe : $groupe" -ForegroundColor Cyan
    } else {
        Write-Host "L'utilisateur n'appartient PAS au groupe : $groupe" -ForegroundColor Yellow
    }

} else {
    Write-Host "Aucun utilisateur trouvé avec ce nom." -ForegroundColor Red
}
```

!!! warning "Important"
    Modifier les valeurs dans une variable n'a aucun effet sur l'objet réel dans Active Directory. Par exemple, si vous faites `$utilisateurTrouve.Title = "Nouveau Titre"`, cela change uniquement la valeur dans votre variable locale, pas dans AD. Pour modifier réellement un objet AD, vous devez utiliser des commandes spécifiques comme `Set-ADUser` que nous verrons plus tard.

### Mission 4.3 — Enrichir le script de recherche

!!! example "Objectif"
    
    Reprenez l'exemple de script ci-dessus et ajoutez :
    
    1. L'affichage du statut activé/désactivé
    2. Un message différent si l'utilisateur appartient au service `Comptabilité`
    3. Les 3 premiers groupes dont l'utilisateur est membre

??? success "Solution"
    
    ```powershell
    $login = Read-Host "SamAccountName"
    $user  = Get-ADUser -Filter "SamAccountName -eq '$login'" `
                 -Properties GivenName, Surname, Title, Department, WhenCreated, Enabled
    
    if (-not $user) {
        Write-Host "Utilisateur introuvable." -ForegroundColor Red
        return
    }
    
    Write-Host "Prénom    : $($user.GivenName)"
    Write-Host "Nom       : $($user.Surname)"
    Write-Host "Titre     : $($user.Title)"
    Write-Host "Service   : $($user.Department)"
    Write-Host "Créé le   : $($user.WhenCreated)"
    Write-Host "Statut    : $(if ($user.Enabled) {'Actif'} else {'Désactivé'})"
    
    if ($user.Department -eq "Comptabilité") {
        Write-Host "→ Compte Comptabilité : accès aux partages financiers à vérifier." -ForegroundColor Yellow
    }
    
    $groupes = Get-ADPrincipalGroupMembership -Identity $user.SamAccountName |
                   Select-Object -First 3
    Write-Host "Groupes (3 premiers) :"
    $groupes | ForEach-Object { Write-Host "  - $($_.Name)" }
    ```

## 5. 🔹 Mini-projet : Rapport d'audit par OU

### Contexte
Sophie a besoin d'un rapport listant **tous les utilisateurs d'une OU** avec leur statut et leurs groupes principaux. Le script ci-dessous est fonctionnel — lisez-le, exécutez-le, puis améliorez-le avec les missions ci-dessous.

```powershell
# Demander le nom de l'OU à l'utilisateur
$nomOU = Read-Host "Entrez le nom de l'OU à auditer (ex: Ventes, RH...)"

# Construire le chemin de l'OU (adapté au domaine maxtec.be)
# Note: Le chemin exact dépend de votre structure AD
$cheminOU = "OU=Users,OU=$nomOU,OU=EU,DC=maxtec,DC=be"

# Récupérer les utilisateurs de cette OU
$users = Get-ADUser -Filter * -SearchBase $cheminOU -Properties Enabled, MemberOf

# Vérifier si des utilisateurs ont été trouvés
if ($users.Count -eq 0) {
    Write-Host "Aucun utilisateur trouvé dans l'OU $nomOU" -ForegroundColor Yellow
} else {
    # Afficher un en-tête
    Write-Host "=== RAPPORT D'AUDIT : OU $nomOU ===" -ForegroundColor Cyan
    Write-Host "Nombre d'utilisateurs : $($users.Count)" -ForegroundColor Cyan
    Write-Host "----------------------------------------"
    
    # Pour chaque utilisateur
    foreach ($user in $users) {
        # Statut du compte
        $statut = if ($user.Enabled) {"ACTIF"} else {"DÉSACTIVÉ"}
        $couleur = if ($user.Enabled) {"Green"} else {"Red"}
        
        # Afficher les informations de base
        Write-Host "UTILISATEUR : $($user.Name) - $statut" -ForegroundColor $couleur
        
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

### Mission 5.1 — Améliorer le rapport

!!! example "Objectif"
    
    Étendez le script d'audit pour qu'il affiche :
    
    1. La date de dernière connexion (`LastLogonDate`)
    2. Si le mot de passe expire ou non (`PasswordNeverExpires`)
    3. Marquez en rouge les comptes inactifs depuis plus de 30 jours

??? success "Solution"
    
    ```powershell
    $nomOU    = Read-Host "Nom de l'OU (ex: Ventes)"
    $cheminOU = "OU=Users,OU=$nomOU,OU=EU,DC=maxtec,DC=be"
    $limite   = (Get-Date).AddDays(-30)
    
    $users = Get-ADUser -Filter * -SearchBase $cheminOU `
                 -Properties Enabled, MemberOf, LastLogonDate, PasswordNeverExpires
    
    if ($users.Count -eq 0) {
        Write-Host "Aucun utilisateur dans $nomOU" -ForegroundColor Yellow
        return
    }
    
    Write-Host "=== AUDIT : OU $nomOU ($($users.Count) utilisateurs) ===" -ForegroundColor Cyan
    
    foreach ($user in $users) {
        $statut  = if ($user.Enabled) { "ACTIF" } else { "DÉSACTIVÉ" }
        $couleur = if ($user.Enabled) { "Green"  } else { "Red" }
    
        $inactif = $user.LastLogonDate -and $user.LastLogonDate -lt $limite
        if ($inactif) { $couleur = "Red" }
    
        Write-Host "$($user.Name) — $statut$(if ($inactif) {' — INACTIF +30j'})" -ForegroundColor $couleur
        Write-Host "  Dernière connexion : $($user.LastLogonDate)"
        Write-Host "  MDP permanent      : $($user.PasswordNeverExpires)"
    
        $groupes = Get-ADPrincipalGroupMembership -Identity $user.SamAccountName |
                       Select-Object -First 3
        Write-Host "  Groupes : $($groupes.Name -join ', ')"
        Write-Host ""
    }
    ```

### Mission 5.2 — Bilan du Jour 2

Vous savez maintenant combiner variables, tableaux, boucles et conditions pour automatiser des tâches réelles. Le chapitre 9.2 va plus loin sur les **requêtes et filtres**, et 9.3 passe à la **création et modification** d'objets AD.

---

## 🧭 Navigation
[⏮️ Chapitre Précédent: Powershell AD - Introduction](Chapitre%209.0.Powershell%20AD%20-%20Introduction.md) | [🏠 Retour au Syllabus](index.md) | [⏭️ Chapitre Suivant: Powershell AD - Requêtes et Informations](Chapitre%209.2.Powershell%20AD%20-%20Requetes_et_Informations.md)

---

**📚 Cours Active Directory - PowerShell | 👨‍💻 Pour débutants**

