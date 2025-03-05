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

AD fonctionne sur Windows. Nous allons l'utiliser concretement Windows Server. Nous pourrions utiliser un ordinateur exclusif pour installer Windows Server, mais nous allons l'installer sur notre propre ordinateur en créant une machine virtuelle utilisant un outil de virtualisation appele Hyper-V.


# Hyper-V

Hyper-V nous permet de créer des machines virtuelles sur notre machine physique. Une machine virtuelle est une simulation logicielle d'un ordinateur : elle fonctionne comme un ordinateur indépendant, avec son propre système d'exploitation, mais n'existe que sous forme de logiciel. On peut y installer Windows, Linux ou d'autres systèmes d'exploitation, exactement comme sur un ordinateur physique.

## 1. Activez Hyper-V dans Windows:

- Dans la barre de recherche de Windows, tapez **Turn Windows Features on or off**
- Cliquez sur **Turn Windows Features on or off**
- Cochez la casse **Hyper-V** et cliquez sur **OK**
- Re-demarrez Windows


## 2. Création des réseaux virtuelles

Nous devons créer une machine virtuelle où on installera Windows Server, mais d'abord on doit créer une reseau virtuelle qui servira a permettre la communication d'un client et de notre windows server. On doit créer aussi un reseau pour que nos machines virtuelles communiquent avec l'internet.

Il y a trois types de reseau:

- External: permet la communication entre tous les equipes physiques de notre reseau et les machines virtuelles qu'y sont installées
- Internal: petmet la communication entre notre équipe physique et les machines virtuelles installées dans l'équipe. On ne peut pas connecter du tout avec d'autres machines en dehors de la notre, ni avec de machines virtuelles installées dans d'autres équipes physiques 
- Private: permet la communication uniquement entre les machines virtuelles installées dans l'équipe, même pas entre l'équipe et ces machines virtuelles

On va créer le reseau interne d'abord. 

1. Lancez le Hyper-V manager depuis la barre de taches de windows
2. Cliquez Virtual Switch Manager
3. Choisissez Private
4. Cliquez sur Create Virtual Switch
5. Nommez le reseau **LAN**
6. Cliquez sur OK

Puis le reseau qui connectera les machines virtuelles a l'internet

1. Cliquez Virtual Switch Manager
2. Choisissez External
3. Cliquez sur Create Virtual Switch
4. Nommez le reseau **WAN**
5. Adaptateur: Choisissez l'adaptateur qui vous connecte à internet (cable où wifi). Cliquez sur OK et ignorez le warning
6. Cliquez sur OK


## 3. Création de la Machine Virtuelle de Windows Server

### 3.1. Création et configuration de la machine virtuelle

Une fois les reseaux ont été créés, on peut maintenant créer une premiere machine virtuelle qui sera notre serveur Windows Server.

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
3. Révisez le resume de la machine virtuelle, puis cliquez sur Finish

La machine apparait dans la liste (**ADS01**)
Appuyez sur **Connect** et puis sur **Start**, puis sur n'importe quelle touche. Vous allez voir l'écran de demarrage d'installation de Windows Server , notre machine virtuelle est lancée et on va installer Windows Server!

### 3.2. Installation de Windows server

1. Choisissez la langue, region et type du clavier (tout par défaut)
2. Choisissez Windows Server Standard Evaluation (pour avoir le bureau)
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

AD fonctionne sur Windows. Nous allons l'utiliser concretement **Windows Server**. Nous pourrions utiliser un ordinateur exclusif pour installer Windows Server, mais nous allons l'installer sur notre propre ordinateur en créant une machine virtuelle utilisant l'outil de virtualisation **Hyper-V**.


# Hyper-V

**Hyper-V nous permet de créer des machines virtuelles sur notre machine physique**. Une machine virtuelle **est une simulation logicielle d'un ordinateur** : elle fonctionne comme un ordinateur indépendant, avec son propre système d'exploitation, mais **n'existe que sous forme de logiciel**. On peut y installer Windows, Linux ou d'autres systèmes d'exploitation, exactement comme sur un ordinateur physique.

## 1. Activez Hyper-V dans Windows:

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

Il y a trois types de reseau:

- External: permet la communication entre tous les equipes physiques de notre reseau et les machines virtuelles qu'y sont installées
- Internal: petmet la communication entre notre équipe physique et les machines virtuelles installées dans l'équipe. On ne peut pas connecter du tout avec d'autres machines en dehors de la notre, ni avec de machines virtuelles installées dans d'autres équipes physiques 
- Private: permet la communication uniquement entre les machines virtuelles installées dans l'équipe, même pas entre l'équipe et ces machines virtuelles

On va créer le reseau interne d'abord. 

1. Lancez le Hyper-V manager depuis la barre de taches de windows
2. Cliquez Virtual Switch Manager
3. Choisissez Private
4. Cliquez sur Create Virtual Switch
5. Nommez le reseau **LAN**
6. Cliquez sur OK

Puis le reseau qui connectera les machines virtuelles a l'internet

1. Cliquez Virtual Switch Manager
2. Choisissez External
3. Cliquez sur Create Virtual Switch
4. Nommez le reseau **WAN**
5. Adaptateur: Choisissez l'adaptateur qui vous connecte à internet (cable où wifi). Cliquez sur OK et ignorez le warning
6. Cliquez sur OK


## 2.2. Création de la Machine Virtuelle de Windows Server

Une fois les reseaux ont été créés, on peut maintenant créer une premiere machine virtuelle qui sera notre serveur Windows Server.

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
3. Révisez le resume de la machine virtuelle, puis cliquez sur Finish

La machine apparait dans la liste (**ADS01**)
Appuyez sur **Connect** et puis sur **Start**, puis sur n'importe quelle touche. Vous allez voir l'écran de demarrage d'installation de Windows Server , notre machine virtuelle est lancée et on va installer Windows Server!

### 3. Installation de Windows server sur sa machine virtuelle

1. Choisissez la langue, region et type du clavier (tout par défaut)
2. Choisissez Windows Server Standard Evaluation (pour avoir le bureau)

L'installation prendra quelques minutes. Après quelques demarrages, L'installation vous demandera un mot de passe pour l'administrateur du serveur.

Une fois le système demarre vous allez voir l'application **Gestionnaire du Serveur** qui nous permet de configurer tous les paramètres du serveur. Fermez cette fenetre pour le moment.

L'interface de Windows Server est très similaire a celle des autres versions de Windows. Le navigateur Edge est installé par défaut. Si vous l'ouvrez, vous verrez qu'il y a pas de connexion à internet... car notre machine virtuelle n'est pas configurée pour se connecter à internet. 

Allez dans le menu de Hyper-V (en dehors de la machine virtuelle) et accédez au Settings de la machine virtuelle **ADS01** en faisant clique droit. Allez dans la section Network Adapter et selectionnez le reseau **WAN**. Cliquez sur OK.

