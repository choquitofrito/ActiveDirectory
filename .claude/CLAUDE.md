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
