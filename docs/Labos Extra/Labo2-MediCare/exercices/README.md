# Exercices Pratiques - MediCare Clinic

Le laboratoire MediCare comprend **8 exercices progressifs** organisés par niveau de difficulté, axés sur la gestion d'un environnement médical avec exigences de conformité RGPD/HIPAA.

## Vue d'Ensemble

| # | Titre | Niveau | Durée | Compétences Clés |
|---|-------|--------|-------|------------------|
| 01 | [Transfert de Patient](Exercice_01_Transfert_Patient.md) | 🟢 Débutant | 20-25 min | Permissions NTFS, transfert données |
| 02 | [Horaire de Garde](Exercice_02_Horaire_Garde.md) | 🟢 Débutant | 25-30 min | Comptes temporaires, Logon Hours |
| 03 | [Audit d'Accès Médical](Exercice_03_Audit_Acces_Medical.md) | 🟢 Débutant | 25-30 min | Audit NTFS, Event Viewer, RGPD |
| 04 | Nouveau Service Médical | 🟡 Intermédiaire | 35-40 min | Architecture OUs, département complet |
| 05 | Confidentialité Renforcée | 🟡 Intermédiaire | 30-35 min | GPO sécurité, RGPD compliance |
| 06 | Délégation Chef de Service | 🟡 Intermédiaire | 30-35 min | Delegation of Control, moindre privilège |
| 07 | Rotation de Spécialistes | 🔴 Avancé | 50-60 min | Roaming profiles, folder redirection |
| 08 | Incident RGPD | 🔴 Avancé | 60-75 min | Investigation forensique, rapport RGPD |

---

## Niveau Débutant 🟢

Ces exercices vous guident **étape par étape** avec des instructions détaillées pour maîtriser les bases de l'administration AD médicale.

### [Exercice 01 : Transfert de Patient](Exercice_01_Transfert_Patient.md)

**Scénario** : Le Dr. Catherine Leblanc transfère 3 patients vers le Dr. Philippe Moreau pour 2 mois de formation continue.

**Vous apprendrez** :
- Modifier les **permissions NTFS** sur des dossiers patients
- Transférer l'accès entre médecins (retirer ancien, ajouter nouveau)
- Documenter le transfert pour **traçabilité RGPD**
- Vérifier les ACLs via PowerShell

**Particularité médicale** : Respecter le principe du moindre privilège - retirer les accès dès qu'ils ne sont plus nécessaires (responsabilité médicale).

**Script de vérification** : [verif_exercice_01.ps1](../scripts/verification/verif_exercice_01.ps1)

---

### [Exercice 02 : Horaire de Garde](Exercice_02_Horaire_Garde.md)

**Scénario** : Créer un compte de garde rotatif "Médecin de Garde" avec accès restreint aux heures de nuit (18h-8h) et week-ends uniquement.

**Vous apprendrez** :
- Créer un **compte temporaire** avec expiration dans 7 jours
- Configurer les **Logon Hours** (restrictions horaires)
- Ajouter à un groupe spécialisé (**GG-MediCare-Medical-Oncall**)
- Tester les restrictions temporelles d'Active Directory

**Particularité médicale** : Les systèmes de garde médicale nécessitent des accès limités temporellement pour sécurité et conformité.

**Script de vérification** : [verif_exercice_02.ps1](../scripts/verification/verif_exercice_02.ps1)

---

### [Exercice 03 : Audit d'Accès Médical](Exercice_03_Audit_Acces_Medical.md)

**Scénario** : Le Responsable Conformité demande un rapport des accès au dossier VIP "M. Dupont" durant les 7 derniers jours (audit RGPD).

**Vous apprendrez** :
- Activer l'**audit NTFS** sur des dossiers sensibles
- Consulter l'**Event Viewer** (Event ID 4663 - File Access)
- Filtrer et analyser les événements de sécurité
- Générer un **rapport CSV** avec : Utilisateur, Date/Heure, Action

**Particularité médicale** : Obligation légale RGPD/HIPAA de tracer tous les accès aux données patients pour détecter violations.

**Script de vérification** : [verif_exercice_03.ps1](../scripts/verification/verif_exercice_03.ps1)

---

## Niveau Intermédiaire 🟡

Ces exercices décrivent l'objectif sans donner d'instructions détaillées. À vous de trouver comment faire!

### Exercice 04 : Nouveau Service Médical

**Scénario** : La clinique ouvre un nouveau service "Dermatologie" avec 3 employés (1 senior, 1 junior, 1 assistante).

**Objectif** : Créer de A à Z la structure AD complète pour ce département.

**Tâches** :
- Créer sub-OU `OU=Dermatologie,OU=Medical,OU=MediCare` avec sous-OUs Users/Computers/Groups (**IMPORTANT** : `-ProtectedFromAccidentalDeletion $false`)
- Créer 3 utilisateurs avec propriétés médicales appropriées
- Créer 2 groupes : **GG-MediCare-Dermato-Users** et **GG-MediCare-Dermato-Admin**
- Créer GPO shell "MediCare - Dermatologie Lecteur D" (manuel GPMC pour lecteur D:)
- Documenter la structure en CSV

**Indices** :
- Utiliser `New-ADOrganizationalUnit` avec protection désactivée
- Groupes Global (GG-) obligatoires
- GPO : Create shell only, manual Drive Map configuration required

**Script de vérification** : [verif_exercice_04.ps1](../scripts/verification/verif_exercice_04.ps1)

---

### Exercice 05 : Confidentialité Renforcée

**Scénario** : Suite à un audit RGPD, renforcer la sécurité des postes médicaux avec nouvelles restrictions.

**Objectif** : Créer et configurer une GPO de sécurité renforcée pour le département Medical.

**Tâches** :
- Créer GPO shell "MediCare - Sécurité Renforcée Médical"
- Configurer manuellement dans GPMC (consulter `gpo-reference.md`) :
  - **Désactiver captures d'écran** (User Config > Administrative Templates)
  - **Bloquer impression vers imprimantes USB/personnelles**
  - **Screen Lock timeout 10 minutes** (Security Options)
- Lier GPO à `OU=Users,OU=Medical`
- Tester avec compte médecin après `gpupdate /force`

**Indices** :
- Ne JAMAIS utiliser `Set-GPRegistryValue` pour politiques standard
- Consulter gpo-reference.md pour chemins exacts
- Tester avec runas /user:maxtec\catherine

**Script de vérification** : [verif_exercice_05.ps1](../scripts/verification/verif_exercice_05.ps1)

---

### Exercice 06 : Délégation Chef de Service

**Scénario** : Anne Leroy (Chef Nursing) doit pouvoir gérer les comptes de son équipe sans accès aux comptes médicaux.

**Objectif** : Déléguer la gestion des comptes Nursing à Anne sans privilèges excessifs.

**Tâches** :
- Utiliser **Delegation of Control Wizard** sur `OU=Nursing,OU=MediCare`
- Déléguer à `anne` :
  - Reset passwords
  - Unlock accounts
  - Modify members of Nursing groups
- Tester avec compte anne (`runas /user:maxtec\anne powershell`)
- Vérifier qu'anne NE PEUT PAS modifier utilisateurs Medical
- Documenter permissions déléguées (Get-Acl)

**Indices** :
- Delegation Wizard dans Active Directory Users and Computers
- Tester avec PowerShell : `Set-ADUser -Identity <nursing_user> -Description "Test"` sous compte anne
- Vérifier refus d'accès sur Medical

**Script de vérification** : [verif_exercice_06.ps1](../scripts/verification/verif_exercice_06.ps1)

---

## Niveau Avancé 🔴

Ces exercices sont des **scénarios réalistes complexes** nécessitant analyse, décisions multiples et troubleshooting.

### Exercice 07 : Rotation de Spécialistes

**Scénario** : 2 cardiologues (Dr. Amélie Laurent, Dr. Marc Bernard) alternent chaque semaine sur la même station de travail "CARDIO-WS01".

**Objectif** : Configurer des profils itinérants et redirection de dossiers pour une expérience utilisateur cohérente.

**Tâches complexes** :
- Configurer **Roaming Profiles** pour les 2 cardiologues
  - Profil stocké : `\\SRV\Profiles$\%username%`
- Configurer **Folder Redirection** pour Documents
  - Redirection : `\\SRV\Redirected$\%username%\Documents`
- Configurer **Primary Computer** pour CARDIO-WS01
  - Attribut AD : `msDS-PrimaryComputer`
- Créer GPO "MediCare - Profils Itinérants Cardio" avec **Loopback Processing**
- Tester connexion des 2 utilisateurs sur CARDIO-WS01
- Vérifier que profils/documents suivent l'utilisateur

**Technologies avancées** :
- Roaming User Profiles
- Folder Redirection via GPO
- Primary Computer (Fast Logon Optimization)
- Group Policy Loopback Processing

**Script de vérification** : [verif_exercice_07.ps1](../scripts/verification/verif_exercice_07.ps1)

---

### Exercice 08 : Incident RGPD - Accès Non Autorisé

**Scénario** : Le dossier médical d'une personnalité VIP a été consulté illégalement. Investigation RGPD complète requise.

**Objectif** : Mener une investigation forensique et produire un rapport RGPD professionnel.

**Tâches d'investigation** :
- Analyser **Event Viewer** (Security log) pour identifier QUI a accédé à "VIP_Dossier.docx"
- Utiliser `Get-Acl` pour vérifier permissions NTFS actuelles
- Utiliser `Get-ADGroupMember` pour tracer appartenance aux groupes
- Analyser logs d'impression (si activés)
- Identifier l'utilisateur fautif et le **chemin d'accès** (groupe → permission)
- Rédiger **rapport RGPD** :
  - **WHO** : Utilisateur responsable
  - **WHEN** : Date/heure exacte
  - **WHAT** : Fichier consulté
  - **HOW** : Chemin d'accès (groupe/permission)
  - **WHY** : Légitime ou non (justification métier)
- Recommandations de **remédiation** :
  - Retrait groupe
  - Renforcement ACL
  - Formation sensibilisation

**Compétences forensiques** :
- Analyse de logs Windows
- Tracing de permissions complexes
- Rédaction de rapport professionnel
- Recommandations de sécurité

**Script de vérification** : [verif_exercice_08.ps1](../scripts/verification/verif_exercice_08.ps1)

---

## Parcours d'Apprentissage Recommandé

### Débutants Complets (Jour 1-2)

1. **Jour 1 Matin** : Exercices 01 + 02 (Transfert + Garde)
2. **Jour 1 Après-midi** : Exercice 03 (Audit)
3. **Jour 2 Matin** : Exercice 04 (Nouveau Service)
4. **Jour 2 Après-midi** : Exercice 05 (Confidentialité)

**Durée totale** : ~4 heures effectives

### Étudiants avec Bases AD (Jour 1-2)

1. **Jour 1** : Exercices 01 → 03 (révision rapide)
2. **Jour 1** : Exercices 04 → 06 (renforcement)
3. **Jour 2** : Exercice 07 (Profils itinérants - complexe)
4. **Jour 2** : Exercice 08 (Investigation RGPD - capstone)

**Durée totale** : ~6-8 heures

---

## Différences avec CreativeHub

| Aspect | CreativeHub | MediCare |
|--------|-------------|----------|
| **Contexte** | Agence créative, projets clients | Clinique médicale, patients |
| **Focus sécurité** | Collaboration, partage projets | Confidentialité RGPD/HIPAA |
| **Exercices uniques** | Onboarding employé, projets clients | Transfert patients, garde médicale, audit RGPD |
| **Technologies** | GPO classiques, groupes AGDLP | Audit NTFS, Logon Hours, profils itinérants |
| **Scénarios** | Crise sécurité générique | Investigation RGPD médicale |
| **Niveau compliance** | Standard entreprise | Réglementé (santé) |

---

## Badges de Certification MediCare

Complétez les exercices pour obtenir votre badge :

| Badge | Critères | Exercices Requis |
|-------|----------|------------------|
| 🥉 **Bronze Médical** | Compétences de base AD médical | 01, 02, 03 réussis |
| 🥈 **Argent Compliance** | Compétences intermédiaires + conformité | 01-06 réussis |
| 🥇 **Or RGPD** | Compétences avancées + audit | 01-07 réussis |
| 💎 **Diamant HIPAA** | Maîtrise complète forensique | 01-08 réussis + Rapport professionnel Exercice 08 |

---

## Support

### Scripts de Vérification

Chaque exercice dispose d'un **script PowerShell de vérification automatique** :

```powershell
cd "C:\Labos\MediCare\scripts\verification"
.\verif_exercice_01.ps1
```

### Commandes PowerShell Essentielles (Spécifiques Médical)

```powershell
# Gestion Permissions NTFS
Get-Acl C:\Temp\Dossiers_Patients\Patient_001
$acl = Get-Acl <chemin>
$acl.AddAccessRule(<règle>)
Set-Acl <chemin> $acl

# Audit NTFS
$auditRule = New-Object System.Security.AccessControl.FileSystemAuditRule(...)
$acl.AddAuditRule($auditRule)

# Événements de sécurité
Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4663}
Get-EventLog -LogName Security -Newest 50

# Logon Hours (via GUI recommandé)
# Active Directory Users > Compte > Account > Logon Hours

# Profils itinérants
Set-ADUser -Identity <user> -ProfilePath "\\SRV\Profiles$\%username%"

# Primary Computer
Set-ADUser -Identity <user> -Add @{msDS-PrimaryComputer="CN=CARDIO-WS01,..."}
```

### Problèmes Courants Spécifiques MediCare

| Problème | Solution Rapide |
|----------|-----------------|
| Audit NTFS ne génère pas d'événements | Vérifier GPO 4 (Audit) + Audit NTFS activé + Accès réel au fichier |
| Logon Hours non respectées | Attendre 30 min ou redémarrer pour prise en compte |
| Profils itinérants non chargés | Vérifier partage réseau accessible + permissions NTFS |
| Event Viewer vide | Journal Security plein ou désactivé |
| Rapport CSV vide | Filtrer sur bon nom de dossier (sensible à la casse) |

---

## Documentation Instructeur

Les formateurs peuvent consulter :

- **Index Exercices** : (ce fichier) Vue d'ensemble complète
- **Scripts de Setup** : `../scripts/MediCare_Setup.ps1` (création lab)
- **Scripts de Cleanup** : `../scripts/MediCare_Cleanup.ps1` (réinitialisation)
- **GPO Reference** : `/.claude/gpo-reference.md` (règles GPO validées)

---

## Objectifs Pédagogiques Globaux

À la fin des 8 exercices, les étudiants maîtrisent :

1. **Gestion de données sensibles** : Permissions NTFS, audit, conformité RGPD
2. **Comptes spécialisés** : Temporaires, horaires restreints, partages
3. **Audit et traçabilité** : Event Viewer, rapports CSV, investigation
4. **Architecture départementale** : Création de structures complètes
5. **GPOs de sécurité** : Configuration manuelle correcte (pas Set-GPRegistryValue)
6. **Délégation de contrôle** : Moindre privilège, séparation des responsabilités
7. **Profils utilisateurs avancés** : Roaming profiles, folder redirection
8. **Investigation forensique** : Analyse de violations, rapports professionnels

---

**Bon courage dans votre apprentissage de l'administration AD médicale! 🏥🔒**

**Dernière mise à jour** : 2025-10-05
**Version** : 1.0
**Mainteneur** : H2EB Active Directory Lab Project
