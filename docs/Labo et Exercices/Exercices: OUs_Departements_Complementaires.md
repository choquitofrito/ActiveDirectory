# Exercices: Unités d'Organisation et Utilisateurs - Départements Complémentaires

!!! info "🎯 Contexte"

    Suite à l'expansion de l'entreprise **maxtec.be**, deux nouveaux départements sont créés : **Marketing** et **Logistique**. Vous êtes chargé(e) d'étendre la structure Active Directory existante (Ventes, RH, Comptabilite, IT) pour intégrer ces nouvelles équipes.

    **Prérequis** : Le script `creation_structure.ps1` du labo a été exécuté. Vous disposez donc déjà des départements Ventes, RH, Comptabilite et IT sous `OU=EU,DC=maxtec,DC=be`, avec leurs utilisateurs et groupes (`GG-EU-<Dept>-Users` / `GG-EU-<Dept>-Admin`).

---

## 1. 🔹 Création de la Structure des Nouveaux Départements

!!! example "Tâches à réaliser"

    1. Sous `OU=EU,DC=maxtec,DC=be`, créer les deux nouvelles OUs départementales :
        - `OU=Marketing`
        - `OU=Logistique`

    2. Sous chaque nouvelle OU départementale, créer les sous-OUs (mêmes noms que dans le reste du labo) :
        - `OU=Users`
        - `OU=Computers`
        - `OU=Groups`

    3. Vérifier que la nouvelle structure respecte la convention existante (par exemple : `OU=Users,OU=Marketing,OU=EU,DC=maxtec,DC=be`).

---

## 2. 🔹 Création d'Utilisateurs pour les Nouveaux Départements

!!! example "Tâches à réaliser"

    1. Créer les utilisateurs suivants dans `OU=Users,OU=Marketing,OU=EU,DC=maxtec,DC=be` :
        - **marc** (Directeur Marketing)
        - **marie** (Chargée de Communication)
        - **michel** (Designer Graphique)

    2. Créer les utilisateurs suivants dans `OU=Users,OU=Logistique,OU=EU,DC=maxtec,DC=be` :
        - **lucas** (Responsable Logistique)
        - **lea** (Gestionnaire de Stock)

    3. Pour chaque utilisateur :
        - Mot de passe standard : `Azerty_1`
        - Activer "L'utilisateur doit changer son mot de passe à la prochaine ouverture de session"
        - Remplir les champs : Prénom, Nom, Titre, Département, E-mail (`prenom@maxtec.be`)

---

## 3. 🔹 Création de Groupes Globaux pour les Nouveaux Départements

!!! example "Tâches à réaliser"

    1. Créer les groupes globaux de sécurité suivants dans l'OU `Groups` du département correspondant (convention identique au labo : `GG-EU-<Dept>-<Rôle>`) :

        | Groupe | OU de destination |
        |---|---|
        | `GG-EU-Marketing-Users` | `OU=Groups,OU=Marketing,OU=EU,...` |
        | `GG-EU-Marketing-Admin` | `OU=Groups,OU=Marketing,OU=EU,...` |
        | `GG-EU-Logistique-Users` | `OU=Groups,OU=Logistique,OU=EU,...` |
        | `GG-EU-Logistique-Admin` | `OU=Groups,OU=Logistique,OU=EU,...` |

    2. Ajouter les utilisateurs appropriés à chaque groupe :
        - **marie** et **michel** dans `GG-EU-Marketing-Users`
        - **marc** dans `GG-EU-Marketing-Admin`
        - **lea** dans `GG-EU-Logistique-Users`
        - **lucas** dans `GG-EU-Logistique-Admin`

---

## 4. 🔹 Gestion des Comptes Utilisateurs Spéciaux

!!! example "Tâches à réaliser"

    1. **Compte d'administration** : ajouter **marc** au groupe `Administrateurs du domaine` (Domain Admins). Discutez ensuite : est-ce une bonne pratique pour un Directeur Marketing ? Pourquoi un groupe `GG-EU-Marketing-Admin` est plus approprié ?

    2. **Contrat à durée déterminée** : définir une date d'expiration dans **6 mois** pour le compte de **michel**.

    3. **Restrictions horaires** : configurer pour **lea** un accès uniquement du **lundi au vendredi, de 7h à 19h**.

    4. **Restriction de poste de travail** : configurer pour **michel** la connexion **uniquement sur `ws-Marketing-01`** (vous n'avez pas besoin que la machine existe pour cet exercice — il s'agit de configurer la restriction côté AD).

---

## 5. 🔹 Création d'une Structure de Projet Transverse

!!! example "Contexte"

    L'entreprise lance le projet **« NouveauSite »** : refonte du site web public. Le projet nécessite la collaboration entre Marketing, IT et Ventes.

!!! example "Tâches à réaliser"

    1. Créer une OU **`Projets`** sous `OU=EU,DC=maxtec,DC=be`.
    2. Créer une sous-OU **`ProjetNouveauSite`** sous `OU=Projets,OU=EU,...`.
    3. Créer une sous-OU `Groups` dans `ProjetNouveauSite`.
    4. Créer un groupe global `GG-EU-ProjetSite-Membres` dans `OU=Groups,OU=ProjetNouveauSite,OU=Projets,OU=EU,...`.
    5. Ajouter les membres suivants au groupe (mix de nouveaux et d'utilisateurs déjà présents dans le labo) :
        - **marie** (Marketing — créée à l'étape 2)
        - **michel** (Marketing — créé à l'étape 2)
        - **ines** (IT — existante dans le labo)
        - **victor** (Ventes — existant dans le labo)

---

## 6. 🔹 Recherche et Filtrage d'Objets AD

!!! example "Tâches à réaliser"

    1. Lister tous les utilisateurs du département **Marketing**.
    2. Lister tous les groupes dont **ines** est membre.
    3. Trouver tous les utilisateurs dont le **titre** contient « Responsable » ou « Directeur/Directrice ».
    4. Construire une requête LDAP qui retourne tous les utilisateurs créés **aujourd'hui**.

??? success "Solution"

    ### 1. Utilisateurs du département Marketing

    **Via Centre d'administration Active Directory** :

    - Naviguer jusqu'à `maxtec (local) > EU > Marketing > Users`
    - Tous les utilisateurs Marketing y sont listés (marc, marie, michel)

    Ou via **Utilisateurs et ordinateurs Active Directory** :

    - Naviguer jusqu'à l'OU `Marketing > Users`
    - `Affichage > Filtrer > Utilisateurs` pour n'afficher que les utilisateurs

    ### 2. Groupes dont `ines` est membre

    - Ouvrir **Utilisateurs et ordinateurs Active Directory**
    - Localiser **ines** dans `EU > IT > Users`
    - Clic droit → **Propriétés** → onglet **Membre de**
    - Tous les groupes dont l'utilisateur est membre seront affichés (au minimum `Domain Users` et `GG-EU-IT-Users`)

    ### 3. Utilisateurs avec « Responsable » ou « Directeur/Directrice » dans le titre

    - Ouvrir le **Centre d'administration Active Directory**
    - Cliquer sur **Recherche globale**
    - Sélectionner **Utilisateur** comme type d'objet
    - **Ajouter un critère** → **Titre** → opérateur **Contient** → valeur `Responsable`
    - **Ajouter un critère** → **Titre** → opérateur **Contient** → valeur `Directeur`
    - **Ajouter un critère** → **Titre** → opérateur **Contient** → valeur `Directrice`
    - Choisir **Correspond à n'importe quel critère**
    - Cliquer sur **Rechercher**

    ### 4. Requête LDAP : utilisateurs créés aujourd'hui

    - Ouvrir **Utilisateurs et ordinateurs Active Directory**
    - `Affichage > Fonctionnalités avancées`
    - `Affichage > Recherche avancée` (ou clic droit sur le domaine → Rechercher)
    - Champ **Requête LDAP** :

        ```
        (&(objectCategory=person)(objectClass=user)(whenCreated>=AAAAMMJJ000000.0Z))
        ```

        Exemple pour le 18 mai 2026 :

        ```
        (&(objectCategory=person)(objectClass=user)(whenCreated>=20260518000000.0Z))
        ```

---

## 7. 🔹 Délégation de Contrôle pour les Nouveaux Départements

!!! example "Contexte"

    Vous voulez permettre aux responsables des nouveaux départements de gérer leurs propres utilisateurs sans les ajouter à `Domain Admins`.

!!! example "Tâches à réaliser"

    1. Déléguer à **marc** (Marketing) les droits suivants sur `OU=Marketing,OU=EU,DC=maxtec,DC=be` :
        - Créer, supprimer et gérer les comptes utilisateurs
        - Réinitialiser les mots de passe

    2. Déléguer à **lucas** (Logistique) les mêmes droits sur `OU=Logistique,OU=EU,DC=maxtec,DC=be`.

    3. **Test** : Connectez-vous (RDP ou changement d'utilisateur) avec le compte **marc** et vérifiez qu'il peut bien créer un utilisateur de test dans `OU=Users,OU=Marketing,...`, mais **pas** dans `OU=Users,OU=Logistique,...`.

    !!! tip "Rappel labo"

        Les utilisateurs **irene** (IT) et **valentin** (Ventes) existent déjà avec leurs groupes `GG-EU-IT-Admin` / `GG-EU-Ventes-Admin` créés par le script du labo. Une fois la délégation comprise, vous pouvez répéter l'opération en accordant les droits à ces groupes (et non aux utilisateurs individuellement) — c'est la pratique recommandée.

---

## 8. 🔹 Comité de Direction (Exercice Optionnel)

!!! example "Contexte"

    Création d'un comité regroupant les responsables de chaque département.

!!! example "Tâches à réaliser"

    1. Créer un groupe global `GG-EU-Comite-Direction` dans une OU `Groups` au niveau de `OU=EU` (créer l'OU si elle n'existe pas).
    2. Ajouter les responsables suivants au groupe :
        - **marc** (Marketing — créé à l'étape 2)
        - **lucas** (Logistique — créé à l'étape 2)
        - **valentin** (Ventes — existant dans le labo)
        - **richard** (RH — existant dans le labo)
        - **charlotte** (Comptabilité — existante dans le labo)
        - **irene** (IT — existante dans le labo)

    3. Discussion : quel **scope de groupe** (Global, DomainLocal, Universal) serait le plus approprié si demain une zone géographique `US` était ajoutée ? Pourquoi ?

---

## 9. 🔹 Vers une Structure Multi-Zones (Exercice Optionnel — Théorique)

!!! warning "Note"

    Cet exercice est **théorique** : le labo ne contient qu'une zone `EU`. L'objectif est de comprendre comment la structure évoluerait, pas de la créer réellement.

!!! example "Tâches à réaliser"

    Si l'entreprise ouvrait une filiale aux États-Unis :

    1. Quelle serait la **nouvelle racine** dans AD ? (réponse attendue : `OU=US,DC=maxtec,DC=be`)
    2. Quels groupes devraient être créés en miroir ? Donnez 2 exemples concrets pour Marketing.
    3. Pour fédérer les utilisateurs Marketing des deux zones dans une seule ressource (par exemple un partage de fichiers commun), quel **type/scope de groupe** utiliseriez-vous, et quel serait son nom selon la convention `<Scope>-<Périmètre>-<Rôle>` ?

??? success "Pistes de réponse"

    1. `OU=US,DC=maxtec,DC=be`, avec la même structure interne (`Marketing/Users`, `Marketing/Computers`, `Marketing/Groups`, etc.)
    2. `GG-US-Marketing-Users`, `GG-US-Marketing-Admin`
    3. Un **groupe Universel** (Universal), par exemple `U-Global-Marketing-Users`, qui contiendrait à la fois `GG-EU-Marketing-Users` et `GG-US-Marketing-Users`. C'est l'application classique du modèle **AGUDLP** (Account → Global → Universal → DomainLocal → Permission).
