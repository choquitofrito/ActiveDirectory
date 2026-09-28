<#
.SYNOPSIS
    Dépannage D4 - "Le poste ne trouve plus le domaine" : pannes DNS côté serveur + consignes côté client.

.DESCRIPTION
    Côté DC (ce script) :
      Intranet : enregistrement A "intranet.maxtec.be" pointant vers 192.168.0.250 (adresse inexistante :
                 l'ancien serveur intranet a été décommissionné, le service est maintenant sur dns1).
      Ptr      : suppression du PTR du poste client (par défaut ws-IT-01) dans 0.168.192.in-addr.arpa.
                 L'adresse du poste n'est pas supposée (.10) : le poste peut être en DHCP depuis le lab
                 Anatomie. Elle vient de -IPPoste, sinon de l'enregistrement A, sinon de Get-ADComputer.
    Côté client (à faire à la main, voir la fin du script) : serveur DNS = 8.8.8.8.

    Garde-fous : aucun enregistrement de dns1 ni de 192.168.0.2 n'est modifié ; les zones ne sont pas touchées.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$Ordinateur = 'ws-IT-01',
    [string]$IpFausse   = '192.168.0.250',
    [string]$IPPoste    = '',
    [ValidateSet('Intranet', 'Ptr')]
    [string[]]$Fautes   = @('Intranet', 'Ptr')
)

. "$PSScriptRoot\Commun.ps1"
Assert-DomaineLab
Import-Module DnsServer -ErrorAction Stop

$zone    = 'maxtec.be'
$zoneInv = '0.168.192.in-addr.arpa'
$nomEtat = 'D4-DNS'
$etat    = Read-Etat $nomEtat

if ($Ordinateur -eq 'dns1') { throw "Refus : on ne touche pas aux enregistrements du DC." }
Write-Host "`n=== Break-D4 : DNS ===" -ForegroundColor Cyan

# --- Panne 1 : A intranet obsolète -------------------------------------------
if ($Fautes -contains 'Intranet') {
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
        Write-Faute "intranet.$zone -> $IpFausse (adresse morte)"
    }
}

# --- Panne 2 : PTR du poste supprimé -----------------------------------------
if ($Fautes -contains 'Ptr') {
    if (-not (Get-DnsServerZone -Name $zoneInv -ErrorAction SilentlyContinue)) {
        Write-Host "  Zone inverse $zoneInv absente : c'est déjà une panne en soi. Faute 'Ptr' ignorée." -ForegroundColor Yellow
    } else {
        $ip = $IPPoste
        if (-not $ip) {
            $a = Get-DnsServerResourceRecord -ZoneName $zone -Name $Ordinateur -RRType A -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($a) { $ip = $a.RecordData.IPv4Address.IPAddressToString }
        }
        if (-not $ip) {
            $ip = (Get-ADComputer -Filter "Name -eq '$Ordinateur'" -Properties IPv4Address | Select-Object -First 1).IPv4Address
        }
        if (-not $ip -or $ip -notlike '192.168.0.*') {
            Write-Host "  Adresse de $Ordinateur introuvable ou hors de 192.168.0.0/24 ('$ip') : faute 'Ptr' ignorée (passez -IPPoste)." -ForegroundColor Yellow
        } else {
            if ($ip -eq '192.168.0.2') { throw "Refus : $Ordinateur a l'adresse du DC." }
            Write-Note "Adresse de $Ordinateur : $ip" 
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
                Write-Faute "PTR $ip ($($etat['PtrCible'])) supprimé"
            }
        }
    }
}

Write-Host "`nÀ FAIRE SUR LE CLIENT $Ordinateur (PowerShell administrateur) :" -ForegroundColor Cyan
Write-Host '  Get-NetAdapter                                   # repérer le nom de la carte (souvent "Ethernet")' -ForegroundColor White
Write-Host '  Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 8.8.8.8' -ForegroundColor White
Write-Host '  ipconfig /flushdns' -ForegroundColor White
Write-Note "Le client ne pourra plus réenregistrer son PTR tant qu'il interroge 8.8.8.8."
Write-Note "Réparation formateur : .\Restore-D4.ps1 (DC) + commandes client affichées par ce script."
