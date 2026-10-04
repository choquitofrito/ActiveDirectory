# Notes formateur — Dépannage et incident du projet final

Dossier **non publié** sur le site (exclu dans `mkdocs.yml`).

## Principe

Chaque étudiant installe lui-même la panne sur son propre lab avec `Labo et Exercices/scripts/Depannage.ps1`, téléchargeable depuis la page Dépannage. On leur demande de ne pas lire le script (règle annoncée dans `index.md`). Le formateur ne passe sur aucun poste.

- Tickets D1 à D4 : `Labo et Exercices/Exercices: Depannage.md`, section *Lancer un ticket*
- Incident du projet final : `Labo et Exercices/Projet_Final.md`, étape 6 (`-Ticket Incident`)
- Retour arrière : instantané VirtualBox, ou la même commande avec `-Restaurer`

| Ticket | Commande | Pannes installées |
|--------|----------|-------------------|
| D1 | `-Ticket D1` (`-Complet`) | Lien de la GPO du lecteur désactivé ; filtrage `GG-EU-IT-Admin` = Appliquer et `Utilisateurs authentifiés` supprimé. `-Complet` : `ws-IT-01` déplacé dans `CN=Computers`. |
| D2 | `-Ticket D2` | `ines` : PSO `PSO-Depannage-ines` (seuil 3) + verrouillage, `logonHours` 01:00-05:00 UTC, `userWorkstations` = `ws-IT-99`. |
| D3 | `-Ticket D3` (`-Preparer`) | `DL-Ventes-Documents-Modification` recréé en Global (SID orphelin), Deny sur `Contrats` pour `GG-EU-Ventes-Users`, `GG-EU-Compta-Users` retiré du DL de lecture. |
| D4 | `-Ticket D4` sur `dns1` puis sur `ws-IT-01` | `intranet` → `192.168.0.250`, PTR du poste supprimé ; sur le poste, DNS = `8.8.8.8`. |
| Incident | `-Ticket Incident` | Filtrage cassé sur `GPO-Logistique-Utilisateurs` ; `louis` verrouillé (PSO dédiée) et limité à `ws-LOG-99`. |

Pendant l'installation, le script n'affiche que `Panne installée.` et l'étape suivante pour l'étudiant. Avec `-WhatIf`, il montre ce qu'il ferait sans rien modifier, utile pour vos essais.

## Fonctionnement

- Script unique, autonome, PowerShell 5.1, **UTF-8 avec BOM** (sans BOM, les accents sont mal lus et le script peut ne plus se charger).
- Garde-fous : administrateur requis ; arrêt si le domaine n'est pas `maxtec.be` ; refus de toucher la Default Domain Policy, la Default Domain Controllers Policy ou un compte privilégié (RID 500, `adminCount = 1`) ; aucun enregistrement DNS du DC modifié ; aucun `Set-GPRegistryValue`.
- Idempotent : relancer une panne ne casse rien de plus et n'écrase pas l'état d'origine.
- L'état d'origine est enregistré dans `C:\ProgramData\Maxtec-Depannage\*.json` (sur `dns1`, et sur `ws-IT-01` pour D4). `-Restaurer` ne répare que ce que la panne a réellement modifié, puis supprime l'état. Sans état, il ramène à l'état standard du lab.
- D4 côté poste : le script détecte qu'il n'est pas sur un DC et ne touche que la carte en `192.168.0.x` (une carte NAT éventuelle n'est pas modifiée). `-Restaurer` remet les DNS saisis à la main, ou rend la main au DHCP.

## Points à connaître pour le débriefing

**D1** : correction attendue du filtrage : `Utilisateurs authentifiés` (ou `Ordinateurs du domaine`) en **Lecture**, `GG-EU-IT-Admin` en **Appliquer**. La variante complète suppose que la GPO de verrouillage de GPO-1 §2.2 est active et que `ws-IT-01` n'est pas dans le groupe d'exception.

**D2** : les échecs sont générés depuis le DC, donc `Nom de l'ordinateur appelant` = `DNS1` dans l'événement 4740. Faites-le interpréter ("en production, ce serait le téléphone ou le lecteur réseau qui garde l'ancien mot de passe"). Le script active l'audit **Gestion des comptes d'utilisateur** ; si une GPO d'audit le désactive, pas de 4740 (`auditpol /get /category:*`). Si le verrouillage automatique échoue, le script demande à l'étudiant 4 essais avec un mauvais mot de passe. Une PSO appliquée à l'utilisateur prime sur une PSO de groupe, quelle que soit la précédence : même si le Ch10 a laissé le seuil du domaine à 5, c'est la PSO (seuil 3) qui s'applique.

**D3** : le piège "jeton Kerberos" ne fonctionne que si `cindy` a ouvert sa session **avant** la correction ; le script demande de reproduire chaque plainte avant de corriger. Après l'ajout de `GG-EU-Compta-Users` dans le DL, elle reste refusée jusqu'à la fermeture de session (`klist purge` suffit souvent, pas toujours si une session SMB vers `dns1` est ouverte).

**D4** : 8.8.8.8 est injoignable sur le réseau interne ; la session s'ouvre grâce aux identifiants en cache, d'où le symptôme trompeur. Si le poste a encore une carte NAT active, son DNS 10.0.2.x brouille le diagnostic (`Verify-Depannage -Client` le signale).

**Incident** : correction attendue du filtrage = **`Utilisateurs authentifiés` en Appliquer** (le filtrage d'origine). "Lecture pour Utilisateurs authentifiés + Appliquer pour `GG-EU-Logistique-Users`" ne suffit pas : `louis` n'est membre que de `GG-EU-Logistique-Admin` et reste sans lecteur, or le ticket dit "plus personne dans l'équipe". Le sujet demande aux binômes de lancer `-Restaurer` après le post-mortem : sinon `PSO-Depannage-louis` gagne sur `PSO-Logistique-Admin` et fausse la preuve de l'étape 5 pendant la démo.

## Vérifier une correction

`Verify-Depannage.ps1` (ce dossier) contrôle en lecture seule qu'un ticket est résolu. Il affiche des conseils qui révèlent les causes : réservé au formateur (vos essais, ou contrôle sur le poste d'un étudiant à sa demande).

```powershell
.\Verify-Depannage.ps1                 # sur dns1, tous les tickets
.\Verify-Depannage.ps1 -Scenario D2
.\Verify-Depannage.ps1 -Client         # sur ws-IT-01, partie poste de D4
```
