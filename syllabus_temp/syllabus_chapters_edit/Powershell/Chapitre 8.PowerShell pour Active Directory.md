# Chapitre 8: PowerShell pour Active Directory

> 📚 **Dans ce chapitre:**
> 1. 🔹 [Introduction à PowerShell](#1-introduction-à-powershell)
>    - Concepts de base
>    - Avantages pour l'administration AD
> 2. 🔹 [Modules PowerShell pour AD](#2-modules-powershell-pour-ad)
>    - ActiveDirectory
>    - GroupPolicy
>    - DNSServer
> 3. 🔹 [Gestion des objets AD](#3-gestion-des-objets-ad)
>    - Utilisateurs et groupes
>    - Unités d'organisation
>    - Ordinateurs
> 4. 🔹 [Automatisation des tâches AD](#4-automatisation-des-tâches-ad)
>    - Scripts utiles
>    - Rapports et surveillance
> 5. 🔹 [Bonnes pratiques](#5-bonnes-pratiques)
>    - Sécurité
>    - Performance
>    - Documentation

---

## 📙 Objectifs Pédagogiques

À la fin de ce chapitre, vous serez capable de :
1. Comprendre les principes fondamentaux de PowerShell dans le contexte d'Active Directory
2. Utiliser les cmdlets PowerShell pour gérer les objets AD
3. Créer des scripts d'automatisation pour les tâches administratives courantes
4. Appliquer les bonnes pratiques de sécurité et de performance

---

## 1. 🔹 Introduction à PowerShell

### 1.1. Qu'est-ce que PowerShell ?

PowerShell est un environnement d'automatisation et de scripting développé par Microsoft qui permet aux administrateurs système de gérer efficacement les environnements Windows, y compris Active Directory.

| 🛠️ Caractéristiques | Description |
|------------|-------------|
| 💻 **Langage orienté objet** | Manipulation directe des objets plutôt que du texte |
| 🔧 **Cmdlets** | Commandes légères spécialisées pour des fonctions spécifiques |
| 📚 **Modules** | Extensions qui ajoutent des fonctionnalités spécifiques |
| 🔄 **Pipeline** | Chaînage de commandes pour des opérations complexes |

> 💡 **Principe clé**: PowerShell permet d'automatiser en quelques lignes ce qui prendrait des heures via l'interface graphique!

### 1.2. Pourquoi utiliser PowerShell pour AD ?

Dans notre environnement maxtec.be, PowerShell offre plusieurs avantages significatifs par rapport à l'interface graphique traditionnelle :

- **Efficacité**: Création en masse d'utilisateurs, de groupes ou d'OUs
- **Cohérence**: Application uniforme des paramètres et configurations
- **Automatisation**: Exécution programmée de tâches récurrentes
- **Documentation**: Scripts servant de documentation des procédures
- **Flexibilité**: Adaptation rapide aux besoins spécifiques de l'entreprise

**Exemple concret**: Imaginez que vous devez créer 50 nouveaux comptes utilisateurs pour le département Comptabilité. Via l'interface graphique, cette tâche prendrait plusieurs heures. Avec PowerShell, quelques lignes de code suffisent.

## 2. 🔹 Modules PowerShell pour AD

### 2.1. Module ActiveDirectory

Le module ActiveDirectory est l'outil principal pour gérer les objets AD via PowerShell. Il est installé automatiquement avec le rôle AD DS.

Pour vérifier sa disponibilité :

```powershell
Get-Module -Name ActiveDirectory -ListAvailable
```

Pour l'importer :

```powershell
Import-Module ActiveDirectory
```

#### Cmdlets essentielles :

| Catégorie | Cmdlets courantes |
|-----------|-------------------|
| **Utilisateurs** | Get-ADUser, New-ADUser, Set-ADUser, Remove-ADUser |
| **Groupes** | Get-ADGroup, New-ADGroup, Add-ADGroupMember |
| **OUs** | Get-ADOrganizationalUnit, New-ADOrganizationalUnit |
| **Ordinateurs** | Get-ADComputer, New-ADComputer |
| **Recherche** | Get-ADObject, Search-ADAccount |

### 2.2. Module GroupPolicy

Ce module permet de gérer les stratégies de groupe via PowerShell.

```powershell
Import-Module GroupPolicy
```

#### Cmdlets essentielles :

| Opération | Cmdlet |
|-----------|--------|
| **Création de GPO** | New-GPO |
| **Liaison de GPO** | New-GPLink |
| **Modification de GPO** | Set-GPRegistryValue |
| **Rapport de GPO** | Get-GPOReport |

### 2.3. Module DNSServer

Pour gérer les aspects DNS d'Active Directory :

```powershell
Import-Module DnsServer
```

#### Cmdlets essentielles :

| Opération | Cmdlet |
|-----------|--------|
| **Zones DNS** | Get-DnsServerZone, Add-DnsServerPrimaryZone |
| **Enregistrements** | Add-DnsServerResourceRecord |
| **Statistiques** | Get-DnsServerStatistics |

## 3. 🔹 Gestion des objets AD

### 3.1. Gestion des utilisateurs

#### Création d'un utilisateur

```powershell
New-ADUser -Name "Sophie Lambert" -GivenName "Sophie" -Surname "Lambert" `
    -SamAccountName "sophie.lambert" -UserPrincipalName "sophie.lambert@maxtec.be" `
    -Path "OU=Utilisateurs,OU=RH,OU=EU,DC=maxtec,DC=be" `
    -AccountPassword (ConvertTo-SecureString "Password1!" -AsPlainText -Force) `
    -Enabled $true
```

#### Recherche d'utilisateurs

```powershell
# Tous les utilisateurs du département Comptabilité
Get-ADUser -Filter * -SearchBase "OU=Utilisateurs,OU=Comptabilité,OU=EU,DC=maxtec,DC=be"

# Utilisateurs dont le compte expire dans 30 jours
Search-ADAccount -AccountExpiring -TimeSpan 30.00:00:00
```

#### Modification d'utilisateurs

```powershell
# Modification d'un attribut
Set-ADUser -Identity "sophie.lambert" -Description "Responsable RH"

# Déplacement d'un utilisateur vers une autre OU
Move-ADObject -Identity "CN=Sophie Lambert,OU=Utilisateurs,OU=RH,OU=EU,DC=maxtec,DC=be" `
    -TargetPath "OU=Utilisateurs,OU=Direction,OU=EU,DC=maxtec,DC=be"
```

### 3.2. Gestion des groupes

#### Création d'un groupe

```powershell
# Création d'un groupe global
New-ADGroup -Name "GG-EU-Compta-Utilisateurs" -GroupScope Global `
    -Path "OU=Groupes,OU=EU,DC=maxtec,DC=be"

# Création d'un groupe Domain Local
New-ADGroup -Name "DL-EU-Rapports-Lecture" -GroupScope DomainLocal `
    -Path "OU=Groupes,OU=EU,DC=maxtec,DC=be"
```

#### Gestion des membres

```powershell
# Ajout d'un utilisateur à un groupe
Add-ADGroupMember -Identity "GG-EU-Compta-Utilisateurs" -Members "sophie.lambert"

# Ajout d'un groupe à un autre groupe
Add-ADGroupMember -Identity "DL-EU-Rapports-Lecture" -Members "GG-EU-Compta-Utilisateurs"
```

### 3.3. Gestion des unités d'organisation

#### Création d'une OU

```powershell
New-ADOrganizationalUnit -Name "Projets" -Path "OU=EU,DC=maxtec,DC=be" `
    -ProtectedFromAccidentalDeletion $true
```

#### Délégation de contrôle

```powershell
# Script pour déléguer le contrôle d'une OU à un groupe
# (Nécessite généralement l'utilisation de DSACLS ou d'autres outils)
```

### 3.4. Gestion des ordinateurs

#### Ajout d'un ordinateur

```powershell
New-ADComputer -Name "ws-compta-05" -SamAccountName "ws-compta-05" `
    -Path "OU=Ordinateurs,OU=Comptabilité,OU=EU,DC=maxtec,DC=be"
```

#### Recherche d'ordinateurs inactifs

```powershell
# Ordinateurs inactifs depuis plus de 90 jours
Search-ADAccount -ComputersOnly -AccountInactive -TimeSpan 90.00:00:00
```

## 4. 🔹 Automatisation des tâches AD

### 4.1. Création en masse d'utilisateurs

L'un des avantages majeurs de PowerShell est la possibilité d'automatiser la création de multiples objets AD à partir d'une source de données externe, comme un fichier CSV.

#### Exemple avec un fichier CSV :

Contenu de `nouveaux_utilisateurs.csv` :
```
Prenom,Nom,Departement,Fonction
Jean,Dupont,Comptabilité,Comptable
Marie,Martin,Ventes,Commerciale
Pierre,Durand,RH,Recruteur
```

Script PowerShell :
```powershell
Import-Csv -Path "C:\Scripts\nouveaux_utilisateurs.csv" | ForEach-Object {
    $nomUtilisateur = "$($_.Prenom).$($_.Nom)".ToLower()
    $ouPath = "OU=Utilisateurs,OU=$($_.Departement),OU=EU,DC=maxtec,DC=be"
    
    New-ADUser -Name "$($_.Prenom) $($_.Nom)" `
        -GivenName $_.Prenom -Surname $_.Nom `
        -SamAccountName $nomUtilisateur `
        -UserPrincipalName "$nomUtilisateur@maxtec.be" `
        -Path $ouPath `
        -AccountPassword (ConvertTo-SecureString "Password1!" -AsPlainText -Force) `
        -Enabled $true `
        -Description $_.Fonction
    
    # Ajout au groupe approprié
    Add-ADGroupMember -Identity "GG-EU-$($_.Departement)-Utilisateurs" -Members $nomUtilisateur
}
```

### 4.2. Rapports AD

PowerShell permet de générer facilement des rapports sur l'état de votre environnement AD.

#### Rapport sur les comptes utilisateurs

```powershell
# Exportation des informations utilisateurs vers CSV
Get-ADUser -Filter * -Properties Name, EmailAddress, Enabled, LastLogonDate |
    Select-Object Name, EmailAddress, Enabled, LastLogonDate |
    Export-Csv -Path "C:\Rapports\utilisateurs.csv" -NoTypeInformation
```

#### Rapport sur les groupes et leurs membres

```powershell
$groupes = Get-ADGroup -Filter *
$rapport = foreach ($groupe in $groupes) {
    $membres = Get-ADGroupMember -Identity $groupe.Name | Select-Object -ExpandProperty Name
    [PSCustomObject]@{
        Groupe = $groupe.Name
        Membres = $membres -join ", "
    }
}
$rapport | Export-Csv -Path "C:\Rapports\groupes_membres.csv" -NoTypeInformation
```

### 4.3. Surveillance et maintenance

#### Vérification des comptes verrouillés

```powershell
Search-ADAccount -LockedOut | Select-Object Name, SamAccountName
```

#### Nettoyage des objets ordinateurs obsolètes

```powershell
# Identification des ordinateurs inactifs depuis plus de 90 jours
$inactifs = Search-ADAccount -ComputersOnly -AccountInactive -TimeSpan 90.00:00:00
$inactifs | ForEach-Object {
    # Désactivation avant suppression (bonne pratique)
    Disable-ADAccount -Identity $_.DistinguishedName
    # Suppression (décommenter pour activer)
    # Remove-ADComputer -Identity $_.DistinguishedName -Confirm:$false
}
```

## 5. 🔹 Bonnes pratiques

### 5.1. Sécurité

- **Ne jamais stocker les mots de passe en clair** dans les scripts
- Utiliser des **comptes de service dédiés** avec privilèges minimaux
- Implémenter la **journalisation** des actions PowerShell
- **Signer numériquement** les scripts dans les environnements de production
- Utiliser **Try/Catch** pour gérer les erreurs proprement

### 5.2. Performance

- **Filtrer au niveau du serveur** plutôt qu'en local :
  ```powershell
  # Bon (filtrage côté serveur)
  Get-ADUser -Filter {Department -eq "Comptabilité"}
  
  # Moins bon (filtrage côté client)
  Get-ADUser -Filter * | Where-Object {$_.Department -eq "Comptabilité"}
  ```

- **Limiter les propriétés** récupérées aux seules nécessaires :
  ```powershell
  Get-ADUser -Filter * -Properties DisplayName, EmailAddress | 
      Select-Object DisplayName, EmailAddress
  ```

- **Utiliser SearchBase** pour limiter la portée des recherches

### 5.3. Documentation et gestion des erreurs

- **Commenter** abondamment les scripts
- Inclure des **blocs d'aide** pour les fonctions complexes
- Utiliser **Try/Catch/Finally** pour la gestion des erreurs
- **Journaliser** les actions importantes et les erreurs

```powershell
try {
    # Tentative d'opération
    New-ADUser -Name "Test User" -SamAccountName "test.user"
} catch {
    # Gestion de l'erreur
    Write-Error "Erreur lors de la création de l'utilisateur: $_"
    # Journalisation
    Add-Content -Path "C:\Logs\ad_operations.log" -Value "$(Get-Date) - ERREUR: $_"
} finally {
    # Code exécuté dans tous les cas
    Write-Host "Opération terminée"
}
```

## 📝 Exercices pratiques avancés

### 🎯 Exercice 1: Tableau de bord interactif pour l'administrateur AD

**Scénario**: Vous êtes l'administrateur système de maxtec.be et vous avez besoin d'un tableau de bord quotidien pour surveiller la santé de votre environnement AD.

**Objectif**: Créer un script PowerShell qui génère un rapport HTML interactif avec les informations suivantes:
- Comptes verrouillés dans les dernières 24 heures
- Comptes expirés ou qui vont expirer dans les 7 prochains jours
- Ordinateurs qui ne se sont pas connectés depuis 30 jours
- Groupes vides (sans membres)
- Dernières modifications des GPOs

**Indice**: Utilisez `ConvertTo-Html` avec des styles CSS pour créer un rapport visuellement attrayant.

**Avantage par rapport à l'interface graphique**: Cette vue consolidée nécessiterait de naviguer dans plusieurs outils différents de l'interface graphique.

### 🎯 Exercice 2: Simulation de catastrophe et récupération

**Scénario**: Un stagiaire a accidentellement supprimé tous les utilisateurs d'une OU importante.

**Objectif**: 
1. Créer un script qui sauvegarde quotidiennement tous les objets d'une OU spécifique (utilisateurs, groupes, ordinateurs) dans un format facilement restaurable
2. Créer un second script qui peut restaurer ces objets en cas de suppression accidentelle

**Indice**: Utilisez `Get-ADObject` avec le paramètre `-IncludeDeletedObjects` pour récupérer les objets supprimés récemment.

**Avantage par rapport à l'interface graphique**: La restauration en masse d'objets supprimés est extrêmement fastidieuse via l'interface graphique.

### 🎯 Exercice 3: Détection des anomalies de sécurité

**Scénario**: Vous suspectez qu'un compte compromis a été utilisé pour créer des comptes administrateurs cachés.

**Objectif**: Créer un script qui:
1. Identifie tous les comptes ayant des privilèges administratifs élevés
2. Compare cette liste avec un inventaire de référence
3. Alerte sur les nouveaux comptes administrateurs non autorisés
4. Vérifie les modifications récentes des appartenances aux groupes privilégiés

**Indice**: Combinez `Get-ADGroupMember` sur les groupes administratifs avec la vérification des attributs `AdminCount` et `memberOf`.

**Avantage par rapport à l'interface graphique**: Ce type d'audit de sécurité serait pratiquement impossible à réaliser manuellement.

### 🎯 Exercice 4: Migration de département automatisée

**Scénario**: Suite à une restructuration, 15 employés du département Ventes doivent être transférés au département Marketing.

**Objectif**: Créer un script qui automatise complètement ce processus de migration:
1. Déplacer les comptes utilisateurs vers la nouvelle OU
2. Mettre à jour les attributs (département, description, etc.)
3. Ajuster les appartenances aux groupes (retirer des anciens, ajouter aux nouveaux)
4. Déplacer les ordinateurs associés
5. Générer un rapport de migration

**Indice**: Utilisez un fichier CSV pour définir les utilisateurs à migrer et leurs nouvelles informations.

**Avantage par rapport à l'interface graphique**: Cette tâche prendrait des heures manuellement et serait sujette aux erreurs humaines.

### 🎯 Exercice 5: Système de provisionnement automatisé

**Scénario**: Le service RH vous envoie chaque semaine un fichier Excel avec les nouveaux employés à intégrer dans le système.

**Objectif**: Créer un système complet qui:
1. Lit le fichier Excel des nouveaux employés
2. Crée les comptes utilisateurs avec tous les attributs nécessaires
3. Ajoute les utilisateurs aux groupes appropriés selon leur département
4. Génère des mots de passe temporaires aléatoires
5. Crée les boîtes aux lettres Exchange si nécessaire
6. Envoie un email de bienvenue avec les informations de connexion
7. Génère un rapport pour le service RH

**Indice**: Utilisez le module `ImportExcel` pour lire directement les fichiers Excel sans conversion préalable.

**Avantage par rapport à l'interface graphique**: Ce processus entièrement automatisé élimine les erreurs humaines et réduit considérablement le temps d'intégration.

### 🎯 Exercice 6: Audit de conformité des GPOs

**Scénario**: Votre entreprise doit se conformer à certaines normes de sécurité qui exigent des paramètres GPO spécifiques.

**Objectif**: Créer un script qui:
1. Analyse toutes les GPOs de l'environnement
2. Vérifie la présence et la configuration correcte de paramètres de sécurité spécifiques
3. Identifie les GPOs non conformes
4. Génère un rapport de conformité avec recommandations
5. Optionnel: Corrige automatiquement les paramètres non conformes

**Indice**: Utilisez `Get-GPOReport` avec le format XML pour une analyse programmatique détaillée.

**Avantage par rapport à l'interface graphique**: L'analyse systématique de centaines de paramètres GPO serait extrêmement chronophage manuellement.

## 📝 Exercices pratiques de base

1. Créer un script PowerShell qui liste tous les utilisateurs du département Ventes et exporte leurs informations dans un fichier CSV.

2. Développer un script qui identifie et désactive automatiquement les comptes utilisateurs inactifs depuis plus de 60 jours.

3. Créer une fonction PowerShell qui permet d'ajouter rapidement un nouvel employé avec tous les paramètres nécessaires (compte, groupes, boîte mail).

4. Développer un rapport hebdomadaire qui surveille les modifications apportées aux GPOs.

5. Créer un script qui vérifie la conformité des noms d'utilisateurs selon la convention firstname.lastname.

## 📚 Ressources supplémentaires

- [Documentation officielle du module ActiveDirectory](https://docs.microsoft.com/en-us/powershell/module/activedirectory/)
- [Centre de scripts PowerShell pour AD](https://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=Tag&f%5B0%5D.Value=Active%20Directory)
- [PowerShell pour Active Directory - Guide pratique](https://www.microsoft.com/en-us/download/details.aspx?id=45520)

---

## 🔑 Points clés à retenir

- PowerShell est **essentiel** pour l'administration efficace d'Active Directory à grande échelle
- Les modules **ActiveDirectory**, **GroupPolicy** et **DNSServer** fournissent les cmdlets nécessaires
- L'**automatisation** des tâches répétitives permet de gagner un temps considérable
- Les **rapports** générés par PowerShell offrent une visibilité précieuse sur l'environnement AD
- Toujours suivre les **bonnes pratiques** de sécurité et de performance
