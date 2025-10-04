# Configuration du Laboratoire GPO

## Infrastructure du Laboratoire

Pour réaliser les exercices de GPO, vous utiliserez un environnement de laboratoire simplifié comprenant :

* Un contrôleur de domaine (dns1.maxtec.be, 192.168.0.2)
* Une machine cliente avec Windows 10/11 Professionnel (qui deviendra, par exemple, `ws-IT-01.maxtec.be`)

Cet environnement est une version simplifiée de l'infrastructure complète, qui dans un contexte d'entreprise inclurait des zones géographiques (eu/us) et des environnements (dev/prod).

## Conventions de Nommage

* Postes de travail : ws-[dept]-[##].maxtec.be
* Groupes globaux : GG-[Nom]
* Groupes locaux de domaine : DL-[Nom]
* Utilisateurs : prenom.nom

## Prérequis Techniques

### Préparation

Avant de commencer, assurez-vous d'avoir la structure complète de l'AD (si ce n'est pas le cas, lancez le script de Powershell - dossier PowerShell -> creation_structure).

1. Ce script n'est pas destructif. Il vérifie l'existence des OUs, des groupes et des utilisateurs avant de les créer.
2. Vous devez créer sur votre serveur (dans n'importe quel dossier, mais le dossier `c:\Scripts` est recommandé pour une meilleure organisation) un fichier texte (clic droit) et le nommer `creation_structure.ps1`.  
   > 💡 Le script à utiliser se trouve ici : [Scripts de création](../Labo/PowerShell-scriptsStructure/creation_structure.md)
3. Confirmez le changement d'extension.
4. Collez le script (de gitbook) dans le fichier `creation_structure.ps1`. Enregistrez le fichier.
5. Ouvrez une console powershell dans ce dossier (barre d'adresse, tapez **powershell** et puis Enter)
6. Dans certains cas on a de problèmes pour lancer de scripts (signatures). Nous allons enlever les restrictions pour pouvoir lancer notre script
```powershell
Set-ExecutionPolicy Bypass -Scope CurrentUser   # No restrictions (not recommended long-term)
Set-ExecutionPolicy Unrestricted -Scope CurrentUser
```
7. Lancez le script
```powershell
.\creation_structure.ps1
```

Puis, pour pratiquer:
- Créez la OU pour le département IT (si elle n'existe pas encore) 
- Créez aussi un groupe pour les administrateurs de IT (ex: "GG-EU-IT-Admins") et un autre pour les utilisateurs (ex: "GG-EU-IT-Users"). 
- Assurez-vous d'avoir un ordinateur (Virtual Machine client) qui porte le nom `ws-IT-01` et un autre `ws-RH-01`. Si ce n'est pas le cas, modifiez les noms des ordinateurs dans vos machines virtuelles et re-démarrez-les.
- Dans le serveur, allez dans `Utilisateurs et ordinateurs AD` et rajoutez des utilisateurs aux groupes (s'ils n'existent pas, créez-les): 
  - `GG-EU-IT-Users` : Ivan, Ines
  - `GG-EU-IT-Admins` : Irene
  - `GG-EU-Ventes-Users` : Victor, Vanessa, Valeria
  - `GG-EU-Ventes-Admins` : Valentin
  - `GG-EU-RH-Users` : Rene, Rebecca
  - `GG-EU-RH-Admins` : Richard
  - `GG-EU-Compta-Users` : Charles, Cindy
  - `GG-EU-Compta-Admins` : Charlotte



## Installation d'un adaptateur réseau extra pour avoir l'internet (si besoin)

1.  eteignez la machine 
2.  rajoutez un adaptateur réseau "pont"
3.  redémarrez la machine

## Installation des VirtualBox Guest Additions (pour pouvoir copier-coller et glisser-deposer)

Nous devons installer une extension de VirtualBox pour permettre le copier-coller et le glisser-déposer de fichiers entre la machine hôte et la machine virtuelle. Cette étape est nécessaire car nous créerons des scripts sur la machine hôte qui devront être transférés vers la machine virtuelle.

Suivez cette procédure :

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
  
## Configuration du Presse-papiers Partagé

Pour permettre l'échange de données entre votre machine hôte et la machine virtuelle :

1. Configuration du presse-papiers :
   * Dans la fenêtre de la machine virtuelle, accédez au menu `Périphériques`
   * Sélectionnez `Presse-papiers partagé` > `Bidirectionnel`
   * Cette option permet le copier-coller de texte dans les deux sens

2. Configuration du glisser-déposer :
   * Dans le même menu `Périphériques`
   * Sélectionnez `Glisser-déposer` > `Bidirectionnel`
   * Cette option permet le transfert de fichiers entre les deux systèmes

## Vérification des Transferts

Pour vérifier que la configuration fonctionne correctement :

1. Sur la machine hôte :
   * Téléchargez une image de test depuis Internet
   * Repérez-la dans votre dossier `Téléchargements`

2. Sur la machine virtuelle :
   * Ouvrez le Bureau (Desktop)
   * Effectuez un glisser-déposer de l'image depuis la machine hôte
   * Vérifiez que le fichier a été correctement transféré

## Script de Configuration de la Structure AD

Pour créer automatiquement la structure des Unités d'Organisation (UO), vous utiliserez le script [`creation_structure.ps1`](./PowerShell-scriptsStructure/creation_structure.md). Ce script ne crée pas les ordinateurs, car ceux-ci doivent être ajoutés au domaine depuis les machines virtuelles clientes. Cette procédure ne peut pas être exécutée depuis le serveur.

1. Consultez le contenu du script `creation_structure.ps1` sur GitBook
2. Copiez le contenu (CTRL+A puis CTRL+C)
3. Accédez à la VM du serveur
4. Dans l'Explorateur de fichiers, cliquez sur "Affichage" dans la barre supérieure
5. Activez l'option `Extensions des noms de fichiers`
6. Créez un dossier `Scripts` dans `C:\` et accédez-y
7. Créez un fichier texte (clic droit) et nommez-le `creation_structure.ps1`. Confirmez le changement d'extension

Nous venons de créer un fichier de script PowerShell vide. Nous allons maintenant l'éditer avec PowerShell ISE, l'éditeur intégré à Windows Server.

8. Ouvrez Windows PowerShell ISE (depuis la barre des tâches)
9. Sélectionnez Fichier > Ouvrir et naviguez vers `C:\Scripts\creation_structure.ps1`
10. Collez le contenu précédemment copié et enregistrez le fichier

**Vous disposez maintenant d'un script qui créera la structure des Unités d'Organisation (UO) dans Active Directory (OUs, groupes, utilisateurs)** La structure sera complète, à l'exception des ordinateurs. Les groupes seront créés, mais leurs membres devront être ajoutés ultérieurement.

**Important** : Ce script respecte votre structure existante et ajoute uniquement les éléments du laboratoire. Avant de l'exécuter, il est recommandé de :
* Déplacer les utilisateurs existants vers le conteneur Users
* Supprimer les groupes existants

**Attention** :

- La suppression d'un groupe n'affecte pas les utilisateurs qui en étaient membres
- La suppression d'une UO entraîne la suppression de tout son contenu

