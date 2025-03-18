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


# Exemples de résolution DNS 

1. Pour imprimer un document :
   - L'utilisateur cherche dans le sous-domaine comptabilité (`comptabilite.computerelectronics.be`)
   - Il accède à l'imprimante (`printer01.comptabilite.computerelectronics.be`)
   - Le DNS traduit ce nom en adresse IP

2. Pour accéder à une application :
   - L'utilisateur se connecte au serveur d'applications (`apps.ventes.computerelectronics.be`)
   - Le DNS redirige vers un serveur répliqué (`server1` ou `server2`)
   - En cas de panne, bascule automatique sur l'autre serveur



# Les Zones DNS

Nous avons vu la structure complète de l'espace de noms.

Une **zone DNS est une partie de l'espace de noms** DNS qu'un administrateur ou une organisation gère. Une **zone DNS est associée à au moins un serveur DNS** qui connaît les adresses des appareils qui se trouvent dans la zone. 

Il existe plusieurs **types de zones DNS** que nous allons détailler :

## Types de Zones DNS selon leur rôle

### 1. Zones Principales (Primary Zones)

Une zone principale est la source autoritaire pour un domaine où les enregistrements sont créés, modifiés et supprimés directement. Chaque **zone principale a un numéro de série unique** qui s'incrémente à chaque modification.

Dans notre exemple précédent, nous avons **deux zones principales** :

- **Zone 1** : Contient les sous-domaines `comptabilite.computerelectronics.be` et `rh.computerelectronics.be`
  - Gérée par le serveur `dns1.computerelectronics.be`
  
- **Zone 2** : Contient le sous-domaine `ventes.computerelectronics.be`
  - Gérée par le serveur `dns2.computerelectronics.be`

### 2. Zones Secondaires (Secondary Zones)

Une zone secondaire est une **copie en lecture seule** d'une zone principale. Elle est utilisée pour :
- Assurer la redondance en cas de panne du serveur principal
- Répartir la charge des requêtes DNS
- Améliorer les performances en rapprochant géographiquement les serveurs DNS des clients

Les zones secondaires se synchronisent automatiquement avec leur zone principale via un processus appelé **transfert de zone**.

## Type de Zones DNS selon leur fonction

Selong leur fonction (la conversion des noms d'hôtes en adresses IP ou vice-versa), il existe deux types de zones DNS :

### 1. Zones de Recherche Directe (Forward Lookup Zones)

Une **zone de recherche directe** convertit les noms d'hôtes en adresses IP. Elle contient plusieurs types d'enregistrements essentiels :

- **Enregistrements A** : Nom d'hôte → IPv4 
  - Exemple : `serveur.monentreprise.com` → `192.168.1.10`
- **Enregistrements AAAA** : Nom d'hôte → IPv6
  - Exemple : `serveur.monentreprise.com` → `2001:0db8:85a3:0000:0000:8a2e:0370:7334`
- **Enregistrements CNAME** : Alias vers un autre nom d'hôte
  - Exemple : `www.monentreprise.com` → `serveur.monentreprise.com`
- **Enregistrements MX** : Serveurs de messagerie
  - Exemple : `monentreprise.com` → `mail.monentreprise.com` (priorité 10)
- **Enregistrements SRV** : Services (comme Active Directory)
  - Exemple : `_ldap._tcp.monentreprise.com` → `dc01.monentreprise.com:389`

### 2. Zones de Recherche Inverse (Reverse Lookup Zones)

Une **zone de recherche inverse** permet de convertir une adresse IP en nom d'hôte. Elle est importante pour :
- La sécurité (validation des connexions)
- Le débogage réseau (ex de fonctionnement: `nslookup 192.168.1.1` pour obtenir le nom d'hôte correspondant)
- Les logs système

## Relation entre les Types de Zones

Une zone DNS peut être à la fois :
- Principale ou secondaire (pour son autorité sur les données)
- De recherche directe ou inverse (pour le type de conversion des enregistrements)


## Modifications de la zone principale

On peut modifier la zone principale en ajoutant ou en supprimant des informations et des appareils.

Exemple pratique :

  Cas pratique 1 - Ajout de deux scanners en Comptabilité :
  1. Dans la zone principale uniquement :
     scanner02.comptabilite.computerelectronics.be → 192.168.1.21
     scanner03.comptabilite.computerelectronics.be → 192.168.1.22

  2. Vérification après quelques minutes :
     Zone Principale    : scanner02.comptabilite.computerelectronics.be et scanner03.comptabilite.computerelectronics.be présents
     Zones Secondaires : scanner02.comptabilite.computerelectronics.be et scanner03.comptabilite.computerelectronics.be présents
     ✓ Synchronisation réussie

  Cas pratique 2 - Ajout de deux serveurs de fichiers dans le département ventes :
  1. Dans la zone principale uniquement :
     fichiers02.ventes.computerelectronics.be → 192.168.4.50
     fichiers03.ventes.computerelectronics.be → 192.168.4.51

  2. Vérification après quelques minutes :
     Zone Principale    : fichiers02.ventes.computerelectronics.be et fichiers03.ventes.computerelectronics.be présents
     Zones Secondaires : fichiers02.ventes.computerelectronics.be et fichiers03.ventes.computerelectronics.be présents
     ✓ Synchronisation réussie

## Types d'Enregistrements DNS

Les enregistrements DNS sont les éléments fondamentaux qui composent une zone DNS. Chaque type d'enregistrement a un rôle spécifique. Ils sont stockés dans la zone DNS, concrement dans un fichier sur un disque du serveur DNS.

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
