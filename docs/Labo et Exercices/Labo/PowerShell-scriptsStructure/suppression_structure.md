# Script de Suppression de Structure Active Directory

## 🧭 Navigation
[⏮️ Retour au Labo](../Labo_structure.md) | [🏠 Retour au Syllabus](../../../index.md)

---

!!! danger "⚠️ ATTENTION - SCRIPT DESTRUCTIF"
    
    **🚨 Ce script SUPPRIME définitivement :**
    
    - ❌ Tous les utilisateurs du laboratoire
    - ❌ Tous les groupes de sécurité créés
    - ❌ Toute la structure d'OUs
    - ❌ Tous les ordinateurs associés
    
    **⚠️ UTILISEZ AVEC EXTRÊME PRÉCAUTION !**

!!! warning "🛡️ Prérequis de sécurité"
    
    - Exécuter UNIQUEMENT dans un environnement de laboratoire
    - Droits d'administrateur de domaine requis
    - **Sauvegarde complète** recommandée avant exécution
    - Vérifiez que vous êtes sur le bon domaine (`maxtec.be`)

---

## 🗑️ Utilisation du Script

!!! tip "💡 Comment utiliser"
    
    1. **⚠️ VÉRIFIEZ** que vous êtes dans un environnement de test
    2. **Copier le code** ci-dessous (utilisez le bouton de copie)
    3. **Sauvegarder** dans `C:\Scripts\suppression_structure.ps1`
    4. **Exécuter** avec PowerShell en tant qu'administrateur
    5. **Lire** l'inventaire et la simulation `-WhatIf`, puis taper `SUPPRIMER` pour confirmer

!!! info "🔄 Processus de suppression"
    
    1. Vérifie que le domaine est bien `maxtec.be` et que `OU=EU` existe
    2. Affiche l'inventaire des objets contenus dans `OU=EU` (par type)
    3. Lance une simulation `-WhatIf`
    4. Demande de taper `SUPPRIMER`
    5. Retire la protection contre la suppression accidentelle puis supprime `OU=EU` avec `-Recursive`

---

## 📜 Code du Script

```powershell
# Script de suppression de la structure du lab Maxtec
# Fichier : C:\Scripts\suppression_structure.ps1
# Supprime OU=EU et TOUT ce qu'elle contient (utilisateurs, groupes, ordinateurs, sous-OUs)

Import-Module ActiveDirectory

$rootOU = "OU=EU,DC=maxtec,DC=be"

# Garde-fou 1 : bon domaine
if ((Get-ADDomain).DNSRoot -ne 'maxtec.be') {
    Write-Host "Ce script est prévu pour le domaine maxtec.be. Arrêt." -ForegroundColor Red
    exit
}

# Garde-fou 2 : l'OU existe
try {
    $null = Get-ADOrganizationalUnit -Identity $rootOU
} catch {
    Write-Host "L'OU $rootOU n'existe pas : rien à supprimer." -ForegroundColor Yellow
    exit
}

# Inventaire de ce qui va disparaître
$objets = Get-ADObject -Filter * -SearchBase $rootOU
Write-Host "`nObjets qui seront supprimés :" -ForegroundColor Cyan
$objets | Group-Object ObjectClass | Select-Object Name, Count | Format-Table -AutoSize

# Simulation (-WhatIf) : rien n'est supprimé ici
Remove-ADOrganizationalUnit -Identity $rootOU -Recursive -WhatIf

# Confirmation explicite
$reponse = Read-Host "`nTapez SUPPRIMER pour confirmer (toute autre réponse annule)"
if ($reponse -cne 'SUPPRIMER') {
    Write-Host "Annulé. Aucune modification." -ForegroundColor Yellow
    exit
}

try {
    # Retirer la protection contre la suppression accidentelle sur TOUS les objets (OUs, mais aussi
    # utilisateurs ou groupes protégés pendant les exercices) : un seul objet protégé bloque -Recursive
    Get-ADObject -Filter * -SearchBase $rootOU -Properties ProtectedFromAccidentalDeletion |
        Where-Object { $_.ProtectedFromAccidentalDeletion } |
        Set-ADObject -ProtectedFromAccidentalDeletion $false -ErrorAction Stop

    Remove-ADOrganizationalUnit -Identity $rootOU -Recursive -Confirm:$false -ErrorAction Stop
    Write-Host "`nStructure supprimée." -ForegroundColor Green
    Write-Host "Les VMs clientes restent jointes au domaine mais leurs comptes ordinateur ont disparu :" -ForegroundColor Gray
    Write-Host "re-joignez-les (ou remettez-les en groupe de travail) après avoir relancé creation_structure." -ForegroundColor Gray
}
catch {
    Write-Host "`nERREUR : $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Objets restants dans l'OU :" -ForegroundColor Gray
    Get-ADObject -Filter * -SearchBase $rootOU -Properties ProtectedFromAccidentalDeletion -ErrorAction SilentlyContinue |
        Select-Object Name, ObjectClass, ProtectedFromAccidentalDeletion | Format-Table -AutoSize
}
```

---

## 🔧 Ce qu'il faut remarquer

!!! success "Bonnes pratiques appliquées"
    
    - **Une seule opération** : `Remove-ADOrganizationalUnit -Recursive` supprime tout le contenu de l'OU, y compris les objets créés pendant les exercices (nouveaux utilisateurs, groupes DL, ordinateurs joints). Pas de liste à maintenir.
    - **Simulation avant action** : `-WhatIf` montre ce qui serait supprimé.
    - **Confirmation non triviale** : taper un mot entier, sensible à la casse (`-cne`), évite le "O + Entrée" machinal.
    - **Erreurs réellement capturées** : `-ErrorAction Stop` transforme l'erreur en exception, sinon le `catch` ne se déclenche pas.

!!! info "Ce qui n'est pas supprimé"
    
    - Les GPOs : elles vivent hors des OUs (seuls leurs liens disparaissent). Nettoyage dans la GPMC ou avec `Get-GPO -All`.
    - Les partages et dossiers créés sur le serveur (`C:\Shares`…).
    - Les objets créés en dehors de `OU=EU`.

!!! danger "🚨 Avertissements critiques"
    
    - **⚠️ IRRÉVERSIBLE** : Les suppressions ne peuvent pas être annulées
    - **🔒 ENVIRONNEMENT** : Utilisez UNIQUEMENT en laboratoire
    - **💾 SAUVEGARDE** : Effectuez une sauvegarde avant exécution
    - **🎯 DOMAINE** : Vérifiez que vous êtes sur `maxtec.be`

---

## 🧭 Navigation
[⏮️ Retour au Labo](../Labo_structure.md) | [🏠 Retour au Syllabus](../../../index.md)

---

**📚 Cours Active Directory - Scripts PowerShell | 🗑️ Suppression de laboratoire**