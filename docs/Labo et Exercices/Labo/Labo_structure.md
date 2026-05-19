# Configuration du Laboratoire GPO

## Infrastructure du Laboratoire

Pour réaliser les exercices de GPO, vous utiliserez un environnement de laboratoire simplifié comprenant :

* Un contrôleur de domaine (dns1.maxtec.be, 192.168.0.2)
* Une machine cliente avec Windows 10/11 Professionnel (qui deviendra, par exemple, `ws-IT-01.maxtec.be`)

Cet environnement est une version simplifiée de l'infrastructure complète, qui dans un contexte d'entreprise inclurait des zones géographiques (eu/us) et des environnements (dev/prod).

## Conventions de Nommage

* Postes de travail : ws-[dept]-[##].maxtec.be
* Groupes globaux : GG-[Nom]
* Utilisateurs : prenom.nom

## Préparation de la VM

### Adaptateur réseau pour accéder à Internet (si besoin)

1. Éteignez la machine
2. Ajoutez un adaptateur réseau en mode `pont`
3. Redémarrez la machine

### Installation des VirtualBox Guest Additions

Cette extension permet le copier-coller et le glisser-déposer entre la machine hôte et la VM. Nécessaire pour transférer le script PowerShell depuis votre poste vers le serveur.

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

1. Consultez le contenu du script `creation_structure.ps1` sur le site du cours et copiez-le (`CTRL+A` puis `CTRL+C`)
2. Accédez à la VM du serveur
3. Dans l'Explorateur de fichiers, onglet `Affichage` > activez `Extensions des noms de fichiers`
4. Créez un dossier `Scripts` dans `C:\` et accédez-y
5. Clic droit > Nouveau > Document texte, nommez-le `creation_structure.ps1` et confirmez le changement d'extension
6. Ouvrez Windows PowerShell ISE (en mode Administrateur)
7. Fichier > Ouvrir > `C:\Scripts\creation_structure.ps1`
8. Collez le contenu copié et enregistrez

### Exécuter le script

Lancez le script depuis PowerShell ISE. Il vous demandera de confirmer chaque étape (OUs, utilisateurs, groupes).

À la fin, vous disposerez de :

* L'OU racine `EU` avec les départements `Ventes`, `RH`, `Comptabilite` et `IT`
* Les utilisateurs répartis dans leurs OUs respectives
* Les groupes globaux `GG-EU-[Dept]-Admin` et `GG-EU-[Dept]-Users`

**Les membres des groupes ne sont pas ajoutés automatiquement** — c'est l'objet de la pratique ci-dessous.

## Pratique : assigner les utilisateurs aux groupes

- Assurez-vous d'avoir une VM cliente nommée `ws-IT-01` et une autre `ws-RH-01`. Si ce n'est pas le cas, renommez vos VMs et redémarrez-les.
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
