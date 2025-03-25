# SUBJECTS

## Managing Users in Active Directory
### **Lesson 1.1: Understanding User Accounts**
- Types of user accounts (local vs. domain users)
- User attributes and profile settings
- Understanding User Principal Name (UPN) and SAMAccountName

### **Lesson 2.2: Creating and Managing Users**
- Creating users via GUI (Active Directory Users and Computers - ADUC)
- Creating users with PowerShell (`New-ADUser`)

### **Lesson 2.3: User Authentication & Security**
- Password policies and account lockout settings
- Multi-Factor Authentication (MFA) integration overview
- Managing user permissions and rights


# EXERCICES:

## Série 1: Création et Configuration de Base des Utilisateurs

### Exercice 1.1: Création d'un Nouvel Employé
Le service Comptabilité accueille une nouvelle comptable junior, Sophie Dubois. 

Tâches:
1. Créer un compte utilisateur pour Sophie en suivant la convention de nommage établie
2. Définir un mot de passe temporaire qui respecte la politique de sécurité
3. Configurer le compte pour que Sophie doive changer son mot de passe à la première connexion
4. Remplir les informations de base:
   - Description: "Comptable Junior - Service Comptabilité"
   - Bureau: "Bâtiment A - 1er étage"
   - Téléphone: "+32 2 123 45 68"

### Exercice 1.2: Restrictions d'Accès
Pour des raisons de sécurité, Sophie ne doit pouvoir se connecter que:
- Sur le poste `ws-compta-01.computerelectronics.be`
- Du lundi au vendredi, de 8h à 18h

Tâches:
1. Configurer les restrictions de connexion pour les postes de travail
2. Définir les plages horaires autorisées

## Série 2: Gestion des Profils et Sécurité

### Exercice 2.1: Configuration du Profil Utilisateur
Pour Sophie, vous devez configurer son profil utilisateur pour qu'il soit stocké sur le serveur.

Tâches:
1. Configurer le chemin du profil itinérant: `\\dns1\profiles\%username%`
2. Définir un script de connexion: `\\dns1\scripts\compta\logon.bat`
3. Vérifier que le dossier personnel est mappé au lecteur H:

### Exercice 2.2: Audit de Sécurité
Vous devez vérifier les paramètres de sécurité du compte de Sophie.

Tâches:
1. Vérifier que le compte n'est pas exempté de la politique de mot de passe
2. Confirmer que le compte expire dans 6 mois (durée du contrat d'essai)
3. Activer la journalisation des tentatives de connexion échouées

## Série 3: Gestion de Fin de Cycle

### Exercice 3.1: Désactivation d'un Compte
Jan Vandenbergh (jan.vandenbergh@computerelectronics.be) quitte l'entreprise aujourd'hui.

Tâches:
1. Désactiver son compte utilisateur
2. Documenter la désactivation dans la description du compte avec:
   - Date de désactivation
   - Raison: "Départ de l'entreprise"
   - Date de suppression prévue (dans 90 jours)
3. Vérifier qu'il ne peut plus se connecter

### Exercice 3.2: Nettoyage des Accès
Suite au départ de Jan Vandenbergh:

Tâches:
1. Identifier tous les groupes dont il est membre
2. Le retirer de tous les groupes sauf "Domain Users"
3. Préparer un rapport listant:
   - Les groupes dont il a été retiré
   - Les ressources auxquelles il avait accès
   - L'emplacement de ses fichiers personnels pour archivage

## Série 4: Gestion des Cas Spéciaux

### Exercice 4.1: Gestion des Homonymes
Deux nouveaux employés arrivent dans le service RH:
- Karim Benali (Recruteur Senior)
- Karim Benali (Assistant RH)

Tâches:
1. Créer les comptes pour les deux Karim Benali en évitant les conflits
2. Documenter clairement dans chaque compte le poste occupé
3. S'assurer que leurs adresses email restent professionnelles et cohérentes

### Exercice 4.2: Compte Temporaire
Un consultant externe, Marek Wojcik, arrive pour un audit de 3 mois.

Tâches:
1. Créer un compte temporaire avec:
   - Date d'expiration automatique dans 90 jours
   - Accès limité à `ws-compta-01` uniquement
   - Heures de connexion: 9h-17h, jours ouvrés
2. Ajouter un préfixe "EXT-" dans la description

## Série 5: Maintenance et Audit

### Exercice 5.1: Vérification des Comptes Inactifs
En tant qu'administrateur, vous devez faire le ménage dans les comptes.

Tâches:
1. Identifier les comptes qui n'ont pas été utilisés depuis 30 jours
2. Pour chaque compte inactif:
   - Vérifier s'il s'agit d'un départ non signalé
   - Documenter le statut dans la description
   - Préparer une liste pour la direction

### Exercice 5.2: Mise à Jour des Informations
Suite à un déménagement interne:

Tâches:
1. Mettre à jour les informations de bureau pour tous les utilisateurs du service Comptabilité:
   - Nouveau bureau: "Bâtiment B - 3e étage"
   - Nouveau téléphone: format "+32 2 123 XX YY"
2. Vérifier que les chemins réseau sont toujours valides
3. Documenter les changements effectués

## Série 6: Gestion des Erreurs

### Exercice 6.1: Résolution des Problèmes de Connexion
L'utilisatrice Sarah El Amrani signale qu'elle ne peut plus se connecter.

Tâches:
1. Vérifier l'état du compte (verrouillé, désactivé, expiré?)
2. Examiner les restrictions de connexion:
   - Postes de travail autorisés
   - Plages horaires
   - Stratégie de mot de passe
3. Résoudre le problème en documentant chaque étape

### Exercice 6.2: Récupération de Profil
Le profil de l'utilisateur Piotr Kowalski est corrompu.

Tâches:
1. Sauvegarder les données importantes du profil actuel
2. Réinitialiser le profil utilisateur:
   - Créer un nouveau chemin de profil
   - Migrer les données essentielles
3. Vérifier que les paramètres de base sont corrects
