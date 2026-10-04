# Chapitre 10 - Surveillance d'Active Directory : lire les journaux

## 🧭 Navigation du Cours
[⏮️ Chapitre Précédent: Powershell AD - Création et Modification](Chapitre%209.3.Powershell%20AD%20-%20Creation_et_Modification.md) | [🏠 Retour au Syllabus](index.md) | [⏭️ Suite : tickets de dépannage](Labo%20et%20Exercices/Exercices:%20Depannage.md)

---

!!! info "Objectifs du chapitre"

    À la fin de ce chapitre, vous savez :

    - expliquer pourquoi un événement peut **ne pas exister**, et activer l'audit sur le DC avec une GPO ;
    - vous repérer dans l'**Observateur d'événements**, filtrer un journal et enregistrer une vue personnalisée ;
    - lire un événement de sécurité et en tirer quatre informations : **quoi, quand, qui, d'où** ;
    - reconnaître une dizaine d'événements courants et savoir **sur quelle machine** les chercher ;
    - refaire la même recherche en PowerShell avec `Get-WinEvent`.

    **Durée** : 1 h 15 (lab compris). **Machines** : `dns1` et `ws-IT-01`.

---

## 1. La question à laquelle on répond

Un utilisateur appelle : « mon compte est bloqué ». Un responsable demande : « qui a ajouté Ivan au groupe des administrateurs IT ? ». Un auditeur veut savoir si quelqu'un a essayé des mots de passe cette nuit.

Dans les trois cas, la réponse est dans les **journaux d'événements** de Windows. Chaque fois que le DC accepte ou refuse un mot de passe, crée un compte ou modifie un groupe, il peut écrire une ligne datée : un **événement**, identifié par un numéro (*Event ID*).

Surveiller Active Directory, au niveau de ce cours, c'est savoir :

1. **faire en sorte** que ces événements soient écrits ;
2. **les retrouver** rapidement au milieu de milliers d'autres ;
3. **les lire** pour répondre à la question posée.

### Trois raisons de ne rien trouver

Quand on cherche un événement et qu'il n'y a rien, c'est presque toujours l'une de ces trois causes. Gardez-les en tête pendant tout le chapitre.

| Cause | Explication | Remède |
|-------|-------------|--------|
| **L'audit n'est pas activé** | Windows n'écrit un événement de sécurité que si on lui a demandé de surveiller cette catégorie. Plusieurs catégories utiles ne sont pas surveillées par défaut. | Activer l'audit par GPO (section 4, étape 1) |
| **Mauvaise machine** | Chaque machine a ses propres journaux. Un mot de passe refusé sur `ws-IT-01` laisse une trace sur le poste **et** une autre, différente, sur le DC. | Le tableau de la section 3 indique où chercher |
| **Le journal a été écrasé** | Un journal a une taille maximale. Quand il est plein, les événements les plus anciens disparaissent. Sur un DC actif, cela peut représenter quelques jours seulement. | Agrandir le journal (section 6) |

---

## 2. L'Observateur d'événements

C'est l'outil de base, présent sur toutes les machines Windows. Sur `dns1` : `Gestionnaire de serveur` > `Outils` > `Observateur d'événements`, ou `Win + R` > `eventvwr.msc`.

### Les trois zones de la fenêtre

```
┌─────────────────────────────┬──────────────────────────────────────────┬──────────────────────┐
│ ARBORESCENCE                │ LISTE DES ÉVÉNEMENTS                     │ ACTIONS              │
│                             │ Mots clés | Date et heure | Source | ID  │                      │
│ ▸ Affichages personnalisés  │ ──────────────────────────────────────── │ Filtrer le journal   │
│ ▾ Journaux Windows          │ Succès de l'audit  10:42:13  ...   4624  │   actuel…            │
│     Application             │ Échec de l'audit   10:41:58  ...   4771  │ Créer un affichage   │
│     Sécurité   ◂── ici      │ ...                                      │   personnalisé…      │
│     Installation            ├──────────────────────────────────────────┤ Rechercher…          │
│     Système                 │ DÉTAIL DE L'ÉVÉNEMENT SÉLECTIONNÉ        │ Propriétés           │
│ ▸ Journaux des applications │ Onglets : Général | Détails              │                      │
│   et des services           │ (texte lisible : compte, machine…)       │                      │
└─────────────────────────────┴──────────────────────────────────────────┴──────────────────────┘
```

- **À gauche**, on choisit **quel journal** lire.
- **Au centre en haut**, la liste des événements ; **au centre en bas**, le détail de celui qui est sélectionné. C'est l'onglet `Général` qu'on lit dans 95 % des cas.
- **À droite**, les actions : filtrer, créer une vue, rechercher, régler la taille du journal.

### Les journaux qui nous intéressent

| Journal | Emplacement | Ce qu'on y trouve |
|---------|-------------|-------------------|
| **Sécurité** | `Journaux Windows` | Ouvertures de session, mots de passe refusés, comptes et groupes modifiés. **Le journal de ce chapitre.** |
| **Système** | `Journaux Windows` | Services qui démarrent ou s'arrêtent, problèmes matériels, erreurs GPO côté poste |
| **Directory Service** | `Journaux des applications et des services` | Messages du service AD DS lui-même (sur le DC) |
| **DNS Server** | `Journaux des applications et des services` | Messages du serveur DNS (sur le DC) |
| **GroupPolicy > Operational** | `Journaux des applications et des services` > `Microsoft` > `Windows` | Application des GPO sur un poste (utile pour le dépannage GPO, section 5) |

Dans le journal **Sécurité**, la première colonne n'est pas `Niveau` mais **`Mots clés`** : `Succès de l'audit` (l'action a réussi) ou `Échec de l'audit` (elle a été refusée).

!!! example "Prise en main (5 min)"

    Sur `dns1`, ouvrez `Journaux Windows` > `Sécurité` et faites défiler quelques secondes.

    1. Combien d'événements le journal contient-il ? (le nombre s'affiche en haut de la liste)
    2. Quels sont les trois ou quatre ID qui reviennent le plus souvent ?
    3. Cliquez sur l'un d'eux et lisez l'onglet `Général`.

    Vous verrez surtout des **4624** (ouverture de session réussie), **4634** (fermeture) et **4672** (session avec privilèges administrateur). Ce sont les connexions normales des machines et des services. Elles sont légitimes et représentent l'essentiel du journal : c'est pour cela qu'on ne lit jamais un journal de sécurité sans **filtre**.

!!! tip "Déjà prêt sur un DC"

    Dans `Affichages personnalisés` > `Rôles de serveur` > `Services de domaine Active Directory`, Windows propose une vue qui regroupe les avertissements et erreurs liés à AD. Le **Gestionnaire de serveur** affiche aussi, dans la page `AD DS`, une tuile `ÉVÉNEMENTS` : c'est le premier endroit à regarder quand le DC semble malade.

---

## 3. Les événements à connaître

Inutile d'apprendre une longue liste. Les événements ci-dessous couvrent la grande majorité des demandes d'un support ou d'un audit. La colonne **Où** est aussi importante que le numéro.

| Situation | Event ID | Où le chercher |
|-----------|----------|----------------|
| Un compte a été **verrouillé** | **4740** | DC |
| Un **mot de passe incorrect** a été tapé (compte du domaine) | **4771** | DC |
| Une **ouverture de session a échoué** sur un poste | **4625** | Le poste concerné |
| Un compte a été **créé** / **supprimé** | **4720** / **4726** | DC |
| Un compte a été **désactivé** | **4725** | DC |
| Un mot de passe a été **réinitialisé** par un administrateur | **4724** | DC |
| Un membre a été **ajouté à un groupe** global / domaine local / universel | **4728** / **4732** / **4756** | DC |
| Un membre a été **retiré** d'un groupe global | **4729** | DC |
| Le **journal de sécurité a été effacé** | **1102** | La machine concernée |

Pour se repérer : les **47xx** concernent les **comptes et les groupes**, les **46xx** les **ouvertures de session**.

### Pourquoi deux événements différents pour un mot de passe refusé ?

Quand `ines` se trompe de mot de passe sur `ws-IT-01`, deux machines interviennent :

- **le poste** constate que l'ouverture de session a échoué et l'écrit dans **son** journal : **4625** ;
- **le DC**, qui est le seul à connaître le mot de passe d'`ines`, a refusé la vérification et l'écrit dans **son** journal : **4771**.

C'est la même tentative, vue de deux côtés. Conséquence pratique : chercher des 4625 sur le DC ne montre que les échecs d'ouverture de session **sur le DC lui-même**, pas ceux des postes.

!!! note "Et si vous voyez 4776 au lieu de 4771 ?"

    Windows vérifie normalement les mots de passe avec le protocole Kerberos, d'où le 4771. Dans certains cas (accès à une machine par son adresse IP, applications anciennes), il utilise un protocole plus ancien, NTLM, et le DC écrit alors un **4776**. Pour ce chapitre, retenez simplement : **4771 ou 4776 sur le DC = mot de passe refusé**.

---

## 4. Lab : de l'action à l'événement

**Durée** : 50 min · **Machines** : `dns1` (connecté en `MAXTEC\Administrateur`) et `ws-IT-01` · **Comptes utilisés** : `ines`, `ivan`

Le principe : vous provoquez vous-même des événements connus, puis vous les retrouvez. Quand ce ne sera plus vous qui les provoquez, vous saurez les reconnaître.

| Étape | Contenu | Durée |
|-------|---------|-------|
| 1 | Activer l'audit sur le DC | 10 min |
| 2 | Activer le verrouillage de compte | 5 min |
| 3 | Provoquer les événements | 10 min |
| 4 | Retrouver et lire les événements | 20 min |
| 5 | Remettre le lab en état | 5 min |

### Étape 1 — Activer l'audit sur le DC (10 min)

Par défaut, un DC enregistre les **succès** de vérification de mot de passe, mais **pas les échecs**. Sans cette étape, vous ne verriez aucun 4771.

L'audit des DC se configure dans la GPO **Default Domain Controllers Policy**, liée à l'OU `Domain Controllers` : tous les DC présents et futurs reçoivent ainsi la même configuration.

1. Ouvrez `Gestion de stratégie de groupe` (`gpmc.msc`).
2. Dépliez `Forêt` > `Domaines` > `maxtec.be` > `Domain Controllers`.
3. Clic droit sur **Default Domain Controllers Policy** > `Modifier…`.
4. Dans l'éditeur, naviguez jusqu'à :
   `Configuration ordinateur` > `Stratégies` > `Paramètres Windows` > `Paramètres de sécurité` > `Configuration avancée de la stratégie d'audit` > `Stratégies d'audit`
5. Configurez les quatre paramètres suivants. Pour chacun : double-clic, cochez **Configurer les événements d'audit suivants**, puis les cases indiquées, `OK`.

| Dossier | Paramètre | Cases à cocher |
|---------|-----------|----------------|
| `Connexion de compte` | `Auditer le service d'authentification Kerberos` | Succès **et** Échec |
| `Gestion des comptes` | `Auditer la gestion des comptes d'utilisateur` | Succès **et** Échec |
| `Gestion des comptes` | `Auditer la gestion des groupes de sécurité` | Succès |
| `Ouverture/Fermeture de session` | `Auditer l'ouverture de session` | Succès **et** Échec |

6. Fermez l'éditeur. Sur `dns1`, dans une invite de commandes administrateur :

    ```
    gpupdate /force
    ```

**Vérification.** Toujours dans la console administrateur :

```
auditpol /get /category:*
```

La commande affiche, pour chaque sous-catégorie, ce qui est audité. Repérez les lignes **Service d'authentification Kerberos**, **Gestion des comptes d'utilisateur**, **Gestion des groupes de sécurité** et **Ouvrir la session** : elles doivent correspondre au tableau ci-dessus.

!!! warning "Pourquoi une GPO et pas un réglage local"

    On trouve sur Internet des tutoriels qui activent l'audit directement sur le serveur avec `auditpol /set`. Cela fonctionne, mais seulement sur cette machine, et une GPO d'audit l'écrase au rafraîchissement suivant. Sur un domaine, l'audit se gère par GPO : c'est documenté, identique sur tous les DC, et visible dans GPMC.

??? note "En PowerShell / ligne de commande (aperçu)"

    La configuration par GPO n'a pas d'équivalent PowerShell simple (voir les règles GPO du cours). Pour un test ponctuel sur une seule machine, `auditpol` accepte les sous-catégories par leur identifiant, ce qui évite les problèmes de langue :

    ```powershell
    # Service d'authentification Kerberos : succès et échecs
    auditpol /set /subcategory:"{0CCE9242-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
    # Vérifier une seule sous-catégorie
    auditpol /get /subcategory:"{0CCE9242-69AE-11D9-BED3-505054503030}"
    ```

### Étape 2 — Activer le verrouillage de compte (5 min)

Par défaut, le **seuil de verrouillage vaut 0** : un compte n'est jamais verrouillé, quel que soit le nombre d'erreurs. Pour obtenir un 4740, il faut d'abord fixer un seuil.

La stratégie de verrouillage des comptes du domaine se règle dans la GPO liée à la racine du domaine (chapitre 8, « Exception : la politique de mots de passe du domaine ») :

1. Dans GPMC, sous `maxtec.be`, clic droit sur **Default Domain Policy** > `Modifier…`.
2. `Configuration ordinateur` > `Stratégies` > `Paramètres Windows` > `Paramètres de sécurité` > `Stratégies de comptes` > `Stratégie de verrouillage du compte`.
3. Double-clic sur **Seuil de verrouillage du compte** > **5** tentatives > `OK`. Windows propose des valeurs pour les deux autres paramètres : acceptez, puis réglez-les à **15** minutes chacun (`Durée de verrouillage des comptes`, `Réinitialiser le compteur de verrouillages du compte après`).
4. Sur `dns1` : `gpupdate /force`.

??? note "En PowerShell (aperçu, vu au chapitre 9)"

    ```powershell
    Set-ADDefaultDomainPasswordPolicy -Identity maxtec.be -LockoutThreshold 5 `
        -LockoutDuration 00:15:00 -LockoutObservationWindow 00:15:00
    Get-ADDefaultDomainPasswordPolicy | Select-Object LockoutThreshold, LockoutDuration
    ```

    Ce réglage est **temporaire** : au prochain rafraîchissement de la Default Domain Policy, le DC réapplique les valeurs de la GPO. Pour un réglage durable, passez par GPMC.

### Étape 3 — Provoquer les événements (10 min)

**Notez l'heure avant de commencer.** Faites les actions dans l'ordre.

**A. Mots de passe refusés et verrouillage** (sur `ws-IT-01`)

1. Fermez la session en cours (`Démarrer` > icône utilisateur > `Se déconnecter`).
2. À l'écran de connexion : `Autre utilisateur`, compte `MAXTEC\ines`, et un **mauvais** mot de passe.
3. Recommencez avec un mauvais mot de passe jusqu'à ce que Windows affiche que **le compte est verrouillé** (au bout de 5 échecs). Essayez ensuite le bon mot de passe (`Password1!`) : il est refusé aussi. C'est le principe du verrouillage.
4. Ouvrez une session avec `MAXTEC\ivan`.

**B. Actions d'administration** (sur `dns1`, dans `Utilisateurs et ordinateurs Active Directory`)

5. **Créer un compte** : dans `EU` > `IT` > `Users`, créez l'utilisateur `test-audit` (mot de passe `Password1!`).
6. **Ajouter à un groupe** : ouvrez les propriétés de `GG-EU-IT-Admin` (`EU` > `IT` > `Groups`) > onglet `Membres` > `Ajouter…` > `ivan` > `OK`.
7. **Supprimer le compte** : clic droit sur `test-audit` > `Supprimer` > `Oui`.

??? note "En PowerShell (aperçu, vu au chapitre 9)"

    ```powershell
    New-ADUser -Name test-audit -SamAccountName test-audit -Path "OU=Users,OU=IT,OU=EU,DC=maxtec,DC=be" `
        -AccountPassword (ConvertTo-SecureString 'Password1!' -AsPlainText -Force) -Enabled $true
    Add-ADGroupMember -Identity GG-EU-IT-Admin -Members ivan
    Remove-ADUser test-audit -Confirm:$false
    ```

### Étape 4 — Retrouver et lire les événements (20 min)

#### 4a. Créer une vue personnalisée (sur `dns1`)

Un **filtre** (`Filtrer le journal actuel…`) est temporaire : il disparaît quand on change de journal. Une **vue personnalisée** est un filtre enregistré, qu'on retrouve à chaque ouverture. Pour une recherche qu'on refera, on crée une vue.

1. Dans l'Observateur, clic droit sur `Affichages personnalisés` > `Créer un affichage personnalisé…`.
2. `Connecté` : **Dernière heure**.
3. `Par journal` > `Journaux d'événements` : cochez `Journaux Windows` > **Sécurité**.
4. Dans le champ `<Tous les ID d'événements>`, saisissez : `4771,4740,4720,4726,4728,4729`
5. `OK`, nommez la vue **Maxtec - Sécurité**, `OK`.

La vue apparaît dans `Affichages personnalisés`. Elle ne contient plus que les événements utiles : quelques dizaines au lieu de milliers.

#### 4b. Lire un événement : quoi, quand, qui, d'où

Chaque événement de sécurité répond à quatre questions. L'onglet `Général` est découpé en rubriques ; le principe est toujours le même :

| Question | Où la lire |
|----------|-----------|
| **Quoi** | L'ID et la première phrase (« Un compte d'utilisateur a été verrouillé ») |
| **Quand** | Colonne `Date et heure` (ou champ `Connecté` sous le texte) |
| **Qui a agi** | Rubrique **Sujet** : le compte qui a fait l'action (souvent un administrateur) |
| **Sur quoi / d'où** | Les rubriques suivantes : compte visé, groupe, ordinateur ou adresse d'origine |

!!! warning "Sujet ou compte visé : le piège de lecture"

    Dans un 4728, il y a **deux** noms de compte : celui de la rubrique **Sujet** (l'administrateur qui a fait l'ajout) et celui de la rubrique **Membre** (la personne ajoutée). Confondre les deux, c'est accuser la mauvaise personne.

**Fiche d'enquête.** Recopiez ce tableau et remplissez-le à partir de votre vue `Maxtec - Sécurité`.

| Event ID | Quand | Qui a agi (Sujet) | Compte ou groupe visé | D'où (machine ou adresse) |
|----------|-------|-------------------|-----------------------|---------------------------|
| 4771 | | — | | |
| 4740 | | | | |
| 4720 | | | | — |
| 4728 | | | | — |
| 4726 | | | | — |

??? success "Solution — fiche d'enquête"

    | Event ID | Quand | Qui a agi (Sujet) | Compte ou groupe visé | D'où |
    |----------|-------|-------------------|-----------------------|------|
    | 4771 (×5) | Heure de l'étape 3A | — (personne n'est connecté : c'est une tentative) | `ines` | **Adresse du client** : `::ffff:192.168.0.10`, c'est-à-dire `ws-IT-01` |
    | 4740 | Juste après le 5e échec | `DNS1$` (le DC lui-même, qui applique le verrouillage) | `ines` | **Nom de l'ordinateur appelant** : `WS-IT-01` |
    | 4720 | Étape 3B.5 | `Administrateur` | Nouveau compte `test-audit` | — |
    | 4728 | Étape 3B.6 | `Administrateur` | Membre : `CN=Ivan,OU=Users,OU=IT,OU=EU,DC=maxtec,DC=be` ; Groupe : `GG-EU-IT-Admin` | — |
    | 4726 | Étape 3B.7 | `Administrateur` | Compte cible : `test-audit` | — |

    Remarques :

    - Dans le 4771, le **code d'échec** `0x18` signifie « mauvais mot de passe ». Après le verrouillage, les tentatives suivantes portent le code `0x12` (« compte verrouillé ou désactivé »).
    - Le préfixe `::ffff:` devant l'adresse IP est une notation IPv6 pour une adresse IPv4 : l'adresse utile est `192.168.0.10`. Si le poste est en DHCP, vérifiez son adresse avec `nslookup ws-IT-01`.
    - Le **nom de l'ordinateur appelant** du 4740 est l'information la plus utile pour un support : elle dit **d'où** viennent les échecs. En entreprise, c'est souvent un téléphone ou un lecteur réseau qui garde un ancien mot de passe.
    - En créant `test-audit`, vous avez aussi généré d'autres événements (4722 compte activé, 4738 compte modifié) : une seule action dans la console peut produire plusieurs événements.

#### 4c. Côté poste (sur `ws-IT-01`)

Sur `ws-IT-01`, ouvrez une session administrateur (par exemple `.\admin-local`), puis l'Observateur d'événements :

1. `Journaux Windows` > clic droit sur **Sécurité** > `Filtrer le journal actuel…`
2. ID : `4625` > `OK`.
3. Ouvrez un événement et trouvez : le compte (`Compte pour lequel l'ouverture de session a échoué`) et la raison (`Informations sur l'échec` > `Raison de l'échec`).

Le poste écrit « nom d'utilisateur inconnu ou mot de passe incorrect », puis, après le verrouillage, que le compte est verrouillé. C'est la version « poste » des 4771 que vous avez lus sur le DC.

### Étape 5 — Remettre le lab en état (5 min)

Le verrouillage gênerait les exercices suivants (un compte bloqué au moindre test raté), et le ticket D2 part d'un seuil à 0.

1. **Déverrouiller `ines`** : `Utilisateurs et ordinateurs Active Directory` > `ines` > `Propriétés` > onglet `Compte` > cochez **Déverrouiller le compte** > `OK`.
2. **Retirer `ivan` du groupe** : propriétés de `GG-EU-IT-Admin` > `Membres` > `ivan` > `Supprimer` > `OK`. (Cela génère un **4729** : vérifiez-le dans votre vue.)
3. **Remettre le seuil à 0** : GPMC > `Default Domain Policy` > `Modifier…` > `Stratégie de verrouillage du compte` > `Seuil de verrouillage du compte` = **0**, puis `gpupdate /force` sur `dns1`.

**Gardez l'audit activé** (étape 1) : il ne gêne pas les exercices et vous servira pour le ticket D2.

??? note "En PowerShell (aperçu, vu au chapitre 9)"

    ```powershell
    Unlock-ADAccount -Identity ines
    Remove-ADGroupMember -Identity GG-EU-IT-Admin -Members ivan -Confirm:$false
    Set-ADDefaultDomainPasswordPolicy -Identity maxtec.be -LockoutThreshold 0
    ```

### Questions de synthèse

1. Un collègue cherche les échecs de connexion d'`ines` en filtrant le journal Sécurité du DC sur **4625** et ne trouve rien. Pourquoi, et que doit-il chercher à la place ?
2. Le compte d'`ines` se verrouille tous les matins vers 8 h. Quel événement ouvrez-vous, et quelle information y cherchez-vous en premier ?
3. Lundi matin, `irene` est membre d'`Admins du domaine` et personne ne sait pourquoi. Quel événement cherchez-vous, et quelle rubrique vous donne le responsable ?
4. Vous cherchez des 4771 de la semaine dernière sur le DC et la vue est vide. Citez deux causes possibles.

??? success "Réponses"

    1. Le 4625 est écrit sur la machine où l'on tente d'ouvrir la session (`ws-IT-01`). Sur le DC, le même échec apparaît en **4771** (ou 4776).
    2. Le **4740**, sur le DC. On y cherche le **nom de l'ordinateur appelant** : c'est la machine qui envoie les mauvais mots de passe. Déverrouiller sans traiter cette source, c'est retrouver le compte verrouillé le lendemain.
    3. Le **4728** (`Admins du domaine` est un groupe global). La rubrique **Sujet** donne le compte qui a fait l'ajout.
    4. L'audit des échecs Kerberos n'était pas activé à ce moment-là ; le journal a été écrasé parce qu'il était plein ; ou la vue est filtrée sur « Dernière heure ».

---

## 5. Autre usage courant : une GPO qui ne s'applique pas

Le journal Sécurité répond aux questions « qui a fait quoi ». Pour le dépannage des GPO (chapitre 8), le journal utile est sur le **poste**, pas sur le DC :

`Journaux des applications et des services` > `Microsoft` > `Windows` > `GroupPolicy` > `Operational`

- Chaque rafraîchissement des GPO y laisse une série d'événements. Le **5312** liste les GPO appliquées, le **5313** celles qui ont été filtrées (avec la raison).
- Les événements de niveau **Erreur** ou **Avertissement** signalent un échec de traitement.

Dans le journal **Système** du poste, source `GroupPolicy`, deux erreurs classiques :

- **1058** : le poste n'arrive pas à lire les fichiers de la GPO sur le DC (partage `SYSVOL`) ;
- **1129** : le poste n'a pas pu joindre de DC (réseau ou DNS).

`gpresult` (chapitre 8) reste le premier outil ; ces journaux expliquent **pourquoi** quand `gpresult` montre qu'une GPO manque.

---

## 6. En PowerShell : la même enquête avec `Get-WinEvent`

L'Observateur est idéal pour une recherche ponctuelle. PowerShell devient utile quand on veut **répéter** la recherche, la faire sur plusieurs jours ou en produire un rapport. Ouvrez une console **administrateur** sur `dns1` : le journal Sécurité n'est lisible que par les administrateurs.

### Le filtre : `-FilterHashtable`

Le filtre se décrit dans une table de hachage, avec les mêmes critères que la vue personnalisée :

| Vue personnalisée | `-FilterHashtable` |
|-------------------|--------------------|
| Journal : Sécurité | `LogName = 'Security'` |
| ID : 4740 | `Id = 4740` (ou plusieurs : `Id = 4728, 4729`) |
| Connecté : dernière heure | `StartTime = (Get-Date).AddHours(-1)` |

```powershell
# Les verrouillages de la dernière heure, lus comme dans l'Observateur
$depuis = (Get-Date).AddHours(-1)
Get-WinEvent -FilterHashtable @{ LogName = 'Security'; Id = 4740; StartTime = $depuis } |
    Format-List TimeCreated, Id, Message
```

La propriété `Message` contient exactement le texte de l'onglet `Général`.

!!! tip "Deux réflexes"

    - **Filtrer dans `-FilterHashtable`, pas avec `Where-Object`.** Le filtre est appliqué par Windows, qui ne renvoie que les événements voulus. `Get-WinEvent -LogName Security | Where-Object Id -eq 4740` lit **tout** le journal avant de trier : sur un DC, plusieurs minutes.
    - **Aucun résultat = erreur rouge.** Quand rien ne correspond, `Get-WinEvent` affiche « Aucun événement correspondant aux critères de sélection spécifiés n'a été trouvé ». Ce n'est pas une panne. Dans un script, ajoutez `-ErrorAction SilentlyContinue`.

`Get-EventLog`, qu'on trouve dans de vieux tutoriels, n'existe plus dans PowerShell 7 et ne lit pas les journaux comme `GroupPolicy/Operational`. Utilisez `Get-WinEvent`.

### Compter : un rapport en trois lignes

```powershell
# Combien d'événements de chaque type dans les dernières 24 h ?
Get-WinEvent -FilterHashtable @{ LogName = 'Security'; Id = 4720, 4726, 4728, 4740, 4771
                                 StartTime = (Get-Date).AddDays(-1) } -ErrorAction SilentlyContinue |
    Group-Object Id | Select-Object Name, Count
```

`Group-Object` (chapitre 9) regroupe par ID : en un coup d'œil, on voit si la nuit a été normale ou s'il y a eu 300 mots de passe refusés.

### Extraire un champ précis

Pour obtenir un tableau (compte, machine…) plutôt qu'un texte, il faut lire les champs nommés de l'événement. Ils sont visibles dans l'Observateur : onglet `Détails` > `Affichage XML`, section `EventData`. Cette fonction les lit :

```powershell
function Get-Champ {
    param($Evenement, [string]$Nom)
    ([xml]$Evenement.ToXml()).Event.EventData.Data |
        Where-Object { $_.Name -eq $Nom } |
        Select-Object -ExpandProperty '#text'
}
```

Exemple sur le 4740 :

```powershell
Get-WinEvent -FilterHashtable @{ LogName = 'Security'; Id = 4740 } -MaxEvents 10 |
    Select-Object TimeCreated,
        @{ n = 'Compte';  e = { Get-Champ $_ 'TargetUserName' } },
        @{ n = 'Machine'; e = { Get-Champ $_ 'TargetDomainName' } }
```

Dans un 4740, le champ `TargetDomainName` contient le nom de l'ordinateur appelant (c'est ainsi que Windows l'a nommé, pas un domaine).

!!! example "Entraînement"

    En vous inspirant de l'exemple 4740, écrivez les commandes qui affichent :

    1. pour chaque **4728** de la dernière heure : l'heure, l'auteur, le membre ajouté et le groupe ;
    2. pour chaque **4771** de la dernière heure : l'heure, le compte et l'adresse IP d'origine.

    Pour trouver le nom des champs : Observateur > l'événement > `Détails` > `Affichage XML`.

??? success "Solutions"

    ```powershell
    # 1. Ajouts aux groupes globaux
    Get-WinEvent -FilterHashtable @{ LogName = 'Security'; Id = 4728; StartTime = (Get-Date).AddHours(-1) } |
        Select-Object TimeCreated,
            @{ n = 'Auteur'; e = { Get-Champ $_ 'SubjectUserName' } },
            @{ n = 'Membre'; e = { Get-Champ $_ 'MemberName' } },
            @{ n = 'Groupe'; e = { Get-Champ $_ 'TargetUserName' } }

    # 2. Mots de passe refusés (Kerberos)
    Get-WinEvent -FilterHashtable @{ LogName = 'Security'; Id = 4771; StartTime = (Get-Date).AddHours(-1) } |
        Select-Object TimeCreated,
            @{ n = 'Compte'; e = { Get-Champ $_ 'TargetUserName' } },
            @{ n = 'IP';     e = { Get-Champ $_ 'IpAddress' } }
    ```

    Dans le 4728, le champ `TargetUserName` est le **groupe** (la cible de l'action) et `MemberName` le DN du membre ajouté. Encore le piège « sujet / cible » de la section 4b.

---

## 7. Bonnes pratiques

1. **Agrandir le journal Sécurité des DC.** La taille par défaut ne couvre parfois que quelques jours. Dans la GPO `Default Domain Controllers Policy` : `Configuration ordinateur` > `Stratégies` > `Paramètres Windows` > `Paramètres de sécurité` > `Journal des événements` > **Taille maximale du journal de sécurité** (en entreprise, souvent 1 à 4 Go). Pour voir la taille actuelle : Observateur > clic droit sur `Sécurité` > `Propriétés`.
2. **Configurer l'audit par GPO**, jamais machine par machine.
3. **Connaître la normale.** Cinquante mots de passe refusés par jour peut être normal pour une entreprise de 500 personnes ; trois cents en une heure ne l'est pas. On ne détecte une anomalie que si on connaît l'activité habituelle.
4. **Surveiller aussi les administrateurs.** Un compte administrateur volé agit avec des droits légitimes : ses ajouts aux groupes sensibles (`Admins du domaine`, `Administrateurs de l'entreprise`) doivent être vérifiés.
5. **Considérer tout 1102 comme suspect.** Effacer le journal de sécurité est le geste d'un attaquant qui efface ses traces. L'effacement lui-même laisse cet événement.
6. **Centraliser.** Les journaux restés sur le DC disparaissent avec lui s'il est compromis. En entreprise, ils sont copiés en continu vers un serveur central (section 8).

---

## 8. Pour aller plus loin (production)

Ces sujets dépassent le lab à un seul DC. Ils sont donnés pour que vous les reconnaissiez en entreprise.

- **Alerte sur un événement.** Dans l'Observateur, clic droit sur un événement > `Joindre une tâche à cet événement…` : Windows crée une tâche planifiée qui se déclenche chaque fois que cet ID réapparaît (par exemple un script qui prévient l'équipe à chaque 4740). Pratique pour un petit environnement, vite ingérable au-delà.
- **Centralisation (SIEM).** En entreprise, les journaux de tous les serveurs sont envoyés vers un outil central qui les conserve, les corrèle et déclenche les alertes : Wazuh ou Graylog (open source), Splunk, Elastic. Windows sait aussi transférer ses événements vers un serveur collecteur sans logiciel tiers (*Windows Event Forwarding*, journal `Événements transférés`).
- **Qui a modifié un attribut ou une GPO.** Le paramètre `Accès DS` > `Auditer les modifications du service d'annuaire` produit des événements **5136** (attribut modifié, avec l'ancienne et la nouvelle valeur), 5137 (objet créé) et 5141 (objet supprimé). Il demande en plus des règles d'audit sur les objets AD : c'est un réglage d'entreprise, au-delà de ce cours.
- **Plusieurs DC.** Le 4740 est écrit sur le DC qui détient le rôle d'**émulateur PDC** (chapitre 4, FSMO), les autres événements sur le DC qui a traité la demande : il faut donc chercher sur tous les DC, d'où l'intérêt de la centralisation. La santé de la réplication entre DC se vérifie avec `repadmin /replsummary` et `dcdiag`.
- **Santé du DC.** `dcdiag /test:services` vérifie que les services AD (NTDS, Netlogon, DNS…) tournent ; `dcdiag /test:dns` vérifie la configuration DNS du DC.

### Ressources

- [Surveiller Active Directory pour détecter les signes de compromission (Microsoft)](https://learn.microsoft.com/fr-fr/windows-server/identity/ad-ds/plan/security-best-practices/monitoring-active-directory-for-signs-of-compromise)
- [Encyclopédie des événements de sécurité (Ultimate Windows Security, en anglais)](https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/) : pour chaque Event ID, la signification de chaque champ

!!! note "Hors parcours"

    Le dossier `Labos Extra` contient un scénario complémentaire : [Lab 3 - MonitoringLab](Labos%20Extra/Labo3-MonitoringLab/README.md) (6 exercices, scénario d'entreprise de services informatiques).

---

## 📝 À retenir

1. **Pas d'audit, pas d'événement.** L'audit des DC se configure dans la `Default Domain Controllers Policy`.
2. **Chercher sur la bonne machine.** 4625 sur le poste ; 4771, 4740, 4720, 4728 sur le DC ; dépannage GPO dans `GroupPolicy > Operational` du poste.
3. **Filtrer avant de lire.** Une vue personnalisée par type de recherche ; en PowerShell, `Get-WinEvent -FilterHashtable`.
4. **Lire quoi, quand, qui, d'où**, sans confondre le **Sujet** (qui agit) et la **cible** (qui subit).
5. **Pour un verrouillage**, la machine d'origine (4740, ordinateur appelant) compte plus que le déverrouillage.

---

## 🧭 Navigation
[⏮️ Chapitre Précédent: Powershell AD - Création et Modification](Chapitre%209.3.Powershell%20AD%20-%20Creation_et_Modification.md) | [🏠 Retour au Syllabus](index.md) | [⏭️ Suite : tickets de dépannage](Labo%20et%20Exercices/Exercices:%20Depannage.md)
