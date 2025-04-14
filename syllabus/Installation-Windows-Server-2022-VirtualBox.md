
# 💻 Guide d'Installation : Windows Server 2022 sur VirtualBox

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

1. 💻 Ouvrez un terminal et mettez à jour la liste des paquets :
   ```bash
   sudo apt update
   ```

2. 📍 Installez VirtualBox et son Pack d'Extension :
   ```bash
   sudo apt install virtualbox virtualbox-ext-pack
   ```

3. ✅ Acceptez les termes de la licence lors de l'installation.

### 💾 Téléchargement de Windows Server 2022

> ⚠️ **Important :** Si les images sont déjà téléchargées, passez à la section suivante

1. 🌐 Visitez le [Centre d'évaluation Microsoft](https://www.microsoft.com/en-us/evalcenter/download-windows-server-2022)
2. 💾 Téléchargez le fichier ISO de Windows Server 2022 (version d'évaluation 180 jours)
3. 📁 Enregistrez le fichier ISO dans un emplacement facilement accessible

## 2. 🖥️ Création de la Machine Virtuelle

### ⚙️ Configuration de Base

1. 🖥️ Ouvrez VirtualBox
2. ➕ Cliquez sur **Nouvelle**
3. ⚙️ Configurez les paramètres de base :
   - 🎮 Nom : `WindowsServerM1`
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
   - 📶 Adaptateur : Changer **NAT** par **réseau interne**
   - Si besoin de l'internet dans votre laboratoire, vous pouvez ajouter un adaptateur NAT ou un pont (selon les circomstances)

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
   - 🔑 Mot de passe : **Password1!** (labos uniquement)
   - ⚠️ Sauvegardez ce mot de passe

9. 🔓 Attendez l'écran de login administrateur

10. ⌨️ Utilisez **Ctrl + Alt + Suppr** via le menu

### ⚙️ Post-Installation

Configuration initiale requise :

- 🔄 Installation des mises à jour Windows
- 🔁 Redémarrage si nécessaire

### 💻 Console de Gestion

🖥️ Console de configuration des rôles et caractéristiques :

1. 🕬️ Ouvrez le **Gestionnaire du Serveur**

2. ⚙️ Configuration du serveur :
   - 🌐 Nom : `dns1.computerelectronics.be`

> 📘 Schéma de l'infrastructure :

![Infrastructure](../diagrams/images/structure_reseau_geographic_zones.png)

3. ⚙️ Configuration du nom :
   1. 🖥️ Ouvrez le **Gestionnaire de serveur** > **Serveur local**
   2. 💻 Sélectionnez le nom actuel
   3. ⚙️ Cliquez sur **Modifier**
   4. 🌐 Nom : **dns1**
   5. 🌐 Suffixe DNS : **computerelectronics.be**
   6. ✅ Cliquez sur **OK**
   7. 🔄 Redémarrez le serveur

Le serveur aura maintenant le nom complet (FQDN) : `dns1.computerelectronics.be`

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

1. 🏢 **Postes de travail départementaux**
   - 💰 Comptabilité : accès aux dossiers financiers
   - 👥 RH : accès aux dossiers du personnel

2. 🔐 **Sécurité personnalisée**
   - 📂 Accès aux ressources spécifiques
   - 🔒 Restrictions appropriées

3. 🔗 **Environnement de test**
   - 🏢 Mini-réseau d'entreprise
   - ⚙️ Tests sans risque
   - 📝 Configurations multiples

### 💻 Installation de Windows 10

> ⚙️ Paramètres de la machine virtuelle :

- 🎮 Nom : `Windows10M1`
- 💻 Génération : 2 (64 bits)
- 💽 Mémoire : 4 GB
- 📶 Adaptateur : Changer **NAT** par **réseau interne**
- Si besoin de l'internet dans votre laboratoire, vous pouvez ajouter un adaptateur NAT ou un pont (selon les circomstances)
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

- 🎮 Nom VM : `Windows10M2`
- 👤 Compte : **peter.parker** / **Password1!**
- 💽 Hardware identique à la première machine

### 🖥️ Exercice 2 : Serveur Secondaire

> ⚙️ Créez un nouveau serveur Windows Server 2022 :

- 🌐 FQDN : `dns2.computerelectronics.be`
- 💻 Suivez la même procédure que pour le premier serveur


## Annexe: configuration pour permettre une connexion locale au serveur

Cette section concerne la configuration du droit "Se connecter localement" (uniquement pour tester les delegations dans le chapitre 4)

## Description

Le paramètre "Permettre l'ouverture d'une session locale" contrôle quels utilisateurs ou groupes peuvent se connecter physiquement à un ordinateur du domaine.

Pour modifier ce comportement on doit créer une stratégie de groupe (GPO) et l'appliquer à l'OU appropriée.

1. Ouvrir `gpmc.msc`
2. Créer une nouvelle GPO ou modifier une existante
3. Naviguer vers : **Configuration ordinateur > Paramètres Windows > Paramètres de sécurité > Stratégies locales > Attribution des droits utilisateur**
4. Double-cliquer sur **"Permettre l'ouverture d'une session locale"**
5. Ajouter les utilisateurs ou groupes nécessaires
6. Lier la GPO à l'OU appropriée

## Groupes par défaut ayant ce droit
- Administrateurs
- ENTERPRISE DOMAIN CONTROLLERS
- Opérateurs de compte
- Opérateurs d'impression
- Opérateurs de sauvegarde
- Opérateurs de serveur

## Vérification
Pour vérifier l'application des paramètres :
1. Exécuter : `gpupdate /force`
2. Vérifier avec : `gpresult /r` ou `rsop.msc`

## Note importante
La modification de ce paramètre peut affecter la compatibilité avec les clients, les services et les applications. Assurez-vous de tester les changements dans un environnement contrôlé avant de les appliquer en production.
