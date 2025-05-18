# Atelier pratique : Création et modification

## 1. 🔹 Création d'utilisateurs

La création d'utilisateurs est l'une des tâches les plus courantes dans l'administration AD. PowerShell permet de l'automatiser efficacement.

### Création d'un utilisateur simple

```powershell
# Créer un nouvel utilisateur
New-ADUser -Name "Pierre Dupont" `
    -GivenName "Pierre" `
    -Surname "Dupont" `
    -SamAccountName "pierre.dupont" `
    -UserPrincipalName "pierre.dupont@computerelectronics.be" `
    -Path "OU=Utilisateurs,OU=Comptabilité,OU=EU,DC=computerelectronics,DC=be" `
    -AccountPassword (ConvertTo-SecureString "Password1!" -AsPlainText -Force) `
    -Enabled $true `
    -ChangePasswordAtLogon $true
```

### Création d'un utilisateur avec attributs avancés

```powershell
# Créer un utilisateur avec des attributs supplémentaires
New-ADUser -Name "Marie Martin" `
    -GivenName "Marie" `
    -Surname "Martin" `
    -SamAccountName "marie.martin" `
    -UserPrincipalName "marie.martin@computerelectronics.be" `
    -Path "OU=Utilisateurs,OU=RH,OU=EU,DC=computerelectronics,DC=be" `
    -AccountPassword (ConvertTo-SecureString "Password1!" -AsPlainText -Force) `
    -Enabled $true `
    -Department "Ressources Humaines" `
    -Title "Responsable RH" `
    -Company "Computer Electronics" `
    -EmailAddress "marie.martin@computerelectronics.be" `
    -OfficePhone "+32 2 123 45 67" `
    -Description "Responsable RH pour la zone Europe"
```

> **Exercice** : Créez un nouvel utilisateur dans le département Ventes avec les attributs appropriés.

## 2. 🔹 Création de groupes

Les groupes sont essentiels pour gérer les permissions dans Active Directory.

### Création d'un groupe de sécurité

```powershell
# Créer un groupe global de sécurité
New-ADGroup -Name "GG-EU-Ventes-Managers" `
    -SamAccountName "GG-EU-Ventes-Managers" `
    -GroupCategory Security `
    -GroupScope Global `
    -DisplayName "Managers des Ventes Europe" `
    -Path "OU=Groupes,OU=EU,DC=computerelectronics,DC=be" `
    -Description "Groupe des managers du département Ventes en Europe"
```

### Création d'un groupe de distribution

```powershell
# Créer un groupe de distribution
New-ADGroup -Name "DL-Newsletter-Marketing" `
    -SamAccountName "DL-Newsletter-Marketing" `
    -GroupCategory Distribution `
    -GroupScope Universal `
    -DisplayName "Newsletter Marketing" `
    -Path "OU=Groupes,OU=EU,DC=computerelectronics,DC=be" `
    -Description "Liste de distribution pour la newsletter marketing"
```

> **Exercice** : Créez un groupe de sécurité local de domaine (DL) pour gérer l'accès à un dossier partagé du département Comptabilité.

## 3. 🔹 Modification d'attributs utilisateur

La modification des attributs utilisateur est une tâche courante qui peut être facilement automatisée avec PowerShell.

### Modification d'attributs simples

```powershell
# Modifier le titre et le département d'un utilisateur
Set-ADUser -Identity "pierre.dupont" `
    -Title "Comptable Senior" `
    -Department "Comptabilité" `
    -Description "Comptable senior pour les clients européens"
```

### Modification d'attributs avancés

```powershell
# Modifier plusieurs attributs d'un utilisateur
Set-ADUser -Identity "marie.martin" `
    -StreetAddress "Avenue Louise 123" `
    -City "Bruxelles" `
    -PostalCode "1050" `
    -Country "BE" `
    -HomePage "https://intranet.computerelectronics.be/rh" `
    -Manager "jean.dupuis" # SamAccountName du manager
```

> **Exercice** : Modifiez les informations de contact d'un utilisateur existant, y compris son numéro de téléphone mobile et son adresse.

## 4. 🔹 Gestion des mots de passe

La gestion des mots de passe est une tâche critique pour la sécurité.

### Réinitialisation de mot de passe

```powershell
# Réinitialiser le mot de passe d'un utilisateur
Set-ADAccountPassword -Identity "pierre.dupont" `
    -Reset `
    -NewPassword (ConvertTo-SecureString "Password1!" -AsPlainText -Force)

# Forcer le changement de mot de passe à la prochaine connexion
Set-ADUser -Identity "pierre.dupont" -ChangePasswordAtLogon $true
```

### Déverrouillage de compte

```powershell
# Déverrouiller un compte utilisateur
Unlock-ADAccount -Identity "marie.martin"

# Vérifier si un compte est verrouillé
Get-ADUser -Identity "marie.martin" -Properties LockedOut | Select-Object Name, LockedOut
```

> **Exercice** : Écrivez un script qui réinitialise le mot de passe d'un utilisateur, déverrouille son compte et force le changement de mot de passe à la prochaine connexion.

## 5. 🔹 Gestion des appartenances aux groupes

La gestion des appartenances aux groupes est essentielle pour contrôler les accès.

### Ajouter un utilisateur à un groupe

```powershell
# Ajouter un utilisateur à un groupe
Add-ADGroupMember -Identity "GG-EU-Comptabilité-Utilisateurs" -Members "pierre.dupont"

# Ajouter plusieurs utilisateurs à un groupe
Add-ADGroupMember -Identity "GG-EU-Ventes-Utilisateurs" -Members "jean.martin", "sophie.lambert"
```

### Retirer un utilisateur d'un groupe

```powershell
# Retirer un utilisateur d'un groupe
Remove-ADGroupMember -Identity "GG-EU-Comptabilité-Managers" -Members "pierre.dupont" -Confirm:$false
```

### Vérifier les appartenances

```powershell
# Vérifier les groupes d'un utilisateur
Get-ADPrincipalGroupMembership -Identity "pierre.dupont" | Select-Object Name
```

> **Exercice** : Ajoutez un utilisateur à trois groupes différents, puis vérifiez ses appartenances.

## 6. 🔹 Mini-projet : Script pour créer plusieurs utilisateurs à partir d'un CSV

Ce mini-projet vous permettra de créer automatiquement plusieurs utilisateurs à partir d'un fichier CSV.

### Étape 1 : Créer le fichier CSV

Créez un fichier `nouveaux_utilisateurs.csv` avec le contenu suivant :

```
Prenom,Nom,Departement,Titre,OU
Thomas,Leclerc,Comptabilité,Comptable,OU=Utilisateurs,OU=Comptabilité,OU=EU,DC=computerelectronics,DC=be
Sophie,Dubois,Ventes,Commerciale,OU=Utilisateurs,OU=Ventes,OU=EU,DC=computerelectronics,DC=be
Marc,Leroy,RH,Assistant RH,OU=Utilisateurs,OU=RH,OU=EU,DC=computerelectronics,DC=be
```

### Étape 2 : Script d'importation

```powershell
# Importer le fichier CSV
$utilisateurs = Import-Csv -Path "C:\Temp\nouveaux_utilisateurs.csv" -Delimiter ","

# Parcourir chaque ligne et créer les utilisateurs
foreach ($user in $utilisateurs) {
    # Créer le nom d'utilisateur (prénom.nom)
    $samAccountName = "$($user.Prenom.ToLower()).$($user.Nom.ToLower())"
    $displayName = "$($user.Prenom) $($user.Nom)"
    $userPrincipalName = "$samAccountName@computerelectronics.be"
    
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
            -Department $user.Departement `
            -Title $user.Titre `
            -EmailAddress $userPrincipalName
            
        # Ajouter l'utilisateur au groupe de son département
        $groupName = "GG-EU-$($user.Departement)-Utilisateurs"
        Add-ADGroupMember -Identity $groupName -Members $samAccountName -ErrorAction SilentlyContinue
            
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
