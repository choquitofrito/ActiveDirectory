# Exercices : Anatomie d'une ouverture de session réseau

## Navigation
[⏮️ Installation du lab](Labo/Labo_structure.md) | [🏠 Retour au syllabus](../index.md) | [⏭️ Chapitre 7 : Utilisateurs, groupes, partages](../Chapitre%207.Gestion_des_Utilisateurs.md)

---

!!! info "Contexte"
    Quand `ivan` tape son mot de passe sur `ws-IT-01`, une dizaine d'échanges réseau ont lieu en moins d'une seconde : attribution d'adresse, requêtes DNS, authentification Kerberos, accès LDAP et SMB. Ce lab les rend visibles un par un. C'est le lien direct entre le module « fondements réseau » (adressage, DNS, ports, protocoles) et Active Directory.

    **Durée** : environ 2 h.

    | Partie | Contenu | Durée |
    |--------|---------|-------|
    | A | DHCP sur le DC | 45 min |
    | B | Que se passe-t-il quand ivan ouvre une session ? | 45 min |
    | C | Pannes réseau typiques | 30 min |

    **Prérequis** :

    - DC `dns1.maxtec.be` (192.168.0.2) opérationnel, structure Maxtec créée (`creation_structure.ps1`).
    - `ws-IT-01` joint au domaine et placé dans `OU=Computers,OU=IT,OU=EU`. `ws-RH-01` est utile pour la partie A mais optionnel.
    - Aucun partage à créer : le lab utilise `\\dns1\NETLOGON`, présent sur tout DC et lisible par tous les utilisateurs du domaine.

    Valeurs de référence : [Référence du lab Maxtec](Labo/Reference_Lab_Maxtec.md).

---

## Partie A — DHCP sur le DC (45 min)

### Rappel : DORA

Un client sans adresse obtient sa configuration en quatre messages, en broadcast UDP (port 67 côté serveur, 68 côté client) :

1. **Discover** : le client crie « y a-t-il un serveur DHCP ? ».
2. **Offer** : le serveur propose une adresse et des options.
3. **Request** : le client accepte cette offre (en broadcast, pour que les autres serveurs sachent qu'elle est prise).
4. **Ack** : le serveur confirme. Le bail (*lease*) commence ; le client tente de le renouveler à 50 % de sa durée.

Sous Linux, le même rôle est tenu par `isc-dhcp-server` (en fin de vie, remplacé par Kea) ou `dnsmasq` ; les concepts (étendue, bail, options) sont identiques.

### Pourquoi le DC garde une adresse fixe

Le DC est le serveur DNS des clients : c'est son adresse qu'on distribue dans l'option 006. Si elle changeait, aucun client ne trouverait plus le domaine. Règle générale : **les serveurs d'infrastructure (DC, DNS, DHCP, passerelle) ont une adresse statique**, les postes sont en DHCP.

!!! example "Cahier des charges"
    Sur `dns1` :

    | Élément | Valeur |
    |---------|--------|
    | Rôle | Serveur DHCP, autorisé dans AD |
    | Étendue | `Maxtec-LAN`, 192.168.0.100 à 192.168.0.199, masque 255.255.255.0 |
    | Durée du bail | 8 jours |
    | Option 006 (serveur DNS) | 192.168.0.2 |
    | Option 015 (nom de domaine DNS) | maxtec.be |

    Puis passez `ws-RH-01` (ou `ws-IT-01` si vous n'avez qu'un client) en DHCP et vérifiez qu'il obtient une adresse de l'étendue, le bon DNS et reste fonctionnel dans le domaine.

    Si c'est `ws-IT-01` qui passe en DHCP, son adresse n'est plus `192.168.0.10`. Le poste met à jour son enregistrement A tout seul, mais l'ancien PTR `192.168.0.10` reste dans la zone inverse (le nettoyage automatique est désactivé) : supprimez-le dans le Gestionnaire DNS. Dans la suite du cours, retrouvez l'adresse du poste avec `Resolve-DnsName ws-IT-01.maxtec.be` plutôt que de supposer `.10`.

!!! warning "Un seul serveur DHCP sur le réseau interne"
    Le réseau interne VirtualBox n'a pas de DHCP par défaut, sauf si quelqu'un en a créé un (`VBoxManage dhcpserver`). Vérifiez-le avant : deux serveurs DHCP sur le même segment, c'est la loterie. Si votre client a aussi une carte NAT, elle reçoit sa propre adresse (10.0.2.x) et son propre DNS : désactivez-la pendant ce lab.

!!! note "Passerelle (option 003)"
    Le réseau interne du lab n'a pas de routeur, donc pas d'option 003. En entreprise, on la renseigne toujours.

??? success "Solution — PowerShell sur le DC"

    ```powershell
    # 1. Installer le rôle
    Install-WindowsFeature DHCP -IncludeManagementTools

    # 2. Créer les groupes locaux DHCP Administrators / DHCP Users et redémarrer le service
    Add-DhcpServerSecurityGroup
    Restart-Service DHCPServer

    # 3. Autoriser le serveur dans AD (sinon il refuse de distribuer des adresses)
    Add-DhcpServerInDC -DnsName "dns1.maxtec.be" -IPAddress 192.168.0.2
    Get-DhcpServerInDC

    # 4. Créer l'étendue
    Add-DhcpServerv4Scope -Name "Maxtec-LAN" `
        -StartRange 192.168.0.100 -EndRange 192.168.0.199 `
        -SubnetMask 255.255.255.0 `
        -LeaseDuration "8.00:00:00" `
        -State Active

    # 5. Options 006 et 015
    Set-DhcpServerv4OptionValue -ScopeId 192.168.0.0 -DnsServer 192.168.0.2 -DnsDomain "maxtec.be"
    Get-DhcpServerv4OptionValue -ScopeId 192.168.0.0
    ```

    Le Gestionnaire de serveur affiche ensuite une alerte « Configuration post-déploiement » pour DHCP. Les étapes 2 et 3 l'ont faite ; pour faire disparaître l'avertissement :

    ```powershell
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\ServerManager\Roles\12" -Name ConfigurationState -Value 2
    ```

    **Pourquoi l'autorisation dans AD ?** Un serveur DHCP Windows joint au domaine vérifie qu'il est listé dans AD avant de répondre. C'est une protection contre les serveurs DHCP installés par erreur (ou par malveillance) qui distribueraient un faux DNS.

??? success "Solution — Passer le client en DHCP"

    Sur `ws-RH-01`, invite de commandes **administrateur** (adaptez le nom de la carte, visible avec `ipconfig`) :

    ```
    netsh interface ip set address "Ethernet" dhcp
    netsh interface ip set dns "Ethernet" dhcp
    ipconfig /renew
    ipconfig /registerdns
    ```

    Équivalent graphique : **Paramètres > Réseau et Internet > Ethernet > Attribution d'adresse IP > Modifier > Automatique (DHCP)**, et idem pour l'attribution du serveur DNS.

    **Vérification sur le client**

    ```
    ipconfig /all
    ```

    Attendu :

    | Ligne | Valeur |
    |-------|--------|
    | DHCP activé | Oui |
    | Adresse IPv4 | 192.168.0.1xx |
    | Serveur DHCP | 192.168.0.2 |
    | Serveurs DNS | 192.168.0.2 |
    | Suffixe DNS propre à la connexion | maxtec.be |
    | Bail obtenu / Bail expirant | 8 jours d'écart |

    **Vérification sur le DC**

    ```powershell
    Get-DhcpServerv4Lease -ScopeId 192.168.0.0
    Resolve-DnsName ws-RH-01.maxtec.be      # l'enregistrement A doit pointer sur la nouvelle adresse
    ```

    Si `Resolve-DnsName` renvoie encore l'ancienne adresse (.11), relancez `ipconfig /registerdns` sur le client et patientez quelques secondes.

    **Équivalent graphique sur le DC** : `dhcpmgmt.msc` → `dns1.maxtec.be` → IPv4 → clic droit **Nouvelle étendue** (l'assistant demande successivement plage, exclusions, durée du bail, puis options : passerelle, DNS, WINS). Les baux actifs sont visibles dans **Étendue > Baux d'adresses**.

---

## Partie B — Que se passe-t-il quand ivan ouvre une session ? (45 min)

Toutes les commandes se lancent sur `ws-IT-01`, dans une invite de commandes ou PowerShell, sauf mention contraire.

### Étape 1 — DNS : trouver le DC

Le poste ne connaît pas l'adresse du DC à l'avance. Il demande au DNS « qui fournit le service LDAP pour le domaine maxtec.be ? » grâce aux enregistrements **SRV** créés par AD (voir Chapitre 5).

!!! example "À faire"
    ```
    nslookup -type=SRV _ldap._tcp.dc._msdcs.maxtec.be
    nslookup -type=SRV _kerberos._tcp.maxtec.be
    nltest /dsgetdc:maxtec.be
    ```

    Répondez : quel serveur est renvoyé, sur quel port ? Que signifient les drapeaux `KDC`, `GC`, `TIMESERV` dans la sortie de `nltest` ?

??? success "Ce que vous devez voir"

    - `nslookup` : `_ldap._tcp.dc._msdcs.maxtec.be SRV service location: priority = 0, weight = 100, port = 389, svr hostname = dns1.maxtec.be`, puis l'adresse 192.168.0.2 dans la section supplémentaire. Pour `_kerberos`, même serveur, port **88**.
    - `nltest` : `DC: \\dns1.maxtec.be`, `Address: \\192.168.0.2`, `Dom Name: maxtec.be`, et une ligne `Flags` contenant notamment `PDC GC DS LDAP KDC TIMESERV WRITABLE DNS_DC`.
        - `KDC` : le DC délivre les tickets Kerberos.
        - `GC` : il héberge le catalogue global (port 3268).
        - `TIMESERV` : il sert de source de temps aux clients.

    Si ces requêtes échouent, rien d'autre ne fonctionnera : pas de logon réseau, pas de GPO. C'est le premier réflexe de diagnostic (voir partie C, panne 1).

### Étape 2 — Les ports utilisés

!!! example "À faire"
    ```powershell
    Test-NetConnection dns1 -Port 53
    Test-NetConnection dns1 -Port 88
    Test-NetConnection dns1 -Port 389
    Test-NetConnection dns1 -Port 445
    ```

    Pour chaque port, notez `TcpTestSucceeded` et associez-le à son service.

??? success "Ce que vous devez voir"

    Les quatre tests renvoient `TcpTestSucceeded : True`.

    | Port | Service | Rôle dans l'ouverture de session |
    |------|---------|----------------------------------|
    | 53 | DNS | Trouver le DC (étape 1). Surtout UDP ; TCP pour les réponses longues |
    | 88 | Kerberos | Obtenir le TGT et les tickets de service |
    | 389 | LDAP | Lire les informations de l'annuaire (compte, GPO applicables) |
    | 445 | SMB | Télécharger les GPO depuis `SYSVOL`, accéder aux partages |

    `Test-NetConnection` ne teste que TCP. Un port UDP (DNS, Kerberos, NTP) peut être filtré alors que le test TCP réussit ; pour DNS, `nslookup` reste le vrai test.

### Étape 3 — Kerberos : les tickets

!!! example "À faire"
    1. Ouvrez une session sur `ws-IT-01` avec `MAXTEC\ivan`.
    2. Dans une invite de commandes **non administrateur** (sinon vous voyez les tickets du compte administrateur), tapez `klist`.
    3. Tapez `klist purge`, puis `klist` : que reste-t-il ?
    4. Ouvrez `\\dns1\NETLOGON` dans l'Explorateur, puis relancez `klist`.

??? success "Ce que vous devez voir"

    **Après l'ouverture de session**, `klist` liste plusieurs tickets, parmi lesquels :

    | Serveur (`Server:`) | Signification |
    |---------------------|---------------|
    | `krbtgt/MAXTEC.BE @ MAXTEC.BE` | Le **TGT**, obtenu au logon |
    | `cifs/dns1.maxtec.be @ MAXTEC.BE` | Ticket de service SMB, utilisé pour télécharger les GPO depuis SYSVOL |
    | `ldap/dns1.maxtec.be/maxtec.be @ MAXTEC.BE` | Ticket de service LDAP, pour interroger l'annuaire |

    Pour chaque ticket : `KerbTicket Encryption Type: AES-256-CTS-HMAC-SHA1-96`, une heure de début, une heure de fin (10 h plus tard pour le TGT).

    **Après `klist purge`** : `Cached Tickets: (0)`.

    Les libellés ci-dessus sont ceux de `klist` en anglais ; sur un Windows en français, la sortie est traduite (« Serveur », « Heure de début », « Heure de fin », type de chiffrement…). Les valeurs, elles, sont identiques.

    **Après l'accès à `\\dns1\NETLOGON`** : un nouveau TGT et un nouveau ticket `cifs/dns1.maxtec.be` sont apparus, sans que vous ayez retapé votre mot de passe. Windows a redemandé un TGT au KDC en utilisant les identifiants gardés en mémoire par le processus LSASS depuis l'ouverture de session.

    C'est exactement ce qui rend le vol d'identifiants en mémoire intéressant pour un attaquant (voir [Chapitre 11](../Chapitre%2011.Securite_AD.md)).

### Étape 4 — Les groupes dans le jeton

Les groupes d'un utilisateur sont calculés **une fois**, à l'ouverture de session, et placés dans son **jeton d'accès** (et dans le TGT). Un changement d'appartenance fait sur le DC n'est donc pas visible immédiatement.

!!! example "À faire"
    1. En session `ivan` sur `ws-IT-01` : `whoami /groups | findstr GG-`
    2. Sur le DC, ajoutez `ivan` à `GG-EU-Ventes-Users` :

        ```powershell
        Add-ADGroupMember -Identity "GG-EU-Ventes-Users" -Members ivan
        ```

    3. Sur `ws-IT-01`, relancez `whoami /groups | findstr GG-`. Le groupe apparaît-il ?
    4. Faites `klist purge`, puis relancez `whoami /groups | findstr GG-`.
    5. Fermez la session, rouvrez-la en `ivan`, relancez la commande.
    6. Nettoyage sur le DC :

        ```powershell
        Remove-ADGroupMember -Identity "GG-EU-Ventes-Users" -Members ivan -Confirm:$false
        ```

??? success "Ce que vous devez voir et pourquoi"

    - Étapes 1, 3 et 4 : seul `MAXTEC\GG-EU-IT-Users` apparaît.
    - Étape 5 : `MAXTEC\GG-EU-Ventes-Users` apparaît enfin.

    Il y a deux choses distinctes :

    | Élément | Contenu | Quand il est mis à jour |
    |---------|---------|-------------------------|
    | **Jeton local** (ce que montre `whoami /groups`) | Groupes utilisés pour les accès sur le poste lui-même | À l'ouverture de session uniquement |
    | **TGT / tickets de service** | Groupes présentés aux serveurs (partages, etc.) | À chaque nouveau TGT : `klist purge` suffit pour les **nouvelles** connexions |

    `klist purge` force donc un nouveau TGT contenant les nouveaux groupes, mais une connexion SMB déjà ouverte vers `dns1` peut garder l'ancien jeton côté serveur. En pratique, **la méthode fiable reste de fermer puis rouvrir la session**.

    C'est la cause du piège décrit dans l'exercice [AGDLP](./Exercices:%20AGDLP_Partage_Fichiers.md) : « j'ai ajouté l'utilisateur au groupe et il n'a toujours pas accès ». Le groupe est bon, le jeton est ancien.

### Étape 5 — L'heure

Kerberos refuse un ticket si l'horloge du client et celle du DC ont plus de **5 minutes** d'écart (paramètre « Tolérance maximale pour la synchronisation de l'horloge de l'ordinateur » dans la Default Domain Policy). C'est une protection contre le rejeu de tickets interceptés.

Dans un domaine, la hiérarchie de temps est automatique : les postes se synchronisent sur un DC, les DC sur le DC qui détient le rôle **émulateur PDC**, et ce dernier sur une source externe (en production) ou sur son horloge locale (dans le lab).

!!! example "À faire"
    Sur `ws-IT-01` puis sur `dns1` :

    ```
    w32tm /query /status
    w32tm /query /source
    ```

    Sur `ws-IT-01`, mesurez l'écart avec le DC :

    ```
    w32tm /stripchart /computer:dns1.maxtec.be /samples:3 /dataonly
    ```

??? success "Ce que vous devez voir"

    - Sur `ws-IT-01` : `Source: dns1.maxtec.be` (ou son adresse), `Stratum` égal à celui du DC + 1.
    - Sur `dns1` : `Local CMOS Clock`, `Free-running System Clock` ou `VM IC Time Synchronization Provider` selon l'hyperviseur. C'est acceptable en lab. En production, l'émulateur PDC se synchronise sur une source NTP externe :

        ```
        w32tm /config /manualpeerlist:"be.pool.ntp.org" /syncfromflags:manual /reliable:yes /update
        ```

    - `stripchart` : un décalage de quelques millisecondes (`+00.0012345s` par exemple).

!!! warning "Ne modifiez pas l'heure du DC"
    Changer l'heure d'un DC perturbe tous les clients, les tickets en cours et la réplication s'il y en a plusieurs. Si vous voulez provoquer un décalage, faites-le **sur le client** (partie C, panne 3).

### Optionnel — Voir les échanges dans Wireshark

Si Wireshark est installé sur `ws-IT-01` : lancez une capture sur la carte du réseau interne, faites `klist purge` puis accédez à `\\dns1\NETLOGON`, arrêtez la capture et appliquez le filtre :

```
kerberos || dns || ldap || smb2
```

Vous devez retrouver, dans l'ordre : requêtes DNS, `AS-REQ`/`AS-REP` (TGT), `TGS-REQ`/`TGS-REP` pour `cifs/dns1.maxtec.be`, puis la négociation `SMB2` et l'arborescence `NETLOGON`. Le contenu SMB est signé (et chiffré si configuré) : on voit les échanges, pas les données.

Pour capturer une ouverture de session complète, il faut capturer depuis une autre machine ou depuis l'hôte VirtualBox, car la session n'est pas encore ouverte au moment des premiers échanges.

---

## Partie C — Pannes réseau typiques (30 min)

Travaillez en binôme : l'un provoque la panne sur le **client** (jamais sur le DC), l'autre diagnostique sans regarder ce qui a été fait. Puis inversez. Pour chaque panne, le diagnostiqueur doit indiquer : le symptôme observé, la commande qui a trouvé la cause, la correction.

### Panne 1 — Le client utilise un DNS public

**Mise en place (sur le client, PowerShell administrateur)** :

```powershell
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 8.8.8.8
Clear-DnsClientCache
```

**Symptômes** : `gpupdate /force` échoue, `\\dns1\NETLOGON` introuvable, un utilisateur qui ne s'est jamais connecté sur ce poste ne peut pas ouvrir de session (« aucun serveur d'accès disponible » ou message équivalent). Un utilisateur déjà connecté auparavant peut encore ouvrir une session grâce aux identifiants en cache, ce qui rend la panne trompeuse.

??? success "Diagnostic et solution"

    ```
    ipconfig /all                                        :: Serveurs DNS : 8.8.8.8
    nslookup -type=SRV _ldap._tcp.dc._msdcs.maxtec.be    :: délai d'attente dépassé / domaine inexistant
    nltest /dsgetdc:maxtec.be                            :: ERROR_NO_SUCH_DOMAIN
    ```

    Cause : le DNS public ne connaît pas la zone interne `maxtec.be` et ne contient pas les enregistrements SRV. Dans le lab, il n'est même pas joignable (pas d'accès Internet).

    Correction :

    ```powershell
    # client en IP fixe
    Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 192.168.0.2
    # client en DHCP (partie A) : revenir au DNS fourni par le DHCP
    Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ResetServerAddresses
    ```

    Règle : un poste du domaine n'utilise **que** les DNS du domaine. C'est le DC (redirecteurs DNS) qui résout Internet pour eux.

### Panne 2 — SMB bloqué par le pare-feu

**Mise en place (sur le client, PowerShell administrateur)** :

```powershell
New-NetFirewallRule -DisplayName "LAB-Panne-SMB" -Direction Outbound -Protocol TCP -RemotePort 445,139 -Action Block
```

On bloque aussi le 139 : si le 445 ne répond pas, le client SMB de Windows se rabat sur NetBIOS (TCP 139), et la panne ne se verrait pas.

**Symptômes** : `ping dns1` répond, `nslookup dns1` répond, mais `\\dns1\NETLOGON` affiche « Chemin réseau introuvable » (erreur 0x80070035) et `gpupdate /force` échoue sur la lecture des GPO.

??? success "Diagnostic et solution"

    ```powershell
    Test-NetConnection dns1 -Port 445      # TcpTestSucceeded : False, PingSucceeded : True
    Test-NetConnection dns1 -Port 139      # idem
    Get-NetFirewallRule -Direction Outbound -Action Block -Enabled True |
        Select-Object DisplayName, Profile
    ```

    Cause : le réseau fonctionne (ping, DNS), mais le port applicatif est filtré. `ping` teste ICMP, pas le service.

    Correction :

    ```powershell
    Remove-NetFirewallRule -DisplayName "LAB-Panne-SMB"
    ```

    Réflexe à retenir : **« ping OK » ne prouve rien pour un service**. On teste le port du service (`Test-NetConnection -Port`).

### Panne 3 — Décalage horaire de plus de 5 minutes

**Mise en place** :

1. VM `ws-IT-01` **éteinte**, sur l'hôte : désactiver la synchronisation de l'heure par les Additions invité VirtualBox :

    ```
    VBoxManage setextradata "ws-IT-01" "VBoxInternal/Devices/VMMDev/0/Config/GetHostTimeDisabled" 1
    ```

    (Adaptez le nom de la VM tel qu'il apparaît dans VirtualBox.)

2. Démarrer `ws-IT-01`, ouvrir PowerShell administrateur et empêcher la resynchronisation Windows avant d'avancer l'horloge :

    ```powershell
    Stop-Service w32time
    Set-Date (Get-Date).AddMinutes(15)
    klist purge
    ```

**Symptômes** : selon la version de Windows et le moment, l'accès aux partages ou `gpupdate` échoue avec une erreur d'authentification, et une ouverture de session d'un autre utilisateur peut afficher « Il existe une différence d'heure et/ou de date entre le client et le serveur ». Windows sait parfois compenser ou retomber sur NTLM : le symptôme n'est pas toujours spectaculaire, d'où l'intérêt de la mesure.

??? success "Diagnostic et solution"

    ```
    w32tm /stripchart /computer:dns1.maxtec.be /samples:3 /dataonly    :: décalage d'environ -900 s
    w32tm /query /status                                              :: service arrêté ou source incorrecte
    ```

    La mesure `w32tm` est la preuve principale. Les erreurs Kerberos côté client (`KRB_AP_ERR_SKEW`, écart d'horloge trop important) ne sont journalisées que si la journalisation Kerberos est activée **avant** la panne : `reg add HKLM\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters /v LogLevel /t REG_DWORD /d 1 /f` (à retirer ensuite avec `reg delete … /v LogLevel /f`). Elles apparaissent alors dans le journal **Système**, source `Security-Kerberos`.

    Correction :

    ```powershell
    Start-Service w32time
    w32tm /resync /force
    klist purge
    ```

    Puis, VM éteinte, réactivez la synchronisation VirtualBox :

    ```
    VBoxManage setextradata "ws-IT-01" "VBoxInternal/Devices/VMMDev/0/Config/GetHostTimeDisabled" 0
    ```

---

## Ports à connaître

| Port | Protocole | Service | Usage dans AD |
|------|-----------|---------|---------------|
| 53 | TCP/UDP | DNS | Localiser les DC (SRV), résolution de noms |
| 88 | TCP/UDP | Kerberos | Authentification (TGT, tickets de service) |
| 123 | UDP | NTP (W32Time) | Synchronisation horaire, indispensable à Kerberos |
| 135 | TCP | RPC Endpoint Mapper | Point d'entrée RPC ; les échanges se poursuivent sur un port dynamique (49152-65535) |
| 389 | TCP/UDP | LDAP | Interrogation et modification de l'annuaire |
| 445 | TCP | SMB | SYSVOL et NETLOGON (GPO, scripts), partages de fichiers |
| 464 | TCP/UDP | Kerberos kpasswd | Changement de mot de passe |
| 636 | TCP | LDAPS | LDAP chiffré par TLS |
| 3268 | TCP | Catalogue global | Recherche dans toute la forêt (3269 en TLS) |
| 3389 | TCP | RDP | Bureau à distance |
| 5985 | TCP | WinRM (HTTP) | Administration PowerShell à distance (`Enter-PSSession`), 5986 en HTTPS |

---

## Pour aller plus loin : un client Linux dans le domaine

Si vous avez une VM Linux (Ubuntu, Debian, Fedora…) sur le même réseau interne, vous pouvez tenter de la joindre au domaine avec `realmd` et `sssd`. Condition indispensable : son DNS doit pointer vers **192.168.0.2** (sinon `realm` ne trouve pas le domaine, exactement comme la panne 1), et son heure doit être synchronisée.

```bash
sudo apt install realmd sssd sssd-tools adcli krb5-user samba-common-bin   # Debian/Ubuntu
realm discover maxtec.be
sudo realm join -U Administrateur maxtec.be
id ivan@maxtec.be
```

Les paquets et les réglages exacts varient selon la distribution et sa version ; attendez-vous à devoir ajuster la configuration (`/etc/sssd/sssd.conf`, création des répertoires personnels). C'est une extension, pas un passage obligé du cours.

---

## Navigation
[⏮️ Installation du lab](Labo/Labo_structure.md) | [🏠 Retour au syllabus](../index.md) | [⏭️ Chapitre 7 : Utilisateurs, groupes, partages](../Chapitre%207.Gestion_des_Utilisateurs.md)
