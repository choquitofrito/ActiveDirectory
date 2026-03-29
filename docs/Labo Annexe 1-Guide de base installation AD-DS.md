# Guide base configuration AD

## 1. Créer VM Windows Server 2022 

N'oubliez pas de changer le réseau à **Réseau interne** dans la configuration de VirtualBox

## 2. Demarrez la VM du **serveur**, puis suivez ces pas:

1. ⚙️ **Configuration du nom du serveur**

    - Ouvrez le **Gestionnaire de serveur** > **Serveur local**
    - Sélectionnez le nom actuel
    - Cliquez sur **Modifier** :
        - Nom : `dns1`
        - Suffixe DNS : `maxtec.be`
    - Cliquez sur **OK**
    - Redémarrez le serveur

2. 🌐 **Configuration de l'IP du serveur**

    - Ouvrez le **Gestionnaire de serveur** > **Serveur local**
    - Cliquez sur **Ethernet** → Propriétés → Protocole IPv4
    - Configurez les valeurs suivantes :
        - Adresse IP : `192.168.0.2`
        - Masque : `255.255.255.0`
        - Serveur DNS : `192.168.0.2` (l'ip de votre serveur, ou l'adresse loopback `127.0.0.1`)
    - Redémarrez le serveur

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

Puis: cliquer sur l'avertissement pour que notre serveur devienne un DC (Controlêur de domaine)

- Cliquez sur le lien "Promouvoir..." et attendre
- "Ajouter une nouvelle forêt"
- Tapez le password Password1! (ce sera le pass pour l'admin)
- Tapez Suivant puis Suivant... puis Suivant... puis Suivant
- Tapez Installer

## 4. Promouvoir le serveur:


| Étape | Configuration | Valeur |
|--------|---------------|--------|
| 1 | Type d'installation | Nouvelle forêt |
| 2 | Nom de domaine | `maxtec.be` |
| 3 | Niveau fonctionnel | Windows Server 2022 |
| 4 | Mot de passe DSRM | `Password1!` |
| 5 | Nom NetBIOS | `MAXTEC` |

## 5. Créer VM Windows 10 

Créer une machine Windows 10 sur virtualbox. 
N'oubliez pas de changer le réseau à **Réseau interne** dans la configuration de VirtualBox


1. **Paramètres Système**:
   - Clic droit sur Démarrer → Système
   - Option **Changer Nom de l'ordinateur (AVANCÉ, pas la prémière option)**
   - **Modifier**

2. **Configuration:**
   - Nom de l'ordinateur: `client1`
   - Autres->Suffix principal -> `maxtec.be`
   - NE CHANGEZ PAS LE DOMAINE
   - **OK**, puis redemarrez

3. Fixed l'ip de la machine client
   - Tapez **Ethernet** dans la barre de recherche
   - Changez la config pour le protocole IPv4:
     - Adresse IP: 192.168.0.10 (ou 11, 12...etc.) (pas automatique!)
     - Masque: 255.255.255.0
     - Serveur DNS: 192.168.0.2 (l'ip de votre serveur)
   - **OK**, puis redemarrez


4. **Authentification:**

Pour le moment on peut se connecter uniquement avec l'Administrateur. On créera des Utilisateurs plus tard avec leurs propres crédentielles.

   - Utilisateur: `Administrateur`
   - Mot de passe: `Password1!`

   
