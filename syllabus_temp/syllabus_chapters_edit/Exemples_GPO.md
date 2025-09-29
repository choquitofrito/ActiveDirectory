
# 2. Exemple pratique : Verrouillage de l'écran après inactivité

Nous allons créer une GPO permettant d'imposer un verrouillage automatique de l'écran après une période d'inactivité. Cette GPO est utile pour renforcer la sécurité en s'assurant que les sessions ouvertes ne restent pas accessibles en l'absence de l'utilisateur.

#### Étapes de configuration

1. **Ouvrir la console de gestion des stratégies de groupe**

   - Sur le serveur, ouvrez `Gestionnaire de serveur`
   - Accédez à `Outils` > `Gestion des stratégies de groupe`

2. **Créer une nouvelle GPO**

   - Dans l’arborescence, accédez à `Forêt: votredomaine.local` > `Domaines` > `votredomaine.local` > `Objets de stratégie de groupe`
   - Effectuez un clic droit sur l’UO cible (ex: `Ventes`) > `Créer une nouvelle GPO et la lier ici`
   - Donnez un nom explicite à la GPO, par exemple : `GPO-Verrouillage-Inactivité`

3. **Modifier la GPO pour imposer le verrouillage après inactivité**

   - Faites un clic droit sur la GPO créée et sélectionnez `Modifier`
   - Naviguez vers :
     - `Configuration utilisateur` > `Stratégies` > `Modèles d'administration` > `Panneau de configuration` > `Personnalisation`
   - Dans le volet de droite, double-cliquez sur `Dépassement du délai d'expiration de l'écran de veille` 
   - Sélectionnez `Activé` et définissez un délai en secondes (ex: `60` pour 1 minute)
   - Double-cliquez sur `Activer l'écran de veille`
   - Sélectionnez `Activé` et validez par `OK`
   
4. **Appliquer et tester la GPO**

   - Sur un poste client, ouvrez une invite de commandes en administrateur
   - Exécutez : `gpupdate /force`
   - Attendez la durée configurée sans utiliser la machine
   - Vérifiez que l’écran se verrouille automatiquement

#### Résultat attendu

Avec cette GPO, tout poste inactif pendant la durée définie sera automatiquement verrouillé, nécessitant une reconnexion de l’utilisateur. Cette mesure améliore la sécurité en empêchant l’accès non autorisé aux sessions ouvertes.

Vous pouvez ajuster la durée du verrouillage selon vos besoins pour équilibrer sécurité et confort d'utilisation.



