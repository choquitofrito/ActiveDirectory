# Carte de référence PowerShell AD — maxtec.be
*Format recto-verso, à imprimer*

---

## Recto — commandes courantes

### Diagnostic
```powershell
# Compte désactivé ou verrouillé ?
Get-ADUser -Identity [nom] -Properties Enabled,LockedOut,LastLogonDate

# Groupes d'un utilisateur
Get-ADPrincipalGroupMembership -Identity [nom]

# Qui a les droits d'administration du domaine ?
Get-ADGroupMember -Identity "Admins du domaine"
```

### Actions (toujours avec `-WhatIf` d'abord)
```powershell
# Ajouter à un groupe
Add-ADGroupMember -Identity [groupe] -Members [user] -WhatIf

# Désactiver un compte (départ)
Set-ADUser -Identity [nom] -Enabled $false -WhatIf

# Déverrouiller un compte
Unlock-ADAccount -Identity [nom] -WhatIf
```

### Trois règles
- Pas de commande qui modifie sans `-WhatIf` d'abord.
- Vérifier la portée (combien d'objets ?) avant d'exécuter.
- En cas de doute, s'arrêter et demander.

---

## Verso — le lab maxtec.be

### Infrastructure
```
Domaine : maxtec.be
DC      : dns1.maxtec.be (192.168.0.2)
Base    : OU=EU,DC=maxtec,DC=be
```

### Structure des OUs
```
OU=EU,DC=maxtec,DC=be
├── OU=IT            (Ivan, Ines, Irene)
├── OU=Ventes        (Victor, Vanessa, Valeria, Valentin)
├── OU=RH            (Rene, Rebecca, Richard)
└── OU=Comptabilite  (Charles, Cindy, Charlotte)
```

### Syntaxe des filtres
```powershell
# Égal
-Filter {Propriété -eq "Valeur"}

# Commence par
-Filter {Propriété -like "Val*"}

# Différent
-Filter {Propriété -ne "Valeur"}
```

### Contacts
- **Support** : admin@maxtec.be
- **Admin de secours** : richard@maxtec.be
- **Incident** : arrêter, documenter, prévenir (voir Module 6)

### À ne pas faire
- `Remove-ADUser` sans `-WhatIf`
- `Get-ADUser -Filter *` sans `-SearchBase` ni limite
- Caractères génériques (`*`) pour désigner des utilisateurs précis
- Script trouvé en ligne exécuté sans l'avoir lu

---

*Carte v2.1 — Cours PowerShell AD 2026*
