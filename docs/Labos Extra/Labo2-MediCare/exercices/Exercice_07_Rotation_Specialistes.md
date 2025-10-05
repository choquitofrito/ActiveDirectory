# Exercice 07 : Rotation de Spécialistes

## Niveau: 🔴 Avancé | Durée: 50-60 min

## Objectifs
- Configurer des **Roaming Profiles**
- Maîtriser la **Folder Redirection** via GPO
- Comprendre **Primary Computer** (Fast Logon Optimization)
- Utiliser **Group Policy Loopback Processing**

## Scénario
Les Dr. Amélie Laurent et Dr. Marc Bernard (cardiologues) alternent chaque semaine sur la station "CARDIO-WS01". Leurs profils et documents doivent les suivre.

## Tâches Complexes

### 1. Créer partages réseau (Prérequis)
```powershell
# Sur serveur fichiers ou DC
New-Item -Path "C:\Shares\Profiles$" -ItemType Directory -Force
New-Item -Path "C:\Shares\Redirected$" -ItemType Directory -Force
New-SmbShare -Name "Profiles$" -Path "C:\Shares\Profiles$" -FullAccess "Everyone"
New-SmbShare -Name "Redirected$" -Path "C:\Shares\Redirected$" -FullAccess "Everyone"
```

### 2. Configurer Roaming Profiles
```powershell
# Pour Dr. Amélie Laurent
Set-ADUser -Identity amélie -ProfilePath "\\SRV-MEDICARE\Profiles$\%username%"

# Pour Dr. Marc Bernard  
Set-ADUser -Identity marc -ProfilePath "\\SRV-MEDICARE\Profiles$\%username%"
```

### 3. Créer GPO Folder Redirection
1. Créer GPO "MediCare - Profils Itinérants Cardio"
2. Configuration manuelle GPMC :
   - User Config > Windows Settings > Folder Redirection > Documents
   - Target: `\\SRV-MEDICARE\Redirected$\%username%\Documents`
   - Settings: "Create a folder for each user under the root path"
3. Configurer Loopback Processing :
   - Computer Config > Administrative Templates > System > Group Policy
   - "Configure user Group Policy loopback processing mode" = Enabled (Merge)
4. Lier GPO à ordinateur CARDIO-WS01

### 4. Configurer Primary Computer (Optionnel)
```powershell
# Obtenir DN de l'ordinateur
$computerDN = (Get-ADComputer -Identity "CARDIO-WS01").DistinguishedName

# Ajouter comme Primary Computer
Set-ADUser -Identity amélie -Add @{"msDS-PrimaryComputer"=$computerDN}
Set-ADUser -Identity marc -Add @{"msDS-PrimaryComputer"=$computerDN}
```

## Vérification
1. Se connecter avec amélie sur CARDIO-WS01
2. Créer fichier dans Documents
3. Se déconnecter
4. Se connecter avec marc
5. Vérifier que Documents de marc est vide (isolation)
6. Se reconnecter avec amélie
7. Vérifier que fichier créé est toujours là (persistance)

```powershell
C:\Labos\MediCare\scripts\verification\verif_exercice_07.ps1
```

## Points Clés
- Roaming Profiles : Profil utilisateur entier suit l'utilisateur
- Folder Redirection : Seuls dossiers sélectionnés redirigés (économie réseau)
- Loopback Processing : Applique GPO user même si OU ordinateur différent
- Primary Computer : Optimise le temps de logon sur PC principal

## Exercice Suivant
**[Exercice 08 : Incident RGPD](Exercice_08_Incident_RGPD.md)**
