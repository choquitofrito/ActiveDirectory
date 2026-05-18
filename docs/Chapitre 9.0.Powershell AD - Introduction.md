# Chapitre 9.0: Powershell AD - Introduction

## 🧭 Navigation du Cours
[⏮️ Chapitre Précédent: Group Policy Objects](Chapitre%208.Group%20Policy%20Objects.md) | [🏠 Retour au Syllabus](index.md) | [⏭️ Chapitre Suivant: Powershell AD - Concepts base](Chapitre%209.1.Powershell%20AD%20-%20Concepts%20base.md)

!!! tip "Cours Moderne PowerShell 2025"
    Ces chapitres (9.0-9.3) couvrent les **bases de PowerShell AD**. Pour une approche moderne et orientée terrain, consultez aussi le **[Cours Moderne 2025](PowershellCourse/cours-powershell-ad-moderne/modules-modernes/M1-realite-2025.md)** qui enseigne PowerShell à travers la résolution de tickets réels, l'utilisation de l'IA comme copilote, et la détection de scripts dangereux.

---

!!! info "📚 Dans ce chapitre"
    
    Découvrez PowerShell pour Active Directory : un outil puissant pour automatiser et simplifier la gestion de votre domaine.

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
    
    Sur un contrôleur de domaine avec le rôle AD DS installé, ce module est généralement **déjà disponible et chargé automatiquement** dans PowerShell ISE.

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



# Afficher tous les utilisateurs du domaine, mais sélectionner des attributs spécifiques et les afficher de manière structurée
# Le Format-Table permet d'afficher les résultats dans un format tabulaire
# La propriétés Enabled, qui n'est pas affichée par défaut, et sélectionnée avec Properties.
Get-ADUser -Filter * -Properties Name, Enabled, SamAccountName | 
    Format-Table Name, Enabled, SamAccountName

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
    
    Exécutez cette commande et discutez de la façon dont vous pourriez accomplir la même tâche avec l'interface graphique (spoiler: c'est très difficile).

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
    
    PowerShell dispose d'un système d'aide intégré complet mais très technique pour débuter :

```powershell
# Afficher l'aide dans une fenêtre séparée
Get-Help Get-ADUser -ShowWindow
```

!!! example "Exercice d'exploration"
    
    Utilisez l'internet, IA ou le système d'aide pour explorer la commande `New-ADUser`. Identifiez les paramètres obligatoires et facultatifs pour créer un nouvel utilisateur.

---

## 6. Fil rouge : Jour 1 chez Maxtec

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
    
    *Indice : `(...).Count` autour d'une commande `Get-AD...`*

??? success "Solution"
    
    ```powershell
    (Get-ADUser -Filter *).Count
    (Get-ADGroup -Filter *).Count
    (Get-ADOrganizationalUnit -Filter *).Count
    (Get-ADComputer -Filter *).Count
    ```
    
    Les parenthèses forcent PowerShell à exécuter la commande d'abord, puis à appliquer `.Count` au tableau résultat.

### Mission 1.2 — Carte d'identité du domaine

!!! example "Objectif"
    
    Récupérez les informations de base du domaine :
    
    1. Le nom DNS (ex: `maxtec.be`)
    2. Le `DomainMode` (niveau fonctionnel)
    3. Le nom NetBIOS
    4. Le ou les contrôleurs de domaine avec leur IP

??? success "Solution"
    
    ```powershell
    # Vue d'ensemble
    Get-ADDomain
    
    # Propriétés ciblées
    (Get-ADDomain).DNSRoot
    (Get-ADDomain).DomainMode
    (Get-ADDomain).NetBIOSName
    
    Get-ADDomainController -Filter * | Select-Object Name, IPv4Address
    ```

### Mission 1.3 — Comptes désactivés

!!! example "Objectif"
    
    Un audit rapide avant le café :
    
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
    
    Comparaison empirique. Tâche : *« Trouver les utilisateurs créés ces 30 derniers jours. »*
    
    1. Faites-le **d'abord dans la GUI** (`Utilisateurs et ordinateurs Active Directory`). Chronométrez.
    2. Faites-le ensuite **en PowerShell** avec la commande ci-dessous. Chronométrez.
    3. Comparez les deux temps — et surtout, demandez-vous lequel est reproductible la semaine prochaine.

??? success "La commande"
    
    ```powershell
    $ilYaUnMois = (Get-Date).AddDays(-30)
    Get-ADUser -Filter {WhenCreated -ge $ilYaUnMois} -Properties WhenCreated |
        Select-Object Name, SamAccountName, WhenCreated |
        Sort-Object WhenCreated
    ```
    
    Au-delà du temps gagné, la vraie valeur est que la commande se sauvegarde dans un `.ps1` et se rejoue à l'identique chaque semaine.

### Bilan du jour

Vous savez maintenant compter les objets AD, lire les propriétés du domaine, écrire un filtre simple, et arbitrer entre GUI et PowerShell. Le chapitre 9.1 introduit les variables, tableaux, boucles et conditions pour transformer ces commandes ponctuelles en scripts réutilisables.

---

## 🧭 Navigation
[⏮️ Chapitre Précédent: Group Policy Objects](Chapitre%208.Group%20Policy%20Objects.md) | [🏠 Retour au Syllabus](index.md) | [⏭️ Chapitre Suivant: Powershell AD - Concepts base](Chapitre%209.1.Powershell%20AD%20-%20Concepts%20base.md)

---

**📚 Cours Active Directory - PowerShell | 👨‍💻 Pour débutants**


