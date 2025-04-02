# 🔹 Exercices GPO - Niveau 3 (Avancé)

## 1. 🔒 Sécurité Avancée

### Exercice 3.1 - Politique de sécurité multiniveau
1. Créer une structure de GPOs imbriquées :
   ```
   EU (GPO-Base-EU)
   └── Comptabilité (GPO-Secure-Compta)
       └── ws-compta-01 (GPO-Endpoint-Compta)
   ```
2. Configurer pour chaque niveau :
   - EU : Règles de base (mots de passe, audit)
   - Comptabilité : Restrictions d'accès
   - Poste : Contrôles spécifiques
3. Gérer les priorités et l'héritage

### Exercice 3.2 - Protection des données sensibles
1. Créer `GPO-DLP-Compta` pour la Comptabilité
2. Implémenter :
   - Chiffrement de dossiers sensibles
   - Restrictions de copie de fichiers
   - Journalisation avancée
   - Blocage des périphériques externes
3. Tester sur ws-compta-01

### Exercice 3.3 - Sécurisation des accès Ventes
1. Créer `GPO-Access-Ventes`
2. Configurer :
   - Authentification à deux facteurs
   - Restrictions horaires
   - Limitations géographiques
   - Audit complet
3. Déployer sur ws-ventes-02

## 2. 🛠️ Administration Avancée

### Exercice 3.4 - Automatisation et maintenance
1. Créer `GPO-Auto-EU` avec :
   - Scripts PowerShell de maintenance
   - Tâches planifiées complexes
   - Rapports automatisés
2. Implémenter la journalisation centralisée
3. Tester sur les deux postes

### Exercice 3.5 - Gestion des applications
1. Créer `GPO-AppControl-Compta`
2. Configurer :
   - Installation silencieuse d'applications
   - Mises à jour automatiques
   - Restrictions AppLocker avancées
3. Tester le déploiement

### Exercice 3.6 - Infrastructure résiliente
1. Créer plusieurs GPOs de secours :
   - `GPO-Fallback-Compta`
   - `GPO-Fallback-Ventes`
2. Configurer :
   - Paramètres de récupération
   - Modes dégradés
   - Procédures d'urgence

## 3. 🔄 Scénarios Complexes

### Exercice 3.7 - Migration GPO
1. Simuler une migration complexe :
   - Exporter les GPOs existantes
   - Modifier pour nouvelle structure
   - Tester la migration
   - Valider les résultats

### Exercice 3.8 - Gestion des exceptions
1. Créer un système d'exceptions avec :
   - Filtres WMI complexes
   - Délégation multiniveau
   - Documentation automatisée
2. Tester différents scénarios

### Exercice 3.9 - Audit et conformité
1. Mettre en place :
   - Audit complet des GPOs
   - Rapports de conformité
   - Détection des anomalies
2. Créer un tableau de bord de suivi

### Exercice 3.10 - Récupération d'urgence
1. Simuler des scénarios critiques :
   - Corruption de GPO
   - Perte de connexion
   - Conflit majeur
2. Appliquer les procédures de récupération

## 📝 Documentation et Procédures

### Modèles de documentation
1. Créer des modèles pour :
   - Nouvelles GPOs
   - Modifications
   - Tests et validation
   - Rapports d'incidents

### Procédures d'urgence
1. Documenter les procédures pour :
   - Restauration GPO
   - Mode dégradé
   - Escalade problèmes
   - Communication utilisateurs

## ⚠️ Points critiques
- Toujours tester sur un scope limité
- Maintenir une documentation précise
- Prévoir des procédures de rollback
- Surveiller les performances système

## 🔍 Validation finale
- Tests complets avant production
- Vérification des dépendances
- Validation utilisateurs clés
- Mise à jour documentation
