# Chapitre 1: Introduction et installation de Windows Server

> 📚 **Dans ce chapitre:**
> 1. 🔗 [Les réseaux décentralisés VS centralisés](#1-les-réseaux-décentralisés-vs-centralisés-avec-active-directory)
>    - Avantages et inconvénients
> 2. 🖥️ [Qu'est-ce que c'est Active Directory?](#2-quest-ce-que-cest-active-directory)
>    - Composants principaux
>    - Fonctionnalités clés
> 3. 💻 [Windows Server](#2-windows-server)
>    - Machines virtuelles
>    - Installation et configuration

---

## 1. Les réseaux décentralisés VS centralisés avec Active Directory

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


---

## 2. Qu'est-ce que c'est Active Directory? 

🔑 Active Directory **arrange ce problème en centralisant** la gestion des utilisateurs et des ordinateurs:

> **Point clé:** Active Directory implique de stocker toutes les informations dans une seule base de données qui se trouvera sur un serveur (et non sur chaque ordinateur).

💻 **Active Directory** est une technologie de Microsoft qui fonctionne comme un "annuaire d'entreprise" numérique centralisant:

| Catégorie | Description | Exemples |
|------------|-------------|----------|
| 👤 **Utilisateurs** | Comptes du personnel | Employés, prestataires |
| 🖥️ **Ressources** | Matériel réseau | Serveurs, imprimantes |
| 🔑 **Permissions** | Droits d'accès | Lecture, écriture, connexion |
| 🛡️ **Sécurité** | Stratégies de protection | Politiques de mot de passe |

Tous ces aspects **peuvent être gérés depuis un seul endroit, le serveur Active Directory**.
**AD fonctionne sur Windows**. Nous allons l'utiliser concrètement sur **Windows Server**.


**Centraliser ou ne pas centraliser?**

Vous vous posez la question : "Est-ce une bonne idée de centraliser toute la gestion?"
Qu'est-ce que vous en pensez? Ne regardez pas la solution!

<details>
<summary>📘 Les avantages de la centralisation</summary>

### ✅ Les bénéfices clés

| Catégorie | Avantages |
|------------|------------|
| 💻 **Gestion Simplifiée** | • Administration centralisée<br>• Déploiement simultané<br>• Mises à jour automatisées |
| 🔐 **Sécurité Améliorée** | • Gestion centralisée des mots de passe<br>• Contrôle d'accès précis<br>• Traçabilité des actions |
| 💰 **Optimisation des Coûts** | • Réduction du temps de maintenance<br>• Moins de déplacements<br>• Optimisation des licences |
</details>

<details>
<summary>⚠️ Points d'attention et solutions</summary>

### 🔴 Risques Potentiels

| Risque | Impact | Solution |
|--------|---------|----------|
| 💥 **Panne Serveur** | • Arrêt total des services<br>• Paralysie de l'entreprise | • Serveur de secours<br>• Plan de continuité |
| 🦠 **Sécurité** | • Vulnérabilité centralisée<br>• Risque de propagation | • Protection renforcée<br>• Surveillance active |
| 🔗 **Dépendance Réseau** | • Besoin de connectivité<br>• Accès limité hors ligne | • Réseau redondant<br>• Cache local |

### 🔧 Stratégies de Mitégation

> 📘 **Plan de continuité:**
> - Serveur secondaire de backup
> - Sauvegardes régulières
> - Procédures d'urgence documentées
</details>



---

# 2. Windows Server 

> 📍 **Point de départ:** On a considéré que les avantages étaient plus importants que les risques ! Nous allons donc utiliser Active Directory.

### 🗓 Étapes d'installation

> Pour mettre en place Active Directory, nous suivrons un processus en trois phases. Chaque phase est essentielle pour assurer une installation réussie.

| 📆 Phase | ⚙️ Étape | 📘 Description |
|-------|--------|-------------|
| **1. Préparation** | 🖥 Configuration VM | Création et paramétrage de la machine virtuelle |
| | 💾 Installation Windows | Installation de Windows Server 2022 |
| **2. Configuration** | 🔑 Services AD DS | Déploiement d'Active Directory |
| | 🌐 Services DNS | Intégration avec le service DNS |
| **3. Finalisation** | ✅ Tests | Vérification de la configuration |

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

- Dans la barre de recherche de Windows, tapez **Activer ou désactiver des fonctionnalités Windows**
- Cliquez sur **Activer ou désactiver des fonctionnalités Windows**
- Cochez la case **Hyper-V** et cliquez sur **OK**
- Redémarrez Windows


### 2.2.3. Création des réseaux virtuels en Hyper-V

### 🔗 Configuration des réseaux virtuels

> 📌 **Prérequis:** Avant d'installer Windows Server, nous devons configurer deux réseaux virtuels distincts.

#### 🔌 Types de réseaux disponibles

| Type | Description | Utilisation |
|------|-------------|-------------|
| 🌐 **External** | Communication complète | Entre machines physiques et virtuelles |
| 🔒 **Internal** | Communication limitée | Entre hôte et ses VMs uniquement |
| 🔐 **Private** | Communication isolée | Entre VMs du même hôte uniquement |

#### 📶 Notre configuration

| Réseau | Type | Objectif |
|---------|------|----------|
| **LAN-VM** | Private | Communication interne entre VMs |
| **WAN-VM** | External | Accès à Internet |

#### 🔧 Création des réseaux

<details>
<summary>📶 Configuration du réseau LAN-VM (interne)</summary>

1. Ouvrez **Hyper-V Manager**
2. Accédez à `Virtual Switch Manager`
3. Sélectionnez `Private`
4. Cliquez sur `Create Virtual Switch`
5. Configurez :
   - Nom : **LAN-VM**
   - Type : Private network
6. Validez avec `OK`
</details>

<details>
<summary>🌐 Configuration du réseau WAN-VM (externe)</summary>

1. Dans `Virtual Switch Manager`
2. Sélectionnez `External`
3. Cliquez sur `Create Virtual Switch`
4. Configurez :
   - Nom : **WAN-VM**
   - Type : External network
   - Adaptateur : Votre connexion Internet (Ethernet/WiFi)
5. Validez et acceptez l'avertissement
</details>


### 💾 Téléchargement de Windows Server

> ⏰ **Version d'évaluation:** Cette version est valable pendant 180 jours, parfaite pour notre environnement d'apprentissage.

#### 📍 Prérequis

| Composant | Minimum requis |
|-----------|----------------|
| 💻 Processeur | 64-bit (compatible PAE/NX) |
| 📲 Mémoire RAM | 2 GB |
| 💾 Espace disque | 32 GB |
| 🔗 Réseau | 2 cartes réseau virtuelles |

#### 📦 Étapes de téléchargement

1. Accédez au [Centre d'évaluation Microsoft](https://www.microsoft.com/en-us/evalcenter/download-windows-server-2022)
2. Sélectionnez l'option **ISO** (nécessaire pour l'installation sur VM)
3. Choisissez la langue : **Français**
4. Conservez le fichier ISO téléchargé dans un emplacement facilement accessible

### ⚙️ Installation de Windows Server

> 🚨 **Important:** Assurez-vous d'avoir activé la virtualisation dans le BIOS de votre ordinateur.

#### 🖥 Création de la machine virtuelle

<details>
<summary>💻 Configuration matérielle</summary>

1. Dans Hyper-V Manager, sélectionnez `New` > `Virtual Machine`
2. Configurez les paramètres suivants :

| Paramètre | Valeur |
|------------|--------|
| Nom | **DC1** |
| Génération | Generation 2 |
| Mémoire | 2048 MB (dynamique) |
| Réseau | **LAN-VM** |
| Disque dur | 60 GB (dynamique) |
| Image | Votre fichier ISO Windows Server |
</details>

<details>
<summary>🔗 Configuration réseau</summary>

1. Ouvrez les paramètres de la VM
2. Ajoutez une deuxième carte réseau
3. Configurez les adaptateurs :
   - Adaptateur 1 : **LAN-VM** (réseau interne)
   - Adaptateur 2 : **WAN-VM** (accès Internet)
</details>

#### 💾 Installation du système

<details>
<summary>🔰 Installation de Windows Server</summary>

1. Démarrez la machine virtuelle
2. Sélectionnez :
   - Langue : **Français**
   - Format de temps : **Français**
   - Clavier : **Français**
3. Choisissez **Windows Server 2022 Standard (Desktop Experience)**
4. Acceptez la licence
5. Sélectionnez **Installation personnalisée**
6. Configurez le disque dur
</details>

> 📘 **Note:** L'installation prend environ 15-20 minutes. Profitez-en pour revoir les concepts d'Active Directory.

### 🔧 Configuration post-installation

> 💡 **Objectif:** Préparer le serveur pour le déploiement d'Active Directory.

#### 🔑 Configuration initiale

<details>
<summary>💻 Paramètres de base</summary>

1. Définissez le mot de passe administrateur
2. Connectez-vous avec le compte administrateur
3. Configurez les paramètres régionaux :
   - Région : **France**
   - Langue : **Français**
   - Clavier : **Français**
</details>

<details>
<summary>🌐 Configuration réseau</summary>

1. Ouvrez les `Paramètres réseau`
2. Configurez la carte **LAN-VM** :
   - IP : **192.168.0.1**
   - Masque : **255.255.255.0**
   - DNS : **127.0.0.1**
3. Configurez la carte **WAN-VM** :
   - DHCP activé (automatique)
</details>

#### 📍 Vérifications essentielles

<details>
<summary>✅ Liste de contrôle</summary>

| Vérification | Commande | Résultat attendu |
|--------------|----------|------------------|
| Nom du serveur | `hostname` | **DC1** |
| Connexion Internet | `ping 8.8.8.8` | Réponses reçues |
| Résolution DNS | `nslookup google.fr` | Adresse IP retournée |
</details>

> 🚨 **Important:** Assurez-vous que toutes les vérifications sont validées avant de continuer avec l'installation d'Active Directory.

### 🔧 Dépannage

> 💡 **Conseil:** La plupart des problèmes peuvent être résolus en vérifiant la configuration de base.

<details>
<summary>💻 Problèmes de virtualisation</summary>

| Problème | Solution |
|-----------|----------|
| ❌ VM ne démarre pas | Vérifiez l'activation de la virtualisation dans le BIOS |
| ❌ Génération 2 non disponible | Mettez à jour Hyper-V |
| ❌ ISO non reconnu | Vérifiez le format UEFI boot |
</details>

<details>
<summary>🌐 Problèmes réseau</summary>

| Symptôme | Vérification | Solution |
|-----------|--------------|----------|
| Pas d'Internet | `ping 8.8.8.8` | Vérifiez la configuration **WAN-VM** |
| Réseau local inactif | `ipconfig` | Contrôlez l'IP **192.168.0.1** |
| DNS non fonctionnel | `nslookup` | Vérifiez le paramètre **127.0.0.1** |
</details>

<details>
<summary>🔑 Problèmes système</summary>

| Message d'erreur | Action |
|-----------------|--------|
| Activation Windows | Normal en version évaluation |
| Mise à jour bloquée | Vérifiez **WAN-VM** et le pare-feu |
| Performance lente | Augmentez la RAM à 4 GB |
</details>

> ℹ️ **Note:** Si un problème persiste après ces vérifications, consultez la [documentation Microsoft](https://docs.microsoft.com/fr-fr/windows-server/troubleshoot/).
