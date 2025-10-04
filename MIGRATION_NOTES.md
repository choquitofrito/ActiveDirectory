# Notas de Migración - Laboratorios Active Directory

**Fecha**: 2025-10-04
**Origen**: `/home/bender/Documents/Trabajo/Cursos-Estudio/H2EB/Labos/`
**Destino**: `/home/bender/Documents/Trabajo/Cursos-Estudio/H2EB/ActiveDirectory/`

## Resumen Ejecutivo

Esta sesión creó un sistema completo de generación automatizada de laboratorios Active Directory para cursos de formación, incluyendo:

1. **2 agentes especializados** configurados en `.claude/agents/`
2. **1 laboratorio completo** (CreativeHub) con 18 usuarios, 4 departamentos, 8 grupos, 3 GPOs
3. **9 ejercicios progresivos** con scripts de verificación automática
4. **Documentación completa** en francés para estudiantes e instructores

---

## Archivos Creados en Esta Sesión

### 1. Agentes Claude (`.claude/agents/`)

#### `ad-lab-creator.md`
- **Función**: Genera scripts PowerShell para crear estructuras AD completas
- **Output**: Scripts .ps1, cleanup scripts, documentación README
- **Características clave**:
  - Scripts idempotentes (re-ejecutables sin errores)
  - Confirmación paso a paso interactiva
  - TODAS las OUs con `-ProtectedFromAccidentalDeletion $false`
  - TODOS los grupos globales con prefijo `GG-` (MANDATORY)
  - Exportación CSV automática
  - Comentarios y mensajes en francés

#### `ad-exercise-creator.md`
- **Función**: Genera ejercicios prácticos basados en labs existentes
- **Output**: Archivos .md con ejercicios + scripts de verificación .ps1
- **Niveles**: Débutant (guidé), Intermédiaire (tâches), Avancé (scénarios)
- **Características clave**:
  - Scripts de verificación automática con feedback colorido
  - Soluciones completas (GUI + PowerShell)
  - Enfoque en el prefijo `GG-` obligatorio
  - OUs siempre sin protección de borrado
  - Escenarios realistas de negocio

### 2. Laboratorio CreativeHub

#### Estructura del Lab
```
LaboExtra1-CreativeHUB/
├── CreativeHub_Setup.ps1           (Script principal - 507 líneas)
├── CreativeHub_Cleanup.ps1         (Script de limpieza - 243 líneas)
├── README_CreativeHub.md           (Documentación completa)
├── INDEX_EXERCICES.md              (Índice de ejercicios)
├── Guide_Instructeur_Exercices.md  (Guía del instructor)
├── Exercice_01_Nouvel_Employe.md
├── Exercice_02_Depart_Employe.md
├── Exercice_03_GPO_Lecteur_Reseau.md
├── Exercice_04_Groupe_Projet_Client.md
├── Exercice_05_Reset_Password.md
├── Exercice_06_Delegation_Controle.md
├── Exercice_07_Scenario_Onboarding_Complet.md
├── Exercice_08_Troubleshooting_GPO.md
├── Exercice_09_Scenario_Crise_Securite.md
├── verif_exercice_01.ps1
├── verif_exercice_02.ps1
├── verif_exercice_03.ps1
├── verif_exercice_04.ps1
├── verif_exercice_05.ps1
├── verif_exercice_06.ps1
├── verif_exercice_07.ps1
├── verif_exercice_08.ps1
└── verif_exercice_09.ps1
```

#### Escenario del Lab: Agence CreativeHub
- **Tipo**: Agencia de marketing digital y diseño
- **Razón de elección**: Realista, atractivo, fácil de entender para principiantes
- **Estructura AD**:
  - 1 OU raíz: `OU=CreativeHub,DC=maxtec,DC=be`
  - 4 departamentos: Marketing, Creative, ClientServices, ITSupport
  - 12 sub-OUs (Users, Computers, Groups por departamento)
  - 18 usuarios con nombres franceses y roles realistas
  - 8 grupos de seguridad: `GG-CreativeHub-[Dept]-Users` y `GG-CreativeHub-[Dept]-Admin`
  - 3 GPOs:
    1. Restricciones para usuarios juniors (Panneau config + CMD desactivados)
    2. Bloqueo USB para Client Services (protección datos sensibles)
    3. Mapeo de lectores de red compartidos

#### Usuarios Creados (18 total)

**Marketing** (5):
- amelie - Amélie Dubois - Community Manager
- bastien - Bastien Martin - Spécialiste SEO
- camille - Camille Bernard - Responsable Marketing Digital
- damien - Damien Petit - Content Strategist
- elise - Élise Robert - Social Media Analyst

**Creative** (5):
- fabien - Fabien Moreau - Graphiste Senior
- gabrielle - Gabrielle Simon - Directrice Artistique
- hugo - Hugo Laurent - Motion Designer
- ines - Inès Lefebvre - Vidéaste
- julien - Julien Roux - Designer UX/UI

**Client Services** (4):
- karine - Karine Garnier - Chef de Projet Senior
- laurent - Laurent Faure - Account Manager
- manon - Manon Girard - Chef de Projet Junior
- nicolas - Nicolas André - Directeur des Opérations

**IT Support** (4):
- olivier - Olivier Mercier - Développeur Web Full-Stack
- pauline - Pauline Blanc - Administratrice Systèmes
- quentin - Quentin Guerin - Développeur Front-End
- rachid - Rachid Dupont - Responsable IT

**Contraseña por defecto**: `Password1!`

### 3. Ejercicios Generados (9 ejercicios progresivos)

#### Nivel Débutant (3 ejercicios)
1. **Nouvel Employé** - Crear usuario y añadirlo a grupos
2. **Départ Employé** - Desactivar cuenta y gestionar salida
3. **GPO Lecteur Réseau** - GPO de mapeo de unidades de red

#### Nivel Intermédiaire (3 ejercicios)
4. **Groupe Projet Client** - Crear grupo de seguridad multi-departamental
5. **Reset Password** - Incidente de seguridad (reseteo de contraseñas)
6. **Délégation Contrôle** - Delegación de control AD

#### Nivel Avancé (3 ejercicios)
7. **Scenario Onboarding Complet** - Onboarding completo de un pasante
8. **Troubleshooting GPO** - Diagnóstico GPO que no se aplica
9. **Scenario Crise Sécurité** - Gestión de crisis (cuenta admin comprometida)

**Cada ejercicio incluye**:
- Objetivos pedagógicos claros
- Contexto/escenario realista
- Instrucciones (detalladas para débutant, vagas para avancé)
- Comandos PowerShell de verificación
- Script de verificación automatizado (`verif_exercice_XX.ps1`)
- Solución completa (GUI + PowerShell)
- Tabla de troubleshooting

---

## Configuraciones Críticas Aplicadas

### 1. Prefijo GG- OBLIGATORIO para Grupos Globales

**Modificado en**:
- `ad-lab-creator.md` (líneas 218, 223, 469, 495-500)
- `ad-exercise-creator.md` (líneas 59, 63, 300, 321)

**Razón**: Convención de nombres estándar en AD (GG = Global Group)

**Ejemplo**: `GG-CreativeHub-Marketing-Users`, `GG-CreativeHub-IT-Admin`

### 2. TODAS las OUs sin Protección de Borrado

**Modificado en**:
- `ad-lab-creator.md` (línea 208)
- `ad-exercise-creator.md` (líneas 69-70, 153-154, 266-272, 313)

**Sintaxis obligatoria**:
```powershell
New-ADOrganizationalUnit -Name "NomOU" -Path "DC=maxtec,DC=be" -ProtectedFromAccidentalDeletion $false
```

**Razón**: Permitir que los scripts de cleanup funcionen sin errores

**Verificado en CreativeHub_Setup.ps1**:
- Línea 118: OU raíz ✓
- Línea 139: OUs departamentales ✓
- Línea 150: Sub-OUs ✓

### 3. Documentación en Francés

**Todo el contenido en francés**:
- Comentarios en scripts PowerShell
- Mensajes de salida (Write-Host)
- Ejercicios para estudiantes
- Documentación README
- Prompts de confirmación

**Razón**: Curso dirigido a estudiantes francófonos

### 4. Scripts Idempotentes

**Funciones de verificación creadas**:
```powershell
Test-OUExists
Test-UserExists
Test-GroupExists
Test-GPOExists
```

**Patrón usado**:
```powershell
if (Test-UserExists $samAccountName) {
    Write-Host "existe déjà" -ForegroundColor Yellow
} else {
    New-ADUser ...
    Write-Host "créé avec succès" -ForegroundColor Green
}
```

**Razón**: Permitir re-ejecución sin errores (útil para debugging y práctica)

---

## Decisiones de Diseño Pedagógico

### Público Objetivo
- **Nivel**: Principiantes (4 días / 28 horas de formación AD)
- **Background**: Algunos sin conocimientos técnicos previos
- **Idioma**: Francés

### Infraestructura del Lab
- 1 Windows Server 2022 (DC con AD DS instalado)
- 2 Windows Clients (unidos al dominio)
- Dominio: `maxtec.be`
- Ejecución: PowerShell ISE en el DC

### Enfoque de Enseñanza
1. **Script automatizado crea estructura base** (ad-lab-creator)
2. **Estudiantes practican manualmente** con ejercicios (ad-exercise-creator)
3. **Verificación automatizada** con feedback inmediato
4. **Progresión gradual**: Guidé → Tâches → Scénarios

### Por qué "Agencia CreativeHub"
- ✅ Realista y comprensible
- ✅ Roles conocidos (diseñador, community manager, etc.)
- ✅ Necesidades de seguridad claras (datos de clientes, proyectos)
- ✅ Atractivo para estudiantes (contexto moderno)
- ✅ Permite GPOs interesantes (restricciones USB, mapeo de drives)

---

## Próximos Pasos para Migración

### Archivos a Copiar

```bash
# Desde: /home/bender/Documents/Trabajo/Cursos-Estudio/H2EB/Labos/
# Hacia: /home/bender/Documents/Trabajo/Cursos-Estudio/H2EB/ActiveDirectory/

# 1. Agentes
.claude/agents/ad-lab-creator.md
.claude/agents/ad-exercise-creator.md

# 2. Laboratorio completo
LaboExtra1-CreativeHUB/  (todo el directorio)

# 3. Este documento
MIGRATION_NOTES.md
```

### Integración en MkDocs

**Preguntas para resolver**:

1. **Estructura de carpetas**:
   - ¿Crear `docs/labs/` para todos los laboratorios?
   - ¿O `docs/labs/creativehub/` específicamente?
   - ¿Los ejercicios van dentro del lab o separados en `docs/exercices/`?

2. **Organización en mkdocs.yml**:
   - ¿Cómo está organizado el lab existente?
   - ¿Hay una sección "Laboratories" o "Travaux Pratiques"?
   - ¿Los ejercicios se listan por nivel o por tema?

3. **Scripts PowerShell**:
   - ¿Dónde guardar los .ps1? (¿`scripts/labs/creativehub/`?)
   - ¿Incluirlos en la documentación con código embebido?
   - ¿O enlaces de descarga?

4. **Naming convention**:
   - ¿Renombrar "LaboExtra1-CreativeHUB" a algo más estándar?
   - Sugerencia: `lab-01-creativehub` o `tp-01-agence-creative`

5. **Índice y navegación**:
   - ¿Crear un `index.md` para cada lab?
   - ¿O integrar en un índice general de labs?

### Propuesta de Estructura (Pendiente de Validación)

```
ActiveDirectory/
├── docs/
│   ├── index.md                     (ya existe - actualizar con nuevo lab)
│   ├── labs/
│   │   ├── index.md                 (índice de todos los labs)
│   │   ├── lab-existente/           (lab actual)
│   │   └── lab-01-creativehub/
│   │       ├── README.md            (README_CreativeHub.md renombrado)
│   │       ├── setup.md             (instrucciones de setup)
│   │       ├── structure.md         (descripción de la estructura AD)
│   │       └── exercices/
│   │           ├── index.md         (INDEX_EXERCICES.md adaptado)
│   │           ├── guide-instructeur.md
│   │           ├── 01-nouvel-employe.md
│   │           ├── 02-depart-employe.md
│   │           ├── ... (9 ejercicios)
│   ├── scripts/
│   │   └── creativehub/
│   │       ├── CreativeHub_Setup.ps1
│   │       ├── CreativeHub_Cleanup.ps1
│   │       └── verification/
│   │           ├── verif_exercice_01.ps1
│   │           └── ... (9 scripts)
│   └── ...
├── .claude/
│   └── agents/
│       ├── ad-lab-creator.md
│       └── ad-exercise-creator.md
└── mkdocs.yml                       (actualizar navegación)
```

### Cambios Necesarios en mkdocs.yml (Ejemplo)

```yaml
nav:
  - Accueil: index.md
  - Cours:
      - ... (contenido existente)
  - Laboratoires:
      - Introduction: labs/index.md
      - Lab Existente: labs/lab-existante/...
      - CreativeHub (Agence Marketing):
          - Vue d'ensemble: labs/lab-01-creativehub/README.md
          - Installation: labs/lab-01-creativehub/setup.md
          - Structure AD: labs/lab-01-creativehub/structure.md
          - Exercices:
              - Index: labs/lab-01-creativehub/exercices/index.md
              - Guide Instructeur: labs/lab-01-creativehub/exercices/guide-instructeur.md
              - Débutant:
                  - Ex01 - Nouvel Employé: labs/lab-01-creativehub/exercices/01-nouvel-employe.md
                  - Ex02 - Départ Employé: labs/lab-01-creativehub/exercices/02-depart-employe.md
                  - Ex03 - GPO Lecteur Réseau: labs/lab-01-creativehub/exercices/03-gpo-lecteur.md
              - Intermédiaire:
                  - Ex04 - Groupe Projet: labs/lab-01-creativehub/exercices/04-groupe-projet.md
                  - Ex05 - Reset Password: labs/lab-01-creativehub/exercices/05-reset-password.md
                  - Ex06 - Délégation: labs/lab-01-creativehub/exercices/06-delegation.md
              - Avancé:
                  - Ex07 - Onboarding Complet: labs/lab-01-creativehub/exercices/07-onboarding.md
                  - Ex08 - Troubleshooting GPO: labs/lab-01-creativehub/exercices/08-troubleshooting-gpo.md
                  - Ex09 - Crise Sécurité: labs/lab-01-creativehub/exercices/09-crise-securite.md
  - Scripts:
      - CreativeHub Setup: scripts/creativehub/setup.md
      - CreativeHub Cleanup: scripts/creativehub/cleanup.md
```

---

## Información Técnica Adicional

### Dominio
- **Nombre**: `maxtec.be`
- **DN Base**: `DC=maxtec,DC=be`

### Convenciones de Nombres

**OUs**:
- Raíz: `OU=CreativeHub,DC=maxtec,DC=be`
- Departamentos: `OU=[Dept],OU=CreativeHub,DC=maxtec,DC=be`
- Sub-OUs: `OU=[Users|Computers|Groups],OU=[Dept],OU=CreativeHub,DC=maxtec,DC=be`

**Usuarios**:
- SamAccountName: minúsculas (ej: `amelie`, `bastien`)
- Email: `[samaccountname]@maxtec.be`
- DisplayName: Nombre completo (ej: "Amélie Dubois")

**Grupos**:
- Pattern: `GG-CreativeHub-[Dept]-[Users|Admin]`
- Scope: Global
- Category: Security

**GPOs**:
- Pattern: `CreativeHub - [Descripción]`
- Ejemplos:
  - `CreativeHub - Restrictions Utilisateurs Juniors`
  - `CreativeHub - Blocage USB Client Services`
  - `CreativeHub - Lecteurs Réseau Partagés`

### Scripts de Verificación

**Patrón de output**:
```
========================================
Vérification Exercice [Number]
========================================

Test 1: [Description]
  ✓ RÉUSSI          (verde)
  ✗ ÉCHOUÉ: [Raison] (rojo)

Test 2: ...

========================================
EXERCICE RÉUSSI! Tous les critères sont satisfaits.
========================================
```

### Exports CSV Generados

El script setup genera automáticamente:
- `C:\Labos\CreativeHub_Utilisateurs.csv`
- `C:\Labos\CreativeHub_Groupes.csv`
- `C:\Labos\CreativeHub_OUs.csv`

---

## Comandos Útiles de Verificación

```powershell
# Verificar OUs creadas
Get-ADOrganizationalUnit -Filter * -SearchBase "OU=CreativeHub,DC=maxtec,DC=be" |
    Select-Object Name, DistinguishedName

# Verificar usuarios
Get-ADUser -Filter * -SearchBase "OU=CreativeHub,DC=maxtec,DC=be" |
    Select-Object Name, SamAccountName, EmailAddress, Department

# Verificar grupos y miembros
Get-ADGroup -Filter "Name -like 'GG-CreativeHub*'" | ForEach-Object {
    Write-Host "Groupe: $($_.Name)" -ForegroundColor Cyan
    Get-ADGroupMember -Identity $_.Name | Select-Object Name, SamAccountName
}

# Verificar GPOs
Get-GPO -All | Where-Object {$_.DisplayName -like "CreativeHub*"} |
    Select-Object DisplayName, GpoStatus

# Verificar que OUs NO estén protegidas
Get-ADOrganizationalUnit -Filter * -SearchBase "OU=CreativeHub,DC=maxtec,DC=be" -Properties ProtectedFromAccidentalDeletion |
    Select-Object Name, ProtectedFromAccidentalDeletion
# Resultado esperado: TODAS con $false
```

---

## Troubleshooting del Lab

### Problema: "No existe relación de confianza con el servidor"

**Causa común**: Cliente perdió sincronización con DC

**Diagnóstico (desde el cliente)**:
```powershell
# Verificar dominio actual
(Get-WmiObject Win32_ComputerSystem).Domain

# Verificar DNS
nslookup maxtec.be
ping maxtec.be

# Verificar sincronización de tiempo (Kerberos requiere <5 min diferencia)
w32tm /query /status

# Probar relación de confianza
Test-ComputerSecureChannel -Verbose
```

**Solución**:
```powershell
# Opción 1: Reparar
Test-ComputerSecureChannel -Repair -Credential (Get-Credential)

# Opción 2: Re-unir al dominio
Remove-Computer -UnjoinDomainCredential (Get-Credential) -Restart
# Después del reinicio:
Add-Computer -DomainName maxtec.be -Credential (Get-Credential) -Restart
```

### Problema: GPOs no se aplican

```powershell
# Forzar actualización de GPO en el cliente
gpupdate /force

# Ver GPOs aplicadas
gpresult /r

# Ver en detalle (genera HTML)
gpresult /h C:\gpo_report.html

# Verificar herencia en OU
Get-GPInheritance -Target "OU=Users,OU=Marketing,OU=CreativeHub,DC=maxtec,DC=be"
```

### Problema: Script de cleanup falla

**Causa**: OUs con protección de borrado accidental

**Solución**: El cleanup script ya incluye esto:
```powershell
Set-ADOrganizationalUnit -Identity $_ -ProtectedFromAccidentalDeletion $false
```

Si falla, ejecutar manualmente:
```powershell
Get-ADOrganizationalUnit -Filter * -SearchBase "OU=CreativeHub,DC=maxtec,DC=be" |
    Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion $false
```

---

## Recursos de Referencia

### Documentación Microsoft Consultada

Scripts generados con referencias a:
- https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-adorganizationalunit?view=windowsserver2022-ps
- https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-aduser?view=windowsserver2025-ps
- https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-adgroup?view=windowsserver2022-ps
- https://learn.microsoft.com/en-us/powershell/module/grouppolicy/new-gpo?view=windowsserver2022-ps
- https://learn.microsoft.com/en-us/powershell/module/grouppolicy/set-gpregistryvalue?view=windowsserver2022-ps
- https://learn.microsoft.com/en-us/powershell/module/grouppolicy/new-gplink?view=windowsserver2022-ps

### Agentes Claude

Ambos agentes configurados para:
- Investigar documentación oficial antes de generar código
- Verificar sintaxis PowerShell
- Citar fuentes en comentarios de scripts

---

## Notas Finales

### Estado Actual
✅ Agentes configurados y probados
✅ Laboratorio CreativeHub generado completamente
✅ 9 ejercicios con scripts de verificación creados
✅ Toda la documentación en francés
✅ Scripts verificados (OUs sin protección, prefijo GG-)

### Pendiente
⏳ Migración a `/home/bender/Documents/Trabajo/Cursos-Estudio/H2EB/ActiveDirectory/`
⏳ Integración en mkdocs.yml
⏳ Reorganización de estructura de docs/
⏳ Pruebas del laboratorio en entorno real
⏳ Generación de labs adicionales con los agentes

### Contacto de Continuación

Para continuar, abrir Claude Code en:
```
/home/bender/Documents/Trabajo/Cursos-Estudio/H2EB/ActiveDirectory/
```

Con este documento `MIGRATION_NOTES.md` como referencia completa.

---

**Generado**: 2025-10-04
**Sesión**: Creación de sistema de laboratorios AD automatizados
**Archivos totales generados**: ~25 archivos (2 agentes + 1 lab completo con docs y scripts)
