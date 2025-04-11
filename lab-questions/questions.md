# Questions pour la compréhension

Essaye de repondre à ces questions en utilisant tes propres mots. Tout l'information se trouve dans le syllabus.

## Chapitre 2. DNS
1. À quoi sert le DNS?
<details>
<summary>Réponse</summary>
Le DNS (Domain Name System) sert à traduire les noms de domaine en adresses IP et vice-versa. C'est comme un annuaire qui permet aux ordinateurs de se connecter en utilisant des noms faciles à retenir plutôt que des adresses IP.
</details>

2. Qui transforme les noms en IP et vice-versa?
<details>
<summary>Réponse</summary>
Les serveurs DNS effectuent cette transformation. Quand un client fait une requête DNS, le serveur DNS consulte sa base de données ou contacte d'autres serveurs DNS pour obtenir l'adresse IP correspondante.
</details>

3. Qu'est-ce que c'est un domain DNS?
<details>
<summary>Réponse</summary>
Un domaine DNS est une zone de l'espace de noms DNS, comme computerelectronics.be. Il représente un groupe d'ordinateurs et de services sous une même administration.
</details>

4. Qu'est-ce que c'est un arbre DNS et une forêt DNS?
<details>
<summary>Réponse</summary>
Un arbre DNS est une structure hiérarchique de noms de domaine partageant un même suffixe (ex: .computerelectronics.be). Une forêt DNS est l'ensemble de tous les arbres DNS sur Internet.
</details>

5. Qu'est-ce que c'est un serveur avec autorité?
<details>
<summary>Réponse</summary>
Un serveur DNS avec autorité est responsable d'une zone DNS spécifique. Il maintient les enregistrements officiels pour cette zone et peut répondre directement aux requêtes sans consulter d'autres serveurs.
</details>

6. Quand est-ce qu'on génére une requête iterative ou recursive?
<details>
<summary>Réponse</summary>
Une requête récursive est générée par un client vers son serveur DNS qui doit fournir la réponse complète. Une requête itérative est générée entre serveurs DNS, où chaque serveur renvoie soit la réponse, soit une référence vers un autre serveur.
</details>

## Chapitre 3. Active Directory Domain Services (AD DS)
1. Qu'est-ce que Active Directory?
<details>
<summary>Réponse</summary>
Active Directory est un service d'annuaire de Microsoft qui stocke des informations sur les objets d'un réseau (utilisateurs, ordinateurs, imprimantes) et permet leur gestion centralisée.
</details>

2. Qu'est-ce que c'est Active Directory Domain Services (AD DS)?
<details>
<summary>Réponse</summary>
AD DS est le service principal d'Active Directory qui gère les utilisateurs et les ressources du domaine. Il fournit les services d'authentification et d'autorisation.
</details>

3. Qu'est-ce que c'est un domaine AD?
<details>
<summary>Réponse</summary>
Un domaine AD est une limite administrative où tous les objets partagent la même base de données d'annuaire, les mêmes politiques de sécurité et les mêmes relations d'approbation.
</details>

4. Quelle est la différence entre un domain AD et le domain DNS? Quelle est leur relation?
<details>
<summary>Réponse</summary>
Un domaine DNS est une structure de nommage pour les ressources réseau, tandis qu'un domaine AD est une limite administrative de sécurité. Le domaine AD utilise la structure DNS pour son nommage, mais gère les aspects de sécurité et d'administration.
</details>

5. Qu'est-ce que c'est un Domain Controller (DC)?
<details>
<summary>Réponse</summary>
Un contrôleur de domaine est un serveur qui héberge une copie de la base de données Active Directory. Il gère l'authentification des utilisateurs et applique les politiques de sécurité du domaine.
</details>

6. Dans le réseau de computerelectronics.be, est-ce que la base de données d'AD est censée d'être sur dns1, dns2 ou les deux?
<details>
<summary>Réponse</summary>
La base de données AD doit être sur les deux serveurs (dns1 et dns2) car ils sont tous les deux des contrôleurs de domaine. Cela assure la redondance et la haute disponibilité.
</details>

7. Vous avez un Windows Server propre qui vient d'être installé. Vous voulez qu'il devienne un controlleur de domaine AD au lieu d'un simple serveur. Qu'est-ce que vous devez configurer sur le serveur avant d'installer AD-DS?
<details>
<summary>Réponse</summary>
Avant d'installer AD DS, il faut:
- Configurer une adresse IP statique
- Configurer le nom du serveur (hostname)
- Installer et configurer le rôle DNS
</details>

8. Expliquez brièvement qu'est-ce que c'est le schéma de l'AD
<details>
<summary>Réponse</summary>
Le schéma AD définit tous les types d'objets et leurs attributs qui peuvent exister dans Active Directory. C'est comme un plan qui détermine la structure de la base de données AD.
</details>

9. Quelle est la relation entre schéma, partition et la base de données d'AD?
<details>
<summary>Réponse</summary>
Le schéma définit la structure, les partitions sont des sections logiques de la base de données (domaine, configuration, schéma), et la base de données AD stocke toutes ces informations dans le fichier ntds.dit.
</details>

10. Qu'est-ce que c'est un catalogue global?
<details>
<summary>Réponse</summary>
Le catalogue global est une base de données qui contient une copie partielle de tous les objets de la forêt AD. Il permet des recherches rapides d'objets dans toute la forêt.
</details>

## Chapitre 4. Gestion des Utilisateurs
1. Qu'est-ce qui se passe avec les utilisateurs qui ont été créés sur Windows Server avant l'installation d'AD DS une fois qu'on installe AD DS et on fait la promotion?
<details>
<summary>Réponse</summary>
Les utilisateurs locaux restent dans la base de données SAM locale mais ne sont pas migrés vers AD. Il faut recréer ces comptes dans AD si nécessaire.
</details>

2. Quel est l'outil le plus utilisé pour gérer l'AD?
<details>
<summary>Réponse</summary>
L'outil le plus utilisé est "Utilisateurs et ordinateurs Active Directory" (Active Directory Users and Computers ou ADUC).
</details>

## Chapitre 5. Unités d'Organisation (OU)
1. Qu'est-ce que c'est une unité d'organisation? Qu'est-ce qu'il y a dans une OU?
<details>
<summary>Réponse</summary>
Une OU est un conteneur administratif dans AD qui peut contenir des utilisateurs, des ordinateurs, des groupes et d'autres OUs. Elle permet d'organiser les objets de manière hiérarchique et d'appliquer des stratégies de groupe.
</details>

2. Pourquoi on crée nos propres OU qui portent le nom Users si par défaut il y a déjà un 'conteneur' Users? Est-ce qu'il s'agit d'une OU?
<details>
<summary>Réponse</summary>
Le conteneur Users par défaut n'est pas une OU et ne permet pas l'application de stratégies de groupe. On crée nos propres OUs Users pour pouvoir appliquer des GPOs et mieux organiser les utilisateurs.
</details>

3. Quels sont les avantages d'une OU sur un conteneur?
<details>
<summary>Réponse</summary>
Les avantages des OUs incluent:
- Possibilité d'appliquer des GPOs
- Délégation d'administration
- Organisation hiérarchique
- Meilleure gestion des objets
</details>

4. Est-ce qu'on peut établir des stratégies de groupe sur les objets d'une OU?
<details>
<summary>Réponse</summary>
Oui, c'est un des principaux avantages des OUs. On peut appliquer des stratégies de groupe (GPOs) spécifiques aux objets d'une OU pour gérer leur configuration et sécurité.
</details>

