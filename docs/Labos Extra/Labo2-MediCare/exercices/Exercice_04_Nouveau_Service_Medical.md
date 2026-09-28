# Exercice 04 : Nouveau Service Médical

## Niveau de Difficulté

🟡 **Intermédiaire** (Objectifs sans instructions détaillées)

## Objectifs Pédagogiques

- Créer une **structure AD complète** pour un nouveau département
- Maîtriser l'**architecture OUs** avec sous-OUs (Users, Computers, Groups)
- Appliquer les **conventions de nommage** (GG- pour Global Groups)
- Configurer une **GPO shell** pour futur mappage réseau

## Durée Estimée

**35-40 minutes**

## Prérequis

- Laboratoire MediCare configuré
- Accès Administrateur de domaine
- Connaissance PowerShell + Active Directory Users and Computers

## Contexte / Scénario

**Email de la Directrice Médicale** :

> Bonjour IT,
>
> Excellente nouvelle! La clinique ouvre un **nouveau service de Dermatologie** dès la semaine prochaine.
>
> **Équipe initiale :**
> - Dr. Sarah Fontaine (dermatologue senior, responsable service)
> - Dr. Lucas Morel (dermatologue junior)
> - Asst. Emma Dubois (assistante médicale)
>
> **Besoins informatiques :**
> - Structure AD complète (comptes, groupes, OUs)
> - 2 groupes : utilisateurs standard + administrateurs service
> - Lecteur réseau D: pour dossiers dermatologie (à configurer plus tard)
> - Politique de sécurité identique au département Medical
>
> Merci,
> Dr. Catherine Leblanc

## Tâche à Réaliser

**Objectif** : Créer de A à Z la structure Active Directory pour le service Dermatologie.

### Contraintes Techniques

1. **Structure OU** :
   - Créer `OU=Dermatologie,OU=Medical,OU=MediCare,DC=maxtec,DC=be`
   - **IMPORTANT** : `-ProtectedFromAccidentalDeletion $false`
   - Créer 3 sous-OUs : Users, Computers, Groups

2. **Utilisateurs** (dans Dermatologie > Users) :
   - Dr. Sarah Fontaine (sarah@maxtec.be)
   - Dr. Lucas Morel (lucas@maxtec.be)
   - Asst. Emma Dubois (emma@maxtec.be)
   - Propriétés : Title, Department="Dermatologie", Description

3. **Groupes** (dans Dermatologie > Groups) :
   - **GG-MediCare-Dermato-Users** (scope: Global)
   - **GG-MediCare-Dermato-Admin** (scope: Global)
   - Membres appropriés

4. **GPO Shell** :
   - Nom : "MediCare - Dermatologie Lecteur D"
   - Commentaire clair
   - Lien vers : OU=Dermatologie
   - Ne PAS configurer (shell uniquement pour futur Drive Map D:)

5. **Documentation** :
   - Exporter CSV : `C:\Labos\MediCare\Dermato_Structure.csv`
   - Contenu : Tous les utilisateurs avec propriétés

### Indices

- Utilisez `New-ADOrganizationalUnit` avec protection désactivée
- Convention groupes : **GG-** obligatoire (Global Group)
- GPO : `New-GPO` + `New-GPLink` (pas de configuration interne)
- CSV : `Get-ADUser ... | Export-Csv`

## Vérification de la Réussite

```powershell
C:\Labos\MediCare\scripts\verification\verif_exercice_04.ps1
```

### Critères de Réussite

- [ ] OU Dermatologie créée avec 3 sous-OUs (Users, Computers, Groups)
- [ ] 3 utilisateurs créés avec propriétés complètes
- [ ] 2 groupes créés avec préfixe GG-
- [ ] Groupes correctement peuplés (Sarah dans Admin + Users, autres dans Users)
- [ ] GPO shell créée et liée
- [ ] CSV exporté avec structure documentée

## Solution Complète (Pour Instructeur)

### Méthode PowerShell

```powershell
# === SCRIPT COMPLET - Nouveau Service Dermatologie ===

Import-Module ActiveDirectory

# 1. Créer structure OUs
$basePath = "OU=Medical,OU=MediCare,DC=maxtec,DC=be"
$dermatoPath = "OU=Dermatologie,$basePath"

Write-Host "[ÉTAPE 1] Création structure OUs..." -ForegroundColor Cyan

New-ADOrganizationalUnit -Name "Dermatologie" -Path $basePath -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Name "Users" -Path $dermatoPath -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Name "Computers" -Path $dermatoPath -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Name "Groups" -Path $dermatoPath -ProtectedFromAccidentalDeletion $false

Write-Host "  ✓ OUs créées" -ForegroundColor Green

# 2. Créer utilisateurs
Write-Host "`n[ÉTAPE 2] Création utilisateurs..." -ForegroundColor Cyan

$users = @(
    @{FirstName="Sarah"; LastName="Fontaine"; Sam="sarah"; Title="Dermatologue Senior"; IsAdmin=$true}
    @{FirstName="Lucas"; LastName="Morel"; Sam="lucas"; Title="Dermatologue Junior"; IsAdmin=$false}
    @{FirstName="Emma"; LastName="Dubois"; Sam="emma"; Title="Assistante Médicale Dermatologie"; IsAdmin=$false}
)

foreach ($u in $users) {
    $password = ConvertTo-SecureString "Password1!" -AsPlainText -Force
    New-ADUser `
        -Name "$($u.FirstName) $($u.LastName)" `
        -GivenName $u.FirstName `
        -Surname $u.LastName `
        -SamAccountName $u.Sam `
        -UserPrincipalName "$($u.Sam)@maxtec.be" `
        -Path "OU=Users,$dermatoPath" `
        -AccountPassword $password `
        -Enabled $true `
        -PasswordNeverExpires $false `
        -ChangePasswordAtLogon $false `
        -Title $u.Title `
        -Department "Dermatologie" `
        -Description "Service Dermatologie - MediCare Clinic" `
        -EmailAddress "$($u.Sam)@maxtec.be"
    
    Write-Host "  ✓ $($u.FirstName) $($u.LastName) créé" -ForegroundColor Green
}

# 3. Créer groupes
Write-Host "`n[ÉTAPE 3] Création groupes..." -ForegroundColor Cyan

$groupsPath = "OU=Groups,$dermatoPath"

New-ADGroup -Name "GG-MediCare-Dermato-Users" -GroupScope Global -Path $groupsPath `
    -Description "Tous les utilisateurs du service Dermatologie"

New-ADGroup -Name "GG-MediCare-Dermato-Admin" -GroupScope Global -Path $groupsPath `
    -Description "Administrateurs du service Dermatologie (responsables)"

Write-Host "  ✓ Groupes créés" -ForegroundColor Green

# 4. Peupler groupes
Write-Host "`n[ÉTAPE 4] Ajout membres aux groupes..." -ForegroundColor Cyan

Add-ADGroupMember -Identity "GG-MediCare-Dermato-Users" -Members sarah,lucas,emma
Add-ADGroupMember -Identity "GG-MediCare-Dermato-Admin" -Members sarah

Write-Host "  ✓ Membres ajoutés" -ForegroundColor Green

# 5. Créer GPO shell
Write-Host "`n[ÉTAPE 5] Création GPO shell..." -ForegroundColor Cyan

$gpoName = "MediCare - Dermatologie Lecteur D"
New-GPO -Name $gpoName -Comment "Mappage lecteur D: pour partage Dermatologie (configuration manuelle GPMC requise)"
New-GPLink -Name $gpoName -Target $dermatoPath -LinkEnabled Yes

Write-Host "  ✓ GPO shell créée et liée" -ForegroundColor Green
Write-Host "    Configuration manuelle requise : Drive Map D: vers \\SRV\Dermatologie" -ForegroundColor Yellow

# 6. Exporter CSV
Write-Host "`n[ÉTAPE 6] Export documentation CSV..." -ForegroundColor Cyan

New-Item -Path "C:\Labos\MediCare" -ItemType Directory -Force | Out-Null

Get-ADUser -Filter * -SearchBase "OU=Users,$dermatoPath" -Properties EmailAddress,Title,Department,Description |
    Select-Object Name,SamAccountName,EmailAddress,Title,Department,Description,Enabled |
    Export-Csv -Path "C:\Labos\MediCare\Dermato_Structure.csv" -NoTypeInformation -Encoding UTF8

Write-Host "  ✓ CSV exporté : C:\Labos\MediCare\Dermato_Structure.csv" -ForegroundColor Green

Write-Host "`n✅ Service Dermatologie créé avec succès!" -ForegroundColor Green
```

## Points Clés à Retenir

1. **ProtectedFromAccidentalDeletion $false** : TOUJOURS pour les labs (permet cleanup scripts)
2. **Convention GG-** : Obligatoire pour tous les groupes Global
3. **Architecture à 3 niveaux** : Department > Sub-OUs (Users/Computers/Groups)
4. **GPO Shell uniquement** : Ne JAMAIS configurer via Set-GPRegistryValue
5. **Documentation** : Toujours exporter en CSV pour traçabilité

## Dépannage (Erreurs Courantes)

| Erreur | Cause | Solution |
|--------|-------|----------|
| "OU already exists" | Dermatologie existe | Utiliser MediCare_Cleanup.ps1 ou supprimer manuellement |
| "User already exists" | Utilisateur créé précédemment | Utiliser SamAccountName différent ou supprimer ancien |
| "Cannot find path" | OU parent manquante | Créer d'abord OU=Dermatologie avant sous-OUs |
| GPO non liée | Erreur dans New-GPLink | Vérifier Target avec Get-ADOrganizationalUnit |

## Exercice Suivant

**[Exercice 05 : Confidentialité Renforcée](Exercice_05_Confidentialite_Renforcee.md)** - Créer une GPO de sécurité médicale avancée.
