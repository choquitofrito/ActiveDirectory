# Cours Active Directory - Haute École Bruxelles-Brabant (H2EB)

> 📚 **Formation complète sur Active Directory Domain Services**
> Infrastructure d'entreprise moderne avec labs pratiques sur **maxtec.be**

---

## 🎯 À propos du cours

Ce cours vous guide à travers l'installation, la configuration et l'administration d'**Active Directory** dans un environnement d'entreprise simulé. Vous travaillerez sur l'infrastructure **maxtec.be** avec des labs pratiques et des exercices concrets.

**Public:** Étudiants en informatique, administrateurs systèmes débutants
**Prérequis:** Connaissances de base Windows Server
**Durée estimée:** 60-80 heures (théorie + pratique)

---

## 📖 Chapitres du cours

### 🏗️ Fondations (Chapitres 1-2)

| Chapitre | Titre | Contenu | Durée |
|----------|-------|---------|-------|
| **[Chapitre 1](Chapitre%201.Introduction%20et%20installation%20de%20Windows%20Server.md)** | Introduction et Installation Windows Server | Concepts de base, architecture serveur, installation Windows Server 2022 | 3h |
| **[Chapitre 2](Chapitre%202.Installation-Windows-Server-2022-VirtualBox.md)** | Installation VirtualBox | Configuration environnement de virtualisation, création VMs | 2h |

### 🌐 Infrastructure réseau (Chapitres 3-4)

| Chapitre | Titre | Contenu | Durée |
|----------|-------|---------|-------|
| **[Chapitre 3](Chapitre%203.DNS.md)** | DNS - Préparation pour AD | Concepts DNS essentiels pour Active Directory | 30min |
| **[Chapitre 4](Chapitre%204.Active%20Directory%20Domain%20Services%20%28AD%20DS%29.md)** | Active Directory Domain Services | Installation et configuration AD DS sur maxtec.be | 4h |
| **[Chapitre 4-bis](Chapitre%204bis.DNS-Pratique-avec-AD.md)** | DNS Pratique avec AD | Labs DNS avec domaine fonctionnel (5 labs progressifs) | 90min |

### 🏢 Organisation et gestion (Chapitres 5-7)

| Chapitre | Titre | Contenu | Durée |
|----------|-------|---------|-------|
| **[Chapitre 5](Chapitre%205.Unites_Organisation.md)** | Unités d'Organisation (OUs) | Structure hiérarchique, délégation AGLP/AGDLP | 4h |
| **[Chapitre 6](Chapitre%206.Gestion_des_Utilisateurs.md)** | Gestion des Utilisateurs | Création comptes, groupes, permissions NTFS/partage | 5h |
| **[Chapitre 7](Chapitre%207.Group%20Policy%20Objects.md)** | Group Policy Objects (GPO) | Stratégies de groupe, LSDO, filtrage et délégation | 6h |

### 💻 Automatisation PowerShell (Chapitre 8)

| Chapitre | Titre | Contenu | Durée |
|----------|-------|---------|-------|
| **[Chapitre 8.0](Chapitre%208.0.Powershell%20AD%20-%20Introduction.md)** | PowerShell AD - Introduction | Premiers pas avec le module Active Directory | 1h |
| **[Chapitre 8.1](Chapitre%208.1.Powershell%20AD%20-%20Concepts%20base.md)** | PowerShell AD - Concepts de base | Cmdlets essentiels, syntaxe, pipelines | 2h |
| **[Chapitre 8.2](Chapitre%208.2.Powershell%20AD%20-%20Requetes_et_Informations.md)** | PowerShell AD - Requêtes | Get-ADUser, Get-ADGroup, filtres et recherches | 3h |
| **[Chapitre 8.3](Chapitre%208.3.Powershell%20AD%20-%20Creation_et_Modification.md)** | PowerShell AD - Création et Modification | New-ADUser, Set-ADUser, gestion en masse | 4h |

---

## 🧪 Laboratoire et Exercices

### 📋 Laboratoire de base

| Ressource | Description |
|-----------|-------------|
| **[Installation du Lab](Labo%20et%20Exercices/Labo/Labo_structure.md)** | Configuration complète de l'infrastructure maxtec.be |
| **[Scripts de création](Labo%20et%20Exercices/Labo/PowerShell-scriptsStructure/creation_structure.md)** | Scripts PowerShell pour créer la structure AD |
| **[Scripts de suppression](Labo%20et%20Exercices/Labo/PowerShell-scriptsStructure/suppression_structure.md)** | Scripts pour nettoyer l'environnement |
| **[Annexe: Permissions](Labo%20et%20Exercices/Labo/Annexe.Permissions.md)** | Guide détaillé des permissions NTFS et partage |

### 📝 Séries d'exercices

| Série | Focus | Difficulté |
|-------|-------|------------|
| **[Questions de Base](Labo%20et%20Exercices/Exercices:%20Questions%20Base.md)** | Validation des concepts fondamentaux | ⭐ Débutant |
| **[Gestion des Utilisateurs](Labo%20et%20Exercices/Exercices:%20Gestion_des_Utilisateurs.md)** | Création et gestion de comptes | ⭐⭐ Intermédiaire |
| **[OUs Départements](Labo%20et%20Exercices/Exercices:%20OUs_Departements_Complementaires.md)** | Structure organisationnelle avancée | ⭐⭐ Intermédiaire |
| **[GPO Série 1](Labo%20et%20Exercices/Exercices:%20GPO-1.md)** | Stratégies de groupe basiques | ⭐⭐ Intermédiaire |
| **[GPO Série 2](Labo%20et%20Exercices/Exercices:%20GPO-2.md)** | Filtrage et ciblage GPO | ⭐⭐⭐ Avancé |
| **[GPO Série 3](Labo%20et%20Exercices/Exercices:%20GPO-3.md)** | Scénarios complexes et troubleshooting | ⭐⭐⭐ Avancé |

---

## 🎓 Cours PowerShell AD Moderne (2025)

Un cours complémentaire axé sur la **réalité du terrain** et l'utilisation moderne de PowerShell AD.

| Module | Titre | Philosophie |
|--------|-------|-------------|
| **[M1](PowershellCourse/cours-powershell-ad-moderne/modules-modernes/M1-realite-2025.md)** | Réalité 2025 | Google/IA comme outils, pas comme tricherie |
| **[M2](PowershellCourse/cours-powershell-ad-moderne/modules-modernes/M2-survie-tickets.md)** | Survie Tickets | Résoudre des incidents réels rapidement |
| **[M3](PowershellCourse/cours-powershell-ad-moderne/modules-modernes/M3-ia-comme-copilote.md)** | IA comme Copilote | ChatGPT/Copilot pour PowerShell AD |
| **[M4](PowershellCourse/cours-powershell-ad-moderne/modules-modernes/M4-scripts-bomba-lab.md)** | Scripts Bomba Lab | Désactiver 800 users sans -WhatIf |
| **[M5](PowershellCourse/cours-powershell-ad-moderne/modules-modernes/M5-whatif-religieux.md)** | -WhatIf Religieux | La religion du -WhatIf |
| **[M6](PowershellCourse/cours-powershell-ad-moderne/modules-modernes/M6-kit-urgence.md)** | Kit Urgence | One-liners de survie pour tickets urgents |

### 📚 Ressources complémentaires

- **[Cas d'horreur réels](PowershellCourse/cours-powershell-ad-moderne/cas-horreur-reels/vendredi-17h-sans-whatif.md)** : Vendredi 17h sans -WhatIf
- **[Carte de survie maxtec.be](PowershellCourse/cours-powershell-ad-moderne/materiels-poche/carte-survie-maxtec.md)** : One-liners essentiels
- **[Checklist validation scripts](PowershellCourse/cours-powershell-ad-moderne/materiels-poche/checklist-validation-scripts.md)** : Liste de contrôle avant exécution
- **[Scripts "bomba"](PowershellCourse/cours-powershell-ad-moderne/laboratoire-maxtec/scripts-bomba-maxtec/)** : Exemples de scripts dangereux (à des fins pédagogiques)

### 📖 Documentation instructeur

- **[README Instructeur](PowershellCourse/cours-powershell-ad-moderne/README-INSTRUCTEUR.md)** : Guide pour l'enseignant
- **[Résumé du cours](PowershellCourse/cours-powershell-ad-moderne/README-COURSE-SUMMARY.md)** : Vue d'ensemble et objectifs

---

## 📚 Références théoriques

| Document | Contenu |
|----------|---------|
| **[Théorie DNS Avancée](Th%C3%A9orie%20DNS-%20DNS%20Concepts%20Avances%20%28Reference%29.md)** | Concepts DNS approfondis (référence) |

---

## 📥 Versions PDF

Tous les chapitres et exercices sont disponibles en PDF dans le dossier **[pdfs/](pdfs/)**:

- Chapitres individuels (Chapitre 1 à 8)
- Exercices (GPO-1 à GPO-3, OUs, Gestion Utilisateurs)
- **[Cours complet.pdf](pdfs/Cours%20complet.pdf)** : Tous les chapitres en un seul document

---

## 🗺️ Parcours d'apprentissage recommandé

### 🟢 Niveau Débutant (Semaines 1-4)

1. Chapitres 1-2: Installation et configuration environnement
2. Chapitre 3-4: DNS et installation AD DS
3. Installation du laboratoire maxtec.be
4. Exercices: Questions de Base

### 🟡 Niveau Intermédiaire (Semaines 5-8)

1. Chapitre 5: Unités d'Organisation
2. Chapitre 6: Gestion des Utilisateurs
3. Chapitre 7: Group Policy Objects
4. Exercices: Gestion Utilisateurs, OUs, GPO-1

### 🔴 Niveau Avancé (Semaines 9-12)

1. Chapitre 8 (complet): PowerShell AD
2. Cours PowerShell AD Moderne (M1-M6)
3. Exercices: GPO-2, GPO-3
4. Labs pratiques avancés

---

## 🛠️ Infrastructure du cours

### Domaine: **maxtec.be**

**Architecture:**
- **Domaine AD principal:** maxtec.be
- **Sites:** Site-EU (192.168.10.0/24), Site-US (192.168.20.0/24)
- **Contrôleur de domaine:** dns1.maxtec.be
- **Structure organisationnelle:**
  - EU/
    - Comptabilité/
    - RH/
    - Ventes/
    - IT/
  - USA/ (structure identique)

---

## 💡 Philosophie pédagogique

Ce cours adopte une approche **"Just-in-Time Learning"**:

✅ **Théorie minimale** avant la pratique
✅ **Labs hands-on** avec infrastructure réelle
✅ **Concepts expliqués** au moment où ils sont nécessaires
✅ **Exercices progressifs** du simple au complexe
✅ **Checkpoints réguliers** pour valider la compréhension

> 💡 **Règle d'or:** 40% théorie, 60% pratique pour un apprentissage optimal

---

## 📞 Support et Ressources

- **Labo complet:** [Labo_structure.md](Labo%20et%20Exercices/Labo/Labo_structure.md)
- **Scripts automatisés:** Dossier [PowerShell-scriptsStructure](Labo%20et%20Exercices/Labo/PowerShell-scriptsStructure/)
- **Template navigation:** [_template_navigation.md](_template_navigation.md)

---

## 📝 TODO et Améliorations

Consultez [TODO.txt](TODO.txt) pour les améliorations planifiées du cours.

---

**📚 Cours Active Directory - H2EB | 2025 | 👨‍💻 Pour débutants et intermédiaires**

> 🎯 *"Apprendre Active Directory en construisant une vraie infrastructure d'entreprise"*
