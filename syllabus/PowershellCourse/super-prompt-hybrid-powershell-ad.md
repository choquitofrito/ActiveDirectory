# Super Prompt Híbrido - Curso PowerShell AD Moderno para maxtec.be

## Contexto e Integración Existente

**IMPORTANTE**: Este prompt complementa y moderniza los capítulos 8.x existentes del syllabus. Los estudiantes ya han completado:
- 3 días de teoría AD (Capítulos 1-7)
- Configuración del laboratorio maxtec.be (dns1.maxtec.be, estructura OU completa)
- Capítulos 8.0-8.3: Conceptos base PowerShell AD (tradicionales)
- Usuarios ya creados: Richard, Irene, Ivan, Ines, Victor, Vanessa, etc.

## FILOSOFÍA REVOLUCIONARIA 2025

### Cambio de Paradigma
**DE**: "PowerShell como programación compleja para expertos"
**A**: "PowerShell como herramienta de supervivencia para admins reales en era IA"

### Principios Fundamentales
1. **Honestidad Total**: "Sí, yo también uso ChatGPT para recordar sintaxis"
2. **Lectura > Escritura**: Validar scripts de IA es más importante que escribir desde cero
3. **Supervivencia Real**: Solo comandos que usarán en tickets reales del lunes
4. **Aprender del Desastre**: Mostrar qué pasa cuando falta -WhatIf un viernes a las 17h
5. **Progresión Microscópica**: Desde `Get-Date` hasta scripts complejos en pasos de bebé

## ESTRUCTURA DE ARCHIVOS COMPLEMENTARIOS

```
/curso-powershell-ad-moderno/
├── README-INSTRUCTOR.md (timing detallado + integración con capítulos 8.x)
├── setup-post-teoria.md (configuración después de los capítulos existentes)
│
├── modulos-modernos/
│   ├── M1-realidad-2025.md (2h - "Cómo realmente trabajo con PS en 2025")
│   ├── M2-supervivencia-tickets.md (2h - Los 10 comandos que salvan carreras)
│   ├── M3-ia-como-copiloto.md (1.5h - Prompts seguros + validación crítica)
│   ├── M4-scripts-bomba-lab.md (2h - Encontrar errores mortales ocultos)
│   ├── M5-whatif-religioso.md (1.5h - Por qué -WhatIf es sagrado)
│   └── M6-kit-emergencia.md (1h - "Cuando todo explota un viernes")
│
├── laboratorio-maxtec/
│   ├── usuarios-realistas-maxtec.csv (datos hispanos con acentos)
│   ├── escenarios-tickets-reales.ps1 (casos del mundo real anonimizados)
│   ├── validacion-scripts-maxtec.ps1 (verificar estructura AD existente)
│   └── scripts-bomba-maxtec/
│       ├── bomba1-remove-all-users.ps1 (ERROR línea 18: sin filtro específico)
│       ├── bomba2-move-ou-incorrect.ps1 (ERROR línea 11: path hardcodeado)
│       ├── bomba3-password-in-clear.ps1 (ERROR línea 7: credenciales en claro)
│       ├── bomba4-infinite-loop-groups.ps1 (ERROR línea 15: sin break condition)
│       └── bomba5-production-friday.ps1 (ERROR línea 23: sin -WhatIf)
│
├── casos-horror-reales/
│   ├── viernes-17h-sin-whatif.md (El becario que borró Ventas)
│   ├── script-de-reddit-maxtec.md (Por qué no copiar código de foros)
│   ├── loop-infinito-ou.md (El servidor que se quedó sin memoria)
│   ├── credenciales-en-slack.md (El screenshot que costó un trabajo)
│   └── backup-que-no-era.md (Restauración de 72 horas un domingo)
│
├── materiales-bolsillo/
│   ├── tarjeta-supervivencia-maxtec.md (10x6cm - comandos vitales)
│   ├── checklist-validacion-scripts.md (A4 - 20 puntos críticos)
│   ├── prompts-ia-seguros.md (15 prompts probados + palabras mágicas)
│   ├── interpretacion-errores.md (50 errores comunes traducidos)
│   └── comandos-panico.md (break glass procedures)
│
├── evaluacion-practica/
│   ├── examen-ticket-real.md (Onboarding 25 usuarios nuevos)
│   ├── simulacro-desastre.md (Recuperar de script bomba ejecutado)
│   ├── rubrica-mundo-real.md (competencias laborales reales)
│   └── certificacion-supervivencia.md (template con firma digital)
│
└── recursos-expansion/
    ├── siguiente-nivel-ps.md (Exchange, Azure, advanced scripting)
    ├── comunidades-utiles.md (Discord, Reddit, Stack Overflow)
    ├── canales-youtube-espanol.md (creadores hispanos recomendados)
    └── troubleshooting-por-empresa.md (errores específicos por sector)
```

## INTEGRACIÓN CON INFRAESTRUCTURA EXISTENTE

### Dominio y Usuarios Base (YA EXISTENTES en maxtec.be)
```
- Dominio: maxtec.be
- DC: dns1.maxtec.be (192.168.0.2)
- Estructura OU: OU=EU,DC=maxtec,DC=be
  ├── OU=IT (Ivan, Ines, Irene)
  ├── OU=Ventes (Victor, Vanessa, Valeria, Valentin)
  ├── OU=RH (Rene, Rebecca, Richard)
  └── OU=Compta (Charles, Cindy, Charlotte)
```

### Grupos Existentes (USAR EN EJEMPLOS)
- GG-EU-IT-Users, GG-EU-IT-Admins
- GG-EU-Ventes-Users, GG-EU-Ventes-Admins
- GG-EU-RH-Users, GG-EU-RH-Admins
- GG-EU-Compta-Users, GG-EU-Compta-Admins

## CONTENIDO ESPECÍFICO POR MÓDULO

### M1: Realidad 2025 (2h - Post capítulos 8.x)
**Timing**: ⏱️ 2 horas exactas
**Prerrequisito**: Haber completado capítulos 8.0-8.3
**Objetivo SMART**: "Al terminar, entenderás cómo trabajan los admins PS reales en 2025"

**Contenido revolucionario**:
1. **Sección "Confesiones de un Admin Real"**:
   - "Sí, uso ChatGPT para recordar sintaxis"
   - "90% del tiempo leo scripts, 10% escribo desde cero"
   - "Get-Help es mi mejor amigo, no mi vergüenza"

2. **Demo en vivo con maxtec.be**:
   ```powershell
   # Lo que realmente hago lunes por la mañana:
   Get-ADUser -Filter * -SearchBase "OU=IT,OU=EU,DC=maxtec,DC=be" -Properties LastLogonDate |
   Where-Object {$_.LastLogonDate -lt (Get-Date).AddDays(-7)} |
   Select-Object Name, LastLogonDate
   ```

3. **🔴 HISTORIA REAL**: "El admin que fingía saber PowerShell"
   - Costo del error: 3 días de trabajo manual
   - Moraleja: La honestidad acelera el aprendizaje

### M2: Supervivencia Tickets (2h)
**Los 10 comandos que salvan carreras profesionales**

Para cada comando, estructura fija:
- ✅ Comando seguro para producción
- ⚠️ Versión con precaución
- 🔴 Versión peligrosa (NUNCA hacer)
- 💡 Tip de supervivencia
- 🎯 Ejercicio con usuarios maxtec.be

**Ejemplo de estructura**:
```markdown
#### Comando 2: Buscar usuario por nombre parcial

✅ **SEGURO**:
```powershell
Get-ADUser -Filter {GivenName -like "Ire*"} -SearchBase "OU=EU,DC=maxtec,DC=be"
```

⚠️ **PRECAUCIÓN**:
```powershell
Get-ADUser -Filter {Name -like "*Ire*"} -Properties *
# Puede ser lento con muchos usuarios
```

🔴 **PELIGROSO - NUNCA**:
```powershell
Get-ADUser -Filter * -Properties * | Where-Object {$_.Name -match ".*"}
# Carga TODOS los usuarios con TODAS las propiedades
```

💡 **TIP SUPERVIVENCIA**: Siempre usa -SearchBase para limitar el scope

🎯 **EJERCICIO MAXTEC**: Encuentra todos los usuarios del departamento IT cuyo nombre empiece por "I"
```

### M3: IA como Copiloto (1.5h)
**"ChatGPT es tu amigo, pero TÚ eres el piloto"**

**Prompts seguros probados**:
```
1. "Crea un script PowerShell para buscar usuarios AD inactivos,
   INCLUYE -WhatIf, validación de errores y comentarios explicativos"

2. "Modifica este script para que sea seguro en producción:
   [PEGAR SCRIPT]. Agrega validaciones y -WhatIf donde corresponda"

3. "Explica línea por línea qué hace este script de AD y
   identifica posibles riesgos: [PEGAR SCRIPT]"
```

**Palabras mágicas para IA**:
- "seguro en producción"
- "incluye -WhatIf"
- "valida errores"
- "incremental no masivo"
- "explica riesgos"

### M4: Scripts Bomba Lab (2h)
**"Aprende a detectar minas terrestres antes de que exploten"**

Cada script bomba tiene:
- Aspecto legítimo a primera vista
- Comentarios que despistan
- 1-2 errores educativos ocultos
- Línea: `# TODO: Revisar antes de producción`

**Bomba1-remove-all-users.ps1** (snippet):
```powershell
# Script para limpiar cuentas de usuarios inactivos
# Autor: Admin Senior (confiable)
# Fecha: 2024-12-15

Import-Module ActiveDirectory

# Obtener usuarios inactivos (última conexión > 90 días)
$dateLimite = (Get-Date).AddDays(-90)
$usuariosInactivos = Get-ADUser -Filter * -Properties LastLogonDate |
    Where-Object {$_.LastLogonDate -lt $dateLimite}

Write-Host "Encontrados $($usuariosInactivos.Count) usuarios inactivos"

# TODO: Revisar antes de producción
foreach ($usuario in $usuariosInactivos) {
    Write-Host "Eliminando usuario: $($usuario.Name)"
    Remove-ADUser -Identity $usuario.SamAccountName -Confirm:$false
    # ☢️ ERROR OCULTO: Sin -WhatIf, sin validación de grupos críticos
}
```

### M5: -WhatIf Religioso (1.5h)
**"Tratamos -WhatIf como artículo de fe"**

**Estructura de contenido**:
1. **🚨 Historia de Horror**: "El viernes sin -WhatIf"
2. **Demostraciones dramáticas**:
   ```powershell
   # ☠️ NUNCA ejecutar (solo mostrar)
   Get-ADUser -Filter * | Remove-ADUser -Confirm:$false

   # ✅ SIEMPRE empezar así
   Get-ADUser -Filter * | Remove-ADUser -WhatIf
   ```
3. **Comandos que SIEMPRE necesitan -WhatIf**:
   - Remove-*
   - Set-* (cambios masivos)
   - Move-*
   - Disable-*

### M6: Kit Emergencia (1h)
**"Cuando todo explota un viernes a las 17h"**

**Procedures "break glass"**:
```markdown
🚨 EMERGENCY CHECKLIST 🚨

□ 1. RESPIRAR (literalmente, cuenta hasta 10)
□ 2. NO ejecutar nada más hasta entender el problema
□ 3. Documentar QUÉ se ejecutó exactamente
□ 4. Verificar backups disponibles
□ 5. Contactar supervisor ANTES de intentar "arreglar"

COMANDOS DE DIAGNÓSTICO RÁPIDO:
```powershell
# Estado del dominio
Get-ADDomain | Select-Object DNSRoot, DomainMode

# Últimas modificaciones (buscar el desastre)
Get-WinEvent -LogName "Security" -MaxEvents 50 |
Where-Object {$_.Id -eq 4728 -or $_.Id -eq 4729}
```
```

## CASOS HORROR ESPECIFICACIÓN DETALLADA

### Historia 1: "Viernes 17h sin -WhatIf"
```markdown
# 🚨 HISTORIA REAL: El Viernes Que Casi Acaba Una Carrera

**Contexto**: Viernes 16:45h, oficina vaciándose, deadline urgente
**Protagonist**: Admin junior con 6 meses experiencia
**Tarea**: "Desactivar las cuentas de los becarios que terminaron"

## Lo que debía pasar:
- Desactivar 5 cuentas específicas de becarios
- Verificar que no afecte a usuarios críticos
- Documentar cambios

## Lo que realmente pasó:
```powershell
# El script "inofensivo" copiado de un foro
Get-ADUser -Filter {Department -eq "Becarios"} | Disable-ADAccount
```

## El error catastrófico:
- El filtro no encontró exactamente "Becarios"
- Alguien había escrito "Becario" (singular) en algunos perfiles
- El script no desactivó a NADIE
- Luego intentó "arreglar" con:
```powershell
Get-ADUser -Filter {Title -like "*Becario*"} | Disable-ADAccount
```

## El desastre:
- Capturó también "Becario Senior" y "Ex-Becario"
- Desactivó al Director Financiero (título: "Ex-Becario, ahora Director")
- Desactivó a 3 desarrolladores seniors
- Sistema ERP perdió acceso
- Bloqueo de nóminas

## Costo real:
- **Tiempo**: 12 horas de restauración (fin de semana)
- **Dinero**: €15,000 en consultores externos urgentes
- **Reputación**: Reunión con RRHH, plan de mejora
- **Estrés**: Ataque de ansiedad, 2 semanas de baja

## Cómo evitarlo:
1. **SIEMPRE empezar con -WhatIf**:
   ```powershell
   Get-ADUser -Filter {Department -eq "Becarios"} | Disable-ADAccount -WhatIf
   ```
2. **Verificar ANTES**:
   ```powershell
   Get-ADUser -Filter {Department -eq "Becarios"} | Select-Object Name, Title, Department
   ```
3. **Filtros específicos**:
   ```powershell
   $becariosADesactivar = @("user1", "user2", "user3", "user4", "user5")
   $becariosADesactivar | ForEach-Object {
       Disable-ADAccount -Identity $_ -WhatIf
   }
   ```

**Moraleja**: -WhatIf no es opcional. Es supervivencia profesional.
```

## MATERIALES IMPRESOS ESPECÍFICOS

### Tarjeta de Bolsillo maxtec.be (10x6 cm)
**ANVERSO**:
```
🆘 SUPERVIVENCIA PS - maxtec.be 🆘

1. Get-ADUser -Identity [name] -Properties *
2. Get-ADUser -Filter * -SearchBase "OU=XX,OU=EU,DC=maxtec,DC=be"
3. Get-ADGroup -Filter {Name -like "GG-EU-*"}
4. Add-ADGroupMember -Identity [group] -Members [user] -WhatIf
5. Set-ADUser -Identity [user] -Enabled $false -WhatIf

🔴 NUNCA sin -WhatIf: Remove-*, Set-* masivo, Move-*
```

**REVERSO**:
```
SINTAXIS FILTROS:
-Filter {Propiedad -eq "Valor"}
-Filter {Propiedad -like "Val*"}
-Filter {Propiedad -ne "Valor"}

EMERGENCIA maxtec.be:
DC: dns1.maxtec.be
Base: OU=EU,DC=maxtec,DC=be
Backup Admin: richard@maxtec.be
```

## TIMING TOTAL Y CERTIFICACIÓN

**Duración total**: 10 horas exactas (complementa capítulos 8.x existentes)
- M1: Realidad 2025 (2h)
- M2: Supervivencia Tickets (2h)
- M3: IA como Copiloto (1.5h)
- ☕ Break 15 min
- M4: Scripts Bomba Lab (2h)
- M5: -WhatIf Religioso (1.5h)
- M6: Kit Emergencia (1h)

**Evaluación final**: Resolver ticket real simulado en maxtec.be con script bomba oculto

## INSTRUCCIONES DE GENERACIÓN

**CRÍTICO - Características de cada archivo**:

1. **Integración total**: Todos los ejemplos usan maxtec.be, usuarios existentes (Richard, Irene, etc.)

2. **Outputs reales**: Cada comando debe mostrar output completo simulado:
   ```powershell
   PS C:\> Get-ADUser -Identity Richard -Properties Department

   Department        : RH
   DistinguishedName : CN=Richard,OU=Users,OU=RH,OU=EU,DC=maxtec,DC=be
   Enabled           : True
   GivenName         : Richard
   Name              : Richard
   SamAccountName    : Richard
   Surname           :
   UserPrincipalName : Richard@maxtec.be
   ```

3. **Casos horror reales pero anónimos**: Inspirados en desastres reales, adaptados a maxtec.be

4. **Scripts bomba educativos**: Funcionales pero con errores pedagógicos específicos

5. **Tono revolucionario**: Directo, honesto, "cómplice". Ejemplos:
   - "Sí, Google es parte del toolkit profesional"
   - "No finjas que memorizas sintaxis, todos consultamos documentación"
   - "Tu trabajo es validar, no escribir desde cero"

6. **Progresión microscópica**: Cada concepto en pasos de bebé, con verificación

7. **Enlaces con capítulos existentes**: Referencias explícitas como "Como vimos en el capítulo 8.1..."

8. **Breaks explícitos**: "☕ Pausa de 10 minutos aquí - es obligatoria"

9. **Validación constante**: Cada ejercicio debe verificar que el comando funcionó

10. **Checklist de seguridad**: Antes de cada comando potencialmente peligroso

**RESULTADO ESPERADO**: 25-30 archivos markdown autocontenidos, listos para usar inmediatamente en aula real con estudiantes que vienen de completar los capítulos 8.x existentes.

Genera todos los archivos con contenido completo, realista y pedagógicamente revolucionario. Cada archivo debe respirar la filosofía 2025 de "supervivencia profesional con honestidad total".