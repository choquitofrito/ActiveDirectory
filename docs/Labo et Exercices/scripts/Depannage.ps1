<#
.SYNOPSIS
    Tickets de dépannage du lab Maxtec : installe la panne d'un ticket, ou la retire.

.DESCRIPTION
    NE LISEZ PAS CE SCRIPT avant d'avoir résolu le ticket : il contient les réponses.
    Prenez un instantané (snapshot) de vos VMs avant de lancer une panne.

    Sur le DC dns1, PowerShell 5.1 en administrateur :
      .\Depannage.ps1 -Ticket D1              lecteur réseau IT (variante courte)
      .\Depannage.ps1 -Ticket D1 -Complet     lecteur réseau IT (variante complète)
      .\Depannage.ps1 -Ticket D2              compte d'ines
      .\Depannage.ps1 -Ticket D3              partage Ventes-Documents (-Preparer si l'exercice AGDLP n'est pas fait)
      .\Depannage.ps1 -Ticket D4              DNS : sur dns1, PUIS la même commande sur ws-IT-01
      .\Depannage.ps1 -Ticket Incident        projet final, étape 6

    Retour à l'état d'avant la panne : même commande avec -Restaurer.
    Si vous avez renommé la GPO du lecteur (D1) ou de la Logistique (Incident) : -GpoName "<nom exact>".

    Garde-fous : arrêt si le domaine n'est pas maxtec.be ; aucune modification du DC lui-même,
    de la Default Domain Policy ni des comptes administrateurs.
    L'état d'origine est enregistré dans C:\ProgramData\Maxtec-Depannage (utilisé par -Restaurer).
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('D1', 'D2', 'D3', 'D4', 'Incident')]
    [string]$Ticket,
    [switch]$Restaurer,
    [switch]$Complet,
    [switch]$Preparer,
    [string]$GpoName = ''
)

$script:DomaineLab  = 'maxtec.be'
$script:DossierEtat = Join-Path $env:ProgramData 'Maxtec-Depannage'

# ============================================================== Fonctions communes

function Assert-DomaineLab {
    # Garde-fou : on ne casse rien en dehors du domaine du lab
    Import-Module ActiveDirectory -ErrorAction Stop
    $dns = (Get-ADDomain -ErrorAction Stop).DNSRoot
    if ($dns -ne $script:DomaineLab) {
        throw "Domaine détecté : '$dns'. Ce script est réservé au domaine $($script:DomaineLab). Arrêt."
    }
}

function Assert-GpoNonCritique {
    # Refuse de casser la Default Domain Policy ou la Default Domain Controllers Policy
    param([Parameter(Mandatory)]$Gpo)
    $critiques = @('31B2F340-016D-11D2-945F-00C04FB984F9', '6AC1786C-016F-11D2-945F-00C04FB984F9')
    if ($critiques -contains $Gpo.Id.ToString().ToUpper()) {
        throw "La GPO '$($Gpo.DisplayName)' est une GPO par défaut du domaine : refus."
    }
}

function Assert-CompteNonPrivilegie {
    # Refuse de casser un compte administrateur (RID 500, ou protégé par AdminSDHolder)
    param([Parameter(Mandatory)][string]$SamAccountName)
    $u = Get-ADUser -Identity $SamAccountName -Properties adminCount -ErrorAction Stop
    if ($u.SID.Value -like '*-500' -or $u.adminCount -eq 1) {
        throw "Le compte '$SamAccountName' est un compte privilégié : refus."
    }
}

function Get-CheminEtat {
    param([Parameter(Mandatory)][string]$Nom)
    $nomFichier = ($Nom -replace '[^A-Za-z0-9_-]', '_') + '.json'
    return (Join-Path $script:DossierEtat $nomFichier)
}

function Read-Etat {
    # Renvoie une hashtable (vide si aucun état enregistré)
    param([Parameter(Mandatory)][string]$Nom)
    $h = @{}
    $chemin = Get-CheminEtat $Nom
    if (Test-Path $chemin) {
        $obj = Get-Content $chemin -Raw | ConvertFrom-Json
        foreach ($p in $obj.PSObject.Properties) { $h[$p.Name] = $p.Value }
    }
    return $h
}

function Save-Etat {
    # Écrit l'état sur disque. -WhatIf:$false : appelé seulement après une modification réelle.
    param([Parameter(Mandatory)][string]$Nom, [Parameter(Mandatory)][hashtable]$Etat)
    if (-not (Test-Path $script:DossierEtat)) {
        New-Item -ItemType Directory -Path $script:DossierEtat -Force -WhatIf:$false | Out-Null
    }
    $Etat | ConvertTo-Json -Depth 5 | Set-Content -Path (Get-CheminEtat $Nom) -Encoding UTF8 -WhatIf:$false
}

function Remove-Etat {
    param([Parameter(Mandatory)][string]$Nom)
    $chemin = Get-CheminEtat $Nom
    if (Test-Path $chemin) { Remove-Item $chemin -Force -WhatIf:$false }
}

function Get-NomLocalise {
    # Nom d'un principal bien connu dans la langue du système (ex. S-1-5-11 -> "Utilisateurs authentifiés")
    param([Parameter(Mandatory)][string]$Sid, [switch]$SansDomaine)
    $nt = (New-Object System.Security.Principal.SecurityIdentifier $Sid).Translate([System.Security.Principal.NTAccount]).Value
    if ($SansDomaine -and $nt.Contains('\')) { return $nt.Split('\')[1] }
    return $nt
}

function Get-LiensGpo {
    # Liste des cibles (DN) où une GPO est liée : racine du domaine + toutes les OUs
    param([Parameter(Mandatory)][string]$GpoName)
    $cibles = @((Get-ADDomain).DistinguishedName)
    $cibles += (Get-ADOrganizationalUnit -Filter * | Select-Object -ExpandProperty DistinguishedName)
    $liens = @()
    foreach ($c in $cibles) {
        $inh = Get-GPInheritance -Target $c -ErrorAction SilentlyContinue
        if ($inh) {
            $liens += $inh.GpoLinks | Where-Object { $_.DisplayName -eq $GpoName } |
                Select-Object @{n='Target';e={$c}}, Enabled
        }
    }
    return $liens
}

function Add-RegleNtfs {
    param([string]$Dossier, [string]$Compte, [string]$Droits, [string]$Type = 'Allow')
    $acl = (Get-Item $Dossier).GetAccessControl('Access')
    $regle = New-Object System.Security.AccessControl.FileSystemAccessRule(
        $Compte, $Droits, 'ContainerInherit,ObjectInherit', 'None', $Type)
    $acl.AddAccessRule($regle)
    (Get-Item $Dossier).SetAccessControl($acl)
}

# Pendant l'installation d'une panne, rien n'est affiché : c'est à vous de trouver.
# Pendant la restauration, chaque action est affichée.
function Write-Faute  { param([string]$Texte) }
function Write-Repare { param([string]$Texte) Write-Host "  [RÉPARÉ]   $Texte" -ForegroundColor Green }
function Write-Deja   { param([string]$Texte) if ($Restaurer) { Write-Host "  [INCHANGÉ] $Texte" -ForegroundColor Yellow } }
function Write-Note   { param([string]$Texte) if ($Restaurer) { Write-Host "  $Texte" -ForegroundColor Gray } }

# ============================================================== D1 - GPO du lecteur réseau

function Install-PanneD1 {
    # Ordinateur : le poste est déplacé dans le conteneur CN=Computers (plus aucune GPO d'OU côté ordinateur).
    # Lien       : tous les liens de la GPO sont désactivés.
    # Filtrage   : GroupeFiltrage reçoit Appliquer, Utilisateurs authentifiés perd TOUT droit (y compris
    #              Lecture). Depuis MS16-072, les GPO utilisateur sont lues dans le contexte de l'ordinateur :
    #              sans Lecture pour les ordinateurs, la GPO n'est plus appliquée.
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$GpoName,
        [string]$Ordinateur     = 'ws-IT-01',
        [string]$GroupeFiltrage = 'GG-EU-IT-Admin',
        [string[]]$Fautes
    )
    Import-Module GroupPolicy -ErrorAction Stop
    $nomEtat = "D1-$GpoName"
    $etat = Read-Etat $nomEtat

    $gpo = Get-GPO -Name $GpoName -ErrorAction SilentlyContinue
    if (-not $gpo) {
        Write-Host "  GPO '$GpoName' introuvable. GPO existantes :" -ForegroundColor Red
        Get-GPO -All | Sort-Object DisplayName | ForEach-Object { Write-Host "  - $($_.DisplayName)" -ForegroundColor Gray }
        throw "Relancez avec -GpoName '<nom exact>'."
    }
    Assert-GpoNonCritique $gpo

    if ($Fautes -contains 'Ordinateur') {
        $pc = Get-ADComputer -Filter "Name -eq '$Ordinateur'"
        if (-not $pc) {
            Write-Host "  Ordinateur '$Ordinateur' introuvable : est-il joint au domaine ?" -ForegroundColor Yellow
        } else {
            $conteneur = (Get-ADDomain).ComputersContainer
            $parent = $pc.DistinguishedName.Substring($pc.DistinguishedName.IndexOf(',') + 1)
            if ($parent -eq $conteneur) {
                Write-Deja "$Ordinateur est déjà dans $conteneur"
            } elseif ($PSCmdlet.ShouldProcess($Ordinateur, "Déplacer vers $conteneur")) {
                if (-not $etat.ContainsKey('OrdinateurOU')) { $etat['OrdinateurOU'] = $parent; $etat['Ordinateur'] = $Ordinateur }
                Move-ADObject -Identity $pc.DistinguishedName -TargetPath $conteneur
                Save-Etat $nomEtat $etat
                Write-Faute "$Ordinateur déplacé de $parent vers $conteneur"
            }
        }
    }

    if ($Fautes -contains 'Lien') {
        $liens = @(Get-LiensGpo -GpoName $GpoName)
        if ($liens.Count -eq 0) {
            Write-Host "  La GPO '$GpoName' n'est liée nulle part : vérifiez les prérequis du ticket." -ForegroundColor Yellow
        }
        foreach ($l in $liens) {
            if (-not $l.Enabled) {
                Write-Deja "lien déjà désactivé sur $($l.Target)"
            } elseif ($PSCmdlet.ShouldProcess($l.Target, "Désactiver le lien de '$GpoName'")) {
                $cibles = @()
                if ($etat.ContainsKey('LiensDesactives')) { $cibles = @($etat['LiensDesactives']) }
                if ($cibles -notcontains $l.Target) { $cibles += $l.Target }
                $etat['LiensDesactives'] = $cibles
                Set-GPLink -Name $GpoName -Target $l.Target -LinkEnabled No | Out-Null
                Save-Etat $nomEtat $etat
                Write-Faute "lien désactivé sur $($l.Target)"
            }
        }
    }

    if ($Fautes -contains 'Filtrage') {
        $au = Get-NomLocalise -Sid 'S-1-5-11' -SansDomaine
        $permAu = Get-GPPermission -Name $GpoName -TargetName $au -TargetType Group -ErrorAction SilentlyContinue
        if (-not $permAu) {
            Write-Deja "'$au' n'a déjà plus aucun droit sur la GPO"
        } elseif ($PSCmdlet.ShouldProcess($GpoName, "Filtrer sur $GroupeFiltrage et retirer '$au'")) {
            if (-not $etat.ContainsKey('PermissionAU')) {
                $etat['PermissionAU'] = [string]$permAu.Permission
                $permGrp = Get-GPPermission -Name $GpoName -TargetName $GroupeFiltrage -TargetType Group -ErrorAction SilentlyContinue
                $etat['GroupeFiltrage'] = $GroupeFiltrage
                $etat['GroupeAvaitDroit'] = [bool]$permGrp
            }
            Set-GPPermission -Name $GpoName -TargetName $GroupeFiltrage -TargetType Group -PermissionLevel GpoApply | Out-Null
            Set-GPPermission -Name $GpoName -TargetName $au -TargetType Group -PermissionLevel None -Replace | Out-Null
            Save-Etat $nomEtat $etat
            Write-Faute "filtrage : $GroupeFiltrage = Appliquer, '$au' supprimé"
        }
    }
}

function Remove-PanneD1 {
    # Avec un état enregistré, ne répare QUE ce que Install-PanneD1 a cassé (un choix légitime n'est pas écrasé).
    # Sans état : poste dans son OU, tous les liens activés, Utilisateurs authentifiés = Appliquer.
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$GpoName,
        [string]$Ordinateur   = 'ws-IT-01',
        [string]$OUOrdinateur = 'OU=Computers,OU=IT,OU=EU,DC=maxtec,DC=be'
    )
    Import-Module GroupPolicy -ErrorAction Stop
    $nomEtat = "D1-$GpoName"
    $etat = Read-Etat $nomEtat
    $hayEtat = $etat.Count -gt 0
    if (-not $hayEtat) { Write-Host "  Aucun état enregistré : retour à l'état standard du lab." -ForegroundColor Yellow }

    # 1. Poste
    if (-not $hayEtat -or $etat.ContainsKey('OrdinateurOU')) {
        if ($etat.ContainsKey('OrdinateurOU')) { $OUOrdinateur = $etat['OrdinateurOU']; $Ordinateur = $etat['Ordinateur'] }
        $pc = Get-ADComputer -Filter "Name -eq '$Ordinateur'"
        if ($pc) {
            $parent = $pc.DistinguishedName.Substring($pc.DistinguishedName.IndexOf(',') + 1)
            if ($parent -eq $OUOrdinateur) {
                Write-Deja "$Ordinateur est dans $OUOrdinateur"
            } elseif ($PSCmdlet.ShouldProcess($Ordinateur, "Déplacer vers $OUOrdinateur")) {
                Move-ADObject -Identity $pc.DistinguishedName -TargetPath $OUOrdinateur -ErrorAction Stop
                Write-Repare "$Ordinateur replacé dans $OUOrdinateur"
            }
        }
    }

    $gpo = Get-GPO -Name $GpoName -ErrorAction SilentlyContinue
    if (-not $gpo) {
        Write-Host "  GPO '$GpoName' introuvable : liens et filtrage non traités (-GpoName ?)." -ForegroundColor Yellow
    } else {
        # 2. Liens
        if (-not $hayEtat -or $etat.ContainsKey('LiensDesactives')) {
            $aReactiver = $null
            if ($etat.ContainsKey('LiensDesactives')) { $aReactiver = @($etat['LiensDesactives']) }
            foreach ($l in @(Get-LiensGpo -GpoName $GpoName)) {
                if ($aReactiver -and ($aReactiver -notcontains $l.Target)) { continue }
                if ($l.Enabled) {
                    Write-Deja "lien actif sur $($l.Target)"
                } elseif ($PSCmdlet.ShouldProcess($l.Target, "Activer le lien de '$GpoName'")) {
                    Set-GPLink -Name $GpoName -Target $l.Target -LinkEnabled Yes -ErrorAction Stop | Out-Null
                    Write-Repare "lien réactivé sur $($l.Target)"
                }
            }
        }

        # 3. Filtrage
        if (-not $hayEtat -or $etat.ContainsKey('PermissionAU')) {
            $au = Get-NomLocalise -Sid 'S-1-5-11' -SansDomaine
            $niveau = 'GpoApply'
            if ($etat.ContainsKey('PermissionAU')) { $niveau = $etat['PermissionAU'] }
            $permAu = Get-GPPermission -Name $GpoName -TargetName $au -TargetType Group -ErrorAction SilentlyContinue
            if ($permAu -and [string]$permAu.Permission -eq $niveau) {
                Write-Deja "'$au' = $niveau"
            } elseif ($PSCmdlet.ShouldProcess($GpoName, "'$au' = $niveau")) {
                Set-GPPermission -Name $GpoName -TargetName $au -TargetType Group -PermissionLevel $niveau -Replace -ErrorAction Stop | Out-Null
                Write-Repare "'$au' = $niveau"
            }
            # Le groupe de filtrage ajouté par la panne est retiré seulement s'il n'avait aucun droit avant
            if ($etat.ContainsKey('GroupeAvaitDroit') -and -not $etat['GroupeAvaitDroit']) {
                $grp = $etat['GroupeFiltrage']
                if ($PSCmdlet.ShouldProcess($GpoName, "Retirer le droit ajouté pour $grp")) {
                    Set-GPPermission -Name $GpoName -TargetName $grp -TargetType Group -PermissionLevel None -Replace -ErrorAction Stop | Out-Null
                    Write-Repare "droit Appliquer retiré pour $grp (état d'origine)"
                }
            }
        }
    }
    if (-not $WhatIfPreference) { Remove-Etat $nomEtat }
}

# ============================================================== D2 - Compte utilisateur

function Install-PanneD2 {
    # Verrouillage : PSO dédiée (seuil 3) appliquée au compte, puis échecs d'authentification jusqu'au
    #                verrouillage. La PSO évite de toucher la Default Domain Policy.
    # Horaires     : logonHours limité à 01:00-05:00 UTC tous les jours.
    # Postes       : userWorkstations = un poste inexistant.
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$Utilisateur  = 'ines',
        [string]$PosteFactice = 'ws-IT-99',
        [string[]]$Fautes     = @('Verrouillage', 'Horaires', 'Postes')
    )
    $nomEtat = "D2-$Utilisateur"
    $etat = Read-Etat $nomEtat
    $nomPso = "PSO-Depannage-$Utilisateur"
    $null = Get-ADUser -Identity $Utilisateur -ErrorAction Stop   # le compte doit exister
    Assert-CompteNonPrivilegie $Utilisateur

    # Verrouillage en premier : les échecs doivent être comptés avant les autres restrictions
    if ($Fautes -contains 'Verrouillage') {
        # Audit "Gestion des comptes d'utilisateur" (événement 4740), par GUID : indépendant de la langue
        if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, 'auditpol : Gestion des comptes d''utilisateur = succès')) {
            auditpol /set /subcategory:"{0CCE9235-69AE-11D9-BED3-505054503030}" /success:enable | Out-Null
        }
        $pso = Get-ADFineGrainedPasswordPolicy -Filter "Name -eq '$nomPso'"
        if (-not $pso) {
            if ($PSCmdlet.ShouldProcess($nomPso, "Créer une PSO (seuil 3) appliquée à $Utilisateur")) {
                # Valeurs de mot de passe alignées sur le domaine pour ne rien changer d'autre
                $dd = Get-ADDefaultDomainPasswordPolicy
                New-ADFineGrainedPasswordPolicy -Name $nomPso -Precedence 90 `
                    -Description "Dépannage $Utilisateur" `
                    -LockoutThreshold 3 `
                    -LockoutDuration (New-TimeSpan -Hours 2) `
                    -LockoutObservationWindow (New-TimeSpan -Minutes 30) `
                    -MinPasswordLength $dd.MinPasswordLength `
                    -ComplexityEnabled $dd.ComplexityEnabled `
                    -PasswordHistoryCount $dd.PasswordHistoryCount `
                    -MaxPasswordAge $dd.MaxPasswordAge `
                    -MinPasswordAge $dd.MinPasswordAge `
                    -ReversibleEncryptionEnabled $false `
                    -ProtectedFromAccidentalDeletion $false
                Add-ADFineGrainedPasswordPolicySubject -Identity $nomPso -Subjects $Utilisateur
                $etat['Pso'] = $nomPso
                Save-Etat $nomEtat $etat
                Write-Faute "PSO $nomPso créée et appliquée à $Utilisateur"
            }
        } else {
            Write-Deja "PSO $nomPso existe"
        }

        $u = Get-ADUser -Identity $Utilisateur -Properties LockedOut
        if ($u.LockedOut) {
            Write-Deja "$Utilisateur est déjà verrouillé"
        } elseif ($PSCmdlet.ShouldProcess($Utilisateur, 'Provoquer 5 échecs d''authentification')) {
            Add-Type -AssemblyName System.DirectoryServices.AccountManagement
            $ctx = New-Object System.DirectoryServices.AccountManagement.PrincipalContext(
                [System.DirectoryServices.AccountManagement.ContextType]::Domain, $script:DomaineLab)
            # Mots de passe faux tous différents (un faux répété n'incrémente pas toujours badPwdCount)
            for ($i = 1; $i -le 5; $i++) {
                try { $null = $ctx.ValidateCredentials($Utilisateur, "Faux-$i-$(Get-Random)!") } catch { }
            }
            $ctx.Dispose()
            Start-Sleep -Seconds 2
            $u = Get-ADUser -Identity $Utilisateur -Properties LockedOut
            if (-not $u.LockedOut) {
                Write-Host "  Étape incomplète : sur le poste client, faites 4 essais de connexion de" -ForegroundColor Yellow
                Write-Host "  '$Utilisateur' avec un mauvais mot de passe avant de commencer le ticket." -ForegroundColor Yellow
            }
        }
    }

    $u = Get-ADUser -Identity $Utilisateur -Properties logonHours, userWorkstations

    if ($Fautes -contains 'Horaires') {
        # 21 octets = 7 jours x 3 octets, en UTC, à partir du dimanche 00:00. Un bit par heure.
        # 0x1E = heures 1, 2, 3, 4 -> 01:00-05:00 UTC.
        $heures = New-Object byte[] 21
        for ($j = 0; $j -lt 7; $j++) { $heures[$j * 3] = 0x1E }
        $actuel = $u.logonHours
        $identique = ($null -ne $actuel) -and ([Convert]::ToBase64String($actuel) -eq [Convert]::ToBase64String($heures))
        if ($identique) {
            Write-Deja "logonHours déjà restreint"
        } elseif ($PSCmdlet.ShouldProcess($Utilisateur, 'Restreindre logonHours à 01:00-05:00 UTC')) {
            if (-not $etat.ContainsKey('LogonHours')) {
                if ($actuel) { $etat['LogonHours'] = [Convert]::ToBase64String($actuel) } else { $etat['LogonHours'] = '' }
            }
            Set-ADUser -Identity $Utilisateur -Replace @{ logonHours = [byte[]]$heures }
            Save-Etat $nomEtat $etat
            Write-Faute "logonHours = 01:00-05:00 UTC"
        }
    }

    if ($Fautes -contains 'Postes') {
        if ($u.userWorkstations -eq $PosteFactice) {
            Write-Deja "userWorkstations = $PosteFactice"
        } elseif ($PSCmdlet.ShouldProcess($Utilisateur, "Limiter la connexion au poste $PosteFactice")) {
            if (-not $etat.ContainsKey('UserWorkstations')) { $etat['UserWorkstations'] = [string]$u.userWorkstations }
            Set-ADUser -Identity $Utilisateur -LogonWorkstations $PosteFactice
            Save-Etat $nomEtat $etat
            Write-Faute "userWorkstations = $PosteFactice"
        }
    }
}

function Remove-PanneD2 {
    # Supprime la PSO de dépannage, déverrouille, restaure logonHours et userWorkstations
    # (valeurs enregistrées, sinon : aucune restriction). L'audit reste activé (réglage souhaitable sur un DC).
    [CmdletBinding(SupportsShouldProcess)]
    param([string]$Utilisateur = 'ines')
    $nomEtat = "D2-$Utilisateur"
    $etat = Read-Etat $nomEtat
    $hayEtat = $etat.Count -gt 0
    $nomPso = "PSO-Depannage-$Utilisateur"

    $pso = Get-ADFineGrainedPasswordPolicy -Filter "Name -eq '$nomPso'"
    if ($pso) {
        if ($PSCmdlet.ShouldProcess($nomPso, 'Supprimer la PSO')) {
            Remove-ADFineGrainedPasswordPolicy -Identity $pso -Confirm:$false
            Write-Repare "PSO $nomPso supprimée"
        }
    } else { Write-Deja "pas de PSO $nomPso" }

    $u = Get-ADUser -Identity $Utilisateur -Properties LockedOut, logonHours, userWorkstations
    if ($u.LockedOut) {
        if ($PSCmdlet.ShouldProcess($Utilisateur, 'Déverrouiller')) {
            Unlock-ADAccount -Identity $Utilisateur
            Write-Repare "$Utilisateur déverrouillé"
        }
    } else { Write-Deja "$Utilisateur n'est pas verrouillé" }

    # Horaires
    $lh = $null
    if ($etat.ContainsKey('LogonHours')) { $lh = [string]$etat['LogonHours'] }
    if ($lh) {
        if ($PSCmdlet.ShouldProcess($Utilisateur, 'Restaurer logonHours d''origine')) {
            Set-ADUser -Identity $Utilisateur -Replace @{ logonHours = [byte[]][Convert]::FromBase64String($lh) } -ErrorAction Stop
            Write-Repare "logonHours restauré (valeur d'origine)"
        }
    } elseif (($etat.ContainsKey('LogonHours') -or -not $hayEtat) -and $u.logonHours) {
        if ($PSCmdlet.ShouldProcess($Utilisateur, 'Effacer logonHours (connexion 24 h/24)')) {
            Set-ADUser -Identity $Utilisateur -Clear logonHours -ErrorAction Stop
            Write-Repare "logonHours effacé (connexion 24 h/24)"
        }
    } else { Write-Deja "horaires : rien à restaurer" }

    # Postes autorisés
    $uw = $null
    if ($etat.ContainsKey('UserWorkstations')) { $uw = [string]$etat['UserWorkstations'] }
    if ($uw) {
        if ($u.userWorkstations -ne $uw -and $PSCmdlet.ShouldProcess($Utilisateur, "userWorkstations = $uw")) {
            Set-ADUser -Identity $Utilisateur -LogonWorkstations $uw -ErrorAction Stop
            Write-Repare "userWorkstations restauré ($uw)"
        }
    } elseif (($etat.ContainsKey('UserWorkstations') -or -not $hayEtat) -and $u.userWorkstations) {
        if ($PSCmdlet.ShouldProcess($Utilisateur, 'Effacer userWorkstations')) {
            Set-ADUser -Identity $Utilisateur -Clear userWorkstations -ErrorAction Stop
            Write-Repare "userWorkstations effacé (tous les postes)"
        }
    } else { Write-Deja "postes autorisés : rien à restaurer" }

    if (-not $WhatIfPreference) { Remove-Etat $nomEtat }
}

# ============================================================== D3 - AGDLP Ventes-Documents

function Install-PanneD3 {
    # Part de l'état final de l'exercice AGDLP. -Preparer crée cet état s'il manque.
    # Etendue : DL-Ventes-Documents-Modification supprimé puis recréé en GLOBAL (nouveau SID :
    #           l'ACE de l'ancien groupe devient orpheline, valentin perd tout accès).
    # Refus   : Refuser (Lecture et exécution) pour GG-EU-Ventes-Users sur le sous-dossier Contrats.
    # Ticket  : GG-EU-Compta-Users retiré de DL-Ventes-Documents-Lecture (cindy reste refusée après
    #           correction tant qu'elle garde son ancienne session).
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$Chemin = 'C:\Shares\Ventes-Documents',
        [switch]$Preparer
    )
    $nb        = (Get-ADDomain).NetBIOSName
    $ouRes     = 'OU=Resources,OU=EU,DC=maxtec,DC=be'
    $ouGroupes = "OU=Groups,$ouRes"
    $dlLect    = 'DL-Ventes-Documents-Lecture'
    $dlModif   = 'DL-Ventes-Documents-Modification'
    $dlCT      = 'DL-Ventes-Documents-ControleTotal'
    $nomEtat   = 'D3-Ventes-Documents'
    $etat      = Read-Etat $nomEtat

    if ($Preparer -and $PSCmdlet.ShouldProcess($Chemin, 'Créer l''état final de l''exercice AGDLP si nécessaire')) {
        foreach ($ou in @(@{N='Resources';P='OU=EU,DC=maxtec,DC=be'}, @{N='Groups';P=$ouRes})) {
            if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq 'OU=$($ou.N),$($ou.P)'")) {
                New-ADOrganizationalUnit -Name $ou.N -Path $ou.P -ProtectedFromAccidentalDeletion $false
            }
        }
        $def = @(
            @{N=$dlLect;  M=@('GG-EU-Ventes-Users','GG-EU-Compta-Users'); D='ReadAndExecute'},
            @{N=$dlModif; M=@('GG-EU-Ventes-Admin');                      D='Modify'},
            @{N=$dlCT;    M=@('GG-EU-IT-Admin');                          D='FullControl'}
        )
        foreach ($g in $def) {
            if (-not (Get-ADGroup -Filter "Name -eq '$($g.N)'")) {
                New-ADGroup -Name $g.N -GroupScope DomainLocal -GroupCategory Security -Path $ouGroupes
            }
            $membres = @(Get-ADGroupMember $g.N | Select-Object -ExpandProperty SamAccountName)
            foreach ($m in $g.M) { if ($membres -notcontains $m) { Add-ADGroupMember -Identity $g.N -Members $m } }
        }
        if (-not (Test-Path $Chemin)) { New-Item -ItemType Directory -Path $Chemin -Force | Out-Null }
        $acl = (Get-Item $Chemin).GetAccessControl('Access')
        if (-not $acl.AreAccessRulesProtected) {
            $acl.SetAccessRuleProtection($true, $true)           # désactiver l'héritage, convertir en explicite
            (Get-Item $Chemin).SetAccessControl($acl)
            $acl = (Get-Item $Chemin).GetAccessControl('Access')
            foreach ($sid in @('S-1-5-32-545', 'S-1-5-11')) {   # Utilisateurs, Utilisateurs authentifiés
                $acl.PurgeAccessRules((New-Object System.Security.Principal.SecurityIdentifier $sid))
            }
            (Get-Item $Chemin).SetAccessControl($acl)
            foreach ($g in $def) { Add-RegleNtfs -Dossier $Chemin -Compte "$nb\$($g.N)" -Droits $g.D }
        }
        if (-not (Get-SmbShare -Name 'Ventes-Documents' -ErrorAction SilentlyContinue)) {
            New-SmbShare -Name 'Ventes-Documents' -Path $Chemin -ChangeAccess (Get-NomLocalise -Sid 'S-1-1-0') | Out-Null
        }
    }

    if (-not (Test-Path $Chemin) -or -not (Get-ADGroup -Filter "Name -eq '$dlModif'")) {
        throw "L'état final de l'exercice AGDLP est absent. Terminez l'exercice, ou relancez avec -Preparer."
    }

    # Etendue
    $g = Get-ADGroup -Identity $dlModif -Properties Description
    if ($g.GroupScope -eq 'Global') {
        Write-Deja "$dlModif est déjà en étendue Global"
    } elseif ($PSCmdlet.ShouldProcess($dlModif, 'Supprimer et recréer en étendue Global')) {
        $membres = @(Get-ADGroupMember $dlModif | Select-Object -ExpandProperty DistinguishedName)
        $parent = $g.DistinguishedName.Substring($g.DistinguishedName.IndexOf(',') + 1)
        # État enregistré AVANT l'opération destructive : si la suite échoue, -Restaurer sait quoi recréer
        if (-not $etat.ContainsKey('AncienSid')) { $etat['AncienSid'] = $g.SID.Value }
        $etat['DlParent']  = $parent
        $etat['DlMembres'] = $membres
        Save-Etat $nomEtat $etat
        Remove-ADGroup -Identity $g -Confirm:$false -ErrorAction Stop
        $p = @{ Name = $dlModif; GroupScope = 'Global'; GroupCategory = 'Security'; Path = $parent; ErrorAction = 'Stop' }
        if ($g.Description) { $p['Description'] = $g.Description }
        New-ADGroup @p
        if ($membres.Count -gt 0) { Add-ADGroupMember -Identity $dlModif -Members $membres -ErrorAction Stop }
        Write-Faute "$dlModif recréé en Global"
    }

    # Refus
    $sous = Join-Path $Chemin 'Contrats'
    if ($PSCmdlet.ShouldProcess($sous, 'Refuser Lecture pour GG-EU-Ventes-Users')) {
        if (-not (Test-Path $sous)) {
            New-Item -ItemType Directory -Path $sous -Force | Out-Null
            Set-Content -Path (Join-Path $sous 'Contrat-Client-2026-014.txt') -Value 'Contrat cadre - client Brasserie Dumont' -Encoding UTF8
        }
        $ggSid = (Get-ADGroup 'GG-EU-Ventes-Users').SID.Value
        $acl = (Get-Item $sous).GetAccessControl('Access')
        $deja = $acl.GetAccessRules($true, $false, [System.Security.Principal.SecurityIdentifier]) |
            Where-Object { $_.IdentityReference.Value -eq $ggSid -and $_.AccessControlType -eq 'Deny' }
        if ($deja) {
            Write-Deja "Deny déjà présent sur $sous"
        } else {
            Add-RegleNtfs -Dossier $sous -Compte "$nb\GG-EU-Ventes-Users" -Droits 'ReadAndExecute' -Type 'Deny'
            $etat['DenySur'] = $sous
            Save-Etat $nomEtat $etat
            Write-Faute "Deny Lecture pour GG-EU-Ventes-Users sur $sous"
        }
    }

    # Compta retirée du DL de lecture
    $membres = @(Get-ADGroupMember $dlLect | Select-Object -ExpandProperty SamAccountName)
    if ($membres -notcontains 'GG-EU-Compta-Users') {
        Write-Deja "GG-EU-Compta-Users n'est pas membre de $dlLect"
    } elseif ($PSCmdlet.ShouldProcess($dlLect, 'Retirer GG-EU-Compta-Users')) {
        Remove-ADGroupMember -Identity $dlLect -Members 'GG-EU-Compta-Users' -Confirm:$false
        $etat['ComptaRetiree'] = $true
        Save-Etat $nomEtat $etat
        Write-Faute "GG-EU-Compta-Users retiré de $dlLect"
    }
}

function Remove-PanneD3 {
    # DL Modification en Domaine local avec GG-EU-Ventes-Admin et son ACE ; ACE orphelines supprimées ;
    # Deny sur Contrats supprimé ; GG-EU-Compta-Users remis dans le DL de lecture.
    [CmdletBinding(SupportsShouldProcess)]
    param([string]$Chemin = 'C:\Shares\Ventes-Documents')
    $nb      = (Get-ADDomain).NetBIOSName
    $dlLect  = 'DL-Ventes-Documents-Lecture'
    $dlModif = 'DL-Ventes-Documents-Modification'
    $nomEtat = 'D3-Ventes-Documents'
    $etat    = Read-Etat $nomEtat
    $SidType = [System.Security.Principal.SecurityIdentifier]

    # 1. Étendue du DL (et recréation si la panne s'est interrompue entre la suppression et la recréation)
    $g = Get-ADGroup -Filter "Name -eq '$dlModif'"
    if (-not $g) {
        if (-not $etat.ContainsKey('DlParent')) { throw "$dlModif introuvable et aucun état pour le recréer. Refaites l'étape AGDLP." }
        if ($PSCmdlet.ShouldProcess($dlModif, "Recréer en Domaine local dans $($etat['DlParent'])")) {
            New-ADGroup -Name $dlModif -GroupScope DomainLocal -GroupCategory Security -Path $etat['DlParent'] -ErrorAction Stop
            $m = @($etat['DlMembres'] | Where-Object { $_ })
            if ($m.Count -gt 0) { Add-ADGroupMember -Identity $dlModif -Members $m -ErrorAction Stop }
            Write-Repare "$dlModif recréé en Domaine local"
        }
        $g = Get-ADGroup -Filter "Name -eq '$dlModif'"
    }
    if (-not $g) {
        Write-Deja "(simulation) $dlModif serait recréé"
    } elseif ($g.GroupScope -ne 'DomainLocal') {
        if ($PSCmdlet.ShouldProcess($dlModif, "Étendue $($g.GroupScope) -> DomainLocal")) {
            if ($g.GroupScope -eq 'Global') { Set-ADGroup -Identity $dlModif -GroupScope Universal }
            Set-ADGroup -Identity $dlModif -GroupScope DomainLocal
            Write-Repare "$dlModif repassé en Domaine local"
        }
    } else { Write-Deja "$dlModif est en Domaine local" }

    $membres = @()
    if ($g) { $membres = @(Get-ADGroupMember $dlModif | Select-Object -ExpandProperty SamAccountName) }
    if ($g -and $membres -notcontains 'GG-EU-Ventes-Admin' -and $PSCmdlet.ShouldProcess($dlModif, 'Ajouter GG-EU-Ventes-Admin')) {
        Add-ADGroupMember -Identity $dlModif -Members 'GG-EU-Ventes-Admin'
        Write-Repare "GG-EU-Ventes-Admin ajouté à $dlModif"
    }

    # 2. ACL de la racine : SID orphelins + ACE du DL
    $acl = (Get-Item $Chemin).GetAccessControl('Access')
    $modifie = $false
    foreach ($r in @($acl.GetAccessRules($true, $false, $SidType))) {
        $sid = $r.IdentityReference
        $orphelin = $false
        if ($sid.Value -like 'S-1-5-21-*') {
            try { $null = $sid.Translate([System.Security.Principal.NTAccount]) } catch { $orphelin = $true }
        }
        if ($orphelin -or ($etat.ContainsKey('AncienSid') -and $sid.Value -eq $etat['AncienSid'])) {
            if ($PSCmdlet.ShouldProcess($Chemin, "Supprimer l'ACE orpheline $($sid.Value)")) {
                $acl.RemoveAccessRuleSpecific($r); $modifie = $true
                Write-Repare "ACE orpheline $($sid.Value) supprimée"
            }
        }
    }
    $dlSid = if ($g) { (Get-ADGroup $dlModif).SID.Value } else { '' }
    $aModif = $acl.GetAccessRules($true, $false, $SidType) | Where-Object {
        $_.IdentityReference.Value -eq $dlSid -and $_.AccessControlType -eq 'Allow' -and
        (($_.FileSystemRights -band [System.Security.AccessControl.FileSystemRights]::Modify) -eq [System.Security.AccessControl.FileSystemRights]::Modify)
    }
    if ($g -and -not $aModif -and $PSCmdlet.ShouldProcess($Chemin, "Ajouter Modification pour $dlModif")) {
        $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule(
            "$nb\$dlModif", 'Modify', 'ContainerInherit,ObjectInherit', 'None', 'Allow')))
        $modifie = $true
        Write-Repare "ACE Modification ajoutée pour $dlModif"
    }
    if ($modifie) { (Get-Item $Chemin).SetAccessControl($acl) }

    # 3. Deny sur Contrats
    $sous = Join-Path $Chemin 'Contrats'
    if (Test-Path $sous) {
        $ggSid = (Get-ADGroup 'GG-EU-Ventes-Users').SID.Value
        $aclS = (Get-Item $sous).GetAccessControl('Access')
        $refus = @($aclS.GetAccessRules($true, $false, $SidType) |
            Where-Object { $_.IdentityReference.Value -eq $ggSid })
        if ($refus.Count -gt 0) {
            if ($PSCmdlet.ShouldProcess($sous, 'Supprimer les ACE explicites de GG-EU-Ventes-Users')) {
                foreach ($r in $refus) { $aclS.RemoveAccessRuleSpecific($r) }
                (Get-Item $sous).SetAccessControl($aclS)
                Write-Repare "ACE explicites de GG-EU-Ventes-Users supprimées sur $sous"
            }
        } else { Write-Deja "aucune ACE explicite pour GG-EU-Ventes-Users sur $sous" }
    }

    # 4. Compta dans le DL de lecture
    $membres = @(Get-ADGroupMember $dlLect | Select-Object -ExpandProperty SamAccountName)
    if ($membres -notcontains 'GG-EU-Compta-Users') {
        if ($PSCmdlet.ShouldProcess($dlLect, 'Ajouter GG-EU-Compta-Users')) {
            Add-ADGroupMember -Identity $dlLect -Members 'GG-EU-Compta-Users'
            Write-Repare "GG-EU-Compta-Users remis dans $dlLect"
        }
    } else { Write-Deja "GG-EU-Compta-Users est membre de $dlLect" }

    if (-not $WhatIfPreference) { Remove-Etat $nomEtat }
}

# ============================================================== D4 - DNS

function Install-PanneD4 {
    # Côté DC. Intranet : A "intranet" vers 192.168.0.250 (adresse morte).
    # Ptr : suppression du PTR du poste. Adresse du poste : enregistrement A, sinon Get-ADComputer.
    # Aucun enregistrement de dns1 ni de 192.168.0.2 n'est modifié ; les zones ne sont pas touchées.
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$Ordinateur = 'ws-IT-01',
        [string]$IpFausse   = '192.168.0.250'
    )
    Import-Module DnsServer -ErrorAction Stop
    $zone    = 'maxtec.be'
    $zoneInv = '0.168.192.in-addr.arpa'
    $nomEtat = 'D4-DNS'
    $etat    = Read-Etat $nomEtat

    $rr = Get-DnsServerResourceRecord -ZoneName $zone -Name 'intranet' -RRType A -ErrorAction SilentlyContinue
    if ($rr -and ($rr | Where-Object { $_.RecordData.IPv4Address.IPAddressToString -eq $IpFausse })) {
        Write-Deja "intranet -> $IpFausse existe déjà"
    } elseif ($PSCmdlet.ShouldProcess("intranet.$zone", "A -> $IpFausse")) {
        if (-not $etat.ContainsKey('IntranetAvant')) {
            $etat['IntranetAvant'] = @($rr | ForEach-Object { $_.RecordData.IPv4Address.IPAddressToString })
        }
        if ($rr) { $rr | ForEach-Object { Remove-DnsServerResourceRecord -ZoneName $zone -InputObject $_ -Force } }
        Add-DnsServerResourceRecordA -ZoneName $zone -Name 'intranet' -IPv4Address $IpFausse -TimeToLive (New-TimeSpan -Hours 1)
        Save-Etat $nomEtat $etat
        Write-Faute "intranet.$zone -> $IpFausse"
    }

    if (-not (Get-DnsServerZone -Name $zoneInv -ErrorAction SilentlyContinue)) {
        Write-Host "  Zone inverse $zoneInv absente : créez-la d'abord (Ch5), puis relancez." -ForegroundColor Yellow
        return
    }
    $ip = $null
    $a = Get-DnsServerResourceRecord -ZoneName $zone -Name $Ordinateur -RRType A -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($a) { $ip = $a.RecordData.IPv4Address.IPAddressToString }
    if (-not $ip) { $ip = (Get-ADComputer -Filter "Name -eq '$Ordinateur'" -Properties IPv4Address | Select-Object -First 1).IPv4Address }
    if (-not $ip -or $ip -notlike '192.168.0.*') {
        Write-Host "  Adresse de $Ordinateur introuvable : le poste est-il allumé et joint au domaine ?" -ForegroundColor Yellow
        return
    }
    if ($ip -eq '192.168.0.2') { throw "Refus : $Ordinateur a l'adresse du DC." }
    $octet = $ip.Split('.')[3]
    $ptr = Get-DnsServerResourceRecord -ZoneName $zoneInv -Name $octet -RRType Ptr -ErrorAction SilentlyContinue
    if (-not $ptr) {
        Write-Deja "pas de PTR pour $ip"
    } elseif ($PSCmdlet.ShouldProcess("$octet.$zoneInv", 'Supprimer le PTR')) {
        if (-not $etat.ContainsKey('PtrNom')) {
            $etat['PtrNom'] = $octet
            $etat['PtrCible'] = ($ptr | Select-Object -First 1).RecordData.PtrDomainName
        }
        Remove-DnsServerResourceRecord -ZoneName $zoneInv -Name $octet -RRType Ptr -Force
        Save-Etat $nomEtat $etat
        Write-Faute "PTR $ip supprimé"
    }
}

function Remove-PanneD4 {
    # intranet : remis dans son état d'avant la panne (sans état : seul l'enregistrement vers l'adresse morte
    # est supprimé). PTR du poste recréé s'il manque. Le PTR du DC n'est jamais touché.
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$Ordinateur = 'ws-IT-01',
        [string]$IpFausse   = '192.168.0.250'
    )
    Import-Module DnsServer -ErrorAction Stop
    $zone    = 'maxtec.be'
    $zoneInv = '0.168.192.in-addr.arpa'
    $nomEtat = 'D4-DNS'
    $etat    = Read-Etat $nomEtat

    # 1. intranet
    $rr = @(Get-DnsServerResourceRecord -ZoneName $zone -Name 'intranet' -RRType A -ErrorAction SilentlyContinue)
    $actuelles = @($rr | ForEach-Object { $_.RecordData.IPv4Address.IPAddressToString })
    if ($etat.ContainsKey('IntranetAvant')) {
        $cibles = @($etat['IntranetAvant'] | Where-Object { $_ })
        if ((($actuelles | Sort-Object) -join ',') -eq (($cibles | Sort-Object) -join ',')) {
            Write-Deja "intranet déjà dans son état d'origine"
        } elseif ($PSCmdlet.ShouldProcess("intranet.$zone", "Remettre à : $($cibles -join ', ')")) {
            foreach ($r in $rr) { Remove-DnsServerResourceRecord -ZoneName $zone -InputObject $r -Force }
            foreach ($ip in $cibles) { Add-DnsServerResourceRecordA -ZoneName $zone -Name 'intranet' -IPv4Address $ip }
            if ($cibles.Count -eq 0) { Write-Repare "intranet supprimé (n'existait pas avant)" } else { Write-Repare "intranet -> $($cibles -join ', ')" }
        }
    } else {
        $mortes = @($rr | Where-Object { $_.RecordData.IPv4Address.IPAddressToString -eq $IpFausse })
        if ($mortes.Count -eq 0) {
            Write-Deja "intranet ne pointe pas vers $IpFausse"
        } elseif ($PSCmdlet.ShouldProcess("intranet.$zone", "Supprimer A -> $IpFausse")) {
            foreach ($r in $mortes) { Remove-DnsServerResourceRecord -ZoneName $zone -InputObject $r -Force }
            Write-Repare "intranet -> $IpFausse supprimé"
        }
    }

    # 2. PTR
    if (Get-DnsServerZone -Name $zoneInv -ErrorAction SilentlyContinue) {
        $octet = $null; $cible = "$Ordinateur.$zone."
        if ($etat.ContainsKey('PtrNom')) { $octet = $etat['PtrNom']; $cible = $etat['PtrCible'] }
        else {
            $ip = $null
            $a = Get-DnsServerResourceRecord -ZoneName $zone -Name $Ordinateur -RRType A -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($a) { $ip = $a.RecordData.IPv4Address.IPAddressToString }
            if (-not $ip) { $ip = (Get-ADComputer -Filter "Name -eq '$Ordinateur'" -Properties IPv4Address | Select-Object -First 1).IPv4Address }
            if ($ip -like '192.168.0.*') { $octet = $ip.Split('.')[3] }
        }
        if ($octet -eq '2') {
            Write-Host "  L'adresse trouvée pour $Ordinateur est celle du DC : PTR non traité." -ForegroundColor Yellow
        } elseif ($octet) {
            if (Get-DnsServerResourceRecord -ZoneName $zoneInv -Name $octet -RRType Ptr -ErrorAction SilentlyContinue) {
                Write-Deja "PTR $octet présent"
            } elseif ($PSCmdlet.ShouldProcess("$octet.$zoneInv", "PTR -> $cible")) {
                Add-DnsServerResourceRecordPtr -ZoneName $zoneInv -Name $octet -PtrDomainName $cible
                Write-Repare "PTR $octet -> $cible recréé"
            }
        } else { Write-Host "  Adresse de $Ordinateur introuvable : PTR non traité." -ForegroundColor Yellow }
    }
    if (-not $WhatIfPreference) { Remove-Etat $nomEtat }
}

function Get-CartePoste {
    # Carte du réseau interne du lab (192.168.0.x) ; une éventuelle carte NAT n'est pas touchée
    $ip = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object { $_.IPAddress -like '192.168.0.*' } | Select-Object -First 1
    if (-not $ip) { throw "Aucune carte réseau en 192.168.0.x sur ce poste." }
    return $ip
}

function Install-PanneD4Poste {
    # Côté poste : serveur DNS = 8.8.8.8 (injoignable depuis le réseau interne du lab)
    [CmdletBinding(SupportsShouldProcess)]
    param()
    $ip = Get-CartePoste
    $etat = Read-Etat 'D4-Poste'
    $actuels = @((Get-DnsClientServerAddress -InterfaceIndex $ip.InterfaceIndex -AddressFamily IPv4).ServerAddresses)
    if ($actuels.Count -eq 1 -and $actuels[0] -eq '8.8.8.8') {
        Write-Deja "DNS déjà sur 8.8.8.8"
    } elseif ($PSCmdlet.ShouldProcess($ip.InterfaceAlias, 'Serveur DNS = 8.8.8.8')) {
        if (-not $etat.ContainsKey('DnsStatique')) {
            # NameServer vide = DNS reçu du DHCP ; sinon, liste des DNS saisis à la main
            $guid = (Get-NetAdapter -InterfaceIndex $ip.InterfaceIndex).InterfaceGuid
            $cle = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid"
            $etat['DnsStatique'] = [string](Get-ItemProperty -Path $cle -Name NameServer -ErrorAction SilentlyContinue).NameServer
        }
        Set-DnsClientServerAddress -InterfaceIndex $ip.InterfaceIndex -ServerAddresses '8.8.8.8'
        Clear-DnsClientCache
        Save-Etat 'D4-Poste' $etat
        Write-Faute "DNS de $($ip.InterfaceAlias) = 8.8.8.8"
    }
}

function Remove-PanneD4Poste {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    $ip = Get-CartePoste
    $etat = Read-Etat 'D4-Poste'
    $statique = ''
    if ($etat.ContainsKey('DnsStatique')) { $statique = [string]$etat['DnsStatique'] }
    elseif ((Get-NetIPInterface -InterfaceIndex $ip.InterfaceIndex -AddressFamily IPv4).Dhcp -ne 'Enabled') { $statique = '192.168.0.2' }
    if ($statique) {
        $serveurs = @($statique -split '[,\s]+' | Where-Object { $_ })
        if ($PSCmdlet.ShouldProcess($ip.InterfaceAlias, "Serveurs DNS = $($serveurs -join ', ')")) {
            Set-DnsClientServerAddress -InterfaceIndex $ip.InterfaceIndex -ServerAddresses $serveurs
            Write-Repare "DNS de $($ip.InterfaceAlias) = $($serveurs -join ', ')"
        }
    } elseif ($PSCmdlet.ShouldProcess($ip.InterfaceAlias, 'Serveurs DNS fournis par le DHCP')) {
        Set-DnsClientServerAddress -InterfaceIndex $ip.InterfaceIndex -ResetServerAddresses
        Write-Repare "DNS de $($ip.InterfaceAlias) : rendu au DHCP"
    }
    if (-not $WhatIfPreference) {
        Clear-DnsClientCache
        ipconfig /registerdns | Out-Null
        Remove-Etat 'D4-Poste'
    }
}

# ============================================================== Programme principal

$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "Lancez PowerShell en tant qu'administrateur."
}
$machine = Get-CimInstance Win32_ComputerSystem
$estDC = $machine.DomainRole -ge 4

# D4 côté poste client : pas de module AD nécessaire
if (-not $estDC) {
    if ($Ticket -ne 'D4') { throw "Le ticket $Ticket se lance sur le DC dns1." }
    if ($machine.Domain -ne $script:DomaineLab) { throw "Ce poste n'est pas membre du domaine $($script:DomaineLab). Arrêt." }
    if ($Restaurer) {
        Remove-PanneD4Poste
        Write-Host "`nPoste restauré. Si ce n'est pas fait, lancez aussi -Restaurer sur dns1." -ForegroundColor Cyan
    } else {
        Install-PanneD4Poste
        Write-Host "`nPartie poste installée. Si ce n'est pas fait, lancez la même commande sur dns1." -ForegroundColor Cyan
        Write-Host "Ensuite, lisez le ticket D4." -ForegroundColor Cyan
    }
    return
}

Assert-DomaineLab

if ($Restaurer) {
    Write-Host "`n=== Restauration du ticket $Ticket ===" -ForegroundColor Cyan
    switch ($Ticket) {
        'D1' {
            if (-not $GpoName) { $GpoName = 'GPO-Mappage-IT-Admin' }
            Remove-PanneD1 -GpoName $GpoName
            Write-Host "`nSur ws-IT-01 : gpupdate /force, puis fermez et rouvrez la session." -ForegroundColor Cyan
        }
        'D2' { Remove-PanneD2 -Utilisateur 'ines' }
        'D3' {
            Remove-PanneD3
            Write-Host "`nSur le poste : fermez et rouvrez les sessions de test (nouveaux jetons)." -ForegroundColor Cyan
        }
        'D4' {
            Remove-PanneD4
            Write-Host "`nLancez aussi -Restaurer sur ws-IT-01." -ForegroundColor Cyan
        }
        'Incident' {
            if (-not $GpoName) { $GpoName = 'GPO-Logistique-Utilisateurs' }
            Remove-PanneD1 -GpoName $GpoName -Ordinateur 'ws-LOG-01' -OUOrdinateur 'OU=Computers,OU=Logistique,OU=EU,DC=maxtec,DC=be'
            Remove-PanneD2 -Utilisateur 'louis'
        }
    }
    return
}

switch ($Ticket) {
    'D1' {
        if (-not $GpoName) { $GpoName = 'GPO-Mappage-IT-Admin' }
        $fautes = @('Lien', 'Filtrage')
        if ($Complet) { $fautes = @('Ordinateur') + $fautes }
        Install-PanneD1 -GpoName $GpoName -Fautes $fautes
        $suite = "Sur ws-IT-01 : gpupdate /force, puis ouvrez une session avec irene."
    }
    'D2' {
        Install-PanneD2 -Utilisateur 'ines'
        $suite = "Commencez par essayer d'ouvrir une session avec ines sur ws-IT-01."
    }
    'D3' {
        Install-PanneD3 -Preparer:$Preparer
        $suite = "Avant de corriger quoi que ce soit, reproduisez chaque plainte sur ws-IT-01 (valentin, vanessa, cindy)."
    }
    'D4' {
        Install-PanneD4
        $suite = "Lancez maintenant la même commande sur ws-IT-01 (PowerShell administrateur)."
    }
    'Incident' {
        if (-not $GpoName) { $GpoName = 'GPO-Logistique-Utilisateurs' }
        Install-PanneD1 -GpoName $GpoName -Ordinateur 'ws-LOG-01' -GroupeFiltrage 'GG-EU-Logistique-Users' -Fautes 'Filtrage'
        Install-PanneD2 -Utilisateur 'louis' -PosteFactice 'ws-LOG-99' -Fautes 'Verrouillage', 'Postes'
        $suite = "Sur le poste client : gpupdate /force, puis ouvrez une session avec lea."
    }
}
Write-Host "`nPanne installée." -ForegroundColor Cyan
Write-Host $suite -ForegroundColor Cyan
Write-Host "Puis lisez le ticket. Pour revenir en arrière : même commande avec -Restaurer (ou votre instantané)." -ForegroundColor Cyan
