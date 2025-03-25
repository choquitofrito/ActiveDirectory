# Solutions Chapitre 4: Gestion des Utilisateurs

## Série 1: Création et Configuration de Base des Utilisateurs

### Solution 1.1: Création d'un Nouvel Employé

1. Créer le compte utilisateur pour Sophie:
   ```
   1. Ouvrir "Active Directory Users and Computers"
   2. Naviguer vers l'OU "Comptabilité"
   3. Clic droit > Nouveau > Utilisateur
   4. Remplir les champs:
      - Prénom: Sophie
      - Nom: Dubois
      - Nom d'ouverture de session: sophie.dubois
      - UPN: sophie.dubois@computerelectronics.be
   5. Cliquer sur "Suivant"
   ```

2. Définir le mot de passe:
   ```
   1. Saisir un mot de passe temporaire respectant la politique
   2. Cocher "L'utilisateur doit changer son mot de passe à la prochaine ouverture de session"
   3. Décocher "Le compte est désactivé"
   4. Cliquer sur "Suivant" puis "Terminer"
   ```

3. Configurer les informations:
   ```
   1. Double-cliquer sur le compte créé
   2. Onglet "Général":
      - Description: "Comptable Junior - Service Comptabilité"
      - Bureau: "Bâtiment A - 1er étage"
      - Téléphone: "+32 2 123 45 68"
   3. Cliquer sur "Appliquer"
   ```

### Solution 1.2: Restrictions d'Accès

1. Configurer les restrictions de poste:
   ```
   1. Propriétés du compte > Onglet "Compte"
   2. Section "Options de connexion"
   3. Cliquer sur "Se connecter à..."
   4. Sélectionner "Les postes suivants"
   5. Ajouter: ws-compta-01.computerelectronics.be
   6. Cliquer sur "OK"
   ```

2. Définir les plages horaires:
   ```
   1. Toujours dans l'onglet "Compte"
   2. Cliquer sur "Heures de connexion..."
   3. Sélectionner la plage 8h-18h pour Lundi-Vendredi
   4. Laisser "Connexion interdite" pour Samedi-Dimanche
   5. Cliquer sur "OK"
   ```

## Série 2: Gestion des Profils et Sécurité

### Solution 2.1: Configuration du Profil Utilisateur

1. Configurer le profil itinérant:
   ```
   1. Propriétés du compte > Onglet "Profil"
   2. Chemin d'accès au profil: \\dns1\profiles\%username%
   3. Script d'ouverture de session: \\dns1\scripts\compta\logon.bat
   4. Cliquer sur "Appliquer"
   ```

2. Vérifier le dossier personnel:
   ```
   1. Même onglet "Profil"
   2. Section "Dossier personnel"
   3. Sélectionner "Connecter"
   4. Lettre de lecteur: H:
   5. À: \\dns1\users\%username%
   6. Cliquer sur "OK"
   ```

### Solution 2.2: Audit de Sécurité

1. Vérifier les paramètres de mot de passe:
   ```
   1. Propriétés du compte > Onglet "Compte"
   2. Vérifier que "Le mot de passe n'expire jamais" n'est PAS coché
   3. Vérifier que "L'utilisateur ne peut pas changer le mot de passe" n'est PAS coché
   ```

2. Configurer l'expiration:
   ```
   1. Dans le même onglet
   2. "Le compte expire le:" > Sélectionner date dans 6 mois
   3. Cliquer sur "Appliquer"
   ```

3. Activer la journalisation:
   ```
   1. Ouvrir "Stratégie de sécurité locale"
   2. Paramètres de sécurité > Stratégies locales > Audit
   3. Double-cliquer "Auditer les événements de connexion"
   4. Cocher "Succès" et "Échec"
   5. Cliquer sur "OK"
   ```

## Série 3: Gestion de Fin de Cycle

### Solution 3.1: Désactivation d'un Compte

1. Désactiver le compte:
   ```
   1. Localiser le compte de Jan Vandenbergh
   2. Propriétés > Onglet "Compte"
   3. Cocher "Désactiver le compte"
   4. Cliquer sur "Appliquer"
   ```

2. Documenter:
   ```
   1. Onglet "Général"
   2. Dans "Description", ajouter:
      [Désactivé le 25/03/2025]
      Raison: Départ de l'entreprise
      À supprimer le: 23/06/2025
   3. Cliquer sur "OK"
   ```

3. Vérifier:
   ```
   1. Tenter une connexion avec le compte
   2. Vérifier que le message "Compte désactivé" apparaît
   ```

### Solution 3.2: Nettoyage des Accès

1. Identifier les groupes:
   ```
   1. Propriétés du compte > Onglet "Membre de"
   2. Noter tous les groupes listés
   3. Exporter la liste (copier-coller dans un document)
   ```

2. Retirer des groupes:
   ```
   1. Sélectionner tous les groupes sauf "Domain Users"
   2. Cliquer sur "Supprimer"
   3. Cliquer sur "Appliquer"
   ```

3. Préparer le rapport:
   ```
   1. Créer un document Word avec sections:
      - Liste des groupes retirés (de l'étape 1)
      - Ressources: examiner les partages et permissions
      - Localisation des fichiers: \\dns1\users\jan.vandenbergh
   2. Sauvegarder dans le dossier Documentation
   ```

## Série 4: Gestion des Cas Spéciaux

### Solution 4.1: Gestion des Homonymes

1. Créer les comptes:
   ```
   1. Pour le premier Karim:
      - Login: karim.benali
      - Description: "Recruteur Senior - Service RH"
   
   2. Pour le second Karim:
      - Login: karim.benali2
      - Description: "Assistant RH - Service RH"
   ```

2. Documentation:
   ```
   1. Dans chaque compte, onglet "Général":
      - Ajouter le titre exact du poste
      - Ajouter une note sur l'homonyme
   2. Cliquer sur "OK" pour chaque compte
   ```

### Solution 4.2: Compte Temporaire

1. Créer le compte temporaire:
   ```
   1. Créer l'utilisateur:
      - Login: marek.wojcik
      - Description: "EXT-Consultant Audit"
   
   2. Onglet "Compte":
      - Définir expiration dans 90 jours
      - Restreindre à ws-compta-01
      - Configurer horaires 9h-17h
   ```

## Série 5: Maintenance et Audit

### Solution 5.1: Vérification des Comptes Inactifs

1. Identifier les comptes:
   ```
   1. Dans ADUC > Créer un filtre personnalisé:
      - Champ: "Dernière connexion"
      - Condition: "Est antérieure à 30 jours"
   2. Exécuter le filtre
   ```

2. Vérifier et documenter:
   ```
   1. Pour chaque compte listé:
      - Contacter le responsable du service
      - Ajouter dans Description:
        [INACTIF depuis le XX/XX/XXXX]
        Status: En attente de vérification
   ```

### Solution 5.2: Mise à Jour des Informations

1. Mettre à jour les bureaux:
   ```
   1. Dans ADUC > Créer un filtre:
      - OU=Comptabilité
   2. Pour chaque utilisateur:
      - Propriétés > Onglet "Général"
      - Mettre à jour Bureau et Téléphone
   ```

2. Vérifier les chemins réseau:
   ```
   1. Pour chaque compte:
      - Onglet "Profil"
      - Vérifier les chemins UNC
      - Tester l'accès aux partages
   ```

## Série 6: Gestion des Erreurs

### Solution 6.1: Résolution des Problèmes de Connexion

1. Vérifier l'état:
   ```
   1. Localiser le compte de Sarah El Amrani
   2. Propriétés > Onglet "Compte":
      - Vérifier si désactivé
      - Vérifier date d'expiration
      - Vérifier verrouillage
   ```

2. Examiner les restrictions:
   ```
   1. Même onglet:
      - Vérifier "Se connecter à..."
      - Vérifier "Heures de connexion"
   2. Onglet "Membre de":
      - Vérifier les appartenances aux groupes
   ```

### Solution 6.2: Récupération de Profil

1. Sauvegarde:
   ```
   1. Localiser le profil:
      \\dns1\profiles\piotr.kowalski
   2. Copier vers:
      \\dns1\backups\profiles\piotr.kowalski_OLD
   ```

2. Réinitialisation:
   ```
   1. Propriétés du compte > Onglet "Profil"
   2. Effacer le chemin du profil
   3. Créer nouveau chemin:
      \\dns1\profiles\piotr.kowalski_NEW
   4. Migrer les données essentielles
   ```
