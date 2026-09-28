# Exercices : GPO — série 2

## Exercice 5: Restreindre la connexion aux ordinateurs d’un département


L’entreprise veut renforcer la sécurité en empêchant les utilisateurs d’un département d’utiliser les ordinateurs d’un autre.

**Configurez les ordinateurs de l’OU `IT\Computers`** pour que **seuls les membres du département IT** puissent s’y connecter.

Piste : utilisez les groupes existants d'IT et une GPO qui s'applique aux ordinateurs.

Le paramètre à configurer :

Configuration ordinateur > Stratégies > Paramètres Windows > Paramètres de sécurité > Stratégies locales > Attribution des droits utilisateur > Permettre l'ouverture de session locale


#### Prérequis

!!! warning "Prérequis pour l'exercice"

    - Structure du lab créée ([Référence du lab Maxtec](Labo/Reference_Lab_Maxtec.md)) : `ivan`, `ines` (`GG-EU-IT-Users`), `irene` (`GG-EU-IT-Admin`), `victor` (`EU\Ventes\Users`)
    - `ws-IT-01` joint au domaine **et déplacé** dans `OU=Computers,OU=IT,OU=EU`

!!! danger "Cette GPO bloque les autres exercices"
    Tant qu'elle est active, seuls les membres d'IT peuvent ouvrir une session sur `ws-IT-01`. Or la plupart des exercices testent d'autres utilisateurs (vanessa, rebecca, valentin…) sur ce même poste. **À la fin de l'exercice, supprimez le lien** : GPMC > OU `EU\IT\Computers` > clic droit sur le lien `GPO-IT-LoginRestreint` > **Supprimer** (le lien seulement : la GPO reste dans `Objets de stratégie de groupe`), puis `gpupdate /force` et redémarrage du poste. Un simple lien désactivé ne suffit pas : l'exercice de dépannage D1 fait chercher les liens désactivés, et vous risqueriez de réactiver celui-ci.


??? success "Solution (cliquez pour afficher)"

    **1. Créer et lier la GPO**

    - Ouvrir `gpmc.msc`
    - Clic droit sur l'OU `EU\IT\Computers` → `Créer un objet GPO dans ce domaine et le lier ici…`
    - Nom : `GPO-IT-LoginRestreint`

    **2. Configurer le droit "Permettre l'ouverture de session locale"**

    - Clic droit sur la GPO → `Modifier`
    - Naviguer jusqu'à : `Configuration ordinateur > Stratégies > Paramètres Windows > Paramètres de sécurité > Stratégies locales > Attribution des droits utilisateur`
    - Double-cliquer sur **`Permettre l'ouverture de session locale`**
    - Cocher `Définir ces paramètres de stratégie`
    - Ajouter **uniquement** :
        - `GG-EU-IT-Users` (techniciens IT)
        - `GG-EU-IT-Admin` (Irene n'est **pas** membre de `GG-EU-IT-Users` : sans ce groupe, elle serait bloquée)
        - `Administrateurs` (groupe local du poste — **à ne jamais oublier**, sinon plus aucun administrateur ne peut ouvrir de session sur la machine)

    !!! danger "Piège classique"
        Si vous oubliez `Administrateurs`, vous vous enfermez hors des postes IT. Il faut alors désactiver le lien de la GPO depuis le DC et attendre que le poste la retire. **Toujours inclure `Administrateurs` dans "Permettre l'ouverture de session locale".**

    **3. Tester**

    - Sur `ws-IT-01` : `gpupdate /force` puis redémarrer
    - Se connecter avec `ivan` (`GG-EU-IT-Users`) → doit fonctionner ; idem avec `irene` (`GG-EU-IT-Admin`)
    - Se connecter avec `victor` (Ventes) → refusé, avec un message du type *« La méthode de connexion que vous tentez d'utiliser n'est pas autorisée »* (en anglais : *The sign-in method you're trying to use isn't allowed* ; le libellé exact varie selon la version de Windows)

    **Pourquoi ça marche ?** La GPO est liée à l'OU des **ordinateurs**, donc elle s'applique à `ws-IT-01`. Le droit "Permettre l'ouverture de session locale" est évalué côté machine : seuls les SID listés (directement ou via un groupe) peuvent ouvrir une session interactive. La GPO **remplace** la liste locale : par défaut, le groupe local `Utilisateurs` (qui contient `Utilisateurs du domaine`) y figurait, ce qui permettait à tout le monde de se connecter.

    **N'oubliez pas de supprimer le lien de la GPO** avant de passer à la suite : GPMC > `EU\IT\Computers` > clic droit sur le lien `GPO-IT-LoginRestreint` > **Supprimer** > **OK** (la GPO reste dans `Objets de stratégie de groupe`). Vérifiez : sélectionnez l'OU `EU\IT\Computers` > onglet **Objets de stratégie de groupe liés** : `GPO-IT-LoginRestreint` n'y figure plus. Puis `gpupdate /force` et redémarrage de `ws-IT-01`.

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    Remove-GPLink -Name "GPO-IT-LoginRestreint" -Target "OU=Computers,OU=IT,OU=EU,DC=maxtec,DC=be"
    ```


## Exercice 6: (Scripts) Nettoyage automatique du dossier Téléchargements à l'ouverture de session

Cette GPO nettoie le dossier Téléchargements de l'utilisateur à chaque **ouverture de session**. Appliquez-la à l'OU des utilisateurs de RH.

**Nom** de la GPO : `Nettoyage-Telechargements-Ouverture`

**Objectif** : Supprimer tous les fichiers du dossier Téléchargements de l'utilisateur à chaque ouverture de session.

**Niveau ciblé** : Utilisateur, pas Ordinateur

**Script** : PowerShell

**Chemin du script** : **C:\Windows\SYSVOL\domain\scripts**
L'admin créera le script à l'intérieur du dossier `scripts`. 

Contenu du script : créez un nouveau document de texte `nettoyage_telechargements.ps1` et copiez ce contenu:

```powershell
$shell = New-Object -ComObject Shell.Application
$downloads = $shell.Namespace('shell:Downloads').Self.Path
Remove-Item "$downloads\*" -Recurse -Force -ErrorAction SilentlyContinue
```

Créez une GPO qui lance ce script à l'ouverture de session des utilisateurs ciblés.

**Paramètre** : `Configuration utilisateur > Stratégies > Paramètres Windows > Scripts (ouverture/fermeture de session) > Ouverture de session`, onglet **Scripts PowerShell**.

Pour sélectionner le script, **utilisez le chemin réseau** `\\dns1\SYSVOL\maxtec.be\scripts`, pas `C:\Windows\SYSVOL\domain\scripts`.

??? success "Solution (cliquez pour afficher)"

    **1. Déposer le script sur le DC**

    - Sur le DC, ouvrir l'Explorateur de fichiers
    - Aller dans `C:\Windows\SYSVOL\domain\scripts` (créer le dossier `scripts` s'il n'existe pas)
    - Créer un fichier `nettoyage_telechargements.ps1` avec le contenu fourni dans l'énoncé

    !!! tip "Pourquoi SYSVOL ?"
        Le dossier `SYSVOL` est **automatiquement répliqué** sur tous les DC du domaine et accessible depuis tous les postes via `\\<domaine>\SYSVOL\...`. C'est l'emplacement standard pour héberger des scripts de GPO.

    **2. Créer et lier la GPO**

    - `gpmc.msc` → clic droit sur l'OU `EU\RH\Users` → `Créer un objet GPO dans ce domaine et le lier ici…`
    - Nom : `Nettoyage-Telechargements-Ouverture`

    **3. Configurer le script d'ouverture de session**

    - Clic droit sur la GPO → `Modifier`
    - Naviguer jusqu'à : `Configuration utilisateur > Stratégies > Paramètres Windows > Scripts (ouverture/fermeture de session)`
    - Double-cliquer sur **`Ouverture de session`**
    - Onglet **`Scripts PowerShell`** (en haut de la boîte de dialogue — pas l'onglet par défaut !)
    - `Ajouter…` → `Parcourir…`
    - Dans la barre d'adresse, taper le **chemin réseau** : `\\dns1\SYSVOL\maxtec.be\scripts`
    - Sélectionner `nettoyage_telechargements.ps1`

    !!! danger "Le piège du chemin"
        Si vous parcourez via `C:\Windows\SYSVOL\domain\scripts`, la GPO enregistrera ce chemin **local**, qui n'existe **pas** sur les postes clients → le script ne s'exécutera jamais. Toujours utiliser le chemin UNC `\\dns1\SYSVOL\maxtec.be\scripts`.

    **4. Tester**

    - Sur `ws-RH-01` (ou `ws-IT-01`, si le lien de la GPO de l'exercice 5 est supprimé), se connecter avec `rebecca`
    - Déposer quelques fichiers dans `Téléchargements`
    - Fermer la session, puis se reconnecter → le dossier `Téléchargements` doit être vidé

    !!! note "Délai des scripts d'ouverture de session"
        Depuis Windows 8.1, les scripts d'ouverture de session sont lancés **5 minutes** après l'ouverture de session par défaut. Attendez, ou réglez le délai à 0 dans une GPO ordinateur : `Configuration ordinateur > Stratégies > Modèles d'administration > Système > Stratégie de groupe > Configurer le délai du script d'ouverture de session`.

    **Dépannage** : si rien ne se passe, vérifier dans `gpresult /h rapport.html` que la GPO est bien appliquée à l'utilisateur, et dans l'Observateur d'événements (`Journaux des applications et services > Microsoft > Windows > GroupPolicy > Operational`) qu'il n'y a pas d'erreur d'exécution du script.

---

## Exercice 7: Délégation de GPOs

**Objectif** : Comprendre et mettre en place les trois niveaux de délégation disponibles sur les GPOs — contrôler à qui une GPO s'applique (Security Filtering), qui peut la modifier (onglet Delegation), et qui peut la lier à une OU (Delegate Control). L'équipe IT ne doit pas être le seul point de passage pour toute modification de stratégie : les chefs de service gèrent les GPOs de leur département, sans pouvoir toucher celles des autres.

**Contexte professionnel** : Dans une organisation qui grandit, il n'est pas tenable que l'administrateur réseau soit sollicité chaque fois qu'un chef de service veut appliquer une restriction ou un mappage de lecteur à son équipe. La délégation applique le principe du moindre privilège : donner à chaque responsable exactement les droits dont il a besoin, ni plus ni moins. C'est aussi ce qui évite que tout le monde travaille avec un compte Domain Admin "parce que c'est plus simple".

#### Prérequis

- La GPO `GPO-LinkBureau` existe et est liée à `EU\Ventes\Users` ([GPO-1, 3.1](./Exercices:%20GPO-1.md))
- Les groupes `GG-EU-Ventes-Admin` (membre : Valentin) et `GG-EU-IT-Admin` (membre : Irene) existent
- Session ouverte avec un compte membre de `Admins du domaine` (ex. : `maxtec\Administrateur`)
- **RSAT installé sur `ws-IT-01`** (au moins les outils de gestion des stratégies de groupe et AD DS) : le test de l'étape 4 se fait depuis le poste client, pas depuis le DC. Procédure : [Gestion des utilisateurs, Ex. 12](./Exercices:%20Gestion_des_Utilisateurs.md). En résumé, sur le poste (accès Internet requis : carte NAT temporaire, voir la procédure) : **Paramètres > Applications > Fonctionnalités facultatives > Ajouter une fonctionnalité** > recherchez `RSAT` > cochez **RSAT : Outils de gestion des stratégies de groupe** et **RSAT : Outils Active Directory Domain Services et Services LDS** > **Installer**.

    **En PowerShell** (aperçu, vu au chapitre 9 ; console en administrateur) :

    ```powershell
    Add-WindowsCapability -Online -Name Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0
    Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
    ```

- Le lien de la GPO de l'exercice 5 est supprimé (sinon Valentin ne peut pas ouvrir de session sur `ws-IT-01`)

---

#### Étape 1 : Security Filtering — Restreindre à qui la GPO s'applique

Le Security Filtering contrôle quels utilisateurs ou ordinateurs **reçoivent effectivement** les paramètres de la GPO. Par défaut, toutes les GPOs s'appliquent à `Utilisateurs authentifiés` (Authenticated Users), ce qui signifie tout le monde dans l'OU ciblée.

1. Ouvrez **GPMC** (`gpmc.msc`)
2. Dans l'arborescence, naviguez vers `Objets de stratégie de groupe` et cliquez sur **GPO-LinkBureau**
3. Dans le volet de droite, cliquez sur l'onglet **Étendue** (Scope)
4. Dans la section **Filtrage de sécurité**, vous voyez `Utilisateurs authentifiés` par défaut
5. Sélectionnez `Utilisateurs authentifiés` et cliquez sur **Supprimer**
6. Cliquez sur **Ajouter**, tapez `GG-EU-Ventes-Admin` et validez

!!! warning "Piège courant"
    
    Quand vous retirez `Utilisateurs authentifiés` du filtrage de sécurité, les **comptes d'ordinateurs** n'ont plus le droit de **lire** la GPO. Depuis le correctif MS16-072 (2016), les GPO utilisateur sont lues avec le compte de l'ordinateur : sans ce droit, la GPO est ignorée **même si elle ne contient que des paramètres utilisateur**. Dès que vous retirez `Utilisateurs authentifiés`, rajoutez-le (ou `Ordinateurs du domaine`) avec uniquement la permission **Lecture**, sans "Appliquer la stratégie de groupe" :
    
    1. Passez à l'onglet **Délégation** de la GPO et cliquez sur **Ajouter…**
    2. Tapez `Utilisateurs authentifiés` et validez
    3. Choisissez la permission **Lecture** et validez : l'onglet Délégation n'accorde que la lecture, sans "Appliquer la stratégie de groupe"
    4. Vérification : **Avancé…** > `Utilisateurs authentifiés` : **Lecture** autorisé, **Appliquer la stratégie de groupe** non coché

**Résultat attendu** : la GPO `GPO-LinkBureau` ne s'appliquera désormais qu'aux membres de `GG-EU-Ventes-Admin`.

---

#### Étape 2 : Onglet Délégation — Qui peut modifier la GPO

L'onglet **Délégation** d'une GPO contrôle les droits d'administration sur la GPO elle-même : qui peut l'éditer, la supprimer, modifier ses permissions. C'est **distinct** du Security Filtering — ici on parle de qui **gère** la GPO, pas de qui la **reçoit**.

1. Dans GPMC, cliquez sur **GPO-LinkBureau**
2. Cliquez sur l'onglet **Délégation**
3. Vous voyez la liste des groupes/utilisateurs qui ont des droits sur cette GPO
4. Cliquez sur **Ajouter...**
5. Tapez `GG-EU-Ventes-Admin` et validez
6. Dans la boîte de dialogue des permissions, choisissez **Modifier les paramètres** (Edit settings)

!!! info "Pourquoi 'Modifier les paramètres' et pas la version complète ?"
    
    La version complète ("Modifier les paramètres, supprimer, modifier la sécurité") donnerait à `GG-EU-Ventes-Admin` la possibilité de **supprimer** la GPO ou de **modifier qui peut l'administrer**. Un chef de service n'a pas besoin de ça — et donner ce niveau de contrôle crée un risque. On revient sur ce point dans la question de réflexion.

7. Pour voir le détail des permissions accordées, cliquez sur **Avancé...**
8. Sélectionnez `GG-EU-Ventes-Admin` dans la liste : vous verrez les ACE (Access Control Entries) fins — lecture, écriture des propriétés, etc. C'est la réalité derrière le bouton "Modifier les paramètres".

**Résultat attendu** : `GG-EU-Ventes-Admin` apparaît dans l'onglet Délégation avec la permission **Modifier les paramètres**.

---

#### Étape 3 : Déléguer le droit de lier des GPOs à l'OU Ventes

Jusqu'ici, même avec les droits d'édition sur la GPO, Valentin ne peut pas **créer ou supprimer de liens** GPO sur l'OU `Ventes`. Ce droit se délègue séparément, directement sur l'OU, via **Délégation de contrôle**.

1. Ouvrez **Utilisateurs et ordinateurs Active Directory** (`dsa.msc`)
2. Dans l'arborescence, développez `maxtec.be > EU`
3. Faites un clic droit sur l'OU **Ventes** et choisissez **Délégation de contrôle...**
4. L'assistant s'ouvre. Cliquez sur **Suivant**
5. Cliquez sur **Ajouter...**, tapez `GG-EU-Ventes-Admin` et validez. Cliquez sur **Suivant**
6. Laissez **Déléguer les tâches courantes suivantes** et cochez **Gérer les liens de stratégie de groupe** (c'est une tâche courante de l'assistant, pas besoin de tâche personnalisée)
7. Cliquez sur **Suivant** puis **Terminer**

Alternative dans GPMC : sélectionnez l'OU `Ventes` > onglet **Délégation** > **Ajouter…** > `GG-EU-Ventes-Admin`, permission **Lier les objets GPO**.

**Résultat attendu** : `GG-EU-Ventes-Admin` peut désormais ajouter et supprimer des liens GPO sur l'OU `Ventes` et ses sous-OUs, sans être Domain Admin.

---

#### Étape 4 : Tester avec le compte de Valentin

Pour valider la délégation, utilisez le compte de Valentin, membre de `GG-EU-Ventes-Admin`.

Le test se fait **depuis `ws-IT-01`** avec RSAT. Sur le DC, Valentin n'a pas le droit d'ouverture de session locale (réservé aux administrateurs) : `runas /user:maxtec\valentin` y échoue.

**Option A** — Ouvrir une session avec `valentin` sur `ws-IT-01` et lancer `gpmc.msc`.

**Option B** — Depuis une session existante sur `ws-IT-01`, lancer GPMC avec les identifiants de Valentin :

```cmd
runas /user:maxtec\valentin "mmc gpmc.msc"
```

Si l'ouverture de session locale de Valentin est bloquée sur le poste, `runas /netonly /user:maxtec\valentin "mmc gpmc.msc"` utilise ses identifiants uniquement pour les accès réseau (LDAP, SYSVOL), ce qui suffit pour GPMC.

Une fois GPMC ouvert avec le compte Valentin, vérifiez les quatre points suivants :

1. **Peut éditer GPO-LinkBureau** : clic droit sur `GPO-LinkBureau` > **Modifier...** — l'éditeur de GPO s'ouvre sans erreur.
2. **Ne peut PAS éditer les autres GPOs** : même opération sur `Default Domain Policy` — un message d'accès refusé doit apparaître.
3. **Peut créer un lien sur l'OU Ventes** : clic droit sur l'OU `Ventes` > **Lier une stratégie de groupe existante...** — la liste s'affiche.
4. **Ne peut PAS créer de lien sur d'autres OUs** : même opération sur `RH` ou `IT` — option grisée ou refusée.

---

#### Question de réflexion

Pourquoi accorder uniquement **"Modifier les paramètres"** à `GG-EU-Ventes-Admin`, et non **"Modifier les paramètres, supprimer, modifier la sécurité"** ?

Réfléchissez aux conséquences si un chef de service avait le droit de modifier les permissions de la GPO : il pourrait s'accorder des droits supplémentaires, retirer l'accès à d'autres administrateurs, ou supprimer accidentellement une GPO de production. On délègue la capacité de **travailler dans le périmètre défini** — pas la capacité de **redéfinir ce périmètre**.

---

#### Pour aller plus loin

Si vous souhaitez déléguer aussi la **création de nouvelles GPOs** (pas seulement l'édition de GPOs existantes), ajoutez le groupe `GG-EU-Ventes-Admin` au groupe intégré **Propriétaires créateurs de la stratégie de groupe** (Group Policy Creator Owners). Les membres de ce groupe peuvent créer des GPOs dans le domaine — mais par défaut, ils n'ont les droits d'édition que sur les GPOs qu'ils ont eux-mêmes créées. C'est un niveau de délégation plus permissif, à réserver aux équipes IT de département matures.

---

#### Vérification

Sur le DC, en administrateur du domaine :

1. **Filtrage et délégation de la GPO** : GPMC > `Objets de stratégie de groupe` > `GPO-LinkBureau` > onglet **Étendue** > **Filtrage de sécurité** : seul `GG-EU-Ventes-Admin`. Onglet **Délégation** : `GG-EU-Ventes-Admin` = **Modifier les paramètres**, `Utilisateurs authentifiés` = **Lecture**. **Avancé…** pour le détail des cases.
2. **Droit de lier sur l'OU Ventes** : GPMC > sélectionnez l'OU `EU\Ventes` > onglet **Délégation** > liste **Autorisation** : **Lier les objets GPO** → `GG-EU-Ventes-Admin` doit apparaître. Même information dans `dsa.msc` (affichage avancé) > propriétés de `Ventes` > **Sécurité** > **Avancé** : entrées `GG-EU-Ventes-Admin` sur `gPLink` et `gPOptions`.
3. **Liens actifs sur l'OU Ventes** : GPMC > OU `EU\Ventes` (et `Ventes\Users`) > onglet **Objets de stratégie de groupe liés**.

**En PowerShell** (aperçu, vu au chapitre 9) :

```powershell
# Voir les permissions actuelles sur une GPO
Get-GPPermission -Name "GPO-LinkBureau" -All | Select-Object Trustee, Permission

# Ajouter la permission "Edit settings" à un groupe sur une GPO
Set-GPPermission -Name "GPO-LinkBureau" -TargetName "GG-EU-Ventes-Admin" `
    -TargetType Group -PermissionLevel GpoEdit

# Vérifier les ACL de l'OU Ventes (confirmer la délégation du lien GPO)
$ouDN = "OU=Ventes,OU=EU,DC=maxtec,DC=be"
(Get-Acl -Path "AD:\$ouDN").Access |
    Where-Object { $_.IdentityReference -like "*Ventes-Admin*" } |
    Select-Object IdentityReference, ActiveDirectoryRights

# Voir les liens GPO actifs sur l'OU Ventes
Get-GPInheritance -Target "OU=Ventes,OU=EU,DC=maxtec,DC=be" |
    Select-Object -ExpandProperty GpoLinks
```

**Durée estimée : 45 à 60 minutes**
