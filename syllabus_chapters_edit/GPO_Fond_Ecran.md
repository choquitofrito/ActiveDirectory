### Exemple pratique : Fonds d'écran par département

Nous allons créer trois GPOs pour définir un fond d'écran différent pour chaque département (Comptabilité, RH, Ventes). Ces GPOs seront appliquées aux UOs correspondantes dans la zone EU. Voici la procédure à suivre :

1. Sur le serveur, ouvrez l'Explorateur de fichiers
2. Créez un nouveau dossier : `C:\FondsEcran`
3. Depuis votre machine hôte, téléchargez une image de fond d'écran appropriée pour chaque département (Comptabilité, RH, Ventes)
4. Transférez ces images vers le dossier `C:\FondsEcran` du serveur par glisser-déposer

Une fois les images transférées, procédons à la création des stratégies de groupe (GPO) :

5. Création de la première GPO pour le département Comptabilité :
   - Lancez la console GPO : `Gestionnaire de serveur` > `Outils` > `Gestion des stratégies de groupe`
   - Dans l'arborescence, accédez à `Forêt: computerelectronics.be` > `Domaines` > `computerelectronics.be` > `Objets de stratégie de groupe`
   - Effectuez un clic droit sur l'UO Comptabilité > `Créer une nouvelle GPO et la lier`
   - Nommez la GPO selon notre convention :
       - `GPO-Configuration-FondEcranCompta`


Une fois la GPO créée :

   - Double-cliquez sur la GPO pour consulter ses propriétés
   (Un avertissement s'affichera pour rappeler que l'emplacement de création d'une GPO importe peu ; c'est sa cible de liaison qui est déterminante. Dans notre cas, la cible est l'UO Comptabilité)

Configuration de la GPO :

   - Faites un clic droit sur la GPO et sélectionnez `Modifier`
   - Naviguez vers `Configuration utilisateur` > `Stratégies` > `Modèles d'administration` > `Bureau`
   - Dans le volet de droite, sélectionnez `Bureau`
   - Double-cliquez sur `Papier peint du Bureau`
   - Sélectionnez `Activé`
   - Dans le champ `Nom du papier peint`, saisissez le chemin d'accès à l'image : `\\dns1\FondsEcran\compta.jpg`

Pour appliquer les modifications :
1. Sur le poste client, exécutez la commande `gpupdate /force`
2. Déconnectez-vous puis reconnectez-vous

Répétez cette procédure pour les départements RH et Ventes en adaptant le nom de la GPO et le chemin de l'image.
