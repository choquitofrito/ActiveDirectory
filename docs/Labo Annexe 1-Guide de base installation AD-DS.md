# Guide de base: Installation AD-DS et Jonction au Domaine

Ce guide couvre deux opérations distinctes:

- **[Partie A](#partie-a-installation-du-serveur-ad-ds)** - Préparer et promouvoir le serveur en contrôleur de domaine
- **[Partie B](#partie-b-joindre-un-poste-client-au-domaine)** - Configurer et joindre un poste client au domaine

Valeurs officielles du lab (noms, IP, versions) : [Référence du lab Maxtec](Labo%20et%20Exercices/Labo/Reference_Lab_Maxtec.md). Serveur recommandé : Windows Server 2025 (2022 accepté). Client : Windows 11 Professionnel.

---

## Partie A: Installation du Serveur AD-DS

### A1. Créer la VM Windows Server

Créez une machine virtuelle Windows Server 2025 (ou 2022) dans VirtualBox ou Hyper-V, édition **Standard (Expérience de bureau)**, mot de passe administrateur `Password1!`. Détails : [Chapitre 2](Chapitre%202.Installation-Windows-Server-2022-VirtualBox.md) (VirtualBox) ou [Chapitre 1](Chapitre%201.Introduction%20et%20installation%20de%20Windows%20Server.md) (Hyper-V).

!!! warning "Réseau"
    **Une seule** carte réseau, en **Réseau interne** (VirtualBox) ou sur un commutateur **Private** (Hyper-V). Pas de deuxième carte NAT/pont sur le DC.

### A2. Configurer le serveur

Démarrez la VM du serveur, puis:

**Nom du serveur:**

1. Ouvrez le **Gestionnaire de serveur** > **Serveur local**
2. Cliquez sur le nom actuel du serveur
3. Cliquez sur **Modifier**:
    - Nom de l'ordinateur: `dns1`
    - Cliquez sur **Autres...** → Suffixe DNS principal: `maxtec.be`
4. **OK** → Redémarrez le serveur

**Adresse IP du serveur:**

1. Ouvrez le **Gestionnaire de serveur** > **Serveur local**
2. Cliquez sur **Ethernet** → Propriétés → Protocole Internet version 4 (TCP/IPv4)
3. Configurez:

    | Paramètre | Valeur |
    |-----------|--------|
    | Adresse IP | `192.168.0.2` |
    | Masque | `255.255.255.0` |
    | Passerelle | *(vide)* |
    | Serveur DNS préféré | `192.168.0.2` |

4. **OK** → Redémarrez le serveur

### A3. Installer le rôle AD-DS

1. Ouvrez le **Gestionnaire de serveur**
2. Menu **Gérer** > **Ajouter des rôles et fonctionnalités**
3. Choisissez **Installation basée sur un rôle**
4. Sélectionnez le serveur `dns1.maxtec.be`
5. Cochez **Services AD DS** (Active Directory Domain Services)
6. Acceptez les fonctionnalités requises
7. Terminez l'installation

### A4. Promouvoir en contrôleur de domaine

Après l'installation du rôle, un avertissement apparaît dans le Gestionnaire de serveur:

1. Cliquez sur le lien **"Promouvoir ce serveur en contrôleur de domaine"**
2. Sélectionnez **Ajouter une nouvelle forêt**
3. Configurez:

    | Paramètre | Valeur |
    |-----------|--------|
    | Nom de domaine racine | `maxtec.be` |
    | Niveau fonctionnel (forêt et domaine) | Windows Server 2025 (serveur 2025) ou Windows Server 2016 (serveur 2022 : il n'existe pas de niveau « 2022 ») |
    | Mot de passe DSRM | `Password1!` |
    | Nom NetBIOS | `MAXTEC` |

    !!! warning "Mot de passe de lab"
        `Password1!` est acceptable dans un lab isolé ; en production, le mot de passe DSRM est fort, unique et conservé dans un coffre.

4. Cliquez **Suivant** à chaque étape restante
5. Cliquez **Installer** → Le serveur redémarre automatiquement

!!! success "Vérification"
    Après le redémarrage, l'écran de connexion devrait afficher **MAXTEC\Administrateur**. Votre contrôleur de domaine est prêt.

---

## Partie B: Joindre un Poste Client au Domaine

### B1. Créer la VM Windows 11

Créez une machine virtuelle **Windows 11 Professionnel** (l'édition Famille ne peut pas rejoindre un domaine ; Windows 10 n'est plus supporté). VirtualBox 7 émule le TPM 2.0 et le démarrage sécurisé exigés par Windows 11 ; sous Hyper-V, utilisez une VM de génération 2 avec le TPM activé. Détails : [Chapitre 2 §4](Chapitre%202.Installation-Windows-Server-2022-VirtualBox.md#4-postes-clients-windows-11).

!!! warning "Réseau"
    Configurez la carte réseau en **Réseau interne** (le même réseau que le serveur).

### B2. Configurer le nom du poste

1. Clic droit sur **Démarrer** → **Système**
2. Cliquez sur **Renommer ce PC (avancé)** (pas le bouton simple "Renommer ce PC")
3. Cliquez sur **Modifier**:
    - Nom de l'ordinateur: `ws-IT-01`
    - Laissez le **Groupe de travail** tel quel (ne changez pas encore le domaine)
4. Cliquez sur **Autres...** → Suffixe DNS principal: `maxtec.be`
5. **OK** → Redémarrez

### B3. Configurer l'adresse IP

1. Tapez `ncpa.cpl` dans la barre de recherche → Entrée
2. Clic droit sur la carte réseau → **Propriétés**
3. Double-cliquez sur **Protocole Internet version 4 (TCP/IPv4)**
4. Configurez:

    | Paramètre | Valeur |
    |-----------|--------|
    | Adresse IP | `192.168.0.10` |
    | Masque | `255.255.255.0` |
    | Passerelle | *(vide)* |
    | Serveur DNS préféré | `192.168.0.2` (l'IP du serveur) |

5. **OK** → **OK**

!!! tip "Vérification rapide"
    Ouvrez une invite de commandes et tapez:
    ```
    ping 192.168.0.2
    ```
    Si le ping répond, le poste peut communiquer avec le serveur. Sinon, vérifiez que les deux VMs sont sur le même réseau interne.

### B4. Joindre le domaine

C'est l'étape clé: rattacher le poste au domaine `maxtec.be`.

1. Clic droit sur **Démarrer** → **Système**
2. Cliquez sur **Renommer ce PC (avancé)**
3. Cliquez sur **Modifier**
4. Dans la section **Membre de**, sélectionnez **Domaine** et tapez:
    ```
    maxtec.be
    ```
5. Cliquez **OK**
6. Une fenêtre d'authentification apparaît:

    | Champ | Valeur |
    |-------|--------|
    | Utilisateur | `Administrateur` |
    | Mot de passe | `Password1!` |

7. Cliquez **OK**

!!! success "Bienvenue dans le domaine maxtec.be"
    Si tout est correct, un message s'affiche: **"Bienvenue dans le domaine maxtec.be"**. Le poste doit redémarrer.

!!! failure "Ça ne marche pas ?"
    | Problème | Solution |
    |----------|----------|
    | "Le domaine spécifié n'existe pas" | Vérifiez que le DNS du poste pointe vers `192.168.0.2` |
    | "Le domaine n'est pas accessible" | Vérifiez le ping vers `192.168.0.2` |
    | Timeout | Vérifiez que les deux VMs sont sur le même réseau interne VirtualBox |
    | Erreur d'authentification | Vérifiez le mot de passe (`Password1!`) |

### B5. Se connecter au domaine

Après le redémarrage, l'écran de connexion montre le dernier utilisateur local. Pour se connecter au domaine:

1. Cliquez sur **Autre utilisateur**
2. Connectez-vous avec:

| Champ | Valeur |
|-------|--------|
| Utilisateur | `MAXTEC\Administrateur` |
| Mot de passe | `Password1!` |

!!! info "Par la suite"
    Pour le moment, seul le compte Administrateur existe sur le domaine. Vous créerez des utilisateurs dans les chapitres suivants, et chaque utilisateur pourra se connecter avec ses propres identifiants (ex: `MAXTEC\ivan`).

### B6. Vérifier la jonction

Sur le poste client, ouvrez une invite de commandes (ou PowerShell) et tapez:

```powershell
# Vérifier le domaine
systeminfo | findstr "Domaine"
# Résultat attendu: Domaine: maxtec.be

# Vérifier la résolution DNS
nslookup maxtec.be
# Résultat attendu: Address: 192.168.0.2

# Vérifier que le poste trouve un contrôleur de domaine
nslookup -type=SRV _ldap._tcp.dc._msdcs.maxtec.be
# Résultat attendu: port = 389, svr hostname = dns1.maxtec.be
```

!!! success "Tout est prêt"
    Si les trois commandes fonctionnent, votre poste est correctement joint au domaine. Vous pouvez continuer avec le cours.

### B7. Déplacer le poste dans son OU

Après la jonction, `ws-IT-01` se trouve dans le conteneur `CN=Computers`, **où aucune GPO d'OU ne s'applique**. Quand la structure du lab existe (script [`creation_structure.ps1`](Labo%20et%20Exercices/Labo/PowerShell-scriptsStructure/creation_structure.md), exécuté au Chapitre 6), déplacez le poste sur `dns1` :

```powershell
Get-ADComputer ws-IT-01 | Move-ADObject -TargetPath "OU=Computers,OU=IT,OU=EU,DC=maxtec,DC=be"

# Vérification
Get-ADComputer ws-IT-01 | Select-Object DistinguishedName
# Résultat attendu: CN=WS-IT-01,OU=Computers,OU=IT,OU=EU,DC=maxtec,DC=be
```

Pour le deuxième poste (`ws-RH-01`, `192.168.0.11`), même procédure avec `OU=Computers,OU=RH,OU=EU`. Voir la [Référence du lab Maxtec](Labo%20et%20Exercices/Labo/Reference_Lab_Maxtec.md).
