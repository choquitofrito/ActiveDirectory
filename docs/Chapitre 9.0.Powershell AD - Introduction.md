# Chapitre 9.0: Powershell AD - Introduction

## 🧭 Navigation du Cours
[⏮️ Chapitre Précédent: Group Policy Objects](Chapitre%208.Group%20Policy%20Objects.md) | [🏠 Retour au Syllabus](index.md) | [⏭️ Chapitre Suivant: Powershell AD - Concepts base](Chapitre%209.1.Powershell%20AD%20-%20Concepts%20base.md)

!!! tip "Cours Moderne PowerShell 2026"
    Ces chapitres (9.0-9.3) couvrent les **bases de PowerShell AD**. Pour une approche moderne et orientée terrain, consultez aussi le **[Cours Moderne 2026](PowershellCourse/cours-powershell-ad-moderne/modules-modernes/M1-realite-2026.md)** qui enseigne PowerShell à travers la résolution de tickets réels, l'utilisation de l'IA comme copilote, et la détection de scripts dangereux.

---

!!! info "Objectifs du chapitre"
    
    À la fin de ce chapitre, vous savez :
    
    - vérifier que le module `ActiveDirectory` est disponible et choisir votre éditeur (VS Code ou ISE) ;
    - lister et compter les utilisateurs, groupes, OUs et ordinateurs de `maxtec.be` ;
    - afficher des propriétés qui ne sont pas renvoyées par défaut (`-Properties`) ;
    - écrire un filtre simple (`Enabled -eq $false`) ;
    - trouver l'aide d'une commande (`Get-Help`, `Update-Help`, `-Online`) ;
    - transposer vos réflexes bash vers PowerShell.

---

## 1. 🔹 Qu'est-ce que PowerShell pour AD ?

PowerShell est un outil d'administration puissant qui permet d'automatiser et de simplifier la gestion d'Active Directory. Contrairement à l'interface graphique, PowerShell offre:

!!! tip "Avantages de PowerShell pour AD"
    
    - **Automatisation** des tâches répétitives
    - **Traitement par lots** pour gérer plusieurs objets simultanément
    - **Scripting** pour créer des solutions personnalisées
    - **Reporting** avancé et extraction de données

## 2. 🔹 Modules PowerShell pour Active Directory

!!! note "Module disponible"
    
    Sur un contrôleur de domaine avec le rôle AD DS installé, le module `ActiveDirectory` est **déjà installé**. PowerShell le charge automatiquement dès que vous tapez une commande `*-AD*` : pas besoin d'`Import-Module` en temps normal.

!!! tip "Quel éditeur ?"
    
    - **Recommandé : Visual Studio Code + extension PowerShell**, installé soit sur le poste client `ws-IT-01` (avec les outils RSAT, voir plus bas), soit directement sur le DC. Coloration, autocomplétion, débogage, et c'est l'outil que vous retrouverez en entreprise.
    - **Accepté : PowerShell ISE**, présent d'office sur Windows Server. Il fonctionne, mais Microsoft ne le fait plus évoluer.

!!! note "PowerShell 5.1 ou 7 ?"
    
    Windows Server et Windows 10 livrent **Windows PowerShell 5.1** (`powershell.exe`). PowerShell 7 (`pwsh.exe`) s'installe à part et peut utiliser le module AD via une couche de compatibilité. Le DC du lab n'a que la 5.1 : **écrivez du code compatible 5.1**. En pratique, évitez l'opérateur ternaire `condition ? a : b` et l'opérateur `??`, qui n'existent qu'en 7. Pour connaître votre version : `$PSVersionTable.PSVersion`.

```powershell
# Vérifier si le module AD est chargé
Get-Module -Name ActiveDirectory

# Si le module n'est pas chargé (rare sur un DC), vous pouvez l'importer
# Import-Module ActiveDirectory
```

!!! warning "Sur un poste de travail"
    
    Sur un poste de travail (non-DC), l'installation des outils RSAT (Remote Server Administration Tools) est nécessaire pour obtenir ce module, et l'importation explicite peut être requise.

!!! example "Test pratique"
    
    Ouvrez PowerShell sur votre contrôleur de domaine et exécutez ces commandes pour vérifier que le module AD est bien installé et disponible.

## 3. 🔹 Commandes de base et structure

!!! info "Structure cohérente"
    
    Les commandes PowerShell pour AD suivent une structure cohérente avec des verbes d'action et des noms d'objets :

| Verbe | Action | Exemples |
|-------|--------|----------|
| Get | Obtenir des informations | Get-ADUser, Get-ADGroup |
| New | Créer de nouveaux objets | New-ADUser, New-ADGroup |
| Set | Modifier des objets existants | Set-ADUser, Set-ADAccountPassword |
| Remove | Supprimer des objets | Remove-ADUser, Remove-ADGroup |
| Add | Ajouter à une collection | Add-ADGroupMember |
| Move | Déplacer des objets | Move-ADObject |

### Exemple pratique: Explorer votre domaine

!!! example "Commandes de découverte"
    
    Exécutez ces commandes sur votre contrôleur de domaine `dns1.maxtec.be` et observez les résultats. 


```powershell
# Obtenir des informations sur le domaine
Get-ADDomain

# Lister les contrôleurs de domaine
Get-ADDomainController -Filter *

# Afficher tous les utilisateurs du domaine
Get-ADUser -Filter *



# Par défaut, Get-ADUser ne renvoie qu'une dizaine de propriétés
# (Name, SamAccountName, Enabled, DistinguishedName, UserPrincipalName...).
# Department et LastLogonDate n'en font pas partie : il faut les demander avec -Properties.
# Format-Table affiche le résultat en tableau.
Get-ADUser -Filter * -Properties Department, LastLogonDate |
    Format-Table Name, SamAccountName, Department, LastLogonDate

# Obtenir d'autres types d'objets AD

# Afficher tous les groupes du domaine
Get-ADGroup -Filter *

# Afficher tous les ordinateurs du domaine
Get-ADComputer -Filter *

# Afficher toutes les unités d'organisation (OUs)
Get-ADOrganizationalUnit -Filter *

```

!!! note "Filtres avancés"
    
    (On verra les filtres plus tard)


!!! info "Comparaison GUI vs PowerShell"
    
    Voici quelques exemples concrets des avantages de PowerShell :

| Tâche | Interface graphique | PowerShell | Avantage PowerShell |
|-------|---------------------|------------|---------------------|
| Créer 10 utilisateurs | 10 opérations manuelles | Une seule commande avec une boucle | Gain de temps, cohérence |
| Trouver tous les comptes désactivés | Filtres complexes dans l'interface | `Get-ADUser -Filter {Enabled -eq $false}` | Rapidité, possibilité d'export |
| Modifier un attribut pour tous les utilisateurs d'un département | Impossible en masse | Une ligne de commande | Automatisation de tâches impossibles en GUI |
| Audit des groupes | Navigation manuelle | Rapport automatisé | Exhaustivité, reproductibilité |

### Exemple pratique: Tâche impossible en GUI

!!! example "Recherche complexe"
    
    Trouvez tous les utilisateurs qui n'ont pas changé leur mot de passe depuis plus de 4 jours :

```powershell
$date = (Get-Date).AddDays(-4)
Get-ADUser -Filter {PasswordLastSet -lt $date -and Enabled -eq $true} -Properties PasswordLastSet |
    Select-Object Name, PasswordLastSet |
    Sort-Object PasswordLastSet
```

!!! question "Réflexion"
    
    Exécutez cette commande, puis cherchez comment obtenir la même liste dans l'interface graphique. La console n'affiche pas `PasswordLastSet` dans ses colonnes : il faut ouvrir l'éditeur d'attributs de chaque compte.

## 4. 🔹 Configuration de l'environnement PowerShell

!!! tip "Configuration recommandée"
    
    Pour travailler efficacement avec PowerShell, quelques configurations sont recommandées :

```powershell
# Définir l'exécution des scripts (sur votre station de travail d'administration)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Créer un dossier pour vos scripts (vous pourriez le faire à la main aussi)
New-Item -Path "C:\Scripts" -ItemType Directory -Force
```


## 5. 🔹 Aide et documentation

!!! info "Aide intégrée"
    
    PowerShell dispose d'un système d'aide intégré, complet mais assez technique. Sur une installation neuve, seule une aide minimale est présente : il faut d'abord la télécharger avec `Update-Help` (console en administrateur, accès Internet requis). Sans Internet, `-Online` ouvre la page correspondante sur learn.microsoft.com depuis une machine connectée.

```powershell
# Télécharger l'aide complète (une fois, en administrateur)
Update-Help -UICulture en-US -ErrorAction SilentlyContinue

# Afficher l'aide dans une fenêtre séparée
Get-Help Get-ADUser -ShowWindow

# Seulement les exemples
Get-Help Get-ADUser -Examples

# Ouvrir la documentation en ligne dans le navigateur
Get-Help Get-ADUser -Online
```

!!! note "Pourquoi `-UICulture en-US` ?"
    
    L'aide n'existe pas pour toutes les langues. Sur un Windows en français, `Update-Help` sans paramètre affiche souvent des erreurs pour les modules sans aide française. Ici, `-ErrorAction SilentlyContinue` est acceptable : un module sans aide n'est pas un problème.

!!! example "Exercice d'exploration"
    
    Utilisez l'internet, IA ou le système d'aide pour explorer la commande `New-ADUser`. Identifiez les paramètres obligatoires et facultatifs pour créer un nouvel utilisateur.

---

## 6. Si vous venez de Linux / bash

Beaucoup de réflexes se transposent, mais la différence fondamentale est la suivante : **dans un pipeline PowerShell, ce sont des objets qui circulent, pas du texte**. On ne découpe pas des colonnes avec `cut` ou `awk`, on demande une propriété par son nom.

| bash | PowerShell | Remarque |
|------|-----------|----------|
| `ls` | `Get-ChildItem` (alias `ls`, `dir`) | Les options GNU (`ls -la`) ne marchent pas : `Get-ChildItem -Force` |
| `cat fichier` | `Get-Content fichier` (alias `cat`) | |
| `grep motif` sur du texte | `Select-String motif` | Pour chercher dans des fichiers ou du texte |
| `grep` sur une sortie de commande | `Where-Object { $_.Propriete -eq 'x' }` | On filtre sur une propriété, pas sur une ligne |
| `wc -l` | `(commande).Count` | Ex. : `(Get-ADUser -Filter *).Count` |
| `sort`, `head -5` | `Sort-Object`, `Select-Object -First 5` | |
| `cut`, `awk '{print $1}'` | `Select-Object Name, Department` | |
| `man commande` | `Get-Help commande` | Après `Update-Help` |
| `which` | `Get-Command` | Indique aussi le module d'origine |
| `x=5` puis `$x` | `$x = 5` puis `$x` | Le `$` est aussi présent à l'affectation |
| `> fichier.txt` | `> fichier.txt` ou `Out-File` | Pour des données : `Export-Csv` |
| `echo` | `Write-Host` / `Write-Output` | |
| `rm -rf` | `Remove-Item -Recurse -Force` | Existe aussi avec `-WhatIf` |

Les pièges classiques quand on arrive de bash :

- **Filtrer côté serveur, pas côté client.** `Get-ADUser -Filter "Department -eq 'IT'"` demande au DC de ne renvoyer que les comptes IT. `Get-ADUser -Filter * | Where-Object Department -eq 'IT'` rapatrie **tout** l'annuaire puis filtre localement : sans importance sur 13 comptes, très lent sur 50 000. Réflexe : `-Filter` d'abord, `Where-Object` seulement pour ce que `-Filter` ne sait pas faire.
- **`Format-Table` / `Format-List` toujours en dernier.** Les `Format-*` transforment les objets en instructions d'affichage. Après eux, `Export-Csv` ou `Select-Object` ne reçoivent plus des utilisateurs mais du texte mis en page. Pour exporter : `Select-Object` puis `Export-Csv`.
- **`-Filter` : chaîne ou bloc `{ }`.** Les deux formes existent. Avec une variable simple, `{Department -eq $dept}` fonctionne ; avec une expression (`$user.Department`, `(Get-Date).AddDays(-30)`), le bloc échoue. La forme la plus fiable est la chaîne entre guillemets doubles : `-Filter "Department -eq '$dept'"`. Calculez les dates dans une variable avant le filtre.
- **Erreurs terminantes et non terminantes.** Beaucoup d'erreurs PowerShell n'arrêtent pas le script : il continue à la ligne suivante, comme un `bash` sans `set -e`. Pour qu'un `try/catch` attrape l'erreur, ajoutez `-ErrorAction Stop` à la commande. À l'inverse, `Get-ADUser -Identity inconnu` lance une erreur terminante que `-ErrorAction SilentlyContinue` ne supprime pas : il faut un `try/catch`.

---

## 7. Fil rouge : Jour 1 chez Maxtec

!!! info "Contexte"
    
    Vous venez d'arriver dans l'équipe IT de **Maxtec**. Sophie Martin, la responsable infrastructure, vous demande de prendre en main l'Active Directory avant toute intervention. Les missions ci-dessous balaient le module et utilisent uniquement les commandes vues plus haut.
    
    Chaque mission s'enchaîne avec la suivante : ce que vous découvrez ici servira directement aux chapitres 9.1 à 9.3.

### Mission 1.1 — Inventaire du domaine

!!! example "Objectif"
    
    Sophie veut connaître la volumétrie. Donnez-lui les chiffres exacts pour `maxtec.be` :
    
    1. Nombre total d'**utilisateurs**
    2. Nombre total de **groupes**
    3. Nombre total d'**unités d'organisation**
    4. Nombre total d'**ordinateurs**
    
    *Indice : entourez la commande de parenthèses et ajoutez `.Count` : `(Get-ADUser -Filter *).Count`. Les parenthèses exécutent d'abord la commande ; `.Count` donne le nombre d'objets obtenus.*

??? success "Solution"
    
    ```powershell
    (Get-ADUser -Filter *).Count
    (Get-ADGroup -Filter *).Count
    (Get-ADOrganizationalUnit -Filter *).Count
    (Get-ADComputer -Filter *).Count
    ```
    
    Le chapitre 9.1 explique pourquoi cela fonctionne (tableaux et propriétés).

### Mission 1.2 — Carte d'identité du domaine

!!! example "Objectif"
    
    Récupérez les informations de base du domaine :
    
    1. Le nom DNS (ex: `maxtec.be`)
    2. Le `DomainMode` (niveau fonctionnel)
    3. Le nom NetBIOS
    4. Le ou les contrôleurs de domaine avec leur IP
    
    *Indice : `Get-ADDomain` affiche tout ; pour ne garder que certaines propriétés, passez le résultat à `Format-List` ou `Format-Table` suivi des noms de propriétés.*

??? success "Solution"
    
    ```powershell
    # Vue d'ensemble : cherchez DNSRoot, DomainMode et NetBIOSName dans la sortie
    Get-ADDomain
    
    # Seulement les propriétés utiles, une par ligne
    Get-ADDomain | Format-List DNSRoot, DomainMode, NetBIOSName
    
    # Les contrôleurs de domaine et leur IP, en tableau
    Get-ADDomainController -Filter * | Format-Table Name, IPv4Address
    ```
    
    `Format-List` affiche une propriété par ligne, `Format-Table` en colonnes. Les deux s'utilisent en fin de commande.

### Mission 1.3 — Comptes désactivés

!!! example "Objectif"
    
    Premier contrôle de sécurité :
    
    1. Listez les comptes utilisateurs **désactivés** du domaine
    2. Donnez leur nombre exact
    3. Affichez `Name` et `SamAccountName` en format tableau
    
    *Indice : la propriété `Enabled` vaut `$false` pour un compte désactivé.*

??? success "Solution"
    
    ```powershell
    Get-ADUser -Filter {Enabled -eq $false}
    
    (Get-ADUser -Filter {Enabled -eq $false}).Count
    
    Get-ADUser -Filter {Enabled -eq $false} |
        Format-Table Name, SamAccountName
    ```
    
    Le filtre `{Enabled -eq $false}` est l'équivalent en une ligne d'une recherche filtrée dans la console graphique.

### Mission 1.4 — GUI vs PowerShell, en temps réel

!!! example "Objectif"
    
    Comparaison empirique. Tâche : *« Donner, pour chaque utilisateur, son service (`Department`) et sa date de dernière connexion (`LastLogonDate`). »*
    
    1. Faites-le **d'abord dans la GUI** (`Utilisateurs et ordinateurs Active Directory`). Chronométrez.
    2. Faites-le ensuite **en PowerShell**. Chronométrez.
    3. Comparez les deux temps, et demandez-vous lequel vous pourrez refaire à l'identique la semaine prochaine.
    
    *Indice : la commande est dans la section 3. `Department` et `LastLogonDate` ne sont pas renvoyées par défaut.*

??? success "Solution"
    
    ```powershell
    Get-ADUser -Filter * -Properties Department, LastLogonDate |
        Format-Table Name, SamAccountName, Department, LastLogonDate
    ```
    
    Dans la GUI, le service se lit dans l'onglet `Organisation` et la dernière connexion dans l'éditeur d'attributs, compte par compte. En PowerShell, une commande, que l'on sauvegarde dans un `.ps1` et que l'on rejoue chaque semaine.

### Bilan du jour

Vous savez maintenant compter les objets AD, lire les propriétés du domaine, demander des propriétés supplémentaires, écrire un filtre simple, et arbitrer entre GUI et PowerShell. Le chapitre 9.1 introduit les variables, tableaux, boucles et conditions pour transformer ces commandes ponctuelles en scripts réutilisables.

---

## 🧭 Navigation
[⏮️ Chapitre Précédent: Group Policy Objects](Chapitre%208.Group%20Policy%20Objects.md) | [🏠 Retour au Syllabus](index.md) | [⏭️ Chapitre Suivant: Powershell AD - Concepts base](Chapitre%209.1.Powershell%20AD%20-%20Concepts%20base.md)

---

**📚 Cours Active Directory - PowerShell**


