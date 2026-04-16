# Guide de base: Installation AD-DS et Jonction au Domaine

Ce guide couvre deux opérations distinctes:

- **[Partie A](#partie-a-installation-du-serveur-ad-ds)** - Préparer et promouvoir le serveur en contrôleur de domaine
- **[Partie B](#partie-b-joindre-un-poste-client-au-domaine)** - Configurer et joindre un poste client au domaine

---

## Partie A: Installation du Serveur AD-DS

### A1. Créer la VM Windows Server 2022

Créez une machine virtuelle Windows Server 2022 dans VirtualBox.

!!! warning "Réseau"
    Configurez la carte réseau en **Réseau interne** dans les paramètres VirtualBox de la VM.

### A2. Configurer le serveur

Démarrez la VM du serveur, puis:

**Nom du serveur:**

1. Ouvrez le **Gestionnaire de serveur** > **Serveur local**
2. Cliquez sur le nom actuel du serveur
3. Cliquez sur **Modifier**:
    - Nom de l'ordinateur: `dns1`
    - Cliquez sur **Plus...** → Suffixe DNS principal: `maxtec.be`
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
    | Niveau fonctionnel | Windows Server 2022 |
    | Mot de passe DSRM | `Password1!` |
    | Nom NetBIOS | `MAXTEC` |

4. Cliquez **Suivant** à chaque étape restante
5. Cliquez **Installer** → Le serveur redémarre automatiquement

!!! success "Vérification"
    Après le redémarrage, l'écran de connexion devrait afficher **MAXTEC\Administrateur**. Votre contrôleur de domaine est prêt.

---

## Partie B: Joindre un Poste Client au Domaine

### B1. Créer la VM Windows 10/11

Créez une machine virtuelle Windows 10 ou 11 dans VirtualBox.

!!! warning "Réseau"
    Configurez la carte réseau en **Réseau interne** (le même réseau que le serveur).

### B2. Configurer le nom du poste

1. Clic droit sur **Démarrer** → **Système**
2. Cliquez sur **Renommer ce PC (avancé)** (pas le bouton simple "Renommer ce PC")
3. Cliquez sur **Modifier**:
    - Nom de l'ordinateur: `client1`
    - Laissez le **Groupe de travail** tel quel (ne changez pas encore le domaine)
4. Cliquez sur **Plus...** → Suffixe DNS principal: `maxtec.be`
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

# Vérifier les services AD
nslookup -type=SRV _ldap._tcp.maxtec.be
# Résultat attendu: service = 0 100 389 dns1.maxtec.be
```

!!! success "Tout est prêt"
    Si les trois commandes fonctionnent, votre poste est correctement joint au domaine. Vous pouvez continuer avec le cours.
