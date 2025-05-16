# Exercices: Unités d'Organisation, Users et Groupes

## Exercice 1: Création de la Structure d'Unités d'Organisation

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

## Exercice 2: Création d'Users par Département

Vous devez créer plusieurs Users pour différents départements selon la convention de nommage établie.

Tâches:
1. Créer les Users suivants dans l'OU Comptabilité de la zone EU:
   - sophie.lambert (Comptable Senior)
   - thomas.dubois (Assistant Comptable)

2. Créer les Users suivants dans l'OU RH de la zone EU:
   - julie.martin (Responsable RH)
   - nicolas.petit (Recruteur)

3. Créer les Users suivants dans l'OU Ventes de la zone EU:
   - pierre.durand (Directeur Commercial)
   - isabelle.moreau (Commerciale)

4. Pour chaque utilisateur:
   - Définir le mot de passe standard: "Password1!"
   - Configurer le changement de mot de passe à la première connexion
   - Remplir les champs: Prénom, Nom, Titre, Département, E-mail (prenom.nom@maxtec.be)

## Exercice 4: Création de Groupes et Attribution de Membres

Vous devez créer des groupes selon la convention de nommage établie et y ajouter les Users appropriés.

Tâches:
1. Créer les groupes globaux suivants dans l'OU Groupes de la zone EU:
   - GG-EU-Compta-Users
   - GG-EU-RH-Users
   - GG-EU-Ventes-Users

2. Ajouter les Users appropriés à chaque groupe:
   - sophie.lambert et thomas.dubois dans GG-EU-Compta-Users
   - julie.martin et nicolas.petit dans GG-EU-RH-Users
   - pierre.durand et isabelle.moreau dans GG-EU-Ventes-Users

3. Créer les groupes de domaine local suivants:
   - DL-EU-Rapports-Lecture
   - DL-EU-Rapports-Modification

4. Ajouter les groupes globaux aux groupes de domaine local:
   - GG-EU-Compta-Users et GG-EU-RH-Users dans DL-EU-Rapports-Lecture
   - GG-EU-Ventes-Users dans DL-EU-Rapports-Modification

## Exercice 5: Gestion des Comptes Users

Vous devez effectuer diverses opérations de gestion sur les comptes Users.

Tâches:
1. Désactiver le compte de thomas.dubois (congé sabbatique)
2. Définir une date d'expiration dans 3 mois pour le compte d'isabelle.moreau (contrat temporaire)
3. Configurer des restrictions horaires pour nicolas.petit (accès uniquement du lundi au vendredi, de 8h à 18h)
4. Configurer des restrictions de poste de travail pour julie.martin (connexion uniquement sur ws-rh-01.maxtec.be)

## Exercice 6: Migration d'Users et Computers

Suite à une restructuration, l'équipe Support (2 personnes) passe du service Ventes au service RH.

Tâches:
1. Créer deux Users dans l'OU Ventes/Users:
   - alex.bernard (Support Technique)
   - emma.leroy (Support Technique)
2. Créer deux Computers dans l'OU Ventes/Computers (opt, car on devrait créer des VMs):
   - ws-ventes-03
   - ws-ventes-04
3. Déplacer ces Users et Computers vers les OUs correspondantes du service RH
4. Mettre à jour les appartenances aux groupes:
   - Retirer alex.bernard et emma.leroy de GG-EU-Ventes-Users
   - Ajouter alex.bernard et emma.leroy à GG-EU-RH-Users

## Exercice 7: Création d'une Structure Internationale (opt)

L'entreprise s'étend aux États-Unis et vous devez configurer une structure similaire pour la zone US.

Tâches:
1. Créer les mêmes départements dans l'OU US que ceux existant dans l'OU EU
2. Créer les Users suivants dans l'OU Ventes de la zone US:
   - john.smith (Sales Manager)
   - sarah.johnson (Sales Representative)
3. Créer un groupe global GG-US-Ventes-Users et y ajouter ces Users
4. Créer un groupe universel U-Global-Ventes qui contient:
   - GG-EU-Ventes-Users
   - GG-US-Ventes-Users

## Exercice 8: Recherche et Filtrage d'Objets AD

Vous devez effectuer des recherches spécifiques dans l'Active Directory.

Tâches:
1. Trouver tous les Users du département Comptabilité
2. Lister tous les groupes dont sophie.lambert est membre
4. Trouver tous les Computers de l'OU RH
5. Lister tous les Users désactivés

## Exercice 9: Gestion des Groupes Imbriqués

Vous devez créer une structure de groupes imbriqués pour gérer les accès à différentes ressources.

Tâches:
1. Créer les groupes de domaine local suivants:
   - DL-EU-Finance-Lecture
   - DL-EU-Finance-Modification
   - DL-EU-Marketing-Lecture
   - DL-EU-Marketing-Modification

2. Créer les groupes globaux suivants:
   - GG-EU-Direction
   - GG-EU-Managers

3. Ajouter pierre.durand au groupe GG-EU-Direction
4. Ajouter sophie.lambert et julie.martin au groupe GG-EU-Managers

5. Configurer les accès suivants:
   - GG-EU-Direction a accès à tous les groupes DL (Lecture et Modification)
   - GG-EU-Managers a accès uniquement aux groupes DL-Lecture
   - GG-EU-Compta-Users a accès à DL-EU-Finance-Lecture
   - GG-EU-Ventes-Users a accès à DL-EU-Marketing-Lecture et DL-EU-Marketing-Modification

