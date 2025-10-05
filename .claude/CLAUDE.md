# Configuración del Proyecto Active Directory

## Agentes Disponibles

### 1. `ad-lab-creator`
- **Función**: Genera scripts PowerShell para crear estructuras AD completas
- **Output**: Scripts .ps1, cleanup scripts, documentación README
- **Características clave**:
  - Scripts idempotentes (re-ejecutables sin errores)
  - Confirmación paso a paso interactiva
  - TODAS las OUs con `-ProtectedFromAccidentalDeletion $false`
  - TODOS los grupos globales con prefijo `GG-` (MANDATORY)
  - Exportación CSV automática
  - Comentarios y mensajes en francés
  - **GPOs**: Consultar `.claude/gpo-reference.md` - SOLO crear shell, NO configurar via Set-GPRegistryValue

### 2. `ad-exercise-creator`
- **Función**: Genera ejercicios prácticos basados en labs existentes
- **Output**: Archivos .md con ejercicios + scripts de verificación .ps1
- **Niveles**: Débutant (guidé), Intermédiaire (tâches), Avancé (scénarios)
- **Características clave**:
  - Scripts de verificación automática con feedback colorido
  - Soluciones completas (GUI + PowerShell)
  - Enfoque en el prefijo `GG-` obligatorio
  - OUs siempre sin protección de borrado
  - Escenarios realistas de negocio
  - **GPOs en ejercicios**: Consultar `.claude/gpo-reference.md` para configuración manual correcta

---

## 🔒 Reglas Críticas para GPOs

### ❌ PROHIBIDO - Set-GPRegistryValue para políticas estándar

**NUNCA usar `Set-GPRegistryValue` para configurar políticas de Windows estándar:**

```powershell
# ❌ MAL - Crea entradas inválidas "nom convivial introuvable"
Set-GPRegistryValue -Name "GPO" -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoControlPanel" -Type DWord -Value 1
Set-GPRegistryValue -Name "GPO" -Key "HKLM\Software\Policies\Microsoft\Windows\RemovableStorageDevices\{53f56...}" -ValueName "Deny_Write" -Type DWord -Value 1
```

**Causa:** Estas claves de registro NO son políticas ADMX válidas y aparecen como errores en GPMC.

### ✅ CORRECTO - Crear GPO Shell + Instrucciones Manuales

```powershell
# ✅ BIEN - Crear GPO vacía con instrucciones claras
$gpoName = "CompanyName - Purpose"
New-GPO -Name $gpoName -Comment "Description claire"
New-GPLink -Name $gpoName -Target "OU=Users,OU=Dept,DC=domain,DC=com" -LinkEnabled Yes

Write-Host "`n⚠️  Configuration manuelle requise dans GPMC:" -ForegroundColor Yellow
Write-Host "  📍 User Configuration > Policies > Administrative Templates > Control Panel" -ForegroundColor Gray
Write-Host "  📝 Prohibit access to Control Panel and PC settings = Enabled" -ForegroundColor White
Write-Host "`n✅ Vérification:" -ForegroundColor Cyan
Write-Host "  1. Connectez-vous avec un utilisateur du département" -ForegroundColor Gray
Write-Host "  2. Exécutez: gpupdate /force" -ForegroundColor Gray
Write-Host "  3. Essayez d'ouvrir le Panneau de configuration (doit être bloqué)" -ForegroundColor Gray
```

### 📋 Políticas Válidas por PowerShell

**Solo estas pueden configurarse via PowerShell:**

1. **Password Policies (Domain-level)**:
   ```powershell
   Set-ADDefaultDomainPasswordPolicy -Identity "domain.com" -MinPasswordLength 12 -ComplexityEnabled $true
   ```

2. **Audit Policies**:
   ```powershell
   auditpol /set /subcategory:"Logon" /success:enable /failure:enable
   ```

3. **Custom Registry Settings** (NO estándar Windows):
   ```powershell
   # Solo para aplicaciones custom, NO para políticas Windows
   Set-GPRegistryValue -Name "GPO" -Key "HKLM\Software\MyCompanyApp\Settings" -ValueName "CustomSetting" -Type String -Value "Value"
   ```

### 🎓 GPOs Recomendadas para Labs Educativos

Consultar `.claude/gpo-reference.md` sección "Educational Lab GPO Recommendations" para:
- Listado completo de GPOs seguras para labs
- Rutas exactas de configuración manual
- Métodos de verificación para estudiantes
- Templates de código con instrucciones paso a paso

**Regla de oro:** Si no está en `gpo-reference.md` como "PowerShell Supported", crear solo el shell y dar instrucciones manuales.
