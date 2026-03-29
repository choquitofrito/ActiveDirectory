# Exercice 5 : Incident de Sécurité - Réinitialisation de Mot de Passe

## Niveau de Difficulté
🟡 **Intermédiaire** - Tâche orientée objectif

## Objectifs Pédagogiques
- Réinitialiser le mot de passe d'un utilisateur de manière sécurisée
- Forcer le changement de mot de passe à la prochaine connexion
- Comprendre les implications de sécurité d'un compte compromis
- Déverrouiller un compte utilisateur bloqué

## Durée Estimée
15 minutes

## Prérequis
- Lab CreativeHub déployé avec succès
- Compréhension des politiques de sécurité de base
- Accès administrateur au domaine

## Contexte / Scénario
**Date**: Jeudi après-midi, 15h30

Vous recevez un appel urgent de Bastien Martin, Spécialiste SEO au département Marketing :

> *"Allô, l'IT ? C'est Bastien. J'ai un gros problème. Je pense que mon mot de passe a été compromis. Ce matin, j'ai reçu un email qui semblait venir de notre directeur, me demandant de cliquer sur un lien pour 'vérifier mon compte'. Comme un idiot, j'ai cliqué et entré mon mot de passe...*
>
> *Maintenant, je n'arrive plus à me connecter ! Le système me dit que mon compte est bloqué après plusieurs tentatives de connexion échouées. Je n'ai pas essayé autant de fois... quelqu'un d'autre doit utiliser mon compte !*
>
> *Pouvez-vous m'aider MAINTENANT ? J'ai une présentation client dans 30 minutes !"*

Amélie Dubois, Community Manager (sa collègue), vous envoie aussi un message :

> *"L'IT, j'ai reçu des messages bizarres de la part de Bastien sur notre messagerie interne. Il me demande des informations confidentielles sur nos clients. Ce n'est PAS son genre. Je pense que son compte a été piraté."*

**INCIDENT DE SÉCURITÉ CONFIRMÉ !**

## Tâche à Réaliser

Votre mission est de sécuriser immédiatement le compte de Bastien et lui permettre de reprendre son travail en toute sécurité.

### Objectifs

1. **Déverrouiller** le compte utilisateur de Bastien (si nécessaire)
2. **Réinitialiser** le mot de passe avec un mot de passe temporaire sécurisé
3. **Forcer** Bastien à changer son mot de passe à la prochaine connexion
4. **Vérifier** que le compte est bien actif et fonctionnel
5. **Documenter** l'incident dans les propriétés du compte (Description ou Notes)

### Contraintes

- Le nouveau mot de passe temporaire doit être : `TempSecure2025!`
- L'utilisateur DOIT changer ce mot de passe à la prochaine connexion (sécurité)
- Ne PAS désactiver le compte (Bastien doit pouvoir travailler)
- Le compte doit être déverrouillé s'il est bloqué

### Informations Utilisateur

- **Nom** : Bastien Martin
- **SAM Account** : `bastien`
- **Département** : Marketing
- **Fonction** : Spécialiste SEO

### Questions de Sécurité à Considérer

1. **Pourquoi forcer le changement de mot de passe** ?
   - Le mot de passe temporaire que vous définissez est connu de l'administrateur
   - L'utilisateur doit choisir SON propre mot de passe que lui seul connaît

2. **Que faire si le compte est verrouillé** ?
   - Active Directory verrouille automatiquement les comptes après X tentatives échouées
   - Vous devez déverrouiller le compte pour permettre la connexion

3. **Doit-on déconnecter les sessions actives** ?
   - Oui ! Si un attaquant est connecté avec ce compte, il faut le déconnecter
   - (Dans cet exercice, concentrez-vous sur la réinitialisation du mot de passe)

### Indices

??? info "💡 Indice 1 : Méthode GUI"
    1. Ouvrir `dsa.msc`
    2. Localiser l'utilisateur Bastien dans `OU=Users,OU=Marketing,OU=CreativeHub`
    3. Clic droit sur l'utilisateur → "Réinitialiser le mot de passe..."
    4. Dans la fenêtre :
       - Cocher "Déverrouiller le compte" (si l'option est disponible)
       - Entrer le nouveau mot de passe
       - Cocher "L'utilisateur doit changer le mot de passe à la prochaine ouverture de session"
    5. Ajouter une note documentant l'incident dans l'onglet Général (Description)
    

??? info "💡 Indice 2 : Méthode PowerShell"
    ```powershell
    Import-Module ActiveDirectory
    
    # Réinitialiser le mot de passe
    $newPassword = ConvertTo-SecureString "TempSecure2025!" -AsPlainText -Force
    Set-ADAccountPassword -Identity bastien -NewPassword $newPassword -Reset
    
    # Forcer le changement à la prochaine connexion
    Set-ADUser -Identity bastien -ChangePasswordAtLogon $true
    
    # Déverrouiller le compte si nécessaire
    Unlock-ADAccount -Identity bastien
    
    # Vérifier l'état
    Get-ADUser -Identity bastien -Properties LockedOut, PasswordExpired | Select-Object Name, Enabled, LockedOut, PasswordExpired
    ```
    

??? info "💡 Indice 3 : Vérifier si le compte est verrouillé"
    ```powershell
    Get-ADUser -Identity bastien -Properties LockedOut, AccountLockoutTime |
        Select-Object Name, LockedOut, AccountLockoutTime
    ```
    
    Si `LockedOut = True`, vous devez déverrouiller le compte.
    

## Vérification de la Réussite

### Commandes PowerShell de Vérification

```powershell
Import-Module ActiveDirectory

# Vérifier l'état du compte
Get-ADUser -Identity bastien -Properties LockedOut, PasswordExpired, PasswordNeverExpires, PasswordLastSet, Description |
    Select-Object Name, Enabled, LockedOut, PasswordExpired, PasswordNeverExpires, PasswordLastSet, Description

# Vérifier la politique de changement de mot de passe
Get-ADUser -Identity bastien -Properties pwdLastSet |
    Select-Object Name, @{Name="MustChangePassword";Expression={$_.pwdLastSet -eq 0}}
```

**OU** exécutez le script de vérification automatique :

```powershell
.\verif_exercice_05.ps1
```

### Critères de Réussite

- [ ] Le compte "bastien" n'est PAS verrouillé (LockedOut = False)
- [ ] Le compte est activé (Enabled = True)
- [ ] Le mot de passe a été réinitialisé (PasswordLastSet est récent)
- [ ] L'utilisateur doit changer le mot de passe à la prochaine connexion (pwdLastSet = 0 OU PasswordExpired = True)
- [ ] *Bonus* : Une description documentant l'incident a été ajoutée

## Solution Complète (Pour Instructeur)

### Méthode GUI

#### Étape 1 : Localiser l'utilisateur

1. Ouvrir **Utilisateurs et ordinateurs Active Directory** (dsa.msc)
2. Naviguer vers : **maxtec.be** → **CreativeHub** → **Marketing** → **Users**
3. Localiser **Bastien Martin**

#### Étape 2 : Vérifier si le compte est verrouillé

1. **Double-clic** sur Bastien Martin
2. Aller dans l'onglet **Compte**
3. Chercher la case "Déverrouiller le compte" (elle n'apparaît que si le compte est verrouillé)

#### Étape 3 : Réinitialiser le mot de passe

1. **Clic droit** sur **Bastien Martin**
2. Sélectionner **Réinitialiser le mot de passe...**
3. Dans la fenêtre qui s'ouvre :
   - **Nouveau mot de passe** : `TempSecure2025!`
   - **Confirmer le mot de passe** : `TempSecure2025!`
   - **Cocher** "Déverrouiller le compte de l'utilisateur" (si disponible)
   - **Cocher** "L'utilisateur doit changer le mot de passe à la prochaine ouverture de session"
4. Cliquer sur **OK**

#### Étape 4 : Documenter l'incident

1. **Double-clic** sur **Bastien Martin**
2. Onglet **Général**
3. Dans le champ **Description**, ajouter :
   ```
   INCIDENT SÉCURITÉ 04/10/2025 - Compte compromis (phishing) - Mot de passe réinitialisé
   ```
4. Cliquer sur **Appliquer** puis **OK**

#### Étape 5 : Informer l'utilisateur

Dans un contexte réel, appelez immédiatement Bastien pour :
- Lui communiquer le mot de passe temporaire de manière sécurisée
- Lui expliquer comment choisir un nouveau mot de passe fort
- Le sensibiliser aux emails de phishing

### Méthode PowerShell

```powershell
Import-Module ActiveDirectory

# Variables
$userSAM = "bastien"
$tempPassword = "TempSecure2025!"
$incidentNote = "INCIDENT SÉCURITÉ 04/10/2025 - Compte compromis (phishing) - Mot de passe réinitialisé"

Write-Host "========================================" -ForegroundColor Red
Write-Host " GESTION INCIDENT DE SÉCURITÉ" -ForegroundColor Red
Write-Host " Utilisateur: $userSAM" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red

# 1. Vérifier l'état actuel du compte
Write-Host "`n[1/5] Vérification de l'état du compte..." -ForegroundColor Yellow
$user = Get-ADUser -Identity $userSAM -Properties LockedOut, AccountLockoutTime, PasswordLastSet

if ($user.LockedOut) {
    Write-Host "  ⚠ Le compte est VERROUILLÉ depuis $($user.AccountLockoutTime)" -ForegroundColor Red
} else {
    Write-Host "  Le compte n'est pas verrouillé." -ForegroundColor Green
}

# 2. Réinitialiser le mot de passe
Write-Host "`n[2/5] Réinitialisation du mot de passe..." -ForegroundColor Yellow
$securePassword = ConvertTo-SecureString $tempPassword -AsPlainText -Force
Set-ADAccountPassword -Identity $userSAM -NewPassword $securePassword -Reset
Write-Host "  ✓ Mot de passe réinitialisé avec succès" -ForegroundColor Green

# 3. Forcer le changement de mot de passe à la prochaine connexion
Write-Host "`n[3/5] Configuration du changement obligatoire..." -ForegroundColor Yellow
Set-ADUser -Identity $userSAM -ChangePasswordAtLogon $true
Write-Host "  ✓ L'utilisateur devra changer son mot de passe à la prochaine connexion" -ForegroundColor Green

# 4. Déverrouiller le compte si nécessaire
Write-Host "`n[4/5] Déverrouillage du compte..." -ForegroundColor Yellow
if ($user.LockedOut) {
    Unlock-ADAccount -Identity $userSAM
    Write-Host "  ✓ Compte déverrouillé" -ForegroundColor Green
} else {
    Write-Host "  Le compte n'était pas verrouillé (pas d'action nécessaire)" -ForegroundColor Gray
}

# 5. Documenter l'incident
Write-Host "`n[5/5] Documentation de l'incident..." -ForegroundColor Yellow
Set-ADUser -Identity $userSAM -Description $incidentNote
Write-Host "  ✓ Incident documenté dans la description du compte" -ForegroundColor Green

# Vérification finale
Write-Host "`n========================================" -ForegroundColor Green
Write-Host " INCIDENT RÉSOLU" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

$userFinal = Get-ADUser -Identity $userSAM -Properties LockedOut, PasswordExpired, PasswordLastSet, Description

Write-Host "`nÉtat final du compte:" -ForegroundColor Cyan
Write-Host "  Utilisateur          : $($userFinal.Name)" -ForegroundColor White
Write-Host "  Compte activé        : $($userFinal.Enabled)" -ForegroundColor White
Write-Host "  Compte verrouillé    : $($userFinal.LockedOut)" -ForegroundColor White
Write-Host "  Mot de passe réinit  : $($userFinal.PasswordLastSet)" -ForegroundColor White
Write-Host "  Doit changer MDP     : $($userFinal.PasswordExpired)" -ForegroundColor White
Write-Host "  Description          : $($userFinal.Description)" -ForegroundColor Gray

Write-Host "`nMot de passe temporaire: $tempPassword" -ForegroundColor Yellow
Write-Host "⚠ Communiquez ce mot de passe à l'utilisateur de manière SÉCURISÉE (téléphone, en personne)" -ForegroundColor Yellow
Write-Host "  NE PAS envoyer par email !" -ForegroundColor Red
```


## Points Clés à Retenir

### Sécurité des Mots de Passe

- **Jamais de communication par email** : Les mots de passe doivent être communiqués par téléphone, SMS, ou en personne
- **Toujours forcer le changement** : Le mot de passe temporaire ne doit être connu que le temps nécessaire
- **Mots de passe forts** : Minimum 12 caractères, mélange de majuscules, minuscules, chiffres, symboles

### Gestion des Incidents de Sécurité

1. **Réagir rapidement** : Chaque minute compte quand un compte est compromis
2. **Documenter** : Tracer l'incident pour l'audit et les analyses futures
3. **Communiquer** : Informer l'utilisateur et, si nécessaire, le responsable de la sécurité
4. **Sensibiliser** : Utiliser l'incident pour former l'utilisateur aux bonnes pratiques

### Différence : Réinitialiser vs Changer

- **Réinitialiser (Reset)** : L'administrateur définit un nouveau mot de passe sans connaître l'ancien
- **Changer (Change)** : L'utilisateur change son propre mot de passe en connaissant l'ancien

### Verrouillage de Compte

- **Politique de verrouillage** : Définie dans les GPO (ex: 5 tentatives échouées = verrouillage)
- **Durée** : Le compte peut se déverrouiller automatiquement après X minutes, ou nécessiter une intervention admin
- **Raisons courantes** :
  - Utilisateur qui a oublié son mot de passe
  - Attaque par force brute (tentatives multiples)
  - Applications avec anciennes credentials en cache

## Dépannage (Erreurs Courantes)

| Erreur Possible | Cause | Solution |
|-----------------|-------|----------|
| "Accès refusé" lors de la réinitialisation | Droits insuffisants | Utilisez un compte Administrateur du domaine ou un compte avec délégation de réinitialisation de MDP |
| "Le mot de passe ne respecte pas la politique" | Mot de passe trop simple | Utilisez un mot de passe plus complexe (12+ caractères, mixte) |
| L'option "Déverrouiller" n'apparaît pas | Le compte n'est pas verrouillé | C'est normal, cette option n'apparaît que si le compte est verrouillé |
| L'utilisateur ne peut toujours pas se connecter | Compte désactivé ou autre problème | Vérifiez avec `Get-ADUser -Identity bastien -Properties *` |

## Actions Complémentaires Recommandées

Dans un contexte réel, vous devriez également :

1. **Vérifier les logs de connexion** : Identifier d'où provenaient les tentatives malveillantes
2. **Révoquer les sessions actives** : Déconnecter toutes les sessions en cours du compte
3. **Vérifier les groupes** : S'assurer que l'attaquant n'a pas ajouté le compte à des groupes privilégiés
4. **Scanner le poste de travail** : Vérifier qu'il n'y a pas de malware sur l'ordinateur de Bastien
5. **Signaler l'incident** : Informer le responsable de la sécurité et éventuellement les autorités

## Pour Aller Plus Loin

### Créer une Politique de Verrouillage de Compte

```powershell
# Voir la politique actuelle
Get-ADDefaultDomainPasswordPolicy | Select-Object LockoutThreshold, LockoutDuration, LockoutObservationWindow

# Modifier (exemple - nécessite des droits élevés)
# Set-ADDefaultDomainPasswordPolicy -LockoutThreshold 5 -LockoutDuration 00:15:00 -LockoutObservationWindow 00:15:00
```

### Rechercher Tous les Comptes Verrouillés

```powershell
Search-ADAccount -LockedOut | Select-Object Name, SamAccountName, LockedOut, LastLogonDate
```

## Exercice Suivant Suggéré

**Exercice 6** : Configurer une GPO de politique de mot de passe renforcée pour un département sensible (niveau avancé)
