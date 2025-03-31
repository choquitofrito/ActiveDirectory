# Chapitre 3: Active Directory Domain Services (AD DS)

> 📚 **Dans ce chapitre:**
> 1. 🔍 [Introduction à AD DS](#1-introduction-à-ad-ds)
>    - Concepts fondamentaux
>    - Architecture AD DS
> 2. 💻 [Installation d'AD DS](#2-installation-dad-ds)
>    - Prérequis
>    - Étapes d'installation
> 3. 🌐 [Configuration du domaine](#3-configuration-du-domaine)
>    - Structure du domaine
>    - Paramètres essentiels

---

## 📙 Objectifs Pédagogiques

À la fin de ce chapitre, vous serez capable de :
1. Comprendre l'architecture d'Active Directory
2. Installer et configurer AD DS sur Windows Server
3. Créer et configurer le domaine `computerelectronics.be`
4. Vérifier le bon fonctionnement d'AD DS

---

## 📙 Introduction à AD DS

Active Directory Domain Services (AD DS) est le service principal d'Active Directory. Il permet de gérer de manière centralisée :

* 👥 Les utilisateurs
* 💻 Les ordinateurs
* 🗄️ Les ressources partagées
* 🔒 Les stratégies de sécurité
* 🌐 Les services réseau

Bien qu'on le confonde souvent avec l'ensemble d'Active Directory, AD DS est un service spécifique parmi d'autres :
 
| Service | Description |
|---------|-------------|
| 🔑 **AD DS** | Service principal gérant l'authentification et l'autorisation des ressources |
| 🪶 **AD LDS** | Version allégée d'AD DS fonctionnant sans domaine Windows |
| 📜 **AD CS** | Gestion des certificats numériques et de l'infrastructure à clé publique (PKI) |
| 🔒 **AD RMS** | Protection et contrôle des droits d'accès aux documents |
| 🔗 **AD FS** | Authentification unique (SSO) et fédération d'identités entre organisations |

**La force d'Active Directory** réside dans sa capacité à **centraliser l'administration**. Au lieu de gérer chaque ordinateur individuellement, les administrateurs peuvent appliquer des politiques et des configurations à partir d'un point central.

<br>

## 📁 Exemple de fonctionnement d'AD

### Structure du réseau

Considérez notre infrastructure réseau :

![Forêt](../diagrams/images/structure_reseau_geographic_zones.png)

### Flux d'authentification et d'accès

Voyons comment un utilisateur accède à un serveur de fichiers :

![Intégration DNS-AD DS](../diagrams/images/ad_auth_flow.png)

> 💡 **Note** : Observez les flèches colorées : bleu pour l'authentification, jaune pour l'accès aux ressources, et bleu bidirectionnel pour la réplication. Les flèches vertes seront expliquées plus tard.

### 🔑 1. Authentification (flèche bleue)

| Étape | Description |
|--------|-------------|
| Requête | `ws-compta-01` (`192.168.0.101`) demande l'authentification |
| Traitement | `dns1.computerelectronics.be` (`192.168.0.2`) vérifie les identifiants |
| Protocole | Kerberos gère l'authentification sécurisée |
| Réseau | Via le switch `SW-COMPTA` (`192.168.0.1`) |

### 📂 2. Accès aux ressources (flèche jaune)

| Étape | Description |
|--------|-------------|
| Connexion | `ws-compta-01` accède à `fileserver.us.computerelectronics.be` |
| Résolution | `dns2` fournit l'IP `192.168.0.41` |
| Autorisation | Le serveur de fichiers vérifie les droits d'accès |

### 🔃 3. Réplication AD (flèche bleue bidirectionnelle)

| Processus | Bénéfice |
|-----------|------------|
| Synchronisation | `dns1` et `dns2` maintiennent leurs bases à jour |
| Redondance | Le service continue si un DC tombe en panne |

### 🔍 Requêtes DNS (flèches vertes)

Les flèches vertes représentent les requêtes DNS pour la résolution des noms. Pour simplifier le diagramme, seules les requêtes sont montrées, pas les réponses.

| Étape | Description |
|--------|-------------|
| 1 | Le PC interroge `dns1` pour localiser son contrôleur de domaine |
| 2 | Après authentification, le PC demande à `dns1` l'IP du serveur de fichiers |
| 3 | `dns1` transfère la requête à `dns2` |
| 4 | `dns2` résout le nom et le PC peut accéder au serveur |

<br>

## 📚 Active Directory Domain Services (AD DS)

AD DS est le service fondamental de notre infrastructure `computerelectronics.be`. Il crée et gère la base de données centrale d'Active Directory.

### Fonctionnalités principales

| Catégorie | Fonctionnalités |
|------------|---------------|
| 🔑 Authentification | Gestion centralisée des identités |
| 📂 Ressources | Administration des ressources réseau |
| 🔒 Sécurité | Application des stratégies de sécurité |
| 🎓 Organisation | Structure hiérarchique des ressources |

### Informations stockées

| Type | Exemples |
|------|----------|
| 👥 Utilisateurs | Employés, prestataires, comptes de service |
| 💻 Ordinateurs | Postes de travail, serveurs, portables |
| 📁 Ressources | Imprimantes, dossiers partagés, applications |
| 🔐 Stratégies | Règles de sécurité, restrictions, droits |
| 🌐 Services | Services réseau, configurations système |

Pour bien comprendre le déploiement d'AD DS dans notre entreprise, commençons par examiner la structure DNS existante, car AD DS s'appuie fortement sur DNS pour son fonctionnement.


### 💾 Base de données AD DS

#### Stockage et redondance

> 💡 La base de données AD doit être hébergée sur au moins un serveur appelé **Contrôleur de Domaine (DC)**.  

| Configuration | Description |
|--------------|-------------|
| Minimum | Un seul DC pour gérer l'arbre DNS |
| Recommandé | Plusieurs DCs pour la redondance |
| Optimal | DCs répartis géographiquement |

#### ⚠️ Services indépendants

| Service | Rôle |
|---------|-------|
| DNS | Résolution de noms en IPs |
| AD DS | Gestion de la base de données d'annuaire |

#### Configurations possibles (exemples)

| Serveurs DNS | Serveurs AD | Avantages |
|-------------|-------------|------------|
| 3 | 2 | Haute disponibilité DNS |
| 2 | 2 | Équilibre optimal |
| 2 | 3 | Redondance AD accrue |

#### 📈 Haute disponibilité

Les deux services doivent être disponibles en permanence :
- 🔄 Basculement automatique en cas de panne
- ⚖️ Répartition de charge
- 💻 Réplication entre serveurs

<br>

## 🏛️ Contrôleurs de Domaine

### Configuration de notre infrastructure

> 💡 Notre infrastructure repose sur deux serveurs principaux qui hébergent à la fois les services DNS et AD DS.

#### Serveurs principaux

| Serveur | Rôle principal | Adresse IP |
|---------|-----------------|------------|
| `dns1.computerelectronics.be` | DC Principal + DNS | `192.168.0.2` |
| `dns2.computerelectronics.be` | DC Secondaire + DNS | `192.168.0.3` |

#### Architecture des services

| Service | Configuration |
|---------|---------------|
| AD DS | Réplication entre les DCs |
| DNS | Gestion de zones par DC |

#### Diagramme d'installation

> Le schéma suivant illustre l'installation d'AD DS sur notre serveur principal :

![Installation AD](../diagrams/images/dns_ad_installation.png)


### 💻 Promotion en contrôleur de domaine

#### Configuration réseau initiale

> ⚠️ Avant de promouvoir le serveur en DC, nous devons configurer correctement son réseau.

1. **Configuration IP**
   | Paramètre | Valeur |
   |------------|--------|
   | Adresse IP | `192.168.0.2` |
   | Masque | `255.255.255.0` |
   | Serveur DNS | `192.168.0.2` |

2. **Configuration du nom**
   | Paramètre | Valeur |
   |------------|--------|
   | Nom d'ordinateur | `dns1` |
   | Suffixe DNS | `computerelectronics.be` |

> 💡 Le serveur utilise sa propre adresse comme serveur DNS car il hébergera le service DNS pour le domaine.


#### Installation du rôle AD DS

> 💡 Un rôle est un ensemble de fonctionnalités permettant au serveur d'accomplir une fonction spécifique.

| Étape | Action |
|--------|--------|
| 1 | Ouvrir le **Gestionnaire de serveur** |
| 2 | Menu **Gérer** > **Ajouter des rôles** |
| 3 | Choisir **Installation basée sur un rôle** |
| 4 | Sélectionner `dns1.computerelectronics.be` |
| 5 | Dans **Rôles**, cocher **Services AD DS** |
| 6 | Accepter les fonctionnalités requises |
| 7 | Terminer l'installation |

#### 🔗 Promotion du serveur

> 💡 Cette étape transforme le serveur en contrôleur de domaine pour `computerelectronics.be`

| Étape | Configuration | Valeur |
|--------|---------------|--------|
| 1 | Type d'installation | Nouvelle forêt |
| 2 | Nom de domaine | `computerelectronics.be` |
| 3 | Niveau fonctionnel | Windows Server 2022 |
| 4 | Mot de passe DSRM | `Password1!` |
| 5 | Nom NetBIOS | `COMPUTERELECTRONICS` |



#### 🔍 Vérifications post-installation

> 💡 Après le redémarrage, vérifiez le bon fonctionnement des services.

##### 1. Vérification DNS

| Test | Commande | Objectif |
|------|----------|----------|
| Résolution | `nslookup dns1.computerelectronics.be` | Vérifie que `dns1` résout à `192.168.0.2` |
| Diagnostique | `dcdiag /test:dns` | Vérifie la configuration DNS d'AD |

**AD DS** est **basé sur** l’utilisation d’un **espace de noms DNS** pour gérer un domaine **et impose donc l’utilisation d’un serveur DNS** au sein du réseau.
**C'est l'installation d'AD DS qui va configurer la base du serveur DNS**.

Ce serveur DNS doit être capable de prendre en charge les enregistrements de service **SRV** nécessaires à la localisation des contrôleurs de domaine.

- Les **enregistrements SRV** **(Service Record)** sont des enregistrements DNS qui permettent la **localisation des services** sur le réseau. 

  - Les enregistrements SRV sont utilisés par les services tels que:
    - `_ldap._tcp.computerelectronics.be` pour le service LDAP (**protocole de communication** pour interroger et modifier des informations dans la base de données d'AD)
    - `_kerberos._tcp.computerelectronics.be` pour le service Kerberos (**protocole d'authentification**)
    - `_gc._tcp.computerelectronics.be` pour le catalogue global (**service qui fournit des informations sur les objets de l'annuaire**, tel que les utilisateurs, les groupes, etc.)
    - `_kpasswd._tcp.computerelectronics.be` pour le service de changement de mot de passe (**protocole de communication** pour changer le mot de passe d'un utilisateur)


  - Ils permettent de trouver l'**adresse IP du service** en fonction du nom de domaine et du nom du service.
  - Par exemple, si un client cherche le contrôleur de domaine `_ldap._tcp.computerelectronics.be`, le serveur DNS renvoie l'adresse IP du contrôleur de domaine.
  - Un autre exemple est `_kerberos._tcp.computerelectronics.be` qui permet de trouver le contrôleur de domaine pour l'authentification Kerberos.
  - Un troisième exemple est `_gc._tcp.computerelectronics.be` qui permet de trouver le contrôleur de domaine pour le service global catalogue (GC).


#### ⚙️ Vérification des services

##### 1. Services essentiels

| Service | Rôle | État attendu |
|---------|-------|---------------|
| AD DS | Service principal d'annuaire | Démarrage auto |
| DNS | Résolution de noms | Démarrage auto |
| Netlogon | Authentification des utilisateurs | Démarrage auto |

##### 2. Dossiers système

| Dossier | Description | Importance |
|---------|-------------|------------|
| **NetLogon** | Fichiers d'authentification | Authentification des utilisateurs |
| **SYSVOL** | Stratégies de groupe | Réplication des GPO |
> 💡 Le dossier **SYSVOL** est partagé entre tous les contrôleurs de domaine et contient :
> - Les stratégies de groupe (GPO)
> - Les scripts de démarrage
> - Les fichiers de configuration système



## 🌐 Configuration DNS

> 💡 AD DS crée automatiquement les zones DNS nécessaires lors de la promotion du serveur.

1. **Zone directe principale**
   - Permet **d'obtenir l'adresse IP** à partir du nom d'hôte  
   - Nom : `computerelectronics.be`
   - Serveur DNS primaire : `dns1.computerelectronics.be` (192.168.0.2)
   - Type : Zone principale Active Directory intégrée
   - Contient les enregistrements pour :
     * Le contrôleur de domaine principal (`dns1`)
     * Les enregistrements SRV pour les services AD DS
     * Les futurs postes clients

> ⚠️ Pour simplifier l'apprentissage, nous utiliserons uniquement `dns1` comme DC principal, bien que `dns2` (192.168.0.3) soit prévu en production.

Maintenant que nous avons configuré notre contrôleur de domaine et ses zones DNS, nous pouvons passer à la gestion des utilisateurs et des ressources. Ces aspects seront traités en détail dans les chapitres suivants.


## 📜 Structure de la base de données

> 💡 La base de données AD DS est divisée en 4 partitions distinctes.

<img src="../diagrams/images/partition_schema.png" alt="Partition Schéma" style="width:10%;" />

### 1. Partition Schéma

> 📖 Définit la structure des objets dans l'annuaire.

#### Classes d'objets principales

| Classe | Description | Exemple | Propriétés |
|--------|-------------|---------|------------|
| Utilisateur | Compte utilisateur | `manuel.dupont` | Nom, mot de passe |
| Groupe | Collection d'objets | `GG-Comptabilite` | Nom, membres |
| Ordinateur | Machine du domaine | `ws-compta-01` | Nom, IP, DN |
   | Unité Organisationnelle (OU) | **Conteneur logique permettant d'organiser les objets et d'appliquer des stratégies GPO** | Comptabilité OU | nom, parent OU
   | Contact | Objet sans compte, utilisé pour stocker des informations de contact | Adolphe Sax | email, téléphone, etc. , **DN** (CN=Adolphe Sax,OU=Contacts,DC=computerelectronics,DC=be), etc. |
   | Partage réseau | Dossier partagé accessible sur le réseau | \\\server\files | permis, chemin, etc. | 

> ℹ️ **Notes importantes**:
> - Le schéma fait partie du catalogue global
> - Le DN (Distinguished Name) identifie chaque objet de manière unique
> - La partition schéma est identique sur tous les DCs

   Ex: La partition de schéma de `dns1` est la même que la partition de schéma de `dns2`, et elle serait la même dans `dns3` si elle existait.

#### 2. **Configuration**
   - Stocke la **topologie** de la forêt
     * Les **domaines et leurs relations**
       - **Cas réel** : Dans une grande entreprise, on aurait `eu.entreprise.com` et `us.entreprise.com` comme des domaines AD distincts
       - **Notre lab** : Un seul domaine AD `computerelectronics.be` avec quatre zones DNS (`eu`, `us`, `dev`, `prod`)

     * Les **liens entre contrôleurs de domaine**
       - **Cas réel** : Quatre DCs (deux en Europe, deux aux USA), chacun gérant son propre domaine avec réplication intra-domaine
       - **Notre lab** : Deux DCs (`dns1` et `dns2`) qui gèrent ensemble toutes les zones DNS, avec réplication entre eux

     * Les **sites** et leur configuration
       - **Cas réel** : Plusieurs sites physiques (EU: 192.168.10.0/24, US: 192.168.20.0/24) connectés par WAN
       - **Notre lab** : Un seul site physique (192.168.10.0/24) contenant nos deux DCs
   
   - C'est **la même** partition sur chaque DC, elle a le même contenu sur tous les DCs

#### 3. **Domaine**
   - Contient **les informations de tous les objets** d'un domaine spécifique :
     * Utilisateurs
     * Ordinateurs
     * Groupes
     * Unités d'organisation
   - Une partition par domaine, autant de partitions de domaines que de domaines dans la forêt 
    
   Ex: nous avons 2 domaines dans la forêt de computerelectronics.be

### 4. Partition Application

> 💡 Stocke les données spécifiques aux applications d'entreprise.

| Application | Usage | Type de données |
|------------|--------|---------------|
| Exchange | Messagerie | Boîtes aux lettres |
| SharePoint | Collaboration | Sites, documents |
| Office 365 | Cloud | Configuration hybride |

## 📖 Le Catalogue Global

> 💡 Cache des attributs fréquemment utilisés pour accélérer les recherches.

<img src="../diagrams/images/catalogue_global.png" alt="Catalogue Global" style="width:50%;" />

### Exemple de réplication

| Objet | Attributs répliqués | Utilité |
|-------|---------------------|----------|
| Utilisateur | Nom, email, titre | Recherche rapide |
| Groupe | Nom, membres | Vérification d'appartenance |
| Ordinateur | Nom, site | Localisation |

Les **attributs répliqués sont sélectionnés en fonction de leur importance** pour :
- La recherche d'objets
- L'authentification des utilisateurs
- L'accès aux ressources

Par exemple, pour un **Utilisateur** :
- Attributs toujours **répliqués** : nom, prénom, nom de connexion
- Attributs **non répliqués** : photo de profil, scripts de connexion


# 🔑 Accès aux ressources du domaine

## Cas pratique : Nouvel employé

> 💡 Exemple concret d'intégration d'un nouvel employé dans l'infrastructure AD.

### Scénario

Ahmed commence à travailler dans le département IT. Pour accéder aux ressources, il a besoin :

| Ressource | Description |
|-----------|-------------|
| Documentation | Serveurs de fichiers |
| Imprimantes | Périphériques réseau |
| Applications | Logiciels métier |

### Infrastructure

- **Serveur** : `dns1.computerelectronics.be`
  - Rôle : Contrôleur de domaine (DC)
  - Service : Active Directory Domain Services
  - État : Installé et configuré

## 💻 Configuration du poste de travail

> 💡 Pour qu'Ahmed puisse accéder aux ressources, l'administrateur doit configurer son poste de travail.

### 1. Configuration réseau

| Paramètre | Valeur | Menu de configuration |
|------------|--------|---------------------|
| IP | `192.168.0.10` | Paramètres Ethernet → Options d'adaptateur |
| DNS | `192.168.0.2` | Options d'adaptateur → DNS |
| Nom | `ws-it-01` | Ce PC → Propriétés → Renommer |
| Suffixe | `computerelectronics.be` | Propriétés → Paramètres avancés |

### 2. Jonction au domaine

1. Ouvrir **Propriétés système**
2. Aller dans **Paramètres avancés**
3. Section **Nom de l'ordinateur** ainsi que le suffixe (`computerelectronics.be`)
4. Sélectionner **Membre du domaine** : `computerelectronics.be`
5. Saisir les identifiants **Domain Admin**

> ⚠️ Redémarrer le poste après chaque étape majeure (changement de nom, jonction au domaine)

### 3. Connexion au domaine

> 💡 Ahmed utilise son compte de domaine pour se connecter. Aucun compte local n'est nécessaire.

| Format | Exemple | Description |
|--------|---------|-------------|
| UPN | `ahmed@computerelectronics.be` | Format moderne (recommandé) |
| NetBIOS | `computerelectronics\ahmed` | Format classique |



#### Qu'est-ce qu'on gagne alors quand on se connecte au DC?

- Pouvoir ****accéder aux ressources partagés**** du serveur (dossiers, imprimantes, applications...) 

- L'application des **politiques de sécurité** (ex: pare-feu)
- Un suivi de son activité par le serveur sous forme de logs

## Annexe. Communication entre zones 

**Dans notre infrastructure, les contrôleurs de domaine gèrent l'authentification pour toutes les zones** :

1. **Flux d'authentification**
   - Un utilisateur sur `ws-compta-01.computerelectronics.be` (192.168.10.128)
   - Se connecte via le DC `dns1.computerelectronics.be` (192.168.0.2)
   - Peut accéder aux ressources de toutes les zones

2. **Résolution DNS**
   - Les requêtes DNS passent toujours par les DCs
   - Les DCs maintiennent les zones pour tous les sous-domaines
   - Exemple : accès à `fileserver-us.computerelectronics.be` depuis la zone EU

1. **Routage inter-zones**
   - Communication directe entre les réseaux via le routeur central
   - Pas de NAT entre les zones (tout en 192.168.x.0/24)
   - Les ACLs réseau peuvent filtrer le trafic si nécessaire


Les zones DNS créées sont visibles dans le diagramme de l'infrastructure :

![Diagramme des zones DNS](../diagrams/images/structure_reseau_geographic_zones.png)
