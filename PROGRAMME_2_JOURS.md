# Programme des 2 derniers jours — Cours AD ISIB

Lab : **Maxtec** (`DC=maxtec,DC=be`)
Format : 2 journées de 7 h
Contexte (analyses, décisions, alternatives) : voir `PLAN_2_JOURS.md`.

---

## Jour 1 — Consolider GPO + Délégation + Teaser PowerShell

| # | Durée | Bloc | Matériel |
|---|------|------|----------|
| 1 | 1 h 30 | **Finir GPO-1**<br>2.4 mappage lecteur IT → 3 Préférences (LinkBureau) → 4 Exceptions | `Exercices: GPO-1.md` §2.4 à §4 |
| 2 | 1 h 30 | **GPO-2 — Ex. 5 & 6**<br>Restriction de logon par machine, script de nettoyage Téléchargements au logon | `Exercices: GPO-2.md` Ex. 5–6 |
| 🍴 | 1 h | **Pause déjeuner** | |
| 3 | 1 h 15 | **GPO-3 sélectif**<br>Redirection de dossiers (haute valeur pratique) + rappel Item-level targeting (déjà rédigé). Imprimantes : démo rapide 15 min ou skip. | `Exercices: GPO-3.md` §1 + §2 |
| 4 | 1 h | **Délégation OU**<br>Théorie courte (Chap. 7 §8) + ex. pratique : déléguer le reset de mot de passe sur OU `RH` à un groupe. | `Chapitre 7` §8 + `Exercices: Gestion_des_Utilisateurs.md` Ex. 12 |
| 5 | 45 min | **Délégation de GPOs** (nouvel exercice)<br>Security Filtering + onglet Delegation + délégation du lien sur OU. Test avec Valentin. | `Exercices: GPO-2.md` Ex. 7 |
| 6 | 30 min | **Teaser PowerShell**<br>Démo : 5 cmdlets `Get-*` qui font ce qu'ils ont fait à la GUI ces deux jours. Planter la graine. | Démo libre — voir `CHEATSHEET.md` §2-§4 |

**Si AGDLP n'a pas été vu** : insérer 1 h entre blocs 4 et 5 avec `Exercices: AGDLP_Partage_Fichiers.md`. Pousser le teaser PowerShell au début du J2.

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
