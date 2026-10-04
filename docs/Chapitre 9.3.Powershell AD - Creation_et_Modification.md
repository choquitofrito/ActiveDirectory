# Chapitre 9.3: Atelier pratique : Création et modification

## 🧭 Navigation du Cours
[⏮️ Chapitre Précédent: Powershell AD - Requêtes et Informations](Chapitre%209.2.Powershell%20AD%20-%20Requetes_et_Informations.md) | [🏠 Retour au Syllabus](index.md) | [⏭️ Chapitre Suivant: Monitoring](Chapitre%2010.Monitoring.md)

---

!!! info "Objectifs du chapitre"
    
    À la fin de ce chapitre, vous savez :
    
    - simuler toute modification avec `-WhatIf` avant de l'exécuter ;
    - créer un utilisateur avec `New-ADUser` en saisissant le mot de passe de façon masquée (`Read-Host -AsSecureString`) ;
    - modifier des attributs avec `Set-ADUser`, sur un compte ou sur une sélection ;
    - réinitialiser un mot de passe et déverrouiller des comptes ;
    - ajouter et retirer des membres de groupes ;
    - créer plusieurs comptes à partir d'un fichier CSV, avec leur groupe.

---

!!! info "Fil rouge : Semaine 2 chez Maxtec"
    
    Deux nouveaux arrivants rejoignent la société en début de semaine : **Jean Dupont** (technicien stagiaire, IT) et **Sophie Dubois** (commerciale, Ventes). Trois autres suivront la semaine prochaine, les RH vous enverront leur liste en CSV. Les missions ci-dessous couvrent les opérations typiques : création de comptes, modification de profils, réinitialisation de mots de passe, gestion des groupes et création en masse.

---

## Avant de modifier en masse : -WhatIf et -Confirm

À partir d'ici, les commandes **modifient** l'annuaire. Une erreur de filtre et c'est tout le domaine qui change de département. Deux paramètres, présents sur toutes les commandes `New-`, `Set-`, `Add-`, `Remove-`, `Move-`, `Unlock-`, vous protègent :

| Paramètre | Effet |
|-----------|-------|
| `-WhatIf` | Simule : affiche `What if: Performing the operation ... on target ...` pour chaque objet visé, **ne modifie rien** |
| `-Confirm` | Demande une confirmation avant chaque objet (`-Confirm:$false` supprime la question : à réserver aux commandes déjà vérifiées) |

La méthode, pour tout le chapitre :

1. Écrire la commande avec `-WhatIf` à la fin.
2. Lire la sortie : le nombre d'objets et leurs DN correspondent-ils à l'intention ?
3. Relancer **la même commande** sans `-WhatIf`.
4. Vérifier le résultat avec un `Get-AD...`.

```powershell
# Exemple : ce qui serait modifié, sans rien modifier
Get-ADUser -Filter "Department -eq 'Ventes'" | Set-ADUser -Company "Maxtec" -WhatIf
# What if: Performing the operation "Set" on target "CN=Vanessa,OU=Users,OU=Ventes,OU=EU,DC=maxtec,DC=be".
# ...
```

!!! warning "Le `-WhatIf` va sur la commande qui modifie"
    
    `Get-ADUser` ne modifie rien et n'a pas de `-WhatIf`. C'est `Set-ADUser` (ou `Remove-...`, `Add-...`) qui doit le porter. Le module [M5 — `-WhatIf`, pourquoi c'est non négociable](PowershellCourse/cours-powershell-ad-moderne/modules-modernes/M5-whatif-avant-tout.md) détaille les incidents typiques et les pièges.

---

## 1. 🔹 Créer et modifier un utilisateur

### Créer un utilisateur

```powershell
# Mot de passe saisi au clavier, masqué, jamais écrit dans le script
# (en lab, tapez Password1!, le mot de passe unique du lab)
$mdp = Read-Host "Mot de passe initial" -AsSecureString

# Simulation
New-ADUser -Name "Jean Dupont" `
    -GivenName "Jean" -Surname "Dupont" -DisplayName "Jean Dupont" `
    -SamAccountName "jean.dupont" -UserPrincipalName "jean.dupont@maxtec.be" `
    -EmailAddress "jean.dupont@maxtec.be" `
    -Department "IT" -Title "Technicien stagiaire" -Company "Maxtec" -Country "BE" `
    -Description "Nouvel arrivant" `
    -Path "OU=Users,OU=IT,OU=EU,DC=maxtec,DC=be" `
    -AccountPassword $mdp -ChangePasswordAtLogon $true -Enabled $true `
    -WhatIf
# What if: Performing the operation "New" on target "CN=Jean Dupont,OU=Users,OU=IT,OU=EU,DC=maxtec,DC=be".

# Si la cible est correcte : même commande, sans -WhatIf
```

Les nouveaux comptes de ce chapitre suivent la convention `prenom.nom` (la plus courante en entreprise) ; les 13 comptes du lab n'utilisent que le prénom (`ivan`, `cindy`...), pour rester courts à taper.

!!! note "Mot de passe en clair : seulement en lab"
    
    Le script du lab et certains exemples utilisent `ConvertTo-SecureString "Password1!" -AsPlainText -Force`. C'est pratique pour un lab qu'on reconstruit souvent, mais le mot de passe est alors lisible par quiconque ouvre le script, et reste dans l'historique PowerShell. En production : `Read-Host -AsSecureString`, un mot de passe différent par compte et `-ChangePasswordAtLogon $true`.

!!! tip "Pourquoi `Description = Nouvel arrivant` ?"
    
    Ce marqueur permet de cibler **uniquement** les nouveaux comptes dans les opérations en masse de ce chapitre (réinitialisation de mot de passe, etc.) sans toucher aux 13 comptes du lab, dont les autres chapitres ont besoin avec leur mot de passe `Password1!`.

### Mission 1.1 — Créer les deux nouveaux arrivants

!!! example "Objectif"
    
    1. Créez `jean.dupont` avec la commande ci-dessus (d'abord avec `-WhatIf`, puis sans).
    2. Sur le même modèle, créez `sophie.dubois` : Sophie Dubois, `Department = Ventes`, `Title = Commerciale`, dans `OU=Users,OU=Ventes,OU=EU,DC=maxtec,DC=be`, `Description = Nouvel arrivant`.
    3. Vérifiez que les deux comptes existent.

??? success "Solution"
    
    ```powershell
    $mdp = Read-Host "Mot de passe initial" -AsSecureString     # en lab : Password1!
    
    # Pour chaque compte : lancez d'abord la commande avec -WhatIf ajouté à la fin,
    # vérifiez la cible affichée, puis relancez-la telle quelle (sans -WhatIf).
    
    # 1. jean.dupont
    New-ADUser -Name "Jean Dupont" `
        -GivenName "Jean" -Surname "Dupont" -DisplayName "Jean Dupont" `
        -SamAccountName "jean.dupont" -UserPrincipalName "jean.dupont@maxtec.be" `
        -EmailAddress "jean.dupont@maxtec.be" `
        -Department "IT" -Title "Technicien stagiaire" -Company "Maxtec" -Country "BE" `
        -Description "Nouvel arrivant" `
        -Path "OU=Users,OU=IT,OU=EU,DC=maxtec,DC=be" `
        -AccountPassword $mdp -ChangePasswordAtLogon $true -Enabled $true
    
    # 2. sophie.dubois
    New-ADUser -Name "Sophie Dubois" `
        -GivenName "Sophie" -Surname "Dubois" -DisplayName "Sophie Dubois" `
        -SamAccountName "sophie.dubois" -UserPrincipalName "sophie.dubois@maxtec.be" `
        -EmailAddress "sophie.dubois@maxtec.be" `
        -Department "Ventes" -Title "Commerciale" -Company "Maxtec" -Country "BE" `
        -Description "Nouvel arrivant" `
        -Path "OU=Users,OU=Ventes,OU=EU,DC=maxtec,DC=be" `
        -AccountPassword $mdp -ChangePasswordAtLogon $true -Enabled $true
    
    # 3. Vérification
    Get-ADUser -Filter "Description -eq 'Nouvel arrivant'" -Properties Department, Title |
        Format-Table Name, SamAccountName, Department, Title
    ```
    
    **Variante plus lisible : le *splatting*.** On range les paramètres dans une table de hachage (`@{ Nom = Valeur }`, une ligne par paramètre, sans tiret ni accent grave), puis on la passe à la commande avec `@` au lieu de `$` :
    
    ```powershell
    $params = @{
        Name              = "Sophie Dubois"
        GivenName         = "Sophie"
        Surname           = "Dubois"
        DisplayName       = "Sophie Dubois"
        SamAccountName    = "sophie.dubois"
        UserPrincipalName = "sophie.dubois@maxtec.be"
        EmailAddress      = "sophie.dubois@maxtec.be"
        Department        = "Ventes"
        Title             = "Commerciale"
        Company           = "Maxtec"
        Country           = "BE"
        Description       = "Nouvel arrivant"
        Path              = "OU=Users,OU=Ventes,OU=EU,DC=maxtec,DC=be"
        AccountPassword   = $mdp
        ChangePasswordAtLogon = $true
        Enabled           = $true
    }
    New-ADUser @params -WhatIf
    ```
    
    Même résultat, mais plus facile à relire et à modifier qu'une dizaine de lignes terminées par un accent grave.

### Entraînement 1.1 — Créer des comptes de test

Toujours le même enchaînement : **`New-ADUser ... -WhatIf` → lecture du DN cible → même commande sans `-WhatIf` → vérification**. Seuls changent le compte et l'OU.

Ces trois comptes servent aux entraînements suivants jusqu'à la section 3, où ils sont supprimés. Ils commencent tous par `test.` pour être faciles à cibler, et aucun n'est dans `Comptabilite` (la mission 1.2 modifie tout ce service).

!!! example "Exercices"
    
    1. **`test.rh`** : nom `Test RH`, `Department = RH`, `Title = Compte de test`, dans `OU=Users,OU=RH,OU=EU,DC=maxtec,DC=be`.
       *Indice : reprenez la commande de Jean Dupont et changez les valeurs. En lab, le mot de passe peut être `ConvertTo-SecureString "Password1!" -AsPlainText -Force`.*
    2. **`test.it`** : même chose dans le service `IT`.
       *Indice : seuls `Name`, `SamAccountName`, `UserPrincipalName`, `Department` et `Path` changent.*
    3. **`test.ventes`** : même chose dans le service `Ventes`, cette fois avec le *splatting*.
       *Indice : une table `$params = @{ ... }`, une ligne par paramètre, puis `New-ADUser @params -WhatIf`.*
    
    Pour finir, affichez les trois comptes en une seule commande.

??? success "Solutions"
    
    ```powershell
    # Mot de passe du lab (en clair : acceptable en lab uniquement)
    $mdp = ConvertTo-SecureString "Password1!" -AsPlainText -Force
    
    # 1. test.rh : simulation, puis même commande sans -WhatIf
    New-ADUser -Name "Test RH" -SamAccountName "test.rh" -UserPrincipalName "test.rh@maxtec.be" `
        -Department "RH" -Title "Compte de test" `
        -Path "OU=Users,OU=RH,OU=EU,DC=maxtec,DC=be" `
        -AccountPassword $mdp -Enabled $true -WhatIf
    
    # 2. test.it : seuls le nom, le login, le service et l'OU changent
    New-ADUser -Name "Test IT" -SamAccountName "test.it" -UserPrincipalName "test.it@maxtec.be" `
        -Department "IT" -Title "Compte de test" `
        -Path "OU=Users,OU=IT,OU=EU,DC=maxtec,DC=be" `
        -AccountPassword $mdp -Enabled $true -WhatIf
    
    # 3. test.ventes avec le splatting
    $params = @{
        Name              = "Test Ventes"
        SamAccountName    = "test.ventes"
        UserPrincipalName = "test.ventes@maxtec.be"
        Department        = "Ventes"
        Title             = "Compte de test"
        Path              = "OU=Users,OU=Ventes,OU=EU,DC=maxtec,DC=be"
        AccountPassword   = $mdp
        Enabled           = $true
    }
    New-ADUser @params -WhatIf
    
    # (relancez chaque commande sans -WhatIf une fois la cible vérifiée)
    
    # Vérification : les trois comptes de test
    Get-ADUser -Filter "SamAccountName -like 'test.*'" -Properties Department, Title |
        Format-Table Name, SamAccountName, Department, Title
    ```

### Modification d'attributs simples

```powershell
# Modifier le bureau et le téléphone d'un utilisateur
Set-ADUser -Identity "victor" -Office "V12" -OfficePhone "+32 2 123 45 70" -WhatIf
# Puis la même commande sans -WhatIf, et relecture
Get-ADUser -Identity "victor" -Properties Office, OfficePhone |
    Format-Table Name, Office, OfficePhone
```

!!! warning "Ne changez pas le `Department` des comptes du lab"
    
    `Department` doit rester égal au nom de l'OU (`Ventes`, `RH`, `Comptabilite`, `IT`) : les filtres des autres chapitres et exercices s'appuient dessus.

### Mission 1.2 — Mise à jour des profils

!!! example "Objectif"
    
    Les RH ont mis à jour deux informations. Appliquez ces changements, toujours `-WhatIf` d'abord :
    
    1. Jean Dupont a terminé sa période d'essai : changez son `Title` en `"Technicien"`.
    2. Modifiez la `Description` de **tous** les utilisateurs du département `"Comptabilite"` : mettez `"Equipe Comptabilite EU"`.
    3. Vérifiez les changements avec `Get-ADUser` après chaque modification.

??? success "Solution"
    
    ```powershell
    # 1. Modifier un utilisateur
    Set-ADUser -Identity "jean.dupont" -Title "Technicien" -WhatIf
    Set-ADUser -Identity "jean.dupont" -Title "Technicien"
    
    # Vérification
    Get-ADUser -Identity "jean.dupont" -Properties Title, Department |
        Select-Object Name, Title, Department
    
    # 2. Modification en masse pour la Comptabilite
    # Simulation : doit lister charlotte, cindy et charles
    # (+ chloe si vous avez fait l'exercice 1 de « Gestion des utilisateurs »)
    Get-ADUser -Filter "Department -eq 'Comptabilite'" |
        Set-ADUser -Description "Equipe Comptabilite EU" -WhatIf
    
    # Exécution
    Get-ADUser -Filter "Department -eq 'Comptabilite'" |
        Set-ADUser -Description "Equipe Comptabilite EU"
    
    # Vérification
    Get-ADUser -Filter "Department -eq 'Comptabilite'" -Properties Description |
        Format-Table Name, Description
    ```
    
    `Set-ADUser` accepte les utilisateurs venant du pipeline : pas besoin de `ForEach-Object` ici.

### Entraînement 1.2 — Modifier un compte, puis une sélection

Le schéma : **désigner le ou les comptes → `Set-ADUser ... -WhatIf` → exécution → relecture avec `-Properties`**. On travaille uniquement sur les comptes `test.*`.

!!! example "Exercices"
    
    1. **Un compte** : sur `test.rh`, mettez `Title = Gestionnaire RH (test)` et `Description = Modifié en 9.3`.
       *Indice : `Set-ADUser -Identity "test.rh" -Title ... -Description ... -WhatIf`.*
    2. **Toute une sélection** : mettez `Company = Maxtec` sur **tous** les comptes `test.*`. Le `-WhatIf` doit lister trois comptes, pas un de plus.
       *Indice : `Get-ADUser -Filter "SamAccountName -like 'test.*'" | Set-ADUser ...`.*
    3. **Deux comptes précis** : mettez `Country = FR` sur `test.it` et `test.ventes` seulement.
       *Indice : un filtre avec `-or` (vu en 9.2) : `"SamAccountName -eq 'test.it' -or SamAccountName -eq 'test.ventes'"`.*

??? success "Solutions"
    
    ```powershell
    # 1. Un compte
    Set-ADUser -Identity "test.rh" -Title "Gestionnaire RH (test)" -Description "Modifié en 9.3" -WhatIf
    Set-ADUser -Identity "test.rh" -Title "Gestionnaire RH (test)" -Description "Modifié en 9.3"
    Get-ADUser -Identity "test.rh" -Properties Title, Description |
        Format-Table Name, Title, Description
    
    # 2. Toute une sélection : le -WhatIf doit afficher exactement 3 lignes
    Get-ADUser -Filter "SamAccountName -like 'test.*'" | Set-ADUser -Company "Maxtec" -WhatIf
    Get-ADUser -Filter "SamAccountName -like 'test.*'" | Set-ADUser -Company "Maxtec"
    Get-ADUser -Filter "SamAccountName -like 'test.*'" -Properties Company |
        Format-Table Name, Company
    
    # 3. Deux comptes précis
    $filtre = "SamAccountName -eq 'test.it' -or SamAccountName -eq 'test.ventes'"
    Get-ADUser -Filter $filtre | Set-ADUser -Country "FR" -WhatIf
    Get-ADUser -Filter $filtre | Set-ADUser -Country "FR"
    Get-ADUser -Filter "SamAccountName -like 'test.*'" -Properties Country |
        Format-Table Name, Country      # test.rh doit rester vide
    ```
    
    Ranger le filtre dans une variable (`$filtre`) garantit que la simulation et l'exécution visent exactement les mêmes comptes.

## 2. 🔹 Gestion des mots de passe

!!! warning "Sécurité critique"
    
    La gestion des mots de passe est une tâche critique pour la sécurité. Ne réinitialisez **jamais** en masse les comptes du lab (`richard`, `ivan`...) : les autres chapitres supposent qu'ils ont toujours `Password1!`.

### Réinitialisation de mot de passe

```powershell
# Réinitialiser le mot de passe d'un utilisateur (saisie masquée)
$mdp = Read-Host "Nouveau mot de passe" -AsSecureString
Set-ADAccountPassword -Identity "jean.dupont" -Reset -NewPassword $mdp

# Forcer le changement de mot de passe à la prochaine connexion
Set-ADUser -Identity "jean.dupont" -ChangePasswordAtLogon $true

# Exemple : réinitialiser les mots de passe de tous les nouveaux arrivants
Get-ADUser -Filter "Description -eq 'Nouvel arrivant'" | ForEach-Object {
    Set-ADAccountPassword -Identity $_.SamAccountName -Reset -NewPassword $mdp -WhatIf
    Set-ADUser -Identity $_.SamAccountName -ChangePasswordAtLogon $true -WhatIf
}
```

### Mission 2.1 — Réinitialisation pour les nouveaux arrivants

!!! example "Objectif"
    
    Jean et Sophie ont oublié le mot de passe communiqué. Appliquez la procédure standard :
    
    1. Réinitialisez le mot de passe de `sophie.dubois` (saisie masquée) et forcez le changement à la première connexion.
    2. Faites de même pour **tous** les comptes marqués `Description = Nouvel arrivant`, en une seule opération : `-WhatIf` d'abord, puis exécution.
    3. Vérifiez qu'aucun de ces comptes n'est verrouillé (`LockedOut`).

??? success "Solution"
    
    ```powershell
    $mdp = Read-Host "Nouveau mot de passe" -AsSecureString
    
    # 1. Réinitialisation individuelle
    Set-ADAccountPassword -Identity "sophie.dubois" -Reset -NewPassword $mdp
    Set-ADUser -Identity "sophie.dubois" -ChangePasswordAtLogon $true
    
    # 2. Réinitialisation en masse : simulation (doit lister jean.dupont et sophie.dubois)
    $nouveaux = Get-ADUser -Filter "Description -eq 'Nouvel arrivant'"
    $nouveaux | ForEach-Object {
        Set-ADAccountPassword -Identity $_ -Reset -NewPassword $mdp -WhatIf
    }
    
    # Exécution
    $nouveaux | ForEach-Object {
        Set-ADAccountPassword -Identity $_ -Reset -NewPassword $mdp
        Set-ADUser -Identity $_ -ChangePasswordAtLogon $true
        Write-Host "Réinitialisé : $($_.Name)"
    }
    
    # 3. Vérification des comptes verrouillés
    Get-ADUser -Filter "Description -eq 'Nouvel arrivant'" -Properties LockedOut |
        Format-Table Name, SamAccountName, LockedOut
    ```

### Entraînement 2.1 — Réinitialiser et forcer le changement

Deux commandes vont toujours ensemble : **`Set-ADAccountPassword -Reset`** puis **`Set-ADUser -ChangePasswordAtLogon $true`**. On ne touche qu'aux comptes `test.*`.

!!! example "Exercices"
    
    1. **Un compte** : réinitialisez le mot de passe de `test.it` (saisie masquée) et forcez le changement à la prochaine connexion.
       *Indice : `Read-Host ... -AsSecureString`, puis les deux commandes de l'exemple plus haut.*
    2. **Une sélection** : faites de même pour tous les comptes `test.*`, `-WhatIf` d'abord, avec une ligne `Réinitialisé : <nom>` par compte.
       *Indice : `ForEach-Object`, comme dans la solution de la mission 2.1, avec un autre filtre.*
    3. **Vérifier** : affichez `Name` et `PasswordLastSet` des comptes `test.*`.
       *Indice : `PasswordLastSet` n'est pas renvoyé par défaut. Quand le changement est exigé, il est vide.*

??? success "Solutions"
    
    ```powershell
    $mdp = Read-Host "Nouveau mot de passe" -AsSecureString
    
    # 1. Un compte
    Set-ADAccountPassword -Identity "test.it" -Reset -NewPassword $mdp
    Set-ADUser -Identity "test.it" -ChangePasswordAtLogon $true
    
    # 2. Une sélection : simulation (3 comptes attendus), puis exécution
    $tests = Get-ADUser -Filter "SamAccountName -like 'test.*'"
    $tests | ForEach-Object {
        Set-ADAccountPassword -Identity $_ -Reset -NewPassword $mdp -WhatIf
    }
    $tests | ForEach-Object {
        Set-ADAccountPassword -Identity $_ -Reset -NewPassword $mdp
        Set-ADUser -Identity $_ -ChangePasswordAtLogon $true
        Write-Host "Réinitialisé : $($_.Name)"
    }
    
    # 3. Vérification : PasswordLastSet vide = changement exigé à la prochaine connexion
    Get-ADUser -Filter "SamAccountName -like 'test.*'" -Properties PasswordLastSet |
        Format-Table Name, PasswordLastSet
    ```

### Déverrouillage de compte

```powershell
# Vérifier si un compte est verrouillé
Get-ADUser -Identity "rebecca" -Properties LockedOut | Select-Object Name, LockedOut

# Déverrouiller un compte utilisateur
Unlock-ADAccount -Identity "rebecca"

# Lister tous les comptes verrouillés
# (LockedOut est une propriété calculée : on ne peut pas filtrer dessus avec -Filter,
#  Search-ADAccount est fait pour ça)
Search-ADAccount -LockedOut | Select-Object Name, SamAccountName

# Déverrouiller tous les comptes verrouillés : simulation puis exécution
Search-ADAccount -LockedOut | Unlock-ADAccount -WhatIf
Search-ADAccount -LockedOut | Unlock-ADAccount
```

!!! tip "Provoquer un verrouillage pour tester"
    
    Si le seuil de verrouillage du domaine est à 0 (valeur historique de la Default Domain Policy), aucun compte ne se verrouille jamais. Vérifiez avec `Get-ADDefaultDomainPasswordPolicy | Select-Object LockoutThreshold`. Avec un seuil défini, ratez volontairement plusieurs connexions avec `rebecca` sur `ws-IT-01`, puis déverrouillez.

### Entraînement 2.2 — État du compte : verrouillé, désactivé

Le schéma : **lire l'état avec `-Properties` (ou `Search-ADAccount`) → agir → relire**. Toujours sur les comptes `test.*`.

!!! example "Exercices"
    
    1. **Lire** : affichez `Name`, `Enabled` et `LockedOut` des trois comptes `test.*` en une commande.
       *Indice : `Enabled` est renvoyé par défaut, `LockedOut` non.*
    2. **Désactiver** : désactivez `test.ventes` (`-WhatIf` d'abord), puis listez les comptes désactivés du domaine.
       *Indice : `Set-ADUser -Enabled $false` ; `Search-ADAccount -AccountDisabled -UsersOnly` pour la liste (vu en 9.2).*
    3. **Réactiver et déverrouiller** : réactivez `test.ventes`, puis lancez `Unlock-ADAccount` sur `test.rh` en simulation.
       *Indice : `Unlock-ADAccount` sur un compte non verrouillé ne fait rien de mal ; le `-WhatIf` montre quand même la cible.*

??? success "Solutions"
    
    ```powershell
    # 1. Lire l'état
    Get-ADUser -Filter "SamAccountName -like 'test.*'" -Properties LockedOut |
        Format-Table Name, Enabled, LockedOut
    
    # 2. Désactiver, puis lister les comptes désactivés
    Set-ADUser -Identity "test.ventes" -Enabled $false -WhatIf
    Set-ADUser -Identity "test.ventes" -Enabled $false
    Search-ADAccount -AccountDisabled -UsersOnly | Format-Table Name, SamAccountName
    
    # 3. Réactiver, puis simuler un déverrouillage
    Set-ADUser -Identity "test.ventes" -Enabled $true
    Unlock-ADAccount -Identity "test.rh" -WhatIf
    
    # Relecture
    Get-ADUser -Filter "SamAccountName -like 'test.*'" -Properties LockedOut |
        Format-Table Name, Enabled, LockedOut
    ```

## 3. 🔹 Gestion des appartenances aux groupes

### Ajouter un utilisateur à un groupe

```powershell
# Ajouter un utilisateur à un groupe
Add-ADGroupMember -Identity "GG-EU-IT-Users" -Members "jean.dupont" -WhatIf

# Ajouter plusieurs utilisateurs : -Members accepte une liste
# (délégation temporaire : victor et valeria reçoivent les droits de responsable Ventes)
Add-ADGroupMember -Identity "GG-EU-Ventes-Admin" -Members victor, valeria -WhatIf

# Ajouter le résultat d'une recherche : la recherche se met entre parenthèses
Add-ADGroupMember -Identity "GG-EU-Ventes-Admin" `
    -Members (Get-ADUser -Filter "Department -eq 'Ventes' -and Title -like 'Commercial*'") -WhatIf

# Variante pipeline : Add-ADPrincipalGroupMembership part de l'utilisateur
Get-ADUser -Filter "Department -eq 'Ventes' -and Title -like 'Commercial*'" |
    Add-ADPrincipalGroupMembership -MemberOf "GG-EU-Ventes-Admin" -WhatIf
```

!!! warning "Piège : `Get-ADUser ... | Add-ADGroupMember -Identity G` ne marche pas"
    
    Dans `Add-ADGroupMember`, c'est `-Identity` (le **groupe**) qui reçoit le pipeline, pas `-Members`. Comme `-Identity` est déjà renseigné avec le nom du groupe, les utilisateurs envoyés dans le pipeline ne se lient à aucun paramètre et la commande échoue (« L'objet d'entrée ne peut être lié à aucun paramètre... »). Deux solutions : `-Members (Get-ADUser ...)`, ou `Add-ADPrincipalGroupMembership -MemberOf`, qui prend l'utilisateur en entrée. Même logique pour `Remove-ADGroupMember` / `Remove-ADPrincipalGroupMembership`.

### Retirer un utilisateur d'un groupe

```powershell
# Retirer des utilisateurs d'un groupe (fin de la délégation temporaire).
# Si l'ajout ci-dessus n'a été fait qu'en -WhatIf, victor et valeria ne sont pas membres :
# la commande réelle afficherait une erreur. Restez alors en -WhatIf.
Remove-ADGroupMember -Identity "GG-EU-Ventes-Admin" -Members victor, valeria -WhatIf

# Remove-ADGroupMember demande confirmation par défaut.
# -Confirm:$false supprime la question : uniquement après avoir lu le -WhatIf.
Remove-ADGroupMember -Identity "GG-EU-Ventes-Admin" -Members victor, valeria -Confirm:$false
```

### Vérifier les appartenances

```powershell
# Vérifier les groupes d'un utilisateur
Get-ADPrincipalGroupMembership -Identity "richard" | Select-Object Name

# Exemple : afficher les groupes pour tous les utilisateurs d'une OU spécifique
$cheminOU = "OU=Users,OU=Ventes,OU=EU,DC=maxtec,DC=be"
Get-ADUser -Filter * -SearchBase $cheminOU | ForEach-Object {
    Write-Host "`nGroupes de $($_.Name):" -ForegroundColor Yellow
    Get-ADPrincipalGroupMembership -Identity $_.SamAccountName | Select-Object Name
}
```

### Mission 3.1 — Affectation aux groupes

!!! example "Objectif"
    
    Jean et Sophie (créés en mission 1.1) ont des profils différents. Appliquez les affectations suivantes, `-WhatIf` d'abord :
    
    1. Ajoutez `jean.dupont` (IT) aux groupes `GG-EU-IT-Users` et `GG-EU-IT-Admin`
    2. Ajoutez `sophie.dubois` (Ventes) au groupe `GG-EU-Ventes-Users`
    3. Retirez `jean.dupont` de `GG-EU-IT-Admin` (accès accordé par erreur)
    4. Vérifiez les groupes de `jean.dupont` en fin d'opération

??? success "Solution"
    
    ```powershell
    # 1. Ajouter jean.dupont à deux groupes
    Add-ADGroupMember -Identity "GG-EU-IT-Users" -Members "jean.dupont" -WhatIf
    Add-ADGroupMember -Identity "GG-EU-IT-Users" -Members "jean.dupont"
    Add-ADGroupMember -Identity "GG-EU-IT-Admin" -Members "jean.dupont" -WhatIf
    Add-ADGroupMember -Identity "GG-EU-IT-Admin" -Members "jean.dupont"
    
    # Variante en une ligne, du point de vue de l'utilisateur
    # Add-ADPrincipalGroupMembership -Identity "jean.dupont" -MemberOf "GG-EU-IT-Users", "GG-EU-IT-Admin"
    
    # 2. Ajouter sophie.dubois
    Add-ADGroupMember -Identity "GG-EU-Ventes-Users" -Members "sophie.dubois" -WhatIf
    Add-ADGroupMember -Identity "GG-EU-Ventes-Users" -Members "sophie.dubois"
    
    # 3. Retirer jean.dupont de IT-Admin
    Remove-ADGroupMember -Identity "GG-EU-IT-Admin" -Members "jean.dupont" -WhatIf
    Remove-ADGroupMember -Identity "GG-EU-IT-Admin" -Members "jean.dupont" -Confirm:$false
    
    # 4. Vérification
    Get-ADPrincipalGroupMembership -Identity "jean.dupont" |
        Select-Object Name | Sort-Object Name
    ```

### Entraînement 3.1 — Ajouter, vérifier, retirer

Le cycle : **ajouter (`-WhatIf` d'abord) → vérifier → retirer → vérifier**. Côté groupe : `Add-ADGroupMember -Identity <groupe>` ; côté utilisateur : `Add-ADPrincipalGroupMembership -MemberOf <groupes>`.

!!! example "Exercices"
    
    1. **Côté groupe** : ajoutez `test.rh` à `GG-EU-RH-Users`, puis affichez les membres du groupe.
       *Indice : `Get-ADGroupMember -Identity ...` pour la vérification.*
    2. **Côté utilisateur** : ajoutez `test.it` à `GG-EU-IT-Users` **et** `GG-EU-IT-Admin` en une seule commande, puis affichez ses groupes.
       *Indice : `-MemberOf` accepte une liste séparée par des virgules.*
    3. **Retirer** : retirez `test.it` de `GG-EU-IT-Admin`, puis affichez les groupes de chacun des trois comptes `test.*`.
       *Indice : pour l'affichage, la boucle « groupes de tous les utilisateurs d'une OU » plus haut, avec le filtre `test.*`.*

??? success "Solutions"
    
    ```powershell
    # 1. Côté groupe
    Add-ADGroupMember -Identity "GG-EU-RH-Users" -Members "test.rh" -WhatIf
    Add-ADGroupMember -Identity "GG-EU-RH-Users" -Members "test.rh"
    Get-ADGroupMember -Identity "GG-EU-RH-Users" | Format-Table Name, SamAccountName
    
    # 2. Côté utilisateur, deux groupes d'un coup
    Add-ADPrincipalGroupMembership -Identity "test.it" -MemberOf "GG-EU-IT-Users", "GG-EU-IT-Admin" -WhatIf
    Add-ADPrincipalGroupMembership -Identity "test.it" -MemberOf "GG-EU-IT-Users", "GG-EU-IT-Admin"
    Get-ADPrincipalGroupMembership -Identity "test.it" | Select-Object Name
    
    # 3. Retirer, puis vérifier les trois comptes
    Remove-ADGroupMember -Identity "GG-EU-IT-Admin" -Members "test.it" -WhatIf
    Remove-ADGroupMember -Identity "GG-EU-IT-Admin" -Members "test.it" -Confirm:$false
    Get-ADUser -Filter "SamAccountName -like 'test.*'" | ForEach-Object {
        Write-Host "`nGroupes de $($_.Name) :" -ForegroundColor Yellow
        Get-ADPrincipalGroupMembership -Identity $_.SamAccountName | Select-Object Name
    }
    ```

!!! warning "Nettoyage des comptes de test"
    
    Les entraînements sur les comptes `test.*` sont terminés. Supprimez-les pour rendre le lab dans son état d'origine (leurs appartenances aux groupes disparaissent avec eux) :
    
    ```powershell
    Get-ADUser -Filter "SamAccountName -like 'test.*'" | Remove-ADUser -WhatIf          # 3 comptes attendus
    Get-ADUser -Filter "SamAccountName -like 'test.*'" | Remove-ADUser -Confirm:$false
    ```

## 4. 🔹 Mini-projet : Script pour créer plusieurs utilisateurs à partir d'un CSV

Ce mini-projet vous permettra de créer automatiquement plusieurs utilisateurs à partir d'un fichier CSV : les trois arrivants de la semaine prochaine.

### Étape 1 : Créer le fichier CSV

Créez un fichier `C:\Scripts\nouveaux_arrivants.csv` avec le contenu suivant :

```
Prenom,Nom,Departement,Titre,OU
Thomas,Leclerc,Comptabilite,Comptable,"OU=Users,OU=Comptabilite,OU=EU,DC=maxtec,DC=be"
Sarah,Lemaire,Ventes,Commerciale,"OU=Users,OU=Ventes,OU=EU,DC=maxtec,DC=be"
Marc,Leroy,RH,Assistant RH,"OU=Users,OU=RH,OU=EU,DC=maxtec,DC=be"
```

!!! note "Encodage du fichier"
    
    Enregistrez le CSV en **UTF-8** (VS Code le fait par défaut, le Bloc-notes récent aussi). En Windows PowerShell 5.1, `Import-Csv` ne suppose pas l'UTF-8 : sans `-Encoding UTF8`, un nom comme `Liège` devient `LiÃ¨ge`. Les scripts ci-dessous précisent donc toujours `-Encoding UTF8`.

### Étape 2 : Script d'importation

```powershell
# Mode simulation : $true = -WhatIf partout. Passez à $false après avoir lu la sortie.
$simulation = $true

# Importer le fichier CSV
$utilisateurs = Import-Csv -Path "C:\Scripts\nouveaux_arrivants.csv" -Delimiter "," -Encoding UTF8
# Pour déboguer, afficher le contenu de $utilisateurs
Write-Host "`nContenu de `$utilisateurs`:" -ForegroundColor Yellow
$utilisateurs | Format-List

# Mot de passe initial commun, saisi une fois, masqué (en lab : Password1!).
# Acceptable pour un premier accès si -ChangePasswordAtLogon est activé.
$mdp = Read-Host "Mot de passe initial" -AsSecureString

# Parcourir chaque ligne et créer les utilisateurs
foreach ($user in $utilisateurs) {
    # Créer le nom d'utilisateur (prénom.nom)
    $samAccountName = "$($user.Prenom.ToLower()).$($user.Nom.ToLower())"
    $displayName = "$($user.Prenom) $($user.Nom)"
    $userPrincipalName = "$samAccountName@maxtec.be"
    
    # Vérifier si l'utilisateur existe déjà (-Filter renvoie $null sans erreur)
    if (Get-ADUser -Filter "SamAccountName -eq '$samAccountName'") {
        Write-Warning "L'utilisateur $samAccountName existe déjà."
        continue    # passe directement à la ligne suivante du CSV
    }
    
    # Créer l'utilisateur
    try {
        New-ADUser -Name $displayName `
            -GivenName $user.Prenom `
            -Surname $user.Nom `
            -DisplayName $displayName `
            -SamAccountName $samAccountName `
            -UserPrincipalName $userPrincipalName `
            -EmailAddress $userPrincipalName `
            -Department $user.Departement `
            -Title $user.Titre `
            -Company "Maxtec" `
            -Path $user.OU `
            -AccountPassword $mdp `
            -Enabled $true `
            -ChangePasswordAtLogon $true `
            -ErrorAction Stop `
            -WhatIf:$simulation
            
        Write-Host "Utilisateur $displayName créé avec succès." -ForegroundColor Green
    }
    catch {
        # Dans un catch, $_ contient l'erreur qui vient de se produire
        Write-Host "Erreur lors de la création de $displayName : $_" -ForegroundColor Red
    }
}

# Afficher un résumé
Write-Host "`nRésumé de l'importation :" -ForegroundColor Yellow
Write-Host "Nombre d'utilisateurs traités : $($utilisateurs.Count)" -ForegroundColor Yellow
```

!!! tip "`-WhatIf:$simulation`"
    
    `-WhatIf:$true` équivaut à `-WhatIf`, `-WhatIf:$false` à son absence. Une seule variable en tête de script bascule tout le script entre simulation et exécution réelle. En simulation, le message « créé avec succès » s'affiche quand même : c'est la ligne `What if: ...` au-dessus qui compte.

### Étape 3 : Vérification et rapport

```powershell
# Vérifier les comptes créés : uniquement les logins du CSV,
# pas tous les comptes du département (les 13 comptes du lab y sont aussi)
# $utilisateurs vient du script de l'étape 2 (même session PowerShell)
foreach ($user in $utilisateurs) {
    $sam = "$($user.Prenom.ToLower()).$($user.Nom.ToLower())"
    if (Get-ADUser -Filter "SamAccountName -eq '$sam'") {
        Write-Host "$sam ($($user.Departement)) : créé" -ForegroundColor Green
    } else {
        Write-Host "$sam ($($user.Departement)) : absent" -ForegroundColor Red
    }
}
```

### Mission 4.1 — Nouvelles colonnes dans le CSV

!!! example "Objectif"
    
    Les RH ont ajouté des colonnes au fichier CSV. Adaptez le script de l'étape 2 :
    
    1. Ajoutez `Bureau`, `Telephone` et `Ville` au CSV et transmettez-les à `New-ADUser` (`-Office`, `-MobilePhone`, `-City`)
    2. Gardez le mode simulation : premier passage avec `$simulation = $true`, puis `$false` une fois la sortie vérifiée

??? success "Solution"
    
    **CSV étendu (`C:\Scripts\nouveaux_arrivants.csv`, en UTF-8)** :
    ```
    Prenom,Nom,Departement,Titre,OU,Bureau,Telephone,Ville
    Thomas,Leclerc,Comptabilite,Comptable,"OU=Users,OU=Comptabilite,OU=EU,DC=maxtec,DC=be",B201,+32489001122,Bruxelles
    Sarah,Lemaire,Ventes,Commerciale,"OU=Users,OU=Ventes,OU=EU,DC=maxtec,DC=be",V105,+32489003344,Liège
    Marc,Leroy,RH,Assistant RH,"OU=Users,OU=RH,OU=EU,DC=maxtec,DC=be",R12,+32489005566,Gand
    ```
    
    **Dans le script**, ajoutez trois lignes à la commande `New-ADUser`, avant `-ErrorAction Stop` :
    ```powershell
            -Office $user.Bureau `
            -MobilePhone $user.Telephone `
            -City $user.Ville `
    ```
    
    Les noms de colonnes du CSV deviennent des propriétés de `$user` : la colonne `Bureau` se lit `$user.Bureau`.

### Entraînement 4.1 — Lire un CSV ligne par ligne

Le schéma : **`Import-Csv` → `foreach ($ligne in ...)` → `$ligne.<NomDeColonne>`**. Aucun de ces exercices ne crée de compte.

!!! example "Exercices"
    
    1. **Afficher** : pour chaque ligne de `C:\Scripts\nouveaux_arrivants.csv`, affichez `Thomas Leclerc : Comptable (Comptabilite)`.
       *Indice : `$user.Prenom`, `$user.Nom`, `$user.Titre`, `$user.Departement` ; chacun entre `$( )` dans le texte.*
    2. **Calculer** : pour chaque ligne, affichez le login et l'UPN que le script créerait : `thomas.leclerc / thomas.leclerc@maxtec.be`.
       *Indice : la même construction que dans le script de l'étape 2, avec `.ToLower()`.*
    3. **Modifier depuis un CSV, en simulation** : créez `C:\Scripts\bureaux.csv` avec les colonnes `Login,Bureau` et deux lignes (`ivan,I01` et `ines,I02`), puis simulez `Set-ADUser -Office` pour chaque ligne.
       *Indice : `-Identity $ligne.Login`. Restez en `-WhatIf` : les comptes du lab ne doivent pas changer.*

??? success "Solutions"
    
    ```powershell
    $utilisateurs = Import-Csv -Path "C:\Scripts\nouveaux_arrivants.csv" -Delimiter "," -Encoding UTF8
    
    # 1. Afficher chaque ligne
    foreach ($user in $utilisateurs) {
        Write-Host "$($user.Prenom) $($user.Nom) : $($user.Titre) ($($user.Departement))"
    }
    
    # 2. Login et UPN calculés, sans rien créer
    foreach ($user in $utilisateurs) {
        $sam = "$($user.Prenom.ToLower()).$($user.Nom.ToLower())"
        Write-Host "$sam / $sam@maxtec.be"
    }
    
    # 3. Modification pilotée par un CSV, en simulation
    # Contenu de C:\Scripts\bureaux.csv (UTF-8) :
    #   Login,Bureau
    #   ivan,I01
    #   ines,I02
    $bureaux = Import-Csv -Path "C:\Scripts\bureaux.csv" -Delimiter "," -Encoding UTF8
    foreach ($ligne in $bureaux) {
        Set-ADUser -Identity $ligne.Login -Office $ligne.Bureau -WhatIf
    }
    ```

### Mission 4.2 — Groupe du département et rapport

!!! example "Objectif"
    
    1. Après la création, ajoutez chaque utilisateur au groupe `GG-EU-<Département>-Users` de son département. Attention : le groupe de `Comptabilite` s'appelle `GG-EU-Compta-Users`, pas `GG-EU-Comptabilite-Users`.
    2. Remplacez les messages du script par un rapport ligne par ligne : `"[Nom] - [Département] - Créé : OK/ERREUR"`
    
    *Indice : un `if / else` suffit pour le cas `Comptabilite`. En simulation, le compte n'est pas réellement créé : `Add-ADGroupMember` échouerait. Ne l'appelez que si `$simulation` vaut `$false` : `if (-not $simulation) { ... }`. Pour le rapport, réutilisez le `try / catch` de l'étape 2 : `OK` à la fin du `try`, `ERREUR` dans le `catch`.*

??? success "Solution"
    
    ```powershell
    $simulation = $true     # $false pour exécuter réellement
    
    $utilisateurs = Import-Csv -Path "C:\Scripts\nouveaux_arrivants.csv" -Delimiter "," -Encoding UTF8
    $mdp = Read-Host "Mot de passe initial" -AsSecureString
    
    foreach ($user in $utilisateurs) {
        $sam = "$($user.Prenom.ToLower()).$($user.Nom.ToLower())"
        $upn = "$sam@maxtec.be"
        $nom = "$($user.Prenom) $($user.Nom)"
    
        if (Get-ADUser -Filter "SamAccountName -eq '$sam'") {
            Write-Host "$nom - déjà existant, ignoré" -ForegroundColor Yellow
            continue
        }
    
        # Nom du groupe : Comptabilite est abrégé en Compta
        if ($user.Departement -eq "Comptabilite") {
            $groupe = "GG-EU-Compta-Users"
        } else {
            $groupe = "GG-EU-$($user.Departement)-Users"
        }
    
        try {
            New-ADUser -Name $nom `
                -GivenName $user.Prenom -Surname $user.Nom -DisplayName $nom `
                -SamAccountName $sam -UserPrincipalName $upn `
                -EmailAddress $upn `
                -Department $user.Departement -Title $user.Titre -Company "Maxtec" `
                -Path $user.OU `
                -AccountPassword $mdp -Enabled $true -ChangePasswordAtLogon $true `
                -Office $user.Bureau -MobilePhone $user.Telephone -City $user.Ville `
                -ErrorAction Stop -WhatIf:$simulation
    
            # En simulation, le compte n'existe pas : on ne peut pas l'ajouter au groupe
            if (-not $simulation) {
                # -ErrorAction Stop : si le groupe n'existe pas, on passe dans le catch
                Add-ADGroupMember -Identity $groupe -Members $sam -ErrorAction Stop
            }
    
            Write-Host "$nom - $($user.Departement) - Créé : OK ($groupe)" -ForegroundColor Green
        }
        catch {
            Write-Host "$nom - $($user.Departement) - Créé : ERREUR ($_)" -ForegroundColor Red
        }
    }
    ```
    
    Pourquoi pas `-ErrorAction SilentlyContinue` sur `Add-ADGroupMember` ? Parce qu'un utilisateur créé mais sans groupe n'a accès à rien, et que personne ne le saurait avant son premier jour. Une erreur visible vaut mieux qu'un échec silencieux.

### Entraînement 4.2 — Décider et contrôler, ligne par ligne

Le schéma : **pour chaque ligne du CSV, un `if / else` ou un `try / catch` → une ligne de rapport**. Lecture seule : rien n'est créé.

!!! example "Exercices"
    
    1. **Calculer le groupe** : pour chaque ligne, affichez `Thomas Leclerc : GG-EU-Compta-Users`, avec le cas particulier de `Comptabilite`.
       *Indice : le même `if / else` que dans la solution de la mission 4.2.*
    2. **Contrôler le groupe** : pour chaque groupe calculé, affichez `GG-EU-Compta-Users : OK` s'il existe, `ERREUR` sinon.
       *Indice : `Get-ADGroup -Identity $groupe -ErrorAction Stop` dans un `try` ; le `catch` reçoit le cas « groupe introuvable ».*
    3. **Contrôler le compte** : pour chaque ligne, affichez `thomas.leclerc : existe déjà` ou `thomas.leclerc : à créer`.
       *Indice : `if (Get-ADUser -Filter "SamAccountName -eq '$sam'")`, comme au début du script de l'étape 2.*

??? success "Solutions"
    
    ```powershell
    $utilisateurs = Import-Csv -Path "C:\Scripts\nouveaux_arrivants.csv" -Delimiter "," -Encoding UTF8
    
    foreach ($user in $utilisateurs) {
        $nom = "$($user.Prenom) $($user.Nom)"
        $sam = "$($user.Prenom.ToLower()).$($user.Nom.ToLower())"
    
        # 1. Nom du groupe (Comptabilite est abrégé en Compta)
        if ($user.Departement -eq "Comptabilite") {
            $groupe = "GG-EU-Compta-Users"
        } else {
            $groupe = "GG-EU-$($user.Departement)-Users"
        }
        Write-Host "$nom : $groupe"
    
        # 2. Le groupe existe-t-il ?
        try {
            # Le résultat est rangé dans une variable pour ne pas l'afficher
            $g = Get-ADGroup -Identity $groupe -ErrorAction Stop
            Write-Host "  $groupe : OK" -ForegroundColor Green
        }
        catch {
            Write-Host "  $groupe : ERREUR" -ForegroundColor Red
        }
    
        # 3. Le compte existe-t-il déjà ?
        if (Get-ADUser -Filter "SamAccountName -eq '$sam'") {
            Write-Host "  $sam : existe déjà" -ForegroundColor Yellow
        } else {
            Write-Host "  $sam : à créer"
        }
    }
    ```
    
    Les trois contrôles sont réunis dans une seule boucle ; on peut aussi écrire trois boucles séparées, une par exercice.

## 🔹 Conclusion

!!! success "Compétences acquises"
    
    Vous savez créer, modifier et affecter des comptes AD en PowerShell, seuls ou en masse, et surtout vérifier la portée d'une commande avec `-WhatIf` avant de l'exécuter.
    
    Vous avez terminé le module PowerShell AD. **Gardez `jean.dupont` et `sophie.dubois`** : la suite du cours s'en sert (module M2, référence du lab). Supprimez en revanche les comptes d'entraînement (`-WhatIf` d'abord, puis la même commande avec `-Confirm:$false`) :
    
    ```powershell
    # Les comptes du CSV
    foreach ($sam in @("thomas.leclerc", "sarah.lemaire", "marc.leroy")) {
        Remove-ADUser -Identity $sam -WhatIf
    }
    
    # Les comptes test.* s'il en reste
    Get-ADUser -Filter "SamAccountName -like 'test.*'" | Remove-ADUser -WhatIf
    ```

---

## 🧭 Navigation
[⏮️ Chapitre Précédent: Powershell AD - Requêtes et Informations](Chapitre%209.2.Powershell%20AD%20-%20Requetes_et_Informations.md) | [🏠 Retour au Syllabus](index.md) | [⏭️ Chapitre Suivant: Monitoring](Chapitre%2010.Monitoring.md)

---

**📚 Cours Active Directory - PowerShell**
