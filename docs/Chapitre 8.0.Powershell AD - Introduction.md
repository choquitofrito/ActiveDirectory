# Chapitre 8.0: Powershell AD - Introduction

## 1. 🔹 Qu'est-ce que PowerShell pour AD ?

PowerShell est un outil d'administration puissant qui permet d'automatiser et de simplifier la gestion d'Active Directory. Contrairement à l'interface graphique, PowerShell offre:

- **Automatisation** des tâches répétitives
- **Traitement par lots** pour gérer plusieurs objets simultanément
- **Scripting** pour créer des solutions personnalisées
- **Reporting** avancé et extraction de données

## 2. 🔹 Modules PowerShell pour Active Directory

Pour gérer Active Directory avec PowerShell, vous utilisez le module ActiveDirectory. Sur un contrôleur de domaine avec le rôle AD DS installé, ce module est généralement **déjà disponible et chargé automatiquement** dans PowerShell ISE.

```powershell
# Vérifier si le module AD est chargé
Get-Module -Name ActiveDirectory

# Si le module n'est pas chargé (rare sur un DC), vous pouvez l'importer
# Import-Module ActiveDirectory
```

> **Note:** Sur un poste de travail (non-DC), l'installation des outils RSAT (Remote Server Administration Tools) est nécessaire pour obtenir ce module, et l'importation explicite peut être requise.

> **Exemple pratique**: Ouvrez PowerShell sur votre contrôleur de domaine et exécutez ces commandes pour vérifier que le module AD est bien installé et disponible.

## 3. 🔹 Commandes de base et structure

Les commandes PowerShell pour AD suivent une structure cohérente avec des verbes d'action et des noms d'objets:

| Verbe | Action | Exemples |
|-------|--------|----------|
| Get | Obtenir des informations | Get-ADUser, Get-ADGroup |
| New | Créer de nouveaux objets | New-ADUser, New-ADGroup |
| Set | Modifier des objets existants | Set-ADUser, Set-ADAccountPassword |
| Remove | Supprimer des objets | Remove-ADUser, Remove-ADGroup |
| Add | Ajouter à une collection | Add-ADGroupMember |
| Move | Déplacer des objets | Move-ADObject |

### Exemple pratique: Explorer votre domaine

Exécutez ces commandes sur votre contrôleur de domaine `dns1.maxtec.be` et observez les résultats. 


```powershell
# Obtenir des informations sur le domaine
Get-ADDomain

# Lister les contrôleurs de domaine
Get-ADDomainController -Filter *

# Afficher tous les utilisateurs du domaine
Get-ADUser -Filter *
# Afficher les 15 premiers utilisateurs du domaine (ResultSetSize permet de limiter le nombre de résultats, peu importe la requête)
Get-ADUser -Filter * -ResultSetSize 15 

# Afficher les utilisateurs du domaine, mais sélectionner des attributs spécifiques
Get-ADUser -Filter * -ResultSetSize 15 -Properties Name, Enabled, SamAccountName 

# Afficher les utilisateurs du domaine, mais sélectionner des attributs spécifiques et les afficher de manière structurée
Get-ADUser -Filter * -ResultSetSize 15 -Properties Name, Enabled, SamAccountName | 
    Format-Table Name, Enabled, SamAccountName

# Obtenir d'autres types d'objets AD

# Afficher tous les groupes du domaine
Get-ADGroup -Filter *

# Afficher tous les ordinateurs du domaine
Get-ADComputer -Filter *

# Afficher toutes les unités d'organisation (OUs)
Get-ADOrganizationalUnit -Filter *
```

(On verra les filtres plus tard)


## 4. 🔹 Comparaison avec l'interface graphique

| Tâche | Interface graphique | PowerShell | Avantage PowerShell |
|-------|---------------------|------------|---------------------|
| Créer 10 utilisateurs | 10 opérations manuelles | Une seule commande avec une boucle | Gain de temps, cohérence |
| Trouver tous les comptes désactivés | Filtres complexes dans l'interface | `Get-ADUser -Filter {Enabled -eq $false}` | Rapidité, possibilité d'export |
| Modifier un attribut pour tous les utilisateurs d'un département | Impossible en masse | Une ligne de commande | Automatisation de tâches impossibles en GUI |
| Audit des groupes | Navigation manuelle | Rapport automatisé | Exhaustivité, reproductibilité |

### Exemple pratique: Tâche impossible en GUI

Trouvez tous les utilisateurs qui n'ont pas changé leur mot de passe depuis plus de 4 jours:

```powershell
$date = (Get-Date).AddDays(-4)
Get-ADUser -Filter {PasswordLastSet -lt $date -and Enabled -eq $true} -Properties PasswordLastSet |
    Select-Object Name, PasswordLastSet |
    Sort-Object PasswordLastSet
```

> **Exercice**: Exécutez cette commande et discutez de la façon dont vous pourriez accomplir la même tâche avec l'interface graphique (spoiler: c'est très difficile).

## 5. 🔹 Configuration de l'environnement PowerShell

Pour travailler efficacement avec PowerShell, quelques configurations sont recommandées:

```powershell
# Définir l'exécution des scripts (sur votre station de travail d'administration)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Créer un dossier pour vos scripts (vous pourriez le faire à la main aussi)
New-Item -Path "C:\Scripts" -ItemType Directory -Force
```


## 6. 🔹 Aide et documentation

PowerShell dispose d'un système d'aide intégré complet mais très technique pour débuter:

```powershell
# Afficher l'aide dans une fenêtre séparée
Get-Help Get-ADUser -ShowWindow
```

> **Exercice**: Utilisez l'internet, IA ou le système d'aide pour explorer la commande `New-ADUser`. Identifiez les paramètres obligatoires et facultatifs pour créer un nouvel utilisateur.


