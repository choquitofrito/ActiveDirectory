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

2. Qu'est-ce que c'est un enregistrement SRV?

    ??? success "Réponse"
        Un enregistrement SRV (Service) indique **quel serveur fournit quel service** sur le réseau. Par exemple, `_ldap._tcp.maxtec.be` indique aux clients quels serveurs offrent le service LDAP du domaine.

3. Si un client Windows ne peut pas rejoindre le domaine maxtec.be, quelle est la première chose à vérifier côté réseau?

    ??? success "Réponse"
        Vérifier la configuration **DNS du client**. Le client doit pointer vers un serveur DNS qui héberge la zone du domaine (dans notre cas, dns1.maxtec.be ou dns2.maxtec.be) — pas vers un DNS public comme 8.8.8.8.

4. Quelle est la différence entre une zone DNS **intégrée à l'AD** et une zone DNS **standard**?

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
