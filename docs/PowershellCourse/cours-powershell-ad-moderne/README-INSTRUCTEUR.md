# 🚀 PowerShell AD Moderne 2025 - Guide de l'Instructeur



### Philosophie Centrale
- **PowerShell comme outil**, pas de programmation
- **Lecture/validation de scripts IA** > écriture from scratch
- **Honnêteté totale** sur comment on travaille vraiment en 2025
- **Prévention des désastres** avant les fonctionnalités avancées

## 🎯 Intégration avec le Syllabus Existant

### Prérequis OBLIGATOIRES
Les étudiants DOIVENT avoir complété :
- ✅ Chapitres 1-8 (théorie AD complète)
- ✅ Laboratoire maxtec.be configuré et fonctionnel
- ✅ Chapitres 9.0-9.3 (concepts de base PowerShell)
- ✅ Utilisateurs et groupes existants créés

### Continuité Pédagogique
Ce cours **complète** (ne remplace PAS) le contenu existant :
- **Construit** sur la base théorique déjà acquise
- **Modernise** les pratiques avec la philosophie 2025
- **Applique** les connaissances à des scénarios professionnels réels

### Journée de Formation Intensive

| Module | Durée | Contenu | Pause |
|--------|-------|---------|-------|
| **M1: Réalité 2025** |  | Confessions d'admin réel + démo live | ☕ |
| **M2: Survie Tickets** |  | 10 commandes qui sauvent des carrières | 🍽️ |
| **M3: IA comme Copilote** |  | Prompts sécurisés + validation critique | ☕ |
| **M4: Scripts Bombes Lab** |  | Détecter erreurs mortelles cachées | ☕ |
| **M5: -WhatIf Religieux** |  | Pourquoi -WhatIf est sacré | ☕ |
| **M6: Kit d'Urgence** |  | Procédures de panique | |
| **TOTAL** |  | | |

## 🏗️ Infrastructure Existante (maxtec.be)

### Domaine et Structure (DÉJÀ CONFIGURÉS)
```
Domaine: maxtec.be
DC: dns1.maxtec.be (192.168.0.2)
Base DN: DC=maxtec,DC=be

Structure OU:
OU=EU,DC=maxtec,DC=be
├── OU=IT
│   ├── OU=Users (Ivan, Ines, Irene)
│   └── OU=Groups (GG-EU-IT-Users, GG-EU-IT-Admins)
├── OU=Ventes
│   ├── OU=Users (Victor, Vanessa, Valeria, Valentin)
│   └── OU=Groups (GG-EU-Ventes-Users, GG-EU-Ventes-Admins)
├── OU=RH
│   ├── OU=Users (Rene, Rebecca, Richard)
│   └── OU=Groups (GG-EU-RH-Users, GG-EU-RH-Admins)
└── OU=Compta
    ├── OU=Users (Charles, Cindy, Charlotte)
    └── OU=Groups (GG-EU-Compta-Users, GG-EU-Compta-Admins)
```

### Vérification Initiale (EXÉCUTER AVANT LE COURS)
```powershell
# Vérifier que le laboratoire est prêt
Get-ADDomain | Select-Object DNSRoot, DomainMode
Get-ADUser -Filter * -SearchBase "OU=EU,DC=maxtec,DC=be" | Measure-Object
Get-ADGroup -Filter {Name -like "GG-EU-*"} | Measure-Object

# Doit afficher :
# - Domaine: maxtec.be
# - Utilisateurs: minimum 12 (3 par département + admins)
# - Groupes: minimum 8 (2 par département)
```

## 🎪 Dynamique de Classe Révolutionnaire

### Ambiance de Confession
1. **Cercle d'honnêteté** (5 min début) :
   - "Qui googler la syntaxe PowerShell ?" (tous lèvent la main)
   - "Qui a utilisé ChatGPT pour des scripts ?" (normaliser)
   - "Qui a cassé quelque chose avec PowerShell ?" (storytelling)

2. **Démonstrations en direct** (PAS de slides) :
   - Instructeur utilisant Google/ChatGPT en temps réel
   - Erreurs genuines et troubleshooting authentique
   - "C'est comme ça que je travaille vraiment le lundi"

3. **Apprendre du désastre** :
   - Chaque commande dangereuse = histoire d'horreur
   - Scripts bombes pour détecter avant l'explosion
   - Culture de "-WhatIf d'abord, exécuter après"

### Méthodologie "Mains Sales"
- **80% terminal, 20% théorie**
- Exercices avec données réelles de maxtec.be
- Erreurs provoquées pour apprendre le troubleshooting
- Validation constante en laboratoire vivant

## 🚨 Protocole de Sécurité de la Classe

### Règles Sacrées
1. **JAMAIS exécuter sans -WhatIf** au premier essai
2. **TOUJOURS vérifier** la portée avant de modifier
3. **BACKUP mental** : puis-je annuler ceci ?
4. **Demander avant** Remove-*, Set-* massif, Move-*

### Commandes Interdites en Classe
```powershell
# ☠️ JAMAIS démontrer sans -WhatIf
Get-ADUser -Filter * | Remove-ADUser
Get-ADGroup -Filter * | Remove-ADGroup
Get-ADOrganizationalUnit -Filter * | Remove-ADOrganizationalUnit

# ⚡ Toujours avec -WhatIf d'abord
Get-ADUser -Filter {Enabled -eq $false} | Remove-ADUser -WhatIf
```

## 📚 Matériel de Support Essentiel

### Pour l'Instructeur
- ✅ Laptop avec PS 5.1 et module AD
- ✅ Accès à maxtec.be depuis projecteur
- ✅ Scripts bombes prêts pour analyse
- ✅ Histoires d'horreur préparées (3-4 anecdotes)
- ✅ Timer visible pour timing exact

### Pour les Étudiants
- ✅ Accès au laboratoire maxtec.be
- ✅ Carte de survie imprimée
- ✅ Checklist de validation scripts
- ✅ Prompts IA sécurisés laminés

## 🎭 Cas d'Usage par Module

### M1: Réalité 2025
**Démo centrale** : "Mon lundi typique"
- Réviser les tickets en attente
- Chercher utilisateurs avec problèmes login
- Valider les appartenances aux groupes
- Reporter au superviseur

**Confession clé** : "Je ne mémorise pas la syntaxe, je la consulte"

### M2: Survie Tickets
**Scénarios réels** :
1. "User locked out" → `Get-ADUser -Identity Richard -Properties LockedOut`
2. "Nouvel employé besoin groupes" → `Add-ADGroupMember -WhatIf`
3. "Département déménagé" → `Get-ADUser -Filter {Department -eq "X"}`

### M3: IA comme Copilote
**Démo en direct** : Utiliser ChatGPT pour générer script
- Prompt : "Script PS pour utilisateurs inactifs avec validation"
- Réviser output ligne par ligne
- Identifier améliorations nécessaires
- Ajouter -WhatIf où ça manque

### M4: Scripts Bombes
**Analyse forensique** : Trouver erreurs cachées
- Script apparemment légitime
- Chercher lignes dangereuses
- Que se passerait-il si j'exécute ça ?
- Comment le réparer avant le désastre

### M5: -WhatIf Religieux
**Simulacre de désastre** : Script sans -WhatIf
- Montrer output destructif
- Calculer temps de récupération
- Histoire réelle de vendredi 17h
- Pratique avec commandes sécurisées

### M6: Kit d'Urgence
**Jeu de rôle de crise** : "Tout explose vendredi 17h"
- Respirer, pas de panique
- Documenter ce qui a mal tourné
- Vérifier backups disponibles
- Appeler superviseur avant de "réparer"

## 🏆 Évaluation Révolutionnaire

### PAS de Test Traditionnel
Au lieu d'un examen théorique :

**Simulacre de Ticket Réel** :
1. **Scénario** : "Onboarding 25 nouveaux employés lundi 8h"
2. **Script fourni** : Avec 3 erreurs cachées (bombe)
3. **Tâche** : Identifier erreurs + créer version sécurisée
4. **Limite temps** : 45 minutes
5. **Critères succès** :
   - Trouve erreurs critiques
   - Propose solution avec -WhatIf
   - Explique pourquoi c'est dangereux

### Compétences Évaluées
- ✅ Détecte code dangereux
- ✅ Utilise -WhatIf religieusement
- ✅ Valide portée avant d'exécuter
- ✅ Consulte aide sans honte
- ✅ Documente changements effectués

## 🚀 Conseils pour Maximiser l'Impact

### Avant de Commencer
1. **Survey rapide** : "Combien ont cassé quelque chose avec PowerShell ?"
2. **Attentes** : "On va confesser, pas faire semblant"
3. **Environnement sûr** : "Erreurs = apprentissage, pas honte"

### Pendant le Cours
1. **Pause chaque 45 min** : Obligatoire, pas optionnelle
2. **Erreurs célébrées** : "Excellente erreur ! Apprenons d'elle"
3. **Histoires réelles** : Une par module, maximum 3 minutes
4. **Hands-on constant** : Parler < 10%, faire > 90%

### À la Fin
1. **Cercle de réflexion** : "Qu'est-ce qui changera lundi ?"
2. **Engagement public** : "Mon premier -WhatIf sera..."
3. **Réseau de support** : Échange contacts pour questions

## 📞 Support Post-Cours

### Canal d'Urgence
- **Slack/Teams** : #powershell-survival
- **Email** : powershell-help@maxtec.be
- **Horaire** : L-V 9h-17h réponse < 2h

### Révision Mensuelle
- **Follow-up** 30 jours : Qu'avez-vous appliqué ?
- **Cas réels** partagés : construire base de connaissances
- **Mises à jour** du cours : nouveaux scripts bombes, cas horreur

---

## 🎯 Objectif Final

**En complétant ce cours**, les étudiants pourront :
- ✅ **Lire et valider** scripts IA de manière critique
- ✅ **Détecter code dangereux** avant d'exécuter
- ✅ **Utiliser -WhatIf religieusement** en production
- ✅ **Résoudre tickets réels** avec confiance
- ✅ **Gérer crises** sans panique (protocole break-glass)
- ✅ **Travailler honnêtement** avec outils 2025

**Résultat** : Admins qui **survivent et prospèrent** dans le monde réel, pas qui mémorisent la syntaxe.

---

*"Le but n'est pas de les transformer en programmeurs PowerShell. Le but est qu'ils n'aient plus jamais peur d'un script, qu'ils sachent quand quelque chose est dangereux, et que lundi ils puissent résoudre des tickets réels avec confiance."*

**- Philosophie du Cours PowerShell AD Moderne 2025**