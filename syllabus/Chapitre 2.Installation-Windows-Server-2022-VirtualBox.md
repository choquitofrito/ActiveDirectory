# Chapitre 2: Installation de Windows Server 2022 sur VirtualBox

## 🧭 Navigation du Cours
[⏮️ Chapitre Précédent: Introduction](Chapitre%201.Introduction%20et%20installation%20de%20Windows%20Server.md) | [🏠 Retour au Syllabus](../README.md) | [⏭️ Chapitre Suivant: DNS](Chapitre%203.DNS.md)

> 📚 **Dans ce guide:**
> 1. 🛠️ [Prérequis](#1-prérequis)
>    - Installation de VirtualBox
>    - Téléchargement de Windows Server
> 2. 🖥️ [Configuration de VirtualBox](#2-configuration-de-virtualbox)
>    - Création de la VM
>    - Paramètres réseau
> 3. 🔩 [Installation de Windows Server](#3-installation-de-windows-server)
>    - Étapes d'installation
>    - Configuration initiale

---

## 🏑 Objectifs

À la fin de ce guide, vous aurez :
1. 🖥️ Une machine virtuelle VirtualBox fonctionnelle
2. 💻 Windows Server 2022 installé et configuré
3. 🔗 Un environnement prêt pour l'installation d'Active Directory

---

## 1. 🛠️ Prérequis

### 💾 Installation de VirtualBox

> ⚠️ **Important :** Si VirtualBox est déjà installé, passez à la section suivante

Telechargez VirtualBox sur le site officiel : https://www.virtualbox.org/wiki/Downloads et suivez les instructions d'installation.


1. ✅ Acceptez les termes de la licence lors de l'installation.


Note: dans certaines configurations on peut avoir de problèmes pendant l'installation des machines virtuelles Windows.
Source : https://askubuntu.com/questions/705720/virtualbox-kernel-driver-not-installed-error-despite-running-sbin-vboxconfig 

```bash  
sudo /usr/lib/virtualbox/vboxdrv.sh setup
```

Si la commande ne fonctionne pas, on doit installer gcc-12

### 💾 Téléchargement de Windows Server 2022

> ⚠️ **Important :** Si les images sont déjà téléchargées, passez à la section suivante
>
> 💡 **Pour débutants:** Même processus que dans le Chapitre 1, mais cette fois pour VirtualBox!

1. 🌐 Visitez le [Centre d'évaluation Microsoft](https://www.microsoft.com/en-us/evalcenter/download-windows-server-2022)
2. 💾 Téléchargez le fichier ISO de Windows Server 2022 (version d'évaluation 180 jours)
3. 📁 Enregistrez le fichier ISO dans un emplacement facilement accessible

## 2. 🖥️ Création de la Machine Virtuelle

### ⚙️ Configuration de Base

1. 🖥️ Ouvrez VirtualBox
2. ➕ Cliquez sur **Nouvelle**
3. ⚙️ Configurez les paramètres de base :
   - 🎮 Nom : `Serveur1`
      > 💡 **Tip:** M1 = Machine 1 (si vous créez plus tard M2, M3...)
   - 💾 Choisissez "VDI (Image disque VirtualBox)"
   - 📚 ISO Image (fichier Windows Server)
   - 💻 Type : Microsoft Windows
   - ⚠️ **Cochez Skip Unattended Installation**
   - 📊 Dans la section **Hardware** :
     - 💽 4096 Mo (4 Go) RAM
     - 🖥️ 2 processeurs
     - 💾 50 Go disque dur

   ✅ Appuyez sur Finish!

### ⚙️ Paramètres Additionnels

1. ⚙️ Sélectionnez la VM et cliquez sur "Paramètres"

2. 💻 Système :
   - 🖥️ Onglet Processeur : 2 processeurs minimum

3. 📺 Affichage :
   - 💽 Mémoire vidéo : 128 Mo
   - 🎮 Activer l'Accélération 3D

4. 🔗 Réseau :
   - 📶 Adaptateur 1 (par défaut): Changer **NAT** par **réseau interne**
   - Rajoutez un deuxième adaptateur de réseau (il faut éteindre la machine) et choisissez pont pour avoir accès à l'internet

5. 💾 Stockage :
   - 📚 Sélectionnez le lecteur optique
   - 💾 Choisissez l'ISO Windows Server
   - ✅ Cliquez sur "OK"

## 3. 💻 Installation de Windows Server 2022

1. 🔽 Démarrez la machine virtuelle

2. 💻 Configuration initiale :
   - 🇫🇷 Sélectionnez la langue (Français, clavier Belge)
   - ▶️ Cliquez sur **Installer maintenant**

3. 💻 Sélection de l'édition :
   - 🖥️ **Windows Server 2022 Standard (Expérience Desktop)**
   - ➡️ Cliquez sur "Suivant"

4. 📄 Acceptez les termes de la licence

5. ⚙️ Choisissez **"Personnalisé : Installer Windows uniquement (avancé)"**

6. 💾 Sélectionnez l'espace non alloué et cliquez sur **Suivant**

7. ⏳ Attendez que l'installation se termine

8. 🔐 Configuration administrateur :
   - 🔑 Mot de passe : **Password1!** (standard pour nos labos)
   - ⚠️ Notez ce mot de passe quelque part

9. 🔓 Attendez l'écran de login administrateur

10. ⌨️ Utilisez **Ctrl + Alt + Suppr** via la barre de menu de la fenêtre de la machine virtuelle dans VirtualBox (pas la barre de VirtualBox)

### ⚙️ Post-Installation

Configuration initiale requise :

- 🔄 Installation des mises à jour Windows
- 🔁 Redémarrage si nécessaire

### 💻 Console de Gestion

🖥️ Console de configuration des rôles et caractéristiques :

Nous travaillerons sur un sous-ensemble de cette structure de réseau:

> 📘 Schéma de l'infrastructure :

![Infrastructure](diagrams/images/structure_reseau_geographic_zones.png)

1. ⚙️ Configuration du nom :
   1. 🖥️ Ouvrez le **Gestionnaire de serveur** > **Serveur local**
   2. 💻 Sélectionnez le nom actuel
   3. ⚙️ Cliquez sur **Modifier**
   4. 🌐 Nom : **dns1**
   5. 🌐 Suffixe DNS : **maxtec.be**
      > 💡 **Pourquoi maxtec.be?** C'est notre entreprise fictive d'exemple
   6. ✅ Cliquez sur **OK**
   7. 🔄 Redémarrez le serveur



Le serveur aura maintenant le nom complet (FQDN) : `dns1.maxtec.be`

> 💻 **Note :** Vous pouvez aussi accéder au nom via **sysdm.cpl**



## 4. 💻 Machines Clientes Windows 10

### 🖥️ Vue d'ensemble

Nous devons créer des machines virtuelles clientes pour simuler notre environnement d'entreprise.

### 📁 Objectif des VM Clientes

Chaque département a des besoins spécifiques :
- La Comptabilité a besoin d'accéder aux logiciels financiers
- Les RH doivent gérer les dossiers du personnel
- Les Ventes utilisent des applications commerciales

> 💻 **Objectif :** Nous allons créer deux machines virtuelles Windows 10 pour simuler :

Supossons qu'on a deux départements pour le moment:

   - 💰 Comptabilité : accès aux dossiers financiers
   - 👥 RH : accès aux dossiers du personnel

Le but est de simuler qu'on a une machine pour chaque département. On peut créer autant de machines qu'on veut (bien qu'on ne pourra pas lancer toutes au même temps! :D)

### 💻 Installation de Windows 10

> ⚙️ Paramètres de la machine virtuelle :

- 🎮 Nom : `Client1`
- 💻 Génération : 2 (64 bits)
- 💽 Mémoire : 4 GB
- 📶 Adaptateur 1 (par défaut): Changer **NAT** par **réseau interne**
- Rajoutez un deuxième adaptateur de réseau et choisissez pont pour avoir accès à l'internet
- 💾 Disque : 30 GB
- 📚 ISO : Windows 10

1. 💻 Installation initiale :
   - 🇫🇷 Langue : Français (Belge)
   - 🖥️ Version : Windows 10 Pro
   - ⚙️ Mode : Installation personnalisée
   - 👤 Compte : **clark.kent** / **Password1!**

2. 🔄 Configuration :
   - 🔄 Mises à jour Windows
   - 🌐 Nom standardisé pour l'ordinateur

### 💻 Exercice 1 : Deuxième Machine Cliente

> ⚙️ Créez une nouvelle VM Windows 10 avec :

- 🎮 Nom VM : `Client2`
- 👤 Compte : **peter.parker** / **Password1!**
- 💽 Hardware identique à la première machine

### 🖥️ Exercice 2 : Serveur Secondaire

> ⚙️ Créez un nouveau serveur Windows Server 2022 :

- 🌐 Nom du serveur (FQDN) : `dns2.maxtec.be`
- 💻 Suivez la même procédure que pour le premier serveur

## 🎯 Checkpoint: Installation VirtualBox
Avant de continuer vers le prochain chapitre, vérifiez que vous avez:
- [ ] Installé Windows Server sur VirtualBox
- [ ] Configuré le nom de serveur (dns1.maxtec.be)
- [ ] Testé la connectivité réseau
- [ ] Créé au moins une machine cliente

---



### 🚀 Prochaine étape:
Vous êtes maintenant prêt(e) pour le **Chapitre 3: Configuration DNS**

## 🧭 Navigation
[⏮️ Chapitre Précédent: Introduction](Chapitre%201.Introduction%20et%20installation%20de%20Windows%20Server.md) | [🏠 Retour au Syllabus](../README.md) | [⏭️ Chapitre 3: DNS](Chapitre%203.DNS.md)

---

**📚 Cours Active Directory -  | 👨‍💻 Pour débutants**