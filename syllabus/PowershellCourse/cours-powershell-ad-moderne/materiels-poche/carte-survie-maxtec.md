# 🆘 CARTE DE SURVIE PowerShell AD - maxtec.be
*À imprimer et plastifier - Format 10x6 cm*

---

## RECTO - COMMANDES VITALES

### 🔍 DIAGNOSTIC RAPIDE
```powershell
# Utilisateur bloqué?
Get-ADUser -Identity [nom] -Properties Enabled,LockedOut,LastLogonDate

# Groupes d'un utilisateur?
Get-ADPrincipalGroupMembership -Identity [nom]

# Qui a les droits admin?
Get-ADGroupMember -Identity "Domain Admins"
```

### ⚡ ACTIONS SÉCURISÉES
```powershell
# Ajouter au groupe (TOUJOURS -WhatIf d'abord!)
Add-ADGroupMember -Identity [groupe] -Members [user] -WhatIf

# Désactiver compte (départ employé)
Set-ADUser -Identity [nom] -Enabled $false -WhatIf

# Déverrouiller compte
Unlock-ADAccount -Identity [nom] -WhatIf
```

### 🚨 RÈGLES D'OR
- **JAMAIS** sans -WhatIf d'abord
- **TOUJOURS** vérifier scope avant exécution
- **Si doute = STOP** et demander aide

---

## VERSO - INFO MAXTEC.BE

### 🏢 INFRASTRUCTURE
```
Domaine: maxtec.be
DC: dns1.maxtec.be (192.168.0.2)
Base: OU=EU,DC=maxtec,DC=be
```

### 📂 STRUCTURE OU
```
OU=EU,DC=maxtec,DC=be
├── OU=IT (Ivan, Ines, Irene)
├── OU=Ventes (Victor, Vanessa, Valeria)
├── OU=RH (Rene, Rebecca, Richard)
└── OU=Compta (Charles, Cindy, Charlotte)
```

### 🔄 SYNTAXE FILTRES
```powershell
# Égal
-Filter {Propriété -eq "Valeur"}

# Contient/commence
-Filter {Propriété -like "Val*"}

# Différent
-Filter {Propriété -ne "Valeur"}
```

### 🆘 URGENCE
- **Support**: admin@maxtec.be
- **Backup Admin**: richard@maxtec.be
- **En cas de panique**: RESPIRE, -WhatIf, puis demande aide

### ⚠️ COMMANDES DANGEREUSES
❌ `Remove-ADUser` sans -WhatIf
❌ `Get-ADUser -Filter *` sans limite
❌ Wildcards dans noms utilisateurs
❌ Scripts internet sans validation

---

*Carte v2.0 - "Post-désastre Julien" - Course PowerShell AD Moderne 2025*