# Configuration du Laboratoire GPO

## Infrastructure du Laboratoire

Pour réaliser les exercices de GPO, vous utiliserez un environnement de laboratoire simplifié comprenant :

* Un contrôleur de domaine (dns1.computerelectronics.be, 192.168.0.2)
* Une machine cliente avec Windows 10/11 Professionnel (qui deviendra, par exemple, `ws-IT-01.computerelectronics.be`)

Cet environnement est une version simplifiée de l'infrastructure complète, qui dans un contexte d'entreprise inclurait des zones géographiques (eu/us) et des environnements (dev/prod).

## Conventions de Nommage

* Postes de travail : ws-[dept]-[##].computerelectronics.be
* Groupes globaux : GG-[Nom]
* Groupes locaux de domaine : DL-[Nom]
* Utilisateurs : prenom.nom

## Prérequis Techniques


## Installation d'un adaptateur réseau extra pour avoir l'internet (si besoin)

1.  eteignez la machine 
2.  rajoutez un adaptateur réseau NAT
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

Pour créer automatiquement la structure des Unités d'Organisation (UO), vous utiliserez le script `creation_structure.ps1`. Ce script ne crée pas les ordinateurs, car ceux-ci doivent être ajoutés au domaine depuis les machines virtuelles clientes. Cette procédure ne peut pas être exécutée depuis le serveur.

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

