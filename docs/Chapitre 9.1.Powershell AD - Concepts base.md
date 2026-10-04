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

# Entre guillemets doubles, une variable est remplacée par sa valeur
$message = "Bonjour $nomUtilisateur"   # Bonjour richard
```

### Mission 1.1 — Variable de contexte

!!! example "Objectif"
    
    Les comptes du lab utilisent le prénom seul (`richard`). Pour les futurs arrivants, Maxtec envisage le format `prenom.nom`. Construisez les variables qui permettraient de le générer :
    
    1. Stockez `"maxtec.be"` dans `$domaine`
    2. Créez `$prenom` et `$nom` avec votre propre prénom/nom
    3. Déduisez `$login` au format `prenom.nom` en minuscules
    4. Déduisez `$email` au format `login@maxtec.be`
    5. Affichez un résumé : nom complet, login, email
    
    *Indice : `"$prenom.$nom"` donne `Jean.Dupont`. `.ToLower()` convertit une chaîne en minuscules : `("$prenom.$nom").ToLower()`.*

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

### Variables et commandes AD

!!! info "Utilisation pratique"
    
    Les variables sont particulièrement utiles pour stocker les résultats de vos commandes AD :

```powershell
# Stocker un utilisateur dans une variable avec toutes ses propriétés
# -Properties * demande à AD tous les attributs : la variable les contient tous.
# Select-Object ne conviendrait pas : il ne va rien chercher dans AD et retire les propriétés non choisies.
# (Voir plus bas : « -Properties, Select-Object, Format-Table : qui fait quoi ? »)
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


### Mission 1.2 — Stocker un résultat AD dans une variable

!!! example "Objectif"
    
    Récupérez le compte de Richard Renard (responsable RH) et explorez ses propriétés via la variable :
    
    1. Stockez le résultat de `Get-ADUser -Identity richard -Properties *` dans `$monCompte`
    2. Affichez le `GivenName`, `Surname`, `Title` et `Department`
    3. Affichez la date de création (`WhenCreated`)
    4. Vérifiez si le compte est activé (`Enabled`)
    
    *Indice : dans un texte entre guillemets, une propriété s'écrit entre `$( )`.*
    
    ```powershell
    Write-Host "Prénom : $($monCompte.GivenName)"   # Prénom : Richard
    Write-Host "Prénom : $monCompte.GivenName"      # Prénom : CN=Richard Renard,OU=...,DC=be.GivenName
    ```

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

### Quelles propriétés sont disponibles ?

!!! info "Découvrir les propriétés"
    
    Avant de pouvoir rechercher des informations spécifiques, il est important de connaître les attributs/propriétés disponibles. Ces propriétés sont aussi accessibles dans le menu `Propriétés` > `Éditeur d'attributs` dans `Utilisateurs et ordinateurs Active Directory` (il faut activer `Affichage` > `Fonctionnalités avancées`).

En PowerShell, la commande **`Get-Member`** liste ce que contient un objet : ses propriétés (les données, comme `GivenName`) et ses méthodes (les actions). On lui passe l'objet par le pipeline. `-MemberType Property` ne garde que les propriétés.

```powershell
# Un seul utilisateur suffit : tous les comptes ont le même schéma
Get-ADUser richard -Properties * | Get-Member -MemberType Property
```

Sans `-Properties *`, `Get-Member` ne liste que la dizaine de propriétés renvoyées par défaut : il décrit l'objet reçu, pas tout ce qui existe dans AD.



### `-Properties`, `Select-Object`, `Format-Table` : qui fait quoi ?

Ces trois éléments se ressemblent (on leur donne tous des noms de propriétés), mais ils interviennent à trois moments différents :

| Étape | Outil | Où ça se passe | Rôle | Exemple |
|-------|-------|----------------|------|---------|
| 1. Demander | `-Properties` | Sur le contrôleur de domaine | Choisir les attributs que AD **envoie** | `Get-ADUser richard -Properties Department` |
| 2. Garder | `Select-Object` | Dans votre session PowerShell | Choisir les propriétés que l'on **conserve** (on a toujours des objets) | `Select-Object Name, Department` |
| 3. Afficher | `Format-Table` / `Format-List` | À l'écran | Choisir la **mise en page** (colonnes ou liste) | `Format-List` |

Les trois étapes s'enchaînent dans cet ordre : `Get-ADUser richard -Properties Department | Select-Object Name, Department | Format-List`.

**Étape 1 : `-Properties` ajoute des attributs à ce que AD renvoie** (il ne remplace pas le jeu par défaut). Par défaut, `Get-ADUser` ne renvoie qu'une dizaine de propriétés : `DistinguishedName`, `Enabled`, `GivenName`, `Name`, `ObjectClass`, `ObjectGUID`, `SamAccountName`, `SID`, `Surname`, `UserPrincipalName`. Tout le reste (`Department`, `Title`, `WhenCreated`, `LastLogonDate`...) doit être demandé.

**Étape 2 : `Select-Object` ne fait que choisir parmi ce qui est déjà arrivé.** Il ne peut pas aller chercher dans AD un attribut qui n'a pas été demandé : il crée la colonne, mais elle reste vide.

```powershell
# ❌ La colonne Department est vide : AD ne l'a pas envoyée
Get-ADUser richard | Select-Object Name, Department

# Department est ajouté aux ~10 propriétés par défaut : la sortie est longue
Get-ADUser richard -Properties Department

# ✅ On demande Department à AD, puis on ne garde que ce qui nous intéresse
Get-ADUser richard -Properties Department | Select-Object Name, Department
```

**Étape 3 : l'affichage en tableau ou en liste.** Quand aucune mise en page n'est imposée, PowerShell choisit seul :

- certains types d'objets ont une présentation prévue par Microsoft (`Get-Process`, `Get-Service` s'affichent en tableau) ;
- les objets AD n'en ont pas. PowerShell compte alors les propriétés : **4 ou moins → tableau, 5 ou plus → liste**.

C'est pour cela que `Get-ADUser` seul s'affiche en liste (10 propriétés), et que la dernière commande ci-dessus s'affiche en tableau (2 propriétés). `Format-Table` et `Format-List` servent à imposer la mise en page quand le choix automatique ne convient pas :

```powershell
# 5 propriétés : PowerShell choisirait une liste. Format-Table force le tableau.
# Avec des noms de propriétés, Format-Table choisit et met en page en une seule étape.
Get-ADUser -Filter * -Properties Department, Title |
    Format-Table Name, SamAccountName, Department, Title, Enabled
```

!!! warning "Format-* toujours en dernier"
    
    Après `Format-Table` ou `Format-List`, il ne reste que de la mise en page, plus des objets. Pour exporter ou trier, utilisez `Select-Object`, jamais `Format-*` avant `Export-Csv`.

!!! tip "Évitez `-Properties *` sur beaucoup de comptes"
    
    `-Properties *` demande au DC tous les attributs de chaque objet. Pratique pour explorer **un** compte (comme `richard` ci-dessus), lent sur tout l'annuaire. Pour une requête large, nommez les attributs dont vous avez besoin.

### Recherche avec `-Filter`

!!! tip "Recherche avec Filter"
    
    Avec **Filter** on peut rechercher des éléments à partir des valeurs de leurs propriétés. Par **exemple, on peut rechercher des utilisateurs par leur nom, leur titre, leur service** ('department' en anglais. La propriété est dans l'onglet `Organisation` dans les propriétés des utilisateurs), etc.

```powershell
# Rechercher les utilisateurs créés après le 1er janvier 2023
$date = [datetime]'2023-01-01'   # format ISO : indépendant de la langue du système

# Exemple 1 : WhenCreated ne fait pas partie des propriétés par défaut, on la demande avec -Properties.
# Résultat : les ~10 propriétés par défaut + WhenCreated, affichées en liste.
Get-ADUser -Filter {WhenCreated -ge $date} -Properties WhenCreated

# Exemple 2 : Select-Object ne garde que 3 propriétés. 4 ou moins : affichage en tableau.
Get-ADUser -Filter {WhenCreated -ge $date} -Properties WhenCreated |
    Select-Object Name, SamAccountName, WhenCreated
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
    
    $departements[0]
    $departements[-1]
    
    $departements += "Logistique"
    
    $departements.Count
    
    $departements.Contains("RH")   # True ou False
    ```
    
    `[0]` = premier élément, `[-1]` = dernier.



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
    
    *Indice : pour une recherche partielle, `-Filter {Name -like "*GG-EU*"}`. `*` remplace n'importe quelle suite de caractères, comme dans l'Explorateur Windows. `-like` est détaillé au chapitre 9.2.*

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
    
    *Indice : avec une variable, écrivez le filtre comme une chaîne entre guillemets doubles : `"Department -eq '$dept'"`. Pour ajouter une deuxième condition, reliez-la par `-and` : `"Department -eq '$dept' -and Enabled -eq 'True'"`.*

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

### Mission 4.2 — Script de diagnostic utilisateur

!!! example "Objectif"
    
    Écrivez un script qui demande un `SamAccountName` et affiche :
    
    - Compte activé ou désactivé
    - Membre du groupe `GG-EU-IT-Admin` : oui ou non
    - Mot de passe configuré pour ne jamais expirer : oui ou non (`PasswordNeverExpires`)
    
    *Indice : même méthode que l'exemple ci-dessus. `Read-Host` pour la saisie ; `Get-ADPrincipalGroupMembership -Identity $login | Where-Object { $_.Name -eq "GG-EU-IT-Admin" }` renvoie le groupe si l'utilisateur en est membre, rien sinon : mettez le résultat dans une variable et testez-la avec `if`.*

??? success "Solution"
    
    ```powershell
    $login = Read-Host "SamAccountName"
    $user  = Get-ADUser -Identity $login -Properties Enabled, PasswordNeverExpires
    
    if ($user.Enabled) {
        Write-Host "Statut        : Actif"
    } else {
        Write-Host "Statut        : Désactivé"
    }
    
    $estAdmin = Get-ADPrincipalGroupMembership -Identity $login |
                    Where-Object { $_.Name -eq "GG-EU-IT-Admin" }
    if ($estAdmin) {
        Write-Host "IT-Admin      : Oui"
    } else {
        Write-Host "IT-Admin      : Non"
    }
    
    if ($user.PasswordNeverExpires) {
        Write-Host "MDP permanent : Oui"
    } else {
        Write-Host "MDP permanent : Non"
    }
    ```

### Mission 4.3 — Enrichir le script de recherche

!!! example "Objectif"
    
    Reprenez l'exemple de script ci-dessus et ajoutez :
    
    1. L'affichage du statut activé/désactivé
    2. Un message différent si l'utilisateur appartient au service `Comptabilite`
    3. Les 3 premiers groupes dont l'utilisateur est membre
    
    *Indice : `... | Select-Object -First 3` ne garde que les 3 premiers objets (l'équivalent de `head -3`).*

??? success "Solution"
    
    ```powershell
    $nomUtilisateurRecherche = Read-Host "Entrez le SamAccountName de l'utilisateur à rechercher"
    $utilisateurTrouve = Get-ADUser -Filter "SamAccountName -eq '$nomUtilisateurRecherche'" -Properties GivenName, Surname, Title, Department, WhenCreated, Enabled
    
    if ($utilisateurTrouve) {
        Write-Host "Utilisateur trouvé !" -ForegroundColor Green
        Write-Host "Prénom           : $($utilisateurTrouve.GivenName)"
        Write-Host "Nom              : $($utilisateurTrouve.Surname)"
        Write-Host "Titre            : $($utilisateurTrouve.Title)"
        Write-Host "Service          : $($utilisateurTrouve.Department)"
        Write-Host "Date de création : $($utilisateurTrouve.WhenCreated)"
    
        # 1. Statut
        if ($utilisateurTrouve.Enabled) {
            Write-Host "Statut           : Actif" -ForegroundColor Green
        } else {
            Write-Host "Statut           : Désactivé" -ForegroundColor Red
        }
    
        # 2. Message pour la Comptabilité
        if ($utilisateurTrouve.Department -eq "Comptabilite") {
            Write-Host "Compte Comptabilité : accès aux partages financiers à vérifier." -ForegroundColor Yellow
        }
    
        # 3. Les 3 premiers groupes
        $groupes = Get-ADPrincipalGroupMembership -Identity $utilisateurTrouve | Select-Object -First 3
        Write-Host "Groupes (3 premiers) :"
        foreach ($groupe in $groupes) {
            Write-Host "  - $($groupe.Name)"
        }
    } else {
        Write-Host "Aucun utilisateur trouvé avec ce nom." -ForegroundColor Red
    }
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
    
    *Indice : `$limite = (Get-Date).AddDays(-30)` donne la date d'il y a 30 jours, et `$user.LastLogonDate -lt $limite` compare deux dates. Attention : un compte qui ne s'est jamais connecté a un `LastLogonDate` vide (`$null`). Testez ce cas en premier avec `if ($null -eq $user.LastLogonDate)` : il compte aussi comme inactif.*

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
        # on traite ce cas en premier, sinon il passerait inaperçu.
        if ($null -eq $user.LastLogonDate) {
            $couleur  = "Red"
            $derniere = "jamais"
        } elseif ($user.LastLogonDate -lt $limite) {
            $couleur  = "Red"
            $derniere = $user.LastLogonDate
        } else {
            $derniere = $user.LastLogonDate
        }
    
        Write-Host "$($user.Name) - $statut" -ForegroundColor $couleur
        Write-Host "  Dernière connexion : $derniere"
        Write-Host "  MDP permanent      : $($user.PasswordNeverExpires)"
    
        $groupes = Get-ADPrincipalGroupMembership -Identity $user.SamAccountName |
                       Select-Object -First 3
        Write-Host "  Groupes principaux :"
        foreach ($groupe in $groupes) {
            Write-Host "    - $($groupe.Name)"
        }
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

