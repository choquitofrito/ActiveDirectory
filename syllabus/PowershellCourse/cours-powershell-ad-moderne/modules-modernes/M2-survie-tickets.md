# Module 2: Survie Tickets - Les 10 Commandes Qui Sauvent des Carrières
*Durée: 2h00 | Prérequis: Module 1 complété*

## 🎯 Objectif de ce Module
**À la fin**: Vous maîtriserez les 10 commandes PowerShell AD qui résolvent 90% des tickets de niveau 1 et 2.

---

## 🚨 Philosophie de Survie

### Règle d'Or du Support
```
🔥 TICKET OUVERT = HORLOGE QUI TOURNE
⏰ TEMPS = ARGENT = RÉPUTATION
🎯 RÉSOLUTION RAPIDE > SOLUTION PARFAITE
```

### Les 3 Types de Commandes
- 🔍 **DIAGNOSTIC** (Qu'est-ce qui ne va pas ?)
- 🔧 **ACTION SÉCURISÉE** (Réparer sans casser)
- 📋 **VÉRIFICATION** (Confirmer que c'est réparé)

---

## 🥇 Commande #1: "L'utilisateur ne peut pas se connecter"
*Ticket le plus fréquent - Maîtrisez-le parfaitement*

### ✅ VERSION SÉCURISÉE
```powershell
# DIAGNOSTIC complet utilisateur
Get-ADUser -Identity Richard -Properties * | Select-Object `
    Name, SamAccountName, Enabled, LockedOut,
    PasswordExpired, PasswordNeverExpires,
    LastLogonDate, BadPwdCount, AccountExpirationDate

# Résultat attendu maxtec.be:
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

### ⚠️ VERSION AVEC PRÉCAUTION
```powershell
# Plus d'infos mais plus lent
Get-ADUser -Identity Richard -Properties *
# Récupère TOUTES les propriétés - lourd sur gros AD
```

### 🔴 VERSION DANGEREUSE - JAMAIS
```powershell
# ☠️ JAMAIS faire ça
Get-ADUser -Filter * -Properties *
# Charge TOUS les utilisateurs avec TOUTES les propriétés = crash serveur
```

### 💡 TIPS DE SURVIE
- **Toujours** commencer par vérifier `Enabled` et `LockedOut`
- **Si LockedOut = True**: `Unlock-ADAccount -Identity Richard -WhatIf`
- **Si Enabled = False**: Chercher pourquoi avant de réactiver

### 🎯 EXERCICE PRATIQUE 2.1
**Mission**: Diagnostiquer pourquoi Valeria ne peut pas se connecter
```powershell
# Votre commande ici:

# Réponse attendue:
Get-ADUser -Identity Valeria -Properties Enabled, LockedOut, PasswordExpired, LastLogonDate
```

---

## 🥈 Commande #2: "Trouver utilisateur par nom partiel"
*"Je cherche l'utilisateur qui s'appelle quelque chose comme Marie ou Maria"*

### ✅ VERSION SÉCURISÉE
```powershell
# Recherche par prénom approximatif dans maxtec.be
Get-ADUser -Filter {GivenName -like "Val*"} -SearchBase "OU=EU,DC=maxtec,DC=be" |
    Select-Object Name, SamAccountName, Department, Enabled

# Résultat maxtec.be:
Name            SamAccountName    Department    Enabled
----            --------------    ----------    -------
Valentin        Valentin         Ventes        True
Valeria         Valeria          Ventes        True
```

### ⚠️ VERSION AVEC PRÉCAUTION
```powershell
# Recherche dans Name (nom complet) - peut être lent
Get-ADUser -Filter {Name -like "*Val*"} -Properties Department
```

### 🔴 VERSION DANGEREUSE - JAMAIS
```powershell
# ☠️ JAMAIS - regex sur tous les utilisateurs
Get-ADUser -Filter * | Where-Object {$_.Name -match ".*Val.*"}
```

### 💡 TIPS DE SURVIE
- **Utilisez** `-SearchBase` pour limiter la portée
- **Préférez** `GivenName` et `Surname` à `Name`
- **Wildcard** `*` fonctionne avec `-like`

### 🎯 EXERCICE PRATIQUE 2.2
**Mission**: Trouvez tous les utilisateurs dont le nom commence par "Ch"
```powershell
# Votre solution:
Get-ADUser -Filter {Surname -like "Ch*"} -SearchBase "OU=EU,DC=maxtec,DC=be"
```

---

## 🥉 Commande #3: "Ajouter utilisateur à un groupe"
*"Le nouvel employé a besoin d'accès au système comptabilité"*

### ✅ VERSION SÉCURISÉE
```powershell
# TOUJOURS -WhatIf d'abord !
Add-ADGroupMember -Identity "GG-EU-Compta-Users" -Members Charles -WhatIf

# Vérifier AVANT:
Write-Host "Membres actuels du groupe:"
Get-ADGroupMember -Identity "GG-EU-Compta-Users" | Select-Object Name

# Puis exécuter sans -WhatIf si OK:
Add-ADGroupMember -Identity "GG-EU-Compta-Users" -Members Charles
```

### ⚠️ VERSION AVEC PRÉCAUTION
```powershell
# Ajout multiple - vérifier chaque utilisateur existe
$utilisateurs = @("Charles", "Cindy", "Charlotte")
$utilisateurs | ForEach-Object {
    Add-ADGroupMember -Identity "GG-EU-Compta-Users" -Members $_ -WhatIf
}
```

### 🔴 VERSION DANGEREUSE - JAMAIS
```powershell
# ☠️ Sans validation ni -WhatIf
Add-ADGroupMember -Identity "Admins du domaine" -Members Charles
# Peut donner des droits admin à tort !
```

### 💡 TIPS DE SURVIE
- **Vérifiez** le groupe de destination avant d'ajouter
- **-WhatIf** est obligatoire pour changements de droits
- **Confirmez** après ajout avec `Get-ADGroupMember`

### 🎯 EXERCICE PRATIQUE 2.3
**Mission**: Ajouter Rebecca au groupe RH-Admins (avec toutes les sécurités)
```powershell
# 1. Vérifier le groupe existe:
Get-ADGroup -Identity "GG-EU-RH-Admins"

# 2. Voir membres actuels:
Get-ADGroupMember -Identity "GG-EU-RH-Admins"

# 3. Ajouter avec -WhatIf:
Add-ADGroupMember -Identity "GG-EU-RH-Admins" -Members Rebecca -WhatIf

# 4. Si OK, exécuter:
Add-ADGroupMember -Identity "GG-EU-RH-Admins" -Members Rebecca
```

---

## 🏅 Commande #4: "Voir les groupes d'un utilisateur"
*"Quels sont les droits de cet utilisateur ?"*

### ✅ VERSION SÉCURISÉE
```powershell
# Voir tous les groupes de Richard avec noms lisibles
Get-ADPrincipalGroupMembership -Identity Richard |
    Select-Object Name, GroupScope, GroupCategory |
    Sort-Object Name

# Résultat maxtec.be:
Name                GroupScope    GroupCategory
----                ----------    -------------
Domain Users        Global        Security
GG-EU-RH-Admins    Global        Security
GG-EU-RH-Users     Global        Security
```

### ⚠️ VERSION AVEC PRÉCAUTION
```powershell
# Plus d'infos mais plus complexe à lire
Get-ADUser -Identity Richard -Properties MemberOf |
    Select-Object -ExpandProperty MemberOf
# Affiche les DN complets (difficiles à lire)
```

### 🔴 VERSION DANGEREUSE - JAMAIS
```powershell
# ☠️ Récursif sur tous les groupes - très lent
Get-ADGroup -Filter * | ForEach-Object {
    Get-ADGroupMember -Identity $_ -Recursive
}
```

### 💡 TIPS DE SURVIE
- **Get-ADPrincipalGroupMembership** plus lisible que MemberOf
- **Triez** par nom pour faciliter lecture
- **Documentez** les droits critiques trouvés

### 🎯 EXERCICE PRATIQUE 2.4
**Mission**: Comparez les droits entre Ivan et Irene (tous deux IT)
```powershell
# Droits Ivan:
Write-Host "=== GROUPES IVAN ===" -ForegroundColor Cyan
Get-ADPrincipalGroupMembership -Identity Ivan | Select-Object Name | Sort-Object Name

# Droits Irene:
Write-Host "=== GROUPES IRENE ===" -ForegroundColor Yellow
Get-ADPrincipalGroupMembership -Identity Irene | Select-Object Name | Sort-Object Name
```

---

## 🏆 Commande #5: "Désactiver compte utilisateur (départ)"
*"Marie quitte la société vendredi, désactiver son compte"*

### ✅ VERSION SÉCURISÉE
```powershell
# TOUJOURS -WhatIf d'abord + documentation
$utilisateur = "Marie"
$raisonDepart = "Fin de contrat - $(Get-Date -Format 'dd/MM/yyyy')"

# 1. Vérifier l'utilisateur existe et est actif
Get-ADUser -Identity $utilisateur | Select-Object Name, Enabled, LastLogonDate

# 2. Désactiver avec -WhatIf
Set-ADUser -Identity $utilisateur -Enabled $false -Description $raisonDepart -WhatIf

# 3. Si OK, exécuter sans -WhatIf
Set-ADUser -Identity $utilisateur -Enabled $false -Description $raisonDepart

# 4. Vérifier résultat
Get-ADUser -Identity $utilisateur | Select-Object Name, Enabled, Description
```

### ⚠️ VERSION AVEC PRÉCAUTION
```powershell
# Désactivation + retrait de tous les groupes (sauf Domain Users)
$groupes = Get-ADPrincipalGroupMembership -Identity $utilisateur |
           Where-Object {$_.Name -ne "Domain Users"}
$groupes | ForEach-Object {
    Remove-ADGroupMember -Identity $_.Name -Members $utilisateur -WhatIf
}
```

### 🔴 VERSION DANGEREUSE - JAMAIS
```powershell
# ☠️ Supprimer directement sans désactiver d'abord
Remove-ADUser -Identity Marie -Confirm:$false
# Perte définitive de données + problèmes d'audit !
```

### 💡 TIPS DE SURVIE
- **Désactiver ≠ Supprimer** (désactivez d'abord)
- **Documentez** la raison dans Description
- **Attendez** 90 jours avant suppression définitive

---

## 🎖️ Commande #6: "Réinitialiser mot de passe"
*"L'utilisateur a oublié son mot de passe"*

### ✅ VERSION SÉCURISÉE
```powershell
# Génération mot de passe temporaire sécurisé
$motDePasseTemp = "TempPass$(Get-Random -Minimum 1000 -Maximum 9999)!"

# 1. Vérifier l'utilisateur
Get-ADUser -Identity Charles | Select-Object Name, Enabled

# 2. Reset avec obligation de changer au prochain logon
Set-ADAccountPassword -Identity Charles -Reset -NewPassword (ConvertTo-SecureString $motDePasseTemp -AsPlainText -Force)
Set-ADUser -Identity Charles -ChangePasswordAtLogon $true

# 3. Documenter et communiquer de façon sécurisée
Write-Host "Mot de passe temporaire généré pour Charles" -ForegroundColor Green
Write-Host "Communiquer par canal sécurisé (pas email/chat)" -ForegroundColor Yellow
```

### ⚠️ VERSION AVEC PRÉCAUTION
```powershell
# Permettre mots de passe utilisateur (moins sécurisé)
$nouveauMDP = Read-Host "Nouveau mot de passe" -AsSecureString
Set-ADAccountPassword -Identity Charles -Reset -NewPassword $nouveauMDP
```

### 🔴 VERSION DANGEREUSE - JAMAIS
```powershell
# ☠️ Mot de passe en clair dans le script
Set-ADAccountPassword -Identity Charles -NewPassword "Password123"
# Visible dans historique PowerShell !
```

### 💡 TIPS DE SURVIE
- **Toujours** forcer changement au prochain logon
- **Jamais** de mots de passe en clair dans scripts
- **Communiquer** par canal sécurisé (téléphone, en personne)

---

## 🏵️ Commande #7: "Trouver comptes verrouillés"
*"Plusieurs utilisateurs disent qu'ils ne peuvent pas se connecter"*

### ✅ VERSION SÉCURISÉE
```powershell
# Chercher tous les comptes verrouillés dans maxtec.be
Get-ADUser -Filter {LockedOut -eq $true} -SearchBase "OU=EU,DC=maxtec,DC=be" -Properties LockedOut, LastBadPasswordAttempt, BadPwdCount |
    Select-Object Name, SamAccountName, LastBadPasswordAttempt, BadPwdCount |
    Format-Table -AutoSize

# Si des comptes trouvés, déverrouiller avec -WhatIf d'abord
Get-ADUser -Filter {LockedOut -eq $true} -SearchBase "OU=EU,DC=maxtec,DC=be" |
    Unlock-ADAccount -WhatIf
```

### ⚠️ VERSION AVEC PRÉCAUTION
```powershell
# Inclure informations de sécurité avancées
Search-ADAccount -LockedOut -SearchBase "OU=EU,DC=maxtec,DC=be" |
    Get-ADUser -Properties LastBadPasswordAttempt, BadPwdCount, LastLogonDate
```

### 🔴 VERSION DANGEREUSE - JAMAIS
```powershell
# ☠️ Déverrouillage massif sans vérification
Get-ADUser -Filter {LockedOut -eq $true} | Unlock-ADAccount
# Peut masquer des tentatives d'intrusion !
```

### 💡 TIPS DE SURVIE
- **Vérifiez** la cause avant de déverrouiller
- **Cherchez** des patterns (même heure, même IP)
- **Alertez** la sécurité si nombreux comptes affectés

---

## 🎗️ Commande #8: "Créer nouvel utilisateur (onboarding)"
*"Nouveau collaborateur lundi, préparer son compte"*

### ✅ VERSION SÉCURISÉE
```powershell
# Template création utilisateur maxtec.be
$prenom = "Marie"
$nom = "Dubois"
$department = "Ventes"
$motDePasseTemp = "Welcome$(Get-Random -Minimum 100 -Maximum 999)!"

# Construire les propriétés
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

# Créer avec -WhatIf d'abord
$parametres = @{
    Name = $displayName
    SamAccountName = $samAccountName
    UserPrincipalName = $userPrincipalName
    GivenName = $prenom
    Surname = $nom
    DisplayName = $displayName
    Department = $department
    Path = $ouPath
    AccountPassword = (ConvertTo-SecureString $motDePasseTemp -AsPlainText -Force)
    ChangePasswordAtLogon = $true
    Enabled = $true
}

New-ADUser @parametres -WhatIf
```

### 🎯 EXERCICE PRATIQUE 2.8
**Mission**: Créer l'utilisateur "Sophie Martin" pour le département IT
```powershell
# Adaptez le script ci-dessus pour Sophie Martin, département IT
```

---

## 🥇 Commande #9: "Vérifier services et réplication AD"
*"Les changements ne se propagent pas entre serveurs"*

### ✅ VERSION SÉCURISÉE
```powershell
# Vérifier santé de base du domaine
Get-ADDomain | Select-Object DNSRoot, DomainMode, PDCEmulator

# Vérifier les contrôleurs de domaine
Get-ADDomainController -Filter * | Select-Object Name, IPv4Address, OperatingSystem

# Test simple de réplication (création objet test)
$testOU = "OU=Test-Replication,DC=maxtec,DC=be"
New-ADOrganizationalUnit -Name "Test-Replication" -Path "DC=maxtec,DC=be" -WhatIf
```

### 💡 TIPS DE SURVIE
- **Testez** avant de blâmer la réplication
- **Vérifiez** les services AD sur le DC
- **Attendez** 15 minutes avant de paniquer

---

## 🏆 Commande #10: "Audit rapide des droits administrateurs"
*"Qui a les droits admin dans notre domaine ?"*

### ✅ VERSION SÉCURISÉE
```powershell
# Vérifier membres des groupes privilégiés
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

## 📋 Récapitulatif: Votre Kit de Survie

### Les 10 Commandes Essentielles
1. **Diagnostic utilisateur**: `Get-ADUser -Identity X -Properties *`
2. **Recherche partielle**: `Get-ADUser -Filter {Name -like "*X*"}`
3. **Ajouter au groupe**: `Add-ADGroupMember -Identity Y -Members X -WhatIf`
4. **Voir groupes**: `Get-ADPrincipalGroupMembership -Identity X`
5. **Désactiver compte**: `Set-ADUser -Identity X -Enabled $false -WhatIf`
6. **Reset password**: `Set-ADAccountPassword -Identity X -Reset`
7. **Comptes verrouillés**: `Get-ADUser -Filter {LockedOut -eq $true}`
8. **Créer utilisateur**: `New-ADUser @parametres -WhatIf`
9. **Vérifier domaine**: `Get-ADDomain`
10. **Audit admins**: `Get-ADGroupMember -Identity "Admins du domaine"`

### 🎯 Mémorisation: La Règle des 3
Pour chaque commande, retenez:
1. **Diagnostic** (que se passe-t-il ?)
2. **Action** (que faire ?)
3. **Vérification** (c'est réparé ?)

---

## ✅ Quiz de Survie (10 min)

**Situation**: Lundi 8h, 5 tickets urgents arrivent:

1. "Charles ne peut plus se connecter depuis vendredi"
2. "Nouvelle stagiaire Sophie doit accéder aux dossiers Ventes"
3. "Liste des utilisateurs qui n'ont jamais changé leur mot de passe"
4. "Marie part aujourd'hui, désactiver son compte"
5. "Vérifier qui a les droits Domain Admin"

**Mission**: Écrivez LA commande PowerShell pour chaque ticket (1 ligne par ticket)

**Réponses**:
```powershell
1. Get-ADUser -Identity Charles -Properties Enabled, LockedOut, LastLogonDate
2. Add-ADGroupMember -Identity "GG-EU-Ventes-Users" -Members Sophie -WhatIf
3. Get-ADUser -Filter * -Properties PasswordLastSet | Where-Object {$_.PasswordLastSet -eq $null}
4. Set-ADUser -Identity Marie -Enabled $false -WhatIf
5. Get-ADGroupMember -Identity "Admins du domaine"
```

---

*🍽️ **PAUSE DÉJEUNER OBLIGATOIRE 45 minutes** - Digérer les commandes*

---

**🎯 Prochaine étape**: Module 3 - L'IA comme Copilote (Prompts Sécurisés + Validation Critique)