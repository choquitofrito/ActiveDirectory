## Exercice 5: Restreindre la connexion aux ordinateurs d’un département


L’entreprise veut renforcer la sécurité en empêchant les utilisateurs d’un département d’utiliser les ordinateurs d’un autre.

**Dans ce laboratoire, tu dois configurer les ordinateurs de l’OU "IT\Computers"** pour qu’**uniquement les utilisateurs de IT\Users** puissent s’y connecter.

Pensez à comment faire ça. Astuce: on doit profiter des groupes existants dans IT et créer une GPO qui affecte les ordinateurs. 

Vu que chercher dans les GPOs est une folie, voici la section de la GPO que tu dois configurer:

Configuration ordinateur > Stratégies > Paramètres Windows > Paramètres de sécurité > Stratégies locales > Attribution des droits utilisateur > Permettre l'ouverture de session locale


#### Prérequis

!!! warning "Prérequis pour l'exercice"

- Une OU principale : `EU`
- Une sous-OU `IT`, contenant :
  - `IT\Users` : utilisateurs du département IT
  - `IT\Computers` : ordinateurs du département IT

- Trois utilisateurs créés dans `IT\Users` : `ines`, `irene`, `ivan`
- Un utilisateur d'un autre département : `victor` dans `EU\Ventes\Users`
- Un ordinateur joint au domaine dans `IT\Computers` : `ws-IT-01` (dans l'idéel deux ordinateurs si vous êtes à l'aise pour changer le nom d'un ordinateur ou pour créer une autre VM)




## Exercice 6: (Scripts) Nettoyage automatique du dossier Téléchargements à chaque démarrage

Cette GPO va permettre de nettoyer le dossier Téléchargements de l'utilisateur à chaque démarrage de session, pour maintenir les postes propres. Apliquez la sur l'OU des utilisateurs de RH

**Nom** de la GPO : Nettoyage-Telechargements-Demarrage

**Objectif** : Supprimer tous les fichiers du dossier Téléchargements de l'utilisateur à chaque démarrage de session, pour maintenir les postes propres.

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

On doit créer un GPO qui lance ce script au démarrage de session des utilisateurs ciblés.

**Setting**: Le paramètre à configurer est : `Configuration utilisateur > Stratégies > Paramètres Windows > Scripts (ouverture de session)
Attention à rajouter le script dans la section des script PowerShell!

Le script doit se lancer dans la fermeture de session. 
Cliquez et chercher le script sur le disque dur mais **utilisez un chemin de réseau**  dans la configuration!`\\dns1\SYSVOL\maxtec.be\scripts`. ATTENTION AU CHEMIN!!! pas `C:\Windows\SYSVOL\domain\scripts`!

---

## Exercice 7: Délégation de GPOs

**Objectif** : Comprendre et mettre en place les trois niveaux de délégation disponibles sur les GPOs — contrôler à qui une GPO s'applique (Security Filtering), qui peut la modifier (onglet Delegation), et qui peut la lier à une OU (Delegate Control). L'équipe IT ne doit pas être le seul point de passage pour toute modification de stratégie : les chefs de service gèrent les GPOs de leur département, sans pouvoir toucher celles des autres.

**Contexte professionnel** : Dans une organisation qui grandit, il n'est pas tenable que l'administrateur réseau soit sollicité chaque fois qu'un chef de service veut appliquer une restriction ou un mappage de lecteur à son équipe. La délégation applique le principe du moindre privilège : donner à chaque responsable exactement les droits dont il a besoin, ni plus ni moins. C'est aussi ce qui évite que tout le monde travaille avec un compte Domain Admin "parce que c'est plus simple".

#### Prérequis

- La GPO `GPO-LinkBureau` existe et est liée à l'OU `Ventes` (créée dans GPO-1)
- Les groupes `GG-EU-Ventes-Admins` (membre : Valentin) et `GG-EU-IT-Admins` (membre : Irene) existent
- Session ouverte avec un compte Domain Admin (ex. : `maxtec\Administrateur`)
- Console GPMC accessible (`gpmc.msc`)

---

#### Étape 1 : Security Filtering — Restreindre à qui la GPO s'applique

Le Security Filtering contrôle quels utilisateurs ou ordinateurs **reçoivent effectivement** les paramètres de la GPO. Par défaut, toutes les GPOs s'appliquent à `Authenticated Users`, ce qui signifie tout le monde dans l'OU ciblée.

1. Ouvrez **GPMC** (`gpmc.msc`)
2. Dans l'arborescence, naviguez vers `Objets de stratégie de groupe` et cliquez sur **GPO-LinkBureau**
3. Dans le volet de droite, cliquez sur l'onglet **Étendue** (Scope)
4. Dans la section **Filtrage de sécurité**, vous voyez `Authenticated Users` par défaut
5. Sélectionnez `Authenticated Users` et cliquez sur **Supprimer**
6. Cliquez sur **Ajouter**, tapez `GG-EU-Ventes-Admins` et validez

!!! warning "Piège courant"
    
    Quand vous retirez `Authenticated Users` du Security Filtering, les **comptes d'ordinateurs** n'ont plus la permission de **lire** la GPO. Windows en a besoin pour traiter les stratégies Ordinateur. Si votre GPO contient des paramètres Computer Configuration, vous devez rajouter `Authenticated Users` avec uniquement la permission **Lecture** (Read), sans cocher "Appliquer la stratégie de groupe" :
    
    1. Toujours dans l'onglet **Étendue**, cliquez sur **Ajouter** et ajoutez `Authenticated Users`
    2. Passez à l'onglet **Délégation** et cliquez sur **Avancé...**
    3. Sélectionnez `Authenticated Users` dans la liste
    4. Vérifiez que **Lecture** est coché en "Autoriser", et que **Appliquer la stratégie de groupe** est bien **décoché**
    5. Cliquez sur **OK**

**Résultat attendu** : la GPO `GPO-LinkBureau` ne s'appliquera désormais qu'aux membres de `GG-EU-Ventes-Admins`.

---

#### Étape 2 : Onglet Délégation — Qui peut modifier la GPO

L'onglet **Délégation** d'une GPO contrôle les droits d'administration sur la GPO elle-même : qui peut l'éditer, la supprimer, modifier ses permissions. C'est **distinct** du Security Filtering — ici on parle de qui **gère** la GPO, pas de qui la **reçoit**.

1. Dans GPMC, cliquez sur **GPO-LinkBureau**
2. Cliquez sur l'onglet **Délégation**
3. Vous voyez la liste des groupes/utilisateurs qui ont des droits sur cette GPO
4. Cliquez sur **Ajouter...**
5. Tapez `GG-EU-Ventes-Admins` et validez
6. Dans la boîte de dialogue des permissions, choisissez **Modifier les paramètres** (Edit settings)

!!! info "Pourquoi 'Modifier les paramètres' et pas la version complète ?"
    
    La version complète ("Modifier les paramètres, supprimer, modifier la sécurité") donnerait à `GG-EU-Ventes-Admins` la possibilité de **supprimer** la GPO ou de **modifier qui peut l'administrer**. Un chef de service n'a pas besoin de ça — et donner ce niveau de contrôle crée un risque. On revient sur ce point dans la question de réflexion.

7. Pour voir le détail des permissions accordées, cliquez sur **Avancé...**
8. Sélectionnez `GG-EU-Ventes-Admins` dans la liste : vous verrez les ACE (Access Control Entries) fins — lecture, écriture des propriétés, etc. C'est la réalité derrière le bouton "Modifier les paramètres".

**Résultat attendu** : `GG-EU-Ventes-Admins` apparaît dans l'onglet Délégation avec la permission **Modifier les paramètres**.

---

#### Étape 3 : Déléguer le droit de lier des GPOs à l'OU Ventes

Jusqu'ici, même avec les droits d'édition sur la GPO, Valentin ne peut pas **créer ou supprimer de liens** GPO sur l'OU `Ventes`. Ce droit se délègue séparément, directement sur l'OU, via **Délégation de contrôle**.

1. Ouvrez **Utilisateurs et ordinateurs Active Directory** (`dsa.msc`)
2. Dans l'arborescence, développez `maxtec.be > EU`
3. Faites un clic droit sur l'OU **Ventes** et choisissez **Délégation de contrôle...**
4. L'assistant s'ouvre. Cliquez sur **Suivant**
5. Cliquez sur **Ajouter...**, tapez `GG-EU-Ventes-Admins` et validez. Cliquez sur **Suivant**
6. Choisissez **Créer une tâche personnalisée à déléguer**, puis **Suivant**
7. Gardez **Ce dossier, les sous-dossiers existants et les nouveaux sous-dossiers** et cliquez sur **Suivant**
8. Dans la liste des permissions, cochez **Gérer les liens de stratégies de groupe**
9. Cliquez sur **Suivant** puis **Terminer**

**Résultat attendu** : `GG-EU-Ventes-Admins` peut désormais ajouter et supprimer des liens GPO sur l'OU `Ventes` et ses sous-OUs, sans être Domain Admin.

---

#### Étape 4 : Tester avec le compte de Valentin

Pour valider la délégation, utilisez le compte de Valentin, membre de `GG-EU-Ventes-Admins`.

**Option A** — Ouvrir une session complète avec Valentin sur un poste client joint au domaine.

**Option B** — Utiliser RunAs sur le DC pour lancer GPMC avec les credentials de Valentin :

```cmd
runas /user:maxtec\valentin "mmc gpmc.msc"
```

Une fois GPMC ouvert avec le compte Valentin, vérifiez les quatre points suivants :

1. **Peut éditer GPO-LinkBureau** : clic droit sur `GPO-LinkBureau` > **Modifier...** — l'éditeur de GPO s'ouvre sans erreur.
2. **Ne peut PAS éditer les autres GPOs** : même opération sur `Default Domain Policy` — un message d'accès refusé doit apparaître.
3. **Peut créer un lien sur l'OU Ventes** : clic droit sur l'OU `Ventes` > **Lier une stratégie de groupe existante...** — la liste s'affiche.
4. **Ne peut PAS créer de lien sur d'autres OUs** : même opération sur `RH` ou `IT` — option grisée ou refusée.

---

#### Question de réflexion

Pourquoi accorder uniquement **"Modifier les paramètres"** à `GG-EU-Ventes-Admins`, et non **"Modifier les paramètres, supprimer, modifier la sécurité"** ?

Réfléchissez aux conséquences si un chef de service avait le droit de modifier les permissions de la GPO : il pourrait s'accorder des droits supplémentaires, retirer l'accès à d'autres administrateurs, ou supprimer accidentellement une GPO de production. On délègue la capacité de **travailler dans le périmètre défini** — pas la capacité de **redéfinir ce périmètre**.

---

#### Pour aller plus loin

Si vous souhaitez déléguer aussi la **création de nouvelles GPOs** (pas seulement l'édition de GPOs existantes), ajoutez le groupe `GG-EU-Ventes-Admins` au groupe intégré **Group Policy Creator Owners**. Les membres de ce groupe peuvent créer des GPOs dans le domaine — mais par défaut, ils n'ont les droits d'édition que sur les GPOs qu'ils ont eux-mêmes créées. C'est un niveau de délégation plus permissif, à réserver aux équipes IT de département matures.

---

#### Vérification PowerShell

```powershell
# Voir les permissions actuelles sur une GPO
Get-GPPermission -Name "GPO-LinkBureau" -All | Select-Object Trustee, Permission

# Ajouter la permission "Edit settings" à un groupe sur une GPO
Set-GPPermission -Name "GPO-LinkBureau" -TargetName "GG-EU-Ventes-Admins" `
    -TargetType Group -PermissionLevel GpoEdit

# Vérifier les ACL de l'OU Ventes (confirmer la délégation du lien GPO)
$ouDN = "OU=Ventes,OU=EU,DC=maxtec,DC=be"
(Get-Acl -Path "AD:\$ouDN").Access |
    Where-Object { $_.IdentityReference -like "*Ventes-Admins*" } |
    Select-Object IdentityReference, ActiveDirectoryRights

# Voir les liens GPO actifs sur l'OU Ventes
Get-GPInheritance -Target "OU=Ventes,OU=EU,DC=maxtec,DC=be" |
    Select-Object -ExpandProperty GpoLinks
```

**Durée estimée : 45 à 60 minutes**
