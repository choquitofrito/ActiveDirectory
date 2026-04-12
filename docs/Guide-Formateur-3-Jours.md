# Guide Formateur: Parcours 3 Jours (21h)

!!! tip "Philosophie de ce parcours"
    **Chaque session alterne théorie courte + pratique immédiate.** L'objectif est que les étudiants ne passent jamais plus de 30 minutes sans toucher le clavier. Le focus est sur les compétences **utiles et transférables** (PowerShell, IA, méthodologie) plutôt que sur la mémorisation de menus GUI.

---

## Prérequis

- [x] Windows Server 2022 installé (Chapitres 1-2 déjà faits)
- [x] DC fonctionnel (`dns1.maxtec.be`, 192.168.0.2)
- [x] Machine cliente jointe au domaine
- [x] VirtualBox Guest Additions installées (copier-coller fonctionnel)

---

## Jour 1: Fondations AD - Construire l'Infrastructure (7h)

!!! abstract "Objectif du jour"
    Les étudiants repartent avec une infrastructure AD complète et fonctionnelle: OUs, utilisateurs, groupes, et ont compris *pourquoi* cette structure existe.

### Matin (3h30)

#### Bloc 1: DNS - L'Essentiel (1h15)

| Durée | Activité | Ressource |
|-------|----------|-----------|
| 15 min | Théorie DNS condensée: uniquement "pourquoi AD a besoin de DNS" et types d'enregistrements | [Ch3 - DNS](Chapitre%203.DNS.md) (sections 1-2 uniquement) |
| 30 min | **Lab DNS pratique**: Explorer la zone maxtec.be, créer enregistrements A/CNAME, tester avec `nslookup` | [Ch5 - Labs 1-2](Chapitre%205.DNS-Pratique-avec-AD.md) |
| 15 min | **Lab DNS**: Zone inverse + Troubleshooting rapide | [Ch5 - Labs 3-4](Chapitre%205.DNS-Pratique-avec-AD.md) |
| 15 min | Exercice final DNS (serveur web) + checkpoint | [Ch5 - Exercice Final](Chapitre%205.DNS-Pratique-avec-AD.md#exercice-final-validation-complete) |

!!! warning "Gain de temps DNS"
    Sauter la section *Concepts Avancés DNS* (référence théorique). Les étudiants n'en ont pas besoin pour la suite. Le Ch3 est court (15 min), l'essentiel est dans le Ch5 (pratique). En combinant les deux, le DNS devient vivant au lieu de pesant.

---

#### Bloc 2: Active Directory - Vérification Post-Installation (15 min)

| Durée | Activité | Ressource |
|-------|----------|-----------|
| 15 min | Tour rapide d'AD DS: ADUC, sites et services, vérifier SYSVOL/NTDS. Pas de théorie longue - ils ont déjà un DC fonctionnel | [Ch4](Chapitre%204.Active%20Directory%20Domain%20Services%20(AD%20DS).md) (sections vérification) |

---

#### Bloc 3: Unités d'Organisation (1h00)

| Durée | Activité | Ressource |
|-------|----------|-----------|
| 20 min | Théorie OUs: hiérarchie, héritage, délégation. Insister sur le *pourquoi* (organiser = pouvoir appliquer des GPOs et déléguer) | [Ch6 - OUs](Chapitre%206.Unites_Organisation.md) |
| 10 min | **Déployer la structure MaxTec** (script de création). Les étudiants voient la structure se créer en live | [Script Création](Labo%20et%20Exercices/Labo/PowerShell-scriptsStructure/creation_structure.md) |
| 30 min | **Exercice OUs**: Créer les départements complémentaires (Informatique, Marketing, Logistique) | [Exercice OUs](Labo%20et%20Exercices/Exercices:%20OUs_Departements_Complementaires.md) (sections 1-3) |

!!! tip "Transition naturelle"
    Le script de création est un premier contact avec PowerShell AD. Les étudiants voient la puissance de l'automatisation avant même le cours PowerShell. Faites-leur lire le script et demandez: *"Que fait chaque ligne ?"*

---

#### Pause (15 min)

---

#### Bloc 4: Gestion des Utilisateurs (1h00)

| Durée | Activité | Ressource |
|-------|----------|-----------|
| 20 min | Théorie Utilisateurs: conventions de nommage, groupes (GG- obligatoire), AGDLP | [Ch7 - Utilisateurs](Chapitre%207.Gestion_des_Utilisateurs.md) |
| 40 min | **Exercices Utilisateurs**: Création, restrictions horaires, expiration comptes, restrictions poste de travail | [Exercices OUs](Labo%20et%20Exercices/Exercices:%20OUs_Departements_Complementaires.md) (sections 4-5) + [Exercices Utilisateurs](Labo%20et%20Exercices/Exercices:%20Gestion_des_Utilisateurs.md) |

---

### Après-midi (3h30)

#### Bloc 5: Lab CreativeHub - Déploiement + Exercices Débutant (2h00)

| Durée | Activité | Ressource |
|-------|----------|-----------|
| 10 min | Présenter le scénario CreativeHub (agence marketing, 18 employés). Lancer le script de setup | [CreativeHub README](Labos%20Extra/Labo1-CreativeHub/README.md) + [Setup](Labos%20Extra/Labo1-CreativeHub/scripts/CreativeHub_Setup.ps1) |
| 30 min | **Ex01 - Nouvel Employé**: Créer Sophie (graphiste) avec tous les attributs et groupes | [Exercice 01](Labos%20Extra/Labo1-CreativeHub/exercices/Exercice_01_Nouvel_Employe.md) |
| 20 min | **Ex02 - Départ Employé**: Désactiver un compte, retirer des groupes, archiver | [Exercice 02](Labos%20Extra/Labo1-CreativeHub/exercices/Exercice_02_Depart_Employe.md) |
| 15 min | **Ex05 - Reset Password**: Réinitialisation mot de passe, forcer changement | [Exercice 05](Labos%20Extra/Labo1-CreativeHub/exercices/Exercice_05_Reset_Password.md) |
| 30 min | **Ex04 - Groupe Projet Client**: Groupes inter-départementaux, projet temporaire | [Exercice 04](Labos%20Extra/Labo1-CreativeHub/exercices/Exercice_04_Groupe_Projet_Client.md) |
| 15 min | Vérification automatique avec scripts + discussion des résultats | Scripts `verif_exercice_0X.ps1` |

!!! success "Pourquoi CreativeHub et pas MediCare"
    CreativeHub est plus simple et progressif. MediCare (compliance RGPD, accès médical) est excellent mais plus adapté comme exercice autonome ou pour une session avancée. Gardez MediCare comme *exercice bonus* pour les étudiants rapides.

---

#### Bloc 6: Délégation + Exercice Intermédiaire (1h00)

| Durée | Activité | Ressource |
|-------|----------|-----------|
| 15 min | Concept de délégation de contrôle (qui peut gérer quoi dans l'AD) | [Ch6](Chapitre%206.Unites_Organisation.md) (section délégation) |
| 45 min | **Ex06 - Délégation Contrôle**: Donner des droits limités à un chef de département | [Exercice 06](Labos%20Extra/Labo1-CreativeHub/exercices/Exercice_06_Delegation_Controle.md) |

---

#### Buffer / Questions (30 min)

!!! info "Fin du Jour 1 - Checkpoint"
    Les étudiants doivent pouvoir:

    - [x] Vérifier le DNS avec `nslookup`
    - [x] Créer des OUs, utilisateurs et groupes via GUI
    - [x] Comprendre les conventions de nommage (GG-, prenom.nom)
    - [x] Gérer le cycle de vie d'un compte (création, modification, désactivation)
    - [x] Comprendre la délégation de contrôle

---

## Jour 2: GPOs (Obligatoire) + PowerShell Moderne - Le Déclic (7h)

!!! abstract "Objectif du jour"
    Couvrir les GPOs (exigence du programme) de manière efficace, puis basculer vers PowerShell moderne. À la fin de la journée, les étudiants auront eu leur "moment eureka" avec PowerShell et l'IA.

### Matin (3h30)

#### Bloc 1: GPOs - Théorie et Pratique (2h30)

| Durée | Activité | Ressource |
|-------|----------|-----------|
| 30 min | Théorie GPOs: LSDO, héritage, filtrage. Focus sur les concepts, pas sur les 500 options possibles | [Ch8 - GPOs](Chapitre%208.Group%20Policy%20Objects.md) |
| 45 min | **GPO Série 1**: Templates administratifs (bloquer panneau de config, bloquer CMD), messages de login | [GPO Série 1](Labo%20et%20Exercices/Exercices:%20GPO-1.md) |
| 30 min | **Ex03 - GPO Lecteur Réseau** (CreativeHub): Mapper un lecteur réseau par département | [Exercice 03](Labos%20Extra/Labo1-CreativeHub/exercices/Exercice_03_GPO_Lecteur_Reseau.md) |
| 30 min | **GPO Série 2**: Filtrage et ciblage GPO | [GPO Série 2](Labo%20et%20Exercices/Exercices:%20GPO-2.md) |
| 15 min | `gpupdate /force` + `gpresult /R` depuis le poste client. Vérification en live | Commandes directes |

!!! tip "GPOs - Juste ce qu'il faut"
    Les GPOs sont au programme mais leur avenir est limité (Intune/Azure prend le relais). Couvrez l'essentiel avec les exercices, puis passez rapidement à PowerShell qui est la vraie compétence transférable. La GPO Série 3 et l'Ex08 (Troubleshooting GPO) sont disponibles comme exercices bonus si nécessaire.

---

#### Bloc 2: Monitoring Express (30 min)

| Durée | Activité | Ressource |
|-------|----------|-----------|
| 15 min | Event Viewer: les Event IDs critiques (4720, 4726, 4740, 4625) | [Ch10 - Monitoring](Chapitre%2010.Monitoring.md) |
| 15 min | Demo live: faire un login échoué, retrouver l'événement dans le journal. Les étudiants cherchent sur leur propre machine | Pratique directe |

!!! info "Pourquoi ici et pas en fin de cours"
    Le monitoring donne du contexte aux modules PowerShell M4 (Scripts Bomba) et M6 (Kit Urgence). Les étudiants comprendront mieux les exercices de détection d'incidents s'ils ont vu les Event IDs.

---

#### Pause (15 min)

---

### Après-midi (3h30) - PowerShell: Le Déclic

!!! warning "Transition importante"
    *"Tout ce que vous avez fait ce matin en cliquant dans des menus... PowerShell peut le faire en une ligne. Et dans votre futur métier, c'est PowerShell (et bientôt Azure CLI) qui fera la différence entre un technicien et un admin."*

#### Bloc 3: M1 - Réalité 2025 (1h30)

| Durée | Activité | Ressource |
|-------|----------|-----------|
| 20 min | La confession: "Les pros ne mémorisent pas, ils valident et adaptent". Briser les mythes | [M1 - Réalité 2025](PowershellCourse/cours-powershell-ad-moderne/modules-modernes/M1-realite-2025.md) |
| 25 min | Demo live: résoudre un ticket réel avec Google + PowerShell. "Mon lundi typique" | M1 - Section "Mon Lundi Typique" |
| 25 min | **Exercice 1.1**: Trouver tous les utilisateurs du département IT de maxtec.be (avec Google/IA autorisé!) | M1 - Exercice Pratique 1.1 |
| 20 min | **Exercice Tickets Support N1**: 3 tickets réels à résoudre | M1 - Exercice Réaliste |

!!! success "Le moment clé"
    Quand vous autorisez explicitement Google et l'IA, vous voyez les étudiants se détendre. C'est le moment où ils passent de "je dois tout savoir" à "je dois savoir chercher et valider". C'est LE déclic du cours.

---

#### Bloc 4: M2 - Survie Tickets (1h30)

| Durée | Activité | Ressource |
|-------|----------|-----------|
| 15 min | Les 10 commandes qui résolvent 90% des tickets. Présenter la version safe / caution / dangereuse de chacune | [M2 - Survie Tickets](PowershellCourse/cours-powershell-ad-moderne/modules-modernes/M2-survie-tickets.md) |
| 15 min | **Exercice 2.1**: Diagnostiquer pourquoi Valeria ne peut pas se connecter | M2 - Exercice 2.1 |
| 15 min | **Exercice 2.2**: Trouver des utilisateurs par nom partiel | M2 - Exercice 2.2 |
| 15 min | **Exercice 2.3**: Ajouter Rebecca au groupe RH-Admins (avec vérifications de sécurité) | M2 - Exercice 2.3 |
| 15 min | **Exercice 2.8**: Créer un utilisateur complet en PowerShell | M2 - Exercice 2.8 |
| 15 min | **Quiz de Survie**: 5 tickets urgents à résoudre | M2 - Quiz de Survie |

---

#### Buffer / Carte de Survie (30 min)

| Durée | Activité | Ressource |
|-------|----------|-----------|
| 15 min | Distribuer/imprimer la **Carte de Survie MaxTec** (format poche). Les étudiants la personnalisent avec leurs notes | [Carte Survie](PowershellCourse/cours-powershell-ad-moderne/materiels-poche/carte-survie-maxtec.md) |
| 15 min | Questions, récap, preview du jour 3 | - |

!!! info "Fin du Jour 2 - Checkpoint"
    Les étudiants doivent pouvoir:

    - [x] Créer et appliquer une GPO basique
    - [x] Vérifier l'application avec `gpresult`
    - [x] Trouver et lire les Event IDs critiques
    - [x] Utiliser `Get-ADUser` avec des filtres
    - [x] Résoudre un ticket de support basique avec PowerShell
    - [x] Savoir chercher efficacement (Google, docs Microsoft, IA)

---

## Jour 3: PowerShell Avancé + IA + Scénarios de Crise (7h)

!!! abstract "Objectif du jour"
    La journée la plus intense et la plus utile. Les étudiants apprennent à utiliser l'IA comme copilote, à détecter les scripts dangereux, et à survivre en production. Ils repartent avec des compétences directement applicables et transférables vers Azure.

### Matin (3h30)

#### Bloc 1: M3 - IA comme Copilote (1h30)

| Durée | Activité | Ressource |
|-------|----------|-----------|
| 20 min | Les 5 règles d'or de l'IA. Le template de prompt professionnel. "IA = copilote, pas autopilote" | [M3 - IA Copilote](PowershellCourse/cours-powershell-ad-moderne/modules-modernes/M3-ia-comme-copilote.md) |
| 30 min | **Exercice 3.1**: Créer un prompt professionnel pour trouver les comptes verrouillés du département IT | M3 - Exercice 3.1 |
| 25 min | **Exercice 3.2 - IA Détective**: Analyser un script suspect généré par IA. Identifier les risques, les failles de sécurité | M3 - Exercice 3.2 |
| 15 min | Discussion: quand l'IA se trompe, comment le détecter ? Exemples réels | Discussion classe |

!!! tip "Windsurf / IDE moderne"
    Si vous avez accès à Windsurf (ou Cursor/VS Code + Copilot), montrez un live demo de génération de script avec validation. C'est le pont vers leur futur: les outils changent, la méthodologie de validation reste.

---

#### Bloc 2: M4 - Scripts Bomba Lab (1h30)

| Durée | Activité | Ressource |
|-------|----------|-----------|
| 10 min | Introduction: Les 5 techniques de camouflage dans les scripts dangereux | [M4 - Scripts Bomba](PowershellCourse/cours-powershell-ad-moderne/modules-modernes/M4-scripts-bomba-lab.md) |
| 25 min | **Mission Détective 4.1**: "Le Nettoyeur Innocent" - trouver les 5+ erreurs dans un script de suppression de groupes (10 min chrono!) | M4 - Mission 4.1 |
| 25 min | **Mission Détective 4.2**: "L'Organisateur de Déménagement" - script catastrophique avec `-Recursive` non validé | M4 - Mission 4.2 |
| 20 min | **Mission Détective 4.3**: "Le Sécurisateur" - script d'attaque brute force déguisé en audit de sécurité | M4 - Mission 4.3 |
| 10 min | Débriefing: Les 7 signaux d'alarme à toujours vérifier | Discussion classe |

!!! warning "Le module préféré des étudiants"
    Ce module fonctionne comme un jeu. Le format "détective avec chrono" crée de l'engagement. Laissez les étudiants travailler en binômes. La compétition amicale sur "qui trouve le plus d'erreurs" est très efficace.

---

#### Pause (15 min)

---

### Après-midi (3h30)

#### Bloc 3: M5 - WhatIf Religieux (1h00)

| Durée | Activité | Ressource |
|-------|----------|-----------|
| 15 min | Les 10 Commandements du -WhatIf. Le Hall of Fame des désastres (histoires réelles anonymisées) | [M5 - WhatIf](PowershellCourse/cours-powershell-ad-moderne/modules-modernes/M5-whatif-religieux.md) |
| 15 min | **Exercice 5.1**: Maîtriser les nuances de -WhatIf (commandes qui le supportent vs. celles qui ne le supportent pas) | M5 - Exercice 5.1 |
| 15 min | **Jeu Sérieux**: "WhatIf ou Catastrophe" - 4 scénarios, la classe vote | M5 - Jeu Sérieux |
| 15 min | **Certification -WhatIf**: 3 questions réflexe rapide (Marie, Stack Overflow, vendredi 17h45) | M5 - Test Final |

---

#### Bloc 4: M6 - Kit d'Urgence + Simulation de Crise (1h15)

| Durée | Activité | Ressource |
|-------|----------|-----------|
| 15 min | Les 10 étapes de survie quand tout explose. Le template de message d'incident | [M6 - Kit Urgence](PowershellCourse/cours-powershell-ad-moderne/modules-modernes/M6-kit-urgence.md) |
| 30 min | **Simulation d'Urgence Live**: Vendredi 17h12, l'équipe Ventes ne peut plus se connecter. La classe joue l'équipe d'urgence | M6 - Simulation d'Urgence |
| 15 min | Scripts de diagnostic rapide + scripts de récupération. Demo live | M6 - Scripts |
| 15 min | Distribution de la **Checklist d'Urgence** (format plastifié). Les étudiants la personnalisent | [Checklist](PowershellCourse/cours-powershell-ad-moderne/materiels-poche/checklist-validation-scripts.md) |

---

#### Bloc 5: Scénario Final Intégrateur (45 min)

Choisir UN scénario avancé selon le niveau de la classe:

| Option | Durée | Niveau | Description | Ressource |
|--------|-------|--------|-------------|-----------|
| **A** | 45 min | Avancé | Ex07 CreativeHub: Onboarding complet (GUI + PowerShell) | [Exercice 07](Labos%20Extra/Labo1-CreativeHub/exercices/Exercice_07_Scenario_Onboarding_Complet.md) |
| **B** | 45 min | Expert | Ex09 CreativeHub: Crise de sécurité (compte admin compromis) | [Exercice 09](Labos%20Extra/Labo1-CreativeHub/exercices/Exercice_09_Scenario_Crise_Securite.md) |
| **C** | 45 min | Avancé | Ex08 MediCare: Incident RGPD (investigation forensique) | [Exercice 08](Labos%20Extra/Labo2-MediCare/exercices/Exercice_08_Incident_RGPD.md) |

!!! tip "Choix du scénario"
    - **Option A** si la classe a eu du mal avec les exercices précédents (consolide les acquis)
    - **Option B** si la classe est à l'aise et aime les défis (application complète M4+M5+M6)
    - **Option C** si vous voulez introduire la dimension compliance/RGPD (très pertinent pour le futur)

---

#### Clôture (30 min)

| Durée | Activité |
|-------|----------|
| 10 min | **Cas d'Horreur Réels**: Lecture collective de "Vendredi 17h sans -WhatIf" - la conclusion parfaite |
| 10 min | Récapitulatif: les 5 choses à retenir pour leur carrière |
| 10 min | Questions finales, distribution des matériaux de poche |

**Les 5 choses à retenir:**

1. **-WhatIf est sacré** - Jamais de commande destructive sans -WhatIf d'abord
2. **L'IA est un copilote** - Utilisez-la, mais validez toujours ligne par ligne
3. **Google n'est pas de la triche** - C'est un outil professionnel
4. **PowerShell > GUI** - Ce que vous savez en PowerShell se transfère vers Azure/Entra
5. **En cas de crise: STOP, RESPIRER, DOCUMENTER** - Ne jamais agir sous la panique

!!! success "Fin du Jour 3 - Compétences Finales"
    Les étudiants repartent avec:

    - [x] Une infrastructure AD complète et fonctionnelle
    - [x] Les 10 commandes PowerShell essentielles
    - [x] La méthodologie de validation de scripts (IA ou humains)
    - [x] Les réflexes -WhatIf et sécurité
    - [x] La carte de survie et la checklist d'urgence (format poche)
    - [x] Une approche moderne et professionnelle transférable vers Azure

---

## Matériel à Préparer Avant la Formation

- [ ] Imprimer les [Cartes de Survie MaxTec](PowershellCourse/cours-powershell-ad-moderne/materiels-poche/carte-survie-maxtec.md) (1 par étudiant, format poche)
- [ ] Imprimer les [Checklists de Validation](PowershellCourse/cours-powershell-ad-moderne/materiels-poche/checklist-validation-scripts.md) (1 par étudiant)
- [ ] Vérifier que le DC et le client sont fonctionnels
- [ ] Avoir le script [CreativeHub Setup](Labos%20Extra/Labo1-CreativeHub/scripts/CreativeHub_Setup.ps1) prêt à exécuter
- [ ] Optionnel: avoir Windsurf/Cursor installé pour la demo IA (Jour 3)

## Exercices Bonus (Étudiants Rapides)

Si certains étudiants finissent avant les autres, proposez dans cet ordre:

1. [GPO Série 3](Labo%20et%20Exercices/Exercices:%20GPO-3.md) - Scénarios complexes GPO
2. [Ex08 - Troubleshooting GPO](Labos%20Extra/Labo1-CreativeHub/exercices/Exercice_08_Troubleshooting_GPO.md) - Diagnostic GPO
3. [Lab MediCare](Labos%20Extra/Labo2-MediCare/README.md) - Scénario santé complet (setup + exercices)
4. [Lab MonitoringLab](Labos%20Extra/Labo3-MonitoringLab/README.md) - Monitoring avancé
5. [Exercices OUs restants](Labo%20et%20Exercices/Exercices:%20OUs_Departements_Complementaires.md) (sections 6-9)

## Adaptation Selon le Niveau

### Classe Débutante (peu d'expérience IT)
- Jour 1: Ralentir sur les OUs et utilisateurs, plus de temps GUI
- Jour 2: Réduire GPO Série 2, plus de temps pour M1-M2
- Jour 3: Sauter M4 Mission 4.3 (brute force), plus de temps pour la simulation M6

### Classe Avancée (admins en poste)
- Jour 1: Accélérer DNS/OUs, ajouter les exercices de délégation avancée
- Jour 2: Ajouter GPO Série 3, accélérer M1 (ils vivent déjà cette réalité)
- Jour 3: Faire les 3 scénarios finaux au lieu d'un seul, ajouter le Lab MonitoringLab
