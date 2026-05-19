# PowerShell Cheat Sheet - Commandes Essentielles

## 🧭 Navigation du Cours
[⏮️ Chapitre Précédent: Powershell AD - Création et Modification](Chapitre%209.3.Powershell%20AD%20-%20Creation_et_Modification.md) | [🏠 Retour au Syllabus](index.md)

---

## 1. 🔹 Commandes de Base PowerShell

### Variables
```powershell
# Créer une variable
$nomUtilisateur = "jean.dupont"

# Afficher une variable
Write-Host $nomUtilisateur
$nomUtilisateur  # Version courte

# Concaténation
$nomComplet = $prenom + " " + $nom
```

### Tableaux
```powershell
# Créer un tableau
$utilisateurs = @("jean.dupont", "marie.martin", "pierre.durand")

# Accéder à un élément (index commence à 0)
$utilisateurs[0]  # Premier élément
$utilisateurs[-1] # Dernier élément

# Ajouter un élément
$utilisateurs += "luc.lefevre"
```

### Boucles
```powershell
# Boucle foreach simple
foreach ($utilisateur in $utilisateurs) {
    Write-Host $utilisateur.Name
}

# Avec pipeline
$utilisateurs | ForEach-Object { Write-Host $_.Name }
```

### Conditions
```powershell
# Condition simple
if ($compteActif) {
    Write-Host "Compte actif"
} else {
    Write-Host "Compte désactivé"
}

# Comparaisons courantes
$nombre -eq 5    # Égal
$nombre -ne 5    # Différent
$nombre -gt 5    # Supérieur
$nombre -lt 5    # Inférieur
```

## 2. 🔹 Commandes Active Directory - Utilisateurs

### Recherche d'utilisateurs
```powershell
# Tous les utilisateurs
Get-ADUser -Filter *

# Utilisateur spécifique
Get-ADUser -Identity "jean.dupont"
Get-ADUser -Filter {SamAccountName -eq "jean.dupont"}

# Utilisateurs avec propriétés étendues
Get-ADUser -Filter * -Properties *

# Recherche par propriétés
Get-ADUser -Filter {Department -eq "Comptabilité"}
Get-ADUser -Filter {Title -like "*Manager*"}
Get-ADUser -Filter {WhenCreated -ge "01/01/2023"}
```

### Création et modification d'utilisateurs
```powershell
# Créer un utilisateur (avec mot de passe initial)
$pwd = ConvertTo-SecureString "Azerty_1" -AsPlainText -Force
New-ADUser -Name "Marie Martin" -SamAccountName "marie.martin" `
    -Path "OU=Users,OU=Comptabilite,OU=EU,DC=maxtec,DC=be" `
    -AccountPassword $pwd -Enabled $true `
    -ChangePasswordAtLogon $true

# Activer/Désactiver un compte
Enable-ADAccount -Identity "marie.martin"
Disable-ADAccount -Identity "marie.martin"

# Modifier les propriétés
Set-ADUser -Identity "marie.martin" -Title "Chef Comptable" -Department "Comptabilité"

# Déplacer un objet vers une autre OU
Move-ADObject -Identity "CN=Marie Martin,OU=Users,OU=Comptabilite,OU=EU,DC=maxtec,DC=be" `
    -TargetPath "OU=Users,OU=RH,OU=EU,DC=maxtec,DC=be"

# Renommer un objet
Rename-ADObject -Identity "CN=Marie Martin,OU=Users,..." -NewName "Marie Dupont"

# Reset / changer le mot de passe
Set-ADAccountPassword -Identity "marie.martin" -Reset `
    -NewPassword (ConvertTo-SecureString "NewPwd_2025!" -AsPlainText -Force)

# Forcer le changement à la prochaine ouverture de session
Set-ADUser -Identity "marie.martin" -ChangePasswordAtLogon $true

# Déverrouiller un compte
Unlock-ADAccount -Identity "marie.martin"

# Supprimer un utilisateur
Remove-ADUser -Identity "marie.martin" -Confirm:$false
```

### Recherche avancée
```powershell
# Utilisateurs actifs seulement
Get-ADUser -Filter {Enabled -eq $true}

# Utilisateurs avec mot de passe expiré
Get-ADUser -Filter {PasswordExpired -eq $true}

# Utilisateurs verrouillés
Get-ADUser -Filter {LockedOut -eq $true}

# Search-ADAccount : raccourcis pour les cas fréquents
Search-ADAccount -AccountInactive -TimeSpan 90.00:00:00 -UsersOnly  # inactifs > 90 j
Search-ADAccount -LockedOut -UsersOnly                              # verrouillés
Search-ADAccount -PasswordNeverExpires -UsersOnly                   # mots de passe sans expiration
Search-ADAccount -AccountDisabled -UsersOnly                        # désactivés
```

## 3. 🔹 Commandes Active Directory - Groupes

### Recherche de groupes
```powershell
# Tous les groupes
Get-ADGroup -Filter *

# Groupe spécifique
Get-ADGroup -Identity "GG-EU-RH-Users"

# Groupes par type
Get-ADGroup -Filter {GroupScope -eq "Global"}
Get-ADGroup -Filter {GroupCategory -eq "Security"}

# Recherche par nom
Get-ADGroup -Filter {Name -like "GG-EU-*"}
```

### Gestion des membres
```powershell
# Ajouter un membre à un groupe
Add-ADGroupMember -Identity "GG-EU-RH-Users" -Members "marie.martin"

# Retirer un membre
Remove-ADGroupMember -Identity "GG-EU-RH-Users" -Members "marie.martin"

# Lister les membres
Get-ADGroupMember -Identity "GG-EU-RH-Users"

# Récupérer tous les groupes d'un utilisateur
Get-ADPrincipalGroupMembership -Identity "marie.martin"
```

## 4. 🔹 Commandes Active Directory - Ordinateurs

### Recherche d'ordinateurs
```powershell
# Tous les ordinateurs
Get-ADComputer -Filter *

# Ordinateur spécifique
Get-ADComputer -Identity "ws-compta-01"

# Ordinateurs par OS
Get-ADComputer -Filter {OperatingSystem -like "*Windows 10*"}

# Ordinateurs activés/désactivés
Get-ADComputer -Filter {Enabled -eq $true}
```

### Gestion des ordinateurs
```powershell
# Créer un compte ordinateur
New-ADComputer -Name "ws-compta-02" -Path "OU=Computers,OU=Comptabilite,OU=EU,DC=maxtec,DC=be"

# Activer/Désactiver un ordinateur
Enable-ADAccount -Identity "ws-compta-02"
Disable-ADAccount -Identity "ws-compta-02"
```

## 5. 🔹 Commandes Active Directory - Unités d'Organisation

### Recherche d'OU
```powershell
# Toutes les OU
Get-ADOrganizationalUnit -Filter *

# OU spécifique
Get-ADOrganizationalUnit -Identity "OU=Comptabilite,OU=EU,DC=maxtec,DC=be"

# OU avec propriétés
Get-ADOrganizationalUnit -Filter * -Properties Description, ManagedBy
```

### Gestion des OU
```powershell
# Créer une OU
New-ADOrganizationalUnit -Name "Ventes" -Path "OU=EU,DC=maxtec,DC=be"

# Modifier une OU
Set-ADOrganizationalUnit -Identity "OU=Ventes,OU=EU,DC=maxtec,DC=be" -Description "Unité organisationnelle Ventes"
```

## 6. 🔹 Commandes Pratiques - Rapports et Export

### Export vers CSV
```powershell
# Exporter tous les utilisateurs
Get-ADUser -Filter * -Properties Name, SamAccountName, Department, Title | Export-Csv -Path "rapport_utilisateurs.csv" -Encoding UTF8

# Exporter les membres d'un groupe
Get-ADGroupMember -Identity "GG-EU-RH-Users" | Select-Object Name, SamAccountName | Export-Csv -Path "membres_rh.csv" -Encoding UTF8
```

### Import CSV — Onboarding en masse
```powershell
# Fichier nouveaux_users.csv :
# Prenom,Nom,SamAccountName,Department,OU
# Pierre,Durand,pierre.durand,Comptabilite,"OU=Users,OU=Comptabilite,OU=EU,DC=maxtec,DC=be"
# Sophie,Leblanc,sophie.leblanc,RH,"OU=Users,OU=RH,OU=EU,DC=maxtec,DC=be"

$pwd = ConvertTo-SecureString "Azerty_1" -AsPlainText -Force

Import-Csv -Path "nouveaux_users.csv" | ForEach-Object {
    New-ADUser `
        -Name "$($_.Prenom) $($_.Nom)" `
        -GivenName $_.Prenom -Surname $_.Nom `
        -SamAccountName $_.SamAccountName `
        -UserPrincipalName "$($_.SamAccountName)@maxtec.be" `
        -Department $_.Department `
        -Path $_.OU `
        -AccountPassword $pwd -Enabled $true `
        -ChangePasswordAtLogon $true
}
```

### -WhatIf et -Confirm — l'assurance-vie du sysadmin
```powershell
# -WhatIf : montre ce qui SERAIT fait, sans rien exécuter
Get-ADUser -Filter {Department -eq "RH"} | Remove-ADUser -WhatIf

# Tester un import CSV avant de l'exécuter pour de vrai
Import-Csv "nouveaux_users.csv" | ForEach-Object {
    New-ADUser -Name "$($_.Prenom) $($_.Nom)" -SamAccountName $_.SamAccountName `
        -Path $_.OU -WhatIf
}

# -Confirm : demande validation interactive avant chaque action
Disable-ADAccount -Identity "marie.martin" -Confirm
```
**Règle d'or** : tout `Remove-*`, `Set-*` ou `Move-*` sur plusieurs objets se teste d'abord avec `-WhatIf`.

### Filtres avancés
```powershell
# Utilisateurs créés récemment
Get-ADUser -Filter {WhenCreated -ge (Get-Date).AddDays(-30)} -Properties WhenCreated

# Utilisateurs n'ayant pas changé leur mot de passe récemment
Get-ADUser -Filter {PasswordLastSet -le (Get-Date).AddDays(-90)} -Properties PasswordLastSet

# Groupes avec plus de 10 membres
Get-ADGroup -Filter * -Properties Members | Where-Object { $_.Members.Count -gt 10 }
```

## 7. 🔹 Commandes Système et Utilitaires

### Navigation et fichiers
```powershell
# Aller dans un répertoire
cd "C:\Scripts"

# Lister le contenu
Get-ChildItem

# Créer un fichier
New-Item -Path "rapport.txt" -ItemType File

# Lire un fichier
Get-Content -Path "rapport.txt"
```

### Gestion des erreurs
```powershell
# Ignorer les erreurs
Get-ADUser -Identity "utilisateur_inexistant" -ErrorAction SilentlyContinue

# Arrêter en cas d'erreur
Get-ADUser -Identity "utilisateur_inexistant" -ErrorAction Stop

# Continuer malgré les erreurs
Get-ADUser -Identity "utilisateur_inexistant" -ErrorAction Continue
```

## 8. 🔹 Raccourcis et Alias

### Alias courants
```powershell
# Alias de commandes
dir    # = Get-ChildItem
ls     # = Get-ChildItem
cat    # = Get-Content
echo   # = Write-Output
clear  # = Clear-Host
```

### Commandes avec alias
```powershell
# Utiliser les alias
dir | Where-Object {$_.Extension -eq ".ps1"}
echo "Bonjour" | Out-File -FilePath "salutation.txt"
```

---

## 🚀 Conseils Pratiques

1. **Toujours utiliser `-Filter *`** pour commencer vos recherches
2. **Utilisez `-Properties *`** pour voir toutes les propriétés disponibles
3. **Testez vos commandes** avec un seul objet avant de les appliquer à tous
4. **Sauvegardez vos scripts** dans des fichiers `.ps1`
5. **Utilisez les commentaires** (`#`) pour expliquer vos scripts

## 📚 Ressources Supplémentaires

- [Documentation Microsoft PowerShell](https://docs.microsoft.com/fr-fr/powershell/)
- [Module Active Directory PowerShell](https://docs.microsoft.com/fr-fr/powershell/module/activedirectory/)
- [Get-Help](https://docs.microsoft.com/fr-fr/powershell/module/microsoft.powershell.core/get-help)

---

*Ce cheat sheet couvre les commandes essentielles pour démarrer avec PowerShell et Active Directory. Pour des besoins plus avancés, consultez la documentation complète.*
