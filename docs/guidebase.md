# Guide base configuration AD

## 1. Créer VM Windows Server 2022 

N'oubliez pas de changer le réseau à **Réseau interne** dans la configuration de VirtualBox

## 2. Demarrez la VM du **serveur**, puis suivez ces pas:
   
   1. ⚙️ Configuration du nom du serveur :
        - Ouvrez le **Gestionnaire de serveur** > **Serveur local**
        - Sélectionnez le nom actuel
        - Cliquez sur **Modifier**
                Nom : **dns1**
                Suffixe DNS : **maxtec.be**
        - Cliquez sur **OK**
        - Redémarrez le serveur
  

    2. Fixer l'ip du serveur
         - Tapez **Ethernet** dans la barre de recherche
         - Changez la config pour le protocole IPv4:
           - Adresse IP: 192.168.0.10 (ou 11, 12...etc.) (pas automatique!)
           - Masque: 255.255.255.0
           - Serveur DNS: lui-même 192.168.0.2 (l'ip de votre serveur, ou l'adresse loopback 127.0.0.1)

## 3. Installez le rol d'AD-DS

| Étape | Action |
|--------|--------|
| 1 | Ouvrir le **Gestionnaire de serveur** |
| 2 | Menu **Gérer** > **Ajouter des rôles** |
| 3 | Choisir **Installation basée sur un rôle** |
| 4 | Sélectionner `dns1.maxtec.be` |
| 5 | Dans **Rôles**, cocher **Services AD DS** |
| 6 | Accepter les fonctionnalités requises |
| 7 | Terminer l'installation |

## 4. Promouvoir le serveur:


| Étape | Configuration | Valeur |
|--------|---------------|--------|
| 1 | Type d'installation | Nouvelle forêt |
| 2 | Nom de domaine | `maxtec.be` |
| 3 | Niveau fonctionnel | Windows Server 2022 |
| 4 | Mot de passe DSRM | `Password1!` |
| 5 | Nom NetBIOS | `MAXTEC` |

## 5. Créer VM Windows 10 

Créer une machine Windows 10 sur virtualbox. N'oubliez pas de changer le réseau à **Réseau interne** dans la configuration de VirtualBox


1. **Paramètres Système**:
   - Clic droit sur Démarrer → Système
   - Paramètres système avancés
   - Onglet **Nom de l'ordinateur**
   - **Modifier**

2. **Configuration:**
   - Nom de l'ordinateur: `ws-compta-01`
   - Membre de: **Domaine** → `maxtec.be` dans 
   - Autres->Suffix principal -> `maxtec.be`
   - **OK**

3. Fixed l'ip de la machine client
   - Tapez **Ethernet** dans la barre de recherche
   - Changez la config pour le protocole IPv4:
     - Adresse IP: 192.168.0.10 (ou 11, 12...etc.) (pas automatique!)
     - Masque: 255.255.255.0
     - Serveur DNS: 192.168.0.2 (l'ip de votre serveur)

4. **Authentification:**

Pour le moment on peut se connecter uniquement avec l'Administrateur. On créera des Utilisateurs plus tard avec leurs propres crédentielles.

   - Utilisateur: `Administrateur@maxtec.be`
   - Mot de passe: `Password1!`

5. **Redémarrer** la machine cliente

   
