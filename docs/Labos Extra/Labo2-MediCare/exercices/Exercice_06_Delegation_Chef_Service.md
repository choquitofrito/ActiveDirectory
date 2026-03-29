# Exercice 06 : Délégation Chef de Service

## Niveau: 🟡 Intermédiaire | Durée: 30-35 min

## Objectifs
- Utiliser l'**Assistant de Délégation de Contrôle**
- Appliquer le principe du **moindre privilège**
- Tester les permissions déléguées
- Vérifier les **limites de délégation**

## Scénario
Anne Leroy (Chef Nursing) doit gérer son équipe sans accès Domain Admin :

- Reset passwords infirmières
- Unlock accounts
- Modifier appartenance groupes Nursing
- **MAIS PAS** accéder aux comptes Medical

## Tâches

**Objectif** : Déléguer contrôle OU Nursing à Anne

### Contraintes
1. Utiliser **Delegation of Control Wizard**
2. OU cible : `OU=Nursing,OU=MediCare,DC=maxtec,DC=be`
3. Permissions déléguées :
   - Reset user passwords and force password change
   - Read all user information
   - Modify the membership of a group

4. Tester avec `runas /user:maxtec\anne powershell`
5. Vérifier refus d'accès sur Medical

### Indices
- Active Directory Users > OU Nursing > Déléguer le contrôle
- Tester : `Set-ADUser -Identity brigitte -Description "Test Anne"`
- Vérifier blocage : `Set-ADUser -Identity catherine -Description "Interdit"`

## Solution

### GUI
1. Ouvrir Active Directory Users and Computers
2. Clic droit sur `OU=Nursing,OU=MediCare` > **Déléguer le contrôle...**
3. Suivre assistant :
   - Utilisateur : `MAXTEC\anne`
   - Tâches : Cocher "Reset user passwords..." + "Modify membership of a group"
   - Terminer

### PowerShell (Test)
```powershell
# Tester délégation (en tant que anne)
runas /user:maxtec\anne "powershell -NoExit -Command 'Import-Module ActiveDirectory; Set-ADUser -Identity brigitte -Description \"Test délégation Anne OK\"'"

# Vérifier blocage Medical (doit échouer)
runas /user:maxtec\anne "powershell -NoExit -Command 'Import-Module ActiveDirectory; Set-ADUser -Identity catherine -Description \"INTERDIT\"'"
```

## Vérification
```powershell
C:\Labos\MediCare\scripts\verification\verif_exercice_06.ps1
```

## Exercice Suivant
**[Exercice 07 : Rotation de Spécialistes](Exercice_07_Rotation_Specialistes.md)**
