# Plan des 2 derniers jours — Cours AD ISIB

Document de planification pour les deux dernières journées du cours (7 h chacune).
Lab utilisé : **Maxtec** (`DC=maxtec,DC=be`). Les étudiants maîtrisent déjà : Users, Computers, groupes GG/DL, premières GPOs (à mi-parcours de `Exercices: GPO-1.md`).

---

## État des matières au début du J1

| Domaine | État | Reste à faire |
|--------|------|----------------|
| GPO-1 | ~50 % (fin section 2.3 — Chrome) | 2.4 (mappage IT), 3 (Préférences + cross-ref Item-level), 4 (Exceptions) |
| GPO-2 | Non commencé | Ex. 5 (logon restrictions), Ex. 6 (logon script), Ex. 7 (délégation de GPOs) |
| GPO-3 | Non commencé | Section 1 (redirection dossiers), section 2 (Item-level targeting — déjà rédigé), section 3 (imprimantes) |
| AGDLP | À confirmer avec le groupe | `Exercices: AGDLP_Partage_Fichiers.md` (1 h) |
| Délégation OU | Non vue | Chap. 7 §8 (théorie) + `Exercices: Gestion_des_Utilisateurs.md` Ex. 12 |
| Délégation GPO | Non vue | Nouvel `Exercices: GPO-2.md` Ex. 7 (créé pour ce plan) |
| PowerShell AD | Non vu | Chap. 9.0–9.3 + sélection de modules `cours-powershell-ad-moderne` |

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
| 6 | 30 min | **Teaser PowerShell**<br>Démo : 5 cmdlets `Get-*` qui font ce qu'ils ont fait à la GUI ces deux jours. Planter la graine. | Démo libre — voir CHEATSHEET §2-§4 |

**Si AGDLP n'a pas été vu** : insérer 1 h entre blocs 4 et 5 avec `Exercices: AGDLP_Partage_Fichiers.md`. Pousser le teaser PowerShell au début du J2.

---

## Jour 2 — PowerShell AD (sur Maxtec)

| # | Durée | Bloc | Matériel |
|---|------|------|----------|
| 0 | 10 min | **M1 — Réalité 2025** (intro motivante) : comment les admins travaillent vraiment (Google + adapter + valider, pas mémoriser). | `cours-powershell-ad-moderne/modules-modernes/M1-realite-2025.md` |
| 1 | 1 h | **Chap. 9.0 + 9.1 — Fondamentaux**<br>Module AD, verbes de base (Get/New/Set/Remove/Add/Move), variables, pipeline, boucles. | `Chapitre 9.0` + `Chapitre 9.1` |
| 2 | 1 h 30 | **Pratique guidée**<br>Refaire en PowerShell ce qu'ils ont fait à la GUI : créer un utilisateur, le bouger entre OUs, l'ajouter à un groupe, le désactiver. Sur Maxtec. | Cheat sheet §2-§3 |
| 🍴 | 1 h | **Pause déjeuner** | |
| 3 | 1 h | **Chap. 9.2 — Requêtes**<br>`-Filter`, `-LDAPFilter`. Cas concrets : utilisateurs inactifs depuis 90 j, mots de passe non changés, hors-groupes attendus. | `Chapitre 9.2` |
| 4 | 30 min | **M5 — `-WhatIf` religieusement**<br>Cultiver le réflexe sécurité avant la création/suppression en masse. | `cours-powershell-ad-moderne/modules-modernes/M5-whatif-religieux.md` |
| 5 | 1 h 30 | **Chap. 9.3 — Création / modification + CSV**<br>`Import-Csv` + `foreach` + `New-ADUser`. Exercice : onboarding de 10 utilisateurs depuis un CSV fourni. | `Chapitre 9.3` |
| 6 | 1 h | **M2 — 10 commandes de survie**<br>Carte de poche : les 10 commandes qui ferment 90 % des tickets. Clôture du cours. | `cours-powershell-ad-moderne/modules-modernes/M2-survie-tickets.md` |

---

## Décisions & conseils stratégiques

### Sur les labs Extra

- **Ne pas ouvrir CreativeHub** dans ces 2 jours : redondant avec Maxtec (même niveau de difficulté, mêmes concepts). Changer de lab pour répéter les mêmes notions, c'est 20–30 min de setup pour aucune valeur ajoutée.
- **MediCare** : utile si l'on veut un contexte régulé (HIPAA/RGPD) pour la délégation et l'audit. À garder pour une 2e session ou un follow-up.
- **MonitoringLab** : avancé et nécessitait des corrections (faites séparément). Plutôt à proposer en autonomie ou pour une formation security/SOC ultérieure.

### Sur l'introduction de PowerShell au J1

- **Oui, mais en teaser uniquement** (30 min max). Un cours PowerShell formel coupé en deux fragmente la compréhension. Le bloc 6 du J1 sert à dire "demain, on automatise tout ce qu'on vient de faire" — pas à apprendre.

### Sur la délégation de GPO

- Pas d'exercice formel existant dans le repo → un nouvel ex. 7 a été ajouté à `Exercices: GPO-2.md`. Il couvre les trois mécanismes souvent confondus : Security Filtering, onglet Delegation, et délégation des liens sur l'OU.

### Risques à surveiller

- **Glissement de planning** : si GPO-1 prend plus de 1 h 30, sacrifier les imprimantes de GPO-3 (peu de valeur unique). Ne pas sacrifier la délégation OU+GPO — c'est la matière la moins couverte.
- **PowerShell trop théorique le J2** : alterner systématiquement démo / mains au clavier. Les Chap. 9 sont denses ; les modules `cours-powershell-ad-moderne` apportent la respiration culturelle.
- **CSV onboarding** : préparer le CSV avant la séance et le distribuer.

### Livrables à fournir aux étudiants

- `docs/CHEATSHEET.md` imprimé (1 page A4 recto-verso si possible).
- Un fichier CSV exemple pour l'exercice onboarding.
- Lien vers les chapitres 9.0–9.3 et les modules M1, M2, M5.
