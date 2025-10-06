# Module 1: Réalité 2025 - Comment les Admins Travaillent Vraiment
*Durée: 2h00 | Prérequis: Chapitres 9.0-9.3 complétés*

## 🎯 Objectif de ce Module
**À la fin**: Vous comprendrez comment les admins PowerShell travaillent VRAIMENT en 2025, pas comment les livres disent qu'on devrait travailler.

---

## 🔥 Ouverture

### La Vérité 2025
```
❌ MYTHE: Les pros mémorisent toute la syntaxe
✅ RÉALITÉ: Les pros savent VALIDER et ADAPTER rapidement

❌ MYTHE: Utiliser Google/IA c'est tricher
✅ RÉALITÉ: Ne pas utiliser les outils disponibles c'est être inefficace

❌ MYTHE: Il faut tout écrire from scratch
✅ RÉALITÉ: Il faut savoir LIRE et VALIDER du code existant
```

---

## 📱 Démonstration en Direct: "Mon Lundi Typique" (30 min)

*L'instructeur travaille en temps réel devant la classe*

### Scénario: Ticket #2847 - "Richard ne peut pas se connecter"

**Étape 1: Je ne connais pas la syntaxe exacte**
```powershell
# Moi, admin avec 5 ans d'expérience, je google:
# "PowerShell check if AD user is locked out"
```

**Étape 2: Je trouve et j'adapte**
```powershell
# Trouvé sur internet, je l'adapte pour maxtec.be:
Get-ADUser -Identity Richard -Properties LockedOut, LastBadPasswordAttempt, BadPwdCount

# Résultat sur maxtec.be:
DistinguishedName      : CN=Richard,OU=Users,OU=RH,OU=EU,DC=maxtec,DC=be
Enabled               : True
GivenName             : Richard
LockedOut             : False
BadPwdCount           : 0
LastBadPasswordAttempt:
Name                  : Richard
SamAccountName        : Richard
Surname               :
UserPrincipalName     : Richard@maxtec.be
```

**Étape 3: J'analyse et documentation**
```powershell
# Compte pas verrouillé, donc autre problème
# Je check les groupes:
Get-ADPrincipalGroupMembership -Identity Richard | Select-Object Name

# Résultat:
Name
----
Domain Users
GG-EU-RH-Users
```

**Étape 4: Je rapporte au ticket**
```
RÉSOLUTION TICKET #2847:
- Compte Richard: ACTIF, pas verrouillé
- Membre de: Domain Users, GG-EU-RH-Users
- Problème probablement ailleurs (réseau, poste client)
- Escalade niveau 2 réseau
```

### Idée de base
*"Voilà comment on peut travailler vraiment. On google, on adapte, on teste, on documente. Aucun admin ne mémorise 500 cmdlets. Notre valeur ajoutée c'est de COMPRENDRE ce qu'on fait, pas de tout retenir."*

---

## 🧠 Les Compétences Qui Comptent Vraiment

### Compétence #1: Lecture Critique de Scripts

**Exercice Pratique**: Analysons ce script trouvé sur internet
```powershell
# Script: "Nettoyer comptes inactifs"
# Source: Reddit r/PowerShell

Get-ADUser -Filter * | Where-Object {
    $_.LastLogonDate -lt (Get-Date).AddDays(-90) -and
    $_.Enabled -eq $true
} | Disable-ADAccount-error-expres-ici

Write-Host "Comptes désactivés avec succès!"
```

**Questions à se poser:**

1. ⚠️ **Portée**: Ça affecte TOUS les utilisateurs du domaine ?
2. ⚠️ **Sécurité**: Y a-t-il des comptes critiques à exclure ?
3. ⚠️ **Validation**: Comment je vérifie avant d'exécuter ?
4. ⚠️ **Rollback**: Comment annuler si erreur ?

**Version Sécurisée pour maxtec.be:**
```powershell
# Version SÉCURISÉE pour production
$dateLimit = (Get-Date).AddDays(-90)
$searchBase = "OU=EU,DC=maxtec,DC=be"

# D'ABORD: voir ce qui serait affecté
Get-ADUser -Filter * -SearchBase $searchBase -Properties LastLogonDate |
    Where-Object {
        $_.LastLogonDate -lt $dateLimit -and
        $_.Enabled -eq $true -and
        $_.SamAccountName -notlike "*admin*"
    } |
    Select-Object Name, LastLogonDate, Department |
    Format-Table -AutoSize

# ENSUITE: exécuter avec -WhatIf
Get-ADUser -Filter * -SearchBase $searchBase -Properties LastLogonDate |
    Where-Object {
        $_.LastLogonDate -lt $dateLimit -and
        $_.Enabled -eq $true -and
        $_.SamAccountName -notlike "*admin*"
    } |
    Disable-ADAccount -WhatIf
```

### Compétence #2: Utilisation Intelligente de l'IA

**Démo ChatGPT (ou Windsurf, Cursor ou autre) en Direct**

**Prompt**:
```
Crée un script PowerShell pour Active Directory qui:
- Trouve tous les utilisateurs du département "RH"
- Qui n'ont pas changé leur mot de passe depuis 6 mois
- Affiche leur nom et date de dernier changement
- INCLUS les validations de sécurité et -WhatIf
- Pour le domaine maxtec.be
```

**Réponse IA (exemple):**
```powershell
# Script généré par IA - À VALIDER AVANT USAGE
Import-Module ActiveDirectory

$dateLimit = (Get-Date).AddDays(-180)  # 6 mois
$searchBase = "OU=RH,OU=EU,DC=maxtec,DC=be"

try {
    # Vérifier que le module AD est disponible
    if (-not (Get-Module ActiveDirectory)) {
        throw "Module ActiveDirectory non disponible"
    }

    # Obtenir les utilisateurs RH avec date changement mot de passe
    $utilisateursRH = Get-ADUser -Filter {Department -eq "RH"} -SearchBase $searchBase `
                      -Properties PasswordLastSet, Department -ErrorAction Stop

    # Filtrer ceux avec mot de passe ancien
    $utilisateursMotDePasseAncien = $utilisateursRH | Where-Object {
        $_.PasswordLastSet -lt $dateLimit -and $_.Enabled -eq $true
    }

    if ($utilisateursMotDePasseAncien.Count -eq 0) {
        Write-Host "Aucun utilisateur RH avec mot de passe ancien trouvé." -ForegroundColor Green
    } else {
        Write-Host "Utilisateurs RH avec mot de passe > 6 mois:" -ForegroundColor Yellow
        $utilisateursMotDePasseAncien | Select-Object Name, PasswordLastSet | Format-Table -AutoSize
    }
}
catch {
    Write-Error "Erreur lors de l'exécution: $($_.Exception.Message)"
}
```

**Validation Critique:**

- ✅ **Bon**: Gestion d'erreurs, vérifications
- ✅ **Bon**: SearchBase spécifique à maxtec.be
- ⚠️ **Attention**: Filtrer par Department peut ne pas marcher si la propriété Department est vide! Observez sa valeur dans les utilisateurs et ordinateurs d'AD
- ⚠️ **Amélioration**: Ajouter exclusions pour comptes service

### 🎯 Exercice Pratique 1.1 (15 min)
**Mission**: Trouvez tous les utilisateurs du département IT de maxtec.be

1. **Sans regarder vos notes**, utilisez Google/ChatGPT pour trouver la syntaxe
2. **Adaptez** pour l'infrastructure maxtec.be
3. **Testez** sur votre labo
4. **Documentez** le résultat

**Solution Suggérée:**
```powershell
# Méthode 1: Par SearchBase (si structure OU claire)
Get-ADUser -Filter * -SearchBase "OU=IT,OU=EU,DC=maxtec,DC=be" |
    Select-Object Name, SamAccountName, Enabled

# Méthode 2: Par propriété Department (si renseignée)
Get-ADUser -Filter {Department -eq "IT"} -Properties Department |
    Select-Object Name, SamAccountName, Department, Enabled

# Vérification: comparer les deux résultats
```

---

## 💡 L'Art de Googler Efficacement (20 min)

### Mots-Clés Magiques pour PowerShell AD

**Templates de Recherche Qui Marchent:**
```
"PowerShell Active Directory [action]"
"Get-ADUser [critère] example"
"PowerShell AD [object] properties"
"Set-ADUser [property] bulk"
```

**Exemples Concrets:**
- `"PowerShell Active Directory find users by department"`
- `"Get-ADUser locked out example"`
- `"PowerShell AD group members bulk add"`

### Sites de Confiance (Dans l'Ordre)
1. **docs.microsoft.com** - Documentation officielle
2. **Stack Overflow** - Solutions communauté (VALIDER d'abord)
3. **Reddit r/PowerShell** - Cas réels (ADAPTER toujours)
4. **TechNet/Spiceworks** - Scripts pros (COMPRENDRE avant utiliser)

### 🚨 Red Flags à Éviter
```
❌ Scripts sans commentaires
❌ Get-ADUser -Filter * sans limitations
❌ Remove-* sans -WhatIf
❌ Mots de passe en dur dans le code
❌ Scripts de sites douteux (.zip, .rar)
```

---

## 🔍 Exercice Réaliste: "Support Niveau 1" 

### Scénario: Ticket Multiple

Vous recevez ces 3 tickets simultanément lundi matin:

1. **Ticket #2851**: "Valeria ne peut pas accéder au dossier Ventes"
2. **Ticket #2852**: "Nouveau stagiaire Charles2 doit avoir les mêmes droits que Charles"
3. **Ticket #2853**: "Liste des utilisateurs qui n'ont jamais changé leur mot de passe"

### Mission

1. **Trouvez** la syntaxe PowerShell pour chaque problème (Google/IA permis)
2. **Testez** sur maxtec.be
3. **Documentez** votre approche
4. **Présentez** vos solutions à la classe

### Solutions Proposées

**Ticket #2851: Droits Valeria**
```powershell
# Étape 1: Vérifier groupes de Valeria
Get-ADPrincipalGroupMembership -Identity Valeria | Select-Object Name

# Résultat attendu maxtec.be:
Name
----
Domain Users
GG-EU-Ventes-Users

# Étape 2: Vérifier si elle devrait être dans Ventes-Admins
Get-ADGroupMember -Identity "GG-EU-Ventes-Admins" | Select-Object Name

# Étape 3: Si nécessaire, ajouter (avec -WhatIf d'abord)
Add-ADGroupMember -Identity "GG-EU-Ventes-Admins" -Members Valeria -WhatIf
```

**Ticket #2852: Copier droits Charles vers Charles2**
```powershell
# Étape 1: Voir groupes de Charles
$groupesCharles = Get-ADPrincipalGroupMembership -Identity Charles | Select-Object -ExpandProperty Name

# Étape 2: Vérifier si Charles2 existe
try {
    Get-ADUser -Identity Charles2 -ErrorAction Stop
    Write-Host "Charles2 existe" -ForegroundColor Green
} catch {
    Write-Host "Charles2 n'existe pas - créer d'abord" -ForegroundColor Red
}

# Étape 3: Ajouter Charles2 aux mêmes groupes (sans Domain Users)
$groupesCharles | Where-Object {$_ -ne "Domain Users"} | ForEach-Object {
    Add-ADGroupMember -Identity $_ -Members Charles2 -WhatIf
}
```

**Ticket #2853: Utilisateurs sans changement mot de passe**
```powershell
# Chercher utilisateurs avec PasswordLastSet null ou très ancien
Get-ADUser -Filter * -SearchBase "OU=EU,DC=maxtec,DC=be" -Properties PasswordLastSet, PasswordNeverExpires |
    Where-Object {
        ($_.PasswordLastSet -eq $null -or $_.PasswordLastSet -lt (Get-Date "2020-01-01")) -and
        $_.Enabled -eq $true
    } |
    Select-Object Name, SamAccountName, PasswordLastSet, PasswordNeverExpires |
    Format-Table -AutoSize
```

---

## 🎓 Récapitulatif: Les 5 Réalités 2025 

### 1. **Google/IA sont des Outils Professionnels**
- Utiliser = efficacité, pas paresse
- Valider = responsabilité professionnelle

### 2. **Lecture > Écriture**
- 80% du temps: comprendre/adapter code existant
- 20% du temps: écrire from scratch

### 3. **-WhatIf est Roi**
- JAMAIS exécuter commandes destructives sans -WhatIf d'abord
- Votre carrière en dépend

### 4. **Documentation Live**
- Commentaires dans scripts
- Tickets avec résolutions claires
- Historique des actions

### 5. **Environnement = Contexte**
- Script générique ≠ script production
- Adapter TOUJOURS à votre infrastructure
- maxtec.be ≠ contoso.com ≠ votre vraie boîte

---

## ✅ Check de Compréhension

**Avant de passer au Module 2, assurez-vous de pouvoir répondre:**

1. "Où trouvez-vous la syntaxe pour une commande PowerShell que vous ne connaissez pas ?"
2. "Comment vérifiez-vous qu'un script trouvé sur internet est sûr pour votre environnement ?"
3. "Quelle est la première chose à faire avant d'exécuter une commande Remove-* ?"

---

*☕ **PAUSE OBLIGATOIRE 15 minutes** - Discussions informelles encouragées*

---

**🎯 Prochaine étape**: Module 2 - Les 10 Commandes de Survie qui Sauvent des Carrières