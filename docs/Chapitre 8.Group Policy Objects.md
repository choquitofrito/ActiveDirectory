# Chapitre 8: Les Stratégies de Groupe (GPO)

## 🧭 Navigation du Cours
[⏮️ Chapitre Précédent: Gestion des Utilisateurs](Chapitre%207.Gestion_des_Utilisateurs.md) | [🏠 Retour au Syllabus](index.md) | [⏭️ Chapitre Suivant: PowerShell AD](Chapitre%209.0.Powershell%20AD%20-%20Introduction.md)


!!! example "Exercices associés"
    Trois séries d'exercices progressifs :

    - **[GPO Série 1](Labo%20et%20Exercices/Exercices:%20GPO-1.md)** - Templates administratifs, sécurité, déploiement logiciel
    - **[GPO Série 2](Labo%20et%20Exercices/Exercices:%20GPO-2.md)** - Filtrage et ciblage GPO
    - **[GPO Série 3](Labo%20et%20Exercices/Exercices:%20GPO-3.md)** - Scénarios complexes et troubleshooting

!!! info "📚 Dans ce chapitre:"

    1. [Introduction aux GPO](#1-introduction-aux-gpo)
       - Concepts de base
       - Sites AD

    2. [Création des GPOs](#2-creation-des-gpos)
       - Premier exemple guidé
       - `gpupdate` et `gpresult`

    3. [Ordre d'application des GPO (LSDO)](#3-ordre-dapplication-des-gpo-lsdo)
       - Qui gagne en cas de conflit
       - Blocage et mode Appliqué

    4. [Filtrage](#7-filtrage-des-gpos) et [diagnostic](#10-diagnostiquer-une-gpo-qui-ne-sapplique-pas)

## 📙 Objectifs pédagogiques

À la fin de ce chapitre, vous serez capable de :

1. Créer une GPO, la lier à une OU du lab et vérifier son application sur `ws-IT-01` avec `gpupdate /force` et `gpresult /r`
2. Prédire quelle GPO gagne en cas de conflit (ordre L-S-D-OU, Bloquer l'héritage, Appliqué)
3. Restreindre une GPO à un groupe par filtrage de sécurité sans la casser (règle MS16-072)
4. Diagnostiquer une GPO qui ne s'applique pas à l'aide d'une checklist, de `gpresult /h` et du journal GroupPolicy

## 1. Introduction aux GPO

### 🌐 1.1. Qu'est-ce qu'une Stratégie de Groupe ?

Une GPO est un objet qu'on crée dans AD DS et qui a les capacités suivantes :

| 🛠️ Capacités | Description |
|------------|-------------|
| 💻 **Configuration** | Gérer de manière centralisée les configurations |
| 🔒 **Sécurité** | Appliquer des paramètres de sécurité |
| 💾 **Déploiement** | Déployer des logiciels |
| 🖥️ **Scripts** | Configurer des scripts de démarrage/arrêt |

> 💡 **Principe clé** : on modifie **une seule GPO** pour configurer **plusieurs machines ou utilisateurs**, au lieu de configurer chaque poste à la main.

Une GPO est stockée en **deux parties** : un objet dans l'annuaire (le *conteneur*, répliqué avec AD) et un dossier de fichiers dans **SYSVOL** (`\\maxtec.be\SYSVOL\maxtec.be\Policies\{GUID}`, le *modèle*). Les clients lisent les deux. Si l'une manque ou n'est pas répliquée, la GPO ne s'applique pas (voir §10).



### 1.2. Exemples d'application


| Catégorie | Description Détaillée | Exemples |
|-----------|---------------------|----------|
| **Sécurité** | Implémente les politiques de sécurité de l'entreprise : complexité des mots de passe, restrictions d'accès, paramètres de pare-feu, etc. | Obligation de mots de passe complexes (12 caractères min.), configuration du pare-feu d'entreprise |
| **Configuration Utilisateur** | Configure l'environnement de travail des utilisateurs : fond d'écran, paramètres Office, mappages de lecteurs réseau. | Application du fond d'écran d'entreprise, mappage automatique des lecteurs réseau par département |
| **Configuration Système** | Gère les paramètres système : services Windows, paramètres réseau, configuration des mises à jour. | Activation/désactivation des services d'impression |
| **Déploiement** | Automatise l'installation et la mise à jour des applications, pilotes et correctifs sur les postes clients. | Installation automatique d'un logiciel `.msi` depuis `\\dns1\Software` |
| **Restrictions** | Contrôle l'accès aux fonctionnalités système et applications selon les besoins métier et la sécurité. | Désactivation des ports USB pour le service RH, restriction de l'accès à l'invite de commandes |
| **Automatisation** | Automatise les tâches via des scripts exécutés à des moments spécifiques (connexion, démarrage, etc.). | Exécution de scripts de connexion pour mapper les lecteurs, sauvegarde automatique des fichiers utilisateurs |


### 1.3. Qui est affecté par les GPOs ? Définition d’un site AD

Les **stratégies de groupe peuvent être liées à différents niveaux** de la hiérarchie AD : un **site**, un domaine AD, une OU (et il existe aussi la stratégie locale de chaque ordinateur).

![Domaine AD](diagrams/images/domaineAD.png)

**Rappel**:

1. **Site AD vs Sous-zone DNS** :
   - **Site AD** :
     * Représente une localisation physique
     * Défini par des sous-réseaux IP (ex: 192.168.10.0/24)
     * But : Optimisation du trafic et de la réplication

   - **Zone DNS** :
     * Section d'un espace de noms DNS (ex: maxtec.be)
     * But : Organisation hiérarchique des noms

!!! info "Infrastructure de référence (scénario, pas le lab)"

    - **Domaine AD** et **Zone DNS** principale : `maxtec.be`
    - **Sites AD** : `site EU (192.168.10.0/24)` et `site US (192.168.20.0/24)`
    - **Zones DNS** : Zone EU (`eu.maxtec.be`), Zone US (`us.maxtec.be`)

Ces concepts sont distincts mais complémentaires dans une infrastructure d'entreprise.

Dans le lab, il n'y a **qu'un site** et un seul réseau (`192.168.0.0/24`), qui joue le rôle du site EU.

Dans le scénario, les deux sites seraient gérés par le DC du lab (`dns1`) et, en théorie, un second DC en réplication (`dns2`), tous deux physiquement **chez nous**.

**Dans un environnement réel, nous aurions au moins deux autres DCs** : `dns3` et `dns4`, situés physiquement aux États-Unis.
Les quatre DCs partagent la même base de données AD. Deux sont situés en Europe et les deux autres aux États-Unis.

#### Faut-il recréer la base AD dans chaque site ?

**Non.**

La **séparation** en sites n'a **pas d'impact** sur le contenu de la base.

Les objets AD (comme les OU) sont stockés dans la base de données du DC, qui est **répliquée à l'identique** sur tous les DCs du domaine. La configuration des OUs est donc la même sur tous les DCs, quel que soit leur site.

**En pratique :** on peut créer toute la structure des OUs sur le seul DC du lab. Si on ajoutait un DC `dns3` pour le site USA, il recevrait la même configuration AD par réplication.

Notre site porte le nom `Default-First-Site-Name` (`Gestionnaire de serveur` → `Outils` → `Sites et services Active Directory` → `Sites`), nom donné par AD DS lors de la création du domaine.

Ce sera notre site pour l'Europe : **renommez-le en `Site-EU`** (clic droit sur le site → `Renommer`).
On pourrait créer un autre site associé à un autre sous-réseau, mais ce n'est pas le but du lab.

## 🎯 Checkpoint: Concepts GPO et Sites

!!! info "Vérification de compréhension"

    Avant de créer vos premières GPOs :

    - [ ] Une GPO est un ensemble de paramètres appliqué à plusieurs machines ou utilisateurs
    - [ ] Une GPO se lie à un site, au domaine ou à une OU
    - [ ] Le lab a un seul site (`Site-EU`)
    - [ ] Un site (physique, sous-réseaux) n'est pas une zone DNS (espace de noms)

## 2. Création des GPOs

Nous allons étudier les caractéristiques des GPOs en détail plus tard, mais commençons par créer une GPO d'exemple.

Avant de commencer, vérifiez que la structure du lab est en place et que `ws-IT-01` est dans son OU (voir la [Référence du lab Maxtec](Labo%20et%20Exercices/Labo/Reference_Lab_Maxtec.md)).

### Exemple pratique : restreindre le panneau de configuration aux utilisateurs de Ventes

!!! example "Objectif"

    Créer la GPO `GPO-Panneau-Restreint` qui cache deux éléments du panneau de configuration aux utilisateurs de Ventes.

!!! info "Suite d'opérations"

    - **Créer** la GPO `GPO-Panneau-Restreint` et la **lier** à l'OU `EU > Ventes > Users`. C'est une GPO de configuration **utilisateur** : elle suivra les utilisateurs de Ventes quel que soit l'ordinateur sur lequel ils se connectent.
    - **Modifier** la GPO (vide au départ) : elle doit cacher aux utilisateurs de Ventes :
        - Programmes et fonctionnalités
        - Système
    - **Tester** depuis le poste client `ws-IT-01` avec un utilisateur de Ventes (`victor`), puis avec un utilisateur d'un autre service.

Pour faire tout ça, voici les étapes.

Sur le **serveur** :

1. Ouvrir `Gestionnaire de serveur` > `Outils` > `Gestion de stratégie de groupe`
2. Déplier `Forêt : maxtec.be` > `Domaines` > `maxtec.be`
3. Déplier l'OU `EU` puis `Ventes`
4. Clic droit sur l'OU `Users` de `Ventes` > `Créer un objet GPO dans ce domaine, et le lier ici…`
5. Nommez la GPO `GPO-Panneau-Restreint`
6. Sous l'OU `Users` de `Ventes`, un élément `GPO-Panneau-Restreint` apparaît. C'est **un lien** : il indique que la GPO s'applique à cette unité d'organisation.

!!! note "Lien et objet"

    Le **vrai objet GPO** se trouve dans le dossier `Objets de stratégie de groupe`. Une même GPO peut être **liée à plusieurs OUs** (ex. Ventes et RH mais pas Comptabilite) ; supprimer un lien ne supprime pas la GPO.

7. Clic droit sur le lien `GPO-Panneau-Restreint` > `Modifier`
8. `Configuration utilisateur` > `Stratégies` > `Modèles d'administration` > `Panneau de configuration` > **`Masquer les éléments spécifiés du Panneau de configuration`**
9. Cochez `Activé`, puis cliquez sur `Afficher…`
10. Ajoutez les **noms canoniques** des éléments, un par ligne :
    - `Microsoft.System`
    - `Microsoft.ProgramsAndFeatures`
11. `OK` > `Appliquer` > `OK`

!!! warning "Noms canoniques, pas noms affichés"

    Ce paramètre attend les noms canoniques (`Microsoft.System`), pas le texte affiché dans le panneau (« Système »). Un nom affiché tapé à la main est simplement ignoré, sans message d'erreur. La liste des noms canoniques est dans la documentation Microsoft « Canonical names of Control Panel items ».

Sur le **client** `ws-IT-01` :

La GPO étant liée à l'OU des **utilisateurs** de Ventes, elle s'applique à `victor` même sur le poste de l'IT.

1. Ouvrez une session avec `MAXTEC\victor`
2. Ouvrez une console et lancez `gpupdate /force`
3. Lancez `gpresult /r` et vérifiez que `GPO-Panneau-Restreint` apparaît dans la partie **Paramètres utilisateur**

    > 📖 Détail des options de `gpupdate` et `gpresult` : voir la [Boîte à outils](#boite-a-outils-gpupdate-et-gpresult) plus bas.

4. Fermez la session et rouvrez-la (même utilisateur)
5. Ouvrez le panneau de configuration (`control`), passez l'affichage en **Grandes icônes** : `Système` et `Programmes et fonctionnalités` ne doivent plus apparaître

Connectez-vous ensuite avec un utilisateur de `Comptabilite` (ex. `cindy`) : le panneau de configuration ne doit pas être restreint.

!!! note "Forcer la mise à jour depuis le serveur"

    Dans GPMC, clic droit sur une OU → `Mise à jour de la stratégie de groupe…` lance un `gpupdate` à distance sur les **ordinateurs** de cette OU (et pour les sessions ouvertes sur ces ordinateurs). Sur une OU qui ne contient que des utilisateurs, comme `EU/Ventes/Users`, il n'y a donc rien à faire.

    Cette commande crée une tâche planifiée à distance sur chaque poste. Le pare-feu du client doit l'autoriser : il ne faut **jamais désactiver le pare-feu**, mais ouvrir les règles prédéfinies **Gestion à distance des tâches planifiées** (RPC et RPC-EPMAP) et **Infrastructure de gestion Windows (WMI-Entrée)**. On le fait par GPO sur l'OU des ordinateurs : `Configuration ordinateur` > `Stratégies` > `Paramètres Windows` > `Paramètres de sécurité` > `Pare-feu Windows Defender avec fonctions avancées de sécurité` > `Règles de trafic entrant` > `Nouvelle règle…` > `Prédéfinie`.



**ATTENTION** : deux points vitaux

1. Une GPO affecte **les ordinateurs et les utilisateurs situés dans l'OU** où elle est liée **et dans ses sous-OUs**. Si l'OU ne contient que des groupes, la GPO ne s'applique pas aux membres de ces groupes.

2. Si une GPO ne contient que des paramètres Utilisateur et qu'elle est liée à une OU qui ne contient que des ordinateurs, elle n'a aucun effet (sauf *loopback*, voir §4.1).


### Être sûr que les GPOs soient appliquées

L'application des stratégies de groupe dépend de l'état du poste de travail et de la session utilisateur. Voici les points clés à comprendre :

| Situation | Stratégie ordinateur | Stratégie utilisateur | Commentaire |
|-----------|---------------------|---------------------|-------------|
| Poste allumé, personne connectée | ✅ Oui | ❌ Non | Les stratégies ordinateur continuent de se rafraîchir même sans utilisateur |
| Poste allumé, utilisateur connecté | ✅ Oui | ✅ Oui | Toutes les stratégies sont actives pendant une session |
| Poste éteint | ❌ Non | ❌ Non | Aucune stratégie ne peut s'appliquer sur un poste éteint |
| Utilisateur connecté via RDP ou console | ✅ Oui | ✅ Oui | Le mode de connexion n'affecte pas l'application des stratégies |

**Quand les GPOs s'appliquent-elles automatiquement ?**

- **Stratégies ordinateur** : au **démarrage** du poste, puis rafraîchissement en arrière-plan.
- **Stratégies utilisateur** : à **l'ouverture de session**, puis rafraîchissement en arrière-plan.
- **Rafraîchissement automatique** :
    * **Postes membres du domaine** : toutes les **90 minutes**, avec un décalage aléatoire de 0 à 30 minutes (pour éviter que tous les postes contactent le DC en même temps).
    * **Contrôleurs de domaine** : toutes les **5 minutes**.
- Certaines extensions ne s'appliquent **pas** en arrière-plan et nécessitent un événement spécifique :
    * **Installation logicielle ordinateur** → redémarrage requis.
    * **Installation logicielle utilisateur / Redirection de dossiers** → fermeture de session requise.

> 💡 Conséquence pratique : si on veut tester immédiatement une GPO sans attendre 90 min ni rebooter, on utilise `gpupdate`. Pour vérifier ce qui a réellement été appliqué, on utilise `gpresult`.

---

### Boîte à outils : `gpupdate` et `gpresult`

Ce sont les **deux commandes de diagnostic GPO** à connaître par cœur. On les lance dans une console **sur le client** (pas sur le DC), en général **en tant qu'administrateur** pour avoir accès au scope ordinateur.

#### `gpupdate` — Forcer le rafraîchissement des GPOs

Demande au client d'aller chercher immédiatement les GPOs sur le DC au lieu d'attendre le cycle de 90 minutes.

| Option | Effet |
|---|---|
| (sans option) | Applique uniquement les paramètres qui ont **changé** depuis le dernier rafraîchissement. |
| `/force` | Réapplique **toutes** les stratégies, même celles inchangées. C'est l'option utilisée en formation et en dépannage. |
| `/target:computer` | Ne rafraîchit que la partie **ordinateur**. |
| `/target:user` | Ne rafraîchit que la partie **utilisateur**. |
| `/logoff` | Déconnecte l'utilisateur **après** application — nécessaire pour les extensions qui ne s'appliquent qu'à l'ouverture de session (ex. Redirection de dossiers, installation logicielle utilisateur). |
| `/boot` | Redémarre la machine **après** application — nécessaire pour l'installation logicielle ciblant l'ordinateur. |
| `/sync` | Force la **prochaine** application au prochain boot/logon à se faire en mode synchrone (le poste attend la fin de l'application avant d'afficher le bureau). Ignore `/force` et `/wait`. |
| `/wait:<secondes>` | Attend N secondes la fin du traitement. Par défaut **600 s**. `0` = ne pas attendre, `-1` = attendre indéfiniment. |

**Commande à retenir** :

```cmd
gpupdate /force
```

> ⚠️ `gpupdate` ne force **pas** un redémarrage ni une déconnexion sauf si on ajoute `/boot` ou `/logoff`. Si une GPO ne semble pas s'appliquer après un `gpupdate /force`, c'est souvent parce qu'elle nécessite l'un des deux : la commande affichera alors un message demandant l'action correspondante.

#### `gpresult` — Vérifier ce qui a été appliqué

Affiche le **RSoP** (Resultant Set of Policy) : la liste réelle des GPOs appliquées à l'utilisateur et à l'ordinateur, avec le détail de qui a gagné quand plusieurs GPOs entraient en conflit.

| Option | Effet |
|---|---|
| `/r` | **Résumé** : liste des GPOs appliquées, groupes de sécurité, dernier rafraîchissement. **L'option à utiliser en premier.** |
| `/v` | **Verbose** : ajoute les paramètres détaillés appliqués au premier niveau de précédence. |
| `/z` | **Tout** : tous les paramètres, toutes les précédences. Très long → à rediriger vers un fichier. |
| `/h <fichier.html>` | Génère un rapport **HTML** lisible et partageable. C'est la meilleure option pour analyser tranquillement. |
| `/x <fichier.xml>` | Même chose en XML (pour traitement automatisé). |
| `/scope user` | Limite à la partie **utilisateur**. |
| `/scope computer` | Limite à la partie **ordinateur** (nécessite une console **administrateur**). |
| `/user <domaine\user>` | Affiche le RSoP d'un autre utilisateur sur ce poste (utile pour comparer). |
| `/s <machine>` | Cible une machine distante (`/u` et `/p` pour les credentials). |

**Commandes à retenir** :

```cmd
:: Vue d'ensemble rapide (utilisateur + ordinateur)
gpresult /r

:: Uniquement les GPOs ordinateur (console en mode administrateur)
gpresult /r /scope:computer

:: Rapport HTML complet — la version "pro" pour le dépannage
gpresult /h rapport.html

:: Tout, dans un fichier texte
gpresult /z > policy.txt
```

> ⚠️ On **doit** spécifier un format de sortie (`/r`, `/v`, `/z`, `/h` ou `/x`). `gpresult` tout court ne fait rien.

#### Workflow type de test d'une GPO

Quand on vient de créer ou modifier une GPO et qu'on veut vérifier qu'elle est correctement appliquée à un utilisateur :

1. **Côté client**, ouvrir une console **en tant qu'administrateur** :

    ```cmd
    gpupdate /force
    ```

2. Vérifier que la GPO apparaît bien dans les GPOs appliquées :

    ```cmd
    gpresult /r
    ```

    Chercher la section `Stratégie de groupe appliquée` (ou `Applied Group Policy Objects`).

3. Si la GPO n'apparaît **pas** où elle devrait, générer le rapport HTML pour comprendre :

    ```cmd
    gpresult /h rapport.html
    start rapport.html
    ```

    Le rapport indique pour chaque GPO si elle a été appliquée, refusée, et **pourquoi** (filtrage de sécurité, WMI, scope, lien désactivé…).

4. Si la GPO touche une configuration **ordinateur** ou nécessite un événement spécial (logon, boot), refaire un **logout/login** ou un **redémarrage** selon le cas.


### Activer/désactiver une GPO

Pour **activer/désactiver** un lien de GPO, clic droit sur le lien (sous l'OU) → cocher/décocher `Lien activé`. **La GPO n'est appliquée à cette OU que si le lien est activé.**

L'option `Appliqué` (*Enforced*) sur un lien fait deux choses : la GPO **traverse les OUs qui bloquent l'héritage**, et elle **gagne les conflits** contre les GPOs liées plus bas. On la réserve aux paramètres de sécurité qui ne doivent pas être contournés (voir §3).

## 3. Ordre d'application des GPO (LSDO)

Pour pouvoir gérer proprement les GPOs on doit comprendre comment elles sont appliquées.

Les **paramètres de stratégie de groupe (GPO) sont appliqués dans l'ordre suivant**, du plus général au plus spécifique :

1. **L**ocal (le plus général, **n'est pas une vraie GPO**)
   - Configuration Windows stockée localement (pas dans AD)
   - Existe avant de joindre le domaine
   - **Ce n'est pas une GPO d'Active Directory**
   - *Exemples* : Pare-feu Windows par défaut, options d'alimentation

2. **S**ite
   - **GPOs** liées aux sites AD (zones physiques du réseau)
   - S'applique aux ordinateurs situés dans le site (et aux utilisateurs qui s'y connectent)
   - *Exemples* : Configuration proxy (Site-EU), imprimantes locales au site

3. **D**omaine
   - **GPOs** globales pour tout le domaine AD
   - S'applique à tous les utilisateurs et ordinateurs du domaine
   - *Exemples* : Politique de mot de passe, installation antivirus
   - Rappel : un domaine peut contenir plusieurs sites (Site-EU, Site-US)

4. **O**U (le plus spécifique)
   - **GPOs** pour des départements ou groupes spécifiques
   - *Exemples* : Logiciels comptables (OU Comptabilite), accès dossiers (OU RH)
   - Les OUs parentes sont traitées avant les OUs enfants (`EU` avant `EU/RH`, avant `EU/RH/Users`)
   - Une OU peut contenir des objets de plusieurs sites : OUs et sites sont indépendants

> **Note**: Chaque GPO contient deux sections distinctes :
>
> - Configuration ordinateur (Computer Configuration)
> - Configuration utilisateur (User Configuration)

### Qui gagne en cas de conflit ?

**Règle** : quand deux GPOs configurent le même paramètre avec des valeurs différentes, **c'est la dernière appliquée qui gagne**. Comme l'ordre est Local → Site → Domaine → OU parente → OU enfant, **l'OU la plus proche de l'objet gagne**. Ce n'est **pas** « la plus restrictive » : une GPO d'OU peut très bien assouplir un paramètre fixé au domaine.

Deux options modifient cette règle :

| Option | Où | Effet |
|---|---|---|
| **Bloquer l'héritage** | Sur une OU | L'OU ne reçoit plus les GPOs liées aux niveaux supérieurs (sauf celles en mode Appliqué) |
| **Appliqué** (*Enforced*) | Sur un lien de GPO | La GPO passe malgré un blocage et **gagne** contre les GPOs liées plus bas |

Plusieurs GPOs liées à la **même** OU : c'est l'**ordre des liens** (onglet `Objets de stratégie de groupe liés`) qui décide ; le lien n° 1 a la plus haute priorité.

!!! example "Exemple Maxtec"

    - `GPO-Ecran-Domaine` liée au domaine : verrouillage de l'écran après 15 min.
    - `GPO-Ecran-RH` liée à `EU/RH` : verrouillage après 5 min.

    Pour un poste de `EU/RH/Computers`, c'est **5 min** (l'OU est plus proche). Si le lien de `GPO-Ecran-Domaine` est en mode **Appliqué**, c'est **15 min**, même si `EU/RH` bloque l'héritage.

!!! warning "Exception : la politique de mots de passe du domaine"

    La politique de mots de passe et de verrouillage des **comptes du domaine** n'est lue que dans les GPOs **liées à la racine du domaine** (en pratique la `Default Domain Policy`). La même politique liée à une OU n'affecte **que les comptes locaux** des ordinateurs de cette OU, pas les comptes AD.

    Pour exiger 12 caractères aux admins et 8 aux autres, on n'utilise donc pas une GPO d'OU mais une **stratégie de mot de passe affinée** (*Fine-Grained Password Policy*, objet PSO), appliquée à un utilisateur ou à un groupe global. Elle se crée dans le Centre d'administration Active Directory ou avec `New-ADFineGrainedPasswordPolicy`. Voir [Chapitre 11 : Sécurité AD](Chapitre%2011.Securite_AD.md).

## 4. 📌 Clarification des stratégies GPO dans Active Directory

Les deux grandes catégories de stratégies GPO sont :

### 1️⃣ **Configuration ordinateur**
- S'applique aux machines, **indépendamment de l’utilisateur** qui se connecte.
- Exemples : paramétrage des services Windows, pare-feu, gestion des mises à jour.

### 2️⃣ **Configuration utilisateur**
- S'applique aux **utilisateurs** lorsqu'ils se connectent à une machine, **indépendamment de l'ordinateur**.
- Exemples : restriction d'accès à certains programmes, redirection de dossiers.

💡 **Une même GPO peut contenir des paramètres dans les deux catégories. La partie ordinateur ne s'applique qu'aux ordinateurs de l'OU, la partie utilisateur qu'aux utilisateurs de l'OU.**


### Les sous-menus de chaque catégorie
Chaque catégorie (ordinateur et utilisateur) contient deux branches : **Stratégies** et **Préférences**.

#### **Stratégies (Policies)**
- Contient des paramètres **imposés** par l’administrateur.
- Pour les modèles d'administration, écrits dans des clés de registre dédiées (`...\Policies\...`) que l'utilisateur standard ne peut pas modifier.
- Quand la GPO ne s'applique plus (lien supprimé, utilisateur déplacé), le paramètre est **retiré automatiquement**.
- Contient trois sous-dossiers : Paramètres du logiciel, Paramètres Windows, **Modèles d'administration**.

#### **Préférences (Preferences)**
- Paramètres **appliqués comme valeur de départ** : lecteurs réseau, raccourcis, imprimantes, clés de registre, utilisateurs et groupes locaux…
- Écrits aux emplacements normaux (hors `Policies`) : l'utilisateur peut les modifier **entre deux rafraîchissements**.
- Par défaut, ils sont **réappliqués à chaque rafraîchissement** (toutes les 90 min, à chaque ouverture de session), ce qui écrase la modification de l'utilisateur. Option `Appliquer une fois et ne pas réappliquer` dans l'onglet `Commun` pour une vraie valeur par défaut.
- Quand la GPO ne s'applique plus, le paramètre **reste en place** (« tatouage »), sauf si l'on a coché `Supprimer cet élément lorsqu'il n'est plus appliqué`.

#### 🔧 **Modèles d'administration (Administrative Templates)**
- Sous-dossier des **Stratégies** (pas une troisième catégorie, et pas des préférences).
- Définis par des fichiers **ADMX/ADML** : chaque fichier décrit des paramètres, leur texte d'aide et la clé de registre qu'ils pilotent.
- C'est ce qui permet de configurer un paramètre (« Masquer les éléments spécifiés du Panneau de configuration ») sans connaître la clé de registre.
- Pour une clé de registre qui n'a pas de modèle, on utilise la préférence `Registre`, pas un modèle d'administration.

Voyons en détail chaque type.

---

### 4.1. Stratégies

#### 📌 Configuration Ordinateur > Stratégies

✔ **Paramètres du logiciel**

- Déploiement de logiciels (installation, mise à jour, désinstallation)

✔ **Paramètres Windows**

- Scripts (au démarrage et à l'arrêt)
- Paramètres de sécurité (stratégie de mot de passe, stratégie d'audit, droits utilisateur, pare-feu Windows Defender)


✔ **Modèles d’administration (Administrative Templates)**

- Configuration des services système
- Restriction sur l’installation des pilotes
- Paramètres de Windows Update

!!! example "Exemples"

    - **Attendre le réseau avant l'ouverture de session** (utile pour que les GPOs utilisateur s'appliquent dès la première connexion) : *Configuration ordinateur > Stratégies > Modèles d'administration > Système > Ouverture de session > Toujours attendre le réseau lors du démarrage de l'ordinateur et de l'ouverture de session*.
    - **Configurer Windows Update** : *Configuration ordinateur > Stratégies > Modèles d'administration > Composants Windows > Windows Update > Configurer les mises à jour automatiques* (dans les ADMX récents, sous le sous-dossier *Gérer l'expérience de l'utilisateur final*).


#### 📌 Configuration Utilisateur > Stratégies

✔ **Paramètres du logiciel**

- Déploiement de logiciels (installation, mise à jour, désinstallation)

✔ **Paramètres Windows**

- Scripts (à l'ouverture et à la fermeture de session)
- Redirection de dossiers
- Paramètres de sécurité (stratégies de clé publique, restriction logicielle)

✔ **Modèles d’administration (Administrative Templates)**

- Restriction d'accès à certaines applications et au panneau de configuration
- Paramètres d’interface (ex. masquer les paramètres système)
- Gestion des extensions de navigateur

!!! example "Exemples"

    - **Désactiver la modification du fond d'écran** : *Configuration utilisateur > Stratégies > Modèles d'administration > Panneau de configuration > Personnalisation > Empêcher la modification de l'arrière-plan du Bureau*.
    - **Restreindre l'accès au gestionnaire de tâches** : *Configuration utilisateur > Stratégies > Modèles d'administration > Système > Options Ctrl+Alt+Suppr > Supprimer le Gestionnaire des tâches*.


#### Piège courant : paramètres utilisateur sur une OU d'ordinateurs
Une erreur fréquente est de lier une GPO contenant des paramètres **Configuration utilisateur** à une OU qui ne contient **que des ordinateurs** (ou l'inverse) : rien ne s'applique.

**Cas particulier : le traitement en boucle de rappel (*loopback*)**

Parfois, on veut justement que l'**ordinateur** décide de l'environnement de l'utilisateur, quel que soit l'utilisateur : salle de formation, kiosque, poste en libre-service. Dans ce cas :

1. On crée une GPO liée à l'OU des **ordinateurs** concernés, qui contient les paramètres **utilisateur** voulus.
2. Dans cette GPO, on active : *Configuration ordinateur > Stratégies > Modèles d'administration > Système > Stratégie de groupe > Configurer le mode de traitement par bouclage de la stratégie de groupe utilisateur*.
3. On choisit le mode :
    - **Fusionner** : l'utilisateur reçoit ses GPOs habituelles **plus** les paramètres utilisateur des GPOs de l'ordinateur (qui gagnent en cas de conflit).
    - **Remplacer** : l'utilisateur ne reçoit **que** les paramètres utilisateur des GPOs de l'ordinateur.

---

### 4.2. Préférences (Preferences)
- Valeurs de départ, que l'utilisateur peut modifier entre deux rafraîchissements
- Réappliquées à chaque rafraîchissement, sauf option `Appliquer une fois et ne pas réappliquer`
- Exemples : lecteurs réseau, imprimantes, raccourcis, clés de registre

**Exemple pratique** (le partage `\\dns1\IT-Admin` est celui de l'exercice GPO-1) :
```
Configuration utilisateur > Préférences > Paramètres Windows > Mappages de lecteurs
Action: Mettre à jour
Emplacement: \\dns1\IT-Admin
Lettre: Z:
```
L'utilisateur peut déconnecter le lecteur `Z:` ; il sera recréé au prochain rafraîchissement ou à la prochaine ouverture de session. Une stratégie, elle, ne laisserait pas le choix.


## **Résumé final en une image mentale**

- 🔹 **Configuration ordinateur** = Gère le PC et ses paramètres système.
- 🔹 **Configuration utilisateur** = Gère l'expérience de l’utilisateur.
- 🔹 **Stratégies (Policies)** = Imposées, retirées quand la GPO ne s'applique plus.
- 🔹 **Préférences (Preferences)** = Valeurs réappliquées à chaque rafraîchissement, modifiables entre-temps, restent en place quand la GPO ne s'applique plus (sauf option).
- 🔹 **Boucle de rappel (loopback)** = Les paramètres utilisateur viennent des GPOs de l'ordinateur (salles de formation, kiosques).

## 5 🎯 Ciblage vs Liaison des GPO

Une distinction importante existe entre le **ciblage** (*targeting* en anglais) et la **liaison** des GPO :

| Étape | Rôle | Effet |
|-------|------|--------|
| Lien GPO → OU | Détermine où la GPO est évaluée | Sans lien, la GPO ne s'applique pas du tout |
| Ciblage au niveau de l'élément | Détermine si l'action spécifique dans la GPO s'applique | Si la condition échoue, l'action est ignorée, mais pas la GPO entière |
| Filtrage de sécurité (ACL) | Détermine qui peut appliquer la GPO | Si l'utilisateur n'a pas de droits, la GPO est ignorée |

> 💡 **Note importante** : le filtrage agit à deux niveaux :
>
> - **GPO entière** : filtrage de sécurité et filtre WMI (tout ou rien)
> - **Élément de préférence** : ciblage au niveau de l'élément (par groupe, plage IP, système d'exploitation, variable d'environnement…), un élément à la fois



## 6. Utilisation de la délégation pour créer des exceptions

On peut empêcher une GPO de s'appliquer à un groupe en lui **refusant** la permission `Appliquer la stratégie de groupe`.

L'onglet `Délégation` d'une GPO mélange trois choses : **qui administre** la GPO (modifier, supprimer), **qui l'applique** (Lecture + Appliquer la stratégie de groupe) et **qui en est exclu** (Refuser). Par défaut :

- `Utilisateurs authentifiés` : Lecture + Appliquer (d'où l'application à tout le monde dans l'OU)
- `Admins du domaine`, `Administrateurs de l'entreprise` : Modifier les paramètres, supprimer, modifier la sécurité

!!! example "Exemple : exclure le responsable Ventes de `GPO-Panneau-Restreint`"

    La GPO du §2 est liée à `EU/Ventes/Users` et touche donc aussi `valentin`, responsable Ventes (membre de `GG-EU-Ventes-Admin`). On veut l'en exclure.

    1. GPMC > `Objets de stratégie de groupe` > `GPO-Panneau-Restreint` > onglet `Délégation` > `Avancé…`
    2. `Ajouter…` > `GG-EU-Ventes-Admin` > `OK`
    3. Pour ce groupe, cochez `Refuser` sur la ligne `Appliquer la stratégie de groupe` > `OK` et confirmez
    4. Sur `ws-IT-01`, connectez-vous en `valentin`, `gpupdate /force` puis `gpresult /r` : la GPO apparaît dans la liste des GPOs **filtrées**, motif « Refusé (Sécurité) ». Avec `victor`, elle est toujours appliquée.

    Un **Refuser** l'emporte sur un Autoriser : même si `valentin` est aussi dans `Utilisateurs authentifiés`, la GPO ne s'applique pas à lui.


## 7. Filtrage des GPOs

Une fois qu'une GPO est liée à un niveau (Site, Domaine ou OU), on peut affiner son application avec deux méthodes de filtrage.

### 7.1. Filtrage de Sécurité

!!! info "Concept"

    Le **filtrage de sécurité** permet de **restreindre l'application d'une GPO** à des groupes de sécurité spécifiques, même si la GPO est liée à une OU contenant d'autres utilisateurs/ordinateurs.

!!! example "Scénario pratique"

    Une GPO liée à `EU/Ventes/Users` installe le client d'un CRM coûteux. Seuls les **responsables** (`GG-EU-Ventes-Admin`, donc `valentin`) doivent le recevoir, pas `victor`, `vanessa` ni `valeria`.

#### Comment fonctionne le filtrage de sécurité ?

Pour qu'une GPO s'applique à un utilisateur ou ordinateur, il doit avoir **deux permissions** :

| Permission | Description |
|------------|-------------|
| **Lecture** | Pouvoir lire le contenu de la GPO |
| **Appliquer la stratégie de groupe** | Permission d'appliquer la stratégie |

!!! warning "Comportement par défaut"

    Par défaut, toute GPO nouvellement créée a le groupe **Utilisateurs authentifiés** dans le filtrage de sécurité : elle s'applique à **tous** les utilisateurs et ordinateurs de l'OU liée (les comptes ordinateurs sont aussi des « utilisateurs authentifiés »).

#### Exemple Pratique : Restreindre une GPO

!!! example "Configuration étape par étape"

    **Situation** : la GPO `GPO-CRM-Installation` est liée à `EU/Ventes/Users` et doit s'appliquer uniquement à `GG-EU-Ventes-Admin`.

    **Étapes** :

    1. Ouvrir **GPMC**
       ```
       Gestionnaire de serveur > Outils > Gestion de stratégie de groupe
       ```

    2. Naviguer vers la GPO :
       ```
       Objets de stratégie de groupe > GPO-CRM-Installation
       ```

    3. Onglet **Étendue**, section **Filtrage de sécurité**

    4. **Ajouter le groupe cible** :
        - Cliquer sur **Ajouter…**
        - Taper `GG-EU-Ventes-Admin` > **Vérifier les noms** > **OK**

    5. **Retirer « Utilisateurs authentifiés » du filtrage** :
        - Sélectionner `Utilisateurs authentifiés` > **Supprimer** > confirmer

    6. **Remettre « Utilisateurs authentifiés » en Lecture seule** (étape indispensable) :
        - Onglet **Délégation** > **Avancé…**
        - **Ajouter…** > `Utilisateurs authentifiés` (ou `Ordinateurs du domaine`)
        - Cocher **Autoriser** uniquement pour **Lecture** (pas « Appliquer la stratégie de groupe ») > **OK**

    ✅ **Résultat** : la GPO ne s'applique qu'aux membres de `GG-EU-Ventes-Admin`.

!!! danger "Pourquoi l'étape 6 (MS16-072)"

    Depuis le correctif de sécurité MS16-072 (juin 2016), le poste lit les GPOs **utilisateur** avec le compte de l'**ordinateur**, pas celui de l'utilisateur. Si vous retirez `Utilisateurs authentifiés` sans laisser au moins la **Lecture** aux ordinateurs, le poste ne peut plus lire la GPO et **elle ne s'applique à personne**, sans message d'erreur clair.

#### Vérification du Filtrage

!!! example "Test de la configuration"

    **Test 1 - Utilisateur dans le groupe ciblé :**

    1. Sur `ws-IT-01`, connectez-vous avec `valentin` (membre de `GG-EU-Ventes-Admin`)
    2. Exécutez `gpupdate /force` et `gpresult /r`
    3. ✅ `GPO-CRM-Installation` doit figurer dans les GPOs appliquées

    **Test 2 - Utilisateur hors du groupe :**

    1. Connectez-vous avec `victor` (dans `EU/Ventes/Users` mais PAS membre de `GG-EU-Ventes-Admin`)
    2. Exécutez `gpupdate /force` et `gpresult /r`
    3. ❌ `GPO-CRM-Installation` doit apparaître parmi les GPOs **filtrées** (« Refusé (Sécurité) »), pas parmi les appliquées

#### Cas d'Usage Fréquents

!!! tip "Exemples d'utilisation"

    | Scénario | GPO | Groupe ciblé |
    |----------|-----|--------------|
    | Logiciel spécialisé | `GPO-Compta-Logiciel` | `GG-EU-Compta-Users` |
    | Blocage USB sauf responsables | `GPO-USB-Block` | `GG-EU-Compta-Users` (Charlotte, dans `GG-EU-Compta-Admin`, n'est pas concernée) |
    | Fond d'écran département | `GPO-Wallpaper-RH` | `GG-EU-RH-Users` |
    | Lecteur réseau IT | `GPO-Lecteur-IT` | `GG-EU-IT-Users` |

!!! warning "Bonnes pratiques"

    - ✅ **Toujours utiliser des groupes**, jamais des utilisateurs individuels
    - ✅ Utiliser des **groupes globaux** (GG-) pour le filtrage
    - ✅ Documenter quel groupe reçoit quelle GPO
    - ✅ Quand vous retirez `Utilisateurs authentifiés` du filtrage, laissez-le en **Lecture** dans la délégation
    - ❌ Éviter de multiplier les filtrages complexes (privilégier la simplicité)

### 7.2. Filtrage WMI (Windows Management Instrumentation)

!!! info "Concept"

    Le **filtrage WMI** permet de filtrer l'application d'une GPO selon des **critères techniques** de la machine (système d'exploitation, type d'ordinateur, etc.).

!!! example "Exemples d'utilisation"

    - Appliquer une GPO uniquement aux ordinateurs **Windows 11**
    - Appliquer des paramètres d'économie d'énergie uniquement aux **ordinateurs portables**
    - Installer un pilote uniquement sur les machines avec une **carte graphique NVIDIA**

!!! note "Note"

    Le filtrage WMI est plus avancé et sera abordé dans des exercices pratiques. Il ralentit aussi le traitement (la requête s'exécute sur chaque poste). Pour l'instant, concentrez-vous sur le **filtrage de sécurité**, qui couvre la plupart des besoins courants.

---

## 8. Le magasin central ADMX (Central Store)

Par défaut, l'éditeur de GPO lit les modèles d'administration (fichiers `.admx` / `.adml`) **sur la machine où il est ouvert** (`C:\Windows\PolicyDefinitions`). Deux administrateurs sur deux machines différentes peuvent donc voir des listes de paramètres différentes.

Le **magasin central** est un dossier unique dans SYSVOL, répliqué sur tous les DC :

```
\\maxtec.be\SYSVOL\maxtec.be\Policies\PolicyDefinitions
```

Pour le créer, copiez `C:\Windows\PolicyDefinitions` (avec le sous-dossier de langue `fr-FR`) à cet emplacement. Ensuite, GPMC indique « Définitions de stratégies (fichiers ADMX) récupérées à partir du magasin central » et tout le monde voit les mêmes paramètres. Pour gérer des paramètres propres à Windows 11 ou à une application (Edge, Office), on ajoute leurs ADMX dans ce dossier.

## 9. Sauvegarder et restaurer une GPO

Avant de modifier une GPO importante, sauvegardez-la. Sur le DC :

```powershell
New-Item -ItemType Directory -Path C:\GPOBackup -Force | Out-Null
Backup-GPO -Name "GPO-Panneau-Restreint" -Path C:\GPOBackup   # une GPO
Backup-GPO -All -Path C:\GPOBackup                            # toutes les GPOs
Restore-GPO -Name "GPO-Panneau-Restreint" -Path C:\GPOBackup  # restaure la dernière sauvegarde
```

La sauvegarde contient les paramètres et le filtrage de sécurité, **pas les liens** : après restauration d'une GPO supprimée, il faut la relier à ses OUs (`New-GPLink`). Le même travail se fait dans GPMC : clic droit sur `Objets de stratégie de groupe` > `Sauvegarder tout…` / `Gérer les sauvegardes…`.

## 10. Diagnostiquer une GPO qui ne s'applique pas

Quand `gpresult /r` ne montre pas la GPO attendue, suivez cette checklist dans l'ordre. La plupart des pannes se trouvent dans les trois premiers points.

| # | Vérification | Comment |
|---|---|---|
| 1 | L'**objet** (utilisateur ou ordinateur) est-il dans l'OU liée, ou une sous-OU ? Un poste resté dans `CN=Computers` ne reçoit aucune GPO d'OU. | `Get-ADComputer ws-IT-01` / `Get-ADUser victor` → `DistinguishedName` |
| 2 | Le **bon côté** de la GPO : paramètres utilisateur ↔ OU d'utilisateurs, paramètres ordinateur ↔ OU d'ordinateurs ? | Éditeur de GPO |
| 3 | Le **lien** est-il activé ? Une OU parente bloque-t-elle l'héritage ? La GPO n'est-elle pas désactivée (onglet `Détails` > `État GPO`) ? | GPMC, onglet `Héritage de stratégie de groupe` de l'OU |
| 4 | **Filtrage de sécurité** : l'objet est-il dans le groupe ciblé ? Un Refuser s'applique-t-il ? `Utilisateurs authentifiés` a-t-il encore la **Lecture** (MS16-072) ? | GPMC, onglets `Étendue` et `Délégation` |
| 5 | **Filtre WMI** : la requête est-elle vraie sur ce poste ? | `gpresult /h` indique « Refusé (Filtre WMI) » |
| 6 | **Appartenance au groupe récente** : le jeton de sécurité date de l'ouverture de session. Un utilisateur ajouté à un groupe doit se déconnecter ; un ordinateur ajouté à un groupe doit redémarrer. | `whoami /groups` sur le client |
| 7 | **Réplication SYSVOL / AD** (plusieurs DC) : la GPO est-elle présente sur le DC utilisé par le client ? | `gpresult /r` affiche le DC utilisé ; GPMC > onglet `État` de la GPO |
| 8 | Le paramètre nécessite-t-il une **fermeture de session ou un redémarrage** (installation logicielle, redirection de dossiers) ? | Message de `gpupdate /force` |

Deux sources d'information complètent la checklist :

- **`gpresult /h rapport.html`** (console admin sur le client) : pour chaque GPO, appliquée ou refusée, et **pourquoi** (« Refusé (Sécurité) », « Refusé (Filtre WMI) », « Vide », « Lien désactivé »…).
- **Journal d'événements du client** : `Observateur d'événements` > `Journaux des applications et des services` > `Microsoft` > `Windows` > `GroupPolicy` > `Operational`. On y voit chaque cycle de traitement, le DC contacté, le temps de traitement et les erreurs de lecture de SYSVOL.

---

## 🎯 Checkpoint Final - Maîtrise des GPOs

!!! info "Vérification finale"

    Avant de terminer ce chapitre, vérifiez que vous savez :

    - [ ] Créer une GPO, la lier à une OU et vérifier son application avec `gpupdate /force` et `gpresult /r`
    - [ ] Donner l'ordre d'application **Local → Site → Domaine → OU** et dire qui gagne (le dernier appliqué, sauf Appliqué)
    - [ ] Expliquer pourquoi une politique de mot de passe liée à une OU ne touche pas les comptes du domaine
    - [ ] Filtrer une GPO sur un groupe en laissant `Utilisateurs authentifiés` en Lecture
    - [ ] Différencier stratégie et préférence
    - [ ] Suivre la checklist de diagnostic du §10

---

### 🚀 Prochaine Étape
Le chapitre suivant introduit **PowerShell pour Active Directory** : les mêmes opérations (utilisateurs, groupes, OUs, et une partie des GPOs) en ligne de commande.

!!! note "Pour aller plus loin (hors parcours)"

    Le dossier `Labos Extra` contient des scénarios complémentaires qui ne font pas partie du parcours du cours : [CreativeHub - GPO lecteur réseau](Labos%20Extra/Labo1-CreativeHub/exercices/Exercice_03_GPO_Lecteur_Reseau.md), [CreativeHub - Troubleshooting GPO](Labos%20Extra/Labo1-CreativeHub/exercices/Exercice_08_Troubleshooting_GPO.md).

---

## 🧭 Navigation
[⏮️ Chapitre Précédent: Gestion des Utilisateurs](Chapitre%207.Gestion_des_Utilisateurs.md) | [🏠 Retour au Syllabus](index.md) | [⏭️ Chapitre Suivant: PowerShell AD](Chapitre%209.0.Powershell%20AD%20-%20Introduction.md)

---

**📚 Cours Active Directory - GPO**
