# Prompt para Claude Code - Curso PowerShell para Active Directory

## Instrucciones de uso
Copia este prompt completo y pégalo en Claude Code para generar todos los archivos del curso.

---

## PROMPT:

Necesito crear un curso completo de PowerShell para Active Directory para principiantes absolutos. El curso dura 10 horas (2 días de 5 horas). Los estudiantes solo conocen fundamentos básicos de redes y vienen de 3 días de teoría de AD.


### FILOSOFÍA DEL CURSO:
- PowerShell como herramienta de administración, NO programación
- Enfoque en leer/validar scripts de IA más que escribirlos desde cero
- Ultra-práctico: solo lo que usarán en el trabajo real
- Honesto sobre el uso de IA en 2025
- Progresión muy gradual desde lo más simple
- "Aprender del desastre": mostrar qué puede salir mal

### ESTRUCTURA DE ARCHIVOS A GENERAR:

```
/curso-powershell-ad/
├── README.md (índice general y guía del instructor con timing detallado)
├── prerrequisitos.md (checklist de preparación + troubleshooting común)
├── dia1/
│   ├── 00-setup-ambiente.md (30 min - configuración + verificación)
│   ├── 01-que-es-powershell.md (1h - conceptos con analogías simples)
│   ├── 02-primeros-comandos.md (1h - Get-Date, whoami, con OUTPUT real)
│   ├── 03-comandos-ad-basicos.md (1.5h - los 5 cmdlets esenciales)
│   ├── 04-lab-busquedas-simples.md (1h - ejercicios copy-paste permitido)
│   ├── 05-exportar-informacion.md (1h - CSV, Excel, formato de salida)
│   └── dia1-resumen-visual.md (infografía de comandos del día)
├── dia2/
│   ├── 06-lectura-scripts.md (1h - decodificar línea por línea)
│   ├── 07-whatif-seguridad.md (1h - simulacros de desastre)
│   ├── 08-casos-reales.md (1.5h - los 10 tickets más comunes)
│   ├── 09-powershell-con-ia.md (1h - prompts y validación)
│   ├── 10-lab-encuentra-errores.md (1h - scripts con bombas ocultas)
│   ├── 11-kit-supervivencia.md (30 min - cuando todo falla)
│   └── dia2-resumen-visual.md
├── labs/
│   ├── crear-ad-pruebas.ps1 (script comentado para generar AD de prueba)
│   ├── usuarios-ficticios.csv (100 usuarios realistas en español)
│   ├── lab-01-solucion.md (paso a paso con screenshots simulados)
│   ├── lab-02-solucion.md
│   ├── scripts-bomba/ 
│   │   ├── bomba1-borrado-masivo.ps1 (con ERROR línea 15)
│   │   ├── bomba2-loop-infinito.ps1 (con ERROR línea 8)
│   │   ├── bomba3-permisos-everyone.ps1 (con ERROR línea 22)
│   │   ├── bomba4-password-blank.ps1 (con ERROR línea 11)
│   │   └── bomba5-ou-incorrecta.ps1 (con ERROR línea 5)
│   └── respuestas-bombas.md (explicación de cada error)
├── materiales-alumno/
│   ├── tarjeta-bolsillo.md (comandos esenciales tamaño tarjeta)
│   ├── plantilla-validacion-scripts.md (checklist visual)
│   ├── prompts-ia-seguros.md (10 prompts copiables)
│   ├── glosario-terminos.md (diccionario PS-Español)
│   └── comandos-emergencia.md (break glass procedures)
├── casos-horror/
│   ├── historia1-viernes-5pm.md (caso real anonimizado)
│   ├── historia2-el-script-de-reddit.md (por qué no copiar de foros)
│   └── historia3-el-becario-root.md (la importancia de -WhatIf)
├── evaluacion/
│   ├── ejercicio-final.md (caso práctico: "Onboarding de 20 usuarios")
│   ├── rubrica-evaluacion.md (checklist de competencias)
│   └── certificado-plantilla.md (plantilla de certificación)
└── recursos-extra/
    ├── enlaces-utiles.md (documentación, foros, canales YouTube)
    ├── siguiente-paso.md (qué aprender después de este curso)
    └── troubleshooting-comun.md (50 errores y sus soluciones)
```

### CONTENIDO ESPECÍFICO POR ARCHIVO:

Para cada archivo .md del curso:

1. **TIEMPO REAL** en la esquina: "⏱️ 15-20 minutos"
2. **Objetivo SMART**: "Al terminar, podrás buscar cualquier usuario en AD"
3. **Sección "¿Por qué me importa?"**: caso real donde necesitarán esto
4. **Ejemplos con OUTPUT COMPLETO**:
   ```powershell
   PS C:\> Get-ADUser juan.perez
   
   DistinguishedName : CN=Juan Perez,OU=Ventas,DC=empresa,DC=local
   Enabled          : True
   Name             : Juan Perez
   SamAccountName   : juan.perez
   UserPrincipalName : juan.perez@empresa.local
   ```

5. **Recuadro "🔴 HISTORIA REAL"**: anécdota de qué pasó sin -WhatIf
6. **Ejercicio GUIADO**: paso 1, paso 2, verificación, troubleshooting
7. **Sección "Si algo sale mal"**: errores comunes con solución
8. **"Pregúntale a ChatGPT"**: prompt exacto para pedir ayuda

### EJEMPLOS PROGRESIVOS:

```powershell
# Nivel 1: Lo más simple
Get-ADUser juan.perez

# Nivel 2: Un poco más
Get-ADUser juan.perez -Properties *

# Nivel 3: Uso real
Get-ADUser -Filter {Department -eq "Ventas"} | Export-Csv ventas.csv

# Nivel 4: Con seguridad
Get-ADUser -Filter * | Where {$_.Enabled -eq $false} | Disable-ADAccount -WhatIf
```

### ELEMENTOS VISUALES (describir en markdown):
- ✅ Comando seguro
- ⚠️ Comando con precaución  
- 🔴 Comando peligroso
- 💡 Tip profesional
- 🚨 Historia de horror real
- 🎯 Ejercicio práctico
- 🤖 Prompt para IA

### SCRIPTS BOMBA ESPECIFICACIÓN:

Cada script debe:

1. Parecer legítimo a primera vista
2. Tener comentarios que despisten
3. Contener 1-2 errores graves pero educativos
4. Incluir una línea como: # TODO: Revisar antes de producción
5. Los errores deben enseñar: sin -WhatIf, sin filtros, paths hardcodeados, sin try/catch, credenciales en claro

### MATERIALES IMPRESOS:

1. **Tarjeta de bolsillo** (10x6 cm):
   - Anverso: 10 comandos esenciales
   - Reverso: Sintaxis de -Filter y -WhatIf

2. **Checklist de validación** (A4):
   - 15 puntos de verificación con checkboxes
   - Sección "Si marcaste NO en alguno, NO EJECUTES"

3. **Prompts para IA** (A4):
   - 10 prompts probados para tareas comunes
   - Sección "Palabras mágicas": seguro, validar, -WhatIf, incremental

### CASOS DE HORROR (storytelling):

Cada historia debe:

- Ser anónima pero creíble
- Durar 2-3 minutos de lectura
- Tener moraleja clara
- Incluir: "Costo del error: [tiempo/dinero/trabajo]"
- Terminar con: "Cómo evitarlo: [técnica específica]"

### TONO Y PEDAGOGÍA:
- Primera persona plural: "Vamos a..." no "Debes..."
- Reconocer miedos: "Sí, da miedo al principio, es normal"
- Humor cuando sea apropiado: "PowerShell no muerde... pero Remove-ADUser sí"
- Refuerzo positivo: "Si entendiste esto, ya superas al 60% de admins"
- Admitir realidad: "Sí, yo también googleo la sintaxis cada vez"

### IMPORTANTE - DETALLES CRÍTICOS:
- El curso será integramente en francés
- Cada archivo debe ser 100% autocontenido
- Incluir outputs de error comunes y cómo interpretarlos
- Los CSVs de ejemplo deben tener acentos y ñ (datos hispanos)
- Tiempo de cada sección debe sumar EXACTAMENTE 10 horas
- Incluir breaks: "☕ Pausa de 10 minutos aquí"
- Para cada comando nuevo, mostrar Get-Help del mismo
- Versión de PowerShell: 5.1 (la más común en empresas)

Genera todos estos archivos con contenido completo, realista y pedagógicamente sólido. Cada archivo debe estar listo para usar mañana mismo en un aula real con estudiantes reales que tienen miedo de romper algo.

---

## Notas adicionales para el instructor:

- Este prompt está diseñado para generar ~30 archivos con contenido completo
- Tiempo estimado de generación: 5-10 minutos en Claude Code
- Puedes pedir archivos específicos si prefieres revisar por partes
- Si necesitas ajustar el nivel, especifica "más básico" o "más avanzado"
- Los scripts de prueba son seguros pero siempre revísalos antes de usar en producción