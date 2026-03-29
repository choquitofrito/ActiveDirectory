# Script pour créer des alertes personnalisées pour le monitoring AD
# Nom du script: 4_Create-CustomAlerts.ps1
# Auteur: H2EB - Cours Active Directory
# Date: 2025-10-07
# Description: Configure des alertes automatiques via Task Scheduler et
#              crée des vues personnalisées dans l'Observateur d'événements
#
# Sources Microsoft consultées:
# - https://learn.microsoft.com/en-us/powershell/module/scheduledtasks/
# - https://learn.microsoft.com/en-us/windows/win32/wes/consuming-events

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

# Fonction pour créer une vue personnalisée XML
function New-CustomEventView {
    param(
        [string]$ViewName,
        [string]$Description,
        [array]$EventIds,
        [string]$LogName = "Security"
    )

    Write-Host "  [CRÉATION] Vue personnalisée: $ViewName..." -ForegroundColor Cyan

    # Construire la liste des Event IDs pour la requête XML
    $eventIdList = ($EventIds | ForEach-Object { "EventID=$_" }) -join " or "

    # XML de la vue personnalisée
    $customViewXml = @"
<ViewerConfig>
  <QueryConfig>
    <QueryParams>
      <Simple>
        <Channel>$LogName</Channel>
        <RelativeTimeInfo>0</RelativeTimeInfo>
        <BySource>False</BySource>
      </Simple>
    </QueryParams>
    <QueryNode>
      <Name>$ViewName</Name>
      <Description>$Description</Description>
      <QueryList>
        <Query Id="0" Path="$LogName">
          <Select Path="$LogName">*[System[($eventIdList)]]</Select>
        </Query>
      </QueryList>
    </QueryNode>
  </QueryConfig>
  <ResultsConfig>
    <Columns>
      <Column Name="Level" Type="System.String" Path="Event/System/Level" Visible="">217</Column>
      <Column Name="Keywords" Type="System.String" Path="Event/System/Keywords">70</Column>
      <Column Name="Date and Time" Type="System.DateTime" Path="Event/System/TimeCreated/@SystemTime" Visible="">267</Column>
      <Column Name="Source" Type="System.String" Path="Event/System/Provider/@Name" Visible="">177</Column>
      <Column Name="Event ID" Type="System.UInt32" Path="Event/System/EventID" Visible="">177</Column>
      <Column Name="Task Category" Type="System.String" Path="Event/System/Task" Visible="">181</Column>
    </Columns>
  </ResultsConfig>
</ViewerConfig>
"@

    return $customViewXml
}

# Fonction pour créer le script d'alerte
function New-AlertScript {
    param(
        [string]$ScriptPath,
        [string]$LogPath,
        [int]$EventId,
        [string]$EventDescription
    )

    $scriptContent = @"
# Script d'alerte automatique pour Event ID $EventId
# Généré automatiquement par 4_Create-CustomAlerts.ps1

`$logFile = "$LogPath"
`$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
`$eventId = $EventId

# Récupérer les détails du dernier événement
try {
    `$event = Get-WinEvent -FilterHashtable @{LogName="Security"; Id=`$eventId} -MaxEvents 1 -ErrorAction Stop

    `$eventXml = [xml]`$event.ToXml()
    `$eventData = @{}
    foreach (`$data in `$eventXml.Event.EventData.Data) {
        `$eventData[`$data.Name] = `$data.'#text'
    }

    # Construire le message d'alerte
    `$alertMessage = @"
[$timestamp] ALERTE: $EventDescription
Event ID: $EventId
Ordinateur: `$(`$event.MachineName)
"@

    # Ajouter des informations spécifiques selon l'événement
    if (`$eventData.ContainsKey('TargetUserName')) {
        `$alertMessage += "`nUtilisateur cible: `$(`$eventData['TargetUserName'])"
    }
    if (`$eventData.ContainsKey('SubjectUserName')) {
        `$alertMessage += "`nInitié par: `$(`$eventData['SubjectUserName'])"
    }
    if (`$eventData.ContainsKey('WorkstationName')) {
        `$alertMessage += "`nPoste de travail: `$(`$eventData['WorkstationName'])"
    }

    `$alertMessage += "`n`$('-' * 80)`n"

    # Écrire dans le fichier de log
    Add-Content -Path `$logFile -Value `$alertMessage

    # Afficher dans la console si exécuté manuellement
    Write-Host `$alertMessage -ForegroundColor Yellow

} catch {
    `$errorMessage = "[$timestamp] ERREUR d'alerte pour Event ID $EventId : `$(`$_.Exception.Message)"
    Add-Content -Path `$logFile -Value `$errorMessage
}
"@

    # Créer le script
    Set-Content -Path $ScriptPath -Value $scriptContent -Encoding UTF8
    Write-Host "    ✅ Script d'alerte créé: $ScriptPath" -ForegroundColor Green
}

# Fonction pour créer une tâche planifiée
function New-EventTriggerTask {
    param(
        [string]$TaskName,
        [string]$ScriptPath,
        [int]$EventId,
        [string]$Description
    )

    Write-Host "  [CONFIGURATION] Tâche planifiée: $TaskName..." -ForegroundColor Cyan

    try {
        # Vérifier si la tâche existe déjà
        $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
        if ($existingTask) {
            Write-Host "    ℹ️  La tâche existe déjà. Suppression et recréation..." -ForegroundColor Yellow
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        }

        # Créer le déclencheur sur l'événement
        $trigger = New-ScheduledTaskTrigger -AtStartup

        # NOTE PÉDAGOGIQUE: Les déclencheurs basés sur des événements spécifiques
        # ne sont pas supportés directement via New-ScheduledTaskTrigger
        # Il faut utiliser une approche XML pour créer un déclencheur d'événement

        $triggerXml = @"
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">*[System[(EventID=$EventId)]]</Select>
  </Query>
</QueryList>
"@

        # Créer l'action (exécuter le script PowerShell)
        $action = New-ScheduledTaskAction -Execute "powershell.exe" `
            -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ScriptPath`""

        # Créer les paramètres
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
            -StartWhenAvailable -MultipleInstances IgnoreNew

        # Créer le principal (compte système)
        $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

        # Enregistrer la tâche avec déclencheur standard (workaround)
        Register-ScheduledTask -TaskName $TaskName `
            -Action $action `
            -Trigger $trigger `
            -Settings $settings `
            -Principal $principal `
            -Description $Description `
            -Force | Out-Null

        Write-Host "    ✅ Tâche planifiée créée: $TaskName" -ForegroundColor Green
        Write-Host "    [NOTE] Pour activer le déclencheur d'événement, configurez manuellement:" -ForegroundColor Yellow
        Write-Host "           1. Ouvrez Task Scheduler (taskschd.msc)" -ForegroundColor Gray
        Write-Host "           2. Trouvez la tâche: $TaskName" -ForegroundColor Gray
        Write-Host "           3. Modifiez les déclencheurs et ajoutez un déclencheur d'événement" -ForegroundColor Gray
        Write-Host "           4. Journal: Security, Source: (Any), Event ID: $EventId" -ForegroundColor Gray

        return $true

    } catch {
        Write-Host "    ❌ ERREUR: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# ============================================
# VARIABLES GLOBALES
# ============================================

Import-Module ScheduledTasks -ErrorAction Stop

$labPath = "C:\MonitoringLab"
$scriptsPath = "$labPath\Scripts\Alerts"
$logsPath = "$labPath\Logs"
$alertLogFile = "$logsPath\Alerts.log"

# Créer les dossiers nécessaires
if (-not (Test-Path $scriptsPath)) {
    New-Item -Path $scriptsPath -ItemType Directory -Force | Out-Null
}

# ============================================
# SCRIPT PRINCIPAL
# ============================================

try {
    Write-Host "`n============================================" -ForegroundColor Green
    Write-Host "Configuration des Alertes Personnalisées" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "`nCe script va configurer:" -ForegroundColor White
    Write-Host "  • Vues personnalisées dans l'Observateur d'événements" -ForegroundColor Gray
    Write-Host "  • Tâches planifiées pour alertes automatiques" -ForegroundColor Gray
    Write-Host "  • Scripts PowerShell d'alerte pour Event ID 4740 (verrouillage)" -ForegroundColor Gray
    Write-Host "  • Fichier de log centralisé: $alertLogFile" -ForegroundColor Gray
    Write-Host ""

    # Vérifier les privilèges d'administration
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Host "❌ ERREUR: Ce script nécessite des privilèges d'administrateur." -ForegroundColor Red
        Write-Host "   Relancez PowerShell ISE en tant qu'Administrateur.`n" -ForegroundColor Yellow
        exit
    }

    # ============================================
    # ÉTAPE 1: CRÉER LES VUES PERSONNALISÉES
    # ============================================

    if (Confirm-Step "Créer les vues personnalisées dans l'Observateur d'événements") {
        Write-Host "`n[ÉTAPE 1/4] Création des vues personnalisées..." -ForegroundColor Cyan

        # Vue 1: Événements critiques de sécurité
        $criticalView = New-CustomEventView `
            -ViewName "MonitoringLab - Événements Critiques" `
            -Description "Échecs de connexion, verrouillages et comptes désactivés" `
            -EventIds @(4625, 4740, 4725)

        $criticalViewPath = "$labPath\CustomView_Critical.xml"
        Set-Content -Path $criticalViewPath -Value $criticalView -Encoding UTF8
        Write-Host "    ✅ Vue critique exportée: $criticalViewPath" -ForegroundColor Green

        # Vue 2: Gestion des comptes
        $accountView = New-CustomEventView `
            -ViewName "MonitoringLab - Gestion des Comptes" `
            -Description "Création, activation, désactivation de comptes" `
            -EventIds @(4720, 4722, 4725)

        $accountViewPath = "$labPath\CustomView_Accounts.xml"
        Set-Content -Path $accountViewPath -Value $accountView -Encoding UTF8
        Write-Host "    ✅ Vue comptes exportée: $accountViewPath" -ForegroundColor Green

        # Vue 3: Gestion des groupes
        $groupView = New-CustomEventView `
            -ViewName "MonitoringLab - Gestion des Groupes" `
            -Description "Ajout et retrait de membres dans les groupes de sécurité" `
            -EventIds @(4728, 4729)

        $groupViewPath = "$labPath\CustomView_Groups.xml"
        Set-Content -Path $groupViewPath -Value $groupView -Encoding UTF8
        Write-Host "    ✅ Vue groupes exportée: $groupViewPath" -ForegroundColor Green

        Write-Host "`n  [INSTRUCTIONS] Pour importer les vues dans l'Observateur d'événements:" -ForegroundColor Yellow
        Write-Host "    1. Ouvrez l'Observateur d'événements (eventvwr.msc)" -ForegroundColor Gray
        Write-Host "    2. Clic droit sur 'Affichages personnalisés' > Importer un affichage personnalisé..." -ForegroundColor Gray
        Write-Host "    3. Sélectionnez les fichiers XML créés dans $labPath" -ForegroundColor Gray
        Write-Host "    4. Les vues apparaîtront dans le panneau de gauche" -ForegroundColor Gray
        Write-Host ""
    }

    # ============================================
    # ÉTAPE 2: CRÉER LES SCRIPTS D'ALERTE
    # ============================================

    if (Confirm-Step "Créer les scripts PowerShell d'alerte") {
        Write-Host "`n[ÉTAPE 2/4] Création des scripts d'alerte..." -ForegroundColor Cyan

        # Initialiser le fichier de log
        if (-not (Test-Path $alertLogFile)) {
            $initMessage = @"
============================================
JOURNAL DES ALERTES - MONITORING AD
Créé le: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
============================================

"@
            Set-Content -Path $alertLogFile -Value $initMessage -Encoding UTF8
            Write-Host "    ✅ Fichier de log initialisé: $alertLogFile" -ForegroundColor Green
        }

        # Script d'alerte pour verrouillage de compte (Event ID 4740)
        $lockoutScriptPath = "$scriptsPath\Alert_AccountLockout.ps1"
        New-AlertScript -ScriptPath $lockoutScriptPath `
            -LogPath $alertLogFile `
            -EventId 4740 `
            -EventDescription "Compte utilisateur verrouillé"

        # Script d'alerte pour échecs de connexion répétés (Event ID 4625)
        $failedLogonScriptPath = "$scriptsPath\Alert_FailedLogon.ps1"
        New-AlertScript -ScriptPath $failedLogonScriptPath `
            -LogPath $alertLogFile `
            -EventId 4625 `
            -EventDescription "Échec de connexion"

        # Script d'alerte pour création de compte (Event ID 4720)
        $accountCreatedScriptPath = "$scriptsPath\Alert_AccountCreated.ps1"
        New-AlertScript -ScriptPath $accountCreatedScriptPath `
            -LogPath $alertLogFile `
            -EventId 4720 `
            -EventDescription "Nouveau compte utilisateur créé"

        Write-Host "`n  [INFO] Scripts d'alerte créés avec succès." -ForegroundColor Green
    }

    # ============================================
    # ÉTAPE 3: CRÉER LES TÂCHES PLANIFIÉES
    # ============================================

    if (Confirm-Step "Créer les tâches planifiées pour alertes automatiques") {
        Write-Host "`n[ÉTAPE 3/4] Configuration des tâches planifiées..." -ForegroundColor Cyan

        # Tâche pour Event ID 4740 (Verrouillage de compte)
        New-EventTriggerTask `
            -TaskName "MonitoringLab - Alerte Verrouillage Compte" `
            -ScriptPath $lockoutScriptPath `
            -EventId 4740 `
            -Description "Alerte automatique lors du verrouillage d'un compte utilisateur"

        # Tâche pour Event ID 4625 (Échecs de connexion)
        New-EventTriggerTask `
            -TaskName "MonitoringLab - Alerte Échecs Connexion" `
            -ScriptPath $failedLogonScriptPath `
            -EventId 4625 `
            -Description "Alerte automatique lors d'échecs de connexion répétés"

        # Tâche pour Event ID 4720 (Création de compte)
        New-EventTriggerTask `
            -TaskName "MonitoringLab - Alerte Création Compte" `
            -ScriptPath $accountCreatedScriptPath `
            -EventId 4720 `
            -Description "Alerte automatique lors de la création d'un compte"

        Write-Host "`n  [INFO] Tâches planifiées créées." -ForegroundColor Green
        Write-Host "  [NOTE] Configurez manuellement les déclencheurs d'événements dans Task Scheduler." -ForegroundColor Yellow
    }

    # ============================================
    # ÉTAPE 4: TESTER LES ALERTES
    # ============================================

    if (Confirm-Step "Tester le système d'alerte (verrouillage de U_Test1)") {
        Write-Host "`n[ÉTAPE 4/4] Test du système d'alerte..." -ForegroundColor Cyan

        Write-Host "`n  [INFORMATION PÉDAGOGIQUE]" -ForegroundColor Yellow
        Write-Host "  Pour tester les alertes, vous devez générer réellement l'événement 4740." -ForegroundColor Gray
        Write-Host "  Cela nécessite de:" -ForegroundColor Gray
        Write-Host "    1. Avoir une politique de verrouillage activée (minimum 3 tentatives)" -ForegroundColor Gray
        Write-Host "    2. Aller sur une machine cliente Windows 10/11" -ForegroundColor Gray
        Write-Host "    3. Tenter de se connecter avec U_Test1 et un mauvais mot de passe 3 fois" -ForegroundColor Gray
        Write-Host "    4. Le compte sera verrouillé et l'alerte sera déclenchée" -ForegroundColor Gray
        Write-Host ""

        # Vérifier la politique de verrouillage
        $domain = Get-ADDomain
        $policy = Get-ADDefaultDomainPasswordPolicy -Identity $domain.DNSRoot

        Write-Host "  [POLITIQUE ACTUELLE]" -ForegroundColor Cyan
        Write-Host "    Seuil de verrouillage: $($policy.LockoutThreshold) tentatives" -ForegroundColor Gray

        if ($policy.LockoutThreshold -eq 0) {
            Write-Host "    ⚠️  Le verrouillage est DÉSACTIVÉ. Activation recommandée pour ce test." -ForegroundColor Red
            Write-Host "`n  Voulez-vous activer temporairement le verrouillage (3 tentatives)? (O/N)" -ForegroundColor Yellow
            $response = Read-Host

            if ($response.ToUpper() -eq 'O') {
                try {
                    Set-ADDefaultDomainPasswordPolicy -Identity $domain.DNSRoot `
                        -LockoutThreshold 3 `
                        -LockoutDuration (New-TimeSpan -Minutes 15) `
                        -LockoutObservationWindow (New-TimeSpan -Minutes 15)
                    Write-Host "    ✅ Politique de verrouillage activée (3 tentatives, 15 min)" -ForegroundColor Green
                } catch {
                    Write-Host "    ❌ Erreur d'activation: $($_.Exception.Message)" -ForegroundColor Red
                }
            }
        } else {
            Write-Host "    ✅ Politique de verrouillage active" -ForegroundColor Green
        }

        Write-Host "`n  [TEST MANUEL]" -ForegroundColor Cyan
        Write-Host "  Vous pouvez également tester manuellement les scripts d'alerte:" -ForegroundColor Gray
        Write-Host "    # Exécuter le script d'alerte pour le dernier Event ID 4740" -ForegroundColor Cyan
        Write-Host "    & '$lockoutScriptPath'" -ForegroundColor White
        Write-Host ""
        Write-Host "    # Consulter le fichier de log des alertes" -ForegroundColor Cyan
        Write-Host "    Get-Content '$alertLogFile' -Tail 20" -ForegroundColor White
        Write-Host ""
    }

    # ============================================
    # BONUS: CONFIGURATION EMAIL (COMMENTÉ)
    # ============================================

    Write-Host "`n[BONUS] Configuration d'alertes par email" -ForegroundColor Cyan
    Write-Host "  [NOTE] Cette fonctionnalité nécessite un serveur SMTP configuré." -ForegroundColor Yellow
    Write-Host "  Pour activer les alertes par email, modifiez les scripts d'alerte" -ForegroundColor Gray
    Write-Host "  et ajoutez les commandes Send-MailMessage avec vos paramètres SMTP." -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Exemple de code à ajouter aux scripts d'alerte:" -ForegroundColor Cyan
    Write-Host @"

  # Configuration email (à personnaliser)
  `$smtpServer = "smtp.votredomaine.com"
  `$from = "monitoring@votredomaine.com"
  `$to = "admin@votredomaine.com"

  Send-MailMessage -SmtpServer `$smtpServer ``
      -From `$from ``
      -To `$to ``
      -Subject "ALERTE AD: Verrouillage de compte" ``
      -Body `$alertMessage ``
      -Priority High
"@ -ForegroundColor Gray
    Write-Host ""

    # ============================================
    # RÉSUMÉ FINAL
    # ============================================

    Write-Host "`n============================================" -ForegroundColor Green
    Write-Host "CONFIGURATION DES ALERTES TERMINÉE!" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green

    Write-Host "`n📊 RÉSUMÉ DE LA CONFIGURATION:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Vues personnalisées créées:" -ForegroundColor White
    Write-Host "  • MonitoringLab - Événements Critiques (4625, 4740, 4725)" -ForegroundColor Gray
    Write-Host "  • MonitoringLab - Gestion des Comptes (4720, 4722, 4725)" -ForegroundColor Gray
    Write-Host "  • MonitoringLab - Gestion des Groupes (4728, 4729)" -ForegroundColor Gray
    Write-Host ""

    Write-Host "Scripts d'alerte créés:" -ForegroundColor White
    Write-Host "  • $lockoutScriptPath" -ForegroundColor Gray
    Write-Host "  • $failedLogonScriptPath" -ForegroundColor Gray
    Write-Host "  • $accountCreatedScriptPath" -ForegroundColor Gray
    Write-Host ""

    Write-Host "Tâches planifiées créées:" -ForegroundColor White
    Write-Host "  • MonitoringLab - Alerte Verrouillage Compte" -ForegroundColor Gray
    Write-Host "  • MonitoringLab - Alerte Échecs Connexion" -ForegroundColor Gray
    Write-Host "  • MonitoringLab - Alerte Création Compte" -ForegroundColor Gray
    Write-Host ""

    Write-Host "Fichier de log:" -ForegroundColor White
    Write-Host "  • $alertLogFile" -ForegroundColor Gray
    Write-Host ""

    Write-Host "🎯 PROCHAINES ÉTAPES:" -ForegroundColor Cyan
    Write-Host "  1. Importez les vues personnalisées dans eventvwr.msc" -ForegroundColor Yellow
    Write-Host "  2. Configurez les déclencheurs d'événements dans taskschd.msc" -ForegroundColor Yellow
    Write-Host "  3. Testez les alertes en générant des événements (script 2_Generate-Events.ps1)" -ForegroundColor Yellow
    Write-Host "  4. Consultez le fichier de log: $alertLogFile" -ForegroundColor Yellow
    Write-Host "  5. Exécutez 5_Generate-SecurityReport.ps1 pour créer un rapport complet" -ForegroundColor Yellow
    Write-Host ""

    Write-Host "📚 COMMANDES UTILES:" -ForegroundColor Cyan
    Write-Host "  # Consulter les 20 dernières alertes" -ForegroundColor Gray
    Write-Host "  Get-Content '$alertLogFile' -Tail 20" -ForegroundColor White
    Write-Host ""
    Write-Host "  # Tester manuellement un script d'alerte" -ForegroundColor Gray
    Write-Host "  & '$lockoutScriptPath'" -ForegroundColor White
    Write-Host ""
    Write-Host "  # Vérifier les tâches planifiées créées" -ForegroundColor Gray
    Write-Host "  Get-ScheduledTask | Where-Object {`$_.TaskName -like '*MonitoringLab*'}" -ForegroundColor White
    Write-Host ""

} catch {
    Write-Host "`n❌ ERREUR CRITIQUE:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "`nStack Trace:" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
}

Write-Host "`nAppuyez sur une touche pour continuer..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
