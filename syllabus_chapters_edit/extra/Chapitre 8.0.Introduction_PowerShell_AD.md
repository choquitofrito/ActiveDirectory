# Introduction à PowerShell pour Active Directory

## 1. 🔹 Qu'est-ce que PowerShell pour AD ?

PowerShell est un outil d'administration puissant qui permet d'automatiser et de simplifier la gestion d'Active Directory. Contrairement à l'interface graphique, PowerShell offre:

- **Automatisation** des tâches répétitives
- **Traitement par lots** pour gérer plusieurs objets simultanément
- **Scripting** pour créer des solutions personnalisées
- **Reporting** avancé et extraction de données

## 2. 🔹 Modules PowerShell pour Active Directory

Pour gérer Active Directory avec PowerShell, vous devez utiliser des modules spécifiques:

```powershell
# Vérifier si le module AD est disponible
Get-Module -Name ActiveDirectory -ListAvailable

# Importer le module AD si nécessaire
Import-Module ActiveDirectory
```

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

```powershell
# Obtenir des informations sur le domaine
Get-ADDomain

# Lister les contrôleurs de domaine
Get-ADDomainController -Filter *

# Afficher les 5 premiers utilisateurs du domaine
Get-ADUser -Filter * -ResultSetSize 5 | Format-Table Name, Enabled, SamAccountName
```

> **Exercice**: Exécutez ces commandes sur votre contrôleur de domaine `dns1.computerelectronics.be` et observez les résultats. Notez comment les informations sont présentées de manière structurée.

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

# Créer un dossier pour vos scripts
New-Item -Path "C:\Scripts" -ItemType Directory -Force

# Vérifier la version de PowerShell
$PSVersionTable.PSVersion
```


## 6. 🔹 Aide et documentation

PowerShell dispose d'un système d'aide intégré très complet:

```powershell
# Obtenir de l'aide sur une commande
Get-Help Get-ADUser

# Obtenir des exemples d'utilisation
Get-Help Get-ADUser -Examples

# Afficher l'aide dans une fenêtre séparée
Get-Help Get-ADUser -ShowWindow
```

> **Exercice**: Utilisez l'internet, IA ou le système d'aide pour explorer la commande `New-ADUser`. Identifiez les paramètres obligatoires et facultatifs pour créer un nouvel utilisateur.


