# Exercices: Unités d'Organisation et Utilisateurs - Départements Complémentaires

## 1. 🔹 Création de la Structure d'Unités d'Organisation Complémentaires

Suite à l'expansion de l'entreprise maxtec.be, vous êtes chargé(e) de créer des unités d'organisation pour les nouveaux départements qui viennent d'être formés.

Tâches:
1. Sous les OUs géographiques existantes (EU et US), créer les nouvelles OUs départementales:
   - OU=Informatique
   - OU=Marketing
   - OU=Logistique

2. Sous chaque nouvelle OU départementale, créer les sous-OUs:
   - OU=Users
   - OU=Computers

## 2. 🔹 Création d'Utilisateurs pour les Nouveaux Départements

Vous devez créer plusieurs utilisateurs pour les nouveaux départements selon la convention de nommage établie.

Tâches:
1. Créer les utilisateurs suivants dans l'OU Informatique de la zone EU:
   - ivan.dupont (Administrateur Système)
   - isabelle.martin (Développeuse)
   - igor.lefebvre (Technicien Support)

2. Créer les utilisateurs suivants dans l'OU Marketing de la zone EU:
   - marc.rousseau (Directeur Marketing)
   - mélanie.blanc (Chargée de Communication)
   - michel.robert (Designer Graphique)

3. Créer les utilisateurs suivants dans l'OU Logistique de la zone EU:
   - lucas.girard (Responsable Logistique)
   - léa.fontaine (Gestionnaire de Stock)

4. Pour chaque utilisateur:
   - Définir le mot de passe standard: "Password1!"
   - Configurer le changement de mot de passe à la première connexion
   - Remplir les champs: Prénom, Nom, Titre, Département, E-mail (prenom.nom@maxtec.be)

## 3. 🔹 Création de Groupes Globaux pour les Nouveaux Départements

Vous devez créer des groupes globaux pour les nouveaux départements et y ajouter les utilisateurs appropriés.

Tâches:
1. Créer les groupes globaux suivants dans l'OU Groupes de la zone EU:
   - GG-EU-Info-Users
   - GG-EU-Marketing-Users
   - GG-EU-Logistique-Users

2. Ajouter les utilisateurs appropriés à chaque groupe:
   - ivan.dupont, isabelle.martin et igor.lefebvre dans GG-EU-Info-Users
   - marc.rousseau, mélanie.blanc et michel.robert dans GG-EU-Marketing-Users
   - lucas.girard et léa.fontaine dans GG-EU-Logistique-Users

## 4. 🔹 Gestion des Comptes Utilisateurs Spéciaux

Vous devez effectuer diverses opérations de gestion sur certains comptes utilisateurs.

Tâches:
1. Configurer le compte d'ivan.dupont comme compte d'administrateur (ajouter au groupe "Administrateurs du domaine")
2. Définir une date d'expiration dans 6 mois pour le compte de michel.robert (contrat à durée déterminée)
3. Configurer des restrictions horaires pour léa.fontaine (accès uniquement du lundi au vendredi, de 7h à 19h)
4. Configurer des restrictions de poste de travail pour igor.lefebvre (connexion uniquement sur ws-info-01.maxtec.be)

## 5. 🔹 Création d'une Structure de Projet Temporaire

L'entreprise lance un nouveau projet marketing qui nécessite une collaboration entre plusieurs départements.

Tâches:
1. Créer une nouvelle OU "Projets" sous l'OU EU
2. Créer une sous-OU "ProjetNouveauSite" sous l'OU Projets
3. Créer un groupe global GG-EU-ProjetSite-Membres dans l'OU Groupes
4. Ajouter les membres suivants au groupe GG-EU-ProjetSite-Membres:
   - isabelle.martin (Informatique)
   - mélanie.blanc (Marketing)
   - michel.robert (Marketing)
   - Un utilisateur de votre choix du département Ventes (créé dans l'exercice précédent)

## 6. 🔹 Recherche et Filtrage d'Objets AD Avancés

Vous devez effectuer des recherches spécifiques dans l'Active Directory pour les nouveaux départements.

Tâches:
1. Trouver tous les utilisateurs du département Marketing
2. Lister tous les groupes dont isabelle.martin est membre
3. Trouver tous les utilisateurs dont le titre contient "Responsable" ou "Directeur/Directrice"
4. Créer une requête LDAP pour trouver tous les utilisateurs créés aujourd'hui

## 7. 🔹 Délégation de Contrôle pour les Nouveaux Départements

Vous devez configurer la délégation de contrôle pour permettre aux responsables de département de gérer leurs propres utilisateurs.

Tâches:
1. Déléguer à ivan.dupont (Informatique) les droits pour:
   - Créer, supprimer et gérer les comptes utilisateurs dans l'OU Informatique
   - Réinitialiser les mots de passe des utilisateurs dans l'OU Informatique

2. Déléguer à marc.rousseau (Marketing) les droits pour:
   - Créer, supprimer et gérer les comptes utilisateurs dans l'OU Marketing
   - Réinitialiser les mots de passe des utilisateurs dans l'OU Marketing

3. Déléguer à lucas.girard (Logistique) les droits pour:
   - Créer, supprimer et gérer les comptes utilisateurs dans l'OU Logistique
   - Réinitialiser les mots de passe des utilisateurs dans l'OU Logistique

## 8. 🔹 Intégration avec les Départements Existants (Exercice Optionnel)

Vous devez créer un comité de direction qui regroupe les responsables de tous les départements.

Tâches:
1. Créer un groupe global GG-EU-Comite-Direction dans l'OU Groupes
2. Ajouter les responsables suivants au groupe:
   - ivan.dupont (Informatique)
   - marc.rousseau (Marketing)
   - lucas.girard (Logistique)
   - Un responsable du département Comptabilité (créé dans l'exercice précédent)
   - Un responsable du département RH (créé dans l'exercice précédent)
   - Un responsable du département Ventes (créé dans l'exercice précédent)

## 9. 🔹 Création d'une Structure Internationale pour les Nouveaux Départements (Exercice Optionnel)

L'entreprise étend ses nouveaux départements aux États-Unis.

Tâches:
1. Créer les mêmes départements (Informatique, Marketing, Logistique) dans l'OU US
2. Créer au moins deux utilisateurs pour chaque département dans la zone US
3. Créer les groupes globaux correspondants (GG-US-Info-Users, GG-US-Marketing-Users, GG-US-Logistique-Users)
4. Créer des groupes universels pour chaque fonction qui regroupent les utilisateurs des deux zones:
   - U-Global-Info-Users (contient GG-EU-Info-Users et GG-US-Info-Users)
   - U-Global-Marketing-Users (contient GG-EU-Marketing-Users et GG-US-Marketing-Users)
   - U-Global-Logistique-Users (contient GG-EU-Logistique-Users et GG-US-Logistique-Users)
