# Exercice 01 : Transfert de Patient

## Niveau de Difficulté

🟢 **Débutant** (Guidé étape par étape)

## Objectifs Pédagogiques

- Comprendre la **modification de permissions NTFS** sur des dossiers médicaux
- Apprendre à **transférer l'accès aux données patients** entre médecins
- Maîtriser la **gestion d'appartenance aux groupes** de sécurité médicaux
- Documenter les changements pour **traçabilité RGPD**

## Durée Estimée

**20-25 minutes**

## Prérequis

!!! info "Environnement requis"
    - Laboratoire MediCare **complètement configuré** (script `MediCare_Setup.ps1` exécuté)
    - Utilisateurs médicaux créés : **Dr. Catherine Leblanc** (catherine) et **Dr. Philippe Moreau** (philippe)
    - **Partage réseau créé** : `\\SRV-MEDICARE\Dossiers_Patients` (voir README.md)
    - Accès **Administrateur de domaine** ou délégation Medical

## Contexte / Scénario

!!! example "Scénario réel - Cabinet MediCare Clinic"
    **Email du Dr. Catherine Leblanc** :
    
    > Bonjour équipe IT,
    >
    > J'ai 3 patients que je transfère vers le Dr. Philippe Moreau suite à mon départ en formation continue pendant 2 mois. Pouvez-vous:
    >
    > 1. **Transférer l'accès** aux dossiers patients suivants vers le Dr. Moreau:
    >    - Patient_001_Dupont
    >    - Patient_012_Martin
    >    - Patient_027_Bernard
    >
    > 2. **Retirer mon accès** à ces dossiers (je n'en serai plus responsable)
    >
    > 3. **Documenter le transfert** pour conformité RGPD (qui, quand, pourquoi)
    >
    > Merci!
    > Dr. Catherine Leblanc
    
    **Votre mission** : Gérer ce transfert médical de manière conforme et tracée.

## Tâches à Réaliser

### Étape 1 : Vérifier la structure actuelle

1. Ouvrir **Active Directory Users and Computers** (`dsa.msc`)

2. Naviguer vers : `maxtec.be > MediCare > Medical > Groups`

3. Double-cliquer sur le groupe **GG-MediCare-Medical-Users**

4. Onglet **Members** : Vérifier que catherine et philippe sont membres

!!! success "Résultat attendu"
    Vous devez voir les deux médecins dans la liste des membres.

### Étape 2 : Créer les dossiers patients de test

!!! warning "Prérequis"
    Cette étape nécessite d'avoir préalablement créé le partage réseau `\\SRV-MEDICARE\Dossiers_Patients`.
    
    Si le partage n'existe pas encore, créez-le avec les permissions par défaut pour `GG-MediCare-Medical-Users`.

1. Ouvrir **PowerShell ISE** en tant qu'**Administrateur**

2. Exécuter le script suivant pour créer les 3 dossiers patients :

```powershell
# Créer les dossiers patients de test
$basePath = "\\SRV-MEDICARE\Dossiers_Patients"

# Si le chemin n'existe pas localement, utilisez un chemin local pour le test
if (-not (Test-Path $basePath)) {
    $basePath = "C:\Temp\Dossiers_Patients"
    New-Item -Path $basePath -ItemType Directory -Force
}

# Créer les 3 dossiers patients
$patients = @("Patient_001_Dupont", "Patient_012_Martin", "Patient_027_Bernard")
foreach ($patient in $patients) {
    New-Item -Path "$basePath\$patient" -ItemType Directory -Force
    Write-Host "✅ Dossier créé : $patient" -ForegroundColor Green
}

Write-Host "`n📁 Dossiers créés dans : $basePath" -ForegroundColor Cyan
```

!!! success "Résultat attendu"
    Les 3 dossiers patients sont créés dans le partage réseau (ou `C:\Temp` pour le test).

### Étape 3 : Configurer les permissions NTFS initiales (Dr. Leblanc)

1. Dans **PowerShell ISE**, exécuter le script suivant pour donner accès initial au Dr. Leblanc :

```powershell
# Configurer permissions NTFS pour Dr. Leblanc (propriétaire initial)
$basePath = "C:\Temp\Dossiers_Patients"  # Ajustez si nécessaire
$patients = @("Patient_001_Dupont", "Patient_012_Martin", "Patient_027_Bernard")

foreach ($patient in $patients) {
    $folderPath = "$basePath\$patient"
    
    # Obtenir l'ACL actuelle
    $acl = Get-Acl $folderPath
    
    # Ajouter permission Modify pour catherine
    $identity = "MAXTEC\catherine"
    $fileSystemRights = "Modify"
    $type = "Allow"
    
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($identity, $fileSystemRights, "ContainerInherit,ObjectInherit", "None", $type)
    $acl.SetAccessRule($accessRule)
    
    # Appliquer l'ACL
    Set-Acl $folderPath $acl
    
    Write-Host "✅ Permissions Modify ajoutées pour catherine sur : $patient" -ForegroundColor Green
}

Write-Host "`n📋 Permissions initiales configurées pour Dr. Leblanc" -ForegroundColor Cyan
```

!!! success "Résultat attendu"
    Le Dr. Leblanc (catherine) a maintenant accès Modify aux 3 dossiers patients.

### Étape 4 : Vérifier les permissions actuelles

1. Exécuter ce script pour afficher les permissions actuelles :

```powershell
# Vérifier les permissions NTFS actuelles
$basePath = "C:\Temp\Dossiers_Patients"
$patients = @("Patient_001_Dupont", "Patient_012_Martin", "Patient_027_Bernard")

foreach ($patient in $patients) {
    $folderPath = "$basePath\$patient"
    Write-Host "`n📁 Dossier : $patient" -ForegroundColor Cyan
    
    $acl = Get-Acl $folderPath
    $acl.Access | Where-Object {$_.IdentityReference -like "*catherine*" -or $_.IdentityReference -like "*philippe*"} |
        Format-Table IdentityReference, FileSystemRights, AccessControlType -AutoSize
}
```

!!! success "Résultat attendu"
    Vous devez voir que **catherine** a des permissions Modify, mais **philippe** n'apparaît pas encore.

### Étape 5 : Transférer l'accès au Dr. Moreau

1. Exécuter le script suivant pour **ajouter** les permissions au Dr. Moreau :

```powershell
# Ajouter permissions pour Dr. Moreau (philippe)
$basePath = "C:\Temp\Dossiers_Patients"
$patients = @("Patient_001_Dupont", "Patient_012_Martin", "Patient_027_Bernard")

foreach ($patient in $patients) {
    $folderPath = "$basePath\$patient"
    
    # Obtenir l'ACL actuelle
    $acl = Get-Acl $folderPath
    
    # Ajouter permission Modify pour philippe
    $identity = "MAXTEC\philippe"
    $fileSystemRights = "Modify"
    $type = "Allow"
    
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($identity, $fileSystemRights, "ContainerInherit,ObjectInherit", "None", $type)
    $acl.SetAccessRule($accessRule)
    
    # Appliquer l'ACL
    Set-Acl $folderPath $acl
    
    Write-Host "✅ Permissions Modify ajoutées pour philippe sur : $patient" -ForegroundColor Green
}

Write-Host "`n📋 Dr. Moreau a maintenant accès aux dossiers patients" -ForegroundColor Cyan
```

!!! success "Résultat attendu"
    Le Dr. Moreau (philippe) a maintenant accès Modify aux 3 dossiers.

### Étape 6 : Retirer l'accès au Dr. Leblanc

1. Exécuter le script suivant pour **retirer** les permissions au Dr. Leblanc :

```powershell
# Retirer permissions de Dr. Leblanc (catherine)
$basePath = "C:\Temp\Dossiers_Patients"
$patients = @("Patient_001_Dupont", "Patient_012_Martin", "Patient_027_Bernard")

foreach ($patient in $patients) {
    $folderPath = "$basePath\$patient"
    
    # Obtenir l'ACL actuelle
    $acl = Get-Acl $folderPath
    
    # Retirer toutes les règles pour catherine
    $acl.Access | Where-Object {$_.IdentityReference -eq "MAXTEC\catherine"} | ForEach-Object {
        $acl.RemoveAccessRule($_) | Out-Null
    }
    
    # Appliquer l'ACL
    Set-Acl $folderPath $acl
    
    Write-Host "✅ Permissions retirées pour catherine sur : $patient" -ForegroundColor Yellow
}

Write-Host "`n📋 Dr. Leblanc n'a plus accès aux dossiers transférés" -ForegroundColor Cyan
```

!!! success "Résultat attendu"
    Le Dr. Leblanc (catherine) n'a plus accès aux 3 dossiers patients.

### Étape 7 : Documenter le transfert (Conformité RGPD)

1. Modifier les **propriétés Description** de l'utilisateur catherine pour documenter le transfert :

```powershell
# Documenter le transfert dans AD
$date = Get-Date -Format "yyyy-MM-dd HH:mm"
$description = "TRANSFERT PATIENTS: 3 patients (001, 012, 027) transférés vers Dr. Moreau le $date (formation continue 2 mois)"

Set-ADUser -Identity catherine -Description $description

Write-Host "`n✅ Transfert documenté dans le compte de catherine" -ForegroundColor Green
Write-Host "   Description: $description" -ForegroundColor Gray
```

!!! success "Résultat attendu"
    Le champ Description du compte catherine est mis à jour avec la trace du transfert.

### Étape 8 : Vérification finale

1. Exécuter le script de vérification finale :

```powershell
# Vérification finale des permissions
$basePath = "C:\Temp\Dossiers_Patients"
$patients = @("Patient_001_Dupont", "Patient_012_Martin", "Patient_027_Bernard")

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "VÉRIFICATION FINALE DU TRANSFERT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

foreach ($patient in $patients) {
    $folderPath = "$basePath\$patient"
    Write-Host "`n📁 Dossier : $patient" -ForegroundColor Cyan
    
    $acl = Get-Acl $folderPath
    $cathAccess = $acl.Access | Where-Object {$_.IdentityReference -eq "MAXTEC\catherine"}
    $philAccess = $acl.Access | Where-Object {$_.IdentityReference -eq "MAXTEC\philippe"}
    
    if ($cathAccess) {
        Write-Host "  ✗ ERREUR: catherine a encore accès!" -ForegroundColor Red
    } else {
        Write-Host "  ✓ catherine n'a plus accès (CORRECT)" -ForegroundColor Green
    }
    
    if ($philAccess) {
        Write-Host "  ✓ philippe a accès Modify (CORRECT)" -ForegroundColor Green
    } else {
        Write-Host "  ✗ ERREUR: philippe n'a pas accès!" -ForegroundColor Red
    }
}

# Vérifier la documentation
$catherineDoc = Get-ADUser -Identity catherine -Properties Description | Select-Object -ExpandProperty Description
Write-Host "`n📝 Documentation RGPD:" -ForegroundColor Cyan
Write-Host "   $catherineDoc" -ForegroundColor Gray
```

!!! success "Résultat attendu"
    - catherine n'a plus accès aux 3 dossiers
    - philippe a accès Modify aux 3 dossiers
    - Le transfert est documenté dans le compte catherine

## Vérification de la Réussite

### Commandes PowerShell de Vérification

Exécutez le script de vérification automatique :

```powershell
C:\Labos\MediCare\scripts\verification\verif_exercice_01.ps1
```

### Critères de Réussite

- [ ] Les 3 dossiers patients existent dans `C:\Temp\Dossiers_Patients` ou le partage réseau
- [ ] Dr. Moreau (philippe) a des permissions **Modify** sur les 3 dossiers
- [ ] Dr. Leblanc (catherine) **n'a plus** de permissions sur les 3 dossiers
- [ ] Le champ **Description** de catherine contient une trace du transfert avec date
- [ ] Aucune erreur lors de l'exécution des scripts

## Solution Complète (Pour Instructeur)

### Méthode GUI

1. **Créer les dossiers patients** (Explorateur Windows) :
   - Naviguer vers `\\SRV-MEDICARE\Dossiers_Patients`
   - Créer 3 dossiers : `Patient_001_Dupont`, `Patient_012_Martin`, `Patient_027_Bernard`

2. **Configurer permissions NTFS** (Explorateur) :
   - Clic droit sur `Patient_001_Dupont` > **Propriétés**
   - Onglet **Sécurité** > **Modifier**
   - Cliquer **Ajouter** > Entrer `MAXTEC\philippe` > **OK**
   - Sélectionner philippe > Cocher **Modification** > **OK**
   - Répéter pour les 2 autres dossiers

3. **Retirer permissions catherine** (Explorateur) :
   - Clic droit sur `Patient_001_Dupont` > **Propriétés**
   - Onglet **Sécurité** > **Modifier**
   - Sélectionner `MAXTEC\catherine` > **Supprimer** > **OK**
   - Répéter pour les 2 autres dossiers

4. **Documenter transfert** (AD Users and Computers) :
   - Ouvrir `dsa.msc`
   - Naviguer vers `MediCare > Medical > Users`
   - Double-cliquer sur **catherine**
   - Onglet **General** > Champ **Description**
   - Entrer : `TRANSFERT PATIENTS: 3 patients (001, 012, 027) transférés vers Dr. Moreau le [DATE] (formation continue 2 mois)`
   - **OK**

### Méthode PowerShell

```powershell
# === SCRIPT COMPLET - Transfert de Patient ===

# Variables
$basePath = "C:\Temp\Dossiers_Patients"  # Ajustez selon votre environnement
$patients = @("Patient_001_Dupont", "Patient_012_Martin", "Patient_027_Bernard")

# 1. Créer les dossiers patients
Write-Host "`n[ÉTAPE 1] Création des dossiers patients..." -ForegroundColor Cyan
if (-not (Test-Path $basePath)) {
    New-Item -Path $basePath -ItemType Directory -Force | Out-Null
}

foreach ($patient in $patients) {
    New-Item -Path "$basePath\$patient" -ItemType Directory -Force | Out-Null
    Write-Host "  ✓ Dossier créé : $patient" -ForegroundColor Green
}

# 2. Configurer permissions initiales pour catherine
Write-Host "`n[ÉTAPE 2] Configuration permissions initiales Dr. Leblanc..." -ForegroundColor Cyan
foreach ($patient in $patients) {
    $folderPath = "$basePath\$patient"
    $acl = Get-Acl $folderPath
    
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        "MAXTEC\catherine",
        "Modify",
        "ContainerInherit,ObjectInherit",
        "None",
        "Allow"
    )
    $acl.SetAccessRule($accessRule)
    Set-Acl $folderPath $acl
    
    Write-Host "  ✓ Permissions Modify ajoutées pour catherine : $patient" -ForegroundColor Green
}

# 3. Transférer accès au Dr. Moreau
Write-Host "`n[ÉTAPE 3] Transfert accès vers Dr. Moreau..." -ForegroundColor Cyan
foreach ($patient in $patients) {
    $folderPath = "$basePath\$patient"
    $acl = Get-Acl $folderPath
    
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        "MAXTEC\philippe",
        "Modify",
        "ContainerInherit,ObjectInherit",
        "None",
        "Allow"
    )
    $acl.SetAccessRule($accessRule)
    Set-Acl $folderPath $acl
    
    Write-Host "  ✓ Permissions Modify ajoutées pour philippe : $patient" -ForegroundColor Green
}

# 4. Retirer accès Dr. Leblanc
Write-Host "`n[ÉTAPE 4] Retrait accès Dr. Leblanc..." -ForegroundColor Cyan
foreach ($patient in $patients) {
    $folderPath = "$basePath\$patient"
    $acl = Get-Acl $folderPath
    
    $acl.Access | Where-Object {$_.IdentityReference -eq "MAXTEC\catherine"} | ForEach-Object {
        $acl.RemoveAccessRule($_) | Out-Null
    }
    
    Set-Acl $folderPath $acl
    Write-Host "  ✓ Permissions retirées pour catherine : $patient" -ForegroundColor Yellow
}

# 5. Documenter le transfert (RGPD)
Write-Host "`n[ÉTAPE 5] Documentation du transfert..." -ForegroundColor Cyan
$date = Get-Date -Format "yyyy-MM-dd HH:mm"
$description = "TRANSFERT PATIENTS: 3 patients (001, 012, 027) transférés vers Dr. Moreau le $date (formation continue 2 mois)"

Set-ADUser -Identity catherine -Description $description
Write-Host "  ✓ Transfert documenté dans le compte catherine" -ForegroundColor Green
Write-Host "    $description" -ForegroundColor Gray

Write-Host "`n✅ Transfert de patients terminé avec succès!" -ForegroundColor Green
```

## Points Clés à Retenir

!!! tip "Concepts importants"
    1. **Permissions NTFS** : Les fichiers médicaux nécessitent des permissions strictes au niveau fichier
    
    2. **Traçabilité RGPD** : Tous les transferts de données patients doivent être documentés (qui, quand, pourquoi)
    
    3. **Principe du moindre privilège** : Retirer les accès dès qu'ils ne sont plus nécessaires
    
    4. **Responsabilité médicale** : Le transfert de patients implique un transfert de responsabilité et d'accès aux dossiers

## Dépannage (Erreurs Courantes)

| Erreur Possible | Cause | Solution |
|-----------------|-------|----------|
| "Access denied" lors de Set-Acl | Pas de droits administrateur | Lancer PowerShell ISE en tant qu'Administrateur |
| "User not found: MAXTEC\catherine" | Nom de domaine incorrect | Vérifier le nom du domaine (MAXTEC vs maxtec) |
| "Path not found" | Chemin partage inexistant | Créer d'abord le partage réseau ou utiliser C:\Temp |
| Permissions non retirées | RemoveAccessRule échoue | Utiliser RemoveAccessRuleAll au lieu de RemoveAccessRule |
| Description non mise à jour | Utilisateur introuvable | Vérifier l'identité avec `Get-ADUser -Identity catherine` |

## Exercice Suivant Suggéré

!!! tip "Progression pédagogique"
    Une fois cet exercice maîtrisé, passez à :
    
    **[Exercice 02 : Horaire de Garde](Exercice_02_Horaire_Garde.md)** - Créer un compte temporaire avec restrictions horaires pour les urgences médicales.
