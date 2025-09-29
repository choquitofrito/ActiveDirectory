# 🔹 Exercices GPO - Niveau 2 (Intermédiaire)

## 1. 🔒 Sécurité et Conformité

### Exercice 2.1 - Protection des données Comptabilité
1. Créer une GPO nommée `GPO-Securite-ComptaData`
2. Configurer :
   - Bloquer l'envoi de fichiers par email
   - Interdire l'accès au panneau de configuration
3. Appliquer à l'OU Comptabilité
4. Tester sur ws-compta-01

### Exercice 2.2 - Authentification renforcée
1. Créer une GPO nommée `GPO-Auth-EU`
2. Configurer :
   - Verrouillage après 3 tentatives
   - Durée de verrouillage : 30 minutes
   - Complexité mot de passe renforcée
   - Expiration session après 15 minutes
3. Appliquer à l'OU EU

### Exercice 2.3 - Restrictions Applications Ventes
1. Créer une GPO nommée `GPO-Apps-Ventes`
2. Configurer :
   - Liste blanche d'applications autorisées
   - Bloquer l'installation de logiciels
   - Autoriser uniquement les applications métier
3. Tester sur ws-ventes-02

## 2. 🛠️ Configuration Avancée

### Exercice 2.4 - Scripts de maintenance
1. Créer une GPO nommée `GPO-Maintenance-EU`
2. Configurer :
   - Script de nettoyage des fichiers temporaires
   - Vérification de l'espace disque
   - Rapport d'état système
3. Appliquer à toutes les machines de l'OU EU

### Exercice 2.5 - Audit de sécurité Comptabilité
1. Créer une GPO nommée `GPO-Audit-Compta`
2. Configurer :
   - Audit des accès aux fichiers sensibles
   - Journalisation des connexions
   - Suivi des modifications système
   - Conservation des logs pendant 90 jours
3. Tester sur ws-compta-01


## 3. 🔄 Gestion des conflits

### Exercice 2.7 - Résolution de conflits GPO
1. Créer deux GPOs contradictoires :
   - `GPO-Securite-EU` (niveau OU EU)
   - `GPO-Securite-Compta` (niveau OU Comptabilité)
2. Configurer des paramètres conflictuels
3. Utiliser les outils d'analyse pour comprendre l'application

## 4. 📦 Installation de logiciels

### Exercice 2.8 - Installation automatique 7-Zip
1. Créer une GPO nommée `GPO-Deploy-7zip`
2. Préparer le package MSI de 7-Zip
3. Configurer dans la GPO :
   - Configuration ordinateur → Stratégies → Paramètres du logiciel
   - Installation du logiciel → Nouveau → Package
   - Sélectionner le fichier MSI via un chemin UNC
   - Choisir "Attribué" comme méthode de déploiement
4. Appliquer à l'OU Ventes
5. Tester sur ws-ventes-02

### Exercice 2.9 - Installation Adobe Reader DC
1. Créer une GPO nommée `GPO-Deploy-AdobeReader`
2. Préparer le déploiement :
   - Télécharger Adobe Reader DC Enterprise
   - Extraire le package MSI avec l'outil Adobe Customization Wizard
   - Créer un fichier de transformation (.mst) pour :
     * Installation silencieuse
     * Désactiver les mises à jour automatiques
     * Configurer les paramètres par défaut
3. Configurer la GPO :
   - Utiliser le chemin UNC pour le MSI
   - Ajouter le fichier de transformation
   - Définir en "Attribué"
4. Appliquer à l'OU Comptabilité
5. Tester sur ws-compta-01

### Exercice 2.10 - Mappage de dossiers partagés
1. Créer les partages sur le serveur :
   - \\dns1\commun
   - \\dns1\compta
   - \\dns1\ventes
2. Créer une GPO nommée `GPO-Partages-Departements`
3. Configurer :
   - Pour Comptabilité :
     * Lecteur P: -> \\dns1\compta
     * Lecteur S: -> \\dns1\commun
   - Pour Ventes :
     * Lecteur V: -> \\dns1\ventes
     * Lecteur S: -> \\dns1\commun
4. Appliquer aux OUs respectives
5. Tester sur :
   - ws-compta-01
   - ws-ventes-02

## 5. 📊 Reporting et Surveillance

### Exercice 2.11 - Rapport d'application GPO
1. Utiliser les outils de reporting pour :
   - Analyser les GPOs appliquées
   - Identifier les conflits
   - Générer des rapports HTML
2. Documenter les résultats

### Exercice 2.12 - Dépannage avancé
1. Simuler des problèmes courants :
   - GPO non appliquée
   - Conflits de paramètres
   - Problèmes de réplication
2. Utiliser les outils de dépannage
3. Documenter la méthodologie

## 📝 Notes importantes
- Documentez chaque modification
- Testez dans un environnement contrôlé
- Utilisez gpresult /h pour les rapports HTML
- Vérifiez l'impact sur les performances

## ⚠️ Bonnes pratiques
- Nommage cohérent des GPOs
- Documentation des modifications
- Tests avant déploiement général
- Sauvegarde des GPOs importantes
