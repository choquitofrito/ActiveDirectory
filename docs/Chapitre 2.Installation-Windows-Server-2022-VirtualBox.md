# Chapitre 2: Installation de Windows Server sur VirtualBox

## Navigation du cours
[Chapitre précédent : Introduction](Chapitre%201.Introduction%20et%20installation%20de%20Windows%20Server.md) | [Retour au Syllabus](index.md) | [Chapitre suivant : DNS](Chapitre%203.DNS.md)

!!! info "Alternative au Chapitre 1"
    Ce chapitre fait la même chose que le [Chapitre 1 §3.2](Chapitre%201.Introduction%20et%20installation%20de%20Windows%20Server.md) (Hyper-V), mais avec **VirtualBox** (Linux, macOS, Windows Famille). Suivez l'un **ou** l'autre, pas les deux.

    Parcours le plus court : le [Guide rapide (Annexe 1)](Labo%20Annexe%201-Guide%20de%20base%20installation%20AD-DS.md), qui va de la VM jusqu'au poste client joint au domaine. Les valeurs officielles du lab sont dans la [Référence du lab Maxtec](Labo%20et%20Exercices/Labo/Reference_Lab_Maxtec.md).

!!! info "Dans ce guide"
    1. [Prérequis](#1-prerequis) : installation de VirtualBox, téléchargement de Windows Server
    2. [Création de la machine virtuelle](#2-creation-de-la-machine-virtuelle) : VM et réseau
    3. [Installation de Windows Server](#3-installation-de-windows-server) : installation et configuration initiale
    4. [Postes clients Windows 11](#4-postes-clients-windows-11)

---

## Objectifs

À la fin de ce guide, vous avez :

1. Une machine virtuelle VirtualBox avec Windows Server 2025 (2022 accepté), nommée `dns1`, IP `192.168.0.2`
2. Une VM cliente Windows 11 Pro (`ws-IT-01`) sur le même réseau interne
3. Un environnement prêt pour l'installation d'Active Directory

---

## 1. Prérequis

### Installation de VirtualBox

Si VirtualBox 7 est déjà installé, passez à la section suivante.

Téléchargez VirtualBox (version 7.x) sur le site officiel : <https://www.virtualbox.org/wiki/Downloads> et suivez les instructions d'installation.

!!! warning "Problème potentiel sur Linux"

    Sur certaines distributions, le module noyau de VirtualBox n'est pas chargé et les VMs refusent de démarrer (« Kernel driver not installed »). Reconstruisez le module :

    ```bash
    sudo /sbin/vboxconfig
    ```

    Si la commande échoue, installez d'abord les en-têtes du noyau et le compilateur (`linux-headers-$(uname -r)`, `gcc`, `make`), puis relancez-la. Si le démarrage sécurisé (Secure Boot) est actif sur l'hôte, le module doit être signé. Référence : <https://askubuntu.com/questions/705720/virtualbox-kernel-driver-not-installed-error-despite-running-sbin-vboxconfig>

### Téléchargement de Windows Server

Si l'ISO est déjà téléchargée, passez à la section suivante.

1. Visitez le [Centre d'évaluation Microsoft](https://www.microsoft.com/fr-fr/evalcenter/download-windows-server-2025)
2. Téléchargez l'ISO de Windows Server 2025 (évaluation 180 jours), en français
3. Enregistrez le fichier dans un emplacement facilement accessible

Pour le client, téléchargez l'ISO de Windows 11 sur <https://www.microsoft.com/fr-fr/software-download/windows11> (l'édition Professionnel se choisit pendant l'installation).

## 2. Création de la machine virtuelle

### Configuration de base

1. **Ouvrez VirtualBox** et cliquez sur **Nouvelle**
2. Configurez :

    | Paramètre | Valeur |
    |-----------|--------|
    | **Nom** | `dns1` (étiquette de la VM ; le nom Windows se règle après l'installation) |
    | **Image ISO** | Fichier Windows Server |
    | **Type / Version** | Microsoft Windows / Windows Server 2025 (64-bit) ou 2022 |
    | **Installation** | Cochez **Skip Unattended Installation** (installation manuelle) |

3. Matériel :

    | Composant | Spécification |
    |-----------|---------------|
    | **RAM** | 4096 Mo |
    | **Processeurs** | 2 |
    | **Disque dur** | 50 Go, VDI, alloué dynamiquement |

4. Cliquez sur **Finish**

### Paramètres additionnels

VM éteinte, sélectionnez-la et cliquez sur **Paramètres** :

1. **Affichage** : mémoire vidéo 128 Mo
2. **Réseau** : Adaptateur 1, remplacez **NAT** par **Réseau interne** (nom par défaut : `intnet`). Toutes les VMs du lab doivent utiliser **le même nom** de réseau interne.

!!! warning "Une seule carte réseau sur le DC"
    Ne gardez qu'un adaptateur, en réseau interne. Un DC avec deux cartes (LAN + NAT/pont) enregistre ses deux adresses dans DNS et les clients tombent au hasard sur la mauvaise.

    Besoin d'Internet ponctuellement (mises à jour, téléchargement) ? Activez un **Adaptateur 2 en NAT** le temps de l'opération, puis désactivez-le.

## 3. Installation de Windows Server

1. **Démarrez la machine virtuelle** (appuyez sur une touche pour démarrer sur l'ISO si demandé)
2. **Langue et clavier** : Français, clavier Belge (point) ou celui de votre ordinateur
3. **Édition** : **Windows Server 2025 Standard Evaluation (Expérience de bureau)**

    !!! tip "Pourquoi « Expérience de bureau » ?"
        L'option sans cette mention installe Server Core (sans interface graphique).

4. Acceptez les termes de la licence
5. Choisissez l'installation **Personnalisée**
6. Sélectionnez l'espace non alloué et lancez l'installation
7. **Mot de passe administrateur** : `Password1!`

    !!! warning "Mot de passe de lab"
        Acceptable dans un lab isolé. En production, jamais de mot de passe partagé ni prévisible pour un compte administrateur.

8. À l'écran de connexion, envoyez **Ctrl+Alt+Suppr** via le menu de la fenêtre de la VM (**Entrée > Clavier > Insérer Ctrl-Alt-Suppr**, ou `Host+Suppr`)

### Post-installation

Nous travaillerons sur un sous-ensemble de cette infrastructure :

![Infrastructure](diagrams/images/structure_reseau_geographic_zones.png)

**Nom du serveur**

1. **Gestionnaire de serveur** > **Serveur local** > cliquez sur le nom actuel (`WIN-XXXXXXX`)
2. **Modifier** :
    - Nom de l'ordinateur : `dns1`
    - **Autres...** → Suffixe DNS principal : `maxtec.be` (le domaine de notre entreprise fictive)
3. **OK** → redémarrez le serveur

Le serveur a maintenant le nom complet (FQDN) `dns1.maxtec.be`. La même fenêtre s'ouvre aussi avec `sysdm.cpl`.

**Adresse IP**

1. `ncpa.cpl` → clic droit sur la carte → **Propriétés** → **Protocole Internet version 4 (TCP/IPv4)**
2. Configurez :

    | Paramètre | Valeur |
    |-----------|--------|
    | Adresse IP | `192.168.0.2` |
    | Masque | `255.255.255.0` |
    | Passerelle | *(vide)* |
    | Serveur DNS préféré | `192.168.0.2` |

**Vérification** : `hostname` renvoie `dns1`, et `ipconfig /all` montre `192.168.0.2` comme adresse et comme serveur DNS.

!!! tip "Suite"
    Le serveur est prêt pour la promotion en contrôleur de domaine : [Chapitre 4](Chapitre%204.Active%20Directory%20Domain%20Services%20(AD%20DS).md) ou [Annexe 1, Partie A](Labo%20Annexe%201-Guide%20de%20base%20installation%20AD-DS.md#partie-a-installation-du-serveur-ad-ds).

## 4. Postes clients Windows 11

### Vue d'ensemble

Les postes clients simulent les ordinateurs des employés. Dans le lab, un poste par département testé :

| VM | Nom Windows | IP | Département |
|----|-------------|----|-------------|
| Client 1 | `ws-IT-01` | `192.168.0.10` | IT |
| Client 2 (optionnel) | `ws-RH-01` | `192.168.0.11` | RH |

Vous pouvez créer d'autres postes, mais la RAM de votre ordinateur limite le nombre de VMs allumées en même temps.

### Création de la VM Windows 11

!!! info "TPM et démarrage sécurisé"
    Windows 11 exige TPM 2.0 et le démarrage sécurisé (UEFI). VirtualBox 7 les émule : choisissez **Version : Windows 11 (64-bit)** et VirtualBox active EFI, Secure Boot et TPM 2.0 automatiquement (vérifiable dans **Paramètres > Système**).

| Paramètre | Valeur |
|-----------|--------|
| **Nom de la VM** | `ws-IT-01` |
| **Type / Version** | Microsoft Windows / Windows 11 (64-bit) |
| **Mémoire** | 4096 Mo |
| **Processeurs** | 2 |
| **Réseau** | Adaptateur 1 : **Réseau interne** (même nom que le serveur) |
| **Disque** | 64 Go (minimum exigé par Windows 11) |
| **ISO** | Windows 11 |

**Installation**

1. Langue : Français (Belgique)
2. Édition : **Windows 11 Professionnel** (l'édition Famille ne peut pas rejoindre un domaine)
3. Installation personnalisée
4. Compte local : sans Internet, l'assistant propose de configurer l'appareil pour le travail ; choisissez **Options de connexion > Joindre un domaine à la place** pour créer un compte local (`admin-local` / `Password1!`). Si l'option n'apparaît pas dans votre version, recommencez la création de la VM **sans** cocher *Skip Unattended Installation* : l'installation automatique de VirtualBox crée le compte local pour vous.

**Configuration** : nom `ws-IT-01`, IP `192.168.0.10`, DNS `192.168.0.2`, puis jonction au domaine : voir [Annexe 1, Partie B](Labo%20Annexe%201-Guide%20de%20base%20installation%20AD-DS.md#partie-b-joindre-un-poste-client-au-domaine), une fois le contrôleur de domaine promu.

### Exercice 1 : deuxième poste client (optionnel)

Créez une deuxième VM Windows 11 Pro :

- Nom : `ws-RH-01`
- IP : `192.168.0.11`, DNS `192.168.0.2`
- Matériel identique au premier poste

### Exercice 2 : serveur secondaire (optionnel, hors labs)

Pour aller plus loin, vous pouvez installer un deuxième Windows Server, `dns2.maxtec.be` (`192.168.0.3`), avec la même procédure. Les labs du cours n'utilisent qu'un seul contrôleur de domaine.


### Prochaine étape
[Chapitre 3 : DNS](Chapitre%203.DNS.md)

## Navigation
[Chapitre précédent : Introduction](Chapitre%201.Introduction%20et%20installation%20de%20Windows%20Server.md) | [Retour au Syllabus](index.md) | [Chapitre 3 : DNS](Chapitre%203.DNS.md)
