# Exercice 3 : Créer une GPO pour Mapper un Lecteur Projet Client

## Niveau de Difficulté
🟢 **Débutant** - Guidé étape par étape

## Objectifs Pédagogiques
- Créer une nouvelle stratégie de groupe (GPO) depuis la console GPMC
- Comprendre la différence entre Configuration Ordinateur et Configuration Utilisateur
- Lier une GPO à une Unité Organisationnelle spécifique
- Tester l'application d'une GPO avec gpupdate

## Durée Estimée
20-25 minutes

## Prérequis
- Lab CreativeHub déployé avec succès
- Accès à la Console de Gestion des Stratégies de Groupe (gpmc.msc)
- Connexion en tant qu'administrateur du domaine
- **Note** : Cet exercice configure une GPO même si le partage réseau n'existe pas encore (normal en environnement de lab)

## Contexte / Scénario
**Date**: Lundi matin, nouvelle semaine de projet

Karine Garnier, Chef de Projet Senior au département Client Services, vous envoie cette demande :

> *"Bonjour l'équipe IT,*
>
> *Nous venons de décrocher un gros contrat avec un nouveau client : la société 'TechVision'. Toute l'équipe Client Services aura besoin d'accéder rapidement aux documents du projet.*
>
> *Pouvez-vous configurer un lecteur réseau automatique (lettre T: pour 'TechVision') qui apparaîtra sur tous nos postes dès qu'on se connecte ?*
>
> *Le chemin du partage réseau sera : \\\\DNS1\\TechVision*
>
> *Merci !*
> *Karine*"

Votre mission : créer une GPO qui mappe automatiquement le lecteur T: pour tous les utilisateurs du département Client Services.

## Tâche à Réaliser

### Préparation: 

1. Créez le dossier partagé `c:\Projets\TechVision`
2. Créez le lecteur T: 

### Étape 1 : Ouvrir la Console de Gestion des Stratégies de Groupe

1. Sur le **contrôleur de domaine**, cliquez sur **Démarrer**
2. Tapez `gpmc.msc` et appuyez sur **Entrée**
3. La console "Gestion de stratégie de groupe" s'ouvre


!!! success "Résultat attendu"
    Vous voyez l'arborescence avec "Forêt: maxtec.be" → "Domaines" → "maxtec.be"

### Étape 2 : Naviguer vers le Conteneur des GPO

1. Dans le volet de gauche, déroulez :
   - **Gestion de stratégie de groupe**
   - **Forêt: maxtec.be**
   - **Domaines**
   - **maxtec.be**
2. Vous verrez plusieurs éléments dont **Objets de stratégie de groupe**


!!! success "Résultat attendu"
    Vous voyez les GPOs existantes (CreativeHub - Restrictions Utilisateurs Juniors, etc.)

### Étape 3 : Créer une Nouvelle GPO

1. **Clic droit** sur **Objets de stratégie de groupe**
2. Sélectionnez **Nouveau**
3. Dans la fenêtre qui apparaît :
   - **Nom** : `CreativeHub - Lecteur Projet TechVision`
   - Laissez "GPO source" sur "(aucune)"
4. Cliquez sur **OK**

!!! success "Résultat attendu"
    
    La nouvelle GPO "CreativeHub - Lecteur Projet TechVision" apparaît dans la liste des GPOs

### Étape 4 : Éditer la GPO pour Configurer le Mappage de Lecteur

1. **Clic droit** sur la GPO **CreativeHub - Lecteur Projet TechVision**
2. Sélectionnez **Modifier...**
3. L'**Éditeur de gestion des stratégies de groupe** s'ouvre dans une nouvelle fenêtre


!!! success "Résultat attendu"
    Vous voyez deux sections principales : "Configuration ordinateur" et "Configuration utilisateur"

### Étape 5 : Naviguer vers les Préférences de Mappage de Lecteurs

**Important** : Nous allons utiliser les **Préférences de stratégie de groupe** (plus souples que les stratégies classiques).

1. Dans l'éditeur, déroulez :
   - **Configuration utilisateur** (pas Configuration ordinateur !)
   - **Préférences**
   - **Paramètres Windows**
2. **Clic droit** sur **Mappages de lecteurs**
3. Sélectionnez **Nouveau** → **Lecteur mappé**


!!! success "Résultat attendu"
    Une fenêtre "Nouvelles propriétés de lecteur mappé" s'ouvre

### Étape 6 : Configurer les Propriétés du Lecteur Mappé

Remplissez les champs suivants :

1. **Action** : Sélectionnez **Créer** (dans le menu déroulant)
2. **Emplacement réseau** : `\\DNS1\\TechVision`
   - **Note** : DNS1 est le nom de votre contrôleur de domaine (ajustez si différent)
3. **Reconnecter** : **Cochez cette case** (pour que le lecteur soit reconnecté à chaque ouverture de session)
4. **Lettre de lecteur** : Sélectionnez **T:** dans le menu déroulant
5. **Afficher cette unité** : Laissez sur "Aucune modification"
6. **Nom** : `Projet TechVision` (optionnel, donne un nom descriptif au lecteur)

7. Cliquez sur **OK**


!!! success "Résultat attendu"
    Le lecteur T: apparaît dans la liste des mappages configurés

### Étape 7 : Fermer l'Éditeur et Vérifier la Configuration

1. Fermez l'**Éditeur de gestion des stratégies de groupe**
2. Vous revenez à la console GPMC


!!! success "Résultat attendu"
    Votre GPO "CreativeHub - Lecteur Projet TechVision" est créée mais pas encore liée (donc pas encore appliquée)

### Étape 8 : Lier la GPO à l'OU Client Services

1. Dans le volet de gauche de GPMC, naviguez vers :
   - **maxtec.be** → **CreativeHub** → **ClientServices** → **Users**
2. **Clic droit** sur l'OU **Users**
3. Sélectionnez **Lier un objet de stratégie de groupe existant...**
4. Dans la liste, sélectionnez **CreativeHub - Lecteur Projet TechVision**
5. Cliquez sur **OK**


!!! success "Résultat attendu"
    La GPO apparaît maintenant sous l'OU "Users" avec un lien (icône de maillon de chaîne)

### Étape 9 : Vérifier l'Ordre de Liaison et l'État

1. Cliquez sur l'OU **OU=Users,OU=ClientServices,OU=CreativeHub,DC=maxtec,DC=be** dans le volet de gauche
2. Dans le volet de droite, sélectionnez l'onglet **Objets de stratégie de groupe liés**
3. Vous devriez voir votre GPO listée avec :
   - **État du lien** : Activé
   - **Application de la stratégie de groupe** : Activé


!!! success "Résultat attendu"
    La GPO est bien liée et activée

### Étape 10 : Tester l'Application de la GPO (Simulation)

**Sur un client Windows joint au domaine** (ou sur le DC pour tester) :

1. Ouvrez **PowerShell** en tant qu'administrateur
2. Exécutez la commande :
   ```powershell
   gpupdate /force
   ```
3. Attendez le message "Mise à jour de la stratégie utilisateur terminée avec succès"


!!! success "Résultat attendu"
    La GPO est téléchargée sur le client

4. Pour vérifier quelles GPOs s'appliquent à un utilisateur :
   ```powershell
   gpresult /r /scope:user
   ```


!!! success "Résultat attendu"
    Vous devriez voir "CreativeHub - Lecteur Projet TechVision" dans la liste des GPOs appliquées


## Vérification de la Réussite

### Commandes PowerShell de Vérification

```powershell
Import-Module GroupPolicy

# Vérifier que la GPO existe
Get-GPO -Name "CreativeHub - Lecteur Projet TechVision" |
    Select-Object DisplayName, GpoStatus, CreationTime

# Vérifier le lien GPO sur l'OU ClientServices\Users
$ouDN = "OU=Users,OU=ClientServices,OU=CreativeHub,DC=maxtec,DC=be"
Get-GPInheritance -Target $ouDN |
    Select-Object -ExpandProperty GpoLinks |
    Where-Object {$_.DisplayName -like "*TechVision*"}
```

**OU** exécutez le script de vérification automatique :

```powershell
.\verif_exercice_03.ps1
```

### Critères de Réussite

- [ ] La GPO "CreativeHub - Lecteur Projet TechVision" existe
- [ ] La GPO contient un mappage de lecteur configuré (T: → \\DNS1\TechVision)
- [ ] La GPO est liée à l'OU `OU=Users,OU=ClientServices,OU=CreativeHub,DC=maxtec,DC=be`
- [ ] Le lien est activé (Enabled)
- [ ] La configuration est dans "Configuration utilisateur" (pas ordinateur)
- [ ] L'option "Reconnecter" est cochée

## Solution Complète (Pour Instructeur)

### Méthode GUI

Étapes détaillées fournies dans la section "Tâche à Réaliser" ci-dessus.

### Méthode PowerShell (Avancée)

**Note** : Le mappage de lecteur via Préférences GPO nécessite de manipuler des fichiers XML dans le répertoire SYSVOL. Voici la méthode pour créer et lier la GPO de base :

```powershell
Import-Module GroupPolicy

# Variables
$gpoName = "CreativeHub - Lecteur Projet TechVision"
$ouTarget = "OU=Users,OU=ClientServices,OU=CreativeHub,DC=maxtec,DC=be"
$driveLetter = "T:"
$sharePath = "\\DNS1\Projets\TechVision"

# 1. Créer la GPO
try {
    $gpo = Get-GPO -Name $gpoName -ErrorAction Stop
    Write-Host "La GPO '$gpoName' existe déjà." -ForegroundColor Yellow
} catch {
    $gpo = New-GPO -Name $gpoName -Comment "Mappe le lecteur T: vers le projet TechVision pour Client Services"
    Write-Host "GPO '$gpoName' créée avec succès." -ForegroundColor Green
}

# 2. Lier la GPO à l'OU ClientServices\Users
$link = New-GPLink -Name $gpoName -Target $ouTarget -LinkEnabled Yes -ErrorAction SilentlyContinue
if ($link) {
    Write-Host "GPO liée à $ouTarget" -ForegroundColor Green
} else {
    Write-Host "Le lien GPO existe peut-être déjà." -ForegroundColor Yellow
}

Write-Host "`nIMPORTANT: Le mappage de lecteur doit être configuré manuellement via GPMC" -ForegroundColor Yellow
Write-Host "ou en créant le fichier XML approprié dans SYSVOL." -ForegroundColor Yellow
Write-Host "Chemin SYSVOL: \\maxtec.be\SYSVOL\maxtec.be\Policies\{GPO-GUID}\User\Preferences\Drives\Drives.xml" -ForegroundColor Gray
```

### Contenu XML pour Mappage de Lecteur (Avancé)

Pour référence, voici la structure XML qui serait créée dans `Drives.xml` :

```xml
<?xml version="1.0" encoding="utf-8"?>
<Drives clsid="{8FDDCC1A-0C3C-43cd-A6B4-71A6DF20DA8C}">
    <Drive clsid="{935D1B74-9CB8-4e3c-9914-7DD559B7A417}" name="Projet TechVision"
           status="Projet TechVision" image="2" changed="2025-10-04 10:00:00" uid="{GUID}">
        <Properties action="C" thisDrive="NOCHANGE" allDrives="NOCHANGE" userName=""
                    path="\\DNS1\Projets\TechVision" label="Projet TechVision"
                    persistent="1" useLetter="1" letter="T"/>
    </Drive>
</Drives>
```


## Points Clés à Retenir

- **GPO vs Préférences** :
  - Les **stratégies** (Policies) sont imposées et ne peuvent pas être modifiées par l'utilisateur
  - Les **préférences** (Preferences) configurent des paramètres mais l'utilisateur peut les modifier
- **Configuration Utilisateur vs Ordinateur** :
  - **Utilisateur** : S'applique à l'utilisateur quel que soit l'ordinateur (bon pour les lecteurs réseau)
  - **Ordinateur** : S'applique à la machine quel que soit l'utilisateur connecté
- **Ordre de liaison des GPO** : Si plusieurs GPO sont liées, l'ordre compte (de haut en bas = du plus faible au plus fort)
- **gpupdate /force** : Force l'application immédiate des GPO (sinon, appliqué au prochain redémarrage/connexion)
- **Héritage GPO** : Les GPO liées à l'OU parent s'appliquent aussi aux enfants (sauf si bloqué)

## Dépannage (Erreurs Courantes)

| Erreur Possible | Cause | Solution |
|-----------------|-------|----------|
| "Mappages de lecteurs" n'apparaît pas | Version Windows trop ancienne ou préférences non disponibles | Vérifiez que vous êtes dans Configuration Utilisateur > Préférences > Paramètres Windows |
| Le lecteur T: ne s'affiche pas après gpupdate | Le partage réseau n'existe pas | Normal en environnement de lab, créez le partage ou testez avec un chemin existant |
| "Accès refusé" lors de la création de GPO | Droits insuffisants | Connectez-vous avec un compte Administrateur du domaine ou Administrateur de stratégies de groupe |
| La GPO ne s'applique pas | Problème de liaison ou filtrage de sécurité | Vérifiez l'onglet "Étendue" de la GPO et assurez-vous que "Utilisateurs authentifiés" a la permission "Lecture" et "Appliquer la stratégie de groupe" |

## Bonus : Créer le Partage Réseau (Optionnel)

Si vous souhaitez tester réellement le lecteur T:, créez le partage :

```powershell
# Sur le contrôleur de domaine
$folderPath = "C:\Partages\Projets\TechVision"

# Créer les répertoires
New-Item -Path $folderPath -ItemType Directory -Force

# Créer le partage
New-SmbShare -Name "Projets" -Path "C:\Partages\Projets" -FullAccess "MAXTEC\Admins du domaine" -ChangeAccess "MAXTEC\GG-CreativeHub-ClientServices-Users"

# Définir les permissions NTFS
$acl = Get-Acl $folderPath
$permission = "MAXTEC\GG-CreativeHub-ClientServices-Users", "Modify", "ContainerInherit,ObjectInherit", "None", "Allow"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.SetAccessRule($accessRule)
Set-Acl -Path $folderPath -AclObject $acl
```

## Exercice Suivant Suggéré

**Exercice 4** : Créer un groupe de sécurité pour un projet spécifique et déléguer des permissions (niveau intermédiaire)
