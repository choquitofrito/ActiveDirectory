# Exercice 08 : Incident RGPD - Accès Non Autorisé

## Niveau: 🔴 Avancé | Durée: 60-75 min

## Objectifs
- Mener une **investigation forensique** complète
- Analyser les **Event Logs** et **ACLs**
- Tracer les **chemins de permissions** (groupe → accès)
- Rédiger un **rapport RGPD professionnel**

## Scénario
**ALERTE SÉCURITÉ** - Le dossier médical d'une personnalité VIP (Ministre de la Santé) a été consulté illégalement. La direction exige :
- Identification du coupable
- Chemin d'accès utilisé
- Recommandations de remédiation
- Rapport RGPD complet pour autorités

## Mission d'Investigation

### Phase 1 : Préparation (Setup du scénario)

**Script instructeur pour créer l'incident :**
```powershell
# Créer dossier VIP
$vipPath = "C:\Temp\Dossiers_Patients\VIP_Ministre_Dupont"
New-Item -Path $vipPath -ItemType Directory -Force
"CONFIDENTIEL - Dossier Ministre Dupont" | Out-File "$vipPath\VIP_Dossier.docx"

# Activer audit
$acl = Get-Acl $vipPath
$auditRule = New-Object System.Security.AccessControl.FileSystemAuditRule(
    "Everyone", "ReadData,WriteData", "ContainerInherit,ObjectInherit", "None", "Success,Failure"
)
$acl.AddAuditRule($auditRule)
Set-Acl $vipPath $acl

# Donner accès via groupe (simule faille de sécurité)
$acl = Get-Acl $vipPath
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "MAXTEC\GG-MediCare-Administration-Users", "Read", "ContainerInherit,ObjectInherit", "None", "Allow"
)
$acl.SetAccessRule($accessRule)
Set-Acl $vipPath $acl

# Simuler accès non autorisé (Patricia = réceptionniste)
runas /user:maxtec\patricia "notepad $vipPath\VIP_Dossier.docx"
```

### Phase 2 : Investigation (Étudiant)

**Tâches forensiques :**

1. **Analyser Event Viewer**
   ```powershell
   Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4663} -MaxEvents 500 |
       Where-Object {$_.Message -like "*VIP_Ministre*"} |
       ForEach-Object {
           $xml = [xml]$_.ToXml()
           [PSCustomObject]@{
               TimeCreated = $_.TimeCreated
               User = ($xml.Event.EventData.Data | Where-Object {$_.Name -eq 'SubjectUserName'}).'#text'
               File = ($xml.Event.EventData.Data | Where-Object {$_.Name -eq 'ObjectName'}).'#text'
           }
       } | Format-Table -AutoSize
   ```

2. **Vérifier permissions NTFS**
   ```powershell
   Get-Acl "C:\Temp\Dossiers_Patients\VIP_Ministre_Dupont" |
       Select-Object -ExpandProperty Access |
       Format-Table IdentityReference, FileSystemRights, AccessControlType
   ```

3. **Tracer appartenance aux groupes**
   ```powershell
   $suspect = "patricia"
   Get-ADUser -Identity $suspect -Properties MemberOf |
       Select-Object -ExpandProperty MemberOf |
       ForEach-Object {
           Get-ADGroup -Identity $_
       } | Select-Object Name, Description
   ```

4. **Identifier le chemin d'accès**
   - Patricia → GG-MediCare-Administration-Users → Permission Read sur dossier VIP
   - **VIOLATION** : Le personnel administratif NE DOIT PAS accéder aux dossiers médicaux

### Phase 3 : Rapport RGPD (Étudiant)

**Créer rapport structuré : `C:\Labos\MediCare\Rapport_RGPD_Investigation.docx`**

**Structure obligatoire :**
```
===========================================
RAPPORT D'INCIDENT RGPD
===========================================

1. RÉSUMÉ EXÉCUTIF
   - Date/heure incident : [...]
   - Gravité : CRITIQUE
   - Données compromises : Dossier médical VIP Ministre Dupont

2. QUI (Utilisateur responsable)
   - Nom : Patricia Fournier
   - Fonction : Réceptionniste
   - Compte : MAXTEC\patricia

3. QUAND (Timeline)
   - Date accès : [...]
   - Durée : [...]
   - Événement ID : 4663

4. QUOI (Données consultées)
   - Fichier : VIP_Dossier.docx
   - Chemin : C:\Temp\Dossiers_Patients\VIP_Ministre_Dupont
   - Type d'accès : Lecture (ReadData)

5. COMMENT (Chemin d'accès technique)
   - Groupe : GG-MediCare-Administration-Users
   - Permission : Read sur dossier VIP
   - Faille : Personnel admin ne devrait JAMAIS accéder aux dossiers médicaux

6. POURQUOI (Légitimité)
   - Accès légitime : NON
   - Justification métier : AUCUNE (réceptionniste n'a pas besoin dossiers patients)
   - Violation : RGPD Article 32 (Sécurité du traitement)

7. REMÉDIATION
   A. Actions immédiates (0-24h) :
      - Retirer patricia du groupe GG-MediCare-Administration-Users
      - Révoquer accès Read sur tous dossiers patients
      - Désactiver temporairement compte patricia (enquête RH)

   B. Actions court terme (1 semaine) :
      - Renforcer ACLs : Dossiers VIP uniquement GG-Medical-Seniors
      - Activer alertes temps réel sur dossiers VIP (SIEM)
      - Audit complet tous dossiers patients (autres accès?)

   C. Actions long terme (1 mois) :
      - Formation RGPD obligatoire pour tout le personnel
      - Revue architecture permissions (principe moindre privilège)
      - Implémenter Data Loss Prevention (DLP)

8. NOTIFICATION RGPD
   - Autorité de contrôle : À notifier sous 72h (violation données sensibles santé)
   - Personne concernée : Ministre Dupont à informer (droit d'être informé)

===========================================
Rapport rédigé par : [Votre nom]
Date : [Date]
===========================================
```

## Vérification
```powershell
C:\Labos\MediCare\scripts\verification\verif_exercice_08.ps1
```

## Critères d'Évaluation

- [ ] Investigation complète (Event Viewer, ACLs, groupes)
- [ ] Identification correcte du coupable
- [ ] Chemin d'accès technique exact
- [ ] Rapport structuré et professionnel
- [ ] Remédiation pertinente (immédiat + court + long terme)
- [ ] Compréhension obligations RGPD

## Points Clés
1. **Forensic Windows** : Event ID 4663 est clé pour audit fichiers
2. **Permission Tracing** : Toujours remonter User → Groupe → Permission
3. **RGPD Article 32** : Obligation de sécurité technique appropriée
4. **Notification 72h** : Violation données santé = notification autorité obligatoire
5. **Principe moindre privilège** : Jamais donner plus d'accès que nécessaire

**🎓 Félicitations! Vous avez terminé les 8 exercices MediCare!**
