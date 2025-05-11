# Exemple pratique : Restriction d'accès aux ordinateurs par département

## Objectif
Restreindre l'accès aux ordinateurs du département Ventes uniquement aux utilisateurs de ce département.

## Prérequis
- Un domaine Active Directory fonctionnel (maxtec.be)
- Des ordinateurs du département Ventes (ws-ventes-*)
- Des utilisateurs du département Ventes

## Étapes de configuration

### 1. Création du groupe global pour les utilisateurs de Ventes
1. Ouvrir **Utilisateurs et ordinateurs Active Directory**
2. Clic droit sur l'OU Ventes → **Nouveau** → **Groupe**
3. Configurer :
   - Nom du groupe : `GG-Ventes-Users`
   - Étendue du groupe : **Globale**
   - Type de groupe : **Sécurité**
4. Ajouter les utilisateurs de Ventes au groupe

### 2. Création de la GPO
1. Ouvrir **Gestion des stratégies de groupe**
2. Clic droit sur l'OU contenant les ordinateurs Ventes → **Créer un objet GPO dans ce domaine et le lier ici**
3. Nommer la GPO : `GPO-Restrictions-VentesPC`

### 3. Configuration de la GPO
1. Éditer la GPO créée
2. Naviguer vers : **Configuration ordinateur** → **Stratégies** → **Paramètres Windows** → **Paramètres de sécurité** → **Stratégies locales** → **Attribution des droits utilisateur**
3. Double-cliquer sur **Accéder à cet ordinateur à partir du réseau**
4. Sélectionner **Définir ces paramètres de stratégie**
5. **IMPORTANT** : Supprimer d'abord tous les groupes existants, y compris :
   - Utilisateurs
   - Utilisateurs authentifiés
   - Tout autre groupe présent
6. Ajouter uniquement :
   - Le groupe `GG-Ventes-Users`
   - Le groupe `Administrateurs du domaine`
   - Le groupe `Administrateurs`

Note : La suppression des groupes existants est cruciale car par défaut, le groupe 'Utilisateurs authentifiés' a accès.

### 4. Application et test
1. Sur un ordinateur Ventes :
   ```cmd
   gpupdate /force
   ```
2. Redémarrer l'ordinateur
3. Vérifier qu'un utilisateur Ventes peut se connecter
4. Vérifier qu'un utilisateur d'un autre département ne peut pas se connecter

## Points importants
- Cette configuration bloque TOUS les autres utilisateurs sauf ceux spécifiés
- Les administrateurs gardent l'accès grâce aux groupes Administrators et Domain Admins
- La GPO doit être appliquée uniquement sur les ordinateurs Ventes
