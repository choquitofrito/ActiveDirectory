# Index des Exercices - Labo 3 : MonitoringLab

## MonitoringTech SPRL - Active Directory : Monitoring, Audit et Sécurité

**Domaine** : `maxtec.be`
**Niveau global** : Débutant à Avancé (progression sur 4 exercices guidés + 2 avancés)
**Durée totale estimée** : 7h00 - 7h30

---

## Vue d'Ensemble de la Progression

```
Exercice 01      Exercice 02      Exercice 03      Exercice 04      Exercice 05      Exercice 06
Débutant    -->  Débutant    -->  Intermédiaire --> Intermédiaire --> Avancé      --> Avancé
(Guidé)          (Guidé)          (Tâches)          (Tâches)          (Scénario)       (Forensique)
45 min           60 min           75 min            60 min            90 min           90 min
```

---

## Tableau de Bord des Exercices

| # | Titre | Niveau | Durée | Thème Principal | Script de Vérification |
|---|-------|--------|-------|-----------------|------------------------|
| 01 | Exploration de la Structure AD | Débutant (Guidé) | 45 min | Navigation ADUC + PowerShell de base | `verif_exercice_01.ps1` |
| 02 | Analyse des Événements de Sécurité | Débutant (Guidé) | 60 min | Observateur d'événements + Event IDs | `verif_exercice_02.ps1` |
| 03 | Configuration des GPOs | Intermédiaire | 75 min | GPMC + Politique mots de passe | `verif_exercice_03.ps1` |
| 04 | Gestion des Comptes de Service | Intermédiaire | 60 min | Comptes de service + groupes GG- | `verif_exercice_04.ps1` |
| 05 | Audit Personnalisé Finance | Avancé | 90 min | Audit NTFS + auditpol | `verif_exercice_05.ps1` |
| 06 | Investigation d'Incident | Avancé | 90 min | Forensique AD + remédiation | `verif_exercice_06.ps1` |

---

## Liens vers les Exercices

- [Exercice 01 - Exploration de la Structure AD](../exercices/Exercice_01_Exploration_Structure.md)
- [Exercice 02 - Analyse des Événements de Sécurité](../exercices/Exercice_02_Analyse_Evenements.md)
- [Exercice 03 - Configuration des GPOs](../exercices/Exercice_03_Configuration_GPOs.md)
- [Exercice 04 - Gestion des Comptes de Service](../exercices/Exercice_04_Comptes_Service.md)
- [Exercice 05 - Audit Personnalisé Finance](../exercices/Exercice_05_Audit_Personnalise.md)
- [Exercice 06 - Investigation d'Incident](../exercices/Exercice_06_Incident_Investigation.md)

---

## Compétences Acquises par Exercice

### Exercice 01 - Exploration
- Navigation dans ADUC (dsa.msc)
- Lecture des propriétés d'objets AD
- Commandes PowerShell : `Get-ADOrganizationalUnit`, `Get-ADUser`, `Get-ADGroup`

### Exercice 02 - Événements
- Utilisation de l'Observateur d'événements (eventvwr.msc)
- Filtrage par Event ID
- Analyse des journaux via PowerShell (`Get-WinEvent`)
- Compréhension des Event IDs 4624, 4625, 4648, 4663, 4720, 4740

### Exercice 03 - GPOs
- Configuration de `Set-ADDefaultDomainPasswordPolicy`
- Navigation dans GPMC (gpmc.msc)
- Configuration manuelle d'audit avancé dans les GPOs
- Commandes `gpupdate /force` et `gpresult /r`

### Exercice 04 - Comptes de Service
- Modification d'attributs utilisateurs (`Set-ADUser`)
- Création de groupes globaux (`New-ADGroup` avec préfixe `GG-`)
- Gestion des membres de groupes intégrés (`Add-ADGroupMember`)
- Principe du moindre privilège

### Exercice 05 - Audit NTFS
- Configuration des SACL (System Access Control Lists)
- Activation des politiques d'audit avec `auditpol.exe`
- Utilisation de la classe .NET `FileSystemAuditRule`
- Corrélation entre audit NTFS et Event ID 4663

### Exercice 06 - Investigation
- Méthodologie d'investigation forensique (confinement > investigation > remédiation > rapport)
- Désactivation d'urgence de comptes compromis
- Corrélation d'événements multi-sources
- Rédaction de rapport d'incident

---

## Prérequis par Niveau

### Pour les exercices 01-02 (Débutant)
- Script `MonitoringLab_Setup.ps1` exécuté avec succès
- Accès administrateur au contrôleur de domaine
- Aucune connaissance PowerShell préalable requise

### Pour les exercices 03-04 (Intermédiaire)
- Exercices 01-02 complétés
- Compréhension de base des concepts AD (OUs, groupes, utilisateurs)
- Connaissance de base de PowerShell (variables, boucles simples)

### Pour les exercices 05-06 (Avancé)
- Exercices 01-04 complétés
- Script `2_Generate-Events.ps1` exécuté pour peupler les journaux
- Connaissance des Event IDs de sécurité (acquise en Ex. 02)

---

## Fichiers du Labo

```
Labo3-MonitoringLab/
├── README.md
├── scripts/
│   ├── MonitoringLab_Setup.ps1         # Script principal de création
│   ├── MonitoringLab_Cleanup.ps1       # Script de nettoyage
│   ├── 2_Generate-Events.ps1           # Génération d'événements de test
│   ├── 3_Monitor-RealTime.ps1          # Monitoring en temps réel
│   ├── 4_Create-CustomAlerts.ps1       # Alertes personnalisées
│   └── verification/
│       ├── verif_exercice_01.ps1
│       ├── verif_exercice_02.ps1
│       ├── verif_exercice_03.ps1
│       ├── verif_exercice_04.ps1
│       ├── verif_exercice_05.ps1
│       └── verif_exercice_06.ps1
├── exercices/
│   ├── Exercice_01_Exploration_Structure.md
│   ├── Exercice_02_Analyse_Evenements.md
│   ├── Exercice_03_Configuration_GPOs.md
│   ├── Exercice_04_Comptes_Service.md
│   ├── Exercice_05_Audit_Personnalise.md
│   └── Exercice_06_Incident_Investigation.md
└── instructeur/
    ├── Guide_Instructeur_Exercices.md
    └── INDEX_EXERCICES.md              # Ce fichier
```
