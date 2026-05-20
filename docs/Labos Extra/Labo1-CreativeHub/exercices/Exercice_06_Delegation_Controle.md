# Exercice 6 : Délégation de Contrôle - Autonomiser les Responsables de Département

## Niveau de Difficulté
🟡 **Intermédiaire** - Tâche orientée objectif avec recherche

## Objectifs Pédagogiques
- Comprendre le principe de délégation de contrôle dans Active Directory
- Utiliser l'Assistant Délégation de contrôle
- Attribuer des permissions limitées à des utilisateurs non-administrateurs
- Appliquer le principe du moindre privilège (Least Privilege)

## Durée Estimée
25-30 minutes

## Prérequis
- Lab CreativeHub déployé avec succès
- Compréhension des groupes de sécurité
- Connaissance de base des permissions AD

## Installer le module RSAT pour Active Directory (sur le poste client)

Ce module permet d'exécuter des commandes **PowerShell** pour la gestion **Active Directory** directement depuis un poste client Windows.

**Vous allez installer les outils nécessaires :**

1. **Connectez-vous en tant qu'administrateur** sur le poste client (par exemple, **ws-client-01**).
2. **Ouvrir le menu Fonctionnalités facultatives** : appuyez sur la touche Windows et tapez **`facultative`** — Windows propose directement **Fonctionnalités facultatives**. Cliquez dessus.

3. **Ajoutez une fonctionnalité** :
   - Cliquez sur **Ajouter une fonctionnalité**.
   - Dans la barre de recherche, tapez **RSAT**.
   - **Sélectionnez** : **RSAT : Outils d'administration de serveur distant**.
   - **Cochez spécifiquement** : **Outils Active Directory pour RSAT** (inclut les outils pour utilisateurs et ordinateurs **Active Directory**, ainsi que les services **LDS**).

4. **Installez la fonctionnalité** :
   - Cliquez sur **Suivant**, puis sur **Installer**.
   - **Redémarrez** le poste client si nécessaire (Windows peut le demander).

5. **Vérifiez que RSAT fonctionne** : ouvrez **PowerShell** (sans privilèges admin) et lancez :

    ```powershell
    Get-ADUser -Filter * | Select-Object -First 5 Name, SamAccountName
    ```

    Vous devriez voir 5 utilisateurs du domaine `maxtec.be`. Si vous obtenez l'erreur *"Get-ADUser n'est pas reconnu"*, le module n'est pas installé — relancez l'étape 3. Si l'erreur est *"Impossible de contacter un serveur AD"*, vérifiez que le poste est bien joint au domaine.

    **Bonus — vérifier la console GUI** : tapez `dsa.msc` (Active Directory Users and Computers) ou `gpmc.msc` (Group Policy Management) dans Démarrer. Les deux doivent s'ouvrir et afficher la structure de `maxtec.be`.

**Après l'installation :**

- Vous pouvez maintenant utiliser des commandes **PowerShell** comme `Get-ADUser` ou `Set-ADAccountPassword` depuis le poste client.
- Assurez-vous que le poste est connecté au domaine **maxtec.be** pour que les commandes fonctionnent correctement.


## Contexte / Scénario
**Date**: Lundi matin, réunion de direction

Rachid Dupont, Responsable IT, vous explique la nouvelle politique :

> *"Bonjour,*
>
> *Nous recevons trop de demandes de réinitialisation de mot de passe et de modifications de comptes utilisateurs. L'équipe IT est débordée pour des tâches simples que les responsables de département pourraient gérer eux-mêmes.*
>
> *Voici la nouvelle politique de délégation que nous allons mettre en place :*
>
> **Gabrielle Simon** (Directrice Artistique - département Creative) :
> - Doit pouvoir réinitialiser les mots de passe de son équipe Creative
> - Doit pouvoir déverrouiller les comptes de son département
> - NE DOIT PAS pouvoir créer ou supprimer des utilisateurs
> - NE DOIT PAS avoir accès aux autres départements
>
> **Camille Bernard** (Responsable Marketing Digital - département Marketing) :
> - Doit pouvoir créer de nouveaux utilisateurs dans son département (Marketing)
> - Doit pouvoir modifier les propriétés des utilisateurs Marketing
> - Doit pouvoir réinitialiser les mots de passe Marketing
> - NE DOIT PAS pouvoir supprimer des utilisateurs
> - NE DOIT PAS avoir accès aux autres départements
>
> *Cette délégation permettra à nos responsables d'être plus autonomes tout en gardant le contrôle centralisé sur les opérations sensibles.*
>
> *Configurez cette délégation pour Gabrielle et Camille. Testez bien que les permissions sont correctement limitées !*
>
> *Rachid*"

## Tâche à Réaliser

Votre mission est de configurer deux délégations de contrôle distinctes.

### Objectif 1 : Délégation pour Gabrielle (Creative)

Déléguer à **gabrielle** (Gabrielle Simon) les permissions suivantes sur l'OU **OU=Users,OU=Creative,OU=CreativeHub,DC=maxtec,DC=be** :

- Réinitialiser les mots de passe
- Lecture des informations de compte
- Modifier les informations de compte (propriétés non sensibles)

**NE PAS déléguer** :

- Création d'utilisateurs
- Suppression d'utilisateurs
- Modification des appartenances aux groupes

### Objectif 2 : Délégation pour Camille (Marketing)

Déléguer à **camille** (Camille Bernard) les permissions suivantes sur l'OU **OU=Users,OU=Marketing,OU=CreativeHub,DC=maxtec,DC=be** :

- Créer, supprimer et gérer les comptes utilisateurs
- Réinitialiser les mots de passe
- Lecture et modification des informations utilisateur
- Modifier l'appartenance aux groupes

### Contraintes

1. Utiliser l'**Assistant Délégation de contrôle** (méthode GUI recommandée)
2. Les permissions doivent être accordées aux **utilisateurs individuels** (gabrielle et camille), pas à des groupes
3. Les permissions doivent s'appliquer uniquement à l'OU spécifiée (pas aux OUs enfants pour cet exercice)
4. Tester les permissions après configuration

### Questions à Vous Poser

1. **Comment accéder à l'Assistant Délégation de contrôle** ?
   - Clic droit sur une OU → ?

2. **Quelles tâches courantes correspondent aux besoins** ?
   - L'assistant propose des tâches prédéfinies
   - Faut-il créer des permissions personnalisées ?

3. **Comment tester que la délégation fonctionne** ?
   - Se connecter en tant que gabrielle ou camille ?
   - Utiliser PowerShell pour vérifier les ACL ?

### Indices

??? info "💡 Indice 1 : Accéder à l'Assistant Délégation"
    1. Ouvrir `dsa.msc`
    2. Naviguer vers l'OU cible (ex: OU=Users,OU=Creative,OU=CreativeHub)
    3. **Clic droit** sur l'OU → **Déléguer le contrôle...**
    4. L'Assistant Délégation de contrôle s'ouvre
    5. Suivre les étapes :
       - Ajouter les utilisateurs/groupes
       - Sélectionner les tâches à déléguer
       - Valider
    

??? info "💡 Indice 2 : Tâches Courantes pour Gabrielle"
    Pour Gabrielle (réinitialiser MDP et déverrouiller comptes) :
    
    - Sélectionner "Réinitialiser les mots de passe utilisateur et forcer la modification du mot de passe lors de la prochaine ouverture de session"
    - Cette tâche inclut automatiquement le déverrouillage de compte
    

??? info "💡 Indice 3 : Tâches Courantes pour Camille"
    Pour Camille (créer, modifier, gérer utilisateurs) :
    
    - Sélectionner "Créer, supprimer et gérer les comptes utilisateurs"
    - Sélectionner "Réinitialiser les mots de passe utilisateur..."
    - Sélectionner "Modifier l'appartenance à un groupe"
    
    OU utiliser "Créer une tâche personnalisée à déléguer" pour un contrôle plus fin.
    

??? info "💡 Indice 4 : Vérifier les Permissions (PowerShell)"
    ```powershell
    Import-Module ActiveDirectory
    
    # Voir les ACL (Access Control List) d'une OU
    $ou = "OU=Users,OU=Creative,OU=CreativeHub,DC=maxtec,DC=be"
    (Get-Acl "AD:$ou").Access | Where-Object {$_.IdentityReference -like "*gabrielle*"} | Format-Table IdentityReference, ActiveDirectoryRights, AccessControlType
    ```
    

??? info "💡 Indice 5 : Tester la Délégation"
    Option 1 : Se connecter avec le compte délégué
    
    - Ouvrir `dsa.msc` en tant que gabrielle
    - Essayer de réinitialiser un mot de passe dans Creative
    - Essayer de créer un utilisateur (devrait échouer)
    
    Option 2 : PowerShell avec credentials
    ```powershell
    $cred = Get-Credential -UserName "MAXTEC\gabrielle" -Message "Entrez le mot de passe de Gabrielle"
    # Tester des commandes AD avec -Credential $cred
    ```
    

## Vérification de la Réussite

### Commandes PowerShell de Vérification

```powershell
Import-Module ActiveDirectory

# Vérifier les permissions de Gabrielle sur l'OU Creative
$ouCreative = "OU=Users,OU=Creative,OU=CreativeHub,DC=maxtec,DC=be"
Write-Host "Permissions de Gabrielle sur Creative:" -ForegroundColor Cyan
(Get-Acl "AD:$ouCreative").Access |
    Where-Object {$_.IdentityReference -like "*gabrielle*"} |
    Select-Object IdentityReference, ActiveDirectoryRights, AccessControlType |
    Format-Table

# Vérifier les permissions de Camille sur l'OU Marketing
$ouMarketing = "OU=Users,OU=Marketing,OU=CreativeHub,DC=maxtec,DC=be"
Write-Host "`nPermissions de Camille sur Marketing:" -ForegroundColor Cyan
(Get-Acl "AD:$ouMarketing").Access |
    Where-Object {$_.IdentityReference -like "*camille*"} |
    Select-Object IdentityReference, ActiveDirectoryRights, AccessControlType |
    Format-Table
```

**OU** exécutez le script de vérification automatique :

```powershell
.\verif_exercice_06.ps1
```

### Critères de Réussite

**Pour Gabrielle (Creative) :**

- [ ] Gabrielle a des permissions sur `OU=Users,OU=Creative`
- [ ] Gabrielle peut réinitialiser les mots de passe (permission présente)
- [ ] Gabrielle NE PEUT PAS créer d'utilisateurs (permission absente)
- [ ] Les permissions s'appliquent uniquement à l'OU Creative Users

**Pour Camille (Marketing) :**

- [ ] Camille a des permissions sur `OU=Users,OU=Marketing`
- [ ] Camille peut créer des utilisateurs (permission présente)
- [ ] Camille peut modifier les utilisateurs (permission présente)
- [ ] Camille peut réinitialiser les mots de passe (permission présente)
- [ ] Les permissions s'appliquent uniquement à l'OU Marketing Users

## Solution Complète (Pour Instructeur)

### Méthode GUI

#### Délégation pour Gabrielle (Creative)

1. Ouvrir **Utilisateurs et ordinateurs Active Directory** (dsa.msc)
2. Naviguer vers **maxtec.be** → **CreativeHub** → **Creative**
3. **Clic droit** sur l'OU **Users** → **Déléguer le contrôle...**
4. L'Assistant Délégation de contrôle s'ouvre, cliquer sur **Suivant**

5. **Page "Utilisateurs ou groupes"** :
   - Cliquer sur **Ajouter...**
   - Taper `gabrielle`
   - Cliquer sur **Vérifier les noms** (le nom doit être souligné)
   - Cliquer sur **OK**
   - Vérifier que "Gabrielle Simon (gabrielle@maxtec.be)" apparaît
   - Cliquer sur **Suivant**

6. **Page "Tâches à déléguer"** :
   - Sélectionner **Déléguer les tâches courantes suivantes**
   - **Cocher** : "Réinitialiser les mots de passe utilisateur et forcer la modification du mot de passe lors de la prochaine ouverture de session"
   - **NE PAS cocher** : "Créer, supprimer et gérer les comptes utilisateurs"
   - Cliquer sur **Suivant**

7. **Page "Fin de l'Assistant"** :
   - Vérifier le résumé
   - Cliquer sur **Terminer**

#### Délégation pour Camille (Marketing)

1. Dans **dsa.msc**, naviguer vers **maxtec.be** → **CreativeHub** → **Marketing**
2. **Clic droit** sur l'OU **Users** → **Déléguer le contrôle...**
3. Cliquer sur **Suivant**

4. **Page "Utilisateurs ou groupes"** :
   - Cliquer sur **Ajouter...**
   - Taper `camille`
   - Cliquer sur **Vérifier les noms**
   - Cliquer sur **OK**
   - Cliquer sur **Suivant**

5. **Page "Tâches à déléguer"** :
   - Sélectionner **Déléguer les tâches courantes suivantes**
   - **Cocher** :
     - ✓ Créer, supprimer et gérer les comptes utilisateurs
     - ✓ Réinitialiser les mots de passe utilisateur et forcer la modification...
     - ✓ Modifier l'appartenance à un groupe
   - Cliquer sur **Suivant**

6. **Page "Fin de l'Assistant"** :
   - Vérifier le résumé
   - Cliquer sur **Terminer**

### Méthode PowerShell (Avancée)

La délégation de contrôle via PowerShell nécessite de manipuler les ACL (Access Control Lists). Voici un exemple simplifié :

```powershell
Import-Module ActiveDirectory

# Variables
$domainDN = "DC=maxtec,DC=be"
$ouCreativeUsers = "OU=Users,OU=Creative,OU=CreativeHub,$domainDN"
$ouMarketingUsers = "OU=Users,OU=Marketing,OU=CreativeHub,$domainDN"

# Obtenir les SID des utilisateurs
$gabrielleSID = (Get-ADUser -Identity gabrielle).SID
$camilleSID = (Get-ADUser -Identity camille).SID

Write-Host "Délégation pour Gabrielle (Creative)..." -ForegroundColor Cyan

# Récupérer l'ACL de l'OU Creative\Users
$aclCreative = Get-Acl "AD:$ouCreativeUsers"

# Créer une règle d'accès pour réinitialiser les mots de passe
# GUID pour "Reset Password" : 00299570-246d-11d0-a768-00aa006e0529
$resetPasswordGUID = [GUID]"00299570-246d-11d0-a768-00aa006e0529"
$userObjectGUID = [GUID]"bf967aba-0de6-11d0-a285-00aa003049e2" # User object type

$identityReference = [System.Security.Principal.SecurityIdentifier]$gabrielleSID
$adRights = [System.DirectoryServices.ActiveDirectoryRights]"ExtendedRight"
$accessControlType = [System.Security.AccessControl.AccessControlType]"Allow"
$inheritanceType = [System.DirectoryServices.ActiveDirectorySecurityInheritance]"Descendents"

$ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
    $identityReference,
    $adRights,
    $accessControlType,
    $resetPasswordGUID,
    $inheritanceType,
    $userObjectGUID
)

$aclCreative.AddAccessRule($ace)
Set-Acl -Path "AD:$ouCreativeUsers" -AclObject $aclCreative

Write-Host "  ✓ Gabrielle peut réinitialiser les mots de passe dans Creative" -ForegroundColor Green

# Note: La délégation complète nécessite plusieurs règles ACL
# Pour un exercice pédagogique, l'utilisation de l'Assistant GUI est recommandée

Write-Host "`nNote: Pour une délégation complète, utilisez l'Assistant GUI (dsa.msc)" -ForegroundColor Yellow
Write-Host "La configuration manuelle des ACL nécessite de connaître tous les GUIDs des permissions AD" -ForegroundColor Yellow
```

**Note Importante** : La méthode PowerShell pour la délégation est complexe car elle nécessite de connaître les GUIDs spécifiques de chaque permission AD. Pour les étudiants débutants, l'Assistant Délégation de contrôle (GUI) est fortement recommandé.

### Tester la Délégation

#### Test 1 : Gabrielle réinitialise un mot de passe dans Creative

```powershell
# Sur un poste client, ouvrir PowerShell
$cred = Get-Credential -UserName "MAXTEC\gabrielle" -Message "Password: Azerty_1"

# Tenter de réinitialiser le mot de passe de Fabien (dans Creative)
$newPwd = ConvertTo-SecureString "NewPassword123!" -AsPlainText -Force
Set-ADAccountPassword -Identity fabien -NewPassword $newPwd -Reset -Credential $cred

# Si cela fonctionne : Délégation réussie
# Si erreur "Accès refusé" : Délégation incorrecte
```

#### Test 2 : Gabrielle tente de créer un utilisateur (doit échouer)

```powershell



$cred = Get-Credential -UserName "MAXTEC\gabrielle"

# Tenter de créer un utilisateur
New-ADUser -Name "Test User" -SamAccountName "testuser" -Path "OU=Users,OU=Creative,OU=CreativeHub,DC=maxtec,DC=be" -Credential $cred

# Devrait échouer avec "Accès refusé" car Gabrielle n'a pas le droit de créer des utilisateurs
```

#### Test 3 : Camille crée un utilisateur dans Marketing

```powershell
$cred = Get-Credential -UserName "MAXTEC\camille"

# Créer un utilisateur test
$pwd = ConvertTo-SecureString "TempPassword1!" -AsPlainText -Force
New-ADUser -Name "Test Marketing" -GivenName "Test" -Surname "Marketing" -SamAccountName "testmarketing" -Path "OU=Users,OU=Marketing,OU=CreativeHub,DC=maxtec,DC=be" -AccountPassword $pwd -Enabled $true -Credential $cred

# Si cela fonctionne : Délégation réussie
```

## Points Clés à Retenir

### Principe du Moindre Privilège (Least Privilege)

- **Définition** : Accorder uniquement les permissions strictement nécessaires pour accomplir une tâche
- **Avantages** :
  - Réduit les risques de sécurité (comptes compromis ont moins de dommages potentiels)
  - Limite les erreurs humaines
  - Facilite l'audit et la conformité

### Délégation de Contrôle vs Administrateur de Domaine

| Aspect | Délégation de Contrôle | Administrateur de Domaine |
|--------|------------------------|---------------------------|
| **Portée** | Limitée à une OU spécifique | Tout le domaine |
| **Permissions** | Seulement les tâches déléguées | Tous les droits |
| **Risque** | Faible | Élevé |
| **Usage** | Gestion quotidienne | Administration système |

### Tâches Courantes de Délégation

1. **Réinitialiser les mots de passe** : Tâche la plus fréquemment déléguée
2. **Créer/Modifier des utilisateurs** : Pour les responsables de département
3. **Gérer l'appartenance aux groupes** : Pour les chefs de projet
4. **Lire les informations** : Pour le support technique (consultation uniquement)

### Vérification des Permissions

Pour voir qui a quelles permissions sur une OU :

```powershell
$ou = "OU=Users,OU=Creative,OU=CreativeHub,DC=maxtec,DC=be"
(Get-Acl "AD:$ou").Access |
    Where-Object {$_.IdentityReference -notlike "*BUILTIN*" -and $_.IdentityReference -notlike "*NT AUTHORITY*"} |
    Select-Object IdentityReference, ActiveDirectoryRights, AccessControlType |
    Format-Table -AutoSize
```

## Dépannage (Erreurs Courantes)

| Erreur Possible | Cause | Solution |
|-----------------|-------|----------|
| "Accès refusé" lors du test | La délégation n'a pas été appliquée correctement | Refaire la délégation avec l'Assistant |
| L'utilisateur délégué ne voit pas l'OU dans dsa.msc | Normal, les utilisateurs non-admin ne voient que ce qu'ils peuvent gérer | Utiliser PowerShell ou se connecter directement à l'OU |
| Les permissions s'appliquent à toutes les OUs | Héritage activé par défaut | Vérifier que la délégation a été faite sur la bonne OU |
| "Impossible de trouver l'objet" | Mauvais chemin d'OU ou utilisateur | Vérifier le Distinguished Name avec Get-ADUser/Get-ADOrganizationalUnit |

## Pour Aller Plus Loin

### Créer un Groupe pour la Délégation (Meilleure Pratique)

Au lieu de déléguer à des utilisateurs individuels, créez des groupes :

```powershell
# Créer un groupe pour les responsables de département
New-ADGroup -Name "GG-CreativeHub-Responsables-Departement" -GroupScope Global -GroupCategory Security -Path "OU=Groupes_Projets,OU=CreativeHub,DC=maxtec,DC=be"

# Ajouter Gabrielle et Camille
Add-ADGroupMember -Identity "GG-CreativeHub-Responsables-Departement" -Members gabrielle,camille

# Déléguer au groupe plutôt qu'aux individus
```

### Permissions AD Avancées (GUIDs)

Quelques GUIDs utiles pour les permissions AD :

- **Reset Password** : `00299570-246d-11d0-a768-00aa006e0529`
- **Change Password** : `ab721a53-1e2f-11d0-9819-00aa0040529b`
- **Create User Objects** : `bf967aba-0de6-11d0-a285-00aa003049e2`
- **Delete User Objects** : `bf967aba-0de6-11d0-a285-00aa003049e2`

### Audit des Délégations

Pour auditer qui a quelles permissions :

```powershell
# Générer un rapport des permissions sur toutes les OUs
Get-ADOrganizationalUnit -Filter * -SearchBase "OU=CreativeHub,DC=maxtec,DC=be" |
    ForEach-Object {
        $ouPath = $_.DistinguishedName
        Write-Host "`n=== $ouPath ===" -ForegroundColor Cyan
        (Get-Acl "AD:$ouPath").Access |
            Where-Object {$_.IdentityReference -like "*MAXTEC*"} |
            Select-Object IdentityReference, ActiveDirectoryRights |
            Format-Table
    }
```

## Exercice Suivant Suggéré

**Exercice 7** : Scénario avancé - Incident de sécurité complet avec audit et remédiation (niveau avancé)
