# Cas d'école — Vendredi 17h, sans -WhatIf

Scénario composite, construit à partir d'erreurs courantes. Les noms, l'entreprise et les montants sont fictifs ; le mécanisme de l'erreur, lui, se rencontre réellement.

## Le contexte

- **Quand** : un vendredi, 16h45.
- **Où** : une PME de 120 employés.
- **Qui** : Julien, administrateur depuis 8 mois. Son responsable est en réunion.

---

## La demande

Courriel des RH, reçu à 16h30 :

```
De: drh@entreprise.com
À: admin@entreprise.com
Sujet: URGENT - Comptes stagiaires

Bonjour Julien,

Les stagiaires d'été partent aujourd'hui (5 personnes).
Peux-tu désactiver leurs comptes avant lundi ?

- Alexandre Durand
- Marie Petit
- Thomas Bernard
- Camille Lefèvre
- Lucas Moreau

Merci, bon week-end
Julie (RH)
```

La demande paraît simple, et l'heure pousse à aller vite. C'est la combinaison classique.

---

## Le script trouvé en ligne

Julien récupère ce script sur un forum :

```powershell
# Désactiver des utilisateurs à partir d'une liste
$stagiaires = @(
    "Alexandre.Durand",
    "Marie.Petit",
    "Thomas.Bernard",
    "Camille.Lefevre",
    "Lucas.Moreau"
)

Write-Host "Désactivation des comptes stagiaires..." -ForegroundColor Yellow

foreach ($stagiaire in $stagiaires) {
    Write-Host "Désactivation : $stagiaire" -ForegroundColor Green
    Set-ADUser -Identity $stagiaire -Enabled $false
}

Write-Host "Terminé." -ForegroundColor Green
```

Le script suppose que les `SamAccountName` suivent le format `Prénom.Nom`. Ce n'est pas le cas dans cette entreprise.

### Première exécution — 16h52

```powershell
PS C:\> .\desactiver-stagiaires.ps1
Désactivation des comptes stagiaires...
Désactivation : Alexandre.Durand
Set-ADUser : Cannot find an object with identity: 'Alexandre.Durand'
Désactivation : Marie.Petit
Set-ADUser : Cannot find an object with identity: 'Marie.Petit'
Désactivation : Thomas.Bernard
Set-ADUser : Cannot find an object with identity: 'Thomas.Bernard'
Désactivation : Camille.Lefevre
Set-ADUser : Cannot find an object with identity: 'Camille.Lefevre'
Désactivation : Lucas.Moreau
Set-ADUser : Cannot find an object with identity: 'Lucas.Moreau'
Terminé.
```

Cinq erreurs sur cinq, et le script affiche quand même « Terminé ». Le bon réflexe serait de regarder les vrais identifiants (`Get-ADUser -Filter "Surname -eq 'Durand'"`). Julien choisit de rendre le script plus permissif.

---

## La « correction » — 16h58

```powershell
$stagiaires = @(
    "Alexandre*",
    "Marie*",
    "Thomas*",
    "Camille*",
    "Lucas*"
)

foreach ($stagiaire in $stagiaires) {
    Write-Host "Recherche et désactivation : $stagiaire" -ForegroundColor Yellow

    # La ligne qui pose problème
    Get-ADUser -Filter {Name -like $stagiaire} | Set-ADUser -Enabled $false

    Write-Host "Fait pour $stagiaire" -ForegroundColor Green
}
```

### Deuxième exécution — 17h01

```powershell
PS C:\> .\desactiver-stagiaires-v2.ps1
Recherche et désactivation : Alexandre*
Fait pour Alexandre*
Recherche et désactivation : Marie*
Fait pour Marie*
Recherche et désactivation : Thomas*
Fait pour Thomas*
Recherche et désactivation : Camille*
Fait pour Camille*
Recherche et désactivation : Lucas*
Fait pour Lucas*
```

Plus aucune erreur. Julien part. L'absence d'erreur ne dit pourtant rien du nombre de comptes touchés.

---

## Lundi, 8h15

Les appels arrivent : la directrice commerciale, la responsable de la paie et le directeur général adjoint ne peuvent plus ouvrir de session.

### Ce qui s'est réellement passé

```powershell
# Comptes désactivés depuis vendredi 16h
$depuis = Get-Date "2023-10-13 16:00"
Get-ADUser -Filter {Enabled -eq $false} -Properties WhenChanged |
    Where-Object { $_.WhenChanged -gt $depuis } |
    Select-Object Name, SamAccountName, WhenChanged

Name              SamAccountName     WhenChanged
----              --------------     -----------
Alexandre Durand  adurand            13/10/2023 17:01:15
Alexandre Martin  amartin            13/10/2023 17:01:15   # directeur général adjoint
Marie Petit       mpetit             13/10/2023 17:01:32
Marie Dubois      mdubois            13/10/2023 17:01:32   # directrice commerciale
Thomas Bernard    tbernard           13/10/2023 17:01:45
Thomas Duchemin   tduchemin          13/10/2023 17:01:45   # responsable IT
Camille Lefèvre   clefevre           13/10/2023 17:01:58
Camille Leroux    cleroux            13/10/2023 17:01:58   # responsable paie
Lucas Moreau      lmoreau            13/10/2023 17:02:12
Lucas Bertrand    lbertrand          13/10/2023 17:02:12   # développeur senior
```

Le filtre `Name -like "Alexandre*"` correspond à **tous** les comptes dont le nom commence par Alexandre. Résultat : les 5 stagiaires, plus 5 collègues qui partagent un prénom avec eux.

### La deuxième erreur

Sous pression, Julien réactive en bloc :

```powershell
Get-ADUser -Filter {Enabled -eq $false} -Properties WhenChanged |
    Where-Object { $_.WhenChanged -gt $depuis } |
    Set-ADUser -Enabled $true
```

Les collègues retrouvent leur accès, mais les stagiaires aussi. Corriger dans l'urgence, sans vérifier, reproduit le problème initial dans l'autre sens.

### Ce que ça coûte

Dans ce scénario : une réunion de direction reportée, la paie en retard d'une journée, une matinée perdue pour l'équipe IT, et un audit des modifications AD demandé par la direction. Le coût exact varie selon l'entreprise ; l'ordre de grandeur, pour 10 minutes de script non vérifié, reste disproportionné.

---

## Ce qu'il aurait fallu faire

### 1. Regarder avant d'agir

```powershell
# Qui correspond réellement au filtre ?
Get-ADUser -Filter {Name -like "Alexandre*"} -Properties Title, Department |
    Format-Table Name, SamAccountName, Title, Department
```

Dix secondes, et le problème est visible avant toute modification.

### 2. Utiliser des identifiants exacts

```powershell
# SamAccountName vérifiés, pas de caractères génériques
$stagiaires = @("adurand", "mpetit", "tbernard", "clefevre", "lmoreau")
```

Si la liste des RH ne contient que des noms, on retrouve les identifiants d'abord, on les vérifie, puis on agit.

### 3. Simuler avec -WhatIf

```powershell
Set-ADUser -Identity "adurand" -Enabled $false -WhatIf
```

### 4. Contrôler les cas suspects

Une vérification simple : un compte qui n'a pas le titre ou le service attendu ne doit pas être traité sans confirmation.

```powershell
foreach ($sam in $stagiaires) {
    $user = Get-ADUser -Identity $sam -Properties Title
    if ($user.Title -notmatch "stagiaire") {
        Write-Warning "$($user.Name) n'est pas indiqué comme stagiaire ($($user.Title))."
        $reponse = Read-Host "Désactiver quand même ? (oui/non)"
        if ($reponse -ne "oui") { continue }
    }
    Set-ADUser -Identity $sam -Enabled $false -WhatIf
}
```

### 5. Ne pas lancer un changement le vendredi à 17h

Si ça peut attendre lundi 9h, ça attend lundi 9h. Désactiver un compte ne pressait pas : les stagiaires ne revenaient pas le week-end.

---

## Version corrigée du script

Le script ci-dessous simule par défaut. Il n'agit réellement que si on ajoute `-Executer`. Il est compatible Windows PowerShell 5.1.

```powershell
# Désactivation des comptes stagiaires
# Simulation par défaut ; ajouter -Executer pour appliquer réellement.

param(
    [switch]$Executer
)

$simulation = -not $Executer

# Liste exacte, vérifiée avec les RH
$stagiaires = @("adurand", "mpetit", "tbernard", "clefevre", "lmoreau")

if ($simulation) {
    Write-Host "Mode : SIMULATION" -ForegroundColor Yellow
} else {
    Write-Host "Mode : RÉEL" -ForegroundColor Red
}

foreach ($sam in $stagiaires) {
    try {
        $user = Get-ADUser -Identity $sam -Properties Title, Department -ErrorAction Stop

        Write-Host "`n$($user.Name) ($($user.SamAccountName)) - $($user.Title) / $($user.Department)"

        # Contrôle : le compte doit correspondre à un stagiaire
        if ($user.Title -notmatch "stagiaire|stage|intern" -and $user.Department -ne "Stagiaires") {
            Write-Warning "$($user.Name) ne semble pas être un stagiaire."
            $confirmation = Read-Host "Tapez CONFIRMER pour continuer"
            if ($confirmation -ne "CONFIRMER") {
                Write-Host "Ignoré : $($user.Name)" -ForegroundColor DarkYellow
                continue
            }
        }

        Set-ADUser -Identity $sam -Enabled $false -WhatIf:$simulation

    } catch {
        Write-Error "Erreur pour $sam : $($_.Exception.Message)"
    }
}

if ($simulation) {
    Write-Host "`nSimulation terminée. Pour appliquer : .\desactiver-stagiaires.ps1 -Executer" -ForegroundColor Cyan
}
```

---

## À retenir

1. **Un filtre avec `*` touche tout ce qui correspond**, pas seulement ce qu'on avait en tête. On l'exécute d'abord avec `Get-ADUser` seul.
2. **« Aucune erreur » ne veut pas dire « bon résultat ».** Une commande trop large réussit sans bruit.
3. **Un script trouvé en ligne fait des suppositions** (format des identifiants, structure des OUs) qu'il faut vérifier dans son propre environnement.
4. **Corriger dans l'urgence sans vérifier** produit une deuxième erreur.
5. **`-WhatIf` avant toute modification en masse**, y compris quand on est sûr de soi.

Côté organisation, les contre-mesures sont connues : environnement de test, relecture des scripts par un collègue, procédure de changement, et une règle simple sur les modifications en fin de semaine.
