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
    $mdp = Read-Host "Mot de passe initial" -AsSecureString
    
    # (jean.dupont : voir la commande plus haut)
    
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
    New-ADUser @params
    
    # Vérification
    Get-ADUser -Filter "Description -eq 'Nouvel arrivant'" -Properties Department, Title |
        Format-Table Name, SamAccountName, Department, Title
    ```
    
    `@params` (le *splatting*) passe une table de hachage comme liste de paramètres : plus lisible que dix lignes terminées par un accent grave.

### Modification d'attributs simples

```powershell
# Modifier le titre et la description d'un utilisateur
Get-ADUser -Filter "SamAccountName -eq 'victor'" | Set-ADUser `
    -Title "Commercial Senior" `
    -Description "Commercial senior pour les clients européens" `
    -WhatIf
# Puis la même commande sans -WhatIf
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
    # Simulation : doit lister charlotte, cindy et charles (+ chloe si vous avez fait Gestion Ex. 1)
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


## 3. 🔹 Gestion des appartenances aux groupes

!!! info "Gestion des accès"
    
    La gestion des appartenances aux groupes est essentielle pour contrôler les accès.

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
# Retirer des utilisateurs d'un groupe (fin de la délégation temporaire)
Remove-ADGroupMember -Identity "GG-EU-Ventes-Admin" -Members victor, valeria -WhatIf

# Remove-ADGroupMember demande confirmation par défaut.
# -Confirm:$false supprime la question : uniquement après avoir lu le -WhatIf.
Remove-ADGroupMember -Identity "GG-EU-Ventes-Admin" -Members victor, valeria -Confirm:$false
```

!!! note "Propriété Department"
    
    `Department` (propriété PowerShell) = **Service** (onglet Organisation dans la console AD).

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
    Add-ADGroupMember -Identity "GG-EU-IT-Admin" -Members "jean.dupont"
    
    # Variante en une ligne, du point de vue de l'utilisateur
    # Add-ADPrincipalGroupMembership -Identity "jean.dupont" -MemberOf "GG-EU-IT-Users", "GG-EU-IT-Admin"
    
    # 2. Ajouter sophie.dubois
    Add-ADGroupMember -Identity "GG-EU-Ventes-Users" -Members "sophie.dubois"
    
    # 3. Retirer jean.dupont de IT-Admin
    Remove-ADGroupMember -Identity "GG-EU-IT-Admin" -Members "jean.dupont" -WhatIf
    Remove-ADGroupMember -Identity "GG-EU-IT-Admin" -Members "jean.dupont" -Confirm:$false
    
    # 4. Vérification
    Get-ADPrincipalGroupMembership -Identity "jean.dupont" |
        Select-Object Name | Sort-Object Name
    ```

## 4. 🔹 Mini-projet : Script pour créer plusieurs utilisateurs à partir d'un CSV

Ce mini-projet vous permettra de créer automatiquement plusieurs utilisateurs à partir d'un fichier CSV : les trois arrivants de la semaine prochaine.

### Étape 1 : Créer le fichier CSV

Créez un fichier `C:\Scripts\utilisateurs.csv` avec le contenu suivant :

```
Prenom,Nom,Departement,Titre,OU
Thomas,Leclerc,Comptabilite,Comptable,"OU=Users,OU=Comptabilite,OU=EU,DC=maxtec,DC=be"
Sarah,Lemaire,Ventes,Commerciale,"OU=Users,OU=Ventes,OU=EU,DC=maxtec,DC=be"
Marc,Leroy,RH,Assistant RH,"OU=Users,OU=RH,OU=EU,DC=maxtec,DC=be"
```

!!! note "Encodage du fichier"
    
    Enregistrez le CSV en **UTF-8** (VS Code le fait par défaut, le Bloc-notes récent aussi). En Windows PowerShell 5.1, `Import-Csv` ne suppose pas l'UTF-8 : sans `-Encoding UTF8`, un nom comme `Liège` devient `LiÃ¨ge`. Les scripts ci-dessous précisent donc toujours `-Encoding UTF8`.

### Étape 2 : Script d'importation (à corriger et adapter)

```powershell
# Mode simulation : $true = -WhatIf partout. Passez à $false après avoir lu la sortie.
$simulation = $true

# Importer le fichier CSV
$utilisateurs = Import-Csv -Path "C:\Scripts\utilisateurs.csv" -Delimiter "," -Encoding UTF8
# Pour déboguer, afficher le contenu de $utilisateurs
Write-Host "`nContenu de `$utilisateurs`:" -ForegroundColor Yellow
$utilisateurs | Format-List

# Mot de passe initial commun, saisi une fois, masqué.
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
        continue
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
# Vérifier les utilisateurs créés : uniquement les logins du CSV,
# pas tous les comptes du département (les 13 comptes du lab y sont aussi)
$departements = $utilisateurs | Select-Object -ExpandProperty Departement -Unique

foreach ($dept in $departements) {
    $logins = $utilisateurs | Where-Object Departement -eq $dept |
        ForEach-Object { "$($_.Prenom.ToLower()).$($_.Nom.ToLower())" }
    $count = @($logins | Where-Object { Get-ADUser -Filter "SamAccountName -eq '$_'" }).Count
    Write-Host "Département $dept : $count / $(@($logins).Count) utilisateurs du CSV créés" -ForegroundColor Cyan
}
```

### Mission 4.1 — Enrichir le script CSV

!!! example "Objectif"
    
    Les RH ont ajouté des colonnes au fichier CSV. Adaptez le script pour gérer ces nouveaux champs :
    
    1. Ajoutez `Bureau`, `Telephone`, et `Ville` au CSV et transmettez-les à `New-ADUser` (`-Office`, `-MobilePhone`, `-City`)
    2. Après la création, ajoutez automatiquement chaque utilisateur au groupe `…-Users` de son département. Attention : le groupe de `Comptabilite` s'appelle `GG-EU-Compta-Users`, pas `GG-EU-Comptabilite-Users`.
    3. Générez un rapport final : ligne par ligne `"[Nom] — [Département] — Créé : OK/ERREUR"`
    4. Gardez le mode simulation : premier passage avec `$simulation = $true`

??? success "Solution"
    
    **CSV étendu (`C:\Scripts\utilisateurs.csv`, en UTF-8)** :
    ```
    Prenom,Nom,Departement,Titre,OU,Bureau,Telephone,Ville
    Thomas,Leclerc,Comptabilite,Comptable,"OU=Users,OU=Comptabilite,OU=EU,DC=maxtec,DC=be",B201,+32489001122,Bruxelles
    Sarah,Lemaire,Ventes,Commerciale,"OU=Users,OU=Ventes,OU=EU,DC=maxtec,DC=be",V105,+32489003344,Liège
    Marc,Leroy,RH,Assistant RH,"OU=Users,OU=RH,OU=EU,DC=maxtec,DC=be",R12,+32489005566,Gand
    ```
    
    **Script adapté** :
    ```powershell
    $simulation = $true     # $false pour exécuter réellement
    
    $utilisateurs = Import-Csv -Path "C:\Scripts\utilisateurs.csv" -Delimiter "," -Encoding UTF8
    $mdp = Read-Host "Mot de passe initial" -AsSecureString
    
    # Correspondance Departement (CSV) -> nom court utilisé dans les groupes
    $groupeParDept = @{
        Ventes       = 'Ventes'
        RH           = 'RH'
        Comptabilite = 'Compta'
        IT           = 'IT'
    }
    
    foreach ($user in $utilisateurs) {
        $sam  = "$($user.Prenom.ToLower()).$($user.Nom.ToLower())"
        $upn  = "$sam@maxtec.be"
        $nom  = "$($user.Prenom) $($user.Nom)"
    
        if (Get-ADUser -Filter "SamAccountName -eq '$sam'") {
            Write-Host "$nom - déjà existant, ignoré" -ForegroundColor Yellow
            continue
        }
    
        if (-not $groupeParDept.ContainsKey($user.Departement)) {
            Write-Host "$nom - département inconnu '$($user.Departement)' - Créé : ERREUR" -ForegroundColor Red
            continue
        }
        $groupe = "GG-EU-$($groupeParDept[$user.Departement])-Users"
    
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
                # -ErrorAction Stop : si le groupe n'existe pas, on le voit dans le rapport
                Add-ADGroupMember -Identity $groupe -Members $sam -ErrorAction Stop
            }
    
            Write-Host "$nom - $($user.Departement) - Créé : OK (groupe $groupe)" -ForegroundColor Green
        }
        catch {
            Write-Host "$nom - $($user.Departement) - Créé : ERREUR ($_)" -ForegroundColor Red
        }
    }
    ```
    
    Pourquoi pas `-ErrorAction SilentlyContinue` sur `Add-ADGroupMember` ? Parce qu'un utilisateur créé mais sans groupe n'a accès à rien, et que personne ne le saurait avant son premier jour. Une erreur visible vaut mieux qu'un échec silencieux.

## 🔹 Conclusion

!!! success "Compétences acquises"
    
    Vous savez créer, modifier et affecter des comptes AD en PowerShell, seuls ou en masse, et surtout vérifier la portée d'une commande avec `-WhatIf` avant de l'exécuter.
    
    Vous avez terminé le module PowerShell AD. Pour nettoyer le lab : `Get-ADUser -Filter "Description -eq 'Nouvel arrivant'" | Remove-ADUser -WhatIf`, puis la même chose pour les comptes du CSV.

---

## 🧭 Navigation
[⏮️ Chapitre Précédent: Powershell AD - Requêtes et Informations](Chapitre%209.2.Powershell%20AD%20-%20Requetes_et_Informations.md) | [🏠 Retour au Syllabus](index.md) | [⏭️ Chapitre Suivant: Monitoring](Chapitre%2010.Monitoring.md)

---

**📚 Cours Active Directory - PowerShell**
