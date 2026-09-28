# Chapitre 3: DNS - Préparation pour Active Directory

## Navigation du cours
[Chapitre précédent : Installation VirtualBox](Chapitre%202.Installation-Windows-Server-2022-VirtualBox.md) | [Retour au Syllabus](index.md) | [Chapitre suivant : Active Directory](Chapitre%204.Active%20Directory%20Domain%20Services%20(AD%20DS).md)

!!! abstract "Objectifs"
    À la fin de ce chapitre, vous savez :

    - expliquer pourquoi un poste ne trouve pas le contrôleur de domaine sans DNS (enregistrements SRV) ;
    - configurer le DNS du serveur sur `192.168.0.2` et le vérifier avec `ipconfig /all` ;
    - dire ce que la promotion en DC crée automatiquement dans le DNS, et ce qu'elle ne crée pas (zone inverse) ;
    - retrouver les enregistrements SRV dans le Gestionnaire DNS et les interroger avec `nslookup -type=SRV`, et configurer un redirecteur.

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

Un poste du domaine ne connaît pas l'adresse du contrôleur de domaine (DC) : personne ne la lui a donnée. À chaque démarrage et à chaque ouverture de session, il la **demande au DNS**.

Le DNS que vous connaissez répond à « quelle est l'adresse de `www.google.com` ? ». C'est un enregistrement **A** : un nom → une adresse, comme les pages blanches de l'annuaire. Active Directory ajoute un autre type de question : « **qui**, dans `maxtec.be`, fournit tel service ? ». C'est un enregistrement **SRV**, l'équivalent des pages jaunes : on cherche un métier, pas une personne. Le DC inscrit lui-même ces fiches SRV dans le DNS au moment où il devient contrôleur de domaine.

Exemple : Ivan allume `ws-IT-01` et ouvre sa session. Voici ce que le poste demande au DNS, dans l'ordre :

| Moment | La question du poste | La réponse du DNS | Ce qui se passe si le DNS ne répond pas |
|--------|----------------------|-------------------|------------------------------------------|
| Démarrage du poste | « Où est un contrôleur de domaine pour `maxtec.be` ? » | « C'est `dns1`, à l'adresse `192.168.0.2`. » | Le poste ne trouve pas le domaine. Message typique : *« Le domaine spécifié n'existe pas ou n'a pas pu être contacté »*. |
| Ivan tape son mot de passe | « Qui vérifie les mots de passe (Kerberos) ? » | « Encore `dns1`. » | Le mot de passe ne peut pas être vérifié. Ivan ne peut pas se connecter, ou seulement avec un ancien profil en cache. |
| Juste après la connexion | « Où lire les règles (GPO) à appliquer ? » | « Dans le dossier partagé `SYSVOL` de `dns1`. » | Les GPO ne s'appliquent pas : pas de lecteur réseau, pas de fond d'écran imposé, sans message d'erreur visible. |
| Jonction au domaine (une seule fois) | « Où est le DC ? », puis « Enregistre mon nom, s'il te plaît. » | Le DNS ajoute `ws-IT-01.maxtec.be` → adresse du poste. | Impossible de joindre le poste au domaine. |

Les noms techniques de ces fiches SRV, et comment les vérifier, sont à la [section 4](#4-les-enregistrements-srv-dun-controleur-de-domaine).

**Sans DNS fonctionnel, Active Directory ne fonctionne pas.** Un poste dont le DNS pointe vers `8.8.8.8` interroge Google, qui ne connaît pas `maxtec.be` : aucune des questions du tableau n'obtient de réponse. C'est la panne AD la plus fréquente, et la première chose à vérifier (`ipconfig /all`, ligne « Serveurs DNS »).

Quand vous promouvrez le serveur en contrôleur de domaine (Chapitre 4), l'assistant installe et configure le rôle DNS.

??? info "Si vous connaissez Linux"
    Trois repères suffisent :

    1. **Où l'on règle le serveur DNS de la machine.** Sous Linux, c'est un fichier texte (`/etc/resolv.conf`). Sous Windows, c'est dans les propriétés de la carte réseau, champ « Serveur DNS préféré » (`ncpa.cpl`).
    2. **Le fichier `hosts` existe dans les deux systèmes.** Sous Windows, il se trouve dans `C:\Windows\System32\drivers\etc\hosts`. Dans les deux cas, il est consulté avant le DNS : une ligne oubliée dedans peut fausser une résolution.
    3. **`nslookup` existe sur les deux.** C'est l'outil que nous utiliserons pour interroger un serveur DNS et vérifier une réponse.

    Une différence importante : dans Active Directory, les zones DNS ne sont pas stockées dans des fichiers texte, mais dans la base AD elle-même, qui est répliquée automatiquement entre les contrôleurs de domaine.

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

Un enregistrement **SRV** répond à la question « quel serveur fournit tel service, sur quel port ? ». C'est ainsi qu'un poste trouve un DC sans connaître son nom à l'avance (les « pages jaunes » de la [section 1](#pourquoi-active-directory-a-besoin-du-dns)).

Le nom d'un SRV se lit de gauche à droite : **le service**, puis **le protocole**, puis **le domaine**. `_kerberos._tcp.maxtec.be` veut dire « le service Kerberos, en TCP, pour `maxtec.be` ». La réponse contient le nom du serveur et le port à contacter.

| Enregistrement | En clair | Quand le poste s'en sert | Port |
|----------------|----------|--------------------------|------|
| `_ldap._tcp.dc._msdcs.maxtec.be` | « Liste des contrôleurs de domaine de `maxtec.be` » | Au démarrage de `ws-IT-01`, à la jonction au domaine, et chaque fois qu'il doit retrouver un DC. **C'est le plus important** : s'il manque, rien d'autre ne fonctionne. | 389 |
| `_kerberos._tcp.maxtec.be` | « Qui vérifie les mots de passe » | Quand Ivan tape son mot de passe à l'ouverture de session, puis quand il ouvre un partage réseau (le poste demande un ticket Kerberos). | 88 |
| `_gc._tcp.maxtec.be` | « Qui a l'annuaire de toute la forêt » (catalogue global) | Pour les recherches dans l'annuaire (par exemple chercher un collègue dans Outlook). À l'ouverture de session, c'est le DC lui-même qui le consulte pour compléter la liste des groupes d'Ivan. Avec un seul domaine comme Maxtec, c'est simplement `dns1` ; il devient utile quand une entreprise a plusieurs domaines. | 3268 |
| `_kpasswd._tcp.maxtec.be` | « Qui accepte les changements de mot de passe » | Quand Ivan change son mot de passe : Ctrl+Alt+Suppr → **Modifier un mot de passe**, ou à la première connexion si « L'utilisateur doit changer le mot de passe » est coché. | 464 |

Dans le lab, les quatre réponses désignent le même serveur : `dns1`. Dans une entreprise avec plusieurs DC, chaque SRV en liste plusieurs, et le poste choisit de préférence un DC proche (même site).

Après la promotion, vérifiez-les de deux façons.

**Dans le Gestionnaire DNS** (sur `dns1`) :

1. Gestionnaire de serveur → **Outils** → **DNS** (ou Win+R → `dnsmgmt.msc`).
2. Dépliez **DNS1** → **Zones de recherche directes** → **_msdcs.maxtec.be** → **dc** → **_tcp**.
3. Vous devez voir l'enregistrement **_ldap** de type **Emplacement du service (SRV)** pointant vers `dns1.maxtec.be`, port 389.
4. Pour Kerberos : **Zones de recherche directes** → **maxtec.be** → **_tcp** → enregistrement **_kerberos** (port 88).

**Avec `nslookup`** (invite de commandes, sur le serveur ou un poste client) :

```cmd
nslookup -type=SRV _ldap._tcp.dc._msdcs.maxtec.be
nslookup -type=SRV _kerberos._tcp.maxtec.be

rem Demander à Windows quel DC il utiliserait
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

**En PowerShell** (aperçu, vu au chapitre 9) :

```powershell
Resolve-DnsName -Type SRV _ldap._tcp.dc._msdcs.maxtec.be
```

Si ces enregistrements manquent, redémarrez le service **Netlogon** sur le DC : il les réenregistre. Win+R → `services.msc` → clic droit sur **Netlogon** → **Redémarrer**. En invite de commandes : `net stop netlogon` puis `net start netlogon`.

## 5. Les redirecteurs (forwarders)

`dns1` a l'autorité sur `maxtec.be`. Pour les autres noms (`www.google.com`), il doit demander ailleurs :

- **Sans redirecteur**, il interroge lui-même les serveurs racine d'Internet (« indications de racine »).
- **Avec un redirecteur**, il transmet la question à un autre résolveur (celui du fournisseur d'accès, `1.1.1.1`, `8.8.8.8`…) qui fait le travail.

La règle en entreprise : **les postes interrogent uniquement le DC**, et c'est le DC qui redirige vers l'extérieur. On ne met jamais `8.8.8.8` comme DNS d'un poste du domaine.

**Configuration dans le Gestionnaire DNS** (sur `dns1`) :

1. Gestionnaire de serveur → **Outils** → **DNS** (ou `dnsmgmt.msc`).
2. Clic droit sur **DNS1** → **Propriétés** → onglet **Redirecteurs**.
3. Cliquez sur **Modifier…**, saisissez l'adresse (par exemple `1.1.1.1`) puis **Entrée**. La validation affichée à côté peut échouer si le lab n'a pas d'accès Internet : ce n'est pas bloquant.
4. **OK**, puis **Appliquer** / **OK**.

**Vérification** : rouvrez l'onglet **Redirecteurs**, l'adresse doit être listée. Si une carte NAT est branchée, testez depuis le serveur : `nslookup www.google.com 192.168.0.2` doit renvoyer une adresse.

**En PowerShell** (aperçu, vu au chapitre 9) :

```powershell
Add-DnsServerForwarder -IPAddress 1.1.1.1
Get-DnsServerForwarder
```

!!! note "Dans le lab"
    Le réseau interne n'a pas d'accès Internet : un redirecteur n'y sert à rien, sauf pendant qu'une carte NAT temporaire est branchée. Retenez surtout le principe et l'emplacement du réglage.


---
