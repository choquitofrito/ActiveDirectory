# Module 2 — Tickets courants : les 10 commandes du support
*Prérequis: Module 1 complété*

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

C'est le ticket le plus fréquent.

### Version recommandée

```powershell
# Diagnostic complet d'un utilisateur (seulement les propriétés utiles)
Get-ADUser -Identity Richard -Properties LockedOut, PasswordExpired, PasswordNeverExpires, LastLogonDate, BadPwdCount, AccountExpirationDate |
    Select-Object Name, SamAccountName, Enabled, LockedOut,
        PasswordExpired, PasswordNeverExpires,
        LastLogonDate, BadPwdCount, AccountExpirationDate

# Résultat type:
Name                    : Richard
SamAccountName          : richard
Enabled                 : True
LockedOut               : False
PasswordExpired         : False
PasswordNeverExpires    : False
LastLogonDate           : 28/09/2026 14:30:15
BadPwdCount             : 0
AccountExpirationDate   :
```

### Variante plus lourde

```powershell
# Toutes les propriétés - coûteux sur gros AD, à éviter sauf nécessité
Get-ADUser -Identity Richard -Properties *
```

### À ne pas faire

```powershell
# Charge tous les utilisateurs avec toutes les propriétés - très lourd sur un gros annuaire
Get-ADUser -Filter * -Properties *
```

### Points clés

- Vérifier d'abord `Enabled` et `LockedOut`.
- Si `LockedOut = True` : `Unlock-ADAccount -Identity Richard -WhatIf`.
- Si `Enabled = False` : chercher pourquoi avant de réactiver.

### Exercice 2.1

Diagnostiquer pourquoi Valeria ne peut pas se connecter.

```powershell
Get-ADUser -Identity valeria -Properties LockedOut, PasswordExpired, LastLogonDate
```

---

## 2. Trouver un utilisateur par nom partiel

*"Je cherche l'utilisateur qui s'appelle quelque chose comme Valerie ou Valeria."*

### Version recommandée

```powershell
# Recherche par prénom approximatif
Get-ADUser -Filter {GivenName -like "Val*"} -SearchBase "OU=EU,DC=maxtec,DC=be" -Properties Department |
    Select-Object Name, SamAccountName, Department, Enabled

# Résultat:
Name        SamAccountName  Department  Enabled
----        --------------  ----------  -------
Valentin    valentin        Ventes      True
Valeria     valeria         Ventes      True
```

### Variante plus large

```powershell
# Recherche sur le Name complet - peut être lent
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

Trouver tous les utilisateurs dont le nom de famille commence par "Co" (dans le lab : Collard et Cornet).

```powershell
Get-ADUser -Filter {Surname -like "Co*"} -SearchBase "OU=EU,DC=maxtec,DC=be" |
    Format-Table Name, Surname, SamAccountName
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
# Sans validation préalable - peut donner des droits admin par erreur
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
Get-ADGroup -Identity "GG-EU-RH-Admin"

# 2. Voir les membres actuels
Get-ADGroupMember -Identity "GG-EU-RH-Admin"

# 3. Simuler
Add-ADGroupMember -Identity "GG-EU-RH-Admin" -Members Rebecca -WhatIf

# 4. Si OK, exécuter
Add-ADGroupMember -Identity "GG-EU-RH-Admin" -Members Rebecca
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
Name                     GroupScope  GroupCategory
----                     ----------  -------------
GG-EU-RH-Admin           Global      Security
Utilisateurs du domaine  Global      Security
```

### Variante via MemberOf

```powershell
# Affiche les DN complets - moins lisible
Get-ADUser -Identity Richard -Properties MemberOf |
    Select-Object -ExpandProperty MemberOf
```

### À ne pas faire

```powershell
# Récursif sur tous les groupes - très lent
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

`marie.martin` n'existe pas dans le lab : créez-la comme dans la [Cheatsheet](../../../CHEATSHEET.md), section 2, pour tester.

### Version recommandée

```powershell
$utilisateur = "marie.martin"
$raisonDepart = "Fin de contrat - $(Get-Date -Format 'dd/MM/yyyy')"

# 1. Vérifier l'état actuel
Get-ADUser -Identity $utilisateur -Properties LastLogonDate | Select-Object Name, Enabled, LastLogonDate

# 2. Simuler
Set-ADUser -Identity $utilisateur -Enabled $false -Description $raisonDepart -WhatIf

# 3. Exécuter
Set-ADUser -Identity $utilisateur -Enabled $false -Description $raisonDepart

# 4. Vérifier
Get-ADUser -Identity $utilisateur -Properties Description | Select-Object Name, Enabled, Description
```

### Variante avec retrait des groupes

```powershell
# Désactivation + retrait des groupes GG- (le groupe principal « Utilisateurs du domaine »
# ne peut pas être retiré)
$groupes = Get-ADPrincipalGroupMembership -Identity $utilisateur |
    Where-Object { $_.Name -like "GG-*" }

$groupes | ForEach-Object {
    Remove-ADGroupMember -Identity $_.Name -Members $utilisateur -WhatIf
}
```

### À ne pas faire

```powershell
# Suppression directe - perte de données, problèmes d'audit
Remove-ADUser -Identity marie.martin -Confirm:$false
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

# 3. Afficher le mot de passe pour le transmettre par canal sécurisé
#    (téléphone, en personne - pas email/chat)
Write-Host "Mot de passe temporaire de charles : $motDePasseTemp" -ForegroundColor Green
```

### Variante interactive

```powershell
# Demander le mot de passe à l'admin (entrée masquée)
$nouveauMDP = Read-Host "Nouveau mot de passe" -AsSecureString
Set-ADAccountPassword -Identity Charles -Reset -NewPassword $nouveauMDP
```

### À ne pas faire

```powershell
# Mot de passe fixe écrit dans le script : lisible par quiconque ouvre le fichier,
# et le même pour tout le monde. Acceptable dans le lab (Password1!), jamais en production.
Set-ADAccountPassword -Identity charles -Reset -NewPassword (ConvertTo-SecureString "Password1!" -AsPlainText -Force)
```

### Points clés

- Toujours forcer le changement au prochain logon.
- Jamais de mot de passe fixe écrit dans un script de production.
- Transmettre par canal sécurisé.

---

## 7. Trouver les comptes verrouillés

*"Plusieurs utilisateurs disent qu'ils ne peuvent pas se connecter."*

### Version recommandée

`LockedOut` est une propriété calculée : `-Filter` ne sait pas l'utiliser. `Search-ADAccount` est fait pour ça (voir chapitre 9.2).

```powershell
# Liste des comptes verrouillés sous OU=EU, avec les détails des échecs
Search-ADAccount -LockedOut -UsersOnly -SearchBase "OU=EU,DC=maxtec,DC=be" |
    ForEach-Object {
        Get-ADUser -Identity $_.SamAccountName -Properties LastBadPasswordAttempt, BadPwdCount
    } |
    Format-Table Name, SamAccountName, LastBadPasswordAttempt, BadPwdCount

# Déverrouiller en simulation d'abord
Search-ADAccount -LockedOut -UsersOnly -SearchBase "OU=EU,DC=maxtec,DC=be" |
    Unlock-ADAccount -WhatIf
```

### À ne pas faire

```powershell
# Déverrouillage en masse sans diagnostic - masque les tentatives d'intrusion
Search-ADAccount -LockedOut | Unlock-ADAccount
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
    $ou = Get-ADOrganizationalUnit -Identity $ouPath -ErrorAction Stop
    Write-Host "OU trouvée: $ouPath" -ForegroundColor Green
} catch {
    Write-Host "OU non trouvée: $ouPath" -ForegroundColor Red
    return    # arrête le script
}

# Création - simuler d'abord
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

# Après exécution sans -WhatIf : afficher le mot de passe à transmettre
Write-Host "Mot de passe temporaire de $samAccountName : $motDePasseTemp"
```

### Exercice 2.8

Créer l'utilisateur Sophie Martin pour le département IT en adaptant le script ci-dessus.

---

## 9. Vérifier l'état du domaine et de la réplication

*"Les changements ne se propagent pas entre serveurs."*

La réplication ne concerne qu'un domaine à **plusieurs** DC. Le lab n'en a qu'un (`dns1`), sauf si vous avez suivi l'ajout d'un deuxième DC.

### Version recommandée

```powershell
# État du domaine
Get-ADDomain | Format-List DNSRoot, DomainMode, PDCEmulator

# Contrôleurs de domaine
Get-ADDomainController -Filter * | Format-Table Name, IPv4Address, OperatingSystem

# Résumé de la réplication entre DC (outil en ligne de commande, sur un DC)
repadmin /replsummary
```

### Points clés

- Tester avant de blâmer la réplication.
- Vérifier que les services AD tournent sur le DC (`dcdiag`).
- Entre DC d'un même site, un changement se réplique en quelques secondes. Entre sites, jusqu'à 3 h avec la planification par défaut.

---

## 10. Audit des droits administrateurs

*"Qui a les droits admin dans notre domaine ?"*

### Version recommandée

```powershell
# Noms d'un DC installé en français (sur un DC anglais : Domain Admins, Enterprise Admins...)
$groupesPrivileges = @(
    "Admins du domaine",
    "Administrateurs",
    "Opérateurs de compte",
    "Opérateurs de serveur"
)

foreach ($groupe in $groupesPrivileges) {
    try {
        Write-Host "=== $groupe ===" -ForegroundColor Cyan
        Get-ADGroupMember -Identity $groupe -ErrorAction Stop |
            Format-Table Name, SamAccountName, ObjectClass
    } catch {
        Write-Host "Groupe $groupe non trouvé ou inaccessible" -ForegroundColor Yellow
    }
}
```

AD marque aussi ses groupes protégés avec `adminCount = 1`, quelle que soit la langue : `Get-ADGroup -Filter "adminCount -eq 1"` en donne la liste complète.

---

## Récapitulatif — les 10 commandes

1. **Diagnostic utilisateur** : `Get-ADUser -Identity X -Properties LockedOut, LastLogonDate, BadPwdCount`
2. **Recherche partielle** : `Get-ADUser -Filter {Name -like "*X*"}`
3. **Ajouter au groupe** : `Add-ADGroupMember -Identity Y -Members X -WhatIf`
4. **Voir les groupes** : `Get-ADPrincipalGroupMembership -Identity X`
5. **Désactiver un compte** : `Set-ADUser -Identity X -Enabled $false -WhatIf`
6. **Reset password** : `Set-ADAccountPassword -Identity X -Reset`
7. **Comptes verrouillés** : `Search-ADAccount -LockedOut -UsersOnly`
8. **Créer un utilisateur** : `New-ADUser @parametres -WhatIf`
9. **Vérifier le domaine** : `Get-ADDomain`
10. **Audit admins** : `Get-ADGroupMember -Identity "Admins du domaine"`

Pour chaque commande, gardez en tête la séquence : **diagnostic → action → vérification**.

---

## Quiz — réflexes de support

Lundi 8h, cinq tickets en attente :

1. Charles ne peut plus se connecter depuis vendredi.
2. Sophie Dubois (`sophie.dubois`, créée au chapitre 9.3) doit accéder aux dossiers Ventes.
3. Liste des utilisateurs qui n'ont jamais changé leur mot de passe.
4. Marie Martin (`marie.martin`) part aujourd'hui, désactiver son compte.
5. Vérifier qui a les droits Domain Admin.

Écrivez la commande PowerShell correspondante (une ligne par ticket).

**Réponses :**

```powershell
# 1
Get-ADUser -Identity Charles -Properties Enabled, LockedOut, LastLogonDate

# 2
Add-ADGroupMember -Identity "GG-EU-Ventes-Users" -Members sophie.dubois -WhatIf

# 3 (même logique que le ticket #2853 du module 1)
Get-ADUser -Filter * -Properties PasswordLastSet, WhenCreated |
    Where-Object { $null -eq $_.PasswordLastSet -or $_.PasswordLastSet -lt $_.WhenCreated.AddMinutes(5) }

# 4
Set-ADUser -Identity marie.martin -Enabled $false -WhatIf

# 5
Get-ADGroupMember -Identity "Admins du domaine"
```

---

**Suite** : Module 3 — Utiliser une IA comme copilote (prompts efficaces et validation critique).
