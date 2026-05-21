# Module 2 — Les 10 commandes essentielles pour le support
*Durée: 2h00 | Prérequis: Module 1 complété*

## Objectif

À la fin de ce module, vous maîtriserez les 10 commandes PowerShell AD qui couvrent la grande majorité des tickets de niveau 1 et 2.

---

## Trois types de commandes

Pour chaque problème, on enchaîne :

- **Diagnostic** — qu'est-ce qui ne va pas ?
- **Action sécurisée** — corriger sans casser.
- **Vérification** — confirmer que c'est réparé.

Cette structure se retrouve dans chacun des 10 cas qui suivent.

---

## 1. "L'utilisateur ne peut pas se connecter"

Le ticket le plus fréquent. À maîtriser parfaitement.

### Version recommandée

```powershell
# Diagnostic complet d'un utilisateur
Get-ADUser -Identity Richard -Properties * | Select-Object `
    Name, SamAccountName, Enabled, LockedOut,
    PasswordExpired, PasswordNeverExpires,
    LastLogonDate, BadPwdCount, AccountExpirationDate

# Résultat type:
Name                    : Richard
SamAccountName          : Richard
Enabled                 : True
LockedOut               : False
PasswordExpired         : False
PasswordNeverExpires    : True
LastLogonDate           : 28/09/2025 14:30:15
BadPwdCount             : 0
AccountExpirationDate   :
```

### Variante plus lourde

```powershell
# Toutes les propriétés — coûteux sur gros AD, à éviter sauf nécessité
Get-ADUser -Identity Richard -Properties *
```

### À ne pas faire

```powershell
# Charge TOUS les utilisateurs avec TOUTES les propriétés — crash potentiel
Get-ADUser -Filter * -Properties *
```

### Points clés

- Vérifier d'abord `Enabled` et `LockedOut`.
- Si `LockedOut = True` : `Unlock-ADAccount -Identity Richard -WhatIf`.
- Si `Enabled = False` : chercher pourquoi avant de réactiver.

### Exercice 2.1

Diagnostiquer pourquoi Valeria ne peut pas se connecter.

```powershell
Get-ADUser -Identity Valeria -Properties Enabled, LockedOut, PasswordExpired, LastLogonDate
```

---

## 2. Trouver un utilisateur par nom partiel

*"Je cherche l'utilisateur qui s'appelle quelque chose comme Valerie ou Valeria."*

### Version recommandée

```powershell
# Recherche par prénom approximatif
Get-ADUser -Filter {GivenName -like "Val*"} -SearchBase "OU=EU,DC=maxtec,DC=be" |
    Select-Object Name, SamAccountName, Department, Enabled

# Résultat:
Name        SamAccountName  Department  Enabled
----        --------------  ----------  -------
Valentin    Valentin        Ventes      True
Valeria     Valeria         Ventes      True
```

### Variante plus large

```powershell
# Recherche sur le Name complet — peut être lent
Get-ADUser -Filter {Name -like "*Val*"} -Properties Department
```

### À ne pas faire

```powershell
# Récupère tous les utilisateurs en mémoire avant de filtrer
Get-ADUser -Filter * | Where-Object { $_.Name -match ".*Val.*" }
```

### Points clés

- Utilisez `-SearchBase` pour limiter la portée.
- Préférez `GivenName` et `Surname` à `Name`.
- Le wildcard `*` fonctionne avec `-like`.

### Exercice 2.2

Trouver tous les utilisateurs dont le nom de famille commence par "Ch".

```powershell
Get-ADUser -Filter {Surname -like "Ch*"} -SearchBase "OU=EU,DC=maxtec,DC=be"
```

---

## 3. Ajouter un utilisateur à un groupe

*"Le nouvel employé a besoin d'accès au système comptabilité."*

### Version recommandée

```powershell
# Toujours -WhatIf d'abord
Add-ADGroupMember -Identity "GG-EU-Compta-Users" -Members Charles -WhatIf

# Vérifier les membres actuels
Get-ADGroupMember -Identity "GG-EU-Compta-Users" | Select-Object Name

# Si OK, exécuter sans -WhatIf
Add-ADGroupMember -Identity "GG-EU-Compta-Users" -Members Charles
```

### Ajout en lot

```powershell
$utilisateurs = @("Charles", "Cindy", "Charlotte")
$utilisateurs | ForEach-Object {
    Add-ADGroupMember -Identity "GG-EU-Compta-Users" -Members $_ -WhatIf
}
```

### À ne pas faire

```powershell
# Sans validation préalable — peut donner des droits admin par erreur
Add-ADGroupMember -Identity "Admins du domaine" -Members Charles
```

### Points clés

- Vérifier le groupe de destination avant ajout.
- `-WhatIf` obligatoire pour tout changement de droits.
- Confirmer après ajout avec `Get-ADGroupMember`.

### Exercice 2.3

Ajouter Rebecca au groupe RH-Admins, avec toutes les vérifications.

```powershell
# 1. Vérifier le groupe
Get-ADGroup -Identity "GG-EU-RH-Admins"

# 2. Voir les membres actuels
Get-ADGroupMember -Identity "GG-EU-RH-Admins"

# 3. Simuler
Add-ADGroupMember -Identity "GG-EU-RH-Admins" -Members Rebecca -WhatIf

# 4. Si OK, exécuter
Add-ADGroupMember -Identity "GG-EU-RH-Admins" -Members Rebecca
```

---

## 4. Voir les groupes d'un utilisateur

*"Quels sont les droits de cet utilisateur ?"*

### Version recommandée

```powershell
Get-ADPrincipalGroupMembership -Identity Richard |
    Select-Object Name, GroupScope, GroupCategory |
    Sort-Object Name

# Résultat:
Name              GroupScope  GroupCategory
----              ----------  -------------
Domain Users      Global      Security
GG-EU-RH-Admins   Global      Security
GG-EU-RH-Users    Global      Security
```

### Variante via MemberOf

```powershell
# Affiche les DN complets — moins lisible
Get-ADUser -Identity Richard -Properties MemberOf |
    Select-Object -ExpandProperty MemberOf
```

### À ne pas faire

```powershell
# Récursif sur tous les groupes — très lent
Get-ADGroup -Filter * | ForEach-Object {
    Get-ADGroupMember -Identity $_ -Recursive
}
```

### Points clés

- `Get-ADPrincipalGroupMembership` est plus lisible que `MemberOf`.
- Trier par nom facilite la lecture.
- Documenter les droits critiques observés.

### Exercice 2.4

Comparer les droits entre Ivan et Irene (tous deux IT).

```powershell
Write-Host "=== GROUPES IVAN ===" -ForegroundColor Cyan
Get-ADPrincipalGroupMembership -Identity Ivan | Select-Object Name | Sort-Object Name

Write-Host "=== GROUPES IRENE ===" -ForegroundColor Yellow
Get-ADPrincipalGroupMembership -Identity Irene | Select-Object Name | Sort-Object Name
```

---

## 5. Désactiver un compte (départ d'un collaborateur)

*"Marie quitte la société vendredi, désactiver son compte."*

### Version recommandée

```powershell
$utilisateur = "Marie"
$raisonDepart = "Fin de contrat - $(Get-Date -Format 'dd/MM/yyyy')"

# 1. Vérifier l'état actuel
Get-ADUser -Identity $utilisateur | Select-Object Name, Enabled, LastLogonDate

# 2. Simuler
Set-ADUser -Identity $utilisateur -Enabled $false -Description $raisonDepart -WhatIf

# 3. Exécuter
Set-ADUser -Identity $utilisateur -Enabled $false -Description $raisonDepart

# 4. Vérifier
Get-ADUser -Identity $utilisateur | Select-Object Name, Enabled, Description
```

### Variante avec retrait des groupes

```powershell
# Désactivation + retrait de tous les groupes sauf Domain Users
$groupes = Get-ADPrincipalGroupMembership -Identity $utilisateur |
    Where-Object { $_.Name -ne "Domain Users" }

$groupes | ForEach-Object {
    Remove-ADGroupMember -Identity $_.Name -Members $utilisateur -WhatIf
}
```

### À ne pas faire

```powershell
# Suppression directe — perte de données, problèmes d'audit
Remove-ADUser -Identity Marie -Confirm:$false
```

### Points clés

- Désactiver n'est pas supprimer. Désactivez d'abord.
- Documenter la raison dans `Description`.
- Attendre 90 jours avant suppression définitive.

---

## 6. Réinitialiser un mot de passe

*"L'utilisateur a oublié son mot de passe."*

### Version recommandée

```powershell
# Mot de passe temporaire généré aléatoirement
$motDePasseTemp = "TempPass$(Get-Random -Minimum 1000 -Maximum 9999)!"

# 1. Vérifier l'utilisateur
Get-ADUser -Identity Charles | Select-Object Name, Enabled

# 2. Reset + obligation de changer au prochain logon
Set-ADAccountPassword -Identity Charles -Reset -NewPassword (ConvertTo-SecureString $motDePasseTemp -AsPlainText -Force)
Set-ADUser -Identity Charles -ChangePasswordAtLogon $true

# 3. Communiquer par canal sécurisé (téléphone, en personne — pas email/chat)
Write-Host "Mot de passe temporaire généré pour Charles" -ForegroundColor Green
```

### Variante interactive

```powershell
# Demander le mot de passe à l'admin (entrée masquée)
$nouveauMDP = Read-Host "Nouveau mot de passe" -AsSecureString
Set-ADAccountPassword -Identity Charles -Reset -NewPassword $nouveauMDP
```

### À ne pas faire

```powershell
# Mot de passe en clair dans le script — visible dans l'historique
Set-ADAccountPassword -Identity Charles -NewPassword "Password123"
```

### Points clés

- Toujours forcer le changement au prochain logon.
- Jamais de mot de passe en clair dans un script.
- Transmettre par canal sécurisé.

---

## 7. Trouver les comptes verrouillés

*"Plusieurs utilisateurs disent qu'ils ne peuvent pas se connecter."*

### Version recommandée

```powershell
# Liste des comptes verrouillés sous OU=EU
Get-ADUser -Filter {LockedOut -eq $true} -SearchBase "OU=EU,DC=maxtec,DC=be" -Properties LockedOut, LastBadPasswordAttempt, BadPwdCount |
    Select-Object Name, SamAccountName, LastBadPasswordAttempt, BadPwdCount |
    Format-Table -AutoSize

# Déverrouiller en simulation d'abord
Get-ADUser -Filter {LockedOut -eq $true} -SearchBase "OU=EU,DC=maxtec,DC=be" |
    Unlock-ADAccount -WhatIf
```

### Variante avec Search-ADAccount

```powershell
Search-ADAccount -LockedOut -SearchBase "OU=EU,DC=maxtec,DC=be" |
    Get-ADUser -Properties LastBadPasswordAttempt, BadPwdCount, LastLogonDate
```

### À ne pas faire

```powershell
# Déverrouillage en masse sans diagnostic — masque les tentatives d'intrusion
Get-ADUser -Filter {LockedOut -eq $true} | Unlock-ADAccount
```

### Points clés

- Vérifier la cause avant de déverrouiller.
- Chercher des patterns (même heure, même IP source).
- Alerter la sécurité si beaucoup de comptes affectés.

---

## 8. Créer un nouvel utilisateur (onboarding)

*"Nouveau collaborateur lundi, préparer son compte."*

### Version recommandée

```powershell
$prenom = "Marie"
$nom = "Dubois"
$department = "Ventes"
$motDePasseTemp = "Welcome$(Get-Random -Minimum 100 -Maximum 999)!"

$samAccountName = "$prenom.$nom".ToLower()
$userPrincipalName = "$samAccountName@maxtec.be"
$displayName = "$prenom $nom"
$ouPath = "OU=Users,OU=$department,OU=EU,DC=maxtec,DC=be"

# Vérifier que l'OU existe
try {
    Get-ADOrganizationalUnit -Identity $ouPath -ErrorAction Stop
    Write-Host "OU trouvée: $ouPath" -ForegroundColor Green
} catch {
    Write-Error "OU non trouvée: $ouPath"
    break
}

# Création — simuler d'abord
$parametres = @{
    Name                  = $displayName
    SamAccountName        = $samAccountName
    UserPrincipalName     = $userPrincipalName
    GivenName             = $prenom
    Surname               = $nom
    DisplayName           = $displayName
    Department            = $department
    Path                  = $ouPath
    AccountPassword       = (ConvertTo-SecureString $motDePasseTemp -AsPlainText -Force)
    ChangePasswordAtLogon = $true
    Enabled               = $true
}

New-ADUser @parametres -WhatIf
```

### Exercice 2.8

Créer l'utilisateur Sophie Martin pour le département IT en adaptant le script ci-dessus.

---

## 9. Vérifier l'état du domaine et de la réplication

*"Les changements ne se propagent pas entre serveurs."*

### Version recommandée

```powershell
# État du domaine
Get-ADDomain | Select-Object DNSRoot, DomainMode, PDCEmulator

# Contrôleurs de domaine
Get-ADDomainController -Filter * | Select-Object Name, IPv4Address, OperatingSystem

# Test rapide via création d'objet (simulation)
New-ADOrganizationalUnit -Name "Test-Replication" -Path "DC=maxtec,DC=be" -WhatIf
```

### Points clés

- Tester avant de blâmer la réplication.
- Vérifier que les services AD tournent sur le DC.
- Laisser 15 minutes avant de conclure à un problème.

---

## 10. Audit des droits administrateurs

*"Qui a les droits admin dans notre domaine ?"*

### Version recommandée

```powershell
$groupesPrivileges = @(
    "Admins du domaine",
    "Enterprise Admins",
    "Schema Admins",
    "Account Operators",
    "Server Operators"
)

foreach ($groupe in $groupesPrivileges) {
    try {
        Write-Host "=== $groupe ===" -ForegroundColor Cyan
        Get-ADGroupMember -Identity $groupe -ErrorAction Stop |
            Select-Object Name, SamAccountName, ObjectClass |
            Format-Table -AutoSize
    } catch {
        Write-Host "Groupe $groupe non trouvé ou inaccessible" -ForegroundColor Yellow
    }
}
```

---

## Récapitulatif — les 10 commandes

1. **Diagnostic utilisateur** : `Get-ADUser -Identity X -Properties *`
2. **Recherche partielle** : `Get-ADUser -Filter {Name -like "*X*"}`
3. **Ajouter au groupe** : `Add-ADGroupMember -Identity Y -Members X -WhatIf`
4. **Voir les groupes** : `Get-ADPrincipalGroupMembership -Identity X`
5. **Désactiver un compte** : `Set-ADUser -Identity X -Enabled $false -WhatIf`
6. **Reset password** : `Set-ADAccountPassword -Identity X -Reset`
7. **Comptes verrouillés** : `Get-ADUser -Filter {LockedOut -eq $true}`
8. **Créer un utilisateur** : `New-ADUser @parametres -WhatIf`
9. **Vérifier le domaine** : `Get-ADDomain`
10. **Audit admins** : `Get-ADGroupMember -Identity "Admins du domaine"`

Pour chaque commande, gardez en tête la séquence : **diagnostic → action → vérification**.

---

## Quiz — réflexes de support (10 min)

Lundi 8h, cinq tickets urgents :

1. Charles ne peut plus se connecter depuis vendredi.
2. Nouvelle stagiaire Sophie doit accéder aux dossiers Ventes.
3. Liste des utilisateurs qui n'ont jamais changé leur mot de passe.
4. Marie part aujourd'hui, désactiver son compte.
5. Vérifier qui a les droits Domain Admin.

Écrivez la commande PowerShell correspondante (une ligne par ticket).

**Réponses :**

```powershell
# 1
Get-ADUser -Identity Charles -Properties Enabled, LockedOut, LastLogonDate

# 2
Add-ADGroupMember -Identity "GG-EU-Ventes-Users" -Members Sophie -WhatIf

# 3
Get-ADUser -Filter * -Properties PasswordLastSet | Where-Object { $_.PasswordLastSet -eq $null }

# 4
Set-ADUser -Identity Marie -Enabled $false -WhatIf

# 5
Get-ADGroupMember -Identity "Admins du domaine"
```

---

**Suite** : Module 3 — Utiliser une IA comme copilote (prompts efficaces et validation critique).
