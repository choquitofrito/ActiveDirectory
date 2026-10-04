# Chapitre 9.1: Les concepts de base PowerShell pour Active Directory

## 🧭 Navigation du Cours
[⏮️ Chapitre Précédent: Powershell AD - Introduction](Chapitre%209.0.Powershell%20AD%20-%20Introduction.md) | [🏠 Retour au Syllabus](index.md) | [⏭️ Chapitre Suivant: Powershell AD - Requêtes et Informations](Chapitre%209.2.Powershell%20AD%20-%20Requetes_et_Informations.md)

---

!!! info "Objectifs du chapitre"
    
    À la fin de ce chapitre, vous savez :
    
    - stocker une valeur ou un objet AD dans une variable et lire ses propriétés (`$user.Department`) ;
    - retrouver la liste des propriétés d'un objet avec `Get-Member` ;
    - manipuler un tableau (index, ajout, `.Count`) ;
    - parcourir une collection avec `foreach` et `ForEach-Object` ;
    - écrire des conditions `if / elseif / else` ;
    - protéger un script contre une OU ou un compte inexistant avec `try / catch` ;
    - produire un rapport d'audit par OU.
    
    Si vous venez de bash, relisez d'abord la section [Si vous venez de Linux / bash](Chapitre%209.0.Powershell%20AD%20-%20Introduction.md#6-si-vous-venez-de-linux-bash) du chapitre 9.0.

---

!!! info "Fil rouge : Jour 2 chez Maxtec"
    
    Sophie vous confie une nouvelle tâche : construire un script d'audit réutilisable. Jusqu'ici vous avez tapé des commandes une par une ; aujourd'hui vous allez les enchaîner avec des **variables**, des **tableaux**, des **boucles** et des **conditions**. Chaque mission ci-dessous s'appuie sur la précédente.

---

## 1. 🔹 Les variables

Une variable stocke temporairement une valeur : un texte, un nombre, ou un objet AD complet. Son nom commence toujours par `$`, y compris au moment de l'affectation (contrairement à bash).

```powershell
$nomUtilisateur = "richard"

$nomUtilisateur                  # Afficher : taper simplement le nom suffit
Write-Host $nomUtilisateur       # Affichage à l'écran uniquement (couleurs possibles)
Write-Output $nomUtilisateur     # Envoie la valeur dans le pipeline (alias : echo)
```

### Mission 1.1 — Variable de contexte

!!! example "Objectif"
    
    Les comptes du lab utilisent le prénom seul (`richard`). Pour les futurs arrivants, Maxtec envisage le format `prenom.nom`. Construisez les variables qui permettraient de le générer :
    
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
    
    Write-Host "$prenom $nom - login : $login - email : $email"
    ```
    
    À noter : dans une chaîne entre guillemets `"..."`, PowerShell évalue les variables directement (`"$login@$domaine"`). Pas besoin de concaténation.

### Mission 1.2 — Stocker un résultat AD dans une variable

!!! example "Objectif"
    
    Récupérez le compte de Richard Renard (responsable RH) et explorez ses propriétés via la variable :
    
    1. Stockez le résultat de `Get-ADUser -Identity richard -Properties *` dans `$monCompte`
    2. Affichez le `GivenName`, `Surname`, `Title` et `Department`
    3. Affichez la date de création (`WhenCreated`)
    4. Vérifiez si le compte est activé (`Enabled`)

??? success "Solution"
    
    ```powershell
    $login     = "richard"
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
$utilisateur = Get-ADUser -Identity "richard" -Properties *
$groupe = Get-ADGroup -Identity "CN=GG-EU-RH-Admin,OU=Groups,OU=RH,OU=EU,DC=maxtec,DC=be" -Properties *
```

!!! note "Recherche par identifiant"
    
    Ceci était une recherche par **identifiant**.

!!! tip "Le paramètre -Identity"
    
    Ce paramètre permet de spécifier quel objet AD vous voulez obtenir/modifier. Il accepte plusieurs formats d'identification. Par exemple... si on a le groupe "GG-EU-IT-Users", on peut le trouver de plusieurs manières en utilisant le paramètre -Identity :
    
    - **Nom** : Simplement le nom du groupe (ex: -Identity "GG-EU-IT-Users")
    - **SamAccountName** : L'identifiant unique du groupe dans le domaine (ex: -Identity "GG-EU-IT-Users")
    - **DistinguishedName** : Le chemin complet dans l'AD (ex: -Identity "CN=GG-EU-IT-Users,OU=Groups,OU=IT,OU=EU,DC=maxtec,DC=be")
    - **GUID** : L'identifiant unique global (ex: -Identity "123e4567-e89b-12d3-a456-426614174000")

```powershell
# Maintenant on peut accéder facilement à ses propriétés
# (le script du lab renseigne GivenName, Surname, Department, Title, EmailAddress...)
Write-Host $utilisateur.Surname
Write-Host $utilisateur.GivenName
Write-Host $utilisateur.EmailAddress   # le nom PowerShell est EmailAddress (attribut LDAP : mail)
```

!!! warning "Note sur la langue"
    
    Même si votre interface AD est en français, les noms des propriétés dans PowerShell sont toujours en anglais. Utilisez donc `GivenName` (prénom), `Surname` (nom de famille), `Title` (titre), etc. Ces noms sont standardisés et ne changent pas avec la langue de l'interface.


### Quelles propriétés sont disponibles ?

!!! info "Découvrir les propriétés"
    
    Avant de pouvoir rechercher des informations spécifiques, il est important de connaître les attributs/propriétés disponibles. Ces propriétés sont aussi accessibles dans le menu `Propriétés` > `Editeur d'attributs` dans `Utilisateurs et groupes d'AD` (il faut activer l'option `Fonctionnalités avancées` dans le menu principal de `Utilisateurs et groupes d'AD`)


```powershell
# Un seul utilisateur suffit : tous les comptes ont le même schéma
Get-ADUser richard -Properties * | Get-Member -MemberType Property
```



!!! tip "Recherche avec Filter"
    
    Avec **Filter** on peut rechercher des éléments à partir des valeurs de leurs propriétés. Par **exemple, on peut rechercher des utilisateurs par leur nom, leur titre, leur service** ('department' en anglais. La propriété est dans l'onglet `Organisation` dans les propriétés des utilisateurs), etc.

```powershell
# Exemple 1:  Rechercher les utilisateurs créés après le 1er janvier 2023
# La commande Select-Object permet de filtrer les propriétés d'un objet que l'on souhaite afficher. Dans ce cas, on ne veut afficher que le nom, le nom d'utilisateur et la date de création.
$date = [datetime]'2023-01-01'   # format ISO : indépendant de la langue du système
# Sans Select-Object, PowerShell retourne TOUTES les propriétés disponibles (plus d'une quinzaine), ce qui rend la sortie verbeuse et moins ciblée. Comparez avec l'exemple 2 pour voir la différence.
Get-ADUser -Filter {WhenCreated -ge $date} -Properties WhenCreated


# Exemple 2: Même requête que l'exemple 1, mais avec Select-Object pour filtrer les propriétés
# Ici, on utilise le même filtre de date, mais Select-Object limite l'affichage à Name, SamAccountName et WhenCreated pour une sortie ciblée et efficace.
$date = [datetime]'2023-01-01'
Get-ADUser -Filter {WhenCreated -ge $date} -Properties WhenCreated | Select-Object Name, SamAccountName, WhenCreated

# Exemple 3: Même requête avec Format-Table . Select-Object afficher comme liste s'il y a plus de 4 propriétés. Si on veut un tableau, utilisez Format-Table
$date = [datetime]'2023-01-01'
Get-ADUser -Filter {WhenCreated -ge $date} -Properties WhenCreated | Select-Object Name, SamAccountName, WhenCreated | Format-Table 





```


## 2. 🔹 Les tableaux : collections d'objets

Un tableau est une collection ordonnée d'éléments, chacun accessible par son indice.

### Création d'un tableau simple

```powershell
# Créer un tableau de noms d'utilisateurs (attention à la notation de @ et parenthèses)
$utilisateurs = @("vanessa", "victor", "rebecca")

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
$utilisateurs += "ivan"

# Modifier un élément (remplacer "rebecca" par "rene")
$index = $utilisateurs.IndexOf("rebecca")
if ($index -ge 0) {
    $utilisateurs[$index] = "rene"
}
```

!!! note "Note sur la suppression"
    Pour la suppression, il faut faire attention à la taille fixe du tableau. Nous n'aborderons pas cette opération ici, mais vous pouvez la rechercher dans la documentation PowerShell si nécessaire.


### Mission 2.1 — Tableau des départements

!!! example "Objectif"
    
    Sophie vous demande de préparer la liste des départements de Maxtec EU. Ce tableau servira dans la mission suivante pour boucler automatiquement dessus :
    
    1. Créez `$departements` avec : `RH`, `IT`, `Ventes`, `Comptabilite` (sans accent, comme dans l'AD), `Marketing`
    2. Affichez le premier et le dernier élément
    3. Ajoutez `"Logistique"` au tableau
    4. Affichez le nombre total d'éléments
    5. Vérifiez si `"RH"` est dans la liste (`.Contains()`)

??? success "Solution"
    
    ```powershell
    $departements = @("RH", "IT", "Ventes", "Comptabilite", "Marketing")
    
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
# Récupérer tous les utilisateurs du service Comptabilite : tableau d'objets ADUser
$utilisateursComptabilite = Get-ADUser -Filter "Department -eq 'Comptabilite'"

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

Une boucle répète une action pour chaque élément d'une collection.

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
    $departements = @("RH", "IT", "Ventes", "Comptabilite", "Marketing")
    
    foreach ($dept in $departements) {
        $count = (Get-ADUser -Filter "Department -eq '$dept' -and Enabled -eq 'True'").Count
        Write-Host "$dept : $count utilisateurs actifs"
    }
    ```
    
    Le filtre en chaîne `"Department -eq '$dept' -and Enabled -eq 'True'"` permet d'injecter une variable directement. `Marketing` n'existe pas chez Maxtec : le résultat attendu est `0`, pas une erreur.

### Trier et construire ses propres lignes de résultat

`Sort-Object` trie les objets qui passent dans le pipeline selon une propriété (l'équivalent de `sort` en bash). Par défaut l'ordre est croissant ; `-Descending` l'inverse.

```powershell
# Les utilisateurs du plus récent au plus ancien
Get-ADUser -Filter * -Properties WhenCreated |
    Sort-Object WhenCreated -Descending |
    Format-Table Name, WhenCreated
```

Quand l'information à trier n'existe pas telle quelle dans AD (un nombre de membres, par exemple), on la calcule dans une boucle et on fabrique un objet avec `[PSCustomObject]`. On choisit soi-même les noms des propriétés, et `Sort-Object` ou `Format-Table` peuvent ensuite les utiliser comme n'importe quelle propriété AD.

```powershell
Get-ADUser -Filter * -Properties Department | ForEach-Object {
    [PSCustomObject]@{
        Utilisateur = $_.Name
        Service     = $_.Department
    }
} | Sort-Object Service | Format-Table
```

### Mission 3.2 — Membres par groupe (pipeline)

!!! example "Objectif"
    
    Sophie veut savoir quels groupes `GG-EU` ont le plus de membres. Utilisez le pipeline :
    
    1. Récupérez tous les groupes dont le nom commence par `"GG-EU"`
    2. Pour chaque groupe, récupérez le nombre de membres avec `Get-ADGroupMember`
    3. Affichez `Nom du groupe — X membre(s)`, trié du plus grand au plus petit
    
    *Indice : dans un `ForEach-Object`, comptez les membres avec `(Get-ADGroupMember -Identity $_.Name).Count`, construisez un `[PSCustomObject]` avec le nom et ce nombre, puis triez avec `Sort-Object -Descending`. Autre piste : `$_.Members.Count`, mais `Members` n'est pas renvoyé par défaut, il faut `Get-ADGroup ... -Properties Members`.*

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

### Structure If-Else

Une condition `if` exécute un bloc de code uniquement si une expression est vraie :

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
# -Filter ne lève pas d'erreur si rien n'est trouvé : il renvoie simplement $null
$nomUtilisateur = "richard"
if (Get-ADUser -Filter "SamAccountName -eq '$nomUtilisateur'") {
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
    
    *Tous les comptes créés par le script du lab ont un email. Pour voir l'autre branche, testez aussi avec le compte `Administrator`, qui n'en a pas.*

??? success "Solution"
    
    ```powershell
    $user = Get-ADUser -Identity "cindy" -Properties EmailAddress, Enabled
    
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
    2. Un message différent si l'utilisateur appartient au service `Comptabilite`
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
    
    if ($user.Department -eq "Comptabilite") {
        Write-Host "-> Compte Comptabilité : accès aux partages financiers à vérifier." -ForegroundColor Yellow
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

# Construire le chemin de l'OU (structure du lab maxtec.be)
$cheminOU = "OU=Users,OU=$nomOU,OU=EU,DC=maxtec,DC=be"

# Récupérer les utilisateurs de cette OU
# Si l'OU n'existe pas (faute de frappe, "Compta" au lieu de "Comptabilite"...),
# -SearchBase lève une erreur terminante : on l'attrape avec try/catch.
try {
    $users = Get-ADUser -Filter * -SearchBase $cheminOU -Properties Enabled -ErrorAction Stop
} catch {
    Write-Host "OU introuvable : $cheminOU" -ForegroundColor Red
    return
}

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
    
    try {
        $users = Get-ADUser -Filter * -SearchBase $cheminOU `
                     -Properties Enabled, LastLogonDate, PasswordNeverExpires -ErrorAction Stop
    } catch {
        Write-Host "OU introuvable : $cheminOU" -ForegroundColor Red
        return
    }
    
    if ($users.Count -eq 0) {
        Write-Host "Aucun utilisateur dans $nomOU" -ForegroundColor Yellow
        return
    }
    
    Write-Host "=== AUDIT : OU $nomOU ($($users.Count) utilisateurs) ===" -ForegroundColor Cyan
    
    foreach ($user in $users) {
        $statut  = if ($user.Enabled) { "ACTIF" } else { "DÉSACTIVÉ" }
        $couleur = if ($user.Enabled) { "Green"  } else { "Red" }
    
        # LastLogonDate vaut $null si le compte ne s'est JAMAIS connecté :
        # on traite ce cas à part, sinon il passerait inaperçu.
        if ($null -eq $user.LastLogonDate) {
            $inactif   = $true
            $motif     = ' - JAMAIS CONNECTÉ'
            $derniere  = 'jamais'
        } else {
            $inactif   = $user.LastLogonDate -lt $limite
            $motif     = if ($inactif) { ' - INACTIF +30j' } else { '' }
            $derniere  = $user.LastLogonDate
        }
        if ($inactif) { $couleur = "Red" }
    
        Write-Host "$($user.Name) - $statut$motif" -ForegroundColor $couleur
        Write-Host "  Dernière connexion : $derniere"
        Write-Host "  MDP permanent      : $($user.PasswordNeverExpires)"
    
        $groupes = Get-ADPrincipalGroupMembership -Identity $user.SamAccountName |
                       Select-Object -First 3
        Write-Host "  Groupes : $($groupes.Name -join ', ')"
        Write-Host ""
    }
    ```
    
    !!! warning "Fiabilité de `LastLogonDate`"
        
        `LastLogonDate` est calculé à partir de l'attribut `lastLogonTimestamp`, qui n'est répliqué entre DC qu'avec un décalage volontaire de **9 à 14 jours**. Il suffit pour repérer des comptes inactifs depuis 30, 60 ou 90 jours, pas pour savoir si quelqu'un s'est connecté hier. Dans le lab, la plupart des comptes ne se sont jamais connectés : ils apparaîtront tous en rouge, c'est attendu.

### Mission 5.2 — Bilan du Jour 2

Vous savez maintenant combiner variables, tableaux, boucles et conditions pour automatiser des tâches réelles. Le chapitre 9.2 va plus loin sur les **requêtes et filtres**, et 9.3 passe à la **création et modification** d'objets AD.

---

## 🧭 Navigation
[⏮️ Chapitre Précédent: Powershell AD - Introduction](Chapitre%209.0.Powershell%20AD%20-%20Introduction.md) | [🏠 Retour au Syllabus](index.md) | [⏭️ Chapitre Suivant: Powershell AD - Requêtes et Informations](Chapitre%209.2.Powershell%20AD%20-%20Requetes_et_Informations.md)

---

**📚 Cours Active Directory - PowerShell**

