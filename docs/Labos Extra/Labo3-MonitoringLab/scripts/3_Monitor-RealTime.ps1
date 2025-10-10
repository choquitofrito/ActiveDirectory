# Script pour surveiller les événements AD en temps réel
# Nom du script: 3_Monitor-RealTime.ps1
# Auteur: H2EB - Cours Active Directory
# Date: 2025-10-07
# Description: Surveillance en temps réel des événements de sécurité Active Directory
#              avec affichage coloré et statistiques
#
# Sources Microsoft consultées:
# - https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.diagnostics/get-winevent
# - https://learn.microsoft.com/en-us/powershell/scripting/samples/creating-get-winevent-queries-with-filterhashtable

# ============================================
# PARAMÈTRES DU SCRIPT
# ============================================

param(
    [int]$Minutes = 5,
    [switch]$Continuous
)

# ============================================
# FONCTIONS UTILITAIRES
# ============================================

# Fonction pour afficher l'en-tête du monitoring
function Show-MonitoringHeader {
    Clear-Host
    Write-Host "`n============================================" -ForegroundColor Green
    Write-Host "Surveillance en Temps Réel - Events AD" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Mode: $(if($Continuous){'CONTINU (Ctrl+C pour arrêter)'}else{"$Minutes minutes"})" -ForegroundColor Cyan
    Write-Host "Démarrage: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Événements surveillés:" -ForegroundColor White
    Write-Host "  • 4624 - Connexion réussie" -ForegroundColor Green
    Write-Host "  • 4625 - Échec de connexion" -ForegroundColor Red
    Write-Host "  • 4720 - Création de compte" -ForegroundColor Cyan
    Write-Host "  • 4722 - Compte activé" -ForegroundColor Green
    Write-Host "  • 4725 - Compte désactivé" -ForegroundColor Yellow
    Write-Host "  • 4728 - Membre ajouté à un groupe" -ForegroundColor Cyan
    Write-Host "  • 4729 - Membre retiré d'un groupe" -ForegroundColor Yellow
    Write-Host "  • 4740 - Compte verrouillé" -ForegroundColor Red
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
}

# Fonction pour obtenir une description colorée de l'événement
function Get-EventDescription {
    param([int]$EventId)

    switch ($EventId) {
        4624 { return @{Text="Connexion réussie"; Color="Green"} }
        4625 { return @{Text="Échec de connexion"; Color="Red"} }
        4720 { return @{Text="Compte créé"; Color="Cyan"} }
        4722 { return @{Text="Compte activé"; Color="Green"} }
        4725 { return @{Text="Compte désactivé"; Color="Yellow"} }
        4728 { return @{Text="Membre ajouté au groupe"; Color="Cyan"} }
        4729 { return @{Text="Membre retiré du groupe"; Color="Yellow"} }
        4740 { return @{Text="Compte verrouillé"; Color="Red"} }
        default { return @{Text="Événement inconnu"; Color="Gray"} }
    }
}

# Fonction pour extraire les informations pertinentes d'un événement
function Get-EventInfo {
    param($Event)

    try {
        $eventXml = [xml]$Event.ToXml()
        $eventData = @{}

        # Extraire les données de l'événement
        foreach ($data in $eventXml.Event.EventData.Data) {
            $eventData[$data.Name] = $data.'#text'
        }

        # Informations communes
        $info = [PSCustomObject]@{
            Time = $Event.TimeCreated
            EventId = $Event.Id
            Computer = $Event.MachineName
            TargetUserName = if($eventData.ContainsKey('TargetUserName')) { $eventData['TargetUserName'] } else { "N/A" }
            SubjectUserName = if($eventData.ContainsKey('SubjectUserName')) { $eventData['SubjectUserName'] } else { "N/A" }
            TargetDomainName = if($eventData.ContainsKey('TargetDomainName')) { $eventData['TargetDomainName'] } else { "N/A" }
            WorkstationName = if($eventData.ContainsKey('WorkstationName')) { $eventData['WorkstationName'] } else { "N/A" }
            IpAddress = if($eventData.ContainsKey('IpAddress')) { $eventData['IpAddress'] } else { "N/A" }
            LogonType = if($eventData.ContainsKey('LogonType')) { $eventData['LogonType'] } else { "N/A" }
            FailureReason = if($eventData.ContainsKey('FailureReason')) { $eventData['FailureReason'] } else { "N/A" }
            Status = if($eventData.ContainsKey('Status')) { $eventData['Status'] } else { "N/A" }
            GroupName = if($eventData.ContainsKey('TargetUserName')) { $eventData['TargetUserName'] } else { "N/A" }
            MemberName = if($eventData.ContainsKey('MemberName')) { $eventData['MemberName'] } else { "N/A" }
        }

        return $info
    } catch {
        return $null
    }
}

# Fonction pour afficher un événement formaté
function Show-FormattedEvent {
    param($Event, $EventInfo)

    $description = Get-EventDescription -EventId $Event.Id
    $timestamp = $Event.TimeCreated.ToString("HH:mm:ss")

    Write-Host "[$timestamp] " -NoNewline -ForegroundColor Gray
    Write-Host "$($description.Text) " -NoNewline -ForegroundColor $description.Color
    Write-Host "(ID: $($Event.Id))" -ForegroundColor Gray

    # Afficher les détails selon le type d'événement
    switch ($Event.Id) {
        4624 {
            # Connexion réussie
            if ($EventInfo.TargetUserName -ne "N/A") {
                Write-Host "    Utilisateur: $($EventInfo.TargetUserName)\$($EventInfo.TargetDomainName)" -ForegroundColor White
                Write-Host "    Poste: $($EventInfo.WorkstationName)" -ForegroundColor Gray
                Write-Host "    Type de connexion: $($EventInfo.LogonType)" -ForegroundColor Gray
            }
        }
        4625 {
            # Échec de connexion
            if ($EventInfo.TargetUserName -ne "N/A") {
                Write-Host "    Utilisateur: $($EventInfo.TargetUserName)\$($EventInfo.TargetDomainName)" -ForegroundColor White
                Write-Host "    Poste: $($EventInfo.WorkstationName)" -ForegroundColor Gray
                Write-Host "    Raison: $($EventInfo.FailureReason)" -ForegroundColor Red
            }
        }
        4720 {
            # Création de compte
            if ($EventInfo.TargetUserName -ne "N/A") {
                Write-Host "    Nouveau compte: $($EventInfo.TargetUserName)" -ForegroundColor Cyan
                Write-Host "    Créé par: $($EventInfo.SubjectUserName)" -ForegroundColor Gray
            }
        }
        4722 {
            # Compte activé
            if ($EventInfo.TargetUserName -ne "N/A") {
                Write-Host "    Compte: $($EventInfo.TargetUserName)" -ForegroundColor Green
                Write-Host "    Activé par: $($EventInfo.SubjectUserName)" -ForegroundColor Gray
            }
        }
        4725 {
            # Compte désactivé
            if ($EventInfo.TargetUserName -ne "N/A") {
                Write-Host "    Compte: $($EventInfo.TargetUserName)" -ForegroundColor Yellow
                Write-Host "    Désactivé par: $($EventInfo.SubjectUserName)" -ForegroundColor Gray
            }
        }
        4728 {
            # Membre ajouté au groupe
            if ($EventInfo.TargetUserName -ne "N/A") {
                Write-Host "    Groupe: $($EventInfo.TargetUserName)" -ForegroundColor Cyan
                Write-Host "    Membre ajouté: $($EventInfo.MemberName)" -ForegroundColor White
                Write-Host "    Par: $($EventInfo.SubjectUserName)" -ForegroundColor Gray
            }
        }
        4729 {
            # Membre retiré du groupe
            if ($EventInfo.TargetUserName -ne "N/A") {
                Write-Host "    Groupe: $($EventInfo.TargetUserName)" -ForegroundColor Yellow
                Write-Host "    Membre retiré: $($EventInfo.MemberName)" -ForegroundColor White
                Write-Host "    Par: $($EventInfo.SubjectUserName)" -ForegroundColor Gray
            }
        }
        4740 {
            # Compte verrouillé
            if ($EventInfo.TargetUserName -ne "N/A") {
                Write-Host "    Compte verrouillé: $($EventInfo.TargetUserName)" -ForegroundColor Red
                Write-Host "    Depuis: $($EventInfo.WorkstationName)" -ForegroundColor Gray
            }
        }
    }

    Write-Host ""
}

# ============================================
# FONCTION PRINCIPALE DE SURVEILLANCE
# ============================================

function Watch-SecurityEvents {
    param(
        [int]$DurationMinutes = 5,
        [bool]$IsContinuous = $false
    )

    # Statistiques
    $stats = @{
        4624 = 0
        4625 = 0
        4720 = 0
        4722 = 0
        4725 = 0
        4728 = 0
        4729 = 0
        4740 = 0
    }

    $startTime = Get-Date
    $endTime = $startTime.AddMinutes($DurationMinutes)
    $lastCheckTime = $startTime

    # IDs des événements à surveiller
    $eventIds = 4624, 4625, 4720, 4722, 4725, 4728, 4729, 4740

    Write-Host "[INFO] Surveillance démarrée..." -ForegroundColor Cyan
    Write-Host "[INFO] Appuyez sur Ctrl+C pour arrêter à tout moment`n" -ForegroundColor Yellow

    try {
        while ($true) {
            # Vérifier si le temps est écoulé (sauf en mode continu)
            if (-not $IsContinuous -and (Get-Date) -ge $endTime) {
                break
            }

            # Rechercher les nouveaux événements depuis la dernière vérification
            try {
                $events = Get-WinEvent -FilterHashtable @{
                    LogName = "Security"
                    Id = $eventIds
                    StartTime = $lastCheckTime
                } -ErrorAction SilentlyContinue

                if ($events) {
                    # Trier par date (plus anciens en premier)
                    $events = $events | Sort-Object TimeCreated

                    foreach ($event in $events) {
                        # Incrémenter les statistiques
                        if ($stats.ContainsKey($event.Id)) {
                            $stats[$event.Id]++
                        }

                        # Extraire et afficher les informations
                        $eventInfo = Get-EventInfo -Event $event
                        Show-FormattedEvent -Event $event -EventInfo $eventInfo
                    }
                }

                # Mettre à jour le temps de la dernière vérification
                $lastCheckTime = Get-Date

            } catch {
                # Ignorer les erreurs (pas d'événements trouvés, etc.)
            }

            # Attendre 2 secondes avant la prochaine vérification
            Start-Sleep -Seconds 2

            # Afficher un message de progression toutes les 30 secondes
            $elapsed = (Get-Date) - $startTime
            if ([int]$elapsed.TotalSeconds % 30 -eq 0) {
                if ($IsContinuous) {
                    Write-Host "[INFO] Surveillance en cours... (Durée: $([int]$elapsed.TotalMinutes) min)" -ForegroundColor Gray
                } else {
                    $remaining = ($endTime - (Get-Date)).TotalMinutes
                    Write-Host "[INFO] Surveillance en cours... (Reste: $([math]::Round($remaining, 1)) min)" -ForegroundColor Gray
                }
            }
        }

    } catch {
        Write-Host "`n[ERREUR] Surveillance interrompue: $($_.Exception.Message)" -ForegroundColor Red
    }

    # Afficher les statistiques finales
    Show-FinalStatistics -Stats $stats -StartTime $startTime
}

# ============================================
# FONCTION D'AFFICHAGE DES STATISTIQUES
# ============================================

function Show-FinalStatistics {
    param($Stats, $StartTime)

    $duration = (Get-Date) - $StartTime

    Write-Host "`n============================================" -ForegroundColor Green
    Write-Host "STATISTIQUES FINALES" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Durée de surveillance: $([math]::Round($duration.TotalMinutes, 1)) minutes" -ForegroundColor Cyan
    Write-Host "Période: $($StartTime.ToString('HH:mm:ss')) à $((Get-Date).ToString('HH:mm:ss'))" -ForegroundColor Cyan
    Write-Host ""

    $totalEvents = ($Stats.Values | Measure-Object -Sum).Sum

    if ($totalEvents -eq 0) {
        Write-Host "Aucun événement détecté pendant la période de surveillance." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "💡 CONSEILS:" -ForegroundColor Cyan
        Write-Host "  • Exécutez 2_Generate-Events.ps1 pour générer des événements de test" -ForegroundColor Gray
        Write-Host "  • Vérifiez que l'audit est activé (exécuté dans 1_Setup-MonitoringLab.ps1)" -ForegroundColor Gray
        Write-Host "  • Essayez de vous connecter/déconnecter pour générer des événements 4624" -ForegroundColor Gray
        Write-Host ""
    } else {
        Write-Host "📊 ÉVÉNEMENTS PAR TYPE:" -ForegroundColor Cyan
        Write-Host ""

        foreach ($eventId in $Stats.Keys | Sort-Object) {
            $count = $Stats[$eventId]
            $description = Get-EventDescription -EventId $eventId
            $percentage = [math]::Round(($count / $totalEvents) * 100, 1)

            $color = $description.Color
            if ($count -eq 0) { $color = "Gray" }

            $bar = "█" * [math]::Min([int]($percentage / 2), 50)

            Write-Host "  Event $eventId - $($description.Text): " -NoNewline -ForegroundColor White
            Write-Host "$count " -NoNewline -ForegroundColor $color
            Write-Host "($percentage%)" -ForegroundColor Gray
            Write-Host "    $bar" -ForegroundColor $color
        }

        Write-Host ""
        Write-Host "TOTAL: $totalEvents événements détectés" -ForegroundColor Green
        Write-Host ""
    }

    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
}

# ============================================
# SCRIPT PRINCIPAL
# ============================================

try {
    # Vérifier les privilèges d'administration
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Host "`n⚠️  ATTENTION: Ce script nécessite des privilèges d'administrateur." -ForegroundColor Yellow
        Write-Host "   Certaines fonctionnalités peuvent être limitées.`n" -ForegroundColor Yellow
    }

    # Afficher l'en-tête
    Show-MonitoringHeader

    # Vérifier que le journal Security est accessible
    try {
        $testEvent = Get-WinEvent -LogName Security -MaxEvents 1 -ErrorAction Stop
        Write-Host "[INFO] Accès au journal Security confirmé.`n" -ForegroundColor Green
    } catch {
        Write-Host "[ERREUR] Impossible d'accéder au journal Security." -ForegroundColor Red
        Write-Host "         Assurez-vous d'exécuter ce script en tant qu'Administrateur.`n" -ForegroundColor Red
        exit
    }

    # Afficher les informations de configuration
    Write-Host "⚙️  CONFIGURATION:" -ForegroundColor Cyan
    Write-Host "  Mode: $(if($Continuous){'Continu (Ctrl+C pour arrêter)'}else{"Durée fixe ($Minutes minutes)"})" -ForegroundColor Gray
    Write-Host "  Intervalle de vérification: 2 secondes" -ForegroundColor Gray
    Write-Host "  Journal surveillé: Security" -ForegroundColor Gray
    Write-Host ""

    Write-Host "🚀 Démarrage de la surveillance..." -ForegroundColor Green
    Write-Host ""

    # Lancer la surveillance
    Watch-SecurityEvents -DurationMinutes $Minutes -IsContinuous $Continuous

    Write-Host "`n✅ Surveillance terminée avec succès." -ForegroundColor Green
    Write-Host ""

    Write-Host "🎯 PROCHAINES ÉTAPES:" -ForegroundColor Cyan
    Write-Host "  1. Consultez l'Observateur d'événements pour plus de détails (eventvwr.msc)" -ForegroundColor Yellow
    Write-Host "  2. Exécutez 4_Create-CustomAlerts.ps1 pour configurer des alertes automatiques" -ForegroundColor Yellow
    Write-Host "  3. Exécutez 5_Generate-SecurityReport.ps1 pour créer un rapport détaillé" -ForegroundColor Yellow
    Write-Host ""

    Write-Host "📚 COMMANDES UTILES:" -ForegroundColor Cyan
    Write-Host "  # Relancer la surveillance pour 10 minutes" -ForegroundColor Gray
    Write-Host "  .\3_Monitor-RealTime.ps1 -Minutes 10" -ForegroundColor White
    Write-Host ""
    Write-Host "  # Mode surveillance continue (Ctrl+C pour arrêter)" -ForegroundColor Gray
    Write-Host "  .\3_Monitor-RealTime.ps1 -Continuous" -ForegroundColor White
    Write-Host ""

} catch {
    Write-Host "`n❌ ERREUR CRITIQUE:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "`nStack Trace:" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
}

Write-Host "`nAppuyez sur une touche pour continuer..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
