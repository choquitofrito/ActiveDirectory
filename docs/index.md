# Cours Active Directory

Cours de 35 h (5 jours) du module *Introduction aux fondements réseau* — ISIB.

Vous allez monter, administrer, automatiser et sécuriser le domaine d'une entreprise fictive, **Maxtec** (`maxtec.be`) : un contrôleur de domaine, un ou deux postes clients, 13 utilisateurs répartis dans 4 services.

**Prérequis** : être à l'aise avec Windows, notions de base en réseau (adresse IP, masque) et en ligne de commande (Linux ou autre).

!!! info "Valeurs du lab"
    Noms, adresses IP, groupes, utilisateurs, partages : tout est sur la page **[Référence du lab Maxtec](Labo%20et%20Exercices/Labo/Reference_Lab_Maxtec.md)**. En cas de contradiction avec un autre document, c'est elle qui fait foi.

---

## Les 5 jours

| Jour | Thème | Chapitres | Pratique |
|------|-------|-----------|----------|
| 1 | Du réseau au domaine | [Ch1](Chapitre%201.Introduction%20et%20installation%20de%20Windows%20Server.md), [Ch2](Chapitre%202.Installation-Windows-Server-2022-VirtualBox.md), [Ch3](Chapitre%203.DNS.md), [Ch4](Chapitre%204.Active%20Directory%20Domain%20Services%20%28AD%20DS%29.md), [Ch5](Chapitre%205.DNS-Pratique-avec-AD.md) | [Guide d'installation AD DS](Labo%20Annexe%201-Guide%20de%20base%20installation%20AD-DS.md), labs DNS |
| 2 | La structure du lab, le réseau au service de l'AD, les identités | [Ch6](Chapitre%206.Unites_Organisation.md), [Ch7](Chapitre%207.Gestion_des_Utilisateurs.md) | [Installation du lab](Labo%20et%20Exercices/Labo/Labo_structure.md), [Anatomie d'une ouverture de session](Labo%20et%20Exercices/Exercices:%20Anatomie_Logon_Reseau.md), [Gestion des utilisateurs](Labo%20et%20Exercices/Exercices:%20Gestion_des_Utilisateurs.md) |
| 3 | Permissions et GPO | [Ch8](Chapitre%208.Group%20Policy%20Objects.md) | [AGDLP](Labo%20et%20Exercices/Exercices:%20AGDLP_Partage_Fichiers.md), [GPO-1](Labo%20et%20Exercices/Exercices:%20GPO-1.md), [GPO-2](Labo%20et%20Exercices/Exercices:%20GPO-2.md) |
| 4 | PowerShell et observation | [Ch9.0](Chapitre%209.0.Powershell%20AD%20-%20Introduction.md) → [Ch9.3](Chapitre%209.3.Powershell%20AD%20-%20Creation_et_Modification.md), [Ch10](Chapitre%2010.Monitoring.md) | Missions des chapitres 9, lab d'audit du Ch10 |
| 5 | Sécurité et projet | [Ch11](Chapitre%2011.Securite_AD.md) | [Projet final](Labo%20et%20Exercices/Projet_Final.md) |

Les jours 2 à 4 se terminent par un **ticket de dépannage** ([Dépannage](Labo%20et%20Exercices/Exercices:%20Depannage.md)) : une panne réelle sur le lab, seulement le symptôme au départ.

---

## Chapitres

| Chapitre | Contenu |
|----------|---------|
| [Ch1 - Introduction et Windows Server](Chapitre%201.Introduction%20et%20installation%20de%20Windows%20Server.md) | Pourquoi centraliser, rôle de Windows Server (installation Hyper-V pour la maison en option) |
| [Ch2 - Installation des VMs (VirtualBox)](Chapitre%202.Installation-Windows-Server-2022-VirtualBox.md) | Installation du cours : serveur et poste client Windows 10 sous VirtualBox |
| [Ch3 - DNS pour AD](Chapitre%203.DNS.md) | Zones, enregistrements, SRV, redirecteurs |
| [Ch4 - AD DS](Chapitre%204.Active%20Directory%20Domain%20Services%20%28AD%20DS%29.md) | Forêt, domaine, promotion du DC, partitions, catalogue global, FSMO |
| [Ch5 - DNS pratique avec AD](Chapitre%205.DNS-Pratique-avec-AD.md) | Labs DNS et dépannage |
| [Ch6 - Unités d'organisation](Chapitre%206.Unites_Organisation.md) | Conception des OUs, délégation |
| [Ch7 - Utilisateurs, groupes, partages](Chapitre%207.Gestion_des_Utilisateurs.md) | Comptes, portées de groupes, partage vs NTFS |
| [Ch8 - GPO](Chapitre%208.Group%20Policy%20Objects.md) | LSDO, héritage, filtrage, préférences, diagnostic |
| [Ch9.0 - PowerShell : introduction](Chapitre%209.0.Powershell%20AD%20-%20Introduction.md) | Découvrir les cmdlets, objets vs texte |
| [Ch9.1 - PowerShell : concepts](Chapitre%209.1.Powershell%20AD%20-%20Concepts%20base.md) | Variables, collections, boucles, conditions |
| [Ch9.2 - PowerShell : requêtes](Chapitre%209.2.Powershell%20AD%20-%20Requetes_et_Informations.md) | Filtres, rapports, exports |
| [Ch9.3 - PowerShell : création et modification](Chapitre%209.3.Powershell%20AD%20-%20Creation_et_Modification.md) | `-WhatIf`, création en masse depuis CSV |
| [Ch10 - Monitoring](Chapitre%2010.Monitoring.md) | Journaux, Event IDs, audit |
| [Ch11 - Sécurité AD](Chapitre%2011.Securite_AD.md) | Tiers, comptes privilégiés, Kerberos/NTLM, FGPP, LAPS, corbeille AD |
| [Cheatsheet](CHEATSHEET.md) | PowerShell AD + commandes de diagnostic réseau |

---

## Lab et exercices

| Ressource | Rôle |
|-----------|------|
| [Référence du lab](Labo%20et%20Exercices/Labo/Reference_Lab_Maxtec.md) | Valeurs officielles (noms, IP, groupes, partages) |
| [Installation du lab](Labo%20et%20Exercices/Labo/Labo_structure.md) | Préparer les VMs, lancer le script, placer les postes |
| [Script de création](Labo%20et%20Exercices/Labo/PowerShell-scriptsStructure/creation_structure.md) / [de suppression](Labo%20et%20Exercices/Labo/PowerShell-scriptsStructure/suppression_structure.md) | Créer / remettre à zéro la structure Maxtec |
| [Questions de base](Labo%20et%20Exercices/Exercices:%20Questions%20Base.md) | Auto-évaluation des concepts |
| [Anatomie d'une ouverture de session](Labo%20et%20Exercices/Exercices:%20Anatomie_Logon_Reseau.md) | DHCP, DNS, ports, Kerberos |
| [Gestion des utilisateurs](Labo%20et%20Exercices/Exercices:%20Gestion_des_Utilisateurs.md) | Cycle de vie des comptes, délégation |
| [OUs - départements complémentaires](Labo%20et%20Exercices/Exercices:%20OUs_Departements_Complementaires.md) | Entraînement en autonomie |
| [AGDLP - partage de fichiers](Labo%20et%20Exercices/Exercices:%20AGDLP_Partage_Fichiers.md) | Permissions selon la méthode AGDLP |
| [GPO série 1](Labo%20et%20Exercices/Exercices:%20GPO-1.md) · [série 2](Labo%20et%20Exercices/Exercices:%20GPO-2.md) · [série 3](Labo%20et%20Exercices/Exercices:%20GPO-3.md) | Stratégies de groupe (la série 3 est une extension) |
| [Dépannage](Labo%20et%20Exercices/Exercices:%20Depannage.md) | Tickets : GPO, compte, permissions, DNS |
| [Projet final](Labo%20et%20Exercices/Projet_Final.md) | Évaluation : le département Logistique, de A à Z |

---

## Pour aller plus loin

- [Théorie DNS avancée](Th%C3%A9orie%20DNS-%20DNS%20Concepts%20Avances%20%28Reference%29.md) (référence)
- Compléments PowerShell M1-M7 (onglet PowerShell AD) — en particulier [M5 : `-WhatIf` avant tout](PowershellCourse/cours-powershell-ad-moderne/modules-modernes/M5-whatif-religieux.md)
- Labos Extra CreativeHub, MediCare, MonitoringLab (hors programme, autres scénarios d'entreprise)
