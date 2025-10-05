# Exercice 03 : Audit d'Accès Médical

## Niveau de Difficulté

🟢 **Débutant** (Guidé étape par étape)

## Objectifs Pédagogiques

- Activer l'**audit NTFS** sur des dossiers médicaux sensibles
- Consulter l'**Event Viewer** (Observateur d'événements) pour tracer les accès
- Filtrer et analyser les **événements de sécurité** (Event ID 4663)
- Générer un **rapport CSV** de conformité RGPD

## Durée Estimée

**25-30 minutes**

## Prérequis

!!! info "Environnement requis"
    - Laboratoire MediCare **complètement configuré**
    - **GPO d'audit** activée (GPO 4 - Audit des Connexions)
    - Dossier patient de test créé (par exemple `C:\Temp\Dossiers_Patients\Patient_VIP_Dupont`)
    - Accès **Administrateur de domaine**
    - Compréhension de base de l'Event Viewer

## Contexte / Scénario

!!! example "Scénario réel - Audit de conformité RGPD"
    **Email du Responsable Conformité (Benoît Chevalier - Officier Sécurité)** :

    > Bonjour IT,
    >
    > Suite à un **audit de conformité RGPD**, nous devons produire un rapport des accès au dossier médical du patient VIP **M. Dupont** durant les **7 derniers jours**.
    >
    > **Requis :**
    >
    > 1. Activer l'**audit des accès fichiers** sur le dossier `Patient_VIP_Dupont`
    > 2. Tracer **qui** a consulté le dossier (lecture/écriture)
    > 3. Identifier **quand** les accès ont eu lieu (date/heure exactes)
    > 4. Générer un **rapport CSV** avec : Utilisateur, Date/Heure, Action (Read/Write)
    >
    > Ce rapport sera présenté à la direction pour prouver la traçabilité des données sensibles.
    >
    > Merci,
    > Benoît Chevalier - Officier de Sécurité IT

    **Votre mission** : Configurer l'audit et générer le rapport de conformité.

## Tâches à Réaliser

### Étape 1 : Créer le dossier patient VIP de test

1. Ouvrir **PowerShell ISE** en tant qu'**Administrateur**

2. Exécuter le script suivant :

```powershell
# Créer le dossier patient VIP
$vipFolder = "C:\Temp\Dossiers_Patients\Patient_VIP_Dupont"
New-Item -Path $vipFolder -ItemType Directory -Force | Out-Null

# Créer quelques fichiers de test
"Diagnostic: Hypertension" | Out-File "$vipFolder\Consultation_2025-10-01.txt"
"Prescription: Lisinopril 10mg" | Out-File "$vipFolder\Prescription_2025-10-01.txt"
"Analyses sanguines: RAS" | Out-File "$vipFolder\Analyses_2025-10-02.txt"

Write-Host "✅ Dossier VIP créé : $vipFolder" -ForegroundColor Green
```

!!! success "Résultat attendu"
    Le dossier `Patient_VIP_Dupont` est créé avec 3 fichiers médicaux de test.

### Étape 2 : Activer l'audit NTFS sur le dossier

1. Ouvrir **Explorateur Windows** et naviguer vers `C:\Temp\Dossiers_Patients`

2. Clic droit sur **Patient_VIP_Dupont** > **Propriétés**

3. Onglet **Sécurité** > Bouton **Avancé**

4. Onglet **Audit** > Cliquer **Continuer** (si UAC demande confirmation)

5. Cliquer **Ajouter**

6. Cliquer **Sélectionner un principal**

7. Entrer : `Everyone` (ou `Tout le monde` en français) > **OK**

8. Configurer l'audit :
   - **Type** : `Réussite` + `Échec` (cocher les deux)
   - **S'applique à** : `Ce dossier, ses sous-dossiers et ses fichiers`
   - Cocher les permissions à auditer :
     - ✅ **Lire les données / Afficher le contenu du dossier**
     - ✅ **Écrire les données / Ajouter des fichiers**
     - ✅ **Ajouter les données / Créer des dossiers**
     - ✅ **Supprimer**

9. Cliquer **OK** > **OK** > **OK**

!!! success "Résultat attendu"
    L'audit est activé. Tous les accès au dossier seront tracés dans le journal de sécurité Windows.

### Étape 3 : Générer des événements d'accès de test

1. Dans **PowerShell ISE**, simuler des accès au dossier :

```powershell
# Simuler des accès au dossier VIP
$vipFolder = "C:\Temp\Dossiers_Patients\Patient_VIP_Dupont"

# Accès 1 : Lecture d'un fichier
Write-Host "`n[Accès 1] Lecture consultation..." -ForegroundColor Cyan
Get-Content "$vipFolder\Consultation_2025-10-01.txt" | Out-Null

# Accès 2 : Écriture d'un nouveau fichier
Write-Host "[Accès 2] Création nouveau fichier..." -ForegroundColor Cyan
"Rapport radiologue: RAS" | Out-File "$vipFolder\Radiologie_2025-10-05.txt"

# Accès 3 : Modification d'un fichier existant
Write-Host "[Accès 3] Modification prescription..." -ForegroundColor Cyan
Add-Content -Path "$vipFolder\Prescription_2025-10-01.txt" -Value "Ajout: Amlodipine 5mg"

Write-Host "`n✅ 3 événements d'accès générés" -ForegroundColor Green
Write-Host "Attendez 10 secondes pour la propagation des événements..." -ForegroundColor Yellow
Start-Sleep -Seconds 10
```

!!! success "Résultat attendu"
    3 événements d'audit sont créés dans le journal de sécurité Windows.

### Étape 4 : Consulter l'Event Viewer

1. Ouvrir **Event Viewer** : `eventvwr.msc`

2. Naviguer vers : **Windows Logs** > **Security**

3. Dans le volet de droite, cliquer **Filtrer le journal actuel...**

4. Configurer le filtre :
   - **IDs d'événement** : `4663`
   - Cliquer **OK**

5. Parcourir les événements et rechercher ceux relatifs à `Patient_VIP_Dupont`

6. Double-cliquer sur un événement pour voir les détails :
   - **Sujet > Nom du compte** : Qui a accédé au fichier
   - **Objet > Nom de l'objet** : Quel fichier a été accédé
   - **Informations d'accès > Accès** : Type d'opération (Read/Write/Delete)

!!! success "Résultat attendu"
    Vous voyez les événements 4663 correspondant aux accès au dossier VIP.

### Étape 5 : Extraire les événements via PowerShell

1. Dans **PowerShell ISE**, exécuter le script suivant pour extraire les événements :

```powershell
# Extraire les événements d'audit pour le dossier VIP
$vipFolder = "C:\Temp\Dossiers_Patients\Patient_VIP_Dupont"
$events = Get-WinEvent -FilterHashtable @{
    LogName = 'Security'
    ID = 4663
} -MaxEvents 1000 -ErrorAction SilentlyContinue

Write-Host "`n[ÉVÉNEMENTS D'AUDIT] Dossier VIP Dupont" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$relevantEvents = $events | Where-Object {
    $_.Message -like "*Patient_VIP_Dupont*"
}

if ($relevantEvents) {
    Write-Host "✓ $($relevantEvents.Count) événement(s) trouvé(s)" -ForegroundColor Green

    $relevantEvents | Select-Object -First 10 | ForEach-Object {
        $xml = [xml]$_.ToXml()
        $user = $xml.Event.EventData.Data | Where-Object {$_.Name -eq 'SubjectUserName'} | Select-Object -ExpandProperty '#text'
        $objectName = $xml.Event.EventData.Data | Where-Object {$_.Name -eq 'ObjectName'} | Select-Object -ExpandProperty '#text'

        Write-Host "`n  Date/Heure : $($_.TimeCreated)" -ForegroundColor Gray
        Write-Host "  Utilisateur: $user" -ForegroundColor Gray
        Write-Host "  Fichier    : $objectName" -ForegroundColor Gray
    }
} else {
    Write-Host "⚠️  Aucun événement trouvé pour le dossier VIP" -ForegroundColor Yellow
    Write-Host "  Vérifiez que l'audit est activé et que des accès ont été effectués." -ForegroundColor Gray
}
```

!!! success "Résultat attendu"
    Les événements d'audit du dossier VIP sont affichés avec utilisateur, date et fichier accédé.

### Étape 6 : Générer le rapport CSV de conformité

1. Exécuter le script suivant pour générer le rapport :

```powershell
# Générer le rapport CSV de conformité RGPD
$vipFolder = "C:\Temp\Dossiers_Patients\Patient_VIP_Dupont"
$reportPath = "C:\Labos\MediCare\Rapport_Audit_VIP_Dupont.csv"

# Créer le dossier si nécessaire
New-Item -Path "C:\Labos\MediCare" -ItemType Directory -Force | Out-Null

# Extraire les événements des 7 derniers jours
$startDate = (Get-Date).AddDays(-7)
$events = Get-WinEvent -FilterHashtable @{
    LogName = 'Security'
    ID = 4663
    StartTime = $startDate
} -ErrorAction SilentlyContinue

# Filtrer les événements du dossier VIP
$relevantEvents = $events | Where-Object {
    $_.Message -like "*Patient_VIP_Dupont*"
}

# Créer le rapport
$auditReport = @()
foreach ($event in $relevantEvents) {
    $xml = [xml]$event.ToXml()

    $user = $xml.Event.EventData.Data | Where-Object {$_.Name -eq 'SubjectUserName'} | Select-Object -ExpandProperty '#text'
    $objectName = $xml.Event.EventData.Data | Where-Object {$_.Name -eq 'ObjectName'} | Select-Object -ExpandProperty '#text'
    $accessMask = $xml.Event.EventData.Data | Where-Object {$_.Name -eq 'AccessMask'} | Select-Object -ExpandProperty '#text'

    # Déterminer le type d'action
    $action = switch ($accessMask) {
        "0x1" { "ReadData" }
        "0x2" { "WriteData" }
        "0x4" { "AppendData" }
        "0x10" { "Delete" }
        default { "Other ($accessMask)" }
    }

    $auditReport += [PSCustomObject]@{
        DateHeure = $event.TimeCreated.ToString("yyyy-MM-dd HH:mm:ss")
        Utilisateur = $user
        Fichier = Split-Path $objectName -Leaf
        CheminComplet = $objectName
        Action = $action
        EventID = $event.Id
    }
}

# Exporter en CSV
if ($auditReport.Count -gt 0) {
    $auditReport | Export-Csv -Path $reportPath -NoTypeInformation -Encoding UTF8

    Write-Host "`n✅ Rapport CSV généré avec succès!" -ForegroundColor Green
    Write-Host "   Chemin: $reportPath" -ForegroundColor Cyan
    Write-Host "   Événements: $($auditReport.Count)" -ForegroundColor Gray

    # Afficher un aperçu
    Write-Host "`n📊 Aperçu du rapport:" -ForegroundColor Cyan
    $auditReport | Select-Object DateHeure, Utilisateur, Fichier, Action | Format-Table -AutoSize

    # Ouvrir le rapport dans Excel/Notepad
    Write-Host "`n📄 Ouverture du rapport..." -ForegroundColor Cyan
    Invoke-Item $reportPath
} else {
    Write-Host "`n⚠️  Aucun événement trouvé pour générer le rapport" -ForegroundColor Yellow
    Write-Host "  Vérifiez que:" -ForegroundColor Gray
    Write-Host "  - L'audit NTFS est activé sur le dossier VIP" -ForegroundColor Gray
    Write-Host "  - Des accès ont été effectués (étape 3)" -ForegroundColor Gray
    Write-Host "  - Les événements ne sont pas trop anciens (< 7 jours)" -ForegroundColor Gray
}
```

!!! success "Résultat attendu"
    Un fichier CSV est créé avec tous les accès au dossier VIP Dupont. Le fichier s'ouvre automatiquement.

### Étape 7 : Vérification finale

1. Ouvrir le fichier CSV généré et vérifier qu'il contient :
   - **DateHeure** : Timestamp précis
   - **Utilisateur** : Nom de l'utilisateur ayant accédé
   - **Fichier** : Nom du fichier consulté
   - **Action** : Type d'opération (ReadData, WriteData, etc.)

2. Vérifier que les 3 accès simulés à l'étape 3 sont présents

!!! success "Résultat attendu"
    Le rapport CSV est complet et exploitable pour l'audit RGPD.

## Vérification de la Réussite

### Commandes PowerShell de Vérification

```powershell
C:\Labos\MediCare\scripts\verification\verif_exercice_03.ps1
```

### Critères de Réussite

- [ ] Le dossier **Patient_VIP_Dupont** existe avec 3-4 fichiers de test
- [ ] L'**audit NTFS** est activé sur ce dossier (visible dans Propriétés > Sécurité > Avancé > Audit)
- [ ] Des **événements 4663** sont présents dans le journal Security pour ce dossier
- [ ] Le **rapport CSV** existe dans `C:\Labos\MediCare\Rapport_Audit_VIP_Dupont.csv`
- [ ] Le rapport contient au moins **3 événements** d'accès

## Solution Complète (Pour Instructeur)

### Méthode PowerShell

```powershell
# === SCRIPT COMPLET - Audit d'Accès Médical ===

Import-Module ActiveDirectory

# 1. Créer dossier VIP
$vipFolder = "C:\Temp\Dossiers_Patients\Patient_VIP_Dupont"
New-Item -Path $vipFolder -ItemType Directory -Force | Out-Null
"Diagnostic: Hypertension" | Out-File "$vipFolder\Consultation_2025-10-01.txt"
"Prescription: Lisinopril 10mg" | Out-File "$vipFolder\Prescription_2025-10-01.txt"
"Analyses sanguines: RAS" | Out-File "$vipFolder\Analyses_2025-10-02.txt"

Write-Host "[ÉTAPE 1] Dossier VIP créé" -ForegroundColor Green

# 2. Activer audit NTFS via PowerShell
$acl = Get-Acl $vipFolder

# Créer règle d'audit pour Everyone
$auditRule = New-Object System.Security.AccessControl.FileSystemAuditRule(
    "Everyone",
    "ReadData,WriteData,AppendData,Delete",
    "ContainerInherit,ObjectInherit",
    "None",
    "Success,Failure"
)

$acl.AddAuditRule($auditRule)
Set-Acl $vipFolder $acl

Write-Host "[ÉTAPE 2] Audit NTFS activé" -ForegroundColor Green

# 3. Générer événements de test
Get-Content "$vipFolder\Consultation_2025-10-01.txt" | Out-Null
"Rapport radiologue: RAS" | Out-File "$vipFolder\Radiologie_2025-10-05.txt"
Add-Content -Path "$vipFolder\Prescription_2025-10-01.txt" -Value "Ajout: Amlodipine 5mg"

Write-Host "[ÉTAPE 3] Événements d'accès générés" -ForegroundColor Green
Start-Sleep -Seconds 10

# 4. Générer rapport CSV
$reportPath = "C:\Labos\MediCare\Rapport_Audit_VIP_Dupont.csv"
New-Item -Path "C:\Labos\MediCare" -ItemType Directory -Force | Out-Null

$events = Get-WinEvent -FilterHashtable @{
    LogName = 'Security'
    ID = 4663
} -MaxEvents 1000 -ErrorAction SilentlyContinue | Where-Object {
    $_.Message -like "*Patient_VIP_Dupont*"
}

$auditReport = @()
foreach ($event in $events) {
    $xml = [xml]$event.ToXml()
    $user = $xml.Event.EventData.Data | Where-Object {$_.Name -eq 'SubjectUserName'} | Select-Object -ExpandProperty '#text'
    $objectName = $xml.Event.EventData.Data | Where-Object {$_.Name -eq 'ObjectName'} | Select-Object -ExpandProperty '#text'

    $auditReport += [PSCustomObject]@{
        DateHeure = $event.TimeCreated.ToString("yyyy-MM-dd HH:mm:ss")
        Utilisateur = $user
        Fichier = Split-Path $objectName -Leaf
        CheminComplet = $objectName
    }
}

$auditReport | Export-Csv -Path $reportPath -NoTypeInformation -Encoding UTF8

Write-Host "[ÉTAPE 4] Rapport CSV généré : $reportPath" -ForegroundColor Green
Write-Host "✅ Audit d'accès médical terminé!" -ForegroundColor Green
```

## Points Clés à Retenir

!!! tip "Concepts importants"
    1. **Audit NTFS** : Permet de tracer tous les accès aux fichiers sensibles (lecture, écriture, suppression)

    2. **Event ID 4663** : Événement Windows standard pour les accès fichiers auditées

    3. **Conformité RGPD** : Obligation légale de tracer qui accède aux données patients

    4. **Rapports CSV** : Format exploitable pour analyses et audits de sécurité

    5. **Rétention des logs** : Les journaux Security doivent être conservés suffisamment longtemps (RGPD : 1 an minimum)

## Dépannage (Erreurs Courantes)

| Erreur Possible | Cause | Solution |
|-----------------|-------|----------|
| Aucun événement 4663 trouvé | Audit non activé ou GPO manquante | Vérifier GPO 4 (Audit Logon) + Audit NTFS |
| "Access denied" sur Set-Acl | Droits insuffisants | Lancer PowerShell ISE en tant qu'Administrateur |
| Événements trop anciens | Journal Security plein ou nettoyé | Regénérer des accès récents (Étape 3) |
| CSV vide | Aucun événement correspondant | Vérifier le nom du dossier dans le filtre PowerShell |
| Impossible de parser XML | Format événement incorrect | Utiliser Get-WinEvent au lieu de Get-EventLog |

## Exercice Suivant Suggéré

!!! tip "Progression pédagogique"
    **[Exercice 04 : Nouveau Service Médical](Exercice_04_Nouveau_Service_Medical.md)** - Créer une structure AD complète pour un nouveau département Dermatologie (niveau intermédiaire).
