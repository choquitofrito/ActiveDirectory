# Réponses aux questions

## Chapitre 2. DNS

1. Quand une machine client est ajoutée au domaine via la console AD, elle utilise le DNS pour localiser son DC. Elle recherche des enregistrements SRV spécifiques dans le DNS qui contiennent les informations sur l'emplacement des DCs disponibles dans le domaine. Ces enregistrements sont automatiquement créés lors de la promotion du serveur en DC.

2. DNS est un prérequis pour AD DS. L'installation d'AD DS peut configurer DNS automatiquement, mais il est recommandé de le configurer manuellement d'abord.

3. Une structure hiérarchique qui organise les noms de domaine. Dans notre cas: computerelectronics.be est l'espace de noms racine.

4. Un arbre DNS est une structure hiérarchique de noms de domaine partageant un nom racine commun. Une forêt est un ensemble d'arbres DNS qui ne partagent pas le même nom racine.

5. Le DNS est fondamental pour le fonctionnement d'AD. Un domaine AD utilise le DNS pour stocker des enregistrements essentiels comme les SRV (qui indiquent l'emplacement des DCs), les enregistrements A (pour la résolution de noms d'hôtes), et les enregistrements CNAME. Le nom du domaine AD est également utilisé comme zone DNS, mais la structure peut être différente car les zones DNS sont des divisions administratives tandis que les domaines AD sont des limites de sécurité.

## Chapitre 3. Active Directory Domain Services (AD DS)
1. C'est un service d'annuaire qui centralise l'administration des ressources réseau. Il permet de gérer les utilisateurs, ordinateurs, et ressources de manière centralisée.

2. AD DS (Active Directory Domain Services) est le service le plus important. C'est le cœur d'AD qui gère l'authentification et l'autorisation.

3. Un domaine est une limite administrative et de sécurité. Il permet de centraliser la gestion des ressources et des politiques.

4. Le DC héberge une copie de la base de données AD. Il gère l'authentification et l'autorisation des utilisateurs et applique les politiques de sécurité.

5. Les deux serveurs contiennent une copie de la base de données AD. La réplication assure que les deux copies restent synchronisées.

6. Installation du rôle DNS Server, configuration d'une adresse IP statique, configuration du nom d'ordinateur, et installation des prérequis d'AD DS.

7. Le schéma définit tous les types d'objets et leurs attributs possibles dans AD. C'est comme un "plan" qui définit la structure de la base de données AD.

8. Le schéma est stocké dans une partition spéciale de la BD d'AD. La BD d'AD est divisée en plusieurs partitions (schéma, configuration, domaine).

9. Le catalogue global contient un sous-ensemble d'attributs définis dans le schéma. Le schéma détermine quels attributs sont répliqués dans le catalogue global.

## Chapitre 4. Gestion des Utilisateurs
1. Ces utilisateurs restent des utilisateurs locaux. Ils ne sont pas automatiquement migrés vers AD DS. Il faut créer de nouveaux comptes dans AD DS.

2. "Active Directory Users and Computers" (ADUC). Accessible via le "Server Manager" ou en exécutant "dsa.msc".

## Chapitre 5. Unités d'Organisation (OU)
1. Une OU est un conteneur administratif dans AD qui peut contenir des utilisateurs, ordinateurs, groupes et autres OUs. Elle permet d'appliquer des stratégies de groupe.

2. Le conteneur Users par défaut est un conteneur système, pas une OU. Les OUs permettent d'appliquer des GPOs, contrairement aux conteneurs système.

3. Application de GPOs possible, délégation d'administration possible, structure organisationnelle plus flexible, meilleur contrôle des objets.

4. Oui, c'est une des principales fonctionnalités des OUs. Les GPOs peuvent être appliquées aux OUs et affectent tous les objets qu'elles contiennent.
