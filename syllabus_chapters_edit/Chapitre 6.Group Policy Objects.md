# Chapitre 6: Les Stratégies de Groupe (GPO)

> 📚 **Dans ce chapitre:**
> 1. 🌐 [Introduction aux GPO](#1-introduction-aux-gpo)
>    - Concepts de base
>    - Types de stratégies
> 2. 🔰 [Hiérarchie et Application](#2-hiérarchie-et-application)
>    - Niveaux d'application
>    - Ordre de traitement
> 3. 💻 [Configuration des GPO](#3-configuration-des-gpo)
>    - Outils de gestion
>    - Exemples pratiques

---

## 📑 Objectifs Pédagogiques

À la fin de ce chapitre, vous serez capable de :
1. Comprendre le rôle et l'utilité des GPO
2. Maîtriser la hiérarchie des stratégies
3. Configurer et gérer des GPO

---

## 1. Introduction aux GPO

### 🌐 1.1. Qu'est-ce qu'une Stratégie de Groupe ?

Une GPO est aussi un objet qu'on peut créer dans la base de données de AD-DS et qui a les capacités suivantes:

| 🛠️ Capacités | Description |
|------------|-------------|
| 💻 **Configuration** | Gérer de manière centralisée les configurations |
| 🔒 **Sécurité** | Appliquer des paramètres de sécurité |
| 💾 **Déploiement** | Déployer des logiciels |
| 🖥️ **Scripts** | Configurer des scripts de démarrage/arrêt |

> 💡 **Principe clé**: Modifier **un seul GPO** pour configurer **plusieurs machines ou utilisateurs**!



### 1.2. Exemples d'application


| Catégorie | Description Détaillée | Exemples |
|-----------|---------------------|----------|
| **Sécurité** | Implémente les politiques de sécurité de l'entreprise : complexité des mots de passe, restrictions d'accès, paramètres de pare-feu, etc. | Obligation de mots de passe complexes (12 caractères min.), configuration du pare-feu d'entreprise |
| **Configuration Utilisateur** | Configure l'environnement de travail des utilisateurs : fond d'écran, paramètres Office, mappages de lecteurs réseau. | Application du fond d'écran d'entreprise, mappage automatique des lecteurs réseau par département |
| **Configuration Système** | Gère les paramètres système : services Windows, paramètres réseau, configuration des mises à jour. | Activation/désactivation des services d'impression |
| **Déploiement** | Automatise l'installation et la mise à jour des applications, pilotes et correctifs sur les postes clients. | Installation automatique de la suite Office 365, mise à jour automatique des logiciels Adobe |
| **Restrictions** | Contrôle l'accès aux fonctionnalités système et applications selon les besoins métier et la sécurité. | Désactivation des ports USB pour le service RH, restriction de l'accès à PowerShell |
| **Automatisation** | Automatise les tâches via des scripts exécutés à des moments spécifiques (connexion, démarrage, etc.). | Exécution de scripts de connexion pour mapper les lecteurs, sauvegarde automatique des fichiers utilisateurs |


### 1.3. Qui est affecté par les GPOs? Definition de site AD

### 1.3. Qui est affecté par les GPOs ? Définition d’un site AD  

Les **stratégies de groupe peuvent être appliquées à différents niveaux** de la hiérarchie AD : un ordinateur, un **site**, un domaine AD, une OU...  

Pour bien comprendre la relation entre les différents concepts, faisons une mise en parallèle :

1. **Domaine AD vs Zone DNS** :

   - **Zone DNS** : Structure de résolution de noms
     * Exemple : computerelectronics.be (même nom mais concept différent) avec ses sous-domains
     * Contient : Enregistrements DNS (A, CNAME, etc.)
     * But : Résolution des noms en adresses IP



   - **Domaine AD** : Structure logique de sécurité et d'administration
     * Exemple : computerelectronics.be
     * Contient : utilisateurs, ordinateurs, groupes, OUs
     * But : Gestion des authentifications et autorisations


![Domaine AD](../diagrams/images/domaineAD.png)

1. **Site AD vs Sous-zone DNS** :
   - **Site AD** : 
     * Représente une localisation physique
     * Défini par des sous-réseaux IP (ex: 192.168.10.0/24)
     * But : Optimisation du trafic et de la réplication

   - **Zone DNS** : 
     * Section d'un espace de noms DNS (ex: computerelectronics.be)
     * But : Organisation hiérarchique des noms

Dans notre infrastructure :
- **Domaine AD** et **Zone DNS** principale : computerelectronics.be
- **Sites AD** : site EU (192.168.10.0/24) et site US (192.168.20.0/24)
- **Zones DNS** : Zone EU (`eu.computerelectronics.be`), Zone US (`us.computerelectronics.be`)

Ces concepts sont distincts mais complémentaires dans une infrastructure d'entreprise.

Dans notre laboratoire de pratique, le domaine AD correspond au **site EU**, et nous avons un seul site (nous avons utilisé les ips `192.168.0.x` au lieu de  `192.168.10.x`), mais peu importe.  


Nous avions convenu que les deux sites/zones seraient gérés par un seul contrôleur de domaine (`dns1`, le DC du labo) et, en théorie, un second en réplication (`dns2`).  

Ces serveurs doivent gérer les deux sites et sont physiquement **chez nous**.  

**Dans un environnement réel, nous aurions au moins deux autres DCs** : `dns3` et `dns4`, qui seraient situés physiquement aux États-Unis.  
Les quatre DCs peuvent gérer les deux sites et partager la même base de données AD. Deux sont situés en Europe et les deux autres aux États-Unis.  

#### Et alors on doit re-créer la BD d'active Directory partout??

**NON!**

La **séparation** en sites n'a **pas d'impact** sur la BD.

Pourquoi? Car **les objets AD (comme les OU) sont stockés dans la base de données du DC**, qui est **la même** (copie) dans tous les DCs de la même forêt, ce qui implique que **la configuration des OUs est la même dans tous les DCs, peu importe le site.**.

**En gros:** On peut créer toute la structure (EU et USA) des OUs dans le seul DC de notre labo. Si on rajoutait un autre DC (`dns3`) pour le site USA il aurait la même configuration AD que le DC du site EU (on ne devrait pas la ré-creer sur le nouveau DC).

Notre site porte le nom `Default First Site Name` (Barre de tache->`Server Manager`->`Sites`->`Sites et services`->`Sites`) , nom donnée par AD-DS lors la création du domaine. 

Ce sera notre site pour l'Europe, **alors renommez-le à `Site-EU`** (click droit sur le site->`Rename`).
On pourrait créer un autre site si on avait un autre adaptateur réseau, chacun associé a un sous-réseau, mais ce n'est pas le but de notre labo.

Connaissant la notion de site, continuons maintenant avec la classification des GPOs.

## 2. Création des GPOs

Nous allons étudier les caractéristiques des GPOs en détail plus tard, mais commençons par créer une GPO d'example.

Avant de commencer, assurez-vous d'avoir installé le laboratoire en suivant les instructions du document d'installation Labo_structure.md

### Exemple pratique: restreindre le panneau de configuration pour les membres de Ventes



Créons une GPO. La suite d'opérations sera la suivante:

- Créer une GPO nommée `GPO-Restrictions-VentesPC` et liée à l'OU Ventes
- Modifier la GPO (vide au départ): elle doit empêcher l'accès des utilisateurs de Ventes aux éléments suivants du panneau de configuration:
   - Programmes et fonctionnalités
   - Système
- Appliquer la GPU
- Se connecter au serveur avec un user de Ventes et vérifier que le panneau de configuration est restreint

Voici les pas en détails: 

1. Ouvrir le `Gestionnire de Serveur` > `Outils` > `Gestion de stratégies de groupe`
2. Cliquer sur la `Forèt` > `Domaines` > `computerelectronics.be`
3. Deployer l'UO `EU` (Europe)
4. Clique droit sur l'OU `User` dans `Ventes` > `Créer un objet GPO dans ce domaine et le lier ici`
5. Nommez la GPO `GPO-Panneau-Restreint` (par exemple)
6. Deployer la OU `Users` dans `Ventes`, observez qu'il y a un élément qui porte le nom `GPO-Panneau-Restreint`. Cet élément est **un lien** vers la GPO qui se trouve à cet endroit pour indiquer que la GPO s'applique à cett unité d'organisation. 

**Note:** La **vraie** GPO se trouve dans l'arbre, dans le folder `Objets de Strategie de groupe`. Ceci permet de **lier/délier cette GPO à une ou plusieurs OUs** (ex: si on veut limiter le panneau de configuration aux Users de `Ventes` et `RH` mais pas à ceux de `Comptabilité`). On fera ça plus tard.

7. Clique droit sur la GPO `GPO-Panneau-Restreint` et sélectionnez `Modifier`
8. Cliquez sur `Configuration de l'utilisateur` > `Stratégies` > `Modeles d'administration` > `Panneau de configuration` > `Masquer les éléments ...` 
9. Cliquez sur `Activer`, puis sur `Afficher`   
10. Rajoutez `Système` et `Programmes et fonctionnalités` à la liste (tapez-les à la main)
11. Clique sur `Ok` > `Appliquer`

Maintenant on se connecte avec un client du département Ventes sur la MV Windows (ex: victor)

1. Connectez-vous avec un user de `Ventes` (victor)
2. Ouvrez une console et lancez `gpupdate /force` pour recevoir les GPOs du serveur
3. Faites logout et connectez-vous à nouveau (même user)
4. Ouvrez le panneau de configuration et cliquez sur `Système`
 ou `Programmes et fonctionnalités`. Ils devraient être vides.

Faites la même procedure avec un user de `Comptabilité` (ex: christophe). Le panier de configuration ne devrait pas être restreint.

On peut voir les politiques appliquées sur un utilisateur avec la commande `gpresult /r` (console ordinateur client)


**ATTENTION**: Deux points vitaux

1. Une GPO affecte **les ordinateurs et les utilisateurs liés à l'OU** sur laquelle la GPO est liée **et à ses sous-OUs**. Si l'OU contient uniquement de groupes elle ne sera pas appliquée aux utilisateurs de ces groupes.

2. Si une GPO contient uniquement des paramètres Utilisateur et elle est liée à une OU contenant seulement des ordinateurs, la GPO n'aura aucun effet.



## 3. Classifications des GPO

Pour pouvoir gérer proprement les GPOs on doit comprendre comment elles sont appliquées.


Les GPO sont appliquées dans l'ordre LSDO (du plus général au plus spécifique) :
- **L**ocal (le plus **général**)
- **S**ite (EU, USA)
- **D**omaine (un domaine AD a plusieurs sites)
- **O**U (le plus **spécifique**)

> **Note**: Dans chaque niveau, une GPO peut contenir des paramètres de configuration ordinateur (Computer Configuration) et/ou des paramètres de configuration utilisateur (User Configuration). Ce sont deux sections distinctes dans la GPO, pas des niveaux de liaison.

**Point clé**: Les politiques définies dans chaque niveau peuvent être **écrassées** par celles du niveau suivant.

**Exemples** d'écrasement de politiques :
- Un ordinateur configuré en **locale** qui n'a pas de restrictions pour accéder au Panneau de configuration peut se voir bloquer cet accès par une GPO de **domaine** (on applique toujours la politique la plus restrictive)
- Une politique de mot de passe définie au niveau du **domaine** (8 caractères) peut être renforcée au **niveau OU** Comptabilité (12 caractères)


**Détail de l'ordre d'application LSDOU :**

1. **Local** (le plus général)
   - Paramètres de base de Windows
   - S'applique avant toute politique AD
   - Peut être écrasé par les politiques suivantes
   - *Exemples* : 
     * Pare-feu Windows par défaut
     * Options d'alimentation de base

2. **Site**
   - Configuration géographique
   - Concerne tous les objets d'un site physique
   
   
   - *Exemples de GPO de Site* : 
     * Configuration du proxy pour le site EU (192.168.10.0/24)
     * Serveurs d'impression locaux du site US (192.168.20.0/24)

   > ⚠️ **Attention** : Ne pas confondre !
   > - Un **Site** AD = zone physique réseau (ex: Site-EU avec subnet 192.168.10.0/24)
   > - Une **OU** EU = structure logique organisationnelle

3. **Domaine**
   - Politiques globales de l'organisation
   - S'applique à tous les objets du domaine AD (utilisateurs, ordinateurs, groupes)
   - *Exemples* : 
     * Politique de mot de passe globale du domaine AD
     * Installation de l'antivirus

4. **OU**
   - Configurations départementales
   - Plus spécifique que le domaine
   - *Exemples* : 
     * Logiciels comptables pour l'OU Comptabilité
     * Accès aux dossiers RH pour l'OU RH

5. **User** (le plus spécifique)
   - Paramètres individuels
   - Dernier niveau d'application
   - *Exemples* : 
     * Mappage de lecteurs personnels
     * Restrictions d'accès spécifiques

Voici encore des exemples sur un tableau, du plus général au plus spécifique :

| Cible de Liaison | Périmètre d'Application | Exemple de GPO |
|------------------|------------------------|----------------|
| **Local** | Politiques définies localement sur chaque ordinateur. Appliquées en premier mais rarement utilisées en environnement AD. | Paramètres de base Windows, configurations par défaut |
| **Site** Active Directory | Un domaine AD peut avoir plusieurs sites (EU, USA). Ce type de GPO **s'applique aux objets dans un site AD physique**. Utile pour des configurations spécifiques à une localisation géographique. | Configuration du proxy pour le site de Paris, paramètres d'impression pour le bâtiment Europe |
| **Domaine** Active Directory | S'applique à tous les objets du domaine AD. Idéal pour les politiques de sécurité globales et les configurations d'entreprise. | Règles de sécurité pour tout le domaine (antivirus, pare-feu), politique de mot de passe pour tous les utilisateurs |
| **Unité d'Organisation (OU)** | S'applique aux objets dans l'OU spécifiée et ses sous-OUs. Permet une gestion granulaire par département ou fonction. | Installation des logiciels comptables pour l'OU Comptabilité, restrictions d'accès pour l'OU RH |



## 4. 📌 Clarification des stratégies GPO dans Active Directory

Les deux grandes catégories de stratégies GPO sont: 

### 1️⃣ **Configuration ordinateur**  
- S'applique aux machines, **indépendamment de l’utilisateur** qui se connecte.
- Exemples : paramétrage des services Windows, pare-feu, gestion des mises à jour.

### 2️⃣ **Configuration utilisateur**  
- S'applique aux **utilisateurs** lorsqu'ils se connectent à une machine, **indépendamment de l'ordinateur**.
- Exemples : restriction d'accès à certains programmes, redirection de dossiers.

💡 **Un même GPO peut contenir des paramètres dans les deux catégories, mais ils ne s'appliquent qu’aux objets auxquels ils sont liés (ordinateurs ou utilisateurs).**


### Les sous-menus de chaque catégorie
Chaque catégorie (ordinateur et utilisateur) contient les mêmes sous-sections principales :

#### **Stratégies (Policies)**
- Contient des paramètres **fortement gérés** par l’administrateur.
- Stockés dans la base de registre sous `Policies`.
- Priorité élevée : Windows réapplique la règle même si l’utilisateur tente de la modifier.
- Exemples : paramétrage des services Windows, pare-feu, gestion des mises à jour.

#### **Préférences (Preferences)**
- Contient des paramètres **moins stricts**, modifiables par l'utilisateur.
- Écrit dans la base de registre **hors "Policies"**, donc modifiable après application.
- Exemples : configuration des imprimantes, mappage de lecteurs réseau.

#### 🔧 **Modèles d'administration (Administrative Templates)**
- **Ensemble de définitions de paramètres GPO** au format ADMX/ADML
- Peuvent être appliqués soit comme stratégies (forcés), soit comme préférences (modifiables)
- L'administrateur choisit le mode d'application lors de la configuration
- Permettent une gestion centralisée sans modification directe du registre Windows

---

### 4.1. Stratégies

#### 📌 Configuration Ordinateur > Stratégies

✔ **Paramètres Logiciel**  

- Déploiement de logiciels

✔ **Paramètres Windows**  
- Scripts (au démarrage et à l’arrêt)
- Paramètres de sécurité (ex. stratégie de mot de passe, pare-feu Windows)
- Configuration du pare-feu


✔ **Modèles d’administration (Administrative Templates)**  

- Configuration des services système
- Restriction sur l’installation des pilotes
- Paramètres de Windows Update

**Exemples :**  
- **Désactiver l'installation automatique des imprimantes réseau** : *Configuration ordinateur > Strategies > Modèles d’administration > Imprimantes > Empêcher l’ajout automatique des imprimantes réseau*.
- **Forcer une mise à jour Windows automatique** : *Configuration ordinateur > Strategies > Modèles d’administration > Composants Windows > Windows Update > Configurer les mises à jour automatiques*.

#### 📌 Configuration Utilisateur > Stratégies

✔ **Paramètres Logiciel**  

- Déploiement de logiciels

✔ **Paramètres Windows**  
- Scripts (à l'ouverture et à la fermeture de session)
- Redirection de dossiers
- Paramètres de sécurité (ex. interdire l'accès au panneau de configuration)

✔ **Modèles d’administration (Administrative Templates)**  
- Restriction d'accès à certaines applications
- Paramètres d’interface (ex. masquer les paramètres système)
- Gestion des extensions de navigateur

**Exemples :**  
- **Désactiver la modification du fond d’écran** : *Configuration utilisateur > Modèles d’administration > Panneau de configuration > Personnalisation > Empêcher la modification du papier peint*.
- **Restreindre l’accès au gestionnaire de tâches** : *Configuration utilisateur > Modèles d’administration > Système > Options Ctrl+Alt+Suppr > Supprimer le Gestionnaire des tâches*.


#### 🛑 **Piège courant : le filtrage GPO par cible**
⚠️ Une erreur fréquente est d’appliquer une GPO contenant des paramètres **"Configuration utilisateur"** sur une **Unité Organisationnelle (OU) contenant uniquement des ordinateurs**, ou vice versa.

💡 **Solution : utiliser "Boucle de rappel utilisateur" (Loopback Processing)**  
👉 Cela permet de forcer l'application des paramètres utilisateur sur un ordinateur, même si la GPO est liée à une OU contenant des ordinateurs.

---

### 4.2. Préférences (Preferences)
- Contient des paramètres **moins stricts**, modifiables par l'utilisateur
- Écrit dans la base de registre **hors "Policies"**, donc modifiable après application
- Exemples : configuration des imprimantes, mappage de lecteurs réseau

**Exemple pratique** :
```
Configuration utilisateur > Préférences > Paramètres Windows > Lecteurs réseau
Action: Créer
Emplacement: \\srv-files\commun
Lettre: Z:
```
L'utilisateur peut modifier la lettre du lecteur si nécessaire.

### 4.3. Modèles d'administration (Administrative Templates)
- **Ensemble de définitions de paramètres GPO** au format ADMX/ADML
- Peuvent être appliqués soit comme stratégies (forcés), soit comme préférences (modifiables)
- L'administrateur choisit le mode d'application lors de la configuration
- Permettent une gestion centralisée sans modification directe du registre Windows

**Exemple pratique** :
```
Configuration utilisateur > Stratégies > Modèles d'administration > Menu Démarrer et Barre des tâches
Paramètre: Supprimer l'accès à "Exécuter"
Valeur: Activé

Résultat: Les utilisateurs ne peuvent plus utiliser la commande Exécuter (Windows + R)
```



## **Résumé final en une image mentale**
🔹 **Configuration ordinateur** = Gère le PC et ses paramètres système.  
🔹 **Configuration utilisateur** = Gère l'expérience de l’utilisateur.  
🔹 **Stratégies (Policies)** = Restrictions strictes, contrôlées par l’admin.  
🔹 **Préférences (Preferences)** = Configurations plus souples, modifiables par l'utilisateur.
🔹 **Boucle de rappel utilisateur** = Force l'application des paramètres utilisateur sur un ordinateur, même si la GPO est liée à une OU contenant des ordinateurs.
🔹 **Modèles d'administration (Administrative Templates)** = Modèles contenant des paramètres modifiables par l'utilisateur.

## 5. Filtrage des GPOs 

Une fois qu'une GPO est liée à un niveau (Site, Domaine ou OU), on peut affiner son application avec deux méthodes de filtrage :

1. **Filtrage de Sécurité**
   - Permet de cibler des groupes de sécurité spécifiques
   - Exemple : Appliquer une GPO uniquement aux membres du groupe "Vendeurs Senior"

2. **Filtrage WMI (Windows Management Instrumentation)**
   - Permet de filtrer selon des critères techniques
   - Exemples : 
     * Appliquer une GPO uniquement aux ordinateurs Windows 11
     * Appliquer des paramètres d'économie d'énergie uniquement aux ordinateurs portables

> **Note importante** : En cas de conflit entre GPO, la règle est simple : la dernière GPO appliquée (la plus spécifique) l'emporte sur les précédentes.
