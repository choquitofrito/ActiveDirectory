# Exercice 7 : Scénario Complet - Onboarding d'une Nouvelle Stagiaire

## Niveau de Difficulté
🔴 **Avancé** - Scénario réaliste multi-tâches

## Objectifs Pédagogiques
- Intégrer plusieurs compétences AD dans un workflow réaliste
- Prendre des décisions autonomes sur la configuration
- Gérer des exigences de sécurité complexes
- Documenter son travail pour l'audit

## Durée Estimée
40-50 minutes

## Prérequis
- Maîtrise des exercices 1 à 6
- Compréhension des groupes, GPO, et délégation
- Capacité à travailler de manière autonome
- Esprit d'analyse et résolution de problèmes

## Contexte / Scénario
**Date**: Lundi 7 octobre 2025, 8h30

Vous arrivez au bureau et trouvez cet email de Gabrielle Simon (Directrice Artistique) dans votre boîte de réception, envoyé hier soir à 22h :

> **Objet : URGENT - Nouvelle stagiaire demain matin 9h !**
>
> *Bonjour l'équipe IT,*
>
> *Je sais que c'est un court préavis, mais nous avons une excellente nouvelle ! Léa Fontaine, une brillante étudiante en design graphique, commence son stage de 3 mois chez nous DEMAIN à 9h00. Elle nous a été recommandée par un de nos meilleurs clients.*
>
> **Informations sur Léa :**
> - Nom complet : Léa Fontaine
> - Email souhaité : lea.fontaine@maxtec.be
> - Fonction : Stagiaire Graphiste
> - Département : Creative
> - Durée du stage : 3 mois (fin le 7 janvier 2026)
> - Manager direct : Moi-même (Gabrielle Simon)
>
> **Besoins d'accès :**
>
> 1. **Compte utilisateur** avec les restrictions standards pour les stagiaires :
>    - Pas d'accès au Panneau de configuration
>    - Pas d'accès à l'invite de commandes
>    - Compte temporaire (expiration automatique à la fin du stage)
>
> 2. **Accès aux ressources Creative** :
>    - Doit être membre du groupe Creative-Users pour accéder aux ressources partagées
>    - Doit pouvoir accéder au lecteur réseau des ressources créatives (si configuré)
>
> 3. **Projet spécial - SecureBank** :
>    - Léa va travailler sur le projet SecureBank avec Fabien
>    - Elle doit donc être ajoutée au groupe projet SecureBank
>    - MAIS : comme c'est une stagiaire, elle ne doit avoir qu'un accès EN LECTURE SEULE
>    - (Note IT : Créez un sous-groupe "GG-Projet-SecureBank-Lecture" si nécessaire)
>
> 4. **Restrictions de sécurité pour stagiaires** :
>    - Bloquer l'accès aux périphériques USB (comme pour Client Services)
>    - Mot de passe initial : "StageCreative2025!" qu'elle devra changer à la première connexion
>    - Son poste de travail sera DESKTOP-CREATIVE-03
>
> *Pouvez-vous configurer tout cela avant 9h demain ? Léa aura besoin d'être opérationnelle dès son arrivée pour rencontrer le client à 10h.*
>
> *Merci infiniment !*
> *Gabrielle*

Vous recevez également ce message de Rachid Dupont (Responsable IT) :

> *"J'ai vu l'email de Gabrielle. Utilise cette opportunité pour mettre en place notre nouveau processus d'onboarding pour stagiaires. Pense à :*
> - *Documenter chaque étape de ce que tu fais*
> - *Créer une checklist réutilisable pour les prochains stagiaires*
> - *Vérifier que toutes les mesures de sécurité sont en place*
> - *M'envoyer un rapport de ce qui a été configuré*
>
> *Si tu as besoin de créer une nouvelle GPO ou de nouveaux groupes, vas-y. Fais preuve d'initiative !*
> *Rachid*"

## Tâche à Réaliser

Vous devez configurer l'environnement AD complet pour l'arrivée de Léa Fontaine.

### Mission Principale

Préparer l'environnement Active Directory pour permettre à Léa Fontaine de commencer son stage dans les meilleures conditions, tout en respectant les contraintes de sécurité pour les stagiaires.

### Exigences Détaillées

#### 1. Création du Compte Utilisateur

- **SAM Account** : `lea.fontaine` ou `lfontaine` (à votre choix, justifiez)
- **Email** : `lea.fontaine@maxtec.be`
- **Fonction** : Stagiaire Graphiste
- **Département** : Creative
- **Mot de passe initial** : `StageCreative2025!`
- **Forcer le changement de mot de passe** : Oui
- **Date d'expiration du compte** : 7 janvier 2026 (fin du stage)
- **Description** : Documenter qu'il s'agit d'un stagiaire avec dates de début et fin

#### 2. Gestion des Groupes

- Ajouter Léa au groupe `GG-CreativeHub-Creative-Users`
- Gérer l'accès au projet SecureBank :
  - **Option A** : Créer un nouveau groupe `GG-Projet-SecureBank-Lecture` pour les accès en lecture seule
  - **Option B** : L'ajouter au groupe existant et gérer les permissions NTFS séparément
  - Justifier votre choix dans votre documentation

#### 3. Configuration des Restrictions de Sécurité (GPO)

Vous devez appliquer les restrictions suivantes à Léa :

- Désactiver le Panneau de configuration
- Désactiver l'invite de commandes
- Bloquer les périphériques USB

**Réflexion** : Comment appliquer ces GPO ?

- Option 1 : Les GPO existantes couvrent-elles déjà ces besoins ?
- Option 2 : Faut-il créer une nouvelle GPO spécifique aux stagiaires ?
- Option 3 : Faut-il créer une OU dédiée aux stagiaires ?

#### 4. Documentation et Rapport

Créer un document texte (ou commentaire dans le script) qui contient :

- Liste de toutes les actions effectuées
- Justification des choix techniques (OU, groupes, GPO)
- Informations de connexion à communiquer à Léa
- Checklist de vérification avant l'arrivée de Léa
- Procédure de départ (offboarding) à suivre dans 3 mois

### Questions Stratégiques à Résoudre

1. **Organisation des stagiaires** :
   - Faut-il créer une OU `OU=Stagiaires` sous Creative ?
   - Ou garder Léa dans `OU=Users,OU=Creative` ?
   - Quels sont les avantages/inconvénients de chaque approche ?

2. **Gestion des GPO** :
   - La GPO "Restrictions Utilisateurs Juniors" existante s'applique-t-elle déjà ?
   - Faut-il créer une GPO "Restrictions Stagiaires" spécifique ?
   - Comment gérer le blocage USB (GPO existante pour Client Services) ?

3. **Sécurité du projet SecureBank** :
   - Comment gérer un accès en lecture seule via les groupes AD ?
   - Faut-il créer une hiérarchie de groupes (global → domain local) ?

4. **Expiration du compte** :
   - Comment configurer l'expiration automatique à une date précise ?
   - Que se passe-t-il après l'expiration (réactivation possible ?) ?

### Aucune Instruction Détaillée !

Cet exercice est volontairement ouvert. Utilisez votre jugement professionnel, vos connaissances des bonnes pratiques AD, et votre capacité de recherche pour trouver les meilleures solutions.

**Ressources autorisées** :

- Documentation Microsoft (Get-Help, liens web)
- PowerShell Get-Command / Get-Help
- Vos notes des exercices précédents

## Vérification de la Réussite

### Script de Vérification Automatique

```powershell
.\verif_exercice_07.ps1
```

### Critères de Réussite (Minimum)

- [ ] Le compte utilisateur de Léa existe avec les propriétés correctes
- [ ] Le compte expire automatiquement le 7 janvier 2026
- [ ] Léa doit changer son mot de passe à la première connexion
- [ ] Léa est membre du groupe Creative-Users
- [ ] Léa a un accès (direct ou indirect) au projet SecureBank
- [ ] Des restrictions de sécurité (GPO) s'appliquent au compte de Léa
- [ ] Le compte est documenté (description, notes)
- [ ] *Bonus* : Une OU spécifique pour les stagiaires a été créée
- [ ] *Bonus* : Un groupe séparé pour la lecture seule SecureBank existe
- [ ] *Bonus* : Documentation complète du processus

### Test Manuel Recommandé

1. **Vérifier l'expiration du compte** :
   ```powershell
   Get-ADUser -Identity lea.fontaine -Properties AccountExpirationDate | Select-Object Name, AccountExpirationDate
   ```

2. **Vérifier les appartenances** :
   ```powershell
   Get-ADPrincipalGroupMembership -Identity lea.fontaine | Select-Object Name
   ```

3. **Vérifier les GPO applicables** :
   ```powershell
   gpresult /r /scope:user /user:lea.fontaine
   ```

## Solution Complète (Pour Instructeur)

### Approche Recommandée

#### Étape 1 : Analyse et Décisions Stratégiques

**Décisions** :

1. **OU pour les stagiaires** : Créer `OU=Stagiaires,OU=Creative` pour faciliter la gestion des GPO
2. **SAM Account** : Utiliser `lea.fontaine` (plus clair que `lfontaine`)
3. **Groupe lecture seule** : Créer `GG-Projet-SecureBank-Lecture` pour la scalabilité
4. **GPO** : Créer une GPO "CreativeHub - Restrictions Stagiaires" liée à l'OU Stagiaires

#### Étape 2 : Implémentation PowerShell

```powershell
Import-Module ActiveDirectory

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " ONBOARDING STAGIAIRE - LÉA FONTAINE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Variables
$firstName = "Léa"
$lastName = "Fontaine"
$samAccount = "lea.fontaine"
$email = "lea.fontaine@maxtec.be"
$title = "Stagiaire Graphiste"
$department = "Creative"
$password = ConvertTo-SecureString "StageCreative2025!" -AsPlainText -Force
$expirationDate = Get-Date "2026-01-07" # Fin du stage
$description = "STAGIAIRE - Du 07/10/2025 au 07/01/2026 - Manager: Gabrielle Simon"

$rootOU = "OU=CreativeHub,DC=maxtec,DC=be"
$creativeOU = "OU=Creative,$rootOU"
$stagiaireOU = "OU=Stagiaires,$creativeOU"

# ÉTAPE 1: Créer l'OU Stagiaires
Write-Host "`n[1/7] Création de l'OU Stagiaires..." -ForegroundColor Yellow
try {
    Get-ADOrganizationalUnit -Identity $stagiaireOU -ErrorAction Stop | Out-Null
    Write-Host "  L'OU Stagiaires existe déjà." -ForegroundColor Yellow
} catch {
    New-ADOrganizationalUnit -Name "Stagiaires" -Path $creativeOU -ProtectedFromAccidentalDeletion $false
    Write-Host "  ✓ OU Stagiaires créée" -ForegroundColor Green
}

# ÉTAPE 2: Créer le compte utilisateur
Write-Host "`n[2/7] Création du compte utilisateur..." -ForegroundColor Yellow
try {
    Get-ADUser -Identity $samAccount -ErrorAction Stop | Out-Null
    Write-Host "  L'utilisateur $samAccount existe déjà." -ForegroundColor Yellow
} catch {
    New-ADUser -Name "$firstName $lastName" `
        -GivenName $firstName `
        -Surname $lastName `
        -SamAccountName $samAccount `
        -UserPrincipalName "$samAccount@maxtec.be" `
        -EmailAddress $email `
        -Title $title `
        -Department $department `
        -Description $description `
        -Path $stagiaireOU `
        -AccountPassword $password `
        -Enabled $true `
        -ChangePasswordAtLogon $true `
        -AccountExpirationDate $expirationDate
    
    Write-Host "  ✓ Compte créé pour $firstName $lastName" -ForegroundColor Green
    Write-Host "    SAM Account  : $samAccount" -ForegroundColor Gray
    Write-Host "    Email        : $email" -ForegroundColor Gray
    Write-Host "    Expiration   : $expirationDate" -ForegroundColor Gray
}

# ÉTAPE 3: Ajouter aux groupes
Write-Host "`n[3/7] Ajout aux groupes de sécurité..." -ForegroundColor Yellow

# Groupe Creative-Users
try {
    Add-ADGroupMember -Identity "GG-CreativeHub-Creative-Users" -Members $samAccount -ErrorAction Stop
    Write-Host "  ✓ Ajoutée au groupe Creative-Users" -ForegroundColor Green
} catch {
    if ($_.Exception.Message -like "*already a member*") {
        Write-Host "  Déjà membre de Creative-Users" -ForegroundColor Yellow
    } else {
        Write-Host "  ✗ ERREUR: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# ÉTAPE 4: Créer le groupe de lecture SecureBank
Write-Host "`n[4/7] Création du groupe lecture SecureBank..." -ForegroundColor Yellow
$groupLecture = "GG-Projet-SecureBank-Lecture"
$projectGroupsOU = "OU=Groupes_Projets,$rootOU"

try {
    Get-ADGroup -Identity $groupLecture -ErrorAction Stop | Out-Null
    Write-Host "  Le groupe $groupLecture existe déjà." -ForegroundColor Yellow
} catch {
    # Créer l'OU Groupes_Projets si nécessaire
    try {
        Get-ADOrganizationalUnit -Identity $projectGroupsOU -ErrorAction Stop | Out-Null
    } catch {
        New-ADOrganizationalUnit -Name "Groupes_Projets" -Path $rootOU -ProtectedFromAccidentalDeletion $false
        Write-Host "  ✓ OU Groupes_Projets créée" -ForegroundColor Green
    }
    
    New-ADGroup -Name $groupLecture `
        -GroupScope Global `
        -GroupCategory Security `
        -Path $projectGroupsOU `
        -Description "Accès lecture seule au projet SecureBank (stagiaires et consultants)"
    
    Write-Host "  ✓ Groupe $groupLecture créé" -ForegroundColor Green
}

# Ajouter Léa au groupe lecture
try {
    Add-ADGroupMember -Identity $groupLecture -Members $samAccount -ErrorAction Stop
    Write-Host "  ✓ Léa ajoutée au groupe lecture SecureBank" -ForegroundColor Green
} catch {
    if ($_.Exception.Message -like "*already a member*") {
        Write-Host "  Déjà membre du groupe lecture" -ForegroundColor Yellow
    }
}

# ÉTAPE 5: Créer la GPO Restrictions Stagiaires
Write-Host "`n[5/7] Configuration des restrictions GPO..." -ForegroundColor Yellow
$gpoName = "CreativeHub - Restrictions Stagiaires"

try {
    Get-GPO -Name $gpoName -ErrorAction Stop | Out-Null
    Write-Host "  La GPO $gpoName existe déjà." -ForegroundColor Yellow
} catch {
    # Créer la GPO
    Import-Module GroupPolicy
    New-GPO -Name $gpoName -Comment "Restrictions de sécurité pour les stagiaires" | Out-Null
    
    # Désactiver le Panneau de configuration
    Set-GPRegistryValue -Name $gpoName `
        -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
        -ValueName "NoControlPanel" -Type DWord -Value 1 | Out-Null
    
    # Désactiver l'invite de commandes
    Set-GPRegistryValue -Name $gpoName `
        -Key "HKCU\Software\Policies\Microsoft\Windows\System" `
        -ValueName "DisableCMD" -Type DWord -Value 2 | Out-Null
    
    # Bloquer les périphériques USB (lecture et écriture)
    Set-GPRegistryValue -Name $gpoName `
        -Key "HKLM\Software\Policies\Microsoft\Windows\RemovableStorageDevices\{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}" `
        -ValueName "Deny_Write" -Type DWord -Value 1 | Out-Null
    
    Set-GPRegistryValue -Name $gpoName `
        -Key "HKLM\Software\Policies\Microsoft\Windows\RemovableStorageDevices\{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}" `
        -ValueName "Deny_Read" -Type DWord -Value 1 | Out-Null
    
    Write-Host "  ✓ GPO créée avec restrictions" -ForegroundColor Green
    Write-Host "    - Panneau de configuration désactivé" -ForegroundColor Gray
    Write-Host "    - Invite de commandes désactivée" -ForegroundColor Gray
    Write-Host "    - Périphériques USB bloqués" -ForegroundColor Gray
}

# ÉTAPE 6: Lier la GPO à l'OU Stagiaires
Write-Host "`n[6/7] Liaison de la GPO..." -ForegroundColor Yellow
try {
    $existingLink = Get-GPInheritance -Target $stagiaireOU -ErrorAction Stop |
        Select-Object -ExpandProperty GpoLinks |
        Where-Object {$_.DisplayName -eq $gpoName}
    
    if ($existingLink) {
        Write-Host "  La GPO est déjà liée à l'OU Stagiaires." -ForegroundColor Yellow
    } else {
        New-GPLink -Name $gpoName -Target $stagiaireOU -LinkEnabled Yes | Out-Null
        Write-Host "  ✓ GPO liée à l'OU Stagiaires" -ForegroundColor Green
    }
} catch {
    Write-Host "  ⚠ Vérifiez manuellement le lien GPO" -ForegroundColor Yellow
}

# ÉTAPE 7: Vérification finale
Write-Host "`n[7/7] Vérification finale..." -ForegroundColor Yellow
$user = Get-ADUser -Identity $samAccount -Properties AccountExpirationDate, PasswordExpired, Description

Write-Host "  ✓ Compte vérifié:" -ForegroundColor Green
Write-Host "    Nom             : $($user.Name)" -ForegroundColor White
Write-Host "    Email           : $email" -ForegroundColor White
Write-Host "    Expiration      : $($user.AccountExpirationDate)" -ForegroundColor White
Write-Host "    Doit changer MDP: $($user.PasswordExpired)" -ForegroundColor White
Write-Host "    Description     : $($user.Description)" -ForegroundColor Gray

# Groupes
$groups = Get-ADPrincipalGroupMembership -Identity $samAccount
Write-Host "`n  Groupes:" -ForegroundColor Cyan
foreach ($group in $groups) {
    Write-Host "    - $($group.Name)" -ForegroundColor White
}

# RAPPORT FINAL
Write-Host "`n========================================" -ForegroundColor Green
Write-Host " ONBOARDING TERMINÉ AVEC SUCCÈS" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Write-Host "`nInformations à communiquer à Léa Fontaine:" -ForegroundColor Cyan
Write-Host "  Nom d'utilisateur : $samAccount" -ForegroundColor White
Write-Host "  Mot de passe      : StageCreative2025!" -ForegroundColor Yellow
Write-Host "  Email             : $email" -ForegroundColor White
Write-Host "  Domaine           : MAXTEC" -ForegroundColor White
Write-Host "`n  ⚠ Léa devra changer son mot de passe lors de la première connexion" -ForegroundColor Yellow
Write-Host "  ⚠ Le compte expirera automatiquement le $($expirationDate.ToShortDateString())" -ForegroundColor Yellow

Write-Host "`nConfiguration de sécurité appliquée:" -ForegroundColor Cyan
Write-Host "  ✓ Panneau de configuration désactivé" -ForegroundColor Gray
Write-Host "  ✓ Invite de commandes désactivée" -ForegroundColor Gray
Write-Host "  ✓ Périphériques USB bloqués" -ForegroundColor Gray
Write-Host "  ✓ Accès lecture seule au projet SecureBank" -ForegroundColor Gray

Write-Host "`nRappel - Dans 3 mois (fin du stage):" -ForegroundColor Cyan
Write-Host "  1. Le compte sera automatiquement désactivé le 07/01/2026" -ForegroundColor Gray
Write-Host "  2. Vérifier qu'aucun fichier important n'est dans son profil" -ForegroundColor Gray
Write-Host "  3. Retirer Léa des groupes de sécurité" -ForegroundColor Gray
Write-Host "  4. Archiver le compte pendant 6 mois avant suppression définitive" -ForegroundColor Gray
```

### Documentation Recommandée

Créer un fichier `Onboarding_Lea_Fontaine_Rapport.txt` :

```text
========================================
RAPPORT D'ONBOARDING STAGIAIRE
========================================

Stagiaire     : Léa Fontaine
Date début    : 07/10/2025
Date fin      : 07/01/2026 (3 mois)
Département   : Creative
Manager       : Gabrielle Simon

========================================
ACTIONS EFFECTUÉES
========================================

1. STRUCTURE AD
   - Créé OU : OU=Stagiaires,OU=Creative,OU=CreativeHub,DC=maxtec,DC=be
   - Justification : Facilite l'application des GPO spécifiques aux stagiaires

2. COMPTE UTILISATEUR
   - SAM Account : lea.fontaine
   - UPN : lea.fontaine@maxtec.be
   - Email : lea.fontaine@maxtec.be
   - Fonction : Stagiaire Graphiste
   - Département : Creative
   - Expiration : 07/01/2026 (automatique)
   - Change Password At Logon : Oui
   - Emplacement : OU=Stagiaires,OU=Creative,OU=CreativeHub,DC=maxtec,DC=be

3. GROUPES DE SÉCURITÉ
   a) GG-CreativeHub-Creative-Users
      - Accès aux ressources partagées du département Creative

   b) GG-Projet-SecureBank-Lecture (CRÉÉ)
      - Groupe Global pour accès lecture seule au projet SecureBank
      - Permet de gérer finement les permissions NTFS
      - Scalable pour futurs stagiaires/consultants

4. STRATÉGIES DE GROUPE (GPO)
   - Créé GPO : "CreativeHub - Restrictions Stagiaires"
   - Restrictions appliquées :
     * Panneau de configuration désactivé
     * Invite de commandes désactivée
     * Périphériques USB bloqués (lecture et écriture)
   - Lien : OU=Stagiaires,OU=Creative,OU=CreativeHub,DC=maxtec,DC=be

========================================
DÉCISIONS TECHNIQUES ET JUSTIFICATIONS
========================================

DÉCISION 1 : Créer une OU Stagiaires
  Justification :
  - Facilite l'application de GPO spécifiques
  - Meilleure visibilité organisationnelle
  - Scalable (futurs stagiaires)
  - Permet un filtrage facile dans les rapports

DÉCISION 2 : SAM Account "lea.fontaine" (pas "lfontaine")
  Justification :
  - Plus explicite et professionnel
  - Évite les ambiguïtés
  - Conforme à l'email demandé

DÉCISION 3 : Créer groupe GG-Projet-SecureBank-Lecture
  Justification :
  - Séparation claire entre accès complet et lecture seule
  - Facilite la gestion des permissions NTFS (AGDLP)
  - Réutilisable pour futurs besoins similaires
  - Principe du moindre privilège

DÉCISION 4 : GPO dédiée aux stagiaires (pas réutilisation de GPO existante)
  Justification :
  - Flexibilité future (ajuster restrictions selon le type de stagiaire)
  - Évite d'impacter les employés permanents
  - Meilleure traçabilité

========================================
INFORMATIONS DE CONNEXION
========================================

À communiquer à Léa le 07/10/2025 :
  Nom d'utilisateur : lea.fontaine
  Domaine : MAXTEC
  Mot de passe initial : StageCreative2025!
  Email : lea.fontaine@maxtec.be

IMPORTANT :
  - Changement de mot de passe obligatoire à la première connexion
  - Nouveau mot de passe doit respecter la politique de domaine
  - Compte expire automatiquement le 07/01/2026

========================================
PROCÉDURE D'OFFBOARDING (DANS 3 MOIS)
========================================

Date prévue : 07/01/2026

ÉTAPES :
1. JOUR J (dernier jour de stage)
   □ Récupérer tous les équipements (laptop, badge, etc.)
   □ Sauvegarder les fichiers de travail de Léa
   □ Transférer les fichiers importants au manager (Gabrielle)

2. JOUR J+1
   □ Le compte sera automatiquement désactivé (expiration)
   □ Vérifier que la désactivation a bien eu lieu
   □ Retirer Léa du groupe GG-Projet-SecureBank-Lecture
   □ (Garder dans Creative-Users pour historique temporaire)

3. JOUR J+7 (1 semaine après)
   □ Déplacer le compte vers OU=Comptes_Desactives (à créer si nécessaire)
   □ Ajouter note dans Description : "Compte expiré - Stage terminé"

4. JOUR J+180 (6 mois après - Avril 2026)
   □ Archiver les fichiers du profil utilisateur
   □ Supprimer définitivement le compte AD
   □ Documenter la suppression dans le registre IT

========================================
CHECKLIST DE VÉRIFICATION (AVANT 9H)
========================================

□ Le compte lea.fontaine existe et est activé
□ L'email lea.fontaine@maxtec.be est configuré
□ Le compte expire le 07/01/2026
□ Le changement de mot de passe à la première connexion est activé
□ Léa est membre de GG-CreativeHub-Creative-Users
□ Léa est membre de GG-Projet-SecureBank-Lecture
□ La GPO "Restrictions Stagiaires" est liée et activée
□ Test de connexion effectué (optionnel : créer un compte test)
□ Gabrielle Simon a été informée que tout est prêt
□ Le poste DESKTOP-CREATIVE-03 est prêt et joint au domaine

========================================
TESTS EFFECTUÉS
========================================

1. Vérification du compte :
   Get-ADUser -Identity lea.fontaine -Properties * | FL Name, AccountExpirationDate, Enabled

2. Vérification des groupes :
   Get-ADPrincipalGroupMembership -Identity lea.fontaine | Select Name

3. Vérification des GPO applicables :
   gpresult /r /scope:user /user:lea.fontaine

========================================
NOTES ET OBSERVATIONS
========================================

- Premier stagiaire dans l'environnement CreativeHub
- Structure créée est réutilisable pour futurs stagiaires
- Considérer la création d'un template de compte stagiaire
- Envisager l'automatisation avec un script PowerShell paramétrable

Rapport généré le : [DATE]
Administrateur : [VOTRE NOM]
```

## Points Clés à Retenir

### Workflow d'Onboarding Professionnel

1. **Analyse des besoins** avant de commencer
2. **Planification** de la structure (OUs, groupes)
3. **Implémentation** méthodique
4. **Documentation** exhaustive
5. **Vérification** et tests
6. **Communication** des informations au manager et à l'utilisateur

### Sécurité des Comptes Temporaires

- **Toujours configurer une date d'expiration** pour les stagiaires/consultants
- **Restrictions appropriées** selon le niveau de confiance
- **Accès minimal nécessaire** (principe du moindre privilège)
- **Traçabilité** (documentation de toutes les actions)

### Gestion des Projets Sensibles

- **Séparer les permissions** : Lecture seule vs Modification
- **Utiliser des groupes intermédiaires** pour la scalabilité
- **Stratégie AGDLP** : Groupes globaux → Groupes domain local → Permissions

### Documentation

- **Toujours documenter** les configurations complexes
- **Créer des procédures** réutilisables
- **Planifier l'offboarding** dès l'onboarding

## Dépannage (Erreurs Courantes)

| Problème | Cause Possible | Solution |
|----------|----------------|----------|
| La GPO ne s'applique pas à Léa | GPO liée à la mauvaise OU | Vérifier le lien avec Get-GPInheritance |
| Léa ne peut pas se connecter | Compte expiré ou désactivé | Vérifier Get-ADUser -Properties AccountExpirationDate, Enabled |
| Les restrictions USB ne fonctionnent pas | GPO HKLM nécessite redémarrage ordinateur | Redémarrer le poste client |
| Impossible de créer l'OU Stagiaires | Protection contre suppression accidentelle | Utiliser -ProtectedFromAccidentalDeletion $false |

## Pour Aller Plus Loin

### Automatisation avec Fonction PowerShell

```powershell
function New-StagiaireAccount {
    param(
        [Parameter(Mandatory=$true)]
        [string]$FirstName,
    
        [Parameter(Mandatory=$true)]
        [string]$LastName,
    
        [Parameter(Mandatory=$true)]
        [string]$Department,
    
        [Parameter(Mandatory=$true)]
        [datetime]$StageEndDate,
    
        [Parameter(Mandatory=$true)]
        [string]$Manager
    )
    
    # Logique de création automatique du compte stagiaire
    # avec toutes les configurations standards
}

# Utilisation :
# New-StagiaireAccount -FirstName "Léa" -LastName "Fontaine" -Department "Creative" -StageEndDate "2026-01-07" -Manager "Gabrielle Simon"
```

### Template de Compte Utilisateur

Envisager la création de comptes "template" pour chaque type d'utilisateur (stagiaire, employé permanent, consultant) avec des configurations pré-définies.

## Exercice Suivant Suggéré

**Exercice 8** : Troubleshooting - Une GPO ne s'applique pas (diagnostiquer et résoudre)
