# Laboratoire Active Directory: MediCare Clinic

## Objectifs Pédagogiques

- Comprendre la **séparation des rôles** dans un environnement médical (médecins, infirmières, administration, IT)
- Implémenter des **groupes de sécurité spécialisés** avec hiérarchie médicale (seniors, garde, facturation, RH)
- Appliquer des **stratégies de sécurité médicale** (blocage USB, audit, restrictions, conformité HIPAA simplifiée)
- Maîtriser la **configuration manuelle des GPOs** via GPMC pour les politiques avancées
- Gérer des **partages réseau médicaux** avec permissions différenciées par département

## Scénario Entreprise

**MediCare Clinic** est une petite clinique médicale multidisciplinaire de **28 employés** comprenant:

- **Département Medical (10)**: Médecins seniors, généralistes, spécialistes (pédiatre, cardiologue), médecins juniors, coordinateur de garde
- **Département Nursing (8)**: Infirmières-chefs, infirmières diplômées, assistantes médicales
- **Département Administration (7)**: Gestionnaires (facturation, RH), réceptionnistes, archivistes médicales, comptable
- **Département IT (3)**: Administrateur système, officier de sécurité, technicien support

!!! warning "Contexte de sécurité médicale"
    La clinique manipule des **données patients sensibles** et doit respecter des normes de conformité simplifiées inspirées de HIPAA:

    - Prévention de l'exfiltration de données (blocage USB zones médicales)
    - Traçabilité des accès (audit des connexions)
    - Contrôle d'accès strict (groupes spécialisés, partages réseau cloisonnés)
    - Protection contre les modifications système non autorisées

## Durée Estimée

- **Exécution du script**: 5-10 minutes
- **Configuration manuelle GPOs**: 15-20 minutes
- **Exploration et vérification**: 15-20 minutes
- **Total**: ~45 minutes

## Prérequis

!!! info "Environnement requis"
    - Windows Server 2022 avec rôle **AD DS installé et configuré**
    - Domaine **maxtec.be** fonctionnel
    - PowerShell ISE ouvert en tant qu'**Administrateur**
    - Module **ActiveDirectory** chargé
    - Module **GroupPolicy** chargé

## Structure Créée par le Script

### Arborescence des Unités Organisationnelles (OUs)

```text
maxtec.be
└── MediCare [OU racine]
    ├── Medical
    │   ├── Users (10 utilisateurs)
    │   ├── Computers
    │   └── Groups (4 groupes)
    ├── Nursing
    │   ├── Users (8 utilisateurs)
    │   ├── Computers
    │   └── Groups (2 groupes)
    ├── Administration
    │   ├── Users (7 utilisateurs)
    │   ├── Computers
    │   └── Groups (4 groupes)
    └── IT
        ├── Users (3 utilisateurs)
        ├── Computers
        └── Groups (2 groupes)
```

!!! tip "Protection contre suppression accidentelle"
    TOUTES les OUs sont créées avec `-ProtectedFromAccidentalDeletion $false` pour faciliter les exercices de manipulation.

### Utilisateurs par Département

#### Département Medical (10 utilisateurs)

| Nom Complet | SamAccountName | Email | Fonction | Groupe Admin |
|-------------|----------------|-------|----------|--------------|
| Dr. Catherine Leblanc | catherine | catherine@maxtec.be | Médecin Senior | ✅ Admin + Seniors + Oncall |
| Dr. Philippe Moreau | philippe | philippe@maxtec.be | Médecin Senior | ✅ Admin + Seniors + Oncall |
| Dr. Amélie Rousseau | amélie | amélie@maxtec.be | Médecin Généraliste | - |
| Dr. Marc Girard | marc | marc@maxtec.be | Médecin Généraliste | - |
| Dr. Sophie Bernard | sophie | sophie@maxtec.be | Médecin Généraliste | - |
| Dr. Laurent Dubois | laurent | laurent@maxtec.be | Pédiatre | - |
| Dr. Isabelle Mercier | isabelle | isabelle@maxtec.be | Cardiologue | - |
| Dr. Nicolas Fontaine | nicolas | nicolas@maxtec.be | Médecin Junior | - |
| Dr. Julie Gauthier | julie | julie@maxtec.be | Médecin Junior | - |
| Thomas Renard | thomas | thomas@maxtec.be | Coordinateur Garde | ✅ Oncall |

#### Département Nursing (8 utilisateurs)

| Nom Complet | SamAccountName | Email | Fonction | Groupe Admin |
|-------------|----------------|-------|----------|--------------|
| Inf. Anne Durand | anne | anne@maxtec.be | Infirmière-Chef | ✅ Admin |
| Inf. Claire Martin | claire | claire@maxtec.be | Infirmière-Chef | ✅ Admin |
| Inf. Brigitte Lefebvre | brigitte | brigitte@maxtec.be | Infirmière Diplômée | - |
| Inf. Sylvie Robert | sylvie | sylvie@maxtec.be | Infirmière Diplômée | - |
| Inf. Nathalie Petit | nathalie | nathalie@maxtec.be | Infirmière Diplômée | - |
| Inf. Valérie Roux | valérie | valérie@maxtec.be | Infirmière Diplômée | - |
| Asst. Céline Simon | céline | céline@maxtec.be | Assistante Médicale | - |
| Asst. Émilie Laurent | émilie | émilie@maxtec.be | Assistante Médicale | - |

#### Département Administration (7 utilisateurs)

| Nom Complet | SamAccountName | Email | Fonction | Groupe Admin |
|-------------|----------------|-------|----------|--------------|
| François Blanc | françois | françois@maxtec.be | Gestionnaire Facturation | ✅ Admin + Billing |
| Danielle Morel | danielle | danielle@maxtec.be | Gestionnaire RH | ✅ Admin + HR |
| Patricia Fournier | patricia | patricia@maxtec.be | Réceptionniste | - |
| Véronique Giraud | véronique | véronique@maxtec.be | Réceptionniste | - |
| Stéphanie Bonnet | stéphanie | stéphanie@maxtec.be | Archiviste Médicale | - |
| Martine Dupont | martine | martine@maxtec.be | Archiviste Médicale | - |
| Olivier Lambert | olivier | olivier@maxtec.be | Comptable | ✅ Billing |

#### Département IT (3 utilisateurs)

| Nom Complet | SamAccountName | Email | Fonction | Groupe Admin |
|-------------|----------------|-------|----------|--------------|
| Alain Perrin | alain | alain@maxtec.be | Administrateur Système | ✅ Admin |
| Benoît Chevalier | benoît | benoît@maxtec.be | Officier Sécurité | ✅ Admin |
| David Garnier | david | david@maxtec.be | Technicien Support | - |

!!! info "Propriétés des comptes"
    - Tous les comptes sont **activés** par défaut
    - Mot de passe par défaut: `Password1!`
    - **Aucun** changement de mot de passe requis à la première connexion
    - PasswordNeverExpires = `$false` (expiration selon politique domaine)

### Groupes de Sécurité Globaux

!!! warning "Convention de nommage OBLIGATOIRE"
    Tous les groupes globaux utilisent le préfixe **GG-** (Global Group). Cette convention est **STRICTE** et doit être respectée.

#### Département Medical (4 groupes)

| Nom du Groupe | Description | Membres Automatiques |
|---------------|-------------|----------------------|
| **GG-MediCare-Medical-Users** | Tous les utilisateurs Medical | catherine, philippe, amélie, marc, sophie, laurent, isabelle, nicolas, julie, thomas |
| **GG-MediCare-Medical-Admin** | Administrateurs Medical (Seniors) | catherine, philippe |
| **GG-MediCare-Medical-Seniors** | Médecins Seniors (droits signature) | catherine, philippe |
| **GG-MediCare-Medical-Oncall** | Accès système de garde rotatif | thomas, philippe |

!!! example "Justification métier - Groupes Medical"
    - **Seniors**: Nécessitent des droits de signature électronique pour valider des prescriptions complexes
    - **Oncall**: Système de garde nécessite accès distant 24/7 aux dossiers patients urgents

#### Département Nursing (2 groupes)

| Nom du Groupe | Description | Membres Automatiques |
|---------------|-------------|----------------------|
| **GG-MediCare-Nursing-Users** | Tous les utilisateurs Nursing | anne, claire, brigitte, sylvie, nathalie, valérie, céline, émilie |
| **GG-MediCare-Nursing-Admin** | Administrateurs Nursing (Chefs) | anne, claire |

#### Département Administration (4 groupes)

| Nom du Groupe | Description | Membres Automatiques |
|---------------|-------------|----------------------|
| **GG-MediCare-Administration-Users** | Tous les utilisateurs Administration | françois, danielle, patricia, véronique, stéphanie, martine, olivier |
| **GG-MediCare-Administration-Admin** | Administrateurs Administration (Gestionnaires) | françois, danielle |
| **GG-MediCare-Administration-Billing** | Équipe Facturation | françois, olivier |
| **GG-MediCare-Administration-HR** | Équipe Ressources Humaines | danielle |

!!! example "Justification métier - Groupes Administration"
    - **Billing**: Accès aux systèmes de facturation médicale et données assurance patients
    - **HR**: Accès aux dossiers RH, contrats, évaluations de performance du personnel

#### Département IT (2 groupes)

| Nom du Groupe | Description | Membres Automatiques |
|---------------|-------------|----------------------|
| **GG-MediCare-IT-Users** | Tous les utilisateurs IT | alain, benoît, david |
| **GG-MediCare-IT-Admin** | Administrateurs IT (SysAdmin + Sécurité) | alain, benoît |

!!! tip "Logique d'affectation automatique"
    - **TOUS** les utilisateurs d'un département sont automatiquement ajoutés au groupe `-Users`
    - Les **administrateurs désignés** (seniors, chefs, gestionnaires) sont ajoutés au groupe `-Admin`
    - Les **groupes spécialisés** (Seniors, Oncall, Billing, HR) reçoivent des membres spécifiques selon leur rôle métier

### Stratégies de Groupe (GPOs)

!!! danger "IMPORTANT - Configuration GPO"
    Ce laboratoire suit strictement les bonnes pratiques du fichier `.claude/gpo-reference.md`:

    - **JAMAIS** d'utilisation de `Set-GPRegistryValue` pour les politiques Windows standard
    - Seules les **GPO shells** sont créées via PowerShell
    - La **configuration manuelle** dans GPMC est requise pour les paramètres avancés
    - Évite les erreurs "nom convivial introuvable" dans GPMC

#### GPO 1: Politique de Mot de Passe du Domaine (Automatique)

!!! success "Configuration PowerShell - Appliquée automatiquement"
    Cette politique est configurée **automatiquement** par le script via `Set-ADDefaultDomainPasswordPolicy`.

**Paramètres appliqués:**

- **Longueur minimale**: 12 caractères
- **Complexité**: Activée (majuscules, minuscules, chiffres, symboles)
- **Âge maximum**: 60 jours (rotation régulière, conformité médicale)
- **Âge minimum**: 1 jour (empêche changements répétés)
- **Historique**: 24 mots de passe mémorisés
- **Verrouillage**: 5 tentatives invalides
- **Durée verrouillage**: 30 minutes
- **Fenêtre observation**: 30 minutes

**Vérification:**

```powershell
Get-ADDefaultDomainPasswordPolicy -Identity "maxtec.be"
```

!!! example "Justification médicale"
    Mots de passe renforcés requis pour protéger l'accès aux dossiers patients sensibles (conformité HIPAA simplifiée).

#### GPO 2: Blocage USB - Zones Médicales (Configuration Manuelle)

!!! warning "Configuration manuelle requise dans GPMC"
    Cette GPO est créée automatiquement par le script, mais **DOIT être configurée manuellement** dans GPMC.

**Nom de la GPO:** `MediCare - Blocage USB Zones Médicales`

**OUs liées:**

- `OU=Users,OU=Medical,OU=MediCare,DC=maxtec,DC=be`
- `OU=Users,OU=Nursing,OU=MediCare,DC=maxtec,DC=be`

**Configuration requise:**

1. Ouvrir **GPMC** (gpmc.msc)
2. Naviguer vers la GPO `MediCare - Blocage USB Zones Médicales`
3. Éditer la GPO
4. Aller à: **User Configuration > Policies > Administrative Templates > System > Removable Storage Access**
5. Configurer: **"All Removable Storage classes: Deny all access"** = `Enabled`
6. Appliquer et fermer

**Vérification:**

1. Connectez-vous avec un compte Medical ou Nursing (ex: `catherine`)
2. Exécutez: `gpupdate /force`
3. Insérez une clé USB
4. **Résultat attendu**: Accès refusé avec message d'erreur système

!!! example "Justification médicale"
    Prévient l'exfiltration de données patients vers périphériques USB non autorisés (violation HIPAA majeure).

#### GPO 3: Restrictions Bureau - Administration (Configuration Manuelle)

!!! warning "Configuration manuelle requise dans GPMC"
    Cette GPO est créée automatiquement par le script, mais **DOIT être configurée manuellement** dans GPMC.

**Nom de la GPO:** `MediCare - Restrictions Bureau Administration`

**OU liée:** `OU=Users,OU=Administration,OU=MediCare,DC=maxtec,DC=be`

**Configuration requise:**

1. Ouvrir **GPMC** (gpmc.msc)
2. Naviguer vers la GPO `MediCare - Restrictions Bureau Administration`
3. Éditer la GPO
4. Aller à: **User Configuration > Policies > Administrative Templates > Control Panel**
5. Configurer: **"Prohibit access to Control Panel and PC settings"** = `Enabled`
6. Appliquer et fermer

**Vérification:**

1. Connectez-vous avec un compte Administration (ex: `patricia`)
2. Exécutez: `gpupdate /force`
3. Tentez d'ouvrir le **Panneau de configuration**
4. **Résultat attendu**: Message "Cette opération a été annulée en raison de restrictions..."

!!! example "Justification médicale"
    Empêche les réceptionnistes et le personnel administratif de modifier les paramètres système qui pourraient compromettre la sécurité de la clinique.

#### GPO 4: Audit des Connexions (Automatique)

!!! success "Configuration auditpol.exe - Appliquée automatiquement"
    Cette politique est configurée **automatiquement** par le script via `auditpol.exe`.

**Audits activés:**

- **Audit Logon**: Success + Failure
- **Audit User Account Management**: Success + Failure

**Vérification:**

1. Ouvrir **Observateur d'événements** (eventvwr.msc)
2. Naviguer vers: **Windows Logs > Security**
3. Connectez-vous/déconnectez-vous avec un utilisateur
4. Rechercher les événements:
   - **4624**: Connexion réussie
   - **4625**: Échec de connexion
   - **4720-4726**: Gestion des comptes utilisateurs

**Commande de vérification:**

```powershell
auditpol /get /category:"Logon/Logoff","Account Management"
```

!!! example "Justification médicale"
    Traçabilité obligatoire des accès aux systèmes médicaux pour conformité HIPAA (audit trail des consultations dossiers patients).

#### GPO 5: Mappage Lecteurs Réseau - Partages Médicaux (Configuration Manuelle)

!!! warning "Configuration manuelle complexe requise - Group Policy Preferences"
    Cette GPO nécessite **Group Policy Preferences** avec **Item-Level Targeting** pour mapper différents lecteurs selon les départements.

**Nom de la GPO:** `MediCare - Lecteurs Médicaux Partagés`

**OU liée:** `OU=MediCare,DC=maxtec,DC=be` (racine - s'applique à tous)

**PRÉREQUIS CRITIQUES:**

!!! danger "Créer d'abord les partages réseau"
    Avant de configurer cette GPO, vous **DEVEZ** créer les partages réseau suivants sur un serveur de fichiers (par exemple `SRV-MEDICARE`):

    1. **\\\\SRV-MEDICARE\\Dossiers_Patients**
       - Permissions NTFS: `GG-MediCare-Medical-Users` (Lecture/Écriture)

    2. **\\\\SRV-MEDICARE\\Notes_Infirmieres**
       - Permissions NTFS: `GG-MediCare-Medical-Users`, `GG-MediCare-Nursing-Users` (Lecture/Écriture)

    3. **\\\\SRV-MEDICARE\\Administration**
       - Permissions NTFS: `GG-MediCare-Administration-Users` (Lecture/Écriture)

**Configuration GPO - Lecteur M: (Dossiers Patients):**

1. Ouvrir **GPMC** (gpmc.msc)
2. Éditer la GPO `MediCare - Lecteurs Médicaux Partagés`
3. Aller à: **User Configuration > Preferences > Windows Settings > Drive Maps**
4. Clic droit > **New > Mapped Drive**
5. Configurer:
   - **Action**: `Create`
   - **Location**: `\\SRV-MEDICARE\Dossiers_Patients`
   - **Drive Letter**: `M:`
   - **Label as**: `Dossiers Patients`
   - **Reconnect**: ✅ Coché

6. Onglet **Common**:
   - Cocher **Item-level targeting**
   - Cliquer **Targeting...**
   - Ajouter: **Security Group** = `GG-MediCare-Medical-Users`

7. Appliquer

**Configuration GPO - Lecteur N: (Notes Infirmières):**

1. Dans la même GPO, créer un nouveau **Mapped Drive**
2. Configurer:
   - **Action**: `Create`
   - **Location**: `\\SRV-MEDICARE\Notes_Infirmieres`
   - **Drive Letter**: `N:`
   - **Label as**: `Notes Infirmières`
   - **Reconnect**: ✅ Coché

3. Onglet **Common**:
   - Cocher **Item-level targeting**
   - Cliquer **Targeting...**
   - Ajouter **deux** groupes avec opérateur **OR**:
     - **Security Group** = `GG-MediCare-Medical-Users`
     - **Security Group** = `GG-MediCare-Nursing-Users`
4. Appliquer

**Configuration GPO - Lecteur A: (Administration):**

1. Dans la même GPO, créer un nouveau **Mapped Drive**
2. Configurer:
   - **Action**: `Create`
   - **Location**: `\\SRV-MEDICARE\Administration`
   - **Drive Letter**: `A:`
   - **Label as**: `Administration`
   - **Reconnect**: ✅ Coché

3. Onglet **Common**:
   - Cocher **Item-level targeting**
   - Cliquer **Targeting...**
   - Ajouter: **Security Group** = `GG-MediCare-Administration-Users`

4. Appliquer

**Vérification:**

1. Créez les 3 partages réseau sur le serveur de fichiers
2. Configurez les permissions NTFS comme indiqué ci-dessus
3. Configurez les 3 lecteurs mappés dans la GPO
4. Connectez-vous avec un utilisateur **Medical** (ex: `catherine`)
   - Exécutez: `gpupdate /force`
   - Ouvrez **Ce PC**: Lecteurs M: et N: doivent apparaître

5. Connectez-vous avec un utilisateur **Nursing** (ex: `anne`)
   - Exécutez: `gpupdate /force`
   - Ouvrez **Ce PC**: Seul le lecteur N: doit apparaître

6. Connectez-vous avec un utilisateur **Administration** (ex: `patricia`)
   - Exécutez: `gpupdate /force`
   - Ouvrez **Ce PC**: Seul le lecteur A: doit apparaître

!!! example "Justification médicale"
    Accès cloisonné aux données médicales selon le rôle:

    - **Medical uniquement**: Dossiers patients complets (diagnostic, traitement)
    - **Medical + Nursing**: Notes infirmières (observations, soins)
    - **Administration uniquement**: Documents administratifs (facturation, RH)

## Instructions d'Exécution

### Étape 1: Préparation de l'environnement

1. Ouvrir **PowerShell ISE** en tant qu'**Administrateur** sur le contrôleur de domaine
2. Vérifier que le domaine est fonctionnel:

```powershell
Get-ADDomain
```

3. Vérifier que les modules sont chargés:

```powershell
Import-Module ActiveDirectory
Import-Module GroupPolicy
```

### Étape 2: Exécution du script de configuration

1. Copier le fichier `MediCare_Setup.ps1` sur le contrôleur de domaine
2. Dans PowerShell ISE, ouvrir le fichier ou copier-coller son contenu
3. **Lire attentivement** les commentaires pour comprendre chaque section
4. Exécuter le script (F5)
5. **Confirmer chaque étape** lorsque demandé (O/N/Q):
   - **O**: Exécuter l'étape
   - **N**: Sauter l'étape
   - **Q**: Quitter le script

!!! tip "Exécution interactive"
    Le script utilise des confirmations interactives (`Confirm-Step`) pour vous permettre de:

    - Comprendre ce qui va être créé avant exécution
    - Sauter des sections si nécessaire
    - Apprendre le processus étape par étape

### Étape 3: Configuration manuelle des GPOs

Après exécution du script, suivre les instructions détaillées dans la section **"Stratégies de Groupe (GPOs)"** ci-dessus pour:

1. **GPO 2**: Configurer le blocage USB
2. **GPO 3**: Configurer les restrictions bureau
3. **GPO 5**: Créer les partages réseau et configurer les lecteurs mappés

!!! warning "Configuration GPO obligatoire"
    Les GPOs 2, 3 et 5 ne sont que des **shells** créés par le script. Elles **NE FONCTIONNERONT PAS** tant que vous ne les aurez pas configurées manuellement dans GPMC comme indiqué.

### Étape 4: Vérification post-exécution

Exécuter les commandes suivantes pour vérifier la création correcte de la structure.

## Vérification Post-Exécution

### Vérification PowerShell

#### Vérifier les OUs créées

```powershell
Get-ADOrganizationalUnit -Filter * |
    Where-Object {$_.DistinguishedName -like "*OU=MediCare*"} |
    Select-Object Name, DistinguishedName |
    Sort-Object DistinguishedName
```

**Résultat attendu:** 16 OUs (1 racine + 4 départements + 12 sous-OUs)

#### Vérifier tous les utilisateurs créés

```powershell
Get-ADUser -Filter * -SearchBase "OU=MediCare,DC=maxtec,DC=be" -Properties EmailAddress, Title, Department |
    Select-Object Name, SamAccountName, EmailAddress, Title, Department, Enabled |
    Sort-Object Department, Name
```

**Résultat attendu:** 28 utilisateurs avec titres médicaux, tous activés

#### Vérifier les groupes et leurs membres

```powershell
Get-ADGroup -Filter * -SearchBase "OU=MediCare,DC=maxtec,DC=be" |
    Sort-Object Name |
    ForEach-Object {
        Write-Host "`nGroupe: $($_.Name)" -ForegroundColor Cyan
        Write-Host "Description: $($_.Description)" -ForegroundColor Gray
        $members = Get-ADGroupMember -Identity $_.Name | Select-Object Name, SamAccountName | Sort-Object Name
        $members | Format-Table -AutoSize
    }
```

**Résultat attendu:** 12 groupes avec le préfixe `GG-` et leurs membres appropriés

#### Vérifier la politique de mot de passe

```powershell
Get-ADDefaultDomainPasswordPolicy -Identity "maxtec.be" |
    Select-Object MinPasswordLength, ComplexityEnabled, MaxPasswordAge, LockoutThreshold, LockoutDuration
```

**Résultat attendu:**

- MinPasswordLength: 12
- ComplexityEnabled: True
- MaxPasswordAge: 60.00:00:00 (60 jours)
- LockoutThreshold: 5
- LockoutDuration: 00:30:00 (30 minutes)

#### Vérifier les GPOs créées

```powershell
Get-GPO -All |
    Where-Object {$_.DisplayName -like "*MediCare*"} |
    Select-Object DisplayName, GpoStatus, CreationTime, ModificationTime
```

**Résultat attendu:** 3 GPOs MediCare (Blocage USB, Restrictions Bureau, Lecteurs Médicaux)

#### Vérifier les liens GPO

```powershell
# Vérifier les liens GPO pour Medical
Get-GPInheritance -Target "OU=Users,OU=Medical,OU=MediCare,DC=maxtec,DC=be" |
    Select-Object -ExpandProperty GpoLinks |
    Select-Object DisplayName, Enabled, Enforced

# Vérifier les liens GPO pour Administration
Get-GPInheritance -Target "OU=Users,OU=Administration,OU=MediCare,DC=maxtec,DC=be" |
    Select-Object -ExpandProperty GpoLinks |
    Select-Object DisplayName, Enabled, Enforced
```

#### Exporter la structure en CSV pour référence

```powershell
# Export utilisateurs
Get-ADUser -Filter * -SearchBase "OU=MediCare,DC=maxtec,DC=be" -Properties EmailAddress, Title, Department |
    Select-Object Name, SamAccountName, EmailAddress, Title, Department, Enabled |
    Export-Csv -Path "C:\Labos\verification_utilisateurs.csv" -NoTypeInformation -Encoding UTF8

# Export groupes avec membres
$groupsData = @()
Get-ADGroup -Filter * -SearchBase "OU=MediCare,DC=maxtec,DC=be" | ForEach-Object {
    $members = (Get-ADGroupMember -Identity $_.Name | Select-Object -ExpandProperty SamAccountName) -join "; "
    $groupsData += [PSCustomObject]@{
        Nom = $_.Name
        Description = $_.Description
        Membres = $members
    }
}
$groupsData | Export-Csv -Path "C:\Labos\verification_groupes.csv" -NoTypeInformation -Encoding UTF8

Write-Host "`n✅ Fichiers CSV exportés dans C:\Labos\" -ForegroundColor Green
```

### Vérification Manuelle (Interface Graphique)

#### Vérifier dans Active Directory Users and Computers

1. Ouvrir **dsa.msc** (Active Directory Users and Computers)
2. Développer le domaine **maxtec.be**
3. Vérifier la présence de l'OU **MediCare** avec ses 4 départements
4. Pour chaque département:
   - Vérifier les 3 sous-OUs (Users, Computers, Groups)
   - Ouvrir **Users**: vérifier les utilisateurs avec titres médicaux
   - Ouvrir **Groups**: vérifier les groupes avec préfixe `GG-`

5. Double-cliquer sur un groupe (ex: `GG-MediCare-Medical-Users`)
   - Onglet **Members**: vérifier la liste des membres

#### Vérifier dans Group Policy Management Console

1. Ouvrir **gpmc.msc** (Group Policy Management)
2. Développer **Forest > Domains > maxtec.be**
3. Développer **Group Policy Objects**
4. Vérifier la présence des 3 GPOs MediCare
5. Pour chaque GPO:
   - Clic droit > **Edit** pour vérifier la configuration
   - Onglet **Scope** > **Links**: vérifier les OUs liées
   - Onglet **Settings**: vérifier les paramètres configurés (après config manuelle)

#### Vérifier les audits dans Event Viewer

1. Ouvrir **eventvwr.msc** (Observateur d'événements)
2. Naviguer vers **Windows Logs > Security**
3. Connectez-vous avec un utilisateur (ex: `catherine`)
4. Rechercher l'événement **4624** (connexion réussie) avec le nom d'utilisateur

## Concepts Clés Démontrés

### 1. Hiérarchie Médicale et Séparation des Rôles

!!! info "Concept RBAC (Role-Based Access Control)"
    La structure MediCare démontre une **hiérarchie médicale réaliste**:

    - **Médecins Seniors**: Droits administratifs, signature, garde
    - **Médecins Généralistes/Spécialistes**: Accès standard dossiers patients
    - **Médecins Juniors**: Accès supervisé (possibilité de restreindre via GPO ultérieurement)
    - **Infirmières-Chefs**: Administration nursing, validation soins
    - **Infirmières/Assistantes**: Saisie notes, observations
    - **Administration**: Facturation, RH, réception (aucun accès médical)
    - **IT**: Support technique, sécurité, mais pas d'accès direct aux données patients

### 2. Groupes de Sécurité Spécialisés

!!! tip "Au-delà des groupes standards Users/Admin"
    MediCare utilise des **groupes métier spécialisés**:

    - **GG-MediCare-Medical-Seniors**: Droits signature électronique prescriptions
    - **GG-MediCare-Medical-Oncall**: Accès distant 24/7 système de garde
    - **GG-MediCare-Administration-Billing**: Accès systèmes facturation médicale
    - **GG-MediCare-Administration-HR**: Accès dossiers RH personnel

    **Avantage pédagogique:** Comprendre que les groupes doivent refléter les **rôles métier**, pas seulement la structure organisationnelle.

### 3. Sécurité Médicale et Conformité HIPAA (Simplifiée)

!!! example "Principes de conformité médicale"
    La configuration GPO démontre des **exigences de sécurité médicale**:

    1. **Prévention exfiltration de données** (GPO 2 - Blocage USB):
       - Empêche copie dossiers patients vers clés USB non chiffrées
       - Violation HIPAA majeure si données sensibles volées/perdues

    2. **Traçabilité des accès** (GPO 4 - Audit):
       - Chaque consultation dossier patient doit être tracée
       - Obligatoire pour enquêtes en cas de violation

    3. **Mots de passe renforcés** (GPO 1):
       - 12 caractères minimum, rotation 60 jours
       - Protection contre compromission comptes médicaux

    4. **Cloisonnement des données** (GPO 5 - Lecteurs mappés):
       - Personnel administratif ne doit **JAMAIS** accéder aux dossiers patients
       - Séparation stricte via permissions NTFS et item-level targeting

### 4. Configuration Manuelle GPO vs. PowerShell

!!! warning "Apprentissage des limites de l'automatisation"
    Ce laboratoire enseigne que **toutes les GPOs ne peuvent pas être configurées via PowerShell**:

    - ❌ **Politiques ADMX standard**: Nécessitent configuration manuelle GPMC (Blocage USB, Restrictions Bureau)
    - ❌ **Group Policy Preferences**: Nécessitent configuration manuelle (Drive Maps, Scheduled Tasks)
    - ✅ **Politiques de mot de passe domaine**: Supportées via `Set-ADDefaultDomainPasswordPolicy`
    - ✅ **Audits**: Supportés via `auditpol.exe`

    **Pourquoi?** Utilisation de `Set-GPRegistryValue` pour politiques standard crée des entrées invalides ("nom convivial introuvable").

### 5. Item-Level Targeting (GPO 5)

!!! tip "Ciblage avancé dans Group Policy Preferences"
    Le mappage de lecteurs réseau démontre **Item-Level Targeting**:

    - **Concept**: Appliquer différentes configurations selon l'appartenance à un groupe
    - **Exemple**: Lecteur M: seulement pour `GG-MediCare-Medical-Users`, Lecteur N: pour `Medical` **ET** `Nursing`
    - **Avantage**: Une seule GPO gère plusieurs mappages avec ciblage intelligent
    - **Application réelle**: Dossiers personnels, partages départementaux, imprimantes réseau

## Exercices Pratiques

Après avoir exécuté le script et configuré les GPOs manuellement, les étudiants peuvent approfondir leur apprentissage avec ces exercices pratiques guidés.

!!! tip "Exercices disponibles"
    Le laboratoire MediCare comprend **8 exercices progressifs** couvrant différents aspects de l'administration AD médicale, avec scripts de vérification automatique:

    **Niveau Débutant:**

    - [Exercice 01: Gestion des Comptes Utilisateurs Médicaux](exercices/Exercice_01_Transfert_Patient.md) - Modifier, désactiver et déplacer des comptes
    - [Exercice 02: Manipulation des Groupes de Sécurité](exercices/Exercice_02_Horaire_Garde.md) - Ajouter/retirer membres, créer groupes

    **Niveau Intermédiaire:**

    - [Exercice 03: Configuration Avancée des GPOs](exercices/Exercice_03_Audit_Acces_Medical.md) - Configurer, tester et dépanner les GPOs
    - [Exercice 04: Permissions NTFS et Partages Réseau](exercices/Exercice_04_Nouveau_Service_Medical.md) - Créer partages médicaux sécurisés
    - [Exercice 05: Audit et Conformité Médicale](exercices/Exercice_05_Confidentialite_Renforcee.md) - Analyser logs d'audit, traçabilité

    **Niveau Avancé:**

    - [Exercice 06: Scénarios de Panne et Récupération](exercices/Exercice_06_Delegation_Chef_Service.md) - Restaurer comptes, réinitialiser mots de passe
    - [Exercice 07: Délégation de Contrôle Départementale](exercices/Exercice_07_Rotation_Specialistes.md) - Déléguer gestion RH et Medical
    - [Exercice 08: Simulation Violation de Sécurité](exercices/Exercice_08_Incident_RGPD.md) - Enquêter et remédier

## Dépannage

### Problèmes Courants

| Erreur | Cause Possible | Solution |
|--------|----------------|----------|
| "OU already exists" | Structure MediCare déjà créée | Utiliser `MediCare_Cleanup.ps1` pour nettoyer, puis réexécuter |
| "Access denied" | Pas de privilèges administrateur | Relancer PowerShell ISE en tant qu'**Administrateur** |
| "Module ActiveDirectory not found" | Module AD non chargé | Exécuter: `Import-Module ActiveDirectory` |
| "Cannot find GPO" | GPO non créée ou supprimée | Vérifier dans GPMC (gpmc.msc), réexécuter le script |
| "User account already exists" | Utilisateur créé lors d'exécution précédente | Passer l'étape (message jaune "existe déjà") ou nettoyer |
| "GPO settings not applying" | Configuration manuelle non effectuée | Suivre instructions GPO 2, 3, 5 dans GPMC |
| "Drive mapping not working" | Partages réseau inexistants | Créer d'abord les partages sur SRV-MEDICARE avec permissions |
| "nom convivial introuvable" dans GPMC | Utilisation incorrecte de Set-GPRegistryValue | Supprimer la GPO, recréer, configurer manuellement |

### Commandes de Diagnostic

#### Vérifier le rôle AD DS

```powershell
Get-WindowsFeature -Name AD-Domain-Services
```

**Résultat attendu:** InstallState = `Installed`

#### Vérifier le domaine actuel

```powershell
Get-ADDomain | Select-Object Name, DNSRoot, DomainMode
```

**Résultat attendu:**

- Name: `maxtec`
- DNSRoot: `maxtec.be`
- DomainMode: `Windows2016Domain` ou supérieur

#### Vérifier les privilèges administrateur

```powershell
whoami /groups | findstr "Admins"
```

**Résultat attendu:** Doit contenir `BUILTIN\Administrators` ou `Domain Admins`

#### Vérifier la réplication AD

```powershell
repadmin /replsummary
```

**Résultat attendu:** Aucune erreur de réplication

#### Vérifier l'application des GPOs sur un utilisateur

```powershell
# Connectez-vous avec un utilisateur (ex: catherine)
gpresult /r /user:maxtec\catherine
```

**Résultat attendu:** Affiche les GPOs appliquées, dont les GPOs MediCare

#### Vérifier les événements d'erreur AD

```powershell
Get-EventLog -LogName "Directory Service" -Newest 50 -EntryType Error, Warning
```

**Résultat attendu:** Aucune erreur récente liée à AD

### Problèmes Spécifiques aux GPOs

#### GPO "nom convivial introuvable"

!!! danger "Problème causé par Set-GPRegistryValue"
    Si vous voyez "nom convivial introuvable" dans GPMC sous **"Définitions de stratégies (fichiers ADMX)"**, cela signifie qu'une GPO a été configurée incorrectement via `Set-GPRegistryValue` avec des clés de registre brutes.

**Solution:**

1. Supprimer la GPO problématique:
   ```powershell
   Remove-GPO -Name "Nom de la GPO" -Confirm:$false
   ```

2. Recréer la GPO via le script ou manuellement

3. **NE PAS** utiliser `Set-GPRegistryValue` pour les politiques Windows standard

4. Configurer manuellement dans GPMC comme indiqué dans ce README

#### GPO ne s'applique pas

!!! warning "Vérifications à effectuer"

1. **Vérifier le lien GPO**:
   ```powershell
   Get-GPInheritance -Target "OU=Users,OU=Medical,OU=MediCare,DC=maxtec,DC=be"
   ```

2. **Vérifier que la GPO est activée**:
   ```powershell
   Get-GPO -Name "MediCare - Blocage USB Zones Médicales" | Select-Object DisplayName, GpoStatus
   ```
   - GpoStatus doit être `AllSettingsEnabled`

3. **Forcer l'application**:
   ```powershell
   gpupdate /force
   ```

4. **Vérifier l'héritage**:
   - Ouvrir GPMC
   - Vérifier qu'aucune OU parent n'a "Block Inheritance"
   - Vérifier qu'aucune GPO de priorité supérieure ne contredit

5. **Vérifier la portée de sécurité**:
   - Dans GPMC, onglet **Scope** de la GPO
   - Vérifier que **Authenticated Users** ou le groupe cible a les permissions **Read** + **Apply Group Policy**

## Évolutions Possibles du Laboratoire

Pour approfondir ce laboratoire dans le futur, vous pourriez:

### 1. Partages Réseau Réels

!!! example "Implémentation complète"
    - Créer un serveur de fichiers dédié `SRV-MEDICARE`
    - Implémenter les 3 partages réseau avec quotas
    - Configurer les permissions NTFS avancées (héritage, refus explicite)
    - Ajouter un partage `\\SRV-MEDICARE\Archives_Patients` avec compression

### 2. Fine-Grained Password Policy

!!! example "Politiques de mot de passe différenciées"
    - **IT Admins**: 16 caractères, rotation 45 jours
    - **Medical Staff**: 12 caractères, rotation 60 jours (actuel)
    - **Administration**: 10 caractères, rotation 90 jours

### 3. Scripts de Connexion (Logon Scripts)

!!! example "Automatisation par département"
    - Medical: Mappage lecteur M:, vérification accès VPN garde
    - Nursing: Mappage lecteur N:, affichage planning garde
    - Administration: Lecteur A:, ouverture application facturation

### 4. Système de Garde Médical Automatisé

!!! example "Rotation automatique groupe Oncall"
    - Script PowerShell hebdomadaire qui modifie `GG-MediCare-Medical-Oncall`
    - Fichier CSV avec planning de garde
    - Email automatique au médecin de garde

### 5. Audit Renforcé et Alertes

!!! example "Surveillance proactive"
    - Audit des accès fichiers dossiers patients
    - Script PowerShell qui alerte si connexion hors horaires (22h-6h)
    - Export quotidien des événements d'audit vers SIEM (simulé)

### 6. Délégation de Contrôle Avancée

!!! example "Autonomie départementale"
    - Déléguer réinitialisation mots de passe aux Infirmières-Chefs
    - Déléguer création comptes RH au Gestionnaire RH
    - Déléguer gestion Medical aux Médecins Seniors

### 7. Intégration avec Certificate Services

!!! example "Signatures électroniques médicales"
    - Déployer PKI interne
    - Certificats utilisateurs pour `GG-MediCare-Medical-Seniors`
    - Signature électronique prescriptions et rapports médicaux

### 8. Protection BitLocker via GPO

!!! example "Chiffrement postes médicaux"
    - GPO de chiffrement BitLocker pour `OU=Computers,OU=Medical`
    - Sauvegarde clés de récupération dans AD
    - Politique TPM + PIN pour ordinateurs portables médecins

### 9. Scénarios de Conformité HIPAA

!!! example "Exercices de conformité avancés"
    - Simulation d'audit HIPAA: produire rapport d'accès patient
    - Scénario "droit à l'oubli": supprimer toutes traces d'un patient
    - Exercice "violation de données": identifier qui a accédé à un dossier

### 10. Multi-Sites avec Réplication AD

!!! example "Extension géographique"
    - Ajouter site `MediCare-Annexe` (clinique satellite)
    - Configurer réplication AD inter-sites
    - GPOs spécifiques par site (imprimantes, serveurs locaux)

---

**Dernière mise à jour:** 2025-10-05
**Version:** 1.0
**Mainteneur:** H2EB Active Directory Lab Project
