# Exercice 8 : Troubleshooting - "La GPO Ne S'Applique Pas !"

## Niveau de Difficulté
🔴 **Avancé** - Diagnostic et résolution de problèmes

## Objectifs Pédagogiques
- Diagnostiquer méthodiquement les problèmes d'application de GPO
- Utiliser les outils de diagnostic Windows (gpupdate, gpresult, Event Viewer)
- Comprendre l'ordre de priorité et l'héritage des GPO
- Résoudre des conflits de stratégies de groupe

## Durée Estimée
30-40 minutes

## Prérequis
- Connaissance approfondie des GPO
- Capacité à utiliser PowerShell pour le diagnostic
- Compréhension de l'héritage AD
- Compétences en résolution de problèmes

## Contexte / Scénario
**Date**: Mercredi matin, 10h15

Vous recevez plusieurs tickets urgents du support utilisateur :

### Ticket #1 - Hugo Laurent (Motion Designer - Creative)

> *"Bonjour IT,*
>
> *Je n'arrive plus à accéder au Panneau de configuration sur mon poste. Il y a deux jours, ça fonctionnait encore. Maintenant, quand je clique dessus, rien ne se passe.*
>
> *J'ai besoin d'accéder aux paramètres de mon écran pour calibrer mes couleurs pour un projet client urgent. Pouvez-vous débloquer ça rapidement ?*
>
> *Hugo*"

### Ticket #2 - Amélie Dubois (Community Manager - Marketing)

> *"Bonjour,*
>
> *Mon collègue Damien et moi travaillons dans le même département Marketing, mais lui ne peut pas utiliser l'invite de commandes alors que moi je peux. C'est bizarre, on devrait avoir les mêmes permissions, non ?*
>
> *Il a besoin du CMD pour lancer un script d'export de données analytics.*
>
> *Amélie*"

### Email de Rachid Dupont (Responsable IT)

> *"J'ai vu les tickets. Voici le contexte :*
>
> *Lundi dernier, j'ai créé une nouvelle GPO "CreativeHub - Restrictions Utilisateurs Juniors" pour bloquer l'accès au Panneau de configuration et au CMD pour les juniors du département Marketing et Creative. Je l'ai liée aux OUs correspondantes.*
>
> *Le problème : Cette GPO ne devrait s'appliquer QU'AUX UTILISATEURS JUNIORS (nouveaux employés avec moins d'un an d'expérience), mais elle semble s'appliquer à tout le monde dans Creative, et pas du tout dans Marketing.*
>
> *J'ai vérifié :*
> - *La GPO existe bien*
> - *Elle est liée aux bonnes OUs*
> - *Les paramètres de registre sont corrects*
>
> *Mais quelque chose ne fonctionne pas. Je dois gérer une autre urgence. Peux-tu diagnostiquer et corriger le problème ?*
>
> *NOTE : Les juniors sont identifiés dans AD par leur appartenance au groupe "GG-CreativeHub-Juniors" (que j'ai créé).*
>
> *Rachid*"

## Situation Initiale (Problèmes Simulés)

### Problème 1 : GPO appliquée à tout le département Creative

La GPO "CreativeHub - Restrictions Utilisateurs Juniors" s'applique à TOUS les utilisateurs de Creative (OU=Users,OU=Creative), alors qu'elle devrait s'appliquer uniquement aux membres du groupe "GG-CreativeHub-Juniors".

**Utilisateurs affectés** :

- Hugo (Senior, ne devrait PAS avoir de restrictions)
- Fabien (Senior, ne devrait PAS avoir de restrictions)
- Julien (Junior, DEVRAIT avoir des restrictions) ← Ce serait le seul concerné

### Problème 2 : GPO non appliquée dans Marketing

La GPO est liée à l'OU Marketing, mais le lien est **désactivé** par erreur.

**Utilisateurs affectés** :

- Damien devrait avoir des restrictions (il est junior) mais ne les a pas

### Problème 3 : Conflit d'héritage

Une GPO plus ancienne au niveau de l'OU CreativeHub (racine) bloque l'héritage pour certaines sous-OUs.

## Tâche à Réaliser

### Mission Principale

Diagnostiquer pourquoi la GPO ne s'applique pas correctement et corriger les problèmes pour que :

1. **Seuls les utilisateurs juniors** aient les restrictions (Panneau de config et CMD désactivés)
2. Les restrictions s'appliquent dans **tous les départements** (Creative ET Marketing)
3. Les utilisateurs **seniors** (Hugo, Fabien, Camille, etc.) ne soient **pas affectés**

### Étapes de Diagnostic Recommandées

#### 1. Comprendre la Configuration Actuelle

**Questions à investiguer** :

- Quelles GPOs existent actuellement ?
- Où sont-elles liées ?
- Quels sont leurs paramètres ?
- Y a-t-il des problèmes d'héritage ?

**Commandes utiles** :
```powershell
# Lister toutes les GPO
Get-GPO -All | Select-Object DisplayName, GpoStatus, CreationTime

# Voir les GPOs liées à une OU
Get-GPInheritance -Target "OU=Users,OU=Creative,OU=CreativeHub,DC=maxtec,DC=be"

# Voir les détails d'une GPO
Get-GPOReport -Name "CreativeHub - Restrictions Utilisateurs Juniors" -ReportType Html -Path "C:\Temp\GPO_Report.html"
```

#### 2. Identifier les Groupes

**Questions** :

- Le groupe "GG-CreativeHub-Juniors" existe-t-il ?
- Qui en est membre ?
- Est-il utilisé pour le filtrage de sécurité de la GPO ?

**Commandes utiles** :
```powershell
# Vérifier si le groupe existe
Get-ADGroup -Filter {Name -like "*Junior*"}

# Voir les membres
Get-ADGroupMember -Identity "GG-CreativeHub-Juniors"
```

#### 3. Vérifier le Filtrage de Sécurité (Security Filtering)

**Le problème probable** : La GPO n'utilise pas le filtrage de sécurité pour cibler uniquement le groupe Juniors.

**Concepts clés** :

- Par défaut, une GPO s'applique à "Authenticated Users" (tous les utilisateurs authentifiés)
- Le **filtrage de sécurité** permet de limiter l'application à des groupes spécifiques
- Le groupe doit avoir les permissions "Lecture" ET "Appliquer la stratégie de groupe"

**Comment corriger** :

1. Ouvrir `gpmc.msc`
2. Sélectionner la GPO
3. Onglet "Étendue" (Scope)
4. Section "Filtrage de sécurité" :
   - **Retirer** "Authenticated Users"
   - **Ajouter** "GG-CreativeHub-Juniors"

#### 4. Vérifier les Liens GPO

**Questions** :

- Les liens sont-ils activés ?
- Y a-t-il des problèmes d'ordre de priorité ?

**Commandes utiles** :
```powershell
# Voir les liens d'une GPO
$gpo = Get-GPO -Name "CreativeHub - Restrictions Utilisateurs Juniors"
Get-GPO -Guid $gpo.Id | Select-Object DisplayName, @{Name="Links";Expression={(Get-ADObject -Filter {gpLink -like "*$($_.Id)*"} -Properties gpLink).DistinguishedName}}
```

#### 5. Tester l'Application

**Commandes** :
```powershell
# Forcer la mise à jour des GPO
gpupdate /force

# Voir les GPO appliquées à un utilisateur spécifique
gpresult /r /scope:user /user:hugo

# Générer un rapport HTML détaillé
gpresult /h C:\Temp\gpresult_hugo.html /user:hugo
```

### Votre Démarche

1. **Créer le groupe GG-CreativeHub-Juniors** (s'il n'existe pas)
2. **Identifier les utilisateurs juniors** et les ajouter au groupe
3. **Configurer le filtrage de sécurité** de la GPO pour cibler uniquement ce groupe
4. **Vérifier et activer les liens** GPO sur toutes les OUs concernées
5. **Tester** que la GPO s'applique correctement aux juniors uniquement
6. **Documenter** la solution

### Utilisateurs Juniors Identifiés

Basé sur les profils de postes, voici les juniors (moins d'un an d'expérience) :

**Marketing** :

- Élise Robert (Social Media Analyst) - Junior
- Damien Petit (Content Strategist) - Junior

**Creative** :

- Julien Roux (Designer UX/UI) - Junior

**Client Services** :

- Manon Girard (Chef de Projet Junior) - **DÉSACTIVÉE** (ne pas inclure)

**IT Support** :

- (Aucun junior identifié)

## Pas d'Instructions Détaillées !

Cet exercice de troubleshooting nécessite que vous :

- Analysiez la situation
- Formuliez des hypothèses
- Testez vos hypothèses
- Trouviez et appliquez la solution
- Validez que le problème est résolu

Utilisez votre esprit d'analyse et les outils de diagnostic Windows/PowerShell.

## Vérification de la Réussite

### Script de Vérification

```powershell
.\verif_exercice_08.ps1
```

### Critères de Réussite

- [ ] Le groupe "GG-CreativeHub-Juniors" existe
- [ ] Les utilisateurs juniors (Élise, Damien, Julien) sont membres du groupe
- [ ] La GPO utilise le filtrage de sécurité (groupe Juniors, pas "Authenticated Users")
- [ ] La GPO est liée ET activée sur les OUs Creative\Users et Marketing\Users
- [ ] Les utilisateurs seniors (Hugo, Fabien, Camille) NE sont PAS affectés par la GPO
- [ ] Les utilisateurs juniors ONT les restrictions (CMD et Panneau de config désactivés)

### Test Manuel

**Test 1 : Vérifier le filtrage** :
```powershell
$gpo = Get-GPO -Name "CreativeHub - Restrictions Utilisateurs Juniors"
Get-GPPermissions -Name $gpo.DisplayName -All | Where-Object {$_.Permission -eq "GpoApply"}
# Doit montrer "GG-CreativeHub-Juniors", PAS "Authenticated Users"
```

**Test 2 : Simuler l'application pour Hugo (senior)** :
```powershell
# Hugo NE DOIT PAS recevoir la GPO
gpresult /r /scope:user /user:hugo
# La GPO "Restrictions Utilisateurs Juniors" NE DOIT PAS apparaître
```

**Test 3 : Simuler l'application pour Julien (junior)** :
```powershell
# Julien DOIT recevoir la GPO
gpresult /r /scope:user /user:julien
# La GPO "Restrictions Utilisateurs Juniors" DOIT apparaître
```

## Solution Complète (Pour Instructeur)

### Script de Configuration et Correction

```powershell
Import-Module ActiveDirectory
Import-Module GroupPolicy

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " TROUBLESHOOTING GPO - SOLUTION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$gpoName = "CreativeHub - Restrictions Utilisateurs Juniors"
$groupName = "GG-CreativeHub-Juniors"
$rootOU = "OU=CreativeHub,DC=maxtec,DC=be"

# ÉTAPE 1: Créer le groupe Juniors (si inexistant)
Write-Host "`n[1/5] Création/Vérification du groupe Juniors..." -ForegroundColor Yellow

try {
    $group = Get-ADGroup -Identity $groupName -ErrorAction Stop
    Write-Host "  Le groupe $groupName existe déjà." -ForegroundColor Yellow
} catch {
    # Créer une OU pour les groupes globaux si nécessaire
    $groupsOU = "OU=Groupes_Projets,$rootOU"
    try {
        Get-ADOrganizationalUnit -Identity $groupsOU -ErrorAction Stop | Out-Null
    } catch {
        New-ADOrganizationalUnit -Name "Groupes_Projets" -Path $rootOU -ProtectedFromAccidentalDeletion $false
    }

    New-ADGroup -Name $groupName `
        -GroupScope Global `
        -GroupCategory Security `
        -Path $groupsOU `
        -Description "Employés juniors (moins d'un an d'ancienneté) - Restrictions de sécurité renforcées"

    Write-Host "  ✓ Groupe $groupName créé" -ForegroundColor Green
    $group = Get-ADGroup -Identity $groupName
}

# ÉTAPE 2: Ajouter les utilisateurs juniors au groupe
Write-Host "`n[2/5] Ajout des utilisateurs juniors au groupe..." -ForegroundColor Yellow

$juniors = @("elise", "damien", "julien")  # SAM Accounts des juniors

foreach ($junior in $juniors) {
    try {
        $user = Get-ADUser -Identity $junior -ErrorAction Stop
        Add-ADGroupMember -Identity $groupName -Members $junior -ErrorAction Stop
        Write-Host "  ✓ $junior ajouté au groupe Juniors" -ForegroundColor Green
    } catch {
        if ($_.Exception.Message -like "*already a member*") {
            Write-Host "  $junior est déjà membre du groupe" -ForegroundColor Yellow
        } elseif ($_.Exception.Message -like "*Cannot find*") {
            Write-Host "  ⚠ Utilisateur $junior introuvable" -ForegroundColor Yellow
        } else {
            Write-Host "  ✗ ERREUR pour $junior : $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# ÉTAPE 3: Vérifier/Créer la GPO
Write-Host "`n[3/5] Vérification de la GPO..." -ForegroundColor Yellow

try {
    $gpo = Get-GPO -Name $gpoName -ErrorAction Stop
    Write-Host "  La GPO '$gpoName' existe." -ForegroundColor Yellow
} catch {
    Write-Host "  La GPO n'existe pas, création..." -ForegroundColor Yellow

    # Créer la GPO
    $gpo = New-GPO -Name $gpoName -Comment "Restrictions pour utilisateurs juniors uniquement"

    # Configurer les restrictions
    Set-GPRegistryValue -Name $gpoName `
        -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
        -ValueName "NoControlPanel" -Type DWord -Value 1 | Out-Null

    Set-GPRegistryValue -Name $gpoName `
        -Key "HKCU\Software\Policies\Microsoft\Windows\System" `
        -ValueName "DisableCMD" -Type DWord -Value 2 | Out-Null

    Write-Host "  ✓ GPO créée avec restrictions" -ForegroundColor Green
}

# ÉTAPE 4: Configurer le FILTRAGE DE SÉCURITÉ (Security Filtering)
Write-Host "`n[4/5] Configuration du filtrage de sécurité..." -ForegroundColor Yellow

# Retirer "Authenticated Users" (appliqué par défaut)
try {
    $authUsers = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-11") # Authenticated Users SID
    Set-GPPermissions -Name $gpoName -PermissionLevel None -TargetName "Authenticated Users" -TargetType Group -ErrorAction Stop
    Write-Host "  ✓ 'Authenticated Users' retiré du filtrage" -ForegroundColor Green
} catch {
    if ($_.Exception.Message -like "*does not have*") {
        Write-Host "  'Authenticated Users' n'était pas dans le filtrage" -ForegroundColor Yellow
    } else {
        Write-Host "  ⚠ Erreur lors du retrait: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Ajouter le groupe Juniors avec permission GpoApply
try {
    Set-GPPermissions -Name $gpoName -PermissionLevel GpoApply -TargetName $groupName -TargetType Group -ErrorAction Stop
    Write-Host "  ✓ Groupe '$groupName' ajouté avec permission GpoApply" -ForegroundColor Green
} catch {
    Write-Host "  ⚠ Erreur lors de l'ajout: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Le groupe doit aussi avoir la permission "Lecture" (Read)
try {
    Set-GPPermissions -Name $gpoName -PermissionLevel GpoRead -TargetName $groupName -TargetType Group -ErrorAction Stop
    Write-Host "  ✓ Permission 'Lecture' accordée au groupe Juniors" -ForegroundColor Green
} catch {
    Write-Host "  La permission existe peut-être déjà" -ForegroundColor Yellow
}

# ÉTAPE 5: Lier la GPO aux OUs (et activer les liens)
Write-Host "`n[5/5] Liaison de la GPO aux OUs..." -ForegroundColor Yellow

$ous = @(
    "OU=Users,OU=Creative,$rootOU",
    "OU=Users,OU=Marketing,$rootOU"
)

foreach ($ou in $ous) {
    try {
        # Vérifier si le lien existe
        $inheritance = Get-GPInheritance -Target $ou -ErrorAction Stop
        $existingLink = $inheritance.GpoLinks | Where-Object {$_.DisplayName -eq $gpoName}

        if ($existingLink) {
            if ($existingLink.Enabled -eq $false) {
                # Lien existe mais est désactivé - l'activer
                Set-GPLink -Name $gpoName -Target $ou -LinkEnabled Yes -ErrorAction Stop
                Write-Host "  ✓ Lien activé pour $ou" -ForegroundColor Green
            } else {
                Write-Host "  Le lien existe déjà et est activé pour $ou" -ForegroundColor Yellow
            }
        } else {
            # Créer le lien
            New-GPLink -Name $gpoName -Target $ou -LinkEnabled Yes -ErrorAction Stop
            Write-Host "  ✓ GPO liée à $ou" -ForegroundColor Green
        }
    } catch {
        Write-Host "  ✗ ERREUR pour $ou : $($_.Exception.Message)" -ForegroundColor Red
    }
}

# VÉRIFICATION FINALE
Write-Host "`n========================================" -ForegroundColor Green
Write-Host " TROUBLESHOOTING TERMINÉ" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Write-Host "`nRécapitulatif de la solution:" -ForegroundColor Cyan
Write-Host "  1. Groupe 'GG-CreativeHub-Juniors' créé" -ForegroundColor White
Write-Host "  2. Utilisateurs juniors ajoutés au groupe (Élise, Damien, Julien)" -ForegroundColor White
Write-Host "  3. Filtrage de sécurité configuré (uniquement groupe Juniors)" -ForegroundColor White
Write-Host "  4. GPO liée et activée sur Creative\Users et Marketing\Users" -ForegroundColor White

Write-Host "`nMembres du groupe Juniors:" -ForegroundColor Cyan
$members = Get-ADGroupMember -Identity $groupName
foreach ($member in $members) {
    $userDetails = Get-ADUser -Identity $member.SamAccountName -Properties Title, Department
    Write-Host "  - $($member.Name) ($($userDetails.Department) - $($userDetails.Title))" -ForegroundColor White
}

Write-Host "`nFiltrage de sécurité de la GPO:" -ForegroundColor Cyan
$permissions = Get-GPPermissions -Name $gpoName -All | Where-Object {$_.Permission -eq "GpoApply"}
foreach ($perm in $permissions) {
    Write-Host "  - $($perm.Trustee.Name) (Permission: $($perm.Permission))" -ForegroundColor White
}

Write-Host "`nLiens GPO:" -ForegroundColor Cyan
foreach ($ou in $ous) {
    $inheritance = Get-GPInheritance -Target $ou
    $link = $inheritance.GpoLinks | Where-Object {$_.DisplayName -eq $gpoName}
    if ($link) {
        Write-Host "  - $ou (Activé: $($link.Enabled))" -ForegroundColor White
    }
}

Write-Host "`n✅ La GPO devrait maintenant s'appliquer UNIQUEMENT aux utilisateurs juniors !" -ForegroundColor Green
Write-Host "`nPour tester:" -ForegroundColor Yellow
Write-Host "  Sur un poste client, exécuter:" -ForegroundColor Gray
Write-Host "  gpupdate /force" -ForegroundColor Gray
Write-Host "  gpresult /r /scope:user /user:julien" -ForegroundColor Gray
```

### Explication de la Solution

#### Problème Principal : Filtrage de Sécurité

Par défaut, une GPO s'applique à "Authenticated Users" (tous les utilisateurs authentifiés du domaine). Pour limiter l'application à un groupe spécifique :

1. **Retirer "Authenticated Users"** de la section "Filtrage de sécurité"
2. **Ajouter le groupe cible** ("GG-CreativeHub-Juniors")
3. Le groupe doit avoir deux permissions :
   - **Lecture** (Read) - pour lire la GPO
   - **Appliquer la stratégie de groupe** (GpoApply) - pour que la GPO s'applique

#### Problèmes Secondaires

- **Lien désactivé** : Vérifier que `Set-GPLink -LinkEnabled Yes`
- **Ordre de priorité** : Si plusieurs GPOs, vérifier l'ordre (last applied wins)
- **Héritage bloqué** : Vérifier qu'il n'y a pas de "Block Inheritance" sur les OUs

## Points Clés à Retenir

### Méthodologie de Troubleshooting GPO

1. **Vérifier l'existence** : La GPO existe-t-elle ?
2. **Vérifier les paramètres** : Les configurations sont-elles correctes ?
3. **Vérifier les liens** : La GPO est-elle liée aux bonnes OUs ?
4. **Vérifier l'état des liens** : Les liens sont-ils activés ?
5. **Vérifier le filtrage de sécurité** : Qui peut recevoir la GPO ?
6. **Vérifier l'héritage** : Y a-t-il des blocages d'héritage ?
7. **Vérifier l'ordre de priorité** : En cas de conflit, quelle GPO gagne ?
8. **Forcer l'application** : `gpupdate /force`
9. **Tester** : `gpresult /r`

### Outils de Diagnostic

| Outil | Commande | Usage |
|-------|----------|-------|
| **GPMC** | `gpmc.msc` | Interface graphique pour gérer les GPO |
| **gpupdate** | `gpupdate /force` | Forcer l'application immédiate des GPO |
| **gpresult** | `gpresult /r /scope:user` | Voir les GPO appliquées à un utilisateur |
| **Get-GPO** | `Get-GPO -All` | Lister toutes les GPO via PowerShell |
| **Get-GPInheritance** | `Get-GPInheritance -Target "OU=..."` | Voir les GPO héritées par une OU |
| **Get-GPPermissions** | `Get-GPPermissions -Name "GPO" -All` | Voir les permissions d'une GPO |

### Filtrage de Sécurité vs WMI Filtering

| Critère | Security Filtering | WMI Filtering |
|---------|-------------------|---------------|
| **Basé sur** | Groupes AD | Requêtes WMI (matériel, OS, etc.) |
| **Performance** | Rapide | Plus lent (évalue une requête) |
| **Usage** | Cibler des utilisateurs/ordinateurs spécifiques | Cibler selon des caractéristiques techniques |
| **Exemple** | "Appliquer uniquement aux juniors" | "Appliquer uniquement aux PC avec Windows 11" |

## Dépannage (Erreurs Courantes)

| Problème | Cause | Solution |
|----------|-------|----------|
| GPO ne s'applique toujours pas après gpupdate | Cache GPO corrompu | `gpupdate /force /sync` ou redémarrer le poste |
| "Authenticated Users" ne peut pas être retiré | Nécessaire pour certaines opérations | Utiliser `Set-GPPermissions -PermissionLevel None` |
| Le groupe n'apparaît pas dans le filtrage | Délai de réplication AD | Attendre quelques minutes ou forcer la réplication |
| Conflit entre plusieurs GPO | Ordre de priorité incorrect | Ajuster l'ordre dans GPMC ou utiliser "Enforced" |

## Pour Aller Plus Loin

### RSoP (Resultant Set of Policy)

```powershell
# Voir toutes les GPO appliquées à un utilisateur spécifique sur un ordinateur spécifique
Get-GPResultantSetOfPolicy -Computer "DESKTOP-01" -User "MAXTEC\julien" -ReportType Html -Path "C:\Temp\RSoP.html"
```

### Audit de l'Application des GPO

```powershell
# Générer un rapport de toutes les GPO et leurs liens
Get-GPO -All | ForEach-Object {
    $gpoName = $_.DisplayName
    $links = (Get-ADObject -Filter {gpLink -like "*$($_.Id)*"} -Properties gpLink).DistinguishedName
    [PSCustomObject]@{
        GPOName = $gpoName
        Links = $links -join "; "
    }
} | Export-Csv -Path "C:\Temp\GPO_Audit.csv" -NoTypeInformation
```

## Exercice Suivant Suggéré

**Exercice 9** : Scénario de crise - Incident de sécurité multi-facettes avec audit complet
