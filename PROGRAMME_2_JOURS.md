# Programme des 2 derniers jours — Cours AD ISIB

Lab : **Maxtec** (`DC=maxtec,DC=be`)
Format : 2 journées de 7 h
Contexte (analyses, décisions, alternatives) : voir `PLAN_2_JOURS.md`.

---

## Jour 1 — Hook délégation + GPOs pro + Monitoring + Teaser PowerShell

Principe directeur : alterner blocs GPO et changements de tempo pour éviter 3 h d'affilée de GPO. AGDLP déjà vu, donc retiré. Le **hook délégation** en ouverture donne dès le départ le "pourquoi" professionnel de tout ce qui suit — la théorie abstraite passe pendant que les cerveaux sont frais, l'exercice complet de délégation arrive en fin de journée (bloc 5) avec tous les prérequis acquis.

| # | Durée | Bloc | Matériel |
|---|------|------|----------|
| 0 | 20 min | **Hook délégation — Démo + théorie**<br>**Démo en vivo (10 min)** : ouvrir une session en tant que Valentin (`GG-EU-Ventes-Admins`, **pas** Domain Admin) et modifier la GPO de Ventes. Message : "Voilà comment AD passe à l'échelle dans une vraie entreprise sans que l'IT soit goulot d'étranglement."<br>**Théorie (10 min)** : les 3 niveaux de délégation (Security Filtering = qui reçoit la GPO / onglet Delegation = qui modifie la GPO / Delegate Control sur l'OU = qui peut lier des GPOs) + principe du moindre privilège.<br>**Contrat pédagogique** : "À la fin de la journée, vous saurez construire toutes les pièces qui rendent ça possible — bloc 5."<br><br>⚙️ **Prérequis technique — RSAT sur le poste client** : la démo suppose que `gpmc.msc` est disponible sur le poste de Valentin (les outils RSAT s'installent côté client, GPMC ne tourne pas sur le DC). **Procédure GUI complète (Paramètres → Apps → Fonctionnalités facultatives → RSAT)** : voir `docs/Labos Extra/Labo1-CreativeHub/exercices/Exercice_06_Delegation_Controle.md` **lignes 20-50** — c'est le seul endroit du syllabus avec la procédure pas à pas. Alternative rapide en classe : `runas /user:maxtec\valentin "mmc gpmc.msc"` depuis le DC (pas besoin de RSAT côté client, mais moins fidèle à la réalité terrain). | `Chapitre 8` §6 + §7 + `Exercices: GPO-2.md` Ex. 7 (à survoler, pas à faire)<br>📍 **RSAT** : `Labo1-CreativeHub/Exercice_06` L. 20-50 |
| 1 | 1 h 30 | **Finir GPO-1**<br>2.4 mappage lecteur Z: pour IT → 3 Préférences (LinkBureau) | `Exercices: GPO-1.md` §2.4 à §3 |
| 2 | 1 h 30 | **GPO-3 §1 — Redirection de dossiers** (la GPO "phare" pro)<br>Création du partage `C:\Shares-Compta` (Share + NTFS), GPO `GPO-Redirection-Dossiers-Comptabilite` liée à `OU=EU\Comptabilité\Users`, redirection Documents vers `\\dns1\Shares\Comptabilite\UserData`, test multi-postes avec Charles. | `Exercices: GPO-3.md` §1 |
| 🍴 | 1 h | **Pause déjeuner** | |
| 3 | 1 h | **Monitoring — vérifier l'effet des GPOs du matin**<br>Pivot pédagogique : on passe de "configurer" à "observer". `gpresult /r` + `gpresult /h rapport.html` (RSOP HTML), `rsop.msc`, Custom View dans Event Viewer (Event IDs 4624/4625/5126/5136/5137), démo `Get-WinEvent -FilterHashtable`. | `Chapitre 10` §🛠️ Outils + §📋 Event IDs |
| 4 | 1 h | **GPO-2 — Ex. 5 + Ex. 6**<br>Restriction de logon par machine (IT) + script PowerShell de nettoyage Téléchargements au logon. Rappel Item-level targeting (`GPO-3 §2`) si temps. | `Exercices: GPO-2.md` Ex. 5–6 + `GPO-3.md` §2 |
| 5 | 1 h | **Délégation OU + Délégation GPO** (paiement de la promesse du bloc 0)<br>Rappel express de la théorie (déjà vue le matin) → Ex. 12 (déléguer reset password sur OU RH) → enchaîner avec Ex. 7 GPO-2 (Security Filtering + onglet Delegation + délégation des liens sur l'OU). Test avec Valentin via `runas` — c'est la même démo qu'au bloc 0, mais cette fois les étudiants la construisent. | `Chapitre 7` §8 + `Exercices: Gestion_des_Utilisateurs.md` Ex. 12 + `Exercices: GPO-2.md` Ex. 7 |
| 6 | 30 min | **Teaser PowerShell**<br>Démo : 5 cmdlets `Get-*` qui font ce qu'ils ont fait à la GUI ces deux jours. Le `Get-WinEvent` du bloc 3 a déjà planté la graine. | Démo libre — voir `CHEATSHEET.md` §2-§4 |

**Total : 6 h 50 + 1 h pause = 7 h 50.** Si trop long, raccourcir le bloc 5 à 45 min (délégation GPO seule, la théorie a déjà été vue au bloc 0) ou le bloc 4 à 45 min (Ex. 5 seul, Ex. 6 en option).

**Garanties du découpage** :

- **Hook au bloc 0** : la théorie de délégation passe à froid (cerveaux frais) avant les clics, et donne le "pourquoi" de toute la journée
- Max **1 h 30 consécutives** de GPO (jamais 3 h en bloc)
- **Monitoring** = vraie pause cognitive *active* qui consolide la matière du matin
- Les GPO "phares" pro y sont toutes (mappage Z:, redirection dossiers, restrictions, script logon, délégation)
- **Symétrie pédagogique** : le bloc 5 paie la promesse faite au bloc 0 (les étudiants reconstruisent eux-mêmes la démo du matin)
- Le `Get-WinEvent` introduit naturellement PowerShell sans rompre le fil GPO

---

## Jour 2 — PowerShell AD (sur Maxtec)

| # | Durée | Bloc | Matériel |
|---|------|------|----------|
| 0 | 10 min | **M1 — Réalité 2025** (intro motivante) : comment les admins travaillent vraiment (Google + adapter + valider, pas mémoriser). | `cours-powershell-ad-moderne/modules-modernes/M1-realite-2025.md` |
| 1 | 1 h | **Chap. 9.0 + 9.1 — Fondamentaux**<br>Module AD, verbes de base (Get/New/Set/Remove/Add/Move), variables, pipeline, boucles. | `Chapitre 9.0` + `Chapitre 9.1` |
| 2 | 1 h 30 | **Pratique guidée**<br>Refaire en PowerShell ce qu'ils ont fait à la GUI : créer un utilisateur, le bouger entre OUs, l'ajouter à un groupe, le désactiver. Sur Maxtec. | `CHEATSHEET.md` §2-§3 |
| 🍴 | 1 h | **Pause déjeuner** | |
| 3 | 1 h | **Chap. 9.2 — Requêtes**<br>`-Filter`, `-LDAPFilter`. Cas concrets : utilisateurs inactifs depuis 90 j, mots de passe non changés, hors-groupes attendus. | `Chapitre 9.2` |
| 4 | 30 min | **M5 — `-WhatIf` religieusement**<br>Cultiver le réflexe sécurité avant la création/suppression en masse. | `cours-powershell-ad-moderne/modules-modernes/M5-whatif-religieux.md` |
| 5 | 1 h 30 | **Chap. 9.3 — Création / modification + CSV**<br>`Import-Csv` + `foreach` + `New-ADUser`. Exercice : onboarding de 10 utilisateurs depuis un CSV fourni. | `Chapitre 9.3` |
| 6 | 1 h | **M2 — 10 commandes de survie**<br>Carte de poche : les 10 commandes qui ferment 90 % des tickets. Clôture du cours. | `cours-powershell-ad-moderne/modules-modernes/M2-survie-tickets.md` |

---

## Livrables à fournir aux étudiants

- `docs/CHEATSHEET.md` imprimé (1 page A4 recto-verso si possible).
- Un fichier CSV exemple pour l'exercice onboarding du J2.
- Lien vers les chapitres 9.0–9.3 et les modules M1, M2, M5.
