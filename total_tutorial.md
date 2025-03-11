<!-- Ce document est un guide simplifié de Windows Server 2025.
Le document inclut des instructions détaillées sur l'administration de réseaux, l'administration des serveurs et applications, ainsi que des conseils generals sur l'administration de Windows Server. -->


# Introduction à Active Directory

Active Directory (AD) est un service d'annuaire pour Windows qui nous permet de gérer de manière sécurisée les identités et les accès dans un réseau d'entreprise. Ses éléments de base sont une base de données et un ensemble de services.

## Qu'est-ce qu'Active Directory ?

Active Directory fonctionne comme un "annuaire téléphonique d'entreprise" numérique qui stocke des informations sur :
- Les utilisateurs (ex: employés, prestataires, etc.)
- Les ordinateurs et autres ressources réseau (ex: serveurs, imprimantes, etc.)
- Les permissions et droits d'accès (ex: connexion, lecture, écriture, etc.)
- Les stratégies de sécurité (ex: permissions de connexion, politiques de mot de passe, etc.)

## Contexte d'utilisation

Active Directory (AD) est principalement utilisé dans les environnements professionnels pour :

- Administration des utilisateurs et des ordinateurs depuis un point unique
- Application des politiques de sécurité à l'échelle de l'entreprise
- Déploiement de logiciels et de mises à jour
- Contrôle d'accès aux ressources 

AD fonctionne sur Windows. Nous allons l'utiliser concrètement sur **Windows Server**. Nous pourrions utiliser un ordinateur dédié pour installer Windows Server, mais nous allons l'installer sur notre propre ordinateur en créant une machine virtuelle utilisant l'outil de virtualisation **Hyper-V**.


# Hyper-V

**Hyper-V nous permet de créer des machines virtuelles sur notre machine physique**. Une machine virtuelle **est une simulation logicielle d'un ordinateur** : elle fonctionne comme un ordinateur indépendant, avec son propre système d'exploitation, mais **n'existe que sous forme de logiciel**. On peut y installer Windows, Linux ou d'autres systèmes d'exploitation, exactement comme sur un ordinateur physique.

## 1. Activez Hyper-V dans Windows

- Dans la barre de recherche de Windows, tapez **Turn Windows Features on or off**
- Cliquez sur **Turn Windows Features on or off**
- Cochez la casse **Hyper-V** et cliquez sur **OK**
- Re-demarrez Windows


## Telechargement de Windows Server

Vous pouvez telecharger Windows Server 2025 depuis [cette page](https://www.microsoft.com/en-us/evalcenter/download-windows-server-2025). Il s'agit d'une version d'évaluation de 180 jours


## 2. Création de la machine virtuelle pour Windows Server

Lancez le gestionnaire Hyper-V depuis la barre de taches de windows

## 2.1. Création des réseaux virtuels

Nous devons créer une machine virtuelle où on installera Windows Server, mais d'abord on doit créer deux reseaux virtuels : 
- un reseau qui servira a permettre la communication des clients et de notre windows server
- un reseau pour que nos machines virtuelles communiquent avec l'internet.

Il y a trois types de réseau :

- External : permet la communication entre tous les équipements physiques de notre réseau et les machines virtuelles qui y sont installées
- Internal : permet la communication entre notre équipement physique et les machines virtuelles installées dans l'équipement. On ne peut pas communiquer avec d'autres machines en dehors de la nôtre, ni avec des machines virtuelles installées dans d'autres équipements physiques 
- Private : permet la communication uniquement entre les machines virtuelles installées dans l'équipement, même pas entre l'équipement et ces machines virtuelles

Commençons par créer le réseau interne :

1. Lancez le Hyper-V Manager depuis la barre des tâches de Windows
2. Cliquez sur Virtual Switch Manager
3. Choisissez Private
4. Cliquez sur Create Virtual Switch
5. Nommez le réseau **LAN**
6. Cliquez sur OK

Puis créons le réseau qui connectera les machines virtuelles à Internet :

1. Cliquez sur Virtual Switch Manager
2. Choisissez External
3. Cliquez sur Create Virtual Switch
4. Nommez le réseau **WAN**
5. Adaptateur : Choisissez l'adaptateur qui vous connecte à Internet (câble ou wifi). Cliquez sur OK et ignorez l'avertissement
6. Cliquez sur OK

## 2.1. Création de la machine virtuelle pour Windows Server

Une fois les réseaux ont été créés, on peut créer une première machine virtuelle qui sera notre serveur Windows Server.

1. Dans le Hyper-V manager, cliquez sur **New->Virtual Machine**
2. Cliquez sur Next une fois
3. Choisissez un nom (ADS01)
4. Choisissez l'emplacement des fichiers de la machine virtuelle (cliquez sur Browse), puis Next
5. Choisissez le type de machine virtuelle: Generation 2 car on travaille qu'avec des machines virtuelles de 64 bits, puis Next
6. Choisissez la quantité de RAM pour la machine virtuelle (4 GB ou un quart de la RAM de la machine physique si elle a moins de 16 GB)
7. La taille du disque dur de la machine virtuelle (ex: 100 GB), puis Next

Maintenant on va lancer la machine virtuelle qui contient le support d'installation de Windows Server

1. Cliquez sur **Install an operating System from a bootable image file**
2. Cliquez Browse et cherchez l'image .ISO de Windows Server (ne vous trompez pas d'image 😊), puis Next
3. Révisez le résumé de la machine virtuelle, puis cliquez sur Finish

La machine apparaît dans la liste (**ADS01**)
Appuyez sur **Connect** et puis sur **Start**, puis sur n'importe quelle touche. Vous allez voir l'écran de démarrage d'installation de Windows Server , notre machine virtuelle est lancée et on va installer Windows Server!

### 3. Installation de Windows server sur sa machine virtuelle

1. Choisissez la langue, région et type du clavier (tout par défaut)
2. Choisissez Windows Server Standard Evaluation (pour avoir le bureau)

L'installation prendra quelques minutes. Après quelques démarrages, l'installation vous demandera un mot de passe pour l'administrateur du serveur.

Une fois le système démarré vous allez voir l'application **Gestionnaire du Serveur** qui nous permet de configurer tous les paramètres du serveur. Fermez cette fenêtre pour le moment.

L'interface de Windows Server est très similaire à celle des autres versions de Windows. Le navigateur Edge est installé par défaut. Si vous l'ouvrez, vous verrez qu'il n'y a pas de connexion à Internet... car notre machine virtuelle n'est pas configurée pour se connecter à Internet. 

Allez dans le menu de Hyper-V (en dehors de la machine virtuelle) et accédez aux paramètres de la machine virtuelle **ADS01** en faisant un clic droit. Allez dans la section Network Adapter et sélectionnez le réseau **WAN**. Cliquez sur OK.

# 4. Utilisateurs et groupes

Un compte d'utilisateur est une identité unique qui permet d'accéder aux ressources partagées préalablement dans le réseau de notre serveur.
Un utilisateur peut démarrer une session et utiliser les ressources. Chaque compte est lié à un profil individuel qui a des permissions, restrictions, etc.

## 4.1. Gestion des utilisateurs

1. Faites un clic droit sur Démarrer -> Gestion de l'ordinateur
2. Cliquez sur **Utilisateurs et groupes locaux**
3. Cliquez sur **Utilisateurs**, observez qu'il y a quatre comptes

Sélectionnez par exemple le compte **Administrateur** et faites un clic droit, puis cliquez sur **Propriétés**. Dans l'onglet **Général**, vous pouvez modifier le nom du compte, le mot de passe, bloquer le compte, etc.

Toutes les options d'un compte d'utilisateur sont accessibles depuis ces onglets (**Général**, **Contrôle à distance**, **Membre de**, etc.). Nous verrons ces options dans les sections suivantes.

## 4.2. Création d'un utilisateur

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

## 4.3. Gestion des groupes

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

## 4.4. Création de groupes

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


## 4.5. Connexion des utilisateurs 

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


# 5. Gestionnaire du Serveur (Server Manager)

C'est une console qui permet de configurer et de gerer rôles et les caracteristiques du serveur, ainsi que la configuration du reseau.

Cliquez sur **Démarrer** et tapez **Gestionnaire du Serveur** dans la barre de commande. 

Notre serveur n'est pas configuré pour le moment.

Commençons par donner un nom au serveur:

1. Cliquez sur **Serveur local** dans la barre à gauche
2. Cliquez sur le nom actuel
3. Tapez une description pour le serveur (ex: Serveur cours AD)
4. Cliquez sur **Modifier**
5. 6. Tapez un nom pour le serveur (ex : ADS01, dans notre cas le même nom que la machine virtuelle)
6. Cliquez sur **Ok**
7. Cliquez sur **Ok**
   
Le systeme vous demande de re-demarrer... faites-le!

Optionnel:

- Montrer l'accès au bureau à distance


# 6. Services

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


# 7. Observateur d'événements

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

# 8. Planificateur de tâches

Le planificateur de tâches permet de **démarrer**, **arreter** et **planifier (automatiser)** des tâches, notamment pour automatiser leur execution.
On peut aussi modifier la frequence et la durée de la tache.

- Ouvrez le **Gestionnaire de Serveur** et appuyez sur **Outils**, puis sur **Planificateur de tâches** (vous pouvez le cherche aussi dans la barre de Windows sous le nom *Planificateur de tâches*).
Vous pouvez voir toutes les tâches planifiées dsans la section inférieure (**Tâches actives**).

## 8.1. Création d'une tâche simple


## Exemple: Lancer Windows Media Player dans 5 minutes

1. Ouvrez le planificateur de tâches
2. Cliquer sur **Créer une tâche de base**
3. Nommez la tâche **Lancement du lecteur multimedia** et rajoutez une description, puis faites click sur **Suivant**
4. Choisissez le moment et la frequence de l'execution (ex: **une seule fois**), puis faites click sur **Suivant** 
5. Dans ce cas qui nous occuppe, choisissez l'heure d'execution (ex: 5 minutes après l'heure actuelle)
6. Choisissez l'action à lancer (ici **Demarrer un programme**), puis faites click sur **Suivant**
7. Cherchez le **programme/script** à lancer (Parcourir: C:\Program Files (x86)\Windows Media Player, double click sur **wmplayer**), puis clique sur **Suivant**
8. Cliquez sur **Terminer**
9. 
Après quelques minutes le Media Player doit être lancé automatiquement.

La tâche apparait dans la liste des **tâches actives** du menu principal du planificateur de tâches, mais pour accéder à ses propriétés on doit cliquez sur **Bibliothèque du Planificateur de tâches**.

Les tâches planifiées sont stockées dans un fichier XML qui se trouvent dans de nombreux repertoires. La tâche qu'on vien de créer se trouve dans un repertoir racine. 
Vous pouvez créez vous-mêmes de dossier contenant des tâches.


## 8.2. Modification et d'autres actions sur une tâche

1. Allez dans **Bibliothèque du Planificateur de tâches**
2. Faites clique droit sur la tâche **Lancement du lecteur multimedia** et vous verrez les possibles actions à réaliser sur un tâche (auto-expliqué)

L'option **Propriétés** vous permet de changer tous les parameetres de la tâche d'une manière intuitive. Par exemple, vous pouvez changer l'heure d'execution, la durée de la tâche, la frequence d'execution, etc...

Si vous voulez déplacer une tâche d'un dossier à un autre dossier, vous devez l'**Exporter** et l'**Importer** depuis le dossier cible, Windows Server ne permet pas de déplacer les tâches entre les dossiers.


## 8.3. Exemple de création de tâches plus élaborées


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


## Exercices pratiques - Planificateur de tâches Windows

### Exercice 1: Maintenance système automatisée
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


