# Guide de Configuration Réseau Windows Server 2025

## Table des matières
1. [Configuration initiale du réseau](#configuration-initiale)
2. [Configuration des paramètres TCP/IP](#tcp-ip)
3. [Configuration du DNS](#dns)
4. [Sécurité réseau](#securite)
5. [Bonnes pratiques](#bonnes-pratiques)

## Configuration initiale {#configuration-initiale}

### Accès à la configuration réseau
1. Ouvrir le "Gestionnaire de serveur"
2. Sélectionner "Réseau" dans le panneau de gauche
3. Cliquer sur "Configuration des adaptateurs réseau"

### Configuration de base des adaptateurs
1. Clic droit sur l'adaptateur réseau > Propriétés
2. Vérifier que les composants suivants sont installés :
   - Client pour les réseaux Microsoft
   - Partage de fichiers et d'imprimantes
   - Protocole Internet version 4 (TCP/IPv4)
   - Protocole Internet version 6 (TCP/IPv6)

## Configuration des paramètres TCP/IP {#tcp-ip}

### Configuration IPv4
1. Sélectionner "Protocole Internet version 4 (TCP/IPv4)" > Propriétés
2. Choisir entre :
   - Obtenir une adresse IP automatiquement (DHCP)
   - Utiliser l'adresse IP suivante :
     - Adresse IP
     - Masque de sous-réseau
     - Passerelle par défaut
3. Configuration DNS recommandée :
   - Utiliser les adresses de serveurs DNS suivantes
   - DNS principal : adresse du contrôleur de domaine
   - DNS secondaire : adresse du DNS de secours

### Configuration IPv6
- Activer si nécessaire pour la compatibilité future
- Configuration similaire à IPv4
- Attention aux règles de sécurité spécifiques à IPv6

## Configuration du DNS {#dns}

### Installation du rôle DNS
1. Dans le Gestionnaire de serveur > "Ajouter des rôles et fonctionnalités"
2. Sélectionner "Serveur DNS"
3. Suivre l'assistant d'installation

### Configuration des zones DNS
1. Ouvrir le Gestionnaire DNS
2. Configuration des zones directes et inversées
3. Paramétrage des redirecteurs
4. Configuration de la réplication DNS (si applicable)

## Sécurité réseau {#securite}

### Pare-feu Windows avec sécurité avancée
1. Configuration des règles entrantes
2. Configuration des règles sortantes
3. Activation des profils appropriés :
   - Domaine
   - Privé
   - Public

### Politiques de sécurité réseau
1. Configuration des stratégies de groupe (GPO) pour le réseau
2. Mise en place des restrictions d'accès
3. Configuration des audits de sécurité

## Bonnes pratiques {#bonnes-pratiques}

### Recommandations générales
- Utiliser des adresses IP statiques pour les serveurs
- Documenter toutes les configurations réseau
- Mettre en place une surveillance réseau
- Effectuer des sauvegardes régulières de la configuration

### Sécurité
- Désactiver les protocoles non utilisés
- Mettre à jour régulièrement les systèmes
- Utiliser des VLANs pour segmenter le réseau
- Implémenter une stratégie de mots de passe forts

### Performance
- Optimiser les paramètres de la carte réseau
- Surveiller régulièrement les performances
- Maintenir un plan de maintenance

---

*Note : Ce guide est basé sur l'interface de Windows Server 2025. Certaines fonctionnalités peuvent varier selon les mises à jour et les versions spécifiques.*
