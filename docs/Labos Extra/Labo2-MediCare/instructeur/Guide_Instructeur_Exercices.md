# Guide Rapide Exercices MediCare - Instructeur

## Vue d'Ensemble Rapide

**8 exercices progressifs** axés sur l'administration AD médicale avec conformité RGPD/HIPAA.

| Ex# | Titre | Niveau | Durée | Technologies Clés |
|-----|-------|--------|-------|-------------------|
| 01 | Transfert Patient | 🟢 Débutant | 20-25' | NTFS ACLs, transfert données |
| 02 | Horaire Garde | 🟢 Débutant | 25-30' | Logon Hours, comptes temporaires |
| 03 | Audit Accès | 🟢 Débutant | 25-30' | Event Viewer 4663, audit NTFS |
| 04 | Nouveau Service | 🟡 Intermédiaire | 35-40' | Architecture OUs, GG- groups |
| 05 | Confidentialité | 🟡 Intermédiaire | 30-35' | GPO sécurité, GPMC manuel |
| 06 | Délégation Chef | 🟡 Intermédiaire | 30-35' | Delegation Wizard, ACLs |
| 07 | Rotation Spécialistes | 🔴 Avancé | 50-60' | Roaming profiles, redirection |
| 08 | Incident RGPD | 🔴 Avancé | 60-75' | Forensique, rapport RGPD |

## Points d'Attention par Exercice

### Ex 01 : Transfert Patient
**Objectif** : Modifier permissions NTFS, documenter transfert RGPD
**Pièges étudiants** :

- Oublient de RETIRER les permissions de catherine (seulement AJOUTER philippe)
- N'utilisent pas RemoveAccessRule correctement
- Oublient de documenter dans Description

**Solution rapide** :
```powershell
$acl = Get-Acl <folder>
$acl.Access | Where {$_.IdentityReference -eq "MAXTEC\catherine"} | % {$acl.RemoveAccessRule($_)}
Set-Acl <folder> $acl
```

### Ex 02 : Horaire Garde
**Objectif** : Compte temporaire + Logon Hours 18h-8h + week-ends
**Pièges étudiants** :

- Logon Hours via PowerShell = TRÈS complexe (bits manipulation)
- Oublient de cocher "Cannot Change Password" (compte partagé)
- Testent hors des horaires autorisés (message confus)

**Solution rapide** :

- **Imposer GUI** pour Logon Hours (Account > Logon Hours...)
- Bloquer Lundi-Vendredi 8h-18h (laisser reste bleu)

### Ex 03 : Audit Accès Médical
**Objectif** : Activer audit NTFS + Event Viewer + CSV
**Pièges étudiants** :

- Event ID 4663 introuvable si audit non activé
- Filtrage XML events complexe
- CSV vide si aucun accès réel au fichier

**Solution rapide** :
```powershell
# Activer audit
$acl = Get-Acl <folder>
$auditRule = New-Object System.Security.AccessControl.FileSystemAuditRule(
    "Everyone", "ReadData,WriteData", "ContainerInherit,ObjectInherit", "None", "Success"
)
$acl.AddAuditRule($auditRule)
Set-Acl <folder> $acl

# IMPORTANT: Générer accès APRÈS activation audit
```

### Ex 04 : Nouveau Service Médical
**Objectif** : Créer département Dermatologie de A à Z
**Pièges étudiants** :

- Oublient `-ProtectedFromAccidentalDeletion $false` (CRITIQUE!)
- Groupes sans préfixe GG-
- GPO configurée avec Set-GPRegistryValue (INTERDIT)

**Solution rapide** :
```powershell
# TOUTES les OUs
New-ADOrganizationalUnit -Name "..." -Path "..." -ProtectedFromAccidentalDeletion $false

# TOUS les groupes Global
New-ADGroup -Name "GG-MediCare-Dermato-Users" -GroupScope Global ...
```

### Ex 05 : Confidentialité Renforcée
**Objectif** : GPO sécurité médicale (GPO shell + config manuelle)
**Pièges étudiants** :

- Tentent Set-GPRegistryValue (apparaît comme "nom convivial introuvable")
- Cherchent les paramètres dans mauvais endroit GPMC
- Oublient de lier GPO à OU Medical

**Solution rapide** :

- **Créer shell uniquement** : `New-GPO` + `New-GPLink`
- **Donner chemins exacts** : Consulter `.claude/gpo-reference.md`
- **Tester** : `gpupdate /force` puis vérifier restrictions actives

### Ex 06 : Délégation Chef Service
**Objectif** : Déléguer gestion Nursing à Anne (sans accès Medical)
**Pièges étudiants** :

- Ne testent pas avec `runas /user:maxtec\anne`
- Donnent trop de permissions (Domain Admin par erreur)
- Oublient de vérifier le REFUS d'accès Medical

**Solution rapide** :

1. AD Users and Computers > OU Nursing > Déléguer le contrôle
2. Sélectionner `anne`
3. Tâches : Reset passwords + Modify group membership
4. **TESTER** : `runas /user:maxtec\anne powershell` puis modifier brigitte (OK) et catherine (INTERDIT)

### Ex 07 : Rotation Spécialistes
**Objectif** : Roaming profiles + folder redirection pour cardiologues
**Pièges étudiants** :

- Partages réseau inexistants (créer AVANT)
- Permissions NTFS insuffisantes sur Profiles$ et Redirected$
- Loopback Processing non configuré (GPO s'applique pas)
- Primary Computer optionnel (complique)

**Solution rapide** :
```powershell
# 1. Créer partages
New-SmbShare -Name "Profiles$" -Path "C:\Shares\Profiles$" -FullAccess "Everyone"
New-SmbShare -Name "Redirected$" -Path "C:\Shares\Redirected$" -FullAccess "Everyone"

# 2. Profils itinérants
Set-ADUser -Identity amélie -ProfilePath "\\SRV\Profiles$\%username%"
Set-ADUser -Identity marc -ProfilePath "\\SRV\Profiles$\%username%"

# 3. GPO Folder Redirection (manuel GPMC)
# User Config > Windows Settings > Folder Redirection > Documents
```

### Ex 08 : Incident RGPD
**Objectif** : Investigation forensique + rapport RGPD complet
**Pièges étudiants** :

- Ne créent pas le scénario d'incident (instructeur doit le faire)
- Event Viewer : filtrent mal Event ID 4663
- Rapport RGPD incomplet (manque recommandations)
- Ne tracent pas le chemin User → Groupe → Permission

**Setup instructeur** (créer l'incident AVANT exercice) :
```powershell
# Créer dossier VIP
$vipPath = "C:\Temp\Dossiers_Patients\VIP_Ministre_Dupont"
New-Item -Path $vipPath -ItemType Directory -Force
"CONFIDENTIEL" | Out-File "$vipPath\VIP_Dossier.docx"

# Activer audit
$acl = Get-Acl $vipPath
$auditRule = New-Object System.Security.AccessControl.FileSystemAuditRule(
    "Everyone", "ReadData", "ContainerInherit,ObjectInherit", "None", "Success"
)
$acl.AddAuditRule($auditRule)
Set-Acl $vipPath $acl

# Donner accès erroné (faille sécurité)
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "MAXTEC\GG-MediCare-Administration-Users", "Read", "ContainerInherit,ObjectInherit", "None", "Allow"
)
$acl.SetAccessRule($accessRule)
Set-Acl $vipPath $acl

# Simuler accès non autorisé (Patricia = réceptionniste)
# Étudiant trouvera cet accès dans Event Viewer
```

## Erreurs Communes Globales

| Erreur | Cause | Solution |
|--------|-------|----------|
| "OU already exists" | Lab précédent non nettoyé | `.\MediCare_Cleanup.ps1` |
| "Access denied" | Pas admin | Lancer PowerShell ISE en tant qu'Administrateur |
| GPO "nom convivial introuvable" | Set-GPRegistryValue utilisé | Supprimer GPO, recréer shell, config manuelle |
| Event 4663 introuvable | Audit non activé | Vérifier GPO 4 (Audit) + Audit NTFS |
| Logon Hours non respectées | Cache Kerberos | Attendre 30 min ou redémarrer |

## Vérification Rapide Instructeur

```powershell
# Vérifier toutes les OUs MediCare
Get-ADOrganizationalUnit -Filter * |
    Where {$_.DistinguishedName -like "*MediCare*"} |
    Select Name, ProtectedFromAccidentalDeletion

# Vérifier tous les groupes GG-
Get-ADGroup -Filter {Name -like "GG-MediCare-*"} | Select Name, GroupScope

# Vérifier audit activé
Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4663} -MaxEvents 10

# Vérifier GPOs créées
Get-GPO -All | Where {$_.DisplayName -like "*MediCare*"} | Select DisplayName
```

## Timing Recommandé (Session 4h)

**Session Matin (2h)** :

- 09h00-09h20 : Exercice 01 (Transfert Patient)
- 09h20-09h50 : Exercice 02 (Horaire Garde)
- 09h50-10h00 : Pause
- 10h00-10h30 : Exercice 03 (Audit Accès)
- 10h30-11h00 : Exercice 04 (Nouveau Service)

**Session Après-midi (2h)** :

- 13h00-13h30 : Exercice 05 (Confidentialité)
- 13h30-14h00 : Exercice 06 (Délégation)
- 14h00-14h10 : Pause
- 14h10-15h00 : Exercice 07 OU 08 (selon niveau)

## Différenciation Pédagogique

**Étudiants rapides** :

- Exercice 07 + 08 (profils itinérants + investigation)
- Challenge : Automatiser Exercice 01-03 en un seul script

**Étudiants en difficulté** :

- Focus Exercice 01-04 (fondamentaux)
- Donner solutions partielles pour Exercice 05-06
- Passer Exercice 07-08 (optionnels)

## Fichiers Clés à Distribuer

1. **README.md du lab** : `/docs/Labos Extra/Labo2-MediCare/README.md`
2. **Scripts de setup** : `MediCare_Setup.ps1`
3. **Index exercices** : `exercices/README.md`
4. **Scripts de vérification** : `scripts/verification/verif_exercice_*.ps1`
5. **GPO Reference** : `.claude/gpo-reference.md` (instructeur uniquement)

## Points Pédagogiques Essentiels

1. **RGPD/HIPAA** : Toujours expliquer le POURQUOI (conformité légale)
2. **Principe moindre privilège** : Retirer accès dès qu'inutile
3. **Documentation** : Traçabilité obligatoire (audits, incidents)
4. **GPO Best Practices** : Jamais Set-GPRegistryValue pour politiques standard
5. **Forensique** : Event Viewer est clé pour investigations

## Évaluation Suggérée

**Badge Bronze** (01-03 réussis) : Compétences de base
**Badge Argent** (01-06 réussis) : Compétences intermédiaires
**Badge Or** (01-07 réussis) : Compétences avancées
**Badge Diamant** (01-08 réussis + rapport RGPD qualité) : Maîtrise complète

---

**Bon courage pour l'enseignement! 🏥🔒**
