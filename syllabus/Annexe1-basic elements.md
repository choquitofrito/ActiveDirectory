
- [3. Utilisateurs et groupes (sans AD)](#3-utilisateurs-et-groupes-sans-ad)
  - [3.1. Gestion des utilisateurs](#31-gestion-des-utilisateurs)
  - [3.2. Création d'un utilisateur](#32-création-dun-utilisateur)
    - [Exercices :](#exercices-)
  - [3.3. Gestion des groupes](#33-gestion-des-groupes)
  - [3.4. Création de groupes](#34-création-de-groupes)
    - [Exercices :](#exercices--1)
  - [3.5. Connexion des utilisateurs](#35-connexion-des-utilisateurs)
    - [Exercices :](#exercices--2)
- [5. Services](#5-services)
- [6. Observateur d'événements](#6-observateur-dévénements)
- [7. Planificateur de tâches](#7-planificateur-de-tâches)
  - [7.1. Création d'une tâche simple](#71-création-dune-tâche-simple)
  - [Exemple: Lancer Windows Media Player dans 5 minutes](#exemple-lancer-windows-media-player-dans-5-minutes)
  - [7.2. Modification et d'autres actions sur une tâche](#72-modification-et-dautres-actions-sur-une-tâche)
  - [7.3. Exemple de création de tâches plus élaborées](#73-exemple-de-création-de-tâches-plus-élaborées)
  - [Création d'une tâche de sauvegarde d'un fichier](#création-dune-tâche-de-sauvegarde-dun-fichier)
  - [7.4. Exercice pratique - Planificateur de tâches Windows](#74-exercice-pratique---planificateur-de-tâches-windows)
  - [8. Rôles et caracteristiques](#8-rôles-et-caracteristiques)


# 3. Utilisateurs et groupes (sans AD)

Un compte d'utilisateur est une identité unique qui permet d'accéder aux ressources partagées préalablement dans le réseau de notre serveur.
Un utilisateur peut démarrer une session et utiliser les ressources. Chaque compte est lié à un profil individuel qui a des permissions, restrictions, etc.

## 3.1. Gestion des utilisateurs

1. Faites un clic droit sur Démarrer -> Gestion de l'ordinateur
2. Cliquez sur **Utilisateurs et groupes locaux**
3. Cliquez sur **Utilisateurs**, observez qu'il y a quatre comptes

Sélectionnez par exemple le compte **Administrateur** et faites un clic droit, puis cliquez sur **Propriétés**. Dans l'onglet **Général**, vous pouvez modifier le nom du compte, le mot de passe, bloquer le compte, etc.

Toutes les options d'un compte d'utilisateur sont accessibles depuis ces onglets (**Général**, **Contrôle à distance**, **Membre de**, etc.). Nous verrons ces options dans les sections suivantes.

## 3.2. Création d'un utilisateur

1. Ouvrez le menu **Gestion de l'ordinateur**
2. Cliquez sur **Utilisateurs et groupes locaux**
3. Cliquez sur **Utilisateurs** pour afficher les utilisateurs déjà existants
4. Faites un clic droit sur **Utilisateurs**
5. Cliquez sur **Nouvel utilisateur**
6. Choisissez un nom d'utilisateur (ex : louisarmstrong)
7. Choisissez un nom complet (ex : Louis Armstrong)
8. Choisissez une description (ex : compte pour des tâches spéciales)
9. Choisissez un mot de passe (ex : Password1!)
10. Cliquez sur **Créer** et fermez la fenêtre : l'utilisateur est maintenant créé

Si vous cliquez sur l'onglez **Membre de** vous verrez que l'utilisateur est par défaut rajouté au groupe **Utilisateurs** (déjà existant dans Windows Server)

Quand l'utilisateur se connecte pour la première fois, il lui sera demandé de choisir un mot de passe. Si un utilisateur oublie son mot de passe, il devra notifier l'administrateur du serveur qui modifiera et lui donnera le nouveau mot de passe.

### Exercices : 
- Créez un utilisateur de votre choix
- Modifiez le mot de passe d'un utilisateur
- Supprimez un utilisateur

## 3.3. Gestion des groupes

Les groupes servent à regrouper des utilisateurs pour leur donner des permissions similaires.

1. Ouvrez le menu **Gestion de l'ordinateur**
2. Cliquez sur **Utilisateurs et groupes locaux**
3. Cliquez sur **Groupes** pour afficher les groupes déjà existants

Observez les descriptions pour avoir une idée de ce que chaque groupe peut faire.

On peut ajouter les utilisateurs aux groupes depuis le menu d'utilisateur ou depuis le menu des groupes. Exemple :

1. Faites un clic droit sur le groupe **Administrateurs**
2. Cliquez sur **Ajouter au groupe**
3. Cliquez sur **Ajouter**
4. Tapez le nom d'un utilisateur existant (ex : louisarmstrong)
5. Cliquez sur **Vérifier les noms**
6. Si l'utilisateur existe, il apparaîtra dans la liste. 
Le nom qui précède le nom de l'utilisateur est le nom du serveur
7. Cliquez sur **OK** pour l'ajouter

## 3.4. Création de groupes

On peut créer un groupe qui aura un ensemble concret de permissions et qui sera accessible par un ensemble concret d'utilisateurs. 

1. Ouvrez le menu **Gestion de l'ordinateur**
2. Cliquez sur **Utilisateurs et groupes locaux**
3. Cliquez sur **Groupes** pour afficher les groupes déjà existants
4. Faites un clic droit sur **Groupes**
5. Cliquez sur **Nouveau groupe**
6. Choisissez un nom de groupe (ex : *Test01*)
7. Choisissez une description (ex : *Gestionnaires d'imprimantes*)
8. Cliquez sur **Créer** et fermez la fenêtre : le groupe est maintenant créé et apparaît dans la liste des groupes

Vous pouvez ajouter des utilisateurs au groupe à tout moment en faisant un clic droit sur le groupe et en cliquant sur **Ajouter au groupe**. Vous pouvez aussi ajouter l'utilisateur au groupe depuis le menu des utilisateurs dans l'onglet **Membres de**. Essayez d'ajouter un utilisateur existant au groupe que vous venez de créer !

### Exercices :

- Créez un groupe de votre choix
- Ajoutez deux utilisateurs au groupe (créez-les si nécessaire)
- Supprimez le groupe
- Supprimez l'utilisateur du groupe
- Modifiez le nom du groupe
- Modifiez la description du groupe


## 3.5. Connexion des utilisateurs 

Nous avons crée des utilisateurs et un groupe. 
On peut se connecter maintenant au serveur en utilisant ces utilisateurs.

Fermez la session de l'administrateur (pareil qu'on windows).

Le système vous demande de taper sur Ctrl-Alt-Suppr. Pour ce faire en Hyper-V, allez dans le menu superieur et cliquez sur **Action**, puis sur Ctrl-Alt-Suppr.

Cliquez sur un nom d'utilisateur et tapez le mot de passe.

Pour de raisons de securité, le système vous demandera de créer un nouveau mot de passe. 

### Exercices :

- Connectez vous au serveur en utilisant un utilisateur existant
- Essayez de desinstaller une application (ex: Edge). Qu'est-ce que vous observez?
- Essayez maintenant de vous rajouter au groupe **Administrateurs**. Qu'est-ce que vous observez?



# 5. Services

Les services sont des programmes du système d'exploitation qui s'executent en arriere plan. 
Il y a de services pour divers fonctions du serveur, comme par exemple:
- impression de documents
- gestion de la securite
- gestion du reseau
- gestion des disques
- etc...

Nous pouvons activer ou desactiver ces services.

- Ouvrez le **Gestionnaire de Serveur** et appuyez sur **Outils**, puis sur **Services**.

Vous pouvez aussi accéder depuis la barre de Windows en tapant **services.msc**.

Il y a de services propres au système et d'autres qui s'installent quand on install une application (ex: antivirus, docker, serveur web, etc...).

Le menu de Services nous montrent s'ils sont en cours d'exécution ou pas (certains démarrent automatiquement et d'autres sont manuels. On peut les arreter ou les demarrer à volonté). Pour ce faire:

1. Faites clique droit sur le nom du service    
2. Cliquez sur **Arreter** ou **Demarrer** (ex arreter le service d'audio)


On peut changer d'autres propriétés, notamment le **type de démarrage**

1. Faites clique droit sur le nom du service
2. Cliquez sur **Propriétés**
3. Changez le type de démarrage (ex : Automatique)

Les types de démarrage sont :

- Manual : l'utilisateur doit cliquer sur le bouton démarrer pour demarrer le service
- Automatic : le service démarre automatiquement si on ouvre une aplication qui l'emploie
- Desactiver: le service ne demarre pas et n'est pas utilisable
- Automatic (début différé) : un service qui demarre automatiquement mais ne s'execute pas imediatement (pour de services qui peuvent consommer du temps et bloquer l'interface utilisateur)


# 6. Observateur d'événements

L'observateur d'événements permet de surveiller les événements sur un serveur. Ces événements peuvent être, par exemple:

- le serveur démarre
- un utilisateur s'authentifie
- le serveur crash
- un disque crash 
- un disque est plein
- un programme met trop de temps à répondre
- un contrôle de sécurité a échoué
- le serveur a reçu un paquet suspect
- etc...

On peut activer ou desactiver un observateur d'événements. 

- Ouvrez le **Gestionnaire de Serveur** et appuyez sur **Outils**, puis sur **Services**.

La section la plus importante est **Journaux Windows** (barre à gauche), qui montre cinq categories d'événements.

Cliquez par exemple sur la catégorie **Sécurité** pour voir les événements de sécurité. Triez par la colonne *Catégorie d'événement* et cherchez les événements du type *User Account*.

Faites double clic sur un de ces événement pour voir les détails et vous verrez que l'événement correspond au login de un de vos utilisateurs.

On peut associer de taches à ces événements, qui seront lancées quand l'événement se produit (ex: un disque est pratiquement plein et on veut notifier l'utilisateur).

# 7. Planificateur de tâches

Le planificateur de tâches permet de **démarrer**, **arreter** et **planifier (automatiser)** des tâches, notamment pour automatiser leur execution.
On peut aussi modifier la frequence et la durée de la tache.

- Ouvrez le **Gestionnaire de Serveur** et appuyez sur **Outils**, puis sur **Planificateur de tâches** (vous pouvez le cherche aussi dans la barre de Windows sous le nom *Planificateur de tâches*).
Vous pouvez voir toutes les tâches planifiées dsans la section inférieure (**Tâches actives**).

## 7.1. Création d'une tâche simple


## Exemple: Lancer Windows Media Player dans 5 minutes

1. Ouvrez le planificateur de tâches
2. Cliquer sur **Créer une tâche de base**
3. Nommez la tâche **Lancement du lecteur multimedia** et rajoutez une description, puis faites click sur **Suivant**
4. Choisissez le moment et la frequence de l'execution (ex: **une seule fois**), puis faites click sur **Suivant** 
5. Dans ce cas qui nous occuppe, choisissez l'heure d'execution (ex: 5 minutes après l'heure actuelle)
6. Choisissez l'action à lancer (ici **Demarrer un programme**), puis faites click sur **Suivant**
7. Cherchez le **programme/script** à lancer (Parcourir: C:\Program Files (x86)\Windows Media Player, double click sur **wmplayer**), puis clique sur **Suivant**
8. Cliquez sur **Terminer**
   
Après quelques minutes le Media Player doit être lancé automatiquement.

La tâche apparait dans la liste des **tâches actives** du menu principal du planificateur de tâches, mais pour accéder à ses propriétés on doit cliquez sur **Bibliothèque du Planificateur de tâches**.

Les tâches planifiées sont stockées dans un fichier XML qui se trouvent dans de nombreux repertoires. La tâche qu'on vien de créer se trouve dans un repertoir racine. 
Vous pouvez créez vous-mêmes de dossier contenant des tâches.


## 7.2. Modification et d'autres actions sur une tâche

1. Allez dans **Bibliothèque du Planificateur de tâches**
2. Faites clique droit sur la tâche **Lancement du lecteur multimedia** et vous verrez les possibles actions à réaliser sur un tâche (auto-expliqué)

L'option **Propriétés** vous permet de changer tous les parameetres de la tâche d'une manière intuitive. Par exemple, vous pouvez changer l'heure d'execution, la durée de la tâche, la frequence d'execution, etc...

Si vous voulez déplacer une tâche d'un dossier à un autre dossier, vous devez l'**Exporter** et l'**Importer** depuis le dossier cible, Windows Server ne permet pas de déplacer les tâches entre les dossiers.


## 7.3. Exemple de création de tâches plus élaborées


## Création d'une tâche de sauvegarde d'un fichier

Nous allons créer une tâche qui lance la sauvegarde d'un fichier important qui ser trouve dans un dossier.
La sauvegarde sera executée par un script de PS qu'on va créer préalablement. Ce script sera lancé tous les jours à un certain moment.


1. Créez le script de sauvegarde (ex: sauvegarde.ps sur votre Bureau)

**sauvegarde.ps**
```powershell
# Obtenir la date actuelle et la formater comme AA-MM-JJ
$formattedDate = Get-Date -Format "yy-MM-dd"


# Définir les chemins des fichiers source et destination
$sourceFile="C:\Users\Administrateur\Desktop\dossier\fichier.txt"
$destFolder="C:\Users\Administrateur\Desktop\Sauvegardes"

# Créer le nom du fichier de destination avec la date
$destFile = Join-Path -Path $destFolder -ChildPath "File_$formattedDate.txt"

# Copier le fichier
Copy-Item -Path $sourceFile -Destination $destFile -Force

Write-Host "Fichier copié dans $destFile"

# Enregistrer l'opération de copie dans le fichier journal
$logFile = "C:\Users\Administrateur\Desktop\Sauvegardes\log.txt"
Add-Content -Path $logFile -Value "Début de l'opération de copie à $(Get-Date)"
Add-Content -Path $logFile -Value "Fichier source : $sourceFile"
Add-Content -Path $logFile -Value "Fichier de destination : $destFile"

Add-Content -Path $logFile -Value "Erreur : $_"

Write-Host "Fichier copié dans $destFile"
```

2. Ouvrez le Planificateur de tâches (via Gestionnaire de serveur > Outils > Planificateur de tâches)
3. Dans le panneau de droite, cliquez sur **Créer une tâche...**
4. Dans l'onglet **Général** :
   - Nom : **Sauvegarde_Quotidienne**
   - Description : **Sauvegarde quotidienne des dossiers importants**
   - Sélectionnez **Exécuter même si l'utilisateur n'est pas connecté**
   - Cochez la case **Exécuter avec les autorisations maximales**

5. Dans l'onglet **Déclencheurs** :
   - Cliquez sur **Nouveau...**
   - Sélectionnez **Quotidien**
   - Réglez l'heure de début à l'héure souhaitée
   - Cliquez sur **OK**

6. Dans l'onglet **Actions** :
   - Cliquez sur **Nouveau...**
   - Action : **Démarrer un programme**
   - Programme/script : powershell.exe
   - Ajouter des arguments: -ExecutionPolicy Bypass -File "C:\Users\Administrateur\Desktop\sauvegarde.ps1"
   - Cliquez sur **OK**

**Important**: à chaque essai de la tâche, assurez-vous que vous avez bien mis fin à l'execution précedante (clique droit sur la tache -> Fin)


## 7.4. Exercice pratique - Planificateur de tâches Windows

Configurez une tâche qui :
- Lance le nettoyage de disque (cleanmgr.exe)
- S'exécute le premier dimanche de chaque mois
- Nécessite des privilèges administratifs
- Génère un journal d'événements en cas de succès/échec

Astuce: la tâche a lancer es cleanmgr.exe avec l'argument /sagerun:1
Extra: cherchez la trace de l'execution de la tâche dans l'observateur d'événements.

1. Ouvre l'**Observateur d'événements**
2. Faites clique droit sur **Affichages personnalisés**
3. Faites clique sur **Créer une vue personnalisée**
4. Cochez **Par source** et cherchez **CleanManager** dans **Source d'événements**
5. Cliquez sur **OK**

Cherchez l'éxécution de la tâche sur base de l'heure d'éxécution que vous aviez choisi dans la planification de la tâche prealablement.

## 8. Rôles et caracteristiques

Un rôle est un composant qui permet au serveur d'offrir une fonctionnalité specifique. Un rôle contient de fonctionnalités.

On gére les rôles via le **Gestionnaire de serveur** > **Gérer** (en haut de la page à droite) > **Ajouter des rôles et des fonctionnalités**

Ignorez l'assistant, on va créer les rôles à la main. Cliquez sur Suivant.

Cliquez sur **Installation basée sur un rôle ou une fonctionnalité**. Selectionnez le seul serveur qu'on a. Normalement il y en a plusieurs dans le réséau.

Le système a par défaut une fonctionnalité **Service de fichiers de stockage**. On peut installer de fonctionnalités isolées. **Certains rôles impliquent un groupe de fonctionnalités** .
