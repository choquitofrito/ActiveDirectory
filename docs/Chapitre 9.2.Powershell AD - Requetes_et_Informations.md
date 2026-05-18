# Chapitre 9.2: Atelier pratique : Requêtes et informations

## 🧭 Navigation du Cours
[⏮️ Chapitre Précédent: Powershell AD - Concepts base](Chapitre%209.1.Powershell%20AD%20-%20Concepts%20base.md) | [🏠 Retour au Syllabus](index.md) | [⏭️ Chapitre Suivant: Powershell AD - Création et Modification](Chapitre%209.3.Powershell%20AD%20-%20Creation_et_Modification.md)

---

!!! info "📚 Dans ce chapitre"
    
    Apprenez à extraire et analyser les informations de votre Active Directory avec PowerShell.

---

!!! info "Fil rouge : Jour 3 chez Maxtec"
    
    Sophie vous confie l'audit de sécurité hebdomadaire. Il s'agit d'un ensemble de requêtes qu'on exécuterait chaque lundi matin pour détecter des anomalies. Vous allez construire ces requêtes une par une en utilisant les filtres présentés dans ce chapitre.

---

## 1. 🔹 Obtenir des informations sur les utilisateurs

Les commandes PowerShell permettent d'extraire rapidement des informations sur les utilisateurs avec différents niveaux de détail.

### Découvrir les attributs disponibles

!!! info "Découvrir les propriétés"
    
    Avant de pouvoir rechercher des informations spécifiques, il est important de connaître les propriétés disponibles. Ces propriétés sont disponibles dans l'interface graphique via le menu `Propriétés` > `Editeur d'attributs` dans `Utilisateurs et groupes d'AD` (il faut d'abord activer l'option `Fonctionnalités avancées` dans le menu principal de `Utilisateurs et groupes d'AD`).



### Commandes de base

### Les filtres les plus courants dans PowerShell AD

Voici les opérateurs de filtre les plus utilisés avec les commandes PowerShell pour Active Directory (`-Filter`), notamment pour `Get-ADUser`, `Get-ADGroup`, etc. :

| Opérateur | Signification | Exemple d'utilisation |
|-----------|--------------|----------------------|
| `-eq`     | Égal à       | `{Department -eq "Comptabilité"}` |
| `-ne`     | Différent de | `{Enabled -ne $true}` |
| `-like`   | Correspondance avec joker (`*` ou `?`) | `{Name -like "Mar*"} ` |
| `-notlike`| Ne correspond pas au motif | `{Name -notlike "*test*"}` |
| `-gt`     | Supérieur à  | `{WhenCreated -gt $date}` |
| `-ge`     | Supérieur ou égal à | `{WhenCreated -ge $date}` |
| `-lt`     | Inférieur à  | `{PasswordLastSet -lt $date}` |
| `-le`     | Inférieur ou égal à | `{PasswordLastSet -le $date}` |
| `-and`    | ET logique   | `{Enabled -eq $true -and Department -eq "RH"}` |
| `-or`     | OU logique   | `{Department -eq "RH" -or Department -eq "Comptabilité"}` |
| `-not`    | Négation     | `{ -not (Enabled -eq $true) }` |

!!! tip "Astuce"
    - L'opérateur `-like` est très utile pour les recherches partielles avec des jokers (`*` pour plusieurs caractères, `?` pour un seul).
    - Les dates doivent être comparées avec des variables de type `[datetime]` (voir exemples plus bas).
    - Les filtres sont sensibles à la casse des propriétés, mais pas des valeurs.

**Exemples rapides :**


```powershell
# Lister tous les utilisateurs (limité aux 10 premiers pour l'exemple)
Get-ADUser -Filter * -ResultSetSize 10

# Obtenir un utilisateur spécifique par son SamAccountName
Get-ADUser -Filter {SamAccountName -eq "victor"}

# Obtenir les utilisateurs dont le nom commence par V (il faut que le nom soit rempli!!)
Get-ADUser -Filter {Name -like "V*"}

# Obtenir un utilisateur avec des propriétés spécifiques
# La propriété 'Department' en PowerShell correspond au champ 'Service' dans l'interface française d'AD
Get-ADUser -Filter {SamAccountName -eq "victor"} -Properties DisplayName, EmailAddress, Department
```

### Exemple pratique : Recherche avancée d'utilisateurs

Changez à la main le pays de quelques utilisateurs vers la Belgique.


```powershell
# Trouver tous les utilisateurs de la Belgique 
Get-ADUser -Filter {Country -eq "BE"} -Properties Country | 
    Format-Table Name, SamAccountName, Country
```

!!! note "Formatage des résultats"
    
    Format-Table permet de formatter les résultats de manière lisible, c'est juste une option


# Trouver les utilisateurs actifs

```powershell
Get-ADUser -Filter {Enabled -eq $true} | Format-Table Name
```

# Filtre avec AND : utilisateurs belges ET du service Ventes

```powershell
# Note: Dans PowerShell, la propriété s'appelle 'Department' (en anglais)
# mais dans l'interface française d'AD, ce champ s'appelle 'Service'
Get-ADUser -Filter {Country -eq "B" -and Department -eq "Ventes"} -Properties Country,Department |
    Format-Table Name, SamAccountName, Country, Department
```

### Mission 1.1 — Recherches de base

!!! example "Objectif"
    
    Construisez les trois requêtes suivantes. Pour chacune, affichez uniquement `Name` et `SamAccountName` en tableau :
    
    1. Tous les utilisateurs dont le nom contient `"va"` (filtre `-like`)
    2. Tous les utilisateurs du département `"IT"` (filtre `-eq` sur `Department`)
    3. Tous les utilisateurs **actifs** créés **après le 1er janvier 2024**

??? success "Solution"
    
    ```powershell
    # 1. Nom contenant "va"
    Get-ADUser -Filter {Name -like "*va*"} |
        Format-Table Name, SamAccountName
    
    # 2. Département IT
    Get-ADUser -Filter {Department -eq "IT"} -Properties Department |
        Format-Table Name, SamAccountName
    
    # 3. Actifs créés après le 1er janvier 2024
    $depuis = Get-Date "2024-01-01"
    Get-ADUser -Filter {Enabled -eq $true -and WhenCreated -ge $depuis} `
               -Properties WhenCreated |
        Select-Object Name, SamAccountName, WhenCreated |
        Format-Table
    ```

### Mission 1.2 — Audit : comptes à risque

!!! example "Objectif"
    
    Sophie veut identifier les comptes potentiellement problématiques. Trouvez :
    
    1. Les utilisateurs **désactivés** qui sont encore membres d'un groupe `GG-EU`
    2. Les utilisateurs actifs dont le **mot de passe n'a pas changé depuis 90 jours** (`PasswordLastSet`)
    3. Les utilisateurs sans adresse email (`EmailAddress` vide ou null)
    
    *Pour (2) : `(Get-Date).AddDays(-90)` donne la date limite.*

??? success "Solution"
    
    ```powershell
    # 1. Désactivés membres d'un groupe GG-EU
    Get-ADUser -Filter {Enabled -eq $false} | ForEach-Object {
        $groupes = Get-ADPrincipalGroupMembership -Identity $_.SamAccountName |
                       Where-Object { $_.Name -like "GG-EU*" }
        if ($groupes) {
            Write-Host "$($_.Name) — désactivé mais membre de : $($groupes.Name -join ', ')" -ForegroundColor Yellow
        }
    }
    
    # 2. Mot de passe non changé depuis 90 jours
    $limite = (Get-Date).AddDays(-90)
    Get-ADUser -Filter {Enabled -eq $true -and PasswordLastSet -lt $limite} `
               -Properties PasswordLastSet |
        Select-Object Name, SamAccountName, PasswordLastSet |
        Sort-Object PasswordLastSet | Format-Table
    
    # 3. Sans email
    Get-ADUser -Filter {Enabled -eq $true} -Properties EmailAddress |
        Where-Object { [string]::IsNullOrEmpty($_.EmailAddress) } |
        Format-Table Name, SamAccountName
    ```


## 2. 🔹 Obtenir des informations sur les groupes

Les groupes sont essentiels dans AD pour gérer les permissions. PowerShell permet de les explorer facilement.

### Commandes de base

```powershell
# Lister tous les groupes
Get-ADGroup -Filter *

# Obtenir les membres d'un groupe
Get-ADGroup -Filter {Name -eq "GG-EU-RH-Users"} | ForEach-Object {
    Get-ADGroupMember -Identity $_.DistinguishedName
}
```

!!! info "ForEach-Object"
    
    ForEach-Object permet de parcourir chaque objet retourné par Get-ADGroup. Le `$_` représente l'objet actuel utilisé dans la boucle


```powershell
# Obtenir les groupes d'un utilisateur
Get-ADUser -Filter {SamAccountName -eq "victor"} | ForEach-Object {
    Get-ADPrincipalGroupMembership -Identity $_.DistinguishedName
}
```

### Mission 2.1 — Exploration des groupes

!!! example "Objectif"
    
    1. Listez tous les groupes dont le nom contient `"IT"`, avec leur description
    2. Affichez les membres du groupe `GG-EU-IT-Users` (nom + SamAccountName)
    3. Listez tous les groupes dont **aucun membre n'est actif** (groupes vides ou uniquement désactivés)
    
    *Note : `Get-ADGroupMember` n'accepte pas `-Filter`, utilisez `-Identity`.*

??? success "Solution"
    
    ```powershell
    # 1. Groupes contenant "IT"
    Get-ADGroup -Filter {Name -like "*IT*"} -Properties Description |
        Format-Table Name, Description
    
    # 2. Membres de GG-EU-IT-Users
    Get-ADGroupMember -Identity "GG-EU-IT-Users" |
        Format-Table Name, SamAccountName
    
    # 3. Groupes vides ou sans membres actifs
    Get-ADGroup -Filter {Name -like "GG-EU*"} | ForEach-Object {
        $membres = Get-ADGroupMember -Identity $_.Name |
                       Where-Object { (Get-ADUser -Identity $_.SamAccountName).Enabled }
        if ($membres.Count -eq 0) {
            Write-Host "Groupe sans membres actifs : $($_.Name)"
        }
    }
    ```

!!! tip "Le paramètre -Identity"
    
    Ce paramètre permet de spécifier quel objet AD vous voulez manipuler. Il accepte plusieurs formats d'identification. Par exemple... si on a le groupe "GG-EU-IT-Users", on peut le trouver de plusieurs manières en utilisant le paramètre -Identity :
    
    - **Nom** : Simplement le nom du groupe (ex: -Identity "GG-EU-IT-Users")
    - **SamAccountName** : L'identifiant unique du groupe dans le domaine (ex: -Identity "GG-EU-IT-Users")
    - **DistinguishedName** : Le chemin complet dans l'AD (ex: -Identity "CN=GG-EU-IT-Users,OU=Groups,OU=EU,DC=maxtec,DC=be")
    - **GUID** : L'identifiant unique global (ex: -Identity "123e4567-e89b-12d3-a456-426614174000")



## 3. 🔹 Explorer les Unités d'Organisation (OUs)

Les OUs structurent votre Active Directory. PowerShell permet de les explorer et de comprendre leur hiérarchie.

### Commandes de base



```powershell
# Lister toutes les OUs
Get-ADOrganizationalUnit -Filter *

# Lister une OU spécifique
Get-ADOrganizationalUnit -Filter { Name -eq "RH"}

# Trouver un user spécifique par son nom
Get-ADUser -Filter {Country -eq "BE"}
```

!!! note "SearchBase obligatoire"
    
    SearchBase est nécessaire car il définit le point de départ de la recherche

```powershell
# Obtenir les objets dans une OU spécifique
Get-ADObject -Filter * -SearchBase "OU=Users,OU=Comptabilite,OU=EU,DC=maxtec,DC=be"
```

!!! note "Limitation de recherche"
    
    SearchBase est nécessaire pour limiter la recherche à une OU spécifique

```powershell
# Compter les utilisateurs dans une OU
(Get-ADUser -Filter * -SearchBase "OU=Users,OU=Comptabilite,OU=EU,DC=maxtec,DC=be").Count
```


## 4. 🔹 Exportation des données

L'exportation des données est essentielle pour le reporting et l'analyse.

### Exportation vers CSV

!!! note "Sélection d'attributs"
    
    Select-Object permet de sélectionner les attributs que l'on souhaite exporter.

!!! tip "Différence Pipeline vs ForEach-Object"
    
    Dans PowerShell, il existe deux façons principales de traiter plusieurs objets :
    
    **1. Le pipeline (|)** : Utilisé pour passer les résultats d'une commande à une autre. Idéal quand la commande suivante accepte des objets en entrée via le pipeline.
    
    **2. ForEach-Object** : Utilisé quand vous devez exécuter **un bloc de code plus complexe** pour chaque objet ou quand la commande suivante n'accepte pas d'entrée via le pipeline.

!!! example "Exemple avec pipeline"
    
    ```powershell
    # Exemple avec pipeline
    Get-ADUser -Filter {Country -eq "BE"} | Select-Object Name, SamAccountName
    ```

!!! example "Exemple avec ForEach-Object"
    
    ```powershell
    # Exemple avec ForEach-Object
    Get-ADGroup -Filter {Name -like "GG-*"} | ForEach-Object {
        # Bloc de code exécuté pour chaque groupe
        Get-ADGroupMember -Identity $_.Name
    }
    ```
    
    **Explication de cet exemple** :
    
    1. `Get-ADGroup -Filter {Name -like "GG-*"}` : Cette commande recherche tous les groupes AD dont le nom commence par "GG-"
    2. `| ForEach-Object { ... }` : Pour chaque groupe trouvé, on exécute le bloc de code entre accolades
    3. `Get-ADGroupMember -Identity $_.Name` : Pour chaque groupe ($_ représente le groupe actuel), on récupère la liste de ses membres
    
    **Pourquoi utiliser ForEach-Object ici ?** Parce que `Get-ADGroupMember` n'accepte pas directement des objets du pipeline. Il faut donc traiter chaque groupe individuellement et extraire son nom pour le passer à la commande.

!!! info "Explication de `$_`"
    
    Dans PowerShell, `$_` est une variable spéciale qui représente l'objet actuel dans le pipeline. Quand vous utilisez ForEach-Object, `$_` fait référence à chaque objet qui est traité un par un. Par exemple, dans `$_.Name`, le `$_` représente un groupe AD et `.Name` accède à la propriété "Name" de ce groupe.

```powershell
# Exemple d'exportation avec pipeline
# Exporter la liste des utilisateurs vers un fichier CSV
# Note: 'Department' (propriété PowerShell) = 'Service' (interface française d'AD)
Get-ADUser -Filter * -Properties Department, Title, EmailAddress |
    Select-Object Name, SamAccountName, Department, Title, EmailAddress |
    Export-Csv -Path "C:\utilisateurs.csv" -NoTypeInformation -Encoding UTF8
```

### Exportation au format HTML (pour visualisation dans un navigateur)

```powershell
# Exporter vers un fichier HTML (plus visuel qu'un CSV)
# Note: 'Department' (propriété PowerShell) = 'Service' (interface française d'AD)
Get-ADUser -Filter * -Properties Department, Title | 
    Select-Object Name, SamAccountName, Department, Title |
    ConvertTo-Html -Title "Liste des utilisateurs" -Property Name, SamAccountName, Country |
    Out-File -FilePath "C:\utilisateurs.html" -Encoding UTF8

# Ouvrir le fichier HTML dans le navigateur par défaut
Invoke-Item "C:\utilisateurs.html"
```

### Mission 4.1 — Rapport d'audit CSV + HTML

!!! example "Objectif"
    
    Produisez deux fichiers de rapport pour Sophie :
    
    1. **CSV** : tous les utilisateurs actifs avec `Name`, `SamAccountName`, `Department`, `EmailAddress`, `PasswordLastSet`
    2. **HTML** : le même rapport, à ouvrir dans un navigateur, avec un titre `"Audit Maxtec — Utilisateurs actifs"`
    3. **Bonus** : un second CSV listant chaque groupe `GG-EU` avec le nombre de membres

??? success "Solution"
    
    ```powershell
    # 1. CSV utilisateurs actifs
    Get-ADUser -Filter {Enabled -eq $true} `
               -Properties Department, EmailAddress, PasswordLastSet |
        Select-Object Name, SamAccountName, Department, EmailAddress, PasswordLastSet |
        Export-Csv -Path "C:\audit_utilisateurs.csv" -NoTypeInformation -Encoding UTF8
    
    # 2. HTML
    Get-ADUser -Filter {Enabled -eq $true} `
               -Properties Department, EmailAddress, PasswordLastSet |
        Select-Object Name, SamAccountName, Department, EmailAddress, PasswordLastSet |
        ConvertTo-Html -Title "Audit Maxtec — Utilisateurs actifs" |
        Out-File -FilePath "C:\audit_utilisateurs.html" -Encoding UTF8
    Invoke-Item "C:\audit_utilisateurs.html"
    
    # 3. Bonus : groupes + nb membres
    Get-ADGroup -Filter {Name -like "GG-EU*"} | ForEach-Object {
        [PSCustomObject]@{
            Groupe  = $_.Name
            Membres = (Get-ADGroupMember -Identity $_.Name).Count
        }
    } | Export-Csv -Path "C:\audit_groupes.csv" -NoTypeInformation -Encoding UTF8
    ```

---

## 🧭 Navigation
[⏮️ Chapitre Précédent: Powershell AD - Concepts base](Chapitre%209.1.Powershell%20AD%20-%20Concepts%20base.md) | [🏠 Retour au Syllabus](index.md) | [⏭️ Chapitre Suivant: Powershell AD - Création et Modification](Chapitre%209.3.Powershell%20AD%20-%20Creation_et_Modification.md)

---

**📚 Cours Active Directory - PowerShell | 👨‍💻 Pour débutants**
