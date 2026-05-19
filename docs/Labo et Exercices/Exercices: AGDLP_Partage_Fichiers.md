# Exercices: Application Concrète d'AGDLP — Partage de Fichiers Ventes

!!! info "🎯 Contexte"

    Le département **Ventes** de **maxtec.be** demande un partage de fichiers commun pour stocker propositions commerciales, contrats et catalogues. La direction veut appliquer **strictement** la stratégie Microsoft **AGDLP** :

    **A**ccounts → **G**lobal Groups → **D**omain **L**ocal Groups → **P**ermissions

    Les groupes globaux du département existent déjà (créés par le script du labo : `GG-EU-Ventes-Users`, `GG-EU-Ventes-Admin`, `GG-EU-IT-Admin`). Votre travail consiste à créer les **groupes Domain Local**, à les imbriquer correctement avec les groupes globaux, puis à appliquer les **permissions NTFS** sur le partage.

    Cet exercice se réalise **entièrement depuis l'interface graphique** (consoles MMC et Explorateur de fichiers). Aucune ligne de PowerShell n'est nécessaire.

    **Prérequis** :

    - Le script `creation_structure.ps1` a été exécuté avec succès.
    - Vous disposez d'un accès administrateur sur le serveur (DC ou serveur de fichiers — pour le lab, le DC peut héberger le partage).
    - Consoles utilisées : **Utilisateurs et ordinateurs Active Directory** (`dsa.msc`), **Explorateur de fichiers**, **Gestion de l'ordinateur** (`compmgmt.msc`).

---

## 1. 🔹 Rappel théorique — Pourquoi AGDLP ?

!!! abstract "À retenir"

    Sans AGDLP, on est tenté d'attribuer les permissions NTFS directement à des utilisateurs ou à des groupes globaux. Le jour où un autre département a besoin du même accès, ou qu'une personne change de service, il faut **rééditer chaque permission** sur la ressource. Avec AGDLP :

    - Les **groupes globaux** (`GG-`) reflètent l'**organisation humaine** (qui appartient à quoi).
    - Les **groupes domain local** (`DL-`) reflètent les **rôles d'accès à une ressource** (qui peut faire quoi sur cette ressource).
    - Les **permissions NTFS** ne sont posées **que sur les groupes DL**.

    Résultat : pour donner à un nouveau département l'accès au partage Ventes, il suffit d'**ajouter son groupe global au DL** approprié dans la console AD. Aucune ACL n'est touchée.

---

## 2. 🔹 Cahier des charges

!!! example "Spécifications fournies par la direction"

    Le partage `\\<DC>\Ventes-Documents` doit offrir trois niveaux d'accès :

    | Rôle d'accès | Qui doit l'avoir | Permissions NTFS attendues |
    |---|---|---|
    | **Lecture seule** | Tous les utilisateurs Ventes | Lecture & exécution |
    | **Modification** | Encadrement Ventes | Modification (lecture + écriture + suppression de ses fichiers) |
    | **Contrôle total** | Administrateurs IT | Contrôle total (maintenance, sauvegarde) |

    Contraintes techniques :

    - Chemin physique : `C:\Partages\Ventes-Documents` (créer le dossier si besoin).
    - Nom de partage SMB : `Ventes-Documents`.
    - Permissions de partage SMB : `Everyone = Modifier` (la sécurité réelle est portée par NTFS).
    - Aucun utilisateur ne doit être ajouté **nominativement** aux ACL ni aux groupes DL.

---

## 3. 🔹 Identifier les groupes nécessaires

!!! example "Tâche à réaliser"

    Avant de cliquer où que ce soit dans les consoles, complétez le tableau de correspondance ci-dessous **sur papier ou dans un document**. C'est l'étape la plus importante de l'exercice : si la table est juste, le reste suit mécaniquement.

    | Groupe Domain Local à créer | Permissions NTFS portées | Groupes Globaux à imbriquer dedans |
    |---|---|---|
    | `DL-Ventes-Documents-Lecture` | ? | ? |
    | `DL-Ventes-Documents-Modification` | ? | ? |
    | `DL-Ventes-Documents-ControleTotal` | ? | ? |

    !!! tip "Indice"

        Les groupes globaux existants sont : `GG-EU-Ventes-Users`, `GG-EU-Ventes-Admin`, `GG-EU-IT-Admin`. Pensez aussi au **principe du droit minimum** : un manager doit-il avoir « modification » seulement, ou aussi « lecture » ?

---

## 4. 🔹 Créer l'OU et les groupes Domain Local

!!! example "Tâches à réaliser dans `dsa.msc`"

    1. Ouvrir **Utilisateurs et ordinateurs Active Directory**.
    2. Clic droit sur `OU=EU` → **Nouveau** → **Unité d'organisation** → nom : `Resources`. **Décocher** la protection contre la suppression accidentelle.
    3. Clic droit sur la nouvelle OU `Resources` → **Nouveau** → **Unité d'organisation** → nom : `Groups`. Décocher également la protection.
    4. Naviguer dans `EU > Resources > Groups`. Pour chacun des trois groupes ci-dessous, faire clic droit → **Nouveau** → **Groupe**, puis renseigner :

        | Nom du groupe | Étendue | Type | Description |
        |---|---|---|---|
        | `DL-Ventes-Documents-Lecture` | **Domaine local** | Sécurité | Lecture seule sur le partage Ventes-Documents |
        | `DL-Ventes-Documents-Modification` | **Domaine local** | Sécurité | Modification sur le partage Ventes-Documents |
        | `DL-Ventes-Documents-ControleTotal` | **Domaine local** | Sécurité | Contrôle total sur le partage Ventes-Documents |

    5. Pour ajouter la description : double-clic sur le groupe → onglet **Général** → champ **Description** → **Appliquer**.

    !!! warning "Attention au scope"

        Dans la boîte de dialogue de création, l'étendue par défaut est **Global**. Vous devez explicitement cocher **Domaine local** avant de valider — c'est l'erreur la plus fréquente de l'exercice.

---

## 5. 🔹 Imbriquer les groupes globaux dans les DL

!!! example "Tâches à réaliser dans `dsa.msc`"

    Appliquez la table de correspondance de l'étape 3. Pour chaque groupe DL :

    1. Double-clic sur le groupe DL (ex. `DL-Ventes-Documents-Lecture`).
    2. Onglet **Membres** → **Ajouter…**.
    3. Saisir le nom du groupe global (ex. `GG-EU-Ventes-Users`) → **Vérifier les noms** → **OK**.
    4. Vérifier que l'icône à gauche du membre ajouté est bien une **icône de groupe** (deux têtes) et non une icône d'utilisateur.

    **À ce stade de l'exercice**, chaque DL contient un seul membre, qui est un groupe global. Ce n'est pas une règle générale : un DL peut tout à fait contenir **plusieurs GG** lorsque plusieurs populations partagent le même niveau d'accès sur la ressource (par exemple Ventes + Comptabilité en lecture). C'est exactement ce que vous ferez à l'étape 8.

    !!! danger "Erreur classique à éviter"

        N'ajoutez **aucun utilisateur** directement dans un groupe DL. Si vous êtes tenté de le faire, c'est que la structure de groupes globaux est incomplète — créez d'abord le bon `GG-`, puis imbriquez-le.

---

## 6. 🔹 Créer le partage et appliquer les permissions NTFS

!!! example "Tâches à réaliser dans l'Explorateur de fichiers"

    **a) Créer le dossier**

    1. Ouvrir l'Explorateur de fichiers sur le DC, naviguer dans `C:\`.
    2. Créer un dossier `Partages` (s'il n'existe pas), puis à l'intérieur un dossier `Ventes-Documents`.

    **b) Désactiver l'héritage et nettoyer les permissions**

    1. Clic droit sur `Ventes-Documents` → **Propriétés** → onglet **Sécurité** → bouton **Avancé**.
    2. Cliquer sur **Désactiver l'héritage**.
    3. Dans la boîte qui s'affiche, choisir **Convertir les autorisations héritées en autorisations explicites**.
    4. Sélectionner et **Supprimer** les entrées suivantes :
        - `Utilisateurs (MAXTEC\Utilisateurs)`
        - `Utilisateurs authentifiés`
        - Toute autre entrée hors `SYSTEM` et `Administrateurs`.
    5. Conserver `SYSTEM` (Contrôle total) et `Administrateurs` (Contrôle total) — ce sont les comptes locaux de la machine, indispensables au système.
    6. **OK** pour fermer la boîte Avancé, **OK** pour les Propriétés.

    **c) Ajouter les groupes DL avec les bonnes permissions**

    1. Retour dans **Propriétés** → **Sécurité** → bouton **Modifier…**.
    2. Pour chaque DL, cliquer sur **Ajouter…**, saisir le nom, **Vérifier les noms**, **OK**, puis cocher les permissions selon le tableau :

        | Principal | Permissions à cocher |
        |---|---|
        | `MAXTEC\DL-Ventes-Documents-Lecture` | Lecture et exécution, Affichage du contenu du dossier, Lecture |
        | `MAXTEC\DL-Ventes-Documents-Modification` | Modification (les Lectures se cochent automatiquement) |
        | `MAXTEC\DL-Ventes-Documents-ControleTotal` | Contrôle total |

    3. **Appliquer** → **OK**.

    **d) Partager le dossier en SMB**

    1. Toujours dans **Propriétés** → onglet **Partage** → bouton **Partage avancé…**.
    2. Cocher **Partager ce dossier**. Nom de partage : `Ventes-Documents`.
    3. Bouton **Autorisations** :
        - Sélectionner `Everyone`.
        - Cocher **Modifier** (la case Lecture se coche aussi).
    4. **OK** → **OK** → **Fermer**.

    !!! tip "Rappel — Permissions SMB vs NTFS"

        Quand un utilisateur accède à un partage, c'est l'**intersection** des permissions SMB et NTFS qui s'applique (la plus restrictive gagne). En posant `Everyone = Modifier` côté SMB, on délègue toute la granularité à NTFS — c'est la pratique recommandée.

---

## 7. 🔹 Tester l'accès

!!! example "Tests à effectuer depuis un poste client joint au domaine"

    Connectez-vous successivement avec **plusieurs utilisateurs** et vérifiez le comportement attendu. Depuis l'Explorateur de fichiers, saisir dans la barre d'adresse : `\\<nom-du-DC>\Ventes-Documents`.

    | Connexion en tant que | Action testée | Résultat attendu |
    |---|---|---|
    | **sophie** (Ventes — Users) | Ouvrir un fichier du partage | OK |
    | **sophie** | Créer un nouveau fichier | ❌ Refusé |
    | **valentin** (Ventes — Admin) | Créer / modifier un fichier | OK |
    | **valentin** | Modifier les permissions du dossier | ❌ Refusé |
    | **irene** (IT — Admin) | Modifier les permissions, supprimer le dossier | OK |
    | **charlotte** (Comptabilité) | Ouvrir le partage | ❌ Refusé (aucun groupe d'accès) |

    !!! tip "Conseil pratique"

        Entre deux tests, **fermez la session** Windows ou redémarrez la machine cliente — sinon l'ancien ticket Kerberos peut masquer l'effet d'un changement d'appartenance de groupe. Côté serveur, vous pouvez aussi rafraîchir les groupes avec un `gpupdate /force` dans une invite admin.

---

## 8. 🔹 Démontrer la valeur d'AGDLP

!!! example "Scénario d'extension"

    La direction décide que le département **Comptabilité** doit avoir un accès en **lecture** au partage Ventes (pour vérifier les contrats facturés).

    !!! question "À vous"

        **Sans ouvrir l'Explorateur de fichiers ni toucher au dossier `Ventes-Documents`**, quelle est la seule opération à effectuer dans `dsa.msc` ? Réalisez-la, puis re-testez avec **charlotte** : elle doit désormais pouvoir lire le partage (après fermeture / réouverture de session).

---

## 9. 🔹 Vérification finale (GUI)

!!! example "Contrôles à faire dans les consoles"

    **a) Dans `dsa.msc`** — onglet `Affichage > Fonctionnalités avancées` activé :

    1. Naviguer dans `EU > Resources > Groups` : les 3 groupes `DL-Ventes-Documents-*` doivent être présents.
    2. Double-clic sur chacun → onglet **Général** : vérifier **Étendue = Domaine local** et **Type = Sécurité**.
    3. Onglet **Membres** de chaque DL : un seul membre, **avec une icône de groupe** (pas d'utilisateur).

    **b) Dans l'Explorateur de fichiers** :

    1. Clic droit sur `C:\Partages\Ventes-Documents` → **Propriétés** → **Sécurité** → **Avancé**.
    2. La liste doit contenir uniquement : `SYSTEM`, `Administrateurs`, et les 3 `DL-Ventes-Documents-*`. Pas de `GG-`, pas d'utilisateurs nominatifs, pas de `Utilisateurs authentifiés`.
    3. Onglet **Partage** : le partage `Ventes-Documents` est actif, autorisations SMB = `Everyone : Modifier`.

    **c) Onglet « Accès effectif » (vérification croisée)** :

    1. **Propriétés** du dossier → **Sécurité** → **Avancé** → onglet **Accès effectif**.
    2. **Sélectionner un utilisateur** → taper `sophie` → **Afficher l'accès effectif**.
    3. Vérifier : `Lecture` autorisée, `Écriture` non autorisée.
    4. Recommencer avec `valentin` (Écriture autorisée, Modification des autorisations non) et `irene` (tout autorisé).

!!! success "Critères de réussite"

    - [ ] L'OU `Resources/Groups` existe sous `OU=EU,...`
    - [ ] Les 3 groupes `DL-Ventes-Documents-*` existent avec scope **DomainLocal**, catégorie **Security**
    - [ ] Chaque DL ne contient **que des groupes globaux**, **aucun utilisateur direct**
    - [ ] Le dossier `C:\Partages\Ventes-Documents` est partagé en SMB sous le nom `Ventes-Documents`
    - [ ] Les ACL NTFS contiennent les 3 DL avec les bons droits, **et aucun GG- ni utilisateur direct**
    - [ ] Tous les tests utilisateurs de l'étape 7 donnent le résultat attendu
    - [ ] L'extension de l'étape 8 a été réalisée **sans toucher aux ACL**

---

??? success "💡 Solution complète"

    ### Étape 3 — Table de correspondance corrigée

    | Groupe Domain Local | Permissions NTFS | Groupes Globaux imbriqués |
    |---|---|---|
    | `DL-Ventes-Documents-Lecture` | Lecture & exécution | `GG-EU-Ventes-Users` |
    | `DL-Ventes-Documents-Modification` | Modification | `GG-EU-Ventes-Admin` |
    | `DL-Ventes-Documents-ControleTotal` | Contrôle total | `GG-EU-IT-Admin` |

    **Pourquoi pas ajouter `GG-EU-Ventes-Admin` au DL de Lecture aussi ?** Inutile : la permission **Modification** inclut déjà Lecture. Ajouter le même GG aux deux DL alourdit la maintenance sans rien apporter et trouble la lisibilité.

    ### Étape 4 — Création des OUs et groupes (`dsa.msc`)

    1. `dsa.msc` ouvert en administrateur.
    2. Clic droit `OU=EU` → **Nouveau** → **Unité d'organisation** → `Resources` → décocher « Protéger… » → **OK**.
    3. Clic droit sur `Resources` → **Nouveau** → **Unité d'organisation** → `Groups` → décocher « Protéger… » → **OK**.
    4. Pour chaque DL :
        - Clic droit dans `Groups` → **Nouveau** → **Groupe**.
        - Nom de groupe : `DL-Ventes-Documents-Lecture` (puis les deux autres).
        - **Étendue du groupe** : sélectionner **Domaine local** (radio button).
        - **Type de groupe** : laisser **Sécurité**.
        - **OK**.
        - Double-clic sur le groupe → champ **Description** → saisir la description → **Appliquer** → **OK**.

    ### Étape 5 — Imbrication des GG dans les DL (`dsa.msc`)

    Pour chaque DL :

    1. Double-clic sur le DL → onglet **Membres** → **Ajouter…**.
    2. Saisir le nom du GG (`GG-EU-Ventes-Users` pour Lecture, `GG-EU-Ventes-Admin` pour Modification, `GG-EU-IT-Admin` pour Contrôle total) → **Vérifier les noms** → **OK**.
    3. **Appliquer** → **OK**.

    Vérification visuelle : le seul membre listé doit afficher une icône représentant **deux têtes** (groupe), pas une seule (utilisateur).

    ### Étape 6 — Dossier, NTFS, partage (Explorateur)

    **Création du dossier** : `C:\Partages\Ventes-Documents` (créer `Partages` d'abord si nécessaire).

    **Désactivation de l'héritage et nettoyage** :

    1. Clic droit sur `Ventes-Documents` → **Propriétés** → **Sécurité** → **Avancé**.
    2. Bouton **Désactiver l'héritage** → choisir **Convertir les autorisations héritées en autorisations explicites**.
    3. Sélectionner les entrées non souhaitées (`Utilisateurs`, `Utilisateurs authentifiés`, `CREATEUR PROPRIETAIRE` éventuellement) → **Supprimer**.
    4. Garder uniquement `SYSTEM` et `Administrateurs` (chacun en Contrôle total).
    5. **OK** pour fermer Avancé.

    **Ajout des 3 DL** (onglet **Sécurité** → bouton **Modifier**) :

    1. **Ajouter** → taper `DL-Ventes-Documents-Lecture` → **Vérifier les noms** → **OK**. Dans le panneau des permissions, cocher **Lecture et exécution** (cela coche automatiquement « Affichage du contenu » et « Lecture »).
    2. **Ajouter** → `DL-Ventes-Documents-Modification` → **OK**. Cocher **Modification** (« Lecture et exécution » se cochent automatiquement).
    3. **Ajouter** → `DL-Ventes-Documents-ControleTotal` → **OK**. Cocher **Contrôle total**.
    4. **Appliquer** → **OK**.

    **Création du partage SMB** :

    1. Propriétés du dossier → onglet **Partage** → bouton **Partage avancé…**.
    2. Cocher **Partager ce dossier**. Nom : `Ventes-Documents`.
    3. **Autorisations** → sélectionner `Everyone` → cocher **Modifier** → **OK**.
    4. **OK** → **Fermer**.

    ### Étape 7 — Comportement attendu lors des tests

    Le piège classique : un utilisateur qui change de groupe ne voit pas le changement immédiatement parce qu'il garde son **ticket Kerberos** de la session en cours. Solution : fermer la session, ou redémarrer le poste client. Sur des labs, le plus simple est de toujours faire `Démarrer > Déconnecter` entre deux tests.

    ### Étape 8 — Extension Comptabilité (la beauté d'AGDLP)

    **Une seule opération, dans `dsa.msc` seulement** :

    1. Naviguer dans `EU > Resources > Groups`.
    2. Double-clic sur `DL-Ventes-Documents-Lecture` → onglet **Membres** → **Ajouter…**.
    3. Saisir `GG-EU-Comptabilite-Users` → **Vérifier les noms** → **OK** → **Appliquer**.

    **C'est tout** : aucune ACL touchée, aucun passage par l'Explorateur de fichiers, aucun redémarrage du serveur de fichiers. Après reconnexion de **charlotte** sur le poste client, elle accède en lecture au partage.

    **C'est tout le point d'AGDLP** : la ressource (NTFS) est figée, l'organisation (qui accède à quoi) vit dans l'annuaire.

---

## 10. 🔹 Étude de cas complémentaire — Partage « Factures »

!!! info "🎯 Nouveau scénario"

    La direction financière demande un partage `Factures` pour centraliser les factures clients et fournisseurs. Trois départements sont concernés, avec **deux niveaux d'accès seulement** :

    | Rôle d'accès | Qui doit l'avoir | Justification métier |
    |---|---|---|
    | **Lecture seule** | Encadrement **RH** | Vérification des notes de frais et remboursements aux salariés |
    | **Modification** | Encadrement **Comptabilité** + Encadrement **Ventes** | La Compta saisit les factures fournisseurs, les Ventes émettent les factures clients |

    Contraintes :

    - Chemin : `C:\Partages\Factures`, nom de partage SMB : `Factures`, SMB = `Everyone : Modifier`.
    - Les groupes DL doivent être créés dans l'OU `Resources/Groups` déjà en place.
    - Aucun utilisateur direct, aucun groupe global dans les ACL NTFS.

### Réflexion préalable

!!! question "À discuter avant de cliquer"

    **a)** Pourquoi seulement deux DL et non trois (un par département) ?

    **b)** Le niveau « Contrôle total » a-t-il sa place ici ? Si oui pour qui, si non pourquoi ?

    **c)** Un comptable doit-il pouvoir modifier les permissions NTFS de la carpeta `Factures` ?

### Tâches à réaliser

!!! example "Mise en œuvre (réutiliser les conventions de l'exercice principal)"

    1. Créer le dossier `C:\Partages\Factures` et le partager en SMB sous le nom `Factures` (`Everyone : Modifier`).
    2. Dans `OU=Groups,OU=Resources,OU=EU,...`, créer deux groupes **Domain Local de sécurité** :
        - `DL-Factures-Lecture`
        - `DL-Factures-Modification`
    3. Imbriquer les groupes globaux :
        - `GG-EU-RH-Admin` → dans `DL-Factures-Lecture`
        - `GG-EU-Comptabilite-Admin` **et** `GG-EU-Ventes-Admin` → tous les deux dans `DL-Factures-Modification`
    4. Sur `C:\Partages\Factures`, désactiver l'héritage, nettoyer, et ajouter les deux DL avec respectivement **Lecture & exécution** et **Modification**.
    5. Tester depuis un poste client avec :
        - **richard** (RH-Admin) → doit lire mais pas écrire.
        - **charlotte** (Comptabilité-Admin) → doit lire et écrire.
        - **valentin** (Ventes-Admin) → doit lire et écrire.
        - **sophie** (Ventes-Users, pas Admin) → ne doit **rien voir**.

??? success "💡 Solution & points pédagogiques"

    **Réponses aux questions de réflexion**

    **a) Deux DL et non trois ?** Parce qu'un DL représente un **niveau d'accès sur la ressource**, pas un département. Compta et Ventes ont strictement le même besoin (Modification), donc un seul DL suffit pour les deux. C'est précisément le levier d'AGDLP : la granularité métier (qui appartient à quoi) reste dans les GG, la granularité de permissions reste dans les DL.

    **b) Contrôle total ?** Non pour les départements métier. Le Contrôle total permet de modifier les ACL, prendre la propriété, supprimer la racine du dossier — ce sont des opérations d'administration de la ressource, pas de production de factures. Si un besoin de Contrôle total existe (sauvegarde, restauration, maintenance), on créerait un troisième DL `DL-Factures-ControleTotal` réservé à `GG-EU-IT-Admin`, comme dans l'exercice principal.

    **c) Modifier les permissions ?** Non. Un comptable doit pouvoir écrire **dans** la carpeta, pas réécrire **les règles** de la carpeta. C'est exactement la différence entre `Modify` et `Full Control` côté NTFS.

    **Convention de nommage**

    Vous aurez peut-être vu en cours des noms comme `DL-Lecture-Factures` (niveau d'abord). Les deux ordres fonctionnent, mais `DL-<Ressource>-<Niveau>` est généralement préféré en production : lorsqu'on trie l'OU Groups par ordre alphabétique, tous les DL d'une même ressource se regroupent visuellement. Sur 30 partages avec 2 à 3 niveaux chacun, ça change la lisibilité de la console.

    **Réalisation pas à pas**

    Même procédure GUI qu'aux étapes 4 à 6 de l'exercice principal :

    - `dsa.msc` → créer les 2 DL dans `Resources/Groups` (étendue **Domaine local**, type **Sécurité**, description claire).
    - Onglet **Membres** du DL Lecture → ajouter `GG-EU-RH-Admin`.
    - Onglet **Membres** du DL Modification → ajouter `GG-EU-Comptabilite-Admin`, puis cliquer à nouveau **Ajouter** et ajouter `GG-EU-Ventes-Admin`. Le DL doit contenir **les deux** GG.
    - Explorateur → `C:\Partages\Factures` → Propriétés → Sécurité → Avancé → Désactiver héritage → Convertir → supprimer `Utilisateurs` et `Utilisateurs authentifiés`.
    - Onglet Sécurité → Modifier → Ajouter `DL-Factures-Lecture` (Lecture & exécution) puis `DL-Factures-Modification` (Modification).
    - Onglet Partage → Partage avancé → cocher → nom `Factures` → Autorisations → `Everyone : Modifier`.

    **Vérification par accès effectif** :

    Propriétés du dossier → Sécurité → Avancé → onglet **Accès effectif** → sélectionner un utilisateur :

    | Utilisateur testé | Lecture | Écriture | Modifier les permissions |
    |---|---|---|---|
    | `richard` (RH-Admin) | ✅ | ❌ | ❌ |
    | `charlotte` (Compta-Admin) | ✅ | ✅ | ❌ |
    | `valentin` (Ventes-Admin) | ✅ | ✅ | ❌ |
    | `sophie` (Ventes-Users) | ❌ | ❌ | ❌ |

    **Ce que ce cas ajoute par rapport à l'exercice principal**

    - Démonstration que **plusieurs GG cohabitent dans un même DL dès la conception** (et pas seulement comme une extension a posteriori).
    - Décision consciente **Modification vs Contrôle total** : éviter le réflexe « Full Control par défaut » qui reste l'une des erreurs les plus fréquentes en environnement Windows.
    - Vérification finale par **Accès effectif**, l'outil GUI qui donne une réponse définitive à la question « cet utilisateur peut-il faire ceci ? ».

---

## Pour aller plus loin

!!! abstract "AGUDLP — version multi-domaines"

    Si demain `maxtec.be` ouvre une filiale `US` dans la même forêt, et que le partage doit être accessible depuis les deux zones, on insère un **groupe Universel** entre les GG et les DL :

    **A**ccount → **G**lobal → **U**niversal → **D**omain Local → **P**ermission

    Exemple : `U-Marketing-Users` contiendrait `GG-EU-Marketing-Users` et `GG-US-Marketing-Users`, et c'est ce groupe Universel qu'on ajouterait au DL de la ressource partagée. Toute la mise en place se fait également depuis `dsa.msc`.
