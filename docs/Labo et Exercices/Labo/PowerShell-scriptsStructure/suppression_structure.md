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
    2. **Télécharger** le script avec le bouton ci-dessous
    3. **Placer** le fichier dans `C:\Scripts` sur le serveur et le **débloquer** (mêmes étapes que pour [le script de création](../Labo_structure.md#preparer-le-fichier-sur-le-serveur))
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

[⬇️ Télécharger suppression_structure.ps1](suppression_structure.ps1){ .md-button .md-button--primary download="suppression_structure.ps1" }

Le code ci-dessous est le contenu exact du fichier téléchargé.

```powershell
--8<-- "Labo et Exercices/Labo/PowerShell-scriptsStructure/suppression_structure.ps1"
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