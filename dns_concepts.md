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

### Zones de recherche directe

Une **zone de recherche directe** (forward lookup zone) est une zone DNS qui permet de convertir les noms d'hôtes en adresses IP. C'est le type de zone le plus couramment utilisé dans DNS.

Par exemple, dans notre structure précédente :
- Quand un utilisateur cherche `pc01.comptabilite.computerelectronics.be`, la zone de recherche directe renvoie son adresse IP
- Cette conversion "nom vers IP" est le processus standard de résolution DNS

Les zones de recherche directe contiennent différents types d'enregistrements DNS, notamment :
- Enregistrements A (Address) : lient un nom d'hôte à une adresse IPv4
- Enregistrements AAAA : lient un nom d'hôte à une adresse IPv6
- Enregistrements CNAME (Canonical Name) : créent des alias pour d'autres noms d'hôtes
- Enregistrements MX (Mail Exchange) : spécifient les serveurs de messagerie

### Relation entre Zones Principales et Zones de Recherche Directe

Il est important de comprendre que "zone principale" et "zone de recherche directe" sont deux concepts différents qui se complètent :

- Une **zone principale** définit le mode de gestion de la zone : c'est l'endroit où les enregistrements peuvent être créés et modifiés directement
- Une **zone de recherche directe** définit le type de résolution : elle convertit les noms d'hôtes en adresses IP

Dans notre exemple :
- La "Zone 1" qui contient `comptabilite.computerelectronics.be` et `rh.computerelectronics.be` est :
  - Une zone principale (car gérée directement par `dns1.computerelectronics.be`)
  - Une zone de recherche directe (car elle convertit les noms comme `pc01.comptabilite.computerelectronics.be` en adresses IP)

Une même zone peut donc être à la fois principale (pour sa gestion) et de recherche directe (pour sa fonction).

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

## Types d'Enregistrements DNS

Les enregistrements DNS sont les éléments fondamentaux qui composent une zone DNS. Chaque type d'enregistrement a un rôle spécifique :

## Enregistrements A (Address)
- **Fonction** : Associe un nom d'hôte à une adresse IPv4
- **Exemple** : 
  ```
  pc01.comptabilite.computerelectronics.be.    IN    A    192.168.1.10
  ```
- **Utilisation** : C'est l'enregistrement le plus courant, utilisé pour la résolution directe des noms d'hôtes

## Enregistrements AAAA (IPv6 Address)
- **Fonction** : Associe un nom d'hôte à une adresse IPv6
- **Exemple** : 
  ```
  pc01.comptabilite.computerelectronics.be.    IN    AAAA    2001:0db8:85a3:0000:0000:8a2e:0370:7334
  ```
- **Utilisation** : Version IPv6 de l'enregistrement A

## Enregistrements CNAME (Canonical Name)
- **Fonction** : Crée un alias pour un autre nom d'hôte
- **Exemple** : 
  ```
  www.computerelectronics.be.    IN    CNAME    server1.ventes.computerelectronics.be.
  ```
- **Utilisation** : Utile pour avoir plusieurs noms pointant vers le même serveur

## Enregistrements MX (Mail Exchange)
- **Fonction** : Définit les serveurs de messagerie pour un domaine
- **Exemple** : 
  ```
  computerelectronics.be.    IN    MX    10    mail.computerelectronics.be.
  ```
- **Utilisation** : Essentiel pour le routage des emails
- **Priorité** : Le nombre (10 dans l'exemple) indique la priorité (plus petit = plus prioritaire)

## Enregistrements NS (Name Server)
- **Fonction** : Indique les serveurs DNS autoritaires pour une zone
- **Exemple** : 
  ```
  computerelectronics.be.    IN    NS    dns1.computerelectronics.be.
  computerelectronics.be.    IN    NS    dns2.computerelectronics.be.
  ```
- **Utilisation** : Définit quels serveurs DNS sont responsables du domaine

## Enregistrement SOA (Start of Authority)
- **Fonction** : Contient les informations administratives d'une zone DNS
- **Exemple** : 
  ```
  computerelectronics.be.    IN    SOA    dns1.computerelectronics.be. admin.computerelectronics.be. (
                                          2023111402  ; Numéro de série
                                          3600        ; Rafraîchissement (1 heure)
                                          1800        ; Nouvelle tentative (30 minutes)
                                          604800      ; Expiration (1 semaine)
                                          86400 )     ; TTL minimum (24 heures)
  ```
- **Utilisation** : Un seul enregistrement SOA par zone
- **Paramètres importants** :
  - Numéro de série : Identifie la version actuelle de la zone
  - Rafraîchissement : Fréquence de vérification des mises à jour par les serveurs secondaires
  - Nouvelle tentative : Délai avant nouvelle tentative en cas d'échec
  - Expiration : Durée maximale de validité d'une zone secondaire
  - TTL minimum : Durée de mise en cache minimale


