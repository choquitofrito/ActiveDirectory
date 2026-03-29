# INDEX - Exercices Active Directory CreativeHub

## 📚 Vue d'Ensemble

Cette collection contient **9 exercices progressifs** pour l'apprentissage de l'administration Active Directory, utilisant un environnement de lab réaliste basé sur une agence de marketing digital nommée **CreativeHub**.

**Domaine** : maxtec.be
**Environnement** : Windows Server 2022 + Clients Windows
**Durée totale** : 6-8 heures de pratique

---

## 🎯 Exercices par Niveau

### 🟢 Niveau Débutant (Guided Step-by-Step)

| # | Titre | Fichier | Durée | Compétences |
|---|-------|---------|-------|-------------|
| 1 | Bienvenue à notre Nouveau Graphiste ! | [Exercice_01_Nouvel_Employe.md](../exercices/Exercice_01_Nouvel_Employe.md) | 15-20 min | Création utilisateur, Configuration propriétés, Ajout aux groupes |
| 2 | Gérer le Départ d'un Employé | [Exercice_02_Depart_Employe.md](../exercices/Exercice_02_Depart_Employe.md) | 15 min | Désactivation compte, Documentation, Gestion des départs |
| 3 | Créer une GPO pour Mapper un Lecteur Projet Client | [Exercice_03_GPO_Lecteur_Reseau.md](../exercices/Exercice_03_GPO_Lecteur_Reseau.md) | 20-25 min | Création GPO, Préférences, Liaison OU |

**Objectif** : Acquérir les bases de l'administration AD via des instructions détaillées étape par étape.

---

### 🟡 Niveau Intermédiaire (Task-Based)

| # | Titre | Fichier | Durée | Compétences |
|---|-------|---------|-------|-------------|
| 4 | Créer un Groupe de Sécurité pour un Projet Client Confidentiel | [Exercice_04_Groupe_Projet_Client.md](../exercices/Exercice_04_Groupe_Projet_Client.md) | 20-25 min | Groupes Global/DomainLocal, AGDLP, Organisation multi-départements |
| 5 | Incident de Sécurité - Réinitialisation de Mot de Passe | [Exercice_05_Reset_Password.md](../exercices/Exercice_05_Reset_Password.md) | 15 min | Sécurité, Réinitialisation MDP, Déverrouillage compte, Gestion incident |
| 6 | Délégation de Contrôle - Autonomiser les Responsables de Département | [Exercice_06_Delegation_Controle.md](../exercices/Exercice_06_Delegation_Controle.md) | 25-30 min | Délégation de contrôle, ACL, Principe du moindre privilège |

**Objectif** : Appliquer les connaissances de manière autonome sans instructions détaillées.

---

### 🔴 Niveau Avancé (Scenarios & Troubleshooting)

| # | Titre | Fichier | Durée | Compétences |
|---|-------|---------|-------|-------------|
| 7 | Scénario Complet - Onboarding d'une Nouvelle Stagiaire | [Exercice_07_Scenario_Onboarding_Complet.md](../exercices/Exercice_07_Scenario_Onboarding_Complet.md) | 40-50 min | Workflow complet, Décisions stratégiques, Documentation, Sécurité stagiaires |
| 8 | Troubleshooting - "La GPO Ne S'Applique Pas !" | [Exercice_08_Troubleshooting_GPO.md](../exercices/Exercice_08_Troubleshooting_GPO.md) | 30-40 min | Diagnostic GPO, Filtrage de sécurité, gpresult, Méthodologie troubleshooting |
| 9 | Scénario de Crise - Compte Administrateur Compromis | [Exercice_09_Scenario_Crise_Securite.md](../exercices/Exercice_09_Scenario_Crise_Securite.md) | 60-90 min | Gestion de crise, Containment, Investigation, Remediation, Documentation incident |

**Objectif** : Résoudre des problèmes complexes et réalistes en situation professionnelle.

---

## 🔍 Scripts de Vérification

Chaque exercice dispose d'un script PowerShell de vérification automatique :

| Exercice | Script de Vérification | Description |
|----------|------------------------|-------------|
| 1 | [verif_exercice_01.ps1](../scripts/verification/verif_exercice_01.ps1) | Vérification création utilisateur Sophie |
| 2 | [verif_exercice_02.ps1](../scripts/verification/verif_exercice_02.ps1) | Vérification désactivation compte Manon |
| 3 | [verif_exercice_03.ps1](../scripts/verification/verif_exercice_03.ps1) | Vérification GPO mappage lecteur TechVision |
| 4 | [verif_exercice_04.ps1](../scripts/verification/verif_exercice_04.ps1) | Vérification groupe projet SecureBank |
| 5 | [verif_exercice_05.ps1](../scripts/verification/verif_exercice_05.ps1) | Vérification réinitialisation MDP Bastien |
| 6 | [verif_exercice_06.ps1](../scripts/verification/verif_exercice_06.ps1) | Vérification délégation Gabrielle/Camille |
| 7 | [verif_exercice_07.ps1](../scripts/verification/verif_exercice_07.ps1) | Vérification onboarding stagiaire Léa |
| 8 | [verif_exercice_08.ps1](../scripts/verification/verif_exercice_08.ps1) | Vérification troubleshooting GPO juniors |
| 9 | [verif_exercice_09.ps1](../scripts/verification/verif_exercice_09.ps1) | Vérification gestion incident sécurité |

**Utilisation** :
```powershell
.\verif_exercice_01.ps1
```

---

## 📖 Documentation Complémentaire

| Document | Description |
|----------|-------------|
| [Guide_Instructeur_Exercices.md](Guide_Instructeur_Exercices.md) | Guide complet pour les formateurs (séquençage, pédagogie, évaluation) |
| [README_CreativeHub.md](../README.md) | Documentation du lab CreativeHub (structure, utilisateurs, groupes) |
| [CreativeHub_Setup.ps1](../scripts/CreativeHub_Setup.ps1) | Script de déploiement du lab |
| [CreativeHub_Cleanup.ps1](../scripts/CreativeHub_Cleanup.ps1) | Script de nettoyage du lab |

---

## 🗺️ Parcours d'Apprentissage Recommandé

### Séquence Standard (1 journée - 8 heures)

```
09h00 - 09h30  │ Introduction lab CreativeHub
09h30 - 10h00  │ 🟢 Exercice 1 : Créer un utilisateur
10h00 - 10h15  │ ☕ Pause
10h15 - 10h45  │ 🟢 Exercice 2 : Désactiver un compte
10h45 - 11h30  │ 🟢 Exercice 3 : GPO mappage réseau
11h30 - 12h00  │ Debriefing et Q&A
───────────────┼──────────────────────────────────────
12h00 - 13h00  │ 🍽️ Pause déjeuner
───────────────┼──────────────────────────────────────
13h00 - 13h45  │ 🟡 Exercice 4 : Groupes de sécurité
13h45 - 14h15  │ 🟡 Exercice 5 : Incident sécurité
14h15 - 14h30  │ ☕ Pause
14h30 - 15h30  │ 🟡 Exercice 6 : Délégation de contrôle
15h30 - 16h45  │ 🔴 Exercice 7 ou 8 (au choix selon niveau)
16h45 - 17h00  │ Récapitulatif et conclusion
```

### Séquence Intensive (2 jours)

**Jour 1** : Exercices 1-6 + Théorie approfondie
**Jour 2** : Exercices 7-9 + Projet final personnalisé

---

## 🎓 Compétences Développées

### Par Thématique

| Thématique | Exercices | Compétences Acquises |
|------------|-----------|----------------------|
| **Gestion Utilisateurs** | 1, 2, 5, 7 | Création, modification, désactivation, réinitialisation MDP |
| **Groupes de Sécurité** | 1, 4, 7 | Groupes Global/DomainLocal, AGDLP, appartenance multiple |
| **Stratégies de Groupe (GPO)** | 3, 7, 8 | Création, liaison, préférences, filtrage sécurité, troubleshooting |
| **Sécurité** | 2, 5, 7, 9 | Incidents, forensics, audit, bonnes pratiques |
| **Délégation & Permissions** | 6 | Délégation de contrôle, ACL, moindre privilège |
| **Organisation AD** | 7 | Structure OU, planification, documentation |
| **Troubleshooting** | 8, 9 | Diagnostic, méthodologie, résolution problèmes |

---

## 📊 Matrice de Compétences

| Exercice | Création | Modification | Suppression | Groupes | GPO | Sécurité | Troubleshooting | Documentation |
|----------|----------|--------------|-------------|---------|-----|----------|-----------------|---------------|
| 1 | ✅✅✅ | ✅ | - | ✅✅ | - | - | - | ✅ |
| 2 | - | ✅ | ✅ | ✅ | - | ✅ | - | ✅✅ |
| 3 | ✅ | - | - | - | ✅✅✅ | - | - | ✅ |
| 4 | ✅✅ | - | - | ✅✅✅ | - | ✅ | - | ✅ |
| 5 | - | ✅✅ | - | - | - | ✅✅✅ | ✅ | ✅ |
| 6 | - | ✅ | - | ✅ | - | ✅✅ | ✅ | ✅✅ |
| 7 | ✅✅✅ | ✅✅ | - | ✅✅ | ✅✅ | ✅✅✅ | - | ✅✅✅ |
| 8 | ✅ | ✅ | - | ✅✅ | ✅✅ | ✅✅ | ✅✅✅ | ✅✅ |
| 9 | - | ✅✅✅ | ✅✅ | ✅ | ✅ | ✅✅✅ | ✅✅✅ | ✅✅✅ |

**Légende** : ✅ = Utilisation basique | ✅✅ = Utilisation intermédiaire | ✅✅✅ = Utilisation avancée

---

## 🏆 Système d'Évaluation

### Badges de Certification

| Badge | Critères | Exercices Requis |
|-------|----------|------------------|
| 🥉 **Bronze** | Compétences de base AD | 1, 2, 3, 4 réussis |
| 🥈 **Argent** | Compétences intermédiaires AD | 1-6 réussis |
| 🥇 **Or** | Compétences avancées AD | 1-8 réussis |
| 💎 **Diamant** | Maîtrise complète + Documentation exemplaire | 1-9 réussis + Rapport professionnel |

### Grille de Notation

| Critère | Poids | Description |
|---------|-------|-------------|
| **Exactitude technique** | 40% | Tous les tests de vérification passent |
| **Autonomie** | 20% | Utilisation minimale des indices/aide |
| **Documentation** | 15% | Notes structurées et complètes |
| **Bonnes pratiques** | 15% | Respect des conventions, sécurité, AGDLP |
| **Gestion du temps** | 10% | Complétion dans les délais estimés |

---

## 💡 Conseils pour les Étudiants

### Avant de Commencer

1. ✅ Assurez-vous que le lab CreativeHub est déployé
2. ✅ Lisez entièrement l'énoncé avant de commencer
3. ✅ Préparez un bloc-notes pour documenter vos actions
4. ✅ Comprenez le contexte business du scénario

### Pendant l'Exercice

1. 📝 **Documentez** chaque action effectuée
2. 🧪 **Testez** après chaque étape majeure
3. 🔍 **Vérifiez** avec le script avant de passer au suivant
4. 💬 **Demandez** de l'aide si bloqué > 15 minutes
5. 🤔 **Réfléchissez** aux implications de sécurité

### Après l'Exercice

1. ✅ Exécutez le script de vérification
2. 📊 Comparez votre approche avec la solution
3. 📚 Notez les commandes PowerShell utiles
4. 🔄 Refaites l'exercice si < 80% de réussite

---

## 🆘 Support et Ressources

### En Cas de Problème Technique

| Problème | Solution Rapide |
|----------|-----------------|
| Script PowerShell ne s'exécute pas | `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| Compte utilisateur introuvable | Vérifier le SAM Account exact (sensible à la casse) |
| GPO ne s'applique pas | `gpupdate /force` puis `gpresult /r` |
| Permission refusée | Vérifier que vous êtes connecté en tant qu'administrateur |

### Commandes PowerShell Essentielles

```powershell
# Gestion Utilisateurs
Get-ADUser -Identity <sam> -Properties *
New-ADUser -Name "..." -SamAccountName "..." -Path "OU=..."
Set-ADUser -Identity <sam> -Description "..."
Disable-ADAccount -Identity <sam>

# Gestion Groupes
Get-ADGroup -Filter {Name -like "*projet*"}
New-ADGroup -Name "..." -GroupScope Global -Path "OU=..."
Add-ADGroupMember -Identity <groupe> -Members <utilisateur>
Get-ADGroupMember -Identity <groupe>

# Gestion GPO
Get-GPO -All
New-GPO -Name "..."
New-GPLink -Name <gpo> -Target "OU=..." -LinkEnabled Yes
gpresult /r /scope:user

# Diagnostic
Get-ADOrganizationalUnit -Filter *
Get-EventLog -LogName Security -Newest 10
```

---

## 📞 Contact et Feedback

### Pour les Instructeurs

Des questions sur la mise en œuvre ? Besoin de personnaliser les exercices ?
Consultez le [Guide_Instructeur_Exercices.md](Guide_Instructeur_Exercices.md) pour des conseils pédagogiques détaillés.

### Pour les Étudiants

Feedback sur les exercices ? Suggestions d'amélioration ?
Partagez vos retours avec votre formateur pour améliorer continuellement la formation.

---

## 📜 Licence et Utilisation

Ces exercices sont conçus pour un usage pédagogique dans le cadre de formations Active Directory.

**Autorisations** :

- ✅ Usage en classe et formations
- ✅ Adaptation pour votre contexte spécifique
- ✅ Distribution aux étudiants

**Conditions** :

- Conserver les crédits et références
- Partager les améliorations avec la communauté
- Usage non-commercial uniquement

---

## 🎯 Objectif Final

À l'issue de ces 9 exercices, les étudiants seront capables de :

✅ **Créer et gérer** des comptes utilisateurs AD de manière professionnelle
✅ **Organiser** une structure AD avec OUs et groupes de sécurité
✅ **Implémenter** des stratégies de groupe (GPO) pour la gestion et la sécurité
✅ **Déléguer** le contrôle AD selon le principe du moindre privilège
✅ **Diagnostiquer et résoudre** des problèmes AD courants
✅ **Gérer** des incidents de sécurité selon une méthodologie professionnelle
✅ **Documenter** leurs actions pour l'audit et la traçabilité

**Bonne formation et bon courage ! 🚀**

---

*Index créé le : 2025-10-04*
*Environnement : CreativeHub Lab - maxtec.be*
*Version : 1.0*
