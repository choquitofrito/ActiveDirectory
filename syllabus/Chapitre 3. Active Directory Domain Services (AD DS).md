## Objectifs Pédagogiques

À la fin de ce chapitre, vous serez capable de :
1. Installer et configurer AD DS sur Windows Server 2022
2. Créer et gérer un domaine `computerelectronics.be`

<br>

# 1. Introduction à Active Directory

Nous avons déjà parlé de Active Directory: **AD est une suite de services qui permettent de gérer** :
 
* La gestion des utilisateurs
* La gestion des ordinateurs
* La gestion des ressources
* La gestion des stratégies de sécurité
* La gestion des services réseau
etc...


**On le confond souvent avec** **AD DS** (le service de base qui crée et gère la base de données d'AD), mais AD est plus large car il contient :
 
1. **AD DS** **(Active Directory Domain Services)** : Service principal gérant l'authentification et l'autorisation des ressources dans le réseau.
2. **AD LDS** (Lightweight Directory Services) : Version allégée d'AD DS fonctionnant sans domaine Windows.
3. **AD CS** (Certificate Services) : Gestion des certificats numériques et de l'infrastructure à clé publique (PKI).
4. **AD RMS** (Rights Management Services) : Protection et contrôle des droits d'accès aux documents.
5. **AD FS** (Federation Services) : Authentification unique (SSO) et fédération d'identités entre organisations.

**La force d'Active Directory** réside dans sa capacité à **centraliser l'administration**. Au lieu de gérer chaque ordinateur individuellement, les administrateurs peuvent appliquer des politiques et des configurations à partir d'un point central.

<br>

# 2. Exemple de fonctionnement d'AD : appel client-serveur

Considérez notre structure de réseau :

![Forêt](../diagrams/images/structure_reseau_geographic_zones.png)

Voyons un flux client-serveur avec Active Directory.

Dans cet exemple, un utilisateur essaie d'accéder au serveur de fichiers.
Observez les flèches en bleu, jaune et bleu bidirectionnel.
**Pas les flèches vertes pour le moment**

![Intégration DNS-AD DS](../diagrams/images/ad_auth_flow.png)

1. **Authentification** (flèche bleue)
   - `ws-compta-01` (`192.168.0.101`) demande une authentification à `dns1` (`192.168.0.2`)
   - `dns1.computerelectronics.be`, en tant que contrôleur de domaine, traite la demande
   - L'authentification utilise le protocole Kerberos
   - La communication passe par le switch départemental (`SW-COMPTA`, `192.168.0.1`)

2. **Accès aux ressources** (flèche jaune)
   - Une fois authentifié, `ws-compta-01` accède au serveur `fileserver.us.computerelectronics.be`
   - `dns2` fournit l'adresse IP de `fileserver.us.computerelectronics.be` (`192.168.0.41`)
   - Le serveur `fileserver.us.computerelectronics.be` autorise l'accès aux ressources demandées

3. **Réplication AD** (flèche bleue bidirectionnelle)
   - `dns1` (`192.168.0.2`) et `dns2` (`192.168.0.3`) synchronisent leurs bases AD DS
   - Cette réplication assure :
     * La cohérence des données entre les contrôleurs
     * La disponibilité du service même si un DC tombe en panne !

Les flèches vertes rajoutées montrent les **requêtes** DNS permettant la résolution des noms (DNS) nécessaire à chaque étape. On ne voit pas les réponses pour ne plus compliquer le diagramme :

1. Le PC interroge `dns1` pour chercher son DC, qui gère l'authentification
2. Une fois authentifié, le PC interroge `dns1` pour chercher l'adresse IP du serveur de fichiers. `dns1` ne le connaît pas 
3. `dns1` interroge alors `dns2`
4. `dns2` fournit l'adresse IP du serveur de fichiers. Le PC accède au serveur de fichiers.

<br>

# 3. Active Directory Domain Services (AD DS)

Dans ce cours, **nous nous concentrerons sur AD DS car c'est le service fondamental** pour la gestion de l'infrastructure de computerelectronics.be. 

**Le service AD DS est un service d'AD qui crée et gère la base de données d'AD.**. 

1. AD DS permet :
   - L'authentification centralisée des utilisateurs
   - La gestion des ressources réseau
   - L'application des stratégies de sécurité
   - L'organisation hiérarchique des ressources

2. AD DS stocke les informations sur :
   - Les utilisateurs (employés, prestataires, etc.)
   - Les ordinateurs (postes de travail, serveurs)
   - Les ressources partagées (imprimantes, dossiers)
   - Les stratégies de sécurité
   - Les services réseau

Pour bien comprendre le déploiement d'AD DS dans notre entreprise, commençons par examiner la structure DNS existante, car AD DS s'appuie fortement sur DNS pour son fonctionnement.


## 3.1. AD DS et la localisation de la base de données d'AD 

La base de données d'AD doit être stockée dans (au moins) un **appareil serveur** qu'on appellera **Contrôleur de Domaine (DC)**.

**Ce suffirait pour gérer les ressources de tout l'arbre DNS, mais** on ne peut pas prendre le risque de perdre la base de données si le serveur tombe en panne ! 

**IMPORTANT** : Ne confondez pas le service DNS et le service AD DS ! **Notez** que le **service DNS** (transformer les noms en IP et vice versa) est **indépendant** **de la base de données d'AD** (base de données contenant toutes les informations sur les utilisateurs, ordinateurs, imprimantes, etc.). 

**On pourrait avoir toute sorte de combinaisons :**
- 3 serveurs DNS et 2 serveurs AD 
- 2 serveurs DNS et 2 serveurs AD
- etc...

**Tant le service DNS comme le service AD DS** doivent fonctionner **sans arrêt** ! Cela veut dire que si un serveur tombe en panne, il faut qu'un autre serveur prenne son rôle. En plus... si un serveur est surchargé, il faut qu'un autre serveur prenne son rôle ! Quoi faire ? **Rajouter des serveurs DNS et des serveurs AD**.

<br>

# 4. Contrôleurs de Domaine

## 4.1. Relations entre DNS et AD DS

Nous allons installer les services d'AD DS sur notre serveur `dns1.computerelectronics.be`.

Il va devenir un **contrôleur de domaine** (DC). Rappellez-vous qu'il contiendra la base de données d'AD. 

Si on a la possibilité on installera AD aussi sur `dns2.computerelectronics.be`, **qui contiendrai une réplique de la base de données d'AD**. Ou peut-être même sur d'autres serveurs si on les avait !

Concernant les services de DNS, **chaque DC peut gérer une ou plusieurs zones**. Dans notre cas `dns1` gére tout le réseau

Ce diagramme representera l'installation de AD sur `dns1.computerelectronics.be` :

![Installation AD](../diagrams/images/dns_ad_installation.png)


## 4.2. Promotion de Windows Server en contrôleur de domaine

### 4.2.1. Configuration du DNS dans le réseau du serveur

On doit configurer le réseau du DC `dns1.computerelectronics.be`:
   - Donnez une adresse IP statique au réseau LAN via l'interface graphique du Gestionnaire de Serveur 
     - Serveur Local->Ethernet->Propriétés->Protocole Internet version 4 (TCP/IPv4) 
   - On lui donnera `192.168.0.2` au lieu d'une adresse automatique
   - Spécifiez le serveur DNS; `192.168.0.2` (le serveur lui-même)
   - Nom d'ordinateur configuré via les Paramètres système (si ce n'est pas déjà fait!)
     - Dans le champ "Nom de l'ordinateur", tapez : **dns1**
     - Dans le champ "Suffixe DNS principal", tapez : **computerelectronics.be**
   
Pour le serveur DNS, on lui donnera `192.168.0.2` au lieu d'une adresse automatique: car **il cherchera les noms DNS chez lui-même**, y incluant le sien: `dns1.computerelectronics.be`.


### 4.2.2. Installation du rôle AD DS

Cette étape va installer **le rôle** AD DS sur le serveur `dns1.computerelectronics.be`. 

Un **rôle est un ensemble de fonctionnalités, programmes et services** qui permettent au serveur d'accomplir une fonction spécifique. 

Dans ce cas, le rôle AD DS comprend plusieurs services (comme le service AD DS lui-même) qui seront activés après la promotion en contrôleur de domaine.

1. Ouvrir le **Gestionnaire de serveur**
2. Cliquer sur **"Gérer"** puis **"Ajouter des rôles et fonctionnalités"**
3. Sélectionner **"Installation basée sur un rôle ou une fonctionnalité"**
4. Choisir le serveur **`dns1.computerelectronics.be`**
5. Suivre l'Assistant jusqu'à **"Rôles de serveurs"**
6. Cocher **"Services AD DS"**
7. Accepter l'ajout des fonctionnalités requises
8. Continuez jusqu'à la fin de l'installation

### 4.2.3. Promotion en contrôleur de domaine

1. Dans le Gestionnaire de serveur, cliquer sur le **drapeau avec le triangle jaune**
2. Sélectionner **"Promouvoir ce serveur en contrôleur de domaine"**
3. Choisir **"Ajouter une nouvelle forêt"**
4. Saisir le nom de domaine : **`computerelectronics.be`**
5. Choisir le **niveau fonctionnel** de la forêt et du domaine (la plus récente)
6. Définir le **mot de passe DSRM** (Password1!)
7. Continuez et ignorez l'avertissement sur les délégations
8. Choisir le nom pour le domaine NETBIOS : **"COMPUTERRELECTRONICS"**
9. Vérifier les chemins de la **base de données**, des **journaux** et de **SYSVOL**
10. Examiner les options sélectionnées et **lancer l'installation**

### 4.2.4. Vérification post-promotion

Une fois la promotion terminée et le serveur redémarré, il est essentiel de vérifier que tout fonctionne correctement. Voici les étapes de vérification à suivre. Ouvrez le Gestionnaire de serveur et cliquez sur le nouveau menu: **AD DS**. 

**Vérification de la configuration DNS (Gestionnaire de serveur->Outils->Gestionnaire DNS):**

1. Vérifiez dans le gestionnaire DNS que **l'enregistrement A** pour `dns1.computerelectronics.be` pointe correctement vers `192.168.0.2` 

2. Vérifiez la résolution du nom de domaine -> le serveur trouve l'**adresse IP** du serveur `dns1.computerelectronics.be`

```powershell
nslookup dns1.computerelectronics.be
```

3. Lancez un diagnostique complet des services DNS d'Active Directory
```powershell
dcdiag /test:dns
```

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


### 4.2.5. Vérifier que les services sont bien configurés

1. Vérifier que les services principales d'AD DS sont en cours d'execution et en démarrage auto:
  - Service de AD DS
  - Service DNS
  - Netlogon, qui gére l'authentification des utilisateurs
  
2. Vérifier que **les dossiers NetLogon** et **Sysvol** existent et sont correctement configurés
   - **NetLogon** : dossier qui contient les **fichiers de logon** de l'annuaire, **utilisé pour l'authentification** des utilisateurs
   - **Sysvol** : dossier qui contient les fichiers de configuration du système (politiques de groupe qui seront utilisées dans les GPOs, scripts de démarrage, etc.) et qui est partagé par tous les contrôleurs de domaine du domaine



### 4.3. Configuration des zones DNS

Après la promotion du contrôleur de domaine, AD DS a automatiquement créé les zones DNS nécessaires. Examinons la configuration qui a été mise en place :

1. **Zone directe principale**
   - Permet **d'obtenir l'adresse IP** à partir du nom d'hôte  
   - Nom : `computerelectronics.be`
   - Serveur DNS primaire : `dns1.computerelectronics.be` (192.168.0.2)
   - Type : Zone principale Active Directory intégrée
   - Contient les enregistrements pour :
     * Le contrôleur de domaine principal (`dns1`)
     * Les enregistrements SRV pour les services AD DS
     * Les futurs postes clients

**Note pratique** : Bien que notre infrastructure de production inclue `dns2.computerelectronics.be` (192.168.0.3), nos exercices pratiques se concentreront initialement sur le contrôleur de domaine principal `dns1` pour une meilleure compréhension des concepts de base.

Maintenant que nous avons configuré notre contrôleur de domaine et ses zones DNS, nous pouvons passer à la gestion des utilisateurs et des ressources. Ces aspects seront traités en détail dans les chapitres suivants.


## 4.4. Structure de la base de données d'Active Directory


### 4.4.3. Les partitions


La base de données qui stocke Active Directory est divisée en **4 partitions**:
<br>

<img src="../diagrams/images/partition_schema.png" alt="Partition Schéma" style="width:10%;" />


#### 1. **Schéma**
   - **Définit la structure** possible **des objets** dans l'annuaire. 
      
   Chaque **objet** a une **classe** qui lui fournit des **propriétés**

    . Voici les principales classes dans AD :

   | **Classe** | Description | Example d'objet | Propriétés objet|
   | --- | --- | --- | --- |
   | Utilisateur | Compte utilisateur dans le domaine | Manuel Dupont| Nom, mot de passe, etc. |
   | Groupe | Ensemble d'utilisateurs ou d'autres groupes pour gérer les permissions | Administrateurs | Nom, type, portée, membres, etc. |
   | Ordinateur | Poste de travail ou serveur joint au domaine | ws-01-compta | Nom, adresse IP, **DN** (CN=ws-01-compta,OU=Computers,DC=computerelectronics,DC=be), etc. |
   | Unité Organisationnelle (OU) | **Conteneur logique permettant d'organiser les objets et d'appliquer des stratégies GPO** | Comptabilité OU | nom, parent OU
   | Contact | Objet sans compte, utilisé pour stocker des informations de contact | Adolphe Sax | email, téléphone, etc. , **DN** (CN=Adolphe Sax,OU=Contacts,DC=computerelectronics,DC=be), etc. |
   | Partage réseau | Dossier partagé accessible sur le réseau | \\\server\files | permis, chemin, etc. | 

   - **Le schéma est une partition du catalogue global** (expliqué plus bas). 
  
   - **Sur la propriété DN**: la propriété DN (Distinguished Name) est présente pour chaque objet, car c'est la propriété qui **permet de l'identifier de manière unique** dans l'annuaire.



   - C'est **la même** partition sur chaque DC, elle a le même contenu sur tous les DCs

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

#### 4. **Application**
   - Contient les informations des applications
   - Configurable selon les besoins spécifiques

   Exemples d'applications qui utilisent la partition d'application :
   - Microsoft Exchange (mail)
   - Microsoft SharePoint (collaboration)
   - Microsoft Office 365 (cloud)




## 4.4.3. Le Catalogue Global

Le catalogue global est un **composant** essentiel d'Active Directory **qui stocke une copie partielle des attributs les plus utilisés de tous les objets de la base de données annuaire**. 

Il facilite la **recherche d'objets** dans une forêt Active Directory.

<img src="../diagrams/images/catalogue_global.png" alt="Catalogue Global" style="width:50%;" />

**Exemple :** Un objet de type (**classe**) Utilisateur comme "Laurent Lambert" aura ses attributs principaux répliqués dans le catalogue global pour une recherche rapide à travers tous les domaines.

Les **attributs répliqués sont sélectionnés en fonction de leur importance** pour :
- La recherche d'objets
- L'authentification des utilisateurs
- L'accès aux ressources

Par exemple, pour un **Utilisateur** :
- Attributs toujours **répliqués** : nom, prénom, nom de connexion
- Attributs **non répliqué**s : photo de profil, scripts de connexion

## 5. Annexe. Communication entre zones 

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


# 5. Joindre des machines au domaine

Pour un premier test, nous joindrons la machine `ws-compta-01` au domaine `computerelectronics.be`.

La suite d'opérations est la suivante :

1. Donner un nom à la machine Client (ex: `ws-compta-01`)
2. Changer le suffixe de domaine (ex: `.computerelectronics.be`)
3. Changer son IP (ex: `192.168.0.10`)
4. Taper le domaine (ex: `computerelectronics.be`) - on abandonne le Workgroup
5. Tapez les crédentielles d'un Utilisateur du domaine qui a des droits de domaine (le seul qu'on a est l'Adminstrateur)
6. Redemarrer la machine
7. Se connecter en tapant `computerelectronics.be\user01`

La machine a rejoint le domaine `computerelectronics.be`... mais on n'a aucun utilisateur dans le domaine.

Créez un utilisateur AD depuis le `Centre d'administration d'Active Directory`