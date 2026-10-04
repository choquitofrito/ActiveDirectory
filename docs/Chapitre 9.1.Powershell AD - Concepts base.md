# Chapitre 9.1: Les concepts de base PowerShell pour Active Directory

## 🧭 Navigation du Cours
[⏮️ Chapitre Précédent: Powershell AD - Introduction](Chapitre%209.0.Powershell%20AD%20-%20Introduction.md) | [🏠 Retour au Syllabus](index.md) | [⏭️ Chapitre Suivant: Powershell AD - Requêtes et Informations](Chapitre%209.2.Powershell%20AD%20-%20Requetes_et_Informations.md)

---

!!! info "Objectifs du chapitre"
    
    À la fin de ce chapitre, vous savez :
    
    - stocker une valeur ou un objet AD dans une variable et lire ses propriétés (`$user.Department`) ;
    - retrouver la liste des propriétés d'un objet avec `Get-Member` ;
    - distinguer `-Properties` (ce que AD envoie), `Select-Object` (ce que l'on garde) et `Format-Table` (ce que l'on affiche) ;
    - manipuler un tableau (index, ajout, `.Count`) ;
    - parcourir une collection avec `foreach` et `ForEach-Object` ;
    - écrire des conditions `if / elseif / else` ;
    - filtrer avec `-Filter` (sur le DC) ou `Where-Object` (dans la session), et savoir lequel choisir ;
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
    
    Deux façons d'assembler du texte : l'opérateur `+` (pour le login) ou une chaîne entre guillemets doubles, où PowerShell remplace chaque variable par sa valeur (pour l'email : `"$login@$domaine"`).

### Entraînement 1.1 — Variables et texte

Le schéma : **des variables → une chaîne entre guillemets doubles qui les assemble**.

!!! example "Exercices"
    
    1. Avec `$service = "IT"` et `$nb = 3`, affichez `Le service IT compte 3 personnes`.
    2. Avec `$service = "RH"`, construisez dans `$cheminOU` le chemin `OU=Users,OU=RH,OU=EU,DC=maxtec,DC=be` et affichez-le. Changez `$service` en `Ventes` et relancez.
       *Indice : seul le nom du service change, le reste du texte est fixe.*
    3. Avec `$prenom = "Ines"` et `$nom = "Installe"`, construisez un login `iinstalle` : initiale du prénom + nom, en minuscules.
       *Indice : `$prenom.Substring(0,1)` renvoie la première lettre.*

??? success "Solutions"
    
    ```powershell
    # 1.
    $service = "IT"
    $nb      = 3
    Write-Host "Le service $service compte $nb personnes"
    
    # 2. Le même texte sert pour n'importe quel service
    $service  = "RH"
    $cheminOU = "OU=Users,OU=$service,OU=EU,DC=maxtec,DC=be"
    Write-Host $cheminOU
    
    # 3. Initiale + nom, en minuscules
    $prenom = "Ines"
    $nom    = "Installe"
    $login  = ($prenom.Substring(0,1) + $nom).ToLower()
    Write-Host $login     # iinstalle
    ```

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

!!! tip "Le paramètre -Identity"
    
    `-Identity` désigne **un** objet précis. Il accepte plusieurs formats, par exemple pour le groupe `GG-EU-IT-Users` :
    
    - **SamAccountName** : l'identifiant de connexion (`-Identity "GG-EU-IT-Users"`, ou `-Identity richard` pour un utilisateur) ;
    - **DistinguishedName** : le chemin complet dans AD (`-Identity "CN=GG-EU-IT-Users,OU=Groups,OU=IT,OU=EU,DC=maxtec,DC=be"`) ;
    - **GUID** ou **SID** : les identifiants uniques internes de l'objet.
    
    Dans le lab, le nom d'un groupe et son SamAccountName sont identiques : on peut donc écrire simplement son nom.

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

### Entraînement 1.2 — Un objet AD dans une variable

Le schéma : **`$x = Get-AD... -Properties ...` → `$x.Propriete` dans un texte, entre `$( )`**.

!!! example "Exercices"
    
    1. Stockez `cindy` avec son `Title` et son `Department`, puis affichez `Cindy Collard est Comptable (Comptabilite)`.
    2. Stockez le groupe `GG-EU-IT-Users` avec sa date de création (`WhenCreated`), puis affichez `GG-EU-IT-Users, créé le ...`.
    3. Stockez le résultat de `Get-ADDomain` (vu au chapitre 9.0), puis affichez `Domaine maxtec.be (NetBIOS : MAXTEC)`.
       *Indice : les propriétés s'appellent `DNSRoot` et `NetBIOSName`.*

??? success "Solutions"
    
    ```powershell
    # 1. Title et Department ne sont pas renvoyés par défaut : -Properties
    $u = Get-ADUser -Identity cindy -Properties Title, Department
    Write-Host "$($u.Name) $($u.Surname) est $($u.Title) ($($u.Department))"
    
    # 2.
    $g = Get-ADGroup -Identity "GG-EU-IT-Users" -Properties WhenCreated
    Write-Host "$($g.Name), créé le $($g.WhenCreated)"
    
    # 3. Get-ADDomain renvoie déjà ces propriétés
    $d = Get-ADDomain
    Write-Host "Domaine $($d.DNSRoot) (NetBIOS : $($d.NetBIOSName))"
    ```
    
    Pour `cindy`, `Name` vaut `Cindy` (le script du lab utilise le prénom comme nom d'objet) : le nom complet s'obtient avec `Name` + `Surname`, ou `GivenName` + `Surname`.

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

`-Filter` demande au DC de ne renvoyer que les objets dont une propriété remplit une condition : un nom, un titre, un service (`Department`, champ « Service » de l'onglet `Organisation`)... `-Filter *` renvoie tout. Les opérateurs (`-eq`, `-like`, `-and`...) sont détaillés au chapitre 9.2.

La condition s'écrit de préférence **entre guillemets doubles**, avec la valeur entre apostrophes :

```powershell
# Les comptes du service Ventes
Get-ADUser -Filter "Department -eq 'Ventes'"

# Avec une variable : les guillemets doubles remplacent $service par sa valeur
$service = "RH"
Get-ADUser -Filter "Department -eq '$service'"
```

Pour une date, on prépare la valeur dans une variable `[datetime]`. Cette forme entre accolades `{ }` fonctionne aussi avec une variable simple :

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

### Entraînement 1.3 — Demander, garder, afficher

Le schéma : **`-Properties` pour ce qui n'est pas renvoyé par défaut → `Format-Table` pour l'écran, `Select-Object` pour exporter**.

!!! example "Exercices"
    
    1. Affichez en tableau le `Name` et le `Title` des comptes du service `Ventes`.
    2. Cette commande affiche une colonne `EmailAddress` vide. Corrigez-la :
       `Get-ADUser -Filter * | Format-Table Name, EmailAddress`
    3. Exportez `Name`, `SamAccountName` et `Department` des comptes `IT` dans `C:\Scripts\it.csv`.
       *Indice : avant `Export-Csv`, c'est `Select-Object`, jamais `Format-Table`.*

??? success "Solutions"
    
    ```powershell
    # 1. Title n'est pas renvoyé par défaut
    Get-ADUser -Filter "Department -eq 'Ventes'" -Properties Title |
        Format-Table Name, Title
    
    # 2. EmailAddress doit être demandé à AD
    Get-ADUser -Filter * -Properties EmailAddress |
        Format-Table Name, EmailAddress
    
    # 3. Select-Object garde des objets : Export-Csv peut les écrire
    # -NoTypeInformation : pas de ligne technique #TYPE en tête du fichier
    # -Encoding UTF8 : les accents restent lisibles
    Get-ADUser -Filter "Department -eq 'IT'" -Properties Department |
        Select-Object Name, SamAccountName, Department |
        Export-Csv -Path "C:\Scripts\it.csv" -NoTypeInformation -Encoding UTF8
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

Vous pouvez lire, ajouter et modifier un élément d'un tableau :

```powershell
# Obtenir un élément (par exemple, le deuxième utilisateur)
$deuxiemeUtilisateur = $utilisateurs[1]
Write-Host "Deuxième utilisateur : $deuxiemeUtilisateur"

# Ajouter un élément à un tableau existant
$utilisateurs += "ivan"

# Modifier un élément : "rebecca" est à l'indice 2, on la remplace par "rene"
$utilisateurs[2] = "rene"
```

Supprimer un élément d'un tableau n'est pas direct en PowerShell : ce chapitre n'en a pas besoin.

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

### Entraînement 2.1 — Tableaux simples

Le schéma : **`@(...)` pour créer, `[i]` pour lire, `+=` pour ajouter, `.Count` pour compter**.

!!! example "Exercices"
    
    1. Créez `$logins` avec `victor`, `cindy`, `ivan`. Affichez le deuxième élément, puis le nombre d'éléments.
    2. Ajoutez `richard` à `$logins`, puis vérifiez avec `.Contains()` que `rebecca` n'y est pas.
    3. Remplacez `cindy` par `charles` et affichez tout le tableau.
       *Indice : `cindy` est à l'indice 1. On remplace avec `$logins[1] = ...`.*

??? success "Solutions"
    
    ```powershell
    # 1. Les indices commencent à 0 : le deuxième élément est [1]
    $logins = @("victor", "cindy", "ivan")
    $logins[1]
    $logins.Count          # 3
    
    # 2.
    $logins += "richard"
    $logins.Contains("rebecca")   # False
    
    # 3.
    $logins[1] = "charles"
    $logins
    ```

### Tableaux d'objets AD

En PowerShell, les résultats de nombreuses commandes sont automatiquement des tableaux, et la plupart du temps ils contiennent des objets :

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

### Entraînement 2.2 — Tableaux d'objets AD

Le schéma : **`$x = Get-AD... -Filter ...` → `$x.Count`, `$x[0]`, `$x[-1]`**.

!!! example "Exercices"
    
    1. Stockez les comptes du service `IT` dans `$it`. Affichez leur nombre et le `Name` du premier.
    2. Stockez dans `$ousUsers` toutes les OUs qui s'appellent `Users`. Combien y en a-t-il ? Affichez le `DistinguishedName` de la dernière.
    3. Stockez les groupes dont le nom se termine par `-Admin`. Affichez leur nombre et le nom du premier et du dernier.

??? success "Solutions"
    
    ```powershell
    # 1.
    $it = Get-ADUser -Filter "Department -eq 'IT'"
    Write-Host "Comptes IT : $($it.Count), premier : $($it[0].Name)"
    
    # 2. Une OU Users par service
    $ousUsers = Get-ADOrganizationalUnit -Filter "Name -eq 'Users'"
    Write-Host "OUs Users : $($ousUsers.Count)"
    Write-Host $ousUsers[-1].DistinguishedName
    
    # 3.
    $admins = Get-ADGroup -Filter {Name -like "*-Admin"}
    Write-Host "Groupes Admin : $($admins.Count)"
    Write-Host "Premier : $($admins[0].Name) / Dernier : $($admins[-1].Name)"
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
# $_ = l'élément en cours. On lit ses propriétés comme avec une variable : $_.Name, $_.SamAccountName...
$utilisateurs | ForEach-Object { Write-Host $_.Name }
```

!!! tip "ForEach-Object ou Select-Object ?"
    
    - **Extraire une propriété** : `Select-Object`. Le résultat reste des objets, réutilisables (tri, variable, `Export-Csv`).
    - **Agir sur chaque élément** (composer un texte, modifier le compte, calculer) : `ForEach-Object`. `Write-Host` écrit à l'écran et ne laisse rien dans le pipeline.
    
    ```powershell
    $utilisateurs | Select-Object Name                                   # objets : exportables
    $utilisateurs | ForEach-Object { Write-Host "$($_.Name) ($($_.SamAccountName))" }   # texte à l'écran
    ```
    
    `Write-Host $_` seul affiche le DistinguishedName du compte : c'est ainsi qu'un objet AD s'écrit dans un texte.
    
    **Les deux ensemble ?** `Select-Object Name, ...` avant un `ForEach-Object` est inutile : la boucle lit déjà `$_.Name` sur l'objet complet, et on se prive des autres propriétés. En revanche, `Select-Object` pour choisir des **lignes** ou des **valeurs** avant la boucle a du sens :
    
    ```powershell
    # Les 3 comptes les plus récents
    # Sort-Object trie (détaillé plus bas) ; -Descending = du plus récent au plus ancien
    # Select-Object -First 3 : ne garde que les 3 premiers objets (des lignes, pas des colonnes)
    Get-ADUser -Filter * -Properties WhenCreated |
        Sort-Object WhenCreated -Descending |
        Select-Object -First 3 |
        ForEach-Object { Write-Host "$($_.Name) créé le $($_.WhenCreated)" }
    
    # Une ligne par service distinct : ici $_ est le texte du service, pas un utilisateur
    # -ExpandProperty : la valeur seule, sans l'objet ; -Unique : sans doublons
    Get-ADUser -Filter * -Properties Department |
        Select-Object -ExpandProperty Department -Unique |
        ForEach-Object { Write-Host "Service : $_" }
    ```

### Mission 3.1 — Boucle sur les départements

!!! example "Objectif"
    
    Sophie veut un rapport listant combien d'utilisateurs actifs se trouvent dans chaque département. Utilisez le tableau `$departements` de la mission 2.1 :
    
    1. Bouclez sur `$departements`
    2. Pour chaque département, comptez les utilisateurs actifs (`Enabled -eq $true`) filtrés par `Department`
    3. Affichez une ligne par département : `"IT : 3 utilisateurs actifs"`
    
    *Indice : avec une variable, écrivez le filtre comme une chaîne entre guillemets doubles : `"Department -eq '$dept'"`. Pour ajouter une deuxième condition, reliez-la par `-and` : `"Department -eq '$dept' -and Enabled -eq 'True'"`.*

??? success "Solution"
    
    ```powershell
    $departements = @("RH", "IT", "Ventes", "Comptabilite", "Marketing")
    
    foreach ($dept in $departements) {
        $count = (Get-ADUser -Filter "Department -eq '$dept' -and Enabled -eq 'True'").Count
        Write-Host "$dept : $count utilisateurs actifs"
    }
    ```
    
    Le filtre en chaîne `"Department -eq '$dept' -and Enabled -eq 'True'"` permet d'injecter une variable directement. Dans un filtre entre guillemets doubles, la valeur « vrai » s'écrit `'True'` : `$true` y serait remplacé par le texte `True` sans guillemets, ce que le filtre AD n'interprète pas de façon fiable. Dans un filtre en bloc `{ }`, on garde `$true`. `Marketing` n'existe pas chez Maxtec : le résultat attendu est `0`, pas une erreur.

### Entraînement 3.1 — `foreach`

Le schéma : **`foreach ($element in $collection) { ... $element ... }`**. Une action par élément.

!!! example "Exercices"
    
    1. Avec `$logins = @("victor", "cindy", "ivan")`, affichez pour chacun `victor : Commercial` (son `Title`).
       *Indice : dans la boucle, `Get-ADUser -Identity $login -Properties Title`.*
    2. Affichez le nom de chaque groupe dont le nom se termine par `-Users`.
    3. Pour chaque compte du service `RH`, affichez `Bonjour Richard` (avec son `GivenName`).

??? success "Solutions"
    
    ```powershell
    # 1. Une requête AD par login
    $logins = @("victor", "cindy", "ivan")
    foreach ($login in $logins) {
        $u = Get-ADUser -Identity $login -Properties Title
        Write-Host "$login : $($u.Title)"
    }
    
    # 2. La collection vient directement d'une commande AD
    $groupes = Get-ADGroup -Filter {Name -like "*-Users"}
    foreach ($groupe in $groupes) {
        Write-Host $groupe.Name
    }
    
    # 3. GivenName fait partie des propriétés par défaut
    $rh = Get-ADUser -Filter "Department -eq 'RH'"
    foreach ($u in $rh) {
        Write-Host "Bonjour $($u.GivenName)"
    }
    ```

### Trier et construire ses propres lignes de résultat

`Sort-Object` trie les objets qui passent dans le pipeline selon une propriété (l'équivalent de `sort` en bash). Par défaut l'ordre est croissant ; `-Descending` l'inverse.

```powershell
# Les utilisateurs du plus récent au plus ancien
Get-ADUser -Filter * -Properties WhenCreated |
    Sort-Object WhenCreated -Descending |
    Format-Table Name, WhenCreated
```

### Mission 3.2a — Nombre de membres par groupe

!!! example "Objectif"
    
    Sophie veut connaître la taille des groupes `GG-EU`. Pour chaque groupe dont le nom commence par `GG-EU`, affichez une ligne de texte :
    
    ```
    GG-EU-RH-Users : 2 membre(s)
    ```
    
    Étapes :
    
    1. Récupérez les groupes avec `Get-ADGroup -Filter {Name -like "GG-EU*"}`
    2. Envoyez-les dans un `ForEach-Object` : à l'intérieur, `$_` est le groupe en cours
    3. Comptez ses membres : `Get-ADGroupMember -Identity $_.Name` renvoie la liste des membres, et `( ... ).Count` compte les éléments de cette liste
    4. Affichez la ligne avec `Write-Host`
    
    *Indice : stockez le nombre dans une variable (`$nbMembres = ...`) avant le `Write-Host`. La ligne d'affichage reste lisible.*

??? success "Solution"
    
    ```powershell
    # 1. Les groupes dont le nom commence par GG-EU
    Get-ADGroup -Filter {Name -like "GG-EU*"} | ForEach-Object {
    
        # 2. $_ = le groupe en cours de traitement
        # 3. Get-ADGroupMember renvoie la liste de ses membres ; .Count compte les éléments
        $nbMembres = (Get-ADGroupMember -Identity $_.Name).Count
    
        # 4. Une ligne de texte par groupe
        Write-Host "$($_.Name) : $nbMembres membre(s)"
    }
    ```

### Entraînement 3.2a — Même schéma, autres objets

Le schéma est toujours le même : **une collection → `ForEach-Object` → un calcul sur `$_` → une ligne de texte**. Seuls changent les objets parcourus et ce que l'on compte.

!!! example "Exercices"
    
    1. **Utilisateurs par service.** Pour chaque OU située directement sous `OU=EU,DC=maxtec,DC=be`, affichez `RH : 3 utilisateur(s)`.
       *Indice : `Get-ADOrganizationalUnit -Filter * -SearchBase "OU=EU,DC=maxtec,DC=be" -SearchScope OneLevel` donne les OUs situées juste sous EU (`-SearchBase` = où commencer, `-SearchScope OneLevel` = un seul niveau). Ensuite, `Get-ADUser -Filter * -SearchBase $_.DistinguishedName` cherche dans l'OU en cours.*
    2. **Groupes par utilisateur.** Pour chaque utilisateur du service `Ventes`, affichez `Victor : 2 groupe(s)`.
       *Indice : `Get-ADPrincipalGroupMembership -Identity $_.SamAccountName` donne les groupes du compte.*
    3. **Comptes par service, à partir d'un tableau.** Partez de `@("Ventes", "RH", "Comptabilite", "IT")` et affichez `IT : 3 compte(s)` pour chacun.
       *Indice : ici `$_` est un texte, pas un objet AD. Utilisez-le dans un filtre entre guillemets doubles : `-Filter "Department -eq '$_'"`.*

??? success "Solutions"
    
    ```powershell
    # 1. Utilisateurs par service
    Get-ADOrganizationalUnit -Filter * -SearchBase "OU=EU,DC=maxtec,DC=be" -SearchScope OneLevel |
        ForEach-Object {
            # $_ = l'OU en cours ; la recherche descend dans ses sous-OUs (Users...)
            $nb = (Get-ADUser -Filter * -SearchBase $_.DistinguishedName).Count
            Write-Host "$($_.Name) : $nb utilisateur(s)"
        }
    
    # 2. Groupes par utilisateur (-Filter n'a pas besoin de -Properties pour filtrer)
    Get-ADUser -Filter "Department -eq 'Ventes'" | ForEach-Object {
        # $_ = l'utilisateur en cours
        $nb = (Get-ADPrincipalGroupMembership -Identity $_.SamAccountName).Count
        Write-Host "$($_.Name) : $nb groupe(s)"
    }
    
    # 3. Comptes par service, à partir d'un tableau
    @("Ventes", "RH", "Comptabilite", "IT") | ForEach-Object {
        # $_ = le nom du service (du texte)
        $nb = (Get-ADUser -Filter "Department -eq '$_'").Count
        Write-Host "$_ : $nb compte(s)"
    }
    ```
    
    `Get-ADPrincipalGroupMembership` compte aussi `Utilisateurs du domaine`, le groupe par défaut de chaque compte.

### Trier un résultat calculé : `[PSCustomObject]`

Pour voir d'abord les groupes les plus grands, il faudrait trier. Ajouter `| Sort-Object` après la boucle de la mission 3.2a ne trie rien : `Write-Host` écrit directement à l'écran et ne laisse rien dans le pipeline (voir la note « ForEach-Object ou Select-Object ? »). `Sort-Object` ne reçoit aucun objet.

Il faut donc que la boucle **produise des objets** au lieu d'écrire du texte. `[PSCustomObject]@{ ... }` fabrique un objet dont on choisit soi-même les propriétés, sous la forme `Nom = valeur`, une par ligne. `Sort-Object` et `Format-Table` les utilisent ensuite comme n'importe quelle propriété AD.

Exemple avec les utilisateurs et leur nombre de groupes :

```powershell
Get-ADUser -Filter * | ForEach-Object {
    $nbGroupes = (Get-ADPrincipalGroupMembership -Identity $_.SamAccountName).Count

    # Un objet par utilisateur, avec deux propriétés : Utilisateur et Groupes
    [PSCustomObject]@{
        Utilisateur = $_.Name
        Groupes     = $nbGroupes
    }
} | Sort-Object Groupes -Descending | Format-Table      # le | après } reçoit les objets de la boucle
```

```
Utilisateur    Groupes
-----------    -------
Administrateur       6
Richard              2
...
```

Le nombre de groupes n'existe pas dans AD : il est calculé dans la boucle, puis rangé dans l'objet pour pouvoir être trié.

### Mission 3.2b — Groupes triés par taille

!!! example "Objectif"
    
    Reprenez la mission 3.2a, mais affichez un **tableau** `Groupe` / `Membres`, trié du groupe le plus grand au plus petit.
    
    *Indice : remplacez le `Write-Host` par un `[PSCustomObject]` (comme dans l'exemple ci-dessus), puis ajoutez `Sort-Object ... -Descending` après la boucle.*

??? success "Solution"
    
    ```powershell
    Get-ADGroup -Filter {Name -like "GG-EU*"} | ForEach-Object {
        $nbMembres = (Get-ADGroupMember -Identity $_.Name).Count
        [PSCustomObject]@{
            Groupe  = $_.Name
            Membres = $nbMembres
        }
    } | Sort-Object Membres -Descending | Format-Table -AutoSize    # -AutoSize : colonnes ajustées au contenu
    ```
    
    Autre façon de compter : `$_.Members.Count`, à condition d'avoir demandé l'attribut avec `Get-ADGroup ... -Properties Members` (il n'est pas renvoyé par défaut).

### Entraînement 3.2b — Du texte aux objets

Même transformation à chaque fois : **`Write-Host` → `[PSCustomObject]`**, puis `Sort-Object` après la boucle. Repartez de vos solutions de l'entraînement 3.2a.

!!! example "Exercices"
    
    1. **Utilisateurs par service**, en tableau `Service` / `Utilisateurs`, du plus grand au plus petit.
    2. **Groupes par utilisateur** du service `Ventes`, en tableau `Utilisateur` / `Groupes`. Ne gardez que les **2 premiers** après le tri.
       *Indice : `Select-Object -First 2` après `Sort-Object` (voir la note « ForEach-Object ou Select-Object ? »).*
    3. **Comptes par service** à partir du tableau de services, en tableau `Service` / `Comptes`, trié par **nom de service** (ordre alphabétique).

??? success "Solutions"
    
    ```powershell
    # 1. Utilisateurs par service, du plus grand au plus petit
    Get-ADOrganizationalUnit -Filter * -SearchBase "OU=EU,DC=maxtec,DC=be" -SearchScope OneLevel |
        ForEach-Object {
            [PSCustomObject]@{
                Service      = $_.Name
                Utilisateurs = (Get-ADUser -Filter * -SearchBase $_.DistinguishedName).Count
            }
        } | Sort-Object Utilisateurs -Descending | Format-Table -AutoSize
    
    # 2. Les 2 utilisateurs de Ventes qui ont le plus de groupes
    Get-ADUser -Filter "Department -eq 'Ventes'" | ForEach-Object {
        [PSCustomObject]@{
            Utilisateur = $_.Name
            Groupes     = (Get-ADPrincipalGroupMembership -Identity $_.SamAccountName).Count
        }
    } | Sort-Object Groupes -Descending | Select-Object -First 2 | Format-Table -AutoSize
    
    # 3. Comptes par service, ordre alphabétique
    @("Ventes", "RH", "Comptabilite", "IT") | ForEach-Object {
        [PSCustomObject]@{
            Service = $_
            Comptes = (Get-ADUser -Filter "Department -eq '$_'").Count
        }
    } | Sort-Object Service | Format-Table -AutoSize
    ```
    
    Le calcul peut aussi se faire directement dans l'objet (`Comptes = (...).Count`), sans variable intermédiaire. Les deux formes sont correctes.

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
# [string]::IsNullOrEmpty(...) vaut $true si la valeur est vide ("") ou absente ($null)
$description = ""
if ([string]::IsNullOrEmpty($description)) {
    Write-Host "La description est vide"
} else {
    Write-Host "La description contient: $description"
}

# Exemple 5: Mettre le résultat d'un if dans une variable
# La variable reçoit la valeur du bloc choisi : "ACTIF" ou "DÉSACTIVÉ"
$user   = Get-ADUser -Identity "richard"
$statut = if ($user.Enabled) { "ACTIF" } else { "DÉSACTIVÉ" }
Write-Host "richard : $statut"
```

> Les opérateurs de comparaison courants sont: `-eq` (égal), `-ne` (différent), `-gt` (supérieur), `-lt` (inférieur), `-ge` (supérieur ou égal), `-le` (inférieur ou égal).

### Mission 4.1 — Vérification de compte

!!! example "Objectif"
    
    Récupérez un utilisateur de votre choix et vérifiez :
    
    1. S'il a une adresse email renseignée (`EmailAddress`)
    2. Si son compte est actif ou désactivé (`Enabled`)
    3. Affichez un message différent selon chaque cas
    
    *Tous les comptes créés par le script du lab ont un email. Pour voir l'autre branche, testez aussi avec le compte `Administrateur`, qui n'en a pas.*

??? success "Solution"
    
    ```powershell
    $user = Get-ADUser -Identity "cindy" -Properties EmailAddress, Enabled
    
    if ([string]::IsNullOrEmpty($user.EmailAddress)) {
        Write-Host "Pas d'email renseigné" -ForegroundColor Yellow   # -ForegroundColor : couleur du texte
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
$user = Get-ADUser -Identity "richard" -Properties LockedOut   # Enabled est déjà renvoyé par défaut

if ($user.Enabled -eq $false) {
    Write-Host "Le compte est désactivé"
} elseif ($user.LockedOut -eq $true) {
    Write-Host "Le compte est verrouillé"
} else {
    Write-Host "Le compte est actif et utilisable"
}
```

### Entraînement 4.1 — `if / elseif / else`

Le schéma : **récupérer une valeur → la tester → un message par cas**.

!!! example "Exercices"
    
    1. Récupérez `valentin` avec son `Title`. Si le titre commence par `Responsable`, affichez `valentin est responsable`, sinon `valentin est collaborateur`. Testez aussi avec `victor`.
       *Indice : `-like "Responsable*"`.*
    2. Comptez les membres de `GG-EU-RH-Users`. Affichez `vide` s'il y en a 0, `petit groupe` s'il y en a moins de 3, `groupe normal` sinon.
    3. Pour chaque login de `@("richard", "inconnu", "cindy")`, affichez s'il existe ou non dans AD.
       *Indice : boucle `foreach` + le test de l'exemple 3 (`Get-ADUser -Filter "SamAccountName -eq '...'"`).*

??? success "Solutions"
    
    ```powershell
    # 1.
    $login = "valentin"
    $u = Get-ADUser -Identity $login -Properties Title
    if ($u.Title -like "Responsable*") {
        Write-Host "$login est responsable"
    } else {
        Write-Host "$login est collaborateur"
    }
    
    # 2. Trois cas : if / elseif / else
    $nb = (Get-ADGroupMember -Identity "GG-EU-RH-Users").Count
    if ($nb -eq 0) {
        Write-Host "vide"
    } elseif ($nb -lt 3) {
        Write-Host "petit groupe"
    } else {
        Write-Host "groupe normal"
    }
    
    # 3. Boucle + condition. -Filter ne lève pas d'erreur si le compte n'existe pas
    foreach ($login in @("richard", "inconnu", "cindy")) {
        if (Get-ADUser -Filter "SamAccountName -eq '$login'") {
            Write-Host "$login existe"
        } else {
            Write-Host "$login n'existe pas"
        }
    }
    ```

### Filtrer une liste : `Where-Object`

`Where-Object` est un `if` appliqué à chaque objet du pipeline : il laisse passer les objets pour lesquels la condition est vraie et écarte les autres. Dans les accolades, `$_` est l'objet examiné.

```powershell
# Parmi les groupes de richard, ne garder que ceux dont le nom commence par GG-
# Get-ADPrincipalGroupMembership n'a pas de paramètre -Filter : il renvoie TOUS les groupes
# du compte, et c'est Where-Object qui filtre ensuite
Get-ADPrincipalGroupMembership -Identity richard |
    Where-Object { $_.Name -like "GG-*" }
#   ^ $_ = le groupe examiné ; s'il ne commence pas par GG-, il est écarté
```

#### `-Filter` ou `Where-Object` ?

Les deux filtrent, mais pas au même endroit :

| | `-Filter` | `Where-Object` |
|---|---|---|
| Où | Sur le contrôleur de domaine, **avant** l'envoi | Dans votre session, **après** réception |
| Ce qui transite sur le réseau | Seulement les objets qui correspondent | Tous les objets, le filtrage se fait ensuite |
| Disponible | Sur les `Get-AD*` qui ont un paramètre `-Filter` | Après n'importe quelle commande |
| Syntaxe | `-Filter "Department -eq 'IT'"` | `Where-Object { $_.Department -eq 'IT' }` |

Même résultat, deux chemins :

```powershell
# -Filter : le DC cherche et n'envoie que les 3 comptes IT
Get-ADUser -Filter "Department -eq 'IT'"

# Where-Object : le DC envoie TOUS les comptes, PowerShell en garde 3
# -Properties Department est obligatoire : Where-Object ne voit que ce que AD a envoyé
Get-ADUser -Filter * -Properties Department | Where-Object { $_.Department -eq 'IT' }
```

Sur 13 comptes, aucune différence perceptible. Sur 50 000, la seconde forme est beaucoup plus lente.

**Règle :** `-Filter` dès que la commande le propose. `Where-Object` quand ce n'est pas possible :

- la commande n'a pas de `-Filter` : `Get-ADGroupMember`, `Get-ADPrincipalGroupMembership`, un tableau `@(...)` ;
- la condition ne s'exprime pas dans `-Filter` : un calcul comme `(Get-ADGroupMember ...).Count -eq 0`.

### Entraînement — `Where-Object`

Le schéma : **une liste → `Where-Object { condition sur $_ }` → seulement les éléments qui passent**.

!!! example "Exercices"
    
    1. Parmi les groupes de `victor`, gardez ceux dont le nom se termine par `-Users`.
       *Indice : `-like "*-Users"`.*
    2. Parmi les membres de `GG-EU-IT-Users`, gardez uniquement les utilisateurs (pas les groupes ni les ordinateurs).
       *Indice : chaque membre a une propriété `objectClass` qui vaut `user`, `group` ou `computer`.*
    3. Dans le tableau `@("Ventes", "RH", "Logistique")`, gardez les services qui ont au moins un utilisateur.
       *Indice : ici `$_` est un texte. Dans la condition, comptez les comptes avec `(Get-ADUser -Filter "Department -eq '$_'").Count` et comparez à 0.*

??? success "Solutions"
    
    ```powershell
    # 1. Groupes de victor qui se terminent par -Users
    Get-ADPrincipalGroupMembership -Identity victor |
        Where-Object { $_.Name -like "*-Users" }
    
    # 2. Membres de GG-EU-IT-Users qui sont des utilisateurs
    Get-ADGroupMember -Identity "GG-EU-IT-Users" |
        Where-Object { $_.objectClass -eq "user" }
    
    # 3. Services qui ont au moins un utilisateur (Logistique n'en a pas)
    @("Ventes", "RH", "Logistique") |
        Where-Object { (Get-ADUser -Filter "Department -eq '$_'").Count -gt 0 }
    ```

### Entraînement — `-Filter` ou `Where-Object` ?

Pour chaque cas, choisissez l'outil, puis écrivez la commande.

!!! example "Exercices"
    
    1. Les comptes du service `RH`.
    2. Parmi les groupes de `cindy`, ceux dont le nom contient `Compta`.
    3. Réécrivez cette commande pour que le DC fasse le filtrage :
       `Get-ADUser -Filter * -Properties Title | Where-Object { $_.Title -like "Comptable*" }`
    
    *Indice : la question à se poser est « la commande a-t-elle un paramètre `-Filter` ? ».*

??? success "Solutions"
    
    ```powershell
    # 1. Get-ADUser a -Filter : on l'utilise
    Get-ADUser -Filter "Department -eq 'RH'"
    
    # 2. Get-ADPrincipalGroupMembership n'a pas de -Filter : Where-Object
    Get-ADPrincipalGroupMembership -Identity cindy |
        Where-Object { $_.Name -like "*Compta*" }
    
    # 3. La condition passe dans -Filter. -Properties Title ne sert plus qu'à l'affichage.
    Get-ADUser -Filter "Title -like 'Comptable*'" -Properties Title |
        Format-Table Name, Title
    ```
    
    Dans `-Filter`, on écrit le nom de la propriété seul (`Title`). Dans `Where-Object`, on passe par l'objet : `$_.Title`.

### Exemple pratique : Rechercher un utilisateur

Voici un exemple de script qui combine variables, conditions et propriétés AD pour rechercher un utilisateur et afficher ses informations. Le script demande à l'utilisateur un SamAccountName et le cherche dans le domaine AD. Si l'utilisateur est trouvé, le script affiche ses informations. Si l'utilisateur appartient au groupe "GG-EU-Ventes-Users", le script affiche un message approprié.

```powershell
# Demander le nom d'utilisateur à rechercher
$nomUtilisateurRecherche = Read-Host "Entrez le SamAccountName de l'utilisateur à rechercher"

# Récupérer l'utilisateur Active Directory
# GivenName et Surname sont renvoyés par défaut : -Properties ne demande que le reste
$utilisateurTrouve = Get-ADUser -Filter "SamAccountName -eq '$nomUtilisateurRecherche'" -Properties Title, Department, WhenCreated

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
    Modifier les valeurs dans une variable n'a aucun effet sur l'objet réel dans Active Directory. Par exemple, si vous faites `$utilisateurTrouve.Title = "Nouveau Titre"`, cela change uniquement la valeur dans votre variable locale, pas dans AD. Pour modifier réellement un objet AD, vous devez utiliser des commandes spécifiques comme `Set-ADUser`, vue au chapitre 9.3.

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
    $user  = Get-ADUser -Identity $login -Properties PasswordNeverExpires
    
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
    $utilisateurTrouve = Get-ADUser -Filter "SamAccountName -eq '$nomUtilisateurRecherche'" -Properties Title, Department, WhenCreated
    
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

Sophie a besoin d'un rapport listant **tous les utilisateurs d'une OU** avec leur statut et leurs groupes principaux. Vous allez écrire ce script vous-même, étape par étape. Chaque étape réutilise une notion du chapitre. Enregistrez le script dans `C:\Scripts\audit_ou.ps1` et **exécutez-le après chaque étape** : une erreur se corrige plus facilement quand on vient d'ajouter trois lignes que trente.

Résultat attendu pour l'OU `Ventes` :

```
=== RAPPORT D'AUDIT : OU Ventes ===
Nombre d'utilisateurs : 4
----------------------------------------
UTILISATEUR : Vanessa - ACTIF
  Groupes principaux :
    - Utilisateurs du domaine
    - GG-EU-Ventes-Users
----------------------------------------
UTILISATEUR : Valeria - ACTIF
...
```

### Mission 5.0 — Écrire le rapport d'audit

!!! example "Étapes"
    
    **1. Demander l'OU.** Stockez la réponse dans `$nomOU` avec `Read-Host`, comme dans l'exemple « Rechercher un utilisateur ».
    
    **2. Construire le chemin de l'OU.** Les utilisateurs de chaque service sont dans la sous-OU `Users`. Construisez dans `$cheminOU` le texte `OU=Users,OU=<service>,OU=EU,DC=maxtec,DC=be`, où `<service>` est la valeur de `$nomOU` (voir l'entraînement 1.1, exercice 2).
    
    **3. Récupérer les utilisateurs de cette OU.** `Get-ADUser -Filter * -SearchBase $cheminOU` renvoie tous les comptes situés dans cette OU. Stockez le résultat dans `$users`. `Enabled` fait partie des propriétés par défaut : pas besoin de `-Properties`.
    
    **4. Se protéger d'une OU qui n'existe pas.** Si l'utilisateur tape `Compta` au lieu de `Comptabilite`, l'OU n'existe pas et `Get-ADUser` affiche une erreur rouge. On l'attrape avec `try / catch` :
    
    - mettez la commande de l'étape 3 dans un bloc `try { ... }` et ajoutez-lui `-ErrorAction Stop` (sans lui, `catch` ne voit pas l'erreur) ;
    - juste après, un bloc `catch { ... }` contient ce qui doit se passer en cas d'erreur : un message `OU introuvable : ...` en rouge ;
    - terminez le `catch` par `return`, qui arrête le script : sans utilisateurs, la suite n'a pas de sens.
    
    Testez avec `Compta` : vous devez voir votre message, pas l'erreur de PowerShell.
    
    **5. Gérer une OU vide.** Si `$users.Count` vaut `0`, affichez `Aucun utilisateur trouvé dans l'OU ...` en jaune, puis `return`.
    
    **6. Afficher l'en-tête.** Trois lignes : le titre `=== RAPPORT D'AUDIT : OU ... ===`, le nombre d'utilisateurs (`$users.Count`), puis une ligne de tirets.
    
    **7. Une boucle sur les utilisateurs.** `foreach ($user in $users) { ... }`. Dans la boucle, pour chaque `$user` :
    
    - **a.** Calculez `$statut` : `ACTIF` si `$user.Enabled` est vrai, `DÉSACTIVÉ` sinon. Calculez de la même façon `$couleur` : `Green` ou `Red` (voir l'exemple 5 de la section 4 : le résultat d'un `if` dans une variable).
    - **b.** Affichez `UTILISATEUR : <nom> - <statut>` avec `-ForegroundColor $couleur`.
    - **c.** Récupérez les 3 premiers groupes du compte : `Get-ADPrincipalGroupMembership -Identity $user.SamAccountName`, suivi de `| Select-Object -First 3`. Stockez-les dans `$groupes`.
    - **d.** Affichez `  Groupes principaux :`, puis une **deuxième boucle** `foreach ($groupe in $groupes)` qui affiche `    - <nom du groupe>`.
    - **e.** Terminez par une ligne de tirets pour séparer les utilisateurs.
    
    Testez avec `Ventes`, `RH`, puis `Compta`.

??? success "Solution"
    
    ```powershell
    # 1. Demander l'OU
    $nomOU = Read-Host "Entrez le nom de l'OU à auditer (ex: Ventes, RH...)"
    
    # 2. Construire le chemin de l'OU (structure du lab maxtec.be)
    $cheminOU = "OU=Users,OU=$nomOU,OU=EU,DC=maxtec,DC=be"
    
    # 3 + 4. Récupérer les utilisateurs, en se protégeant d'une OU inexistante
    try {
        # -ErrorAction Stop : sans lui, l'erreur s'affiche mais catch ne la voit pas
        $users = Get-ADUser -Filter * -SearchBase $cheminOU -ErrorAction Stop
    } catch {
        Write-Host "OU introuvable : $cheminOU" -ForegroundColor Red
        return    # arrête le script
    }
    
    # 5. OU vide
    if ($users.Count -eq 0) {
        Write-Host "Aucun utilisateur trouvé dans l'OU $nomOU" -ForegroundColor Yellow
        return
    }
    
    # 6. En-tête
    Write-Host "=== RAPPORT D'AUDIT : OU $nomOU ===" -ForegroundColor Cyan
    Write-Host "Nombre d'utilisateurs : $($users.Count)" -ForegroundColor Cyan
    Write-Host "----------------------------------------"
    
    # 7. Une boucle sur les utilisateurs
    foreach ($user in $users) {
        # a. Statut et couleur
        $statut  = if ($user.Enabled) { "ACTIF" } else { "DÉSACTIVÉ" }
        $couleur = if ($user.Enabled) { "Green" } else { "Red" }
    
        # b. Ligne de l'utilisateur
        Write-Host "UTILISATEUR : $($user.Name) - $statut" -ForegroundColor $couleur
    
        # c. Les 3 premiers groupes
        $groupes = Get-ADPrincipalGroupMembership -Identity $user.SamAccountName |
                       Select-Object -First 3
    
        # d. Deuxième boucle : un groupe par ligne
        Write-Host "  Groupes principaux :"
        foreach ($groupe in $groupes) {
            Write-Host "    - $($groupe.Name)"
        }
    
        # e. Séparateur
        Write-Host "----------------------------------------"
    }
    ```

!!! tip "Couper une longue commande"
    
    À partir d'ici, certaines solutions coupent une commande trop longue avec un **accent grave** (`` ` ``, AltGr+7 sur un clavier AZERTY) en fin de ligne : la commande continue sur la ligne suivante. Rien ne doit suivre l'accent grave, pas même un espace, sinon la coupure ne fonctionne plus. Après un `|`, pas besoin d'accent grave : PowerShell attend naturellement la suite.

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
                     -Properties LastLogonDate, PasswordNeverExpires -ErrorAction Stop
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
        $couleur = if ($user.Enabled) { "Green" } else { "Red" }
    
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

### Bilan du Jour 2

Vous savez maintenant combiner variables, tableaux, boucles et conditions pour automatiser des tâches réelles. Le chapitre 9.2 va plus loin sur les **requêtes et filtres**, et 9.3 passe à la **création et modification** d'objets AD.

---

## 🧭 Navigation
[⏮️ Chapitre Précédent: Powershell AD - Introduction](Chapitre%209.0.Powershell%20AD%20-%20Introduction.md) | [🏠 Retour au Syllabus](index.md) | [⏭️ Chapitre Suivant: Powershell AD - Requêtes et Informations](Chapitre%209.2.Powershell%20AD%20-%20Requetes_et_Informations.md)

---

**📚 Cours Active Directory - PowerShell**

