# Chapitre 11 - Sécurité Active Directory : l'essentiel

## Navigation du cours
[⏮️ Chapitre précédent : Monitoring](Chapitre%2010.Monitoring.md) | [🏠 Retour au syllabus](index.md) | [⏭️ Suivant : Projet final](Labo%20et%20Exercices/Projet_Final.md)

---

## Objectifs

Durée : le chapitre complet représente environ 3 h (45 min de théorie réparties, le reste en pratique sur le lab Maxtec). Le programme du cours lui consacre 2 h : pratiques 1, 2, 4 et 5 sur le lab ; pratiques 3 et 6 en démonstration par le formateur.

À la fin de ce chapitre, vous serez capable de :

- expliquer pourquoi un attaquant vise Active Directory et ce que signifie « Domain Admin compromis » ;
- classer une machine ou un compte dans le **modèle en tiers** (0, 1, 2) ;
- lister en PowerShell les membres des **groupes à haut privilège** et les comptes à risque (mot de passe qui n'expire jamais, comptes jamais utilisés, `adminCount=1`) ;
- décrire le fonctionnement de **Kerberos** (TGT, ticket de service, port 88, tolérance horaire) et expliquer pourquoi NTLM est abandonné ;
- appliquer une **stratégie de mot de passe affinée** (FGPP) à un groupe ;
- placer un compte d'administration dans **Protected Users** et vérifier l'effet ;
- déployer **Windows LAPS** sur un poste et lire le mot de passe géré ;
- activer la **corbeille AD** et restaurer un utilisateur supprimé avec son SID et ses groupes ;
- lire un rapport **PingCastle** et prioriser trois corrections.

!!! note "Contexte réglementaire en Belgique"
    La directive européenne NIS2 est transposée en Belgique par la loi du 26 avril 2024. Le **Centre pour la Cybersécurité Belgique (CCB)** est l'autorité compétente et propose le cadre **CyberFundamentals** comme référentiel de conformité. Parmi les mesures attendues des entités concernées : la gestion des comptes à privilèges et l'authentification multifacteur pour les accès d'administration. Autrement dit, ce que vous voyez dans ce chapitre n'est pas seulement de la bonne pratique : pour beaucoup d'entreprises, c'est une obligation.

---

## 1. Pourquoi AD est la cible n°1

Active Directory contient **toutes** les identités de l'entreprise et décide qui a le droit de faire quoi sur chaque machine jointe au domaine. Un compte **Admins du domaine** (Domain Admins) compromis donne donc à l'attaquant la main sur tous les serveurs, tous les postes, toutes les données et, souvent, les sauvegardes.

Le scénario d'un rançongiciel en entreprise suit presque toujours le même schéma :

```
Phishing  →  poste utilisateur  →  identifiants en mémoire  →  mouvement latéral  →  Domain Admin  →  chiffrement de tout le parc
```

1. Un utilisateur ouvre une pièce jointe piégée : l'attaquant contrôle **un poste**.
2. Sur ce poste, il récupère les identifiants mis en cache ou présents en mémoire, par exemple ceux d'un technicien qui s'y est connecté avec un compte admin pour dépanner.
3. Avec ces identifiants, il se connecte à d'autres machines (**mouvement latéral**), jusqu'à trouver un compte plus privilégié.
4. Une fois Domain Admin, il déploie le chiffrement sur tout le parc, souvent par GPO.

Le point faible n'est presque jamais une faille exotique : c'est un **compte privilégié utilisé au mauvais endroit**. Tout ce chapitre vise à casser cette chaîne.

!!! warning "Périmètre"
    Ce chapitre est défensif. On explique les techniques d'attaque au niveau conceptuel pour comprendre les protections, sans outils ni commandes offensives.

---

## 2. Le modèle en tiers

Microsoft a formalisé la séparation des privilèges dans un modèle en **trois niveaux** (le nom officiel actuel est *Enterprise Access Model*, mais le vocabulaire « Tier 0/1/2 » reste celui qu'on entend partout).

| Tier | Contenu | Exemples Maxtec |
|------|---------|-----------------|
| **Tier 0** | Ce qui contrôle l'identité : DC, base AD, comptes et groupes qui administrent AD, PKI, serveurs de synchronisation d'identités | `dns1`, `Administrateur`, groupe Admins du domaine |
| **Tier 1** | Serveurs et applications de l'entreprise | Serveur de fichiers, base de données, serveur web interne |
| **Tier 2** | Postes de travail et utilisateurs | `ws-IT-01`, `ws-RH-01`, comptes `ivan`, `vanessa`… |

**Règle fondamentale** : une identité d'un tier élevé **ne se connecte jamais** sur un système d'un tier plus bas. Un Domain Admin ne se connecte pas sur un poste utilisateur, même « juste pour vérifier un truc ». Si ce poste est compromis, les identifiants du Domain Admin y restent en mémoire et l'attaquant les récupère.

Conséquence pratique : on retrouve les **comptes d'administration séparés** vus au [Chapitre 7](Chapitre%207.Gestion_des_Utilisateurs.md#comptes-administrateurs-bonne-pratique). En production, une administratrice comme `irene` aurait :

| Compte | Usage | Où il se connecte |
|--------|-------|-------------------|
| `irene` | Email, navigation, bureautique | Son poste (Tier 2) |
| `irene-adm` | Administration des postes et serveurs | Serveurs (Tier 1) ou poste d'administration dédié |
| `irene-t0` (si nécessaire) | Administration d'AD | DC uniquement, depuis un poste d'administration sécurisé |

### Groupes à haut privilège

Ces groupes donnent, directement ou indirectement, le contrôle du domaine. Ils doivent être **presque vides** : chaque membre supplémentaire est une porte d'entrée de plus.

| Groupe (nom FR sur un DC français) | SID / RID | Pourquoi c'est sensible |
|------------------------------------|-----------|-------------------------|
| Admins du domaine (Domain Admins) | `<SID domaine>-512` | Administrateur de toutes les machines du domaine |
| Administrateurs de l'entreprise (Enterprise Admins) | `<SID domaine racine>-519` | Contrôle de toute la forêt |
| Administrateurs du schéma (Schema Admins) | `<SID domaine racine>-518` | Modifie le schéma ; à laisser vide hors opération planifiée |
| Administrateurs (Administrators, builtin) | `S-1-5-32-544` | Administrateurs des DC eux-mêmes |
| Opérateurs de compte (Account Operators) | `S-1-5-32-548` | Crée et modifie la plupart des comptes et groupes |
| Opérateurs de sauvegarde (Backup Operators) | `S-1-5-32-551` | Peut lire n'importe quel fichier du DC, y compris la base AD |
| Opérateurs de serveur (Server Operators) | `S-1-5-32-549` | Peut se connecter au DC, gérer ses services |
| Opérateurs d'impression (Print Operators) | `S-1-5-32-550` | Peut se connecter au DC et charger des pilotes |

Les quatre groupes « Opérateurs » sont des héritages des années 2000. Recommandation actuelle : **vides**, et on délègue plutôt des droits précis sur des OUs (voir la délégation au Chapitre 7).

!!! tip "Noms localisés : utilisez les SID"
    Sur un DC installé en français, le groupe s'appelle « Admins du domaine », sur un DC anglais « Domain Admins ». Un script qui cherche le nom en dur casse selon la langue. Le **SID** ne change jamais : le RID 512 est toujours Domain Admins, `S-1-5-32-544` toujours Administrators.

---

## 3. Pratique 1 — Auditer les privilèges de Maxtec (25 min)

!!! example "Cahier des charges"
    La direction de Maxtec demande un état des lieux des comptes à privilèges avant l'audit NIS2. Depuis le DC (`dns1`), dans une console PowerShell administrateur, produisez :

    1. la liste des membres (récursifs) de chacun des 8 groupes du tableau ci-dessus ;
    2. les comptes utilisateurs dont le mot de passe **n'expire jamais** ;
    3. les comptes utilisateurs **jamais utilisés** (aucune ouverture de session) ;
    4. les comptes avec `adminCount = 1`.

    Puis simulez un incident : ajoutez `ines` dans Admins du domaine, relancez l'audit, retirez-la, et observez son attribut `adminCount` après retrait.

**Point de départ** — obtenir un groupe par son SID :

```powershell
$domSid = (Get-ADDomain).DomainSID.Value
Get-ADGroup -Filter "SID -eq '$domSid-512'"      # Admins du domaine
Get-ADGroup -Identity "S-1-5-32-544"             # Administrateurs (builtin)
```

!!! note "À propos de `adminCount`"
    Toutes les 60 minutes, un processus du DC appelé **SDProp** parcourt les membres des groupes protégés, leur met `adminCount = 1` et réapplique des permissions verrouillées (modèle `AdminSDHolder`). Quand on retire le compte du groupe, **`adminCount` reste à 1** : c'est un marqueur utile pour retrouver les comptes qui ont été privilégiés un jour.

??? success "Solution"

    **1. Membres des groupes privilégiés**

    ```powershell
    $domSid = (Get-ADDomain).DomainSID.Value
    $sids = @(
        "$domSid-512",   # Admins du domaine
        "$domSid-519",   # Administrateurs de l'entreprise
        "$domSid-518",   # Administrateurs du schéma
        "S-1-5-32-544",  # Administrateurs
        "S-1-5-32-548",  # Opérateurs de compte
        "S-1-5-32-549",  # Opérateurs de serveur
        "S-1-5-32-550",  # Opérateurs d'impression
        "S-1-5-32-551"   # Opérateurs de sauvegarde
    )

    foreach ($s in $sids) {
        $g = Get-ADGroup -Identity $s
        $membres = @(Get-ADGroupMember -Identity $g -Recursive)
        Write-Host ("{0} : {1} membre(s)" -f $g.Name, $membres.Count) -ForegroundColor Cyan
        foreach ($m in $membres) {
            Write-Host "   - $($m.SamAccountName) ($($m.objectClass))"
        }
    }
    ```

    Résultat attendu sur un lab propre : seul `Administrateur` apparaît dans les groupes Admins (du domaine, de l'entreprise, du schéma, Administrateurs). Les quatre groupes Opérateurs sont vides.

    `-Recursive` déplie les groupes imbriqués : Administrateurs contient les groupes Admins du domaine et Administrateurs de l'entreprise, et on veut voir les **personnes** au bout.

    **2. Mots de passe qui n'expirent jamais**

    ```powershell
    Search-ADAccount -PasswordNeverExpires -UsersOnly |
        Select-Object SamAccountName, Enabled, DistinguishedName
    ```

    Sur le lab, vous devriez surtout voir des comptes intégrés (`Invité`, désactivé, et éventuellement `Administrateur` selon l'installation). Aucun utilisateur Maxtec ne doit y figurer : le script de création ne pose pas ce drapeau.

    **3. Comptes jamais utilisés**

    ```powershell
    Get-ADUser -Filter * -Properties LastLogonDate |
        Where-Object { -not $_.LastLogonDate } |
        Select-Object SamAccountName, Enabled
    ```

    `LastLogonDate` est basé sur `lastLogonTimestamp`, répliqué avec un retard volontaire de 9 à 14 jours. Pour trouver les comptes inactifs en production, on raisonne en mois, pas en jours :

    ```powershell
    Search-ADAccount -AccountInactive -TimeSpan 90.00:00:00 -UsersOnly
    ```

    **4. `adminCount = 1`**

    ```powershell
    Get-ADUser -Filter "adminCount -eq 1" -Properties adminCount |
        Select-Object SamAccountName, Enabled
    ```

    Attendu : `Administrateur` et `krbtgt`.

    **Incident simulé**

    ```powershell
    $da = Get-ADGroup -Filter "SID -eq '$domSid-512'"
    Add-ADGroupMember -Identity $da -Members ines
    Get-ADGroupMember -Identity $da -Recursive | Select-Object SamAccountName   # ines apparaît

    Remove-ADGroupMember -Identity $da -Members ines -Confirm:$false
    Get-ADUser ines -Properties adminCount | Select-Object SamAccountName, adminCount
    ```

    Si SDProp est passé entre l'ajout et le retrait (jusqu'à 60 min), `adminCount` vaut 1 et reste à 1 après le retrait. Sinon il est vide. Pour ne pas attendre, vous pouvez vérifier plus tard dans la journée. Nettoyage éventuel :

    ```powershell
    Set-ADUser ines -Clear adminCount
    ```

    Le retrait de `adminCount` ne rétablit pas l'héritage des permissions sur l'objet : en production, il faut aussi réactiver l'héritage dans l'onglet **Sécurité > Avancé** du compte.

---

## 4. Kerberos en 5 minutes (et pourquoi NTLM disparaît)

### Kerberos

Kerberos est le protocole d'authentification par défaut d'AD. Le principe : on prouve son identité **une fois** au DC, qui délivre des **tickets** ; ensuite on présente ces tickets aux services sans renvoyer le mot de passe.

```
 1. Ouverture de session
    ivan ──(preuve chiffrée avec son mot de passe)──► KDC (sur dns1, port 88)
    ivan ◄──────────────── TGT (Ticket-Granting Ticket, ~10 h) ──┘

 2. Accès à \\dns1\IT-docs
    ivan ──(TGT + « je veux cifs/dns1 »)──► KDC
    ivan ◄──── ticket de service cifs/dns1 ──┘

 3. ivan ──(ticket de service)──► serveur de fichiers dns1 : accès accordé
```

À retenir :

- **KDC** (Key Distribution Center) : service Kerberos qui tourne sur chaque DC, port **88** TCP/UDP.
- **TGT** : le « badge d'entrée », délivré au logon, valable 10 h par défaut. Il contient la liste des groupes de l'utilisateur (dans une structure appelée **PAC**).
- **Ticket de service (TGS)** : un ticket par service visité (`cifs/dns1` pour les partages, `ldap/dns1` pour l'annuaire, `http/intranet`…). Le nom du service est un **SPN** (Service Principal Name).
- **Horloge** : les tickets sont horodatés. Au-delà de **5 minutes** d'écart entre client et DC, l'authentification échoue. C'est pour ça que la synchronisation horaire est critique dans un domaine.
- **`klist`** sur un poste affiche les tickets en cache ; `klist purge` les supprime.

Vous manipulerez tout cela en pratique dans le lab [Anatomie d'une ouverture de session](Labo%20et%20Exercices/Exercices:%20Anatomie_Logon_Reseau.md).

### NTLM

NTLM est l'ancien protocole (années 1990), toujours utilisé en repli quand Kerberos n'est pas possible (accès par adresse IP, machine hors domaine, vieille application). Ses défauts :

- pas d'authentification mutuelle : le client ne vérifie pas qu'il parle au bon serveur ;
- le condensat (hash) du mot de passe suffit à s'authentifier : un attaquant qui le vole n'a pas besoin du mot de passe en clair (*pass-the-hash*) ;
- vulnérable au relais (un attaquant retransmet l'authentification à un autre serveur).

État en 2026 : le protocole **NTLMv1 a été supprimé** de Windows 11 24H2 et Windows Server 2025. NTLM dans son ensemble est **déprécié** : Microsoft a annoncé sa désactivation par défaut dans la prochaine version majeure de Windows Server, sans date précise, et renforce l'audit NTLM dans les versions actuelles. En entreprise, le travail consiste à **identifier ce qui utilise encore NTLM** avant de pouvoir le couper.

### Kerberoasting : le concept

N'importe quel utilisateur du domaine peut demander un ticket de service pour n'importe quel SPN. Ce ticket est chiffré avec une clé dérivée du **mot de passe du compte de service**. Si ce compte est un compte utilisateur classique avec un mot de passe faible (« Service2019! »), l'attaquant emporte le ticket et essaie des milliards de mots de passe **hors ligne**, sans jamais alerter le DC. S'il trouve, il obtient le compte de service, souvent trop privilégié.

Défenses :

| Défense | Effet |
|---------|-------|
| **gMSA** (Group Managed Service Account) | Mot de passe de 240 octets (120 caractères) généré et renouvelé automatiquement par AD. Impossible à casser en pratique. Solution recommandée. |
| Mot de passe long (25+ caractères) pour les comptes de service restants | Rend l'attaque hors ligne irréaliste |
| **AES** uniquement (pas de RC4) | RC4 est beaucoup plus rapide à attaquer ; cocher « Ce compte prend en charge le chiffrement AES 256 bits » et retirer RC4 |
| Pas de comptes de service dans Admins du domaine | Limite l'impact si le compte tombe |

Pour lister les comptes utilisateurs qui portent un SPN (donc exposés) :

```powershell
Get-ADUser -Filter "ServicePrincipalName -like '*'" -Properties ServicePrincipalName |
    Select-Object SamAccountName, ServicePrincipalName
```

Sur le lab, seul `krbtgt` apparaît (son mot de passe est aléatoire et long, il n'est pas concerné en pratique).

---

## 5. Pratique 2 — Stratégie de mot de passe affinée pour les admins IT (20 min)

La stratégie de mot de passe du domaine (Default Domain Policy) s'applique à tout le monde. Une **Fine-Grained Password Policy** (FGPP, objet *PSO*) permet d'imposer des règles plus strictes à un groupe précis. Ce sont des objets AD, pas des GPO : ils se créent donc sans problème en PowerShell.

!!! example "Cahier des charges"
    Les membres de `GG-EU-IT-Admin` doivent avoir :

    | Paramètre | Valeur |
    |-----------|--------|
    | Longueur minimale | 14 caractères |
    | Complexité | Activée |
    | Historique | 24 mots de passe |
    | Durée de vie maximale | 180 jours |
    | Durée de vie minimale | 1 jour |
    | Verrouillage | Après 5 tentatives échouées, pendant 30 minutes |

    Nom de la stratégie : `PSO-IT-Admin`, priorité 10. Vérifiez ensuite que `irene` reçoit bien cette stratégie et qu'un mot de passe de 10 caractères est refusé.

!!! note "Règles des FGPP"
    - Une FGPP s'applique à des **utilisateurs** ou à des **groupes globaux de sécurité** (d'où l'intérêt des `GG-`). Pas aux OUs.
    - Si plusieurs FGPP s'appliquent, la plus petite **Precedence** gagne.
    - Elle ne change pas le mot de passe actuel : elle s'applique au **prochain changement**.

??? success "Solution"

    ```powershell
    New-ADFineGrainedPasswordPolicy -Name "PSO-IT-Admin" `
        -Precedence 10 `
        -MinPasswordLength 14 `
        -ComplexityEnabled $true `
        -PasswordHistoryCount 24 `
        -MaxPasswordAge "180.00:00:00" `
        -MinPasswordAge "1.00:00:00" `
        -LockoutThreshold 5 `
        -LockoutDuration "00:30:00" `
        -LockoutObservationWindow "00:30:00" `
        -ReversibleEncryptionEnabled $false `
        -ProtectedFromAccidentalDeletion $false `
        -Description "Admins IT : 14 caracteres, verrouillage apres 5 essais"

    Add-ADFineGrainedPasswordPolicySubject -Identity "PSO-IT-Admin" -Subjects "GG-EU-IT-Admin"
    ```

    **Vérification**

    ```powershell
    Get-ADUserResultantPasswordPolicy -Identity irene
    ```

    Vous devez voir `Name : PSO-IT-Admin`, `MinPasswordLength : 14`, `LockoutThreshold : 5`. Pour un utilisateur hors du groupe, la commande ne renvoie rien : c'est la stratégie du domaine qui s'applique.

    ```powershell
    Get-ADUserResultantPasswordPolicy -Identity ivan    # vide
    ```

    **Test de refus**

    ```powershell
    # 10 caractères : doit échouer (le mot de passe ne respecte pas les exigences)
    Set-ADAccountPassword irene -Reset -NewPassword (ConvertTo-SecureString "Court_1234" -AsPlainText -Force)

    # 16 caractères : doit réussir
    Set-ADAccountPassword irene -Reset -NewPassword (ConvertTo-SecureString "Maxtec_Admin_26!" -AsPlainText -Force)
    ```

    Notez le nouveau mot de passe d'`irene` : vous en aurez besoin pour la suite.

    **Équivalent graphique** : Centre d'administration Active Directory (`dsac.exe`) → `maxtec (local)` → `System` → `Password Settings Container` → **Nouveau** → **Paramètres de mot de passe**. La vue « Paramètres de mot de passe résultants » est disponible par clic droit sur un utilisateur.

---

## 6. Pratique 3 — Protected Users pour le compte d'administration (20 min)

**Protected Users** est un groupe de sécurité intégré (depuis Windows Server 2012 R2). Ses membres reçoivent automatiquement des protections qu'on ne peut pas configurer autrement :

| Protection | Conséquence |
|------------|-------------|
| Pas d'authentification **NTLM** | Le hash NTLM ne sert plus à rien, pas de pass-the-hash |
| Kerberos sans **DES ni RC4** | Seul AES est accepté |
| Pas de **délégation** Kerberos | Un serveur ne peut pas réutiliser l'identité du compte ailleurs |
| **TGT de 4 heures**, non renouvelable | Un ticket volé expire vite |
| Pas de **mise en cache** des identifiants | Pas d'ouverture de session hors ligne ; rien à voler sur le poste après déconnexion |

!!! danger "Qui ne doit PAS aller dans Protected Users"
    - Les **comptes de service** et les comptes d'ordinateur : beaucoup d'applications dépendent de NTLM ou de la délégation, elles cesseraient de fonctionner.
    - Le **seul** compte Domain Admin dont vous disposez : si une application ou un outil d'administration dépend de NTLM, vous vous enfermez dehors. Testez toujours avec un compte secondaire d'abord.
    - Les utilisateurs de portables qui doivent ouvrir une session hors réseau (pas de cache).

!!! example "Cahier des charges"
    1. Créez le compte d'administration `irene-adm` (Irene Iserbyt - Admin) dans `OU=Users,OU=IT,OU=EU,DC=maxtec,DC=be`, membre de `GG-EU-IT-Admin`. Mot de passe d'au moins 14 caractères (il tombe sous `PSO-IT-Admin`), qui ne contienne ni le login ni un morceau du nom affiché (règle de complexité : « Irene » ou « Admin » dans le mot de passe le font refuser).
    2. Ajoutez `irene-adm` au groupe Protected Users (retrouvez-le par son RID : **525**).
    3. Vérifiez depuis `ws-IT-01` :
        - que le TGT d'`irene-adm` dure 4 heures ;
        - que l'accès à un partage par **adresse IP** (qui force NTLM) échoue, alors que l'accès par **nom** fonctionne.

??? success "Solution"

    **Création du compte et ajout au groupe**

    ```powershell
    $motDePasse = ConvertTo-SecureString "Tier1_Maxtec_2026!" -AsPlainText -Force
    New-ADUser -Name "Irene Iserbyt (adm)" `
        -SamAccountName "irene-adm" `
        -UserPrincipalName "irene-adm@maxtec.be" `
        -GivenName "Irene" -Surname "Iserbyt" `
        -DisplayName "Irene Iserbyt - Admin" `
        -Department "IT" `
        -Description "Compte d'administration d'irene" `
        -Path "OU=Users,OU=IT,OU=EU,DC=maxtec,DC=be" `
        -AccountPassword $motDePasse -Enabled $true

    Add-ADGroupMember -Identity "GG-EU-IT-Admin" -Members "irene-adm"

    $domSid = (Get-ADDomain).DomainSID.Value
    $pu = Get-ADGroup -Filter "SID -eq '$domSid-525'"     # Protected Users / Utilisateurs protégés
    Add-ADGroupMember -Identity $pu -Members "irene-adm"
    Get-ADGroupMember -Identity $pu | Select-Object SamAccountName
    ```

    **Vérification 1 : durée du TGT**

    Sur `ws-IT-01`, ouvrez une session avec `MAXTEC\irene-adm`, puis dans une invite de commandes :

    ```
    klist tgt
    ```

    Comparez l'heure de début et l'heure de fin du TGT (`Start Time` / `End Time` dans un `klist` en anglais) : 4 heures d'écart (contre 10 h pour `ivan`). Dans `klist`, le type de chiffrement des tickets est `AES-256-CTS-HMAC-SHA1-96`.

    **Vérification 2 : NTLM refusé**

    Toujours en `irene-adm` :

    ```
    dir \\dns1\NETLOGON          :: Kerberos : fonctionne
    dir \\192.168.0.2\NETLOGON   :: par IP, Windows utilise NTLM : échec d'authentification
    ```

    Refaites le même test avec `ivan` : les deux fonctionnent, car `ivan` a le droit d'utiliser NTLM. On teste sur `NETLOGON` parce que tous les utilisateurs du domaine peuvent le lire : un refus ne peut venir que du protocole, pas des permissions.

    **À noter** : l'appartenance à Protected Users est lue à l'ouverture de session. Un compte déjà connecté au moment de l'ajout doit se déconnecter puis se reconnecter.

    **Dans votre environnement réel**, l'étape suivante serait d'utiliser `irene-adm` pour l'administration et de retirer `irene` de `GG-EU-IT-Admin`. Dans le lab, on garde `irene` telle quelle pour ne pas casser les autres exercices.

---

## 7. Pratique 4 — Windows LAPS sur ws-IT-01 (35 min)

### Le problème

Chaque poste Windows a un compte **Administrateur local**. Si tous les postes ont le même mot de passe (image clonée, script de déploiement), un attaquant qui le récupère sur un poste se connecte à **tous** les autres. C'est le premier accélérateur de mouvement latéral.

**Windows LAPS** (Local Administrator Password Solution) donne à chaque machine un mot de passe local **unique, aléatoire et renouvelé automatiquement**, stocké dans l'objet ordinateur AD. Seuls les comptes autorisés peuvent le lire. Windows LAPS est intégré à Windows 11, Windows Server 2019 et plus récents depuis les mises à jour d'avril 2023, et natif dans Windows Server 2025 : rien à installer, les modèles d'administration GPO sont inclus.

!!! note "Ne pas confondre"
    L'ancien « Microsoft LAPS » (MSI à installer, attribut `ms-Mcs-AdmPwd`) est obsolète. On utilise ici **Windows LAPS**, avec le module PowerShell `LAPS` et les attributs `msLAPS-*`.

!!! warning "Prérequis"
    - `ws-IT-01` doit être dans `OU=Computers,OU=IT,OU=EU,DC=maxtec,DC=be` (voir [Référence du lab](Labo%20et%20Exercices/Labo/Reference_Lab_Maxtec.md)), sinon la GPO liée à cette OU ne s'appliquera pas.
    - La mise à jour du schéma est une opération de forêt, **irréversible**. Aucun risque en lab ; en production, elle se planifie.
    - Sur un DC Windows Server 2022, le module `LAPS` et `Update-LapsADSchema` n'existent qu'après la mise à jour cumulative d'avril 2023. Vérifiez avec `Get-Command Update-LapsADSchema` : si la commande est introuvable, le DC n'est pas à jour (ISO d'évaluation ancienne, pas d'Internet dans le lab).

!!! example "Cahier des charges"
    1. Étendre le schéma pour Windows LAPS.
    2. Autoriser les ordinateurs de `OU=Computers,OU=IT` à écrire leur propre mot de passe.
    3. Créer la GPO `Maxtec - LAPS`, liée à `OU=Computers,OU=IT,OU=EU,DC=maxtec,DC=be`, configurée pour sauvegarder le mot de passe dans AD (14 caractères minimum, rotation 30 jours).
    4. Forcer l'application sur `ws-IT-01` et lire le mot de passe depuis le DC.

??? success "Solution"

    **Étape 1 et 2 — sur le DC, PowerShell administrateur**

    ```powershell
    # Extension du schéma (ajoute les attributs msLAPS-* aux objets ordinateur)
    Update-LapsADSchema -Verbose

    # Permission pour que chaque ordinateur de l'OU écrive son propre mot de passe
    Set-LapsADComputerSelfPermission -Identity "OU=Computers,OU=IT,OU=EU,DC=maxtec,DC=be"
    ```

    `Update-LapsADSchema` demande confirmation : répondez `O` (ou `Y`) à chaque question.

    **Étape 3 — GPO : shell en PowerShell, configuration dans GPMC**

    ```powershell
    $gpoName = "Maxtec - LAPS"
    New-GPO -Name $gpoName -Comment "Windows LAPS : sauvegarde du mot de passe admin local dans AD"
    New-GPLink -Name $gpoName -Target "OU=Computers,OU=IT,OU=EU,DC=maxtec,DC=be" -LinkEnabled Yes
    ```

    Ouvrez ensuite `gpmc.msc` → clic droit sur `Maxtec - LAPS` → **Modifier**, et allez dans :

    **Configuration ordinateur > Stratégies > Modèles d'administration > Système > LAPS**
    (*Computer Configuration > Policies > Administrative Templates > System > LAPS*)

    Le nœud `LAPS` n'apparaît pas ? Si vous avez créé le magasin central au chapitre 8, GPMC ne lit plus que lui : copiez `C:\Windows\PolicyDefinitions\LAPS.admx` dans `\\maxtec.be\SYSVOL\maxtec.be\Policies\PolicyDefinitions\` et `C:\Windows\PolicyDefinitions\fr-FR\LAPS.adml` dans le sous-dossier `fr-FR` correspondant, puis rouvrez l'éditeur.

    | Paramètre (FR / EN) | Valeur |
    |---------------------|--------|
    | Configurer le répertoire de sauvegarde du mot de passe / *Configure password backup directory* | **Activé**, répertoire de sauvegarde : **Active Directory** |
    | Paramètres du mot de passe / *Password Settings* | **Activé** : complexité « Majuscules + minuscules + chiffres + caractères spéciaux », longueur **14**, âge **30** jours |
    | Nom du compte administrateur à gérer / *Name of administrator account to manage* | **Non configuré** (LAPS gère alors le compte Administrateur intégré, RID 500) |

    Le paramètre « Activer le chiffrement du mot de passe » (*Enable password encryption*) peut rester non configuré dans le lab ; en production, on l'active (niveau fonctionnel 2016 minimum requis). Si le chiffrement est actif, seuls les Admins du domaine (par défaut) peuvent déchiffrer le mot de passe.

    !!! tip "Compte Administrateur désactivé"
        Sur Windows 11, le compte Administrateur intégré est désactivé par défaut. LAPS gère quand même son mot de passe. Si vous voulez tester une connexion avec ce compte, activez-le sur le poste (`net user Administrateur /active:yes`), puis désactivez-le après le test.

    **Étape 4 — sur ws-IT-01, PowerShell administrateur**

    ```powershell
    gpupdate /force
    Invoke-LapsPolicyProcessing
    ```

    Le journal **Observateur d'événements > Journaux des applications et des services > Microsoft > Windows > LAPS > Operational** doit indiquer que le mot de passe a été mis à jour dans Active Directory.

    **Lecture du mot de passe — sur le DC**

    ```powershell
    Get-LapsADPassword -Identity "ws-IT-01" -AsPlainText
    ```

    Vous obtenez `ComputerName`, `Account` (Administrateur), `Password`, `PasswordUpdateTime` et `ExpirationTimestamp`.

    Forcer une rotation immédiate (par exemple après une intervention d'un technicien) :

    ```powershell
    Reset-LapsPassword                      # sur le poste lui-même
    # ou, depuis le DC, avancer l'expiration :
    Set-LapsADPasswordExpirationTime -Identity "ws-IT-01"
    ```

    Avec `Set-LapsADPasswordExpirationTime`, la rotation a lieu au prochain cycle de traitement sur le poste (ou immédiatement après un `Invoke-LapsPolicyProcessing`).

    **Si `Get-LapsADPassword` ne renvoie rien** : vérifiez que le poste est dans la bonne OU (`Get-ADComputer ws-IT-01`), que la GPO s'applique (`gpresult /r /scope computer` sur le poste), et consultez le journal LAPS du poste.

---

## 8. Pratique 5 — Corbeille AD et restauration (20 min)

Sans corbeille, un objet supprimé perd la plupart de ses attributs, dont ses **appartenances aux groupes**. Le recréer avec le même nom ne sert à rien : il aura un **nouveau SID** et ne retrouvera aucune de ses permissions NTFS. La **corbeille AD** (*Recycle Bin*) conserve l'objet complet pendant la durée de vie des objets supprimés (180 jours par défaut).

!!! warning "Activation irréversible"
    Une fois activée, la corbeille ne peut plus être désactivée. C'est sans inconvénient réel, et c'est recommandé partout ; elle exige un niveau fonctionnel de forêt 2008 R2 minimum (votre lab est en 2016 ou 2025).

!!! example "Cahier des charges"
    1. Activer la corbeille sur la forêt `maxtec.be`.
    2. Noter le SID et les groupes de `charles`.
    3. Supprimer `charles`.
    4. Le restaurer et prouver qu'il a **le même SID** et **les mêmes groupes**.

??? success "Solution"

    ```powershell
    # 1. Activer la corbeille
    Enable-ADOptionalFeature -Identity 'Recycle Bin Feature' -Scope ForestOrConfigurationSet -Target 'maxtec.be'
    Get-ADOptionalFeature -Filter "Name -like 'Recycle*'" | Select-Object Name, EnabledScopes

    # 2. État avant suppression
    $sidAvant = (Get-ADUser charles).SID.Value
    $groupesAvant = Get-ADPrincipalGroupMembership charles | Select-Object -ExpandProperty Name
    $sidAvant
    $groupesAvant

    # 3. Suppression
    Remove-ADUser charles -Confirm:$false
    Get-ADUser charles      # erreur : objet introuvable

    # 4. Restauration
    Get-ADObject -Filter "samAccountName -eq 'charles'" -IncludeDeletedObjects | Restore-ADObject

    # Comparaison
    $sidApres = (Get-ADUser charles).SID.Value
    $groupesApres = Get-ADPrincipalGroupMembership charles | Select-Object -ExpandProperty Name
    "SID identique : " + ($sidAvant -eq $sidApres)
    Compare-Object $groupesAvant $groupesApres     # aucune sortie = mêmes groupes
    ```

    `charles` revient dans son OU d'origine (`OU=Users,OU=Comptabilite,OU=EU`), avec son SID, son mot de passe et son appartenance à `GG-EU-Compta-Users`.

    **Équivalent graphique** : `dsac.exe` → `maxtec (local)` → conteneur **Deleted Objects** → clic droit sur l'objet → **Restaurer**.

!!! note "La corbeille ne remplace pas une sauvegarde"
    La corbeille protège contre une suppression d'objet, pas contre une base AD corrompue ou chiffrée. Pour cela, il faut une **sauvegarde de l'état du système** du DC (`wbadmin start systemstatebackup -backuptarget:E:` après installation de la fonctionnalité *Sauvegarde Windows Server*, sur un disque distinct du système), conservée hors ligne. La restauration se fait en démarrant le DC en mode **DSRM** (*Directory Services Restore Mode*) avec le mot de passe défini lors de la promotion : ce mot de passe doit donc être connu et stocké en lieu sûr.

---

## 9. Pratique 6 — Audit avec PingCastle (démonstration formateur, 20 min)

**PingCastle** est un outil d'audit qui analyse un domaine et produit un rapport HTML avec un score de risque et une liste de corrections classées. L'édition gratuite (community) est utilisable pour un audit interne de sa propre organisation ; l'outil appartient à Netwrix depuis 2024. Vérifiez les conditions de licence sur le site de l'éditeur avant tout usage professionnel.

!!! danger "Autorisation écrite obligatoire"
    Dans une entreprise réelle, **ne lancez jamais** un outil d'audit AD (PingCastle, BloodHound, Purple Knight ou autre) sans autorisation écrite du responsable. Ces outils interrogent massivement l'annuaire, déclenchent les alertes de sécurité, et leur exécution non autorisée peut être traitée comme une tentative d'intrusion.

### Déroulé

1. Sur le DC (ou un poste du domaine), copier le dossier PingCastle téléchargé (une carte NAT temporaire est nécessaire pour le téléchargement).
2. Lancer, dans une invite de commandes depuis le dossier :

    ```
    PingCastle.exe --healthcheck --server dns1.maxtec.be
    ```

3. Ouvrir le fichier `ad_hc_maxtec.be.html` généré dans le même dossier.
4. Lire d'abord le **score global**, puis les quatre catégories (*Stale Objects*, *Privileged Accounts*, *Trusts*, *Anomalies*), puis la liste des règles déclenchées avec leur explication et la correction proposée.

### Trois constats typiques sur le lab Maxtec

Selon l'état de votre lab, vous verrez probablement :

| Constat | Explication | Correction |
|---------|-------------|------------|
| **Quota de jonction de machines = 10** (`ms-DS-MachineAccountQuota`) | Par défaut, n'importe quel utilisateur peut joindre 10 ordinateurs au domaine | Mettre le quota à 0 et déléguer la jonction à un groupe dédié |
| **Service Spouleur d'impression actif sur le DC** | Le spouleur a servi de vecteur à plusieurs attaques (PrintNightmare, coercition d'authentification) | `Stop-Service Spooler; Set-Service Spooler -StartupType Disabled` sur les DC |
| **Compte Administrateur utilisé, non protégé** | Le compte intégré sert au quotidien, n'est pas marqué « sensible et ne peut pas être délégué » | Comptes admin nominatifs, compte intégré réservé au secours |

Si vous avez fait les pratiques précédentes, les constats « corbeille non activée » et « LAPS non déployé » doivent avoir disparu ou être partiels (LAPS n'est déployé que sur une OU). C'est le bon moment pour relancer l'analyse et montrer l'évolution du score.

### Alternatives (pour information)

- **Purple Knight** (Semperis) : outil d'évaluation gratuit, rapport similaire, couvre aussi Entra ID.
- **BloodHound Community Edition** (SpecterOps) : cartographie les **chemins d'attaque** (« quel utilisateur peut devenir Domain Admin en combien d'étapes »). Utilisé autant par les défenseurs que par les attaquants, d'où l'importance de l'autorisation écrite.

---

## 10. Checklist : 10 contrôles à vérifier sur n'importe quel AD

À lancer depuis un DC en PowerShell administrateur (`$domSid = (Get-ADDomain).DomainSID.Value` au préalable).

| # | Contrôle | Commande de vérification | Attendu |
|---|----------|--------------------------|---------|
| 1 | Admins du domaine presque vide | `Get-ADGroupMember -Identity "$domSid-512" -Recursive` | 2-3 comptes nominatifs maximum |
| 2 | Groupes Opérateurs vides | `Get-ADGroupMember 'S-1-5-32-548'` (idem 549, 550, 551) | Aucun membre |
| 3 | Mot de passe `krbtgt` renouvelé | `Get-ADUser krbtgt -Properties PasswordLastSet` | Moins de 180 jours |
| 4 | Pas de mots de passe permanents | `Search-ADAccount -PasswordNeverExpires -UsersOnly` | Uniquement des exceptions documentées |
| 5 | Pas de comptes inactifs actifs | `Search-ADAccount -AccountInactive -TimeSpan 90.00:00:00 -UsersOnly` | Désactivés ou supprimés |
| 6 | Comptes à SPN maîtrisés (Kerberoasting) | `Get-ADUser -Filter "ServicePrincipalName -like '*'" -Properties ServicePrincipalName` | `krbtgt` + comptes de service documentés, idéalement des gMSA |
| 7 | Pré-authentification Kerberos exigée | `Get-ADUser -LDAPFilter "(userAccountControl:1.2.840.113556.1.4.803:=4194304)"` | Aucun résultat |
| 8 | Pas de délégation non contrainte hors DC | `Get-ADComputer -Filter 'TrustedForDelegation -eq $true'` | Uniquement les DC |
| 9 | LAPS déployé | `Get-ADComputer -Filter * -Properties 'msLAPS-PasswordExpirationTime'` | Une date pour chaque poste et serveur membre |
| 10 | Corbeille AD activée | `Get-ADOptionalFeature -Filter "Name -like 'Recycle*'"` | `EnabledScopes` non vide |

!!! tip "Et après ?"
    Cette liste couvre les fondamentaux. Les étapes suivantes en entreprise : MFA sur tous les accès d'administration, postes d'administration dédiés (PAW), surveillance des événements de sécurité ([Chapitre 10](Chapitre%2010.Monitoring.md)), audit régulier avec un outil comme PingCastle, et sauvegardes du DC hors ligne testées.

---

## Navigation du cours
[⏮️ Chapitre précédent : Monitoring](Chapitre%2010.Monitoring.md) | [🏠 Retour au syllabus](index.md) | [⏭️ Suivant : Projet final](Labo%20et%20Exercices/Projet_Final.md)
