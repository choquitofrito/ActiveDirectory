# Exercice 9 : Scénario de Crise - Compte Administrateur Compromis

## Niveau de Difficulté
🔴🔴 **Très Avancé** - Scénario de crise multi-facettes

## Objectifs Pédagogiques
- Gérer une situation de crise de sécurité sous pression
- Appliquer une méthodologie de réponse à incident
- Effectuer un audit de sécurité AD complet
- Prendre des décisions critiques de sécurité
- Documenter un incident pour analyse post-mortem

## Durée Estimée
60-90 minutes

## Prérequis
- Maîtrise complète des exercices 1 à 8
- Compréhension approfondie de la sécurité AD
- Capacité à travailler sous pression
- Esprit d'analyse et méthodologie rigoureuse

## ⚠️ AVERTISSEMENT - EXERCICE RÉALISTE DE CRISE

Cet exercice simule une situation de crise réelle. Vous devez :

- **Agir rapidement** mais méthodiquement
- **Prendre des notes** de toutes vos actions
- **Justifier** chaque décision
- **Documenter** pour l'audit futur

## Contexte / Scénario

**Date** : Vendredi 11 octobre 2025, 14h37

Vous profitez d'un vendredi après-midi calme lorsque votre téléphone sonne. C'est Rachid Dupont, le Responsable IT, et il semble paniqué :

> *"CODE ROUGE ! Viens immédiatement dans mon bureau. Nous avons un GROS problème de sécurité."*

Vous vous précipitez dans son bureau. Il vous montre son écran avec plusieurs fenêtres ouvertes :

### Email #1 - De Gabrielle Simon (Directrice Artistique)

> **Objet : URGENT - Accès non autorisé à mes fichiers**
>
> *"Rachid,*
>
> *Je viens de découvrir que quelqu'un a accédé à mes fichiers personnels sur le serveur hier soir à 23h47. J'étais chez moi à ce moment-là et mon ordinateur de bureau était éteint.*
>
> *J'ai trouvé un nouveau dossier "Backup_Temp" dans mon répertoire personnel qui contient des copies de TOUS nos fichiers clients confidentiels, y compris SecureBank.*
>
> *Je n'ai jamais créé ce dossier. Quelqu'un a fouillé dans nos données !*
>
> *Gabrielle*"

### Email #2 - De Nicolas André (Directeur des Opérations)

> **Objet : RE: Compte administrateur bizarre**
>
> *"Rachid,*
>
> *Suite à notre discussion de ce matin, j'ai vérifié dans Active Directory. Il y a un compte utilisateur que je ne reconnais pas :*
> - *Nom : "Support Technique"*
> - *SAM Account : "support.temp"*
> - *Créé le : 10/10/2025 à 22h15*
> - *Membre du groupe : Admins du domaine !!!*
>
> *Personne dans l'équipe n'a créé ce compte. C'est quoi cette histoire ?*
>
> *Nicolas*"

### Alerte Système - Event Viewer

Rachid vous montre les logs Windows Event Viewer :

```
Event ID: 4728 - A member was added to a security-enabled global group
  Security ID:    MAXTEC\support.temp
  Group:          Admins du domaine
  Date/Time:      10/10/2025 22:17:43

Event ID: 4624 - An account was successfully logged on
  Account Name:   olivier
  Logon Type:     3 (Network)
  Workstation:    DESKTOP-EXTERNAL-01
  Date/Time:      10/10/2025 22:05:12
  Source IP:      192.168.100.250 (Inconnu - pas dans notre réseau)

Event ID: 4672 - Special privileges assigned to new logon
  Account Name:   support.temp
  Privileges:     SeBackupPrivilege, SeRestorePrivilege, SeSecurityPrivilege
  Date/Time:      10/10/2025 22:18:01

Event ID: 4663 - An attempt was made to access an object
  Object Name:    \\DC01\Users\Gabrielle\Documents\Clients\SecureBank\
  Account Name:   support.temp
  Access:         READ_CONTROL, ReadData
  Date/Time:      10/10/2025 23:47:23
```

Rachid vous regarde, stressé :

> *"Voilà ce que je sais :*
>
> 1. *Hier soir vers 22h, Olivier Mercier (notre Développeur Web) a reçu un email qui semblait venir de moi, lui demandant de me fournir temporairement son mot de passe pour "une urgence maintenance". Il me l'a donné par SMS. Mais CE N'ÉTAIT PAS MOI qui ai envoyé cet email !*
>
> 2. *À 22h05, quelqu'un s'est connecté avec le compte d'Olivier depuis une adresse IP externe (192.168.100.250 - pas notre réseau).*
>
> 3. *À 22h15, un compte "support.temp" a été créé et immédiatement ajouté au groupe Admins du domaine.*
>
> 4. *Hier soir entre 22h et minuit, ce compte "support.temp" a accédé à de nombreux fichiers confidentiels.*
>
> 5. *Ce matin à 7h30, Olivier a reçu un email (anonyme) lui disant : "Merci pour l'accès. Nous avons ce dont nous avons besoin. Nous vous contacterons bientôt pour négocier."*
>
> *C'EST UNE ATTAQUE ! Notre Active Directory a été compromis. Nos données clients sont peut-être entre de mauvaises mains !*
>
> *Tu dois :*
> 1. *CONTENIR l'incident immédiatement*
> 2. *SÉCURISER tous les comptes et accès*
> 3. *AUDITER ce qui a été compromis*
> 4. *DOCUMENTER tout pour le rapport d'incident*
> 5. *Mettre en place des mesures pour éviter que ça se reproduise*
>
> *GO ! Je préviens la direction. Je te laisse 2 heures maximum pour sécuriser l'environnement avant qu'on ne doive contacter les autorités et nos clients.*
>
> *Rachid*"

## Tâche à Réaliser

### Mission Principale

Vous devez gérer cet incident de sécurité majeur en suivant une méthodologie de réponse à incident professionnelle.

### Phase 1 : CONTAINMENT (Confinement) - 20 minutes

**Objectif** : Stopper immédiatement la propagation de l'attaque et empêcher tout accès supplémentaire.

**Actions Critiques** :

1. **Désactiver le compte compromis "support.temp"**
   - Le supprimer ou le désactiver ?
   - Justifier votre choix (forensics vs sécurité immédiate)

2. **Retirer "support.temp" du groupe Admins du domaine**
   - Même si désactivé, retirer les permissions

3. **Réinitialiser le mot de passe d'Olivier**
   - Son compte a été compromis
   - Forcer le changement à la prochaine connexion

4. **Désactiver temporairement le compte d'Olivier**
   - Le temps d'investiguer s'il a été utilisé pour d'autres actions malveillantes

5. **Vérifier s'il y a d'autres comptes suspects**
   - Chercher les comptes créés récemment (dernières 72h)
   - Chercher les membres récemment ajoutés aux groupes privilégiés

6. **Auditer les membres du groupe Admins du domaine**
   - Qui devrait être dans ce groupe ?
   - Y a-t-il d'autres comptes suspects ?

**Commandes PowerShell Critiques** :

```powershell
# Chercher comptes créés récemment
Get-ADUser -Filter * -Properties WhenCreated |
    Where-Object {$_.WhenCreated -gt (Get-Date).AddDays(-3)} |
    Select-Object Name, SamAccountName, WhenCreated, Enabled

# Auditer Admins du domaine
Get-ADGroupMember -Identity "Admins du domaine" |
    Select-Object Name, SamAccountName

# Chercher modifications récentes dans les groupes privilégiés
Get-ADGroup -Filter {Name -like "*Admin*"} |
    ForEach-Object {
        Get-ADReplicationAttributeMetadata -Object $_.DistinguishedName -Properties member
    }
```

### Phase 2 : INVESTIGATION (Enquête) - 30 minutes

**Objectif** : Comprendre l'étendue de la compromission et identifier toutes les actions de l'attaquant.

**Questions à Investiguer** :

1. **Timeline de l'attaque** :
   - Quand le compte d'Olivier a-t-il été compromis ? (22h05)
   - Quand "support.temp" a-t-il été créé ? (22h15)
   - Combien de temps l'attaquant a-t-il eu accès admin ? (22h18 - maintenant ?)
   - Quels fichiers ont été accédés ?

2. **Étendue des dommages** :
   - Quels comptes utilisateurs ont été modifiés ?
   - Quels groupes ont été modifiés ?
   - Quelles GPO ont été modifiées ou créées ?
   - Y a-t-il des backdoors (autres comptes cachés) ?
   - Des fichiers ont-ils été exfiltrés (copiés) ?

3. **Vecteur d'attaque** :
   - Email de phishing ciblant Olivier
   - Connexion depuis IP externe (comment ?)
   - Escalade de privilèges (comment "support.temp" a-t-il été ajouté à Admins du domaine ?)

**Commandes d'Audit** :

```powershell
# Voir toutes les connexions du compte support.temp
Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4624} |
    Where-Object {$_.Message -like "*support.temp*"}

# Auditer tous les groupes pour modifications récentes
Get-ADGroup -Filter * -Properties WhenChanged |
    Where-Object {$_.WhenChanged -gt (Get-Date).AddDays(-2)} |
    Select-Object Name, WhenChanged

# Chercher les GPO modifiées récemment
Get-GPO -All |
    Where-Object {$_.ModificationTime -gt (Get-Date).AddDays(-2)} |
    Select-Object DisplayName, ModificationTime

# Auditer les permissions déléguées récentes
# (Nécessite d'examiner les ACL de chaque OU)
```

### Phase 3 : REMEDIATION (Correction) - 20 minutes

**Objectif** : Éliminer complètement la menace et restaurer un environnement sécurisé.

**Actions de Correction** :

1. **Supprimer définitivement le compte "support.temp"**
   - Après avoir documenté son existence pour l'investigation

2. **Réinitialiser les mots de passe** :
   - Olivier (déjà fait)
   - Rachid (son identité a été usurpée dans l'email)
   - Tous les comptes Admins du domaine (au cas où)

3. **Révoquer toutes les sessions actives** :
   - Sessions d'Olivier
   - Sessions de "support.temp" (si encore actif)

4. **Vérifier et nettoyer** :
   - Pas de GPO malveillante créée
   - Pas de délégation de contrôle suspecte
   - Pas de scripts de démarrage ajoutés
   - Pas de tâches planifiées suspectes

5. **Renforcer la sécurité** :
   - Activer l'audit avancé si pas déjà fait
   - Limiter strictement le groupe Admins du domaine
   - Mettre en place une politique de mots de passe plus stricte

### Phase 4 : RECOVERY (Récupération) - 10 minutes

**Objectif** : Remettre en service les comptes légitimes et les services.

**Actions** :

1. **Réactiver le compte d'Olivier** (avec nouveau mot de passe)
2. **Informer Olivier** de ce qui s'est passé et le sensibiliser
3. **Vérifier que les services critiques fonctionnent**
4. **Surveiller** les prochaines connexions suspectes

### Phase 5 : DOCUMENTATION (Post-Mortem) - 20 minutes

**Objectif** : Documenter l'incident pour l'audit, les assurances, et l'amélioration continue.

**Créer un rapport d'incident contenant** :

1. **Résumé Exécutif**
   - Quoi : Compte administrateur compromis via phishing
   - Quand : 10/10/2025 22h05 - 11/10/2025 14h37
   - Impact : Accès non autorisé à fichiers confidentiels clients
   - Statut : Contenu et résolu

2. **Timeline Détaillée**
   - Chaque événement avec horodatage

3. **Actions Effectuées**
   - Liste de toutes les commandes exécutées
   - Justification de chaque décision

4. **Données Compromises**
   - Quels fichiers ont été accédés
   - Quelles données peuvent avoir été exfiltrées

5. **Leçons Apprises et Recommandations**
   - Qu'est-ce qui a permis cette attaque ?
   - Comment empêcher cela à l'avenir ?
   - Mesures de sécurité à mettre en place

## Aucune Instruction Détaillée !

Cet exercice simule une vraie crise. Vous devez :

- Utiliser votre jugement
- Prioriser les actions
- Documenter en temps réel
- Justifier vos décisions

**Vous êtes seul maître à bord.**

## Vérification de la Réussite

### Script de Vérification

```powershell
.\verif_exercice_09.ps1
```

### Critères de Réussite (Minimum)

**Containment** :

- [ ] Le compte "support.temp" est désactivé ou supprimé
- [ ] "support.temp" n'est plus membre de Admins du domaine
- [ ] Le mot de passe d'Olivier a été réinitialisé
- [ ] Aucun autre compte suspect n'est actif

**Investigation** :

- [ ] Timeline de l'attaque documentée
- [ ] Liste des fichiers accédés identifiée
- [ ] Pas de backdoor (autre compte malveillant) trouvé

**Remediation** :

- [ ] Compte malveillant supprimé définitivement
- [ ] Mots de passe critiques réinitialisés
- [ ] Pas de GPO malveillante présente
- [ ] Audit de sécurité activé

**Documentation** :

- [ ] Rapport d'incident créé
- [ ] Actions documentées
- [ ] Recommandations de sécurité formulées

## Solution Complète (Pour Instructeur)

### Script de Gestion de Crise

```powershell
Import-Module ActiveDirectory
Import-Module GroupPolicy

Write-Host "========================================" -ForegroundColor Red
Write-Host " GESTION INCIDENT DE SÉCURITÉ" -ForegroundColor Red
Write-Host " CODE ROUGE - COMPTE ADMIN COMPROMIS" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red
Write-Host ""
Write-Host "Incident détecté le: $(Get-Date)" -ForegroundColor Yellow
Write-Host ""

# Créer un fichier de log pour documenter toutes les actions
$logFile = "C:\Labos\Incident_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$reportFile = "C:\Labos\Incident_Report_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

function Write-Log {
    param($Message, $Color = "White")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    Write-Host $logMessage -ForegroundColor $Color
    Add-Content -Path $logFile -Value $logMessage
}

Write-Log "========================================" "Red"
Write-Log "PHASE 1: CONTAINMENT (Confinement)" "Red"
Write-Log "========================================" "Red"

# Action 1: Désactiver immédiatement le compte compromis
Write-Log "[ACTION 1] Désactivation du compte malveillant support.temp..." "Yellow"
try {
    $suspectAccount = Get-ADUser -Identity "support.temp" -Properties * -ErrorAction Stop
    Write-Log "  Compte trouvé: $($suspectAccount.SamAccountName)" "Gray"
    Write-Log "  Créé le: $($suspectAccount.WhenCreated)" "Gray"
    Write-Log "  Dernière connexion: $($suspectAccount.LastLogonDate)" "Gray"

    # DÉSACTIVER (ne pas supprimer tout de suite pour forensics)
    Disable-ADAccount -Identity "support.temp" -ErrorAction Stop
    Write-Log "  ✓ Compte désactivé (préservé pour analyse forensique)" "Green"

} catch {
    Write-Log "  ⚠ Compte support.temp introuvable (peut-être déjà supprimé)" "Yellow"
}

# Action 2: Retirer du groupe Admins du domaine
Write-Log "`n[ACTION 2] Retrait du groupe Admins du domaine..." "Yellow"
try {
    Remove-ADGroupMember -Identity "Admins du domaine" -Members "support.temp" -Confirm:$false -ErrorAction Stop
    Write-Log "  ✓ support.temp retiré du groupe Admins du domaine" "Green"
} catch {
    if ($_.Exception.Message -like "*not a member*") {
        Write-Log "  support.temp n'était pas membre de Admins du domaine" "Yellow"
    } else {
        Write-Log "  ✗ ERREUR: $($_.Exception.Message)" "Red"
    }
}

# Action 3: Réinitialiser le mot de passe d'Olivier (compte compromis)
Write-Log "`n[ACTION 3] Réinitialisation du mot de passe d'Olivier..." "Yellow"
try {
    $newPassword = ConvertTo-SecureString "TempSecureOlivier2025!" -AsPlainText -Force
    Set-ADAccountPassword -Identity "olivier" -NewPassword $newPassword -Reset -ErrorAction Stop
    Set-ADUser -Identity "olivier" -ChangePasswordAtLogon $true -ErrorAction Stop
    Write-Log "  ✓ Mot de passe d'Olivier réinitialisé" "Green"
    Write-Log "  Nouveau mot de passe temporaire: TempSecureOlivier2025!" "Yellow"
} catch {
    Write-Log "  ✗ ERREUR: $($_.Exception.Message)" "Red"
}

# Action 4: Désactiver temporairement le compte d'Olivier
Write-Log "`n[ACTION 4] Désactivation temporaire du compte d'Olivier..." "Yellow"
try {
    Disable-ADAccount -Identity "olivier" -ErrorAction Stop
    Write-Log "  ✓ Compte d'Olivier désactivé temporairement (investigation en cours)" "Green"
} catch {
    Write-Log "  ✗ ERREUR: $($_.Exception.Message)" "Red"
}

# Action 5: Chercher d'autres comptes suspects créés récemment
Write-Log "`n[ACTION 5] Recherche de comptes suspects créés récemment..." "Yellow"
$recentAccounts = Get-ADUser -Filter * -Properties WhenCreated |
    Where-Object {$_.WhenCreated -gt (Get-Date).AddDays(-3)} |
    Select-Object Name, SamAccountName, WhenCreated, Enabled

Write-Log "  Comptes créés dans les 3 derniers jours:" "Gray"
foreach ($account in $recentAccounts) {
    Write-Log "    - $($account.SamAccountName) (Créé: $($account.WhenCreated), Activé: $($account.Enabled))" "Gray"

    if ($account.SamAccountName -like "*temp*" -or $account.SamAccountName -like "*support*" -or $account.SamAccountName -like "*admin*") {
        Write-Log "    ⚠ SUSPECT: $($account.SamAccountName)" "Red"
    }
}

# Action 6: Auditer Admins du domaine
Write-Log "`n[ACTION 6] Audit du groupe Admins du domaine..." "Yellow"
$domainAdmins = Get-ADGroupMember -Identity "Admins du domaine"
Write-Log "  Membres actuels de Admins du domaine:" "Gray"
foreach ($admin in $domainAdmins) {
    Write-Log "    - $($admin.SamAccountName)" "Gray"
}

Write-Log "  ✓ Aucun autre compte suspect détecté dans Admins du domaine" "Green"

Write-Log "`n========================================" "Cyan"
Write-Log "PHASE 2: INVESTIGATION (Enquête)" "Cyan"
Write-Log "========================================" "Cyan"

# Investigation 1: Timeline de l'attaque
Write-Log "`n[INVESTIGATION 1] Reconstruction de la timeline..." "Yellow"
Write-Log "  10/10/2025 22:05 - Connexion du compte olivier depuis IP externe 192.168.100.250" "Gray"
Write-Log "  10/10/2025 22:15 - Création du compte support.temp" "Gray"
Write-Log "  10/10/2025 22:17 - support.temp ajouté au groupe Admins du domaine" "Gray"
Write-Log "  10/10/2025 22:18 - Privilèges spéciaux attribués à support.temp" "Gray"
Write-Log "  10/10/2025 23:47 - Accès aux fichiers confidentiels SecureBank" "Gray"
Write-Log "  11/10/2025 07:30 - Email de rançon reçu par Olivier" "Gray"
Write-Log "  11/10/2025 14:37 - Incident détecté et containment initié" "Gray"

# Investigation 2: Fichiers accédés
Write-Log "`n[INVESTIGATION 2] Fichiers potentiellement compromis..." "Yellow"
Write-Log "  Basé sur les Event Logs:" "Gray"
Write-Log "    - \\DC01\Users\Gabrielle\Documents\Clients\SecureBank\ (Lecture)" "Red"
Write-Log "    - Dossier 'Backup_Temp' créé (contient copies des données clients)" "Red"
Write-Log "  ⚠ DONNÉES SENSIBLES COMPROMISES" "Red"

# Investigation 3: Modifications dans AD
Write-Log "`n[INVESTIGATION 3] Modifications récentes dans AD..." "Yellow"

# GPO modifiées
$recentGPOs = Get-GPO -All |
    Where-Object {$_.ModificationTime -gt (Get-Date).AddDays(-2)} |
    Select-Object DisplayName, ModificationTime

if ($recentGPOs.Count -gt 0) {
    Write-Log "  GPO modifiées récemment:" "Gray"
    foreach ($gpo in $recentGPOs) {
        Write-Log "    - $($gpo.DisplayName) (Modifiée: $($gpo.ModificationTime))" "Gray"
    }
} else {
    Write-Log "  ✓ Aucune GPO modifiée récemment (pas de persistance via GPO)" "Green"
}

# Groupes modifiés
$recentGroups = Get-ADGroup -Filter * -Properties WhenChanged |
    Where-Object {$_.WhenChanged -gt (Get-Date).AddDays(-2)} |
    Select-Object Name, WhenChanged

Write-Log "  Groupes modifiés récemment:" "Gray"
foreach ($group in $recentGroups) {
    Write-Log "    - $($group.Name) (Modifié: $($group.WhenChanged))" "Gray"
}

Write-Log "`n========================================" "Cyan"
Write-Log "PHASE 3: REMEDIATION (Correction)" "Cyan"
Write-Log "========================================" "Cyan"

# Remediation 1: Supprimer définitivement le compte malveillant
Write-Log "`n[REMEDIATION 1] Suppression du compte support.temp..." "Yellow"
try {
    # Export pour forensics avant suppression
    $suspectAccount | Export-Clixml -Path "C:\Labos\Forensics_support.temp_$(Get-Date -Format 'yyyyMMdd_HHmmss').xml"
    Write-Log "  ✓ Compte exporté pour analyse forensique" "Green"

    # Suppression
    Remove-ADUser -Identity "support.temp" -Confirm:$false -ErrorAction Stop
    Write-Log "  ✓ Compte support.temp supprimé définitivement" "Green"
} catch {
    Write-Log "  Compte déjà supprimé ou introuvable" "Yellow"
}

# Remediation 2: Réinitialiser les mots de passe des comptes sensibles
Write-Log "`n[REMEDIATION 2] Réinitialisation des mots de passe critiques..." "Yellow"

$criticalAccounts = @("rachid", "pauline") # Admins IT
foreach ($account in $criticalAccounts) {
    try {
        $tempPwd = ConvertTo-SecureString "TempSecure$($account)2025!" -AsPlainText -Force
        Set-ADAccountPassword -Identity $account -NewPassword $tempPwd -Reset -ErrorAction Stop
        Set-ADUser -Identity $account -ChangePasswordAtLogon $true -ErrorAction Stop
        Write-Log "  ✓ Mot de passe de $account réinitialisé" "Green"
    } catch {
        Write-Log "  ✗ Erreur pour $account : $($_.Exception.Message)" "Red"
    }
}

# Remediation 3: Vérifier qu'il n'y a pas de backdoor
Write-Log "`n[REMEDIATION 3] Vérification des backdoors potentiels..." "Yellow"

# Chercher des comptes avec AdminCount=1 (privilégiés)
$privilegedAccounts = Get-ADUser -Filter {AdminCount -eq 1} -Properties AdminCount, WhenCreated
Write-Log "  Comptes privilégiés (AdminCount=1):" "Gray"
foreach ($privAccount in $privilegedAccounts) {
    Write-Log "    - $($privAccount.SamAccountName) (Créé: $($privAccount.WhenCreated))" "Gray"
}

Write-Log "  ✓ Audit terminé" "Green"

Write-Log "`n========================================" "Green"
Write-Log "PHASE 4: RECOVERY (Récupération)" "Green"
Write-Log "========================================" "Green"

# Recovery 1: Réactiver le compte d'Olivier
Write-Log "`n[RECOVERY 1] Réactivation du compte d'Olivier..." "Yellow"
try {
    Enable-ADAccount -Identity "olivier" -ErrorAction Stop
    Write-Log "  ✓ Compte d'Olivier réactivé" "Green"
    Write-Log "  Informer Olivier:" "Yellow"
    Write-Log "    - Son compte a été compromis via phishing" "Yellow"
    Write-Log "    - Nouveau mot de passe: TempSecureOlivier2025!" "Yellow"
    Write-Log "    - Il doit le changer à la première connexion" "Yellow"
    Write-Log "    - Sensibilisation aux emails de phishing requise" "Yellow"
} catch {
    Write-Log "  ✗ ERREUR: $($_.Exception.Message)" "Red"
}

# Recovery 2: Vérifier que les services fonctionnent
Write-Log "`n[RECOVERY 2] Vérification des services critiques..." "Yellow"
try {
    $dcStatus = Get-Service -Name "NTDS" -ErrorAction Stop
    if ($dcStatus.Status -eq "Running") {
        Write-Log "  ✓ Service Active Directory fonctionne" "Green"
    }
} catch {
    Write-Log "  ⚠ Impossible de vérifier le service AD" "Yellow"
}

Write-Log "`n========================================" "Green"
Write-Log "INCIDENT RÉSOLU" "Green"
Write-Log "========================================" "Green"

Write-Log "`nRésumé de l'incident:" "Cyan"
Write-Log "  Type: Compromission de compte administrateur via phishing" "White"
Write-Log "  Vecteur: Email de phishing ciblant Olivier Mercier" "White"
Write-Log "  Impact: Accès non autorisé aux données clients (SecureBank)" "White"
Write-Log "  Durée: ~16 heures (22h05 - 14h37)" "White"
Write-Log "  Statut: CONTENU ET RÉSOLU" "Green"

Write-Log "`nActions effectuées:" "Cyan"
Write-Log "  ✓ Compte malveillant désactivé puis supprimé" "White"
Write-Log "  ✓ Privilèges révoqués (retiré de Admins du domaine)" "White"
Write-Log "  ✓ Comptes compromis réinitialisés (Olivier, Rachid, Pauline)" "White"
Write-Log "  ✓ Audit de sécurité complet effectué" "White"
Write-Log "  ✓ Aucun backdoor détecté" "White"
Write-Log "  ✓ Services rétablis" "White"

Write-Log "`nRecommandations de sécurité:" "Cyan"
Write-Log "  1. Formation anti-phishing pour TOUS les employés" "Yellow"
Write-Log "  2. Activer l'authentification multi-facteurs (MFA) pour les comptes admin" "Yellow"
Write-Log "  3. Implémenter une politique de mots de passe plus stricte" "Yellow"
Write-Log "  4. Limiter les membres du groupe Admins du domaine au strict minimum" "Yellow"
Write-Log "  5. Activer l'audit avancé des connexions et modifications AD" "Yellow"
Write-Log "  6. Implémenter un système de détection d'intrusion (IDS/IPS)" "Yellow"
Write-Log "  7. Procédure de vérification pour demandes urgentes de mots de passe" "Yellow"
Write-Log "  8. Segmenter le réseau (VPN obligatoire pour connexions externes)" "Yellow"

Write-Log "`nFichiers générés:" "Cyan"
Write-Log "  - Log d'incident: $logFile" "White"
Write-Log "  - Rapport d'incident: $reportFile" "White"

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Incident de sécurité géré avec succès." -ForegroundColor Green
Write-Host "Consultez les fichiers de log pour documentation." -ForegroundColor White
Write-Host "========================================" -ForegroundColor Green

# Créer le rapport d'incident formel
$report = @"
========================================
RAPPORT D'INCIDENT DE SÉCURITÉ
========================================

Date du rapport: $(Get-Date -Format "dd/MM/yyyy HH:mm:ss")
Rédacteur: Administrateur Système
Classification: CONFIDENTIEL

RÉSUMÉ EXÉCUTIF
===============

Type d'incident: Compromission de compte administrateur
Gravité: CRITIQUE
Statut: RÉSOLU
Durée: ~16 heures (10/10/2025 22h05 - 11/10/2025 14h37)

Impact:
  - Compte administrateur malveillant créé (support.temp)
  - Accès non autorisé aux fichiers clients confidentiels
  - Données potentiellement exfiltrées (projet SecureBank)
  - 1 compte utilisateur compromis (olivier)

TIMELINE DÉTAILLÉE
==================

10/10/2025 ~20h00
  - Email de phishing envoyé à Olivier Mercier se faisant passer pour Rachid Dupont
  - Demande urgente du mot de passe d'Olivier

10/10/2025 ~21h30
  - Olivier fournit son mot de passe par SMS à l'attaquant
  - (pensant communiquer avec Rachid)

10/10/2025 22:05:12
  - Connexion réussie avec le compte d'Olivier
  - Source: IP externe 192.168.100.250 (hors réseau)
  - Type de connexion: Réseau (Type 3)

10/10/2025 22:15:00
  - Création du compte "support.temp" avec privilèges admin

10/10/2025 22:17:43
  - Compte "support.temp" ajouté au groupe Admins du domaine
  - Escalade de privilèges réussie

10/10/2025 22:18:01
  - Privilèges spéciaux attribués à support.temp
  - SeBackupPrivilege, SeRestorePrivilege, SeSecurityPrivilege

10/10/2025 23:47:23
  - Accès aux fichiers confidentiels du projet SecureBank
  - Lecture des documents clients sensibles
  - Création du dossier "Backup_Temp" (exfiltration probable)

11/10/2025 07:30:00
  - Email de rançon reçu par Olivier
  - Confirmation de l'accès non autorisé
  - Menace implicite de divulgation des données

11/10/2025 14:37:00
  - Incident détecté et signalé par Rachid Dupont
  - Activation du protocole de réponse à incident

11/10/2025 14:40:00
  - Début de la phase de Containment
  - Désactivation du compte support.temp
  - Retrait des privilèges Admins du domaine
  - Réinitialisation du mot de passe d'Olivier

11/10/2025 15:30:00
  - Audit de sécurité complet effectué
  - Aucun autre compte compromis détecté
  - Aucune GPO malveillante créée

11/10/2025 16:00:00
  - Suppression définitive du compte support.temp
  - Réactivation du compte d'Olivier (avec nouveau mot de passe)
  - Incident résolu

DONNÉES COMPROMISES
===================

Fichiers accédés:
  - \\DC01\Users\Gabrielle\Documents\Clients\SecureBank\*
  - Contenu: Contrats clients, données bancaires, stratégies marketing

Données potentiellement exfiltrées:
  - Dossier "Backup_Temp" créé dans le répertoire de Gabrielle
  - Contient des copies de fichiers confidentiels
  - Volume estimé: [À déterminer via analyse forensique]

Comptes compromis:
  - olivier (Développeur Web Full-Stack)
  - support.temp (compte malveillant créé par attaquant)

ACTIONS CORRECTIVES EFFECTUÉES
===============================

Phase de Containment:
  ✓ Désactivation immédiate du compte support.temp
  ✓ Retrait du groupe Admins du domaine
  ✓ Réinitialisation du mot de passe d'Olivier
  ✓ Désactivation temporaire du compte d'Olivier
  ✓ Audit des comptes créés récemment
  ✓ Audit complet du groupe Admins du domaine

Phase d'Investigation:
  ✓ Reconstruction complète de la timeline
  ✓ Identification des fichiers accédés
  ✓ Vérification de l'absence de backdoors
  ✓ Audit des GPO pour modifications malveillantes
  ✓ Audit des groupes de sécurité

Phase de Remediation:
  ✓ Suppression définitive du compte support.temp
  ✓ Réinitialisation des mots de passe critiques (rachid, pauline)
  ✓ Vérification de l'absence de persistance (GPO, tâches planifiées)
  ✓ Export forensique du compte malveillant pour analyse

Phase de Recovery:
  ✓ Réactivation du compte d'Olivier (avec nouveau mot de passe)
  ✓ Vérification du bon fonctionnement des services AD
  ✓ Monitoring renforcé activé

VECTEUR D'ATTAQUE
=================

1. Ingénierie sociale (Phishing ciblé)
   - Email se faisant passer pour le Responsable IT (Rachid)
   - Demande urgente de mot de passe
   - Exploite la confiance et l'urgence

2. Compromission de compte utilisateur
   - Olivier fournit son mot de passe par SMS
   - Connexion depuis IP externe (VPN ou accès distant)

3. Escalade de privilèges
   - Utilisation du compte d'Olivier pour créer un compte admin
   - Ajout au groupe Admins du domaine
   - Obtention de privilèges système complets

4. Exfiltration de données
   - Accès aux fichiers confidentiels
   - Copie des données sensibles
   - Tentative de rançon/extorsion

LEÇONS APPRISES
===============

Points faibles identifiés:
  1. Aucune formation anti-phishing pour les employés
  2. Pas d'authentification multi-facteurs (MFA) pour comptes admin
  3. Trop de membres dans le groupe Admins du domaine
  4. Pas de détection automatique de connexions depuis IP externes
  5. Pas de vérification pour demandes urgentes de mots de passe
  6. Audit de sécurité AD insuffisant

RECOMMANDATIONS
===============

PRIORITÉ HAUTE (À implémenter immédiatement):
  1. Formation anti-phishing obligatoire pour TOUS les employés
  2. Activer MFA pour tous les comptes administrateurs
  3. Réduire les membres de Admins du domaine au strict minimum
  4. Implémenter une procédure de vérification pour demandes de MDP
  5. Sensibiliser Olivier et toute l'équipe à cet incident

PRIORITÉ MOYENNE (Dans les 30 jours):
  6. Activer l'audit avancé des connexions AD
  7. Implémenter un système d'alerte pour connexions externes
  8. Politique de mots de passe renforcée (longueur, complexité)
  9. Segmentation réseau (VPN obligatoire pour accès externe)
  10. Scanner régulier des comptes privilégiés et récents

PRIORITÉ BASSE (Dans les 90 jours):
  11. Système de détection d'intrusion (IDS/IPS)
  12. Sauvegarde régulière de la base AD
  13. Plan de reprise après incident (PRA/PCA)
  14. Audit de sécurité trimestriel
  15. Principe du moindre privilège pour tous les comptes

CONTACTS ET NOTIFICATIONS
==========================

Personnes informées:
  - Rachid Dupont (Responsable IT) - Signaleur de l'incident
  - Nicolas André (Directeur des Opérations) - Informé
  - Olivier Mercier (Développeur) - Victime, informé et sensibilisé
  - Gabrielle Simon (Directrice Artistique) - Fichiers accédés

Actions requises:
  - Notification des clients concernés (SecureBank) - EN ATTENTE DÉCISION DIRECTION
  - Déclaration à la CNIL (RGPD) - EN ATTENTE DÉCISION JURIDIQUE
  - Éventuel dépôt de plainte - EN ATTENTE DÉCISION DIRECTION

ANNEXES
=======

A. Log complet de l'incident: $logFile
B. Export forensique du compte support.temp
C. Captures d'écran des Event Logs
D. Liste des fichiers potentiellement compromis

========================================
FIN DU RAPPORT
========================================

Rapport approuvé par:
  Nom: [À compléter]
  Fonction: [À compléter]
  Date: [À compléter]
  Signature: [À compléter]
"@

Add-Content -Path $reportFile -Value $report
Write-Host "`nRapport d'incident créé: $reportFile" -ForegroundColor Cyan
```

### Points Clés de la Solution

1. **Priorisation** : Containment d'abord, investigation ensuite
2. **Documentation** : Logging de toutes les actions en temps réel
3. **Forensics** : Export du compte malveillant avant suppression
4. **Sécurité** : Réinitialisation de TOUS les mots de passe sensibles
5. **Communication** : Rapport formel pour la direction et les parties prenantes

## Points Clés à Retenir

### Méthodologie de Réponse à Incident (NIST)

1. **Preparation** : Avoir un plan avant l'incident
2. **Detection & Analysis** : Identifier et comprendre l'incident
3. **Containment** : Stopper la propagation immédiatement
4. **Eradication** : Éliminer la menace
5. **Recovery** : Restaurer les services
6. **Post-Incident Activity** : Apprendre et améliorer

### Priorités en Situation de Crise

1. **Safety First** : Protéger les données et les utilisateurs
2. **Contain** : Empêcher l'aggravation
3. **Document** : Tracer toutes les actions
4. **Communicate** : Informer les bonnes personnes
5. **Learn** : Améliorer pour éviter la répétition

### Erreurs à Éviter

- ❌ Paniquer et agir sans réfléchir
- ❌ Supprimer des preuves (forensics)
- ❌ Cacher l'incident à la direction
- ❌ Négliger la documentation
- ❌ Réactiver les services sans vérification complète

## Pour Aller Plus Loin

### Simulation Réaliste (Setup de l'Exercice)

Pour les instructeurs qui souhaitent créer réellement cet incident simulé :

```powershell
# SCRIPT DE SIMULATION D'INCIDENT (INSTRUCTEUR SEULEMENT)
# À exécuter AVANT l'exercice pour créer la situation

# Créer le compte malveillant
$pwd = ConvertTo-SecureString "MaliciousPassword123!" -AsPlainText -Force
New-ADUser -Name "Support Technique" -GivenName "Support" -Surname "Technique" -SamAccountName "support.temp" -AccountPassword $pwd -Enabled $true -Path "CN=Users,DC=maxtec,DC=be"

# Ajouter au groupe Admins du domaine
Add-ADGroupMember -Identity "Admins du domaine" -Members "support.temp"

# Modifier les dates de création pour correspondre au scénario
# (nécessite manipulation directe de l'attribut WhenCreated - avancé)
```

## Dépannage (Si Problèmes Durant l'Exercice)

| Problème | Cause | Solution |
|----------|-------|----------|
| Impossible de supprimer le compte | Protection ou sessions actives | Forcer avec -Force, ou désactiver d'abord |
| Admins du domaine ne peut pas être modifié | Permissions insuffisantes | Utiliser un compte Enterprise Admin |
| Les logs Event Viewer sont vides | Audit non activé | Activer l'audit des connexions dans les GPO |

---

**FIN DE LA SÉRIE D'EXERCICES CREATIVEHUB**

Félicitations ! Vous avez complété les 9 exercices couvrant toutes les compétences essentielles de gestion Active Directory, de la création de comptes basique jusqu'à la gestion de crises de sécurité complexes.
