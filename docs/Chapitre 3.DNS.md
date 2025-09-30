# Chapitre 3: DNS - Préparation pour Active Directory

## 🧭 Navigation du Cours
[⏮️ Chapitre Précédent: Installation VirtualBox](Chapitre%202.Installation-Windows-Server-2022-VirtualBox.md) | [🏠 Retour au Syllabus](../README.md) | [⏭️ Chapitre Suivant: Active Directory](Chapitre%204.Active%20Directory%20Domain%20Services%20(AD%20DS).md)

## 📊 Votre Progrès
- [✅] Chapitre 1: Introduction et installation
- [✅] Chapitre 2: Installation VirtualBox
- [🔄] **Chapitre 3**: DNS Préparation *(En cours)*
- [⏸️] Chapitre 4: Active Directory Domain Services
- [⏸️] Chapitre 4-bis: DNS Pratique avec AD

---

> 📚 **Objectif de ce chapitre court:**
> Comprendre **juste assez** de DNS pour installer Active Directory avec succès.
> La pratique DNS approfondie viendra **APRÈS** installation AD (Chapitre 4-bis).

---

## 📙 Objectifs Pédagogiques

À la fin de ce chapitre, vous serez capable de :
1. ✅ Expliquer en 30 secondes **pourquoi AD a besoin de DNS**
2. ✅ Vérifier que votre serveur **peut résoudre des noms**
3. ✅ Configurer le **DNS du serveur** pour préparer l'installation AD

> 💡 **Note importante:** Nous verrons la théorie DNS complète et les manipulations pratiques **APRÈS avoir installé AD**. Pourquoi ? Parce qu'AD installe automatiquement DNS et vous aurez un domaine réel (maxtec.be) pour pratiquer !

---

## 1. DNS - L'Essentiel

### 🌐 Qu'est-ce que le DNS ?

**DNS = Annuaire téléphonique de l'internet**

```
Vous tapez : www.google.com
DNS traduit : 142.250.179.174
```

**Sans DNS**, vous devriez mémoriser : `142.250.179.174` pour Google, `151.101.1.140` pour Reddit, etc. Impossible !

### 🏢 Pourquoi Active Directory A BESOIN de DNS ?

> 🔑 **Point clé:** Active Directory utilise les **noms de domaine** pour TOUT !

| Ce qu'AD doit faire | Comment DNS aide |
|---------------------|------------------|
| 🖥 Trouver les contrôleurs de domaine | `dc1.maxtec.be` → `192.168.0.2` |
| 🔐 Authentifier les utilisateurs | Localise le serveur Kerberos via DNS |
| 💻 Joindre des postes au domaine | `ws-compta-01.maxtec.be` → enregistrement DNS |
| 📋 Appliquer les stratégies de groupe | DNS trouve où sont les GPO |

**Sans DNS fonctionnel → Active Directory NE PEUT PAS fonctionner ! ☠️**

> 💡 Quand vous installerez AD DS au Chapitre 4, Windows Server installera et configurera automatiquement DNS pour vous !

---

## 2. Vérification Pré-Installation 

### 🔍 Test 1: Votre serveur peut-il résoudre des noms ? est-il connecté à l'internet?

**Sur votre serveur Windows Server**, ouvrez PowerShell et testez :

```powershell
# Test 1: Résoudre google.com
ping google.com

# Résultat attendu:
# Envoi d'une requête 'ping' sur google.com [142.250.xxx.xxx] avec 32 octets de données
```

**✅ Si vous voyez une adresse IP** → DNS externe fonctionne !
**❌ Si erreur "Impossible de trouver l'hôte"** → Problème réseau/DNS, ou adaptateur de réseau

```powershell
# Test 2: Vérifier quel serveur DNS vous utilisez
nslookup google.com

# Résultat montre:
# Serveur :   dns.google
# Address:  8.8.8.8  (ou autre DNS de votre FAI)
```



### 🛠️ Test 2: Préparer le DNS pour AD

**Actuellement**, votre serveur utilise probablement le DNS de votre FAI (exemple: 8.8.8.8). Si on cherche un nom de domaine, ce sera ce serveur qui nous donnera l'ip.

**Pour installer AD**, il est indispensable de configurer le serveur pour qu’il utilise **son propre service DNS**. Cela signifie que, lors d’une requête de résolution de nom de domaine, c’est le serveur lui-même qui répondra (par exemple, lorsqu’on tape un nom de machine du domaine comme `dns1.maxtec.be` ou `ws-compta-01.maxtec.be` ce notre propre serveur qui nous donnera l'ip).

> 🛠️ **À faire maintenant :**
> - Modifiez la configuration réseau de votre serveur pour que l’adresse du serveur DNS soit `127.0.0.1` (localhost).
> - Cela garantit que toutes les requêtes DNS passent par le service DNS local, ce qui est obligatoire pour le bon fonctionnement d’Active Directory.
> - Après l’installation d’AD DS, le serveur DNS local sera automatiquement configuré pour gérer la zone du domaine AD.

**Résumé :**  
- Le serveur doit utiliser son propre DNS (127.0.0.1) avant d’installer AD DS.
- Sans cette configuration, l’installation d’Active Directory échouera ou ne fonctionnera pas correctement.

#### Configuration réseau pour AD

1. **Ouvrir les Paramètres réseau**
   - État du Réseau → Ethernet → Modifier les options de l'adaptateur
   - Ou : `ncpa.cpl` dans Exécuter... plus simple!

2. **Configurer l'adaptateur LAN-VM** (réseau interne)
   - Clic droit sur la carte réseau LAN-VM → Propriétés
   - Sélectionner "Protocole Internet version 4 (TCP/IPv4)"
   - Cliquer sur Propriétés

3. **Paramètres réseau pour AD**

| Paramètre | Valeur | Explication |
|-----------|--------|-------------|
| Adresse IP | `192.168.0.2` | IP de votre serveur |
| Masque | `255.255.255.0` | Réseau local |
| Passerelle | *(vide pour l'instant)* | Pas nécessaire pour le réseau interne |
| **DNS préféré** | `127.0.0.1` | 🔑 **Le serveur s'utilise lui-même !** |
| DNS auxiliaire | *(vide)* | Sera configuré après installation AD |

> 🔑 **Pourquoi 127.0.0.1 ?**
> - `127.0.0.1` = localhost = "moi-même"
> - Quand AD s'installera, il créera un serveur DNS sur cette machine
> - Le serveur devra utiliser son propre DNS pour fonctionner

4. **Valider et fermer**

### ✅ Test 3: Vérification finale

```powershell
# Vérifier la configuration IP
ipconfig /all

# Cherchez dans le résultat:
# Serveurs DNS. . . : 127.0.0.1
```

**✅ Si vous voyez `127.0.0.1`** → Parfait ! Prêt pour installer AD
**❌ Si vous voyez autre chose** → Revérifier la configuration

> ⚠️ **Attention:** Après cette configuration, vous ne pourrez **temporairement plus** accéder à internet depuis le serveur (normal). L'accès internet sera restauré après l'installation d'AD avec les redirecteurs DNS.

---

## 3. Qu'est-ce qui va se passer au Chapitre 4 ? 🔮

Quand vous lancerez l'installation d'Active Directory Domain Services :

1. **📦 Installation automatique DNS**
   - Windows Server installe le rôle DNS automatiquement
   - Crée la zone DNS `maxtec.be`
   - Configure tous les enregistrements nécessaires pour AD

2. **🌐 Configuration automatique**
   - Enregistrements SRV pour Kerberos, LDAP
   - Enregistrement A pour `dc1.maxtec.be`
   - Zone de recherche directe et inverse

3. **✨ Magie DNS-AD**
   - Quand un poste rejoint le domaine → DNS l'enregistre automatiquement
   - Quand vous créez un utilisateur → DNS mis à jour
   - Tout est intégré !

**Dans le Chapitre 4-bis on pratiquera DNS**

---

## 4. Récapitulatif - Checklist Pré-AD ✅

Avant de passer au Chapitre 4, assurez-vous que :

- [ ] Vous comprenez que **DNS = annuaire de noms → IP**
- [ ] Vous savez que **AD ne peut PAS fonctionner sans DNS**
- [ ] Vous avez testé `ping google.com` avec succès
- [ ] Vous avez configuré DNS = `127.0.0.1` sur l'adaptateur LAN-VM
- [ ] Vous avez vérifié avec `ipconfig /all`

> 💡 **Prochaine étape:** Installation d'Active Directory Domain Services qui installera automatiquement le DNS !

---

## 🎯 Questions Fréquentes

<details>
<summary>❓ Pourquoi si peu de théorie DNS ?</summary>

**Réponse:** Parce que la meilleure façon d'apprendre DNS c'est de le manipuler avec un domaine réel. Une fois AD installé (Chapitre 4), vous aurez `maxtec.be` fonctionnel et nous ferons de la pratique (Chapitre 4-bis) !
</details>

<details>
<summary>❓ Je ne peux plus accéder à internet sur le serveur, c'est normal ?</summary>

**Réponse:** Oui ! Temporairement. Vous avez configuré le DNS vers `127.0.0.1` (vous-même), mais le serveur DNS n'est pas encore installé. Dès que AD sera installé avec DNS, on configurera les "redirecteurs" pour restaurer l'accès internet.
</details>

<details>
<summary>❓ Où est toute la théorie DNS (zones, délégation, etc.) ?</summary>

**Réponse:** Dans **deux endroits** :
1. **Chapitre 4-bis** (après installation AD) : Labs pratiques avec votre domaine réel
2. **Théorie DNS** : Théorie DNS avancée pour consultation/approfondissement
</details>

<details>
<summary>❓ Est-ce que je peux sauter ce chapitre et aller directement au Chapitre 4 ?</summary>

**Réponse:** NON ! Sans configurer DNS = 127.0.0.1, l'installation d'AD échouera. Cette configuration est vitale.
</details>

---

## 📚 Pour aller plus loin (optionnel maintenant)

Si vous voulez approfondir la théorie DNS **avant** l'installation AD :
- 📖 [Théorie DNS - DNS Concepts Avancés](Théorie%20DNS-%20DNS%20Concepts%20Avances%20(Reference).md)

Mais nous recommandons d'**installer AD d'abord** (Chapitre 4) puis de faire les **labs pratiques DNS** (Chapitre 4-bis). 

---

## 🚀 Vous êtes prêt(e) !


**Prochaine étape:** Installation d'Active Directory Domain Services qui transformera votre serveur en contrôleur de domaine avec DNS intégré !

## 🧭 Navigation
[⏮️ Chapitre 2: Installation VirtualBox](Chapitre%202.Installation-Windows-Server-2022-VirtualBox.md) | [🏠 Retour au Syllabus](../README.md) | [⏭️ Chapitre 4: Installation AD DS](Chapitre%204.Active%20Directory%20Domain%20Services%20(AD%20DS).md)

---

