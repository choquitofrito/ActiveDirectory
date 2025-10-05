# GPO Reference Guide - Validated Settings Only

## ⚠️ IMPORTANT - GPO Creation Rules

### ❌ NEVER DO THIS
```powershell
# WRONG - Using registry paths directly
Set-GPRegistryValue -Name "GPO-Name" -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoControlPanel" -Type DWord -Value 1

# WRONG - Using GUIDs for removable storage
Set-GPRegistryValue -Name "GPO-Name" -Key "HKLM\Software\Policies\Microsoft\Windows\RemovableStorageDevices\{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}" -ValueName "Deny_Write" -Type DWord -Value 1
```

**WHY?** These create invalid registry entries that show as "nom convivial introuvable" (friendly name not found) in GPMC.

### ✅ CORRECT APPROACH

1. **Use ONLY validated policy paths** (see below)
2. **Create GPO shell** with `New-GPO`
3. **Add note in comments** that settings must be configured via GPMC GUI
4. **Provide exact navigation path** for manual configuration

```powershell
# CORRECT - Create GPO and provide manual instructions
New-GPO -Name "GPO-Name" -Comment "Désactive l'accès au Panneau de configuration"

Write-Host "  Configuration manuelle requise dans GPMC:" -ForegroundColor Yellow
Write-Host "  User Configuration > Policies > Administrative Templates > Control Panel" -ForegroundColor Gray
Write-Host "  Paramètre: 'Prohibit access to Control Panel and PC settings' = Enabled" -ForegroundColor Gray
```

---

## 📋 Validated GPO Settings Catalog

### 1. SECURITY - User Restrictions

#### 1.1 Control Panel Access (User)
- **Path**: `User Configuration > Policies > Administrative Templates > Control Panel`
- **Setting**: "Prohibit access to Control Panel and PC settings"
- **Value**: Enabled
- **Use Case**: Restrict junior users, kiosk mode
- **PowerShell**: ❌ NOT SUPPORTED via Set-GPRegistryValue
- **Config Method**: Manual via GPMC or Group Policy Preferences

#### 1.2 Command Prompt Access (User)
- **Path**: `User Configuration > Policies > Administrative Templates > System`
- **Setting**: "Prevent access to the command prompt"
- **Value**: Enabled
- **Additional**: "Disable the command prompt script processing also?" = Yes/No
- **Use Case**: Restrict scripting access
- **PowerShell**: ❌ NOT SUPPORTED via Set-GPRegistryValue
- **Config Method**: Manual via GPMC

### 2. SECURITY - Computer Restrictions

#### 2.1 Guest Account Disable (Computer)
- **Path**: `Computer Configuration > Windows Settings > Security Settings > Local Policies > Security Options`
- **Setting**: "Accounts: Guest account status"
- **Value**: Disabled
- **Use Case**: Baseline security
- **PowerShell**: ✅ SUPPORTED via `Set-GPRegistryValue` or `secedit`
- **Alternative**: Use Security Templates (.inf files)

#### 2.2 LAN Manager Hash Storage (Computer)
- **Path**: `Computer Configuration > Windows Settings > Security Settings > Local Policies > Security Options`
- **Setting**: "Network security: Do not store LAN Manager hash value on next password change"
- **Value**: Enabled
- **Use Case**: Prevent weak hash storage
- **PowerShell**: ✅ SUPPORTED via Security Templates

#### 2.3 UAC Settings (Computer)
- **Path**: `Computer Configuration > Policies > Windows Settings > Security Settings > Local Policies > Security Options`
- **Setting**: "User Account Control: Run all administrators in Admin Approval Mode"
- **Value**: Enabled
- **Use Case**: Enforce UAC prompts
- **PowerShell**: ✅ SUPPORTED via Security Templates

#### 2.4 Interactive Logon - Screen Lock Timeout (Computer)
- **Path**: `Computer Configuration > Windows Settings > Security Settings > Local Policies > Security Options`
- **Setting**: "Interactive logon: Machine inactivity limit"
- **Value**: 600-900 seconds (10-15 minutes)
- **Use Case**: Auto-lock idle sessions
- **PowerShell**: ✅ SUPPORTED via Security Templates

### 3. PASSWORD & ACCOUNT POLICIES

#### 3.1 Minimum Password Length
- **Path**: `Computer Configuration > Windows Settings > Security Settings > Account Policies > Password Policy`
- **Setting**: "Minimum password length"
- **Value**: 12-15 characters
- **Use Case**: Strong password enforcement
- **PowerShell**: ✅ SUPPORTED via `Set-ADDefaultDomainPasswordPolicy`

#### 3.2 Maximum Password Age
- **Path**: `Computer Configuration > Windows Settings > Security Settings > Account Policies > Password Policy`
- **Setting**: "Maximum password age"
- **Value**: 60-90 days
- **Use Case**: Regular password rotation
- **PowerShell**: ✅ SUPPORTED via `Set-ADDefaultDomainPasswordPolicy`

#### 3.3 Password Complexity
- **Path**: `Computer Configuration > Windows Settings > Security Settings > Account Policies > Password Policy`
- **Setting**: "Password must meet complexity requirements"
- **Value**: Enabled
- **Use Case**: Enforce mixed character passwords
- **PowerShell**: ✅ SUPPORTED via `Set-ADDefaultDomainPasswordPolicy`

#### 3.4 Account Lockout Threshold
- **Path**: `Computer Configuration > Windows Settings > Security Settings > Account Policies > Account Lockout Policy`
- **Setting**: "Account lockout threshold"
- **Value**: 5 invalid attempts
- **Use Case**: Brute-force protection
- **PowerShell**: ✅ SUPPORTED via `Set-ADDefaultDomainPasswordPolicy`

#### 3.5 Account Lockout Duration
- **Path**: `Computer Configuration > Windows Settings > Security Settings > Account Policies > Account Lockout Policy`
- **Setting**: "Account lockout duration"
- **Value**: 15-30 minutes
- **Use Case**: Auto-unlock after lockout
- **PowerShell**: ✅ SUPPORTED via `Set-ADDefaultDomainPasswordPolicy`

### 4. AUDITING

#### 4.1 Audit Logon Events
- **Path**: `Computer Configuration > Windows Settings > Security Settings > Advanced Audit Policy Configuration > Audit Policies > Logon/Logoff`
- **Setting**: "Audit Logon"
- **Value**: Success, Failure
- **Use Case**: Track authentication attempts
- **PowerShell**: ✅ SUPPORTED via `auditpol.exe /set /subcategory:"Logon" /success:enable /failure:enable`

#### 4.2 Audit Account Management
- **Path**: `Computer Configuration > Windows Settings > Security Settings > Advanced Audit Policy Configuration > Audit Policies > Account Management`
- **Setting**: "Audit User Account Management"
- **Value**: Success, Failure
- **Use Case**: Track user/group changes
- **PowerShell**: ✅ SUPPORTED via `auditpol.exe`

#### 4.3 Audit Policy Change
- **Path**: `Computer Configuration > Windows Settings > Security Settings > Advanced Audit Policy Configuration > Audit Policies > Policy Change`
- **Setting**: "Audit Policy Change"
- **Value**: Success, Failure
- **Use Case**: Track GPO modifications
- **PowerShell**: ✅ SUPPORTED via `auditpol.exe`

### 5. REMOVABLE STORAGE (COMPLEX - REQUIRES PREFERENCES)

#### 5.1 Block Removable Storage Access
- **Path**: `User Configuration > Policies > Administrative Templates > System > Removable Storage Access`
- **Setting**: "All Removable Storage classes: Deny all access"
- **Value**: Enabled
- **Use Case**: Prevent USB data exfiltration
- **PowerShell**: ❌ NOT SUPPORTED via Set-GPRegistryValue
- **Config Method**: Manual via GPMC
- **Alternative**: Use Device Guard/AppLocker for granular control

⚠️ **NOTE**: The old registry method using GUIDs (`{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}`) is deprecated and causes "friendly name not found" errors.

### 6. SOFTWARE INSTALLATION

#### 6.1 Prohibit User Software Installs
- **Path**: `Computer Configuration > Administrative Templates > Windows Components > Windows Installer`
- **Setting**: "Prohibit User Installs"
- **Value**: Enabled
- **Use Case**: Prevent unauthorized software
- **PowerShell**: ❌ NOT SUPPORTED via Set-GPRegistryValue
- **Config Method**: Manual via GPMC

#### 6.2 Auto-Restart Prevention
- **Path**: `Computer Configuration > Administrative Templates > Windows Components > Windows Update`
- **Setting**: "No auto-restart with logged on users for scheduled automatic updates installations"
- **Value**: Enabled
- **Use Case**: Prevent work disruption
- **PowerShell**: ❌ NOT SUPPORTED via Set-GPRegistryValue
- **Config Method**: Manual via GPMC

### 7. DRIVE MAPPING (REQUIRES PREFERENCES)

#### 7.1 Network Drive Mapping
- **Path**: `User Configuration > Preferences > Windows Settings > Drive Maps`
- **Action**: Create/Update/Replace
- **Example**: Map P: to `\\SERVER\Projects`
- **PowerShell**: ❌ NOT SUPPORTED via Set-GPRegistryValue
- **Config Method**: Group Policy Preferences XML manipulation or manual GPMC configuration

⚠️ **IMPORTANT**: Drive mapping via GPO Preferences requires XML manipulation or GPMC. Do NOT attempt with registry values.

---

## 🛠️ PowerShell Implementation Guidelines

### Safe GPO Creation Pattern

```powershell
# 1. Create GPO shell only
$gpoName = "CompanyName - Descriptive Purpose"
New-GPO -Name $gpoName -Comment "Clear description of what this GPO does"

# 2. Link to target OU
$targetOU = "OU=Users,OU=Department,DC=domain,DC=com"
New-GPLink -Name $gpoName -Target $targetOU -LinkEnabled Yes

# 3. Provide manual configuration instructions
Write-Host "`nGPO '$gpoName' créée. Configuration manuelle requise:" -ForegroundColor Yellow
Write-Host "  1. Ouvrir GPMC (gpmc.msc)" -ForegroundColor Gray
Write-Host "  2. Naviguer vers: [EXACT PATH FROM TABLE ABOVE]" -ForegroundColor Gray
Write-Host "  3. Configurer: [EXACT SETTING NAME] = [VALUE]" -ForegroundColor Gray
Write-Host "  4. Appliquer avec: gpupdate /force" -ForegroundColor Gray
```

### Exception: Password Policies (Domain Level)

```powershell
# Password policies can be set via PowerShell at domain level
Set-ADDefaultDomainPasswordPolicy -Identity "maxtec.be" `
    -MinPasswordLength 12 `
    -PasswordHistoryCount 24 `
    -MaxPasswordAge (New-TimeSpan -Days 90) `
    -MinPasswordAge (New-TimeSpan -Days 1) `
    -ComplexityEnabled $true `
    -LockoutThreshold 5 `
    -LockoutDuration (New-TimeSpan -Minutes 30) `
    -LockoutObservationWindow (New-TimeSpan -Minutes 30)
```

### Exception: Audit Policies

```powershell
# Audit policies can be configured via auditpol.exe
auditpol /set /subcategory:"Logon" /success:enable /failure:enable
auditpol /set /subcategory:"User Account Management" /success:enable /failure:enable
```

---

## 🎓 Educational Lab GPO Recommendations

For beginner AD labs, focus on **demonstrative GPOs** that:
1. Are **easy to verify** (visible impact on UI/behavior)
2. Are **safe to test** (non-destructive)
3. Teach **real-world concepts**

### Recommended Lab GPOs

| GPO Purpose | User/Computer | Manual Config Required | Verification Method |
|-------------|---------------|------------------------|---------------------|
| Block Control Panel | User | ✅ Yes | User logs in, tries to open Control Panel |
| Block CMD | User | ✅ Yes | User tries to run `cmd.exe` |
| Screen Lock Timeout | Computer | ⚠️ Security Template | Wait for timeout, screen locks |
| Password Policy | Domain | ❌ No (PowerShell) | Attempt weak password change |
| Audit Logon Events | Computer | ⚠️ auditpol.exe | Check Event Viewer after logon |
| Map Network Drive | User | ✅ Yes (GPP) | Drive appears after `gpupdate /force` |

### Lab-Safe GPO Examples (Script Template)

```powershell
# Example: Create demonstration GPOs with clear manual instructions

# GPO 1: User Restrictions (Junior Users)
$gpo1 = "LabCompany - Restrictions Utilisateurs Juniors"
if (-not (Test-GPOExists $gpo1)) {
    New-GPO -Name $gpo1 -Comment "Démo: Restreint accès Panneau config + CMD pour juniors"
    New-GPLink -Name $gpo1 -Target "OU=Users,OU=Marketing,$rootOU" -LinkEnabled Yes

    Write-Host "`n[GPO CRÉÉE] $gpo1" -ForegroundColor Green
    Write-Host "  ⚠️  Configuration manuelle requise dans GPMC:" -ForegroundColor Yellow
    Write-Host "`n  📍 Étape 1 - Bloquer Panneau de Configuration:" -ForegroundColor Cyan
    Write-Host "     User Config > Policies > Administrative Templates > Control Panel" -ForegroundColor Gray
    Write-Host "     > Prohibit access to Control Panel and PC settings = Enabled" -ForegroundColor White
    Write-Host "`n  📍 Étape 2 - Bloquer Invite de Commandes:" -ForegroundColor Cyan
    Write-Host "     User Config > Policies > Administrative Templates > System" -ForegroundColor Gray
    Write-Host "     > Prevent access to the command prompt = Enabled" -ForegroundColor White
    Write-Host "`n  ✅ Vérification:" -ForegroundColor Cyan
    Write-Host "     1. Connectez-vous avec un compte du département Marketing" -ForegroundColor Gray
    Write-Host "     2. Exécutez: gpupdate /force" -ForegroundColor Gray
    Write-Host "     3. Essayez d'ouvrir le Panneau de configuration (doit être bloqué)" -ForegroundColor Gray
    Write-Host "     4. Essayez d'ouvrir cmd.exe (doit être bloqué)`n" -ForegroundColor Gray
}

# GPO 2: Password Policy (Domain-level, PowerShell supported)
Write-Host "`n[CONFIGURATION] Stratégie de Mots de Passe du Domaine" -ForegroundColor Green
try {
    Set-ADDefaultDomainPasswordPolicy -Identity "maxtec.be" `
        -MinPasswordLength 10 `
        -ComplexityEnabled $true `
        -MaxPasswordAge (New-TimeSpan -Days 90) `
        -MinPasswordAge (New-TimeSpan -Days 1) `
        -PasswordHistoryCount 12

    Write-Host "  ✅ Politique de mots de passe configurée:" -ForegroundColor Green
    Write-Host "     - Longueur minimale: 10 caractères" -ForegroundColor Gray
    Write-Host "     - Complexité: Activée" -ForegroundColor Gray
    Write-Host "     - Âge maximum: 90 jours" -ForegroundColor Gray
    Write-Host "     - Historique: 12 mots de passe`n" -ForegroundColor Gray
} catch {
    Write-Host "  ⚠️  ERREUR configuration politique: $($_.Exception.Message)" -ForegroundColor Red
}

# GPO 3: Drive Mapping (Requires GPP - manual only)
$gpo3 = "LabCompany - Lecteurs Réseau Partagés"
if (-not (Test-GPOExists $gpo3)) {
    New-GPO -Name $gpo3 -Comment "Mappe lecteur P: vers \\SERVEUR\Projets"
    New-GPLink -Name $gpo3 -Target $rootOU -LinkEnabled Yes

    Write-Host "`n[GPO CRÉÉE] $gpo3" -ForegroundColor Green
    Write-Host "  ⚠️  Configuration manuelle requise dans GPMC:" -ForegroundColor Yellow
    Write-Host "`n  📍 Mappage de Lecteur Réseau:" -ForegroundColor Cyan
    Write-Host "     User Config > Preferences > Windows Settings > Drive Maps" -ForegroundColor Gray
    Write-Host "     > Action: Create" -ForegroundColor White
    Write-Host "     > Location: \\\\SERVEUR\\Projets" -ForegroundColor White
    Write-Host "     > Drive Letter: P:" -ForegroundColor White
    Write-Host "     > Label as: Projets Clients" -ForegroundColor White
    Write-Host "`n  ⚠️  PRÉREQUIS: Créer d'abord le partage réseau \\\\SERVEUR\\Projets" -ForegroundColor Yellow
    Write-Host "`n  ✅ Vérification:" -ForegroundColor Cyan
    Write-Host "     1. Configurez le partage réseau sur le serveur" -ForegroundColor Gray
    Write-Host "     2. Configurez le lecteur mappé dans GPMC comme indiqué ci-dessus" -ForegroundColor Gray
    Write-Host "     3. Connectez-vous avec un utilisateur" -ForegroundColor Gray
    Write-Host "     4. Exécutez: gpupdate /force" -ForegroundColor Gray
    Write-Host "     5. Vérifiez que le lecteur P: apparaît dans 'Ce PC'`n" -ForegroundColor Gray
}
```

---

## 🔍 Troubleshooting "Nom Convivial Introuvable"

### Symptom
In GPMC, under "Définitions de stratégies (fichiers ADMX)", you see:
```
Autres paramètres Registre
Le nom convivial de certains paramètres est introuvable.

Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoControlPanel
Software\Policies\Microsoft\Windows\RemovableStorageDevices\{53f5...}\Deny_Write
```

### Cause
- Used `Set-GPRegistryValue` with raw registry paths
- These are NOT valid ADMX-backed policy settings
- Windows can't map them to friendly names

### Solution
1. **Delete the GPO** and recreate
2. **Use manual GPMC configuration** for the correct setting
3. **Never use** `Set-GPRegistryValue` for User/Computer Configuration policies
4. **Only use** `Set-GPRegistryValue` for custom registry tweaks NOT covered by ADMX

### When CAN You Use Set-GPRegistryValue?
- Custom application registry settings (e.g., `HKLM\Software\CompanyApp\Setting`)
- Advanced tweaks not covered by built-in ADMX templates
- **NOT** for standard Windows policies (those should be configured via GPMC)

---

## 📚 References
- [Microsoft Learn - Group Policy](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/component-updates/group-policy-overview)
- [Active Directory Pro - GPO Security Examples](https://activedirectorypro.com/group-policy-examples-most-useful-gpos-for-security/)
- [Lepide - Top 10 GPO Settings](https://www.lepide.com/blog/top-10-most-important-group-policy-settings-for-preventing-security-breaches/)
- [Heimdal Security - GPO Guide](https://heimdalsecurity.com/blog/group-policy-objects-gpo/)

---

**Last Updated**: 2025-10-05
**Version**: 1.0
**Maintainer**: H2EB Active Directory Lab Project
