
# Installation de Windows Server 2022 avec VirtualBox

Ce guide vous accompagnera dans le processus d'installation de Windows Server 2022 en utilisant VirtualBox 6 sous Ubuntu 22.

# 1. Prérequis

## 1.1. Installation de VirtualBox

(**Important: **Si VirtualBox est déjà installé, passez à la section suivante)

1. Ouvrez un terminal et mettez à jour la liste des paquets :
   ```bash
   sudo apt update
   ```

2. Installez VirtualBox et son Pack d'Extension :
   ```bash
   sudo apt install virtualbox virtualbox-ext-pack
   ```

3. Acceptez les termes de la licence lors de l'installation.

## 1.2. Téléchargement de Windows Server 2022

(**Important:** Si les images sont déjà téléchargées, passez à la section suivante)


1. Visitez le [Centre d'évaluation Microsoft](https://www.microsoft.com/en-us/evalcenter/download-windows-server-2022)
2. Téléchargez le fichier ISO de Windows Server 2022 (C'est une version d'évaluation valable 180 jours)
3. Enregistrez le fichier ISO dans un emplacement facilement accessible


# 2. Création de la Machine Virtuelle

## 2.1. Configuration de Base

1. Ouvrez VirtualBox
2. Cliquez sur **Nouvelle**
3. Configurez les paramètres de base (pas besoin de changer le reste):
   - Nom : `WindowsServerM1`
   - Choisissez "VDI (Image disque VirtualBox)"
   - ISO Image (cherche le fichier ISO dans votre disque, téléchargez-le à l'avance)
   - Type : Microsoft Windows
   - **Cochez Skip Unattended Installation** ou l'installation échouera
   - Dans la section **Hardware** (specs. chez ISIB):
     - 4096 Mo (4 Go)
     - 2 processeurs
     - Disque dur : 50 Go

   Appuyez sur Finish!

      
## 2.2. Paramètres Additionnels

1. Sélectionnez la VM et cliquez sur "Paramètres"

2. Système :
   - Onglet Processeur : Attribuez au moins 2 processeurs

3. Affichage :
   - Mémoire vidéo : 128 Mo
   - Activer l'Accélération 3D

4. Réseau : sélectionnez
   - Adaptateur : Changez **NAT** par **réseau privé**

5. Stockage :
   - Cliquez sur le lecteur optique vide
   - Choisissez le fichier ISO Windows Server 2022 téléchargé
   - Cliquez sur "OK"

# 3. Installation de Windows Server 2022 sur la VM

1. Démarrez la machine virtuelle

2. Lorsque l'écran d'installation de Windows apparaît :
   - Sélectionnez vos préférences de langue (Français, clavier Belge!)
   - Cliquez sur **Installer maintenant**

3. Sélectionnez l'édition Windows Server 2022 :
   - **Choisissez "Windows Server 2022 Standard (Expérience Desktop)"**
   - Cliquez sur "Suivant"

4. Acceptez les termes de la licence

5. Choisissez **"Personnalisé : Installer Windows uniquement (avancé)"**

6. Sélectionnez l'espace non alloué et cliquez sur **Suivant**

7. Attendez que l'installation se termine (la VM redémarrera plusieurs fois)

8. Configurez le compte administrateur :
   - Entrez **Password1!** comme mot de passe (just pour nos labos)
   - N'oubliez pas de sauvegarder ce mot de passe en lieu sûr

9. Le système redémarrera et vous verrez l'écran de login pour l'administrateur (le seul utilisateur que vous avez créé pendant l'installation)

10. Utilisez la barre supérieure de menu pour envoyer au serveur un sequence de touches (comme sur un clavier) : **Ctrl + Alt + Suppr** (Barre supérieure de menu->Entrée->Clavier->Envoyer CTRL+ALT+DEL)  

## 3.1. Post-Installation de base

Après l'installation de Windows Server 2022, il est nécessaire d'effectuer quelques configurations de base :

- Installation des mises à jour Windows (lancer Windows Update)
- Redémarrage si nécessaire


## 3.2. Console de Gestion du Serveur

C'est une console qui permet de configurer et de gérer les rôles et les caractéristiques du serveur, ainsi que la configuration du réseau.

Cliquez sur **Démarrer** et tapez **Gestionnaire du Serveur** dans la barre de commande. 

Notre serveur n'est pas configuré pour le moment.

Commençons par donner un nom au serveur. Notre serveur sera l'élément clé: `dns1.computerelectronics.be`.

Regardez le schéma de l'infrastructure de réseau de Computerelectronics.be:

![Infrastructure](../diagrams/images/structure_reseau_geographic_zones.png)



1. Ouvrez à nouveau le **Gestionnaire de serveur** et cliquez sur **Serveur local**
2. Cliquez sur le nom actuel du serveur
3. Dans la fenêtre Propriétés système, cliquez sur **Modifier**
4. Dans le champ **Nom de l'ordinateur**, tapez : **dns1**
5. Dans le champ **Suffixe DNS principal de l'ordinateur**, tapez : **computerelectronics.be**
6. Cliquez sur **OK**
7. Redémarrez le serveur pour appliquer les changements

Le serveur aura maintenant le nom complet (FQDN) : dns1.computerelectronics.be

(Vous auriez pu acceder au nom du serveur depuis le **sysdm.cpl**).

**FQDN** = Fully Qualified Domain Name (Nom de domaine complet)

# 4. Machines clientes Windows 10

Nous avons une VM pour le serveur, mais nous devons créer des VM pour les machines clientes (au moins une!).    

## 4.1. Pourquoi avons-nous besoin des VM clients Windows 10 ?

Les départements de l'entreprise (Comptabilité, RH, Ventes) ont des besoins différents. Par exemple :
- La Comptabilité a besoin d'accéder aux logiciels financiers
- Les RH doivent gérer les dossiers du personnel
- Les Ventes utilisent des applications commerciales

Pour bien comprendre comment gérer ces différents besoins, **nous allons créer deux ordinateurs virtuels Windows 10** qui simuleront :

1. **Un poste de travail pour chaque département**

2. **Des règles différentes pour chaque poste**
   - Par exemple : le poste de la Comptabilité pourra accéder aux dossiers financiers
   - Tandis que le poste des RH aura accès aux dossiers du personnel

3. **Un mini-réseau d'entreprise**
   - Comme une vraie entreprise en plus petit
   - Parfait pour apprendre sans risque
   - Idéal pour tester différentes configurations

C'est un peu comme avoir une "maquette" de l'entreprise : on peut tout tester en toute sécurité avant de le faire dans une vraie situation !

## 4.2. Installation d'une machine cliente Windows 10

Voici la procédure pour installer la première machine cliente :

Suivez la même procedure que pour le serveur, mais avec les paramètres suivants :

   - Nom pour la VM: `Windows10M1`
   - Génération : 2 (64 bits)
   - Mémoire : 4 GB (si possible)
   - Réseau : **réseau privé**
   - Disque dur virtuel : 30 GB
   - ISO : Image Windows 10

1. Démarrez la machine virtuelle et suivez l'assistant d'installation :
   - Langue : Français (clavier Belge!)
   - Version : Windows 10 Pro
   - Installation personnalisée
   - Créez un compte local: **clark.kent**, password **Password1!**

2. Une fois l'installation terminée :
   - Installez les mises à jour Windows
   - Renommez l'ordinateur avec le nom standardisé

## Exercice - Création d'une seconde machine cliente W10

Pour mettre en pratique vos connaissances, installez une seconde machine cliente en suivant ces critères :

- Nom de la VM : `Windows10M2`
- Créez un compte local: **peter.parker**, password **Password1!** 
- Hardware: pareil que la première machine
  
## Exercice - Création d'un deuxième serveur 

Créez par vous-meme un serveur virtuel Windows Server 2022, qui sera notre `dns2.computerelectronics.be`.
