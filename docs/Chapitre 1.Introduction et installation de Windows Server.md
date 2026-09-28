# Chapitre 1: Introduction et installation de Windows Server

!!! abstract "Objectifs"
    À la fin de ce chapitre, vous savez :

    - expliquer en trois points pourquoi une gestion centralisée (Active Directory) remplace la gestion poste par poste ;
    - préparer la VM Windows Server 2022 du cours sous **VirtualBox** ([Chapitre 2](Chapitre%202.Installation-Windows-Server-2022-VirtualBox.md)), avec **une seule** carte réseau sur le réseau interne ;
    - renommer le serveur en `dns1` (suffixe `maxtec.be`) et lui donner l'IP fixe `192.168.0.2` ;
    - vérifier avec `hostname` et `ipconfig /all` que le serveur est prêt pour la promotion en contrôleur de domaine.

## 1. Les réseaux décentralisés VS centralisés

Imaginez que **vous êtes le responsable informatique d'un magasin d'électronique** de l'entreprise **Maxtec** (maxtec.be).
Vous avez actuellement 10 ordinateurs, 2 imprimantes et 2 serveurs (pour la base de données et pour la messagerie).

Vous **devez gérer chaque ordinateur individuellement**, en vous assurant que chaque utilisateur a le bon mot de passe, que chaque imprimante est configurée correctement, que chaque serveur est mis à jour, etc.

Vous **allez vite vous trouver en difficulté**. Pourquoi ?

??? question "Réfléchissez, puis cliquez pour voir la réponse"

    **Problèmes de la gestion décentralisée :**

    - **Départs d'employés** : difficile de s'assurer que le compte est supprimé sur tous les ordinateurs et serveurs
    - **Nouvelles imprimantes** : configuration manuelle sur chaque ordinateur (risque d'oubli)
    - **Serveurs de stockage** : refaire le mappage des lecteurs sur chaque ordinateur
    - **Mots de passe** : chaque utilisateur doit se souvenir de multiples comptes
    - **Mises à jour** : installation manuelle sur chaque poste

## Checkpoint : avez-vous compris le problème ?

!!! info "Vérification de compréhension"

    Avant de continuer, assurez-vous de pouvoir :

    - [ ] Expliquer pourquoi la gestion décentralisée pose problème
    - [ ] Donner 3 exemples concrets de difficultés
    - [ ] Estimer l'impact sur une entreprise de 50+ employés


---

## 2. Qu'est-ce que c'est Active Directory ?

Active Directory **résout ce problème en centralisant** la gestion des utilisateurs et des ordinateurs.

!!! note "Et Microsoft Entra ID (ex-Azure AD) ?"
    Entra ID est le service d'identité cloud de Microsoft (Microsoft 365, applications SaaS). Ce n'est pas une nouvelle version d'Active Directory : les deux coexistent souvent en entreprise, et AD reste la base pour les postes, serveurs et GPO sur site. Entra ID n'est pas couvert dans ce cours.

!!! tip "Point clé"

    Active Directory stocke toutes les informations dans une seule base de données, sur un serveur (et non sur chaque ordinateur).

**Active Directory** est une technologie de Microsoft qui fonctionne comme un "annuaire d'entreprise" centralisant :

| Catégorie | Description | Exemples |
|------------|-------------|----------|
| **Utilisateurs** | Comptes du personnel | Employés, prestataires |
| **Ressources** | Matériel réseau | Serveurs, imprimantes |
| **Permissions** | Droits d'accès | Lecture, écriture, connexion |
| **Sécurité** | Stratégies de protection | Politiques de mot de passe |

Tous ces aspects **peuvent être gérés depuis un seul endroit, le serveur Active Directory** (le contrôleur de domaine).
**AD fonctionne sur Windows Server**, que nous allons installer dans ce chapitre.


## Réflexion : centraliser ou ne pas centraliser ?

!!! question "Question"

    **"Est-ce une bonne idée de centraliser toute la gestion sur (éventuellement) un seul serveur ?"**

    Réfléchissez 2 minutes avant de regarder la réponse :

    - Quels seraient les **avantages** ?
    - Quels seraient les **risques** ?
    - Comment **minimiser** les risques ?

??? success "Les avantages de la centralisation"

    | Catégorie | Avantages |
    |------------|------------|
    | **Gestion simplifiée** | • Administration centralisée<br>• Déploiement simultané (ex : installer un même logiciel sur plusieurs machines)<br>• Mises à jour automatisées sur plusieurs machines |
    | **Sécurité améliorée** | • Gestion centralisée des mots de passe (tous dans la même base)<br>• Contrôle d'accès précis<br>• Traçabilité des actions |
    | **Optimisation des coûts** | • Réduction du temps de maintenance<br>• Moins de déplacements<br>• Optimisation des licences |

??? warning "Risques et solutions"

    | Risque | Impact | Solution |
    |--------|---------|----------|
    | **Panne serveur** | • Plus d'authentification<br>• Paralysie de l'entreprise | • Au moins deux contrôleurs de domaine<br>• Plan de continuité |
    | **Sécurité** | • Cible unique et très précieuse pour un attaquant | • Protection renforcée du DC<br>• Surveillance active |
    | **Dépendance réseau** | • Besoin de connectivité<br>• Accès limité hors ligne | • Réseau redondant<br>• Cache local des identifiants |

    **Plan de continuité minimal :**

    - Deuxième contrôleur de domaine (réplication automatique)
    - Sauvegardes régulières
    - Procédures d'urgence documentées


---

## 3. Windows Server

!!! success "Point de départ"

    Les avantages l'emportent sur les risques : nous allons donc utiliser Active Directory.

### Étapes d'installation

| Phase | Étape | Description |
|-------|--------|-------------|
| **1. Préparation** | Configuration VM | Création et paramétrage de la machine virtuelle |
| | Installation Windows | Installation de Windows Server 2022 |
| **2. Configuration** | Services AD DS | Déploiement d'Active Directory (Chapitre 4) |
| **3. Finalisation** | Tests | Vérification de la configuration |

**Active Directory (AD)** est un ensemble de services qui a besoin d'être installé sur **Windows Server**.

**Windows Server est un système d'exploitation** conçu pour les serveurs d'entreprise. Il offre :

- Des fonctionnalités de **gestion de réseau**
  _Exemple : attribuer une IP fixe au serveur._

- La possibilité d'installer des **services d'entreprise comme Active Directory**
  _Exemple : créer un domaine pour centraliser la connexion des utilisateurs._

- Une **sécurité renforcée** adaptée aux environnements professionnels
  _Exemple : forcer des mots de passe complexes._

- Des **outils d'administration centralisés**
  _Exemple : gérer tous les serveurs depuis une console._

- La possibilité de **gérer les ressources de nombreux utilisateurs** et connexions simultanées
  _Exemple : partager des dossiers à plusieurs utilisateurs en même temps._

!!! info "Versions utilisées dans ce cours"
    - **Serveur** : Windows Server 2022 (ISO fournie en cours, ou ISO d'évaluation 180 jours). La version actuelle est Windows Server 2025 ; tout le cours fonctionne sur 2022.
    - **Client** : Windows 10 Professionnel.

    Toutes les valeurs du lab (noms, IP, OUs, groupes) sont dans la [Référence du lab Maxtec](Labo%20et%20Exercices/Labo/Reference_Lab_Maxtec.md).


### 3.1. Pourquoi des machines virtuelles ?

Nos expériences ne doivent pas modifier la configuration de notre ordinateur, et nous devons **pouvoir facilement revenir à une configuration de départ** en cas d'erreur. D'où les machines virtuelles :

- **Chaque machine virtuelle est indépendante** des autres et de l'ordinateur physique. Exemple : une VM Windows Server et une VM Windows 10 sur le même portable.
- On peut **modifier la configuration d'une VM sans risque** pour l'ordinateur physique.
- On peut **prendre un instantané (snapshot)** avant une étape risquée, ou **supprimer une VM et en recréer une**.


### 3.2. Installation pour le cours : VirtualBox

En cours, toutes les VMs tournent sous **VirtualBox**. L'installation pas à pas est au [Chapitre 2](Chapitre%202.Installation-Windows-Server-2022-VirtualBox.md) ; le [Guide rapide (Annexe 1)](Labo%20Annexe%201-Guide%20de%20base%20installation%20AD-DS.md) reprend les mêmes étapes sans la théorie, de la VM jusqu'au poste client joint au domaine.

### 3.3. Option à la maison : installation avec Hyper-V

!!! warning "Hors cours"
    Cette section ne sert **que** si vous voulez refaire le lab chez vous avec Hyper-V (hôte Windows 10/11 Pro ou Entreprise). En cours, on utilise VirtualBox (§3.2). Ne mélangez pas les deux pour un même lab.

    Activer Hyper-V sur un PC où vous utilisez aussi VirtualBox peut fortement ralentir VirtualBox : si vous voulez garder VirtualBox chez vous, n'activez pas Hyper-V.

### 3.3.1. Activation de Hyper-V dans Windows

- Dans la barre de recherche de Windows, tapez **Activer ou désactiver des fonctionnalités Windows**
- Cochez la case **Hyper-V** et cliquez sur **OK**
- Redémarrez Windows


### 3.3.2. Création du réseau virtuel

Hyper-V propose trois types de commutateurs virtuels :

| Type | Description | Utilisation |
|------|-------------|-------------|
| **External** | Communication complète | Entre machines physiques et virtuelles, accès Internet |
| **Internal** | Communication limitée | Entre l'hôte et ses VMs uniquement |
| **Private** | Communication isolée | Entre VMs du même hôte uniquement |

Pour le lab, **un seul réseau** suffit :

| Réseau | Type | Objectif |
|---------|------|----------|
| **LAN-VM** | Private | Réseau du lab `192.168.0.0/24` (DC + postes clients) |

!!! info "Créer le réseau LAN-VM"

    1. Ouvrez **Hyper-V Manager**
    2. Accédez à **Virtual Switch Manager** (Gestionnaire de commutateur virtuel)
    3. Sélectionnez **Private** puis **Create Virtual Switch**
    4. Nom : **LAN-VM**
    5. Validez avec **OK**

!!! warning "Une seule carte réseau sur le DC"
    Le futur contrôleur de domaine n'a qu'une carte, sur `LAN-VM`. Un DC avec deux cartes (LAN + Internet) enregistre ses deux adresses dans DNS et les clients tombent au hasard sur la mauvaise.

    Besoin d'Internet ponctuellement (mises à jour, téléchargement) ? Ajoutez une deuxième carte connectée au **Default Switch** (NAT fourni par Hyper-V) le temps de l'opération, puis retirez-la.


### 3.3.3. Téléchargement de Windows Server

La version d'évaluation est valable 180 jours, ce qui couvre largement le cours.

| Composant | Minimum requis | Recommandé pour le lab |
|-----------|----------------|------------------------|
| Processeur | 64 bits, virtualisation activée dans le BIOS/UEFI | 2 vCPU |
| Mémoire RAM | 2 GB | 4 GB |
| Espace disque | 32 GB | 50 GB (dynamique) |
| Réseau | 1 carte réseau | 1 carte sur **LAN-VM** |

1. Accédez au [Centre d'évaluation Microsoft](https://www.microsoft.com/fr-fr/evalcenter/download-windows-server-2022)
2. Sélectionnez l'option **ISO**
3. Choisissez la langue : **Français**
4. Conservez le fichier ISO dans un emplacement facilement accessible

### 3.3.4. Création de la machine virtuelle

!!! warning "Prérequis"

    La virtualisation doit être activée dans le BIOS/UEFI de votre ordinateur.

1. Dans Hyper-V Manager, sélectionnez **New** > **Virtual Machine**
2. Configurez les paramètres suivants :

    | Paramètre | Valeur |
    |------------|--------|
    | Nom de la VM | **dns1** (le nom de la VM dans Hyper-V n'est qu'une étiquette ; le nom Windows se règle après l'installation) |
    | Génération | Generation 2 |
    | Mémoire | 4096 MB (dynamique possible) |
    | Réseau | **LAN-VM** |
    | Disque dur | 50 GB (dynamique) |
    | Image | Votre fichier ISO Windows Server |

!!! tip "Et le poste client Windows 10 ?"
    Même procédure dans Hyper-V, avec l'ISO de Windows 10 Professionnel. La création et la jonction du client sont décrites dans l'[Annexe 1, Partie B](Labo%20Annexe%201-Guide%20de%20base%20installation%20AD-DS.md#partie-b-joindre-un-poste-client-au-domaine).

### 3.3.5. Installation du système

1. Démarrez la machine virtuelle (appuyez sur une touche pour démarrer sur l'ISO)
2. Sélectionnez :
    - Langue : **Français**
    - Format de l'heure : **Français (Belgique)**
    - Clavier : **Belge (point)** ou celui de votre ordinateur
3. Choisissez **Windows Server 2022 Standard Evaluation (Expérience de bureau)**

    !!! tip "Pourquoi « Expérience de bureau » ?"
        L'option sans cette mention installe Server Core (sans interface graphique). En production, Core est souvent préférable ; pour apprendre, l'interface graphique est plus pratique.

4. Acceptez la licence
5. Choisissez l'installation **Personnalisée** (pas « Mise à niveau », nous partons de zéro)
6. Sélectionnez le disque et lancez l'installation

L'installation prend environ 15-20 minutes.

### 3.3.6. Configuration post-installation

**Compte administrateur**

1. Définissez le mot de passe administrateur : **Password1!**

    !!! warning "Mot de passe de lab"
        `Password1!` est acceptable dans un lab isolé. En production, jamais de mot de passe partagé ni prévisible pour un compte administrateur.

2. Connectez-vous avec le compte **Administrateur** (Hyper-V : menu **Action > Ctrl+Alt+Suppr**)

**Nom du serveur**

La VM s'appelle `dns1` dans Hyper-V, mais Windows lui a donné un nom aléatoire (`WIN-XXXXXXX`). Renommez-le :

1. **Gestionnaire de serveur** > **Serveur local** > cliquez sur le nom actuel
2. **Modifier** :
    - Nom de l'ordinateur : `dns1`
    - **Autres...** → Suffixe DNS principal : `maxtec.be`
3. **OK** → redémarrez

Le nom complet (FQDN) du serveur est maintenant `dns1.maxtec.be`.

**Adresse IP**

1. `ncpa.cpl` → clic droit sur la carte réseau → **Propriétés** → **Protocole Internet version 4 (TCP/IPv4)**
2. Configurez :

    | Paramètre | Valeur |
    |-----------|--------|
    | Adresse IP | `192.168.0.2` |
    | Masque | `255.255.255.0` |
    | Passerelle | *(vide)* |
    | Serveur DNS préféré | `192.168.0.2` (le serveur lui-même, il hébergera le DNS) |

3. **OK** → **OK**

### 3.3.7. Vérifications

Ouvrez une invite de commandes (Win+R → `cmd`) :

| Vérification | Commande | Résultat attendu |
|--------------|----------|------------------|
| Nom du serveur | `hostname` | `dns1` |
| Adresse IP et DNS | `ipconfig /all` | IPv4 `192.168.0.2`, Serveurs DNS `192.168.0.2`, Suffixe DNS principal `maxtec.be` |
| Une seule carte | Win+R → `ncpa.cpl` | Une seule carte réseau listée (en PowerShell, chapitre 9 : `Get-NetAdapter`) |

!!! note "Et la résolution DNS ?"
    À ce stade, aucun serveur DNS n'existe encore : `nslookup` échouera, c'est attendu. Le rôle DNS est installé lors de la promotion en contrôleur de domaine (Chapitre 4), et vous vérifierez la résolution à ce moment-là (`nslookup dns1.maxtec.be`, puis Chapitre 5).

### 3.3.8. Dépannage

**Virtualisation**

| Problème | Solution |
|-----------|----------|
| La VM ne démarre pas | Vérifiez l'activation de la virtualisation dans le BIOS/UEFI |
| « No operating system was loaded » | Redémarrez la VM et appuyez sur une touche dès l'invite « Press any key to boot from CD or DVD » |
| ISO non reconnu en génération 2 | Vérifiez que le démarrage sécurisé utilise le modèle **Microsoft Windows** |

**Réseau**

| Symptôme | Vérification | Solution |
|-----------|--------------|----------|
| Pas d'Internet | — | Normal : `LAN-VM` est privé. Ajoutez temporairement une carte sur **Default Switch** |
| Réseau local inactif | `ipconfig` | Contrôlez l'IP **192.168.0.2** et le masque |
| Le client ne joint pas le serveur | `ping 192.168.0.2` depuis le client | Vérifiez que les deux VMs sont sur **LAN-VM** |

**Système**

| Message | Action |
|-----------------|--------|
| Windows non activé | Normal en version d'évaluation |
| Mises à jour impossibles | Pas d'Internet sur `LAN-VM` : voir ci-dessus |
| Lenteur | Augmentez la RAM à 4 GB ou plus |

Si un problème persiste, consultez la [documentation Microsoft](https://learn.microsoft.com/fr-fr/troubleshoot/windows-server/).

### Prochaine étape

En cours : passez au [Chapitre 2](Chapitre%202.Installation-Windows-Server-2022-VirtualBox.md) pour installer les VMs sous VirtualBox.

À la maison avec Hyper-V (§3.3) : votre serveur est prêt, passez au [Chapitre 3 : DNS](Chapitre%203.DNS.md). Pour le poste client, suivez le Chapitre 2 §4 en adaptant la création de la VM à Hyper-V.

## Navigation
[Retour au Syllabus](index.md) | [Chapitre 2 : installation (VirtualBox)](Chapitre%202.Installation-Windows-Server-2022-VirtualBox.md) | [Chapitre 3 : DNS](Chapitre%203.DNS.md)
