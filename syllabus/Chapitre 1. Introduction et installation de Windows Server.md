# 1. Les réseaux décentralisées VS centralisés avec Active Directory

Imaginez, par exemple, que **vous êtes le responsable informatique d'un magasin d'électronique** d'une entreprise **Computer Electronics** (computerelectronics.be). 
Vous avez actuellement 10 ordinateurs, 2 imprimantes et 2 serveurs (pour la base de données et pour la messagerie). 

Vous **devez gérer chaque ordinateur individuellement**, en vous assurant que chaque utilisateur a le bon mot de passe, que chaque imprimante est configurée correctement, que chaque serveur est mis à jour, etc.

Vous **allez vite vous trouver en difficulté**. Pourquoi?

<details>
<summary>Reponse</summary>
- Chaque fois qu'un employé part, il est difficile de s'assurer que son compte est supprimé sur tous les ordinateurs et serveurs.
- Si vous ajoutez une nouvelle imprimante, vous devez configurer chaque ordinateur séparément pour qu'il puisse l'utiliser. Si vous oubliez un ordinateur, les utilisateurs de cet ordinateur ne pourront pas imprimer. 
- Pareil pour les serveurs. Si vous avez des unités de stockage dans serveurs, vous devez refaire le mapping sur chaque ordinateur.
</details>


## Qu'est-ce que c'est Active Directory? 

Active Directory **arrange ce problème en centralisant** la gestion des utilisateurs et des ordinateurs: **cela implique de stocker toutes les informations dans une seule base de données qui se trouvera sur un serveur** (et non sur chaque ordinateur).

**Active Directory** est une technologie de Microsoft qui permet de créer et gérer une base de données qui fonctionne comme un "annuaire téléphonique d'entreprise" numérique qui stocke des informations sur :
- Les **utilisateurs** (ex: employés, prestataires, etc.)
- Les **ordinateurs** et autres ressources réseau (ex: serveurs, imprimantes, etc.)
- Les **permissions** et droits d'accès (ex: connexion, lecture, écriture, etc.)
- Les stratégies de **sécurité** (ex: permissions de connexion, politiques de mot de passe, etc.)

Tous ces aspects **peuvent être gérés depuis un seul endroit, le serveur Active Directory**.
**AD fonctionne sur Windows**. Nous allons l'utiliser concrètement sur **Windows Server**.


**Centraliser ou ne pas centraliser?**

Vous vous posez la question : "Est-ce une bonne idée de centraliser toute la gestion?"
Qu'est-ce que vous en pensez? Ne regardez pas la solution!

<details>
<summary>Les avantages....</summary>

**Les bons côtés** :
1. C'est plus simple à gérer
   - Tout se fait depuis un seul endroit
   - Plus besoin de faire le tour des ordinateurs, on peut applique de changements à tous les ordinateurs en une seule fois
   - Les mises à jour se font en une fois

2. C'est plus sécurisé
   - Les mots de passe sont gérés au même endroit
   - On voit facilement qui a accès à quoi
   - On peut suivre qui fait quoi sur le réseau

3. Ça fait gagner du temps et de l'argent
   - Moins de temps perdu en maintenance
   - Moins de déplacements entre les postes
   - On paie moins de licences logicielles
</details>

<details>
<summary>Les risques...</summary>

**Les risques** :
1. Si le serveur central tombe en panne c'est la catastrophe totale!
   - Plus personne ne peut travailler
   - Tous les services sont affectés en même temps (ni imprimantes, ni serveurs de fichiers, etc.)

2. Question de sécurité
   - Si un virus infecte le serveur, c'est toute l'entreprise qui est touchée
   - Il faut très bien protéger ce serveur

3. Dépendance au réseau
   - Il faut une bonne connexion réseau partout
   - Sans réseau, pas d'accès aux informations

**Les solutions aux risques...** :
Pour éviter les problèmes, on peut :
- Installer un deuxième serveur de secours
- Faire des sauvegardes régulières
- Avoir un plan en cas de panne

</details>



# 2. Windows Server 

On a consideré que les avantages étaient plus importants que les risques! Alors on va utiliser Active Directory.

**Active Directory (AD)** est un ensemble de services qui a besoin d'être installé sur **Windows Server**. 

**Windows Server est un système d'exploitation** conçu spécifiquement pour les serveurs d'entreprise. Il offre :
- Des fonctionnalités avancées de **gestion de réseau**
- La possibilité d'installer des **services d'entreprise comme Active Directory**
- Une **sécurité renforcée** adaptée aux environnements professionnels
- Des **outils d'administration centralisés**
- La possibilité de **gérer de nombreux utilisateurs** et connexions simultanées


## 2.1. Les machines virtuelles ?

**Nous devons nous assurer que nos expériences ne modifient pas la configuration de notre ordinateur**. Nous devons également **pouvoir facilement restorer une configuration de départ** si nous faisons des erreurs.

**La solution est d'utiliser des machines virtuelles**. Les avantages sont :
* **Chaque machine virtuelle sera indépendante de l'autre et de notre ordinateur physique**.

**Exemple**: on peut créer une machine virtuelle qui contiendra Windows Server, et une autre qui contiendra un autre système d'exploitation. Ou deux machines virtuelles, chacun avec un système d'exploitation différent... les posibilités sont infinies!

* Nous pourrons ainsi **modifier la configuration de chaque machine virtuelle sans craindre de modifier notre ordinateur physique**.
 
* De plus, **nous pourrons facilement supprimer une machine virtuelle et en créer une nouvelle si nous faisons des erreurs**.


## 2.2. Installation de Windows Server avec Hyper-V (Windows)

**IMPORTANT:** si vous n'utilisez pas Windows, vous pouvez utiliser **VirtualBox** au lieu d'Hyper-V. Allez sur [Installation-Windows-Server-2022-VirtualBox.md](Installation-Windows-Server-2022-VirtualBox.md).

Nous allons créer une première machine virtuelle et y installer Windows Server.

L'outil de virtualisation que nous allons utiliser est **Hyper-V**.

### 2.2.1. Activation de Hyper-V dans Windows

- Dans la barre de recherche de Windows, tapez **Activer ou desactiver des fonctionnalités Windows**
- Cliquez sur **Activer ou desactiver des fonctionnalités Windows**
- Cochez la case **Hyper-V** et cliquez sur **OK**
- Redémarrez Windows


### 2.2.3. Création des réseaux virtuels en Hyper-V

Avant de créer la machine virtuelle contenant Windows Server, nous allons créer deux réseaux virtuels, car l'installation de Windows Server demandera de choisir la configuration des réseaux.

Nos machines virtuelles seront connectées à Internet via le réseau **WAN-VM** et elles se connecteront entre elles via le réseau **LAN-VM**

- Un réseau qui servira à permettre **la communication entre les appareils dans notre réseau interne** (ex: clients, serveurs, etc)
- Un réseau pour que nos machines virtuelles communiquent avec Internet

Il y a trois types de réseau :

- *External* : permet la communication entre tous les équipements physiques de notre réseau et les machines virtuelles qui y sont installées
- *Internal* : permet la communication entre notre équipement physique et les machines virtuelles installées dans l'équipement. On ne peut pas communiquer avec d'autres machines en dehors de la nôtre, ni avec des machines virtuelles installées dans d'autres équipements physiques 
- *Private* : permet la communication uniquement entre les machines virtuelles installées dans l'équipement, même pas entre l'équipement et ces machines virtuelles

Commençons par créer le réseau interne :

1. Lancez le Hyper-V Manager depuis la barre des tâches de Windows
2. Cliquez sur Virtual Switch Manager
3. Choisissez Private
4. Cliquez sur Create Virtual Switch
5. Nommez le réseau **LAN-VM**
6. Cliquez sur OK

Puis créons le réseau qui connectera les machines virtuelles à Internet :

1. Cliquez sur Virtual Switch Manager
2. Choisissez External
3. Cliquez sur Create Virtual Switch
4. Nommez le réseau **WAN-VM**
5. Adaptateur : Choisissez l'adaptateur qui vous connecte à Internet (câble ou wifi). Cliquez sur OK et ignorez l'avertissement
6. Cliquez sur OK


### 2.2.2. Téléchargement de Windows Server

Vous pouvez télécharger Windows Server 2022 depuis [cette page](https://www.microsoft.com/en-us/evalcenter/download-windows-server-2022). Il s'agit d'une version d'évaluation de 180 jours


### 2.2.4. Nomenclature des machines

Avant de commencer l'installation, il est important de définir les noms des machines qui constitueront notre infrastructure :

- **Serveur Windows Server** :
  - Nom : `dns1.computerelectronics.be`
  
