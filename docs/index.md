# Cours Active Directory 

!!! info "📚 Formation complète sur Active Directory Domain Services"
    Infrastructure d'entreprise moderne avec labs pratiques sur **maxtec.be**

---

## 🎯 À propos du cours

Ce cours vous guide à travers l'installation, la configuration et l'administration d'**Active Directory** dans un environnement d'entreprise simulé. Vous travaillerez sur l'infrastructure **maxtec.be** avec des labs pratiques et des exercices concrets.

**Public:** Étudiants en informatique, administrateurs systèmes débutants
**Prérequis:** Connaissances de base Windows Server
**Contenu:** Théorie + pratique complète

---

## 📖 Chapitres du cours

### 🏗️ Fondations (Chapitres 1-2)

| Chapitre | Titre | Contenu |
|----------|-------|---------|
| **[Chapitre 1](Chapitre%201.Introduction%20et%20installation%20de%20Windows%20Server.md)** | Introduction et Installation Windows Server | Concepts de base, architecture serveur, installation Windows Server 2022 | 
| **[Chapitre 2](Chapitre%202.Installation-Windows-Server-2022-VirtualBox.md)** | Installation VirtualBox | Configuration environnement de virtualisation, création VMs | 

### 🌐 Infrastructure réseau (Chapitres 3-5)

| Chapitre | Titre | Contenu |
|----------|-------|---------|
| **[Chapitre 3](Chapitre%203.DNS.md)** | DNS - Préparation pour AD | Concepts DNS essentiels pour Active Directory |
| **[Chapitre 4](Chapitre%204.Active%20Directory%20Domain%20Services%20%28AD%20DS%29.md)** | Active Directory Domain Services | Installation et configuration AD DS sur maxtec.be | 
| **[Chapitre 5](Chapitre%205.DNS-Pratique-avec-AD.md)** | DNS Pratique avec AD | Labs DNS avec domaine fonctionnel (4 labs progressifs) |

### 🏢 Organisation et gestion (Chapitres 6-8)


| Chapitre | Titre | Contenu |
|----------|-------|---------|
| **[Chapitre 6](Chapitre%206.Unites_Organisation.md)** | Unités d'Organisation (OUs) | Structure hiérarchique, délégation AGLP/AGDLP | 
| **[Chapitre 7](Chapitre%207.Gestion_des_Utilisateurs.md)** | Gestion des Utilisateurs | Création comptes, groupes, permissions NTFS/partage | 
| **[Chapitre 8](Chapitre%208.Group%20Policy%20Objects.md)** | Group Policy Objects (GPO) | Stratégies de groupe, LSDO, filtrage et délégation |

### 💻 Automatisation PowerShell

#### 📘 Cours de Base (Chapitre 9)

| Chapitre | Titre | Contenu |
|----------|-------|---------|
| **[Chapitre 9.0](Chapitre%209.0.Powershell%20AD%20-%20Introduction.md)** | PowerShell AD - Introduction | Premiers pas avec le module Active Directory | 
| **[Chapitre 9.1](Chapitre%209.1.Powershell%20AD%20-%20Concepts%20base.md)** | PowerShell AD - Concepts de base | Cmdlets essentiels, syntaxe, pipelines |
| **[Chapitre 9.2](Chapitre%209.2.Powershell%20AD%20-%20Requetes_et_Informations.md)** | PowerShell AD - Requêtes | Get-ADUser, Get-ADGroup, filtres et recherches |
| **[Chapitre 9.3](Chapitre%209.3.Powershell%20AD%20-%20Creation_et_Modification.md)** | PowerShell AD - Création et Modification | New-ADUser, Set-ADUser, gestion en masse |

#### 🚀 Cours Moderne (2025)

Un cours complémentaire axé sur la **réalité du terrain** et l'utilisation moderne de PowerShell AD.

| Module | Titre | Philosophie |
|--------|-------|-------------|
| **[M1](PowershellCourse/cours-powershell-ad-moderne/modules-modernes/M1-realite-2025.md)** | Réalité 2025 | Google/IA comme outils, pas comme tricherie |
| **[M2](PowershellCourse/cours-powershell-ad-moderne/modules-modernes/M2-survie-tickets.md)** | Survie Tickets | Résoudre des incidents réels rapidement |
| **[M3](PowershellCourse/cours-powershell-ad-moderne/modules-modernes/M3-ia-comme-copilote.md)** | IA comme Copilote | ChatGPT/Copilot pour PowerShell AD |
| **[M4](PowershellCourse/cours-powershell-ad-moderne/modules-modernes/M4-scripts-bomba-lab.md)** | Scripts Bomba Lab | Désactiver 800 users sans -WhatIf |
| **[M5](PowershellCourse/cours-powershell-ad-moderne/modules-modernes/M5-whatif-religieux.md)** | -WhatIf Religieux | La religion du -WhatIf |
| **[M6](PowershellCourse/cours-powershell-ad-moderne/modules-modernes/M6-kit-urgence.md)** | Kit Urgence | One-liners de survie pour tickets urgents |

#### 📚 Ressources PowerShell

| Ressource | Description |
|-----------|-------------|
| **[Cas d'horreur réels](PowershellCourse/cours-powershell-ad-moderne/cas-horreur-reels/vendredi-17h-sans-whatif.md)** | Vendredi 17h sans -WhatIf |
| **[Carte de survie maxtec.be](PowershellCourse/cours-powershell-ad-moderne/materiels-poche/carte-survie-maxtec.md)** | One-liners essentiels |
| **[Checklist validation scripts](PowershellCourse/cours-powershell-ad-moderne/materiels-poche/checklist-validation-scripts.md)** | Liste de contrôle avant exécution | 

---

## 🧪 Laboratoire et Exercices

### 📋 Laboratoire Principal

| Ressource | Description |
|-----------|-------------|
| **[Installation du Lab](Labo%20et%20Exercices/Labo/Labo_structure.md)** | Configuration complète de l'infrastructure maxtec.be |
| **[Guide Installation AD-DS](Labo%20Annexe%201-Guide%20de%20base%20installation%20AD-DS.md)** | Guide de base pour installer AD DS |
| **[Annexe: Permissions](Labo%20et%20Exercices/Labo/Annexe.Permissions.md)** | Guide détaillé des permissions NTFS et partage |

#### Scripts PowerShell

| Script | Description |
|--------|-------------|
| **[Scripts de création](Labo%20et%20Exercices/Labo/PowerShell-scriptsStructure/creation_structure.md)** | Scripts PowerShell pour créer la structure AD |
| **[Scripts de suppression](Labo%20et%20Exercices/Labo/PowerShell-scriptsStructure/suppression_structure.md)** | Scripts pour nettoyer l'environnement |

### 🏗️ Laboratoires Extra - Scénarios d'Entreprise

Des laboratoires complets avec structures AD réalistes, scripts automatisés et exercices progressifs.

#### Labo Extra 1 - CreativeHub

**Scénario:** Agence de marketing digital belge (18 employés, 4 départements)

| Ressource | Description |
|-----------|-------------|
| **[Présentation](Labos%20Extra/Labo1-CreativeHub/README.md)** | Objectifs pédagogiques, structure AD complète, scénario business |
| **[Script Setup](Labos%20Extra/Labo1-CreativeHub/scripts/CreativeHub_Setup.ps1)** | Création automatique: 17 OUs, 18 utilisateurs, 8 groupes, 3 GPOs |
| **[Script Cleanup](Labos%20Extra/Labo1-CreativeHub/scripts/CreativeHub_Cleanup.ps1)** | Suppression complète pour recommencer |

**Exercices pratiques (9 exercices progressifs):**

| # | Exercice | Niveau | Focus |
|---|----------|--------|-------|
| 01 | [Nouvel Employé](Labos%20Extra/Labo1-CreativeHub/exercices/Exercice_01_Nouvel_Employe.md) | Débutant | Création utilisateur, groupes GG- |
| 02 | [Départ Employé](Labos%20Extra/Labo1-CreativeHub/exercices/Exercice_02_Depart_Employe.md) | Débutant | Désactivation compte, archivage |
| 03 | [GPO Lecteur Réseau](Labos%20Extra/Labo1-CreativeHub/exercices/Exercice_03_GPO_Lecteur_Reseau.md) | Intermédiaire | Drive mapping via GPO |
| 04 | [Groupe Projet Client](Labos%20Extra/Labo1-CreativeHub/exercices/Exercice_04_Groupe_Projet_Client.md) | Intermédiaire | Groupes inter-départementaux |
| 05 | [Reset Password](Labos%20Extra/Labo1-CreativeHub/exercices/Exercice_05_Reset_Password.md) | Débutant | Réinitialisation mot de passe |
| 06 | [Délégation Contrôle](Labos%20Extra/Labo1-CreativeHub/exercices/Exercice_06_Delegation_Controle.md) | Avancé | Délégation permissions OU |
| 07 | [Onboarding Complet](Labos%20Extra/Labo1-CreativeHub/exercices/Exercice_07_Scenario_Onboarding_Complet.md) | Avancé | Scénario complet nouvel employé |
| 08 | [Troubleshooting GPO](Labos%20Extra/Labo1-CreativeHub/exercices/Exercice_08_Troubleshooting_GPO.md) | Avancé | Diagnostic problèmes GPO |
| 09 | [Crise Sécurité](Labos%20Extra/Labo1-CreativeHub/exercices/Exercice_09_Scenario_Crise_Securite.md) | Expert | Gestion incident sécurité |

**Scripts de vérification automatique:** Chaque exercice inclut un [script de vérification PowerShell](Labos%20Extra/Labo1-CreativeHub/scripts/verification/) avec feedback coloré.

**Pour instructeurs:**
- [Guide Instructeur](Labos%20Extra/Labo1-CreativeHub/instructeur/Guide_Instructeur_Exercices.md): Solutions complètes, timing, points clés
- [Index Exercices](Labos%20Extra/Labo1-CreativeHub/instructeur/INDEX_EXERCICES.md): Vue d'ensemble pédagogique

### 📝 Exercices Généraux

| Série | Focus | Difficulté |
|-------|-------|------------|
| **[Questions de Base](Labo%20et%20Exercices/Exercices:%20Questions%20Base.md)** | Validation des concepts fondamentaux | ⭐ Débutant |
| **[Gestion des Utilisateurs](Labo%20et%20Exercices/Exercices:%20Gestion_des_Utilisateurs.md)** | Création et gestion de comptes | ⭐⭐ Intermédiaire |
| **[OUs Départements](Labo%20et%20Exercices/Exercices:%20OUs_Departements_Complementaires.md)** | Structure organisationnelle avancée | ⭐⭐ Intermédiaire |
| **[GPO Série 1](Labo%20et%20Exercices/Exercices:%20GPO-1.md)** | Stratégies de groupe basiques | ⭐⭐ Intermédiaire |
| **[GPO Série 2](Labo%20et%20Exercices/Exercices:%20GPO-2.md)** | Filtrage et ciblage GPO | ⭐⭐⭐ Avancé |
| **[GPO Série 3](Labo%20et%20Exercices/Exercices:%20GPO-3.md)** | Scénarios complexes et troubleshooting | ⭐⭐⭐ Avancé |

---

## 📚 Références théoriques

| Document | Contenu |
|----------|---------|
| **[Théorie DNS Avancée](Th%C3%A9orie%20DNS-%20DNS%20Concepts%20Avances%20%28Reference%29.md)** | Concepts DNS approfondis (référence) |


---
