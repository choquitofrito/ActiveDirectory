# Chapitre 8.3: Atelier pratique : Création et modification

## 1. 🔹 Modification d'attributs utilisateur

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

> **Exercice** : Modifiez la description de tous les utilisateurs du département Comptabilité (mettez par exemple: "Utilisateur de comptabilité")

## 4. 🔹 Gestion des mots de passe

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

> **Exercice**: Réinitialisez le mot de passe de tous les utilisateurs du département Comptabilité et forcez le changement de mot de passe à la prochaine connexion.


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


## 5. 🔹 Gestion des appartenances aux groupes

La gestion des appartenances aux groupes est essentielle pour contrôler les accès.

### Ajouter un utilisateur à un groupe

```powershell
# Ajouter un utilisateur à un groupe
Get-ADUser -Filter "SamAccountName -eq 'pierre.dupont'" | Add-ADGroupMember -Identity "GG-EU-Comptabilité-Utilisateurs"

# Ajouter plusieurs utilisateurs à un groupe
Get-ADUser -Filter "(SamAccountName -eq 'jean.martin') -or (SamAccountName -eq 'sophie.lambert')" | Add-ADGroupMember -Identity "GG-EU-Ventes-Utilisateurs"
```

### Retirer un utilisateur d'un groupe

```powershell
# Retirer un utilisateur d'un groupe
Get-ADUser -Filter {SamAccountName -eq 'pierre.dupont'} | Remove-ADGroupMember -Identity "GG-EU-Comptabilité-Managers" -Confirm:$false

# Exemple: retirer tous les utilisateurs d'un service d'un groupe
# Note: 'Department' (propriété PowerShell) = 'Service' (interface française d'AD)
Get-ADUser -Filter {Department -eq 'Stagiaires'} | Remove-ADGroupMember -Identity "GG-EU-Comptabilité-Utilisateurs" -Confirm:$false
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

> **Exercice** : Ajoutez un utilisateur à trois groupes différents, puis vérifiez ses appartenances.

## 6. 🔹 Mini-projet : Script pour créer plusieurs utilisateurs à partir d'un CSV

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

> **Exercice final** : Modifiez le script pour ajouter des attributs supplémentaires comme le bureau, le téléphone, et l'adresse. Ajoutez également une gestion d'erreurs plus robuste.

## 🔹 Conclusion

Cette section vous a présenté les techniques essentielles pour créer et modifier des objets Active Directory avec PowerShell. Ces compétences vous permettront d'automatiser des tâches répétitives et de gagner un temps précieux dans votre administration quotidienne.

Dans la prochaine section, nous verrons comment gérer les stratégies de groupe (GPO) avec PowerShell.
