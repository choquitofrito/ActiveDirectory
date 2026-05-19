# Script pour créer la structure Active Directory - Agence CreativeHub
# Nom du script: CreativeHub_Setup.ps1
# Auteur: Laboratoire Active Directory - Formation Débutants
# Date: 2025-10-04
# Description: Création d'une structure AD complète pour une agence de marketing digital et design
#
# Sources Microsoft consultées:
# - https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-adorganizationalunit?view=windowsserver2022-ps
# - https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-aduser?view=windowsserver2025-ps
# - https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-adgroup?view=windowsserver2022-ps
# - https://learn.microsoft.com/en-us/powershell/module/grouppolicy/new-gpo?view=windowsserver2022-ps
# - https://learn.microsoft.com/en-us/powershell/module/grouppolicy/set-gpregistryvalue?view=windowsserver2022-ps
# - https://learn.microsoft.com/en-us/powershell/module/grouppolicy/new-gplink?view=windowsserver2022-ps

# ============================================
# FONCTIONS UTILITAIRES
# ============================================

# Fonction pour demander confirmation avant chaque étape
function Confirm-Step {
    param($stepName)
    Write-Host "`nPrêt à exécuter: $stepName" -ForegroundColor Yellow
    $response = Read-Host "Appuyez sur 'O' pour continuer, 'N' pour sauter cette étape, ou 'Q' pour quitter"
    if ($response.ToUpper() -eq 'Q') {
        Write-Host "Script arrêté par l'utilisateur." -ForegroundColor Red
        exit
    }
    return $response.ToUpper() -eq 'O'
}

# Fonction pour vérifier l'existence d'une OU
function Test-OUExists {
    param($ouDN)
    try {
        Get-ADOrganizationalUnit -Identity $ouDN -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Fonction pour vérifier l'existence d'un utilisateur
function Test-UserExists {
    param($samAccountName)
    try {
        Get-ADUser -Identity $samAccountName -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Fonction pour vérifier l'existence d'un groupe
function Test-GroupExists {
    param($groupName)
    try {
        Get-ADGroup -Identity $groupName -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Fonction pour vérifier l'existence d'une GPO
function Test-GPOExists {
    param($gpoName)
    try {
        Get-GPO -Name $gpoName -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# ============================================
# VARIABLES GLOBALES
# ============================================

Import-Module ActiveDirectory

$domainDN = "DC=maxtec,DC=be"
$rootOU = "OU=CreativeHub,$domainDN"
$defaultPassword = ConvertTo-SecureString "Azerty_1" -AsPlainText -Force

# Créer le répertoire pour les exports CSV si nécessaire
$exportPath = "C:\Labos"
if (-not (Test-Path $exportPath)) {
    New-Item -Path $exportPath -ItemType Directory -Force | Out-Null
    Write-Host "Répertoire de travail créé: $exportPath" -ForegroundColor Green
}

# ============================================
# SCRIPT PRINCIPAL
# ============================================

try {
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host " CREATION STRUCTURE AD - AGENCE CREATIVEHUB" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Cette agence de marketing digital et design compte 4 départements:" -ForegroundColor White
    Write-Host "  - Marketing (Community managers, spécialistes SEO)" -ForegroundColor White
    Write-Host "  - Creative (Graphistes, vidéastes)" -ForegroundColor White
    Write-Host "  - Client Services (Chefs de projet, gestionnaires de comptes)" -ForegroundColor White
    Write-Host "  - IT Support (Développeurs web, support technique)" -ForegroundColor White
    Write-Host ""

    # ============================================
    # ÉTAPE 1: CRÉATION DE L'OU RACINE
    # ============================================

    if (Confirm-Step "Création de l'Unité Organisationnelle racine 'CreativeHub'") {
        Write-Host "`n[ÉTAPE 1] Création de l'OU racine CreativeHub..." -ForegroundColor Cyan

        if (Test-OUExists $rootOU) {
            Write-Host "  L'OU '$rootOU' existe déjà." -ForegroundColor Yellow
        } else {
            New-ADOrganizationalUnit -Name "CreativeHub" -Path $domainDN -ProtectedFromAccidentalDeletion $false
            Write-Host "  OU 'CreativeHub' créée avec succès." -ForegroundColor Green
        }
    }

    # ============================================
    # ÉTAPE 2: CRÉATION DES OUs DÉPARTEMENTALES
    # ============================================

    if (Confirm-Step "Création des Unités Organisationnelles départementales") {
        Write-Host "`n[ÉTAPE 2] Création des OUs départementales et sous-OUs..." -ForegroundColor Cyan

        $departments = @("Marketing", "Creative", "ClientServices", "ITSupport")

        foreach ($dept in $departments) {
            $deptOU = "OU=$dept,$rootOU"

            # Créer l'OU du département
            if (Test-OUExists $deptOU) {
                Write-Host "  L'OU '$dept' existe déjà." -ForegroundColor Yellow
            } else {
                New-ADOrganizationalUnit -Name $dept -Path $rootOU -ProtectedFromAccidentalDeletion $false
                Write-Host "  OU '$dept' créée avec succès." -ForegroundColor Green
            }

            # Créer les sous-OUs: Users, Computers, Groups
            $subOUs = @("Users", "Computers", "Groups")
            foreach ($subOU in $subOUs) {
                $subOUPath = "OU=$subOU,$deptOU"
                if (Test-OUExists $subOUPath) {
                    Write-Host "    Sous-OU '$subOU' dans '$dept' existe déjà." -ForegroundColor Yellow
                } else {
                    New-ADOrganizationalUnit -Name $subOU -Path $deptOU -ProtectedFromAccidentalDeletion $false
                    Write-Host "    Sous-OU '$subOU' créée dans '$dept'." -ForegroundColor Green
                }
            }
        }
    }

    # ============================================
    # ÉTAPE 3: CRÉATION DES UTILISATEURS
    # ============================================

    if (Confirm-Step "Création des comptes utilisateurs (18 employés)") {
        Write-Host "`n[ÉTAPE 3] Création des utilisateurs..." -ForegroundColor Cyan

        # Définition des utilisateurs par département
        $users = @(
            # Département Marketing (5 utilisateurs)
            @{FirstName="Amélie"; LastName="Dubois"; Dept="Marketing"; Title="Community Manager"; SAM="amelie"},
            @{FirstName="Bastien"; LastName="Martin"; Dept="Marketing"; Title="Spécialiste SEO"; SAM="bastien"},
            @{FirstName="Camille"; LastName="Bernard"; Dept="Marketing"; Title="Responsable Marketing Digital"; SAM="camille"},
            @{FirstName="Damien"; LastName="Petit"; Dept="Marketing"; Title="Content Strategist"; SAM="damien"},
            @{FirstName="Élise"; LastName="Robert"; Dept="Marketing"; Title="Social Media Analyst"; SAM="elise"},

            # Département Creative (5 utilisateurs)
            @{FirstName="Fabien"; LastName="Moreau"; Dept="Creative"; Title="Graphiste Senior"; SAM="fabien"},
            @{FirstName="Gabrielle"; LastName="Simon"; Dept="Creative"; Title="Directrice Artistique"; SAM="gabrielle"},
            @{FirstName="Hugo"; LastName="Laurent"; Dept="Creative"; Title="Motion Designer"; SAM="hugo"},
            @{FirstName="Inès"; LastName="Lefebvre"; Dept="Creative"; Title="Vidéaste"; SAM="ines"},
            @{FirstName="Julien"; LastName="Roux"; Dept="Creative"; Title="Designer UX/UI"; SAM="julien"},

            # Département Client Services (4 utilisateurs)
            @{FirstName="Karine"; LastName="Garnier"; Dept="ClientServices"; Title="Chef de Projet Senior"; SAM="karine"},
            @{FirstName="Laurent"; LastName="Faure"; Dept="ClientServices"; Title="Account Manager"; SAM="laurent"},
            @{FirstName="Manon"; LastName="Girard"; Dept="ClientServices"; Title="Chef de Projet Junior"; SAM="manon"},
            @{FirstName="Nicolas"; LastName="André"; Dept="ClientServices"; Title="Directeur des Opérations"; SAM="nicolas"},

            # Département IT Support (4 utilisateurs)
            @{FirstName="Olivier"; LastName="Mercier"; Dept="ITSupport"; Title="Développeur Web Full-Stack"; SAM="olivier"},
            @{FirstName="Pauline"; LastName="Blanc"; Dept="ITSupport"; Title="Administratrice Systèmes"; SAM="pauline"},
            @{FirstName="Quentin"; LastName="Guerin"; Dept="ITSupport"; Title="Développeur Front-End"; SAM="quentin"},
            @{FirstName="Rachid"; LastName="Dupont"; Dept="ITSupport"; Title="Responsable IT"; SAM="rachid"}
        )

        foreach ($user in $users) {
            $userPath = "OU=Users,OU=$($user.Dept),$rootOU"
            $userSAM = $user.SAM

            if (Test-UserExists $userSAM) {
                Write-Host "  L'utilisateur '$userSAM' existe déjà." -ForegroundColor Yellow
            } else {
                try {
                    $params = @{
                        Name = "$($user.FirstName) $($user.LastName)"
                        GivenName = $user.FirstName
                        Surname = $user.LastName
                        SamAccountName = $userSAM
                        UserPrincipalName = "$userSAM@maxtec.be"
                        EmailAddress = "$userSAM@maxtec.be"
                        Title = $user.Title
                        Department = $user.Dept
                        Path = $userPath
                        AccountPassword = $defaultPassword
                        Enabled = $true
                        ChangePasswordAtLogon = $false
                    }
                    New-ADUser @params
                    Write-Host "  Utilisateur créé: $($user.FirstName) $($user.LastName) ($userSAM) - $($user.Title)" -ForegroundColor Green
                } catch {
                    Write-Host "  ERREUR lors de la création de $userSAM : $($_.Exception.Message)" -ForegroundColor Red
                }
            }
        }
    }

    # ============================================
    # ÉTAPE 4: CRÉATION DES GROUPES DE SÉCURITÉ
    # ============================================

    if (Confirm-Step "Création des groupes de sécurité globaux") {
        Write-Host "`n[ÉTAPE 4] Création des groupes de sécurité..." -ForegroundColor Cyan

        $departments = @("Marketing", "Creative", "ClientServices", "ITSupport")

        foreach ($dept in $departments) {
            $groupPath = "OU=Groups,OU=$dept,$rootOU"

            # Créer groupe Users
            $groupNameUsers = "GG-CreativeHub-$dept-Users"
            if (Test-GroupExists $groupNameUsers) {
                Write-Host "  Le groupe '$groupNameUsers' existe déjà." -ForegroundColor Yellow
            } else {
                New-ADGroup -Name $groupNameUsers -GroupScope Global -GroupCategory Security -Path $groupPath -Description "Tous les utilisateurs du département $dept"
                Write-Host "  Groupe créé: $groupNameUsers" -ForegroundColor Green
            }

            # Créer groupe Admin
            $groupNameAdmin = "GG-CreativeHub-$dept-Admin"
            if (Test-GroupExists $groupNameAdmin) {
                Write-Host "  Le groupe '$groupNameAdmin' existe déjà." -ForegroundColor Yellow
            } else {
                New-ADGroup -Name $groupNameAdmin -GroupScope Global -GroupCategory Security -Path $groupPath -Description "Administrateurs du département $dept"
                Write-Host "  Groupe créé: $groupNameAdmin" -ForegroundColor Green
            }
        }
    }

    # ============================================
    # ÉTAPE 5: AJOUT DES UTILISATEURS AUX GROUPES
    # ============================================

    if (Confirm-Step "Affectation des utilisateurs aux groupes de sécurité") {
        Write-Host "`n[ÉTAPE 5] Ajout des utilisateurs aux groupes..." -ForegroundColor Cyan

        $departments = @("Marketing", "Creative", "ClientServices", "ITSupport")

        foreach ($dept in $departments) {
            $groupNameUsers = "GG-CreativeHub-$dept-Users"
            $groupNameAdmin = "GG-CreativeHub-$dept-Admin"

            # Récupérer tous les utilisateurs du département
            $deptUsers = Get-ADUser -Filter "Department -eq '$dept'" -SearchBase $rootOU | Sort-Object SamAccountName

            if ($deptUsers.Count -eq 0) {
                Write-Host "  Aucun utilisateur trouvé dans le département $dept." -ForegroundColor Yellow
                continue
            }

            Write-Host "`n  Département: $dept ($($deptUsers.Count) utilisateurs)" -ForegroundColor White

            # Ajouter tous les utilisateurs au groupe Users
            foreach ($user in $deptUsers) {
                try {
                    $isMember = Get-ADGroupMember -Identity $groupNameUsers | Where-Object {$_.SamAccountName -eq $user.SamAccountName}
                    if ($isMember) {
                        Write-Host "    $($user.SamAccountName) est déjà membre de $groupNameUsers" -ForegroundColor Yellow
                    } else {
                        Add-ADGroupMember -Identity $groupNameUsers -Members $user.SamAccountName
                        Write-Host "    $($user.SamAccountName) ajouté à $groupNameUsers" -ForegroundColor Green
                    }
                } catch {
                    Write-Host "    ERREUR lors de l'ajout de $($user.SamAccountName) à $groupNameUsers" -ForegroundColor Red
                }
            }

            # Ajouter le premier utilisateur alphabétiquement au groupe Admin
            $firstUser = $deptUsers | Select-Object -First 1
            try {
                $isMember = Get-ADGroupMember -Identity $groupNameAdmin | Where-Object {$_.SamAccountName -eq $firstUser.SamAccountName}
                if ($isMember) {
                    Write-Host "    $($firstUser.SamAccountName) est déjà administrateur de $groupNameAdmin" -ForegroundColor Yellow
                } else {
                    Add-ADGroupMember -Identity $groupNameAdmin -Members $firstUser.SamAccountName
                    Write-Host "    $($firstUser.SamAccountName) ajouté à $groupNameAdmin (Administrateur)" -ForegroundColor Green
                }
            } catch {
                Write-Host "    ERREUR lors de l'ajout de $($firstUser.SamAccountName) à $groupNameAdmin" -ForegroundColor Red
            }
        }
    }

    # ============================================
    # ÉTAPE 6: CRÉATION DES STRATÉGIES DE GROUPE (GPOs)
    # ============================================

    if (Confirm-Step "Création des Stratégies de Groupe (GPOs)") {
        Write-Host "`n[ÉTAPE 6] Création et liaison des GPOs..." -ForegroundColor Cyan

        # ========== GPO 1: Restrictions pour les Stagiaires/Juniors ==========
        $gpoName1 = "CreativeHub - Restrictions Utilisateurs Juniors"
        Write-Host "`n  GPO 1: $gpoName1" -ForegroundColor White
        Write-Host "  Objectif: Désactiver le Panneau de configuration et l'invite de commandes pour les juniors" -ForegroundColor Gray

        if (Test-GPOExists $gpoName1) {
            Write-Host "  La GPO '$gpoName1' existe déjà." -ForegroundColor Yellow
        } else {
            try {
                # Créer la GPO
                New-GPO -Name $gpoName1 -Comment "Restreint l'accès au Panneau de configuration et CMD pour utilisateurs juniors" | Out-Null

                # Désactiver le Panneau de configuration
                # Source: HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer
                Set-GPRegistryValue -Name $gpoName1 -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoControlPanel" -Type DWord -Value 1 | Out-Null

                # Désactiver l'invite de commandes
                # Source: HKCU\Software\Policies\Microsoft\Windows\System
                Set-GPRegistryValue -Name $gpoName1 -Key "HKCU\Software\Policies\Microsoft\Windows\System" -ValueName "DisableCMD" -Type DWord -Value 2 | Out-Null

                Write-Host "  GPO '$gpoName1' créée avec succès." -ForegroundColor Green
                Write-Host "    - Panneau de configuration désactivé (NoControlPanel=1)" -ForegroundColor Gray
                Write-Host "    - Invite de commandes désactivée (DisableCMD=2)" -ForegroundColor Gray

                # Lier la GPO aux OUs Users (exemple: Marketing et Creative pour les juniors)
                $ouMarketing = "OU=Users,OU=Marketing,$rootOU"
                $ouCreative = "OU=Users,OU=Creative,$rootOU"

                New-GPLink -Name $gpoName1 -Target $ouMarketing -LinkEnabled Yes | Out-Null
                Write-Host "  GPO liée à: $ouMarketing" -ForegroundColor Green

                New-GPLink -Name $gpoName1 -Target $ouCreative -LinkEnabled Yes | Out-Null
                Write-Host "  GPO liée à: $ouCreative" -ForegroundColor Green

            } catch {
                Write-Host "  ERREUR lors de la création de la GPO: $($_.Exception.Message)" -ForegroundColor Red
            }
        }

        # ========== GPO 2: Restriction USB pour Client Services ==========
        $gpoName2 = "CreativeHub - Blocage USB Client Services"
        Write-Host "`n  GPO 2: $gpoName2" -ForegroundColor White
        Write-Host "  Objectif: Bloquer les périphériques de stockage USB pour protéger les données clients sensibles" -ForegroundColor Gray

        if (Test-GPOExists $gpoName2) {
            Write-Host "  La GPO '$gpoName2' existe déjà." -ForegroundColor Yellow
        } else {
            try {
                # Créer la GPO
                New-GPO -Name $gpoName2 -Comment "Bloque les périphériques de stockage USB pour le département Client Services" | Out-Null

                # Bloquer l'accès en écriture aux périphériques de stockage amovibles
                # Source: HKLM\Software\Policies\Microsoft\Windows\RemovableStorageDevices\{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}
                # GUID {53f5630d-b6bf-11d0-94f2-00a0c91efb8b} = Removable Disks
                Set-GPRegistryValue -Name $gpoName2 -Key "HKLM\Software\Policies\Microsoft\Windows\RemovableStorageDevices\{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}" -ValueName "Deny_Write" -Type DWord -Value 1 | Out-Null

                # Bloquer l'accès en lecture aux périphériques de stockage amovibles
                Set-GPRegistryValue -Name $gpoName2 -Key "HKLM\Software\Policies\Microsoft\Windows\RemovableStorageDevices\{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}" -ValueName "Deny_Read" -Type DWord -Value 1 | Out-Null

                Write-Host "  GPO '$gpoName2' créée avec succès." -ForegroundColor Green
                Write-Host "    - Accès en lecture USB bloqué (Deny_Read=1)" -ForegroundColor Gray
                Write-Host "    - Accès en écriture USB bloqué (Deny_Write=1)" -ForegroundColor Gray

                # Lier la GPO à l'OU Client Services
                $ouClientServices = "OU=Users,OU=ClientServices,$rootOU"
                New-GPLink -Name $gpoName2 -Target $ouClientServices -LinkEnabled Yes | Out-Null
                Write-Host "  GPO liée à: $ouClientServices" -ForegroundColor Green

            } catch {
                Write-Host "  ERREUR lors de la création de la GPO: $($_.Exception.Message)" -ForegroundColor Red
            }
        }

        # ========== GPO 3: Mappage de Lecteurs Réseau - Projets et Ressources ==========
        $gpoName3 = "CreativeHub - Lecteurs Réseau Partagés"
        Write-Host "`n  GPO 3: $gpoName3" -ForegroundColor White
        Write-Host "  Objectif: Mapper des lecteurs réseau pour les projets clients et ressources créatives" -ForegroundColor Gray
        Write-Host "  NOTE: Cette GPO crée la configuration de base. Les partages réseau doivent être créés manuellement." -ForegroundColor Yellow

        if (Test-GPOExists $gpoName3) {
            Write-Host "  La GPO '$gpoName3' existe déjà." -ForegroundColor Yellow
        } else {
            try {
                # Créer la GPO
                New-GPO -Name $gpoName3 -Comment "Mappe les lecteurs réseau P: (Projets) et R: (Ressources) pour tous les départements" | Out-Null

                Write-Host "  GPO '$gpoName3' créée avec succès." -ForegroundColor Green
                Write-Host "    NOTE: Le mappage de lecteurs doit être configuré via Group Policy Preferences" -ForegroundColor Yellow
                Write-Host "    dans la console GPMC (User Config > Preferences > Windows Settings > Drive Maps)" -ForegroundColor Yellow
                Write-Host "    Exemple: P: -> \\SERVEUR\Projets, R: -> \\SERVEUR\Ressources" -ForegroundColor Gray

                # Lier la GPO à l'OU racine CreativeHub pour tous les utilisateurs
                New-GPLink -Name $gpoName3 -Target $rootOU -LinkEnabled Yes | Out-Null
                Write-Host "  GPO liée à: $rootOU (tous les départements)" -ForegroundColor Green

            } catch {
                Write-Host "  ERREUR lors de la création de la GPO: $($_.Exception.Message)" -ForegroundColor Red
            }
        }

        Write-Host "`n  IMPORTANT: Les GPOs nécessitent un 'gpupdate /force' sur les clients pour être appliquées." -ForegroundColor Yellow
    }

    # ============================================
    # ÉTAPE 7: EXPORT CSV POUR DOCUMENTATION
    # ============================================

    if (Confirm-Step "Export de la structure en fichiers CSV") {
        Write-Host "`n[ÉTAPE 7] Export de la documentation en CSV..." -ForegroundColor Cyan

        # Export des utilisateurs
        $csvUsers = "$exportPath\CreativeHub_Utilisateurs.csv"
        Get-ADUser -Filter * -SearchBase $rootOU -Properties EmailAddress, Title, Department |
            Select-Object Name, SamAccountName, EmailAddress, Title, Department, Enabled |
            Export-Csv -Path $csvUsers -NoTypeInformation -Encoding UTF8
        Write-Host "  Utilisateurs exportés vers: $csvUsers" -ForegroundColor Green

        # Export des groupes
        $csvGroups = "$exportPath\CreativeHub_Groupes.csv"
        $groupData = @()
        $groups = Get-ADGroup -Filter * -SearchBase $rootOU

        foreach ($group in $groups) {
            $members = Get-ADGroupMember -Identity $group | Select-Object -ExpandProperty SamAccountName
            $groupData += [PSCustomObject]@{
                NomGroupe = $group.Name
                Description = $group.Description
                Membres = ($members -join "; ")
                NombreMembres = $members.Count
            }
        }

        $groupData | Export-Csv -Path $csvGroups -NoTypeInformation -Encoding UTF8
        Write-Host "  Groupes exportés vers: $csvGroups" -ForegroundColor Green

        # Export des OUs
        $csvOUs = "$exportPath\CreativeHub_OUs.csv"
        Get-ADOrganizationalUnit -Filter * -SearchBase $rootOU |
            Select-Object Name, DistinguishedName |
            Export-Csv -Path $csvOUs -NoTypeInformation -Encoding UTF8
        Write-Host "  OUs exportées vers: $csvOUs" -ForegroundColor Green
    }

    # ============================================
    # RÉCAPITULATIF FINAL
    # ============================================

    Write-Host "`n============================================" -ForegroundColor Green
    Write-Host " STRUCTURE CREATIVEHUB CRÉÉE AVEC SUCCÈS!" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Résumé de la structure créée:" -ForegroundColor White
    Write-Host "  - 1 OU racine: CreativeHub" -ForegroundColor White
    Write-Host "  - 4 départements: Marketing, Creative, Client Services, IT Support" -ForegroundColor White
    Write-Host "  - 12 sous-OUs (Users, Computers, Groups par département)" -ForegroundColor White
    Write-Host "  - 18 utilisateurs répartis dans les 4 départements" -ForegroundColor White
    Write-Host "  - 8 groupes de sécurité (Users + Admin par département)" -ForegroundColor White
    Write-Host "  - 3 GPOs configurées pour la sécurité et la productivité" -ForegroundColor White
    Write-Host ""
    Write-Host "Fichiers CSV exportés dans: $exportPath" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Mot de passe par défaut pour tous les utilisateurs: Azerty_1" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Prochaines étapes recommandées:" -ForegroundColor White
    Write-Host "  1. Ouvrir 'Utilisateurs et ordinateurs Active Directory' pour explorer la structure" -ForegroundColor Gray
    Write-Host "  2. Vérifier les appartenances aux groupes de sécurité" -ForegroundColor Gray
    Write-Host "  3. Examiner les GPOs dans la console GPMC" -ForegroundColor Gray
    Write-Host "  4. Tester la connexion avec un compte utilisateur sur un client Windows" -ForegroundColor Gray
    Write-Host "  5. Exécuter 'gpupdate /force' sur les clients pour appliquer les GPOs" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Pour nettoyer cette structure et recommencer, exécutez: .\CreativeHub_Cleanup.ps1" -ForegroundColor Cyan
    Write-Host ""

} catch {
    Write-Host "`n============================================" -ForegroundColor Red
    Write-Host " ERREUR CRITIQUE" -ForegroundColor Red
    Write-Host "============================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Une erreur s'est produite lors de l'exécution du script:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Stack Trace:" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    Write-Host ""
    Write-Host "Veuillez vérifier:" -ForegroundColor Yellow
    Write-Host "  - Que vous exécutez ce script en tant qu'Administrateur" -ForegroundColor Yellow
    Write-Host "  - Que le module ActiveDirectory est disponible" -ForegroundColor Yellow
    Write-Host "  - Que le domaine maxtec.be est fonctionnel" -ForegroundColor Yellow
    Write-Host "  - Que vous êtes connecté à un contrôleur de domaine" -ForegroundColor Yellow
}
