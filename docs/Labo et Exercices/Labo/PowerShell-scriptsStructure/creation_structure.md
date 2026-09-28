# Script de Création de Structure Active Directory

## 🧭 Navigation
[⏮️ Retour au Labo](../Labo_structure.md) | [🏠 Retour au Syllabus](../../../index.md)

---

!!! info "📋 À propos de ce script"
    
    Ce script PowerShell automatise la création complète de la structure Active Directory pour le laboratoire, incluant :
    
    - ✅ Unités d'Organisation (OUs)
    - ✅ Utilisateurs par département
    - ✅ Groupes de sécurité
    - ✅ Structure hiérarchique complète

!!! warning "⚠️ Prérequis"
    
    - Exécuter sur un contrôleur de domaine
    - Droits d'administrateur de domaine
    - Module Active Directory installé
    - Domaine `maxtec.be` configuré

---

## 📜 Code du Script

[⬇️ Télécharger creation_structure.ps1](creation_structure.ps1){ .md-button .md-button--primary download="creation_structure.ps1" }

!!! tip "💡 Comment utiliser"
    
    1. **Télécharger** le script avec le bouton ci-dessus
    2. **Placer** le fichier dans `C:\Scripts` sur le serveur et le **débloquer** (étapes détaillées dans [l'installation du lab](../Labo_structure.md#preparer-le-fichier-sur-le-serveur))
    3. **Exécuter** avec PowerShell en tant qu'administrateur
    4. **Suivre** les confirmations interactives

    Le code ci-dessous est le contenu exact du fichier téléchargé.

!!! note "Si vous copiez-collez le code au lieu de télécharger"
    Le fichier téléchargé est déjà en **UTF-8 avec BOM**. Si vous créez le fichier vous-même par copier-coller, enregistrez-le dans cet encodage : Windows PowerShell 5.1 lit un `.ps1` sans BOM comme de l'ANSI et les accents des messages s'affichent mal (`PrÃªt` au lieu de `Prêt`). Le script fonctionne quand même. Dans VS Code : cliquez sur `UTF-8` dans la barre d'état > *Enregistrer avec l'encodage* > *UTF-8 with BOM*. PowerShell ISE le fait par défaut.

```powershell
--8<-- "Labo et Exercices/Labo/PowerShell-scriptsStructure/creation_structure.ps1"
```

---

## 🔧 Fonctionnalités du Script

!!! success "✨ Fonctionnalités avancées"
    
    **🔍 Vérifications intelligentes**
    
    - Vérifie l'existence avant création
    - Évite les doublons
    - Gestion d'erreurs complète
    
    **🎯 Confirmations interactives**
    
    - Confirmation par étape
    - Possibilité de sauter des étapes
    - Arrêt sécurisé à tout moment
    
    **📊 Feedback visuel**
    
    - Messages colorés par type d'action
    - Progression claire et détaillée
    - Rapport de succès/erreurs

!!! info "📋 Structure créée"
    
    **Départements :**
    
    - 🏢 **Ventes** : Vanessa, Valeria, Victor, Valentin
    - 👥 **RH** : Richard, Rebecca, René  
    - 💰 **Comptabilité** : Charlotte, Cindy, Charles
    - 💻 **IT** : Ivan, Ines, Irene
    
    Chaque compte a `GivenName`, `Surname`, `Department` (= nom de l'OU, sans accent), `Title`, `EmailAddress` et `Country = BE` renseignés : les requêtes PowerShell du chapitre 9 s'appuient dessus.

    **Groupes de sécurité :**
    
    - `GG-EU-Ventes-Admin` / `GG-EU-Ventes-Users`
    - `GG-EU-RH-Admin` / `GG-EU-RH-Users`
    - `GG-EU-Compta-Admin` / `GG-EU-Compta-Users`
    - `GG-EU-IT-Admin` / `GG-EU-IT-Users`

!!! warning "🛡️ Sécurité"
    
    - **Mot de passe par défaut** : `Password1!`
    - **⚠️ Important** : mot de passe identique pour tous et écrit en clair dans le script — acceptable en lab, jamais en production
    - **Protection** : OUs non protégées contre suppression accidentelle

---

## 🧭 Navigation
[⏮️ Retour au Labo](../Labo_structure.md) | [🏠 Retour au Syllabus](../../../index.md)

---

**📚 Cours Active Directory - Scripts PowerShell | 👨‍💻 Pour laboratoire**