# Exercice 05 : Confidentialité Renforcée

## Niveau: 🟡 Intermédiaire | Durée: 30-35 min

## Objectifs
- Créer une **GPO de sécurité** conforme RGPD/HIPAA
- Maîtriser la **configuration manuelle GPMC** (pas Set-GPRegistryValue)
- Appliquer des **restrictions de sécurité** médicale
- Tester l'application des GPOs

## Scénario
Suite à un **audit RGPD**, la clinique doit renforcer la sécurité des postes médicaux pour empêcher :

1. Captures d'écran de dossiers patients (exfiltration visuelle)
2. Impression vers imprimantes personnelles/USB
3. Sessions non verrouillées (timeout 10 minutes)

## Tâches à Réaliser

**Objectif** : Créer et configurer GPO "MediCare - Sécurité Renforcée Médical"

### Contraintes
1. Créer GPO shell uniquement via PowerShell
2. Configurer manuellement dans GPMC (consulter `.claude/gpo-reference.md`)
3. Lier à `OU=Users,OU=Medical,OU=MediCare`
4. Paramètres requis :
   - Bloquer Impression vers imprimantes non réseau
   - Screen Lock timeout: 600 secondes (10 min)
   - Message de sécurité au logon

5. Tester avec compte médecin (catherine ou philippe)

### Indices
- **JAMAIS** utiliser `Set-GPRegistryValue` pour politiques Windows
- Chercher dans gpo-reference.md les chemins exacts
- Tester : `gpupdate /force` puis attendre 10 min inactivité

## Solution

```powershell
# Créer GPO shell
$gpoName = "MediCare - Sécurité Renforcée Médical"
New-GPO -Name $gpoName -Comment "Sécurité RGPD: Blocage impressions USB + Screen lock 10min"
New-GPLink -Name $gpoName -Target "OU=Users,OU=Medical,OU=MediCare,DC=maxtec,DC=be" -LinkEnabled Yes

Write-Host "`n⚠️  Configuration manuelle requise dans GPMC:" -ForegroundColor Yellow
Write-Host "1. Computer Config > Security Settings > Local Policies > Security Options"
Write-Host "   'Interactive logon: Machine inactivity limit' = 600 seconds"
Write-Host "2. User Config > Administrative Templates > Control Panel > Printers"
Write-Host "   'Point and Print Restrictions' = Enabled (configurer selon besoins)"
```

## Vérification
```powershell
C:\Labos\MediCare\scripts\verification\verif_exercice_05.ps1
```

## Exercice Suivant
**[Exercice 06 : Délégation Chef de Service](Exercice_06_Delegation_Chef_Service.md)**
