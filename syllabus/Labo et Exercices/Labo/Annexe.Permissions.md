## Résolution des Problèmes de Permissions et Propriété de Dossiers dans Windows

## Introduction
Lorsque vous rencontrez des problèmes de modification de permissions ou d'accès à un dossier créé par un utilisateur ou un groupe, cela est souvent dû à des conflits de **propriété** ou de **permissions**. Ce guide vous montre comment **prendre possession** d'un dossier et modifier les **permissions** de manière appropriée.

### Problème
Si un dossier est créé par un utilisateur ou un groupe, il peut être difficile de modifier les permissions. Cela se produit car le dossier appartient à l'utilisateur ou au groupe qui l'a créé et vous n'avez peut-être pas les droits nécessaires pour le modifier.

## Solution : Comment Résoudre ce Problème

### Étape 1 : Prendre Possession du Dossier
1. **Cliquez droit** sur le dossier (par exemple, un sous-dossier créé par un utilisateur) et sélectionnez **Propriétés**.
2. Allez dans l'onglet **Sécurité** et cliquez sur **Paramètres de sécurité avancés**.
3. Dans la fenêtre **Paramètres de sécurité avancés**, allez dans l'onglet **Propriétaire**.
4. Cliquez sur **Modifier**, puis sélectionnez votre compte **Administrateur** ou le groupe **Administrateurs** comme nouveau propriétaire.
5. Cochez la case **"Remplacer le propriétaire sur les sous-conteneurs et objets"** pour vous assurer que la possession du sous-dossier et de tous les fichiers à l'intérieur est également transférée.
6. Cliquez sur **Appliquer**, puis sur **OK** pour valider.

### Étape 2 : Vérifier et Activer l'Héritage des Permissions (si nécessaire)
1. Dans la fenêtre **Paramètres de sécurité avancés**, assurez-vous que l'option **Activer l'héritage** est cochée.
2. Si l'héritage est désactivé, cliquez sur **Activer l'héritage** pour permettre au dossier de recevoir les permissions du dossier parent.

### Étape 3 : Modifier les Permissions
1. Dans la même fenêtre **Paramètres de sécurité avancés**, cliquez sur **Ajouter**.
2. Ajoutez le groupe (**GG-EU-RH-Admins**) et attribuez-lui les permissions nécessaires (par exemple, **Contrôle total**).
3. Cliquez sur **Appliquer** puis sur **OK** pour enregistrer les modifications.

### Étape 4 : Vérifier les Permissions
1. Retournez dans l'onglet **Sécurité** et vérifiez que le groupe **GG-EU-RH-Admins** dispose des permissions souhaitées.
2. Si nécessaire, ajustez ou supprimez des permissions non désirées.

## Notes Importantes
- **Prendre possession** du dossier permet de contourner les restrictions de l'utilisateur ou du groupe qui l'a créé, et d'obtenir un contrôle total sur ce dossier.
- **L'héritage** garantit que les permissions du dossier parent sont automatiquement appliquées aux sous-dossiers et fichiers.
- Il est recommandé de toujours **sauvegarder** le dossier ou les données avant de modifier les paramètres de sécurité.

---

## Cas Pratique : Gestion des Dossiers Partagés

### Problème
Lorsque vous partagez un dossier sur un serveur ou une machine, il peut arriver que vous rencontriez des erreurs de **"Accès refusé"** ou des problèmes pour modifier les permissions sur un dossier créé par un autre utilisateur ou un groupe.

### Solution Professionnelle
Voici un résumé des étapes pour prendre possession du dossier et corriger les permissions :

#### 1. Prendre Possession du Dossier
- Accédez aux **Propriétés** du dossier concerné et changez le propriétaire en votre compte ou le groupe Administrateurs.
- Cochez l'option **"Remplacer le propriétaire sur les sous-conteneurs et objets"** pour appliquer ce changement à tous les sous-dossiers et fichiers.

#### 2. Activer l'Héritage
- Dans les **Paramètres de sécurité avancés**, assurez-vous que **l'héritage** est activé. Cela permet aux sous-dossiers d'hériter des permissions du



## Annexe: configuration pour permettre une connexion locale au serveur

Cette section concerne la configuration du droit "Se connecter localement" 

## Description

Le paramètre "Permettre l'ouverture d'une session locale" contrôle quels utilisateurs ou groupes peuvent se connecter physiquement à un ordinateur du domaine.

Pour modifier ce comportement on doit créer une stratégie de groupe (GPO) et l'appliquer à l'OU appropriée.

1. Ouvrir `gpmc.msc`
2. Créer une nouvelle GPO ou modifier une existante
3. Naviguer vers : **Configuration ordinateur > Paramètres Windows > Paramètres de sécurité > Stratégies locales > Attribution des droits utilisateur**
4. Double-cliquer sur **"Permettre l'ouverture d'une session locale"**
5. Ajouter les utilisateurs ou groupes nécessaires
6. Lier la GPO à l'OU appropriée

## Groupes par défaut ayant ce droit
- Administrateurs
- ENTERPRISE DOMAIN CONTROLLERS
- Opérateurs de compte
- Opérateurs d'impression
- Opérateurs de sauvegarde
- Opérateurs de serveur

## Vérification
Pour vérifier l'application des paramètres :
1. Exécuter : `gpupdate /force`
2. Vérifier avec : `gpresult /r` ou `rsop.msc`

## Note importante
La modification de ce paramètre peut affecter la compatibilité avec les clients, les services et les applications. Assurez-vous de tester les changements dans un environnement contrôlé avant de les appliquer en production.
