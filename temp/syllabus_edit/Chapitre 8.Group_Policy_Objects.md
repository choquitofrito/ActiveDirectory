# 1. Group Policy Objects (GPOs)

## 1. Introduction aux GPOs

### 1.1. Qu'est-ce qu'une GPO ?

Une stratégie de groupe (GPO) **est un ensemble de règles et de paramètres qui permettent de gérer et standardiser la configuration des utilisateurs et des ordinateurs dans un environnement Active Directory**. Elle permet de :
- Configurer automatiquement les paramètres des postes de travail
- Appliquer des politiques de sécurité cohérentes
- Déployer des logiciels de manière centralisée
- Standardiser l'expérience utilisateur

**Analogie** : Pensez à une GPO comme à un "règlement d'entreprise numérique" qui définit :
- Ce que les utilisateurs peuvent faire
- Ce à quoi ils ont accès
- Comment leurs ordinateurs sont configurés

### 1.2. Objectifs Pédagogiques

À la fin de ce chapitre, vous serez capable de :
1. Créer et configurer des GPOs adaptées à différents besoins
2. Appliquer des stratégies spécifiques par département (Comptabilité, RH, Ventes)
3. Déployer des logiciels et des paramètres de sécurité via GPO
4. Dépanner les problèmes courants de stratégies de groupe

### 1.3. Types de paramètres GPO

#### Paramètres Ordinateur
**Description** : Configuration s'appliquant à la machine, indépendamment de l'utilisateur

**Exemples** :
```
Type               Exemple
---------------    ------------------------------------------
Sécurité          Configuration du pare-feu Windows
Système           Paramètres de mise à jour Windows
Réseau            Configuration proxy et paramètres réseau
```

#### Paramètres Utilisateur
**Description** : Configuration s'appliquant à l'utilisateur, indépendamment de la machine

**Exemples** :
```
Type               Exemple
---------------    ------------------------------------------
Bureau             Fond d'écran et thème standardisés
Applications       Paramètres Office et navigateur
Scripts            Scripts de connexion/déconnexion
```

> **Important** : Les GPOs suivent une hiérarchie stricte d'application. En cas de conflit, les règles de précédence déterminent quelle politique s'applique.

> **Note** : Pour la gestion des comptes utilisateurs, consultez le chapitre [3.1 Gestion des Utilisateurs, Groupes et Permissions](3.1.User_Groups_and_Permissions.md#2-gestion-des-comptes-utilisateurs).

## 2. Configuration des GPOs pour notre laboratoire

### 2.1. Préparation de l'environnement

#### Accès à la console GPMC
**Objectif** : Ouvrir l'outil de gestion des stratégies de groupe

**Procédure** :
1. Sur `dns1.computerelectronics.be`, ouvrez :
   ```
   Gestionnaire de serveur -> Outils -> Gestion des stratégies de groupe
   ```

#### Vérification des GPOs existantes
**Objectif** : Comprendre les stratégies par défaut

**GPOs système** :
```
Nom                                          Objectif
-------------------------------------------  -------------------------------
Default Domain Policy                         Sécurité globale du domaine
Default Domain Controllers Policy             Sécurité des contrôleurs
```

### 2.2. Création des GPOs par département

#### GPO de sécurité pour les postes de travail
**Nom** : `GPO_Securite_Postes`

**Cible** : Tous les postes clients du domaine (ws-*)
```
Liens : 
- OU=Ordinateurs,OU=Comptabilité,DC=computerelectronics,DC=be
- OU=Ordinateurs,OU=RH,DC=computerelectronics,DC=be
- OU=Ordinateurs,OU=Ventes,DC=computerelectronics,DC=be
Périmètre : ws-compta-*, ws-rh-*, ws-vnt-*
```

**Paramètres de sécurité** :
```
Catégorie          Paramètre                         Valeur
---------------    --------------------------------    ---------------
Pare-feu          État                              Activé
Registre          Accès éditeur de registre          Désactivé
Scripts           Exécution de scripts non signés     Désactivé
```

#### GPO pour le service comptabilité
**Nom** : `GPO_Configuration_Compta`

**Cible** : Utilisateurs et postes du service comptabilité
```
Lien : OU=Comptabilite,DC=computerelectronics,DC=be
Périmètre : Utilisateurs et ws-compta-*
```

**Paramètres spécifiques** :
```
Catégorie          Paramètre                         Valeur
---------------    --------------------------------    ---------------
Applications       Excel (formules)                    Activé
Dossiers          Accès D:\Partages\Comptabilite      Autorisé
Impression        Imprimantes comptabilité            Par défaut
```
   ```
   Paramètres :
   - Masquer le panneau de configuration
   - Désactiver l'accès au cmd
   - Restreindre l'accès aux dossiers système

## 3. Exercices Pratiques

### 3.1. Sécurisation des postes comptabilité

**Scénario** : Le département comptabilité nécessite des restrictions spécifiques

1. **Création de la GPO**
   ```
   Nom : COMPTA-Security-Policy
   Lien : OU=Comptabilite,OU=Clients,OU=Computers
   ```

2. **Configuration**
   - **Sécurité USB**
     * Désactiver le stockage amovible
     * Journaliser les accès aux périphériques
   - **Navigateur**
     * Bloquer les sites non professionnels
     * Activer le mode entreprise
   - **Système**
     * Désactiver l'invite de commandes
     * Masquer les lecteurs réseau non autorisés

3. **Test**
   ```powershell
   # Sur ws-compta-01
   gpupdate /force
   gpresult /r /scope computer
   ```

### 3.2. Configuration de ws-rh-01

**Scénario** : Déploiement automatique des logiciels RH

1. **Préparation**
   - Créer un partage réseau pour les installateurs
   - Préparer les fichiers MSI des applications

2. **Création de la GPO**
   ```
   Nom : RH-Software-Deployment
   Lien : OU=RH,OU=Clients,OU=Computers
   ```

3. **Configuration**
   - Installation de logiciels
     * Logiciel de paie
     * Suite bureautique complète
     * Logiciel de gestion des congés
   - Paramètres d'installation
     * Installation silencieuse
     * Redémarrage automatique

4. **Validation**
   ```powershell
   # Vérification du déploiement
   gpresult /h c:\software_deployment.html
   ```

### 3.3. Exercice avancé - Stratégies de mot de passe

**Scénario** : Implémenter des politiques de mot de passe différentes par département

1. **Création des GPOs**
   ```
   Nom : COMPTA-Password-Policy
   Nom : RH-Password-Policy
   ```

2. **Configuration Comptabilité**
   - Longueur minimale : 12 caractères
   - Complexité renforcée
   - Changement tous les 60 jours
   - Historique : 24 mots de passe

3. **Configuration RH**
   - Longueur minimale : 10 caractères
   - Complexité standard
   - Changement tous les 90 jours
   - Historique : 12 mots de passe

4. **Test et validation**
   ```powershell
   # Vérification des stratégies
   Get-ADDefaultDomainPasswordPolicy
   Get-ADFineGrainedPasswordPolicy
   ```

### 3.4. Exercice de dépannage

**Scénario** : Une GPO ne s'applique pas correctement

1. **Analyse**
   ```powershell
   # Vérification de la réplication
   dcdiag /test:replications
   
   # Vérification des liens
   Get-GPO -All | Format-Table DisplayName,Id,CreationTime
   
   # Test de la stratégie
   gpresult /h c:\gpo_debug.html /scope computer
   ```

2. **Points de vérification**
   - Héritage des stratégies
   - Filtres de sécurité
   - Ordre de traitement
   - Connectivité réseau

3. **Résolution**
   - Identifier le problème
   - Documenter la solution
   - Tester la correction
   - Mettre à jour la documentation

## 4. Bonnes pratiques GPO

1. **Organisation**
   - Nommage clair et descriptif
   - Documentation des modifications
   - Sauvegarde régulière

2. **Performance**
   - Limiter le nombre de GPOs
   - Optimiser les liens
   - Éviter les conflits

3. **Sécurité**
   - Tester avant déploiement
   - Utiliser des groupes de sécurité
   - Auditer les modifications
