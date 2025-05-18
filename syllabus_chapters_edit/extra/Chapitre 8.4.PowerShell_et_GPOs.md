# PowerShell et GPOs

## 1. 🔹 Introduction aux commandes PowerShell pour les GPOs

Les stratégies de groupe (GPO) sont un élément essentiel d'Active Directory. PowerShell permet de les gérer efficacement via le module GroupPolicy.

```powershell
# Importer le module GroupPolicy si nécessaire
Import-Module GroupPolicy

# Vérifier que le module est chargé
Get-Command -Module GroupPolicy
```

> **Exercice** : Exécutez ces commandes sur votre contrôleur de domaine et observez les commandes disponibles pour gérer les GPOs.

## 2. 🔹 Obtenir des informations sur les GPOs

### Lister les GPOs

```powershell
# Lister toutes les GPOs du domaine
Get-GPO -All

# Obtenir une GPO spécifique par son nom
Get-GPO -Name "GPO-Securite-MotDePasse"

# Obtenir une GPO par son GUID
Get-GPO -Guid "31B2F340-016D-11D2-945F-00C04FB984F9"
```

### Obtenir des informations détaillées

```powershell
# Obtenir des informations détaillées sur une GPO
$gpo = Get-GPO -Name "GPO-Securite-MotDePasse"
$gpo | Format-List *

# Vérifier si une GPO est activée
$gpo.GpoStatus

# Vérifier les sections activées (Ordinateur/Utilisateur)
$gpo.Computer.Enabled
$gpo.User.Enabled
```

> **Exercice** : Listez toutes les GPOs de votre domaine et identifiez celles qui ont la partie Ordinateur désactivée.

## 3. 🔹 Création et gestion des GPOs

### Créer une nouvelle GPO

```powershell
# Créer une nouvelle GPO
New-GPO -Name "GPO-Configuration-FondEcran" -Comment "Définit le fond d'écran d'entreprise"

# Créer une GPO basée sur un modèle
New-GPO -Name "GPO-Securite-Avancee" -StarterGpoName "Sécurité renforcée"
```

### Supprimer une GPO

```powershell
# Supprimer une GPO
Remove-GPO -Name "GPO-Test" -Confirm:$false
```

### Renommer une GPO

```powershell
# Renommer une GPO (en créant une copie)
$sourceGPO = Get-GPO -Name "GPO-Ancien-Nom"
$newGPO = New-GPO -Name "GPO-Nouveau-Nom"
Copy-GPO -SourceGPO $sourceGPO -TargetName $newGPO.DisplayName
Remove-GPO -Name $sourceGPO.DisplayName -Confirm:$false
```

> **Exercice** : Créez une nouvelle GPO nommée "GPO-Configuration-Navigateur" avec un commentaire approprié.

## 4. 🔹 Liaison des GPOs aux OUs

La liaison des GPOs aux OUs est une opération courante qui peut être automatisée avec PowerShell.

### Lier une GPO à une OU

```powershell
# Lier une GPO à une OU
New-GPLink -Name "GPO-Securite-MotDePasse" -Target "OU=Comptabilité,OU=EU,DC=computerelectronics,DC=be"

# Lier une GPO avec une priorité spécifique (ordre de traitement)
New-GPLink -Name "GPO-Configuration-FondEcran" -Target "OU=EU,DC=computerelectronics,DC=be" -Order 1
```

### Obtenir les GPOs liées à une OU

```powershell
# Obtenir toutes les GPOs liées à une OU
Get-GPInheritance -Target "OU=Comptabilité,OU=EU,DC=computerelectronics,DC=be"

# Obtenir les liens GPO directs d'une OU
Get-GPLink -Target "OU=Comptabilité,OU=EU,DC=computerelectronics,DC=be"
```

### Modifier ou supprimer un lien GPO

```powershell
# Désactiver un lien GPO
Set-GPLink -Name "GPO-Securite-MotDePasse" -Target "OU=Comptabilité,OU=EU,DC=computerelectronics,DC=be" -LinkEnabled No

# Configurer un lien GPO pour ne pas être hérité
Set-GPLink -Name "GPO-Securite-MotDePasse" -Target "OU=Comptabilité,OU=EU,DC=computerelectronics,DC=be" -Enforced Yes

# Supprimer un lien GPO
Remove-GPLink -Name "GPO-Test" -Target "OU=Comptabilité,OU=EU,DC=computerelectronics,DC=be"
```

> **Exercice** : Liez la GPO "GPO-Configuration-Navigateur" que vous avez créée à l'OU "Ventes" et vérifiez que le lien est bien établi.

## 5. 🔹 Vérification des paramètres GPO

PowerShell permet d'examiner les paramètres configurés dans une GPO.

### Obtenir les paramètres de registre

```powershell
# Obtenir les paramètres de registre d'une GPO
Get-GPRegistryValue -Name "GPO-Configuration-FondEcran" -Key "HKCU\Control Panel\Desktop"
```

### Obtenir les paramètres de sécurité

```powershell
# Obtenir les paramètres de sécurité d'une GPO
$gpo = Get-GPO -Name "GPO-Securite-MotDePasse"
$report = Get-GPOReport -Name $gpo.DisplayName -ReportType Xml
[xml]$xml = $report
$xml.GPO.Computer.ExtensionData | Where-Object { $_.Name -eq "Security" }
```

> **Exercice** : Examinez les paramètres de registre d'une GPO existante dans votre domaine.

## 6. 🔹 Exportation et importation des GPOs

L'exportation et l'importation des GPOs sont essentielles pour la sauvegarde et le déploiement dans différents environnements.

### Sauvegarder une GPO

```powershell
# Sauvegarder une GPO
Backup-GPO -Name "GPO-Securite-MotDePasse" -Path "C:\Temp\GPOBackups"

# Sauvegarder toutes les GPOs
Backup-GPO -All -Path "C:\Temp\GPOBackups"
```

### Restaurer une GPO

```powershell
# Restaurer une GPO à partir d'une sauvegarde
$backup = Get-GPOBackup -Path "C:\Temp\GPOBackups" | Where-Object { $_.DisplayName -eq "GPO-Securite-MotDePasse" }
Restore-GPO -BackupId $backup.Id -Path "C:\Temp\GPOBackups"

# Restaurer une GPO avec un nouveau nom
Restore-GPO -BackupId $backup.Id -Path "C:\Temp\GPOBackups" -TargetName "GPO-Securite-MotDePasse-Restauree"
```

### Importer des paramètres d'une GPO à une autre

```powershell
# Importer les paramètres d'une GPO à une autre
Import-GPO -BackupGpoName "GPO-Securite-MotDePasse" -TargetName "GPO-Nouvelle-Securite" -Path "C:\Temp\GPOBackups" -CreateIfNeeded
```

> **Exercice** : Sauvegardez une GPO importante de votre domaine et restaurez-la avec un nouveau nom.

## 7. 🔹 Cas pratique : Audit des GPOs

Créons un script pour auditer les GPOs de votre domaine et générer un rapport.

```powershell
# Définir le chemin du rapport
$reportPath = "C:\Temp\GPO_Audit_$(Get-Date -Format 'yyyyMMdd').csv"

# Obtenir toutes les GPOs
$allGPOs = Get-GPO -All

# Créer un tableau pour stocker les résultats
$results = @()

foreach ($gpo in $allGPOs) {
    # Obtenir les liens de la GPO
    $links = Get-GPLink -Name $gpo.DisplayName -ErrorAction SilentlyContinue
    
    # Si la GPO n'est liée à aucune OU
    if ($links.Count -eq 0) {
        $linkStatus = "Non liée"
        $linkTargets = "Aucun"
    } else {
        $linkStatus = "Liée"
        $linkTargets = ($links | ForEach-Object { $_.Target }) -join "; "
    }
    
    # Créer un objet avec les informations de la GPO
    $gpoInfo = [PSCustomObject]@{
        Nom = $gpo.DisplayName
        Statut = $gpo.GpoStatus
        DateCreation = $gpo.CreationTime
        DateModification = $gpo.ModificationTime
        StatutLien = $linkStatus
        Cibles = $linkTargets
        OrdinateurActive = $gpo.Computer.Enabled
        UtilisateurActive = $gpo.User.Enabled
        Commentaire = $gpo.Description
    }
    
    # Ajouter l'objet au tableau des résultats
    $results += $gpoInfo
}

# Exporter les résultats au format CSV
$results | Export-Csv -Path $reportPath -NoTypeInformation -Encoding UTF8

# Afficher un résumé
Write-Host "Rapport d'audit des GPOs généré : $reportPath" -ForegroundColor Green
Write-Host "Nombre total de GPOs : $($allGPOs.Count)" -ForegroundColor Yellow
Write-Host "GPOs non liées : $($results | Where-Object { $_.StatutLien -eq "Non liée" } | Measure-Object).Count" -ForegroundColor Yellow
```

> **Exercice final** : Exécutez ce script d'audit et analysez les résultats. Identifiez les GPOs qui pourraient être nettoyées (non liées, désactivées, etc.).

## 🔹 Conclusion

Cette section vous a présenté les techniques essentielles pour gérer les stratégies de groupe (GPO) avec PowerShell. Ces compétences vous permettront d'automatiser la gestion des GPOs, de maintenir une configuration cohérente et de faciliter les audits de sécurité.

Dans l'après-midi, nous mettrons en pratique toutes ces connaissances dans un laboratoire global d'intégration.
