# Exercices : GPO — série 1

### Prérequis

!!! warning "Configuration requise"

    - Structure AD créée avec [`creation_structure.ps1`](Labo/PowerShell-scriptsStructure/creation_structure.md) et membres des groupes ajoutés (voir [Configuration du laboratoire](Labo/Labo_structure.md)). Valeurs de référence : [Référence du lab Maxtec](Labo/Reference_Lab_Maxtec.md).
    - `ws-IT-01` joint au domaine **et déplacé** dans `OU=Computers,OU=IT,OU=EU`. Sans ce déplacement, aucune GPO de configuration ordinateur ne s'applique.
    - `ws-RH-01` (optionnel) dans `OU=Computers,OU=RH,OU=EU`. Sans second poste, déplacez temporairement `ws-IT-01` dans l'OU concernée pour les exercices qui visent les ordinateurs RH.

!!! info "Rappel des groupes"

    - `GG-EU-IT-Users` : Ivan, Ines — `GG-EU-IT-Admin` : Irene
    - `GG-EU-Ventes-Users` : Victor, Vanessa, Valeria — `GG-EU-Ventes-Admin` : Valentin
    - `GG-EU-RH-Users` : Rene, Rebecca — `GG-EU-RH-Admin` : Richard
    - `GG-EU-Compta-Users` : Charles, Cindy — `GG-EU-Compta-Admin` : Charlotte

!!! tip "Tester une GPO utilisateur sans poste Ventes"
    Une GPO de configuration **utilisateur** suit l'utilisateur, quel que soit le poste. Pour tester une GPO liée à `EU\Ventes\Users`, ouvrez simplement une session avec `vanessa` sur `ws-IT-01`.

## Exercice 1 : Modèles d'administration

### 1.1. GPO-Restriction-PanneauConfig. Bloquer l'accès au Panneau de Configuration dans Ventes

!!! example "Objectif"

    Bloquer l'accès au Panneau de configuration (et à l'application Paramètres) aux utilisateurs de Ventes.

!!! note "Si vous avez fait l'exemple du chapitre 8"
    Le chapitre 8 §2 a déjà créé `GPO-Panneau-Restreint`, liée à la même OU `EU\Ventes\Users`. Complétez cette GPO avec le paramètre ci-dessous au lieu d'en créer une seconde : deux GPOs sur la même OU pour le même sujet, c'est ce qu'on cherche à éviter en production.

!!! info "Configuration"

    **Paramètre** : Configuration utilisateur > Stratégies > Modèles d'administration > Panneau de configuration > **Interdire l'accès au Panneau de configuration et à l'application Paramètres du PC** = Activé

!!! info "Vérification"

    1. Sur `ws-IT-01`, ouvrez une session avec `vanessa`
    2. `gpupdate /force`, puis fermez et rouvrez la session
    3. `Win+R` > `control` : un message indique que l'opération est annulée en raison de restrictions
    4. `gpresult /r /scope user` : la GPO apparaît sous **Objets Stratégie de groupe appliqués**

??? success "Solution"

    1. `gpmc.msc` > clic droit sur `EU\Ventes\Users` > **Créer un objet GPO dans ce domaine, et le lier ici…** > nom `GPO-Restriction-PanneauConfig`
    2. Clic droit sur la GPO > **Modifier** > naviguez jusqu'au paramètre ci-dessus > **Activé** > OK
    3. Testez comme indiqué dans la vérification

    Création et liaison en PowerShell (le paramètre lui-même se règle dans l'éditeur, voir les règles du cours sur `Set-GPRegistryValue`) :

    ```powershell
    New-GPO -Name "GPO-Restriction-PanneauConfig" |
        New-GPLink -Target "OU=Users,OU=Ventes,OU=EU,DC=maxtec,DC=be"
    ```

### 1.2. GPO-Restriction-CMD. Bloquer l'accès à l'invite de commande

!!! example "Objectif"

    Interdire aux utilisateurs de Ventes d'utiliser `cmd.exe`.

!!! info "Étapes"

    1.2.1. Appliquer la GPO uniquement à Ventes

    1.2.2. Appliquer la GPO à Ventes et IT, mais créer une exception pour le groupe `GG-EU-IT-Admin`

!!! info "Configuration"

    **Paramètre** : Configuration utilisateur > Stratégies > Modèles d'administration > Système > **Désactiver l'accès à l'invite de commandes**

??? success "Solution"

    **1.2.1**

    1. `gpmc.msc` > clic droit sur `EU\Ventes\Users` > créez et liez `GPO-Restriction-CMD`
    2. Modifiez la GPO > paramètre ci-dessus > **Activé**. Laissez l'option qui désactive aussi le traitement des scripts sur `Non`, sinon les scripts d'ouverture de session `.bat`/`.cmd` ne tournent plus.
    3. Test : session `vanessa` sur `ws-IT-01`, `gpupdate /force`, fermer/rouvrir la session, lancer `cmd` → message "L'invite de commandes a été désactivée par votre administrateur".

    **1.2.2**

    1. Clic droit sur `EU\IT\Users` > **Lier un objet de stratégie de groupe existant…** > `GPO-Restriction-CMD`
    2. Sélectionnez la GPO > onglet **Délégation** > **Avancé…** > **Ajouter** `GG-EU-IT-Admin` > cochez **Refuser** pour **Appliquer la stratégie de groupe** > OK
    3. Test : `ivan` n'a plus `cmd`, `irene` l'a toujours.
    4. **Retour arrière** : une fois le test fait, clic droit sur le lien `GPO-Restriction-CMD` sous `EU\IT\Users` > décochez **Lien activé**. Les chapitres 10 et 11 utilisent des sessions `ivan` et ont besoin de `cmd`.

    ```powershell
    New-GPLink -Name "GPO-Restriction-CMD" -Target "OU=Users,OU=IT,OU=EU,DC=maxtec,DC=be"
    # Retour arriere apres le test
    Set-GPLink -Name "GPO-Restriction-CMD" -Target "OU=Users,OU=IT,OU=EU,DC=maxtec,DC=be" -LinkEnabled No
    ```

    Ce paramètre bloque `cmd.exe`, pas PowerShell. C'est une restriction de confort, pas une barrière de sécurité.

## Exercice 2 : Stratégies

### 2.1. GPO-Configuration-MessageConnexion. Afficher message de connexion

!!! example "Objectif"

    Établir une GPO pour afficher un message corporatif lors de la connexion sur les ordinateurs d'IT (ex : `Bienvenue sur le réseau Maxtec. Rappel : les données d'IT sont confidentielles.`)

!!! info "Paramètres"

    1. Config Ordinateur > Stratégies > Paramètres Windows > Paramètres de sécurité > Stratégies locales > Options de sécurité > Ouverture de session interactive : contenu du message

    2. Config Ordinateur > Stratégies > Paramètres Windows > Paramètres de sécurité > Stratégies locales > Options de sécurité > Ouverture de session interactive : titre du message

!!! info "Vérification"

    La GPO se lie à `EU\IT\Computers` (c'est une configuration **ordinateur**). Sur `ws-IT-01` : `gpupdate /force`, puis redémarrez. Le message s'affiche avant l'écran de connexion.

### 2.2. GPO-Blocage-Inactivite. Blocage de l'ordinateur après 5 minutes d'inactivité

!!! example "Objectif"

    2.2.1. Établir une GPO qui verrouille tous les ordinateurs d'EU après 5 minutes d'inactivité (pour l'exercice, fixez 15 secondes pour ne pas devoir attendre).

!!! tip "Conseil"

    Le paramètre se trouve dans la même section que l'exercice précédent.

!!! warning "Problème"

    2.2.2. Richard (RH) ne supporte plus le verrouillage.
    Créez un groupe de sécurité contenant **son ordinateur** (`ws-RH-01` ; d'autres ordinateurs pourront y être ajoutés plus tard) et excluez ce groupe de la GPO. Le verrouillage pour inactivité est un paramètre **ordinateur** : l'exception doit porter sur l'ordinateur, pas sur l'utilisateur.

??? success "Solution"

    **2.2.1**

    1. Créez `GPO-Blocage-Inactivite` et liez-la à l'OU `EU` (elle s'applique par héritage à toutes les OUs `Computers` en dessous)
    2. Paramètre : Configuration ordinateur > Stratégies > Paramètres Windows > Paramètres de sécurité > Stratégies locales > Options de sécurité > **Ouverture de session interactive : limite d'inactivité de l'ordinateur** = `15` secondes (en production : `300`)
    3. `gpupdate /force` sur le poste, redémarrez, attendez 15 s sans toucher : la session se verrouille

    **2.2.2**

    1. Dans `dsa.msc`, créez le groupe global de sécurité `GG-EU-Computers-SansVerrouillage` dans `EU\RH\Groups`
    2. Ajoutez-y `ws-RH-01` : **Ajouter** > **Types d'objets** > cochez **Ordinateurs** > recherchez `ws-RH-01`
    3. Dans GPMC, sélectionnez `GPO-Blocage-Inactivite` > onglet **Délégation** > **Avancé…** > **Ajouter** `GG-EU-Computers-SansVerrouillage` > **Refuser** pour **Appliquer la stratégie de groupe**
    4. **Redémarrez `ws-RH-01`** : un ordinateur ne voit sa nouvelle appartenance à un groupe qu'après avoir obtenu un nouveau ticket Kerberos, donc au redémarrage. `gpupdate /force` seul ne suffit pas.

    ```powershell
    New-ADGroup -Name "GG-EU-Computers-SansVerrouillage" -GroupScope Global -GroupCategory Security -Path "OU=Groups,OU=RH,OU=EU,DC=maxtec,DC=be"
    Add-ADGroupMember "GG-EU-Computers-SansVerrouillage" -Members (Get-ADComputer ws-RH-01)
    ```

    Sans `ws-RH-01`, faites l'exercice avec `ws-IT-01`.

    **Retour arrière (obligatoire)** : la GPO est liée à toute l'OU `EU`. Si vous la laissez à 15 s, `ws-IT-01` se verrouille toutes les 15 secondes pour le reste de la semaine.

    1. Modifiez `GPO-Blocage-Inactivite` et remettez la valeur normale (`300` secondes), ou désactivez son lien sur `EU` (clic droit sur le lien > décochez **Lien activé**)
    2. Si vous avez utilisé `ws-IT-01` à la place de `ws-RH-01`, retirez-le de `GG-EU-Computers-SansVerrouillage`, puis redémarrez-le

    ```powershell
    Set-GPLink -Name "GPO-Blocage-Inactivite" -Target "OU=EU,DC=maxtec,DC=be" -LinkEnabled No
    Remove-ADGroupMember "GG-EU-Computers-SansVerrouillage" -Members (Get-ADComputer ws-IT-01) -Confirm:$false
    ```

### 2.3. GPO-Installation-Chrome. Déploiement de Chrome sur les ordinateurs de RH

!!! example "Contexte"

    Les utilisateurs de RH ont demandé à pouvoir utiliser Chrome. L'administrateur veut automatiser l'installation.

!!! warning "Sécurité"

    Tous les ordinateurs concernés doivent avoir accès à un dossier partagé qui contient l'installateur. Ce dossier ne doit être accessible qu'aux ordinateurs concernés (et aux administrateurs) : un dossier de logiciels accessible à tous est un vecteur d'attaque classique.

!!! info "Étape 2.3.1 - Création du groupe d'ordinateurs"

    La GPO s'applique à des **ordinateurs** : on veut installer Chrome sur les postes RH, quel que soit l'utilisateur.
    Le plus propre est de créer un groupe de sécurité contenant les ordinateurs de RH.

    - Ouvrez `Utilisateurs et ordinateurs Active Directory` sur le serveur
    - Créez un groupe de sécurité global pour les ordinateurs de RH (un seul pour l'instant : `ws-RH-01`). Ex : `GG-EU-RH-Computers-Chrome`
    - Pour ajouter des ordinateurs au groupe, cliquez sur `Types d'objets` dans la fenêtre de recherche et cochez `Ordinateurs`
    - Recherchez `ws-RH-01` et cliquez sur `Ajouter`

!!! tip "Avantage"

    Ce groupe reçoit les permissions sur le dossier partagé qui contient l'installateur. Pour installer Chrome sur un autre ordinateur, il suffira de l'ajouter au groupe.

!!! info "Étape 2.3.2 - Création du dossier partagé"

    Créez le dossier `C:\Shares\Software` **sur le serveur** et partagez-le sous le nom `Software`.

    Dans `Partage avancé` > `Autorisations` : supprimez `Tout le monde` et ajoutez, en **Lecture** :

    - `GG-EU-RH-Computers-Chrome`
    - `Administrateurs` (pour parcourir le dossier pendant la configuration de la GPO)

    Dans l'onglet `Sécurité` > `Modifier` > `Ajouter` : `GG-EU-RH-Computers-Chrome` avec **Lecture et exécution**.

!!! note "Note importante"

    Vous pouvez ajouter `GG-EU-RH-Admin` et `GG-EU-RH-Users` pour afficher le contenu depuis le poste client pendant les tests, mais ce n'est pas nécessaire. **L'installation se fait au démarrage, sous le compte de l'ordinateur** : seuls les ordinateurs doivent lire le `.msi`.

!!! example "Téléchargement de Chrome"

    Téléchargez Chrome et placez-le dans le dossier partagé. Si le serveur n'a pas d'accès Internet :

    1. Éteignez la machine dans VirtualBox
    2. Ajoutez un adaptateur réseau NAT (adapter 2)
    3. Redémarrez la machine (retirez l'adaptateur une fois le téléchargement terminé)

    Allez sur https://chromeenterprise.google/download/

    Choisissez le **Bundle** ou directement l'installateur **.msi** 64 bits.

    Copiez le `.msi` dans `C:\Shares\Software`.

!!! info "Application de la GPO"

    La GPO se lie à l'OU des ordinateurs de RH (`EU\RH\Computers`).

!!! example "Création de la GPO sur l'OU des ordinateurs de RH"

    Allez dans `Configuration ordinateur > Stratégies > Paramètres du logiciel > Installation de logiciel`

    Clic droit > `Nouveau` > `Package…`, puis **saisissez le chemin RÉSEAU** dans la barre d'adresse. Méthode de déploiement : **Attribué**.

!!! warning "Important"

    Le chemin doit être au format réseau : `\\dns1\Software\chrome_installer.msi`. Un chemin local du type `C:\Shares\Software\chrome_installer.msi` ne fonctionnera pas : il n'existe pas sur le poste client.

    (Remplacez `chrome_installer.msi` par le nom du fichier téléchargé, ou renommez-le.)

!!! info "Étape 2.3.3 - Test de la GPO"

    Sur `ws-RH-01` (ou `ws-IT-01` déplacé temporairement dans `EU\RH\Computers` et ajouté au groupe), exécutez `gpupdate /force`. Un message indique que l'installation de logiciel nécessite un redémarrage.

!!! success "Étape 2.3.4 - Installation"

    Redémarrez l'ordinateur. Chrome s'installe au démarrage, avant l'écran de connexion. Si rien ne se passe, cherchez les erreurs dans l'Observateur d'événements > Journaux Windows > Application (sources `Application Management Group Policy` et `MsiInstaller`).

!!! warning "Retour arrière si vous avez utilisé `ws-IT-01`"
    Remettez `ws-IT-01` dans son OU d'origine et retirez-le du groupe Chrome, puis redémarrez-le. Sinon il reçoit les GPOs ordinateur de RH et plus celles d'IT pour la suite du cours.

    ```powershell
    Get-ADComputer ws-IT-01 | Move-ADObject -TargetPath "OU=Computers,OU=IT,OU=EU,DC=maxtec,DC=be"
    Remove-ADGroupMember "GG-EU-RH-Computers-Chrome" -Members (Get-ADComputer ws-IT-01) -Confirm:$false
    ```

!!! example "Exercice supplémentaire"

    Répétez l'exercice pour installer `7-Zip`. Téléchargez l'installateur `.msi` et placez-le dans `C:\Shares\Software`.


!!! success "Résumé des permissions"

    | Caractéristique | Onglet Partage | Onglet Sécurité (NTFS) |
    |-----------------|----------------|----------------------|
    | S'applique à | Accès réseau uniquement | Accès local et réseau |
    | Contrôle | Qui peut accéder au dossier partagé | Qui peut accéder aux fichiers/dossiers à l'intérieur |
    | Emplacement | Partage avancé → Autorisations | Onglet Sécurité |
    | Droits | Lecture / Modifier / Contrôle total | Liste complète (Lecture, Écriture, Modification…) |
    | Plusieurs groupes | Les autorisations se cumulent ; un Refuser l'emporte | Les autorisations se cumulent ; un Refuser explicite l'emporte |

    **Combinaison des deux** (accès par le réseau) : Windows calcule le résultat du partage et le résultat NTFS séparément, puis retient **le plus restrictif des deux**.

## Exercice 3 : Préférences

### 3.1. GPO-LinkBureau. Créer une icône sur le Bureau pour les utilisateurs de Ventes

!!! info "Configuration"

    Configuration utilisateur > Préférences > Paramètres Windows > Raccourcis > Nouveau > Raccourci. Renseignez le nom, le type de cible (URL ou objet du système de fichiers), la cible et l'emplacement (`Bureau`).

!!! example "Tableau des actions des préférences (GPP)"

    Les préférences sont réappliquées à chaque rafraîchissement de stratégie (ouverture de session, `gpupdate`, rafraîchissement périodique), sauf si l'option **Appliquer une fois et ne pas réappliquer** est cochée dans l'onglet `Commun`.

    | Action | Si l'élément n'existe pas | Si l'élément existe | Le raccourci revient-il s'il est supprimé ? |
    |--------|---------------------------|---------------------|---------------------------------------------|
    | **Créer** | Il est créé | Rien n'est modifié | Oui, au rafraîchissement suivant |
    | **Mettre à jour** | Il est créé | Les propriétés configurées sont mises à jour | Oui, au rafraîchissement suivant |
    | **Remplacer** | Il est créé | Il est supprimé puis recréé | Oui, au rafraîchissement suivant |
    | **Supprimer** | Rien | Il est supprimé | — |

    L'option **Supprimer cet élément lorsqu'il n'est plus appliqué** (onglet `Commun`) retire l'élément quand la GPO ou le ciblage ne s'applique plus à l'utilisateur. Elle force l'action `Remplacer`.

!!! tip "Ciblage"

    Pour limiter la préférence à certains utilisateurs : clic droit sur le raccourci > Propriétés > Commun > Ciblage au niveau de l'élément.

??? success "Solution"

    1. Créez `GPO-LinkBureau` et liez-la à `EU\Ventes\Users`
    2. Modifiez-la > Configuration utilisateur > Préférences > Paramètres Windows > **Raccourcis** > clic droit > **Nouveau > Raccourci**
    3. Action `Mettre à jour`, Nom `Intranet Maxtec`, Type de cible `URL`, Emplacement `Bureau`, URL cible `https://www.maxtec.be` (ou toute autre adresse)
    4. Test : session `vanessa` sur `ws-IT-01`, `gpupdate /force` → le raccourci apparaît sur le Bureau. Supprimez-le, relancez `gpupdate /force` : il revient.

!!! note "Pour aller plus loin"

    Pour restreindre l'application du raccourci aux seuls responsables de Ventes (sans déplacer le lien de la GPO), voir l'exercice **Item-level targeting** dans [Exercices : GPO-3](./Exercices:%20GPO-3.md).

## Exercice 4 : Préférences — mappage de lecteur réseau

### 4.1. GPO-Mappage-IT-Admin. Faire apparaître un dossier partagé comme lecteur réseau (ex : Z:)

!!! example "Objectif"

    1. Créer le dossier partagé `C:\Shares\IT-Admin` (voir la création d'un dossier partagé au chapitre 7 §5). Le but est de le mapper sur les sessions d'IT (les utilisateurs verront ce dossier comme un lecteur `Z:` ou la lettre de votre choix).
    2. Ce partage est réservé aux responsables d'IT (`GG-EU-IT-Admin`). Réglez les permissions de partage et NTFS en conséquence.

!!! info "Configuration de la GPO"

    Créez une GPO liée à l'OU `EU\IT\Users`.

    Configuration utilisateur > Préférences > Paramètres Windows > Mappages de lecteurs > clic droit > Nouveau > Lecteur mappé.

    Le chemin est le **chemin réseau** du partage : pas `C:\Shares\IT-Admin` mais `\\dns1\IT-Admin` (visible dans les propriétés du dossier, onglet `Partage`).

!!! question "Question de réflexion"

    Que faut-il faire pour tester la GPO ? Avec quel utilisateur ?

!!! example "Variante"

    Le lecteur ne doit apparaître **que** pour les responsables d'IT. Ivan et Ines ne doivent même pas le voir.

??? success "Solution"

    **Partage et permissions**

    1. Créez `C:\Shares\IT-Admin`, partagez-le sous le nom `IT-Admin`
    2. Partage avancé > Autorisations : retirez `Tout le monde`, ajoutez `GG-EU-IT-Admin` en **Modifier** et `Administrateurs` en **Contrôle total**
    3. Sécurité : désactivez l'héritage (convertir en autorisations explicites), retirez `Utilisateurs`, ajoutez `GG-EU-IT-Admin` en **Modification**

    **GPO**

    1. Créez `GPO-Mappage-IT-Admin` liée à `EU\IT\Users`
    2. Mappages de lecteurs > Nouveau > Lecteur mappé : Action `Mettre à jour`, Emplacement `\\dns1\IT-Admin`, cochez **Reconnecter**, Libellé `IT-Admin`, lettre `Z:`

    **Test** : session `irene` sur `ws-IT-01`, `gpupdate /force`, fermez et rouvrez la session. `Z:` apparaît dans `Ce PC` et est accessible. Avec `ivan`, le mappage échoue (accès refusé au partage) : la GPO s'applique à toute l'OU et ce sont les permissions qui bloquent. Ça fonctionne, mais ce n'est pas propre : d'où la variante.

    **Variante** : onglet `Commun` du lecteur mappé > **Ciblage au niveau de l'élément** > Groupe de sécurité `GG-EU-IT-Admin` (même mécanique que [GPO-3 Ex. 2.1](./Exercices:%20GPO-3.md)). Une alternative moins fine est le filtrage de sécurité de la GPO entière.
