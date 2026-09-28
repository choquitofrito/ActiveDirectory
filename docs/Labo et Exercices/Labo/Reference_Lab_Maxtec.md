# Référence du lab Maxtec

Valeurs officielles du lab. Tous les chapitres et exercices s'y réfèrent : en cas de doute ou de contradiction, **cette page fait foi**.

---

## Réseau et machines

| Élément | Valeur |
|---------|--------|
| Domaine DNS / AD | `maxtec.be` |
| Nom NetBIOS | `MAXTEC` |
| DN du domaine | `DC=maxtec,DC=be` |
| Réseau du lab | `192.168.0.0/24` (VirtualBox : **Réseau interne**) |
| Contrôleur de domaine | `dns1.maxtec.be` — `192.168.0.2` — DNS préféré : `192.168.0.2` |
| Poste client 1 | `ws-IT-01` — `192.168.0.10` (ou DHCP) — DNS : `192.168.0.2` |
| Poste client 2 (optionnel) | `ws-RH-01` — `192.168.0.11` (ou DHCP) — DNS : `192.168.0.2` |
| Zone de recherche inverse | `0.168.192.in-addr.arpa` |

| Logiciel | Version du cours | Remarque |
|----------|------------------|----------|
| Serveur | Windows Server 2022 | La version actuelle est Windows Server 2025 ; le cours n'en a pas besoin |
| Niveau fonctionnel forêt/domaine | Windows Server 2016 | Niveau maximal avec un DC 2022 (il n'existe pas de niveau « 2022 ») |
| Client | Windows 10 Professionnel | L'édition Famille ne peut pas rejoindre un domaine |
| Éditeur de scripts | Visual Studio Code + extension PowerShell | PowerShell ISE fonctionne aussi (présent sur le serveur, n'évolue plus) |

!!! warning "Une seule carte réseau sur le DC"
    Le DC n'a qu'une carte, sur le réseau interne. Un DC avec deux cartes (LAN + NAT) enregistre ses deux adresses dans DNS et les clients tombent au hasard sur la mauvaise. Si vous avez besoin d'Internet ponctuellement (mises à jour, téléchargement), ajoutez une carte NAT le temps de l'opération puis retirez-la.

!!! note "Les postes clients doivent être dans leur OU"
    Une machine qui rejoint le domaine arrive dans le conteneur `CN=Computers`, **où aucune GPO d'OU ne s'applique**. Après la jonction, déplacez-la :

    - `ws-IT-01` → `OU=Computers,OU=IT,OU=EU,DC=maxtec,DC=be`
    - `ws-RH-01` → `OU=Computers,OU=RH,OU=EU,DC=maxtec,DC=be`

    Dans **Utilisateurs et ordinateurs Active Directory** : **Computers** > clic droit sur le poste > **Déplacer…** > choisir l'OU. Détail : [Guide rapide, étape B7](../../Labo%20Annexe%201-Guide%20de%20base%20installation%20AD-DS.md#b7-deplacer-le-poste-dans-son-ou).

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    Get-ADComputer ws-IT-01 | Move-ADObject -TargetPath "OU=Computers,OU=IT,OU=EU,DC=maxtec,DC=be"
    ```

---

## Comptes et mots de passe du lab

Deux mots de passe seulement : **`Password1!` pour les comptes d'administration**, **`Azerty_1` pour les utilisateurs du lab**.

| Compte | Où | Mot de passe | Quand il sert |
|--------|----|--------------|---------------|
| `Administrateur` | Serveur `dns1` | `Password1!` | Installation de Windows Server (Ch1-2). Après la promotion en DC, ce même compte devient **`MAXTEC\Administrateur`**, l'administrateur du domaine. |
| Mode de restauration (DSRM) | Serveur `dns1` | `Password1!` | Saisi pendant la promotion en DC (Ch4). Ne sert qu'à dépanner un DC qui ne démarre plus normalement. |
| `admin-local` | Poste `ws-IT-01` (et `ws-RH-01`) | `Password1!` | Compte local créé à l'installation de Windows 10 (Ch2). Pour l'utiliser après la jonction au domaine, tapez **`.\admin-local`** : le `.\` veut dire « ce poste », pas le domaine. |
| `MAXTEC\Administrateur` | Domaine | `Password1!` | Jonction des postes au domaine, administration pendant tout le cours. |
| `vanessa`, `ivan`, `irene`… | Domaine | `Azerty_1` | Tous les utilisateurs créés par `creation_structure.ps1` (tableau ci-dessous), les exercices et le projet final. |

!!! tip "Connexion refusée ? Vérifiez d'abord *où* vous vous connectez"
    Sur l'écran de connexion du poste, la ligne **« Se connecter à : »** sous le champ du mot de passe indique si Windows vise le domaine (`MAXTEC`) ou le poste lui-même. `ivan` avec `Password1!`, ou `admin-local` sans `.\`, échouera toujours.

!!! warning "Mots de passe de lab"
    Des mots de passe identiques et connus de tous ne sont acceptables que dans un lab isolé. Certains exercices en utilisent volontairement d'autres (`Azerty_2` pour tester la délégation au Ch6, `Court_1234` pour tester une stratégie de mot de passe au Ch11) : ils sont indiqués dans l'exercice concerné. `Azerty_1` fait 8 caractères : il respecte la stratégie par défaut du domaine (7 minimum, complexité), mais plus une stratégie à 12 caractères (Ch11, projet final).

---

## Structure AD (créée par `creation_structure.ps1`)

```
maxtec.be
└── EU
    ├── Ventes        ├── Users  ├── Computers  └── Groups
    ├── RH            ├── Users  ├── Computers  └── Groups
    ├── Comptabilite  ├── Users  ├── Computers  └── Groups
    └── IT            ├── Users  ├── Computers  └── Groups
```

Toutes les OUs sont créées **sans** protection contre la suppression accidentelle (lab). En production, on les protège.

### Utilisateurs

`SamAccountName` = prénom en minuscules, UPN = `prenom@maxtec.be`, mot de passe de lab `Azerty_1` (voir [Comptes et mots de passe du lab](#comptes-et-mots-de-passe-du-lab)).

!!! note "Nom de l'objet = prénom"
    Le `Name` des utilisateurs du lab est le **prénom** : c'est ce que vous voyez dans `dsa.msc` et ce qui forme le DN (`CN=Ivan,OU=Users,OU=IT,OU=EU,DC=maxtec,DC=be`). Le nom complet (« Ivan Istace ») est dans `DisplayName`.

| Login | Nom affiché | OU / `Department` | `Title` | Groupe |
|-------|-------------|-------------------|---------|--------|
| `vanessa` | Vanessa Vermeulen | Ventes | Commerciale | GG-EU-Ventes-Users |
| `valeria` | Valeria Verhoeven | Ventes | Commerciale | GG-EU-Ventes-Users |
| `victor` | Victor Vandamme | Ventes | Commercial | GG-EU-Ventes-Users |
| `valentin` | Valentin Vanderlinden | Ventes | Responsable Ventes | **GG-EU-Ventes-Admin** |
| `richard` | Richard Renard | RH | Responsable RH | **GG-EU-RH-Admin** |
| `rebecca` | Rebecca Rousseau | RH | Gestionnaire RH | GG-EU-RH-Users |
| `rene` | Rene Remy | RH | Gestionnaire RH | GG-EU-RH-Users |
| `charlotte` | Charlotte Claes | Comptabilite | Responsable Comptabilite | **GG-EU-Compta-Admin** |
| `cindy` | Cindy Collard | Comptabilite | Comptable | GG-EU-Compta-Users |
| `charles` | Charles Cornet | Comptabilite | Comptable | GG-EU-Compta-Users |
| `ivan` | Ivan Istace | IT | Technicien | GG-EU-IT-Users |
| `ines` | Ines Installe | IT | Technicienne | GG-EU-IT-Users |
| `irene` | Irene Iserbyt | IT | Administratrice systeme | **GG-EU-IT-Admin** |

!!! tip "Pièges de nommage fréquents"
    - Le groupe est `GG-EU-Compta-…` mais l'OU et le `Department` sont `Comptabilite` (**sans accent**).
    - Les groupes d'administration sont au **singulier** : `GG-EU-RH-Admin`, pas `…-Admins`.
    - Les membres "Admin" (valentin, richard, charlotte, irene) ne sont **pas** membres du groupe `…-Users` de leur département. Pour tester un accès "utilisateur", prenez un membre de `…-Users`.

### Groupes

8 groupes globaux de sécurité, dans `OU=Groups,OU=<Dept>,OU=EU` :

| Département | Groupe utilisateurs | Groupe responsables |
|-------------|--------------------|--------------------|
| Ventes | `GG-EU-Ventes-Users` | `GG-EU-Ventes-Admin` |
| RH | `GG-EU-RH-Users` | `GG-EU-RH-Admin` |
| Comptabilite | `GG-EU-Compta-Users` | `GG-EU-Compta-Admin` |
| IT | `GG-EU-IT-Users` | `GG-EU-IT-Admin` |

Conventions pour les groupes que vous créerez :

| Type | Préfixe | Exemple |
|------|---------|---------|
| Global | `GG-` | `GG-EU-Ventes-Users` |
| Domaine local | `DL-` | `DL-Ventes-Documents-Modification` |
| Universel | `UG-` | `UG-Direction` |

Les groupes domaine local suivent le format `DL-<Ressource>-<Niveau>`, avec trois niveaux dans tout le cours : `-Lecture`, `-Modification`, `-ControleTotal`.

---

## Partages

Règle unique : le dossier `C:\Shares\<Nom>` sur le DC est partagé sous le nom `<Nom>`, donc accessible en `\\dns1\<Nom>`. Le chemin à mettre dans une GPO est **toujours** le chemin réseau (UNC), jamais `C:\…`.

| Dossier local | Chemin réseau | Utilisé dans |
|---------------|---------------|--------------|
| `C:\Shares\IT-docs` | `\\dns1\IT-docs` | Chapitre 7 §5 (share vs NTFS) |
| `C:\Shares\Ventes-Documents` | `\\dns1\Ventes-Documents` | AGDLP |
| `C:\Shares\Factures` | `\\dns1\Factures` | AGDLP (extension) |
| `C:\Shares\Software` | `\\dns1\Software` | GPO-1 (déploiement MSI) |
| `C:\Shares\IT-Admin` | `\\dns1\IT-Admin` | GPO-1 (lecteur réseau) |
| `C:\Shares\Compta-Docs` | `\\dns1\Compta-Docs` | GPO-3 (redirection de dossiers) |

!!! note "Partages sur un DC"
    En entreprise, les fichiers sont sur un serveur de fichiers membre, pas sur un DC. Ici on n'a qu'un serveur : c'est un compromis de lab.

---

## Objets créés pendant le cours

Ces objets ne sont pas créés par `creation_structure.ps1` : ils apparaissent au fil des exercices. Ils sont listés ici pour éviter les collisions de noms et savoir d'où vient un objet inattendu.

| Objet | Où | Créé dans |
|-------|----|-----------|
| OU `Resources` et sa sous-OU `Groups` (`OU=Groups,OU=Resources,OU=EU,DC=maxtec,DC=be`) | sous `OU=EU` | AGDLP |
| `DL-Ventes-Documents-Lecture`, `-Modification`, `-ControleTotal` | `OU=Groups,OU=Resources,OU=EU` | AGDLP |
| `DL-Factures-Lecture`, `DL-Factures-Modification` | `OU=Groups,OU=Resources,OU=EU` | AGDLP (extension) |
| Partage `Profiles$` (`C:\Shares\Profiles` → `\\dns1\Profiles$`) | DC | Gestion des utilisateurs, Ex. 11 |
| Partage `Logistique` (`C:\Shares\Logistique` → `\\dns1\Logistique`) | DC | Projet final |
| Compte `chloe` (Chloé Dumont) | `OU=Users,OU=Comptabilite,OU=EU` | Gestion des utilisateurs, Ex. 1 |
| Comptes `jean.dupont`, `sophie.dubois` | `OU=Users,OU=IT,OU=EU` et `OU=Users,OU=Ventes,OU=EU` | Chapitre 9.3 |
| Compte `irene-adm` | `OU=Users,OU=IT,OU=EU` | Chapitre 11 |
| OU `Logistique` (louis, lea, lucas, laura ; `GG-EU-Logistique-*`, `DL-Logistique-*`) | sous `OU=EU` | Projet final |
| OU `Achats` (adrien, agathe ; `GG-EU-Achats-*`) et OU `Marketing` | sous `OU=EU` | Exercice en autonomie : OUs et départements complémentaires |

---

## Remise à zéro

- Tout supprimer : [`suppression_structure.ps1`](PowerShell-scriptsStructure/suppression_structure.md)
- Tout recréer : [`creation_structure.ps1`](PowerShell-scriptsStructure/creation_structure.md)
