# Plan du cours (5 jours - 32h30)

# Jour 1 - Installation et Configuration de Base (6h30)
- Introduction à Windows Server (1h)
  - Architecture Windows Server
  - Rôles et fonctionnalités
  - Éditions et licences
  - **Exercice** : Comparaison des éditions Windows Server (15min)

- Installation et Configuration (5h30)
  - Configuration Hyper-V (1h)
    - **TP** : Installation et configuration d'Hyper-V (30min)
  - Création des machines virtuelles (1h30)
    - **TP** : Création de la première VM (45min)
    - **TP** : Configuration réseau de la VM (30min)
  - Installation de Windows Server (2h)
    - **TP** : Installation pas à pas de Windows Server (1h)
    - **TP** : Configuration post-installation (30min)
  - Configuration réseau de base (1h)
    - **TP** : Configuration IP statique et DHCP (30min)
  - Bonnes pratiques de sécurité (1h)
    - **Exercice** : Audit de sécurité basique (30min)

# Jour 2 - DNS et Infrastructure de Base (6h30)
- Structure DNS de l'entreprise (2h30)
  - Architecture DNS de computerelectronics.be
    - **Exercice** : Analyse de l'architecture DNS existante (30min)
  - Configuration du domaine racine
    - **TP** : Configuration du serveur DNS principal (45min)
  - Sous-domaines (comptabilite, rh, ventes)
    - **TP** : Création des zones pour chaque département (45min)

- Configuration DNS avancée (4h)
  - Installation et configuration des serveurs DNS (1h30)
    - **TP** : Configuration de dns1 et dns2 (45min)
  - Configuration des zones et enregistrements (1h)
    - **TP** : Création d'enregistrements pour les services essentiels (30min)
  - Délégation des sous-domaines (1h)
    - **Exercice** : Scénarios de délégation DNS (30min)
  - Types de requêtes DNS et résolution (30min)
    - **TP** : Diagnostic des requêtes DNS (30min)
  - Réplication DNS et dépannage (30min)
    - **TP** : Configuration de la réplication DNS (30min)

# Jour 3 - Contrôleurs de Domaine et Active Directory (6h30)
- Introduction à Active Directory (1h30)
  - Concepts fondamentaux
  - Structure AD et domaines
  - **Exercice** : Analyse des besoins de computerelectronics.be (30min)
  - **TP** : Planification de l'infrastructure AD (30min)

- Installation et Configuration DC (3h30)
  - Installation du rôle AD DS (1h)
    - **TP** : Installation pas à pas du rôle AD DS (30min)
  - Promotion en contrôleur de domaine (1h)
    - **TP** : Promotion du serveur en DC (30min)
    - **Exercice** : Vérification post-promotion (15min)
  - Configuration des sites AD (1h)
    - **TP** : Configuration des sites pour les départements (30min)
  - Réplication entre contrôleurs (30min)
    - **TP** : Test de réplication entre dns1 et dns2 (15min)

- Rôles FSMO (1h30)
  - Types de rôles et leur importance
  - **TP** : Identification des rôles FSMO (30min)
  - **Exercice** : Planification de transfert de rôles (30min)

# Jour 4 - Structure Organisationnelle et Gestion (6h30)
- Conception des UO (3h30)
  - Stratégie de structure UO
    - **Exercice** : Analyse des besoins par département (30min)
  - Création des UO principales
    - **TP** : Création de la structure UO pour comptabilité (45min)
    - **TP** : Création de la structure UO pour RH (45min)
    - **TP** : Création de la structure UO pour ventes (45min)
  - Délégation administrative
    - **TP** : Configuration des délégations par département (30min)

- Gestion des Objets AD (3h)
  - Création et gestion des utilisateurs
    - **TP** : Création d'utilisateurs par département (45min)
  - Configuration des groupes
    - **TP** : Mise en place des groupes de sécurité (45min)
  - Gestion des ordinateurs
    - **TP** : Intégration des postes de travail (45min)
  - **Exercice** : Audit de la structure mise en place (45min)

# Jour 5 - Stratégies et Automatisation (6h30)
- Stratégies de groupe (GPO) (3h30)
  - Création et liaison des GPO
    - **TP** : Création d'une GPO de sécurité de base (45min)
  - Paramètres de sécurité
    - **TP** : Configuration des restrictions par département (45min)
  - Déploiement de logiciels
    - **TP** : Déploiement d'applications par GPO (45min)
  - Dépannage GPO
    - **Exercice** : Résolution de problèmes GPO courants (45min)

- PowerShell pour AD (3h)
  - Cmdlets AD essentielles
    - **TP** : Manipulation des objets AD en PowerShell (45min)
  - Scripts d'automatisation
    - **TP** : Création d'un script de gestion utilisateurs (45min)
  - Gestion en masse
    - **TP** : Script de création d'UO et groupes (45min)
  - **Exercice** : Création d'un rapport AD avec PowerShell (45min)
