# Plan des 2 derniers jours — Cours AD ISIB

Document de **décisions, contexte et conseils stratégiques** pour les deux dernières journées du cours (7 h chacune).

👉 **Programme horaire détaillé** : voir `PROGRAMME_2_JOURS.md`.

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
