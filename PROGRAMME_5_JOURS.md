# Programme — Active Directory (35 h, 5 × 7 h)

ISIB — module *Introduction aux fondements réseau* — édition 2026-2027
Public : 12 adultes, à l'aise avec un ordinateur, bases Linux, pour certains programmation ou réseau.
Lab unique : **Maxtec** (`maxtec.be`). Valeurs de référence : `docs/Labo et Exercices/Labo/Reference_Lab_Maxtec.md`.

Les horaires ne comptent pas les pauses (déjeuner + 2 × 15 min à ajouter).

---

## Fil conducteur

| Jour | Thème | Question à laquelle la journée répond |
|------|-------|----------------------------------------|
| 1 | Du réseau au domaine | Qu'est-ce qu'un domaine et comment un serveur en devient le cœur ? |
| 2 | Le réseau au service de l'AD, puis les identités | Que se passe-t-il sur le réseau quand quelqu'un ouvre une session ? Comment organiser 13 personnes et 4 services ? |
| 3 | Permissions et GPO | Qui a accès à quoi, et comment on configure 100 postes sans y toucher ? |
| 4 | PowerShell et observation | Comment faire en 1 ligne ce qu'on a fait en 20 clics — et comment savoir ce qui s'est passé ? |
| 5 | Sécurité et projet | Comment protéger un AD, et savez-vous tout remonter seuls ? |

Les jours 2, 3 et 4 se terminent par un **ticket de dépannage** (`Exercices: Depannage.md`) : chaque étudiant installe la panne sur son propre lab avec `docs/Labo et Exercices/scripts/Depannage.ps1` (téléchargeable depuis la page Dépannage), **sans lire le script**, après un instantané des VMs. Ils n'ont que le symptôme. Règle annoncée dans le syllabus (`index.md`) : on joue le jeu, personne ne contrôle. Retour arrière : instantané ou `-Restaurer`.

---

## Jour 1 — Du réseau au domaine

| Durée | Bloc | Matériel |
|------:|------|----------|
| 0:30 | Pourquoi un annuaire centralisé ; où on trouve AD en 2026 (PME, écoles, hôpitaux, administrations belges ; NIS2 en une phrase) | Ch1 §1-2 |
| 1:30 | Mise en place des VMs : serveur (1 carte réseau interne, IP fixe, nom `dns1`) et client `ws-IT-01` | Ch2 (VirtualBox) ou Annexe 1 partie A (version courte) |
| 1:15 | Promotion du DC + vérifications (SRV, SYSVOL/NETLOGON, services) | Ch4 §6, Annexe 1 A3-A4 |
| 0:45 | DNS pour AD : zones, enregistrements A/PTR/SRV, pourquoi le DC est son propre DNS (le rôle DNS existe maintenant) | Ch3 |
| 0:45 | Jonction de `ws-IT-01` au domaine | Annexe 1 partie B, Ch4 §10 |
| 1:00 | Concepts : forêt, domaine, partitions, catalogue global, FSMO, heure | Ch4 §7-9 (condensé) |
| 1:15 | DNS pratique : labs 1 et 2 | Ch5 |

**Objectifs vérifiables en fin de journée** : `nltest /dsgetdc:maxtec.be` répond depuis le client ; `nslookup -type=SRV _ldap._tcp.dc._msdcs.maxtec.be` renvoie `dns1` ; l'étudiant sait expliquer la différence domaine DNS / domaine AD.

---

## Jour 2 — La structure du lab, le réseau au service de l'AD, les identités

| Durée | Bloc | Matériel |
|------:|------|----------|
| 0:45 | DNS pratique : labs 3 et 4 (zone inverse, dépannage) | Ch5 |
| 1:00 | OUs : conception, création ; script `creation_structure` ; **placer `ws-IT-01` dans son OU** | Ch6 (noyau), `Labo_structure.md`, `Reference_Lab_Maxtec.md` |
| 2:00 | **Anatomie d'une ouverture de session** : DHCP sur le DC, SRV, ports 53/88/389/445, tickets Kerberos (`klist`), groupes dans le jeton, heure (nécessite les utilisateurs du lab : après le bloc précédent) | `Exercices: Anatomie_Logon_Reseau.md` |
| 1:30 | Utilisateurs et groupes : cycle de vie d'un compte, comptes admin séparés, portées de groupes | Ch7 §1-4, `Exercices: Gestion_des_Utilisateurs` Ex. 1-5 |
| 1:00 | Partage vs NTFS (dossier `IT-docs`) | Ch7 §5 |
| 0:45 | Ticket **D4** — "Le poste ne trouve plus le domaine" | `Exercices: Depannage.md` |

---

## Jour 3 — Permissions et GPO

| Durée | Bloc | Matériel |
|------:|------|----------|
| 1:45 | **AGDLP** : partage `Ventes-Documents`, conception, test, extension `Factures` | `Exercices: AGDLP_Partage_Fichiers.md` |
| 1:00 | Délégation sur une OU (reset de mot de passe pour les responsables) — test depuis le client avec RSAT (**RSAT préinstallé**, voir préparation) | Ch6 §délégation, Gestion Ex. 12 |
| 1:00 | GPO : principe, LSDO, héritage, `gpupdate` / `gpresult` — démo | Ch8 §1-3 |
| 1:45 | GPO pratiques, sélection : 1.1 (panneau de configuration), 2.1 (message), 2.2 (verrouillage), 3.1 (raccourci), 4.1 (lecteur réseau) | `Exercices: GPO-1.md` |
| 1:00 | Filtrage de sécurité (MS16-072), délégation de GPO | `Exercices: GPO-2.md` Ex. 7 |
| 0:30 | Ticket **D1** — "Le lecteur réseau a disparu pour l'IT" (variante courte : `-Ticket D1`) | `Exercices: Depannage.md` |

---

## Jour 4 — PowerShell et observation

| Durée | Bloc | Matériel |
|------:|------|----------|
| 0:45 | Découvrir : `Get-Command`, `Get-Help`, `Get-Member`, objets vs texte (tableau bash → PowerShell) | Ch9.0 |
| 1:00 | Variables, collections, boucles, conditions sur Maxtec | Ch9.1 (missions choisies) |
| 1:30 | Requêtes : `-Filter`, dates, groupes, exports CSV/HTML, `Search-ADAccount` | Ch9.2 |
| 1:45 | Créer et modifier : `-WhatIf` d'abord, onboarding depuis CSV | Ch9.3 (+ M5 en lecture) |
| 1:15 | **De l'action à l'événement** : activer l'audit, provoquer, retrouver avec l'Observateur et `Get-WinEvent` | Ch10 |
| 0:45 | Ticket **D2** — "Ines ne peut plus se connecter" (utilise `Search-ADAccount` et l'événement 4740, vus ce jour-là ; la PSO est découverte dans le ticket et approfondie au Ch11) | `Exercices: Depannage.md` |

---

## Jour 5 — Sécurité et projet final

| Durée | Bloc | Matériel |
|------:|------|----------|
| 2:00 | Sécurité AD : tiers, groupes privilégiés, Kerberos/NTLM ; pratiques 1 (audit), 2 (FGPP), 4 (LAPS), 5 (corbeille) ; pratiques 3 (Protected Users) et 6 (PingCastle) en démo formateur | Ch11 |
| 4:15 | **Projet final** en binômes : département Logistique (structure, AGDLP, GPO, délégation, sécurité, incident surprise) | `Projet_Final.md` |
| 0:45 | Démos (5 min par binôme) + vérification automatique + débriefing — chaque binôme lance `Depannage.ps1 -Ticket Incident -Restaurer` **avant** les démos | `Projet_Final.md` — grille /20 |

Le projet est conçu pour ~5 h : sur 4 h 15, la partie 5 (sécurité et reporting) peut être réduite au seul rapport CSV. Si le jour 4 a pris de l'avance, démarrer la partie 1 du projet en fin de jour 4.

---

## Réserve (le programme est plein : c'est la marge)

À utiliser pour les groupes rapides, ou pour remplacer un bloc qui ne s'y prête pas ce jour-là :

| Durée | Contenu | Matériel |
|------:|---------|----------|
| 0:45 | Ticket **D3** — "Accès refusé au dossier Ventes" (idéal juste après l'AGDLP) | `Exercices: Depannage.md` |
| 1:00 | GPO-1 1.2 (invite de commandes) et 2.3 (déploiement de Chrome) | `Exercices: GPO-1.md` |
| 0:45 | GPO-2 Ex. 5-6 (restriction de logon, script de logon) | `Exercices: GPO-2.md` |
| 1:30 | GPO-3 (redirection de dossiers, ciblage) | `Exercices: GPO-3.md` |
| 0:30 | Ch11 pratiques 3 et 6 faites par les étudiants | Ch11 |

---

## Ce qui est hors programme (ressources en autonomie)

| Contenu | Statut |
|---------|--------|
| Ch1 §3.3 (installation avec Hyper-V) | Uniquement pour refaire le lab à la maison ; en cours, tout se fait sous VirtualBox |
| Théorie DNS avancée | Référence |
| Gestion des utilisateurs Ex. 6-11, 13-14 (l'Ex. 12 est au programme du jour 3), `Exercices: OUs_Departements_Complementaires.md` | Entraînement en autonomie |
| Cours PowerShell moderne M1-M7 | Lecture ; M5 (`-WhatIf`) conseillé |
| Labos Extra (CreativeHub, MediCare, MonitoringLab) | Non utilisés (redondants avec Maxtec) |
| Second DC, réplication | Démo optionnelle si le groupe est en avance |

---

## Évaluation

- **Projet final** (binômes) : grille /20 dans `Projet_Final.md`, vérifiée par `Verify-ProjetFinal.ps1` + démo.
- **Tickets de dépannage** : formatif, non noté (ou bonus : qualité du diagnostic écrit).
- **Questions de base** (`Exercices: Questions Base.md`) : auto-évaluation en fin de J1 et J2.

---

## Préparation formateur

- [ ] VMs : ISO **Windows Server 2022** et **Windows 10 Pro** ; idéalement une VM serveur et une VM client préparées (sysprep ou OVA) pour gagner 1 h le jour 1.
- [ ] VirtualBox 7.x sur les postes.
- [ ] Vérifier que les scripts `creation_structure` / `suppression_structure` passent sur un lab vierge.
- [ ] Tester chaque ticket de `Depannage.ps1` (panne, puis `-Restaurer`) sur un lab complet, avec `docs/instructeur/Verify-Depannage.ps1` pour contrôler les corrections.
- [ ] Télécharger PingCastle (édition gratuite) pour la démo du jour 5.
- [ ] **RSAT sur le client** : le poste du lab n'a pas Internet. Installez « RSAT : Services AD DS » et « RSAT : Gestion des stratégies de groupe » dans l'image cliente avant le cours (ou, le jour 3, carte NAT temporaire sur le client → `Add-WindowsCapability` → retirer la carte → `ipconfig /flushdns`).
- [ ] DC 2022 et client Windows 10 : appliquer au moins la mise à jour cumulative d'avril 2023 avant le cours (sinon pas de Windows LAPS intégré, Ch11).
- [ ] Imprimer `CHEATSHEET.md` (dont la section diagnostic réseau).
- [ ] Préparer le CSV du jour 4 (Ch9.3) et celui du projet (dans `Projet_Final.md`).
