On aurait alors deux contrôleurs de domaine (DC) qui :
1. Agissent comme serveurs DNS avec des responsabilités distinctes :
   - `dns1.computerelectronics.be` (`192.168.0.2`) gère les zones DNS pour les départements comptabilité et RH
   - `dns2.computerelectronics.be` (`192.168.0.3`) gère la zone DNS pour le département ventes

2. **Maintiennent chacun une copie complète de la base de données AD DS** qui est automatiquement répliquée entre eux

Mais pour notre cours on va installer AD, pour le moment, uniquement sur `dns1.computerelectronics.be` (`192.168.0.2`) (le seul serveur qu'on a virtualisé).


**Dans notre infrastructure `computerelectronics.be`, un même ordinateur est représenté** :
   - Dans **DNS** : par son **nom de domaine complet** (FQDN)
     Exemple : `ws-compta-01.computerelectronics.be`
   - Dans **AD DS** : par son **nom distinctif** (Distinguished Name - DN)
     Exemple : `CN=ws-compta-01,OU=Ordinateurs,OU=Comptabilite,DC=computerelectronics,DC=be`C=be` (on comprendra mieux cette notation plus tard, quand on verra les Unités d'Organisation - OU)

Active Directory Domain Services (AD DS) utilise un espace de noms DNS pour gérer un domaine : c'est indispensable d'avoir un serveur DNS au sein du réseau.


#### Points clés de l'intégration DNS-AD DS :
1. Localisation des services
   - Les clients utilisent DNS pour localiser les contrôleurs de domaine
   - Les enregistrements SRV dans DNS identifient les services disponibles
   - Exemple : `_ldap._tcp.computerelectronics.be` pointe vers les DC
