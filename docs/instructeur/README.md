# Scripts formateur — Dépannage et incident du projet final

Dossier **non publié** sur le site (exclu dans `mkdocs.yml`). Les étudiants ne doivent voir que les symptômes : ne partagez pas ces scripts avant la fin des tickets.

Documents étudiants correspondants :

- `Labo et Exercices/Exercices: Depannage.md` (tickets D1 à D4)
- `Labo et Exercices/Projet_Final.md` (étape 6, incident surprise)

---

## Contenu

| Fichier | Rôle |
|---------|------|
| `Commun.ps1` | Fonctions partagées (garde-fou domaine, fichiers d'état). Chargé par les autres scripts, ne pas lancer seul. |
| `Break-D1.ps1` / `Restore-D1.ps1` | GPO du lecteur IT-Admin : poste dans `CN=Computers`, lien désactivé, filtrage sans Lecture pour Utilisateurs authentifiés. |
| `Break-D2.ps1` / `Restore-D2.ps1` | Compte `ines` : verrouillage (via une PSO dédiée), `logonHours`, `userWorkstations`. |
| `Break-D3.ps1` / `Restore-D3.ps1` | AGDLP Ventes-Documents : DL recréé en Global (SID orphelin), Deny sur `Contrats` (dossier créé par le script s'il manque), Compta retirée du DL de lecture. |
| `Break-D4.ps1` / `Restore-D4.ps1` | DNS : `intranet` vers une adresse morte, PTR du poste supprimé. La partie client (DNS 8.8.8.8) est à taper sur le poste. |
| `Break-Incident.ps1` / `Restore-Incident.ps1` | Projet final : pannes type D1 + D2 sur l'OU Logistique (paramétrables, mémorisées pour le Restore). |
| `Verify-Depannage.ps1` | Contrôle en lecture seule que chaque ticket est résolu (`-Client` pour la partie poste de D4). |

## Règles communes

- À lancer **sur le DC `dns1`**, PowerShell 5.1 administrateur, depuis ce dossier (copiez-le par exemple dans `C:\Instructeur\`). Les scripts utilisent `$PSScriptRoot` : gardez-les ensemble.
- Si vous copiez ou éditez les scripts, **conservez l'encodage UTF-8 avec BOM** : sans BOM, PowerShell 5.1 lit les accents de travers et certains scripts ne se chargent plus.
- Garde-fou : arrêt immédiat si le domaine n'est pas `maxtec.be`.
- **Toujours un premier passage en `-WhatIf`** : il affiche ce qui serait cassé, sans rien modifier.
- Idempotents : relancer un `Break` ne casse rien de plus et n'écrase pas l'état d'origine ; relancer un `Restore` est sans effet si tout est déjà correct.
- L'état d'origine est enregistré dans `C:\Instructeur\Etat\*.json` (un fichier par scénario). `Restore` l'utilise puis le supprime. Avec un état, `Restore-D1` et `Restore-D2` ne réparent **que** les pannes que le `Break` a réellement injectées (un choix légitime de l'étudiant n'est pas écrasé). Sans fichier, `Restore` ramène à l'état standard du lab.
- Garde-fous supplémentaires : `Break-D1` refuse de toucher à la Default Domain Policy et à la Default Domain Controllers Policy ; `Break-D2` refuse un compte privilégié (RID 500 ou `adminCount = 1`).
- Rien ne touche au DC lui-même : pas de modification des enregistrements de `dns1`, des zones, ni de la Default Domain Policy. Aucun `Set-GPRegistryValue` : les pannes GPO passent par `Set-GPLink` et `Set-GPPermission`.
- Si la politique d'exécution bloque : `Set-ExecutionPolicy -Scope Process Bypass`.

---

## Quand injecter

| Ticket | Prérequis sur le lab de l'étudiant | Moment conseillé | Durée |
|--------|------------------------------------|------------------|-------|
| D4 — DNS | DC + `ws-IT-01` joint au domaine, zone inverse créée | Fin du jour 2 | 45 min |
| D1 — GPO | GPO-1 §4.1 (lecteur IT-Admin) faite ; pour la variante complète, §2.1/§2.2 aussi | Fin du jour 3, **variante courte** (`-Fautes Lien,Filtrage`) | 30 min |
| D2 — Compte | `creation_structure.ps1` exécuté | Fin du jour 4, après le Ch10 | 45 min |
| D3 — Permissions | Exercice AGDLP terminé (sinon `-Preparer`) | En réserve (idéal : juste après l'AGDLP, jour 3) | 45 min |

Injectez pendant une pause ou pendant que les étudiants travaillent sur autre chose : le ticket arrive ensuite "de l'extérieur".

---

## Mode d'emploi par scénario

### D1 — Le lecteur réseau a disparu pour l'IT

GPO-1 §4.1 nomme la GPO `GPO-Mappage-IT-Admin`, mais les étudiants renomment parfois. Vérifiez le nom réel chez chaque étudiant :

```powershell
Get-GPO -All | Select-Object DisplayName
.\Break-D1.ps1 -GpoName "<nom exact>" -WhatIf
.\Break-D1.ps1 -GpoName "<nom exact>"
```

Nom par défaut : `GPO-Mappage-IT-Admin`. Au programme (jour 3, 30 min), utilisez la **variante courte** : `-Fautes Lien,Filtrage` (le poste reste dans son OU, seul le lecteur disparaît). La variante complète (par défaut) déplace aussi le poste dans `CN=Computers` ; elle suppose que la GPO de verrouillage de GPO-1 §2.2 est active et que `ws-IT-01` n'est pas dans le groupe d'exception.

Après injection, faites exécuter `gpupdate /force` et une reconnexion d'`irene` sur `ws-IT-01` pour que le symptôme soit visible.

Correction attendue du filtrage : `Utilisateurs authentifiés` (ou `Ordinateurs du domaine`) en **Lecture**, `GG-EU-IT-Admin` en **Appliquer**. `Restore-D1` remet `Utilisateurs authentifiés` en Appliquer (défaut d'une GPO neuve) si aucun état n'avait été enregistré.

### D2 — Ines ne peut plus se connecter

```powershell
.\Break-D2.ps1 -WhatIf
.\Break-D2.ps1
```

- Le verrouillage passe par une PSO `PSO-Depannage-ines` (seuil 3, durée 2 h) appliquée au seul compte : la Default Domain Policy n'est pas modifiée, et un `gpupdate` sur le DC ne peut pas l'annuler.
- Les échecs sont générés depuis le DC : dans l'événement 4740, `Nom de l'ordinateur appelant` = `DNS1`. C'est voulu : faites-le interpréter ("en production, ce serait le téléphone ou le lecteur réseau qui garde l'ancien mot de passe").
- Le script active l'audit **Gestion des comptes d'utilisateur** (succès) via `auditpol` et le GUID de sous-catégorie. Si une GPO d'audit du domaine le désactive, l'événement 4740 n'apparaîtra pas : vérifiez avec `auditpol /get /category:*`.
- Si le compte n'est pas verrouillé à la fin du script (message rouge), faites 4 tentatives de connexion avec un mauvais mot de passe depuis le client.
- Une PSO appliquée directement à l'utilisateur prime sur une PSO appliquée à un groupe, quelle que soit la précédence. Point utile pour le projet final (louis a aussi la PSO du groupe Logistique-Admin).
- Si le Ch10 a laissé le seuil du domaine à 5, c'est quand même la PSO (seuil 3) qui s'applique à `ines`. La solution étudiante inclut la suppression de `PSO-Depannage-ines` ; sinon `Restore-D2` la supprime.

### D3 — Accès refusé au dossier Ventes

```powershell
.\Break-D3.ps1 -WhatIf
.\Break-D3.ps1              # si l'exercice AGDLP est terminé
.\Break-D3.ps1 -Preparer    # sinon : crée l'état final AGDLP puis casse
```

Le sous-dossier `Contrats` n'existe pas dans l'exercice AGDLP : `Break-D3` le crée (avec un fichier exemple) avant d'y poser le Deny. Avant de supprimer le DL, `Break-D3` enregistre l'état ; `Restore-D3` recrée le DL s'il manque.

Pour que la panne "ticket Kerberos" soit observable : faites ouvrir `\\dns1\Ventes-Documents` par `cindy` **après** l'injection et **avant** la correction, puis laissez-la connectée. Après l'ajout de `GG-EU-Compta-Users` dans le DL, elle reste refusée tant qu'elle n'a pas fermé sa session (un `klist purge` suffit souvent, mais pas toujours si une session SMB vers `dns1` est déjà ouverte).


### D4 — Le poste ne trouve plus le domaine

Sur le DC :

```powershell
.\Break-D4.ps1 -WhatIf
.\Break-D4.ps1
```

Sur `ws-IT-01` (session administrateur locale ou du domaine encore en cache) :

```powershell
Get-NetAdapter
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 8.8.8.8
ipconfig /flushdns
```

Le réseau du lab est interne : 8.8.8.8 est injoignable, toute résolution échoue. La session reste ouvrable grâce aux identifiants en cache, ce qui rend le symptôme trompeur ("je suis connecté, mais plus rien ne marche").

L'adresse du poste n'est pas supposée : si `ws-IT-01` est en DHCP depuis le lab Anatomie, les scripts la prennent dans l'enregistrement A du poste, sinon dans `Get-ADComputer ... IPv4Address` ; forcez-la avec `-IPPoste 192.168.0.1xx` si besoin. Le A et le PTR de `dns1` ne sont jamais modifiés.

Si le poste a encore une carte NAT VirtualBox active, son DNS 10.0.2.x brouille le diagnostic ; `Verify-Depannage -Client` le signale explicitement.

### Projet final — incident surprise (étape 6)

Pendant la pause qui précède l'étape 6, sur le DC du binôme :

```powershell
.\Break-Incident.ps1 -WhatIf
.\Break-Incident.ps1
# Variante pour un autre binôme :
.\Break-Incident.ps1 -FautesGpo Lien -FautesCompte Horaires,Postes -Utilisateur lucas
```

Par défaut : filtrage cassé sur `GPO-Logistique-Utilisateurs` + `louis` verrouillé et limité au poste `ws-LOG-99`. Les noms de GPO sont ceux imposés dans le sujet du projet ; si un binôme a nommé autrement, passez `-GpoName`. Notez les pannes injectées par binôme pour la grille (critère Incident, 3 points). Les garde-fous de `Break-D1`/`Break-D2` s'appliquent (pas de GPO par défaut, pas de compte privilégié).

Le filtrage par défaut de l'incident donne **Appliquer** à `GG-EU-Logistique-Users` et retire tout droit à `Utilisateurs authentifiés`. Correction attendue : **`Utilisateurs authentifiés` = Appliquer** (le filtrage d'origine de la GPO). Ne validez pas "`Utilisateurs authentifiés` en Lecture + `GG-EU-Logistique-Users` en Appliquer" : les postes relisent bien la GPO, lea/lucas/laura retrouvent L:, mais `louis` n'est membre que de `GG-EU-Logistique-Admin` et reste sans lecteur. Le ticket dit "plus personne dans l'équipe" : louis en fait partie. L'entrée `GG-EU-Logistique-Users` ajoutée devient alors redondante et peut être retirée.

`Break-Incident` enregistre ses paramètres (`GpoName`, `Ordinateur`, `Utilisateur`) dans `C:\Instructeur\Etat\Incident.json` ; `Restore-Incident` les réutilise (sauf ceux passés explicitement), donc une variante `-Utilisateur lucas` se restaure avec un simple `.\Restore-Incident.ps1`.

**Lancez `Restore-Incident` après l'étape 6 et AVANT les démos**, même si le binôme pense avoir tout réparé : tant que `PSO-Depannage-louis` existe, elle gagne sur `PSO-Logistique-Admin` (PSO appliquée à l'utilisateur > PSO de groupe) et `Get-ADUserResultantPasswordPolicy louis` montre la mauvaise PSO pendant la preuve de l'étape 5.

---

## Revenir en arrière

```powershell
.\Restore-D1.ps1 -GpoName "<nom exact>"
.\Restore-D2.ps1
.\Restore-D3.ps1
.\Restore-D4.ps1 -IntranetVersDC  # + commandes client affichées (DNS 192.168.0.2 ou reset DHCP, ipconfig /registerdns)
.\Restore-Incident.ps1            # reprend les paramètres du Break-Incident
.\Verify-Depannage.ps1            # contrôle global sur le DC
.\Verify-Depannage.ps1 -Client    # sur ws-IT-01, partie poste de D4
```

`Restore-D4 -IntranetVersDC` fait pointer `intranet` vers `192.168.0.2` (la correction attendue du ticket). Sans ce commutateur, `intranet` est remis dans son état d'avant `Break-D4` (en général : supprimé) ; `Verify-Depannage -Client` accepte les deux cas (192.168.0.2 ou absent, si le DNS du domaine répond).

En dernier recours, la remise à zéro complète du lab reste possible avec `suppression_structure.ps1` puis `creation_structure.ps1` (cela ne remet pas les GPO, partages ni DNS).
