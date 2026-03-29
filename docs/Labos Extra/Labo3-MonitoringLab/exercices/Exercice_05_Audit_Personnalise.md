# Exercice 05 : Politique d'Audit Personnalisée pour les Accès Finance

## Niveau de Difficulté

Avancé

## Objectifs Pédagogiques

- Concevoir une politique d'audit ciblée en réponse à un besoin métier précis
- Configurer l'audit NTFS sur des dossiers sensibles pour tracer les accès aux fichiers
- Implémenter une combinaison de politiques d'audit AD et système pour une couverture complète

## Durée Estimée

90 minutes

## Prérequis

- Exercices 01 à 04 complétés
- Bonne compréhension des Event IDs de sécurité (Exercice 02)
- Droits administrateur sur le contrôleur de domaine

## Contexte / Scénario

!!! example "Scénario réel"
    Le Directeur Financier de MonitoringTech SPRL vient de vous envoyer un email urgent. Il a constaté que des fichiers de reporting financier trimestriel ont été consultés par des personnes non habilitées, mais il n'a aucune preuve pour identifier le responsable car aucun audit d'accès aux fichiers n'est en place.
    
    Il vous demande de :
    
    1. Créer un dossier partagé simulant les données financières sensibles
    2. Mettre en place un audit complet des accès à ce dossier
    3. Configurer les politiques AD pour auditer les modifications de comptes dans le département Finance
    4. Produire un rapport de test démontrant que l'audit fonctionne
    
    **Vous devez concevoir et implémenter cette solution de façon autonome.**

---

## Exigences Fonctionnelles

!!! warning "Lisez attentivement avant de commencer"
    Contrairement aux exercices précédents, vous ne recevez pas d'instructions pas-à-pas. Vous devez analyser les besoins et construire la solution vous-même.

### Exigences de l'audit

1. **Dossier Finance simulé** : Créer `C:\FinanceData\` avec les sous-dossiers `Rapports\`, `Budgets\`, `Confidential\`

2. **Audit NTFS** sur `C:\FinanceData\` :
    - Tracer TOUS les accès en lecture aux fichiers (Event ID 4663)
    - Tracer TOUTES les modifications, créations, suppressions
    - Appliquer l'audit aux sous-dossiers et fichiers
    - Auditer : **Tout le monde** (Succès et Échec)

3. **Politique d'audit AD** pour le département Finance :
    - Audit de la gestion des comptes (Succès + Échec)
    - Audit des modifications d'appartenance aux groupes
    - Audit de l'accès aux objets AD du département Finance

4. **Données de test** : Créer au minimum 3 fichiers dans `C:\FinanceData\Confidential\` avec du contenu simulé

5. **Validation** : Accéder aux fichiers en tant qu'utilisateur Finance et démontrer que l'accès est enregistré dans les journaux

---

## Contraintes Techniques

!!! warning "Contraintes obligatoires"
    - N'utilisez PAS `Set-GPRegistryValue` pour configurer les politiques d'audit
    - Utilisez `auditpol.exe` pour les politiques d'audit système OU la configuration manuelle dans GPMC
    - L'audit NTFS doit être configuré via `icacls` ou l'interface graphique des propriétés du dossier
    - Tout nouveau groupe créé doit respecter la convention `GG-` + préfixe approprié

---

## Indices

!!! tip "Indice 1 - Créer la structure de dossiers"
    ```powershell
    # PowerShell peut créer des dossiers avec New-Item
    New-Item -Path "C:\FinanceData" -ItemType Directory -Force
    New-Item -Path "C:\FinanceData\Rapports" -ItemType Directory -Force
    # ... continuer pour les autres sous-dossiers
    ```

!!! tip "Indice 2 - Configurer l'audit NTFS via PowerShell"
    ```powershell
    # Pour activer l'audit sur un dossier, on peut utiliser icacls
    # Syntaxe : icacls <chemin> /grant "*S-1-1-0:(OI)(CI)(GA)" (attention : ceci concerne les permissions, pas l'audit)
    # Pour l'audit NTFS, utiliser la classe .NET FileSystemAuditRule
    $path = "C:\FinanceData"
    $acl = Get-Acl $path
    # Créer une règle d'audit pour Everyone (Tout le monde)
    $identity = [System.Security.Principal.NTAccount]"Everyone"
    $rights = [System.Security.AccessControl.FileSystemRights]"FullControl"
    $flags = [System.Security.AccessControl.AuditFlags]"Success,Failure"
    $inheritFlags = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit,ObjectInherit"
    $propFlags = [System.Security.AccessControl.PropagationFlags]"None"
    $auditRule = New-Object System.Security.AccessControl.FileSystemAuditRule($identity, $rights, $inheritFlags, $propFlags, $flags)
    $acl.AddAuditRule($auditRule)
    Set-Acl -Path $path -AclObject $acl
    ```

!!! tip "Indice 3 - Activer l'audit système pour les accès objets"
    ```powershell
    # Activer l'audit d'accès aux objets via auditpol (requis pour que l'audit NTFS génère des événements)
    auditpol /set /subcategory:"File System" /success:enable /failure:enable
    auditpol /set /subcategory:"Handle Manipulation" /success:enable /failure:enable
    ```

!!! tip "Indice 4 - Vérifier l'audit en place"
    ```powershell
    # Vérifier les paramètres d'audit actuels
    auditpol /get /category:*
    # Vérifier les ACL d'audit sur le dossier
    (Get-Acl "C:\FinanceData").Audit
    ```

!!! tip "Indice 5 - Tester l'audit"
    ```powershell
    # Accéder à un fichier et vérifier l'Event ID 4663 dans le journal Security
    Get-Content "C:\FinanceData\Confidential\rapport_test.txt" -ErrorAction SilentlyContinue
    # Puis vérifier les événements générés
    Get-WinEvent -LogName Security -MaxEvents 100 | Where-Object { $_.Id -eq 4663 }
    ```

---

## Livrables Attendus

À la fin de l'exercice, vous devez être capable de démontrer :

1. La structure `C:\FinanceData\` avec les sous-dossiers et fichiers de test
2. Les ACL d'audit sur le dossier (visible via `(Get-Acl "C:\FinanceData").Audit`)
3. Les paramètres `auditpol` activés pour "File System"
4. Au moins 3 événements 4663 dans le journal Security après vos tests d'accès
5. Un rapport PowerShell affichant les 10 derniers accès au dossier Finance

---

## Vérification de la Réussite

### Commandes PowerShell de Vérification

```powershell
Import-Module ActiveDirectory
Write-Host "=== Vérification Exercice 05 ===" -ForegroundColor Cyan
$erreurs = 0

# Test 1: Structure de dossiers
$dossiers = @("C:\FinanceData", "C:\FinanceData\Rapports", "C:\FinanceData\Budgets", "C:\FinanceData\Confidential")
foreach ($d in $dossiers) {
    if (Test-Path $d) {
        Write-Host "Dossier $d : OK" -ForegroundColor Green
    } else {
        Write-Host "Dossier $d : MANQUANT" -ForegroundColor Red
        $erreurs++
    }
}

# Test 2: ACL d'audit configurées
$acl = Get-Acl "C:\FinanceData" -ErrorAction SilentlyContinue
if ($acl -and $acl.Audit.Count -gt 0) {
    Write-Host "Audit NTFS configuré sur C:\FinanceData : OK ($($acl.Audit.Count) règle(s))" -ForegroundColor Green
} else {
    Write-Host "Audit NTFS sur C:\FinanceData : NON CONFIGURÉ" -ForegroundColor Red
    $erreurs++
}

# Test 3: auditpol activé pour File System
$auditResult = auditpol /get /subcategory:"File System" 2>$null
if ($auditResult -match "Success") {
    Write-Host "Auditpol File System : ACTIVÉ" -ForegroundColor Green
} else {
    Write-Host "Auditpol File System : NON ACTIVÉ" -ForegroundColor Red
    $erreurs++
}

# Test 4: Événements 4663 générés
$events4663 = Get-WinEvent -LogName Security -MaxEvents 5000 -ErrorAction SilentlyContinue |
    Where-Object { $_.Id -eq 4663 }
Write-Host "Événements 4663 (accès objets) : $($events4663.Count)" -ForegroundColor $(if ($events4663.Count -gt 0) { "Green" } else { "Yellow" })

# Résumé
Write-Host "`n========================================" -ForegroundColor Cyan
if ($erreurs -eq 0) {
    Write-Host "EXERCICE RÉUSSI!" -ForegroundColor Green
} else {
    Write-Host "EXERCICE INCOMPLET : $erreurs point(s) à corriger" -ForegroundColor Red
}
```

### Critères de Réussite

- [ ] La structure `C:\FinanceData\` avec 3 sous-dossiers existe
- [ ] Au moins 3 fichiers de test sont présents dans `C:\FinanceData\Confidential\`
- [ ] Les ACL d'audit sont configurées sur `C:\FinanceData` (visible via `Get-Acl`)
- [ ] `auditpol /get /subcategory:"File System"` indique Success et/ou Failure activés
- [ ] Des événements 4663 sont générés après accès aux fichiers
- [ ] Vous pouvez produire un rapport des 10 derniers accès au dossier

---

## Solution Complète (Pour Instructeur)

### Méthode PowerShell

```powershell
# Solution complète - Exercice 05

# === PARTIE 1 : Structure de dossiers et fichiers de test ===
$dossiers = @(
    "C:\FinanceData",
    "C:\FinanceData\Rapports",
    "C:\FinanceData\Budgets",
    "C:\FinanceData\Confidential"
)
foreach ($d in $dossiers) {
    New-Item -Path $d -ItemType Directory -Force | Out-Null
    Write-Host "Dossier créé : $d" -ForegroundColor Green
}

# Créer des fichiers de test
$contenu = "CONFIDENTIEL - MonitoringTech SPRL`nRapport Financier Q4 2025`nChiffre d'affaires: 2 450 000 EUR`nBénéfice net: 340 000 EUR"
Set-Content -Path "C:\FinanceData\Confidential\rapport_q4_2025.txt" -Value $contenu
Set-Content -Path "C:\FinanceData\Confidential\budget_previsionnel_2026.txt" -Value "BUDGET PRÉVISIONNEL 2026`nInvestissements IT: 150 000 EUR"
Set-Content -Path "C:\FinanceData\Confidential\salaires_direction.txt" -Value "CONFIDENTIEL - DONNÉES SALARIALES DIRECTION`nNe pas distribuer"
Set-Content -Path "C:\FinanceData\Rapports\rapport_mensuel_mars.txt" -Value "Rapport mensuel Mars 2026"
Set-Content -Path "C:\FinanceData\Budgets\budget_q1.txt" -Value "Budget Q1 2026 - Version finale"

Write-Host "Fichiers de test créés." -ForegroundColor Green

# === PARTIE 2 : Activer l'audit système (requis pour que NTFS génère des événements) ===
Write-Host "`nActivation des politiques d'audit système..." -ForegroundColor Yellow
auditpol /set /subcategory:"File System" /success:enable /failure:enable
auditpol /set /subcategory:"Handle Manipulation" /success:enable /failure:enable
auditpol /set /subcategory:"User Account Management" /success:enable /failure:enable
Write-Host "Politiques d'audit système activées." -ForegroundColor Green

# === PARTIE 3 : Configurer l'audit NTFS sur C:\FinanceData ===
Write-Host "`nConfiguration de l'audit NTFS..." -ForegroundColor Yellow

$path = "C:\FinanceData"
$acl = Get-Acl $path

# Créer la règle d'audit pour "Everyone" (Tout le monde)
$identity = [System.Security.Principal.NTAccount]"Everyone"
$rights = [System.Security.AccessControl.FileSystemRights]"Read, Write, Delete, Modify"
$auditFlags = [System.Security.AccessControl.AuditFlags]"Success,Failure"
$inheritFlags = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit,ObjectInherit"
$propFlags = [System.Security.AccessControl.PropagationFlags]"None"

$auditRule = New-Object System.Security.AccessControl.FileSystemAuditRule(
    $identity, $rights, $inheritFlags, $propFlags, $auditFlags
)
$acl.AddAuditRule($auditRule)
Set-Acl -Path $path -AclObject $acl
Write-Host "Audit NTFS configuré sur $path" -ForegroundColor Green

# === PARTIE 4 : Tester l'audit ===
Write-Host "`nTest d'accès aux fichiers pour générer des événements..." -ForegroundColor Yellow
Start-Sleep -Seconds 1
Get-Content "C:\FinanceData\Confidential\rapport_q4_2025.txt" | Out-Null
Get-Content "C:\FinanceData\Confidential\budget_previsionnel_2026.txt" | Out-Null
Get-ChildItem "C:\FinanceData\Confidential\" | Out-Null
Write-Host "Accès effectués. Consultez le journal Security pour les événements 4663." -ForegroundColor Green

# === PARTIE 5 : Rapport des accès ===
Write-Host "`n=== RAPPORT DES 10 DERNIERS ACCÈS AU DOSSIER FINANCE ===" -ForegroundColor Cyan
Start-Sleep -Seconds 2

$events = Get-WinEvent -LogName Security -MaxEvents 10000 -ErrorAction SilentlyContinue |
    Where-Object { $_.Id -eq 4663 }

$rapportAcces = foreach ($event in $events | Select-Object -First 20) {
    $xml = [xml]$event.ToXml()
    $data = $xml.Event.EventData.Data
    $user = ($data | Where-Object { $_.Name -eq "SubjectUserName" }).'#text'
    $file = ($data | Where-Object { $_.Name -eq "ObjectName" }).'#text'
    $access = ($data | Where-Object { $_.Name -eq "AccessMask" }).'#text'
    
    if ($file -like "*FinanceData*") {
        [PSCustomObject]@{
            Heure   = $event.TimeCreated.ToString("dd/MM/yyyy HH:mm:ss")
            Compte  = $user
            Fichier = $file
            Accès   = $access
        }
    }
}

if ($rapportAcces) {
    $rapportAcces | Format-Table -AutoSize
} else {
    Write-Host "Aucun accès au dossier Finance trouvé dans les journaux récents." -ForegroundColor Yellow
    Write-Host "Attendez quelques secondes et relancez la commande Get-WinEvent." -ForegroundColor Yellow
}
```

---

## Points Clés à Retenir

- L'audit NTFS seul ne suffit pas : il faut aussi activer l'audit système via `auditpol` pour que les événements 4663 soient générés
- L'audit NTFS se configure au niveau des ACL du dossier (SACL - System Access Control List), distinct des ACL de permissions
- Plus l'audit est granulaire, plus il génère de journaux. Un bon équilibre entre exhaustivité et performance est essentiel
- L'audit des accès aux fichiers sensibles est souvent exigé par des réglementations comme RGPD, ISO 27001, ou les réglementations financières

## Dépannage (Erreurs Courantes)

| Erreur Possible | Cause | Solution |
|-----------------|-------|----------|
| Aucun Event 4663 généré malgré l'audit NTFS | `auditpol` non activé pour "File System" | Exécuter `auditpol /set /subcategory:"File System" /success:enable` |
| Erreur "Accès refusé" sur Set-Acl | PowerShell non lancé en administrateur | Relancer PowerShell avec "Exécuter en tant qu'administrateur" |
| L'audit NTFS disparaît après redémarrage | GPO écrasant les paramètres locaux | Configurer l'audit dans une GPO plutôt qu'en local |
| Trop d'événements 4663 générés | Audit trop large (Everyone + FullControl) | Restreindre l'audit aux utilisateurs Finance uniquement |

## Exercice Suivant Suggéré

**Exercice 06 - Investigation d'Incident** : Vous allez maintenant utiliser toutes vos compétences d'audit pour investiguer un incident de sécurité réel simulé impliquant un compte de service utilisé de façon suspecte.
