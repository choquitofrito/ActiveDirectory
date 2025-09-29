# 🔹 Exercices GPO - Niveau 1 (Débutant)


Pour chaque exercice, vous devez penser:
- Où l'appliquer?
- Quel type de GPO est-ce ?
- Quelle est la configuration?
Après la configuration, vous devez la tester!


## 1. 🎯 Configuration de base des GPOs

### Exercice 1.1 - Message de connexion pour le departement de Ventes
1. Créer une GPO nommée `GPO-Message-Ventes` qui affiche un message de connexion quand on se connecte **à un ordinateur** de la Ventes (Astuce: les paramètres se trouvent dans la stratégie `Ouverture de Session Interactive: Titre du message` et `Ouverture de Session Interactive: Contenu du message`). C'est un paramètre de stratégie locale de sécurité de Windows
2. Tester sur ws-ventes-01

### Exercice 1.6 - Mappage lecteurs Comptabilité
1. Créer une GPO nommée `GPO-Lecteurs-Compta`
2. Configurer :
   - Mappage du lecteur S: vers \\serveur\compta
3. Appliquer à l'OU Comptabilité

### Exercice 1.5 - Scripts pour Ventes
1. Créer une GPO nommée `GPO-Scripts-Ventes`
2. Ajouter un script qui :
   - Crée un fichier texte sur le bureau
   - Y écrit la date de la dernière connexion
3. Appliquer à l'OU Ventes

### Exercice 1.2 - Blocage du compte utilisateur après 3 tentatives
1. Créer une GPO nommée `GPO-Blocage-Compte` qui permet de bloquer le compte utilisateur après 3 tentatives.
2. Configurer :
   - Blocage du compte utilisateur après 3 tentatives
3. Appliquer à l'OU Ventes



### Exercice 1.7 - Restrictions Menu Démarrer Ventes
1. Créer une GPO nommée `GPO-MenuDemarrer-Ventes`
2. Configurer :
   - Masquer l'option "Exécuter"
   - Désactiver l'accès à la ligne de commande
3. Tester sur ws-ventes-02


### Exercice 1.9 - Restrictions USB Comptabilité
1. Créer une GPO nommée `GPO-USB-Compta`
2. Configurer :
   - Désactiver le stockage amovible
3. Tester sur ws-compta-01

### Exercice 1.10 - Explorateur pour Ventes
1. Créer une GPO nommée `GPO-Explorateur-Ventes`
2. Configurer :
   - Masquer le lecteur C:
   - Désactiver l'accès aux outils d'administration
3. Vérifier sur ws-ventes-02

## 📝 Notes importantes
- Utilisez gpupdate /force après chaque modification
- Vérifiez les résultats avec gpresult /r
- Documentez les problèmes rencontrés

## ⚠️ Rappels
- Vérifiez toujours les permissions de délégation
- Testez chaque GPO avant de passer à l'exercice suivant
- N'oubliez pas que "Authenticated Users" doit avoir au moins "Read"
