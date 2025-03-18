# Comprendre le DNS : Une Introduction Simple

## Qu'est-ce que le DNS ?

Le **DNS** (Domain Name System)** est comme **l'annuaire téléphonique d'Internet**. Son rôle principal est de **transformer les noms de domaine** que nous utilisons (comme `www.computerelectronics.be`) **en adresses IP** (comme `192.168.2.10`). Une adresse IP est **un numéro unique qui identifie un ordinateur sur Internet**.

Exemple:

- **Nom de domaine** : `computerelectronics.be`
- **Adresse IP** : `192.168.2.10`





### Analogie Simple

Imaginez que vous voulez envoyer une lettre à un ami. Vous connaissez son nom (comme `www.computerelectronics.be`), mais pour que la poste livre la lettre, il faut son adresse complète (comme l'adresse IP `192.168.2.10`). Le DNS fait exactement ça : il traduit les noms en adresses. Si on n'avait pas le DNS, il faudrait que chaque personne connaisse l'adresse IP de chaque site web qu'elle visite!!


## Diagramme de résolution DNS pour computerelectronics.be

![Diagramme DNS](diagrams/dns_resolution_computerelectronics.drawio)

Le diagramme ci-dessus illustre le processus de résolution DNS pour accéder au site computerelectronics.be :

1. Le client envoie une requête DNS au serveur DNS pour obtenir l'adresse IP de computerelectronics.be
2. Le serveur DNS répond avec l'adresse IP correspondante
3. Le client peut alors établir une connexion directe avec le serveur web computerelectronics.be en utilisant l'adresse IP reçue

Ce processus est fondamental pour la navigation web, car il permet de traduire les noms de domaine en adresses IP utilisables.


## L'Espace de Noms

Un espace de noms **est un système d'organisation hiérarchique des noms**, **similaire à l'organisation des dossiers sur votre ordinateur**. 
La structure est comme un arbre, avec la racine (le domaine) et ses sous-racines (les sous-domaines). 
Les feuilles sont les appareils (ordinateurs, serveurs de tout genre, imprimantes, etc.).

Dans l'espace de noms on peut avoir:

- **Domaine** : racine de l'entreprise
- **Sous-domaine** : sous-racine de l'entreprise (des noms de départements comme comptabilite.computerelectronics.be, rh.computerelectronics.be, etc.)
- **Appareil** : ordinateur, serveur, imprimante, etc.

Considérons une entreprise "computerelectronics.be" qui a plusieurs départements:
- Comptabilité
- RH
- Ventes

Ce diagramme correspond à la structure **physique** du reseau:

![Diagramme DNS](diagrams/structure_reseau.drawio)


Cette structure physique correspond à cette structure DNS. 

Observez bien la structure logique des noms, car elle ne correspond pas à ce qu'on visualise sur le diagramme physique (expliquée plus bas):


```
computerelectronics.be                      # **Domaine** racine de l'entreprise
├── comptabilite.computerelectronics.be     # **Sous-domaine** du département comptabilité
│   ├── pc01.comptabilite.computerelectronics.be    # Poste de travail comptabilité (appareil)
│   └── printer01.comptabilite.computerelectronics.be    # Imprimante comptabilité (appareil)
├── dns1.computerelectronics.be             # Serveur DNS gérant les adresses de comptabilité et RH 
│                                           # directement dans le domaine racine sans sous-domaine (appareil)
├── dns2.computerelectronics.be             # Serveur DNS gérant ventes (appareil)
│                                           # directement dans le domaine racine sans sous-domaine (appareil)
├── rh.computerelectronics.be               # **Sous-domaine** du département RH
|   ├── pc01.rh.computerelectronics.be      # Poste de travail RH (appareil)
|   └── scanner01.rh.computerelectronics.be # Scanner du service RH (appareil)
└── ventes.computerelectronics.be           # **Sous-domaine** du département ventes
    ├── fichiers.ventes.computerelectronics.be    # Serveur de fichiers partagés (appareil)
    ├── apps.ventes.computerelectronics.be        # Serveur hébergeant les applications (appareil)
    ├── database.ventes.computerelectronics.be    # Serveur de bases de données (appareil)
    ├── server1.ventes.computerelectronics.be     # Serveur répliqué pour load balancing (appareil)
    ├── server2.ventes.computerelectronics.be     # Serveur répliqué pour redondance (appareil)
    ├── pc01.ventes.computerelectronics.be        # Poste de travail ventes (appareil)
    └── printer01.ventes.computerelectronics.be   # Imprimante ventes (appareil)
```

Analysons cette structure niveau par niveau :

1. **Premier niveau de l'espace de noms (domaine): `computerelectronics.be`**
   - C'est le domaine racine de l'entreprise
   - Tous les appareils et services de l'entreprise font partie de ce domaine

2. **Deuxième niveau de l'espace de noms (sous-domaines)** 
   - `comptabilite.computerelectronics.be` : Sous-domaine du département comptabilité
   - `rh.computerelectronics.be` : Sous-domaine du département RH
   - `ventes.computerelectronics.be` : Sous-domaine du département ventes
   - Chaque département a son propre **sous-domaine**
   - Permet d'organiser et de gérer séparément les ressources de chaque département

3. **Dernier niveau : Les appareils (noms d'hôte ou hostnames)**
   - Infrastructure DNS :
     - `dns1.computerelectronics.be` : Le serveur DNS qui gère les zones comptabilité et RH (appareil lié au domaine racine, c'est tout à fait possible et normal)
     - `dns2.computerelectronics.be` : Le serveur DNS qui gère la zone ventes lié aussi au domaine racine)
   - Serveurs du département ventes :
     - `fichiers.ventes.computerelectronics.be` : Serveur de fichiers partagés (appareil)
     - `apps.ventes.computerelectronics.be` : Serveur hébergeant les applications (appareil)
     - `database.ventes.computerelectronics.be` : Serveur de bases de données (appareil)
     - `server1.ventes.computerelectronics.be` : Serveur répliqué pour load balancing (appareil)
     - `server2.ventes.computerelectronics.be` : Serveur répliqué pour redondance (appareil)
   - Postes de travail et périphériques :
     - `pc01.comptabilite.computerelectronics.be` : Poste de travail comptabilité (appareil)
     - `printer01.comptabilite.computerelectronics.be` : Imprimante comptabilité (appareil)
     - `pc01.rh.computerelectronics.be` : Poste de travail RH (appareil)
     - `scanner01.rh.computerelectronics.be` : Scanner du service RH (appareil)
     - `pc01.ventes.computerelectronics.be` : Poste de travail ventes (appareil)
     - `printer01.ventes.computerelectronics.be` : Imprimante ventes (appareil)

**Important**: cette structure DNS est une **organisation logique** qui peut être **totalement indépendante de l'emplacement physique des ressources**. 


# Exemples de résolution DNS :

1. Pour imprimer un document :
   - L'utilisateur cherche dans le sous-domaine comptabilité (`comptabilite.computerelectronics.be`)
   - Il accède à l'imprimante (`printer01.comptabilite.computerelectronics.be`)
   - Le DNS traduit ce nom en adresse IP

2. Pour accéder à une application :
   - L'utilisateur se connecte au serveur d'applications (`apps.ventes.computerelectronics.be`)
   - Le DNS redirige vers un serveur répliqué (`server1` ou `server2`)
   - En cas de panne, bascule automatique sur l'autre serveur



## Les Zones DNS

Nous avons vu la structure complete de l'espace de noms.

Une **zone DNS est une partie de l'espace de noms** DNS qu'un administrateur ou une organisation gère. Une **zone DNS est associée à au moins un serveur DNS** qui connait les adresses des appareils qui se trouvent dans la zone. 

### Types de Zones DNS

Il existe plusieurs **types de zones DNS**: les zones **principales** et les zones **secondaires**.

## Zones principales

Zone DNS où les enregistrements sont créés (un **enregistrement** pour chaque **appareil**), modifiés et supprimés directement. C'est la source autoritaire pour le domaine.

On va determiner, **juste car on le veut**, que dans l'exemple précédent **il y aura deux zones principales**: 

**Zone 1**: contiendra l'espace de noms contenant les sous-domaines `comptabilite.computerelectronics.be` et `rh.computerelectronics.be`,  ainsi que tous les appareils qui se trouvent dans la structure.

Un seul serveur gère l'ensemble des appareils de cette zone (dans le schéma, `dns1.computerelectronics.be`). 

**Zone 2**: contiendra l'espace de noms `ventes.computerelectronics.be`.
C'est un autre serveur qui gère l'ensemble des appareils de cette zone (dans le schéma, `dns2.computerelectronics.be`)







Note: une zone peut être liée a plusieurs serveurs DNS si on veut assurer la disponibilité en, par exemple, cas de panne. On aurait alors un dns3.computerelectronics.be

On aura alors deux **zones principales**, chacune avec son propre serveur DNS pour gérer l'ensemble des appareils de la zone.

Chaque **zone principale a un numéro de série unique**. 

### Zones secondaires

**Zone sécondaire**: Copie en lecture seule d'une zone principale, synchronisée périodiquement pour la redondance et la répartition de charge.


#### 1. Modifications de la zone principale

On peut modifier la zone principale en ajoutant ou en supprimant des informations et des appareils.

Exemple pratique :

  1. L'admin fait un changement dans la **zone principale**
     Exemple : Ajout d'un nouveau PC dans le service Comptabilité
     • Avant : Numéro de série zone = 2023111401 
     • Ajout : pc03.comptabilite.computerelectronics.be → 192.168.1.60
     • Après : Numéro de série zone = 2023111402

  2. Les zones secondaires vérifient périodiquement
     • Toutes les 15 minutes par défaut
     • Comparent leur numéro de série avec celui de la principale
     • Si différent → demandent une mise à jour
  
  3. Transfert des modifications
     • La zone principale envoie les changements
     • Les zones secondaires appliquent les modifications
     • Toutes les zones sont maintenant synchronisées

Exemple pratique de synchronisation :

  Cas pratique - Ajout d'un scanner en comptabilité :
  1. Dans la zone principale uniquement :
     scanner02.comptabilite.computerelectronics.be → 192.168.1.21
  
  2. Vérification après quelques minutes :
     Zone Principale    : scanner02.comptabilite.computerelectronics.be présent
     Zones Secondaires : scanner02.comptabilite.computerelectronics.be présent
     ✓ Synchronisation réussie

- Exemple de contenu de la zone principale : 
  ```
  Zone : computerelectronics.be
  Serveur Principal : dns1.computerelectronics.be (192.168.2.1)
  Contenu :
    # Infrastructure
    dns1.computerelectronics.be               → 192.168.2.1
    dns2.computerelectronics.be               → 192.168.2.3
    ad.computerelectronics.be                 → 192.168.2.2
    mail.computerelectronics.be               → 192.168.2.4
    
    # Département Comptabilité
    pc01.comptabilite.computerelectronics.be     → 192.168.1.10
    printer01.comptabilite.computerelectronics.be → 192.168.1.20
    
    # Département RH
    pc01.rh.computerelectronics.be               → 192.168.1.30
    scanner01.rh.computerelectronics.be          → 192.168.1.40
  ```

#### 2. Zone Secondaire (Secondary Zone)
- Copie en lecture seule de la zone principale
- Utilisée pour la redondance et la répartition de charge
- Exemple :
  ```
  Zone Principale : dns1.computerelectronics.be (192.168.2.1)
  Zone Secondaire : dns2.computerelectronics.be (192.168.2.3)
  • Synchronisation toutes les 15 minutes
  • Copie exacte des données de tous les départements
  • Si dns1 tombe en panne, dns2 continue à répondre aux requêtes
  ```

#### 3. Zone Stub
- Contient uniquement les informations des serveurs de noms (SOA, NS, A) qui servent à pointer vers la zone secondaire
- Utile pour la délégation de sous-domaines
- Exemple :
  ```
  Zone Stub : ventes.computerelectronics.be
  Serveur : dns2.computerelectronics.be (192.168.2.3)
  Contient uniquement :
    • Informations SOA (Start of Authority)
    • Enregistrements NS (Name Server)
    • Enregistrements A des serveurs :
      - fichiers.ventes.computerelectronics.be  → 192.168.2.20
      - apps.ventes.computerelectronics.be      → 192.168.2.21
      - database.ventes.computerelectronics.be  → 192.168.2.22
  ```



