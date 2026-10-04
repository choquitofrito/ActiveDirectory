# Module 1 — Comment travaillent les admins en 2026
*Prérequis: Chapitres 9.0-9.3 complétés*

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

## Démo en direct — un lundi typique

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
SamAccountName         : richard
UserPrincipalName      : richard@maxtec.be
```

**3. J'analyse.**

```powershell
# Compte actif et non verrouillé. Le problème est ailleurs.
Get-ADPrincipalGroupMembership -Identity Richard | Select-Object Name

Name
----
Utilisateurs du domaine
GG-EU-RH-Admin
```

**4. Je documente dans le ticket.**

```
RÉSOLUTION TICKET #2847
- Compte Richard: actif, non verrouillé
- Membre de: Utilisateurs du domaine, GG-EU-RH-Admin
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

Et un bug caché : `LastLogonDate` n'est pas demandé avec `-Properties`. Il est donc vide pour tous les comptes, un vide est considéré comme « plus ancien » que n'importe quelle date, et le script désactive **tous** les comptes actifs du domaine.

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
    Format-Table Name, LastLogonDate

# Attention : un compte qui ne s'est jamais connecté a un LastLogonDate vide.
# Il apparaît dans la liste. Dans le lab, c'est le cas de presque tous les comptes.

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
# Script généré par IA - à valider avant usage
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
        $utilisateursMotDePasseAncien | Format-Table Name, PasswordLastSet -AutoSize
    }
}
catch {
    Write-Error "Erreur lors de l'exécution: $($_.Exception.Message)"
}
```

**Analyse critique :**

- Bon : gestion d'erreurs, SearchBase ciblée, lecture seule.
- À surveiller : le filtre `Department -eq "RH"` ne marche que si la propriété `Department` est renseignée. Le script du lab la remplit ; sur un autre annuaire, vérifiez-la dans *Utilisateurs et ordinateurs Active Directory* (onglet **Organisation**, champ **Service**).
- Redondant : `-SearchBase` sur l'OU RH **et** le filtre `Department -eq "RH"`. L'un des deux suffit.
- À améliorer : ajouter exclusion des comptes de service.

### Exercice 1.1

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

## Chercher efficacement

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

1. **learn.microsoft.com** — documentation officielle
2. **Stack Overflow** — à valider avant utilisation
3. **Reddit r/PowerShell** — cas réels, toujours à adapter
4. **Blogs techniques, Spiceworks** — à comprendre avant d'exécuter

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
2. **Ticket #2852** — Un nouveau stagiaire, `charles2` (compte hypothétique, à créer pour tester), doit avoir les mêmes droits que Charles.
3. **Ticket #2853** — Liste des utilisateurs qui n'ont jamais changé leur mot de passe.

### Mission

1. Trouvez la syntaxe (Google ou IA autorisés).
2. Testez sur maxtec.be.
3. Documentez votre approche.
4. Présentez vos solutions.

### Solutions proposées

**#2851 — Droits de Valeria**

```powershell
# 1. Ses groupes : GG-EU-Ventes-Users doit y être
Get-ADPrincipalGroupMembership -Identity valeria | Select-Object Name

# 2. S'il manque, l'ajouter (avec -WhatIf d'abord). Pas Ventes-Admin : le besoin
#    est un accès utilisateur, on ne donne pas plus de droits que nécessaire.
Add-ADGroupMember -Identity "GG-EU-Ventes-Users" -Members valeria -WhatIf
```

Si elle est déjà membre, le problème est ailleurs : droits du partage, ou ajout récent au groupe (le jeton n'est mis à jour qu'à la prochaine ouverture de session, voir `klist purge` dans la Cheatsheet).

**#2852 — Copier les droits de Charles vers Charles2**

```powershell
# Les groupes GG- de charles (le groupe principal « Utilisateurs du domaine » est exclu)
$groupesCharles = Get-ADPrincipalGroupMembership -Identity charles |
    Where-Object { $_.Name -like "GG-*" }

if (Get-ADUser -Filter "SamAccountName -eq 'charles2'") {
    foreach ($groupe in $groupesCharles) {
        Add-ADGroupMember -Identity $groupe -Members charles2 -WhatIf
    }
} else {
    Write-Host "charles2 n'existe pas : créez le compte d'abord" -ForegroundColor Red
}
```

**#2853 — Utilisateurs sans changement de mot de passe**

```powershell
# Le mot de passe est défini à la création, quelques secondes après WhenCreated.
# « Jamais changé » = PasswordLastSet encore à cette date (ou vide : changement exigé).
Get-ADUser -Filter "Enabled -eq 'True'" -SearchBase "OU=EU,DC=maxtec,DC=be" `
           -Properties PasswordLastSet, WhenCreated |
    Where-Object {
        $null -eq $_.PasswordLastSet -or
        $_.PasswordLastSet -lt $_.WhenCreated.AddMinutes(5)
    } |
    Format-Table Name, SamAccountName, WhenCreated, PasswordLastSet
```

Dans le lab, personne n'a encore changé son mot de passe : tous les comptes sortent. La comparaison entre deux propriétés du même compte se fait avec `Where-Object` : `-Filter` ne sait pas le faire.

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
