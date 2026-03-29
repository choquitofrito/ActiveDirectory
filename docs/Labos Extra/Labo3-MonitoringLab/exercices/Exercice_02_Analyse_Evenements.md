# Exercice 02 : Analyse des Événements de Sécurité

## Niveau de Difficulté

Débutant (Guidé)

## Objectifs Pédagogiques

- Utiliser l'Observateur d'événements Windows pour consulter les journaux de sécurité
- Identifier et interpréter les Event IDs critiques liés à l'authentification et aux modifications AD
- Créer des filtres personnalisés pour isoler des événements spécifiques

## Durée Estimée

60 minutes

## Prérequis

- Exercice 01 complété (connaissance de la structure du lab)
- Script `2_Generate-Events.ps1` exécuté pour peupler les journaux d'événements
- Accès au contrôleur de domaine avec un compte Administrateur

## Contexte / Scénario

!!! example "Scénario réel"
    Le responsable de la sécurité de MonitoringTech SPRL vous informe qu'il a reçu une alerte : plusieurs tentatives de connexion échouées ont été détectées ce matin. Votre mission est de consulter les journaux de sécurité du contrôleur de domaine pour identifier les comptes impliqués, les horaires, et évaluer si ces tentatives sont inquiétantes.

---

## Référence des Event IDs Importants

!!! info "Event IDs à connaître"
    | Event ID | Description | Criticité |
    |----------|-------------|-----------|
    | 4624 | Connexion réussie | Informatif |
    | 4625 | Échec de connexion | Important |
    | 4648 | Connexion avec credentials explicites | Important |
    | 4663 | Accès à un objet (fichier/dossier) | Selon contexte |
    | 4720 | Création d'un compte utilisateur | Critique |
    | 4722 | Activation d'un compte utilisateur | Important |
    | 4723 | Tentative de changement de mot de passe | Important |
    | 4740 | Compte verrouillé | Critique |
    | 4756 | Membre ajouté à un groupe universel | Important |

---

## Tâches à Réaliser

### Partie 1 : Générer des événements de test

#### Étape 1 : Exécuter le script de génération d'événements

!!! warning "Prérequis important"
    Avant de commencer l'analyse, des événements doivent être générés. Si ce n'est pas déjà fait, exécutez le script suivant sur le contrôleur de domaine.

1. Ouvrez PowerShell en tant qu'administrateur
2. Naviguez vers le dossier des scripts du lab
3. Exécutez :

```powershell
# Vérifier que des événements récents existent
$events = Get-WinEvent -LogName Security -MaxEvents 50 -ErrorAction SilentlyContinue
Write-Host "Nombre d'événements récents dans le journal Security : $($events.Count)"
```

!!! success "Résultat attendu"
    Le journal de sécurité contient des événements récents. Si le journal est vide, exécutez le script `2_Generate-Events.ps1`.

---

### Partie 2 : Exploration via l'Observateur d'Événements (GUI)

#### Étape 2 : Ouvrir l'Observateur d'événements

1. Cliquez sur **Démarrer**
2. Tapez `eventvwr.msc` et appuyez sur **Entrée**

!!! success "Résultat attendu"
    L'Observateur d'événements s'ouvre avec le volet de navigation à gauche.

#### Étape 3 : Accéder au journal de sécurité

1. Dans le volet gauche, développez **Journaux Windows**
2. Cliquez sur **Sécurité**

!!! success "Résultat attendu"
    Le volet central affiche les événements de sécurité. Vous pouvez voir des milliers d'entrées avec différents Event IDs.

!!! tip "Astuce"
    Les événements sont triés du plus récent au plus ancien. L'heure et la date sont visibles dans la colonne "Date et heure".

#### Étape 4 : Filtrer les échecs de connexion (Event ID 4625)

1. Dans le volet droit, cliquez sur **Filtrer le journal actuel...**
2. Dans le champ **ID d'événement**, tapez `4625`
3. Cliquez sur **OK**

!!! success "Résultat attendu"
    Le journal est filtré pour n'afficher que les échecs de connexion (Event ID 4625). Vous devriez voir plusieurs entrées générées par le script.

#### Étape 5 : Analyser un événement 4625

1. Double-cliquez sur l'un des événements 4625
2. Lisez attentivement le contenu dans l'onglet **Général**
3. Identifiez les informations suivantes :
    - **Nom du compte** (Account Name) : quel utilisateur a échoué à se connecter ?
    - **Nom du poste de travail** (Workstation Name) : depuis quel ordinateur ?
    - **Raison de l'échec** (Failure Reason) : pourquoi la connexion a-t-elle échoué ?
    - **Heure** : à quelle heure l'événement s'est-il produit ?
4. Notez ces informations sur papier ou dans un document texte
5. Fermez la fenêtre de l'événement

!!! success "Résultat attendu"
    Vous pouvez identifier le compte concerné, l'origine de la tentative et la raison de l'échec.

#### Étape 6 : Filtrer les connexions réussies (Event ID 4624)

1. Cliquez à nouveau sur **Filtrer le journal actuel...**
2. Effacez `4625` et tapez `4624`
3. Cliquez sur **OK**
4. Ouvrez un événement 4624 et identifiez :
    - Le nom du compte connecté
    - Le type d'ouverture de session (Logon Type)
    - L'heure de connexion

!!! info "Types d'ouverture de session courants"
    | Type | Description |
    |------|-------------|
    | 2 | Connexion interactive (localement à la machine) |
    | 3 | Connexion réseau |
    | 4 | Connexion en tant que service |
    | 5 | Connexion planifiée (tâche planifiée) |
    | 10 | Connexion à distance (Remote Desktop) |

#### Étape 7 : Rechercher les créations de comptes (Event ID 4720)

1. Filtrez sur l'Event ID `4720`
2. Si des événements existent, ouvrez-en un et identifiez :
    - Quel compte a été créé ?
    - Par qui a-t-il été créé (Subject Account Name) ?
    - À quelle heure ?

!!! tip "Astuce"
    L'Event ID 4720 est particulièrement important pour détecter des créations de comptes non autorisées.

---

### Partie 3 : Analyse via PowerShell

#### Étape 8 : Requêter les événements par Event ID

```powershell
# Récupérer les 20 derniers échecs de connexion
Write-Host "=== Derniers échecs de connexion (4625) ===" -ForegroundColor Red
Get-WinEvent -LogName Security -MaxEvents 1000 |
    Where-Object { $_.Id -eq 4625 } |
    Select-Object TimeCreated, Message |
    Select-Object -First 10 |
    Format-List
```

!!! success "Résultat attendu"
    Les 10 derniers échecs de connexion s'affichent avec leur date/heure et le message détaillé.

#### Étape 9 : Extraire des informations structurées

```powershell
# Analyser les événements 4625 avec extraction des champs XML
Write-Host "=== Analyse des Échecs de Connexion ===" -ForegroundColor Cyan

$failedLogons = Get-WinEvent -LogName Security -MaxEvents 2000 |
    Where-Object { $_.Id -eq 4625 } |
    Select-Object -First 20

foreach ($event in $failedLogons) {
    $xml = [xml]$event.ToXml()
    $data = $xml.Event.EventData.Data
    $targetUser = ($data | Where-Object { $_.Name -eq "TargetUserName" }).'#text'
    $workstation = ($data | Where-Object { $_.Name -eq "WorkstationName" }).'#text'
    $failureReason = ($data | Where-Object { $_.Name -eq "FailureReason" }).'#text'
    
    Write-Host "Heure: $($event.TimeCreated) | Compte: $targetUser | Poste: $workstation | Raison: $failureReason"
}
```

!!! success "Résultat attendu"
    Une liste formatée des échecs de connexion avec les informations clés extraites.

#### Étape 10 : Compter les échecs par compte utilisateur

```powershell
# Statistiques : quels comptes ont le plus d'échecs ?
Write-Host "=== Comptes avec le Plus d'Échecs de Connexion ===" -ForegroundColor Yellow

Get-WinEvent -LogName Security -MaxEvents 5000 |
    Where-Object { $_.Id -eq 4625 } |
    ForEach-Object {
        $xml = [xml]$_.ToXml()
        $data = $xml.Event.EventData.Data
        ($data | Where-Object { $_.Name -eq "TargetUserName" }).'#text'
    } |
    Where-Object { $_ -ne "-" -and $_ -ne "" } |
    Group-Object |
    Sort-Object Count -Descending |
    Select-Object -First 10 |
    Format-Table Name, Count -AutoSize
```

!!! success "Résultat attendu"
    Un classement des comptes ayant accumulé le plus d'échecs de connexion. Ce type de rapport est essentiel pour détecter des attaques par force brute.

#### Étape 11 : Rechercher les événements de la dernière heure

```powershell
# Événements critiques dans la dernière heure
$uneHeure = (Get-Date).AddHours(-1)
Write-Host "=== Événements Critiques de la Dernière Heure ===" -ForegroundColor Magenta

$evenementsCritiques = @(4625, 4720, 4740, 4648)
Get-WinEvent -LogName Security |
    Where-Object { $_.TimeCreated -gt $uneHeure -and $_.Id -in $evenementsCritiques } |
    Select-Object TimeCreated, Id, Message |
    Sort-Object TimeCreated -Descending |
    Format-List
```

!!! success "Résultat attendu"
    Tous les événements critiques de la dernière heure s'affichent. En dehors des heures de bureau, ce type de requête permet de détecter des activités suspectes.

---

## Vérification de la Réussite

### Commandes PowerShell de Vérification

```powershell
# Vérifier que le journal de sécurité contient des événements analysables
$eventIds = @(4624, 4625)
foreach ($id in $eventIds) {
    $count = (Get-WinEvent -LogName Security -MaxEvents 5000 |
        Where-Object { $_.Id -eq $id }).Count
    Write-Host "Event ID $id trouvé : $count occurrence(s)" -ForegroundColor Cyan
}
```

### Critères de Réussite

- [ ] Vous avez ouvert le journal de Sécurité dans l'Observateur d'événements
- [ ] Vous avez filtré et identifié au moins 3 événements 4625 (échecs de connexion)
- [ ] Vous avez extrait les informations clés d'un événement 4625 (compte, poste, raison)
- [ ] Vous avez identifié les différents types de Logon (Logon Type)
- [ ] Vous avez exécuté les commandes PowerShell et obtenu des résultats cohérents
- [ ] Vous savez à quoi correspondent les Event IDs 4624, 4625, 4720 et 4740

---

## Solution Complète (Pour Instructeur)

### Méthode GUI

Navigation dans l'Observateur d'événements :

1. `eventvwr.msc` > Journaux Windows > Sécurité
2. Filtrer le journal actuel > saisir l'Event ID souhaité
3. Double-cliquer sur un événement pour lire les détails

Points pédagogiques à souligner :

- La différence entre l'onglet "Général" (lisible) et l'onglet "XML" (données brutes)
- L'importance de noter l'heure, le compte et l'origine de chaque événement
- La nécessité de filtrer car le journal peut contenir des milliers d'événements

### Méthode PowerShell

```powershell
# Solution complète d'analyse des événements
Import-Module ActiveDirectory

# Fonction utilitaire pour extraire les données XML d'un événement
function Get-EventData {
    param($Event, $FieldName)
    $xml = [xml]$Event.ToXml()
    $data = $xml.Event.EventData.Data
    return ($data | Where-Object { $_.Name -eq $FieldName }).'#text'
}

# Rapport complet des événements des dernières 24h
$hier = (Get-Date).AddHours(-24)

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "RAPPORT D'AUDIT - MonitoringTech SPRL" -ForegroundColor Cyan
Write-Host "Période : Dernières 24 heures" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# 1. Connexions réussies
$logons = Get-WinEvent -LogName Security |
    Where-Object { $_.Id -eq 4624 -and $_.TimeCreated -gt $hier } |
    Select-Object -First 50
Write-Host "Connexions réussies (4624) : $($logons.Count)" -ForegroundColor Green

# 2. Échecs de connexion
$failedLogons = Get-WinEvent -LogName Security |
    Where-Object { $_.Id -eq 4625 -and $_.TimeCreated -gt $hier }
Write-Host "Échecs de connexion (4625) : $($failedLogons.Count)" -ForegroundColor Red

# 3. Comptes verrouillés
$locked = Get-WinEvent -LogName Security |
    Where-Object { $_.Id -eq 4740 -and $_.TimeCreated -gt $hier }
Write-Host "Comptes verrouillés (4740) : $($locked.Count)" -ForegroundColor DarkRed

# 4. Comptes créés
$created = Get-WinEvent -LogName Security |
    Where-Object { $_.Id -eq 4720 -and $_.TimeCreated -gt $hier }
Write-Host "Comptes créés (4720) : $($created.Count)" -ForegroundColor Yellow
```

---

## Points Clés à Retenir

- Le journal de Sécurité du contrôleur de domaine est la source principale d'information pour l'audit AD
- Les Event IDs 4625 (échec connexion) et 4740 (verrouillage) sont des signaux d'alerte importants pour détecter des attaques
- PowerShell permet d'automatiser l'analyse des journaux et de produire des rapports structurés
- L'analyse régulière des journaux (idéalement automatisée) est une bonne pratique de sécurité fondamentale

## Dépannage (Erreurs Courantes)

| Erreur Possible | Cause | Solution |
|-----------------|-------|----------|
| "Accès refusé" au journal Security | Droits insuffisants | Exécuter PowerShell en tant qu'administrateur |
| Journal vide ou peu d'événements | Audit non configuré ou journaux effacés | Exécuter `2_Generate-Events.ps1` pour générer des événements |
| `Get-WinEvent` retourne une erreur | Module non disponible ou journal inexistant | Vérifier le nom exact du journal : "Security" (avec majuscule) |
| Événements trop anciens | Taille du journal dépassée | Augmenter la taille du journal : clic droit sur Security > Propriétés |

## Exercice Suivant Suggéré

**Exercice 03 - Configuration des GPOs de Sécurité** : Maintenant que vous savez analyser les événements, vous allez configurer des politiques de groupe pour renforcer la sécurité et faciliter l'audit dans MonitoringTech SPRL.
