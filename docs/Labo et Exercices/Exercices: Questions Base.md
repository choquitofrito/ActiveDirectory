### Concepts de base

Essaye de repondre à ces questions en utilisant tes propres mots. Tout l'information se trouve dans le syllabus.

## Chapitre 3. DNS

1. À quoi sert le DNS?

    ??? success "Réponse"
        Le DNS (**Domain Name System**) **traduit les noms de domaine en adresses IP** et vice-versa. Cela permet aux ordinateurs de se connecter en utilisant des **noms faciles à retenir** plutôt que des adresses IP.

2. Où est-ce qu'on stocke la correspondance entre les noms et les adresses IP?

    ??? success "Réponse"
        Les serveurs DNS stockent la correspondance entre les noms et les adresses IP dans leurs bases de données, dans les registres DNS.
        Par exemple:

        ```
        ws-compta-01 IN A 192.168.10.128
        ```

3. Qu'est-ce que c'est un arbre DNS et une forêt DNS?

    ??? success "Réponse"
        Un arbre DNS est une structure hiérarchique de noms de domaine partageant un même suffixe (ex: .maxtec.be). Une forêt DNS est l'ensemble de tous les arbres DNS sur Internet.

4. Qu'est-ce que c'est un serveur avec autorité?

    ??? success "Réponse"
        Un serveur DNS avec autorité est responsable d'une zone DNS spécifique. Il maintient les enregistrements officiels pour cette zone et peut répondre directement aux requêtes sans consulter d'autres serveurs (comme notre `dns1.maxtec.be`)

## Chapitre 4. Active Directory Domain Services (AD DS)

1. Qu'est-ce que Active Directory?

    ??? success "Réponse"
        Active Directory est un service d'annuaire de Microsoft qui stocke des informations sur les objets d'un réseau (utilisateurs, ordinateurs, imprimantes) et permet leur gestion centralisée.

2. Qu'est-ce que c'est Active Directory Domain Services (AD DS)?

    ??? success "Réponse"
        AD DS est le service principal d'Active Directory qui gère les utilisateurs et les ressources du domaine. Il fournit les services d'authentification et d'autorisation.

3. Qu'est-ce que c'est un domaine AD?

    ??? success "Réponse"
        Un domaine AD est la structure administrative qui regroupe l'ensemble des éléments qui se trouvent dans le même annuaire (utilisateurs, ordinateurs, UOs, GPOs...). Le domaine AD porte le même nom que le domaine dns, pour nous `maxtec.be`.

4. Qu'est-ce que c'est un Domain Controller (DC)?

    ??? success "Réponse"
        Un contrôleur de domaine est un serveur qui héberge une copie de la base de données Active Directory.
        Il gère l'authentification des utilisateurs et applique les politiques de sécurité du domaine.

5. Dans le réseau de maxtec.be, est-ce que la base de données d'AD est censée d'être sur dns1, dns2 ou les deux?

    ??? success "Réponse"
        La base de données AD doit être sur les **deux serveurs** (dns1 et dns2) car ils sont tous les deux des contrôleurs de domaine. Cela assure la **redondance** et la **haute disponibilité** (repartition des charges)

6. Vous avez un Windows Server propre qui vient d'être installé. Vous voulez qu'il devienne un controlleur de domaine AD au lieu d'un simple serveur. Qu'est-ce que vous devez configurer sur le serveur avant d'installer AD-DS?

    ??? success "Réponse"
        Avant d'installer AD DS, il faut:

        - Configurer une adresse IP statique
        - Configurer le nom du serveur (hostname)
        - Installer et configurer AD-DS

7. Expliquez brièvement qu'est-ce que c'est le schéma de l'AD

    ??? success "Réponse"
        Le schéma AD définit la structure de chaque objet de l'annuaire. C'est un ensemble de règles qui déterminent les attributs (propriétés) que chaque type d'objet (utilisateur, ordinateur, etc.) peut avoir.

        !!! example "Exemples d'attributs"

            - un utilisateur a des attributs comme nom, prénom, mot de passe, etc.
            - une OU a des attributs comme nom, description, etc.

8. Quelle est la relation entre schéma, partition et la base de données d'AD?

    ??? success "Réponse"
        La BD de AD a plusieurs partitions. Le schéma est juste une partition qui définit la structure des objets. La partition de domaine, par exemple, contient tous les objets de l'annuaire.

9. Qu'est-ce que c'est un catalogue global?

    ??? success "Réponse"
        Le catalogue global est une base de données qui contient une copie partielle de tous les objets de la forêt AD. Cela permet des recherches rapides d'objets dans toute la forêt.

## Chapitre 5. DNS-Pratique-avec-AD

1. Pourquoi le DNS est-il indispensable au fonctionnement de l'AD?

    ??? success "Réponse"
        L'AD utilise le DNS pour **localiser les contrôleurs de domaine** via des enregistrements spéciaux appelés **SRV records**. Sans DNS qui fonctionne correctement, les clients ne peuvent pas trouver les DC pour s'authentifier — l'AD devient inutilisable.

2. Si un client Windows ne peut pas rejoindre le domaine maxtec.be, quelle est la première chose à vérifier côté réseau?

    ??? success "Réponse"
        Vérifier la configuration **DNS du client**. Le client doit pointer vers un serveur DNS qui héberge la zone du domaine (dans notre cas, dns1.maxtec.be ou dns2.maxtec.be) — pas vers un DNS public comme 8.8.8.8.

3. Quelle est la différence entre une zone DNS **intégrée à l'AD** et une zone DNS **standard**?

    ??? success "Réponse"
        - **Intégrée à l'AD** : la zone est stockée dans la base de données AD et se réplique automatiquement entre les DC. Plus sécurisée et résiliente.
        - **Standard (fichier)** : la zone est stockée dans un fichier texte. La réplication doit être configurée manuellement (transfert de zone).

## Chapitre 6. Unités d'Organisation (OU)

1. Quelle est la différence entre une OU et un groupe?

    ??? success "Réponse"
        Une **OU est un conteneur** pour organiser les objets AD, tandis qu'un **groupe est utilisé pour attribuer des permissions** à plusieurs utilisateurs.

2. Pourquoi utiliser des OUs?

    ??? success "Réponse"
        Les OUs permettent de :

        - **Organiser** les objets de manière logique
        - **Déléguer** l'administration
        - **Appliquer** des stratégies de groupe (GPO)

3. Qu'est-ce que c'est une unité d'organisation? Qu'est-ce qu'il y a dans une OU?

    ??? success "Réponse"
        Une OU est un conteneur administratif dans AD qui peut contenir des utilisateurs, des ordinateurs, des groupes et d'autres OUs. Elle permet d'organiser les objets de manière hiérarchique et d'appliquer des stratégies de groupe.

4. Pourquoi on crée nos propres OU qui portent le nom Users si par défaut il y a déjà un 'conteneur' Users? Est-ce qu'il s'agit d'une OU?

    ??? success "Réponse"
        Le conteneur Users par défaut n'est pas une OU et ne permet pas l'application de stratégies de groupe. On crée nos propres OUs Users pour pouvoir appliquer des GPOs et mieux organiser les utilisateurs.

5. Quels sont les avantages d'une OU sur un conteneur?

    ??? success "Réponse"
        Les avantages des OUs incluent:

        - Possibilité d'appliquer des GPOs
        - Délégation d'administration
        - Organisation hiérarchique
        - Meilleure gestion des objets

6. Est-ce qu'on peut établir des stratégies de groupe sur les objets d'un groupe d'utilisateurs?

    ??? success "Réponse"
        Non, on ne peut pas appliquer des stratégies de groupe sur les objets d'un groupe d'utilisateurs. Les stratégies de groupe (GPOs) sont appliquées aux objets d'une OU, pas aux groupes.

## Chapitre 7. Gestion des Utilisateurs

1. Quel est l'outil le plus utilisé pour gérer l'AD?

    ??? success "Réponse"
        L'outil le plus utilisé est "Utilisateurs et ordinateurs Active Directory" (Active Directory Users and Computers ou ADUC) ou le centre de gestion Active Directory.

2. Pourquoi est-il déconseillé d'utiliser le compte Administrateur du domaine pour le travail quotidien?

    ??? success "Réponse"
        Le compte Administrateur a tous les droits sur le domaine. L'utiliser pour des tâches quotidiennes (lire des emails, naviguer sur internet) augmente le risque qu'un malware ou un attaquant compromette tout le domaine. La bonne pratique est d'avoir un compte standard pour le travail et un compte admin séparé uniquement pour l'administration.

3. Quelle est la différence entre désactiver un utilisateur et le supprimer?

    ??? success "Réponse"
        - **Désactiver** : le compte existe toujours dans l'AD, mais ne peut plus se connecter. Son SID, ses appartenances aux groupes et ses permissions sont préservés. Idéal pour un départ temporaire ou un employé qui quitte (en attendant transfert des données).
        - **Supprimer** : le compte est éliminé. Si on recrée un utilisateur avec le même nom, il aura un nouveau SID et perdra toutes ses anciennes permissions.

4. Qu'est-ce que c'est un SID et pourquoi est-il important?

    ??? success "Réponse"
        Le SID (**Security Identifier**) est l'identifiant unique d'un objet AD (utilisateur, groupe, ordinateur). Windows utilise le SID — pas le nom — pour appliquer les permissions. C'est pour cela que recréer un utilisateur avec le même nom ne récupère pas ses anciens droits.

        !!! example "Exemple de SID"
            ```
            S-1-5-21-3623811015-3361044348-30300820-1013
            ```

            - `S` : indique qu'il s'agit d'un SID
            - `1` : version du SID
            - `5` : autorité (NT Authority)
            - `21-3623811015-3361044348-30300820` : identifiant unique du **domaine** maxtec.be
            - `1013` : **RID** (Relative ID) — propre à l'objet dans ce domaine

            Si on supprime l'utilisateur `jdupont` puis on en recrée un avec le même nom, il aura un nouveau RID (par ex. `1247`) et donc un nouveau SID. Toutes les permissions liées à l'ancien SID sont perdues.

        !!! info "SID vs distinguishedName : ne pas confondre"
            Un objet AD a **deux identifiants** très différents :

            | | **SID** | **distinguishedName (DN)** |
            |---|---|---|
            | Format | `S-1-5-21-...-1013` | `CN=Jean Dupont,OU=Compta,OU=Users,DC=maxtec,DC=be` |
            | Rôle | Identifier pour la **sécurité** (ACL, permissions) | Identifier l'**emplacement** dans l'arbre AD |
            | Change si... | on supprime/recrée l'objet | on **déplace** l'objet dans une autre OU ou on le **renomme** |
            | Utilisé par | Windows (kernel, ACL) | LDAP, scripts, GPO scoping |

            Conséquences pratiques :

            - Déplacer `jdupont` de l'OU `Compta` vers `Direction` change son **DN** mais pas son **SID** → il garde toutes ses permissions.
            - Supprimer `jdupont` puis le recréer change son **SID** → toutes les permissions sont perdues, même si le DN finit par être identique.

        !!! tip "Voir le SID dans ADUC (interface graphique)"
            1. Ouvrir **Utilisateurs et ordinateurs Active Directory**
            2. Menu **Affichage → Fonctionnalités avancées** (à cocher)
            3. Clic droit sur l'utilisateur → **Propriétés**
            4. Onglet **Éditeur d'attributs**
            5. Chercher l'attribut **`objectSid`** (et `distinguishedName` juste à côté pour comparer)

5. Pourquoi utilise-t-on le préfixe `GG-` pour les groupes globaux dans le lab maxtec.be?

    ??? success "Réponse"
        C'est une convention de nommage qui permet d'identifier rapidement le **type de groupe** (GG = Groupe Global). On peut aussi voir `DL-` pour Domain Local et `UG-` pour Universal. Cela facilite la lecture, le tri et la documentation, surtout quand un environnement a des centaines de groupes.

6. Quelle est la différence entre un groupe **Global**, **Domain Local** et **Universal**?

    ??? success "Réponse"
        - **Global (GG)** : regroupe des utilisateurs du **même domaine**. C'est dans ce groupe qu'on met les personnes.
        - **Domain Local (DL)** : reçoit les permissions sur une ressource (un dossier, une imprimante). C'est ce groupe qu'on associe à un ACL.
        - **Universal (UG)** : utile dans une forêt multi-domaines pour réunir des groupes globaux de différents domaines.

        La règle classique **AGDLP** dit : on met les **A**ccounts dans des **G**lobals, qu'on imbrique dans des **D**omain **L**ocals, qui reçoivent les **P**ermissions.

## Chapitre 8. Group Policy Objects

1. Qu'est-ce que c'est une GPO?

    ??? success "Réponse"
        Une GPO (**Group Policy Object**) est un ensemble de paramètres de configuration qu'on applique de manière centralisée à des utilisateurs ou des ordinateurs du domaine. Cela évite de configurer chaque poste manuellement.

2. Sur quels objets une GPO peut-elle être liée (linked)?

    ??? success "Réponse"
        Une GPO peut être liée à trois niveaux :

        - Un **site** AD
        - Un **domaine** entier
        - Une **OU**

        On ne peut **pas** lier une GPO directement à un groupe ou à un utilisateur individuel.

3. Quelle est la différence entre la section **Computer Configuration** et **User Configuration** d'une GPO?

    ??? success "Réponse"
        - **Computer Configuration** : s'applique à la machine, au démarrage. Indépendant de qui se connecte.
        - **User Configuration** : s'applique à l'utilisateur, à la connexion. Suit l'utilisateur d'une machine à l'autre.

4. Dans quel ordre les GPOs sont-elles appliquées?

    ??? success "Réponse"
        L'ordre est **LSDOU** :

        1. **L**ocal (la machine elle-même)
        2. **S**ite
        3. **D**omaine
        4. **O**U (de la plus haute à la plus basse)

        Si deux GPOs définissent la même valeur, **la dernière appliquée gagne** — donc une GPO liée à une OU enfant peut écraser celle du domaine.

5. Que fait la commande `gpupdate /force`?

    ??? success "Réponse"
        Elle force le rafraîchissement immédiat des GPOs sur la machine, sans attendre le cycle automatique (toutes les 90 minutes environ). Utile pour tester une nouvelle GPO sans redémarrer.

## Chapitre 9. PowerShell AD

1. Pourquoi utiliser PowerShell pour gérer l'AD au lieu de l'interface graphique?

    ??? success "Réponse"
        PowerShell permet :

        - **L'automatisation** : créer 100 utilisateurs en une commande au lieu de cliquer 100 fois
        - **La reproductibilité** : un script s'exécute toujours de la même façon
        - **L'audit** : on peut sauvegarder les scripts et savoir ce qui a été fait
        - **L'accès à des paramètres avancés** non disponibles dans la GUI

2. Quel module faut-il importer pour gérer l'AD via PowerShell?

    ??? success "Réponse"
        Le module **`ActiveDirectory`**. Il est installé automatiquement sur un contrôleur de domaine, et disponible via les RSAT sur un poste client.

        ```powershell
        Import-Module ActiveDirectory
        ```

3. Quelle est la différence entre `Get-ADUser` et `Get-ADUser -Filter *`?

    ??? success "Réponse"
        - `Get-ADUser` seul attend un identifiant et renverra une erreur.
        - `Get-ADUser -Filter *` récupère **tous** les utilisateurs du domaine. L'astérisque agit comme un "joker".

4. À quoi sert le paramètre `-SearchBase` dans les commandes AD?

    ??? success "Réponse"
        Il limite la recherche à une **OU spécifique** au lieu de chercher dans tout le domaine. Utile pour ne pas surcharger les requêtes :

        ```powershell
        Get-ADUser -Filter * -SearchBase "OU=Compta,OU=Users,DC=maxtec,DC=be"
        ```
