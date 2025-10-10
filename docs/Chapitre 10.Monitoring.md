# Chapitre 10 - Surveillance et Monitoring Active Directory

## 📊 Objectifs d'apprentissage

À la fin de ce chapitre, vous serez capable de :
- Comprendre l'importance du monitoring dans Active Directory
- Identifier les événements critiques à surveiller
- Utiliser les outils natifs Windows pour le monitoring
- Configurer des alertes basiques
- Analyser les logs d'événements AD
- Détecter des anomalies de sécurité courantes

---

## 🎯 Pourquoi surveiller Active Directory ?

Active Directory est le **cœur de l'infrastructure IT** dans la plupart des entreprises. Une défaillance ou une compromission peut paralyser toute l'organisation.

### Scénarios critiques à détecter

| Scénario | Impact | Détection |
|----------|--------|-----------|
| **Comptes verrouillés en masse** | Perte de productivité, possible attaque brute force | Event ID 4740 |
| **Modification non autorisée de groupes** | Élévation de privilèges | Event ID 4728, 4732, 4756 |
| **Échecs d'authentification répétés** | Tentative d'intrusion | Event ID 4625 |
| **Réplication AD échouée** | Incohérence des données | Event ID 2042, 1925 |
| **Modification de GPO** | Changement de configuration critique | Event ID 5136, 5137 |

---

## 🔍 Les 3 Piliers du Monitoring AD

### 1️⃣ **Disponibilité** (Availability)
- Les contrôleurs de domaine sont-ils opérationnels ?
- Les services AD essentiels fonctionnent-ils ?
- La réplication fonctionne-t-elle correctement ?

### 2️⃣ **Performance** (Performance)
- Temps de réponse LDAP acceptable ?
- Charge CPU/Mémoire normale ?
- File d'attente de réplication sous contrôle ?

### 3️⃣ **Sécurité** (Security)
- Activités suspectes (connexions anormales) ?
- Modifications non autorisées ?
- Tentatives d'élévation de privilèges ?

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
- **1202** : Promotion/rétrogradation DC
- **1963** : Échec résolution DNS pour réplication
- **1925** : Échec de réplication
- **2042** : Réplication non effectuée depuis trop longtemps

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

### 3. Performance Monitor (PerfMon)

**Compteurs AD critiques :**

| Catégorie | Compteur | Seuil d'alerte |
|-----------|----------|----------------|
| **NTDS** | DRA Pending Replication Synchronizations | > 50 |
| **NTDS** | LDAP Client Sessions | Baseline à établir |
| **NTDS** | LDAP Searches/sec | > 200 peut indiquer une charge élevée |
| **Database** | Database Cache % Hit | < 90% (besoin de RAM) |
| **Processor** | % Processor Time | > 80% soutenu |
| **Memory** | Available MBytes | < 1 GB critique |

### 4. Active Directory Health Check (dcdiag)

```powershell
# Diagnostic complet du DC
dcdiag /v

# Tester la réplication (ne nous concerne pas, on n'a pas de replications)
# dcdiag /test:replications

# Vérifier la connectivité DNS
dcdiag /test:dns

# Tester les services AD
dcdiag /test:services
```

### 5. Replication Status (repadmin)

(Nous n'avons pas fait de replications pendant la formation)

```powershell
# Voir l'état de réplication
repadmin /replsummary

# Forcer la réplication
repadmin /syncall /AdeP

# Afficher les partenaires de réplication
repadmin /showrepl
```

---

## 🚨 Configuration d'Alertes Basiques

### Méthode 1 : Planificateur de tâches + Event Trigger

**Scénario : Alerte email sur verrouillage de compte**

1. **Ouvrir Planificateur de tâches** (`taskschd.msc`)
2. **Create Basic Task** → "Alert Account Lockout"
3. **Trigger** : "When a specific event is logged"
   - Log : Security
   - Source : Microsoft Windows Security Auditing
   - Event ID : 4740
4. **Action** : Send an email (nécessite configuration SMTP)
   - OU exécuter un script PowerShell :

```powershell
# C:\Scripts\Alert-AccountLockout.ps1
$event = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4740} -MaxEvents 1
$user = $event.Properties[0].Value
$computer = $event.Properties[1].Value

Send-MailMessage -To "admin@entreprise.com" `
                 -From "dc01@entreprise.com" `
                 -Subject "⚠️ ALERTE: Compte verrouillé - $user" `
                 -Body "Compte: $user`nOrdinateur: $computer`nHeure: $($event.TimeCreated)" `
                 -SmtpServer "smtp.entreprise.com"
```

### Méthode 2 : PowerShell Scheduled Job

```powershell
# Script de surveillance actif (à exécuter toutes les 15 min via tâche planifiée)
$depuis = (Get-Date).AddMinutes(-15)

# Vérifier les échecs de connexion massifs
$echecs = Get-WinEvent -FilterHashtable @{
    LogName='Security';
    ID=4625;
    StartTime=$depuis
} -ErrorAction SilentlyContinue

if ($echecs.Count -gt 20) {
    Write-Warning "⚠️ $($echecs.Count) échecs de connexion détectés en 15 minutes!"
    # Envoyer alerte
}

# Vérifier les modifications de groupes Admin
$modifGroupes = Get-WinEvent -FilterHashtable @{
    LogName='Security';
    ID=4728,4732,4756;
    StartTime=$depuis
} -ErrorAction SilentlyContinue | Where-Object {
    $_.Message -match "Domain Admins|Enterprise Admins|Schema Admins"
}

if ($modifGroupes) {
    Write-Warning "⚠️ CRITIQUE: Modification de groupe privilégié détecté!"
    # Envoyer alerte immédiate
}
```

---

## 📊 Reporting Basique

### Script : Rapport Quotidien de Sécurité

```powershell
# Rapport-Quotidien-AD.ps1
param(
    [int]$Heures = 24,
    [string]$EmailDest = "admin@entreprise.com"
)

$debut = (Get-Date).AddHours(-$Heures)
$rapport = @"
═══════════════════════════════════════════════
  RAPPORT QUOTIDIEN ACTIVE DIRECTORY
  Période: $debut à $(Get-Date)
═══════════════════════════════════════════════

"@

# 1. Comptes créés
$comptesCreated = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4720; StartTime=$debut} -ErrorAction SilentlyContinue
$rapport += "`n👤 COMPTES CRÉÉS: $($comptesCreated.Count)`n"
$comptesCreated | ForEach-Object {
    $rapport += "  - $($_.Properties[0].Value) à $($_.TimeCreated)`n"
}

# 2. Comptes verrouillés
$verrouilles = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4740; StartTime=$debut} -ErrorAction SilentlyContinue
$rapport += "`n🔒 COMPTES VERROUILLÉS: $($verrouilles.Count)`n"
$verrouilles | ForEach-Object {
    $rapport += "  - $($_.Properties[0].Value) verrouillé par $($_.Properties[1].Value)`n"
}

# 3. Modifications de groupes
$groupesModif = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4728,4732,4756; StartTime=$debut} -ErrorAction SilentlyContinue
$rapport += "`n👥 MODIFICATIONS DE GROUPES: $($groupesModif.Count)`n"

# 4. Échecs de connexion (top 5 utilisateurs)
$echecs = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4625; StartTime=$debut} -ErrorAction SilentlyContinue
$topEchecs = $echecs | Group-Object {$_.Properties[5].Value} | Sort-Object Count -Descending | Select-Object -First 5
$rapport += "`n❌ ÉCHECS DE CONNEXION: $($echecs.Count) total`n"
$topEchecs | ForEach-Object {
    $rapport += "  - $($_.Name): $($_.Count) échecs`n"
}

Write-Output $rapport

# Optionnel: Envoyer par email
# Send-MailMessage -To $EmailDest -From "dc01@entreprise.com" -Subject "Rapport AD Quotidien" -Body $rapport -SmtpServer "smtp.entreprise.com"
```

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

1. ❌ Ignorer les avertissements de réplication (ne nous concerne pas dans cette formation)
2. ❌ Ne surveiller qu'un seul DC (seulement si on en a plusieurs)
3. ❌ Alertes trop sensibles (alert fatigue)
4. ❌ Ne pas sécuriser les logs (cible d'attaquants)
5. ❌ Oublier de monitorer les admins eux-mêmes



## 🔗 Ressources Complémentaires

### Documentation Microsoft
- [Monitoring Active Directory](https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/monitoring-active-directory-for-signs-of-compromise)
- [Advanced Security Audit Policies](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/advanced-security-auditing)
- [Event Log Reference](https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/)

### Outils Tiers (Aperçu)
- **Netwrix Auditor** : Auditing AD complet (commercial)
- **ManageEngine ADAudit Plus** : Monitoring temps réel
- **Splunk** : SIEM pour agrégation logs
- **Graylog** : Alternative open-source à Splunk

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


