# Exercice 02 : Horaire de Garde

## Niveau de Difficulté

🟢 **Débutant** (Guidé étape par étape)

## Objectifs Pédagogiques

- Créer un **compte utilisateur temporaire** avec date d'expiration
- Configurer des **horaires d'accès restreints** (logon hours) pour les gardes médicales
- Ajouter un utilisateur à un **groupe spécialisé** (Oncall)
- Tester les **restrictions temporelles** d'Active Directory

## Durée Estimée

**25-30 minutes**

## Prérequis

!!! info "Environnement requis"
    - Laboratoire MediCare **complètement configuré**
    - Groupe **GG-MediCare-Medical-Oncall** existant
    - Accès **Administrateur de domaine**
    - Connaissance de base d'Active Directory Users and Computers

## Contexte / Scénario

!!! example "Scénario réel - Système de garde MediCare"
    **Email du Coordinateur de Garde (Thomas Renard)** :

    > Bonjour IT,
    >
    > Nous avons besoin d'un **compte de garde rotatif** pour les urgences nocturnes et les week-ends.
    >
    > **Cahier des charges :**
    >
    > - Nom du compte : **"Médecin de Garde"** (SamAccountName : `garde`)
    > - Mot de passe temporaire : `MediCare2025!`
    > - **Horaires d'accès strictes** : Uniquement de **18h à 8h du matin** + **week-ends 24/7**
    > - Expiration du compte : **7 jours** (renouvellement hebdomadaire)
    > - Groupe d'accès : **GG-MediCare-Medical-Oncall** (accès système patients urgents)
    >
    > Le compte sera utilisé sur la station **URGENCES-WS01** pour les consultations de nuit.
    >
    > Merci!
    > Thomas Renard - Coordinateur de Garde

    **Votre mission** : Créer ce compte avec les restrictions horaires appropriées.

## Tâches à Réaliser

### Étape 1 : Créer le compte utilisateur "Médecin de Garde"

1. Ouvrir **Active Directory Users and Computers** (`dsa.msc`)

2. Naviguer vers : `maxtec.be > MediCare > Medical > Users`

3. Clic droit sur **Users** > **New** > **User**

4. Configurer le nouveau compte :
   - **First name** : `Médecin`
   - **Last name** : `de Garde`
   - **Full name** : `Médecin de Garde`
   - **User logon name** : `garde@maxtec.be`
   - Cliquer **Next**

5. Configurer le mot de passe :
   - **Password** : `MediCare2025!`
   - **Confirm password** : `MediCare2025!`
   - Décocher **"User must change password at next logon"**
   - Cocher **"User cannot change password"** (compte partagé)
   - Cocher **"Password never expires"** (compte de service)
   - Cliquer **Next** > **Finish**

!!! success "Résultat attendu"
    Le compte **garde** apparaît dans la liste des utilisateurs de l'OU Medical > Users.

### Étape 2 : Configurer la date d'expiration du compte

1. Dans **Active Directory Users and Computers**, double-cliquer sur **Médecin de Garde**

2. Onglet **Account**

3. Section **Account expires** :
   - Sélectionner **End of:** (radio button)
   - Cliquer sur le calendrier et sélectionner **la date dans 7 jours**
   - Exemple : Si aujourd'hui est le 5 octobre, sélectionner le 12 octobre

4. Cliquer **Apply**

!!! success "Résultat attendu"
    Le compte expirera automatiquement dans 7 jours.

### Étape 3 : Configurer les horaires d'accès (Logon Hours)

!!! warning "Restriction horaire complexe"
    Nous devons autoriser l'accès uniquement :

    - **Lundi à Vendredi** : 18h00 - 23h59 + 00h00 - 08h00
    - **Samedi et Dimanche** : 24h/24 (00h00 - 23h59)

1. Toujours dans les propriétés de **Médecin de Garde**, onglet **Account**

2. Cliquer sur le bouton **Logon Hours...**

3. **Par défaut, tous les créneaux sont autorisés (bleu)**

4. **Bloquer d'abord toutes les heures de travail normales** (8h-18h, lundi-vendredi) :
   - **Lundi** : Cliquer et glisser de **8 AM** à **6 PM** (devient blanc/bloqué)
   - Répéter pour **Mardi, Mercredi, Jeudi, Vendredi**

5. Vérifier que les créneaux suivants sont **autorisés (bleu)** :
   - Lundi-Vendredi : 18h (6 PM) → 8h (8 AM le lendemain)
   - Samedi-Dimanche : 0h → 23h (toute la journée)

6. Cliquer **OK** > **Apply** > **OK**

!!! success "Résultat attendu"
    La grille des horaires montre :

    - Lundi-Vendredi : Bleu de 18h à 8h (+ plage nocturne), Blanc de 8h à 18h
    - Samedi-Dimanche : Entièrement bleu (24/24)

### Étape 4 : Ajouter le compte au groupe GG-MediCare-Medical-Oncall

1. Dans **Active Directory Users and Computers**, naviguer vers : `MediCare > Medical > Groups`

2. Double-cliquer sur **GG-MediCare-Medical-Oncall**

3. Onglet **Members**

4. Cliquer **Add...**

5. Dans le champ **Enter the object names to select**, taper : `garde`

6. Cliquer **Check Names** (le nom doit devenir souligné : **Médecin de Garde**)

7. Cliquer **OK** > **Apply** > **OK**

!!! success "Résultat attendu"
    Le compte **Médecin de Garde** apparaît dans la liste des membres du groupe Oncall.

### Étape 5 : Configurer les propriétés additionnelles

1. Retourner aux propriétés de **Médecin de Garde**

2. Onglet **General** :
   - **Description** : `Compte de garde rotatif - Urgences nocturnes et week-ends`
   - **Office** : `Salle des Urgences`
   - **Telephone number** : `+32-2-555-URGE`

3. Onglet **Organization** :
   - **Title** : `Médecin de Garde`
   - **Department** : `Medical`

4. Cliquer **Apply** > **OK**

!!! success "Résultat attendu"
    Les propriétés du compte sont complètes et documentées.

### Étape 6 : Vérification PowerShell du compte créé

1. Ouvrir **PowerShell ISE** en tant qu'**Administrateur**

2. Exécuter le script de vérification suivant :

```powershell
# Vérification du compte de garde
Import-Module ActiveDirectory

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "VÉRIFICATION COMPTE MÉDECIN DE GARDE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Obtenir le compte
$garde = Get-ADUser -Identity garde -Properties AccountExpirationDate, Description, Title, Department, LogonHours

Write-Host "`n✓ Compte trouvé: $($garde.Name)" -ForegroundColor Green
Write-Host "  SamAccountName: $($garde.SamAccountName)" -ForegroundColor Gray
Write-Host "  Description: $($garde.Description)" -ForegroundColor Gray
Write-Host "  Titre: $($garde.Title)" -ForegroundColor Gray
Write-Host "  Département: $($garde.Department)" -ForegroundColor Gray

# Vérifier expiration
if ($garde.AccountExpirationDate) {
    $daysUntilExpiry = ($garde.AccountExpirationDate - (Get-Date)).Days
    Write-Host "`n✓ Expiration configurée:" -ForegroundColor Green
    Write-Host "  Date: $($garde.AccountExpirationDate)" -ForegroundColor Gray
    Write-Host "  Expire dans: $daysUntilExpiry jours" -ForegroundColor Yellow
} else {
    Write-Host "`n✗ ERREUR: Aucune date d'expiration configurée!" -ForegroundColor Red
}

# Vérifier groupe Oncall
$oncallGroup = Get-ADGroupMember -Identity "GG-MediCare-Medical-Oncall" | Where-Object {$_.SamAccountName -eq "garde"}
if ($oncallGroup) {
    Write-Host "`n✓ Membre du groupe GG-MediCare-Medical-Oncall" -ForegroundColor Green
} else {
    Write-Host "`n✗ ERREUR: Pas membre du groupe Oncall!" -ForegroundColor Red
}

# Vérifier horaires d'accès
if ($garde.LogonHours) {
    Write-Host "`n✓ Horaires d'accès configurés (Logon Hours)" -ForegroundColor Green
    Write-Host "  (Détails visibles dans l'interface graphique)" -ForegroundColor Gray
} else {
    Write-Host "`n⚠️  AVERTISSEMENT: Horaires d'accès non configurés (accès 24/7)" -ForegroundColor Yellow
}
```

!!! success "Résultat attendu"
    Le script affiche toutes les propriétés du compte avec des messages de succès en vert.

### Étape 7 : Tester les restrictions horaires

!!! warning "Test en conditions réelles"
    Pour tester pleinement cette configuration, vous devriez :

    1. **Tester dans les horaires autorisés** (18h-8h ou week-end)
    2. **Tester hors horaires** (8h-18h en semaine)

**Méthode de test :**

1. Si vous êtes **dans les horaires autorisés** (soir/nuit/week-end) :

```powershell
# Test de connexion (simulation)
runas /user:maxtec\garde "powershell -NoExit -Command 'Write-Host Connexion autorisée! -ForegroundColor Green'"
```

2. Si vous êtes **hors horaires autorisés** (journée de semaine) :
   - La tentative de connexion devrait échouer avec le message :
   - **"Your account has time restrictions that prevent you from signing in at this time."**

!!! tip "Simulation de test"
    Si vous ne pouvez pas attendre les horaires de garde, vous pouvez :

    - **Temporairement autoriser toutes les heures** pour tester que le compte fonctionne
    - **Vérifier via PowerShell** que les LogonHours sont bien définies
    - **Consulter l'interface graphique** pour voir la grille horaire

### Étape 8 : Documentation pour le coordinateur de garde

1. Créer un fichier de documentation dans **C:\Labos\MediCare\Garde_Instructions.txt** :

```powershell
# Créer fichier d'instructions
$instructions = @"
========================================
COMPTE DE GARDE - INSTRUCTIONS
========================================

Compte utilisateur : garde@maxtec.be
Mot de passe : MediCare2025!

HORAIRES D'ACCÈS AUTORISÉS:
- Lundi à Vendredi : 18h00 - 08h00 (soirée + nuit)
- Samedi et Dimanche : 24h/24

EXPIRATION DU COMPTE:
Le compte expire dans 7 jours et doit être renouvelé chaque semaine.

STATION DE TRAVAIL:
Utilisez le poste URGENCES-WS01 pour les consultations nocturnes.

ACCÈS SYSTÈME:
Le compte donne accès aux dossiers patients urgents via le groupe Oncall.

Pour renouveler le compte, contactez l'équipe IT.

========================================
Généré le: $(Get-Date -Format "yyyy-MM-dd HH:mm")
========================================
"@

New-Item -Path "C:\Labos\MediCare" -ItemType Directory -Force | Out-Null
$instructions | Out-File -FilePath "C:\Labos\MediCare\Garde_Instructions.txt" -Encoding UTF8

Write-Host "`n✅ Instructions créées dans C:\Labos\MediCare\Garde_Instructions.txt" -ForegroundColor Green
notepad "C:\Labos\MediCare\Garde_Instructions.txt"
```

!!! success "Résultat attendu"
    Le fichier d'instructions s'ouvre automatiquement dans Notepad pour révision.

## Vérification de la Réussite

### Commandes PowerShell de Vérification

Exécutez le script de vérification automatique :

```powershell
C:\Labos\MediCare\scripts\verification\verif_exercice_02.ps1
```

### Critères de Réussite

- [ ] Le compte **garde** existe dans `OU=Users,OU=Medical,OU=MediCare`
- [ ] Le compte a une **date d'expiration** dans 7 jours
- [ ] Les **horaires d'accès** (Logon Hours) sont configurés (18h-8h + week-ends)
- [ ] Le compte est **membre** du groupe **GG-MediCare-Medical-Oncall**
- [ ] Les propriétés **Description**, **Title**, **Department** sont renseignées
- [ ] Le fichier d'instructions existe dans **C:\Labos\MediCare\**

## Solution Complète (Pour Instructeur)

### Méthode GUI

Suivre les étapes 1 à 7 décrites dans la section "Tâches à Réaliser" ci-dessus.

### Méthode PowerShell

```powershell
# === SCRIPT COMPLET - Création Compte de Garde ===

Import-Module ActiveDirectory

# Variables
$ouPath = "OU=Users,OU=Medical,OU=MediCare,DC=maxtec,DC=be"
$expirationDate = (Get-Date).AddDays(7)

# 1. Créer le compte utilisateur
Write-Host "`n[ÉTAPE 1] Création du compte Médecin de Garde..." -ForegroundColor Cyan
try {
    $password = ConvertTo-SecureString "MediCare2025!" -AsPlainText -Force

    New-ADUser `
        -Name "Médecin de Garde" `
        -GivenName "Médecin" `
        -Surname "de Garde" `
        -SamAccountName "garde" `
        -UserPrincipalName "garde@maxtec.be" `
        -Path $ouPath `
        -AccountPassword $password `
        -Enabled $true `
        -PasswordNeverExpires $true `
        -CannotChangePassword $true `
        -AccountExpirationDate $expirationDate `
        -Description "Compte de garde rotatif - Urgences nocturnes et week-ends" `
        -Title "Médecin de Garde" `
        -Department "Medical" `
        -Office "Salle des Urgences" `
        -OfficePhone "+32-2-555-URGE"

    Write-Host "  ✓ Compte 'garde' créé avec succès" -ForegroundColor Green
    Write-Host "    Expiration: $expirationDate" -ForegroundColor Gray
} catch {
    Write-Host "  ✗ ERREUR: $($_.Exception.Message)" -ForegroundColor Red
}

# 2. Configurer les horaires d'accès (Logon Hours)
Write-Host "`n[ÉTAPE 2] Configuration des horaires d'accès..." -ForegroundColor Cyan

# Créer le tableau d'heures (21 bytes, 168 bits pour 7 jours x 24 heures)
# Chaque octet représente 8 heures, chaque bit = 1 heure
# 1 = autorisé, 0 = bloqué
# Ordre: Dimanche, Lundi, Mardi, Mercredi, Jeudi, Vendredi, Samedi

# Configuration simplifiée: Autoriser 18h-8h en semaine + 24/7 week-end
# Cette configuration est complexe en PowerShell, utilisation de la GUI recommandée

Write-Host "  ⚠️  Les horaires d'accès doivent être configurés manuellement via GUI" -ForegroundColor Yellow
Write-Host "     Active Directory Users > garde > Account > Logon Hours" -ForegroundColor Gray
Write-Host "     Bloquer: Lundi-Vendredi 8h-18h" -ForegroundColor Gray
Write-Host "     Autoriser: Tout le reste (18h-8h + week-ends)" -ForegroundColor Gray

# NOTE TECHNIQUE: La configuration via PowerShell nécessite manipulation de bits
# Pour référence instructeur:
# $logonHours = [byte[]]::new(21)
# [Manipulation complexe des bits pour chaque tranche horaire]
# Set-ADUser -Identity garde -Replace @{logonHours = $logonHours}

# 3. Ajouter au groupe Oncall
Write-Host "`n[ÉTAPE 3] Ajout au groupe Oncall..." -ForegroundColor Cyan
try {
    Add-ADGroupMember -Identity "GG-MediCare-Medical-Oncall" -Members garde
    Write-Host "  ✓ Ajouté au groupe GG-MediCare-Medical-Oncall" -ForegroundColor Green
} catch {
    Write-Host "  ✗ ERREUR: $($_.Exception.Message)" -ForegroundColor Red
}

# 4. Créer fichier d'instructions
Write-Host "`n[ÉTAPE 4] Création du fichier d'instructions..." -ForegroundColor Cyan
$instructions = @"
========================================
COMPTE DE GARDE - INSTRUCTIONS
========================================

Compte utilisateur : garde@maxtec.be
Mot de passe : MediCare2025!

HORAIRES D'ACCÈS AUTORISÉS:
- Lundi à Vendredi : 18h00 - 08h00 (soirée + nuit)
- Samedi et Dimanche : 24h/24

EXPIRATION DU COMPTE:
Le compte expire le $($expirationDate.ToString("yyyy-MM-dd")) et doit être renouvelé.

STATION DE TRAVAIL:
Utilisez le poste URGENCES-WS01 pour les consultations nocturnes.

ACCÈS SYSTÈME:
Le compte donne accès aux dossiers patients urgents via le groupe Oncall.

Pour renouveler le compte, contactez l'équipe IT.

========================================
Généré le: $(Get-Date -Format "yyyy-MM-dd HH:mm")
========================================
"@

New-Item -Path "C:\Labos\MediCare" -ItemType Directory -Force | Out-Null
$instructions | Out-File -FilePath "C:\Labos\MediCare\Garde_Instructions.txt" -Encoding UTF8
Write-Host "  ✓ Instructions créées: C:\Labos\MediCare\Garde_Instructions.txt" -ForegroundColor Green

Write-Host "`n✅ Configuration du compte de garde terminée!" -ForegroundColor Green
Write-Host "`n⚠️  ACTION MANUELLE REQUISE:" -ForegroundColor Yellow
Write-Host "  Configurez les Logon Hours via Active Directory Users and Computers" -ForegroundColor Yellow
```

## Points Clés à Retenir

!!! tip "Concepts importants"
    1. **Comptes temporaires** : Utiliser `AccountExpirationDate` pour les comptes à durée limitée (stagiaires, gardes, consultants)

    2. **Logon Hours** : Permet de restreindre les heures de connexion selon les besoins métier (gardes médicales, shifts)

    3. **Comptes partagés** : Configurer `CannotChangePassword` pour les comptes utilisés par plusieurs personnes

    4. **Groupes spécialisés** : Le groupe Oncall permet un accès distant/urgence sans donner tous les droits admin

    5. **Documentation** : Toujours fournir des instructions claires pour les utilisateurs finaux

## Dépannage (Erreurs Courantes)

| Erreur Possible | Cause | Solution |
|-----------------|-------|----------|
| "User already exists" | Compte garde existe déjà | Supprimer l'ancien compte ou utiliser Remove-ADUser |
| "Password does not meet requirements" | Politique de mot de passe stricte | Vérifier complexité minimale (12 caractères dans MediCare) |
| "Cannot find group Oncall" | Nom de groupe incorrect | Vérifier avec `Get-ADGroup -Filter {Name -like "*Oncall*"}` |
| Logon Hours non sauvegardées | Erreur de manipulation GUI | Cliquer bien sur **OK** (pas Cancel) dans chaque dialogue |
| Expiration non visible | Mauvaise date sélectionnée | Vérifier avec `Get-ADUser garde -Properties AccountExpirationDate` |

## Exercice Suivant Suggéré

!!! tip "Progression pédagogique"
    Une fois cet exercice maîtrisé, passez à :

    **[Exercice 03 : Audit d'Accès Médical](Exercice_03_Audit_Acces_Medical.md)** - Activer l'audit des fichiers et générer un rapport de conformité RGPD.
