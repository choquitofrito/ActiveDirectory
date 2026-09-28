# Exercices: Unités d'Organisation et Utilisateurs - Départements Complémentaires

!!! info "🎯 Contexte"

    Suite à l'expansion de l'entreprise **maxtec.be**, deux nouveaux départements sont créés : **Marketing** et **Achats**. Vous êtes chargé(e) d'étendre la structure Active Directory existante (Ventes, RH, Comptabilite, IT) pour intégrer ces nouvelles équipes.

    **Prérequis** : Le script `creation_structure.ps1` du labo a été exécuté. Vous disposez donc déjà des départements Ventes, RH, Comptabilite et IT sous `OU=EU,DC=maxtec,DC=be`, avec leurs utilisateurs et groupes (`GG-EU-<Dept>-Users` / `GG-EU-<Dept>-Admin`).

---

## 1. Création de la Structure des Nouveaux Départements

!!! example "Tâches à réaliser"

    1. Sous `OU=EU,DC=maxtec,DC=be`, créer les deux nouvelles OUs départementales :
        - `OU=Marketing`
        - `OU=Achats`

    2. Sous chaque nouvelle OU départementale, créer les sous-OUs (mêmes noms que dans le reste du labo) :
        - `OU=Users`
        - `OU=Computers`
        - `OU=Groups`

    3. Vérifier que la nouvelle structure respecte la convention existante (par exemple : `OU=Users,OU=Marketing,OU=EU,DC=maxtec,DC=be`).

    Dans le lab, décochez **Protéger le conteneur contre une suppression accidentelle** (sinon le script de suppression échouera sur ces OUs).

??? success "Solution"

    1. `dsa.msc` > clic droit sur `EU` > **Nouveau > Unité d'organisation** > Nom `Marketing`, **décochez** **Protéger le conteneur contre une suppression accidentelle** > **OK**
    2. Clic droit sur `Marketing` > **Nouveau > Unité d'organisation** : `Users`, puis `Computers`, puis `Groups` (protection décochée à chaque fois)
    3. Idem pour `Achats`
    4. Vérification : l'arborescence `EU > Marketing > Users` apparaît. Avec **Affichage > Fonctionnalités avancées**, propriétés de l'OU > onglet **Éditeur d'attributs** > `distinguishedName` montre `OU=Users,OU=Marketing,OU=EU,DC=maxtec,DC=be`.

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    foreach ($d in "Marketing", "Achats") {
        New-ADOrganizationalUnit -Name $d -Path "OU=EU,DC=maxtec,DC=be" -ProtectedFromAccidentalDeletion $false
        foreach ($s in "Users", "Computers", "Groups") {
            New-ADOrganizationalUnit -Name $s -Path "OU=$d,OU=EU,DC=maxtec,DC=be" -ProtectedFromAccidentalDeletion $false
        }
    }
    ```

---

## 2. Création d'Utilisateurs pour les Nouveaux Départements

!!! example "Tâches à réaliser"

    1. Créer les utilisateurs suivants dans `OU=Users,OU=Marketing,OU=EU,DC=maxtec,DC=be` :
        - **marc** (Directeur Marketing)
        - **marie** (Chargée de Communication)
        - **michel** (Designer Graphique)

    2. Créer les utilisateurs suivants dans `OU=Users,OU=Achats,OU=EU,DC=maxtec,DC=be` :
        - **adrien** (Responsable Achats)
        - **agathe** (Acheteuse)

    3. Pour chaque utilisateur :
        - Mot de passe standard : `Password1!`
        - Activer "L'utilisateur doit changer son mot de passe à la prochaine ouverture de session"
        - Remplir les champs : Prénom, Nom (à vous de choisir), Titre, Service (`Department` = nom de l'OU : `Marketing` ou `Achats`), E-mail (`prenom@maxtec.be`)

??? success "Solution"

    1. `dsa.msc` > `EU > Marketing` > clic droit sur `Users` > **Nouveau > Utilisateur**
    2. Prénom, Nom, **Nom complet** : le prénom seul (`Marc`, voir ci-dessous) ; nom d'ouverture de session `marc` > **Suivant**
    3. Mot de passe `Password1!` (deux fois), cochez **L'utilisateur doit changer le mot de passe à la prochaine ouverture de session** > **Suivant** > **Terminer**
    4. Propriétés du compte : onglet **Général** (**Nom complet** `Marc Mertens`, **Adresse de messagerie** `marc@maxtec.be`), onglet **Organisation** (**Fonction** `Directeur Marketing`, **Service** `Marketing`)
    5. Recommencez pour marie, michel, puis adrien et agathe dans `EU > Achats > Users`. Astuce : clic droit sur un compte terminé > **Copier…** reprend le service et les groupes ; il reste à changer nom, login et fonction.

    Exemple de noms : Marc Mertens, Marie Maes, Michel Michiels, Adrien Aerts, Agathe Albert. Comme dans le reste du lab, le nom de l'objet (`Name`, donc le `CN`) est le prénom ; le nom complet va dans `DisplayName`.

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    $mdp = ConvertTo-SecureString "Password1!" -AsPlainText -Force   # mot de passe de LAB
    New-ADUser -Name Marc -DisplayName "Marc Mertens" -GivenName Marc -Surname Mertens -SamAccountName marc -UserPrincipalName marc@maxtec.be `
        -EmailAddress marc@maxtec.be -Title "Directeur Marketing" -Department Marketing `
        -Path "OU=Users,OU=Marketing,OU=EU,DC=maxtec,DC=be" -AccountPassword $mdp -ChangePasswordAtLogon $true -Enabled $true
    # Meme commande pour marie, michel (Marketing), adrien, agathe (Achats)
    ```

---

## 3. Création de Groupes Globaux pour les Nouveaux Départements

!!! example "Tâches à réaliser"

    1. Créer les groupes globaux de sécurité suivants dans l'OU `Groups` du département correspondant (convention identique au labo : `GG-EU-<Dept>-<Rôle>`) :

        | Groupe | OU de destination |
        |---|---|
        | `GG-EU-Marketing-Users` | `OU=Groups,OU=Marketing,OU=EU,...` |
        | `GG-EU-Marketing-Admin` | `OU=Groups,OU=Marketing,OU=EU,...` |
        | `GG-EU-Achats-Users` | `OU=Groups,OU=Achats,OU=EU,...` |
        | `GG-EU-Achats-Admin` | `OU=Groups,OU=Achats,OU=EU,...` |

    2. Ajouter les utilisateurs appropriés à chaque groupe :
        - **marie** et **michel** dans `GG-EU-Marketing-Users`
        - **marc** dans `GG-EU-Marketing-Admin`
        - **agathe** dans `GG-EU-Achats-Users`
        - **adrien** dans `GG-EU-Achats-Admin`

??? success "Solution"

    1. `dsa.msc` > `EU > Marketing` > clic droit sur `Groups` > **Nouveau > Groupe** > Nom `GG-EU-Marketing-Users`, **Étendue du groupe** : **Globale**, **Type de groupe** : **Sécurité** > **OK**. Idem pour `GG-EU-Marketing-Admin`, puis les deux groupes Achats dans `EU > Achats > Groups`.
    2. Double-clic sur le groupe > onglet **Membres** > **Ajouter…** > tapez `marie; michel` > **Vérifier les noms** > **OK** > **OK**
    3. Idem pour les autres groupes. Contrôle : propriétés de `marie` > onglet **Membre de**.

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    foreach ($d in "Marketing", "Achats") {
        foreach ($r in "Users", "Admin") {
            New-ADGroup -Name "GG-EU-$d-$r" -GroupScope Global -GroupCategory Security -Path "OU=Groups,OU=$d,OU=EU,DC=maxtec,DC=be"
        }
    }
    Add-ADGroupMember GG-EU-Marketing-Users -Members marie, michel
    Add-ADGroupMember GG-EU-Marketing-Admin -Members marc
    Add-ADGroupMember GG-EU-Achats-Users -Members agathe
    Add-ADGroupMember GG-EU-Achats-Admin -Members adrien
    ```

---

## 4. Gestion des Comptes Utilisateurs Spéciaux

!!! example "Tâches à réaliser"

    1. **Compte d'administration** : ajouter **marc** au groupe `Admins du domaine` (Domain Admins). Discutez ensuite : est-ce une bonne pratique pour un Directeur Marketing ? Pourquoi un groupe `GG-EU-Marketing-Admin` avec une délégation (étape 7) est plus approprié ? **Retirez-le ensuite du groupe** : sinon le test de délégation de l'étape 7 ne prouve rien (un Admin du domaine peut tout faire partout).

    2. **Contrat à durée déterminée** : définir une date d'expiration dans **6 mois** pour le compte de **michel**.

    3. **Restrictions horaires** : configurer pour **agathe** un accès uniquement du **lundi au vendredi, de 7h à 19h**.

    4. **Restriction de poste de travail** : configurer pour **michel** la connexion **uniquement sur `ws-Marketing-01`**. Pré-créez l'objet ordinateur dans `OU=Computers,OU=Marketing` : la restriction s'accepte même sans objet, mais un objet pré-créé est plus propre (le vrai poste le réutilisera à la jonction). Conséquence à noter : tant que ce poste n'existe pas, michel ne peut se connecter nulle part.

??? success "Solution"

    Dans `dsa.msc` :

    - **4.1** : propriétés de `Marc` > onglet **Membre de** > **Ajouter…** > `Admins du domaine` > **OK**. Après la discussion : même onglet > sélectionnez `Admins du domaine` > **Supprimer**. (Ou, depuis le conteneur `Users` du domaine : propriétés du groupe `Admins du domaine` > **Membres**.)
    - **4.2** : propriétés de `Michel` > onglet **Compte** > **Le compte expire** > **Fin de :** aujourd'hui + 6 mois
    - **4.3** : propriétés de `Agathe` > onglet **Compte** > **Horaires d'accès…** : sélectionnez tout > **Ouverture de session refusée**, puis sélectionnez lundi-vendredi 7h-19h > **Ouverture de session autorisée** > **OK**
    - **4.4** : `EU > Marketing` > clic droit sur `Computers` > **Nouveau > Ordinateur** > `ws-Marketing-01` > **OK**. Puis propriétés de `Michel` > onglet **Compte** > **Se connecter à…** > **Les ordinateurs suivants** > `ws-Marketing-01` > **Ajouter** > **OK**

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    Add-ADGroupMember "Admins du domaine" -Members marc      # 4.1 (Domain Admins sur un serveur en anglais)
    Remove-ADGroupMember "Admins du domaine" -Members marc -Confirm:$false

    Set-ADAccountExpiration michel -DateTime (Get-Date).AddMonths(6)       # 4.2

    New-ADComputer -Name ws-Marketing-01 -Path "OU=Computers,OU=Marketing,OU=EU,DC=maxtec,DC=be"
    Set-ADUser michel -LogonWorkstations "ws-Marketing-01"                 # 4.4
    ```

    4.3 n'a pas d'équivalent PowerShell lisible (`logonHours` est un tableau d'octets) : on passe par la GUI.

    4.1, discussion : `Admins du domaine` donne le contrôle total du domaine (tous les comptes, tous les DC, toutes les GPO). Un directeur métier n'en a pas besoin, et son compte, utilisé tous les jours pour les mails et le web, serait une porte d'entrée pour un attaquant. On lui donne uniquement ce dont il a besoin, par délégation sur son OU.

---

## 5. Création d'une Structure de Projet Transverse

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

??? success "Solution"

    1. `dsa.msc` > clic droit sur `EU` > **Nouveau > Unité d'organisation** > `Projets` (protection décochée)
    2. Clic droit sur `Projets` > **Nouveau > Unité d'organisation** > `ProjetNouveauSite`, puis dans celle-ci `Groups` (protection décochée)
    3. Clic droit sur `Groups` > **Nouveau > Groupe** > `GG-EU-ProjetSite-Membres`, **Globale**, **Sécurité**
    4. Propriétés du groupe > **Membres** > **Ajouter…** > `marie; michel; ines; victor` > **Vérifier les noms** > **OK**

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    New-ADOrganizationalUnit -Name Projets -Path "OU=EU,DC=maxtec,DC=be" -ProtectedFromAccidentalDeletion $false
    New-ADOrganizationalUnit -Name ProjetNouveauSite -Path "OU=Projets,OU=EU,DC=maxtec,DC=be" -ProtectedFromAccidentalDeletion $false
    New-ADOrganizationalUnit -Name Groups -Path "OU=ProjetNouveauSite,OU=Projets,OU=EU,DC=maxtec,DC=be" -ProtectedFromAccidentalDeletion $false
    New-ADGroup -Name GG-EU-ProjetSite-Membres -GroupScope Global -GroupCategory Security `
        -Path "OU=Groups,OU=ProjetNouveauSite,OU=Projets,OU=EU,DC=maxtec,DC=be"
    Add-ADGroupMember GG-EU-ProjetSite-Membres -Members marie, michel, ines, victor
    ```

    Un groupe peut contenir des utilisateurs de n'importe quelle OU du domaine : ines et victor restent dans leur OU d'origine. L'OU `Projets` sert à ranger le groupe, pas les personnes.

---

## 6. Recherche et Filtrage d'Objets AD

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
    - **Affichage > Options de filtre…** > **Afficher uniquement les types d'objets suivants** > cochez **Utilisateurs** pour n'afficher que les utilisateurs

    ### 2. Groupes dont `ines` est membre

    - Ouvrir **Utilisateurs et ordinateurs Active Directory**
    - Localiser **ines** dans `EU > IT > Users`
    - Clic droit → **Propriétés** → onglet **Membre de**
    - Tous les groupes dont l'utilisateur est membre seront affichés (au minimum `Utilisateurs du domaine` et `GG-EU-IT-Users`, plus `GG-EU-ProjetSite-Membres` si vous avez fait l'étape 5)
    - En invite de commandes : `net user ines /domain` (ligne « Groupes globaux »)
    - En PowerShell (aperçu, vu au chapitre 9) : `Get-ADPrincipalGroupMembership ines | Select-Object Name`

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
    - Clic droit sur le domaine → **Rechercher…**
    - Liste **Rechercher** : **Recherche personnalisée** → onglet **Avancé**
    - Champ **Entrer une requête LDAP** :

        ```
        (&(objectCategory=person)(objectClass=user)(whenCreated>=AAAAMMJJ000000.0Z))
        ```

        Exemple pour le 18 mai 2026 :

        ```
        (&(objectCategory=person)(objectClass=user)(whenCreated>=20260518000000.0Z))
        ```

---

## 7. Délégation de Contrôle pour les Nouveaux Départements

!!! example "Contexte"

    Vous voulez permettre aux responsables des nouveaux départements de gérer leurs propres utilisateurs sans les ajouter à `Admins du domaine`.

!!! example "Tâches à réaliser"

    1. Déléguer à `GG-EU-Marketing-Admin` (qui contient **marc**) les droits suivants sur `OU=Marketing,OU=EU,DC=maxtec,DC=be` :
        - Créer, supprimer et gérer les comptes utilisateurs
        - Réinitialiser les mots de passe

    2. Déléguer à `GG-EU-Achats-Admin` (qui contient **adrien**) les mêmes droits sur `OU=Achats,OU=EU,DC=maxtec,DC=be`.

    3. **Test** : vérifiez que **marc** peut créer un utilisateur de test dans `OU=Users,OU=Marketing,...`, mais **pas** dans `OU=Users,OU=Achats,...`. Le test se fait **depuis `ws-IT-01` avec RSAT** ([installation : Gestion des utilisateurs, Ex. 12](./Exercices:%20Gestion_des_Utilisateurs.md#exercice-12-delegation-dadministration)) : marc n'a pas le droit d'ouvrir une session sur le DC, ni en local ni en RDP.

    !!! tip "Déléguer au groupe"

        On délègue au groupe `GG-EU-Marketing-Admin` et non à marc directement : si le directeur change, on modifie l'appartenance au groupe, pas les ACL de l'OU. Vérifiez aussi que marc n'est plus dans `Admins du domaine` (étape 4.1).

??? success "Solution"

    1. `dsa.msc` > clic droit sur `EU > Marketing` > **Délégation de contrôle…** > **Ajouter** `GG-EU-Marketing-Admin` > tâches **Créer, supprimer et gérer les comptes d'utilisateurs** et **Réinitialiser les mots de passe utilisateur et forcer le changement de mot de passe à la prochaine ouverture de session** > **Terminer**
    2. Idem sur `EU > Achats` avec `GG-EU-Achats-Admin`
    3. Sur `ws-IT-01` (RSAT installé), depuis une session existante :

        ```cmd
        runas /user:maxtec\marc "mmc dsa.msc"
        ```

        (ou `runas /netonly /user:maxtec\marc "mmc dsa.msc"` si marc ne peut pas ouvrir de session locale sur le poste). **Nouveau > Utilisateur** dans `Marketing > Users` fonctionne ; dans `Achats > Users`, l'option est absente ou la création échoue. Marc devra changer son mot de passe `Password1!` à la première connexion : faites-le avant (session sur le poste, ou `Ctrl+Alt+Suppr` > Modifier un mot de passe).

---

## 8. Comité de Direction (Exercice Optionnel)

!!! example "Contexte"

    Création d'un comité regroupant les responsables de chaque département.

!!! example "Tâches à réaliser"

    1. Créer un groupe global `GG-EU-Comite-Direction` dans une OU `Groups` au niveau de `OU=EU` (créer l'OU si elle n'existe pas).
    2. Ajouter les responsables suivants au groupe :
        - **marc** (Marketing — créé à l'étape 2)
        - **adrien** (Achats — créé à l'étape 2)
        - **valentin** (Ventes — existant dans le labo)
        - **richard** (RH — existant dans le labo)
        - **charlotte** (Comptabilité — existante dans le labo)
        - **irene** (IT — existante dans le labo)

    3. Discussion : quel **scope de groupe** (Global, DomainLocal, Universal) serait le plus approprié si demain une zone géographique `US` était ajoutée ? Pourquoi ?

??? success "Solution"

    1. `dsa.msc` > clic droit sur `EU` > **Nouveau > Unité d'organisation** > `Groups` (protection décochée), si elle n'existe pas
    2. Clic droit sur `EU > Groups` > **Nouveau > Groupe** > `GG-EU-Comite-Direction`, **Globale**, **Sécurité**
    3. Propriétés > **Membres** > **Ajouter…** > `marc; adrien; valentin; richard; charlotte; irene` > **Vérifier les noms** > **OK**

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    New-ADOrganizationalUnit -Name Groups -Path "OU=EU,DC=maxtec,DC=be" -ProtectedFromAccidentalDeletion $false
    New-ADGroup -Name GG-EU-Comite-Direction -GroupScope Global -GroupCategory Security -Path "OU=Groups,OU=EU,DC=maxtec,DC=be"
    Add-ADGroupMember GG-EU-Comite-Direction -Members marc, adrien, valentin, richard, charlotte, irene
    ```

    Discussion : tout dépend de la forme que prend la zone `US`.

    - **Une OU `US` dans le même domaine** `maxtec.be` : un groupe **global** suffit. Il peut contenir des utilisateurs de n'importe quelle OU du domaine. On le renommerait simplement sans `EU` (par exemple `GG-Comite-Direction`).
    - **Un domaine séparé** dans la même forêt (par exemple `us.maxtec.be`) : un groupe global ne peut contenir que des comptes de son domaine. On crée alors un groupe **universel** (`UG-Comite-Direction`) qui contient les groupes globaux des deux domaines.

---

## 9. Vers une Structure Multi-Zones (Exercice Optionnel — Théorique)

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
    3. `US` est ici une **OU dans le même domaine** : pas besoin de groupe universel. On applique AGDLP : un groupe **domaine local** `DL-Marketing-Partage-Modification` qui contient `GG-EU-Marketing-Users` et `GG-US-Marketing-Users`, et c'est lui qui reçoit la permission sur le partage.

        Le groupe **universel** (modèle **AGUDLP** : Account → Global → Universal → DomainLocal → Permission) ne devient utile que si `US` est un **domaine séparé** de la forêt (`us.maxtec.be`) : par exemple `UG-Marketing-Users`, qui contient les GG des deux domaines et qu'on place dans les DL des ressources.
