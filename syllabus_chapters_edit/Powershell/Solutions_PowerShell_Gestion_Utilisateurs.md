# Solutions PowerShell pour les exercices de Gestion des Utilisateurs

Ce document présente les solutions PowerShell pour les exercices du chapitre "Gestion des Utilisateurs". Chaque solution est conçue pour être simple et accessible aux débutants en PowerShell.

## Exercice 1: Création d'un Nouvel Employé

**Scénario**: Le service Comptabilité accueille une nouvelle comptable junior, Sophie Dubois.

**Solution PowerShell**:

```powershell
# Création du compte utilisateur pour Sophie Dubois
New-ADUser -Name "Sophie Dubois" `
    -GivenName "Sophie" `
    -Surname "Dubois" `
    -SamAccountName "sophie.dubois" `
    -UserPrincipalName "sophie.dubois@maxtec.be" `
    -Path "OU=Utilisateurs,OU=Comptabilité,OU=EU,DC=maxtec,DC=be" `
    -AccountPassword (ConvertTo-SecureString "Password1!" -AsPlainText -Force) `
    -Enabled $true `
    -ChangePasswordAtLogon $true `
    -Description "Comptable Junior - Service Comptabilité" `
    -Office "Bâtiment A - 1er étage" `
    -OfficePhone "+32 2 123 45 68" `
    -Department "Comptabilité"
```

## Exercice 2: Restrictions d'Accès

**Scénario**: Sophie ne doit pouvoir se connecter que sur un poste spécifique et pendant des horaires définis.

**Solution PowerShell**:

```powershell
# Définir les restrictions de connexion pour Sophie
# 1. Restriction aux postes de travail spécifiques
Set-ADUser -Identity "sophie.dubois" -LogonWorkstations "ws-compta-01"

# 2. Définir les plages horaires autorisées (Lundi-Vendredi, 8h-18h)
# Note: Les heures sont en UTC, ajustez selon votre fuseau horaire
$heures = New-Object byte[] 21
# Par défaut, tous les octets sont à 0 (aucun accès)
# Définir les heures de travail (8h-18h) pour les jours ouvrés (lundi=index 0 à vendredi=index 4)
for ($jour = 0; $jour -le 4; $jour++) {
    for ($heure = 8; $heure -lt 18; $heure++) {
        # Chaque jour a 3 octets (24 bits, 1 bit par heure)
        # Calculer l'index de l'octet et le bit à modifier
        $octet = [math]::Floor($heure / 8) + ($jour * 3)
        $bit = [math]::Pow(2, $heure % 8)
        $heures[$octet] = $heures[$octet] -bor $bit
    }
}
Set-ADUser -Identity "sophie.dubois" -Replace @{logonHours = $heures}
```

## Exercice 3: Audit de Sécurité

**Scénario**: Vérifier les paramètres de sécurité du compte de Sophie.

**Solution PowerShell**:

```powershell
# 1. Vérifier la politique de mot de passe
$politiqueMDP = Get-ADDefaultDomainPasswordPolicy
Write-Host "Politique de mot de passe du domaine:"
Write-Host "Longueur minimale: $($politiqueMDP.MinPasswordLength) caractères"
Write-Host "Complexité requise: $($politiqueMDP.ComplexityEnabled)"

# 2. Configurer l'expiration du compte dans 6 mois
$dateFin = (Get-Date).AddMonths(6)
Set-ADUser -Identity "sophie.dubois" -AccountExpirationDate $dateFin

# 3. Vérifier que la journalisation des échecs de connexion est activée
# Note: Cette configuration se fait généralement via GPO, mais on peut vérifier
$auditPolicy = auditpol /get /category:"Logon/Logoff"
Write-Host "Politique d'audit actuelle:"
Write-Host $auditPolicy
```

## Exercice 4: Désactivation d'un Compte

**Scénario**: Jan Vandenbergh quitte l'entreprise aujourd'hui.

**Solution PowerShell**:

```powershell
# 1. Désactiver le compte utilisateur
$dateDesactivation = Get-Date -Format "yyyy-MM-dd"
$dateSuppression = (Get-Date).AddDays(90).ToString("yyyy-MM-dd")
$description = "Désactivé le $dateDesactivation - Départ de l'entreprise - Suppression prévue le $dateSuppression"

# Désactiver le compte et mettre à jour la description
Disable-ADAccount -Identity "jan.vandenbergh"
Set-ADUser -Identity "jan.vandenbergh" -Description $description

# 2. Vérifier que le compte est bien désactivé
$user = Get-ADUser -Identity "jan.vandenbergh" -Properties Enabled, Description
Write-Host "État du compte: $(if($user.Enabled){'Actif'}else{'Désactivé'})"
Write-Host "Description: $($user.Description)"
```

## Exercice 5: Nettoyage des Accès

**Scénario**: Suite au départ de Jan Vandenbergh, retirer ses appartenances aux groupes.

**Solution PowerShell**:

```powershell
# 1. Identifier tous les groupes dont l'utilisateur est membre
$groupes = Get-ADPrincipalGroupMembership -Identity "jan.vandenbergh"

# 2. Retirer l'utilisateur de tous les groupes sauf "Domain Users"
foreach ($groupe in $groupes) {
    if ($groupe.Name -ne "Domain Users") {
        Remove-ADGroupMember -Identity $groupe -Members "jan.vandenbergh" -Confirm:$false
        Write-Host "Utilisateur retiré du groupe: $($groupe.Name)"
    }
}

# Vérifier les groupes restants
$groupesRestants = Get-ADPrincipalGroupMembership -Identity "jan.vandenbergh"
Write-Host "Groupes restants: $($groupesRestants.Name -join ', ')"
```

## Exercice 6: Gestion des Homonymes

**Scénario**: Deux nouveaux employés portant le même nom arrivent dans le service RH.

**Solution PowerShell**:

```powershell
# 1. Créer le compte pour Karim Benali (Recruteur Senior)
New-ADUser -Name "Karim Benali (Recruteur)" `
    -GivenName "Karim" `
    -Surname "Benali" `
    -SamAccountName "karim.benali.recruteur" `
    -UserPrincipalName "karim.benali.recruteur@maxtec.be" `
    -Path "OU=Utilisateurs,OU=RH,OU=EU,DC=maxtec,DC=be" `
    -AccountPassword (ConvertTo-SecureString "Password1!" -AsPlainText -Force) `
    -Enabled $true `
    -ChangePasswordAtLogon $true `
    -Description "Recruteur Senior - Service RH" `
    -Department "RH" `
    -Title "Recruteur Senior"

# 2. Créer le compte pour Karim Benali (Assistant RH)
New-ADUser -Name "Karim Benali (Assistant)" `
    -GivenName "Karim" `
    -Surname "Benali" `
    -SamAccountName "karim.benali.assistant" `
    -UserPrincipalName "karim.benali.assistant@maxtec.be" `
    -Path "OU=Utilisateurs,OU=RH,OU=EU,DC=maxtec,DC=be" `
    -AccountPassword (ConvertTo-SecureString "Password1!" -AsPlainText -Force) `
    -Enabled $true `
    -ChangePasswordAtLogon $true `
    -Description "Assistant RH - Service RH" `
    -Department "RH" `
    -Title "Assistant RH"
```

## Exercice 7: Compte Temporaire

**Scénario**: Un consultant externe arrive pour un audit de 3 mois.

**Solution PowerShell**:

```powershell
# 1. Créer un compte temporaire pour le consultant
$dateExpiration = (Get-Date).AddDays(90)

New-ADUser -Name "Marek Wojcik" `
    -GivenName "Marek" `
    -Surname "Wojcik" `
    -SamAccountName "marek.wojcik" `
    -UserPrincipalName "marek.wojcik@maxtec.be" `
    -Path "OU=Utilisateurs,OU=Comptabilité,OU=EU,DC=maxtec,DC=be" `
    -AccountPassword (ConvertTo-SecureString "Password1!" -AsPlainText -Force) `
    -Enabled $true `
    -ChangePasswordAtLogon $true `
    -Description "EXT-Consultant Audit - Temporaire" `
    -AccountExpirationDate $dateExpiration `
    -LogonWorkstations "ws-compta-01"

# 2. Définir les heures de connexion (9h-17h, jours ouvrés)
$heures = New-Object byte[] 21
for ($jour = 0; $jour -le 4; $jour++) {
    for ($heure = 9; $heure -lt 17; $heure++) {
        $octet = [math]::Floor($heure / 8) + ($jour * 3)
        $bit = [math]::Pow(2, $heure % 8)
        $heures[$octet] = $heures[$octet] -bor $bit
    }
}
Set-ADUser -Identity "marek.wojcik" -Replace @{logonHours = $heures}
```

## Exercice 8: Vérification des Comptes Inactifs

**Scénario**: Identifier et documenter les comptes inactifs.

**Solution PowerShell**:

```powershell
# 1. Identifier les comptes qui n'ont pas été utilisés depuis 30 jours
$dateLimite = (Get-Date).AddDays(-30)
$comptesInactifs = Search-ADAccount -AccountInactive -TimeSpan 30.00:00:00 -UsersOnly

# 2. Documenter chaque compte inactif
$rapport = @()
foreach ($compte in $comptesInactifs) {
    $utilisateur = Get-ADUser -Identity $compte.SamAccountName -Properties LastLogonDate, Description, Department
    
    # Mettre à jour la description
    $nouvelleDescription = "INACTIF depuis $($utilisateur.LastLogonDate) - Vérifié le $(Get-Date -Format 'yyyy-MM-dd')"
    if ($utilisateur.Description) {
        $nouvelleDescription = "$($utilisateur.Description) | $nouvelleDescription"
    }
    Set-ADUser -Identity $compte.SamAccountName -Description $nouvelleDescription
    
    # Ajouter au rapport
    $rapport += [PSCustomObject]@{
        Nom = $utilisateur.Name
        SamAccountName = $utilisateur.SamAccountName
        Département = $utilisateur.Department
        DernièreConnexion = $utilisateur.LastLogonDate
        Description = $nouvelleDescription
    }
}

# 3. Exporter le rapport pour la direction
$rapport | Export-Csv -Path "C:\Rapports\ComptesInactifs.csv" -NoTypeInformation -Encoding UTF8
Write-Host "Rapport des comptes inactifs généré: C:\Rapports\ComptesInactifs.csv"
```

## Exercice 9: Mise à Jour des Informations

**Scénario**: Mettre à jour les informations de bureau pour tous les utilisateurs du service Comptabilité.

**Solution PowerShell**:

```powershell
# 1. Obtenir tous les utilisateurs du département Comptabilité
$utilisateursCompta = Get-ADUser -Filter {Department -eq "Comptabilité"} -Properties Department, Office, OfficePhone

# 2. Mettre à jour les informations de bureau et téléphone
$compteur = 0
foreach ($utilisateur in $utilisateursCompta) {
    # Générer un numéro de téléphone unique
    $numeroTel = "+32 2 123 " + (Get-Random -Minimum 10 -Maximum 99) + " " + (Get-Random -Minimum 10 -Maximum 99)
    
    # Mettre à jour les informations
    Set-ADUser -Identity $utilisateur.SamAccountName `
        -Office "Bâtiment B - 3e étage" `
        -OfficePhone $numeroTel
    
    $compteur++
}

# 3. Vérifier les mises à jour
$utilisateursMAJ = Get-ADUser -Filter {Department -eq "Comptabilité"} -Properties Department, Office, OfficePhone
Write-Host "$compteur utilisateurs mis à jour dans le département Comptabilité"
Write-Host "Exemple de mise à jour:"
$utilisateursMAJ[0] | Select-Object Name, Office, OfficePhone | Format-List
```

## Exercice 10: Résolution des Problèmes de Connexion

**Scénario**: L'utilisatrice Sarah El Amrani ne peut plus se connecter.

**Solution PowerShell**:

```powershell
# 1. Vérifier l'état du compte
$utilisateur = Get-ADUser -Identity "sarah.elamrani" -Properties *

Write-Host "Diagnostic du compte utilisateur: $($utilisateur.Name)"
Write-Host "----------------------------------------"
Write-Host "Compte activé: $($utilisateur.Enabled)"
Write-Host "Compte verrouillé: $($utilisateur.LockedOut)"
Write-Host "Expiration du compte: $($utilisateur.AccountExpirationDate)"
Write-Host "Dernière connexion: $($utilisateur.LastLogonDate)"
Write-Host "Postes de travail autorisés: $($utilisateur.LogonWorkstations)"
Write-Host "----------------------------------------"

# 2. Résoudre les problèmes potentiels
$problèmesRésolus = @()

# Vérifier si le compte est verrouillé
if ($utilisateur.LockedOut) {
    Unlock-ADAccount -Identity $utilisateur.SamAccountName
    $problèmesRésolus += "Compte déverrouillé"
}

# Vérifier si le compte est désactivé
if (-not $utilisateur.Enabled) {
    Enable-ADAccount -Identity $utilisateur.SamAccountName
    $problèmesRésolus += "Compte réactivé"
}

# Vérifier si le compte a expiré
if ($utilisateur.AccountExpirationDate -and $utilisateur.AccountExpirationDate -lt (Get-Date)) {
    Set-ADUser -Identity $utilisateur.SamAccountName -AccountExpirationDate $null
    $problèmesRésolus += "Date d'expiration supprimée"
}

# Vérifier les restrictions de poste de travail
if ($utilisateur.LogonWorkstations -and -not $utilisateur.LogonWorkstations.Contains("*")) {
    # Ajouter le poste actuel aux postes autorisés
    $nouveauxPostes = $utilisateur.LogonWorkstations
    if ($nouveauxPostes) {
        $nouveauxPostes += ",ws-rh-01"
    } else {
        $nouveauxPostes = "ws-rh-01"
    }
    Set-ADUser -Identity $utilisateur.SamAccountName -LogonWorkstations $nouveauxPostes
    $problèmesRésolus += "Poste de travail ws-rh-01 ajouté aux postes autorisés"
}

# Afficher les actions effectuées
if ($problèmesRésolus.Count -gt 0) {
    Write-Host "Actions effectuées:"
    $problèmesRésolus | ForEach-Object { Write-Host "- $_" }
} else {
    Write-Host "Aucun problème évident détecté. Vérifiez les stratégies de groupe et les paramètres de sécurité."
}
```

## Exercice 11: Gestion des Profils Itinérants

**Scénario**: Configurer des profils itinérants pour l'équipe de vente.

**Solution PowerShell**:

```powershell
# 1. Créer un partage réseau pour les profils itinérants
# Note: Cette partie nécessite généralement des droits d'administrateur sur le serveur de fichiers

# Créer le dossier pour les profils
$cheminProfils = "C:\Profiles"
if (-not (Test-Path $cheminProfils)) {
    New-Item -Path $cheminProfils -ItemType Directory
}

# Créer le partage réseau
$nomPartage = "Profiles$"
New-SmbShare -Name $nomPartage -Path $cheminProfils -FullAccess "Administrateurs" -ChangeAccess "Utilisateurs du domaine"

# 2. Configurer les profils itinérants pour les commerciaux
$utilisateurs = @("pierre.dubois", "marie.lambert", "ahmed.benali")
$serveur = "dns1"  # Nom du serveur de fichiers

foreach ($utilisateur in $utilisateurs) {
    # Créer le dossier individuel pour l'utilisateur
    $dossierUtilisateur = Join-Path -Path $cheminProfils -ChildPath $utilisateur
    if (-not (Test-Path $dossierUtilisateur)) {
        New-Item -Path $dossierUtilisateur -ItemType Directory
    }
    
    # Définir les permissions NTFS
    $acl = Get-Acl -Path $dossierUtilisateur
    $permission = New-Object System.Security.AccessControl.FileSystemAccessRule("maxtec\$utilisateur", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $acl.SetAccessRule($permission)
    Set-Acl -Path $dossierUtilisateur -AclObject $acl
    
    # Configurer le profil itinérant dans AD
    $cheminProfil = "\\$serveur\$nomPartage\$utilisateur"
    Set-ADUser -Identity $utilisateur -ProfilePath $cheminProfil
    
    # Configurer la limite de taille (via GPO en réalité, simulé ici)
    Write-Host "Profil itinérant configuré pour $utilisateur: $cheminProfil"
    Write-Host "Limite de taille de 500 MB définie (à implémenter via GPO)"
}
```

## Exercice 12: Délégation d'Administration

**Scénario**: Permettre à Claire Martin de gérer les comptes de son service.

**Solution PowerShell**:

```powershell
# 1. Créer un groupe pour la délégation
New-ADGroup -Name "GG-EU-RH-AdminDelegue" `
    -GroupScope Global `
    -Path "OU=Groupes,OU=EU,DC=maxtec,DC=be"

# 2. Ajouter Claire au groupe
Add-ADGroupMember -Identity "GG-EU-RH-AdminDelegue" -Members "claire.martin"

# 3. Configurer les droits délégués
# Note: Cette partie utilise dsacls, un outil en ligne de commande pour gérer les ACL AD

# Obtenir le chemin de l'OU RH
$ouRH = "OU=RH,OU=EU,DC=maxtec,DC=be"

# Déléguer les droits de création/modification de comptes
dsacls $ouRH /G "maxtec\GG-EU-RH-AdminDelegue:CCDC;User" /I:S

# Déléguer les droits de réinitialisation des mots de passe
dsacls "$ouRH\OU=Utilisateurs" /G "maxtec\GG-EU-RH-AdminDelegue:CA;Reset Password;User" /I:S

# Déléguer les droits de modification des informations de profil
dsacls "$ouRH\OU=Utilisateurs" /G "maxtec\GG-EU-RH-AdminDelegue:WP;givenName;User" /I:S
dsacls "$ouRH\OU=Utilisateurs" /G "maxtec\GG-EU-RH-AdminDelegue:WP;sn;User" /I:S
dsacls "$ouRH\OU=Utilisateurs" /G "maxtec\GG-EU-RH-AdminDelegue:WP;displayName;User" /I:S
dsacls "$ouRH\OU=Utilisateurs" /G "maxtec\GG-EU-RH-AdminDelegue:WP;description;User" /I:S
dsacls "$ouRH\OU=Utilisateurs" /G "maxtec\GG-EU-RH-AdminDelegue:WP;telephoneNumber;User" /I:S
dsacls "$ouRH\OU=Utilisateurs" /G "maxtec\GG-EU-RH-AdminDelegue:WP;physicalDeliveryOfficeName;User" /I:S

Write-Host "Délégation configurée pour Claire Martin via le groupe GG-EU-RH-AdminDelegue"
```

## Exercice 13: Migration d'Utilisateurs

**Scénario**: Migration de l'équipe Support du service IT au service Ventes.

**Solution PowerShell**:

```powershell
# 1. Identifier les utilisateurs à déplacer (équipe Support)
$utilisateursSupport = Get-ADUser -Filter {Department -eq "IT" -and Title -like "*Support*"} -Properties Department, Title, MemberOf

# 2. Planifier la migration
# Créer un groupe pour l'équipe Support dans le service Ventes si nécessaire
if (-not (Get-ADGroup -Filter {Name -eq "GG-EU-Ventes-Support"} -ErrorAction SilentlyContinue)) {
    New-ADGroup -Name "GG-EU-Ventes-Support" `
        -GroupScope Global `
        -Path "OU=Groupes,OU=EU,DC=maxtec,DC=be" `
        -Description "Équipe Support du service Ventes"
}

# 3. Exécuter la migration
foreach ($utilisateur in $utilisateursSupport) {
    # Stocker les groupes actuels pour référence
    $groupesActuels = Get-ADPrincipalGroupMembership -Identity $utilisateur.SamAccountName
    
    # Déplacer l'utilisateur vers l'OU Ventes
    Move-ADObject -Identity $utilisateur.DistinguishedName `
        -TargetPath "OU=Utilisateurs,OU=Ventes,OU=EU,DC=maxtec,DC=be"
    
    # Mettre à jour les attributs
    Set-ADUser -Identity $utilisateur.SamAccountName `
        -Department "Ventes" `
        -Description "Support - Service Ventes (Transféré de IT)"
    
    # Ajouter au nouveau groupe
    Add-ADGroupMember -Identity "GG-EU-Ventes-Support" -Members $utilisateur.SamAccountName
    
    # Retirer des groupes IT spécifiques (à adapter selon votre environnement)
    foreach ($groupe in $groupesActuels) {
        if ($groupe.Name -like "GG-EU-IT*" -and $groupe.Name -ne "Domain Users") {
            Remove-ADGroupMember -Identity $groupe -Members $utilisateur.SamAccountName -Confirm:$false
            Write-Host "Utilisateur $($utilisateur.Name) retiré du groupe $($groupe.Name)"
        }
    }
    
    Write-Host "Migration de $($utilisateur.Name) vers le service Ventes terminée"
}

# 4. Vérifier la migration
$utilisateursMigrés = Get-ADUser -Filter {Department -eq "Ventes" -and Title -like "*Support*"} -Properties Department, Title
Write-Host "Nombre d'utilisateurs migrés: $($utilisateursMigrés.Count)"
```

## Exercice 14: Gestion des Comptes de Service

**Scénario**: Créer et sécuriser des comptes de service pour les applications internes.

**Solution PowerShell**:

```powershell
# 1. Créer les comptes de service
$comptesService = @(
    @{
        Nom = "svc-backup"
        Description = "Compte de service pour les sauvegardes"
        Serveurs = "srv-backup,srv-admin"
    },
    @{
        Nom = "svc-monitoring"
        Description = "Compte de service pour la surveillance"
        Serveurs = "srv-monitor,srv-admin"
    },
    @{
        Nom = "svc-print"
        Description = "Compte de service pour le serveur d'impression"
        Serveurs = "srv-print"
    }
)

# Créer un dossier pour stocker le registre des comptes
$dossierRegistre = "C:\ServiceAccounts"
if (-not (Test-Path $dossierRegistre)) {
    New-Item -Path $dossierRegistre -ItemType Directory
}

# Créer le fichier de registre
$registre = @()

foreach ($compte in $comptesService) {
    # Générer un mot de passe complexe
    $longueur = 20
    $caracteres = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_-+={}[]"
    $motDePasse = 1..$longueur | ForEach-Object { $caracteres[(Get-Random -Maximum $caracteres.Length)] } | Join-String
    $motDePasseSecurise = ConvertTo-SecureString $motDePasse -AsPlainText -Force
    
    # Créer le compte de service
    New-ADUser -Name $compte.Nom `
        -SamAccountName $compte.Nom `
        -UserPrincipalName "$($compte.Nom)@maxtec.be" `
        -Path "OU=ServiceAccounts,DC=maxtec,DC=be" `
        -AccountPassword $motDePasseSecurise `
        -Enabled $true `
        -PasswordNeverExpires $true `
        -CannotChangePassword $true `
        -Description $compte.Description `
        -LogonWorkstations $compte.Serveurs
    
    # Ajouter au registre
    $registre += [PSCustomObject]@{
        Compte = $compte.Nom
        Description = $compte.Description
        ServeursAutorises = $compte.Serveurs
        DateCreation = Get-Date -Format "yyyy-MM-dd"
        MotDePasse = $motDePasse  # En production, ne jamais stocker en clair!
    }
    
    Write-Host "Compte de service $($compte.Nom) créé avec succès"
}

# Exporter le registre (en production, utiliser un stockage sécurisé!)
$registre | Export-Csv -Path "$dossierRegistre\RegistreComptesService.csv" -NoTypeInformation -Encoding UTF8
Write-Host "Registre des comptes de service créé: $dossierRegistre\RegistreComptesService.csv"
Write-Host "IMPORTANT: En production, ne jamais stocker les mots de passe en clair!"
```

## Remarques importantes

1. Ces scripts sont conçus pour être éducatifs et illustrer les concepts de PowerShell pour la gestion d'Active Directory.

2. Dans un environnement de production :
   - Ne jamais stocker les mots de passe en clair
   - Toujours tester les scripts dans un environnement de test avant de les utiliser en production
   - Utiliser des méthodes plus sécurisées pour gérer les informations sensibles

3. Certaines opérations (comme la délégation de contrôle) peuvent nécessiter des outils supplémentaires ou des méthodes différentes selon votre environnement.

4. Adaptez toujours les scripts à votre environnement spécifique avant de les exécuter.
