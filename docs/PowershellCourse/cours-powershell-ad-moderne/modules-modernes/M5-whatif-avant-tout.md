# Module 5 — `-WhatIf` avant tout
*Prérequis: Modules 1-4 complétés*

## Objectif

À la fin de ce module, `-WhatIf` doit être un réflexe avant toute commande destructive — y compris sous pression, y compris sur vos propres scripts.

---

## La règle

`-WhatIf` simule l'exécution d'une commande sans rien modifier. Il affiche ce qui serait fait. C'est gratuit, ça prend quelques secondes, et ça évite la plupart des incidents AD.

Dix points à intégrer comme réflexes :

1. `-WhatIf` avant toute commande destructive.
2. Ne pas faire confiance même à ses propres scripts.
3. Vérifier la portée d'une action avant exécution.
4. Documenter ce que `-WhatIf` montre quand c'est utile.
5. Jamais de `Remove-*` sans `-WhatIf` d'abord.
6. Garder son sang-froid sous pression.
7. Partager le réflexe avec les collègues.
8. Vérifier deux fois n'a rien de honteux.
9. `-WhatIf` est un gain de temps net, pas une perte.
10. Les changements de fin de semaine, faits à la hâte, sont ceux qu'on regrette le plus.

---

## Trois incidents typiques évitables

### Cas 1 — Suppression en masse non intentionnelle

```powershell
# Intention : supprimer les comptes de test
Get-ADUser -Filter "Name -like 'Test*'" | Remove-ADUser -Confirm:$false

# Exécuté en réalité (filtre remplacé par * pendant un essai, jamais remis) :
Get-ADUser -Filter * | Remove-ADUser -Confirm:$false
```

Résultat : tous les comptes du domaine supprimés. Restauration : plusieurs heures au mieux.

Ce que `-WhatIf` aurait montré :

```
What if: Performing the operation "Remove" on target "CN=Administrateur,CN=Users,DC=maxtec,DC=be".
What if: Performing the operation "Remove" on target "CN=Vanessa,OU=Users,OU=Ventes,OU=EU,DC=maxtec,DC=be".
... (une ligne par compte du domaine)
```

Le nombre de lignes, et `Administrateur` en tête, auraient suffi à alerter l'admin.

### Cas 2 — Variable mal initialisée

```powershell
# Intention : nettoyer une OU de test
Remove-ADOrganizationalUnit -Identity "OU=Test,OU=EU,DC=maxtec,DC=be" -Recursive

# Réalité : $ouToDelete, réutilisée d'un script précédent, valait "OU=Users,OU=RH,OU=EU,DC=maxtec,DC=be"
Remove-ADOrganizationalUnit -Identity $ouToDelete -Recursive
```

Résultat : suppression de la production. `-WhatIf` aurait affiché le vrai contenu de la variable.

### Cas 3 — TargetPath vide

```powershell
# Intention : OU=Users,OU=IT,OU=EU,DC=maxtec,DC=be
$newOU = "OU=IT,OU=EU,DC=maxtec,DC=be"     # niveau oublié : pas dans la sous-OU Users
Get-ADUser -Filter "Department -eq 'IT'" | Move-ADObject -TargetPath $newOU
```

La commande réussit : les comptes IT atterrissent à côté de la sous-OU `Users`, là où les GPO liées à `Users` ne s'appliquent plus. `-WhatIf` aurait affiché la cible de chaque déplacement.

---

## Mise en situation — vendredi 16h58

**Email reçu à 16h55 :**

```
De: directeur.general@maxtec.be
À: admin@maxtec.be
Sujet: URGENT - Réunion lundi 8h avec clients japonais

Salut,

Peux-tu créer rapidement le groupe "GG-EU-Clients-Japon" et y ajouter
toute l'équipe commerciale ? Réunion critique lundi matin.

Merci !
DG
```

**Réflexe à éviter :** *"Script simple, je saute le `-WhatIf` cette fois."*

### Le script "rapide"

```powershell
New-ADGroup -Name "GG-EU-Clients-Japon" -GroupScope Global -GroupCategory Security -Path "OU=Groups,OU=Ventes,OU=EU,DC=maxtec,DC=be"

Get-ADUser -Filter {Department -eq "Ventes"} | ForEach-Object {
    Add-ADGroupMember -Identity "GG-EU-Clients-Japon" -Members $_.SamAccountName
}

Write-Host "Groupe créé et membres ajoutés" -ForegroundColor Green
```

### Exécution

```powershell
PS C:\> .\create-japan-group.ps1
Groupe créé et membres ajoutés
```

Aucune erreur, message vert, l'admin part en weekend.

### Lundi matin

```
- Le groupe GG-EU-Clients-Japon existe, mais il est vide
- Personne de l'équipe Ventes n'a accès au dossier de la réunion
```

Cause : dans cette entreprise, l'attribut `Department` n'est pas renseigné sur les comptes Ventes (dans votre lab, le script le remplit : le filtre y trouverait les quatre commerciaux). Le filtre `{Department -eq "Ventes"}` ne renvoie aucun utilisateur, la boucle ne tourne pas une seule fois, et le `Write-Host` affiche son message quoi qu'il arrive.

### Ce que `-WhatIf` aurait montré

```powershell
New-ADGroup -Name "GG-EU-Clients-Japon" -GroupScope Global -GroupCategory Security `
    -Path "OU=Groups,OU=Ventes,OU=EU,DC=maxtec,DC=be" -WhatIf
# What if: Performing the operation "New" on target "CN=GG-EU-Clients-Japon,OU=Groups,OU=Ventes,OU=EU,DC=maxtec,DC=be".

Get-ADUser -Filter {Department -eq "Ventes"} | ForEach-Object {
    Add-ADGroupMember -Identity "GG-EU-Clients-Japon" -Members $_.SamAccountName -WhatIf
}
# (aucune ligne "What if" : aucun utilisateur ne correspond au filtre)
```

Trois choses à lire dans cette sortie :

- **Ce qui manque compte autant que ce qui s'affiche.** Une ligne `What if` par commercial était attendue ; il n'y en a aucune. C'est le signal que le filtre ne trouve personne.
- `-WhatIf` sur `New-ADGroup` annonce seulement l'opération et sa cible. Il **ne vérifie pas** si un groupe du même nom existe déjà : pour cela, un `Get-ADGroup -Filter "Name -eq 'GG-EU-Clients-Japon'"` avant la création.
- `Add-ADGroupMember` doit trouver le groupe, même en simulation. Si la création n'a été que simulée, les ajouts simulés échouent avec `Cannot find an object with identity`. Un script qui enchaîne création puis utilisation se simule donc **par étapes** : simuler la création, créer, vérifier avec `Get-ADGroup`, puis simuler les ajouts.

Avec cette méthode, l'admin aurait vu le groupe vide avant de partir, et vérifié l'attribut `Department` (ou filtré par OU avec `-SearchBase`).

---

## Lab — comprendre `-WhatIf`

### Commandes qui supportent `-WhatIf`

```powershell
Set-ADUser -Identity Richard -Title "Chef RH" -WhatIf
Add-ADGroupMember -Identity "GG-EU-RH-Users" -Members Ines -WhatIf
Remove-ADUser -Identity TestUser -WhatIf
Move-ADObject -Identity "CN=Charles,OU=Users,OU=Comptabilite,OU=EU,DC=maxtec,DC=be" `
              -TargetPath "OU=Users,OU=IT,OU=EU,DC=maxtec,DC=be" -WhatIf
```

### Commandes qui ne le supportent pas

Les cmdlets de lecture seule (`Get-*`, `Search-*`) n'ont pas `-WhatIf` parce qu'elles ne modifient rien.

```powershell
Get-ADUser -Identity Richard
Get-ADGroup -Filter {Name -like "GG-*"}
```

### Piège des commandes hybrides

```powershell
# Get-ADUser n'a pas besoin de -WhatIf, mais Set-ADUser oui
Get-ADUser -Filter * | Set-ADUser -Department "Test" -WhatIf

# Sans le -WhatIf à la fin : tous les utilisateurs du domaine changent de département
Get-ADUser -Filter * | Set-ADUser -Department "Test"
```

Le `-WhatIf` se place sur la commande qui modifie, pas sur celle qui lit.

### Lire un output `-WhatIf`

**Sans `-WhatIf` (à ne pas faire pour tester) :**

```powershell
Remove-ADUser -Identity "CN=TestUser,OU=Users,OU=IT,OU=EU,DC=maxtec,DC=be"
# Aucun output, l'utilisateur est supprimé
```

**Avec `-WhatIf` :**

```powershell
Remove-ADUser -Identity "CN=TestUser,OU=Users,OU=IT,OU=EU,DC=maxtec,DC=be" -WhatIf
# What if: Performing the operation "Remove" on target "CN=TestUser,OU=Users,OU=IT,OU=EU,DC=maxtec,DC=be"
```

**Cas où la sortie en dit peu :**

```powershell
Add-ADGroupMember -Identity "GG-EU-IT-Users" -Members ivan, ines -WhatIf
# What if: Performing the operation "Set" on target "CN=GG-EU-IT-Users,OU=Groups,OU=IT,OU=EU,DC=maxtec,DC=be".
```

Une seule ligne : le groupe modifié, pas la liste des membres ajoutés. Pour un ajout en masse, affichez d'abord vous-même la liste (`Get-ADUser -Filter ... | Format-Table Name`) avant de lancer la commande.

---

## Situations où la pression monte

### Le boss impatient

Réponse : *"Trois secondes pour `-WhatIf` peuvent éviter trois jours de récupération."* L'argument est difficile à contester.

Pendant que vous expliquez, exécutez le `-WhatIf` :

```powershell
Get-ADUser -Filter {Department -eq "Stagiaires"} | Remove-ADUser -WhatIf

# What if: Remove CN=Alexandre.Martin,OU=Users,OU=Direction...   <- ce compte n'est pas un stagiaire
```

Une sortie inattendue justifie le délai à elle seule.

### "Je l'ai testé 100 fois en dev"

L'environnement de dev n'est pas l'environnement de prod. Filtres différents, données différentes, OUs différentes. `-WhatIf` obligatoire en production peu importe le nombre de runs précédents.

### Le script du collègue de confiance

Confiance ≠ validation. Un script reçu sans avoir été lu ligne par ligne, c'est un script inconnu. Toujours `-WhatIf`.

---

## Quiz — `-WhatIf` ou pas ?

### A.

```powershell
Get-ADUser -Identity Richard -Properties Department
```

Pas nécessaire — lecture seule.

### B.

```powershell
Set-ADUser -Identity Richard -Department "Direction"
```

Nécessaire — modification.

### C.

```powershell
Get-ADUser -Filter {Name -like "Test*"} | Remove-ADUser
```

Obligatoire — une suppression basée sur un filtre est le cas le plus risqué.

### D.

```powershell
.\clean-old-accounts.ps1
```

Obligatoire — vous ne savez pas ce que le script contient tant que vous ne l'avez pas lu.

---

## Test final

### Question 1

Vous devez désactiver le compte de Marie qui part demain. Première action ?

- A) `Set-ADUser -Identity marie.martin -Enabled $false`
- B) `Set-ADUser -Identity marie.martin -Enabled $false -WhatIf`
- C) Demander confirmation au manager d'abord

**Réponse : B**, puis C avant exécution réelle.

### Question 2

Script trouvé sur Stack Overflow avec 200 upvotes. Première exécution ?

- A) Exécuter directement
- B) Modifier pour votre environnement puis exécuter
- C) Ajouter `-WhatIf` partout et analyser l'output

**Réponse : C.** La popularité n'est pas un gage de sécurité pour *votre* environnement.

### Question 3

Vendredi 17h45, script "urgent" du DG. Que faites-vous ?

- A) Exécuter rapidement
- B) `-WhatIf` d'abord
- C) Remettre à lundi

**Réponse : B.** La pression n'est pas une excuse pour ignorer la validation.

---

## Workflow

```
1. Lire et comprendre la commande
2. Identifier l'impact potentiel
3. Ajouter -WhatIf sur toute commande destructive
4. Analyser l'output ligne par ligne
5. Vérifier que le scope correspond à l'intention
6. Si OK, relancer sans -WhatIf
7. Documenter ce qui a été fait
```

### Exceptions à la règle

Aucune. Ni "testé en dev", ni "script simple", ni "urgence", ni "confiance collègue", ni "pression hiérarchique".

---

## Récapitulatif

`-WhatIf` est un investissement, pas un coût :

- Quelques secondes par commande.
- Évite la majorité des incidents AD.
- Permet de relire l'intention avant l'action.
- Marche y compris sur vos propres scripts.

À retenir : **un `-WhatIf` de trop ne coûte rien ; un de moins peut coûter un week-end.**

---

**Suite** : Module 6 — Kit d'urgence : réagir à un incident AD.
