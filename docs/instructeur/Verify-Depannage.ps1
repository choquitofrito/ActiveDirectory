<#
.SYNOPSIS
    Vérifie que les tickets de dépannage D1 à D4 sont résolus. Lecture seule.

.DESCRIPTION
    Sur le DC :      .\Verify-Depannage.ps1                 (tous les scénarios)
                     .\Verify-Depannage.ps1 -Scenario D2,D3
    Sur le client :  .\Verify-Depannage.ps1 -Client         (partie poste de D4 : DNS du client)

    Ne dépend pas des fichiers d'état : un ticket corrigé autrement que par -Restaurer est accepté
    s'il respecte l'état attendu.
#>
[CmdletBinding()]
param(
    [ValidateSet('D1', 'D2', 'D3', 'D4')]
    [string[]]$Scenario    = @('D1', 'D2', 'D3', 'D4'),
    [switch]$Client,
    [string]$GpoLecteur    = 'GPO-Mappage-IT-Admin',
    [string]$PosteIT       = 'ws-IT-01',
    [string]$UtilisateurD2 = 'ines',
    [string]$CheminVentes  = 'C:\Shares\Ventes-Documents'
)

$script:erreurs = 0
function Test-Point {
    param([string]$Libelle, [scriptblock]$Test, [string]$Conseil = '')
    try {
        $ok = & $Test
        if ($ok) {
            Write-Host "  [OK] $Libelle" -ForegroundColor Green
        } else {
            Write-Host "  [KO] $Libelle" -ForegroundColor Red
            if ($Conseil) { Write-Host "      -> $Conseil" -ForegroundColor Yellow }
            $script:erreurs++
        }
    } catch {
        Write-Host "  [KO] $Libelle (erreur : $($_.Exception.Message))" -ForegroundColor Red
        $script:erreurs++
    }
}

# ---------------------------------------------------------------- Partie client
if ($Client) {
    Write-Host "`n=== D4 - côté client ($env:COMPUTERNAME) ===" -ForegroundColor Cyan
    $dns = @(Get-DnsClientServerAddress -AddressFamily IPv4 |
        Where-Object { $_.ServerAddresses.Count -gt 0 } | ForEach-Object { $_.ServerAddresses })
    Write-Host "      Serveurs DNS configurés : $($dns -join ', ')" -ForegroundColor Gray
    Test-Point "Le client interroge 192.168.0.2" { $dns -contains '192.168.0.2' } 'Set-DnsClientServerAddress ... -ServerAddresses 192.168.0.2'
    Test-Point "Pas de DNS de la carte NAT VirtualBox (10.0.2.x)" { -not ($dns | Where-Object { $_ -like '10.0.2.*' }) } 'Carte NAT encore active : retirez-la (VirtualBox > Configuration > Réseau) ou Disable-NetAdapter sur la carte NAT'
    Test-Point "Aucun DNS public configuré (8.8.8.8, 1.1.1.1...)" { -not ($dns | Where-Object { $_ -notlike '192.168.0.*' -and $_ -notlike '127.*' -and $_ -notlike '10.0.2.*' }) } 'Un client de domaine ne doit interroger que les DNS du domaine'
    Test-Point "dns1.maxtec.be se résout" { (Resolve-DnsName dns1.maxtec.be -Type A -ErrorAction Stop).IPAddress -contains '192.168.0.2' }
    Test-Point "Enregistrement SRV du DC trouvé (_ldap._tcp.dc._msdcs)" { Resolve-DnsName _ldap._tcp.dc._msdcs.maxtec.be -Type SRV -ErrorAction Stop }
    Test-Point "intranet.maxtec.be pointe vers 192.168.0.2 (ou n'existe plus)" {
        # Absent = accepté : Depannage.ps1 -Ticket D4 -Restaurer supprime l'enregistrement s'il n'existait pas avant
        $ip = @(Resolve-DnsName intranet.maxtec.be -Type A -DnsOnly -ErrorAction SilentlyContinue |
            Where-Object { $_.Type -eq 'A' } | ForEach-Object { $_.IPAddress })
        if ($ip.Count -eq 0) {
            # Absence crédible seulement si le DNS du domaine répond
            if (-not (Resolve-DnsName dns1.maxtec.be -Type A -DnsOnly -ErrorAction SilentlyContinue)) { return $false }
            Write-Host "      intranet.maxtec.be absent du DNS (accepté)" -ForegroundColor Gray; return $true
        }
        ($ip -contains '192.168.0.2') -and -not ($ip -contains '192.168.0.250')
    } 'ipconfig /flushdns après correction côté serveur'
    Write-Host ""
    if ($script:erreurs -eq 0) { Write-Host "D4 client : résolu." -ForegroundColor Green } else { Write-Host "D4 client : $($script:erreurs) point(s) en échec." -ForegroundColor Red }
    return
}

# ---------------------------------------------------------------- Partie DC
Import-Module ActiveDirectory -ErrorAction Stop
if ((Get-ADDomain).DNSRoot -ne 'maxtec.be') { Write-Host "Domaine inattendu. Arrêt." -ForegroundColor Red; return }
$SidType = [System.Security.Principal.SecurityIdentifier]

if ($Scenario -contains 'D1') {
    Write-Host "`n=== D1 - Lecteur réseau IT ===" -ForegroundColor Cyan
    Import-Module GroupPolicy -ErrorAction Stop
    Test-Point "$PosteIT est dans OU=Computers,OU=IT" {
        (Get-ADComputer $PosteIT).DistinguishedName -like "CN=$PosteIT,OU=Computers,OU=IT,OU=EU,*"
    } 'Move-ADObject vers OU=Computers,OU=IT,OU=EU,DC=maxtec,DC=be'
    $gpo = Get-GPO -Name $GpoLecteur -ErrorAction SilentlyContinue
    if (-not $gpo) {
        Write-Host "  [KO] GPO '$GpoLecteur' introuvable (paramètre -GpoLecteur ?)" -ForegroundColor Red; $script:erreurs++
    } else {
        $liens = @()
        $cibles = @((Get-ADDomain).DistinguishedName) + @(Get-ADOrganizationalUnit -Filter * | Select-Object -ExpandProperty DistinguishedName)
        foreach ($c in $cibles) {
            $liens += (Get-GPInheritance -Target $c).GpoLinks | Where-Object { $_.DisplayName -eq $GpoLecteur }
        }
        Test-Point "La GPO est liée au moins une fois" { $liens.Count -gt 0 }
        Test-Point "Tous ses liens sont activés" { $liens.Count -gt 0 -and -not ($liens | Where-Object { -not $_.Enabled }) } 'GPMC : clic droit sur le lien > Lien activé'
        $au = (New-Object System.Security.Principal.SecurityIdentifier 'S-1-5-11').Translate([System.Security.Principal.NTAccount]).Value.Split('\')[1]
        Test-Point "Utilisateurs authentifiés (ou Ordinateurs du domaine) ont au moins Lecture" {
            $p = Get-GPPermission -Name $GpoLecteur -All | Where-Object {
                $_.Trustee.Sid.Value -eq 'S-1-5-11' -or $_.Trustee.Sid.Value -like '*-515' }
            [bool]$p
        } "GPMC > Délégation > Ajouter '$au' en Lecture"
        Test-Point "Au moins un groupe a le droit Appliquer" {
            [bool](Get-GPPermission -Name $GpoLecteur -All | Where-Object { $_.Permission -eq 'GpoApply' })
        }
    }
}

if ($Scenario -contains 'D2') {
    Write-Host "`n=== D2 - Compte $UtilisateurD2 ===" -ForegroundColor Cyan
    $u = Get-ADUser $UtilisateurD2 -Properties LockedOut, logonHours, userWorkstations, Enabled
    Test-Point "Compte activé" { $u.Enabled }
    Test-Point "Compte non verrouillé" { -not $u.LockedOut } "Unlock-ADAccount $UtilisateurD2"
    Test-Point "Pas de restriction d'horaires" {
        (-not $u.logonHours) -or (-not ($u.logonHours | Where-Object { $_ -ne 255 }))
    } 'dsa.msc > Compte > Horaires d''accès > tout autoriser'
    Test-Point "Pas de restriction de poste (ou poste existant)" {
        if (-not $u.userWorkstations) { return $true }
        $postes = $u.userWorkstations.Split(',')
        -not ($postes | Where-Object { -not (Get-ADComputer -Filter "Name -eq '$_'") })
    } 'dsa.msc > Compte > Se connecter à... > Tous les ordinateurs'
    $pso = Get-ADUserResultantPasswordPolicy $UtilisateurD2
    if ($pso) { Write-Host "      Info : PSO effective pour $UtilisateurD2 : $($pso.Name) (seuil $($pso.LockoutThreshold))" -ForegroundColor Gray }
}

if ($Scenario -contains 'D3') {
    Write-Host "`n=== D3 - Partage Ventes-Documents ===" -ForegroundColor Cyan
    $dlModif = 'DL-Ventes-Documents-Modification'
    $dlLect  = 'DL-Ventes-Documents-Lecture'
    Test-Point "$dlModif est en étendue Domaine local" { (Get-ADGroup $dlModif).GroupScope -eq 'DomainLocal' } 'Set-ADGroup -GroupScope Universal puis DomainLocal'
    Test-Point "$dlModif contient GG-EU-Ventes-Admin" { (Get-ADGroupMember $dlModif).SamAccountName -contains 'GG-EU-Ventes-Admin' }
    Test-Point "$dlLect contient GG-EU-Compta-Users" { (Get-ADGroupMember $dlLect).SamAccountName -contains 'GG-EU-Compta-Users' }
    $acl = (Get-Item $CheminVentes).GetAccessControl('Access')
    $regles = @($acl.GetAccessRules($true, $true, $SidType))
    Test-Point "Aucun SID orphelin dans l'ACL de la racine" {
        -not ($regles | Where-Object {
            $_.IdentityReference.Value -like 'S-1-5-21-*' -and
            -not (Get-ADObject -Filter "objectSid -eq '$($_.IdentityReference.Value)'") })
    } 'Supprimer l''entrée "Compte inconnu (S-1-5-21-...)"'
    Test-Point "$dlModif a Modification sur la racine" {
        $sid = (Get-ADGroup $dlModif).SID.Value
        [bool]($regles | Where-Object { $_.IdentityReference.Value -eq $sid -and $_.AccessControlType -eq 'Allow' -and
            ($_.FileSystemRights -band [System.Security.AccessControl.FileSystemRights]::Modify) -eq [System.Security.AccessControl.FileSystemRights]::Modify })
    }
    $sous = Join-Path $CheminVentes 'Contrats'
    if (Test-Path $sous) {
        $aclS = (Get-Item $sous).GetAccessControl('Access')
        Test-Point "Aucune ACE Refuser sur Contrats" {
            -not ($aclS.GetAccessRules($true, $false, $SidType) | Where-Object { $_.AccessControlType -eq 'Deny' })
        } 'Supprimer l''entrée Refuser (et ne pas la remplacer par un GG)'
    }
    Test-Point "Aucun groupe global ni utilisateur dans les ACL (racine et Contrats)" {
        $toutes = @($regles)
        if (Test-Path $sous) { $toutes += (Get-Item $sous).GetAccessControl('Access').GetAccessRules($true, $false, $SidType) }
        -not ($toutes | Where-Object {
            $s = $_.IdentityReference.Value
            if ($s -notlike 'S-1-5-21-*') { return $false }
            $o = Get-ADObject -Filter "objectSid -eq '$s'" -Properties groupType
            # groupType : bit 0x4 = Domain local ; un groupe sans ce bit ou un utilisateur est un écart AGDLP
            $o -and ($o.ObjectClass -ne 'group' -or (($o.groupType -band 4) -eq 0))
        })
    } 'Seuls des DL-* doivent apparaître (hors SYSTEM, Administrateurs, CREATEUR PROPRIETAIRE)'
}

if ($Scenario -contains 'D4') {
    Write-Host "`n=== D4 - DNS (côté DC) ===" -ForegroundColor Cyan
    Import-Module DnsServer -ErrorAction Stop
    Test-Point "intranet.maxtec.be ne pointe pas vers 192.168.0.250" {
        -not (Get-DnsServerResourceRecord -ZoneName maxtec.be -Name intranet -RRType A -ErrorAction SilentlyContinue |
            Where-Object { $_.RecordData.IPv4Address.IPAddressToString -eq '192.168.0.250' })
    } 'Corriger l''enregistrement A (192.168.0.2)'
    $a = Get-DnsServerResourceRecord -ZoneName maxtec.be -Name $PosteIT -RRType A -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($a) {
        $octet = $a.RecordData.IPv4Address.IPAddressToString.Split('.')[3]
        Test-Point "PTR de $PosteIT présent dans 0.168.192.in-addr.arpa" {
            [bool](Get-DnsServerResourceRecord -ZoneName 0.168.192.in-addr.arpa -Name $octet -RRType Ptr -ErrorAction SilentlyContinue)
        } 'ipconfig /registerdns sur le client, ou création manuelle du PTR'
    } else {
        Write-Host "  [KO] Pas d'enregistrement A pour $PosteIT (le client n'a pas réenregistré son nom)" -ForegroundColor Red; $script:erreurs++
    }
    Write-Host "      Partie client : lancez ce script avec -Client sur $PosteIT." -ForegroundColor Gray
}

Write-Host "`n========================================" -ForegroundColor Cyan
if ($script:erreurs -eq 0) { Write-Host "Tous les points vérifiés sont OK." -ForegroundColor Green }
else { Write-Host "$($script:erreurs) point(s) en échec." -ForegroundColor Red }
