# Module 5 — `-WhatIf`, pourquoi c'est non négociable
*Durée: 1h30 | Prérequis: Modules 1-4 complétés*

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
8. Pas honte de double-vérifier.
9. `-WhatIf` est un gain de temps net, pas une perte.
10. Vendredi 17h est le moment statistiquement le plus risqué.

---

## Trois incidents typiques évitables

### Cas 1 — Suppression en masse non intentionnelle

```powershell
# Intention:
Get-Mailbox -ResultSize 10 | Remove-Mailbox

# Exécuté en réalité (oubli de filtre):
Get-Mailbox -ResultSize Unlimited | Remove-Mailbox
```

Résultat : milliers de boîtes mail supprimées. Restauration : plusieurs jours.

Ce que `-WhatIf` aurait montré :

```
What if: Performing operation "Remove" on target "user1@..."
What if: Performing operation "Remove" on target "user2@..."
... (plusieurs milliers de lignes)
```

Le scroll seul aurait alerté l'admin.

### Cas 2 — Variable mal initialisée

```powershell
# Intention: nettoyer une OU de test
Remove-ADOrganizationalUnit -Identity "OU=Test,DC=company,DC=com" -Recursive

# Réalité: $ouToDelete pointait vers OU=Users
Remove-ADOrganizationalUnit -Identity $ouToDelete -Recursive
```

Résultat : suppression de la production. `-WhatIf` aurait affiché le vrai contenu de la variable.

### Cas 3 — TargetPath vide

```powershell
Get-ADUser -Filter {Department -eq "Dev"} | Move-ADObject -TargetPath $newOU
# $newOU était null → tous les devs déplacés vers la racine du domaine
```

Permissions cassées, applications down. `-WhatIf` aurait affiché `TargetPath: DC=company,DC=com` immédiatement.

---

## Mise en situation — vendredi 16h58

*L'instructeur joue le rôle de l'admin sous pression.*

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
New-ADGroup : The specified group already exists
Add-ADGroupMember : Cannot find an object with identity: 'GG-EU-Clients-Japon'
Add-ADGroupMember : Cannot find an object with identity: 'GG-EU-Clients-Japon'
Add-ADGroupMember : Cannot find an object with identity: 'GG-EU-Clients-Japon'
Groupe créé et membres ajoutés
```

Le message final est vert, l'admin part en weekend.

### Lundi matin

```
- Personne de l'équipe Ventes ne peut accéder aux dossiers clients
- Les groupes Ventes ont disparu
- Tentatives de connexion échouées en masse
```

### Ce que `-WhatIf` aurait montré

```powershell
New-ADGroup -Name "GG-EU-Clients-Japon" -WhatIf
# What if: Le groupe 'GG-EU-Clients-Japon' existe déjà et serait ignoré

Get-ADUser -Filter {Department -eq "Ventes"} | ForEach-Object {
    Add-ADGroupMember -Identity "GG-EU-Clients-Japon" -Members $_.SamAccountName -WhatIf
}
# What if: Ajout de 'Victor' au groupe 'GG-EU-Clients-Japon'
# What if: Ajout de 'Vanessa' au groupe 'GG-EU-Clients-Japon'
# What if: ERREUR - Groupe 'GG-EU-Clients-Japon' non trouvé
```

L'incohérence (le groupe existe mais on ne peut pas y ajouter de membres) saute aux yeux. L'admin aurait creusé avant d'exécuter.

---

## Lab — comprendre `-WhatIf`

### Commandes qui supportent `-WhatIf`

```powershell
Set-ADUser -Identity Richard -Title "Chef RH" -WhatIf
Add-ADGroupMember -Identity "GG-EU-RH-Users" -Members Ines -WhatIf
Remove-ADUser -Identity TestUser -WhatIf
Move-ADObject -Identity "CN=Charles,OU=Users,OU=Compta,OU=EU,DC=maxtec,DC=be" `
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

**Cas avec détails :**

```powershell
Add-ADGroupMember -Identity "GG-EU-IT-Users" -Members @("Ivan", "Ines") -WhatIf
# What if: Performing operation "Add" on target "CN=GG-EU-IT-Users,..." to add member "CN=Ivan,..."
# What if: Performing operation "Add" on target "CN=GG-EU-IT-Users,..." to add member "CN=Ines,..."
```

---

## Situations où la pression monte

### Le boss impatient

Réponse : *"Trois secondes pour `-WhatIf` peuvent éviter trois jours de récupération."* En général, ça passe.

Pendant que vous expliquez, exécutez le `-WhatIf` :

```powershell
Get-ADUser -Filter {Department -eq "Stagiaires"} | Remove-ADUser -WhatIf

# What if: Remove CN=Alexandre.Martin,OU=Users,OU=Direction... ← STOP
```

Une mauvaise sortie justifie immédiatement le délai.

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

Obligatoire — suppression avec filtre = danger maximal.

### D.

```powershell
.\clean-old-accounts.ps1
```

Obligatoire — vous ne savez pas ce que le script contient tant que vous ne l'avez pas lu.

---

## Test final

### Question 1

Vous devez désactiver le compte de Marie qui part demain. Première action ?

- A) `Set-ADUser -Identity Marie -Enabled $false`
- B) `Set-ADUser -Identity Marie -Enabled $false -WhatIf`
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

À retenir : **mieux vaut un `-WhatIf` de trop qu'un désastre de trop peu.**

---

**Suite** : Module 6 — Gérer un incident AD (procédures break-glass).
