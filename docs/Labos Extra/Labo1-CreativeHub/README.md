# Laboratoire Active Directory: Agence CreativeHub

## Objectifs Pédagogiques

À la fin de ce laboratoire, les étudiants seront capables de:

1. **Comprendre la structure organisationnelle d'un Active Directory** en explorant une hiérarchie d'OUs représentant une vraie entreprise
2. **Gérer les comptes utilisateurs** et comprendre l'importance des attributs (email, titre, département)
3. **Utiliser les groupes de sécurité** pour organiser les permissions et distinguer entre groupes d'utilisateurs et groupes d'administrateurs
4. **Configurer et appliquer des Stratégies de Groupe (GPOs)** pour implémenter des politiques de sécurité adaptées à différents départements

## Scénario Entreprise

**CreativeHub** est une petite agence de marketing digital et design située en Belgique, comptant 18 employés répartis dans 4 départements. L'agence offre des services complets de communication digitale à ses clients:

### Contexte Business

- **Nom de l'entreprise**: CreativeHub
- **Secteur**: Marketing digital, design graphique, développement web, production vidéo
- **Taille**: 18 employés permanents
- **Clients**: PME belges et européennes nécessitant des services de communication digitale

### Structure Départementale

L'agence est organisée en 4 départements spécialisés:

#### 1. **Marketing** (5 employés)

Responsable de la stratégie digitale, gestion des réseaux sociaux, SEO/SEM, et création de contenu pour les clients.

| Employé | Fonction |
|---------|----------|
| **Camille Bernard** | Responsable Marketing Digital (Admin) |
| **Amélie Dubois** | Community Manager |
| **Bastien Martin** | Spécialiste SEO |
| **Damien Petit** | Content Strategist |
| **Élise Robert** | Social Media Analyst |

#### 2. **Creative** (5 employés)

L'équipe créative produit tous les visuels, vidéos et designs pour les campagnes clients.

| Employé | Fonction |
|---------|----------|
| **Fabien Moreau** | Graphiste Senior (Admin) |
| **Gabrielle Simon** | Directrice Artistique |
| **Hugo Laurent** | Motion Designer |
| **Inès Lefebvre** | Vidéaste |
| **Julien Roux** | Designer UX/UI |

#### 3. **Client Services** (4 employés)

Département gérant les relations clients, gestion de projets, et coordination entre les équipes techniques et créatives.

| Employé | Fonction |
|---------|----------|
| **Karine Garnier** | Chef de Projet Senior (Admin) |
| **Laurent Faure** | Account Manager |
| **Manon Girard** | Chef de Projet Junior |
| **Nicolas André** | Directeur des Opérations |

!!! warning "Note de sécurité"
    Ce département manipule des données clients sensibles (contrats, budgets, informations stratégiques) nécessitant des mesures de sécurité renforcées.

#### 4. **IT Support** (4 employés)

Équipe technique responsable du développement web, maintenance de l'infrastructure IT, et support aux autres départements.

| Employé | Fonction |
|---------|----------|
| **Olivier Mercier** | Développeur Web Full-Stack (Admin) |
| **Pauline Blanc** | Administratrice Systèmes |
| **Quentin Guerin** | Développeur Front-End |
| **Rachid Dupont** | Responsable IT |

### Besoins de Sécurité

1. **Protection des données clients**: Le département Client Services gère des informations sensibles nécessitant des restrictions d'accès (blocage USB)
2. **Contrôle des juniors**: Les employés juniors (stagiaires, nouvelles recrues) ont besoin de restrictions pour éviter les modifications système accidentelles
3. **Collaboration**: Tous les départements doivent accéder à des ressources partagées (projets clients, bibliothèque de ressources créatives)
4. **Gestion des permissions**: Chaque département a besoin d'administrateurs locaux pour gérer leurs équipes

---

---

## Structure Créée par le Script

!!! info "Scripts disponibles"
    - **Script de création**: [CreativeHub_Setup.ps1](scripts/CreativeHub_Setup.ps1)
    - **Script de nettoyage**: [CreativeHub_Cleanup.ps1](scripts/CreativeHub_Cleanup.ps1)
    - **Scripts de vérification**: [Dossier verification](scripts/verification/)

### Arborescence des Unités Organisationnelles (OUs)

```
DC=maxtec,DC=be
└── OU=CreativeHub
    ├── OU=Marketing
    │   ├── OU=Users
    │   ├── OU=Computers
    │   └── OU=Groups
    ├── OU=Creative
    │   ├── OU=Users
    │   ├── OU=Computers
    │   └── OU=Groups
    ├── OU=ClientServices
    │   ├── OU=Users
    │   ├── OU=Computers
    │   └── OU=Groups
    └── OU=ITSupport
        ├── OU=Users
        ├── OU=Computers
        └── OU=Groups
```

**Total**: 1 OU racine + 4 OUs départementales + 12 sous-OUs = **17 Unités Organisationnelles**

### Utilisateurs

Le script crée **18 comptes utilisateurs** avec les attributs suivants:

| Nom Complet | Login (SAM) | Email | Département | Titre/Poste | Mot de passe |
|-------------|-------------|-------|-------------|-------------|--------------|
| **MARKETING** |
| Amélie Dubois | amelie | amelie@maxtec.be | Marketing | Community Manager | Password1! |
| Bastien Martin | bastien | bastien@maxtec.be | Marketing | Spécialiste SEO | Password1! |
| Camille Bernard | camille | camille@maxtec.be | Marketing | Responsable Marketing Digital | Password1! |
| Damien Petit | damien | damien@maxtec.be | Marketing | Content Strategist | Password1! |
| Élise Robert | elise | elise@maxtec.be | Marketing | Social Media Analyst | Password1! |
| **CREATIVE** |
| Fabien Moreau | fabien | fabien@maxtec.be | Creative | Graphiste Senior | Password1! |
| Gabrielle Simon | gabrielle | gabrielle@maxtec.be | Creative | Directrice Artistique | Password1! |
| Hugo Laurent | hugo | hugo@maxtec.be | Creative | Motion Designer | Password1! |
| Inès Lefebvre | ines | ines@maxtec.be | Creative | Vidéaste | Password1! |
| Julien Roux | julien | julien@maxtec.be | Creative | Designer UX/UI | Password1! |
| **CLIENT SERVICES** |
| Karine Garnier | karine | karine@maxtec.be | ClientServices | Chef de Projet Senior | Password1! |
| Laurent Faure | laurent | laurent@maxtec.be | ClientServices | Account Manager | Password1! |
| Manon Girard | manon | manon@maxtec.be | ClientServices | Chef de Projet Junior | Password1! |
| Nicolas André | nicolas | nicolas@maxtec.be | ClientServices | Directeur des Opérations | Password1! |
| **IT SUPPORT** |
| Olivier Mercier | olivier | olivier@maxtec.be | ITSupport | Développeur Web Full-Stack | Password1! |
| Pauline Blanc | pauline | pauline@maxtec.be | ITSupport | Administratrice Systèmes | Password1! |
| Quentin Guerin | quentin | quentin@maxtec.be | ITSupport | Développeur Front-End | Password1! |
| Rachid Dupont | rachid | rachid@maxtec.be | ITSupport | Responsable IT | Password1! |

!!! info "Propriétés des comptes"
    - Sont **activés** par défaut
    - Utilisent le mot de passe: `Password1!`
    - N'exigent **pas** de changement de mot de passe à la première connexion (pour faciliter les tests)
    - Ont des adresses email au format `prenom@maxtec.be`

### Groupes de Sécurité

Le script crée **8 groupes de sécurité globaux** (Global Groups):

| Nom du Groupe | Type | Emplacement | Description | Membres |
|---------------|------|-------------|-------------|---------|
| **GG-CreativeHub-Marketing-Users** | Global Security | OU=Groups,OU=Marketing | Tous les utilisateurs Marketing | amelie, bastien, camille, damien, elise (5) |
| **GG-CreativeHub-Marketing-Admin** | Global Security | OU=Groups,OU=Marketing | Administrateurs Marketing | amelie (1er alphabétique) |
| **GG-CreativeHub-Creative-Users** | Global Security | OU=Groups,OU=Creative | Tous les utilisateurs Creative | fabien, gabrielle, hugo, ines, julien (5) |
| **GG-CreativeHub-Creative-Admin** | Global Security | OU=Groups,OU=Creative | Administrateurs Creative | fabien (1er alphabétique) |
| **GG-CreativeHub-ClientServices-Users** | Global Security | OU=Groups,OU=ClientServices | Tous les utilisateurs Client Services | karine, laurent, manon, nicolas (4) |
| **GG-CreativeHub-ClientServices-Admin** | Global Security | OU=Groups,OU=ClientServices | Administrateurs Client Services | karine (1er alphabétique) |
| **GG-CreativeHub-ITSupport-Users** | Global Security | OU=Groups,OU=ITSupport | Tous les utilisateurs IT Support | olivier, pauline, quentin, rachid (4) |
| **GG-CreativeHub-ITSupport-Admin** | Global Security | OU=Groups,OU=ITSupport | Administrateurs IT Support | olivier (1er alphabétique) |

!!! note "Convention de nommage"
    Format: `GG-[Entreprise]-[Département]-[Rôle]`

    - **GG** = Global Group (groupe global)
    - **Entreprise** = CreativeHub
    - **Département** = Marketing, Creative, ClientServices, ITSupport
    - **Rôle** = Users (tous les utilisateurs) ou Admin (administrateurs)

!!! tip "Logique d'appartenance automatique"
    - TOUS les utilisateurs d'un département sont ajoutés au groupe `-Users`
    - Le PREMIER utilisateur par ordre alphabétique devient automatiquement membre du groupe `-Admin`

### Stratégies de Groupe (GPOs)

Le script crée et configure **3 GPOs** démontrant des cas d'usage courants en entreprise:

#### GPO 1: CreativeHub - Restrictions Utilisateurs Juniors

**Objectif pédagogique:** Protéger le système contre les modifications accidentelles par des utilisateurs inexpérimentés

**Configuration:**

- **Désactive le Panneau de configuration** (`NoControlPanel=1`)
    - Clé de registre: `HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer`
- **Désactive l'invite de commandes** (`DisableCMD=2`)
    - Clé de registre: `HKCU\Software\Policies\Microsoft\Windows\System`

**Liée à:**

- `OU=Users,OU=Marketing,OU=CreativeHub,DC=maxtec,DC=be`
- `OU=Users,OU=Creative,OU=CreativeHub,DC=maxtec,DC=be`

!!! example "Raison business"
    Les équipes Marketing et Creative ont souvent des stagiaires ou juniors qui ont besoin d'accéder aux applications métier (Adobe Creative Suite, outils marketing) mais ne doivent pas modifier les paramètres système.

#### GPO 2: CreativeHub - Blocage USB Client Services

**Objectif pédagogique:** Protéger les données sensibles contre l'exfiltration via périphériques USB

**Configuration:**

- **Bloque la lecture depuis périphériques USB** (`Deny_Read=1`)
- **Bloque l'écriture vers périphériques USB** (`Deny_Write=1`)
- Clé de registre: `HKLM\Software\Policies\Microsoft\Windows\RemovableStorageDevices\{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}`
- GUID `{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}` = Removable Disks (disques amovibles)

**Liée à:**

- `OU=Users,OU=ClientServices,OU=CreativeHub,DC=maxtec,DC=be`

!!! example "Raison business"
    Le département Client Services manipule des contrats clients, informations budgétaires sensibles, et données stratégiques qui ne doivent jamais quitter l'infrastructure sécurisée de l'entreprise.

#### GPO 3: CreativeHub - Lecteurs Réseau Partagés

**Objectif pédagogique:** Faciliter l'accès aux ressources partagées via mappage de lecteurs réseau

**Configuration:**

- GPO créée mais nécessite configuration manuelle via Group Policy Preferences
- Lecteurs suggérés:
    - **P:** → `\\SERVEUR\Projets` (dossiers projets clients)
    - **R:** → `\\SERVEUR\Ressources` (bibliothèque d'assets créatifs, templates, logos clients)

**Liée à:**

- `OU=CreativeHub,DC=maxtec,DC=be` (tous les départements)

!!! example "Raison business"
    Tous les employés doivent accéder facilement aux projets clients en cours et à la bibliothèque de ressources créatives partagées (images, vidéos, templates).

!!! warning "Configuration manuelle requise"
    Le mappage de lecteurs réseau via GPO nécessite:

    1. Création des partages réseau sur le serveur de fichiers (à faire manuellement)
    2. Configuration via **Group Policy Management Console (GPMC)** → User Configuration → Preferences → Windows Settings → Drive Maps

---

## Instructions d'Exécution

### Étape 1: Préparation

1. **Connectez-vous** au contrôleur de domaine Windows Server 2022 en tant qu'Administrateur du domaine
2. **Ouvrez PowerShell ISE** avec privilèges administratifs:
   - Clic droit sur "Windows PowerShell ISE" → **Exécuter en tant qu'administrateur**
3. **Copiez** le fichier `CreativeHub_Setup.ps1` sur le serveur (par exemple dans `C:\Labos\`)

### Étape 2: Exécution du Script

1. Dans PowerShell ISE, ouvrez le fichier `CreativeHub_Setup.ps1`:
   ```powershell
   # Si le fichier est dans C:\Labos\
   cd C:\Labos
   .\CreativeHub_Setup.ps1
   ```

2. **Ou** copiez-collez tout le contenu du script dans la fenêtre de script PowerShell ISE

3. Appuyez sur **F5** pour exécuter le script

4. Le script vous demandera confirmation avant chaque étape majeure:
   - **O** = Continuer avec cette étape
   - **N** = Sauter cette étape
   - **Q** = Quitter le script complètement

### Étape 3: Observation

Pendant l'exécution, observez la sortie console avec attention:

- **Texte vert** = Succès (objet créé)
- **Texte jaune** = Avertissement (objet existe déjà, ou action nécessitant attention)
- **Texte rouge** = Erreur
- **Texte cyan/bleu** = Informations générales
- **Texte gris** = Détails techniques

Le script affiche des messages détaillés pour chaque action, ce qui permet de comprendre ce qui se passe dans Active Directory.

### Étape 4: Vérification

À la fin de l'exécution, le script affiche un récapitulatif complet et exporte 3 fichiers CSV dans `C:\Labos\`:

- `CreativeHub_Utilisateurs.csv` - Liste complète des utilisateurs
- `CreativeHub_Groupes.csv` - Liste des groupes avec leurs membres
- `CreativeHub_OUs.csv` - Structure des Unités Organisationnelles

---



## Exercices Pratiques

Après avoir exécuté le script, les étudiants peuvent approfondir leur apprentissage avec ces exercices pratiques guidés:

!!! tip "Exercices disponibles"
    Le laboratoire CreativeHub comprend **9 exercices progressifs** avec scripts de vérification automatique:

    **Niveau Débutant:**

    - [Exercice 01: Nouvel Employé](exercices/Exercice_01_Nouvel_Employe.md) - Création utilisateur et groupes
    - [Exercice 02: Départ Employé](exercices/Exercice_02_Depart_Employe.md) - Désactivation et archivage
    - [Exercice 05: Reset Password](exercices/Exercice_05_Reset_Password.md) - Réinitialisation mot de passe

    **Niveau Intermédiaire:**

    - [Exercice 03: GPO Lecteur Réseau](exercices/Exercice_03_GPO_Lecteur_Reseau.md) - Drive mapping
    - [Exercice 04: Groupe Projet Client](exercices/Exercice_04_Groupe_Projet_Client.md) - Groupes inter-départementaux

    **Niveau Avancé:**

    - [Exercice 06: Délégation Contrôle](exercices/Exercice_06_Delegation_Controle.md) - Permissions OU
    - [Exercice 07: Onboarding Complet](exercices/Exercice_07_Scenario_Onboarding_Complet.md) - Scénario complet
    - [Exercice 08: Troubleshooting GPO](exercices/Exercice_08_Troubleshooting_GPO.md) - Diagnostic GPO
    - [Exercice 09: Crise Sécurité](exercices/Exercice_09_Scenario_Crise_Securite.md) - Gestion incident

---

## Dépannage

### Problèmes Courants et Solutions

| Symptôme | Cause Probable | Solution |
|----------|----------------|----------|
| **"Access denied" ou "Accès refusé"** | PowerShell ISE non lancé en tant qu'Administrateur | Fermer PowerShell ISE, clic droit → "Exécuter en tant qu'administrateur", relancer le script |
| **"Module ActiveDirectory not found"** | Module AD non chargé ou rôle AD DS non installé | Exécuter: `Import-Module ActiveDirectory` ou vérifier l'installation du rôle AD DS |
| **"OU already exists" pour toutes les OUs** | Script déjà exécuté précédemment | C'est normal si vous relancez le script. Appuyez sur 'N' pour sauter les étapes déjà faites, ou exécutez `CreativeHub_Cleanup.ps1` pour tout supprimer |
| **GPOs créées mais paramètres non appliqués sur les clients** | Délai de rafraîchissement GPO pas encore écoulé | Sur le client: exécuter `gpupdate /force` en tant qu'administrateur, puis redémarrer la session |
| **"The specified domain does not exist"** | Domaine maxtec.be non trouvé | Vérifier que vous êtes sur le contrôleur de domaine et que le domaine est fonctionnel: `Get-ADDomain` |
| **Utilisateurs créés mais pas dans les groupes** | Étape 5 du script sautée ou erreur | Relancer le script et répondre 'O' à l'étape 5, ou ajouter manuellement avec `Add-ADGroupMember` |
| **GPO liée mais ne s'applique pas à un utilisateur** | Filtrage de sécurité ou permissions insuffisantes | Vérifier dans GPMC: Onglet Délégation → S'assurer que "Utilisateurs authentifiés" a les permissions "Lecture" et "Appliquer la stratégie de groupe" |
| **Impossible de se connecter avec un compte utilisateur sur un client** | Compte pas encore répliqué, ou client pas joint au domaine | Attendre 5 minutes pour la réplication, vérifier que le client est bien joint au domaine: `nltest /dsgetdc:maxtec.be` |

### Commandes de Diagnostic

#### Vérifier l'état du domaine

```powershell
# Informations sur le domaine
Get-ADDomain | Format-List

# Vérifier le niveau fonctionnel
Get-ADDomain | Select-Object DomainMode, ForestMode

# Lister tous les contrôleurs de domaine
Get-ADDomainController -Filter * | Select-Object Name, IPv4Address, OperatingSystem
```

#### Vérifier les rôles Active Directory

```powershell
# Vérifier que le rôle AD DS est installé
Get-WindowsFeature -Name AD-Domain-Services

# Vérifier les rôles FSMO (maîtres d'opérations)
Get-ADDomain | Select-Object InfrastructureMaster, RIDMaster, PDCEmulator
Get-ADForest | Select-Object SchemaMaster, DomainNamingMaster
```

#### Vérifier les privilèges de l'utilisateur actuel

```powershell
# Voir avec quel compte vous êtes connecté
whoami

# Voir vos groupes (vérifier si vous êtes Admins du Domaine)
whoami /groups

# Vérifier les permissions sur une OU spécifique
(Get-Acl -Path "AD:\OU=CreativeHub,DC=maxtec,DC=be").Access | Format-Table IdentityReference, ActiveDirectoryRights
```

#### Vérifier la réplication AD

```powershell
# Vérifier l'état de la réplication
repadmin /replsummary

# Forcer la réplication
repadmin /syncall /AdeP
```

#### Tester la connectivité réseau avec le domaine

```powershell
# Tester la résolution DNS du domaine
nslookup maxtec.be

# Vérifier le contrôleur de domaine utilisé
nltest /dsgetdc:maxtec.be

# Tester la connexion LDAP
Test-ComputerSecureChannel -Verbose
```

---

---

## Fichiers Générés

Le laboratoire CreativeHub génère les fichiers suivants:

| Fichier | Emplacement | Description | Généré par |
|---------|-------------|-------------|------------|
| `CreativeHub_Utilisateurs.csv` | `C:\Labos\` | Liste de tous les utilisateurs avec propriétés | Script setup (étape 7) |
| `CreativeHub_Groupes.csv` | `C:\Labos\` | Liste des groupes avec membres | Script setup (étape 7) |
| `CreativeHub_OUs.csv` | `C:\Labos\` | Structure des OUs | Script setup (étape 7) |
| `GPO_*.html` | `C:\Labos\` | Rapports HTML des GPOs (optionnel) | Commandes de vérification |
| `CreativeHub_Utilisateurs_Complet.csv` | `C:\Labos\` | Export enrichi utilisateurs (optionnel) | Commandes de vérification |
| `CreativeHub_Groupes_Rapport.csv` | `C:\Labos\` | Rapport détaillé groupes (optionnel) | Commandes de vérification |

Tous ces fichiers sont en encodage **UTF-8** et peuvent être ouverts avec Excel, LibreOffice, ou tout éditeur de texte.

---

## Ressources Complémentaires

### Documentation Officielle Microsoft

- [Active Directory Domain Services Overview](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview)
- [New-ADOrganizationalUnit Cmdlet](https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-adorganizationalunit?view=windowsserver2022-ps)
- [New-ADUser Cmdlet](https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-aduser?view=windowsserver2025-ps)
- [New-ADGroup Cmdlet](https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-adgroup?view=windowsserver2022-ps)
- [Group Policy Management with PowerShell](https://learn.microsoft.com/en-us/powershell/module/grouppolicy/)
- [Set-GPRegistryValue Cmdlet](https://learn.microsoft.com/en-us/powershell/module/grouppolicy/set-gpregistryvalue?view=windowsserver2022-ps)

### Guides Pratiques

- [Best Practices for Organizing Active Directory](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/creating-an-organizational-unit-design)
- [Group Policy Best Practices](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/group-policy/group-policy-best-practices)
- [Active Directory Security Best Practices](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/best-practices-for-securing-active-directory)

---

## Évolutions Possibles du Laboratoire

Pour approfondir ce laboratoire dans le futur, vous pourriez:

1. **Ajouter des partages réseau réels**:
   - Créer `\\SERVEUR\Projets` et `\\SERVEUR\Ressources`
   - Configurer des permissions NTFS basées sur les groupes AD
   - Compléter la GPO de mappage de lecteurs avec Drive Maps Preferences

2. **Implémenter une politique de mots de passe renforcée**:
   - Fine-Grained Password Policy pour exiger des mots de passe plus complexes pour les admins
   - Historique des mots de passe, durée de vie maximale, etc.

3. **Ajouter des ordinateurs aux OUs Computers**:
   - Joindre des machines Windows 10/11 au domaine
   - Les déplacer dans les bonnes OUs (par département)
   - Créer des GPOs spécifiques aux ordinateurs (configuration logicielle, pare-feu, etc.)

4. **Créer des scripts de connexion (Logon Scripts)**:
   - Scripts PowerShell qui s'exécutent à la connexion de l'utilisateur
   - Mapper des imprimantes réseau selon le département
   - Afficher un message de bienvenue personnalisé

5. **Implémenter des quotas de stockage**:
   - Configurer des quotas sur les dossiers personnels utilisateurs
   - Utiliser File Server Resource Manager (FSRM)

6. **Audit et journalisation**:
   - Activer l'audit des connexions réussies/échouées
   - Audit des modifications d'objets AD (création/suppression utilisateurs)
   - Générer des rapports de sécurité

7. **Scénarios de panne et récupération**:
   - Simuler la corruption d'un compte utilisateur
   - Restaurer un objet supprimé depuis la corbeille AD
   - Gérer un compte verrouillé (lockout)

---

Ce laboratoire vous donne une expérience pratique réaliste de la gestion d'Active Directory dans un contexte d'entreprise moderne. Les compétences acquises ici sont directement transférables à l'administration de vrais environnements AD en production.
