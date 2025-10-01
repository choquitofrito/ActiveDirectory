### Concepts de base

Essaye de repondre à ces questions en utilisant tes propres mots. Tout l'information se trouve dans le syllabus.

## Chapitre 3. DNS
1. À quoi sert le DNS?

<details>
<summary>Réponse</summary>
Le DNS (**Domain Name System**) **traduit les noms de domaine en adresses IP** et vice-versa. Cela permet aux ordinateurs de se connecter en utilisant des **noms faciles à retenir** plutôt que des adresses IP.
</details>
<br>

2. Où est-ce qu'on stocke la correspondance entre les noms et les adresses IP?
<details>
<summary>Réponse</summary>
Les serveurs DNS stockent la correspondance entre les noms et les adresses IP dans leurs bases de données, dans les registres DNS.
Par exemple:

```
ws-compta-01 IN A 192.168.10.128
``` 

</details>
<br>

3. Qu'est-ce que c'est un arbre DNS et une forêt DNS?
<br>
<details>
<summary>Réponse</summary>
Un arbre DNS est une structure hiérarchique de noms de domaine partageant un même suffixe (ex: .maxtec.be). Une forêt DNS est l'ensemble de tous les arbres DNS sur Internet.
</details>
<br>

4. Qu'est-ce que c'est un serveur avec autorité?
<br>
<details>
<summary>Réponse</summary>
Un serveur DNS avec autorité est responsable d'une zone DNS spécifique. Il maintient les enregistrements officiels pour cette zone et peut répondre directement aux requêtes sans consulter d'autres serveurs (comme notre `dns1.maxtec.be`)
</details>
<br>


## Chapitre 3. Active Directory Domain Services (AD DS)

1. Qu'est-ce que Active Directory?
<details>
<summary>Réponse</summary>
Active Directory est un service d'annuaire de Microsoft qui stocke des informations sur les objets d'un réseau (utilisateurs, ordinateurs, imprimantes) et permet leur gestion centralisée.
</details>
<br>

2. Qu'est-ce que c'est Active Directory Domain Services (AD DS)?
<details>
<summary>Réponse</summary>
AD DS est le service principal d'Active Directory qui gère les utilisateurs et les ressources du domaine. Il fournit les services d'authentification et d'autorisation.
</details>
<br>

3. Qu'est-ce que c'est un domaine AD?
<details>
<summary>Réponse</summary>
Un domaine AD est la structure administrative qui regroupe l'ensemble des éléments qui se trouvent dans le même annuaire (utilisateurs, ordinateurs, UOs, GPOs...). Le domaine AD porte le même nom que le domaine dns, pour nous `dns1.maxtec.be`.
</details>
<br>

4. Qu'est-ce que c'est un Domain Controller (DC)?
<details>
<summary>Réponse</summary>
Un contrôleur de domaine est un serveur qui héberge une copie de la base de données Active Directory. 
Il gère l'authentification des utilisateurs et applique les politiques de sécurité du domaine.
</details>
<br>

5. Dans le réseau de maxtec.be, est-ce que la base de données d'AD est censée d'être sur dns1, dns2 ou les deux?
<details>
<summary>Réponse</summary>
La base de données AD doit être sur les **deux serveurs** (dns1 et dns2) car ils sont tous les deux des contrôleurs de domaine. Cela assure la **redondance** et la **haute disponibilité** (repartition des charges)
</details>
<br>

6. Vous avez un Windows Server propre qui vient d'être installé. Vous voulez qu'il devienne un controlleur de domaine AD au lieu d'un simple serveur. Qu'est-ce que vous devez configurer sur le serveur avant d'installer AD-DS?
<details>
<summary>Réponse</summary>
Avant d'installer AD DS, il faut:
- Configurer une adresse IP statique
- Configurer le nom du serveur (hostname)
- Installer et configurer AD-DS
</details>
<br>

7. Expliquez brièvement qu'est-ce que c'est le schéma de l'AD
<details>
<summary>Réponse</summary>
Le schéma AD définit la structure de chaque objet de l'annuaire. C'est un ensemble de règles qui déterminent les attributs (propriétés) que chaque type d'objet (utilisateur, ordinateur, etc.) peut avoir.

Examples: 
- un utilisateur a des attributs comme nom, prénom, mot de passe, etc.
- une OU a des attributs comme nom, description, etc.
</details>
<br>

8. Quelle est la relation entre schéma, partition et la base de données d'AD?
<details>
<summary>Réponse</summary>
La BD de AD a plusieurs partitions. Le schéma est juste une partition qui définit la structure des objets. La partition de domaine, par exemple, contient tous les objets de l'annuaire. </details>
<br>

9.  Qu'est-ce que c'est un catalogue global?
<details>
<summary>Réponse</summary>
Le catalogue global est une base de données qui contient une copie partielle de tous les objets de la forêt AD. Cela permet  des recherches rapides d'objets dans toute la forêt.
</details>
<br>

## Chapitre 7. Gestion des Utilisateurs

1. Quel est l'outil le plus utilisé pour gérer l'AD?
<details>
<summary>Réponse</summary>
L'outil le plus utilisé est "Utilisateurs et ordinateurs Active Directory" (Active Directory Users and Computers ou ADUC) ou le centre de gestion Active Directory.
</details>
<br>

## Chapitre 6. Unités d'Organisation (OU)
1. Quelle est la différence entre une OU et un groupe?
<details>
<summary>Réponse</summary>
Une **OU est un conteneur** pour organiser les objets AD, tandis qu'un **groupe est utilisé pour attribuer des permissions** à plusieurs utilisateurs.
</details>
<br>

2. Pourquoi utiliser des OUs?
<details>
<summary>Réponse</summary>
Les OUs permettent de :
- **Organiser** les objets de manière logique
- **Déléguer** l'administration
- **Appliquer** des stratégies de groupe (GPO)
</details>
<br>

3. Qu'est-ce que c'est une unité d'organisation? Qu'est-ce qu'il y a dans une OU?
<details>
<summary>Réponse</summary>
Une OU est un conteneur administratif dans AD qui peut contenir des utilisateurs, des ordinateurs, des groupes et d'autres OUs. Elle permet d'organiser les objets de manière hiérarchique et d'appliquer des stratégies de groupe.
</details>
<br>

4. Pourquoi on crée nos propres OU qui portent le nom Users si par défaut il y a déjà un 'conteneur' Users? Est-ce qu'il s'agit d'une OU?
<details>
<summary>Réponse</summary>
Le conteneur Users par défaut n'est pas une OU et ne permet pas l'application de stratégies de groupe. On crée nos propres OUs Users pour pouvoir appliquer des GPOs et mieux organiser les utilisateurs.
</details>
<br>

5. Quels sont les avantages d'une OU sur un conteneur?
<details>
<summary>Réponse</summary>
Les avantages des OUs incluent:
- Possibilité d'appliquer des GPOs
- Délégation d'administration
- Organisation hiérarchique
- Meilleure gestion des objets
</details>
<br>

6. Est-ce qu'on peut établir des stratégies de groupe sur les objets d'un groupe d'utilisateurs?
<details>
<summary>Réponse</summary>
Non, on ne peut pas appliquer des stratégies de groupe sur les objets d'un groupe d'utilisateurs. Les stratégies de groupe (GPOs) sont appliquées aux objets d'une OU, pas aux groupes.
</details>

