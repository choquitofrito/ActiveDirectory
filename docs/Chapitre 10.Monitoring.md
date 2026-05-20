# Chapitre 10 - Surveillance et Monitoring Active Directory

## 🧭 Navigation du Cours
[⏮️ Chapitre Précédent: Powershell AD - Création et Modification](Chapitre%209.3.Powershell%20AD%20-%20Creation_et_Modification.md) | [🏠 Retour au Syllabus](index.md)

---

## 📊 Objectifs d'apprentissage

À la fin de ce chapitre, vous serez capable de :

- Comprendre l'importance du monitoring dans Active Directory
- Identifier les événements critiques à surveiller (Event IDs)
- Utiliser l'**Event Viewer** et **`Get-WinEvent`** pour analyser les logs
- Détecter des anomalies de sécurité courantes

!!! warning "Périmètre de ce chapitre"
    Ce chapitre se concentre sur les **outils de base** : Event Viewer + PowerShell `Get-WinEvent`. Notre lab Maxtec a **un seul DC**, donc tout ce qui touche à la **réplication multi-DC** (compteurs `NTDS DRA`, `repadmin`, etc.) est hors scope ici. Ces sujets avancés sont regroupés en fin de chapitre dans **"Pour aller plus loin (production)"**.

!!! example "Lab pratique associé"
    Le **[Lab 3 - MonitoringLab](Labos%20Extra/Labo3-MonitoringLab/README.md)** propose 6 exercices progressifs avec un scénario MSP: exploration de structure, analyse d'événements, configuration d'audit GPO, comptes de service, et investigation d'incidents. Chaque exercice inclut un script de vérification automatique.

---

## 🎯 Pourquoi surveiller Active Directory ?

Active Directory est le **cœur de l'infrastructure IT** dans la plupart des entreprises. Une défaillance ou une compromission peut paralyser toute l'organisation.


### Scénarios critiques à détecter

| Scénario | Impact | Détection |
|----------|--------|-----------|
| **Comptes verrouillés en masse** | Perte de productivité, possible attaque brute force | Event ID 4740 |
| **Modification non autorisée de groupes** | Élévation de privilèges | Event ID 4728, 4732, 4756 |
| **Échecs d'authentification répétés** | Tentative d'intrusion | Event ID 4625 |
| **Modification de GPO** | Changement de configuration critique | Event ID 5136, 5137 |
| **Création/suppression de comptes** | Activité administrative à tracer | Event ID 4720, 4726 |

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

### 🔐 Sécurité (Security Log)

#### Authentification
- **4624** : Connexion réussie (logon successful)
- **4625** : Échec de connexion (logon failed)
- **4634** : Déconnexion (logoff)
- **4648** : Connexion avec identifiants explicites (runas)

#### Gestion des Comptes
- **4720** : Création de compte utilisateur
- **4722** : Activation de compte
- **4723** : Tentative de changement de mot de passe
- **4724** : Réinitialisation de mot de passe
- **4725** : Désactivation de compte
- **4726** : Suppression de compte
- **4740** : Verrouillage de compte

#### Gestion des Groupes
- **4728** : Membre ajouté à un groupe de sécurité global
- **4729** : Membre retiré d'un groupe de sécurité global
- **4732** : Membre ajouté à un groupe de sécurité local
- **4733** : Membre retiré d'un groupe de sécurité local
- **4756** : Membre ajouté à un groupe de sécurité universel

#### GPOs

- **5312** : Erreur d'application de GPO
- **5126** : La stratégie de groupe a reçu correctement les objets de stratégie de groupe applicables du contrôleur du domaine
- **5017** : Temps de traitement GPO dépassé
- **5018** : Temps de traitement GPO précédent dépassé
- **5136** : Création d'un GPO
- **5137** : Modification d'un GPO
- **5138** : Suppression d'un GPO


#### Active Directory
- **4662** : Opération effectuée sur un objet AD
- **5136** : Modification d'objet AD (attribut changé)
- **5137** : Création d'objet AD
- **5138** : Récupération d'objet AD depuis la corbeille
- **5139** : Déplacement d'objet AD
- **5141** : Suppression d'objet AD
- **5016** : Avertissement traitement GPO

### ⚙️ Système (System Log)

#### Services AD
- **1000** : Active Directory Web Services démarré
- **1202** : Promotion/rétrogradation DC (rare, événement de configuration)

> 💡 Les Event IDs de réplication (1925, 2042, 1963) ne s'appliquent qu'aux environnements multi-DC. Voir "Pour aller plus loin" en fin de chapitre.

---

## 🛠️ Outils Natifs de Monitoring

### 1. Event Viewer (Observateur d'événements)

Lancer l'observateur d'événements despuis le gestionnaire du serveur.
Cet outil vous permet de chercher dans les logs du système, tant les logs de Windows comme les logs des applications installées.

Vous pouvez observer directement les logs dans **Journaux Windows** et **Journaux des applications et des services**, ou bien créer un affichage personnalisé (ex: chercher tous les événements de verrouillage de compte, ou tous les événements de GPO echouée).


**Filtrage rapide :**

- Clic droit sur un log → **Filter Current Log**
- Sélectionner les Event IDs pertinents
- Sauvegarder comme **Custom View** pour réutilisation

### 2. PowerShell - Get-EventLog / Get-WinEvent

```powershell
# Récupérer les 10 derniers échecs de connexion
Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4625} -MaxEvents 10

# Comptes verrouillés dans les dernières 24h
$date = (Get-Date).AddDays(-1)
Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4740; StartTime=$date}

# Modifications de groupes privilégiés
Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4728,4732,4756} -MaxEvents 50
```

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

## 🎓 Bonnes Pratiques pour Débutants

### ✅ À FAIRE

1. **Établir une baseline** : Savoir ce qui est « normal » avant de détecter les anomalies (ex. : attaque par déni de service par quelqu'un qui simule beaucoup de connexions simultanées)
   ```powershell
   # Exemple: Combien de connexions/jour normalement ?
   $baseline = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4624} -MaxEvents 1000
   $baseline.Count / 7  # Moyenne sur 7 jours
   ```

2. **Créer des Custom Views dans Event Viewer** pour les événements fréquents
   - Security → Filter → Event IDs: 4625, 4740, 4728
   - Sauvegarder comme "Surveillance Sécurité Quotidienne"

3. **Documenter les alertes** : Tenir un journal des incidents
   ```
   Date | Event ID | Description | Action Prise | Résolu ?
   -----|----------|-------------|--------------|----------
   ```

4. **Tester les alertes** : Simuler des événements pour vérifier la détection
   ```powershell
   # Simuler un verrouillage (3 mauvais mots de passe)
   # Avec un compte de test bien sûr !
   ```

5. **Archiver les logs** : Politique de rétention claire
   - Security log : Minimum 90 jours
   - System log : 30 jours
   - Exporter régulièrement vers stockage sécurisé

### ❌ À ÉVITER

1. ❌ Alertes trop sensibles (alert fatigue — au bout de 50 fausses alertes, plus personne ne lit)
2. ❌ Ne pas sécuriser les logs (cible d'attaquants qui veulent effacer leurs traces)
3. ❌ Oublier de monitorer les admins eux-mêmes (un admin compromis ne déclenche aucune alerte standard)
4. ❌ Garder les logs avec une rétention par défaut (souvent 7 jours — insuffisant pour une investigation post-incident)

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

### Alertes automatiques par email sur événement

**Méthode : Planificateur de tâches + Event Trigger**

1. `taskschd.msc` → **Create Basic Task** → "Alert Account Lockout"
2. **Trigger** : "When a specific event is logged" → Log: Security, Event ID: 4740
3. **Action** : exécuter un script PowerShell qui envoie un email :

```powershell
$event = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4740} -MaxEvents 1
$user = $event.Properties[0].Value
$computer = $event.Properties[1].Value

Send-MailMessage -To "admin@entreprise.com" `
                 -From "dc01@entreprise.com" `
                 -Subject "⚠️ ALERTE: Compte verrouillé - $user" `
                 -Body "Compte: $user`nOrdinateur: $computer`nHeure: $($event.TimeCreated)" `
                 -SmtpServer "smtp.entreprise.com"
```

### Rapport quotidien automatisé

Un script PowerShell exécuté chaque matin via tâche planifiée agrège les événements importants des dernières 24 h. Squelette :

```powershell
$debut = (Get-Date).AddHours(-24)
$comptesCreated = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4720; StartTime=$debut} -ErrorAction SilentlyContinue
$verrouilles    = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4740; StartTime=$debut} -ErrorAction SilentlyContinue
$groupesModif   = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4728,4732,4756; StartTime=$debut} -ErrorAction SilentlyContinue
$echecs         = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4625; StartTime=$debut} -ErrorAction SilentlyContinue

Write-Host "Comptes créés       : $($comptesCreated.Count)"
Write-Host "Comptes verrouillés : $($verrouilles.Count)"
Write-Host "Modifs de groupes   : $($groupesModif.Count)"
Write-Host "Échecs de connexion : $($echecs.Count)"
```

À enrichir avec `Send-MailMessage` ou export CSV/HTML selon besoin.

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
- [Event Log Reference](https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/)

### Scripts Communautaires
- [AD Security Checks (GitHub)](https://github.com/canix1/ADACLScanner)
- [PowerShell Empire Detection](https://github.com/SigmaHQ/sigma)

---

## 📝 Points Clés à Retenir

1. **Le monitoring AD n'est pas optionnel** : C'est une nécessité de sécurité
2. **Commencer simple** : Event IDs critiques + PowerShell de base
3. **Automatiser progressivement** : Scripts → Tâches planifiées → SIEM (outils de centralisations d'alertes en temps réel)
4. **Documenter les baselines** : Savoir ce qui est normal
5. **Tester régulièrement** : Vérifier que les alertes fonctionnent
6. **Corrélation** : Un événement seul ne fait pas un incident

---

## 🧭 Navigation
[⏮️ Chapitre Précédent: Powershell AD - Création et Modification](Chapitre%209.3.Powershell%20AD%20-%20Creation_et_Modification.md) | [🏠 Retour au Syllabus](index.md)

---

**📚 Cours Active Directory - Monitoring | 👨‍💻 Pour débutants**


