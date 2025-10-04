# Exercices Pratiques - CreativeHub

Le laboratoire CreativeHub comprend **9 exercices progressifs** organisés par niveau de difficulté.

## Vue d'Ensemble

| # | Titre | Niveau | Durée | Compétences Clés |
|---|-------|--------|-------|------------------|
| 01 | [Nouvel Employé](Exercice_01_Nouvel_Employe.md) | 🟢 Débutant | 15-20 min | Création utilisateur, groupes |
| 02 | [Départ Employé](Exercice_02_Depart_Employe.md) | 🟢 Débutant | 15 min | Désactivation, documentation |
| 03 | [GPO Lecteur Réseau](Exercice_03_GPO_Lecteur_Reseau.md) | 🟢 Débutant | 20-25 min | GPO, préférences, liaison |
| 04 | [Groupe Projet Client](Exercice_04_Groupe_Projet_Client.md) | 🟡 Intermédiaire | 20-25 min | Groupes Global/DomainLocal, AGDLP |
| 05 | [Reset Password](Exercice_05_Reset_Password.md) | 🟡 Intermédiaire | 15 min | Sécurité, gestion incidents |
| 06 | [Délégation Contrôle](Exercice_06_Delegation_Controle.md) | 🟡 Intermédiaire | 25-30 min | ACL, moindre privilège |
| 07 | [Onboarding Complet](Exercice_07_Scenario_Onboarding_Complet.md) | 🔴 Avancé | 40-50 min | Workflow complet, décisions |
| 08 | [Troubleshooting GPO](Exercice_08_Troubleshooting_GPO.md) | 🔴 Avancé | 30-40 min | Diagnostic, gpresult |
| 09 | [Crise Sécurité](Exercice_09_Scenario_Crise_Securite.md) | 🔴 Avancé | 60-90 min | Gestion crise, investigation |

---

## Niveau Débutant 🟢

Ces exercices vous guident **étape par étape** avec des instructions détaillées.

### [Exercice 01: Nouvel Employé](Exercice_01_Nouvel_Employe.md)

**Scénario**: Créer le compte de Sophie Moreau, nouvelle graphiste qui commence aujourd'hui.

**Vous apprendrez**:
- Créer un compte utilisateur via l'interface graphique
- Configurer les propriétés essentielles (email, département, fonction)
- Ajouter un utilisateur à un groupe de sécurité

**Script de vérification**: [verif_exercice_01.ps1](../scripts/verification/verif_exercice_01.ps1)

---

### [Exercice 02: Départ Employé](Exercice_02_Depart_Employe.md)

**Scénario**: Manon Girard quitte l'entreprise. Gérer son départ de manière professionnelle.

**Vous apprendrez**:
- Désactiver un compte utilisateur (vs. suppression)
- Documenter les actions pour l'audit
- Retirer un utilisateur des groupes de sécurité

**Script de vérification**: [verif_exercice_02.ps1](../scripts/verification/verif_exercice_02.ps1)

---

### [Exercice 03: GPO Lecteur Réseau](Exercice_03_GPO_Lecteur_Reseau.md)

**Scénario**: Mapper automatiquement un lecteur réseau pour le projet client TechVision.

**Vous apprendrez**:
- Créer une stratégie de groupe (GPO)
- Configurer les préférences de GPO (Drive Maps)
- Lier une GPO à une unité organisationnelle

**Script de vérification**: [verif_exercice_03.ps1](../scripts/verification/verif_exercice_03.ps1)

---

## Niveau Intermédiaire 🟡

Ces exercices décrivent l'objectif sans donner d'instructions détaillées. À vous de trouver comment faire!

### [Exercice 04: Groupe Projet Client](Exercice_04_Groupe_Projet_Client.md)

**Scénario**: Créer une structure de groupes pour le projet confidentiel SecureBank.

**Vous apprendrez**:
- Créer des groupes Global et Domain Local
- Comprendre et appliquer le modèle AGDLP
- Organiser des permissions multi-départements

**Script de vérification**: [verif_exercice_04.ps1](../scripts/verification/verif_exercice_04.ps1)

---

### [Exercice 05: Reset Password](Exercice_05_Reset_Password.md)

**Scénario**: Incident de sécurité - Bastien pense que son mot de passe a été compromis.

**Vous apprendrez**:
- Réinitialiser un mot de passe de manière sécurisée
- Déverrouiller un compte utilisateur
- Gérer un incident de sécurité selon les bonnes pratiques

**Script de vérification**: [verif_exercice_05.ps1](../scripts/verification/verif_exercice_05.ps1)

---

### [Exercice 06: Délégation Contrôle](Exercice_06_Delegation_Controle.md)

**Scénario**: Permettre aux responsables de département de gérer leurs propres équipes.

**Vous apprendrez**:
- Utiliser l'assistant de délégation de contrôle
- Comprendre les listes de contrôle d'accès (ACL)
- Appliquer le principe du moindre privilège

**Script de vérification**: [verif_exercice_06.ps1](../scripts/verification/verif_exercice_06.ps1)

---

## Niveau Avancé 🔴

Ces exercices sont des **scénarios réalistes complexes** nécessitant analyse, décisions et troubleshooting.

### [Exercice 07: Onboarding Complet](Exercice_07_Scenario_Onboarding_Complet.md)

**Scénario**: Accueil complet d'une nouvelle stagiaire avec toutes les étapes professionnelles.

**Vous apprendrez**:
- Gérer un workflow d'onboarding de A à Z
- Prendre des décisions stratégiques (sécurité, organisation)
- Créer une documentation complète pour l'audit

**Script de vérification**: [verif_exercice_07.ps1](../scripts/verification/verif_exercice_07.ps1)

---

### [Exercice 08: Troubleshooting GPO](Exercice_08_Troubleshooting_GPO.md)

**Scénario**: La GPO de restriction des juniors ne s'applique pas sur certains utilisateurs. Pourquoi?

**Vous apprendrez**:
- Diagnostiquer les problèmes de GPO
- Utiliser `gpresult`, `gpupdate`, et GPMC
- Comprendre le filtrage de sécurité des GPOs
- Méthodologie de troubleshooting systématique

**Script de vérification**: [verif_exercice_08.ps1](../scripts/verification/verif_exercice_08.ps1)

---

### [Exercice 09: Crise Sécurité](Exercice_09_Scenario_Crise_Securite.md)

**Scénario**: Le compte d'un administrateur a été compromis. Gestion de crise complète.

**Vous apprendrez**:
- Containment: isoler la menace immédiatement
- Investigation: identifier l'étendue de la compromission
- Remediation: nettoyer et sécuriser
- Documentation: rapport d'incident professionnel

**Script de vérification**: [verif_exercice_09.ps1](../scripts/verification/verif_exercice_09.ps1)

---

## Parcours d'Apprentissage Recommandé

### Débutants Complets

1. Exercices 01 → 02 → 03 (niveau débutant)
2. Pause et révision des concepts
3. Exercices 04 → 05 (niveau intermédiaire)
4. Choisir UN exercice avancé (07 ou 08)

**Durée totale**: 1 journée (6-8 heures)

### Étudiants avec Bases AD

1. Exercices 01 → 03 (révision rapide)
2. Exercices 04 → 05 → 06 (renforcement)
3. Exercices 07 → 08 → 09 (tous les scénarios avancés)

**Durée totale**: 1.5 journées (10-12 heures)

---

## Badges de Certification

Complétez les exercices pour obtenir votre badge:

| Badge | Critères | Exercices Requis |
|-------|----------|------------------|
| 🥉 **Bronze** | Compétences de base AD | 01, 02, 03, 04 réussis |
| 🥈 **Argent** | Compétences intermédiaires | 01-06 réussis |
| 🥇 **Or** | Compétences avancées | 01-08 réussis |
| 💎 **Diamant** | Maîtrise complète | 01-09 réussis + Rapport professionnel |

---

## Support

### Scripts de Vérification

Chaque exercice dispose d'un **script PowerShell de vérification automatique**.

Exécutez-le après avoir terminé l'exercice pour valider votre travail:

```powershell
cd "C:\Labos\CreativeHub\verification"
.\verif_exercice_01.ps1
```

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

### Problèmes Courants

| Problème | Solution Rapide |
|----------|-----------------|
| Script PowerShell bloqué | `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| Utilisateur introuvable | Vérifier SAM exact (sensible à la casse) |
| GPO ne s'applique pas | `gpupdate /force` puis redémarrer session |
| Permission refusée | Se connecter en tant qu'administrateur du domaine |

---

## Documentation Instructeur

Les formateurs peuvent consulter:

- **[Index Exercices](../instructeur/INDEX_EXERCICES.md)**: Vue d'ensemble complète avec matrice de compétences
- **[Guide Instructeur](../instructeur/Guide_Instructeur_Exercices.md)**: Conseils pédagogiques, timing, évaluation

---

**Bon courage et bonne formation! 🚀**
