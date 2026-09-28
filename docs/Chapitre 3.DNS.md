# Chapitre 3: DNS - Préparation pour Active Directory

## Navigation du cours
[Chapitre précédent : Installation VirtualBox](Chapitre%202.Installation-Windows-Server-2022-VirtualBox.md) | [Retour au Syllabus](index.md) | [Chapitre suivant : Active Directory](Chapitre%204.Active%20Directory%20Domain%20Services%20(AD%20DS).md)

!!! abstract "Objectifs"
    À la fin de ce chapitre, vous savez :

    - expliquer pourquoi un poste ne trouve pas le contrôleur de domaine sans DNS (enregistrements SRV) ;
    - configurer le DNS du serveur sur `192.168.0.2` et le vérifier avec `ipconfig /all` ;
    - dire ce que la promotion en DC crée automatiquement dans le DNS, et ce qu'elle ne crée pas (zone inverse) ;
    - interroger un enregistrement SRV avec `nslookup -type=SRV` ou `Resolve-DnsName`, et configurer un redirecteur.

!!! tip "Pratique DNS"
    Ce chapitre couvre l'essentiel (15 min de lecture). La pratique (créer des enregistrements, zone inverse, dépannage) est au **[Chapitre 5 - DNS Pratique avec AD](Chapitre%205.DNS-Pratique-avec-AD.md)**, après l'installation d'AD. La théorie approfondie est dans la [référence DNS](Théorie%20DNS-%20DNS%20Concepts%20Avances%20(Reference).md).

---

## 1. DNS - L'essentiel

### Qu'est-ce que le DNS ?

**DNS = l'annuaire téléphonique du réseau** : il traduit un nom en adresse IP.

```
Vous tapez : www.google.com
DNS traduit : 142.250.179.174
```

Sans DNS, il faudrait mémoriser `142.250.179.174` pour Google, `151.101.1.140` pour Reddit, etc.

### Pourquoi Active Directory a besoin du DNS

Active Directory utilise les **noms DNS** pour tout localiser.

| Ce qu'AD doit faire | Comment DNS aide |
|---------------------|------------------|
| Trouver les contrôleurs de domaine | Enregistrement SRV `_ldap._tcp.dc._msdcs.maxtec.be` → `dns1.maxtec.be` → `192.168.0.2` |
| Authentifier les utilisateurs | Enregistrement SRV `_kerberos._tcp.maxtec.be` → serveur Kerberos |
| Joindre des postes au domaine | Le poste localise un DC, puis enregistre son propre nom (`ws-IT-01.maxtec.be`) |
| Appliquer les stratégies de groupe | Le poste localise un DC pour lire les GPO dans `SYSVOL` |

**Sans DNS fonctionnel, Active Directory ne fonctionne pas.** Un poste dont le DNS pointe vers `8.8.8.8` ne trouvera jamais `maxtec.be`.

Quand vous promouvrez le serveur en contrôleur de domaine (Chapitre 4), l'assistant installe et configure le rôle DNS.

### Si vous venez de Linux

| Linux | Windows |
|-------|---------|
| `/etc/resolv.conf` → `nameserver` | Propriétés IPv4 de la carte → « Serveur DNS préféré » ; `Get-DnsClientServerAddress` / `Set-DnsClientServerAddress` |
| `/etc/resolv.conf` → `search` | Suffixe DNS principal (`maxtec.be`) et liste de suffixes ; `Get-DnsClientGlobalSetting` |
| `/etc/hosts` | `C:\Windows\System32\drivers\etc\hosts` |
| `dig`, `host` | `nslookup` (partout) et `Resolve-DnsName` (PowerShell, plus proche de `dig`) |
| `resolvectl flush-caches` | `ipconfig /flushdns` ou `Clear-DnsClientCache` |
| Cache : `resolvectl statistics` | `ipconfig /displaydns` ou `Get-DnsClientCache` |
| BIND : fichiers de zone | Zones **intégrées à AD** : stockées dans la base AD et répliquées entre DC, pas dans des fichiers |

```powershell
# Équivalent de "dig maxtec.be"
Resolve-DnsName maxtec.be

# Équivalent de "dig @192.168.0.2 dns1.maxtec.be"
Resolve-DnsName dns1.maxtec.be -Server 192.168.0.2
```

---

## 2. Vérification avant l'installation d'AD

#### Configuration réseau du serveur

Si vous avez suivi le Chapitre 1 ou 2, c'est déjà fait. Sinon :

1. `ncpa.cpl` (Win+R) → clic droit sur la carte réseau (la seule) → **Propriétés**
2. **Protocole Internet version 4 (TCP/IPv4)** → **Propriétés**
3. Configurez :

    | Paramètre | Valeur | Explication |
    |-----------|--------|-------------|
    | Adresse IP | `192.168.0.2` | IP fixe du serveur |
    | Masque | `255.255.255.0` | Réseau `192.168.0.0/24` |
    | Passerelle | *(vide)* | Pas nécessaire sur le réseau interne |
    | **DNS préféré** | `192.168.0.2` | **Le serveur s'utilise lui-même** : il hébergera le DNS du domaine |
    | DNS auxiliaire | *(vide)* | Avec un deuxième DC, on y mettrait son adresse |

    `127.0.0.1` (localhost) fonctionne aussi comme DNS préféré ; le lab utilise `192.168.0.2` partout pour rester cohérent.

4. Validez et fermez

### Test

```powershell
ipconfig /all

# Cherchez dans le résultat :
#   Adresse IPv4 . . . . . : 192.168.0.2
#   Serveurs DNS . . . . . : 192.168.0.2
#   Suffixe DNS principal  : maxtec.be
```

Si une de ces valeurs est différente, corrigez-la avant d'installer AD DS.

!!! tip "Guide rapide"

    Toutes les étapes pratiques (configuration réseau, installation AD DS, promotion en DC et intégration du poste client) sont regroupées dans le **[Guide rapide - Installation AD-DS](Labo%20Annexe%201-Guide%20de%20base%20installation%20AD-DS.md)**.

## 3. Ce que la promotion en DC fait dans le DNS

Quand vous promouvrez le serveur (Chapitre 4) :

1. **Installation du rôle DNS**
    - L'assistant installe le rôle DNS sur `dns1`
    - Il crée la zone de recherche directe `maxtec.be`, intégrée à AD, et la zone `_msdcs.maxtec.be`

2. **Enregistrements créés automatiquement**
    - Enregistrement A pour `dns1.maxtec.be` → `192.168.0.2`
    - Enregistrements SRV (LDAP, Kerberos, catalogue global…) publiés par le service **Netlogon** du DC

3. **Ce qui n'est pas créé**
    - **La zone de recherche inverse** (`0.168.192.in-addr.arpa`) n'est pas créée par la promotion. Vous la créerez vous-même au Chapitre 5.

4. **Mises à jour dynamiques**
    - Quand un poste rejoint le domaine, **il enregistre lui-même** son nom (enregistrement A) dans la zone `maxtec.be`, de manière sécurisée.
    - Les **utilisateurs** ne sont **pas** dans le DNS : créer un utilisateur dans AD ne modifie pas le DNS. Le DNS contient des noms de machines et de services, pas des personnes.

!!! note "Avertissement de délégation pendant la promotion"
    L'assistant affiche « Impossible de créer une délégation pour ce serveur DNS… ». C'est attendu : il n'existe pas de zone parente `be` que nous contrôlons. Cliquez sur **Suivant**.

## 4. Les enregistrements SRV d'un contrôleur de domaine

Un enregistrement **SRV** répond à la question « quel serveur fournit tel service, sur quel port ? ». C'est ainsi qu'un poste trouve un DC sans connaître son nom à l'avance.

| Enregistrement | Service | Port |
|----------------|---------|------|
| `_ldap._tcp.dc._msdcs.maxtec.be` | Contrôleurs de domaine du domaine (c'est celui que les postes cherchent) | 389 |
| `_kerberos._tcp.maxtec.be` | Authentification Kerberos | 88 |
| `_gc._tcp.maxtec.be` | Catalogue global | 3268 |
| `_kpasswd._tcp.maxtec.be` | Changement de mot de passe Kerberos | 464 |

Après la promotion, vérifiez-les depuis le serveur ou un poste client :

```powershell
# Invite de commandes ou PowerShell
nslookup -type=SRV _ldap._tcp.dc._msdcs.maxtec.be
nslookup -type=SRV _kerberos._tcp.maxtec.be

# PowerShell
Resolve-DnsName -Type SRV _ldap._tcp.dc._msdcs.maxtec.be

# Demander à Windows quel DC il utiliserait
nltest /dsgetdc:maxtec.be
```

Résultat attendu (extrait) :

```
_ldap._tcp.dc._msdcs.maxtec.be   SRV service location:
          priority       = 0
          weight         = 100
          port           = 389
          svr hostname   = dns1.maxtec.be
```

Si ces enregistrements manquent, redémarrez le service Netlogon sur le DC (`Restart-Service Netlogon`) : il les réenregistre.

## 5. Les redirecteurs (forwarders)

`dns1` a l'autorité sur `maxtec.be`. Pour les autres noms (`www.google.com`), il doit demander ailleurs :

- **Sans redirecteur**, il interroge lui-même les serveurs racine d'Internet (« indications de racine »).
- **Avec un redirecteur**, il transmet la question à un autre résolveur (celui du fournisseur d'accès, `1.1.1.1`, `8.8.8.8`…) qui fait le travail.

La règle en entreprise : **les postes interrogent uniquement le DC**, et c'est le DC qui redirige vers l'extérieur. On ne met jamais `8.8.8.8` comme DNS d'un poste du domaine.

**Configuration (GUI)** : Gestionnaire DNS → clic droit sur **DNS1** → **Propriétés** → onglet **Redirecteurs** → **Modifier** → ajoutez l'adresse.

**Configuration (PowerShell)** :

```powershell
Add-DnsServerForwarder -IPAddress 1.1.1.1
Get-DnsServerForwarder
```

!!! note "Dans le lab"
    Le réseau interne n'a pas d'accès Internet : un redirecteur n'y sert à rien, sauf pendant qu'une carte NAT temporaire est branchée. Retenez surtout le principe et l'emplacement du réglage.


---
