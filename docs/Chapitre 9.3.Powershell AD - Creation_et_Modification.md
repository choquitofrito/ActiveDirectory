# Chapitre 9.3: Atelier pratique : Création et modification

## 🧭 Navigation du Cours
[⏮️ Chapitre Précédent: Powershell AD - Requêtes et Informations](Chapitre%209.2.Powershell%20AD%20-%20Requetes_et_Informations.md) | [🏠 Retour au Syllabus](index.md)

---

!!! info "📚 Dans ce chapitre"
    
    Apprenez à créer et modifier des objets Active Directory avec PowerShell pour automatiser vos tâches d'administration.

---

!!! info "Fil rouge : Semaine 2 chez Maxtec"
    
    Trois nouveaux arrivants rejoignent la société en début de semaine. Les RH vous ont transmis leurs informations et vous chargent de tout préparer avant leur premier jour. Les missions ci-dessous couvrent les opérations typiques : modification de profils, réinitialisation de mots de passe, gestion des groupes et création en masse depuis un CSV.

---

## 1. 🔹 Modification d'attributs utilisateur

!!! tip "Automatisation"
    
    La modification des attributs utilisateur est une tâche courante qui peut être facilement automatisée avec PowerShell.

### Modification d'attributs simples

```powershell
# Modifier le titre et le département d'un utilisateur
# Méthode avec Filter
Get-ADUser -Filter "SamAccountName -eq 'Victor'" | Set-ADUser `
    -Title "Comptable Senior" `
    -Department "Comptabilité" `
    -Description "Comptable senior pour les clients européens"
```

### Mission 1.1 — Mise à jour des profils

!!! example "Objectif"
    
    Les RH ont mis à jour les titres de trois personnes. Appliquez ces changements :
    
    1. Modifiez un utilisateur de votre choix : changez son `Title` en `"Analyste Senior"` et son `Department` en `"IT"`
    2. Modifiez la `Description` de **tous** les utilisateurs du département `"Comptabilité"` : mettez `"Equipe Comptabilité EU"`
    3. Vérifiez les changements avec `Get-ADUser` après chaque modification

??? success "Solution"
    
    ```powershell
    # 1. Modifier un utilisateur
    Get-ADUser -Filter "SamAccountName -eq 'jean.dupont'" | Set-ADUser `
        -Title      "Analyste Senior" `
        -Department "IT"
    
    # Vérification
    Get-ADUser -Identity "jean.dupont" -Properties Title, Department |
        Select-Object Name, Title, Department
    
    # 2. Modification en masse pour la Comptabilité
    Get-ADUser -Filter "Department -eq 'Comptabilité'" | ForEach-Object {
        Set-ADUser -Identity $_.SamAccountName -Description "Equipe Comptabilité EU"
    }
    
    # Vérification
    Get-ADUser -Filter "Department -eq 'Comptabilité'" -Properties Description |
        Format-Table Name, Description
    ```

## 2. 🔹 Gestion des mots de passe

!!! warning "Sécurité critique"
    
    La gestion des mots de passe est une tâche critique pour la sécurité.

### Réinitialisation de mot de passe

```powershell
# Réinitialiser le mot de passe d'un utilisateur
Get-ADUser -Filter "SamAccountName -eq 'pierre.dupont'" | Set-ADAccountPassword `
    -Reset `
    -NewPassword (ConvertTo-SecureString "Password1!" -AsPlainText -Force)

# Forcer le changement de mot de passe à la prochaine connexion
Get-ADUser -Filter "SamAccountName -eq 'pierre.dupont'" | Set-ADUser -ChangePasswordAtLogon $true


# Exemple: réinitialiser les mots de passe de tous les utilisateurs d'un département
Get-ADUser -Filter "Department -eq 'Stagiaires'" | ForEach-Object {
    Set-ADAccountPassword -Identity $_.SamAccountName `
        -Reset `
        -NewPassword (ConvertTo-SecureString "Password1!" -AsPlainText -Force)
    Set-ADUser -Identity $_.SamAccountName -ChangePasswordAtLogon $true
}
```

### Mission 2.1 — Réinitialisation pour les nouveaux arrivants

!!! example "Objectif"
    
    Les trois nouveaux arrivants n'ont pas encore de mot de passe défini. Appliquez la procédure standard :
    
    1. Réinitialisez le mot de passe d'un utilisateur avec `Password1!` et forcez le changement à la première connexion
    2. Faites de même pour **tous** les utilisateurs du département `"Stagiaires"` en une seule opération
    3. Vérifiez qu'aucun compte `"Stagiaires"` n'est verrouillé (`LockedOut`)

??? success "Solution"
    
    ```powershell
    # 1. Réinitialisation individuelle
    $pass = ConvertTo-SecureString "Password1!" -AsPlainText -Force
    
    Set-ADAccountPassword -Identity "jean.dupont" -Reset -NewPassword $pass
    Set-ADUser -Identity "jean.dupont" -ChangePasswordAtLogon $true
    
    # 2. Réinitialisation en masse pour les Stagiaires
    Get-ADUser -Filter "Department -eq 'Stagiaires'" | ForEach-Object {
        Set-ADAccountPassword -Identity $_.SamAccountName -Reset -NewPassword $pass
        Set-ADUser -Identity $_.SamAccountName -ChangePasswordAtLogon $true
        Write-Host "Réinitialisé : $($_.Name)"
    }
    
    # 3. Vérification des comptes verrouillés
    Get-ADUser -Filter "Department -eq 'Stagiaires'" -Properties LockedOut |
        Format-Table Name, SamAccountName, LockedOut
    ```


### Déverrouillage de compte

```powershell
# Déverrouiller un compte utilisateur
Get-ADUser -Filter "SamAccountName -eq 'marie.martin'" | Unlock-ADAccount

# Vérifier si un compte est verrouillé
Get-ADUser -Filter {SamAccountName -eq 'marie.martin'} -Properties LockedOut | Select-Object Name, LockedOut

# Exemple: déverrouiller tous les comptes verrouillés
Get-ADUser -Filter {LockedOut -eq $true} -Properties LockedOut | ForEach-Object {
    Unlock-ADAccount -Identity $_.SamAccountName
    Write-Host "Compte $($_.Name) déverrouillé" -ForegroundColor Green
}
```


## 3. 🔹 Gestion des appartenances aux groupes

!!! info "Gestion des accès"
    
    La gestion des appartenances aux groupes est essentielle pour contrôler les accès.

### Ajouter un utilisateur à un groupe

```powershell
# Ajouter un utilisateur à un groupe
Get-ADUser -Filter "SamAccountName -eq 'pierre.dupont'" | Add-ADGroupMember -Identity "GG-EU-Compta-Users"

# Ajouter plusieurs utilisateurs à un groupe
Get-ADUser -Filter "(SamAccountName -eq 'jean.martin') -or (SamAccountName -eq 'sophie.lambert')" | Add-ADGroupMember -Identity "GG-EU-Ventes-Users"
```

### Retirer un utilisateur d'un groupe

```powershell
# Retirer un utilisateur d'un groupe
Get-ADUser -Filter {SamAccountName -eq 'pierre.dupont'} | Remove-ADGroupMember -Identity "GG-EU-Compta-Admin" -Confirm:$false

# Exemple: retirer tous les utilisateurs d'un service d'un groupe
!!! note "Propriété Department"
    
    'Department' (propriété PowerShell) = 'Service' (interface française d'AD)
Get-ADUser -Filter {Department -eq 'Stagiaires'} | Remove-ADGroupMember -Identity "GG-EU-Compta-Users" -Confirm:$false
```

### Vérifier les appartenances

```powershell
# Vérifier les groupes d'un utilisateur
Get-ADUser -Filter {SamAccountName -eq 'Richard'} | ForEach-Object {
    Get-ADPrincipalGroupMembership -Identity $_.SamAccountName | Select-Object Name
}

# Exemple: afficher les groupes pour tous les utilisateurs d'une OU spécifique
$cheminOU = "OU=Users,OU=Ventes,OU=EU,DC=maxtec,DC=be"
Get-ADUser -Filter * -SearchBase $cheminOU | ForEach-Object {
    Write-Host "\nGroupes de $($_.Name):" -ForegroundColor Yellow
    Get-ADPrincipalGroupMembership -Identity $_.SamAccountName | Select-Object Name
}
```

### Mission 3.1 — Affectation aux groupes

!!! example "Objectif"
    
    Les trois nouveaux arrivants ont des profils différents. Appliquez les affectations suivantes :
    
    1. Ajoutez `jean.dupont` (IT) aux groupes `GG-EU-IT-Users` et `GG-EU-IT-Admin`
    2. Ajoutez `sophie.dubois` (Ventes) au groupe `GG-EU-Ventes-Users`
    3. Retirez `jean.dupont` de `GG-EU-IT-Admin` (accès accordé par erreur)
    4. Vérifiez les groupes de `jean.dupont` en fin d'opération

??? success "Solution"
    
    ```powershell
    # 1. Ajouter jean.dupont à deux groupes
    Add-ADGroupMember -Identity "GG-EU-IT-Users" -Members "jean.dupont"
    Add-ADGroupMember -Identity "GG-EU-IT-Admin" -Members "jean.dupont"
    
    # 2. Ajouter sophie.dubois
    Add-ADGroupMember -Identity "GG-EU-Ventes-Users" -Members "sophie.dubois"
    
    # 3. Retirer jean.dupont de IT-Admin
    Remove-ADGroupMember -Identity "GG-EU-IT-Admin" -Members "jean.dupont" -Confirm:$false
    
    # 4. Vérification
    Get-ADPrincipalGroupMembership -Identity "jean.dupont" |
        Select-Object Name | Sort-Object Name
    ```

## 4. 🔹 Mini-projet : Script pour créer plusieurs utilisateurs à partir d'un CSV

Ce mini-projet vous permettra de créer automatiquement plusieurs utilisateurs à partir d'un fichier CSV.

### Étape 1 : Créer le fichier CSV

Créez un fichier `utilisateurs.csv` avec le contenu suivant :

```
Prenom,Nom,Departement,Titre,OU
Thomas,Leclerc,Comptabilite,Comptable,"OU=Users,OU=Comptabilite,OU=EU,DC=maxtec,DC=be"
Sophie,Dubois,Ventes,Commerciale,"OU=Users,OU=Ventes,OU=EU,DC=maxtec,DC=be"
Marc,Leroy,RH,Assistant RH,"OU=Users,OU=RH,OU=EU,DC=maxtec,DC=be"
```

### Étape 2 : Script d'importation (à corriger et adapter)

```powershell
# Importer le fichier CSV
$utilisateurs = Import-Csv -Path "C:\utilisateurs.csv" -Delimiter ","
# Pour déboguer, afficher le contenu de $utilisateurs
Write-Host "`nContenu de `$utilisateurs`:" -ForegroundColor Yellow
$utilisateurs | Format-List

# Parcourir chaque ligne et créer les utilisateurs
foreach ($user in $utilisateurs) {
    # Créer le nom d'utilisateur (prénom.nom)
    $samAccountName = "$($user.Prenom.ToLower()).$($user.Nom.ToLower())"
    $displayName = "$($user.Prenom) $($user.Nom)"
    $userPrincipalName = "$samAccountName@maxtec.be"
    
    # Vérifier si l'utilisateur existe déjà
    if (Get-ADUser -Filter {SamAccountName -eq $samAccountName} -ErrorAction SilentlyContinue) {
        Write-Warning "L'utilisateur $samAccountName existe déjà."
        continue
    }
    
    # Créer l'utilisateur
    try {
        New-ADUser -Name $displayName `
            -GivenName $user.Prenom `
            -Surname $user.Nom `
            -SamAccountName $samAccountName `
            -UserPrincipalName $userPrincipalName `
            -Path $user.OU `
            -AccountPassword (ConvertTo-SecureString "Password1!" -AsPlainText -Force) `
            -Enabled $true `
            -ChangePasswordAtLogon $true `
            -EmailAddress $userPrincipalName
            
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

### Étape 3 : Vérification et rapport

```powershell
# Vérifier les utilisateurs créés
$departements = $utilisateurs | Select-Object -ExpandProperty Departement -Unique

foreach ($dept in $departements) {
    $count = (Get-ADUser -Filter {Department -eq $dept}).Count
    Write-Host "Département $dept : $count utilisateurs" -ForegroundColor Cyan
}
```

### Mission 4.1 — Enrichir le script CSV

!!! example "Objectif"
    
    Les RH ont ajouté des colonnes au fichier CSV. Adaptez le script pour gérer ces nouveaux champs :
    
    1. Ajoutez `Bureau`, `Telephone`, et `Ville` au CSV et transmettez-les à `New-ADUser` (`-Office`, `-MobilePhone`, `-City`)
    2. Après la création, ajoutez automatiquement chaque utilisateur au groupe correspondant à son département (ex: `"GG-EU-Ventes-Users"` pour le département `"Ventes"`)
    3. Générez un rapport final : ligne par ligne `"[Nom] — [Département] — Créé : OK/ERREUR"`

??? success "Solution"
    
    **CSV étendu (`utilisateurs.csv`)** :
    ```
    Prenom,Nom,Departement,Titre,OU,Bureau,Telephone,Ville
    Thomas,Leclerc,Comptabilite,Comptable,"OU=Users,OU=Comptabilite,OU=EU,DC=maxtec,DC=be",B201,+32489001122,Bruxelles
    Sophie,Dubois,Ventes,Commerciale,"OU=Users,OU=Ventes,OU=EU,DC=maxtec,DC=be",V105,+32489003344,Liège
    Marc,Leroy,RH,Assistant RH,"OU=Users,OU=RH,OU=EU,DC=maxtec,DC=be",R12,+32489005566,Gand
    ```
    
    **Script adapté** :
    ```powershell
    $utilisateurs = Import-Csv -Path "C:\utilisateurs.csv" -Delimiter ","
    $pass = ConvertTo-SecureString "Password1!" -AsPlainText -Force
    
    foreach ($user in $utilisateurs) {
        $sam  = "$($user.Prenom.ToLower()).$($user.Nom.ToLower())"
        $upn  = "$sam@maxtec.be"
        $nom  = "$($user.Prenom) $($user.Nom)"
    
        if (Get-ADUser -Filter "SamAccountName -eq '$sam'" -ErrorAction SilentlyContinue) {
            Write-Host "$nom — déjà existant, ignoré" -ForegroundColor Yellow
            continue
        }
    
        try {
            New-ADUser -Name $nom `
                -GivenName $user.Prenom -Surname $user.Nom `
                -SamAccountName $sam -UserPrincipalName $upn `
                -Path $user.OU `
                -AccountPassword $pass -Enabled $true -ChangePasswordAtLogon $true `
                -EmailAddress $upn `
                -Office $user.Bureau -MobilePhone $user.Telephone -City $user.Ville
    
            # Affectation au groupe du département
            $groupe = "GG-EU-$($user.Departement)-Users"
            Add-ADGroupMember -Identity $groupe -Members $sam -ErrorAction SilentlyContinue
    
            Write-Host "$nom — $($user.Departement) — Créé : OK" -ForegroundColor Green
        }
        catch {
            Write-Host "$nom — $($user.Departement) — Créé : ERREUR ($_)" -ForegroundColor Red
        }
    }
    ```

## 🔹 Conclusion

!!! success "Compétences acquises"
    
    Cette section vous a présenté les techniques essentielles pour créer et modifier des objets Active Directory avec PowerShell. Ces compétences vous permettront d'automatiser des tâches répétitives et de gagner un temps précieux dans votre administration quotidienne.
    
    Vous avez maintenant terminé le module PowerShell AD.

---

## 🧭 Navigation
[⏮️ Chapitre Précédent: Powershell AD - Requêtes et Informations](Chapitre%209.2.Powershell%20AD%20-%20Requetes_et_Informations.md) | [🏠 Retour au Syllabus](index.md)

---

**📚 Cours Active Directory - PowerShell | 👨‍💻 Pour débutants**
