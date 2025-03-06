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

Exercices :

- Créez un groupe de votre choix
- Ajoutez deux utilisateurs au groupe (créez-les si nécessaire)
- Supprimez le groupe
- Supprimez l'utilisateur du groupe
- Modifiez le nom du groupe
- Modifiez la description du groupe


