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
    3. **Sauvegarder** dans un fichier `suppression_structure.ps1`
    4. **Exécuter** avec PowerShell en tant qu'administrateur
    5. **Confirmer** chaque action si demandé

!!! info "🔄 Processus de suppression"
    
    Le script suit cet ordre logique :
    
    1. **👥 Utilisateurs** → Suppression de tous les comptes
    2. **💻 Ordinateurs** → Suppression des machines du domaine
    3. **🏷️ Groupes** → Suppression des groupes de sécurité
    4. **📁 Structure OU** → Suppression récursive des unités d'organisation

---

## 📜 Code du Script

```powershell
# Script pour supprimer la structure des OUs
# Stocker ce script dans un fichier supression.ps1

# ATTENTION: Ce script supprime des objets AD. À utiliser avec précaution!

# Importer le module Active Directory
Import-Module ActiveDirectory

# Fonction pour supprimer récursivement les OUs
function Remove-OUStructure {
    param (
        [Parameter(Mandatory=$true)]
        [string]$OUPath
    )
    
    # Récupérer toutes les sous-OUs
    $childOUs = Get-ADOrganizationalUnit -Filter * -SearchBase $OUPath -SearchScope OneLevel
    
    foreach ($childOU in $childOUs) {
        # Supprimer récursivement les sous-OUs
        Remove-OUStructure -OUPath $childOU.DistinguishedName
        
        # Désactiver la protection contre la suppression accidentelle
        Set-ADOrganizationalUnit -Identity $childOU.DistinguishedName -ProtectedFromAccidentalDeletion $false
        
        # Supprimer l'OU
        Write-Host "Suppression de l'OU: $($childOU.Name)"
        Remove-ADOrganizationalUnit -Identity $childOU.DistinguishedName -Confirm:$false
    }
}

# Chemin de base pour l'OU EU
$baseOU = "OU=EU,DC=maxtec,DC=be"

try {
    # 1. Supprimer les utilisateurs
    Write-Host "Suppression des utilisateurs..."
    $users = @(
        "vanessa", "valeria", "victor", "valentin",  # Ventes
        "richard", "rebecca", "rene",                # RH
        "charlotte", "cindy", "charles"              # Comptabilité
    )
    
    foreach ($user in $users) {
        $userDN = "CN=$user,*,OU=EU,DC=maxtec,DC=be"
        Get-ADUser -Filter {SamAccountName -eq $user} | Remove-ADUser -Confirm:$false
        Write-Host "Utilisateur supprimé: $user"
    }
    
    # 2. Supprimer les ordinateurs
    Write-Host "Suppression des ordinateurs..."
    $computers = @(
        "ws-ventes-01", "ws-ventes-02",  # Ventes
        "ws-RH-01", "ws-RH-02",          # RH
        "ws-compta-01", "ws-compta-02"   # Comptabilité
    )
    
    foreach ($computer in $computers) {
        Get-ADComputer -Filter {Name -eq $computer} | Remove-ADComputer -Confirm:$false
        Write-Host "Ordinateur supprimé: $computer"
    }
    
    # 3. Supprimer les groupes
    Write-Host "Suppression des groupes..."
    $groups = @(
        "GG-EU-Ventes-Admin", "GG-EU-Ventes-Users",    # Ventes
        "GG-EU-RH-Admin", "GG-EU-RH-Users",           # RH
        "GG-EU-Compta-Admin", "GG-EU-Compta-Users"    # Comptabilité
    )
    
    foreach ($group in $groups) {
        Get-ADGroup -Filter {Name -eq $group} | Remove-ADGroup -Confirm:$false
        Write-Host "Groupe supprimé: $group"
    }
    
    # 4. Supprimer la structure d'OUs
    Write-Host "Suppression de la structure d'OUs..."
    
    # Désactiver la protection contre la suppression accidentelle sur l'OU racine
    Set-ADOrganizationalUnit -Identity $baseOU -ProtectedFromAccidentalDeletion $false
    
    # Supprimer récursivement toute la structure
    Remove-OUStructure -OUPath $baseOU
    
    # Supprimer l'OU racine EU
    Remove-ADOrganizationalUnit -Identity $baseOU -Confirm:$false
    Write-Host "OU racine EU supprimée"
    
    Write-Host "Structure supprimée avec succès!"
}
catch {
    Write-Error "Une erreur s'est produite: $_"
}
```

---

## 🔧 Fonctionnalités du Script

!!! success "✨ Fonctionnalités techniques"
    
    **🔄 Suppression récursive**
    
    - Fonction `Remove-OUStructure` pour suppression hiérarchique
    - Gestion automatique des dépendances
    - Désactivation de la protection contre suppression accidentelle
    
    **🎯 Ordre de suppression intelligent**
    
    - Utilisateurs → Ordinateurs → Groupes → Structure OU
    - Évite les erreurs de dépendances
    - Progression logique et sécurisée
    
    **🛡️ Gestion d'erreurs**
    
    - Try-catch global pour capturer les erreurs
    - Messages informatifs pour chaque suppression
    - Arrêt sécurisé en cas de problème

!!! info "📋 Objets supprimés"
    
    **👥 Utilisateurs supprimés :**
    
    - **Ventes** : vanessa, valeria, victor, valentin
    - **RH** : richard, rebecca, rené
    - **Comptabilité** : charlotte, cindy, charles
    
    **💻 Ordinateurs supprimés :**
    
    - **Ventes** : ws-ventes-01, ws-ventes-02
    - **RH** : ws-RH-01, ws-RH-02
    - **Comptabilité** : ws-compta-01, ws-compta-02
    
    **🏷️ Groupes supprimés :**
    
    - Tous les groupes `GG-EU-*-Admin` et `GG-EU-*-Users`

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