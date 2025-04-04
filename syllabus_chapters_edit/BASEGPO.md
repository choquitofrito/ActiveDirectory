# Exercices GPO:

## 1. Modeles d'administration

#### 1.1. GPO-Restriction-PanneauConfig. Bloquer l'accès au Panneau de Configuration dans Ventes

 (Config Utilisateur > Modèles d'administration > Panneau de configuration > Interdire l'accès)


## 2. Stratégies

#### 2.1. GPO-Configuration-MessageConnexion. Afficher message de connexion
(Config Ordinateur > Stratégies > Paramètres Windows > Paramètres de sécurité > Stratégies locales > Options de sécurité > Ouverture de session interactive: contenu du message + Ouverture de session interactive: titre du message)

## 3. Preferences

#### 3.1. GPO-LinkBureau. Créer une icone sur le Bureau de l'utilisateur pour les utilisateurs de Ventes
(Config Utilisateur > Préférences -> Paramètres Windows > Raccourcis > Nouveau > Définir l'adresse et l'emplacement). 

| Action choisie dans la GPO | Le lien revient s’il est supprimé ? | Quand ?                                              |
|----------------------------|--------------------------------------|------------------------------------------------------|
| **Create**                 | ❌ Non                               | Jamais                                               |
| **Update**                 | ❌ Non                               | Jamais                                               |
| **Replace**                | ✅ Oui                               | Au prochain `gpupdate`, redémarrage ou ouverture de session |
| **Delete**                 | 🔄 Supprime le lien (s’il existe)    | Lors de l'application de la GPO                      |


**Important**: pour ajuster le ciblage, clique droit sur le Raccourci créé et Propriétés > Commun > Ciblage

#### 3.2. Modifier la GPO pour qu'elle affecte uniquement au groupe d'admins de Ventes (pas au groupe des utilisateurs)

## 4. Créer des exceptions à la GPO

Eviter l'application d'une GPO sur un ordinateur ou un utilisateur en particulier

#### 4.1. Éviter la restriction du panneau de configuration sur les admin de Ventes


## 5. Filtrage des GPO: appliquer les GPOs uniquement à certains groups

On peut appliquer une GPO sur un groupe spécifique. Par défaut, la GPO s'applique à tous les groupes concernés (selon la liaison de la GPO), mais on peut choisir un groupe spécifique sur lequel la GPO ne s'appliquera pas.

