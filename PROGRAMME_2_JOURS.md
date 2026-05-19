# Programme des 2 derniers jours — Cours AD ISIB

Lab : **Maxtec** (`DC=maxtec,DC=be`)
Format : 2 journées de 7 h
Contexte (analyses, décisions, alternatives) : voir `PLAN_2_JOURS.md`.

---

## Jour 1 — GPOs pro + Monitoring + Délégation + Teaser PowerShell

Principe directeur : alterner blocs GPO et changements de tempo pour éviter 3 h d'affilée de GPO. AGDLP déjà vu, donc retiré.

| # | Durée | Bloc | Matériel |
|---|------|------|----------|
| 1 | 1 h 30 | **Finir GPO-1**<br>2.4 mappage lecteur Z: pour IT → 3 Préférences (LinkBureau) → 4 Exceptions | `Exercices: GPO-1.md` §2.4 à §4 |
| 2 | 1 h 30 | **GPO-3 §1 — Redirection de dossiers** (la GPO "phare" pro)<br>Création du partage `C:\Shares-Compta` (Share + NTFS), GPO `GPO-Redirection-Dossiers-Comptabilite` liée à `OU=EU\Comptabilité\Users`, redirection Documents vers `\\dns1\Shares\Comptabilite\UserData`, test multi-postes avec Charles. | `Exercices: GPO-3.md` §1 |
| 🍴 | 1 h | **Pause déjeuner** | |
| 3 | 1 h | **Monitoring — vérifier l'effet des GPOs du matin**<br>Pivot pédagogique : on passe de "configurer" à "observer". `gpresult /r` + `gpresult /h rapport.html` (RSOP HTML), `rsop.msc`, Custom View dans Event Viewer (Event IDs 4624/4625/5126/5136/5137), démo `Get-WinEvent -FilterHashtable`. | `Chapitre 10` §🛠️ Outils + §📋 Event IDs |
| 4 | 1 h | **GPO-2 — Ex. 5 + Ex. 6**<br>Restriction de logon par machine (IT) + script PowerShell de nettoyage Téléchargements au logon. Rappel Item-level targeting (`GPO-3 §2`) si temps. | `Exercices: GPO-2.md` Ex. 5–6 + `GPO-3.md` §2 |
| 5 | 1 h | **Délégation OU + Délégation GPO**<br>Théorie courte (Chap. 7 §8) → Ex. 12 (déléguer reset password sur OU RH) → enchaîner avec Ex. 7 GPO-2 (Security Filtering + onglet Delegation + délégation des liens sur l'OU). Test avec Valentin via `runas`. | `Chapitre 7` §8 + `Exercices: Gestion_des_Utilisateurs.md` Ex. 12 + `Exercices: GPO-2.md` Ex. 7 |
| 6 | 30 min | **Teaser PowerShell**<br>Démo : 5 cmdlets `Get-*` qui font ce qu'ils ont fait à la GUI ces deux jours. Le `Get-WinEvent` du bloc 3 a déjà planté la graine. | Démo libre — voir `CHEATSHEET.md` §2-§4 |

**Total : 6 h 30 + 1 h pause = 7 h 30.** Si trop long, raccourcir le bloc 5 à 45 min (délégation GPO seule) ou le bloc 4 à 45 min (Ex. 5 seul, Ex. 6 en option).

**Garanties du découpage** :

- Max **1 h 30 consécutives** de GPO (jamais 3 h en bloc)
- **Monitoring** = vraie pause cognitive *active* qui consolide la matière du matin
- Les GPO "phares" pro y sont toutes (mappage Z:, redirection dossiers, restrictions, script logon, délégation)
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
