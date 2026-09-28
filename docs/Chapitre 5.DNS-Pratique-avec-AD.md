# Chapitre 5: DNS en Pratique avec Active Directory

## Navigation du cours
[Chapitre précédent : Active Directory DS](Chapitre%204.Active%20Directory%20Domain%20Services%20(AD%20DS).md) | [Retour au Syllabus](index.md) | [Chapitre suivant : Unités d'Organisation](Chapitre%206.Unites_Organisation.md)

!!! abstract "Objectifs"
    À la fin de ce chapitre, vous savez :

    - retrouver dans le Gestionnaire DNS les enregistrements créés par la promotion (SOA, NS, A, SRV) ;
    - créer des enregistrements A et CNAME et vérifier avec `nslookup` qu'ils se résolvent ;
    - créer la zone inverse `0.168.192.in-addr.arpa` et vérifier avec `nslookup 192.168.0.10` qu'un poste est résolu par son IP ;
    - diagnostiquer trois pannes DNS courantes : DNS du client mal configuré, enregistrement obsolète, PTR absent.

Vous avez installé Active Directory et le domaine **maxtec.be** fonctionne. Ce chapitre met en pratique le DNS sur cette infrastructure.

**Prérequis** : `dns1` promu contrôleur de domaine et `ws-IT-01` joint au domaine ([Chapitre 4 §10](Chapitre%204.Active%20Directory%20Domain%20Services%20(AD%20DS).md#10-laboratoire-joindre-un-poste-au-domaine)).

Adresses utilisées dans ce chapitre (toutes dans `192.168.0.0/24`) :

| Nom | IP | Existe réellement ? |
|-----|----|---------------------|
| `dns1.maxtec.be` | `192.168.0.2` | Oui (DC) |
| `ws-IT-01.maxtec.be` | `192.168.0.10` | Oui (poste client) |
| `ws-RH-01.maxtec.be` | `192.168.0.11` | Optionnel |
| `fileserver.maxtec.be` | `192.168.0.20` | Non : enregistrement d'exercice |
| `webserver.maxtec.be` | `192.168.0.30` | Non : enregistrement d'exercice |
| `printer-01.maxtec.be` | `192.168.0.40` | Non : enregistrement d'exercice |

Les machines d'exercice n'existent pas : `nslookup` doit les résoudre, mais `ping` ne recevra pas de réponse. C'est normal.

---

## Lab 1 : Explorer le DNS créé par Active Directory

### Objectif
Découvrir ce que la promotion en DC et la jonction du poste ont créé dans le DNS.

### Étape 1 : Ouvrir le Gestionnaire DNS

1. **Sur `dns1`**, ouvrez le **Gestionnaire de serveur**
2. Menu **Outils** → **DNS**
3. La console **Gestionnaire DNS** s'ouvre (raccourci : `dnsmgmt.msc` dans Win+R)

### Étape 2 : Explorer la zone maxtec.be

Dans le volet gauche, déroulez :
```
DNS
└── DNS1
    └── Zones de recherche directes
        ├── _msdcs.maxtec.be
        └── maxtec.be   ← cliquez ici
```

### Étape 3 : Identifier les enregistrements

Dans le volet droit, complétez ce tableau :

| Nom | Type | Valeur/Données | À quoi ça sert ? |
|-----|------|----------------|------------------|
| (identique au dossier parent) | SOA | dns1.maxtec.be | **Start of Authority** : paramètres de la zone et serveur de référence |
| (identique au dossier parent) | NS | dns1.maxtec.be | **Name Server** : serveur DNS qui fait autorité sur la zone |
| (identique au dossier parent) | A | 192.168.0.2 | Le nom de domaine `maxtec.be` lui-même pointe vers le DC |
| dns1 | A | 192.168.0.2 | Adresse du contrôleur de domaine |
| ws-IT-01 | A | 192.168.0.10 | Enregistré **par le poste lui-même** après la jonction |
| _msdcs, _sites, _tcp, _udp | (dossiers) | ... | Enregistrements SRV des services AD |
| DomainDnsZones, ForestDnsZones | (dossiers) | ... | Partitions d'application qui stockent les zones DNS |

Si `ws-IT-01` n'apparaît pas, voir le [scénario 3 du Lab 4](#scenario-3-le-poste-nest-pas-resolu-par-son-ip).

### Étape 4 : Explorer les enregistrements SRV

Les enregistrements SRV (Service) permettent aux postes de trouver les contrôleurs de domaine.

1. Déroulez `_tcp` dans la zone `maxtec.be`
2. Double-cliquez sur `_ldap`
3. Observez :

```
Service : _ldap
Protocole : _tcp
Priorité : 0      Poids : 100
Numéro de port : 389
Hôte offrant ce service : dns1.maxtec.be.
```

L'enregistrement que cherche un poste pour joindre le domaine est `_ldap._tcp.dc._msdcs.maxtec.be` (zone `_msdcs.maxtec.be` → `dc` → `_tcp`). Explication au [Chapitre 3 §4](Chapitre%203.DNS.md#4-les-enregistrements-srv-dun-controleur-de-domaine).

### Checkpoint Lab 1

!!! info "Vérification de compréhension"

    - [ ] Où se trouvent les zones DNS ? (Gestionnaire DNS → Zones de recherche directes)
    - [ ] Qu'est-ce qu'un enregistrement SOA ?
    - [ ] Pourquoi les enregistrements SRV sont-ils indispensables à AD ?
    - [ ] Combien d'enregistrements A voyez-vous, et qui les a créés ?

**Test en invite de commandes (sur `ws-IT-01` ou `dns1`) :**
```cmd
nslookup maxtec.be
nslookup -type=SRV _ldap._tcp.dc._msdcs.maxtec.be
```

**En PowerShell** (aperçu, vu au chapitre 9) :

```powershell
Resolve-DnsName -Type SRV _ldap._tcp.dc._msdcs.maxtec.be
```

---

## Lab 2 : Créer des enregistrements manuellement

### Objectif
Ajouter des enregistrements pour des ressources qui ne s'enregistrent pas seules (serveurs à IP fixe hors domaine, imprimantes, alias).

### Exercice 2.1 : Créer un enregistrement A (hôte)

**Scénario :** un serveur de fichiers aura l'IP `192.168.0.20`.

1. **Dans le Gestionnaire DNS**, clic droit sur la zone **maxtec.be**
2. **Nouvel hôte (A ou AAAA)...**
3. Remplissez :
    - Nom : `fileserver`
    - Adresse IP : `192.168.0.20`
    - Laissez **Créer un pointeur (PTR) associé** décoché pour l'instant : la zone inverse n'existe pas encore (Lab 3)
4. Cliquez sur **Ajouter un hôte**

**Vérification :**
```powershell
nslookup fileserver.maxtec.be

# Résultat attendu :
# Nom :    fileserver.maxtec.be
# Address:  192.168.0.20
```

**En PowerShell** (aperçu, vu au chapitre 9 ; sur `dns1`) :

```powershell
Add-DnsServerResourceRecordA -ZoneName "maxtec.be" -Name "fileserver" -IPv4Address "192.168.0.20"
Get-DnsServerResourceRecord -ZoneName "maxtec.be" -Name "fileserver"
```

### Exercice 2.2 : Créer un alias (CNAME)

**Scénario :** `files.maxtec.be` doit pointer vers `fileserver.maxtec.be`.

1. Clic droit sur la zone **maxtec.be** → **Nouvel alias (CNAME)...**
2. Remplissez :
    - Nom de l'alias : `files`
    - Nom de domaine complet (FQDN) de l'hôte de destination : `fileserver.maxtec.be`
3. **OK**

**Vérification :**
```powershell
nslookup files.maxtec.be

# Résultat attendu :
# Nom :    fileserver.maxtec.be
# Address:  192.168.0.20
# Aliases:  files.maxtec.be
```

Avantage d'un CNAME : si `fileserver` change d'IP, vous ne modifiez que l'enregistrement A ; l'alias `files` suit.

**En PowerShell** (aperçu, vu au chapitre 9) :

```powershell
Add-DnsServerResourceRecordCName -ZoneName "maxtec.be" -Name "files" -HostNameAlias "fileserver.maxtec.be"
```

### Exercice 2.3 : Alias web et imprimante

**Mission :**

1. Créez un CNAME `www` qui pointe vers `fileserver.maxtec.be` (en attendant un vrai serveur web).
2. Créez un enregistrement A `printer-01` → `192.168.0.40`.

??? success "Solution"
    1. Clic droit sur la zone **maxtec.be** → **Nouvel alias (CNAME)** → Nom : `www`, FQDN cible : `fileserver.maxtec.be` → **OK**
    2. Clic droit sur la zone **maxtec.be** → **Nouvel hôte (A ou AAAA)** → Nom : `printer-01`, IP : `192.168.0.40` → **Ajouter un hôte**

    Vérification :
    ```powershell
    nslookup www.maxtec.be         # -> fileserver.maxtec.be, 192.168.0.20
    nslookup printer-01.maxtec.be  # -> 192.168.0.40
    ```


### Checkpoint Lab 2

!!! info "Vérification"

    - [ ] Enregistrement A : `fileserver.maxtec.be` → `192.168.0.20`
    - [ ] Alias CNAME : `files.maxtec.be` → `fileserver.maxtec.be`
    - [ ] Alias CNAME : `www.maxtec.be` → `fileserver.maxtec.be`
    - [ ] Enregistrement A : `printer-01.maxtec.be` → `192.168.0.40`
    - [ ] Tous se résolvent avec `nslookup`

---

## Lab 3 : Configurer une zone de recherche inverse

### Objectif
Permettre la résolution IP → nom. La promotion en DC **ne crée pas** cette zone : c'est à vous de le faire.

### Pourquoi une zone inverse ?

- **Résolution directe :** `ws-IT-01.maxtec.be` → `192.168.0.10`
- **Résolution inverse :** `192.168.0.10` → `ws-IT-01.maxtec.be`

Utilisations :

- **Dépannage et journaux** : un journal qui affiche des noms plutôt que des IP est plus lisible
- **Outils** : `nslookup` affiche « Serveur : UnKnown » quand le serveur DNS lui-même n'a pas de PTR
- **Messagerie** : les serveurs mail vérifient la résolution inverse des expéditeurs (anti-spam)

### Étape 1 : Créer la zone inverse

1. **Dans le Gestionnaire DNS**, clic droit sur **Zones de recherche inversée** → **Nouvelle zone...**
2. Assistant :
    - Type : **Zone principale**, cochez **Enregistrer la zone dans Active Directory**
    - Étendue de réplication : **Vers tous les serveurs DNS exécutés sur des contrôleurs de domaine dans ce domaine**
    - **Zone de recherche inversée IPv4**
    - ID réseau : `192.168.0` (sans le dernier octet)
    - Mises à jour dynamiques : **N'autoriser que les mises à jour dynamiques sécurisées**
3. **Terminer**

**En PowerShell** (aperçu, vu au chapitre 9) :

```powershell
Add-DnsServerPrimaryZone -NetworkId "192.168.0.0/24" -ReplicationScope "Domain" -DynamicUpdate "Secure"
```

### Étape 2 : Vérifier la zone créée

Dans **Zones de recherche inversée**, vous voyez `0.168.192.in-addr.arpa`. L'ordre des octets est inversé : c'est la convention DNS (du plus spécifique au plus général, comme dans un nom).

### Étape 3 : Remplir la zone

La zone est vide au départ. Les machines du domaine enregistrent leur PTR elles-mêmes lors de leur prochain enregistrement dynamique ; forcez-le :

```powershell
# Sur dns1, puis sur ws-IT-01
ipconfig /registerdns
```

Actualisez la zone (F5) après une ou deux minutes : `2` → `dns1.maxtec.be` et `10` → `ws-IT-01.maxtec.be` doivent apparaître.

### Étape 4 : Tester la résolution inverse

```powershell
nslookup 192.168.0.2
# Nom :    dns1.maxtec.be
# Address:  192.168.0.2

nslookup 192.168.0.10
# Nom :    ws-IT-01.maxtec.be
# Address:  192.168.0.10
```

### Étape 5 : Ajouter un PTR manuellement

Les enregistrements d'exercice (`fileserver`) ne s'enregistrent pas seuls. Deux méthodes :

- **Clic droit** sur `0.168.192.in-addr.arpa` → **Nouveau pointeur (PTR)...** → Adresse IP : `192.168.0.20`, Nom d'hôte : `fileserver.maxtec.be` → **OK**
- Ou modifiez l'enregistrement A `fileserver` et cochez **Mettre à jour l'enregistrement de pointeur (PTR) associé**

Vérification : `nslookup 192.168.0.20` → `fileserver.maxtec.be`.

### Checkpoint Lab 3

!!! info "Vérification"

    - [ ] Zone inverse créée : `0.168.192.in-addr.arpa`
    - [ ] `nslookup 192.168.0.2` retourne `dns1.maxtec.be`
    - [ ] `nslookup 192.168.0.10` retourne `ws-IT-01.maxtec.be`
    - [ ] `nslookup 192.168.0.20` retourne `fileserver.maxtec.be`

---

## Lab 4 : Dépannage DNS

### Objectif
Diagnostiquer trois pannes courantes à partir de leurs symptômes. Pour chaque scénario, préparez la panne (ou demandez à un collègue de la préparer sans vous dire laquelle), diagnostiquez, puis comparez avec la solution.

**Commandes de diagnostic :**

| Commande | Usage |
|----------|-------|
| `ipconfig /all` | Configuration IP et DNS du poste |
| `nslookup nom` | Résoudre un nom |
| `nslookup IP` | Résolution inverse |
| `nslookup -type=SRV _ldap._tcp.dc._msdcs.maxtec.be` | Le poste trouve-t-il un DC ? |
| `nltest /dsgetdc:maxtec.be` | Quel DC Windows utiliserait |
| `ipconfig /flushdns` | Vider le cache DNS du poste |
| `ipconfig /registerdns` | Forcer l'enregistrement dynamique du poste |
| Gestionnaire DNS (`dnsmgmt.msc`) → zone `maxtec.be` | Voir les enregistrements côté serveur (en PowerShell, chapitre 9 : `Get-DnsServerResourceRecord`) |

### Scénario 1 : le poste ne peut pas rejoindre le domaine

**Préparation :** sur `ws-IT-01` (ou `ws-RH-01`), réglez le DNS préféré sur `8.8.8.8` : Win+R → `ncpa.cpl` → clic droit sur la carte **Ethernet** → **Propriétés** → **Protocole Internet version 4 (TCP/IPv4)** → **Propriétés** → **Serveur DNS préféré** : `8.8.8.8` → **OK**.

**Symptôme :** `nltest /dsgetdc:maxtec.be` et `gpupdate /force` échouent. Sur un poste pas encore joint, la jonction échouerait avec « Un contrôleur de domaine Active Directory (AD DC) pour le domaine maxtec.be n'a pas pu être contacté ». Pourtant `ping 192.168.0.2` répond.

??? success "Diagnostic et solution"
    **Diagnostic :**

    ```powershell
    ipconfig /all
    # Serveurs DNS . . . : 8.8.8.8   ← le problème

    nslookup -type=SRV _ldap._tcp.dc._msdcs.maxtec.be
    # Échec : 8.8.8.8 ne connaît pas la zone interne maxtec.be
    ```

    Le réseau fonctionne (le ping répond), mais le poste demande à un DNS public où se trouve le DC. Seul `dns1` connaît les enregistrements SRV de `maxtec.be`.

    **Solution :** remettez le DNS du poste sur le DC.

    1. Win+R → `ncpa.cpl` → clic droit sur la carte **Ethernet** → **Propriétés**.
    2. **Protocole Internet version 4 (TCP/IPv4)** → **Propriétés**.
    3. **Serveur DNS préféré** : `192.168.0.2` → **OK** → **Fermer**.
    4. En invite de commandes : `ipconfig /flushdns`, puis `nslookup -type=SRV _ldap._tcp.dc._msdcs.maxtec.be`, qui doit maintenant renvoyer `dns1.maxtec.be`.

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 192.168.0.2
    ipconfig /flushdns
    nslookup -type=SRV _ldap._tcp.dc._msdcs.maxtec.be   # doit maintenant renvoyer dns1.maxtec.be
    ```

    Puis relancez la jonction. Règle : un poste du domaine n'utilise **que** les DC comme serveurs DNS ; l'accès Internet passe par les redirecteurs du DC ([Chapitre 3 §5](Chapitre%203.DNS.md#5-les-redirecteurs-forwarders)).

### Scénario 2 : un enregistrement obsolète

**Préparation :** sur `dns1`, le serveur de fichiers a « déménagé » de `192.168.0.20` vers `192.168.0.21`. Quelqu'un a ajouté le nouvel enregistrement A `fileserver` → `192.168.0.21` sans supprimer l'ancien.

Pour le reproduire : Gestionnaire DNS → clic droit sur la zone **maxtec.be** → **Nouvel hôte (A ou AAAA)…** → Nom : `fileserver`, Adresse IP : `192.168.0.21` → **Ajouter un hôte**. L'ancien enregistrement `192.168.0.20` reste en place.

**En PowerShell** (aperçu, vu au chapitre 9) :

```powershell
Add-DnsServerResourceRecordA -ZoneName "maxtec.be" -Name "fileserver" -IPv4Address "192.168.0.21"
```

**Symptôme :** les utilisateurs se plaignent que `\\fileserver` fonctionne « une fois sur deux ».

??? success "Diagnostic et solution"
    **Diagnostic :**

    ```powershell
    nslookup fileserver.maxtec.be
    # Addresses:  192.168.0.20
    #             192.168.0.21   ← deux réponses pour un seul serveur
    ```

    Côté serveur, dans le Gestionnaire DNS, zone **maxtec.be** : deux lignes `fileserver` de type **Hôte (A)**, une par adresse.

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    Get-DnsServerResourceRecord -ZoneName "maxtec.be" -Name "fileserver"
    ```

    Le DNS renvoie les deux adresses (en alternance, « round robin »). Les clients qui tombent sur l'ancienne IP échouent.

    **Solution :** supprimez l'enregistrement obsolète sur `dns1`, puis videz le cache des clients.

    1. Gestionnaire DNS → zone **maxtec.be** → clic droit sur la ligne `fileserver` dont les données sont `192.168.0.20` → **Supprimer** → **Oui**.
    2. Sur le poste client, en invite de commandes : `ipconfig /flushdns`, puis `nslookup fileserver.maxtec.be` ne doit plus renvoyer que `192.168.0.21`.

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    Remove-DnsServerResourceRecord -ZoneName "maxtec.be" -RRType "A" -Name "fileserver" -RecordData "192.168.0.20" -Force
    ipconfig /flushdns   # sur le poste client
    ```

    Pensez aussi au PTR : `192.168.0.20` pointe encore vers `fileserver` dans la zone inverse ; supprimez-le (Gestionnaire DNS → **Zones de recherche inversée** → `0.168.192.in-addr.arpa` → clic droit sur l'enregistrement `20` (pointeur vers `fileserver.maxtec.be`) → **Supprimer**).

    Pour les machines du domaine qui s'enregistrent seules, les enregistrements dynamiques obsolètes (poste supprimé, IP changée) se nettoient automatiquement si le **vieillissement et nettoyage** (aging/scavenging) est activé : il faut à la fois le **vieillissement sur la zone** (Gestionnaire DNS → clic droit sur **DNS1** → **Définir le vieillissement/nettoyage pour toutes les zones**) et le **nettoyage automatique sur le serveur** (clic droit sur **DNS1** → **Propriétés** → onglet **Avancé** → **Activer le nettoyage automatique des enregistrements obsolètes**). Les deux sont désactivés par défaut.

### Scénario 3 : le poste n'est pas résolu par son IP

**Préparation :** sur `dns1`, supprimez le PTR de `ws-IT-01` (`10` dans `0.168.192.in-addr.arpa`).

**Symptôme :** `nslookup 192.168.0.10` répond « Non-existent domain ». Un outil de supervision affiche l'IP au lieu du nom du poste.

??? success "Diagnostic et solution"
    **Diagnostic :**

    ```powershell
    nslookup ws-IT-01.maxtec.be   # fonctionne : l'enregistrement A existe
    nslookup 192.168.0.10         # échoue : pas de PTR
    ```

    Vérifiez d'abord que la zone `0.168.192.in-addr.arpa` existe (si elle n'existe pas, aucune résolution inverse ne fonctionne : Lab 3). Si elle existe, seul le PTR du poste manque. Cas fréquent : le poste a été joint **avant** la création de la zone inverse.

    **Solution :** sur `ws-IT-01`, forcez le réenregistrement dynamique (A et PTR) :

    ```powershell
    ipconfig /registerdns
    ```

    Attendez une minute, puis `nslookup 192.168.0.10` sur n'importe quelle machine. Si le PTR ne revient pas, vérifiez dans les propriétés IPv4 avancées de la carte (onglet **DNS**) que **Enregistrer les adresses de cette connexion dans le système DNS** est cochée, ou créez le PTR manuellement.

### Checkpoint Lab 4

!!! info "Vérification"

    - [ ] Vous savez vérifier la configuration DNS d'un poste (`ipconfig /all`)
    - [ ] Vous savez tester qu'un poste trouve un DC (`nslookup -type=SRV`, `nltest /dsgetdc`)
    - [ ] Vous savez repérer et supprimer un enregistrement obsolète
    - [ ] Vous savez pourquoi un PTR peut manquer et comment le recréer

Nettoyage : pour revenir aux valeurs de référence, remplacez `fileserver` → `192.168.0.21` par `fileserver` → `192.168.0.20` (enregistrement A et PTR), sinon `files` et `www` pointent vers une adresse qui n'est plus celle du cours. Remettez le DNS du poste de test sur `192.168.0.2`.

---

## Récapitulatif

### Types d'enregistrements DNS

| Type | Nom complet | Usage | Exemple du chapitre |
|------|-------------|-------|---------------------------|
| **A** | Address | Nom → IPv4 | `fileserver.maxtec.be` → `192.168.0.20` |
| **CNAME** | Canonical Name | Alias | `www` → `fileserver` |
| **PTR** | Pointer | IP → Nom (inverse) | `192.168.0.2` → `dns1.maxtec.be` |
| **SRV** | Service | Localisation d'un service | `_ldap._tcp.dc._msdcs.maxtec.be` → `dns1:389` |
| **NS** | Name Server | Serveur DNS qui fait autorité | `maxtec.be` → `dns1.maxtec.be` |
| **SOA** | Start of Authority | Paramètres de la zone | Numéro de série, serveur principal |

### Ce qui se passe quand un poste rejoint le domaine

1. Le **poste** demande au DNS : « où est un contrôleur de domaine pour maxtec.be ? » (requête SRV `_ldap._tcp.dc._msdcs.maxtec.be`)
2. Le **DNS** répond : `dns1.maxtec.be`, port 389, puis donne l'IP `192.168.0.2`
3. Le **poste** contacte le DC (LDAP, Kerberos) avec les identifiants d'un compte autorisé
4. Le **DC** crée le compte ordinateur dans AD (conteneur `CN=Computers`)
5. Après redémarrage, le **poste** enregistre lui-même son nom dans DNS (mise à jour dynamique sécurisée) : `ws-IT-01.maxtec.be` → `192.168.0.10`

Vous avez observé le résultat de ce processus au Lab 1.

### Architecture DNS-AD intégrée

```
┌──────────────────────────────────────┐
│   Active Directory (maxtec.be)       │
│                                      │
│   ┌──────────────────────────────┐   │
│   │   DNS intégré à AD           │   │
│   │   • Zones stockées dans AD   │   │
│   │   • Enregistrements SRV      │   │
│   │   • Mises à jour dynamiques  │   │
│   │     sécurisées               │   │
│   └──────────────────────────────┘   │
│                  ↑                   │
│   ┌──────────────────────────────┐   │
│   │ Les postes du domaine        │   │
│   │ s'enregistrent eux-mêmes     │   │
│   └──────────────────────────────┘   │
└──────────────────────────────────────┘
```

---

## Exercice final

### Mission

Maxtec installe un serveur web. Exigences :

1. Le serveur s'appelle `webserver`, IP `192.168.0.30`
2. Les utilisateurs y accèdent via `www.maxtec.be`
3. Les admins y accèdent via `webadmin.maxtec.be`
4. La résolution inverse fonctionne pour l'IP du serveur

Attention : `www` existe déjà (exercice 2.3) et pointe vers `fileserver`.

??? success "Solution"
    **Étape 1 : enregistrement A avec PTR**

    Gestionnaire DNS → `maxtec.be` → clic droit → **Nouvel hôte** : Nom `webserver`, IP `192.168.0.30`, cochez **Créer un pointeur (PTR) associé** (la zone inverse existe maintenant).

    **Étape 2 : alias**

    - `www` existe déjà : double-cliquez dessus et remplacez la cible par `webserver.maxtec.be` (ou supprimez-le et recréez-le). Deux CNAME du même nom ne peuvent pas coexister.
    - Nouvel alias : clic droit sur `maxtec.be` → **Nouvel alias (CNAME)…** → Nom `webadmin`, cible `webserver.maxtec.be` → **OK**

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    Add-DnsServerResourceRecordA -ZoneName "maxtec.be" -Name "webserver" -IPv4Address "192.168.0.30" -CreatePtr
    Remove-DnsServerResourceRecord -ZoneName "maxtec.be" -RRType "CName" -Name "www" -Force
    Add-DnsServerResourceRecordCName -ZoneName "maxtec.be" -Name "www" -HostNameAlias "webserver.maxtec.be"
    Add-DnsServerResourceRecordCName -ZoneName "maxtec.be" -Name "webadmin" -HostNameAlias "webserver.maxtec.be"
    ```

    **Étape 3 : vérifier**
    ```powershell
    ipconfig /flushdns             # sur le poste : l'ancien www est peut-être en cache
    nslookup webserver.maxtec.be   # -> 192.168.0.30
    nslookup www.maxtec.be         # -> webserver.maxtec.be -> 192.168.0.30
    nslookup webadmin.maxtec.be    # -> webserver.maxtec.be -> 192.168.0.30
    nslookup 192.168.0.30          # -> webserver.maxtec.be
    ```


### Validation finale

!!! info "Vérification finale"

    - [ ] Enregistrement A créé pour `webserver`
    - [ ] `www.maxtec.be` pointe vers `webserver`
    - [ ] `webadmin.maxtec.be` fonctionne
    - [ ] La résolution inverse de `192.168.0.30` fonctionne

---

## Compétences acquises

Vous savez maintenant :

- gérer le DNS d'un domaine Active Directory ;
- créer et maintenir des enregistrements A, CNAME et PTR, en GUI et en PowerShell ;
- diagnostiquer les problèmes de résolution les plus courants.

### Pour aller plus loin

La [Référence DNS - Concepts avancés](Théorie%20DNS-%20DNS%20Concepts%20Avances%20(Reference).md) couvre :

- la résolution récursive et itérative ;
- la délégation DNS ;
- les zones secondaires ;
- les enregistrements spécialisés (MX, TXT).

---

## Navigation
[Chapitre 4 : Active Directory DS](Chapitre%204.Active%20Directory%20Domain%20Services%20(AD%20DS).md) | [Retour au Syllabus](index.md) | [Chapitre 6 : Unités d'Organisation](Chapitre%206.Unites_Organisation.md)
