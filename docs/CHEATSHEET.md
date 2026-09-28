# PowerShell Cheat Sheet - Commandes Essentielles

## 🧭 Navigation du Cours
[⏮️ Chapitre Précédent: Powershell AD - Création et Modification](Chapitre%209.3.Powershell%20AD%20-%20Creation_et_Modification.md) | [🏠 Retour au Syllabus](index.md)

---

Les exemples utilisent le lab Maxtec (`maxtec.be`, comptes `richard`, `ivan`..., OU `Comptabilite` sans accent). `marie.martin` est un compte de test créé dans la section 2.

## 1. 🔹 Commandes de Base PowerShell

### Variables
```powershell
# Créer une variable
$nomUtilisateur = "richard"

# Afficher une variable
Write-Host $nomUtilisateur
$nomUtilisateur  # Version courte

# Concaténation
$nomComplet = $prenom + " " + $nom
$nomComplet = "$prenom $nom"      # équivalent, plus lisible
```

### Tableaux
```powershell
# Créer un tableau
$utilisateurs = @("vanessa", "victor", "rebecca")

# Accéder à un élément (index commence à 0)
$utilisateurs[0]  # Premier élément
$utilisateurs[-1] # Dernier élément

# Ajouter un élément
$utilisateurs += "ivan"
```

### Boucles
```powershell
$utilisateurs = Get-ADUser -Filter "Department -eq 'IT'"

# Boucle foreach simple
foreach ($utilisateur in $utilisateurs) {
    Write-Host $utilisateur.Name
}

# Avec pipeline
$utilisateurs | ForEach-Object { Write-Host $_.Name }
```

### Conditions
```powershell
# Condition simple
if ($compteActif) {
    Write-Host "Compte actif"
} else {
    Write-Host "Compte désactivé"
}

# Comparaisons courantes
$nombre -eq 5    # Égal
$nombre -ne 5    # Différent
$nombre -gt 5    # Supérieur
$nombre -lt 5    # Inférieur
```

## 2. 🔹 Commandes Active Directory - Utilisateurs

### Recherche d'utilisateurs
```powershell
# Tous les utilisateurs
Get-ADUser -Filter *

# Utilisateur spécifique
Get-ADUser -Identity "richard"
Get-ADUser -Filter "SamAccountName -eq 'richard'"

# Toutes les propriétés d'UN utilisateur (pour découvrir les noms de propriétés)
Get-ADUser -Identity "richard" -Properties *

# Recherche par propriétés
Get-ADUser -Filter "Department -eq 'Comptabilite'"
Get-ADUser -Filter "Title -like 'Responsable*'"
$depuis = [datetime]'2023-01-01'      # format ISO, indépendant de la langue
Get-ADUser -Filter {WhenCreated -ge $depuis} -Properties WhenCreated
```

### Création et modification d'utilisateurs
```powershell
# Créer un utilisateur (mot de passe saisi au clavier, masqué)
# $mdp et non $pwd : $PWD est une variable automatique (le dossier courant)
$mdp = Read-Host "Mot de passe initial" -AsSecureString
New-ADUser -Name "Marie Martin" -SamAccountName "marie.martin" `
    -UserPrincipalName "marie.martin@maxtec.be" `
    -Department "Comptabilite" `
    -Path "OU=Users,OU=Comptabilite,OU=EU,DC=maxtec,DC=be" `
    -AccountPassword $mdp -Enabled $true `
    -ChangePasswordAtLogon $true

# Activer/Désactiver un compte
Enable-ADAccount -Identity "marie.martin"
Disable-ADAccount -Identity "marie.martin"

# Modifier les propriétés
Set-ADUser -Identity "marie.martin" -Title "Chef Comptable"

# Déplacer un objet vers une autre OU (penser à mettre Department à jour aussi)
Get-ADUser "marie.martin" | Move-ADObject -TargetPath "OU=Users,OU=RH,OU=EU,DC=maxtec,DC=be" -WhatIf

# Renommer un objet (change le CN, pas le SamAccountName)
Get-ADUser "marie.martin" | Rename-ADObject -NewName "Marie Dupont"

# Reset / changer le mot de passe
Set-ADAccountPassword -Identity "marie.martin" -Reset `
    -NewPassword (Read-Host "Nouveau mot de passe" -AsSecureString)

# Forcer le changement à la prochaine ouverture de session
Set-ADUser -Identity "marie.martin" -ChangePasswordAtLogon $true

# Déverrouiller un compte
Unlock-ADAccount -Identity "marie.martin"

# Supprimer un utilisateur (en dernier) : simuler d'abord, puis confirmer
Remove-ADUser -Identity "marie.martin" -WhatIf
Remove-ADUser -Identity "marie.martin"          # demande confirmation (O/N)
```

!!! note "Mot de passe en clair"
    
    `ConvertTo-SecureString "Azerty_1" -AsPlainText -Force` (utilisé par le script du lab) écrit le mot de passe en clair dans le script et l'historique. Acceptable en lab, jamais en production.

### Recherche avancée
```powershell
# Utilisateurs actifs seulement
Get-ADUser -Filter {Enabled -eq $true}

# PasswordExpired et LockedOut sont des propriétés calculées :
# -Filter ne sait pas les utiliser. Search-ADAccount est fait pour ça.
Search-ADAccount -PasswordExpired -UsersOnly                        # mot de passe expiré
Search-ADAccount -LockedOut -UsersOnly                              # verrouillés
Search-ADAccount -AccountInactive -TimeSpan 90.00:00:00 -UsersOnly  # inactifs > 90 j
Search-ADAccount -PasswordNeverExpires -UsersOnly                   # mots de passe sans expiration
Search-ADAccount -AccountDisabled -UsersOnly                        # désactivés
```

## 3. 🔹 Commandes Active Directory - Groupes

### Recherche de groupes
```powershell
# Tous les groupes
Get-ADGroup -Filter *

# Groupe spécifique
Get-ADGroup -Identity "GG-EU-RH-Users"

# Groupes par type
Get-ADGroup -Filter {GroupScope -eq "Global"}
Get-ADGroup -Filter {GroupCategory -eq "Security"}

# Recherche par nom
Get-ADGroup -Filter {Name -like "GG-EU-*"}
```

### Gestion des membres
```powershell
# Ajouter un membre à un groupe
Add-ADGroupMember -Identity "GG-EU-Compta-Users" -Members "marie.martin"

# Ajouter le résultat d'une recherche (entre parenthèses : -Members n'accepte pas le pipeline)
Add-ADGroupMember -Identity "GG-EU-Compta-Users" `
    -Members (Get-ADUser -Filter "Department -eq 'Comptabilite'") -WhatIf

# Variante pipeline : partir des utilisateurs
Get-ADUser -Filter "Department -eq 'Comptabilite'" |
    Add-ADPrincipalGroupMembership -MemberOf "GG-EU-Compta-Users" -WhatIf

# Retirer un membre
Remove-ADGroupMember -Identity "GG-EU-Compta-Users" -Members "marie.martin"

# Lister les membres
Get-ADGroupMember -Identity "GG-EU-RH-Users"

# Récupérer tous les groupes d'un utilisateur
Get-ADPrincipalGroupMembership -Identity "richard"
```

## 4. 🔹 Commandes Active Directory - Ordinateurs

### Recherche d'ordinateurs
```powershell
# Tous les ordinateurs
Get-ADComputer -Filter *

# Ordinateur spécifique
Get-ADComputer -Identity "ws-IT-01"

# Ordinateurs par OS
Get-ADComputer -Filter {OperatingSystem -like "*Windows 11*"} -Properties OperatingSystem

# Ordinateurs activés/désactivés
Get-ADComputer -Filter {Enabled -eq $true}
```

### Gestion des ordinateurs
```powershell
# Créer un compte ordinateur (pré-création avant jonction)
New-ADComputer -Name "ws-compta-01" -Path "OU=Computers,OU=Comptabilite,OU=EU,DC=maxtec,DC=be"

# Activer/Désactiver un ordinateur
# Passer par Get-ADComputer : le SamAccountName d'un ordinateur se termine par $ (WS-IT-01$),
# -Identity "ws-IT-01" sur Disable-ADAccount ne le trouverait pas.
# Attention : désactiver le compte machine coupe le poste du domaine.
Get-ADComputer ws-IT-01 | Disable-ADAccount -WhatIf
Get-ADComputer ws-IT-01 | Enable-ADAccount
```

## 5. 🔹 Commandes Active Directory - Unités d'Organisation

### Recherche d'OU
```powershell
# Toutes les OU
Get-ADOrganizationalUnit -Filter *

# OU spécifique
Get-ADOrganizationalUnit -Identity "OU=Comptabilite,OU=EU,DC=maxtec,DC=be"

# OU avec propriétés
Get-ADOrganizationalUnit -Filter * -Properties Description, ManagedBy
```

### Gestion des OU
```powershell
# Créer une OU (lab : sans protection ; en production, laissez la protection activée)
New-ADOrganizationalUnit -Name "Test" -Path "OU=EU,DC=maxtec,DC=be" -ProtectedFromAccidentalDeletion $false

# Modifier une OU
Set-ADOrganizationalUnit -Identity "OU=Ventes,OU=EU,DC=maxtec,DC=be" -Description "Unité organisationnelle Ventes"
```

## 6. 🔹 Commandes Pratiques - Rapports et Export

### Export vers CSV
```powershell
# Exporter tous les utilisateurs
# Select-Object avant Export-Csv : sinon le CSV contient toutes les propriétés techniques
# -NoTypeInformation : pas de ligne "#TYPE ..." en tête (nécessaire en PowerShell 5.1)
Get-ADUser -Filter * -Properties Department, Title |
    Select-Object Name, SamAccountName, Department, Title |
    Export-Csv -Path "C:\Scripts\rapport_utilisateurs.csv" -NoTypeInformation -Encoding UTF8

# Exporter les membres d'un groupe
Get-ADGroupMember -Identity "GG-EU-RH-Users" | Select-Object Name, SamAccountName |
    Export-Csv -Path "C:\Scripts\membres_rh.csv" -NoTypeInformation -Encoding UTF8
```

### Import CSV — Onboarding en masse
```powershell
# Fichier C:\Scripts\nouveaux_users.csv (en UTF-8) :
# Prenom,Nom,SamAccountName,Department,OU
# Pierre,Durand,pierre.durand,Comptabilite,"OU=Users,OU=Comptabilite,OU=EU,DC=maxtec,DC=be"
# Sophie,Leblanc,sophie.leblanc,RH,"OU=Users,OU=RH,OU=EU,DC=maxtec,DC=be"

$mdp = Read-Host "Mot de passe initial" -AsSecureString

Import-Csv -Path "C:\Scripts\nouveaux_users.csv" -Encoding UTF8 | ForEach-Object {
    New-ADUser `
        -Name "$($_.Prenom) $($_.Nom)" `
        -GivenName $_.Prenom -Surname $_.Nom `
        -SamAccountName $_.SamAccountName `
        -UserPrincipalName "$($_.SamAccountName)@maxtec.be" `
        -Department $_.Department `
        -Path $_.OU `
        -AccountPassword $mdp -Enabled $true `
        -ChangePasswordAtLogon $true `
        -WhatIf     # retirer après lecture de la simulation
}
```

### -WhatIf et -Confirm — l'assurance-vie du sysadmin
```powershell
# -WhatIf : montre ce qui SERAIT fait, sans rien exécuter
Get-ADUser -Filter {Department -eq "RH"} | Remove-ADUser -WhatIf

# Tester un import CSV avant de l'exécuter pour de vrai
Import-Csv "C:\Scripts\nouveaux_users.csv" -Encoding UTF8 | ForEach-Object {
    New-ADUser -Name "$($_.Prenom) $($_.Nom)" -SamAccountName $_.SamAccountName `
        -Path $_.OU -WhatIf
}

# -Confirm : demande validation interactive avant chaque action
Disable-ADAccount -Identity "marie.martin" -Confirm
```
**Règle d'or** : tout `Remove-*`, `Set-*` ou `Move-*` sur plusieurs objets se teste d'abord avec `-WhatIf`. `-Confirm:$false` (qui supprime la question) ne s'ajoute qu'après, sur une commande déjà vérifiée. Voir [M5 — `-WhatIf`](PowershellCourse/cours-powershell-ad-moderne/modules-modernes/M5-whatif-religieux.md).

### Filtres avancés
```powershell
# Calculer la date AVANT le filtre : une expression comme (Get-Date).AddDays(-30)
# à l'intérieur de -Filter { } provoque une erreur.

# Utilisateurs créés récemment
$ilYa30j = (Get-Date).AddDays(-30)
Get-ADUser -Filter {WhenCreated -ge $ilYa30j} -Properties WhenCreated

# Utilisateurs n'ayant pas changé leur mot de passe récemment
$ilYa90j = (Get-Date).AddDays(-90)
Get-ADUser -Filter {PasswordLastSet -le $ilYa90j} -Properties PasswordLastSet

# Groupes avec plus de 10 membres
Get-ADGroup -Filter * -Properties Members | Where-Object { $_.Members.Count -gt 10 }
```

## 7. 🔹 Commandes Système et Utilitaires

### Navigation et fichiers
```powershell
# Aller dans un répertoire
cd "C:\Scripts"

# Lister le contenu
Get-ChildItem

# Créer un fichier
New-Item -Path "rapport.txt" -ItemType File

# Lire un fichier
Get-Content -Path "rapport.txt"
```

### Gestion des erreurs
```powershell
# Piège : Get-ADUser -Identity sur un compte inexistant lève une erreur TERMINANTE.
# -ErrorAction SilentlyContinue ne la supprime pas.
Get-ADUser -Identity "utilisateur_inexistant" -ErrorAction SilentlyContinue   # erreur quand même

# Option 1 : try/catch
try {
    $u = Get-ADUser -Identity "utilisateur_inexistant" -ErrorAction Stop
} catch {
    Write-Host "Utilisateur introuvable" -ForegroundColor Yellow
}

# Option 2 : -Filter ne lève pas d'erreur, il renvoie $null si rien n'est trouvé
$u = Get-ADUser -Filter "SamAccountName -eq 'utilisateur_inexistant'"
if (-not $u) { Write-Host "Utilisateur introuvable" }

# Pour les autres commandes : -ErrorAction Stop rend une erreur attrapable par catch
Get-ChildItem "C:\DossierInexistant" -ErrorAction Stop
```

## 8. 🔹 Raccourcis et Alias

### Alias courants
```powershell
# Alias de commandes
dir    # = Get-ChildItem
ls     # = Get-ChildItem
cat    # = Get-Content
rm     # = Remove-Item
echo   # = Write-Output
clear  # = Clear-Host
```

!!! warning "Les alias ne sont pas les commandes Linux"
    
    `ls`, `cat` ou `rm` lancent les cmdlets PowerShell : seul le nom est emprunté. Les options GNU ne fonctionnent pas : `ls -la` échoue (« aucun paramètre ne correspond au nom la »), `rm -rf dossier` aussi. Équivalents : `Get-ChildItem -Force` pour voir les fichiers cachés, `Remove-Item dossier -Recurse -Force` (avec `-WhatIf` d'abord). Dans un script partagé, écrivez le nom complet de la cmdlet.

### Commandes avec alias
```powershell
# Utiliser les alias
dir | Where-Object {$_.Extension -eq ".ps1"}
echo "Bonjour" | Out-File -FilePath "salutation.txt"
```

---

## 🚀 Conseils Pratiques

1. **Filtrez côté serveur** : `-Filter "Department -eq 'IT'"` plutôt que `-Filter * | Where-Object ...`. Dans le lab (13 comptes) ça ne change rien ; sur un annuaire de 50 000 comptes, `-Filter *` rapatrie tout.
2. **Demandez les propriétés dont vous avez besoin** : `-Properties Department, Title`. Gardez `-Properties *` pour explorer un seul objet (`Get-ADUser richard -Properties *`), pas pour tout l'annuaire.
3. **Testez vos commandes** avec un seul objet, puis avec `-WhatIf`, avant de les appliquer à tous
4. **Sauvegardez vos scripts** dans des fichiers `.ps1` (dans `C:\Scripts`)
5. **Utilisez les commentaires** (`#`) pour expliquer vos scripts

## 🌐 Diagnostic réseau et AD

Ces commandes ne font pas partie du module ActiveDirectory, mais ce sont les premières à lancer quand « le domaine ne marche pas ». La plupart fonctionnent dans une invite de commandes comme dans PowerShell.

```powershell
ipconfig /all                       # IP, passerelle et surtout serveur DNS (doit être 192.168.0.2)
nslookup dns1.maxtec.be             # le nom du DC se résout-il ?
Resolve-DnsName dns1.maxtec.be      # équivalent PowerShell, sortie en objets
Resolve-DnsName -Type SRV _ldap._tcp.dc._msdcs.maxtec.be   # les enregistrements qui permettent de trouver un DC
Test-NetConnection 192.168.0.2 -Port 53    # DNS joignable ?
Test-NetConnection 192.168.0.2 -Port 88    # Kerberos
Test-NetConnection 192.168.0.2 -Port 389   # LDAP
Test-NetConnection 192.168.0.2 -Port 445   # SMB (partages, SYSVOL, GPO)
klist                               # tickets Kerberos de la session en cours
klist purge                         # vider les tickets (après un changement de groupe, par exemple)
whoami /groups                      # groupes présents dans le jeton de la session
gpupdate /force                     # réappliquer les GPO immédiatement
gpresult /r                         # GPO appliquées à l'utilisateur et à l'ordinateur (résumé)
gpresult /h C:\Scripts\gpo.html     # même chose en rapport HTML détaillé
dcdiag /test:dns                    # (sur le DC) santé DNS du contrôleur de domaine
w32tm /query /status                # synchronisation de l'heure (Kerberos tolère 5 min d'écart)
nltest /dsgetdc:maxtec.be           # quel DC le poste utilise-t-il ?
```

## 📚 Ressources Supplémentaires

- [Documentation Microsoft PowerShell](https://learn.microsoft.com/fr-fr/powershell/)
- [Module Active Directory PowerShell](https://learn.microsoft.com/fr-fr/powershell/module/activedirectory/)
- [Get-Help](https://learn.microsoft.com/fr-fr/powershell/module/microsoft.powershell.core/get-help)

---

*Ce cheat sheet couvre les commandes essentielles pour démarrer avec PowerShell et Active Directory. Pour des besoins plus avancés, consultez la documentation complète.*
