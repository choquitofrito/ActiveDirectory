# 🔹 Solutions GPO - Niveau 1 (Débutant)

## 1. 🎯 Solutions des exercices de configuration GPO



### Solution 1.1 - Message de connexion pour les Ventes
1. Ouvrir la Console de gestion des stratégies de groupe (GPMC)
2. Dans l'arborescence, naviguer vers la forêt → Domaines → maxtec.be → EU → Ventes
3. Clic droit sur l'OU Ventes → Créer un GPO et le lier ici
4. Nommer le GPO : `GPO-Message-Ventes`
5. Éditer le GPO :
   - Configuration ordinateur → Stratégies → Paramètres Windows → Paramètres de sécurité → Stratégies locales → Options de sécurité
   - Double-cliquer sur "Message texte pour les utilisateurs tentant de se connecter"
   - Entrer le message : "Poste de la Ventes - Usage Restreint"
6. Fermer l'éditeur de stratégie de groupe
7. Sur ws-ventes-01 :
   ```
   gpupdate /force
   ```
8. Se déconnecter et se reconnecter pour voir le message

### Solution 1.3 - Sécurité de base EU
1. Dans GPMC, naviguer vers l'OU EU
2. Créer un nouveau GPO nommé `GPO-Securite-EU`
3. Éditer le GPO :
   - Configuration ordinateur → Stratégies → Paramètres Windows → Paramètres de sécurité → Stratégies de compte → Stratégie de mot de passe
   - Configurer :
     * "Les mots de passe doivent respecter des exigences de complexité" → Activé
     * "Longueur minimale du mot de passe" → 8 caractères
     * "Nombre de mots de passe mémorisés" → 3
4. Appliquer avec :
   ```
   gpupdate /force
   ```

### Solution 1.5 - Scripts pour Ventes
1. Créer le script logon.bat :
   ```batch
   @echo off
   echo %date% > "%userprofile%\Desktop\derniere_connexion.txt"
   ```
2. Dans GPMC, créer `GPO-Scripts-Ventes` sur l'OU Ventes
3. Éditer le GPO :
   - Configuration utilisateur → Stratégies → Paramètres Windows → Scripts
   - Double-cliquer sur "Ouverture de session"
   - Ajouter → Parcourir → Copier le script logon.bat
   - Sélectionner le script
4. Tester avec :
   ```
   gpupdate /force
   ```

### Solution 1.6 - Mappage lecteurs Comptabilité

#### Prérequis
1. Créer le dossier c:\Shares\Ventes-Docs, partagez-le avec les permissions de base
2. Allez dans Utilisateurs et Ordinateurs AD
3. Clique droite sur l'OU Ventes et Nouveau > Dossier Partage



#### Configuration du GPO
1. Créer `GPO-Lecteurs-Compta` sur l'OU Comptabilité
2. 


### Solution 1.7 - Restrictions Menu Démarrer Ventes
1. Créer `GPO-MenuDemarrer-Ventes` sur l'OU Ventes
2. Éditer :
   - Configuration utilisateur → Stratégies → Modèles d'administration → Menu Démarrer et Barre des tâches
   - "Supprimer la commande Exécuter du menu Démarrer" → Activé
   - "Empêcher l'accès à l'invite de commandes" → Activé
3. Tester sur ws-ventes-02 avec gpupdate /force

### Solution 1.9 - Restrictions USB Comptabilité
1. Créer `GPO-USB-Compta` sur l'OU Comptabilité
2. Éditer :
   - Configuration ordinateur → Stratégies → Modèles d'administration → Système → Accès au stockage amovible
   - "Périphériques de stockage amovibles : Refuser l'accès en lecture et en écriture" → Activé
3. Tester sur ws-compta-01 avec gpupdate /force

### Solution 1.10 - Explorateur pour Ventes
1. Créer `GPO-Explorateur-Ventes` sur l'OU Ventes
2. Éditer :
   - Configuration utilisateur → Stratégies → Modèles d'administration → Composants Windows → Explorateur de fichiers
   - "Masquer ces lecteurs spécifiés dans Poste de travail" → Activé → C:
   - "Masquer tous les outils de gestion du système d'exploitation" → Activé
3. Vérifier sur ws-ventes-02 avec gpupdate /force

## 📝 Points de vérification pour chaque GPO
1. Ouvrez une console
2. Vérifier l'application avec :
   ```
   gpresult /r
   ```
3. Tester la GPO sur un poste cible
5. Documenter tout problème dans un fichier de suivi

Ce commande montre uniquement les stratégies d'utilisateur.

Pour vérifier les stratégies ordinateur:

1. Ouvrez une console en tant qu'administrateur (click droit)
2. Lancez 
```
   gpresult /r /scope computer
```   


Si la GPO n'est pas appliquée, confirmez (dans le serveur) que "Authenticated Users" a au moins les droits "Read"


## ⚠️ Résolution des problèmes courants
- Si une GPO ne s'applique pas, vérifier :
  * Les droits "Authenticated Users"
  * La délégation des permissions
  * Les filtres WMI ou de sécurité
  * Les liens d'héritage
- Utiliser GPRESULT et l'observateur d'événements pour le dépannage
