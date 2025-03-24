# 2. Comprendre le DNS

## 1. Objectifs Pédagogiques

À la fin de ce chapitre, vous serez capable de :
1. Comprendre le rôle et l'**importance du DNS** dans un réseau d'entreprise
2. Configurer un serveur DNS pour notre domaine `computerelectronics.be`
3. Gérer les zones et les enregistrements DNS
4. Dépanner les problèmes DNS courants

## 2. Introduction au DNS

Après avoir installé et configuré Windows Server, nous allons maintenant nous concentrer sur le service **DNS** (Domain Name System). Ce service est essentiel pour notre infrastructure car il s**era la base de notre futur domaine Active Directory**. 

Le service **DNS permettra de trouver l'IP de chaque élément de notre réseau à partir de son nom de domaine** 

Ex: `www.google.com` => `142.250.179.174` (adresse IPv4)

## Exercice 2.1 - Explorer le DNS dans votre environnement

Avant de plonger dans les détails techniques, explorons comment le DNS fonctionne dans votre environnement actuel :

1. Ouvrez une console sur votre machine
2. Exécutez les commandes suivantes et notez les résultats :
   - `ping -4 www.google.com`
   - `ping -4 computerelectronics.be`
4. Que remarquez-vous ? Quelles informations sont affichées ?
5. Pourquoi pensez-vous que certains sites répondent et d'autres non ?

Note: `ping -4` est utilisé pour forcer le ping à utiliser l'IPv4. 

<details>
<summary>Solution 2.1</summary>

- Si `computerelectronics.be` ne répond pas, c'est normal car :
  1. C'est notre domaine interne de test
  2. Il n'existe pas encore sur Internet
  3. Nous allons le configurer dans notre infrastructure locale

</details>



## 3. Qu'est-ce que le DNS ?


### 3.1 Définition du DNS

Le **DNS** (Domain Name System) est comme **l'annuaire téléphonique d'Internet**. Son rôle principal est de **transformer les noms de domaine** que nous utilisons (comme `www.computerelectronics.be`) **en adresses IP** (comme `203.0.113.10`). Une adresse IP est **un numéro unique qui identifie un ordinateur sur Internet**.

- **Nom de domaine** : `computerelectronics.be`
- **Adresse IP** : `203.0.113.10`

### 3.2 Processus de Résolution DNS

![Diagramme DNS](../diagrams/images/dns_resolution_computerelectronics.png)

Le diagramme ci-dessus illustre le processus de résolution DNS pour accéder au site computerelectronics.be :

1. Le **client envoie une requête DNS au serveur DNS** pour obtenir l'adresse IP de computerelectronics.be
2. Le **serveur DNS répond** avec l'adresse **IP** correspondante
3. Le **client** peut alors établir une **connexion directe** avec le serveur web computerelectronics.be en utilisant **l'adresse IP reçue**

Ce processus est fondamental pour la navigation web, car il permet de traduire les noms de domaine en adresses IP utilisables.

## 2. L'Espace de Noms DNS 


Un **espace de noms DNS** est un ensemble de noms de domaines organisés de façon hiérarchique, comme un arbre avec :

- **Domaine racine** : le domaine principal de l'entreprise (ex: computerelectronics.be)
- **Sous-domaines géographiques** : représentent les régions (ex: eu.computerelectronics.be, us.computerelectronics.be)
- **Sous-domaines de service** : représentent les environnements (ex: dev.computerelectronics.be, prod.computerelectronics.be)
- **Appareils et services** : les ressources informatiques (postes de travail, serveurs, services)

Prenons un cas pratique: **Computer Electronics** (`computerelectronics.be`) est une entreprise internationale d'électronique avec des opérations en Europe et aux États-Unis. Pour gérer efficacement son infrastructure informatique, l'entreprise organise son espace de noms DNS selon :

- Une **séparation géographique** (Europe et États-Unis)
- Une **séparation par environnement** (développement et production)

Voici son diagramme logique:

![Diagramme DNS](../diagrams/images/structure_reseau_geographic_zones.png)


Cette structure reflète l'organisation réseau de l'entreprise, séparant les zones géographiques et les environnements de service.

## Point clé:
- Pour les postes de travail (ws) et les imprimantes on va utiliser une structure DNS plate (directement sous le domaine racine ou **flat DNS**) pour simplifier la gestion des certificats et l'authentification unique (SSO)
- Pour le reste (serveurs, services, etc.) on va utiliser une structure DNS avec sous-domaines géographiques et d'environnement

Nous avons un seul arbre DNS, avec une seule racine, qui est notre domaine racine. 

Un espace de noms qui a plusieurs arbres devient un **forest DNS**. Par exemple, si notre entreprise fusionne avec une autre entreprise (ex: `techshop.fr`), nous pourrions avoir :

- **Premier arbre** : `computerelectronics.be` et ses sous-domaines
- **Deuxième arbre** : `techshop.fr` et ses sous-domaines

Chaque arbre garde son indépendance tout en permettant une collaboration entre les entreprises.

![Diagramme DNS](../diagrams/images/forest_structure.png)



### 2.2. Les Zones DNS (organisation logique)

Notre **espace de noms** contient tous les noms de domaine de notre entreprise. Une **zone DNS** est une partie de cet espace qui contient les enregistrements pour un domaine ou sous-domaine spécifique.

La division **en zones DNS présente plusieurs avantages** :
- **Organisation logique** : Séparation claire des ressources par région (eu, us) et par environnement (dev, prod)
- **Sécurité** : Possibilité d'appliquer des politiques de sécurité différentes par zone
- **Performance** : Optimisation du trafic réseau en dirigeant les requêtes vers les ressources les plus proches
- **Maintenance** : Facilité de maintenance et de dépannage grâce à la segmentation logique

Dans notre infrastructure, nous utilisons une architecture DNS centralisée :
- Le serveur DNS primaire (**dns1.computerelectronics.be**) est **maître** pour toutes les zones
- Le serveur DNS secondaire (**dns2.computerelectronics.be**) **réplique** automatiquement ces zones
- Les deux serveurs assurent la **redondance** et la **répartition** de charge
- Cette centralisation garantit la cohérence et simplifie l'administration

Le diagramme suivant montre la **structure physique du réseau** avec la répartition géographique et les environnements :

![Diagramme DNS](../diagrams/images/structure_reseau_geographic_zones.png)


**Bien que les ressources soient physiquement réparties entre l'Europe et les États-Unis, la gestion DNS reste centralisée pour optimiser la maintenance et la sécurité.**



### 2.3 Analyse des zones

Analysons cette structure niveau par niveau :

- **Premier niveau (domaine racine)**
  - Le domaine `computerelectronics.be` est la racine de l'entreprise
  - Tous les appareils et services de l'entreprise en font partie

- **Deuxième niveau (sous-domaines géographiques et de service)** 
  - **Sous-domaines géographiques** :
    - `eu.computerelectronics.be` : Opérations européennes
    - `us.computerelectronics.be` : Opérations américaines
  - **Sous-domaines de service** :
    - `dev.computerelectronics.be` : Environnement de développement
    - `prod.computerelectronics.be` : Environnement de production

- **Dernier niveau (appareils et services)**
  - **Infrastructure DNS (192.168.0.0/24)** :
    - Réservé (192.168.0.1) : Passerelle par défaut
    - `dns1.computerelectronics.be` : Serveur DNS principal (192.168.0.2)
    - `dns2.computerelectronics.be` : Serveur DNS secondaire (192.168.0.3)

  - **Zone Europe (192.168.10.0/24)** :
    - Réservé (192.168.10.1) : Passerelle par défaut
    - Services (192.168.10.10-19) :
      - `fileserver.eu.computerelectronics.be` (192.168.10.10)
      - `mail.eu.computerelectronics.be` (192.168.10.11)
    - Périphériques réseau (192.168.10.20-49) :
      - `printer-compta-01.computerelectronics.be` (192.168.10.20)
    - Postes de travail (192.168.10.128-254) :
      - `ws-compta-01.computerelectronics.be` (192.168.10.128)
      - `ws-compta-02.computerelectronics.be` (192.168.10.129)

  - **Zone US (192.168.20.0/24)** :
    - Réservé (192.168.20.1) : Passerelle par défaut
    - Services (192.168.20.10-19) :
      - `fileserver.us.computerelectronics.be` (192.168.20.10)
      - `mail.us.computerelectronics.be` (192.168.20.11)
    - Périphériques réseau (192.168.20.20-49) :
      - `printer-compta-02.computerelectronics.be` (192.168.20.20)
    - Postes de travail (192.168.20.128-254) :
      - `ws-ventes-01.computerelectronics.be` (192.168.20.128)
      - `ws-ventes-02.computerelectronics.be` (192.168.20.129)

  - **Zone Développement (192.168.30.0/24)** :
    - Réservé (192.168.30.1) : Passerelle par défaut
    - Services de développement (192.168.30.10-19) :
      - `app.dev.computerelectronics.be` (192.168.30.10)
      - `db.dev.computerelectronics.be` (192.168.30.11)

  - **Zone Production (192.168.40.0/24)** :
    - Réservé (192.168.40.1) : Passerelle par défaut
    - Services de production (192.168.40.10-19) :
      - `app.prod.computerelectronics.be` (192.168.40.10)
      - `db.prod.computerelectronics.be` (192.168.40.11)


**Important**: cette structure DNS est une **organisation logique** qui peut être **totalement indépendante de l'emplacement physique des ressources**. 


### 2.4 Structure Physique vs Logique

Dans notre infrastructure, il est important de comprendre la distinction entre :

**Structure Physique** :
- Deux serveurs DNS physiques dans le même datacenter (192.168.0.2 et 192.168.0.3)
- Une gestion DNS centralisée sur ces serveurs
- Des ressources physiquement réparties entre l'Europe et les États-Unis

**Structure Logique** :
- Un découpage en zones (eu, us, dev, prod) pour organiser les ressources
- Une hiérarchie de noms indépendante de l'emplacement des serveurs DNS
- Une administration centralisée malgré la distribution géographique des ressources

Cette séparation permet d'avoir une organisation logique claire tout en maintenant une gestion technique centralisée et efficace.

<br>

# Exercices Section 2

## Exercice 2.1 - Structure DNS
Dessinez la structure DNS d'une nouvelle zone géographique "asia" pour computerelectronics.be qui contient :
- 2 serveurs : un serveur de fichiers régional et un serveur ERP local
- 3 postes de travail
- 1 imprimante réseau

en suivant la nomenclature actuelle de computerelectronics.be et en utilisant le sous-réseau 192.168.**50**.0/24.

<details>
<summary>Solution 2.1</summary>

Voici la structure DNS pour la zone Asia :

1. Sous-domaine : `asia.computerelectronics.be`

2. Serveurs (192.168.50.0/24) :
   - `fileserver.asia.computerelectronics.be` (192.168.50.10)
   - `erp.asia.computerelectronics.be` (192.168.50.11)

3. Postes de travail :
   - `ws-01.asia.computerelectronics.be` (192.168.50.128)
   - `ws-02.asia.computerelectronics.be` (192.168.50.129)
   - `ws-03.asia.computerelectronics.be` (192.168.50.130)

4. Imprimante réseau :
   - `printer-01.asia.computerelectronics.be` (192.168.50.20)

Cette structure suit la même logique que les zones EU et US existantes :
- Réservé (192.168.50.1) : Passerelle par défaut
- Serveurs (192.168.50.10-19)
- Périphériques réseau (192.168.50.20-49)
- Postes de travail (192.168.50.128-254)
</details>

## Exercice 2.2 - Analyse
Dans la structure actuelle de computerelectronics.be, identifiez:
- Tous les appareils qui sont directement rattachés au domaine racine
- Tous les appareils qui appartiennent à la zone géographique EU
- Tous les appareils qui appartiennent à la zone DEV
Expliquez pourquoi les serveurs DNS sont dans le domaine racine et non dans une zone spécifique

<details>
<summary>Solution 2.2</summary>

1. Appareils rattachés au domaine racine :
   - dns1.computerelectronics.be (192.168.0.2)
   - dns2.computerelectronics.be (192.168.0.3)


2. Appareils de la zone EU (192.168.10.0/24) :
   - ws-compta-01.computerelectronics.be (192.168.10.128)
   - ws-compta-02.computerelectronics.be (192.168.10.129)
   - fileserver.eu.computerelectronics.be (192.168.10.10)
   - printer-compta-01.computerelectronics.be (192.168.10.20)
   - printer-ventes-01.computerelectronics.be (192.168.10.21)
   - mail.eu.computerelectronics.be (192.168.10.11)

3. Appareils de la zone DEV (192.168.30.0/24) :
   - app.dev.computerelectronics.be (192.168.30.10)
   - db.dev.computerelectronics.be (192.168.30.11)

Les serveurs DNS sont dans le domaine racine pour plusieurs raisons :
- **Accessibilité** : Ils doivent être accessibles depuis toutes les zones (eu, us, dev, prod)
- **Hiérarchie** : Reflète leur rôle de gestion globale de l'infrastructure DNS

</details>


### Exercice 2.3 - Analyse des Structures DNS

En utilisant le diagramme réseau ([structure_reseau_geographic_zones.drawio](diagrams/structure_reseau_geographic_zones.drawio)) et la structure DNS de ComputerElectronics, analysez les différences entre l'organisation physique et logique du réseau.

#### Questions :

1. Comparez la gestion des zones géographiques (EU/US) :
   - Comment sont-elles représentées physiquement dans le réseau ?
   - Comment sont-elles organisées dans la hiérarchie DNS ?
   - Quel impact cela a-t-il sur la résolution des noms ?

2. Analysez la distribution des services (mail, fileserver, app, db, printer...):
   - Comment les serveurs de messagerie (mail.eu/us) sont-ils placés physiquement ?
   - Comment leur organisation DNS reflète-t-elle (ou non) cette réalité ?

3. Étudiez la redondance DNS :
   - Où sont placés physiquement dns1 et dns2 ?
   - Comment apparaissent-ils dans la structure DNS ?
   - Pourquoi cette différence est-elle importante ?

<details>
<summary>Solution 2.3</summary>

1. Zones géographiques :
   - Physiquement : Réseaux distincts (192.168.10.0/24 et 192.168.20.0/24) avec équipements locaux
   - DNS : Sous-domaines eu/us.computerelectronics.be avec délégation DNS
   - Impact : Permet une gestion locale des zones tout en maintenant une administration centralisée

2. Distribution des services () :
   - Physiquement : Serveurs dans leurs zones géographiques respectives
   - DNS : Nommage reflétant la localisation (mail.eu/us.computerelectronics.be)
   - Avantages : 
     * Clarté de la localisation des services
     * Facilite la répartition de charge géographique
     * Simplifie la maintenance par zone

3. Redondance DNS :
   - Physiquement : dns1 (192.168.0.2) et dns2 (192.168.0.3) dans la zone racine
   - DNS : Configuration primaire/secondaire pour toutes les zones
   - Importance : 
     * dns1 est le serveur primaire (maître) pour toutes les zones
     * dns2 est le serveur secondaire (réplique en lecture seule)
     * Transfert de zone automatique du primaire vers le secondaire
     * Protection contre la panne d'un serveur DNS
</details>




## 3. Résolution DNS 

Mais **comment fonctionne la résolution DNS** ? On l'explique dans cette section!

### 3.1. Autorité d'un serveur DNS sur un espace de nom

Un serveur DNS a l'autorité sur un espace de nom si il dispose des informations nécessaires pour répondre directement à une requête.



#### 3.1.1. Serveur DNS avec Autorité

Ex: `dns1.computerelectronics.be` possède l'autorité sur `computerelectronics.be` et tous ses sous-domaines (`eu.computerelectronics.be`, `us.computerelectronics.be`, `dev.computerelectronics.be`, `prod.computerelectronics.be`).

Un serveur DNS ayant autorité sur un espace de nom :

1. **Répond toujours directement** :
   - Renvoie immédiatement l'IP si le nom existe dans sa zone
   - Renvoie immédiatement une erreur si le nom n'existe pas
   - Pas besoin de consulter d'autres serveurs DNS

2. **Aucune récursion nécessaire** :
   - Possède toutes les données de sa zone localement
   - Ne fait jamais de requêtes à d'autres serveurs pour sa propre zone
   - Réponse instantanée car données en mémoire

#### 3.1.2. Serveur DNS sans Autorité

#### 3.2.2. Serveur DNS sans Autorité

Un serveur DNS **n'ayant pas autorité sur un espace** de nom peut résoudre la requête de plusieurs façons (dans l'ordre) :

Quand un serveur n'a pas l'autorité sur une zone, il doit obtenir l'information d'une autre source. C'est là qu'interviennent les types de requêtes.

### 3.2. Types de Requêtes DNS pour un serveur sans autorité

Quand un serveur **n'a pas l'autorité** sur une zone demandée, il doit utiliser l'un des deux types de requêtes suivants pour obtenir l'information: requête **récursive** ou **itérative**.

Ces deux types de requêtes ne se produisent que lorsqu'un serveur **n'a PAS l'autorité sur la zone demandée**. Un serveur avec autorité répond toujours directement sans consulter d'autres serveurs.

#### 3.2.1. **Requêtes Récursives**

Voici le déroulement d'une requête récursive :

![Requête DNS récursive](../diagrams/images/requetes_dns_recursive.png)

**Exemple de requête récursive :**

1. Un poste client (`ws-compta-01.computerelectronics.be`) demande à `dns1` l'adresse de `www.google.com`

2. `dns1` se charge de tout le processus de résolution :
   - Il cherche dans ses zones (**pas d'autorité** sur google.com)
   - Il fait les requêtes nécessaires vers d'autres serveurs
   - Il obtient l'IP finale

3. `dns1` renvoie directement l'IP au client

Le **client n'a fait qu'une seule requête** et attend simplement la réponse finale.

Dans une requête **récursive** :

   - Le client fait **une seule requête** à son serveur DNS
   - Le serveur DNS est **responsable d'obtenir la réponse finale**
   - Si le serveur n'a pas l'information dans ses zones :
     * Il fait toutes les requêtes nécessaires lui-même
     * Le client n'a rien à faire de plus


#### 3.2.2. **Requêtes Itératives**

Quand un serveur ne peut pas faire de requête récursive, il utilise des requêtes itératives. Dans ce cas :

![Requête DNS itérative](../diagrams/images/requetes_dns_iterative.png)

**Exemple de requête itérative :**

1. Le client demande l'IP de www.google.com à un serveur DNS
2. Le serveur répond : "Je ne sais pas, essayez les serveurs DNS qui gèrent .com"
3. Le client demande l'IP aux serveurs .com
4. Les serveurs .com répondent : "Demandez aux serveurs DNS de Google"
5. Le client demande l'IP aux serveurs DNS de Google
6. Les serveurs DNS de Google répondent avec l'IP finale

**Points clés des requêtes itératives :**

- Le serveur DNS qui ne connaît pas la réponse renvoie une **référence** vers d'autres serveurs
- Le client doit faire **plusieurs requêtes successives**
- Chaque serveur aide à se rapprocher de la réponse finale
- Plus complexe pour le client mais moins de charge sur les serveurs

1. **Aucune récursion nécessaire** :
   - Possède toutes les données de sa zone localement
   - Ne fait jamais de requêtes à d'autres serveurs pour sa propre zone
   - Réponse instantanée car données en mémoire

Voici, plus en détail, la suite d'opérations pour chercher l'IP d'un serveur DNS sans autorité:

1. Chercher dans la **Cache DNS** : Si l'IP a déjà été résolue récemment
   - Réponse immédiate sans autre requête
   - Valide jusqu'à expiration du TTL (Time To Live)

2. Transmettre la requête au **Redirecteur (Forwarder)** : Si configuré
   - Transmet la requête à un autre serveur DNS (souvent celui du FAI)
   - **Attend** une **réponse récursive complète**
   - Plus simple que la résolution itérative

3. Lancer une **Résolution Itérative** : **En dernier recours**
   - Interroge les serveurs DNS racine
   - Suit les références de serveur en serveur
   - Processus plus complexe mais plus autonome

<br>


# Exercices Section 3

## Exercice 3.1 - Autorité DNS
Dans le contexte de computerelectronics.be, indiquez pour chaque scénario si le serveur dns1 a autorité ou non :
- Une requête pour ws-compta-01.computerelectronics.be
- Une requête pour www.google.com
- Une requête pour fileserver.us.computerelectronics.be

<details>
<summary>Solution 3.1</summary>

1. Requête pour ws-compta-01.computerelectronics.be :
   - dns1 a autorité car il gère tout le domaine computerelectronics.be et ses sous-domaines
   - Il peut donc répondre directement avec l'adresse IP (192.168.10.128) ou affirmer que le nom n'existe pas

2. Requête pour www.google.com :
   - dns1 n'a pas autorité sur le domaine google.com
   - Il devra soit utiliser son cache, soit faire appel à un redirecteur ou aux serveurs DNS racine

3. Requête pour fileserver.us.computerelectronics.be :
   - dns1 a autorité car il gère tout le domaine computerelectronics.be et ses sous-domaines
   - Il peut donc répondre directement avec l'adresse IP (192.168.20.10)
</details>


<br>

# 4. La Délégation DNS

La délégation DNS est **le mécanisme qui permet de répartir la responsabilité de la gestion des zones DNS entre différents serveurs**. Dans notre infrastructure, la délégation s'organise sur plusieurs niveaux :

## 4.1 Niveau Internet (DNS Public)

Pour accéder aux services publics (site web, email, etc.) de notre domaine, nous utilisons les serveurs DNS publics.

- Le registrar du domaine `computerelectronics.be` configure les serveurs DNS publics
- Ces serveurs contiennent les enregistrements NS (Name Server) qui pointent vers les serveurs DNS autoritaires pour le domaine
- Ils gèrent principalement les services accessibles depuis l'extérieur (site web, email, etc.)

![Diagramme de délégation DNS au niveau Internet](../diagrams/images/dns_delegation_public.png)

## 4.2 Niveau Entreprise (DNS Interne)

Pour accéder aux **services internes** (serveurs, applications, etc.) de notre domaine, nous utilisons les serveurs DNS internes.

- `dns1.computerelectronics.be` et `dns2.computerelectronics.be` sont configurés comme serveurs autoritaires pour l'ensemble du domaine
- Les zones géographiques et d'environnement sont configurées ainsi dans le serveur dns1, dans un fichier de configuration DNS:
  ```
  # Configuration des zones géographiques :
  eu.computerelectronics.be.   IN  NS  dns1.computerelectronics.be.
  us.computerelectronics.be.   IN  NS  dns1.computerelectronics.be.
  
  # Configuration des zones d'environnement :
  dev.computerelectronics.be.  IN  NS  dns1.computerelectronics.be.
  prod.computerelectronics.be. IN  NS  dns1.computerelectronics.be.
  ```
Nous allons voir plus tard les **enregistrements** de zone (IN, NS, etc.).

- Chaque ligne délègue la gestion d'un sous-domaine à ce serveur DNS
- Les services utiliseront ces sous-domaines (ex: `fileserver.eu.computerelectronics.be`)

# Exercices Section 4

## Exercice 4.1 - Configuration de Zone DNS
Vous devez configurer une nouvelle zone géographique "asia" pour l'expansion en Asie :
- La zone sera gérée par dns1
- Créez les enregistrements de zone nécessaires

<details>
<summary>Solution 4.1</summary>

Configuration à ajouter sur dns1 :
```
asia.computerelectronics.be.  IN  NS  dns1.computerelectronics.be.
```

Explication :
- L'enregistrement NS définit dns1 comme serveur autoritaire pour la zone asia
- Cette zone suivra le même modèle que les zones EU et US existantes
- Le sous-réseau 192.168.30.0/24 sera utilisé pour cette zone
</details>

## Exercice 4.2 - Analyse des Zones DNS
Analysez la configuration des zones DNS et répondez aux questions :
- Quels serveurs DNS sont responsables de la résolution des noms dans la zone eu.computerelectronics.be ?
- Si dns1 reçoit une requête pour ws-compta-01.computerelectronics.be, que se passe-t-il ?

<details>
<summary>Solution 4.2</summary>

1. Responsabilité de la zone EU :
   - dns1 et dns2 sont tous les deux autoritaires pour la zone
   - Cela est défini par la configuration des serveurs DNS qui ont autorité sur l'ensemble du domaine

2. Processus de résolution via dns1 :
   - dns1 reçoit la requête pour ws-compta-01.computerelectronics.be
   - dns1 consulte sa configuration et voit qu'il a l'autorité sur la zone
   - dns1 répond directement avec l'IP 192.168.10.128
   - Aucune redirection n'est nécessaire car dns1 est autoritaire
</details>


#### 5.1.2 Zones Secondaires (Secondary Zones)

Une zone secondaire est une **copie en lecture seule** d'une zone principale. Elle est utilisée pour :
- Assurer la redondance en cas de panne du serveur principal
- Répartir la charge des requêtes DNS
- Améliorer les performances en rapprochant géographiquement les serveurs DNS des clients

Les zones secondaires se synchronisent automatiquement avec leur zone principale via un processus appelé **transfert de zone**.

### 5.2 Types de Zones DNS selon leur fonction

#### 5.2.1 Zones de Recherche Directe (Forward Lookup Zones)

Une **zone de recherche directe** convertit les noms d'hôtes en adresses IP. Elle contient plusieurs types d'enregistrements essentiels :

- **Enregistrements A** : Nom d'hôte → IPv4 
  - Exemple : `serveur.monentreprise.com` → `192.168.0.10`
- **Enregistrements AAAA** : Nom d'hôte → IPv6
  - Exemple : `serveur.monentreprise.com` → `2001:0db8:85a3:0000:0000:8a2e:0370:7334`
- **Enregistrements CNAME** : Alias vers un autre nom d'hôte
  - Exemple : `www.monentreprise.com` → `serveur.monentreprise.com`
- **Enregistrements MX** : Serveurs de messagerie
  - Exemple : `monentreprise.com` → `mail.monentreprise.com` (priorité 10)
- **Enregistrements SRV** : Services (comme Active Directory)
  - Exemple : `_ldap._tcp.monentreprise.com` → `dc01.monentreprise.com:389`

#### 5.2.2 Zones de Recherche Inverse (Reverse Lookup Zones)

Une **zone de recherche inverse** permet de convertir une adresse IP en nom d'hôte. Elle est importante pour :
- La sécurité (validation des connexions)
- Le débogage réseau (ex de fonctionnement: `nslookup 192.168.0.1` pour obtenir le nom d'hôte correspondant)
- Les logs système

### 5.3. Relation entre les Types de Zones

Une zone DNS peut être à la fois :

- **Principale** ou **secondaire** (pour son autorité sur les données)
  * Zone principale : `computerelectronics.be` sur `dns1.computerelectronics.be` (192.168.0.2)
  * Zone secondaire : `computerelectronics.be` sur `dns2.computerelectronics.be` (192.168.0.3)

- De **recherche directe** (nom-->ip) ou **inverse** (ip-->nom) selon le type de conversion des enregistrements
  * Zone directe : `computerelectronics.be` (nom → IP)
  * Zone inverse : `0.168.192.in-addr.arpa` (IP → nom)

## 5.4. Modifications de la zone principale

On peut modifier la zone principale en ajoutant ou en supprimant des informations et des appareils.

Exemple pratique :

  Cas pratique 1 - Ajout de deux scanners en Comptabilité :
  1. Dans la zone principale uniquement :
     scanner-compta-02.computerelectronics.be → 192.168.10.21
     scanner-compta-03.computerelectronics.be → 192.168.10.22

  2. Vérification après quelques minutes :
     Zone Principale    : scanner-compta-02.computerelectronics.be et scanner-compta-03.computerelectronics.be présents
     Zones Secondaires : scanner-compta-02.computerelectronics.be et scanner-compta-03.computerelectronics.be présents
     ✓ Synchronisation réussie

  Cas pratique 2 - Ajout de deux serveurs de fichiers dans le département ventes :
  1. Dans la zone principale uniquement :
     fileserver-vnt-02.computerelectronics.be → 192.168.10.50
     fileserver-vnt-03.eu.computerelectronics.be → 192.168.10.51

  2. Vérification après quelques minutes :
     Zone Principale    : fileserver-vnt-02.computerelectronics.be et fileserver-vnt-03.eu.computerelectronics.be présents
     Zones Secondaires : fileserver-vnt-02.computerelectronics.be et fileserver-vnt-03.eu.computerelectronics.be présents
     ✓ Synchronisation réussie

## Annexe: Types d'Enregistrements DNS

Les enregistrements DNS sont les éléments fondamentaux qui composent une zone DNS. Chaque type d'enregistrement a un rôle spécifique. Ils sont stockés dans la zone DNS, concrement dans un fichier sur un disque du serveur DNS.

### A (Address)
- **Fonction** : Associe un nom d'hôte à une adresse IPv4
- **Exemple** : 
  ```
  ws-compta-01.computerelectronics.be.    IN    A    192.168.10.101
  ```
- **Utilisation** : C'est l'enregistrement le plus courant, utilisé pour la résolution directe des noms d'hôtes

### AAAA (IPv6 Address)
- **Fonction** : Associe un nom d'hôte à une adresse IPv6
- **Exemple** : 
  ```
  ws-compta-01.computerelectronics.be.    IN    AAAA    2001:0db8:85a3:0000:0000:8a2e:0370:7334
  ```
- **Utilisation** : Version IPv6 de l'enregistrement A

### CNAME (Canonical Name)
- **Fonction** : Crée un alias pour un autre nom d'hôte
- **Exemple** : 
  ```
  www.computerelectronics.be.    IN    CNAME    webserver-vnt-01.computerelectronics.be.
  ```
- **Utilisation** : Utile pour avoir plusieurs noms pointant vers le même serveur

### MX (Mail Exchange)
- **Fonction** : Définit les serveurs de messagerie pour un domaine
- **Exemple** : 
  ```
  computerelectronics.be.    IN    MX    10    mail.computerelectronics.be.
  ```
- **Utilisation** : Essentiel pour le routage des emails
- **Priorité** : Le nombre (10 dans l'exemple) indique la priorité (plus petit = plus prioritaire)

### NS (Name Server)
- **Fonction** : Indique les serveurs DNS autoritaires pour une zone
- **Exemple** : 
  ```
  computerelectronics.be.    IN    NS    dns1.computerelectronics.be.
  computerelectronics.be.    IN    NS    dns2.computerelectronics.be.
  ```
- **Utilisation** : Définit quels serveurs DNS sont responsables du domaine

### SOA (Start of Authority)
- **Fonction** : Définit les paramètres de la zone DNS
- **Contient** :
  - Serveur DNS maître
  - Contact administrateur
  - Numéro de série : Date de dernière modification
  - Rafraîchissement : Intervalle de mise à jour des serveurs secondaires
  - Nouvelle tentative : Délai avant nouvelle tentative en cas d'échec
  - Expiration : Durée maximale de validité d'une zone secondaire
  - TTL minimum : Durée de mise en cache minimale

# Exercices Section 5

## Exercice 5.1 - Types de Zones
Pour chacun des sous-domaines suivants, indiquez quel type de zone DNS serait le plus approprié et pourquoi :
- eu.computerelectronics.be (sous-zone pour l'Europe)
- us.computerelectronics.be (sous-zone pour les États-Unis) (avec réplication entre server1 et server2)

<details>
<summary>Solution 5.1</summary>

1. eu.computerelectronics.be :
   - Type : Zone principale (Primary Zone)
   - Justification : 
     - dns1 est le serveur principal pour cette zone géographique
     - Réplication vers dns2 comme serveur secondaire
     - Modifications directes possibles uniquement sur dns1

2. us.computerelectronics.be :
   - Type : Zone principale (Primary Zone)
   - Justification :
     - dns1 est le serveur principal pour cette zone géographique
     - Réplication vers dns2 comme serveur secondaire
     - Configuration similaire à la zone EU pour la cohérence
</details>

## Exercice 5.2 - Enregistrements DNS
Créez les enregistrements DNS nécessaires pour :
- Un nouveau serveur web dans le département ventes (www.ventes.computerelectronics.be)
- Une nouvelle imprimante dans le département RH avec IPv4 et IPv6

<details>
<summary>Solution 5.2</summary>

1. Serveur web ventes (sur dns2) :
```
www.ventes.eu.computerelectronics.be.    IN    A      192.168.10.41
www.ventes.eu.computerelectronics.be.    IN    CNAME  webserver-vnt-01.computerelectronics.be.
```

2. Imprimante RH (sur dns1) :
```
printer-rh-01.computerelectronics.be.    IN    A      192.168.10.31
printer-rh-02.computerelectronics.be.    IN    AAAA   2001:0db8:85a3:0000:0000:8a2e:0370:7335
```
</details>

## Exercice 4.1 - Dépannage DNS

Scénario : Un utilisateur du département Ventes rapporte qu'il ne peut pas accéder à `ws-vnt-02.computerelectronics.be`

1. Quelles sont les étapes de dépannage à suivre ?
2. Quelles commandes utiliseriez-vous ?
3. Comment vérifier si le problème vient du DNS ou du réseau ?

<details>
<summary>Solution 4.1</summary>

Étapes de dépannage :

1. Vérifier la configuration DNS du poste client :
   ```powershell
   ipconfig /all   # Vérifier le serveur DNS configuré
   ```

2. Tester la résolution DNS :
   ```powershell
   nslookup ws-vnt-02.computerelectronics.be
   ```

3. Vérifier la connectivité réseau :
   ```powershell
   ping ws-vnt-02.computerelectronics.be
   ping 192.168.10.142  # IP directe si connue
   ```

4. Consulter les enregistrements DNS sur le serveur :
   - Ouvrir DNS Manager
   - Vérifier la zone eu.computerelectronics.be
   - Chercher l'enregistrement A pour ws-vnt-02

</details>

## 5. Travaux Pratiques : Configuration DNS

### 5.1. Préparation de l'Environnement

**Objectif** : Préparer le serveur DNS pour notre domaine

**Étapes** :
1. Vérification des prérequis :
   ```
   Composant               Statut Requis
   --------------------   ------------------------------
   Windows Server 2022     Installé et à jour
   Rôle DNS               Non installé
   Adresse IP             Statique (192.168.0.2) # DNS primaire utilise le réseau d'infrastructure
   ```

2. Installation du rôle DNS :
   ```powershell
   # Vérification de l'installation
   Get-WindowsFeature -Name DNS
   
   # Installation si nécessaire
   Install-WindowsFeature -Name DNS -IncludeManagementTools
   ```

### 5.2. Configuration de Base

#### Exercice 5.2.1 : Création des Zones DNS

**Objectif** : Créer les zones DNS pour notre infrastructure

<details>
<summary>Solution 5.2.1</summary>

1. Création de la zone racine :
   ```
   Type : Zone principale
   Nom : computerelectronics.be
   Fichier : computerelectronics.be.dns
   Mises à jour dynamiques : Autorisées
   ```

2. Création des zones géographiques :
   ```
   Type : Zone principale
   Nom : eu.computerelectronics.be
   Fichier : eu.computerelectronics.be.dns
   Mises à jour dynamiques : Autorisées
   ```
   ```
   Type : Zone principale
   Nom : us.computerelectronics.be
   Fichier : us.computerelectronics.be.dns
   Mises à jour dynamiques : Autorisées
   ```

3. Création des zones d'environnement :
   ```
   Type : Zone principale
   Nom : dev.computerelectronics.be
   Fichier : dev.computerelectronics.be.dns
   Mises à jour dynamiques : Autorisées
   ```
   ```
   Type : Zone principale
   Nom : prod.computerelectronics.be
   Fichier : prod.computerelectronics.be.dns
   Mises à jour dynamiques : Autorisées
   ```
</details>

#### Exercice 5.2.2 : Ajout d'Enregistrements DNS

**Objectif** : Configurer les enregistrements DNS essentiels

<details>
<summary>Solution 5.2.2</summary>

1. Enregistrements d'infrastructure (zone computerelectronics.be) :
   ```
   Nom                  Type    Adresse IP
   ------------------   -----   -----------
   dns1                 A       192.168.0.2
   dns2                 A       192.168.0.3
   ```

2. Enregistrements NS pour les sous-zones :
   ```
   Nom                          Type    Valeur
   --------------------------   -----   -------------------------
   eu.computerelectronics.be    NS      dns1.computerelectronics.be
   eu.computerelectronics.be    NS      dns2.computerelectronics.be
   us.computerelectronics.be    NS      dns1.computerelectronics.be
   us.computerelectronics.be    NS      dns2.computerelectronics.be
   dev.computerelectronics.be   NS      dns1.computerelectronics.be
   dev.computerelectronics.be   NS      dns2.computerelectronics.be
   prod.computerelectronics.be  NS      dns1.computerelectronics.be
   prod.computerelectronics.be  NS      dns2.computerelectronics.be
   ```

3. Exemple d'enregistrements dans la zone EU :
   ```
   Nom                          Type    Adresse IP
   --------------------------   -----   -----------
   ws-compta-01                A       192.168.10.101
   ws-rh-01                    A       192.168.10.121
   ws-vnt-01                   A       192.168.10.141
   ```

4. Vérification des enregistrements :
   ```powershell
   # Vérification des serveurs DNS
   nslookup dns1.computerelectronics.be
   nslookup dns2.computerelectronics.be

   # Vérification des zones géographiques
   nslookup -type=ns eu.computerelectronics.be
   nslookup -type=ns us.computerelectronics.be

   # Vérification des postes de travail
   nslookup ws-compta-01.computerelectronics.be
   nslookup ws-rh-01.computerelectronics.be
   ```
</details>

### 5.3. Tests et Vérification

#### Exercice 5.3.1 : Vérification de la Résolution DNS

**Objectif** : Tester la résolution des noms dans différentes zones

<details>
<summary>Solution 5.3.1</summary>

1. Test des serveurs DNS :
   ```powershell
   Resolve-DnsName -Name dns1.computerelectronics.be
   Resolve-DnsName -Name dns2.computerelectronics.be
   ```

2. Test de la zone EU :
   ```powershell
   Resolve-DnsName -Name ws-compta-01.computerelectronics.be
   Resolve-DnsName -Name ws-rh-01.computerelectronics.be
   ```

3. Test de la zone US :
   ```powershell
   Resolve-DnsName -Name ws-compta-01.us.computerelectronics.be
   Resolve-DnsName -Name ws-rh-01.us.computerelectronics.be
   ```

4. Vérification des journaux DNS :
   ```
   Observateur d'événements -> Journaux Windows -> DNS Server
   ```
</details>

## 6. Dépannage DNS

### 6.1. Problèmes Courants

```
Problème                       Cause Possible                Solution
------------------------   ------------------------    ------------------------
Résolution impossible        Cache DNS                   ipconfig /flushdns
Nom inconnu dans zone EU      Enregistrement manquant     Vérifier eu.computerelectronics.be
Zone géographique inaccessible Problème de délégation    Vérifier les NS records
Zone non chargée            Fichier corrompu             Recharger la zone
Serveur DNS secondaire       Transfert de zone échoué    Vérifier la réplication
```

### 6.2. Commandes de Dépannage

```powershell
# Vérification des services DNS
Get-Service -Name DNS

# Tests de résolution par zone
Test-DnsServer -IPAddress 192.168.0.2 -ZoneName computerelectronics.be
Test-DnsServer -IPAddress 192.168.0.2 -ZoneName eu.computerelectronics.be
Test-DnsServer -IPAddress 192.168.0.2 -ZoneName us.computerelectronics.be

# Vérification des transferts de zone
Get-DnsServerZoneTransfer -Name eu.computerelectronics.be

# Nettoyage du cache DNS
Clear-DnsClientCache

# Vérification des délégations
Get-DnsServerZoneDelegation -Name computerelectronics.be
```
