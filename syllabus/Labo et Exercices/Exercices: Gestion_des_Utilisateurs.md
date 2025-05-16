### Exercice 1: Création d'un Nouvel Employé
Le service Comptabilité accueille une nouvelle comptable junior, Sophie Dubois. 

Tâches:
1. Créer un compte utilisateur pour Sophie en suivant la convention de nommage établie
2. Définir un mot de passe temporaire qui respecte la politique de sécurité
3. Configurer le compte pour que Sophie doive changer son mot de passe à la première connexion
4. Remplir les informations de base:
   - Description: "Comptable Junior - Service Comptabilité"
   - Bureau: "Bâtiment A - 1er étage"
   - Téléphone: "+32 2 123 45 68"

### Exercice 2: Restrictions d'Accès
Pour des raisons de sécurité, Sophie ne doit pouvoir se connecter que:
- Sur le poste `ws-compta-01.maxtec.be`
- Du lundi au vendredi, de 8h à 18h (choisissez une heure qui vous permet de tester la connexion)

Tâches:
1. Configurer les restrictions de connexion pour les postes de travail
2. Définir les plages horaires autorisées


### Exercice 3: Audit de Sécurité
Vous devez vérifier les paramètres de sécurité du compte de Sophie.

Tâches:
1. Vérifier que le compte suit la politique de mot de passe
2. Confirmer que le compte expire dans 6 mois (durée du contrat d'essai)
3. Activer la journalisation des tentatives de connexion échouées

### Exercice 4: Désactivation d'un Compte
Jan Vandenbergh (jan.vandenbergh@maxtec.be) quitte l'entreprise aujourd'hui.

Tâches:
1. Désactiver son compte utilisateur
2. Documenter la désactivation dans le champ "Description" des propriétés du compte avec:
   - Date de désactivation
   - Raison: "Départ de l'entreprise"
   - Date de suppression prévue (dans 90 jours)
   Note: Le champ "Description" se trouve dans l'onglet "Général" des propriétés du compte
3. Vérifier qu'il ne peut plus se connecter

### Exercice 5 : Nettoyage des Accès
Suite au départ de Jan Vandenbergh:

Tâches:
1. Identifier tous les groupes dont il est membre
2. Le retirer de tous les groupes sauf "Domain Users"


### Exercice 6: Gestion des Homonymes
Deux nouveaux employés arrivent dans le service RH:
- Karim Benali (Recruteur Senior)
- Karim Benali (Assistant RH)

Tâches:
1. Créer les comptes pour les deux Karim Benali en évitant les conflits
2. Documenter clairement dans chaque compte le poste occupé
3. S'assurer que leurs adresses email restent professionnelles et cohérentes

### Exercice 7: Compte Temporaire
Un consultant externe, Marek Wojcik, arrive pour un audit de 3 mois.

Tâches:
1. Créer un compte temporaire avec:
   - Date d'expiration automatique dans 90 jours
   - Accès limité à `ws-compta-01` uniquement
   - Heures de connexion: 9h-17h, jours ouvrés
2. Ajouter un préfixe "EXT-" dans la description

### Exercice 8: Vérification des Comptes Inactifs
En tant qu'administrateur, vous devez faire le ménage dans les comptes.

Tâches:
1. Identifier les comptes qui n'ont pas été utilisés depuis 30 jours
2. Pour chaque compte inactif:
   - Vérifier s'il s'agit d'un départ non signalé
   - Documenter le statut dans la description
   - Préparer une liste pour la direction

### Exercice 9: Mise à Jour des Informations
Suite à un déménagement interne:

Tâches:
1. Mettre à jour les informations de bureau **pour tous les utilisateurs** du service Comptabilité:
   - Nouveau bureau: "Bâtiment B - 3e étage"
   - Nouveau téléphone: format "+32 2 123 XX YY"
2. Vérifier que les chemins réseau sont toujours valides
3. Documenter les changements effectués

### Exercice 10: Résolution des Problèmes de Connexion
L'utilisatrice Sarah El Amrani signale qu'elle ne peut plus se connecter.

Tâches:
1. Vérifier l'état du compte (verrouillé, désactivé, expiré?)
2. Examiner les restrictions de connexion:
   - Postes de travail autorisés
   - Plages horaires
   - Stratégie de mot de passe
3. Résoudre le problème en documentant chaque étape

### Exercice 11: Gestion des Profils Itinérants
Vous devez configurer des profils itinérants pour l'équipe de vente qui se déplace entre plusieurs postes.

Tâches:
1. Créer un partage réseau pour les profils itinérants sur le serveur
2. Configurer le profil itinérant pour trois commerciaux:
   - Pierre Dubois
   - Marie Lambert
   - Ahmed Benali
3. Vérifier que leurs paramètres personnels sont conservés entre les postes
4. Configurer une limite de taille pour les profils (500 MB)

### Exercice 12: Délégation d'Administration
Vous devez permettre à Claire Martin, responsable RH, de gérer les comptes de son service.

Tâches:
1. Créer un groupe "GG-EU-RH-AdminDelegue"
2. Ajouter Claire au groupe
3. Configurer les droits délégués:
   - Création/modification de comptes dans l'OU RH
   - Réinitialisation des mots de passe
   - Modification des informations de profil
4. Tester les permissions avec le compte de Claire

### Exercice 13: Migration d'Utilisateurs
Suite à une restructuration, l'équipe Support (5 personnes) passe du service IT au service Ventes.

Tâches:
1. Identifier les utilisateurs à déplacer
2. Planifier la migration:
   - Nouveaux groupes nécessaires
   - Modifications des droits d'accès
3. Exécuter le déplacement des comptes vers la nouvelle OU
4. Mettre à jour toutes les appartenances aux groupes
5. Vérifier que les accès fonctionnent correctement

### Exercice 14: Gestion des Comptes de Service
Créer et sécuriser des comptes de service pour les applications internes.

Tâches:
1. Créer trois comptes de service:
   - svc-backup (pour les sauvegardes)
   - svc-monitoring (pour la surveillance)
   - svc-print (pour le serveur d'impression)
2. Configurer les paramètres de sécurité:
   - Mots de passe complexes
   - Pas d'expiration de mot de passe
   - Connexion limitée aux serveurs spécifiques
3. Documenter les comptes dans un registre


