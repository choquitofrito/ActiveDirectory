# Guide Instructeur - Exercices Active Directory CreativeHub

## Vue d'Ensemble

Cette collection de **9 exercices progressifs** a été conçue pour former des étudiants débutants à l'administration Active Directory en utilisant le lab **CreativeHub** (agence de marketing digital et design).

**Durée totale estimée** : 6-8 heures de pratique hands-on

**Public cible** : Étudiants avec 4 jours (28 heures) de formation AD, certains sans background technique

## Structure Pédagogique

### Progression des Compétences

Les exercices suivent une progression pédagogique rigoureuse en 3 niveaux :

#### 🟢 Niveau Débutant (Exercices 1-3)
**Objectif** : Acquérir les compétences de base via des instructions étape par étape

- **Exercice 1** : Créer un utilisateur et l'ajouter à un groupe
- **Exercice 2** : Désactiver un compte et gérer un départ
- **Exercice 3** : Créer et lier une GPO de mappage réseau

**Caractéristiques** :
- Instructions détaillées avec captures d'écran recommandées
- Résultats attendus après chaque étape
- Approche "hold-your-hand" pour construire la confiance
- Durée : 15-25 minutes par exercice

#### 🟡 Niveau Intermédiaire (Exercices 4-6)
**Objectif** : Appliquer les connaissances sans instructions détaillées

- **Exercice 4** : Créer un groupe projet multi-départements
- **Exercice 5** : Gérer un incident de sécurité (réinitialisation MDP)
- **Exercice 6** : Déléguer le contrôle AD à des responsables

**Caractéristiques** :
- Objectifs clairs mais pas de marche à suivre
- Indices disponibles si nécessaire
- Développe l'autonomie et la réflexion
- Durée : 20-30 minutes par exercice

#### 🔴 Niveau Avancé (Exercices 7-9)
**Objectif** : Résoudre des scénarios complexes et réalistes

- **Exercice 7** : Onboarding complet d'une stagiaire (multi-tâches)
- **Exercice 8** : Troubleshooting GPO qui ne s'applique pas
- **Exercice 9** : Gérer une crise de sécurité (compte admin compromis)

**Caractéristiques** :
- Scénarios réalistes d'entreprise
- Aucune instruction, juste des objectifs
- Nécessite recherche et réflexion critique
- Durée : 40-90 minutes par exercice

## Fichiers Créés

### Exercices (Markdown)

| Fichier | Niveau | Durée | Compétences Clés |
|---------|--------|-------|------------------|
| `Exercice_01_Nouvel_Employe.md` | 🟢 Débutant | 15-20 min | Création utilisateur, groupes |
| `Exercice_02_Depart_Employe.md` | 🟢 Débutant | 15 min | Désactivation compte, documentation |
| `Exercice_03_GPO_Lecteur_Reseau.md` | 🟢 Débutant | 20-25 min | GPO, mappage réseau, préférences |
| `Exercice_04_Groupe_Projet_Client.md` | 🟡 Intermédiaire | 20-25 min | Groupes sécurité, AGDLP, délégation |
| `Exercice_05_Reset_Password.md` | 🟡 Intermédiaire | 15 min | Sécurité, réinitialisation MDP, déverrouillage |
| `Exercice_06_Delegation_Controle.md` | 🟡 Intermédiaire | 25-30 min | Délégation, ACL, moindre privilège |
| `Exercice_07_Scenario_Onboarding_Complet.md` | 🔴 Avancé | 40-50 min | Workflow complet, OU, GPO, sécurité |
| `Exercice_08_Troubleshooting_GPO.md` | 🔴 Avancé | 30-40 min | Diagnostic, filtrage sécurité, gpresult |
| `Exercice_09_Scenario_Crise_Securite.md` | 🔴 Très Avancé | 60-90 min | Gestion de crise, forensics, documentation |

### Scripts de Vérification (PowerShell)

Chaque exercice dispose d'un script de vérification automatique :

- `verif_exercice_01.ps1` à `verif_exercice_09.ps1`
- Exécutables par les étudiants pour auto-évaluation
- Feedback détaillé et coloré
- Suggestions de correction en cas d'erreur

## Guide d'Utilisation en Classe

### Préparation (Avant le Cours)

1. **Déployer le lab CreativeHub** :
   ```powershell
   .\CreativeHub_Setup.ps1
   ```

2. **Vérifier l'environnement** :
   - 1 contrôleur de domaine Windows Server 2022
   - 2 clients Windows joints au domaine (optionnel pour tests)
   - Domaine : maxtec.be
   - Structure AD créée par le script

3. **Distribuer les exercices** :
   - Imprimer ou partager les fichiers .md
   - Mettre les scripts de vérification à disposition

### Déroulement Recommandé

#### Séquence sur 1 Journée (8 heures)

**Matin (4 heures)** :
- 09h00-09h30 : Introduction et démo du lab CreativeHub
- 09h30-10h00 : Exercice 1 (guidé en groupe)
- 10h00-10h15 : Pause
- 10h15-10h45 : Exercice 2 (guidé, travail individuel)
- 10h45-11h30 : Exercice 3 (GPO - plus complexe)
- 11h30-12h00 : Debriefing et Q&A
- 12h00-13h00 : Pause déjeuner

**Après-midi (4 heures)** :
- 13h00-13h45 : Exercice 4 (intermédiaire)
- 13h45-14h15 : Exercice 5 (incident sécurité)
- 14h15-14h30 : Pause
- 14h30-15h30 : Exercice 6 (délégation - plus long)
- 15h30-16h30 : Exercice 7 ou 8 (avancé - selon niveau du groupe)
- 16h30-17h00 : Récapitulatif et remise des certificats

#### Séquence sur 2 Demi-Journées

**Jour 1 (4 heures)** : Exercices 1-6
**Jour 2 (4 heures)** : Exercices 7-9 + projet final

### Approche Pédagogique Recommandée

#### Pour les Exercices Débutants (1-3)

1. **Démonstration** : Montrer l'exercice 1 en live devant la classe
2. **Pratique guidée** : Les étudiants reproduisent en parallèle
3. **Pratique autonome** : Exercices 2 et 3 en autonomie
4. **Vérification** : Utiliser les scripts de vérification
5. **Debriefing** : Corriger en groupe, expliquer les erreurs courantes

#### Pour les Exercices Intermédiaires (4-6)

1. **Lecture du scénario** : Chaque étudiant lit le contexte
2. **Réflexion** : 5 minutes pour planifier l'approche
3. **Exécution** : Travail individuel (indices disponibles)
4. **Vérification** : Script automatique
5. **Partage** : Les étudiants partagent leurs approches différentes

#### Pour les Exercices Avancés (7-9)

1. **Mise en situation** : Lire le scénario à voix haute (créer l'urgence)
2. **Travail individuel ou par binôme** : 45-90 minutes
3. **Prises de notes obligatoires** : Documenter les actions
4. **Présentation** : Chaque groupe présente sa solution
5. **Discussion** : Comparer les approches, identifier les bonnes pratiques

### Gestion des Différences de Niveau

**Si des étudiants terminent en avance** :
- Proposer les "Pour Aller Plus Loin" dans chaque exercice
- Demander de créer leur propre exercice
- Faire du peer-teaching (aider les autres)

**Si des étudiants sont en difficulté** :
- Débloquer avec les indices fournis
- Permettre le travail en binôme
- Fournir la solution PowerShell mais demander de comprendre chaque ligne

## Scripts de Vérification - Guide Instructeur

### Fonctionnalités

Chaque script `verif_exercice_XX.ps1` :

✅ **Vérifie automatiquement** tous les critères de réussite
✅ **Affiche un feedback coloré** (Vert=OK, Rouge=Erreur, Jaune=Avertissement)
✅ **Fournit des suggestions** de correction
✅ **Génère un score** pour les exercices avancés
✅ **Rappelle les bonnes pratiques** AD

### Utilisation en Classe

```powershell
# Étudiant exécute :
.\verif_exercice_01.ps1

# Exemple de sortie :
# ========================================
# Vérification Exercice 1
# ========================================
# Test 1: Existence de l'utilisateur 'sophie'
#   ✓ RÉUSSI - L'utilisateur 'sophie' existe
# Test 2: Emplacement dans l'OU Creative\Users
#   ✓ RÉUSSI - Sophie est dans l'OU correcte
# ...
# 🎉 EXERCICE RÉUSSI ! PARFAIT !
```

### Personnalisation

Les instructeurs peuvent modifier les scripts pour :
- Ajouter des tests spécifiques
- Ajuster les critères de réussite
- Adapter au contexte de leur lab

## Solutions Instructeur

### Accès aux Solutions

Chaque exercice contient une section **"Solution Complète (Pour Instructeur)"** avec :

1. **Méthode GUI** : Étapes via interface graphique
2. **Méthode PowerShell** : Script complet automatisé
3. **Vérifications post-exécution** : Commandes de validation

### Quand Donner les Solutions

**❌ À ÉVITER** :
- Donner la solution dès qu'un étudiant demande
- Afficher les solutions au tableau

**✅ RECOMMANDÉ** :
- Laisser les étudiants chercher (minimum 10-15 min)
- Fournir des indices progressifs d'abord
- Donner la solution après vérification de l'effort
- Utiliser les solutions pour le debriefing final

## Évaluation des Étudiants

### Grille d'Évaluation Suggérée

| Critère | Exercices 1-3 | Exercices 4-6 | Exercices 7-9 | Points |
|---------|---------------|---------------|---------------|--------|
| **Exactitude** | Tous les tests passent | Tous les tests passent | Score ≥ 80% | 40% |
| **Autonomie** | Suit les instructions | Utilise peu d'indices | Aucune aide | 20% |
| **Documentation** | Notes basiques | Notes structurées | Rapport complet | 15% |
| **Bonnes pratiques** | Respecte les noms | Justifie les choix | AGDLP, Sécurité | 15% |
| **Temps** | Dans les délais | Dans les délais | Gestion du temps | 10% |
| **TOTAL** | | | | 100% |

### Certification Suggérée

**Bronze** : Exercices 1-6 réussis (compétences de base)
**Argent** : Exercices 1-8 réussis (compétences avancées)
**Or** : Tous les exercices réussis + documentation exemplaire

## Scénarios Additionnels (Extensions)

Pour prolonger la formation, créez des variantes :

### Exercice 10 (Proposition) : Fusion Départementale

> CreativeHub absorbe une petite agence concurrente. Vous devez :
> - Créer une nouvelle OU "AgenceAcquise"
> - Migrer 5 utilisateurs
> - Fusionner les groupes
> - Gérer les conflits de noms

### Exercice 11 (Proposition) : Audit de Conformité RGPD

> Un auditeur externe arrive demain. Vous devez :
> - Lister tous les comptes avec accès aux données clients
> - Identifier les comptes inactifs (> 90 jours)
> - Générer un rapport de conformité
> - Nettoyer les comptes obsolètes

## Dépannage Courant

### Problème : Les étudiants ne peuvent pas exécuter les scripts PowerShell

**Cause** : Execution Policy restrictive

**Solution** :
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Problème : Le lab CreativeHub n'est pas déployé correctement

**Diagnostic** :
```powershell
Get-ADOrganizationalUnit -Filter {Name -eq "CreativeHub"}
Get-ADUser -Filter * -SearchBase "OU=CreativeHub,DC=maxtec,DC=be"
```

**Solution** : Relancer le script de setup

### Problème : Les GPO ne s'appliquent pas sur les clients

**Cause** : Clients pas dans le bon OU ou GPO pas liée

**Solution** :
```powershell
# Sur le client
gpupdate /force
gpresult /r
```

## Ressources Complémentaires

### Documentation Microsoft

- [Active Directory Administration](https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/)
- [Group Policy Overview](https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/manage/group-policy/)
- [PowerShell Active Directory Module](https://docs.microsoft.com/en-us/powershell/module/activedirectory/)

### Formations Recommandées

- Microsoft Learn : Windows Server Administration
- Pluralsight : Active Directory Fundamentals
- LinkedIn Learning : Active Directory Essential Training

### Communautés

- Reddit : r/sysadmin, r/PowerShell
- TechNet Forums : Windows Server
- Stack Overflow : Active Directory tags

## Feedback et Amélioration Continue

### Collecte de Feedback Étudiant

À la fin de chaque exercice, demander :
1. Difficulté perçue (1-5)
2. Clarté des instructions (1-5)
3. Temps nécessaire vs estimé
4. Suggestions d'amélioration

### Évolution des Exercices

Basé sur le feedback :
- Ajuster les durées estimées
- Clarifier les instructions ambiguës
- Ajouter des indices supplémentaires
- Créer des variantes pour différents niveaux

## Conclusion

Ces 9 exercices forment un parcours pédagogique complet pour transformer des débutants en administrateurs AD compétents. L'approche progressive, les scénarios réalistes et les scripts de vérification automatiques créent une expérience d'apprentissage immersive et efficace.

**Clés du succès** :
- ✅ Environnement lab réaliste (CreativeHub)
- ✅ Progression pédagogique rigoureuse
- ✅ Feedback immédiat via scripts de vérification
- ✅ Scénarios engageants et professionnels
- ✅ Documentation exhaustive pour autonomie

**Bonne formation !** 🎓

---

*Document créé le : 2025-10-04*
*Auteur : Claude Code - Assistant Pédagogique AD*
*Version : 1.0*
