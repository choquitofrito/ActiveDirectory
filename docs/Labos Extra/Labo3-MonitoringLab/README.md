# Laboratoire Active Directory: Monitoring et Audit

## Objectifs Pédagogiques

!!! info "Compétences visées"
    - **Comprendre l'importance du monitoring** dans une infrastructure Active Directory
    - **Configurer les politiques d'audit avancées** pour tracer les événements de sécurité
    - **Gérer les journaux d'événements Windows** (taille, rétention, analyse)
    - **Créer une structure organisationnelle** adaptée au monitoring et à la séparation des rôles
    - **Implémenter des comptes de service** dédiés aux outils de monitoring
    - **Appliquer des GPOs de sécurité** pour renforcer la surveillance de l'infrastructure

## Scénario Entreprise

!!! example "Contexte professionnel"
    **MonitoringTech SPRL** est une PME bruxelloise spécialisée dans les services informatiques gérés (Managed Services Provider). L'entreprise compte 24 employés répartis en 4 départements:

    - **IT Operations** (5 personnes): Gère l'infrastructure serveurs, réseau et virtualisation
    - **Security** (5 personnes): Responsable de la sécurité informatique, audits et conformité
    - **Ressources Humaines** (5 personnes): Gestion du personnel et formation
    - **Finance** (5 personnes): Comptabilité, contrôle de gestion, reporting financier

    Suite à un incident de sécurité récent (tentative d'accès non autorisé détectée tardivement), la direction a mandaté l'équipe IT Operations et Security pour **mettre en place une infrastructure de monitoring robuste** avec traçabilité complète des événements critiques.

    Le laboratoire simule cette infrastructure après déploiement des solutions de monitoring (PRTG, collecteur de logs SIEM, outils d'audit).

## Durée Estimée

!!! note "Temps d'exécution"
    - **Exécution du script**: 5-8 minutes
    - **Configuration manuelle des GPOs**: 15-20 minutes
    - **Exploration et vérification**: 20-30 minutes
    - **Total**: ~50 minutes

## Prérequis

!!! warning "Avant de commencer"
    - Windows Server 2022 avec rôle **AD DS installé et configuré**
    - Domaine **maxtec.be** fonctionnel
    - PowerShell ISE ouvert en tant qu'**Administrateur**
    - Modules PowerShell: `ActiveDirectory`, `GroupPolicy` (installés automatiquement avec AD DS)
    - Espace disque: ~500 MB libre pour les journaux d'événements étendus

## Structure Créée par le Script

### Vue d'ensemble de l'arborescence

```text
OU=MONITORING,DC=maxtec,DC=be
│
├── OU=ITOperations
│   ├── OU=Users (5 utilisateurs)
│   ├── OU=Computers (stations IT)
│   └── OU=Groups (GG-MONITORING-ITOperations-Users, GG-MONITORING-ITOperations-Admin)
│
├── OU=Security
│   ├── OU=Users (5 utilisateurs)
│   ├── OU=Computers (stations Security)
│   └── OU=Groups (GG-MONITORING-Security-Users, GG-MONITORING-Security-Admin, GG-MONITORING-SecurityAuditors)
│
├── OU=RH
│   ├── OU=Users (5 utilisateurs)
│   ├── OU=Computers (stations RH)
│   └── OU=Groups (GG-MONITORING-RH-Users, GG-MONITORING-RH-Admin)
│
├── OU=Finance
│   ├── OU=Users (5 utilisateurs)
│   ├── OU=Computers (stations Finance)
│   └── OU=Groups (GG-MONITORING-Finance-Users, GG-MONITORING-Finance-Admin)
│
├── OU=ServiceAccounts
│   ├── svc_monitoring (compte service PRTG/Nagios)
│   ├── svc_backup (compte service sauvegarde AD)
│   ├── svc_audit (compte service collecte logs)
│   ├── svc_replication (compte service vérification réplication)
│   └── GG-MONITORING-ServiceAccounts (groupe)
│
└── OU=Computers
    ├── OU=DomainControllers (MON-DC01, MON-DC02)
    ├── OU=Servers (MON-SRV-MONITORING, MON-SRV-LOG, MON-SRV-BACKUP, MON-SRV-FILE)
    └── OU=Workstations (MON-WS-IT01, MON-WS-IT02, MON-WS-SEC01, MON-WS-SEC02, MON-WS-RH01, MON-WS-FIN01)
```

### Unités Organisationnelles (OUs)

!!! info "Structure des OUs"
    **OU Racine:**

    - `OU=MONITORING,DC=maxtec,DC=be` - Conteneur principal du laboratoire

    **Départements (4 OUs):**

    | Département | Chemin DN | Sous-OUs |
    |-------------|-----------|----------|
    | **ITOperations** | `OU=ITOperations,OU=MONITORING,...` | Users, Computers, Groups |
    | **Security** | `OU=Security,OU=MONITORING,...` | Users, Computers, Groups |
    | **RH** | `OU=RH,OU=MONITORING,...` | Users, Computers, Groups |
    | **Finance** | `OU=Finance,OU=MONITORING,...` | Users, Computers, Groups |

    **OUs Spéciales:**

    - `OU=ServiceAccounts` - Comptes de service pour outils monitoring
    - `OU=Computers` - Tous les ordinateurs (DCs, serveurs, stations)
        - `OU=DomainControllers` - Contrôleurs de domaine
        - `OU=Servers` - Serveurs d'infrastructure
        - `OU=Workstations` - Stations de travail utilisateurs

!!! warning "Protection contre suppression"
    Toutes les OUs sont créées avec `-ProtectedFromAccidentalDeletion $false` pour faciliter les exercices de reconstruction et nettoyage du laboratoire.

### Utilisateurs

#### Département IT Operations

!!! info "Équipe infrastructure et opérations"
    | Nom Complet | Login | Email | Fonction | Mot de passe |
    |-------------|-------|-------|----------|--------------|
    | **Alexandre Martin** | alexandre | alexandre@maxtec.be | Responsable Infrastructure | Monitor2024! |
    | **Béatrice Dubois** | beatrice | beatrice@maxtec.be | Administrateur Systèmes | Monitor2024! |
    | **Charles Lefebvre** | charles | charles@maxtec.be | Ingénieur Réseau | Monitor2024! |
    | **Diane Bernard** | diane | diane@maxtec.be | Technicien Support | Monitor2024! |
    | **Émile Rousseau** | emile | emile@maxtec.be | Spécialiste Virtualisation | Monitor2024! |

    **Logique d'appartenance:**

    - TOUS les utilisateurs → `GG-MONITORING-ITOperations-Users`
    - Alexandre (premier alphabétiquement) → `GG-MONITORING-ITOperations-Admin`

#### Département Security

!!! info "Équipe sécurité et audit"
    | Nom Complet | Login | Email | Fonction | Mot de passe |
    |-------------|-------|-------|----------|--------------|
    | **Fabien Moreau** | fabien | fabien@maxtec.be | Responsable Sécurité (RSSI) | Monitor2024! |
    | **Gabrielle Simon** | gabrielle | gabrielle@maxtec.be | Analyste Sécurité Senior | Monitor2024! |
    | **Henri Laurent** | henri | henri@maxtec.be | Auditeur Systèmes | Monitor2024! |
    | **Isabelle Michel** | isabelle | isabelle@maxtec.be | Spécialiste Conformité | Monitor2024! |
    | **Julien Leroy** | julien | julien@maxtec.be | Analyste SOC | Monitor2024! |

    **Logique d'appartenance:**

    - TOUS les utilisateurs → `GG-MONITORING-Security-Users`
    - Fabien (premier alphabétiquement) → `GG-MONITORING-Security-Admin`
    - Henri, Isabelle, Julien → `GG-MONITORING-SecurityAuditors` (auditeurs en lecture seule)

#### Département Ressources Humaines

!!! info "Équipe RH"
    | Nom Complet | Login | Email | Fonction | Mot de passe |
    |-------------|-------|-------|----------|--------------|
    | **Karine Fontaine** | karine | karine@maxtec.be | Directrice Ressources Humaines | Monitor2024! |
    | **Laurent Chevalier** | laurent | laurent@maxtec.be | Gestionnaire Paie | Monitor2024! |
    | **Marie Girard** | marie | marie@maxtec.be | Responsable Recrutement | Monitor2024! |
    | **Nicolas Bonnet** | nicolas | nicolas@maxtec.be | Assistant RH | Monitor2024! |
    | **Olivia Dupont** | olivia | olivia@maxtec.be | Formatrice Interne | Monitor2024! |

    **Logique d'appartenance:**

    - TOUS les utilisateurs → `GG-MONITORING-RH-Users`
    - Karine (premier alphabétiquement) → `GG-MONITORING-RH-Admin`

#### Département Finance

!!! info "Équipe financière"
    | Nom Complet | Login | Email | Fonction | Mot de passe |
    |-------------|-------|-------|----------|--------------|
    | **Pascal Roux** | pascal | pascal@maxtec.be | Directeur Financier (CFO) | Monitor2024! |
    | **Quentin Garnier** | quentin | quentin@maxtec.be | Contrôleur de Gestion | Monitor2024! |
    | **Rachel Fabre** | rachel | rachel@maxtec.be | Comptable Senior | Monitor2024! |
    | **Sylvain Perrin** | sylvain | sylvain@maxtec.be | Analyste Financier | Monitor2024! |
    | **Théa Morel** | thea | thea@maxtec.be | Assistante Comptable | Monitor2024! |

    **Logique d'appartenance:**

    - TOUS les utilisateurs → `GG-MONITORING-Finance-Users`
    - Pascal (premier alphabétiquement) → `GG-MONITORING-Finance-Admin`

#### Comptes de Service

!!! warning "Comptes techniques pour monitoring"
    | Nom Compte | Description | Mot de passe | Propriétés |
    |------------|-------------|--------------|------------|
    | **svc_monitoring** | Compte service PRTG/Nagios | ServiceP@ss2024! | PasswordNeverExpires |
    | **svc_backup** | Compte service sauvegarde AD | ServiceP@ss2024! | PasswordNeverExpires |
    | **svc_audit** | Compte service collecte logs audit | ServiceP@ss2024! | PasswordNeverExpires |
    | **svc_replication** | Compte service vérification réplication AD | ServiceP@ss2024! | PasswordNeverExpires |

    **Tous les comptes de service** appartiennent au groupe `GG-MONITORING-ServiceAccounts`.

!!! info "Propriétés des comptes utilisateurs"
    - Comptes **activés** par défaut
    - Mot de passe: `Monitor2024!` (utilisateurs normaux) ou `ServiceP@ss2024!` (comptes service)
    - **Pas de changement obligatoire** du mot de passe à la première connexion
    - Format email: `login@maxtec.be`

### Groupes de Sécurité

!!! danger "Convention de nommage OBLIGATOIRE"
    TOUS les groupes utilisent le préfixe **GG-** (Global Group). Cette convention est **strictement appliquée** dans tout le laboratoire.

#### Groupes Départementaux

!!! info "Groupes par département"
    | Nom du Groupe | Scope | Description | Membres |
    |---------------|-------|-------------|---------|
    | **GG-MONITORING-ITOperations-Users** | Global | Tous utilisateurs IT Ops | alexandre, beatrice, charles, diane, emile |
    | **GG-MONITORING-ITOperations-Admin** | Global | Administrateurs IT Ops | alexandre |
    | **GG-MONITORING-Security-Users** | Global | Tous utilisateurs Security | fabien, gabrielle, henri, isabelle, julien |
    | **GG-MONITORING-Security-Admin** | Global | Administrateurs Security | fabien |
    | **GG-MONITORING-SecurityAuditors** | Global | Auditeurs en lecture seule | henri, isabelle, julien |
    | **GG-MONITORING-RH-Users** | Global | Tous utilisateurs RH | karine, laurent, marie, nicolas, olivia |
    | **GG-MONITORING-RH-Admin** | Global | Administrateurs RH | karine |
    | **GG-MONITORING-Finance-Users** | Global | Tous utilisateurs Finance | pascal, quentin, rachel, sylvain, thea |
    | **GG-MONITORING-Finance-Admin** | Global | Administrateurs Finance | pascal |

#### Groupes Spéciaux Monitoring

!!! tip "Groupes transverses pour monitoring"
    | Nom du Groupe | Scope | Description | Membres |
    |---------------|-------|-------------|---------|
    | **GG-MONITORING-MonitoringAdmins** | Global | Accès complet monitoring (PRTG, SIEM, logs) | alexandre, beatrice, fabien |
    | **GG-MONITORING-ServiceAccounts** | Global | Comptes de service monitoring | svc_monitoring, svc_backup, svc_audit, svc_replication |

### Ordinateurs

#### Contrôleurs de Domaine

!!! info "DCs - Infrastructure AD"
    | Nom | Description | Localisation |
    |-----|-------------|--------------|
    | **MON-DC01** | Contrôleur de domaine principal | DataCenter Brussels |
    | **MON-DC02** | Contrôleur de domaine secondaire | DataCenter Antwerp |

#### Serveurs d'Infrastructure

!!! info "Serveurs - Outils monitoring et support"
    | Nom | Description | Localisation |
    |-----|-------------|--------------|
    | **MON-SRV-MONITORING** | Serveur monitoring PRTG/Nagios | DataCenter Brussels |
    | **MON-SRV-LOG** | Serveur centralisation logs (SIEM) | DataCenter Brussels |
    | **MON-SRV-BACKUP** | Serveur sauvegarde et récupération | DataCenter Antwerp |
    | **MON-SRV-FILE** | Serveur fichiers départemental | DataCenter Brussels |

#### Stations de Travail

!!! info "Workstations - Postes utilisateurs"
    | Nom | Utilisateur Assigné | Département | Localisation |
    |-----|---------------------|-------------|--------------|
    | **MON-WS-IT01** | Alexandre Martin | IT Operations | Brussels Office - Floor 2 |
    | **MON-WS-IT02** | Béatrice Dubois | IT Operations | Brussels Office - Floor 2 |
    | **MON-WS-SEC01** | Fabien Moreau | Security | Brussels Office - Floor 3 |
    | **MON-WS-SEC02** | Gabrielle Simon | Security | Brussels Office - Floor 3 |
    | **MON-WS-RH01** | Karine Fontaine | RH | Brussels Office - Floor 1 |
    | **MON-WS-FIN01** | Pascal Roux | Finance | Brussels Office - Floor 1 |

### Stratégies de Groupe (GPOs)

!!! warning "Configuration manuelle requise"
    Les GPOs sont créées comme **shells vides** par le script. La configuration des paramètres doit être effectuée **manuellement via GPMC** en suivant les instructions détaillées ci-dessous.

#### GPO 1: Configuration Journaux Événements

!!! info "MONITORING - Configuration Journaux Événements"
    **Objectif:** Augmenter la taille des journaux Windows pour conserver plus d'événements de monitoring

    **Liée à:** `OU=MONITORING,DC=maxtec,DC=be`

    **Configuration manuelle dans GPMC:**

    **Étape 1 - Journal Sécurité (Security Log):**

    1. Computer Configuration → Policies → Administrative Templates → Windows Components
    2. Event Log Service → Security
    3. **Specify the maximum log file size (KB)** = **Enabled** → Valeur: `2097151` KB (2 GB)
    4. **Control Event Log behavior when the log file reaches its maximum size** = **Enabled** → Sélectionner: "Overwrite events as needed"

    **Étape 2 - Journal Application:**

    1. Computer Configuration → Policies → Administrative Templates → Windows Components
    2. Event Log Service → Application
    3. **Specify the maximum log file size (KB)** = **Enabled** → Valeur: `524288` KB (512 MB)

    **Étape 3 - Journal Système:**

    1. Computer Configuration → Policies → Administrative Templates → Windows Components
    2. Event Log Service → System
    3. **Specify the maximum log file size (KB)** = **Enabled** → Valeur: `524288` KB (512 MB)

    **Vérification:**

    ```powershell
    # Appliquer la GPO
    gpupdate /force

    # Vérifier la taille du journal Sécurité
    Get-WinEvent -ListLog Security | Select-Object LogName, MaximumSizeInBytes

    # Ouvrir Event Viewer et vérifier les propriétés
    eventvwr.msc
    # Clic droit sur Security → Properties → Maximum log size = 2 GB
    ```

#### GPO 2: Restrictions Stations Sensibles

!!! info "MONITORING - Restrictions Stations Sensibles"
    **Objectif:** Bloquer l'accès aux périphériques USB amovibles sur les stations IT et Security pour éviter l'exfiltration de données

    **Liée à:**

    - `OU=Computers,OU=Security,OU=MONITORING,...`
    - `OU=Computers,OU=ITOperations,OU=MONITORING,...`

    **Configuration manuelle dans GPMC:**

    **Bloquer périphériques USB amovibles:**

    1. Computer Configuration → Policies → Administrative Templates → System
    2. Removable Storage Access
    3. **All Removable Storage classes: Deny all access** = **Enabled**

    **Vérification:**

    1. Connecter une clé USB à un ordinateur du département Security ou IT Operations
    2. Exécuter: `gpupdate /force`
    3. La clé USB doit être **bloquée** avec message d'erreur Windows
    4. Vérifier dans Event Viewer: Security log → Event ID 4663 (tentative accès refusé)

#### GPO 3: Verrouillage Session Automatique

!!! info "MONITORING - Verrouillage Session Automatique"
    **Objectif:** Verrouiller automatiquement les sessions inactives après 10 minutes pour éviter les accès non autorisés

    **Liée à:** `OU=MONITORING,DC=maxtec,DC=be`

    **Configuration manuelle dans GPMC:**

    **Délai verrouillage automatique:**

    1. Computer Configuration → Policies → Windows Settings → Security Settings
    2. Local Policies → Security Options
    3. **Interactive logon: Machine inactivity limit** = **600 secondes** (10 minutes)

    **Vérification:**

    1. Appliquer la GPO: `gpupdate /force`
    2. Ouvrir une session utilisateur
    3. Laisser l'ordinateur inactif pendant 10 minutes
    4. L'écran doit se verrouiller automatiquement avec écran de connexion Windows

### Politiques de Sécurité

#### Politique de Mots de Passe (Domain-level)

!!! success "Configurée automatiquement par PowerShell"
    Cette politique est **directement configurée par le script** via `Set-ADDefaultDomainPasswordPolicy`:

    | Paramètre | Valeur | Description |
    |-----------|--------|-------------|
    | **Longueur minimale** | 12 caractères | Force des mots de passe robustes |
    | **Complexité** | Activée | Majuscules, minuscules, chiffres, symboles requis |
    | **Âge maximum** | 90 jours | Rotation obligatoire tous les 3 mois |
    | **Âge minimum** | 1 jour | Empêche changements répétitifs rapides |
    | **Historique** | 24 mots de passe | Mémorise les 24 derniers mots de passe |
    | **Seuil verrouillage** | 5 tentatives | Compte bloqué après 5 échecs |
    | **Durée verrouillage** | 30 minutes | Déverrouillage automatique après 30 min |
    | **Fenêtre observation** | 30 minutes | Compteur réinitialisé après 30 min sans échec |

    **Vérification:**

    ```powershell
    # Consulter la politique actuelle
    Get-ADDefaultDomainPasswordPolicy -Identity "maxtec.be"

    # Tester en modifiant le mot de passe d'un utilisateur
    Set-ADAccountPassword -Identity "diane" -NewPassword (ConvertTo-SecureString "faible" -AsPlainText -Force)
    # Doit échouer car ne respecte pas les critères
    ```

#### Politiques d'Audit Avancées

!!! success "Configurées automatiquement par auditpol.exe"
    Le script active **12 politiques d'audit** via la commande `auditpol /set`. Les événements sont enregistrés dans le journal **Sécurité** de Windows.

    | Catégorie | Sous-catégorie | Success | Failure | Événements tracés |
    |-----------|----------------|---------|---------|-------------------|
    | **Logon/Logoff** | Logon | ✅ | ✅ | Connexions utilisateurs (Event ID 4624, 4625) |
    | **Logon/Logoff** | Logoff | ✅ | ❌ | Déconnexions utilisateurs (Event ID 4634, 4647) |
    | **Account Logon** | Credential Validation | ✅ | ✅ | Validation credentials Kerberos/NTLM (Event ID 4768, 4769, 4771) |
    | **Account Management** | User Account Management | ✅ | ✅ | Création/modification/suppression comptes (Event ID 4720, 4722, 4723, 4724, 4726) |
    | **Account Management** | Security Group Management | ✅ | ✅ | Modifications groupes de sécurité (Event ID 4727, 4728, 4729, 4730, 4731, 4732, 4733, 4756, 4757, 4758) |
    | **Account Management** | Computer Account Management | ✅ | ✅ | Gestion comptes ordinateurs (Event ID 4741, 4742, 4743) |
    | **Policy Change** | Audit Policy Change | ✅ | ✅ | Modifications politiques d'audit (Event ID 4719, 4912) |
    | **Policy Change** | Authentication Policy Change | ✅ | ✅ | Modifications politiques authentification (Event ID 4706, 4707, 4713, 4716, 4717, 4718, 4739) |
    | **Privilege Use** | Sensitive Privilege Use | ✅ | ✅ | Utilisation privilèges sensibles (Event ID 4672, 4673, 4674) |
    | **DS Access** | Directory Service Access | ✅ | ✅ | Accès objets AD DS (Event ID 4662) |
    | **DS Access** | Directory Service Changes | ✅ | ❌ | Modifications objets AD DS (Event ID 5136, 5137, 5138, 5139, 5141) |
    | **Object Access** | File Share | ✅ | ✅ | Accès partages réseau (Event ID 5140, 5142, 5143, 5144, 5145) |

    **Vérification:**

    ```powershell
    # Afficher toutes les politiques d'audit configurées
    auditpol /get /category:*

    # Vérifier une sous-catégorie spécifique
    auditpol /get /subcategory:"Logon"

    # Consulter les événements d'audit dans Event Viewer
    Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4624} -MaxEvents 20 | Format-Table TimeCreated, Message -AutoSize

    # Filtrer événements échecs de connexion
    Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4625} -MaxEvents 10
    ```

## Instructions d'Exécution

### Étape 1: Préparer l'environnement

!!! warning "Prérequis techniques"
    1. Vous devez être connecté en tant qu'**Administrateur du domaine** sur le contrôleur de domaine
    2. Le domaine **maxtec.be** doit être fonctionnel
    3. Ouvrir **PowerShell ISE** en tant qu'Administrateur (clic droit → Exécuter en tant qu'administrateur)

### Étape 2: Copier le script

!!! tip "Récupération du script"
    1. Localisez le fichier `MonitoringLab_Setup.ps1` dans le répertoire `scripts/`
    2. **Option A**: Ouvrir directement dans PowerShell ISE (File → Open → `MonitoringLab_Setup.ps1`)
    3. **Option B**: Copier-coller le contenu complet du script dans l'éditeur PowerShell ISE

### Étape 3: Lire les commentaires

!!! note "Comprendre avant d'exécuter"
    Avant d'exécuter, parcourez le script pour comprendre:

    - Les 9 étapes principales (OUs, utilisateurs, groupes, ordinateurs, GPOs, etc.)
    - Les conventions de nommage (préfixe GG- pour les groupes)
    - Les mots de passe par défaut utilisés
    - Les politiques de sécurité appliquées

### Étape 4: Exécuter le script

!!! success "Lancement interactif"
    1. Dans PowerShell ISE, appuyer sur **F5** (ou cliquer sur le bouton vert "Run Script")
    2. Le script vous demandera confirmation pour **chaque étape majeure**
    3. Répondre avec:
        - **O** (Oui) pour exécuter l'étape
        - **N** (Non) pour sauter l'étape
        - **Q** (Quitter) pour arrêter complètement le script

    4. Observer la sortie console avec codes couleur:
        - 🟢 **Vert**: Objet créé avec succès
        - 🟡 **Jaune**: Objet existe déjà (idempotence)
        - 🔴 **Rouge**: Erreur lors de la création

### Étape 5: Configurer les GPOs manuellement

!!! warning "Configuration GPMC requise"
    Après exécution du script, **3 GPOs sont créées mais vides**. Vous devez les configurer manuellement:

    1. Ouvrir **Group Policy Management Console** (gpmc.msc)
    2. Naviguer vers **Forest: maxtec.be → Domains → maxtec.be → Group Policy Objects**
    3. Pour chaque GPO créée (voir section GPOs ci-dessus):
        - Clic droit → **Edit**
        - Suivre les chemins de navigation indiqués dans la section GPOs
        - Configurer les paramètres exacts spécifiés
        - Fermer GPMC Editor

    4. Appliquer les GPOs: `gpupdate /force`

### Étape 6: Vérifier la création

!!! tip "Validation post-exécution"
    Utilisez les commandes PowerShell ci-dessous pour vérifier que tout est correct (voir section "Vérification Post-Exécution").

## Vérification Post-Exécution

### Commandes PowerShell de Vérification

!!! info "Vérifier les OUs créées"
    ```powershell
    # Afficher toutes les OUs sous MONITORING
    Get-ADOrganizationalUnit -Filter * -SearchBase "OU=MONITORING,DC=maxtec,DC=be" |
        Select-Object Name, DistinguishedName |
        Sort-Object DistinguishedName

    # Compter le nombre total d'OUs
    (Get-ADOrganizationalUnit -Filter * -SearchBase "OU=MONITORING,DC=maxtec,DC=be").Count
    # Attendu: ~21 OUs
    ```

!!! info "Vérifier tous les utilisateurs créés"
    ```powershell
    # Lister tous les utilisateurs dans MONITORING
    Get-ADUser -Filter * -SearchBase "OU=MONITORING,DC=maxtec,DC=be" -Properties EmailAddress, Title, Department |
        Select-Object Name, SamAccountName, EmailAddress, Title, Department, Enabled |
        Format-Table -AutoSize

    # Compter les utilisateurs
    (Get-ADUser -Filter * -SearchBase "OU=MONITORING,DC=maxtec,DC=be").Count
    # Attendu: 24 utilisateurs (20 normaux + 4 comptes service)

    # Vérifier un utilisateur spécifique
    Get-ADUser -Identity "alexandre" -Properties *
    ```

!!! info "Vérifier les groupes et leurs membres"
    ```powershell
    # Lister tous les groupes avec préfixe GG-MONITORING
    Get-ADGroup -Filter 'Name -like "GG-MONITORING*"' |
        Select-Object Name, GroupScope, GroupCategory, Description |
        Format-Table -AutoSize

    # Afficher les membres d'un groupe spécifique
    Get-ADGroupMember -Identity "GG-MONITORING-ITOperations-Users" |
        Select-Object Name, SamAccountName, objectClass

    # Afficher tous les groupes avec leurs membres (détaillé)
    Get-ADGroup -Filter * -SearchBase "OU=MONITORING,DC=maxtec,DC=be" | ForEach-Object {
        Write-Host "`n[GROUPE] $($_.Name)" -ForegroundColor Cyan
        Get-ADGroupMember -Identity $_.Name | Select-Object Name, SamAccountName | Format-Table
    }
    ```

!!! info "Vérifier les ordinateurs créés"
    ```powershell
    # Lister tous les ordinateurs dans MONITORING
    Get-ADComputer -Filter * -SearchBase "OU=MONITORING,DC=maxtec,DC=be" -Properties Description, Location |
        Select-Object Name, Description, Location, Enabled |
        Format-Table -AutoSize

    # Compter les ordinateurs
    (Get-ADComputer -Filter * -SearchBase "OU=MONITORING,DC=maxtec,DC=be").Count
    # Attendu: 12 ordinateurs (2 DCs + 4 serveurs + 6 stations)

    # Lister uniquement les DCs
    Get-ADComputer -Filter * -SearchBase "OU=DomainControllers,OU=Computers,OU=MONITORING,DC=maxtec,DC=be"
    ```

!!! info "Vérifier les GPOs créées"
    ```powershell
    # Lister toutes les GPOs MONITORING
    Get-GPO -All | Where-Object {$_.DisplayName -like "MONITORING*"} |
        Select-Object DisplayName, GpoStatus, CreationTime, Description |
        Format-Table -AutoSize

    # Vérifier les liens GPO
    Get-GPO -Name "MONITORING - Configuration Journaux Événements" | Get-GPOReport -ReportType Xml
    ```

!!! info "Vérifier la politique de mots de passe"
    ```powershell
    # Afficher la politique de mots de passe du domaine
    Get-ADDefaultDomainPasswordPolicy -Identity "maxtec.be"

    # Résultat attendu:
    # MinPasswordLength: 12
    # ComplexityEnabled: True
    # MaxPasswordAge: 90 jours
    # LockoutThreshold: 5
    ```

!!! info "Vérifier les politiques d'audit"
    ```powershell
    # Afficher toutes les politiques d'audit
    auditpol /get /category:*

    # Vérifier une catégorie spécifique
    auditpol /get /category:"Account Logon"

    # Vérifier les événements d'audit récents
    Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4624} -MaxEvents 5 | Format-List
    ```

!!! success "Exporter la structure en CSV pour référence"
    ```powershell
    # Exporter les utilisateurs
    Get-ADUser -Filter * -SearchBase "OU=MONITORING,DC=maxtec,DC=be" -Properties EmailAddress, Title, Department |
        Select-Object Name, SamAccountName, EmailAddress, Title, Department, Enabled |
        Export-Csv -Path "C:\Labos\MonitoringLab_Utilisateurs.csv" -NoTypeInformation -Encoding UTF8

    # Exporter les groupes avec membres
    $groups = Get-ADGroup -Filter * -SearchBase "OU=MONITORING,DC=maxtec,DC=be"
    $groupData = @()
    foreach ($group in $groups) {
        $members = Get-ADGroupMember -Identity $group.Name | Select-Object -ExpandProperty SamAccountName
        $groupData += [PSCustomObject]@{
            GroupName = $group.Name
            Members = ($members -join "; ")
            MemberCount = $members.Count
        }
    }
    $groupData | Export-Csv -Path "C:\Labos\MonitoringLab_Groupes.csv" -NoTypeInformation -Encoding UTF8

    # Exporter les ordinateurs
    Get-ADComputer -Filter * -SearchBase "OU=MONITORING,DC=maxtec,DC=be" -Properties Description, Location |
        Export-Csv -Path "C:\Labos\MonitoringLab_Ordinateurs.csv" -NoTypeInformation -Encoding UTF8
    ```

### Vérification Manuelle (GUI)

!!! tip "Vérification via outils graphiques"
    **Active Directory Users and Computers (dsa.msc):**

    1. Ouvrir **Active Directory Users and Computers**
    2. Naviguer vers **maxtec.be → MONITORING**
    3. Vérifier la présence de toutes les OUs départementales
    4. Dans chaque département:
        - Vérifier les utilisateurs dans `OU=Users`
        - Vérifier les groupes dans `OU=Groups`
        - Double-cliquer sur un groupe → Onglet **Members** → Vérifier les appartenances

    5. Vérifier les comptes de service dans `OU=ServiceAccounts`
    6. Vérifier les ordinateurs dans `OU=Computers` (DCs, Servers, Workstations)

    **Group Policy Management Console (gpmc.msc):**

    1. Ouvrir **Group Policy Management**
    2. Naviguer vers **Forest: maxtec.be → Domains → maxtec.be → Group Policy Objects**
    3. Vérifier la présence des 3 GPOs MONITORING-*
    4. Clic droit sur chaque GPO → **Edit** → Vérifier les paramètres configurés
    5. Vérifier les liens: naviguer vers **OU=MONITORING** → Onglet **Linked Group Policy Objects**

    **Event Viewer (eventvwr.msc):**

    1. Ouvrir **Event Viewer**
    2. Naviguer vers **Windows Logs → Security**
    3. Clic droit → **Properties** → Vérifier **Maximum log size = 2 GB** (après configuration GPO)
    4. Filtrer les événements d'audit:
        - Event ID 4624: Connexions réussies
        - Event ID 4625: Échecs de connexion
        - Event ID 4720: Création compte utilisateur
        - Event ID 4728: Ajout membre à un groupe

## Concepts Clés Démontrés

!!! abstract "Compétences Active Directory mises en pratique"
    **1. Architecture AD pour le Monitoring**

    - Séparation des responsabilités via OUs départementales
    - OU dédiée aux comptes de service (meilleure pratique de sécurité)
    - OU centralisée pour les ordinateurs avec sous-catégorisation (DCs/Servers/Workstations)

    **2. Gestion des Identités et Accès (IAM)**

    - Comptes utilisateurs avec attributs complets (titre, département, email)
    - Comptes de service avec propriétés spécifiques (PasswordNeverExpires, CannotChangePassword)
    - Groupes de sécurité Global Groups (GG-) pour gérer les permissions
    - Séparation rôles admin vs. utilisateurs standards

    **3. Audit et Traçabilité**

    - Politiques d'audit avancées via `auditpol.exe`
    - Traçage des connexions, modifications de comptes, changements de politiques
    - Accès aux objets AD DS et partages fichiers
    - Journaux d'événements étendus pour conserver l'historique

    **4. Politiques de Sécurité**

    - Politique de mots de passe renforcée (12 caractères, complexité, rotation)
    - Verrouillage automatique des comptes après tentatives échouées
    - Verrouillage automatique des sessions inactives
    - Restriction des périphériques USB pour limiter l'exfiltration de données

    **5. Group Policy Objects (GPOs)**

    - Création de GPOs via PowerShell
    - Configuration manuelle dans GPMC pour paramètres Windows natifs
    - Liaison de GPOs à des OUs spécifiques (héritage)
    - Application sélective selon les départements

    **6. Monitoring Infrastructure**

    - Comptes de service dédiés pour outils de monitoring (PRTG, Nagios, SIEM)
    - Groupe spécial MonitoringAdmins pour accès administratif complet
    - Groupe SecurityAuditors pour auditeurs en lecture seule
    - Serveurs dédiés pour centralisation logs et backups

## Exercices Pratiques

!!! tip "Exercices disponibles"
    Le laboratoire Monitoring comprend **6 exercices progressifs** avec scripts de vérification automatique:

    **Niveau Débutant:**

    - [Exercice 01: Exploration de la Structure Monitoring](exercices/Exercice_01_Exploration_Structure.md) - Découverte guidée de l'arborescence AD et des objets créés
    - [Exercice 02: Analyse des Événements d'Audit](exercices/Exercice_02_Analyse_Evenements.md) - Consultation des logs Security et identification des événements critiques

    **Niveau Intermédiaire:**

    - [Exercice 03: Configuration Complète des GPOs](exercices/Exercice_03_Configuration_GPOs.md) - Configuration manuelle des 3 GPOs dans GPMC et tests de fonctionnement
    - [Exercice 04: Gestion des Comptes de Service](exercices/Exercice_04_Comptes_Service.md) - Modification des comptes service et attribution de permissions monitoring

    **Niveau Avancé:**

    - [Exercice 05: Création d'une Politique d'Audit Personnalisée](exercices/Exercice_05_Audit_Personnalise.md) - Définir et implémenter une nouvelle politique d'audit pour un besoin métier spécifique
    - [Exercice 06: Simulation Incident de Sécurité et Investigation](exercices/Exercice_06_Incident_Investigation.md) - Scénario réaliste d'incident avec analyse forensique des logs AD

## Dépannage

### Problèmes Courants

!!! warning "Erreurs fréquentes et solutions"
    | Erreur | Cause Possible | Solution |
    |--------|---------------|----------|
    | "OU already exists" | Structure déjà créée lors d'une exécution précédente | Utiliser le script `MonitoringLab_Cleanup.ps1` pour nettoyer, ou appuyer sur 'N' pour sauter l'étape |
    | "Access denied" | PowerShell ISE non exécuté en tant qu'Administrateur | Fermer PowerShell ISE, clic droit → Exécuter en tant qu'administrateur |
    | "Module ActiveDirectory not found" | Module AD non chargé (rare avec AD DS installé) | Exécuter: `Import-Module ActiveDirectory` |
    | "Cannot validate argument on parameter 'Identity'" | Erreur de syntaxe DN ou nom groupe incorrect | Vérifier l'orthographe exacte du DN dans le script (respecter majuscules/minuscules) |
    | "The specified account already exists" | Utilisateur existe déjà dans AD | Le script est idempotent: il affichera un message jaune et continuera |
    | GPO créée mais paramètres vides | Configuration manuelle non effectuée | Ouvrir GPMC et suivre les instructions de configuration dans la section GPOs ci-dessus |
    | "auditpol : Access is denied" | Permissions insuffisantes | Exécuter PowerShell en tant qu'Administrateur du domaine |

### Commandes de Diagnostic

!!! info "Commandes utiles pour diagnostiquer les problèmes"
    **Vérifier le rôle AD DS:**

    ```powershell
    # Vérifier que AD DS est installé et démarré
    Get-WindowsFeature -Name AD-Domain-Services

    # Résultat attendu: Install State = Installed
    ```

    **Vérifier le domaine actuel:**

    ```powershell
    # Afficher les informations du domaine
    Get-ADDomain

    # Vérifier le nom DNS du domaine
    (Get-ADDomain).DNSRoot
    # Attendu: maxtec.be
    ```

    **Vérifier les privilèges de l'utilisateur connecté:**

    ```powershell
    # Vérifier l'appartenance aux groupes Admins
    whoami /groups | findstr "Admins"

    # Ou avec PowerShell
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    # Doit retourner: True
    ```

    **Vérifier la connectivité avec le DC:**

    ```powershell
    # Tester la connexion LDAP au DC
    Test-Connection -ComputerName (Get-ADDomainController).HostName -Count 2

    # Afficher le DC actuellement utilisé
    (Get-ADDomainController).HostName
    ```

    **Vérifier les modules PowerShell chargés:**

    ```powershell
    # Lister les modules importés
    Get-Module

    # Vérifier spécifiquement ActiveDirectory et GroupPolicy
    Get-Module -Name ActiveDirectory, GroupPolicy

    # Si absents, les importer manuellement
    Import-Module ActiveDirectory
    Import-Module GroupPolicy
    ```

    **Diagnostic complet de l'environnement AD:**

    ```powershell
    # Script de diagnostic complet
    Write-Host "=== Diagnostic Environnement AD ===" -ForegroundColor Cyan
    Write-Host "`nDomaine:" -ForegroundColor Yellow
    Get-ADDomain | Select-Object Name, DNSRoot, DomainMode

    Write-Host "`nContrôleur de domaine:" -ForegroundColor Yellow
    Get-ADDomainController | Select-Object HostName, IPv4Address, OperatingSystem

    Write-Host "`nUtilisateur actuel:" -ForegroundColor Yellow
    whoami

    Write-Host "`nPrivilèges administratifs:" -ForegroundColor Yellow
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    Write-Host "`nModules PowerShell chargés:" -ForegroundColor Yellow
    Get-Module | Select-Object Name, Version
    ```

## Évolutions Possibles du Laboratoire

!!! tip "Extensions futures pour approfondir l'apprentissage"
    Pour approfondir ce laboratoire dans des sessions avancées, vous pourriez:

    1. **Intégration SIEM Réel**
        - Installer un collecteur de logs (ELK Stack, Splunk Free, Wazuh)
        - Configurer la collecte automatique des événements Windows Security
        - Créer des tableaux de bord de monitoring en temps réel

    2. **Fine-Grained Password Policies (FGPP)**
        - Créer des politiques de mots de passe différenciées par département
        - Politique plus stricte pour Security (15 caractères minimum)
        - Politique moins stricte pour RH (10 caractères)

    3. **Monitoring de Réplication AD**
        - Scripts PowerShell pour surveiller l'état de réplication entre MON-DC01 et MON-DC02
        - Alertes automatiques en cas de problème de réplication
        - Dashboard de santé AD avec `Get-ADReplicationFailure`

    4. **Sauvegarde et Restauration AD**
        - Configuration de sauvegardes système Windows Server Backup
        - Sauvegarde de l'état système AD (System State)
        - Exercices de restauration autoritaire et non-autoritaire

    5. **Audit Avancé avec PowerShell**
        - Scripts de génération de rapports d'audit automatiques
        - Détection d'anomalies (connexions en dehors des heures ouvrables)
        - Alerting par email lors d'événements critiques

    6. **Intégration Azure AD Connect (Hybride)**
        - Synchronisation avec Azure AD pour simulation cloud hybride
        - Monitoring de la synchronisation
        - Audit des identités cloud et on-premises

    7. **Scénarios de Réponse aux Incidents**
        - Exercices de compromission simulée (compte piraté)
        - Procédures de réponse (désactivation compte, analyse logs)
        - Post-mortem et documentation d'incident

    8. **Performance Monitoring AD**
        - Compteurs de performance Windows (LDAP queries, authentications)
        - Monitoring des ressources serveurs (CPU, RAM, disque DCs)
        - Baseline de performance et alertes de dépassement

    9. **Gestion des Certificats et PKI**
        - Installation d'une autorité de certification (CA)
        - Déploiement de certificats pour utilisateurs/ordinateurs
        - Monitoring de l'expiration des certificats

    10. **Advanced Threat Analytics (ATA) / Microsoft Defender for Identity**
        - Installation de Microsoft Defender for Identity
        - Détection de comportements anormaux (Pass-the-Hash, Golden Ticket)
        - Intégration avec le monitoring AD existant
