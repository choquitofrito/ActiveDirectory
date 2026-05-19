## Exercices avancés de stratégies de groupe (GPO)

### Prérequis

Avant de commencer, assurez-vous d'avoir la structure complète de l'AD avec les départements (Comptabilité, RH, Ventes, IT) et leurs OUs respectives.

!!! warning "Prérequis pour les exercices GPO-3"

- Assurez-vous d'avoir les groupes suivants :
  - `GG-EU-Compta-Users` : Charles, Cindy
  - `GG-EU-Compta-Admins` : Charlotte
  - `GG-EU-RH-Users` : Rene, Rebecca
  - `GG-EU-RH-Admins` : Richard
  - `GG-EU-Ventes-Users` : Victor, Vanessa, Valeria
  - `GG-EU-Ventes-Admins` : Valentin
  - `GG-EU-IT-Users` : Ivan, Ines
  - `GG-EU-IT-Admin` : Irene

- Assurez-vous d'avoir au moins un ordinateur dans chaque département :
  - `ws-compta-01.maxtec.be`
  - `ws-rh-01.maxtec.be`
  - `ws-ventes-01.maxtec.be`
  - `ws-it-01.maxtec.be`

## 1. 🔹 Redirection de dossiers vers un serveur

### Exercice 1.1: GPO-Redirection-Dossiers-Comptabilite

**Objectif** : Configurer une redirection des dossiers Documents et Bureau des utilisateurs du département Comptabilité vers un emplacement centralisé sur le serveur.

**Contexte professionnel** : Cette pratique est courante en entreprise pour faciliter les sauvegardes et permettre aux utilisateurs d'accéder à leurs documents depuis n'importe quel poste de travail. Elle garantit également la disponibilité des données en cas de panne d'un poste de travail.


#### Étape 1: Préparation de l'infrastructure

1. Créez un dossier partagé sur le serveur : `C:\Shares-Compta`
2. Configurez les permissions de partage :
   - `GG-EU-Compta-Users` : Contrôle total
   - `GG-EU-Compta-Admins` : Contrôle total
   - `Administrateurs du domaine` : Contrôle total

3. Configurez les permissions NTFS :
   - Effacez `Utilisateurs` (desactivez l'héritage)
   - `GG-EU-Compta-Users` : Contrôle total
   - `GG-EU-Compta-Admins` : Contrôle total

#### Étape 2: Création de la GPO

1. Créez une nouvelle GPO nommée `GPO-Redirection-Dossiers-Comptabilite`
2. Liez-la à l'OU `EU\Comptabilité\Users`
3. Configurez les paramètres suivants :
   - Naviguez vers `Configuration utilisateur > Stratégies > Paramètres Windows > Redirection de dossiers`
   - Cliquez-droit sur `Documents` > `Propriétés`
   - Sélectionnez `De base - Rediriger le dossier de chaque utilisateur vers le même emplacement`
   - Pour l'emplacement cible, sélectionnez `Créer un dossier pour chaque utilisateur sous le chemin racine`
   - Entrez le chemin racine : `\\dns1\Shares\Comptabilite\UserData`

#### Étape 3: Test de la GPO

1. Connectez-vous sur `ws-compta-01` avec l'utilisateur `Charles`
2. Exécutez `gpupdate /force`
3. Déconnectez-vous puis reconnectez-vous
4. Vérifiez que les dossiers `Documents` sont maintenant redirigés vers le serveur
5. Créez un document dans le dossier `Documents`
6. Déconnectez-vous et connectez-vous sur un autre poste avec le même utilisateur
7. Vérifiez que le document est accessible

Si la GPO ne fonctionne pas, allez dans l'observateur d'événements et regardez les logs de la GPO (Observateur d'événements > Journaux Windows > Application -> Filtrer -> Erreurs -> 520)


## 2. 🔹 Ciblage au niveau de l'élément (Item-level targeting)

### Exercice 2.1: Restreindre une préférence à un groupe de sécurité

**Objectif** : Modifier la GPO `GPO-LinkBureau` (créée dans `Exercices: GPO-1.md`, section 3.1) pour que le raccourci de Bureau ne s'applique qu'aux membres de `GG-EU-Ventes-Admins`, sans toucher au lien de la GPO ni à l'OU.

**Contexte professionnel** : Une même GPO peut contenir plusieurs préférences destinées à des sous-groupes différents (admins, users, mobiles...). Le ciblage d'élément permet de filtrer ligne par ligne à l'intérieur de la GPO, ce qui évite de multiplier les GPOs ou de créer des sous-OUs artificielles.

**Pourquoi pas une sous-OU ou un autre lien ?** Les admins et les users de Ventes sont dans la **même OU**. Déplacer le lien de la GPO sur une sous-OU ferait disparaître le raccourci pour tous les utilisateurs Ventes. Le ciblage d'élément agit *à l'intérieur* de la préférence, sans modifier la portée de la GPO.

#### Prérequis

- Avoir terminé l'exercice 3.1 de `Exercices: GPO-1.md` (GPO `GPO-LinkBureau` qui crée un raccourci sur le Bureau des utilisateurs de Ventes).
- Avoir au moins un utilisateur dans `GG-EU-Ventes-Admins` (ex: Valentin) et un dans `GG-EU-Ventes-Users` (ex: Victor).

#### Étape 1: Activer le ciblage sur la préférence

1. Ouvrez la console `Gestion des stratégies de groupe` (GPMC).
2. Faites un clic droit sur la GPO `GPO-LinkBureau` > `Modifier`.
3. Naviguez vers `Configuration Utilisateur > Préférences > Paramètres Windows > Raccourcis`.
4. Double-cliquez sur le raccourci créé précédemment.
5. Allez dans l'onglet `Commun`.
6. Cochez `Ciblage au niveau de l'élément`.
7. Cliquez sur le bouton `Ciblage...`.

#### Étape 2: Définir la condition de ciblage

1. Dans l'éditeur de ciblage : `Nouvel élément > Groupe de sécurité`.
2. Cliquez sur `...` à côté du champ `Groupe` et sélectionnez `GG-EU-Ventes-Admins`.
3. Laissez l'option `L'utilisateur dans le groupe` cochée (et non `L'ordinateur dans le groupe`).
4. Validez avec `OK`, puis `Appliquer` et `OK`.

#### Étape 3: Test de la GPO

1. Sur un poste client de Ventes, connectez-vous avec **Valentin** (`GG-EU-Ventes-Admins`).
2. Exécutez `gpupdate /force`, déconnectez-vous et reconnectez-vous.
3. Vérifiez que le raccourci apparaît sur le Bureau.
4. Déconnectez-vous et connectez-vous avec **Victor** ou **Vanessa** (`GG-EU-Ventes-Users`).
5. Vérifiez que le raccourci **n'apparaît pas**.

#### Question de réflexion

Que se passe-t-il si vous utilisez l'action `Replace` (au lieu de `Create`) sur le raccourci, et qu'un utilisateur quitte ensuite le groupe `GG-EU-Ventes-Admins` ? (Indice : relisez le tableau des actions GPO de `Exercices: GPO-1.md` section 3.1.)

#### Variante : combiner critères utilisateur et ordinateur

Une même condition de ciblage peut mélanger des critères de **l'utilisateur** et de **l'ordinateur**. Exemple : faire apparaître le raccourci uniquement quand Valentin se connecte depuis un poste de l'OU `Ventes` (et pas depuis un portable de prêt).

1. Dans l'éditeur de ciblage, conservez la condition `Groupe de sécurité = GG-EU-Ventes-Admins`.
2. Ajoutez `Nouvel élément > Unité d'organisation` et sélectionnez `OU=Computers,OU=Ventes,OU=EU,...`. Cochez `L'ordinateur est dans l'unité d'organisation`.
3. Sur la seconde ligne, vérifiez que l'opérateur est `ET` (bouton `Options d'élément`).

!!! warning "Attention au contexte de la préférence"
    
    Cette astuce ne marche qu'avec une préférence située dans `Configuration Utilisateur` (évaluée à l'ouverture de session, où l'utilisateur **et** l'ordinateur sont connus). Dans `Configuration Ordinateur`, une condition sur l'utilisateur est évaluée contre le compte `SYSTEM` et échouera presque toujours.

#### Pour aller plus loin

Le ciblage d'élément accepte des conditions combinées (ET / OU / NON) et de nombreux critères : OS, plage IP, fichier existant, variable d'environnement, requête WMI, etc. C'est la même mécanique que celle utilisée pour les imprimantes dans la section suivante.

## 3. 🔹 Configuration d'imprimantes par emplacement

### Exercice 3.1: GPO-Imprimantes-EU

**Objectif** : Déployer automatiquement des imprimantes différentes selon l'emplacement des utilisateurs (EU).

**Contexte professionnel** : Dans une entreprise avec plusieurs sites, les utilisateurs doivent avoir accès aux imprimantes de leur zone géographique pour éviter d'imprimer des documents dans un autre bâtiment.

#### Étape 1: Configuration des imprimantes sur le serveur

1. Sur le serveur, ouvrez `Ajouter une imprimante`
2. Ajoutez une nouvelle imprimante réseau :
   - Nom : `Imprimante-EU-01`
   - Port : Créez un nouveau port TCP/IP (vous pouvez utiliser une adresse fictive comme `192.168.10.100`)
   - Pilote : Sélectionnez `MS Publisher Color Printer` (pilote générique disponible par défaut)
   - Partagez l'imprimante avec le nom `Imprimante-EU-01`

3. Ajoutez une deuxième imprimante :
   - Nom : `Imprimante-EU-02`
   - Port : Nouveau port TCP/IP (ex: `192.168.10.101`)
   - Pilote : Sélectionnez `MS Publisher Color Printer`
   - Partagez l'imprimante avec le nom `Imprimante-EU-02`

#### Étape 2: Création de la GPO pour les imprimantes EU

1. Créez une nouvelle GPO nommée `GPO-Imprimantes-EU`
2. Liez-la à l'OU `EU`
3. Configurez les paramètres suivants :
   - Naviguez vers `Configuration utilisateur > Préférences > Paramètres du Panneau de configuration > Imprimantes`
   - Cliquez-droit et sélectionnez `Nouveau > Imprimante partagée`
   - Action : `Créer`
   - Chemin de l'imprimante partagée : `\\dns1\Imprimante-EU-01`
   - Cochez `Définir comme imprimante par défaut` pour la première imprimante

4. Ajoutez une deuxième imprimante :
   - Cliquez-droit et sélectionnez `Nouveau > Imprimante partagée`
   - Action : `Créer`
   - Chemin de l'imprimante partagée : `\\dns1\Imprimante-EU-02`

#### Étape 3: Configuration du ciblage par département

1. Pour l'imprimante `Imprimante-EU-01` :
   - Cliquez-droit sur l'élément d'imprimante et sélectionnez `Propriétés`
   - Allez dans l'onglet `Commun`
   - Cochez `Ciblage d'élément`
   - Cliquez sur `Ciblage...`
   - Ajoutez une nouvelle condition : `Groupe de sécurité` est `GG-EU-Compta-Users`
   - Ajoutez une autre condition avec OU logique : `Groupe de sécurité` est `GG-EU-RH-Users`

2. Pour l'imprimante `Imprimante-EU-02` :
   - Configurez le ciblage pour les groupes `GG-EU-Ventes-Users` et `GG-EU-IT-Users`

#### Étape 4: Test de la GPO

1. Connectez-vous sur un poste client avec un utilisateur de Comptabilité
2. Exécutez `gpupdate /force`
3. Vérifiez que l'imprimante `Imprimante-EU-01` est installée et définie par défaut
4. Déconnectez-vous et connectez-vous avec un utilisateur de Ventes
5. Vérifiez que l'imprimante `Imprimante-EU-02` est installée

### Exercice 3.2: GPO-Imprimantes-Departement

**Objectif** : Configurer des imprimantes spécifiques par département avec des droits d'impression différents.

**Contexte professionnel** : Certains départements comme la Comptabilité ont besoin d'imprimantes dédiées pour les documents confidentiels.

1. Créez une nouvelle imprimante partagée sur le serveur :
   - Nom : `Imprimante-Compta-Confidentiel`
   - Configurez les permissions pour que seul le groupe `GG-EU-Compta-Users` puisse imprimer

2. Créez une GPO nommée `GPO-Imprimante-Compta-Confidentiel`
3. Liez-la à l'OU `EU\Comptabilité\Users`
4. Configurez l'installation de l'imprimante `\\dns1\Imprimante-Compta-Confidentiel`
5. Définissez cette imprimante comme imprimante par défaut

6. Testez en vous connectant avec un utilisateur de Comptabilité et vérifiez que les deux imprimantes sont disponibles, mais que l'imprimante confidentielle est définie par défaut
