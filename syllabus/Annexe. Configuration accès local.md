# Configuration du droit "Se connecter localement"

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