# Carte de référence PowerShell AD — maxtec.be
*Format recto-verso, à imprimer*

---

## Recto — commandes courantes

### Diagnostic
```powershell
# Compte désactivé ou verrouillé ?
Get-ADUser -Identity [nom] -Properties LockedOut,LastLogonDate   # Enabled est renvoyé par défaut

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

Dans chaque service : OU=Users (comptes), OU=Groups (GG-EU-<service>-Users / -Admin),
OU=Computers. Exemple : OU=Users,OU=RH,OU=EU,DC=maxtec,DC=be
Login = prénom en minuscules (richard). Mot de passe du lab : Password1!
```

### Syntaxe des filtres
```powershell
# Égal
-Filter {Propriété -eq "Valeur"}

# Commence par
-Filter {Propriété -like "Val*"}

# Différent
-Filter {Propriété -ne "Valeur"}

# Avec une variable : chaîne entre guillemets doubles (forme la plus fiable)
-Filter "Department -eq '$service'"
```

### Contacts
- **Support** : admin@maxtec.be
- **Admin de secours** : irene@maxtec.be
- **Incident** : arrêter, documenter, prévenir (voir Module 6)

### À ne pas faire
- `Remove-ADUser` sans `-WhatIf`
- `Get-ADUser -Filter *` sans `-SearchBase` ni limite
- Caractères génériques (`*`) pour désigner des utilisateurs précis
- Script trouvé en ligne exécuté sans l'avoir lu

---

*Carte v2.1 — Cours PowerShell AD 2026*
