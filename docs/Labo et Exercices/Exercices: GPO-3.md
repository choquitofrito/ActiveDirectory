# Exercices : GPO — série 3 (avancé)

### Prérequis

Structure complète de l'AD avec les départements (Ventes, RH, Comptabilite, IT) et leurs OUs : voir la [Référence du lab Maxtec](Labo/Reference_Lab_Maxtec.md).

!!! warning "Prérequis pour les exercices GPO-3"

    - Groupes et membres :
        - `GG-EU-Compta-Users` : Charles, Cindy
        - `GG-EU-Compta-Admin` : Charlotte
        - `GG-EU-RH-Users` : Rene, Rebecca
        - `GG-EU-RH-Admin` : Richard
        - `GG-EU-Ventes-Users` : Victor, Vanessa, Valeria
        - `GG-EU-Ventes-Admin` : Valentin
        - `GG-EU-IT-Users` : Ivan, Ines
        - `GG-EU-IT-Admin` : Irene

    - Postes : `ws-IT-01` dans `EU\IT\Computers` (obligatoire), `ws-RH-01` dans `EU\RH\Computers` (optionnel).
    - La GPO de restriction d'ouverture de session de [GPO-2, exercice 5](./Exercices:%20GPO-2.md) ne doit plus être liée à `EU\IT\Computers` (lien supprimé en fin d'exercice 5), sinon seuls les membres d'IT peuvent se connecter à `ws-IT-01`.

!!! tip "Un seul poste suffit"
    Toutes les GPO de cette série sont des GPO de configuration **utilisateur** : elles suivent l'utilisateur, quel que soit le poste. Pour tester un utilisateur de Comptabilite ou de Ventes, ouvrez simplement une session avec lui sur `ws-IT-01`. Un second poste n'est utile que pour vérifier qu'on retrouve ses documents en changeant de machine.

## 1. Redirection de dossiers vers un serveur

### Exercice 1.1: GPO-Redirection-Dossiers-Comptabilite

**Objectif** : Rediriger le dossier **Documents** des utilisateurs de Comptabilite vers un emplacement centralisé sur le serveur.

**Contexte professionnel** : Pratique courante en entreprise pour faciliter les sauvegardes et permettre aux utilisateurs de retrouver leurs documents depuis n'importe quel poste. Les données survivent à la panne d'un poste.


#### Étape 1: Préparation de l'infrastructure

1. Créez le dossier `C:\Shares\Compta-Docs` sur le serveur et partagez-le sous le nom `Compta-Docs`
2. Permissions de **partage** (Partage avancé > Autorisations) : retirez `Tout le monde`, puis
    - `GG-EU-Compta-Users` : Contrôle total
    - `GG-EU-Compta-Admin` : Contrôle total
    - `Administrateurs` : Contrôle total

    Le contrôle total au niveau du partage n'est pas un problème : c'est NTFS qui fait le vrai filtrage.

3. Permissions **NTFS** à la racine (onglet Sécurité > Avancé) :
    - **Désactivez l'héritage** (convertir en autorisations explicites), puis supprimez `Utilisateurs` et toute autre entrée non listée ci-dessous
    - `SYSTEM` : Contrôle total — Ce dossier, les sous-dossiers et les fichiers
    - `Administrateurs` : Contrôle total — Ce dossier seulement
    - `CREATEUR PROPRIETAIRE` : Contrôle total — Les sous-dossiers et les fichiers seulement
    - `GG-EU-Compta-Users` et `GG-EU-Compta-Admin` : **Afficher les autorisations avancées** > uniquement `Parcours du dossier / exécuter le fichier`, `Liste du dossier / lecture de données`, `Lecture des attributs`, `Lecture des attributs étendus`, `Création de dossiers / ajout de données` et `Autorisations de lecture` — **Ce dossier seulement**

!!! info "Pourquoi pas « Contrôle total » pour les utilisateurs à la racine ?"
    Avec un contrôle total à la racine, chaque utilisateur pourrait ouvrir, modifier ou supprimer le dossier de ses collègues. Le schéma ci-dessus est celui recommandé par Microsoft (documentation *Deploy Folder Redirection*) : l'utilisateur peut seulement **créer** son dossier à la racine ; en tant que créateur, il en devient propriétaire, et `CREATEUR PROPRIETAIRE` lui donne le contrôle total **sur son dossier uniquement**. En cas de doute sur un détail, c'est cette documentation qui fait foi.

    `GG-EU-Compta-Admin` est ajouté car Charlotte est dans l'OU Comptabilite mais **pas** dans `GG-EU-Compta-Users` : sans cette entrée, sa redirection échouerait.

#### Étape 2: Création de la GPO

1. Créez une nouvelle GPO nommée `GPO-Redirection-Dossiers-Comptabilite`
2. Liez-la à l'OU `EU\Comptabilite\Users`
3. Configurez les paramètres suivants :
    - Naviguez vers `Configuration utilisateur > Stratégies > Paramètres Windows > Redirection de dossiers`
    - Clic droit sur `Documents` > `Propriétés`
    - Sélectionnez `De base - Rediriger le dossier de chaque utilisateur vers le même emplacement`
    - Emplacement du dossier cible : `Créer un dossier pour chaque utilisateur sous le chemin racine`
    - Chemin racine : `\\dns1\Compta-Docs`
    - Onglet `Paramètres` : laissez **Accorder à l'utilisateur des droits exclusifs** coché (les administrateurs n'auront pas accès au contenu, c'est voulu) et **Déplacer le contenu de Documents vers le nouvel emplacement** coché

#### Étape 3: Test de la GPO

1. Ouvrez une session sur `ws-IT-01` avec `charles`
2. Exécutez `gpupdate /force`
3. Fermez la session puis rouvrez-la (la redirection de dossiers ne s'applique qu'à l'ouverture de session ; il faut parfois deux ouvertures de session)
4. Vérifiez que `Documents` est redirigé vers le serveur (voir vérification ci-dessous)
5. Créez un document dans `Documents`
6. Si vous avez `ws-RH-01` : connectez-vous dessus avec `charles` et vérifiez que le document est là

Si la GPO ne fonctionne pas : Observateur d'événements > Journaux Windows > Application, source **Folder Redirection**, et `Journaux des applications et des services > Microsoft > Windows > Folder Redirection > Operational`.

??? success "Vérification"

    - Sur le poste : clic droit sur `Documents` > Propriétés > onglet **Emplacement** → `\\dns1\Compta-Docs\charles\Documents`
    - `gpresult /r /scope user` → `GPO-Redirection-Dossiers-Comptabilite` figure dans les **Objets Stratégie de groupe appliqués**
    - Sur le serveur : `C:\Shares\Compta-Docs\charles` existe. En tant qu'administrateur, vous ne pouvez pas l'ouvrir (droits exclusifs) : c'est le comportement attendu
    - Avec `cindy` : son propre dossier est créé, et elle ne peut pas ouvrir celui de `charles` (`\\dns1\Compta-Docs\charles` → accès refusé)

    Vérification des permissions de la racine : sur le serveur, Explorateur > clic droit sur `C:\Shares\Compta-Docs` > **Propriétés** > onglet **Sécurité** > **Avancé** : les entrées doivent correspondre à l'étape 1 (colonne **S'applique à** : « Ce dossier seulement », « Les sous-dossiers et les fichiers seulement »…). En invite de commandes : `icacls C:\Shares\Compta-Docs`.

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    (Get-Acl C:\Shares\Compta-Docs).Access | Format-Table IdentityReference, FileSystemRights, InheritanceFlags, PropagationFlags -AutoSize
    ```


## 2. Ciblage au niveau de l'élément (Item-level targeting)

### Exercice 2.1: Restreindre une préférence à un groupe de sécurité

**Objectif** : Modifier la GPO `GPO-LinkBureau` (créée dans [GPO-1](./Exercices:%20GPO-1.md), section 3.1) pour que le raccourci de Bureau ne s'applique qu'aux membres de `GG-EU-Ventes-Admin`, sans toucher au lien de la GPO ni à l'OU.

**Contexte professionnel** : Une même GPO peut contenir plusieurs préférences destinées à des sous-groupes différents (responsables, utilisateurs, portables…). Le ciblage d'élément filtre ligne par ligne à l'intérieur de la GPO, ce qui évite de multiplier les GPOs ou de créer des sous-OUs artificielles.

**Pourquoi pas une sous-OU ou un autre lien ?** Les responsables et les utilisateurs de Ventes sont dans la **même OU**. Déplacer le lien de la GPO sur une sous-OU ferait disparaître le raccourci pour tous les utilisateurs Ventes. Le ciblage d'élément agit *à l'intérieur* de la préférence, sans modifier la portée de la GPO.

#### Prérequis

- Avoir terminé l'exercice 3.1 de [GPO-1](./Exercices:%20GPO-1.md) (GPO `GPO-LinkBureau` qui crée un raccourci sur le Bureau des utilisateurs de Ventes).
- Si vous avez fait l'étape 1 de [GPO-2, exercice 7](./Exercices:%20GPO-2.md), la GPO est déjà filtrée sur `GG-EU-Ventes-Admin` : remettez `Utilisateurs authentifiés` (Authenticated Users) dans le filtrage de sécurité pour que le test ait un sens.

#### Étape 1: Activer le ciblage sur la préférence

1. Ouvrez la console `Gestion des stratégies de groupe` (GPMC).
2. Faites un clic droit sur la GPO `GPO-LinkBureau` > `Modifier`.
3. Naviguez vers `Configuration utilisateur > Préférences > Paramètres Windows > Raccourcis`.
4. Double-cliquez sur le raccourci créé précédemment.
5. Allez dans l'onglet `Commun`.
6. Cochez `Ciblage au niveau de l'élément`.
7. Cliquez sur le bouton `Ciblage...`.

#### Étape 2: Définir la condition de ciblage

1. Dans l'éditeur de ciblage : `Nouvel élément > Groupe de sécurité`.
2. Cliquez sur `...` à côté du champ `Groupe` et sélectionnez `GG-EU-Ventes-Admin`.
3. Laissez l'option `L'utilisateur dans le groupe` cochée (et non `L'ordinateur dans le groupe`).
4. Validez avec `OK`, puis `Appliquer` et `OK`.

#### Étape 3: Test de la GPO

1. Sur `ws-IT-01`, connectez-vous avec **Valentin** (`GG-EU-Ventes-Admin`).
2. Exécutez `gpupdate /force`.
3. Vérifiez que le raccourci apparaît sur le Bureau.
4. Déconnectez-vous et connectez-vous avec **Victor** ou **Vanessa** (`GG-EU-Ventes-Users`).
5. Vérifiez que le raccourci **n'apparaît pas**. Si Vanessa avait déjà le raccourci (test de GPO-1), il reste : le ciblage empêche la préférence de s'appliquer, il ne supprime pas ce qui existe. Voir la question de réflexion.

#### Question de réflexion

Que se passe-t-il si vous utilisez l'action `Remplacer` (au lieu de `Créer`) sur le raccourci, et qu'un utilisateur quitte ensuite le groupe `GG-EU-Ventes-Admin` ? Et si l'option **Supprimer cet élément lorsqu'il n'est plus appliqué** est cochée ? (Indice : relisez le tableau des actions de [GPO-1](./Exercices:%20GPO-1.md), section 3.1.)

??? success "Réponse"

    Avec `Remplacer` seul, le raccourci déjà présent **reste** : l'élément n'est plus appliqué, donc plus rien ne le touche. Avec **Supprimer cet élément lorsqu'il n'est plus appliqué**, le raccourci est retiré au rafraîchissement suivant, dès que l'utilisateur ne remplit plus la condition de ciblage. Rappel : l'utilisateur ne voit sa sortie du groupe qu'après une nouvelle ouverture de session (son jeton contient ses groupes).

#### Variante : combiner critères utilisateur et ordinateur

Une même condition de ciblage peut mélanger des critères de **l'utilisateur** et de **l'ordinateur**. Exemple : faire apparaître le raccourci uniquement quand Valentin se connecte depuis un poste d'une OU donnée (et pas depuis un portable de prêt). Dans le lab, le seul poste est dans `EU\IT\Computers` : utilisez cette OU pour le test.

1. Dans l'éditeur de ciblage, conservez la condition `Groupe de sécurité = GG-EU-Ventes-Admin`.
2. Ajoutez `Nouvel élément > Unité d'organisation` et sélectionnez `OU=Computers,OU=IT,OU=EU,DC=maxtec,DC=be` (en production : l'OU des postes Ventes). Cochez `L'ordinateur est dans l'unité d'organisation`.
3. Sur la seconde ligne, vérifiez que l'opérateur est `ET` (bouton `Options d'élément`).
4. Test : Valentin sur `ws-IT-01` voit le raccourci. Remplacez l'OU par `OU=Computers,OU=Ventes,…`, `gpupdate /force` : il ne le voit plus (à condition que l'option de suppression soit cochée, voir ci-dessus).

!!! warning "Attention au contexte de la préférence"

    Cette astuce ne marche qu'avec une préférence située dans `Configuration utilisateur` (évaluée à l'ouverture de session, où l'utilisateur **et** l'ordinateur sont connus). Dans `Configuration ordinateur`, une condition sur l'utilisateur est évaluée contre le compte `SYSTEM` et échouera presque toujours.

#### Pour aller plus loin

Le ciblage d'élément accepte des conditions combinées (ET / OU / NON) et de nombreux critères : OS, plage IP, fichier existant, variable d'environnement, requête WMI, etc. C'est la même mécanique que celle utilisée pour les imprimantes dans la section suivante.

## 3. Configuration d'imprimantes par emplacement (optionnel)

!!! warning "Section optionnelle : deux limites à connaître avant de commencer"

    **Pilotes et Point and Print.** Depuis la mise à jour KB5005033 (août 2021, suite à PrintNightmare), un utilisateur standard ne peut plus installer un pilote d'imprimante depuis un serveur d'impression : l'installation demande des identifiants administrateur. Avec une GPO utilisateur, la connexion à l'imprimante peut donc échouer silencieusement. Solution de lab : ouvrez **une fois** une session administrateur sur `ws-IT-01` et connectez-vous à chaque imprimante (`\\dns1\Imprimante-EU-01`…) pour installer le pilote. Les utilisateurs pourront ensuite s'y connecter. Ne désactivez pas cette protection pour contourner le problème.

    **Impression sur un DC.** En production, on désactive le service Spouleur d'impression sur les contrôleurs de domaine (recommandation de sécurité depuis PrintNightmare) et on utilise un serveur d'impression membre. Ici, on l'utilise sur le DC par manque de machines. Après l'exercice, vous pouvez supprimer les imprimantes et arrêter le spouleur.

### Exercice 3.1: GPO-Imprimantes-EU

**Objectif** : Déployer automatiquement des imprimantes différentes selon le département des utilisateurs.

**Contexte professionnel** : Dans une entreprise avec plusieurs sites ou étages, chaque utilisateur doit avoir les imprimantes de sa zone pour éviter d'imprimer dans un autre bâtiment.

#### Étape 1: Configuration des imprimantes sur le serveur

1. Sur le serveur, ouvrez `Paramètres > Imprimantes et scanners > Ajouter une imprimante` (ou `printmanagement.msc`)
2. Ajoutez une nouvelle imprimante :
    - Nom : `Imprimante-EU-01`
    - Port : nouveau port TCP/IP (adresse fictive, par exemple `192.168.0.100` ; désactivez l'interrogation de l'imprimante)
    - Pilote : `MS Publisher Color Printer` (pilote générique disponible par défaut)
    - Partagez l'imprimante sous le nom `Imprimante-EU-01`

3. Ajoutez une deuxième imprimante :
    - Nom : `Imprimante-EU-02`
    - Port : nouveau port TCP/IP (ex : `192.168.0.101`)
    - Pilote : `MS Publisher Color Printer`
    - Partagez l'imprimante sous le nom `Imprimante-EU-02`

#### Étape 2: Création de la GPO pour les imprimantes EU

1. Créez une nouvelle GPO nommée `GPO-Imprimantes-EU`
2. Liez-la à l'OU `EU`
3. Configurez les paramètres suivants :
    - Naviguez vers `Configuration utilisateur > Préférences > Paramètres du Panneau de configuration > Imprimantes`
    - Clic droit > `Nouveau > Imprimante partagée`
    - Action : `Mettre à jour`
    - Chemin de partage : `\\dns1\Imprimante-EU-01`
    - Cochez `Définir cette imprimante comme imprimante par défaut`

4. Ajoutez une deuxième imprimante :
    - Clic droit > `Nouveau > Imprimante partagée`
    - Action : `Mettre à jour`
    - Chemin de partage : `\\dns1\Imprimante-EU-02`

#### Étape 3: Configuration du ciblage par département

1. Pour l'imprimante `Imprimante-EU-01` :
    - Clic droit sur l'élément > `Propriétés` > onglet `Commun`
    - Cochez `Ciblage au niveau de l'élément` > `Ciblage...`
    - Ajoutez une condition : `Groupe de sécurité` = `GG-EU-Compta-Users`
    - Ajoutez une seconde condition, opérateur `OU` (bouton `Options d'élément`) : `Groupe de sécurité` = `GG-EU-RH-Users`

2. Pour l'imprimante `Imprimante-EU-02` :
    - Même procédure avec `GG-EU-Ventes-Users` OU `GG-EU-IT-Users`

#### Étape 4: Test de la GPO

1. Connectez-vous sur `ws-IT-01` avec `charles` (Comptabilite)
2. Exécutez `gpupdate /force`
3. Vérifiez que `Imprimante-EU-01` est installée et définie par défaut
4. Déconnectez-vous et connectez-vous avec `vanessa` (Ventes)
5. Vérifiez que seule `Imprimante-EU-02` est installée

??? success "Vérification"

    - Sur `ws-IT-01` (Windows 10) : `Paramètres > Périphériques > Imprimantes et scanners` → l'imprimante apparaît sous la forme `Imprimante-EU-01 sur dns1`. Imprimante par défaut : `Panneau de configuration > Périphériques et imprimantes` (coche verte), ou mention **Par défaut** dans Paramètres. Décochez **Laisser Windows gérer mon imprimante par défaut** si Windows choisit à votre place.
    - En PowerShell (aperçu, vu au chapitre 9) : `Get-Printer | Select-Object Name, Type` → l'imprimante apparaît comme `Connection` ; imprimante par défaut : `Get-CimInstance Win32_Printer -Filter "Default=True" | Select-Object Name`
    - `gpresult /r /scope user` → `GPO-Imprimantes-EU` appliquée
    - Si l'imprimante n'apparaît pas : journal `Application`, source **Group Policy Printers**. Une erreur d'accès ou de pilote renvoie au problème Point and Print ci-dessus.

### Exercice 3.2: GPO-Imprimante-Compta-Confidentiel

**Objectif** : Configurer une imprimante réservée à un département.

**Contexte professionnel** : Certains départements comme la Comptabilité ont besoin d'une imprimante dédiée pour les documents confidentiels.

1. Créez une nouvelle imprimante partagée sur le serveur :
    - Nom : `Imprimante-Compta-Confidentiel`
    - Propriétés > onglet `Sécurité` : retirez l'autorisation `Imprimer` de `Tout le monde`, ajoutez `GG-EU-Compta-Users` et `GG-EU-Compta-Admin` avec `Imprimer`

2. Créez une GPO nommée `GPO-Imprimante-Compta-Confidentiel`
3. Liez-la à l'OU `EU\Comptabilite\Users`
4. Déployez l'imprimante `\\dns1\Imprimante-Compta-Confidentiel` (préférence Imprimante partagée, comme en 3.1)
5. Définissez cette imprimante comme imprimante par défaut

6. Testez avec `charles` : les deux imprimantes (`Imprimante-EU-01` et `Imprimante-Compta-Confidentiel`) sont disponibles, et la confidentielle est l'imprimante par défaut.

??? success "Pourquoi la confidentielle l'emporte comme imprimante par défaut"

    Les deux GPO définissent une imprimante par défaut. Les GPO sont appliquées dans l'ordre **L**ocal, **S**ite, **D**omaine, **OU** (de la plus haute à la plus basse) : `GPO-Imprimantes-EU` (liée à `EU`) est traitée avant `GPO-Imprimante-Compta-Confidentiel` (liée à `EU\Comptabilite\Users`). La dernière appliquée gagne. Vérifiez l'ordre avec `gpresult /h rapport.html` (section *Objets de stratégie de groupe appliqués*).

    Test d'accès : avec `vanessa`, tentez d'ajouter `\\dns1\Imprimante-Compta-Confidentiel` manuellement : l'accès est refusé.
