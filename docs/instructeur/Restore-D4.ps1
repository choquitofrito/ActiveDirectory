<#
.SYNOPSIS
    Dépannage D4 - rétablit le DNS côté DC et affiche les commandes côté client.

.DESCRIPTION
    - intranet.maxtec.be : remis dans son état d'avant Break-D4 (en général : supprimé).
      Avec -IntranetVersDC, pointe vers 192.168.0.2 (la "bonne" correction du ticket).
    - PTR du poste : recréé s'il manque. Adresse : celle enregistrée par Break-D4, sinon -IPPoste,
      sinon l'enregistrement A du poste, sinon Get-ADComputer (le poste peut être en DHCP).
      Le PTR du DC (192.168.0.2) n'est jamais touché.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$Ordinateur = 'ws-IT-01',
    [string]$IPPoste    = '',
    [switch]$IntranetVersDC
)

. "$PSScriptRoot\Commun.ps1"
Assert-DomaineLab
Import-Module DnsServer -ErrorAction Stop

$zone    = 'maxtec.be'
$zoneInv = '0.168.192.in-addr.arpa'
$nomEtat = 'D4-DNS'
$etat    = Read-Etat $nomEtat
Write-Host "`n=== Restore-D4 : DNS ===" -ForegroundColor Cyan

# 1. intranet
$cibles = @()
if ($IntranetVersDC) { $cibles = @('192.168.0.2') }
elseif ($etat.ContainsKey('IntranetAvant')) { $cibles = @($etat['IntranetAvant'] | Where-Object { $_ }) }
$rr = @(Get-DnsServerResourceRecord -ZoneName $zone -Name 'intranet' -RRType A -ErrorAction SilentlyContinue)
$actuelles = @($rr | ForEach-Object { $_.RecordData.IPv4Address.IPAddressToString })
if ((($actuelles | Sort-Object) -join ',') -eq (($cibles | Sort-Object) -join ',')) {
    Write-Deja "intranet déjà dans l'état attendu ($($cibles -join ', '))"
} elseif ($PSCmdlet.ShouldProcess("intranet.$zone", "Remettre à : $($cibles -join ', ')")) {
    foreach ($r in $rr) { Remove-DnsServerResourceRecord -ZoneName $zone -InputObject $r -Force }
    foreach ($ip in $cibles) { Add-DnsServerResourceRecordA -ZoneName $zone -Name 'intranet' -IPv4Address $ip }
    if ($cibles.Count -eq 0) { Write-Repare "intranet supprimé (n'existait pas avant)" } else { Write-Repare "intranet -> $($cibles -join ', ')" }
}

# 2. PTR
if (Get-DnsServerZone -Name $zoneInv -ErrorAction SilentlyContinue) {
    $octet = $null; $cible = "$Ordinateur.$zone."
    if ($etat.ContainsKey('PtrNom')) { $octet = $etat['PtrNom']; $cible = $etat['PtrCible'] }
    else {
        $ip = $IPPoste
        if (-not $ip) {
            $a = Get-DnsServerResourceRecord -ZoneName $zone -Name $Ordinateur -RRType A -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($a) { $ip = $a.RecordData.IPv4Address.IPAddressToString }
        }
        if (-not $ip) {
            $ip = (Get-ADComputer -Filter "Name -eq '$Ordinateur'" -Properties IPv4Address | Select-Object -First 1).IPv4Address
        }
        if ($ip -like '192.168.0.*') { $octet = $ip.Split('.')[3] }
    }
    if ($octet -eq '2') {
        Write-Host "  Refus : l'adresse trouvée pour $Ordinateur est celle du DC. PTR non traité." -ForegroundColor Yellow
    } elseif ($octet) {
        if (Get-DnsServerResourceRecord -ZoneName $zoneInv -Name $octet -RRType Ptr -ErrorAction SilentlyContinue) {
            Write-Deja "PTR $octet présent"
        } elseif ($PSCmdlet.ShouldProcess("$octet.$zoneInv", "PTR -> $cible")) {
            Add-DnsServerResourceRecordPtr -ZoneName $zoneInv -Name $octet -PtrDomainName $cible
            Write-Repare "PTR $octet -> $cible recréé"
        }
    } else { Write-Host "  Impossible de déterminer l'adresse de $Ordinateur : PTR non traité." -ForegroundColor Yellow }
}

if (-not $WhatIfPreference) { Remove-Etat $nomEtat }

Write-Host "`nÀ FAIRE SUR LE CLIENT $Ordinateur (PowerShell administrateur) :" -ForegroundColor Cyan
Write-Host '  Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 192.168.0.2' -ForegroundColor White
Write-Host '  # (si la carte est en DHCP : Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ResetServerAddresses)' -ForegroundColor Gray
Write-Host '  ipconfig /flushdns' -ForegroundColor White
Write-Host '  ipconfig /registerdns' -ForegroundColor White
Write-Host '  nltest /dsgetdc:maxtec.be' -ForegroundColor White
