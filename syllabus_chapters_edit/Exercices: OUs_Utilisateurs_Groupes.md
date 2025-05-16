# Exercices: Unités d'Organisation, Utilisateurs et Groupes

## 1. 🔹 Création de la Structure d'Unités d'Organisation

Le département informatique vous a chargé de créer la structure d'Unités d'Organisation (OUs) pour l'entreprise maxtec.be selon les standards établis.

Tâches:
1. Créer les OUs géographiques principales:
   - OU=EU,DC=maxtec,DC=be
   - OU=US,DC=maxtec,DC=be

2. Sous chaque OU géographique, créer les OUs départementales:
   - OU=Comptabilité
   - OU=RH
   - OU=Ventes

3. Sous chaque OU départementale, créer les sous-OUs:
   - OU=Users
   - OU=Computers

4. Créer une OU "Groupes" sous chaque OU géographique

## 2. 🔹 Création d'Utilisateurs par Département

Vous devez créer plusieurs utilisateurs pour différents départements selon la convention de nommage établie.

Tâches:
1. Créer les utilisateurs suivants dans l'OU Comptabilité de la zone EU:
   - charles (Comptable Senior)
   - cindy (Assistant Comptable)

2. Créer les utilisateurs suivants dans l'OU RH de la zone EU:
   - rene (Responsable RH)
   - rebecca (Recruteur)

3. Créer les utilisateurs suivants dans l'OU Ventes de la zone EU:
   - victor (Directeur Commercial)
   - vanessa (Commerciale)

4. Pour chaque utilisateur:
   - Définir le mot de passe standard: "Password1!"
   - Configurer le changement de mot de passe à la première connexion
   - Remplir les champs: Prénom, Nom, Titre, Département, E-mail (prenom@maxtec.be)

## 4. 🔹 Création de Groupes et Attribution de Membres

Vous devez créer des groupes selon la convention de nommage établie et y ajouter les utilisateurs appropriés.

Tâches:
1. Créer les groupes globaux suivants dans l'OU Groupes de la zone EU:
   - GG-EU-Compta-Users
   - GG-EU-RH-Users
   - GG-EU-Ventes-Users

2. Ajouter les utilisateurs appropriés à chaque groupe:
   - charles et cindy dans GG-EU-Compta-Users
   - rene et rebecca dans GG-EU-RH-Users
   - victor et vanessa dans GG-EU-Ventes-Users

3. Créer les groupes globaux fonctionnels suivants dans l'OU Groupes de la zone EU:
   - GG-EU-Rapports-Lecture (pour les utilisateurs ayant accès en lecture aux rapports)
   - GG-EU-Rapports-Modification (pour les utilisateurs ayant accès en modification aux rapports)

4. Ajouter les utilisateurs aux groupes fonctionnels selon leurs besoins:
   - Ajouter charles, cindy, rene et rebecca au groupe GG-EU-Rapports-Lecture
   - Ajouter victor et vanessa au groupe GG-EU-Rapports-Modification

## 5. 🔹 Gestion des Comptes Utilisateurs

Vous devez effectuer diverses opérations de gestion sur les comptes utilisateurs.

Tâches:
1. Désactiver le compte de cindy (congé sabbatique)
2. Définir une date d'expiration dans 3 mois pour le compte de vanessa (contrat temporaire)
3. Configurer des restrictions horaires pour rebecca (accès uniquement du lundi au vendredi, de 8h à 18h)
4. Configurer des restrictions de poste de travail pour rene (connexion uniquement sur ws-rh-01.maxtec.be)

## 6. 🔹 Migration d'Utilisateurs et Ordinateurs

Suite à une restructuration, l'équipe Support (2 personnes) passe du service Ventes au service RH.

Tâches:
1. Créer deux utilisateurs dans l'OU Ventes/Users:
   - valeria (Support Technique)
   - valentin (Support Technique)
2. Créer deux Computers dans l'OU Ventes/Computers (opt, car on devrait créer des VMs):
   - ws-ventes-03
   - ws-ventes-04
3. Déplacer ces utilisateurs et ordinateurs vers les OUs correspondantes du service RH
4. Mettre à jour les appartenances aux groupes:
   - Retirer valeria et valentin de GG-EU-Ventes-Users
   - Ajouter valeria et valentin à GG-EU-RH-Users

## 7. 🔹 Création d'une Structure Internationale (opt)

L'entreprise s'étend aux États-Unis et vous devez configurer une structure similaire pour la zone US.

Tâches:
1. Créer les mêmes départements dans l'OU US que ceux existant dans l'OU EU
2. Créer les utilisateurs suivants dans l'OU Ventes de la zone US:
   - victor.us (Sales Manager)
   - vanessa.us (Sales Representative)
3. Créer un groupe global GG-US-Ventes-Users et y ajouter ces utilisateurs
4. Créer un groupe universel U-Global-Ventes qui contient:
   - GG-EU-Ventes-Users
   - GG-US-Ventes-Users

## 8. 🔹 Recherche et Filtrage d'Objets AD

Vous devez effectuer des recherches spécifiques dans l'Active Directory.

Tâches:
1. Trouver tous les utilisateurs du département Comptabilité
2. Lister tous les groupes dont charles est membre
4. Trouver tous les Computers de l'OU RH
5. Lister tous les utilisateurs désactivés

## 9. 🔹 Gestion des Groupes Imbriqués

Vous devez créer une structure de groupes imbriqués pour gérer les accès à différentes ressources.

Tâches:
1. Créer les groupes globaux fonctionnels suivants dans l'OU Groupes de la zone EU:
   - GG-EU-Finance-Lecture
   - GG-EU-Finance-Modification
   - GG-EU-Marketing-Lecture
   - GG-EU-Marketing-Modification

2. Créer les groupes globaux de rôles suivants:
   - GG-EU-Direction
   - GG-EU-Managers

3. Ajouter victor au groupe GG-EU-Direction
4. Ajouter charles et rene au groupe GG-EU-Managers

5. Configurer les accès suivants (en ajoutant les groupes comme membres):
   - Ajouter GG-EU-Direction comme membre de tous les groupes fonctionnels (Lecture et Modification)
   - Ajouter GG-EU-Managers comme membre uniquement des groupes de Lecture
   - Ajouter GG-EU-Compta-Users comme membre de GG-EU-Finance-Lecture
   - Ajouter GG-EU-Ventes-Users comme membre de GG-EU-Marketing-Lecture et GG-EU-Marketing-Modification

