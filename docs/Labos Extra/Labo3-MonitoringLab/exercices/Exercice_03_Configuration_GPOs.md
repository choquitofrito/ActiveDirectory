# Exercice 03 : Configuration des GPOs de Sécurité et d'Audit

## Niveau de Difficulté

Intermédiaire

## Objectifs Pédagogiques

- Identifier les GPO shells créées par le setup et leur emplacement dans la hiérarchie AD
- Configurer manuellement des stratégies de groupe via la console GPMC en respectant la règle de ne jamais utiliser `Set-GPRegistryValue` pour des politiques Windows standard
- Configurer la politique de mots de passe du domaine via PowerShell
- Vérifier l'application des GPOs avec `gpresult` et `gpupdate`

## Durée Estimée

75 minutes

## Prérequis

- Exercices 01 et 02 complétés
- La console GPMC (Group Policy Management Console) est disponible sur le DC
- PowerShell avec le module GroupPolicy importé
- Le lab a été créé via `MonitoringLab_Setup.ps1` — les 3 GPO shells listées ci-dessous existent déjà

## Contexte / Scénario

!!! example "Scénario réel"
    Le RSSI (Responsable de la Sécurité des Systèmes d'Information) de MonitoringTech SPRL vous a remis une liste de contrôles de sécurité à implémenter via les GPOs. Le script de création du lab a déjà créé les **3 GPO shells (vides)** et les a liées aux bonnes OUs. Votre mission est de les configurer manuellement dans GPMC selon les exigences de sécurité de l'entreprise, puis de configurer la politique de mots de passe du domaine via PowerShell.

---

## Vue d'Ensemble des GPOs à Configurer

!!! info "GPO shells présentes dans le lab (créées par le setup)"
    | Nom de la GPO | OU cible | À configurer manuellement |
    |---------------|----------|----------------------------|
    | `MONITORING - Configuration Journaux Événements` | `OU=MONITORING` | Taille max des journaux Security (2 GB), Application (512 MB), System (512 MB) |
    | `MONITORING - Restrictions Stations Sensibles` | `OU=Computers,OU=Security` + `OU=Computers,OU=ITOperations` | Blocage de tous les périphériques USB amovibles |
    | `MONITORING - Verrouillage Session Automatique` | `OU=MONITORING` | Verrouillage automatique après 10 minutes d'inactivité |

Plus une **politique de mots de passe** à configurer via PowerShell (`Set-ADDefaultDomainPasswordPolicy`).

---

## Tâches à Réaliser

### Partie 1 : Vérifier les GPO shells existantes

#### Tâche 1.1 : Lister les GPOs du lab

Objectif : Identifier les 3 GPOs créées par le script.

```powershell
# Lister toutes les GPOs MONITORING
Get-GPO -All | Where-Object { $_.DisplayName -like "MONITORING -*" } |
    Select-Object DisplayName, GpoStatus, CreationTime |
    Format-Table -AutoSize
```

!!! success "Résultat attendu"
    Vous voyez les 3 GPOs `MONITORING - ...`. Leur statut est "AllSettingsEnabled" mais elles n'ont aucun paramètre configuré (les shells).

#### Tâche 1.2 : Vérifier les liens des GPOs

```powershell
# Vérifier les liens GPO sur l'OU MONITORING
Get-GPInheritance -Target "OU=MONITORING,DC=maxtec,DC=be" |
    Select-Object -ExpandProperty GpoLinks |
    Select-Object DisplayName, Enabled, Enforced, Order |
    Format-Table -AutoSize

# Vérifier les liens sur les OUs Computers sensibles
Get-GPInheritance -Target "OU=Computers,OU=Security,OU=MONITORING,DC=maxtec,DC=be" |
    Select-Object -ExpandProperty GpoLinks |
    Format-Table -AutoSize

Get-GPInheritance -Target "OU=Computers,OU=ITOperations,OU=MONITORING,DC=maxtec,DC=be" |
    Select-Object -ExpandProperty GpoLinks |
    Format-Table -AutoSize
```

!!! success "Résultat attendu"
    - `Configuration Journaux Événements` et `Verrouillage Session Automatique` sont liées à `OU=MONITORING`
    - `Restrictions Stations Sensibles` est liée aux deux OUs Computers (Security et ITOperations)

---

### Partie 2 : Configurer la politique de mots de passe (PowerShell)

!!! info "Information"
    La politique de mots de passe du domaine peut être configurée via PowerShell avec `Set-ADDefaultDomainPasswordPolicy`. C'est l'une des rares politiques que l'on peut configurer directement par PowerShell (hors GPMC).

#### Tâche 2.1 : Configurer la politique de mots de passe du domaine

Objectif : Configurer une politique de mots de passe forte pour MonitoringTech SPRL.

**Contraintes** :

- Longueur minimale : 12 caractères
- Complexité activée (majuscules, minuscules, chiffres, caractères spéciaux)
- Âge maximum : 90 jours
- Âge minimum : 1 jour
- Historique : 12 mots de passe mémorisés
- Seuil de verrouillage : 5 tentatives
- Durée de verrouillage : 30 minutes

**Indice** : Utilisez `Set-ADDefaultDomainPasswordPolicy` avec les paramètres `-MinPasswordLength`, `-ComplexityEnabled`, `-MaxPasswordAge`, etc.

!!! warning "Attention"
    Cette commande affecte tous les utilisateurs du domaine. Dans un environnement de production, cette modification doit être validée par le responsable sécurité.

Vérification après configuration :

```powershell
Get-ADDefaultDomainPasswordPolicy -Identity "maxtec.be" |
    Select-Object MinPasswordLength, ComplexityEnabled, MaxPasswordAge,
                  PasswordHistoryCount, LockoutThreshold, LockoutDuration |
    Format-List
```

!!! success "Résultat attendu"
    Les valeurs configurées correspondent aux contraintes demandées.

---

### Partie 3 : Configurer la taille des journaux d'événements (GPMC)

La GPO `MONITORING - Configuration Journaux Événements` doit configurer la taille des journaux Windows pour éviter que les événements importants soient écrasés trop vite. C'est critique pour l'investigation forensique.

!!! warning "Règle importante"
    Pour ces paramètres, vous devez utiliser GPMC manuellement. N'utilisez PAS `Set-GPRegistryValue`.

#### Tâche 3.1 : Ouvrir la GPO dans l'éditeur

1. Cliquez sur **Démarrer** et tapez `gpmc.msc`, puis appuyez sur **Entrée**
2. Développez : `Forêt : maxtec.be` > `Domaines` > `maxtec.be` > `Objets de stratégie de groupe`
3. Faites un clic droit sur **MONITORING - Configuration Journaux Événements** > **Modifier...**

!!! success "Résultat attendu"
    L'éditeur de stratégie de groupe (Group Policy Management Editor) s'ouvre.

#### Tâche 3.2 : Configurer la taille du journal Sécurité (2 GB)

Naviguez vers :

`Configuration ordinateur > Stratégies > Modèles d'administration > Composants Windows > Service Journal d'événements > Sécurité`

1. Double-cliquez sur **Spécifier la taille maximale du fichier journal (Ko)**
2. Sélectionnez **Activé**
3. Dans la zone de texte, entrez **2097151** (≈ 2 GB)
4. Cliquez sur **OK**

5. Double-cliquez sur **Contrôler le comportement du journal d'événements lorsque le fichier journal atteint sa taille maximale**
6. Sélectionnez **Activé**
7. Choisissez **Remplacer les événements selon les besoins (les plus anciens d'abord)**
8. Cliquez sur **OK**

#### Tâche 3.3 : Configurer la taille des journaux Application et Système (512 MB)

Dans la même GPO :

`Configuration ordinateur > Stratégies > Modèles d'administration > Composants Windows > Service Journal d'événements > Application`

1. Double-cliquez sur **Spécifier la taille maximale du fichier journal (Ko)**
2. **Activé**, valeur : **524288** (512 MB)

Puis sous `Service Journal d'événements > Système` :

3. Même paramètre, même valeur : **524288**

4. Fermez l'éditeur de stratégie de groupe.

!!! success "Résultat attendu"
    Les 3 paramètres de taille de journal sont configurés dans la GPO.

#### Tâche 3.4 : Forcer l'application et vérifier

```powershell
# Forcer la mise à jour
gpupdate /force

# Vérifier la taille effective du journal Sécurité (devrait être ≈ 2 GB)
Get-WinEvent -ListLog Security | Select-Object LogName, MaximumSizeInBytes, IsEnabled

# Idem pour Application et System
Get-WinEvent -ListLog Application, System | Select-Object LogName, MaximumSizeInBytes
```

!!! tip "Conversion"
    2097151 Ko ≈ 2 147 482 624 octets ≈ 2 GB
    524288 Ko ≈ 536 870 912 octets ≈ 512 MB

---

### Partie 4 : Bloquer les périphériques USB amovibles (GPMC)

La GPO `MONITORING - Restrictions Stations Sensibles` doit bloquer toute connexion de périphérique USB amovible sur les stations des départements Security et IT Operations.

#### Tâche 4.1 : Ouvrir la GPO

1. Dans GPMC, clic droit sur **MONITORING - Restrictions Stations Sensibles** > **Modifier...**

#### Tâche 4.2 : Activer le blocage des périphériques amovibles

Naviguez vers :

`Configuration ordinateur > Stratégies > Modèles d'administration > Système > Accès au stockage amovible`

1. Double-cliquez sur **Toutes les classes de stockage amovibles : Refuser tous les accès**
2. Sélectionnez **Activé**
3. Cliquez sur **OK**
4. Fermez l'éditeur.

!!! success "Résultat attendu"
    Le paramètre apparaît avec l'état "Activé" dans le panneau central de l'éditeur.

#### Tâche 4.3 : Vérifier

1. Forcez la mise à jour avec `gpupdate /force` sur un poste lié (ex. `MON-WS-SEC01`).
2. Connectez une clé USB physique ou simulée — l'accès doit être refusé avec un message Windows.

---

### Partie 5 : Verrouillage automatique des sessions inactives (GPMC)

La GPO `MONITORING - Verrouillage Session Automatique` doit forcer le verrouillage de l'écran après 10 minutes d'inactivité.

#### Tâche 5.1 : Ouvrir la GPO

1. Dans GPMC, clic droit sur **MONITORING - Verrouillage Session Automatique** > **Modifier...**

#### Tâche 5.2 : Configurer le délai d'inactivité

Naviguez vers :

`Configuration ordinateur > Stratégies > Paramètres Windows > Paramètres de sécurité > Stratégies locales > Options de sécurité`

1. Double-cliquez sur **Ouverture de session interactive : limite d'inactivité de l'ordinateur**
2. Cochez **Définir ce paramètre de stratégie**
3. Entrez **600** secondes (10 minutes)
4. Cliquez sur **OK**
5. Fermez l'éditeur.

!!! success "Résultat attendu"
    Le paramètre apparaît avec la valeur "600" dans la GPO.

---

### Partie 6 : Forcer l'application et vérifier l'ensemble

#### Tâche 6.1 : Forcer la mise à jour

Sur le contrôleur de domaine et sur un poste client :

```powershell
gpupdate /force
```

!!! success "Résultat attendu"
    Le message "La mise à jour de la stratégie de l'ordinateur s'est terminée correctement." s'affiche.

#### Tâche 6.2 : Vérifier l'application avec gpresult

```powershell
# Rapport RSoP pour l'ordinateur local
gpresult /r /scope computer
```

!!! success "Résultat attendu"
    Le rapport affiche les GPOs `MONITORING - ...` parmi les "Objets de stratégie de groupe appliqués".

!!! tip "Astuce"
    Pour un rapport HTML détaillé : `gpresult /h C:\Temp\gpresult.html` puis ouvrez le fichier dans un navigateur.

---

## Vérification de la Réussite

### Commandes PowerShell de Vérification

```powershell
# Vérifier la politique de mots de passe
$pwdPolicy = Get-ADDefaultDomainPasswordPolicy -Identity "maxtec.be"
Write-Host "Longueur minimale : $($pwdPolicy.MinPasswordLength) (attendu : 12)" -ForegroundColor $(if ($pwdPolicy.MinPasswordLength -ge 12) { "Green" } else { "Red" })
Write-Host "Complexité : $($pwdPolicy.ComplexityEnabled) (attendu : True)" -ForegroundColor $(if ($pwdPolicy.ComplexityEnabled) { "Green" } else { "Red" })
Write-Host "Seuil de verrouillage : $($pwdPolicy.LockoutThreshold) (attendu : 5)" -ForegroundColor $(if ($pwdPolicy.LockoutThreshold -eq 5) { "Green" } else { "Red" })

# Vérifier que les 3 GPOs MONITORING existent
$gpos = Get-GPO -All | Where-Object { $_.DisplayName -like "MONITORING -*" }
Write-Host "`nGPOs MONITORING trouvées : $($gpos.Count) (attendu : 3)" -ForegroundColor Cyan

# Vérifier la taille du journal Sécurité
$secLog = Get-WinEvent -ListLog Security
$secSizeGB = [math]::Round($secLog.MaximumSizeInBytes / 1GB, 2)
Write-Host "Taille max journal Sécurité : $secSizeGB GB (attendu : ~2 GB)" -ForegroundColor $(if ($secSizeGB -ge 1.9) { "Green" } else { "Yellow" })
```

### Critères de Réussite

- [ ] La politique de mots de passe du domaine a une longueur minimale de 12 caractères et la complexité est activée
- [ ] La GPO `MONITORING - Configuration Journaux Événements` configure les 3 journaux (Security 2 GB, App 512 MB, System 512 MB) avec overwrite-as-needed
- [ ] La GPO `MONITORING - Restrictions Stations Sensibles` active "Toutes les classes de stockage amovibles : Refuser tous les accès"
- [ ] La GPO `MONITORING - Verrouillage Session Automatique` définit la limite d'inactivité à 600 secondes
- [ ] `gpupdate /force` s'exécute sans erreur
- [ ] `gpresult /r` montre les GPOs `MONITORING - ...` comme appliquées
- [ ] `Get-WinEvent -ListLog Security` confirme la nouvelle taille du journal Sécurité

---

## Solution Complète (Pour Instructeur)

### Méthode PowerShell (Politique de mots de passe uniquement)

```powershell
# Configuration de la politique de mots de passe - SEULE partie 100% PowerShell
Set-ADDefaultDomainPasswordPolicy -Identity "maxtec.be" `
    -MinPasswordLength 12 `
    -ComplexityEnabled $true `
    -MaxPasswordAge (New-TimeSpan -Days 90) `
    -MinPasswordAge (New-TimeSpan -Days 1) `
    -PasswordHistoryCount 12 `
    -LockoutThreshold 5 `
    -LockoutDuration (New-TimeSpan -Minutes 30) `
    -LockoutObservationWindow (New-TimeSpan -Minutes 30)

Write-Host "Politique de mots de passe configurée." -ForegroundColor Green
```

### Méthode GUI (GPMC) — Chemins de navigation exacts

**GPO `MONITORING - Configuration Journaux Événements`** :

- Taille Sécurité 2 GB :
  `Configuration ordinateur > Stratégies > Modèles d'administration > Composants Windows > Service Journal d'événements > Sécurité > Spécifier la taille maximale du fichier journal (Ko)` = Activé, **2097151**
- Comportement quand plein :
  `... > Service Journal d'événements > Sécurité > Contrôler le comportement du journal d'événements...` = Activé, **Remplacer les événements selon les besoins**
- Application 512 MB : `... > Service Journal d'événements > Application > Spécifier la taille...` = Activé, **524288**
- Système 512 MB : `... > Service Journal d'événements > Système > Spécifier la taille...` = Activé, **524288**

**GPO `MONITORING - Restrictions Stations Sensibles`** :

- `Configuration ordinateur > Stratégies > Modèles d'administration > Système > Accès au stockage amovible > Toutes les classes de stockage amovibles : Refuser tous les accès` = **Activé**

**GPO `MONITORING - Verrouillage Session Automatique`** :

- `Configuration ordinateur > Stratégies > Paramètres Windows > Paramètres de sécurité > Stratégies locales > Options de sécurité > Ouverture de session interactive : limite d'inactivité de l'ordinateur` = **600** secondes

---

## Points Clés à Retenir

- `Set-GPRegistryValue` ne doit JAMAIS être utilisé pour les politiques Windows standard : cela crée des entrées invalides visibles dans GPMC comme "nom convivial introuvable"
- La politique de mots de passe du domaine est l'une des seules politiques de sécurité configurables directement via PowerShell (`Set-ADDefaultDomainPasswordPolicy`)
- La taille du journal Sécurité (2 GB) est dimensionnée pour conserver plusieurs semaines d'historique sur un DC à charge modérée — sans ça, les événements importants sont écrasés en quelques heures
- Bloquer l'USB sur les stations sensibles (Security + IT Ops) est une mesure DLP (Data Loss Prevention) classique
- Toujours exécuter `gpupdate /force` après modification d'une GPO et vérifier avec `gpresult /r`

## Dépannage (Erreurs Courantes)

| Erreur Possible | Cause | Solution |
|-----------------|-------|----------|
| GPO ne s'applique pas après `gpupdate` | Lien GPO manquant ou désactivé | Vérifier dans GPMC que le lien est activé sur la bonne OU |
| "Le module GroupPolicy n'est pas chargé" | Module RSAT manquant | `Import-Module GroupPolicy` ou installer RSAT GPO Tools |
| Paramètre Event Log Service introuvable | Mauvaise navigation | Vérifier le chemin exact : *Composants Windows > Service Journal d'événements* (pas "Service de journalisation") |
| Le journal Sécurité ne dépasse pas 2 GB | Lien GPO sur la mauvaise OU | Vérifier que la GPO est liée à `OU=MONITORING` (ou parente), redémarrer le service Event Log |
| `Set-ADDefaultDomainPasswordPolicy` échoue | Droits insuffisants ou domaine incorrect | Vérifier d'être admin du domaine et que le nom de domaine est exact |

## Exercice Suivant Suggéré

**Exercice 04 — Gestion des Comptes de Service** : Vous allez sécuriser les 4 comptes de service existants, créer un groupe de sécurité dédié et leur attribuer les permissions minimales pour leurs tâches de monitoring.
