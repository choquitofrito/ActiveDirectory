# Chapitre 4: DNS en Pratique avec Active Directory

## 🧭 Navigation du Cours
[⏮️ Chapitre Précédent: Active Directory DS](Chapitre%204.Active%20Directory%20Domain%20Services%20(AD%20DS).md) | [🏠 Retour au Syllabus](../README.md) | [⏭️ Chapitre Suivant: Unités d'Organisation](Chapitre%205.Unites_Organisation.md)

## 📊 Votre Progrès
- [✅] Chapitre 1-3: Préparation
- [✅] Chapitre 4: Active Directory DS installé
- [🔄] **Chapitre 4**: DNS Pratique avec AD *(En cours - 90 minutes)*
- [⏸️] Chapitre 5: Unités d'Organisation

---

> 🎉 **Félicitations !** Vous avez installé Active Directory et maintenant vous avez un domaine **maxtec.be** fonctionnel !
>
> Dans ce chapitre, nous allons **pratiquer DNS** avec votre infrastructure réelle. Fini la théorie abstraite, place à la manipulation concrète !

---

## 📙 Objectifs Pédagogiques (90 minutes de pratique)

À la fin de ce chapitre, vous serez capable de :
1. ✅ **Explorer** les zones DNS créées automatiquement par AD
2. ✅ **Comprendre** les enregistrements DNS critiques pour AD
3. ✅ **Créer** des enregistrements DNS manuellement
4. ✅ **Joindre** un poste au domaine et observer l'enregistrement DNS automatique
5. ✅ **Configurer** une zone de recherche inverse
6. ✅ **Dépanner** les problèmes DNS courants

---

## 🔍 Lab 1: Explorer le DNS créé par Active Directory (20 minutes)

### Objectif
Découvrir et comprendre ce qu'Active Directory a créé automatiquement dans le DNS.

### 🖥️ Étape 1: Ouvrir le Gestionnaire DNS

1. **Sur votre serveur** (dc1 ou dns1), ouvrir **Gestionnaire de serveur**
2. Menu **Outils** → **DNS**
3. La console **Gestionnaire DNS** s'ouvre

> 💡 **Astuce rapide:** Vous pouvez aussi taper `dnsmgmt.msc` dans Exécuter (Win+R)

### 🌐 Étape 2: Explorer la Zone maxtec.be

Dans le volet gauche, déroulez :
```
DNS
└── DNS1 (ou nom de votre serveur)
    └── Zones de recherche directes
        └── maxtec.be  ← CLIQUEZ ICI
```

**Observez les enregistrements créés automatiquement !**

### 📋 Étape 3: Identifier les Enregistrements Critiques

Dans le volet droit, vous devriez voir plusieurs enregistrements. Complétons ce tableau ensemble :

| Nom | Type | Valeur/Données | À quoi ça sert ? |
|-----|------|----------------|------------------|
| (identique au dossier parent) | SOA | dns1.maxtec.be | 🔑 **Start of Authority** - définit l'autorité sur cette zone |
| (identique au dossier parent) | NS | dns1.maxtec.be | 🌐 **Name Server** - indique quel serveur DNS est autoritaire |
| dns1 | A | 192.168.0.2 | 💻 **Adresse** de votre contrôleur de domaine |
| _msdcs | ... | ... | 📁 **Dossier spécial** pour les services AD |
| _sites | ... | ... | 📁 Services AD par site géographique |
| _tcp | ... | ... | 📁 Services TCP (LDAP, Kerberos) |
| _udp | ... | ... | 📁 Services UDP |

### 🔎 Étape 4: Explorer les Enregistrements SRV

Les enregistrements SRV (Service) sont **CRITIQUES** pour Active Directory !

1. **Déroulez** `_tcp` dans la zone maxtec.be
2. **Cliquez** sur `_ldap`
3. **Observez** les enregistrements SRV

**Exemple d'enregistrement SRV que vous devriez voir:**
```
_ldap._tcp.maxtec.be
Service: LDAP
Protocole: TCP
Port: 389
Hôte cible: dns1.maxtec.be
```

> 🔑 **Pourquoi c'est important ?**
> Quand un poste veut joindre le domaine, il demande : "Où est le serveur LDAP ?"
> Le DNS répond grâce à cet enregistrement SRV !

### ✅ Checkpoint Lab 1

Assurez-vous de pouvoir répondre :
- [ ] Où se trouvent les zones DNS ? (Gestionnaire DNS → Zones de recherche directes)
- [ ] Qu'est-ce qu'un enregistrement SOA ? (Start of Authority - autorité sur la zone)
- [ ] Pourquoi les enregistrements SRV sont importants ? (Localisation des services AD)
- [ ] Combien d'enregistrements A voyez-vous ? (Au moins un pour votre DC)

**🎯 Test rapide en PowerShell:**
```powershell
# Vérifier que le DNS résout votre domaine
nslookup maxtec.be

# Vérifier les services LDAP
nslookup -type=SRV _ldap._tcp.maxtec.be
```

---

## 🛠️ Lab 2: Créer des Enregistrements Manuellement (25 minutes)

### Objectif
Apprendre à ajouter des enregistrements DNS pour des ressources spécifiques (serveurs, alias, etc.)

### 📝 Exercice 2.1: Créer un Enregistrement A (Hôte)

**Scénario:** Vous avez un serveur de fichiers qui aura l'IP `192.168.10.10`

1. **Dans Gestionnaire DNS**, clic droit sur la zone **maxtec.be**
2. **Nouveau hôte (A ou AAAA)...**
3. **Remplir:**
   - Nom: `fileserver`
   - Adresse IP: `192.168.10.10`
   - ☑️ Créer un enregistrement PTR associé (si zone inverse existe)
4. **Cliquer** sur "Ajouter un hôte"

**✅ Vérification:**
```powershell
# Test 1: Résolution DNS
nslookup fileserver.maxtec.be

# Résultat attendu:
# Nom :    fileserver.maxtec.be
# Address: 192.168.10.10

# Test 2: Ping
ping fileserver.maxtec.be
```

### 🔗 Exercice 2.2: Créer un Alias (CNAME)

**Scénario:** Vous voulez que `files.maxtec.be` pointe vers `fileserver.maxtec.be`

1. **Dans Gestionnaire DNS**, clic droit sur la zone **maxtec.be**
2. **Nouvel alias (CNAME)...**
3. **Remplir:**
   - Nom de l'alias: `files`
   - Nom de domaine complet (FQDN) de l'hôte cible: `fileserver.maxtec.be`
4. **OK**

**✅ Vérification:**
```powershell
nslookup files.maxtec.be

# Résultat attendu:
# Nom :    fileserver.maxtec.be  ← Notez l'alias !
# Address: 192.168.10.10
```

> 💡 **Avantage des CNAME:**
> Si `fileserver` change d'IP, vous mettez à jour UNE SEULE fois l'enregistrement A, et l'alias `files` fonctionne toujours !

### 🌐 Exercice 2.3: Créer un Enregistrement pour un Service Web

**Scénario:** Vous voulez que `www.maxtec.be` pointe vers un serveur web

**Mission:** Créez un enregistrement CNAME `www` qui pointe vers `fileserver` (pour simuler)

<details>
<summary>💡 Cliquez pour voir la solution</summary>

1. Clic droit sur zone **maxtec.be** → **Nouvel alias (CNAME)**
2. Nom: `www`
3. FQDN cible: `fileserver.maxtec.be`
4. OK

Vérification:
```powershell
nslookup www.maxtec.be
# Devrait résoudre vers fileserver.maxtec.be → 192.168.10.10
```
</details>

### ✅ Checkpoint Lab 2

Vérifiez que vous avez créé:
- [ ] Enregistrement A: `fileserver.maxtec.be` → `192.168.10.10`
- [ ] Alias CNAME: `files.maxtec.be` → `fileserver.maxtec.be`
- [ ] Alias CNAME: `www.maxtec.be` → `fileserver.maxtec.be`
- [ ] Tous se résolvent correctement avec `nslookup`

---

## 💻 Lab 3: Joindre un Poste au Domaine et Observer le DNS (20 minutes)

### Objectif
Comprendre comment l'enregistrement DNS automatique fonctionne quand un poste rejoint le domaine.

### 🖥️ Prérequis
Vous avez besoin d'une **deuxième VM** (machine cliente Windows 10/11 Pro):
- Nom: `ws-compta-01` (ou autre)
- Réseau: Même réseau que le serveur (LAN-VM)
- DNS configuré: `192.168.0.2` (votre serveur)

### 📋 Étape 1: Avant de Joindre le Domaine

**Sur le serveur**, vérifier que le poste n'est PAS encore dans le DNS :

```powershell
nslookup ws-compta-01.maxtec.be

# Résultat attendu:
# Serveur peut pas trouver ws-compta-01.maxtec.be : Non-existent domain
```

**Dans Gestionnaire DNS**, vérifier visuellement:
- Zone **maxtec.be**
- Chercher `ws-compta-01` → **N'existe pas encore**

### 🔗 Étape 2: Joindre le Poste au Domaine

**Sur la machine cliente (ws-compta-01):**

1. **Paramètres Système**:
   - Clic droit sur Démarrer → Système
   - Paramètres système avancés
   - Onglet **Nom de l'ordinateur**
   - **Modifier**

2. **Configuration:**
   - Nom de l'ordinateur: `ws-compta-01`
   - Membre de: **Domaine** → `maxtec.be`
   - **OK**

3. **Authentification:**
   - Utilisateur: `Administrateur@maxtec.be`
   - Mot de passe: `Password1!`

4. **Redémarrer** la machine cliente

### 🎉 Étape 3: Observer l'Enregistrement DNS Automatique

**Immédiatement après le redémarrage**, retour sur le serveur :

**Test PowerShell:**
```powershell
nslookup ws-compta-01.maxtec.be

# Résultat MAINTENANT:
# Nom :    ws-compta-01.maxtec.be
# Address: 192.168.10.128  (ou l'IP de votre poste client)
```

**Dans Gestionnaire DNS:**
1. Actualiser la vue (F5 ou clic droit → Actualiser)
2. Zone **maxtec.be**
3. **Chercher** `ws-compta-01` → **Il existe maintenant ! 🎉**

### 🔍 Étape 4: Analyser l'Enregistrement Créé

**Double-cliquez** sur `ws-compta-01` dans le Gestionnaire DNS :

Observez:
- **Type:** A (Host)
- **Adresse IP:** L'IP du poste client
- **Horodatage:** Date/heure de création
- **Option:** "Supprimer cet enregistrement lorsqu'il devient obsolète"

> 💡 **Magie de l'intégration DNS-AD !**
> Quand un poste rejoint le domaine, AD communique automatiquement avec DNS pour créer l'enregistrement. Aucune intervention manuelle nécessaire !

### ✅ Checkpoint Lab 3

- [ ] Le poste client est membre du domaine maxtec.be
- [ ] L'enregistrement DNS `ws-compta-01.maxtec.be` existe
- [ ] `nslookup ws-compta-01.maxtec.be` retourne l'IP correcte
- [ ] Vous comprenez pourquoi c'est automatique (intégration AD-DNS)

---

## 🔄 Lab 4: Configurer une Zone de Recherche Inverse (15 minutes)

### Objectif
Permettre la résolution IP → Nom (l'inverse de la résolution normale)

### 🌐 Pourquoi une Zone Inverse ?

**Résolution normale:** `ws-compta-01.maxtec.be` → `192.168.10.128`
**Résolution inverse:** `192.168.10.128` → `ws-compta-01.maxtec.be`

**Utilisations:**
- 🔐 Authentification (vérifier qu'une IP correspond bien à un nom attendu)
- 📧 Anti-spam (serveurs mail vérifient les noms des expéditeurs)
- 🔍 Troubleshooting (logs plus lisibles)

### 📝 Étape 1: Créer la Zone Inverse

1. **Dans Gestionnaire DNS**, clic droit sur **Zones de recherche inversée**
2. **Nouvelle zone...**
3. Assistant de création:
   - Type: **Zone principale** ✓ "Stocker la zone dans Active Directory"
   - Portée: **Vers tous les serveurs DNS exécutés sur des contrôleurs de domaine dans ce domaine**
   - Nom de zone inverse: **Zone de recherche inversée IPv4**
   - ID réseau: `192.168.0` (sans le dernier octet !)
   - Mises à jour dynamiques: **Autoriser uniquement les mises à jour dynamiques sécurisées**
4. **Terminer**

### 🔍 Étape 2: Vérifier la Zone Créée

Dans **Zones de recherche inversée**, vous devriez voir:
- `0.168.192.in-addr.arpa`

> 📘 **Note:** L'ordre des octets est inversé dans les zones inverses (convention DNS)

### 📋 Étape 3: Observer les Enregistrements PTR

**Déroulez** la zone `0.168.192.in-addr.arpa`:
- Vous devriez voir des enregistrements PTR pour votre serveur
- Exemple: `2` → `dns1.maxtec.be` (si votre serveur est 192.168.0.2)

### ✅ Étape 4: Tester la Résolution Inverse

```powershell
# Test résolution inverse de votre serveur
nslookup 192.168.0.2

# Résultat attendu:
# Nom :    dns1.maxtec.be
# Address: 192.168.0.2

# Test résolution inverse du poste client
nslookup 192.168.10.128  # (remplacez par l'IP de votre client)

# Si configuré automatiquement:
# Nom :    ws-compta-01.maxtec.be
# Address: 192.168.10.128
```

### 🔧 Étape 5: Ajouter un Enregistrement PTR Manuellement

**Si un enregistrement PTR n'existe pas** pour le poste client:

1. **Clic droit** sur la zone `0.168.192.in-addr.arpa`
2. **Nouveau pointeur (PTR)...**
3. **Adresse IP de l'hôte:** `192.168.10.128` (exemple)
4. **Nom de domaine complet de l'hôte:** `ws-compta-01.maxtec.be`
5. **OK**

### ✅ Checkpoint Lab 4

- [ ] Zone inverse créée: `0.168.192.in-addr.arpa`
- [ ] Enregistrement PTR pour le serveur existe
- [ ] `nslookup 192.168.0.2` retourne `dns1.maxtec.be`
- [ ] Vous comprenez la différence entre résolution directe et inverse

---

## 🔧 Lab 5: Dépannage DNS - Troubleshooting (10 minutes)

### Objectif
Apprendre à diagnostiquer et résoudre les problèmes DNS courants.

### 🚨 Scénario 1: "Je ne peux plus rejoindre le domaine"

**Symptôme:** Un nouveau poste ne peut pas joindre le domaine maxtec.be

**Diagnostic étape par étape:**

```powershell
# Sur le poste client, vérifier la configuration réseau
ipconfig /all

# Vérifier:
# 1. L'adresse IP est correcte ?
# 2. Le serveur DNS est 192.168.0.2 ?
# 3. Le suffixe DNS principal est maxtec.be ?
```

**Test DNS:**
```powershell
# Test 1: Peut-on résoudre le domaine ?
nslookup maxtec.be

# Test 2: Peut-on trouver le contrôleur de domaine ?
nslookup dns1.maxtec.be

# Test 3: Les services AD sont-ils visibles ?
nslookup -type=SRV _ldap._tcp.maxtec.be
```

**Solutions courantes:**
| Problème | Solution |
|----------|----------|
| DNS serveur incorrect | Configurer DNS = 192.168.0.2 |
| Pas de connectivité réseau | Vérifier carte réseau LAN-VM |
| Cache DNS corrompu | `ipconfig /flushdns` |

### 🔍 Scénario 2: "Un poste ne s'enregistre pas automatiquement dans le DNS"

**Diagnostic:**

```powershell
# Sur le poste client
ipconfig /registerdns

# Force le ré-enregistrement DNS
```

**Sur le serveur**, vérifier les paramètres de mise à jour dynamique:
1. Gestionnaire DNS → Zone maxtec.be → Propriétés
2. Onglet **Général**
3. Mises à jour dynamiques: **Sécurisées uniquement**

### 🛠️ Commandes de Dépannage Essentielles

| Commande | Usage | Exemple |
|----------|-------|---------|
| `nslookup nom` | Résoudre un nom | `nslookup www.maxtec.be` |
| `nslookup IP` | Résolution inverse | `nslookup 192.168.0.2` |
| `ipconfig /flushdns` | Vider cache DNS | Après modification enregistrement |
| `ipconfig /registerdns` | Forcer enregistrement | Poste pas dans DNS |
| `nslookup -type=SRV` | Vérifier services | `nslookup -type=SRV _ldap._tcp.maxtec.be` |

### ✅ Checkpoint Lab 5

- [ ] Vous savez vérifier la configuration DNS d'un poste (`ipconfig /all`)
- [ ] Vous savez tester la résolution DNS (`nslookup`)
- [ ] Vous connaissez les commandes de dépannage essentielles
- [ ] Vous comprenez les mises à jour dynamiques sécurisées

---

## 📚 Concepts DNS Clés - Récapitulatif

Maintenant que vous avez **pratiqué**, récapitulons les concepts importants :

### 🌐 Types d'Enregistrements DNS

| Type | Nom complet | Usage | Exemple vécu dans les labs |
|------|-------------|-------|---------------------------|
| **A** | Address | Nom → IPv4 | `fileserver.maxtec.be` → `192.168.10.10` |
| **CNAME** | Canonical Name | Alias | `www` → `fileserver` |
| **PTR** | Pointer | IP → Nom (inverse) | `192.168.0.2` → `dns1.maxtec.be` |
| **SRV** | Service | Localisation service | `_ldap._tcp` pour AD |
| **NS** | Name Server | Serveur DNS autoritaire | `maxtec.be` → `dns1.maxtec.be` |
| **SOA** | Start of Authority | Autorité sur zone | Paramètres de la zone |

### 🔄 Résolution DNS dans Active Directory

**Ce qui se passe quand un poste rejoint le domaine:**

1. 🖥️ **Poste client** envoie requête DNS: "Où est le contrôleur de domaine ?"
2. 🌐 **DNS** répond avec enregistrement SRV: "C'est dns1.maxtec.be:389 (LDAP)"
3. 🔐 **Poste** se connecte au DC via LDAP
4. ✅ **AD** authentifie le poste et l'ajoute au domaine
5. 📝 **AD** demande à DNS de créer enregistrement A pour le poste
6. 🎉 **DNS** crée automatiquement `ws-compta-01.maxtec.be`

**Vous avez VU tout ce processus dans le Lab 3 !**

### 🏗️ Architecture DNS-AD Intégrée

```
┌─────────────────────────────────────┐
│   Active Directory (maxtec.be)      │
│                                     │
│   ┌─────────────────────────────┐  │
│   │         DNS Intégré         │  │
│   │                             │  │
│   │  • Zones AD automatiques    │  │
│   │  • Enregistrements SRV      │  │
│   │  • Mises à jour dynamiques  │  │
│   └─────────────────────────────┘  │
│                │                    │
│                ↓                    │
│   ┌──────────────────────────────┐ │
│   │ Postes clients s'enregistrent│ │
│   │    automatiquement           │ │
│   └──────────────────────────────┘ │
└─────────────────────────────────────┘
```

---

## 🎯 Exercice Final: Validation Complète (10 minutes)

### Mission Complète

Vous devez configurer un nouveau serveur web pour maxtec.be. Voici les exigences:

1. **Serveur web** aura le nom `webserver` et l'IP `192.168.10.15`
2. **Les utilisateurs** doivent pouvoir accéder via `www.maxtec.be`
3. **Les admins** doivent pouvoir accéder via `webadmin.maxtec.be`
4. **La résolution inverse** doit fonctionner pour l'IP du serveur

### 📝 Étapes à Réaliser

<details>
<summary>💡 Cliquez pour voir la solution complète</summary>

**Étape 1: Créer l'enregistrement A**
```
Gestionnaire DNS → maxtec.be → Clic droit → Nouveau hôte
- Nom: webserver
- IP: 192.168.10.15
- ☑️ Créer enregistrement PTR associé
```

**Étape 2: Créer les alias CNAME**
```
Alias 1:
- Nom: www
- FQDN cible: webserver.maxtec.be

Alias 2:
- Nom: webadmin
- FQDN cible: webserver.maxtec.be
```

**Étape 3: Vérifier**
```powershell
nslookup webserver.maxtec.be  # → 192.168.10.15
nslookup www.maxtec.be         # → webserver.maxtec.be → 192.168.10.15
nslookup webadmin.maxtec.be    # → webserver.maxtec.be → 192.168.10.15
nslookup 192.168.10.15         # → webserver.maxtec.be
```

**✅ Tous les tests doivent fonctionner !**
</details>

### ✅ Validation Finale

- [ ] Enregistrement A créé pour webserver
- [ ] Alias www.maxtec.be fonctionne
- [ ] Alias webadmin.maxtec.be fonctionne
- [ ] Résolution inverse de 192.168.10.15 fonctionne
- [ ] Tous les nslookup réussissent

---

## 🎉 Félicitations ! Vous Maîtrisez DNS avec Active Directory !

### 🏆 Ce que vous avez accompli

- ✅ **Exploré** les zones DNS créées automatiquement par AD
- ✅ **Compris** les enregistrements critiques (A, CNAME, PTR, SRV)
- ✅ **Créé** des enregistrements manuellement
- ✅ **Observé** l'enregistrement automatique lors de la jonction au domaine
- ✅ **Configuré** une zone de recherche inverse
- ✅ **Dépanné** des problèmes DNS courants

### 🚀 Compétences Acquises

Vous savez maintenant:
- 🔧 Gérer le DNS dans un environnement Active Directory
- 🔍 Diagnostiquer les problèmes de résolution DNS
- 📝 Créer et maintenir des enregistrements DNS
- 🔄 Comprendre l'intégration DNS-AD

### 📚 Pour Aller Plus Loin

Si vous voulez approfondir les concepts théoriques DNS:
- 📖 [Annexe A - DNS Concepts Avancés (Référence)](Annexe%20A%20-%20DNS%20Concepts%20Avances%20(Reference).md)
  - Délégation DNS en détail
  - Architecture multi-sites
  - Zones secondaires avancées
  - Enregistrements spécialisés

---

## 🧭 Navigation
[⏮️ Chapitre 4: Active Directory DS](Chapitre%204.Active%20Directory%20Domain%20Services%20(AD%20DS).md) | [🏠 Retour au Syllabus](../README.md) | [⏭️ Chapitre 5: Unités d'Organisation](Chapitre%205.Unites_Organisation.md)

---

**📚 Cours Active Directory - Chapitre 4-bis/8 | ⏱️ Durée: 90 minutes pratiques | 💻 Hands-on complet**