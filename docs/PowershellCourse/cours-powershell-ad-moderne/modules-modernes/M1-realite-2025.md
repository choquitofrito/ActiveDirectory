# Module 1 — Comment travaillent les admins en 2025
*Durée: 2h00 | Prérequis: Chapitres 9.0-9.3 complétés*

## Objectif

À la fin de ce module, vous aurez une image réaliste de la façon dont les admins PowerShell travaillent au quotidien — par opposition à ce que les livres laissent entendre.

---

## Le point de départ

Trois idées reçues à corriger avant d'aller plus loin :

- Les pros ne mémorisent pas toute la syntaxe. Ils savent **valider et adapter** rapidement.
- Utiliser Google ou une IA n'est pas tricher. Ne pas utiliser les outils disponibles, c'est juste être lent.
- On n'écrit pas tout *from scratch*. On lit, on adapte, on teste.

Ce module est construit autour de cette réalité.

---

## Démo en direct — un lundi typique (30 min)

*L'instructeur travaille en temps réel devant la classe.*

### Ticket #2847 — "Richard ne peut pas se connecter"

**1. Je ne connais pas la syntaxe exacte par cœur.**

```powershell
# Recherche Google: "PowerShell check if AD user is locked out"
```

**2. Je trouve un exemple et je l'adapte à maxtec.be :**

```powershell
Get-ADUser -Identity Richard -Properties LockedOut, LastBadPasswordAttempt, BadPwdCount

# Résultat:
DistinguishedName      : CN=Richard,OU=Users,OU=RH,OU=EU,DC=maxtec,DC=be
Enabled                : True
GivenName              : Richard
LockedOut              : False
BadPwdCount            : 0
LastBadPasswordAttempt :
Name                   : Richard
SamAccountName         : Richard
UserPrincipalName      : Richard@maxtec.be
```

**3. J'analyse.**

```powershell
# Compte actif et non verrouillé. Le problème est ailleurs.
Get-ADPrincipalGroupMembership -Identity Richard | Select-Object Name

Name
----
Domain Users
GG-EU-RH-Users
```

**4. Je documente dans le ticket.**

```
RÉSOLUTION TICKET #2847
- Compte Richard: actif, non verrouillé
- Membre de: Domain Users, GG-EU-RH-Users
- Cause probable: réseau ou poste client
- Escalade niveau 2 réseau
```

### Ce qu'il faut retenir

On cherche, on adapte, on teste, on documente. Aucun admin ne retient 500 cmdlets. La valeur ajoutée, c'est de comprendre ce qu'on fait — pas de tout savoir par cœur.

---

## Les compétences qui comptent vraiment

### Lecture critique d'un script trouvé en ligne

Voici un script trouvé sur Reddit — "Nettoyer comptes inactifs" :

```powershell
Get-ADUser -Filter * | Where-Object {
    $_.LastLogonDate -lt (Get-Date).AddDays(-90) -and
    $_.Enabled -eq $true
} | Disable-ADAccount

Write-Host "Comptes désactivés avec succès!"
```

Avant de toucher à ça, quatre questions :

1. **Portée** — ça affecte tous les utilisateurs du domaine ?
2. **Sécurité** — quels comptes critiques doivent être exclus ?
3. **Validation** — comment je vérifie avant d'exécuter ?
4. **Rollback** — comment j'annule si erreur ?

Version adaptée pour maxtec.be :

```powershell
$dateLimit = (Get-Date).AddDays(-90)
$searchBase = "OU=EU,DC=maxtec,DC=be"

# 1. Voir d'abord ce qui serait affecté
Get-ADUser -Filter * -SearchBase $searchBase -Properties LastLogonDate |
    Where-Object {
        $_.LastLogonDate -lt $dateLimit -and
        $_.Enabled -eq $true -and
        $_.SamAccountName -notlike "*admin*"
    } |
    Select-Object Name, LastLogonDate, Department |
    Format-Table -AutoSize

# 2. Ensuite, simuler avec -WhatIf
Get-ADUser -Filter * -SearchBase $searchBase -Properties LastLogonDate |
    Where-Object {
        $_.LastLogonDate -lt $dateLimit -and
        $_.Enabled -eq $true -and
        $_.SamAccountName -notlike "*admin*"
    } |
    Disable-ADAccount -WhatIf
```

### Utilisation d'une IA comme assistant

Démo ChatGPT (ou Windsurf, Cursor, peu importe) en direct.

**Prompt :**

```
Crée un script PowerShell pour Active Directory qui:
- Trouve tous les utilisateurs du département "RH"
- Qui n'ont pas changé leur mot de passe depuis 6 mois
- Affiche leur nom et date de dernier changement
- Inclut validations de sécurité et -WhatIf
- Pour le domaine maxtec.be
```

**Réponse type :**

```powershell
# Script généré par IA — à valider avant usage
Import-Module ActiveDirectory

$dateLimit = (Get-Date).AddDays(-180)
$searchBase = "OU=RH,OU=EU,DC=maxtec,DC=be"

try {
    if (-not (Get-Module ActiveDirectory)) {
        throw "Module ActiveDirectory non disponible"
    }

    $utilisateursRH = Get-ADUser -Filter {Department -eq "RH"} -SearchBase $searchBase `
                      -Properties PasswordLastSet, Department -ErrorAction Stop

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

**Analyse critique :**

- Bon : gestion d'erreurs, SearchBase ciblée, lecture seule.
- À surveiller : le filtre `Department -eq "RH"` ne marche que si la propriété `Department` est renseignée. Vérifiez dans *Utilisateurs et ordinateurs Active Directory*. Si elle est vide sur votre lab, exécutez `scripts/Patch-UserDepartments.ps1` sur le DC.
- À améliorer : ajouter exclusion des comptes de service.

### Exercice 1.1 (15 min)

**Mission** : Trouver tous les utilisateurs du département IT de maxtec.be.

1. Sans regarder vos notes, utilisez Google ou une IA pour trouver la syntaxe.
2. Adaptez à l'infrastructure maxtec.be.
3. Testez sur votre labo.
4. Documentez le résultat.

**Solutions possibles :**

```powershell
# Méthode 1: par SearchBase
Get-ADUser -Filter * -SearchBase "OU=IT,OU=EU,DC=maxtec,DC=be" |
    Select-Object Name, SamAccountName, Enabled

# Méthode 2: par propriété Department
Get-ADUser -Filter {Department -eq "IT"} -Properties Department |
    Select-Object Name, SamAccountName, Department, Enabled

# Comparer les deux résultats
```

---

## Chercher efficacement (20 min)

### Templates de recherche qui fonctionnent

```
"PowerShell Active Directory [action]"
"Get-ADUser [critère] example"
"PowerShell AD [object] properties"
"Set-ADUser [property] bulk"
```

Exemples concrets :

- `PowerShell Active Directory find users by department`
- `Get-ADUser locked out example`
- `PowerShell AD group members bulk add`

### Sources fiables (par ordre)

1. **docs.microsoft.com** — documentation officielle
2. **Stack Overflow** — à valider avant utilisation
3. **Reddit r/PowerShell** — cas réels, toujours à adapter
4. **TechNet / Spiceworks** — à comprendre avant d'exécuter

### Signaux d'alarme à éviter

- Scripts sans commentaires
- `Get-ADUser -Filter *` sans limitations
- `Remove-*` sans `-WhatIf`
- Mots de passe en dur
- Scripts venant de sites douteux (archives `.zip`, `.rar`)

---

## Exercice — support niveau 1

Vous recevez ces 3 tickets simultanément lundi matin :

1. **Ticket #2851** — Valeria ne peut pas accéder au dossier Ventes.
2. **Ticket #2852** — Nouveau stagiaire Charles2 doit avoir les mêmes droits que Charles.
3. **Ticket #2853** — Liste des utilisateurs qui n'ont jamais changé leur mot de passe.

### Mission

1. Trouvez la syntaxe (Google ou IA autorisés).
2. Testez sur maxtec.be.
3. Documentez votre approche.
4. Présentez vos solutions.

### Solutions proposées

**#2851 — Droits de Valeria**

```powershell
# Vérifier les groupes actuels
Get-ADPrincipalGroupMembership -Identity Valeria | Select-Object Name

# Vérifier qui est dans Ventes-Admins
Get-ADGroupMember -Identity "GG-EU-Ventes-Admins" | Select-Object Name

# Si nécessaire, ajouter (avec -WhatIf d'abord)
Add-ADGroupMember -Identity "GG-EU-Ventes-Admins" -Members Valeria -WhatIf
```

**#2852 — Copier les droits de Charles vers Charles2**

```powershell
$groupesCharles = Get-ADPrincipalGroupMembership -Identity Charles |
    Select-Object -ExpandProperty Name

try {
    Get-ADUser -Identity Charles2 -ErrorAction Stop
    Write-Host "Charles2 existe" -ForegroundColor Green
} catch {
    Write-Host "Charles2 n'existe pas — créer d'abord" -ForegroundColor Red
}

$groupesCharles | Where-Object { $_ -ne "Domain Users" } | ForEach-Object {
    Add-ADGroupMember -Identity $_ -Members Charles2 -WhatIf
}
```

**#2853 — Utilisateurs sans changement de mot de passe**

```powershell
Get-ADUser -Filter * -SearchBase "OU=EU,DC=maxtec,DC=be" -Properties PasswordLastSet, PasswordNeverExpires |
    Where-Object {
        ($_.PasswordLastSet -eq $null -or $_.PasswordLastSet -lt (Get-Date "2020-01-01")) -and
        $_.Enabled -eq $true
    } |
    Select-Object Name, SamAccountName, PasswordLastSet, PasswordNeverExpires |
    Format-Table -AutoSize
```

---

## Récapitulatif — cinq points à retenir

1. **Google et IA sont des outils professionnels.** Les utiliser n'est pas de la paresse ; ne pas valider ce qu'on en tire l'est.
2. **Lecture > écriture.** En pratique, 80 % du temps c'est comprendre et adapter du code existant, 20 % seulement écrire du neuf.
3. **`-WhatIf` avant toute commande destructive.** Sans exception.
4. **Documentation au fil de l'eau.** Commentaires dans les scripts, tickets résolus, historique des actions.
5. **Adapter au contexte.** Un script générique n'est pas un script de production. maxtec.be ≠ contoso.com ≠ votre vraie infrastructure.

---

## Check de compréhension

Avant le Module 2, assurez-vous de pouvoir répondre :

1. Où cherchez-vous la syntaxe d'une commande PowerShell que vous ne connaissez pas ?
2. Comment vérifiez-vous qu'un script trouvé en ligne est sûr pour votre environnement ?
3. Quelle est la première chose à faire avant d'exécuter une commande `Remove-*` ?

---

**Suite** : Module 2 — Les 10 commandes essentielles pour le support niveau 1 et 2.
