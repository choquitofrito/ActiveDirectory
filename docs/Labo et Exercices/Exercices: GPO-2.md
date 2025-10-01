## Exercice 5: Restreindre la connexion aux ordinateurs d’un département


L’entreprise veut renforcer la sécurité en empêchant les utilisateurs d’un département d’utiliser les ordinateurs d’un autre.

**Dans ce laboratoire, tu dois configurer les ordinateurs de l’OU "IT\Computers"** pour qu’**uniquement les utilisateurs de IT\Users** puissent s’y connecter.

Pensez à comment faire ça. Astuce: on doit profiter des groupes existants dans IT et créer une GPO qui affecte les ordinateurs. 

Vu que chercher dans les GPOs est une folie, voici la section de la GPO que tu dois configurer:

Configuration ordinateur > Stratégies > Paramètres Windows > Paramètres de sécurité > Stratégies locales > Attribution des droits utilisateur > Permettre l'ouverture de session locale


#### Prérequis

!!! warning "Prérequis pour l'exercice"

- Une OU principale : `EU`
- Une sous-OU `IT`, contenant :
  - `IT\Users` : utilisateurs du département IT
  - `IT\Computers` : ordinateurs du département IT
- Trois utilisateurs créés dans `IT\Users` : `ines`, `irene`, `ivan`
- Un utilisateur d'un autre département : `victor` dans `EU\Ventes\Users`
- Un ordinateur joint au domaine dans `IT\Computers` : `ws-IT-01` (dans l'idéel deux ordinateurs si vous êtes à l'aise pour changer le nom d'un ordinateur ou pour créer une autre VM)




## Exercice 6: (Scripts) Nettoyage automatique du dossier Téléchargements à chaque démarrage

Cette GPO va permettre de nettoyer le dossier Téléchargements de l'utilisateur à chaque démarrage de session, pour maintenir les postes propres. Apliquez la sur l'OU des utilisateurs de RH

**Nom** de la GPO : Nettoyage-Telechargements-Demarrage

**Objectif** : Supprimer tous les fichiers du dossier Téléchargements de l'utilisateur à chaque démarrage de session, pour maintenir les postes propres.

**Niveau ciblé** : Utilisateur, pas Ordinateur

**Script** : PowerShell

**Chemin du script** : **C:\Windows\SYSVOL\domain\scripts**
L'admin créera le script à l'intérieur du dossier `scripts`. 

Contenu du script : créez un nouveau document de texte `nettoyage_telechargements.ps1` et copiez ce contenu:

```powershell
$shell = New-Object -ComObject Shell.Application
$downloads = $shell.Namespace('shell:Downloads').Self.Path
Remove-Item "$downloads\*" -Recurse -Force -ErrorAction SilentlyContinue
```

On doit créer un GPO qui lance ce script au démarrage de session des utilisateurs ciblés.

**Setting**: Le paramètre à configurer est : `Configuration utilisateur > Stratégies > Paramètres Windows > Scripts (ouverture de session)
Attention à rajouter le script dans la section des script PowerShell!

Le script doit se lancer dans la fermeture de session. 
Cliquez et chercher le script sur le disque dur mais **utilisez un chemin de réseau**  dans la configuration!`\\dns1\SYSVOL\maxtec.be\scripts`. ATTENTION AU CHEMIN!!! pas `C:\Windows\SYSVOL\domain\scripts`!

 
