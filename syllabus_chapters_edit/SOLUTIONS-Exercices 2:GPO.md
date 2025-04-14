# Solutions Exercices GPO-2


## Exercice 1: limiter les ordinateurs IT

### 1. Créer un groupe de sécurité pour les utilisateurs IT
(Si vous ne l'avez pas encore)

### 2. Créer une GPO pour restreindre les connexions

1. Ouvre **Group Policy Management (GPMC)**.
2. Clique droit sur l’OU `IT\Computers` > **Créer une GPO dans ce domaine et la lier ici…**.
   - **Nom** : `GPO_Connexion_IT`
3. Clique droit sur cette GPO > **Modifier**.

### 3. Configurer les droits de connexion

Dans l’éditeur de la GPO :

1. Navigue vers :

Configuration ordinateur > Stratégies > Paramètres Windows > Paramètres de sécurité > Stratégies locales > Attribution des droits utilisateur
 
2. Double-clique sur **Permettre l’ouverture de session locale**.
3. Cochez **Définir ces paramètres de stratégie** pour que la configuration que vous allez réaliser soit appliquée.
4. Clique sur **Ajouter un utilisateur ou un groupe** > Ajoute le groupe des Utilisateurs IT et le groupe d'**Administrateurs** (qui ont accès à toutes les ressources du domaine AD). Autrement on serait en train d'empecher les Admins de se connecter sur l'ordinateur!
5. Supprime les autres groupes comme `Users du domaine`, si présents (pas présent par défaut)
6. Ferme l’éditeur.

### 4. Forcer la mise à jour de la stratégie

1. Sur un ordinateur de l’OU `IT\Computers`, ouvre une session avec un utilisateur de IT.
2. Lance la commande suivante dans un terminal ou PowerShell :

   ```bash
   gpupdate /force
   ```

### 5. Tester la restriction

Essayez de vous conecter sur un ordinateur d'IT avec un utilisateur de IT (AD doit fonctionner)

Essayez de vous conecter sur un ordinateur d'IT avec un utilisateur de RH (AD ne doit pas permettre la connexion)

