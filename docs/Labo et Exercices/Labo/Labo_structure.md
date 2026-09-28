# Configuration du Laboratoire GPO

!!! info "Source de vérité"
    Noms, adresses, utilisateurs, groupes et partages du lab : **[Référence du lab Maxtec](Reference_Lab_Maxtec.md)**. En cas de contradiction avec une autre page, c'est elle qui fait foi.

## Infrastructure du Laboratoire

Pour réaliser les exercices de GPO, vous utiliserez un environnement de laboratoire simplifié comprenant :

* Un contrôleur de domaine : `dns1.maxtec.be` (192.168.0.2)
* Un poste client Windows 10 Professionnel **obligatoire** : `ws-IT-01.maxtec.be` (192.168.0.10)
* Un second poste client **optionnel** : `ws-RH-01.maxtec.be` (192.168.0.11). Certains exercices (GPO appliquée à un département et pas à l'autre, profils itinérants) sont plus parlants avec deux postes ; sans lui, vous pouvez déplacer `ws-IT-01` d'une OU à l'autre.

Cet environnement est une version simplifiée de l'infrastructure complète, qui dans un contexte d'entreprise inclurait des zones géographiques (eu/us) et des environnements (dev/prod).

## Conventions de Nommage

* Postes de travail : ws-[dept]-[##].maxtec.be
* Groupes globaux : GG-[Nom]
* Utilisateurs : login = prénom en minuscules (`vanessa`, `irene`…), UPN `prenom@maxtec.be`

## Préparation de la VM

### Adaptateur réseau pour accéder à Internet (si besoin)

1. Éteignez la machine
2. Ajoutez un deuxième adaptateur réseau en mode `NAT` (Configuration > Réseau > Carte 2)
3. Redémarrez la machine, faites vos téléchargements
4. Éteignez la machine, retirez la carte NAT, redémarrez

!!! warning "Carte NAT temporaire, jamais en permanence sur le DC"
    Le DC ne doit garder qu'une carte réseau, sur le réseau interne (voir la [référence du lab](Reference_Lab_Maxtec.md)) : avec deux cartes, il enregistre ses deux adresses dans DNS et les clients tombent au hasard sur la mauvaise. Retirez la carte NAT dès les téléchargements terminés.

    N'utilisez pas le mode `pont` : il expose la VM directement sur le réseau de l'école, avec un DC et un serveur DNS qui répondent aux autres machines de la salle.

### Installation des VirtualBox Guest Additions

Permet le copier-coller et le glisser-déposer entre l'hôte et la VM, pratique pour transférer le script PowerShell vers le serveur.

1. Démarrage :
    * Lancez VirtualBox
    * Démarrez votre machine virtuelle serveur

2. Montage du CD virtuel :
    * Dans la fenêtre de la machine virtuelle
    * Menu `Périphériques` > `Lecteurs optiques`
    * Sélectionnez `VBoxGuestAdditions`

3. Installation :
    * Connectez-vous au serveur
    * Ouvrez `Ce PC`
    * Accédez au lecteur CD
    * Double-cliquez sur `VBoxGuestAdditions`
    * Suivez l'assistant d'installation
    * Redémarrez lorsque demandé

### Configuration du Presse-papiers Partagé

1. Presse-papiers :
    * Dans la fenêtre de la VM, menu `Périphériques`
    * Sélectionnez `Presse-papiers partagé` > `Bidirectionnel`

2. Glisser-déposer :
    * Même menu `Périphériques`
    * Sélectionnez `Glisser-déposer` > `Bidirectionnel`

### Vérification

1. Sur la machine hôte : téléchargez une image de test
2. Sur la VM : effectuez un glisser-déposer de l'image vers le Bureau. Le fichier doit être correctement transféré.

## Création de la Structure AD

Vous utiliserez le script [`creation_structure.ps1`](./PowerShell-scriptsStructure/creation_structure.md) pour créer automatiquement les OUs, utilisateurs et groupes globaux. Le script **ne crée pas les ordinateurs** : ceux-ci doivent rejoindre le domaine depuis les VMs clientes.

Le script est **idempotent** : il vérifie l'existence de chaque élément avant de le créer, donc vous pouvez le relancer sans erreur.

### Préparer le fichier sur le serveur

1. Sur la VM du serveur, dans l'Explorateur de fichiers, onglet `Affichage` > activez `Extensions des noms de fichiers`
2. Créez un dossier `Scripts` dans `C:\`
3. Récupérez le script depuis la [page du script](./PowerShell-scriptsStructure/creation_structure.md), bouton **Télécharger creation_structure.ps1**. Deux possibilités :
    * **Depuis la VM**, si elle a accès à Internet : ouvrez la page dans le navigateur de la VM et cliquez sur le bouton. Si le navigateur signale que ce type de fichier peut être dangereux, choisissez de **conserver** le fichier. Déplacez ensuite le fichier de `Téléchargements` vers `C:\Scripts`.
    * **Depuis la machine hôte** : téléchargez le fichier sur l'hôte, puis faites-le glisser dans `C:\Scripts` sur la VM (glisser-déposer configuré ci-dessus).
4. Vérifiez le nom du fichier dans `C:\Scripts` : exactement `creation_structure.ps1`. Si vous avez téléchargé deux fois, le navigateur a pu l'appeler `creation_structure (1).ps1` : renommez-le.
5. **Débloquez le fichier** : clic droit sur `creation_structure.ps1` > **Propriétés** > onglet **Général**. En bas, si la ligne *Sécurité : Ce fichier provient d'un autre ordinateur…* apparaît, cochez **Débloquer** > **OK**. Si la ligne n'apparaît pas, il n'y a rien à faire.
6. Ouvrez Visual Studio Code (extension PowerShell) ou, à défaut, Windows PowerShell ISE, **en tant qu'administrateur**
7. Ouvrez `C:\Scripts\creation_structure.ps1`

!!! warning "Pourquoi débloquer ?"
    Windows marque les fichiers venus d'Internet. La stratégie d'exécution par défaut de Windows Server (`RemoteSigned`) refuse de lancer un script marqué qui n'est pas signé. Sans l'étape 5, vous obtenez : *Impossible de charger le fichier C:\Scripts\creation_structure.ps1… n'est pas signé numériquement*. Débloquez le fichier et relancez.

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    Unblock-File -Path C:\Scripts\creation_structure.ps1
    ```

??? note "Pas de téléchargement possible ? Créer le fichier par copier-coller"
    1. Sur la [page du script](./PowerShell-scriptsStructure/creation_structure.md), copiez le code avec le bouton de copie du bloc
    2. Dans `C:\Scripts`, clic droit > Nouveau > Document texte, nommez-le `creation_structure.ps1` et confirmez le changement d'extension
    3. Ouvrez-le dans VS Code ou PowerShell ISE (en administrateur), collez le code et enregistrez
    4. Dans VS Code, enregistrez en **UTF-8 avec BOM** pour que les accents s'affichent correctement (détails sur la page du script). Un fichier créé ainsi n'a pas besoin d'être débloqué.

### Exécuter le script

Lancez le script (F5 dans VS Code ou ISE). Il demande une confirmation à chaque étape (OUs, utilisateurs, groupes, membres).

À la fin, vous disposerez de :

* L'OU racine `EU` avec les départements `Ventes`, `RH`, `Comptabilite` et `IT`
* Les utilisateurs répartis dans leurs OUs respectives
* Les groupes globaux `GG-EU-[Dept]-Admin` et `GG-EU-[Dept]-Users`

L'étape 5 du script (**ajout des membres aux groupes**) est optionnelle. Répondez `N` pour la faire à la main avec la pratique ci-dessous : c'est recommandé la première fois, c'est le geste que vous referez le plus souvent en exploitation. Répondez `O` si vous reconstruisez le lab et voulez aller vite.

## Placer les postes dans leur OU

Quand un poste rejoint le domaine, son objet ordinateur arrive dans le conteneur `CN=Computers`. Ce n'est pas une OU : **aucune GPO liée à une OU ne s'y applique**. Tant que vous n'avez pas déplacé les postes, aucune GPO de configuration ordinateur des exercices ne fonctionnera.

Après la jonction au domaine :

- `ws-IT-01` → `OU=Computers,OU=IT,OU=EU,DC=maxtec,DC=be`
- `ws-RH-01` → `OU=Computers,OU=RH,OU=EU,DC=maxtec,DC=be`

Sur `dns1`, dans **Utilisateurs et ordinateurs Active Directory** :

1. Dépliez `maxtec.be` > **Computers**.
2. Clic droit sur `WS-IT-01` > **Déplacer…** > `EU` > `IT` > `Computers` > **OK**.
3. Même chose pour `WS-RH-01` vers `EU` > `RH` > `Computers`, si vous avez ce poste.
4. Vérifiez (touche **F5**) que chaque poste apparaît dans sa nouvelle OU.

**En PowerShell** (aperçu, vu au chapitre 9) :

```powershell
Get-ADComputer ws-IT-01 | Move-ADObject -TargetPath "OU=Computers,OU=IT,OU=EU,DC=maxtec,DC=be"
Get-ADComputer ws-RH-01 | Move-ADObject -TargetPath "OU=Computers,OU=RH,OU=EU,DC=maxtec,DC=be"
```

Redémarrez ensuite le poste (ou `gpupdate /force`) pour qu'il prenne en compte sa nouvelle position.

## Pratique : assigner les utilisateurs aux groupes

- Assurez-vous que votre VM cliente s'appelle `ws-IT-01` (et la seconde, si vous l'avez, `ws-RH-01`). Sinon, renommez-la et redémarrez-la.
- Dans le serveur, ouvrez `Utilisateurs et ordinateurs Active Directory` et ajoutez les utilisateurs aux groupes correspondants :
    - `GG-EU-IT-Users` : Ivan, Ines
    - `GG-EU-IT-Admin` : Irene
    - `GG-EU-Ventes-Users` : Victor, Vanessa, Valeria
    - `GG-EU-Ventes-Admin` : Valentin
    - `GG-EU-RH-Users` : Rene, Rebecca
    - `GG-EU-RH-Admin` : Richard
    - `GG-EU-Compta-Users` : Charles, Cindy
    - `GG-EU-Compta-Admin` : Charlotte

**Attention** :

- La suppression d'un groupe n'affecte pas les utilisateurs qui en étaient membres
- La suppression d'une UO entraîne la suppression de tout son contenu
