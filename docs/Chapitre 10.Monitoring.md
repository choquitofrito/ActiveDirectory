# Chapitre 10 - Surveillance et Monitoring Active Directory

## 🧭 Navigation du Cours
[⏮️ Chapitre Précédent: Powershell AD - Création et Modification](Chapitre%209.3.Powershell%20AD%20-%20Creation_et_Modification.md) | [🏠 Retour au Syllabus](index.md) | [⏭️ Chapitre Suivant: Sécurité AD](Chapitre%2011.Securite_AD.md)

---

## 📊 Objectifs d'apprentissage

À la fin de ce chapitre, vous serez capable de :

1. Activer l'audit nécessaire sur le DC (ouverture de session, Kerberos, gestion des comptes et des groupes, modifications de l'annuaire) et vérifier la configuration avec `auditpol /get`
2. Associer une action d'administration ou une attaque simple à son Event ID (4625, 4771, 4740, 4728, 5136…) et dire **sur quelle machine** il apparaît
3. Retrouver ces événements avec une vue personnalisée de l'Observateur d'événements **et** avec `Get-WinEvent -FilterHashtable`
4. Extraire d'un événement le compte concerné et la machine d'origine

!!! warning "Périmètre de ce chapitre"
    Ce chapitre se concentre sur les **outils de base** : Observateur d'événements + PowerShell `Get-WinEvent`. Notre lab Maxtec a **un seul DC**, donc tout ce qui touche à la **réplication multi-DC** (compteurs `NTDS DRA`, `repadmin`, etc.) est hors sujet ici. Ces sujets avancés sont regroupés en fin de chapitre dans **"Pour aller plus loin (production)"**.

---

## 🎯 Pourquoi surveiller Active Directory ?

Active Directory est le **cœur de l'infrastructure IT** dans la plupart des entreprises. Une défaillance ou une compromission peut paralyser toute l'organisation.


### Scénarios critiques à détecter

| Scénario | Impact | Détection |
|----------|--------|-----------|
| **Comptes verrouillés en masse** | Perte de productivité, possible attaque brute force | Event ID 4740 (DC) |
| **Modification non autorisée de groupes** | Élévation de privilèges | Event ID 4728, 4732, 4756 (DC) |
| **Échecs d'authentification répétés** | Tentative d'intrusion | 4771 / 4776 (DC), 4625 (poste où l'on tente de se connecter) |
| **Modification de GPO ou d'objets AD** | Changement de configuration critique | Event ID 5136, 5137, 5141 (DC, audit « Directory Service Changes ») |
| **Création/suppression de comptes** | Activité administrative à tracer | Event ID 4720, 4726 (DC) |

---

## 🔍 Les 3 Piliers du Monitoring AD

### 1️⃣ **Disponibilité** (Availability)
- Le contrôleur de domaine est-il opérationnel ?
- Les services AD essentiels (NTDS, DNS, Netlogon) répondent-ils ?

### 2️⃣ **Sécurité** (Security) — *focus principal de ce chapitre*
- Activités suspectes (connexions anormales, échecs en série) ?
- Modifications non autorisées (groupes privilégiés, GPOs) ?
- Tentatives d'élévation de privilèges ?

### 3️⃣ **Performance** (Performance) — *concerne les environnements de production*
- Charge sur le DC (CPU/RAM/disque)
- Temps de réponse aux requêtes LDAP

> 💡 La performance et la disponibilité avancée se mesurent avec **Performance Monitor** (compteurs `NTDS`, `LDAP Searches/sec`, etc.). Ces sujets sont traités dans la section "Pour aller plus loin" — pour notre lab à 1 DC, le focus reste sur la **sécurité**.

---

## 📋 Event IDs Essentiels à Connaître

!!! info "Un événement n'existe que si l'audit correspondant est activé"

    Windows n'enregistre un événement de sécurité que si la **sous-catégorie d'audit** correspondante est activée (Advanced Audit Policy). Plusieurs sous-catégories utiles sont **désactivées par défaut**, ou n'enregistrent que les succès. Le [lab](#lab-de-laction-a-levenement) ci-dessous commence par là.

### 🔐 Sécurité (journal Security)

#### Authentification

Où apparaît un échec de connexion ? Cela dépend de la machine qui vérifie le mot de passe.

| ID | Signification | Où | Sous-catégorie d'audit |
|---|---|---|---|
| **4624** | Ouverture de session réussie | Machine sur laquelle on ouvre la session | Logon |
| **4625** | Échec d'ouverture de session | Machine sur laquelle on tente d'ouvrir la session (ex. `ws-IT-01`) | Logon |
| **4634** | Fermeture de session | Machine de la session | Logoff |
| **4648** | Ouverture de session avec identifiants explicites (`runas`) | Machine où la commande est lancée | Logon |
| **4768** | Ticket Kerberos (TGT) demandé | **DC** | Kerberos Authentication Service |
| **4771** | Échec de pré-authentification Kerberos (mauvais mot de passe d'un compte du domaine) | **DC** | Kerberos Authentication Service |
| **4776** | Validation d'identifiants NTLM (succès ou échec) | **DC** | Credential Validation |

!!! warning "Piège classique : 4625 sur le DC"

    Quand `ines` se trompe de mot de passe sur `ws-IT-01`, le **4625** est écrit dans le journal de **`ws-IT-01`**. Sur le DC, le même échec apparaît comme **4771** (Kerberos, cas normal dans un domaine) et/ou **4776** (si NTLM est utilisé, par exemple accès par adresse IP). Chercher des 4625 sur le DC ne montre que les échecs d'ouverture de session **sur le DC lui-même**, y compris les accès réseau vers le DC (par exemple `\\dns1\partage` avec un mauvais mot de passe).

#### Gestion des Comptes (sur le DC, sous-catégorie User Account Management)
- **4720** : Création de compte utilisateur
- **4722** : Activation de compte
- **4723** : Tentative de changement de mot de passe (par l'utilisateur lui-même)
- **4724** : Réinitialisation de mot de passe (par un administrateur ou un délégué)
- **4725** : Désactivation de compte
- **4726** : Suppression de compte
- **4740** : Verrouillage de compte (enregistré sur le DC qui détient le rôle d'émulateur PDC ; dans le lab, `dns1`)

#### Gestion des Groupes (sur le DC, sous-catégorie Security Group Management)
- **4728** : Membre ajouté à un groupe de sécurité global
- **4729** : Membre retiré d'un groupe de sécurité global
- **4732** : Membre ajouté à un groupe de sécurité local ou domaine local
- **4733** : Membre retiré d'un groupe de sécurité local ou domaine local
- **4756** : Membre ajouté à un groupe de sécurité universel

#### Modifications de l'annuaire (objets AD, y compris les GPOs)

Ces événements concernent **n'importe quel objet AD** (utilisateur, groupe, OU, GPO…). Ils n'apparaissent que si la sous-catégorie **Directory Service Changes** (catégorie *DS Access*) est activée sur le DC, et que l'objet a une règle d'audit (SACL) qui le couvre.

- **5136** : Modification d'un attribut d'un objet AD (ex. `title` d'un utilisateur, `versionNumber` d'une GPO modifiée)
- **5137** : Création d'un objet AD (ex. nouvelle GPO, nouvel utilisateur)
- **5138** : Restauration d'un objet supprimé (corbeille AD)
- **5139** : Déplacement d'un objet AD
- **5141** : Suppression d'un objet AD
- **4662** : Opération effectuée sur un objet AD (sous-catégorie Directory Service Access ; très bavard)

### 🧩 Traitement des GPOs (sur les clients)

Le traitement des GPOs sur un poste ne va **pas** dans le journal Security. Il est dans :

`Journaux des applications et des services` > `Microsoft` > `Windows` > `GroupPolicy` > `Operational`

- **5312** : liste des GPOs **applicables** à ce poste ou à cet utilisateur (informatif, pas une erreur)
- **5313** : liste des GPOs **filtrées** (non appliquées) et raison
- Les événements de niveau **Erreur** et **Avertissement** de ce journal signalent les échecs de traitement

Dans le journal **Système** du client, source `GroupPolicy` :

- **1058** : impossible d'accéder aux fichiers de la GPO dans SYSVOL
- **1030** : impossible d'obtenir la liste des GPOs
- **1129** : échec du traitement faute de connexion réseau avec un DC

### ⚙️ Système (journal System)

- **7036** : un service a changé d'état (démarré/arrêté)
- **7034** : un service s'est arrêté de manière inattendue

Pour les messages propres à AD DS et au DNS du DC : `Journaux des applications et des services` > `Directory Service` et `DNS Server`.

> 💡 Les Event IDs de réplication (1925, 2042, 1963) ne concernent que les environnements multi-DC. Voir "Pour aller plus loin" en fin de chapitre.

---

## 🛠️ Outils Natifs de Monitoring

### 1. Event Viewer (Observateur d'événements)

Lancez l'Observateur d'événements depuis le Gestionnaire de serveur (`Outils`) ou avec `eventvwr.msc`.
Il permet de consulter les journaux du système et ceux des applications installées.

Vous pouvez parcourir **Journaux Windows** et **Journaux des applications et des services**, ou créer une **vue personnalisée** (ex. tous les verrouillages de compte, ou tous les échecs de traitement GPO).


**Filtrage rapide :**

- Clic droit sur un journal → **Filtrer le journal actuel…**
- Saisir les Event IDs pertinents
- Enregistrer comme **vue personnalisée** pour la réutiliser

### 2. PowerShell - Get-WinEvent

`Get-WinEvent` est la commande à utiliser. L'ancienne `Get-EventLog` n'existe plus dans PowerShell 7 et ne lit pas les journaux `Applications and Services` modernes (comme `GroupPolicy/Operational`).

```powershell
# Récupérer les 10 derniers échecs de pré-authentification Kerberos (sur le DC)
Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4771} -MaxEvents 10

# Comptes verrouillés dans les dernières 24h
$date = (Get-Date).AddDays(-1)
Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4740; StartTime=$date}

# Modifications de groupes
Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4728,4732,4756} -MaxEvents 50

# Traitement des GPOs (sur un client)
Get-WinEvent -LogName 'Microsoft-Windows-GroupPolicy/Operational' -MaxEvents 20
```

!!! tip "`-FilterHashtable` plutôt que `Where-Object`"

    Le filtre `-FilterHashtable` est appliqué par le service de journaux : seuls les événements voulus sont lus. `Get-WinEvent -LogName Security | Where-Object Id -eq 4740` lit **tout** le journal avant de filtrer, ce qui peut prendre des minutes sur un DC.

### 3. Diagnostic rapide du DC : `dcdiag`

Pour vérifier que le contrôleur de domaine est en bon état :

```powershell
# Vérifier que les services AD essentiels tournent (NTDS, Netlogon, DNS, etc.)
dcdiag /test:services

# Vérifier la connectivité et la configuration DNS du DC
dcdiag /test:dns
```

> 💡 Les commandes `repadmin` (état de réplication) et `dcdiag /test:replications` ne s'appliquent qu'aux environnements multi-DC. Voir "Pour aller plus loin" pour ces sujets.

---

## 🧪 Lab : de l'action à l'événement

**Durée** : 45-60 min · **Machines** : `dns1` (DC) et `ws-IT-01` · **Comptes** : `MAXTEC\Administrateur` sur le DC, `ines`, `ivan`, `rebecca`

Objectif : provoquer vous-même des événements de sécurité, puis les retrouver. Vous saurez ensuite reconnaître ces mêmes événements quand ce n'est pas vous qui les provoquez.

### Étape 1 — Activer l'audit sur le DC (10 min)

Sur `dns1`, dans une console **administrateur**. On utilise les **GUID** des sous-catégories plutôt que leur nom : sur un Windows en français, `auditpol` attend les noms en français (« Ouvrir la session »…), alors que les GUID fonctionnent dans toutes les langues.

```powershell
# Logon (4624/4625)
auditpol /set /subcategory:"{0CCE9215-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
# Kerberos Authentication Service (4768/4771)
auditpol /set /subcategory:"{0CCE9242-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
# Credential Validation (4776)
auditpol /set /subcategory:"{0CCE923F-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
# User Account Management (4720, 4724, 4740...)
auditpol /set /subcategory:"{0CCE9235-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
# Security Group Management (4728, 4732...)
auditpol /set /subcategory:"{0CCE9237-69AE-11D9-BED3-505054503030}" /success:enable
# Directory Service Changes (5136, 5137, 5141...)
auditpol /set /subcategory:"{0CCE923C-69AE-11D9-BED3-505054503030}" /success:enable

# Vérifier
auditpol /get /category:*
```

!!! note "La méthode production : une GPO"

    `auditpol` modifie la stratégie locale du DC. En production, on configure l'audit dans la **Default Domain Controllers Policy** pour que tous les DC aient la même configuration : GPMC > `Default Domain Controllers Policy` > `Modifier` > `Configuration ordinateur` > `Stratégies` > `Paramètres Windows` > `Paramètres de sécurité` > `Configuration avancée de la stratégie d'audit` > `Stratégies d'audit`, puis :

    - `Ouverture/Fermeture de session` > `Auditer l'ouverture de session` : Succès, Échec
    - `Connexion de compte` > `Auditer le service d'authentification Kerberos` et `Auditer la validation des informations d'identification` : Succès, Échec
    - `Gestion des comptes` > `Auditer la gestion des comptes d'utilisateur` : Succès, Échec ; `Auditer la gestion des groupes de sécurité` : Succès
    - `Accès DS` > `Auditer les modifications du service d'annuaire` : Succès

    Si une GPO configure l'audit avancé, elle remplace au prochain rafraîchissement ce que vous avez fait avec `auditpol`.

### Étape 2 — Configurer le verrouillage de compte (5 min)

Par défaut, le **seuil de verrouillage est 0** : un compte n'est jamais verrouillé, et vous n'obtiendrez jamais de 4740. Configurez-le d'abord.

**Méthode GPMC (celle qui fait foi)** : `Default Domain Policy` (liée au domaine) > `Modifier` > `Configuration ordinateur` > `Stratégies` > `Paramètres Windows` > `Paramètres de sécurité` > `Stratégies de comptes` > `Stratégie de verrouillage du compte` :

- `Seuil de verrouillage du compte` : **5** tentatives
- `Durée de verrouillage des comptes` : **15** minutes
- `Réinitialiser le compteur de verrouillages du compte après` : **15** minutes

Puis `gpupdate /force` sur le DC.

**Méthode PowerShell (rapide)** :

```powershell
Set-ADDefaultDomainPasswordPolicy -Identity maxtec.be -LockoutThreshold 5 `
    -LockoutDuration 00:15:00 -LockoutObservationWindow 00:15:00
Get-ADDefaultDomainPasswordPolicy | Select-Object LockoutThreshold, LockoutDuration, LockoutObservationWindow
```

!!! warning "La Default Domain Policy a le dernier mot"

    La Default Domain Policy définit elle-même un seuil (0 par défaut). Quand le DC réapplique ses paramètres de sécurité (après une modification de la GPO, et de toute façon périodiquement), il réécrit les valeurs de la GPO. La méthode PowerShell suffit pour la séance ; pour un réglage durable, passez par la GPO.

### Étape 3 — Provoquer les événements depuis `ws-IT-01` (10 min)

1. **Échecs d'authentification** : sur `ws-IT-01`, dans une session ouverte (par exemple avec `ivan`), ouvrez **PowerShell** et lancez **3 fois** en tapant un **mauvais** mot de passe :

    ```powershell
    runas /user:MAXTEC\ines powershell
    ```

    On passe par PowerShell et non par `cmd` : si la GPO « Désactiver l'accès à l'invite de commandes » de GPO-1 est encore liée aux utilisateurs IT, `cmd` est bloqué pour `ivan`.

2. **Verrouillage** : relancez la même commande avec un mauvais mot de passe jusqu'à dépasser **5** échecs au total. Au 6e essai, même avec le bon mot de passe, Windows répond que le compte est verrouillé.

3. **Ajout à un groupe** : sur le DC (ou depuis `ws-IT-01` avec RSAT), ajoutez `ivan` au groupe `GG-EU-IT-Admin` :

    ```powershell
    Add-ADGroupMember -Identity GG-EU-IT-Admin -Members ivan
    ```

4. **Modification d'un attribut** : changez le poste (`Title`) de `rebecca` :

    ```powershell
    Set-ADUser rebecca -Title "Gestionnaire RH senior"
    ```

Notez l'heure : vous en aurez besoin pour filtrer.

### Étape 4 — Retrouver les événements (15-20 min)

**A. Observateur d'événements (sur le DC)**

1. `eventvwr.msc` > clic droit sur `Affichages personnalisés` > `Créer une vue personnalisée…`
2. `Connecté` : Dernière heure ; `Par journal` : `Journaux Windows` > `Sécurité`
3. IDs : `4771,4776,4740,4728,4729,5136`
4. Nom : `Lab Maxtec - Sécurité` > `OK`

Ouvrez chaque événement et trouvez : le compte concerné, la machine ou l'adresse IP d'origine, et (pour 4728/5136) **qui** a fait la modification.

Puis, sur **`ws-IT-01`**, filtrez le journal `Sécurité` sur l'ID **4625** (si rien n'apparaît, l'audit des échecs d'ouverture de session n'est pas activé sur le poste : vérifiez avec `auditpol /get /subcategory:"{0CCE9215-69AE-11D9-BED3-505054503030}"`).

**B. PowerShell (sur le DC)**

Écrivez les commandes qui répondent aux questions suivantes. Les solutions sont plus bas ; essayez d'abord.

1. Lister les échecs Kerberos de la dernière heure avec, pour chacun, l'heure, le compte et l'adresse IP d'origine.
2. Trouver quel compte a été verrouillé et depuis quelle machine.
3. Trouver qui a ajouté qui à quel groupe.
4. Trouver l'ancienne et la nouvelle valeur du `Title` de `rebecca`.

!!! tip "Lire les champs d'un événement"

    Chaque événement contient des champs nommés (`TargetUserName`, `IpAddress`…), visibles dans l'onglet `Détails` > `Affichage XML` de l'Observateur. En PowerShell, on les lit en convertissant l'événement en XML. Cette petite fonction (compatible PowerShell 5.1) vous servira pour toutes les questions :

    ```powershell
    function Get-Champ {
        param($Evenement, [string]$Nom)
        ([xml]$Evenement.ToXml()).Event.EventData.Data |
            Where-Object { $_.Name -eq $Nom } |
            Select-Object -ExpandProperty '#text'
    }
    ```

??? success "Solution 1 — échecs Kerberos (4771)"

    ```powershell
    $depuis = (Get-Date).AddHours(-1)
    Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4771; StartTime=$depuis} |
        Select-Object TimeCreated,
            @{n='Compte'; e={ Get-Champ $_ 'TargetUserName' }},
            @{n='IP';     e={ Get-Champ $_ 'IpAddress' }},
            @{n='Code';   e={ Get-Champ $_ 'Status' }}
    ```

    Code `0x18` = mauvais mot de passe. Après le verrouillage, le code devient `0x12` (compte verrouillé ou désactivé). L'IP est celle de `ws-IT-01` (`192.168.0.10`, préfixée `::ffff:`).

    Si aucun 4771 n'apparaît mais que vous voyez des **4776**, l'authentification est passée par NTLM : même question, champs `TargetUserName`, `Workstation` et `Status`.

??? success "Solution 2 — verrouillage (4740)"

    ```powershell
    Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4740; StartTime=(Get-Date).AddHours(-1)} |
        Select-Object TimeCreated,
            @{n='Compte';  e={ Get-Champ $_ 'TargetUserName' }},
            @{n='Machine'; e={ Get-Champ $_ 'TargetDomainName' }}
    ```

    Dans le 4740, le champ `TargetDomainName` contient le **nom de la machine d'origine** (affiché « Nom de l'ordinateur appelant ») : ici `WS-IT-01`. C'est l'information qu'un support cherche en premier (« d'où viennent les tentatives ? »).

    Déverrouillez ensuite le compte : `Unlock-ADAccount ines`.

??? success "Solution 3 — ajout au groupe (4728)"

    ```powershell
    Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4728; StartTime=(Get-Date).AddHours(-1)} |
        Select-Object TimeCreated,
            @{n='Auteur';  e={ Get-Champ $_ 'SubjectUserName' }},
            @{n='Membre';  e={ Get-Champ $_ 'MemberName' }},
            @{n='Groupe';  e={ Get-Champ $_ 'TargetUserName' }}
    ```

    `MemberName` est le DN du membre ajouté (`CN=Ivan,OU=Users,OU=IT,OU=EU,DC=maxtec,DC=be`). Remettez le lab en état : `Remove-ADGroupMember GG-EU-IT-Admin -Members ivan -Confirm:$false` (qui génère un **4729**).

??? success "Solution 4 — modification d'attribut (5136)"

    ```powershell
    Get-WinEvent -FilterHashtable @{LogName='Security'; Id=5136; StartTime=(Get-Date).AddHours(-1)} |
        Where-Object { (Get-Champ $_ 'AttributeLDAPDisplayName') -eq 'title' } |
        Select-Object TimeCreated,
            @{n='Auteur';    e={ Get-Champ $_ 'SubjectUserName' }},
            @{n='Objet';     e={ Get-Champ $_ 'ObjectDN' }},
            @{n='Valeur';    e={ Get-Champ $_ 'AttributeValue' }},
            @{n='Operation'; e={ Get-Champ $_ 'OperationType' }}
    ```

    Remplacer une valeur produit **deux** 5136 : une suppression de l'ancienne valeur (`Gestionnaire RH`, opération `%%14675` « Valeur supprimée ») et un ajout de la nouvelle (`%%14674` « Valeur ajoutée »).

    **Aucun 5136 ?** Vérifiez d'abord `auditpol /get /subcategory:"{0CCE923C-69AE-11D9-BED3-505054503030}"`. Si l'audit est actif, c'est la règle d'audit (SACL) de l'objet qui manque : ADUC > `Affichage` > `Fonctionnalités avancées` > propriétés de l'OU `EU` > `Sécurité` > `Avancé` > onglet `Audit` > `Ajouter` : principal `Tout le monde`, type `Succès`, s'applique à `Objets Utilisateur descendants`, permission `Écrire toutes les propriétés`. Refaites l'étape 3.4.

    Remettez la valeur d'origine : `Set-ADUser rebecca -Title "Gestionnaire RH"`.

### Pour conclure le lab

Répondez en une phrase chacune :

- Pourquoi n'avez-vous pas trouvé de 4625 pour `ines` sur le DC ?
- Qu'est-ce qui, dans le 4740, vous permet de trouver la machine d'où viennent les tentatives ?
- Quel événement verrait-on si un attaquant ajoutait son compte à `Admins du domaine` (groupe global) ?

!!! warning "Remettre le seuil de verrouillage à 0"

    En production, on garde un seuil de verrouillage. Dans le lab, il gênerait les exercices suivants (comptes verrouillés au moindre test raté). Revenez en arrière avec la méthode utilisée à l'étape 2 :

    - **GPMC** : `Default Domain Policy` > `Stratégie de verrouillage du compte` > `Seuil de verrouillage du compte` = **0**, puis `gpupdate /force` sur le DC ;
    - **PowerShell** :

        ```powershell
        Set-ADDefaultDomainPasswordPolicy -Identity maxtec.be -LockoutThreshold 0
        Get-ADDefaultDomainPasswordPolicy | Select-Object LockoutThreshold
        ```

---

## 🎓 Bonnes Pratiques

### ✅ À FAIRE

1. **Établir une baseline** : savoir ce qui est « normal » avant de chercher des anomalies (ex. un pic soudain d'échecs d'authentification, ou de connexions hors des heures habituelles)
   ```powershell
   # Nombre d'ouvertures de session réussies par jour sur les 7 derniers jours
   $depuis = (Get-Date).AddDays(-7)
   Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4624; StartTime=$depuis} -ErrorAction SilentlyContinue |
       Group-Object { $_.TimeCreated.Date.ToString('yyyy-MM-dd') } |
       Select-Object Name, Count
   ```
   Vérifiez que le journal couvre bien la période : s'il est plein, les événements les plus anciens ont été écrasés et la moyenne est fausse.

2. **Créer des vues personnalisées** dans l'Observateur pour les événements fréquents
   - Sécurité → IDs : 4771, 4740, 4728
   - Enregistrer comme « Surveillance Sécurité Quotidienne »

3. **Documenter les alertes** : tenir un journal des incidents
   ```
   Date | Event ID | Description | Action Prise | Résolu ?
   -----|----------|-------------|--------------|----------
   ```

4. **Tester les alertes** : provoquer volontairement les événements (comme dans le lab) avec un compte de test, pour vérifier que la détection fonctionne

5. **Archiver les logs** : politique de rétention claire
   - Journal Security : minimum 90 jours
   - Journal System : 30 jours
   - Exporter régulièrement vers un stockage sécurisé

### ❌ À ÉVITER

1. ❌ Alertes trop sensibles (*alert fatigue* : au bout de 50 fausses alertes, plus personne ne lit)
2. ❌ Ne pas sécuriser les logs (cible d'attaquants qui veulent effacer leurs traces ; l'effacement du journal Security génère l'événement **1102**)
3. ❌ Oublier de surveiller les admins eux-mêmes (un compte admin compromis agit avec des droits légitimes)
4. ❌ Garder la taille de journal par défaut : quand le journal est plein, les anciens événements sont écrasés, ce qui peut ne représenter que quelques jours sur un DC actif

---

## 🚀 Pour aller plus loin (production multi-DC)

Cette section regroupe les sujets **avancés** qui ne s'appliquent pas à notre lab à 1 DC, mais que vous rencontrerez dans des environnements de production. À étudier après avoir maîtrisé les bases.

### Performance Monitor (PerfMon) — compteurs AD

Dans un environnement de production, on surveille des compteurs spécifiques au service AD :

| Catégorie | Compteur | Seuil indicatif |
|-----------|----------|-----------------|
| `NTDS` | `DRA Pending Replication Synchronizations` | > 50 = retard de réplication |
| `NTDS` | `LDAP Client Sessions` | À baseliner sur 1-2 semaines |
| `NTDS` | `LDAP Searches/sec` | > 200 = charge élevée |
| `Database` | `Database Cache % Hit` | < 90% = besoin de RAM |
| `Processor` | `% Processor Time` | > 80% soutenu = saturation |
| `Memory` | `Available MBytes` | < 1 GB = critique |

> ⚠️ Ces compteurs nécessitent une **baseline** établie sur plusieurs semaines avant de définir des seuils utiles. Un seuil pris à la volée génère du bruit.

### Réplication multi-DC : `repadmin`

Quand il y a plusieurs DC, la réplication LDAP+SYSVOL entre eux doit être surveillée :

```powershell
# Vue d'ensemble de l'état de réplication entre tous les DC
repadmin /replsummary

# Forcer la réplication immédiatement
repadmin /syncall /AdeP

# Voir les partenaires de réplication d'un DC
repadmin /showrepl
```

Couplé avec `dcdiag /test:replications` pour un diagnostic complet.

### Alertes automatiques sur événement

**Méthode : Planificateur de tâches + déclencheur sur événement**

1. `taskschd.msc` → **Créer une tâche de base** → « Alerte verrouillage de compte »
2. **Déclencheur** : « Lorsqu'un événement spécifique est enregistré » → Journal : Sécurité, ID : 4740
3. **Action** : exécuter un script PowerShell qui prévient l'équipe :

```powershell
$event = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4740} -MaxEvents 1
$user = $event.Properties[0].Value       # TargetUserName
$computer = $event.Properties[1].Value   # machine d'origine

Send-MailMessage -To "admin@entreprise.com" `
                 -From "dc01@entreprise.com" `
                 -Subject "ALERTE: Compte verrouillé - $user" `
                 -Body "Compte: $user`nOrdinateur: $computer`nHeure: $($event.TimeCreated)" `
                 -SmtpServer "smtp.entreprise.com"
```

!!! warning "`Send-MailMessage` est obsolète"

    Microsoft a marqué `Send-MailMessage` comme obsolète : il ne garantit pas une connexion sécurisée au serveur SMTP. Il fonctionne encore et illustre bien le principe, mais en production on utilise un relais SMTP interne, l'API d'une messagerie (ex. Microsoft Graph) ou, plus simplement, on centralise les journaux dans un SIEM qui gère les alertes.

### Rapport quotidien automatisé

Un script PowerShell exécuté chaque matin via tâche planifiée agrège les événements importants des dernières 24 h. Squelette :

```powershell
$debut = (Get-Date).AddHours(-24)
$comptesCreated = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4720; StartTime=$debut} -ErrorAction SilentlyContinue
$verrouilles    = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4740; StartTime=$debut} -ErrorAction SilentlyContinue
$groupesModif   = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4728,4732,4756; StartTime=$debut} -ErrorAction SilentlyContinue
$echecs         = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4771,4776; StartTime=$debut} -ErrorAction SilentlyContinue

Write-Host "Comptes créés        : $(@($comptesCreated).Count)"
Write-Host "Comptes verrouillés  : $(@($verrouilles).Count)"
Write-Host "Modifs de groupes    : $(@($groupesModif).Count)"
Write-Host "Échecs d'auth. (DC)  : $(@($echecs).Count)"
```

À enrichir avec un export CSV/HTML selon besoin. (4776 compte succès **et** échecs NTLM : filtrez sur le champ `Status` pour ne garder que les échecs.)

### Outils tiers (à connaître pour l'entreprise)

- **Netwrix Auditor** : audit AD complet (commercial)
- **ManageEngine ADAudit Plus** : monitoring temps réel (commercial)
- **Splunk** / **Graylog** : SIEM pour agréger logs de plusieurs sources
- **Elastic Stack (ELK)** : alternative open-source pour la centralisation et la recherche

---

## 🔗 Ressources Complémentaires

### Documentation Microsoft
- [Monitoring Active Directory](https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/monitoring-active-directory-for-signs-of-compromise)
- [Advanced Security Audit Policies](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/advanced-security-auditing)
- [Event Log Reference (Ultimate Windows Security)](https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/)

### Outils communautaires
- [AD ACL Scanner (audit des permissions AD, GitHub)](https://github.com/canix1/ADACLScanner)
- [Règles de détection Sigma (SigmaHQ)](https://github.com/SigmaHQ/sigma)

!!! note "Pour aller plus loin (hors parcours)"

    Le dossier `Labos Extra` contient un scénario complémentaire qui ne fait pas partie du parcours du cours : [Lab 3 - MonitoringLab](Labos%20Extra/Labo3-MonitoringLab/README.md) (6 exercices, scénario MSP).

---

## 📝 Points Clés à Retenir

1. **Pas d'audit, pas d'événement** : vérifiez `auditpol /get /category:*` avant de chercher
2. **Savoir où chercher** : 4625 sur le poste, 4771/4776/4740/4728/5136 sur le DC, traitement GPO dans `GroupPolicy/Operational` du client
3. **`Get-WinEvent -FilterHashtable`** pour chercher vite, et les champs nommés (XML) pour extraire compte et machine
4. **Automatiser progressivement** : scripts → tâches planifiées → SIEM (centralisation et alertes en temps réel)
5. **Documenter les baselines** : savoir ce qui est normal
6. **Corrélation** : un événement seul ne fait pas un incident

---

## 🧭 Navigation
[⏮️ Chapitre Précédent: Powershell AD - Création et Modification](Chapitre%209.3.Powershell%20AD%20-%20Creation_et_Modification.md) | [🏠 Retour au Syllabus](index.md) | [⏭️ Chapitre Suivant: Sécurité AD](Chapitre%2011.Securite_AD.md)

---

**📚 Cours Active Directory - Monitoring**
