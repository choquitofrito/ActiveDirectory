# Scripts PowerShell - CreativeHub

## Scripts Principaux

### Script de Création

**Fichier**: [CreativeHub_Setup.ps1](CreativeHub_Setup.ps1)

- **Fonction**: Crée toute la structure AD du laboratoire CreativeHub
- **Durée**: 5-10 minutes
- **Utilisation**: Exécuter en tant qu'Administrateur sur le contrôleur de domaine

```powershell
cd C:\Labos
.\CreativeHub_Setup.ps1
```

!!! info "Ce que le script crée"
    - 17 Unités Organisationnelles (OUs)
    - 18 comptes utilisateurs
    - 8 groupes de sécurité globaux
    - 3 stratégies de groupe (GPOs)
    - 3 fichiers CSV de documentation

### Script de Nettoyage

**Fichier**: [CreativeHub_Cleanup.ps1](CreativeHub_Cleanup.ps1)

- **Fonction**: Supprime complètement la structure AD créée
- **Utilisation**: Pour recommencer le labo depuis zéro

```powershell
cd C:\Labos
.\CreativeHub_Cleanup.ps1
```

!!! warning "Attention"
    Ce script supprime **définitivement** tous les objets AD créés par le setup (utilisateurs, groupes, OUs, GPOs).

---

## Scripts de Vérification

Ces scripts PowerShell permettent de vérifier automatiquement la complétion des exercices.

| Exercice | Script | Description |
|----------|--------|-------------|
| Ex01 | [verif_exercice_01.ps1](verification/verif_exercice_01.ps1) | Vérification création utilisateur Sophie |
| Ex02 | [verif_exercice_02.ps1](verification/verif_exercice_02.ps1) | Vérification désactivation compte Manon |
| Ex03 | [verif_exercice_03.ps1](verification/verif_exercice_03.ps1) | Vérification GPO mappage lecteur TechVision |
| Ex04 | [verif_exercice_04.ps1](verification/verif_exercice_04.ps1) | Vérification groupe projet SecureBank |
| Ex05 | [verif_exercice_05.ps1](verification/verif_exercice_05.ps1) | Vérification réinitialisation MDP Bastien |
| Ex06 | [verif_exercice_06.ps1](verification/verif_exercice_06.ps1) | Vérification délégation Gabrielle/Camille |
| Ex07 | [verif_exercice_07.ps1](verification/verif_exercice_07.ps1) | Vérification onboarding stagiaire Léa |
| Ex08 | [verif_exercice_08.ps1](verification/verif_exercice_08.ps1) | Vérification troubleshooting GPO juniors |
| Ex09 | [verif_exercice_09.ps1](verification/verif_exercice_09.ps1) | Vérification gestion incident sécurité |

### Utilisation

Après avoir complété un exercice, exécutez le script de vérification correspondant:

```powershell
cd "C:\Labos\CreativeHub\verification"
.\verif_exercice_01.ps1
```

!!! success "Feedback coloré"
    - ✅ **Vert**: Test réussi
    - ❌ **Rouge**: Test échoué avec explication
    - ⚠️ **Jaune**: Avertissement ou recommandation

---

## Commandes PowerShell Utiles

### Vérifier la structure créée

```powershell
# Lister toutes les OUs CreativeHub
Get-ADOrganizationalUnit -Filter * |
    Where-Object {$_.DistinguishedName -like "*CreativeHub*"} |
    Select-Object Name, DistinguishedName

# Lister tous les utilisateurs
Get-ADUser -Filter * -SearchBase "OU=CreativeHub,DC=maxtec,DC=be" |
    Select-Object Name, SamAccountName, EmailAddress, Enabled

# Lister tous les groupes
Get-ADGroup -Filter * -SearchBase "OU=CreativeHub,DC=maxtec,DC=be" |
    Select-Object Name, GroupScope, GroupCategory

# Lister toutes les GPOs CreativeHub
Get-GPO -All | Where-Object {$_.DisplayName -like "*CreativeHub*"} |
    Select-Object DisplayName, GpoStatus
```

### Exporter la documentation

```powershell
# Exporter les utilisateurs en CSV
Get-ADUser -Filter * -SearchBase "OU=CreativeHub,DC=maxtec,DC=be" `
    -Properties EmailAddress, Title, Department |
    Export-Csv -Path "C:\Labos\export_utilisateurs.csv" -NoTypeInformation -Encoding UTF8

# Exporter les groupes avec leurs membres
Get-ADGroup -Filter * -SearchBase "OU=CreativeHub,DC=maxtec,DC=be" |
    ForEach-Object {
        [PSCustomObject]@{
            GroupName = $_.Name
            Members = (Get-ADGroupMember -Identity $_.Name).Name -join ", "
        }
    } | Export-Csv -Path "C:\Labos\export_groupes.csv" -NoTypeInformation -Encoding UTF8
```

---

## Dépannage

### Problème: "Script ne s'exécute pas"

**Solution**: Modifier la politique d'exécution PowerShell

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Problème: "Access Denied" ou "Accès refusé"

**Solution**: Ouvrir PowerShell ISE en tant qu'Administrateur

1. Clic droit sur "Windows PowerShell ISE"
2. Sélectionner "Exécuter en tant qu'administrateur"

### Problème: "Module ActiveDirectory not found"

**Solution**: Charger le module manuellement

```powershell
Import-Module ActiveDirectory
```

Si l'erreur persiste, vérifier que le rôle AD DS est installé:

```powershell
Get-WindowsFeature -Name AD-Domain-Services
```
