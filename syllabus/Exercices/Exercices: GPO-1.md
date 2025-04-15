### Exercices GPO:

Avant de commencer, assurez-vous d'avoir la structure complète de l'AD.
- Créez la OU pour le département IT (si elle n'existe pas encore) 
- Rajoutez quelques utilisateurs dans Users (ex: "ivan","ines","irene"). 
- Créez aussi un groupe pour les administrateurs de IT (ex: "GG-EU-IT-Admins") et un autre pour les utilisateurs (ex: "GG-EU-IT-Users"). 
- Assurez-vous d'avoir un ordinateur dans Computers (ws-IT-01)
- Rajoutez des utilisateurs aux groupes: 
  - `GG-EU-IT-Users` : Ivan, Ines
  - `GG-EU-IT-Admins` : Irene
  - `GG-EU-Ventes-Users` : Victor, Vanessa, Valeria
  - `GG-EU-Ventes-Admins` : Valentin
  - `GG-EU-RH-Users` : Rene, Rebecca
  - `GG-EU-RH-Admins` : Richard
  - `GG-EU-Compta-Users` : Charles, Cindy
  - `GG-EU-Compta-Admins` : Charlotte




## 1. Modeles d'administration

#### 1.1. GPO-Restriction-PanneauConfig. Bloquer l'accès au Panneau de Configuration dans Ventes

Bloquer l'accès au Panneau de Configuration aux utilisateurs de Ventes

**Setting**: Config Utilisateur > Modèles d'administration > Panneau de configuration > Interdire l'accès


#### 1.2. GPO-Restriction-CMD. Bloquer l'accès à l'invite de commande

**Objectif** : Interdire aux utilisateurs de Ventes d'utiliser `cmd.exe`.

1.2.1. Appliquer la GPO uniquement à Ventes
1.2.2. Appliquer la GPO à Ventes et IT mais créer une exception pour le groupe "GG-EU-IT-Admins" (Créez le groupe si nécessaire)

**Setting**: Config Utilisateur > Modèles d'administration > Système > Empêcher l'accès à l'invite de commandes

## 2. Stratégies

#### 2.1. GPO-Configuration-MessageConnexion. Afficher message de connexion

Établir une GPO pour afficher un message corporatif lors de la connexion dans les ordinateurs de IT (ex: `Bienvenue sur le réseau ComputerElectronics. Rappel : les données d'IT sont confidentielles.`)

**Settings**: 

1. Config Ordinateur > Stratégies > Paramètres Windows > Paramètres de sécurité > Stratégies locales > Options de sécurité > Ouverture de session interactive: contenu du message 

2.  Config Ordinateur > Stratégies > Paramètres Windows > Paramètres de sécurité > Stratégies locales > Options de sécurité > Ouverture de session interactive: titre du message

#### 2.2. GPO-Blocage-Inactivite. Blocage de l'ordinateur après 5 minutes d'inactivité

2.2.1. Établir une GPO qui bloque tous les ordinateurs d'EU après 5 minutes d'inactivité (pour l'exercice, fixez 15 secondes pour ne pas devoir attendre autant)

Vous pouvez trouvez le paramètre dans la même section que l'exercice précédent... essayez de le trouvez par vous-même

2.2.2. Richard de RH ne supporte plus que le blocage...
Créez un groupe de sécurité contenant **son ordinateur** (on pourrait rajouter d'autres ordinateurs dans le futur). Les politiques de blocage pour inactivité sont appliquées à niveau d'ordinateurs, pas d'utilisateur.

Pour limiter l'impact de la GPO, vous pouvez débloquer l'application de la GPO sur l'ordinateur de Richard:
- Double Clic sur GPO > Délegation > Avancé > Ajouter 
- Pour que les ordinateurs soient visibles, il faut cliquer sur `Type d'objet` et cocher `Computers`
- Chercher l'ordinateur de Richard (ex: `ws-rh-01`)
- Clic sur `OK`
- Cliquez l'ordinateur dans la liste, puis allez dans les droits et cocher `Refuser` pour `Appliquer la strategie de groupe`


#### 2.3. GPO-Installation-Chrome. Déploiment de Chrome sur les ordinateurs de RH

Les utilisateurs de RH se sont mis d'accord et ils ont demandé de pouvoir utiliser Chrome sur leurs ordinateurs. L'admin veut automatiser la procedure.

Pour ce faire, tous les ordinateurs doivent avoir accès à un dossier partagé qui contienne Chrome. C'est très important que ce dossier partagé soit accésible que par les utilisateurs concernés car s'il est accesible par tout le monde les possibilités de hacking du serveur se multiplient.

2.3.1. Créer un dossier partagé `c:\Software` **sur le serveur**. 

Allez dans `Partage avancé` > `Utilisateurs` pour effacer l'accès de `Everyone` sur le dossier, et rajoutez: `Ordinateurs du domaine` et `Utilisateurs du domaine`.

Dans l'onglet `Permissions`, cliquez `Securité` > `Modifier` > `Ajouter` 
Rajoutez `Ordinateurs du domaine` et `Utilisateurs du domaine` et donnez les accès de `Affichage` , `Lecture` et `Lecture et execution`.

✅ **Résumé des permissions:**

| Caractéristique | Onglet Partage | Onglet Sécurité (NTFS) |
|-----------------|----------------|----------------------|
| S'applique à | Accès réseau uniquement | Accès local et réseau |
| Contrôle | Qui peut accéder au dossier partagé | Qui peut accéder aux fichiers/dossiers à l'intérieur |
| Emplacement | Onglet Partage → Permissions | Onglet Sécurité |
| Droits communs | Lecture / Modification / Contrôle total | Liste complète (Lecture, Écriture, Modification...) |
| Priorité | La plus restrictive l'emporte | La plus restrictive l'emporte |


On doit télécharger Chrome sur et le stocker dans le dossier partagé. Si vous n'avez pas l'internet:
1.  eteignez la machine 
2.  rajoutez un adaptateur réseau NAT
3.  redémarrez la machine

Concernant le partage: vous ne pouvez pas partager un dossier avec une OU... qu'est-ce que vous vient à l'esprit? Il y a une manière: créez un groupe de sécurité contenant le/les ordinateurs sur lesquels on veut appliquer la GPO pour installer Chrome

**Attention**: lors la création du groupe de sécurité vous allez devoir chercher les ordinateurs pour les rajouter. Pour pouvoir rechercher ces ordinateurs dans le AD, cliquez sur `Type d'objet` après avoir cliqué sur `Ajouter`.

Puis vous allez pouvoir appliquer la GPO sur l'OU des utilisateurs de RH: elle sera appliquée par héritage sur les ordinateurs de RH.

**Créons la GPO sur l'OU de RH**:

Stratégies > Paramètres du logiciel > Installation logiciel

Cliquez sur `Nouveau` et **tapez le chemin à la main** dans la barre de recherche.
Si vous tapez juste `dns1` et puis enter vous devriez voir les dossiers partagés du serveur. Puis selectionnez le fichier `chrome_installer.msi` (ou le nom du telechargement).

Important: Le chemin doit être un dans le format de réseau, c'est-à-dire `\dns1\Software\chrome_installer.msi`. Un chemin du type `C:\Software\chrome_installer.msi` ne fonctionnera pas.

**Exercice**: repetez l'exercice pour installer `7-zip`. Vous devez télécharger un installateur en format `.msi` sur le serveur et le mettre dans le dossier partagé `c:\Software`.



### 2.4. Créer d'un dossier partagé pour les utilisateurs d'IT et le faire apparaître sur leurs ordinateurs comme une unité de stockage (ex: F:, Z: ...)

1. Créer un dossier partagé `C:\Shares\IT-Admin` (suivez les instructions pour créer un dossier partagé du chapitre 5). Le but sera de le mapper sur les ordinateurs de RH (les utilisateurs veront ce dossier comme une unité de stockage F:, Z: ou le lettre de notre choix)
2. Dans notre cas, ce dossier partagé sera accessible par les utilisateurs administrateurs de RH. Modifiez les permissions du partage et NTFS    

Créez maintenant un GPO sur l'OU `IT`.

Allez dans Configuration Utilisateur > Préférences > Paramètres Windows

Faites clique droit > Nouveau.

Le chemin pour le dossier **doit être un chemin réseau**. Pas `C:\Shares\IT-Admin` mais `\\dns1\Shares\IT-Admin`

Qu'est-ce qu'on doit faire maintenant pour tester le fonctionnement de notre GPO?

**Variation de l'exercice:** Imaginez que le **mappage** du dossier partagé doit être caché et visible uniquement pour les utilisateurs administrateurs de IT.


## 3. Preferences

#### 3.1. GPO-LinkBureau. Créer une icone sur le Bureau de l'utilisateur pour les utilisateurs de Ventes
(Config Utilisateur > Préférences -> Paramètres Windows > Raccourcis > Nouveau > Définir l'adresse et l'emplacement). 

| Action choisie dans la GPO | Le lien revient s’il est supprimé ? | Quand ?                                              |
|----------------------------|--------------------------------------|------------------------------------------------------|
| **Create**                 | ❌ Non                               | Jamais                                               |
| **Update**                 | ❌ Non                               | Jamais                                               |
| **Replace**                | ✅ Oui                               | Au prochain `gpupdate`, redémarrage ou ouverture de session |
| **Delete**                 | 🔄 Supprime le lien (s’il existe)    | Lors de l'application de la GPO                      |


**Important**: pour ajuster le ciblage, clique droit sur le Raccourci créé et Propriétés > Commun > Ciblage

#### 3.2. Modifier la GPO pour qu'elle affecte uniquement au groupe d'admins de Ventes (pas au groupe des utilisateurs)

## 4. Créer des exceptions à la GPO

Eviter l'application d'une GPO sur un ordinateur ou un utilisateur en particulier

#### 4.1. Éviter la restriction du panneau de configuration sur les admin de Ventes



