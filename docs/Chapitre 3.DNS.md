# Chapitre 3: DNS - Préparation pour Active Directory

## 🧭 Navigation du Cours
[⏮️ Chapitre Précédent: Installation VirtualBox](Chapitre%202.Installation-Windows-Server-2022-VirtualBox.md) | [🏠 Retour au Syllabus](../README.md) | [⏭️ Chapitre Suivant: Active Directory](Chapitre%204.Active%20Directory%20Domain%20Services%20(AD%20DS).md)

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

#### Configuration réseau pour AD

!!! info "Configuration réseau pour AD"

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
| **DNS préféré** | `192.168.0.2` ou `127.0.0.1` | 🔑 **Le serveur s'utilise lui-même !** |
| DNS auxiliaire | *(vide)* | Sera configuré après installation AD |

> 🔑 **Pourquoi 127.0.0.1 ?**
> - `127.0.0.1` = localhost = "moi-même"
> - Quand AD s'installera, il créera un serveur DNS sur cette machine
> - Le serveur devra utiliser son propre DNS pour fonctionner

4. **Valider et fermer**

### Test

```powershell
# Vérifier la configuration IP
ipconfig /all

# Cherchez dans le résultat:
# Serveurs DNS. . . : 127.0.0.1
```



**✅ Si vous voyez `127.0.0.1`** → Parfait ! Prêt pour installer AD
**❌ Si vous voyez autre chose** → Revérifier la configuration


## 3. Qu'est-ce qui va se passer au Chapitre 4 ? 🔮

Quand vous lancerez l'installation d'Active Directory Domain Services :

!!! info "Qu'est-ce qui va se passer au Chapitre 4 ?"

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





---
