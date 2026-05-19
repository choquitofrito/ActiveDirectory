### Prérequis

!!! warning "Configuration requise"
    
    Avant de commencer, assurez-vous d'avoir la structure complète de l'AD.

!!! info "Éléments à préparer"
    
    - Créez la OU pour le département IT (si elle n'existe pas encore) 
    - Rajoutez quelques utilisateurs dans Users (ex: "ivan","ines","irene"). 
    - Créez aussi un groupe pour les administrateurs de IT (ex: "GG-EU-IT-Admin") et un autre pour les utilisateurs (ex: "GG-EU-IT-Users"). 
    - Assurez-vous d'avoir un ordinateur dans Computers (ws-IT-01)
    - Rajoutez des utilisateurs aux groupes: 
      - `GG-EU-IT-Users` : Ivan, Ines
      - `GG-EU-IT-Admin` : Irene
      - `GG-EU-Ventes-Users` : Victor, Vanessa, Valeria
      - `GG-EU-Ventes-Admins` : Valentin
      - `GG-EU-RH-Users` : Rene, Rebecca
      - `GG-EU-RH-Admins` : Richard
      - `GG-EU-Compta-Users` : Charles, Cindy
      - `GG-EU-Compta-Admins` : Charlotte




## 1. Modèles d'administration

### 1.1. GPO-Restriction-PanneauConfig. Bloquer l'accès au Panneau de Configuration dans Ventes

!!! example "Objectif"
    
    Bloquer l'accès au Panneau de Configuration aux utilisateurs de Ventes

!!! info "Configuration"
    
    **Setting**: Config Utilisateur > Modèles d'administration > Panneau de configuration > Interdire l'accès

### 1.2. GPO-Restriction-CMD. Bloquer l'accès à l'invite de commande

!!! example "Objectif"
    
    Interdire aux utilisateurs de Ventes d'utiliser `cmd.exe`.

!!! info "Étapes"
    
    1.2.1. Appliquer la GPO uniquement à Ventes
    1.2.2. Appliquer la GPO à Ventes et IT mais créer une exception pour le groupe "GG-EU-IT-Admin" (Créez le groupe si nécessaire)

!!! info "Configuration"
    
    **Setting**: Config Utilisateur > Strategies > Modèles d'administration > Système > Desactiver l'accès à l'invite de commandes

## 2. Stratégies

### 2.1. GPO-Configuration-MessageConnexion. Afficher message de connexion

!!! example "Objectif"
    
    Établir une GPO pour afficher un message corporatif lors de la connexion dans les ordinateurs de IT (ex: `Bienvenue sur le réseau Maxtec. Rappel : les données d'IT sont confidentielles.`)

!!! info "Settings"
    
    1. Config Ordinateur > Stratégies > Paramètres Windows > Paramètres de sécurité > Stratégies locales > Options de sécurité > Ouverture de session interactive: contenu du message 
    
    2. Config Ordinateur > Stratégies > Paramètres Windows > Paramètres de sécurité > Stratégies locales > Options de sécurité > Ouverture de session interactive: titre du message

### 2.2. GPO-Blocage-Inactivite. Blocage de l'ordinateur après 5 minutes d'inactivité

!!! example "Objectif"
    
    2.2.1. Établir une GPO qui bloque tous les ordinateurs d'EU après 5 minutes d'inactivité (pour l'exercice, fixez 15 secondes pour ne pas devoir attendre autant)

!!! tip "Conseil"
    
    Vous pouvez trouvez le paramètre dans la même section que l'exercice précédent... essayez de le trouvez par vous-même

!!! warning "Problème"
    
    2.2.2. Richard de RH ne supporte plus que le blocage...
    Créez un groupe de sécurité contenant **son ordinateur** (on pourrait rajouter d'autres ordinateurs dans le futur). Les politiques de blocage pour inactivité sont appliquées à niveau d'ordinateurs, pas d'utilisateur.

!!! info "Solution"
    
    Pour limiter l'impact de la GPO, vous pouvez débloquer l'application de la GPO sur l'ordinateur de Richard:
    
    - Double Clic sur GPO > Délegation > Avancé > Ajouter 
    - Pour que les ordinateurs soient visibles, il faut cliquer sur `Type d'objet` et cocher `Computers`
    - Chercher l'ordinateur de Richard (ex: `ws-rh-01`)
    - Clic sur `OK`
    - Cliquez l'ordinateur dans la liste, puis allez dans les droits et cocher `Refuser` pour `Appliquer la strategie de groupe`


### 2.3. GPO-Installation-Chrome. Déploiement de Chrome sur les ordinateurs de RH

!!! example "Contexte"
    
    Les utilisateurs de RH se sont mis d'accord et ont demandé de pouvoir utiliser Chrome sur leurs ordinateurs. L'administrateur veut automatiser la procédure.

!!! warning "Sécurité"
    
    Pour ce faire, tous les ordinateurs doivent avoir accès à un dossier partagé qui contient Chrome. Il est très important que ce dossier partagé ne soit accessible que par les utilisateurs concernés car s'il est accessible par tout le monde, les risques de sécurité du serveur se multiplient.

!!! info "Étape 2.3.1 - Création du groupe d'ordinateurs"
    
    Cette GPO va être appliquée à un ensemble d'**ordinateurs**, car nous voulons installer Chrome uniquement sur les ordinateurs de RH.
    La façon la plus propre de faire c'est de créer un groupe de sécurité contenant les ordinateurs de RH.
    
    - Allez dans `Utilisateurs et ordinateurs d'AD` dans le serveur
    - Créez un groupe de sécurité qui contiendra les ordinateurs de RH (on en a qu'un: `ws-rh-01`). Ex: `GG-EU-RH-Computers-Chrome`. 
    - Pour pouvoir rechercher et ajouter ces ordinateurs dans le groupe, vous devez cliquer sur `Types d'objets` dans la fenêtre de recherche et cocher la case `Ordinateurs`
    - Faites la recherche, trouvez `ws-rh-01` et cliquez sur `Ajouter`  

!!! tip "Avantage"
    
    Ce groupe recevra les permissions pour accéder au dossier partagé sur le serveur qui contiendra le fichier d'installation de Chrome. Nous créons un groupe car cela nous permet de déclencher l'installation de Chrome sur un autre ordinateur simplement en l'ajoutant au groupe.

!!! info "Étape 2.3.2 - Création du dossier partagé"
    
    Créer un dossier partagé (ex: `c:\Software`) **sur le serveur**. 
    
    Dans `Partage avancé` > `Utilisateurs`, supprimez l'accès de `Everyone` sur le dossier (la lecture suffira)
    
    Ajoutez les groupes suivants :
    
    - `GG-EU-RH-Computers-Chrome`
    - `Administrateur` (car il devra accéder au dossier pendant la configuration de la GPO)

!!! note "Note importante"
    
    Vous pouvez (pour pouvoir afficher son contenu depuis la machine cliente pendant les tests) ajouter `GG-EU-RH-Admins` et `GG-EU-RH-Users` si vous le souhaitez, mais ce n'est pas nécessaire. **Seuls les ordinateurs doivent accéder au dossier pour lire et exécuter le fichier .msi d'installation**. En principe, les utilisateurs ne doivent pas accéder à ce dossier.
    
    Dans l'onglet `Sécurité` > `Modifier` > `Ajouter` le groupe des ordinateurs de RH.

!!! example "Téléchargement de Chrome"
    
    On doit télécharger Chrome et le stocker dans le dossier partagé. Si vous n'avez pas d'accès Internet :
    
    1. Éteignez la machine dans Virtualbox
    2. Ajoutez un adaptateur (adapter 2) réseau NAT
    3. Redémarrez la machine
    
    Allez sur ce lien https://chromeenterprise.google/download/
    
    Cliquez sur `Bundle` et choisissez **.msi**
    
    Copiez ce fichier dans le dossier partagé `c:\Software`

!!! info "Application de la GPO"
    
    Vous pourrez ensuite appliquer la GPO sur l'OU des ordinateurs de RH : elle sera appliquée par héritage sur les ordinateurs de RH.

!!! example "Création de la GPO sur l'OU des ordinateurs de RH"
    
    Allez sur `Configuration Ordinateur > Stratégies > Paramètres du logiciel > Installation logiciel`
    
    Faites un clic droit et sélectionnez `Nouveau`, puis **saisissez le chemin RÉSEAU manuellement** dans la barre de recherche.

!!! warning "Important"
    
    Le chemin doit être au format réseau, c'est-à-dire `\\dns1\Software\chrome_installer.msi`. Un chemin local du type `C:\Software\chrome_installer.msi` ne fonctionnera pas.
    
    (remplacez `chrome_installer.msi` par le nom du fichier que vous avez téléchargé. Si le nom du fichier est complexe, vous pouvez simplement le renommer)

!!! info "Étape 2.3.3 - Test de la GPO"
    
    Connectez-vous avec un client de `RH` et forcez l'application de la GPO avec `gpupdate /force`. Un avertissement s'affichera pour vous indiquer que la politique d'installation de notre logiciel a besoin de démarrer l'ordinateur.

!!! success "Étape 2.3.4 - Installation"
    
    Redémarrez l'ordinateur. Chrome s'installera au démarrage.
    Vous devriez voir l'icône de Chrome sur le bureau.

!!! example "Exercice supplémentaire"
    
    Répétez l'exercice pour installer `7-zip`. Vous devez télécharger un installateur au format `.msi` sur le serveur et le mettre dans le dossier partagé `c:\Software`.


!!! success "Résumé des permissions"

| Caractéristique | Onglet Partage | Onglet Sécurité (NTFS) |
|-----------------|----------------|----------------------|
| S'applique à | Accès réseau uniquement | Accès local et réseau |
| Contrôle | Qui peut accéder au dossier partagé | Qui peut accéder aux fichiers/dossiers à l'intérieur |
| Emplacement | Onglet Partage → Permissions | Onglet Sécurité |
| Droits communs | Lecture / Modification / Contrôle total | Liste complète (Lecture, Écriture, Modification...) |
| Priorité | La plus restrictive l'emporte | La plus restrictive l'emporte |

### 2.4. Créer d'un dossier partagé pour les utilisateurs d'IT et le faire apparaître sur leurs ordinateurs comme une unité de stockage (ex: F:, Z: ...)

!!! example "Objectif"
    
    1. Créer un dossier partagé `C:\Shares\IT-Admin` (suivez les instructions pour créer un dossier partagé du chapitre 5). Le but sera de le mapper sur les ordinateurs de IT (les utilisateurs veront ce dossier comme une unité de stockage F:, Z: ou le lettre de notre choix)
    2. Dans notre cas, ce dossier partagé sera accessible par les utilisateurs administrateurs de IT. Modifiez les permissions du partage et NTFS    

!!! info "Configuration de la GPO"
    
    Créez maintenant un GPO sur l'OU `IT`.
    
    Allez dans Configuration Utilisateur > Préférences > Paramètres Windows > Mappages lecteurs > Faites clique droit > Nouveau.
    
    Le chemin pour le dossier **doit être le nom du partage** qu'on voit dans les propriétés du dossier partagé. Pas `C:\Shares\IT-Admin` mais `\\dns1\IT-Admin` (regardez dans les propriétés du dossier partagé)

!!! question "Question de réflexion"
    
    Qu'est-ce qu'on doit faire maintenant pour tester le fonctionnement de notre GPO?

!!! example "Variation de l'exercice"
    
    Imaginez que le **mappage** du dossier partagé doit être caché et visible uniquement pour les utilisateurs administrateurs de IT.


## 3. Préférences

### 3.1. GPO-LinkBureau. Créer une icone sur le Bureau de l'utilisateur pour les utilisateurs de Ventes (ou un autre departement pour lequel vous avez déjà un ordinateur)

!!! info "Configuration"
    
    (Config Utilisateur > Préférences -> Paramètres Windows > Raccourcis > Nouveau > Définir l'adresse et l'emplacement).

!!! example "Tableau des actions GPO"

| Action choisie dans la GPO | Le lien revient s'il est supprimé ? | Quand ?                                              |
|----------------------------|--------------------------------------|------------------------------------------------------|
| **Create**                 | ❌ Non                               | Jamais                                               |
| **Update**                 | ❌ Non                               | Jamais                                               |
| **Replace**                | ✅ Oui                               | Au prochain `gpupdate`, redémarrage ou ouverture de session |
| **Delete**                 | 🔄 Supprime le lien (s'il existe)    | Lors de l'application de la GPO                      |

!!! tip "Important"
    
    Pour ajuster le ciblage, clique droit sur le Raccourci créé et Propriétés > Commun > Ciblage

!!! note "Pour aller plus loin"
    
    Pour restreindre l'application du raccourci aux seuls administrateurs de Ventes (sans déplacer le lien de la GPO), voir l'exercice **Item-level targeting** dans `Exercices: GPO-3.md`.

## 4. Créer des exceptions à la GPO

!!! example "Objectif"
    
    Eviter l'application d'une GPO sur un ordinateur ou un utilisateur en particulier

### 4.1. Éviter la restriction du panneau de configuration sur les admin de Ventes



