# Exercice 03 : Configuration des GPOs de Sécurité et d'Audit

## Niveau de Difficulté

Intermédiaire

## Objectifs Pédagogiques

- Créer et lier des GPO shells via PowerShell en respectant la règle de ne jamais utiliser `Set-GPRegistryValue` pour des politiques Windows standard
- Configurer manuellement des stratégies de groupe via la console GPMC
- Vérifier l'application des GPOs avec `gpresult` et `gpupdate`

## Durée Estimée

75 minutes

## Prérequis

- Exercices 01 et 02 complétés
- La console GPMC (Group Policy Management Console) est disponible sur le DC
- PowerShell avec le module GroupPolicy importé
- Le lab a été créé avec des GPO shells déjà présentes

## Contexte / Scénario

!!! example "Scénario réel"
    Le RSSI (Responsable de la Sécurité des Systèmes d'Information) de MonitoringTech SPRL vous a remis une liste de contrôles de sécurité à implémenter via les GPOs. Le script de création du lab a déjà créé les GPO shells (vides). Votre mission est de les configurer manuellement dans GPMC selon les exigences de sécurité de l'entreprise.

---

## Vue d'Ensemble des GPOs à Configurer

!!! info "GPOs présentes dans le lab"
    | Nom de la GPO | OU cible | À configurer |
    |---------------|----------|-------------|
    | MonitoringTech - Audit Avancé | OU=MONITORING | Audit de connexion et gestion de comptes |
    | MonitoringTech - Restrictions Utilisateurs | OU=Users de chaque dept | Blocage Panneau de configuration |
    | MonitoringTech - Politique Mots de Passe | Domaine (via PowerShell) | Longueur, complexité, verrouillage |

---

## Tâches à Réaliser

### Partie 1 : Vérifier les GPO shells existantes

#### Tâche 1.1 : Lister les GPOs du lab

Objectif : Identifier les GPOs déjà créées par le script.

```powershell
# Lister toutes les GPOs liées à MonitoringTech
Get-GPO -All | Where-Object { $_.DisplayName -like "MonitoringTech*" } |
    Select-Object DisplayName, GpoStatus, CreationTime |
    Format-Table -AutoSize
```

!!! success "Résultat attendu"
    Vous voyez au moins 2 GPOs dont le nom commence par "MonitoringTech". Leur statut indique qu'elles sont actives mais non configurées.

#### Tâche 1.2 : Vérifier les liens des GPOs

```powershell
# Vérifier les liens GPO sur l'OU MONITORING
Get-GPInheritance -Target "OU=MONITORING,DC=maxtec,DC=be" |
    Select-Object -ExpandProperty GpoLinks |
    Select-Object DisplayName, Enabled, Enforced, Order |
    Format-Table -AutoSize
```

!!! success "Résultat attendu"
    Les GPOs sont liées à l'OU MONITORING avec le statut "Enabled : True".

---

### Partie 2 : Configurer la politique de mots de passe (PowerShell)

#### Tâche 2.1 : Configurer la politique de mots de passe du domaine

!!! info "Information"
    La politique de mots de passe du domaine peut être configurée via PowerShell avec `Set-ADDefaultDomainPasswordPolicy`. C'est l'une des rares politiques que l'on peut configurer directement par PowerShell (hors GPMC).

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

### Partie 3 : Configurer l'audit avancé via GPMC

!!! warning "Règle importante"
    Pour les politiques d'audit avancé, vous devez utiliser la console GPMC manuellement. N'utilisez PAS `Set-GPRegistryValue` pour ces paramètres.

#### Tâche 3.1 : Ouvrir GPMC et localiser la GPO d'audit

1. Cliquez sur **Démarrer** et tapez `gpmc.msc`
2. Appuyez sur **Entrée** pour ouvrir la console de Gestion des stratégies de groupe
3. Développez : `Forêt : maxtec.be` > `Domaines` > `maxtec.be`
4. Cliquez sur **Objets de stratégie de groupe**
5. Trouvez la GPO **MonitoringTech - Audit Avancé**

!!! success "Résultat attendu"
    Vous voyez la GPO dans la liste. Elle est actuellement vide (aucun paramètre configuré).

#### Tâche 3.2 : Modifier la GPO d'audit

1. Cliquez avec le bouton droit sur **MonitoringTech - Audit Avancé**
2. Choisissez **Modifier...**
3. L'éditeur de stratégie de groupe s'ouvre

#### Tâche 3.3 : Activer l'audit des connexions

Dans l'éditeur de stratégie de groupe :

1. Naviguez vers :
   `Configuration ordinateur` > `Paramètres Windows` > `Paramètres de sécurité` > `Configuration avancée de la stratégie d'audit` > `Stratégies d'audit` > `Ouverture/Fermeture de session`

2. Double-cliquez sur **Auditer l'ouverture de session**
3. Cochez **Configurer les événements d'audit suivants**
4. Cochez **Succès** ET **Échec**
5. Cliquez sur **OK**

!!! success "Résultat attendu"
    Le paramètre "Auditer l'ouverture de session" affiche "Succès et Échec" dans la liste.

#### Tâche 3.4 : Activer l'audit de la gestion des comptes

Dans la même GPO, naviguez vers :
`Configuration ordinateur` > `Paramètres Windows` > `Paramètres de sécurité` > `Configuration avancée de la stratégie d'audit` > `Stratégies d'audit` > `Gestion des comptes`

1. Double-cliquez sur **Auditer la gestion des comptes d'utilisateurs**
2. Cochez **Configurer les événements d'audit suivants**
3. Cochez **Succès** ET **Échec**
4. Cliquez sur **OK**

!!! success "Résultat attendu"
    Le paramètre affiche "Succès et Échec".

#### Tâche 3.5 : Activer l'audit des changements de politique

Dans la même GPO :
`Configuration ordinateur` > `Paramètres Windows` > `Paramètres de sécurité` > `Configuration avancée de la stratégie d'audit` > `Stratégies d'audit` > `Modification de stratégie`

1. Double-cliquez sur **Auditer la modification de la stratégie d'audit**
2. Activez **Succès** ET **Échec**
3. Cliquez sur **OK**
4. Fermez l'éditeur de stratégie de groupe

!!! success "Résultat attendu"
    Les 3 paramètres d'audit sont configurés dans la GPO.

---

### Partie 4 : Configurer les restrictions utilisateurs via GPMC

#### Tâche 4.1 : Modifier la GPO de restrictions

1. Dans GPMC, trouvez et cliquez avec le bouton droit sur **MonitoringTech - Restrictions Utilisateurs**
2. Choisissez **Modifier...**

#### Tâche 4.2 : Bloquer l'accès au Panneau de configuration

!!! warning "Attention"
    Cette restriction s'appliquera aux utilisateurs des départements concernés. Ne l'activez que si vous comprenez son impact.

Naviguez vers :
`Configuration utilisateur` > `Stratégies` > `Modèles d'administration` > `Panneau de configuration`

1. Double-cliquez sur **Interdire l'accès au Panneau de configuration et aux paramètres du PC**
2. Sélectionnez **Activé**
3. Cliquez sur **OK**

!!! success "Résultat attendu"
    Le paramètre affiche "Activé" dans la liste.

#### Tâche 4.3 : Bloquer l'accès à l'invite de commandes

Dans la même GPO, naviguez vers :
`Configuration utilisateur` > `Stratégies` > `Modèles d'administration` > `Système`

1. Double-cliquez sur **Empêcher l'accès à l'invite de commandes**
2. Sélectionnez **Activé**
3. Dans l'option "Désactiver également le traitement des scripts de l'invite de commandes ?", choisissez **Non** (pour ne pas bloquer les scripts système)
4. Cliquez sur **OK**
5. Fermez l'éditeur de stratégie de groupe

!!! success "Résultat attendu"
    Les 2 restrictions sont configurées dans la GPO.

---

### Partie 5 : Forcer l'application des GPOs

#### Tâche 5.1 : Forcer la mise à jour des GPOs

Sur le contrôleur de domaine, ouvrez PowerShell et exécutez :

```powershell
# Forcer la mise à jour des GPOs localement
gpupdate /force
```

!!! success "Résultat attendu"
    Le message "La mise à jour de la stratégie de l'ordinateur s'est terminée correctement." s'affiche.

#### Tâche 5.2 : Vérifier l'application avec gpresult

```powershell
# Afficher un rapport RSoP (Resultant Set of Policy) pour l'ordinateur local
gpresult /r /scope computer
```

!!! success "Résultat attendu"
    Le rapport affiche les GPOs appliquées, dont **MonitoringTech - Audit Avancé**.

!!! tip "Astuce"
    Pour générer un rapport HTML complet : `gpresult /h C:\Temp\gpresult.html` puis ouvrez le fichier dans un navigateur.

---

## Vérification de la Réussite

### Commandes PowerShell de Vérification

```powershell
# Vérifier la politique de mots de passe
$pwdPolicy = Get-ADDefaultDomainPasswordPolicy -Identity "maxtec.be"
Write-Host "Longueur minimale : $($pwdPolicy.MinPasswordLength) (attendu : 12)" -ForegroundColor $(if ($pwdPolicy.MinPasswordLength -ge 12) { "Green" } else { "Red" })
Write-Host "Complexité : $($pwdPolicy.ComplexityEnabled) (attendu : True)" -ForegroundColor $(if ($pwdPolicy.ComplexityEnabled) { "Green" } else { "Red" })
Write-Host "Seuil de verrouillage : $($pwdPolicy.LockoutThreshold) (attendu : 5)" -ForegroundColor $(if ($pwdPolicy.LockoutThreshold -eq 5) { "Green" } else { "Red" })

# Vérifier que les GPOs MonitoringTech existent
$gpos = Get-GPO -All | Where-Object { $_.DisplayName -like "MonitoringTech*" }
Write-Host "`nGPOs MonitoringTech trouvées : $($gpos.Count)" -ForegroundColor Cyan
```

### Critères de Réussite

- [ ] La politique de mots de passe du domaine a une longueur minimale de 12 caractères
- [ ] La complexité est activée et le seuil de verrouillage est à 5
- [ ] La GPO "MonitoringTech - Audit Avancé" est configurée avec Succès et Échec pour les connexions
- [ ] La GPO "MonitoringTech - Restrictions Utilisateurs" bloque le Panneau de configuration
- [ ] `gpupdate /force` s'exécute sans erreur
- [ ] `gpresult /r` montre les GPOs MonitoringTech comme appliquées

---

## Solution Complète (Pour Instructeur)

### Méthode PowerShell (Politique de mots de passe uniquement)

```powershell
# Configuration de la politique de mots de passe - SEULE partie faisable en PowerShell
Set-ADDefaultDomainPasswordPolicy -Identity "maxtec.be" `
    -MinPasswordLength 12 `
    -ComplexityEnabled $true `
    -MaxPasswordAge (New-TimeSpan -Days 90) `
    -MinPasswordAge (New-TimeSpan -Days 1) `
    -PasswordHistoryCount 12 `
    -LockoutThreshold 5 `
    -LockoutDuration (New-TimeSpan -Minutes 30) `
    -LockoutObservationWindow (New-TimeSpan -Minutes 30)

Write-Host "Politique de mots de passe configurée avec succès." -ForegroundColor Green
```

### Méthode GUI (GPMC) - Chemins de navigation exacts

**GPO "MonitoringTech - Audit Avancé" :**

- Audit connexions :
  `Conf. ordinateur > Param. Windows > Sécurité > Config. avancée stratégie audit > Stratégies d'audit > Ouverture/Fermeture de session > Auditer l'ouverture de session` = Succès + Échec

- Audit gestion comptes :
  `Conf. ordinateur > Param. Windows > Sécurité > Config. avancée stratégie audit > Stratégies d'audit > Gestion des comptes > Auditer la gestion des comptes d'utilisateurs` = Succès + Échec

**GPO "MonitoringTech - Restrictions Utilisateurs" :**

- Bloquer Panneau de config :
  `Conf. utilisateur > Stratégies > Modèles d'administration > Panneau de configuration > Interdire l'accès au Panneau de configuration` = Activé

- Bloquer CMD :
  `Conf. utilisateur > Stratégies > Modèles d'administration > Système > Empêcher l'accès à l'invite de commandes` = Activé

---

## Points Clés à Retenir

- `Set-GPRegistryValue` ne doit JAMAIS être utilisé pour les politiques Windows standard : cela crée des entrées invalides visibles dans GPMC comme "nom convivial introuvable"
- La politique de mots de passe du domaine est la seule politique de sécurité configurable directement via PowerShell (`Set-ADDefaultDomainPasswordPolicy`)
- Les GPOs de restrictions et d'audit doivent être configurées manuellement dans GPMC via les chemins de navigation officiels
- Toujours exécuter `gpupdate /force` après modification d'une GPO et vérifier avec `gpresult /r`

## Dépannage (Erreurs Courantes)

| Erreur Possible | Cause | Solution |
|-----------------|-------|----------|
| GPO ne s'applique pas après `gpupdate` | Lien GPO manquant ou désactivé | Vérifier dans GPMC que le lien est activé sur la bonne OU |
| "Le module GroupPolicy n'est pas chargé" | Module RSAT manquant | `Import-Module GroupPolicy` ou installer RSAT GPO Tools |
| Paramètre d'audit non visible dans GPMC | Mauvaise navigation dans l'arborescence | Vérifier le chemin exact : "Configuration avancée" vs "Configuration de base" |
| `Set-ADDefaultDomainPasswordPolicy` échoue | Droits insuffisants ou domaine incorrect | Vérifier d'être admin du domaine et que le nom de domaine est exact |

## Exercice Suivant Suggéré

**Exercice 04 - Gestion des Comptes de Service** : Vous allez modifier les comptes de service existants pour leur attribuer des permissions de monitoring appropriées et renforcer leur sécurité.
