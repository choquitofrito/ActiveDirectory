### Exercice 1: Création d'un Nouvel Employé

!!! example "Contexte"
    
    Le département Comptabilité de Maxtec accueille une nouvelle comptable junior, Sophie Dubois.

!!! info "Tâches à réaliser"
    
    1. Créer un compte utilisateur pour Sophie en suivant la convention de nommage établie (`prenom.nom`)
    2. Définir un mot de passe temporaire qui respecte la politique de sécurité
    3. Configurer le compte pour que Sophie doive changer son mot de passe à la première connexion
    4. Remplir les informations de base:
        - Description: "Comptable Junior - Comptabilité"
        - Bureau: "Bâtiment A - 1er étage"
        - Téléphone: "+32 2 123 45 68"
        - Placer le compte dans `OU=Users,OU=Comptabilite,OU=EU,DC=maxtec,DC=be`

### Exercice 2: Restrictions d'Accès

!!! warning "Contraintes de sécurité"
    
    Pour des raisons de sécurité, Sophie ne doit pouvoir se connecter que:
    
    - Sur le poste `ws-Compta-01.maxtec.be`
    - Du lundi au vendredi, de 8h à 18h (choisissez une heure qui vous permet de tester la connexion)

!!! info "Tâches à réaliser"
    
    1. Configurer les restrictions de connexion pour les postes de travail
    2. Définir les plages horaires autorisées


### Exercice 3: Audit de Sécurité `GPO`

!!! example "Objectif"
    
    Vous devez vérifier les paramètres de sécurité du compte de Sophie.

!!! info "Tâches à réaliser"
    
    1. Vérifier que le compte suit la politique de mot de passe
    2. Confirmer que le compte expire dans 6 mois (durée du contrat d'essai)
    3. Activer la journalisation des tentatives de connexion échouées

??? success "Solution"

    **Tâche 1 — Vérifier la politique de mot de passe**

    La politique s'applique automatiquement au niveau du domaine. Pour consulter la politique active :

    `Outils` → `Gestion des stratégies de groupe` → double-clic sur `Default Domain Policy` → onglet `Paramètres` → `Configuration ordinateur > Paramètres Windows > Paramètres de sécurité > Stratégies de compte`

    Pour vérifier si le compte a une politique spécifique (Fine-Grained) :

    `Utilisateurs et ordinateurs AD` → clic droit sur l'utilisateur → `Objet de paramètres de mot de passe résultant`

    ---

    **Tâche 2 — Expiration du compte dans 6 mois**

    `Utilisateurs et ordinateurs AD` → double-clic sur le compte → onglet **`Compte`**

    Dans la section **"Le compte expire"** : sélectionner `Fin de :` et saisir la date (aujourd'hui + 6 mois).

    ---

    **Tâche 3 — Journalisation des tentatives de connexion échouées**

    Cette configuration se fait via GPO, pas sur le compte individuel.

    Dans `Default Domain Policy` (ou une GPO dédiée) :

    ```
    Configuration ordinateur
      → Paramètres Windows
        → Paramètres de sécurité
          → Stratégies locales
            → Stratégie d'audit
              → Auditer les événements de connexion → ✅ Échecs
    ```

    Après application (`gpupdate /force`), les tentatives échouées apparaissent dans :

    `Observateur d'événements` → `Journaux Windows` → `Sécurité` → **ID d'événement 4625**

### Exercice 4: Désactivation d'un Compte

!!! warning "Situation"
    
    Charles (`charles@maxtec.be`), comptable au département Comptabilité, quitte l'entreprise aujourd'hui.

!!! info "Tâches à réaliser"
    
    1. Désactiver son compte utilisateur
    2. Documenter la désactivation dans le champ "Description" des propriétés du compte avec:
        - Date de désactivation
        - Raison: "Départ de l'entreprise"
        - Date de suppression prévue (dans 90 jours)
       
        !!! note "Note"

            Le champ "Description" se trouve dans l'onglet "Général" des propriétés du compte
    
    3. Vérifier qu'il ne peut plus se connecter

### Exercice 5: Nettoyage des Accès

!!! example "Contexte"
    
    Suite au départ de Charles:

!!! info "Tâches à réaliser"
    
    1. Identifier tous les groupes dont il est membre
    2. Le retirer de tous les groupes sauf "Domain Users"

### Exercice 6: Gestion des Homonymes

!!! example "Situation"
    
    Deux nouveaux employés arrivent dans le service RH:
    
    - Karim Benali (Recruteur Senior)
    - Karim Benali (Assistant RH)

!!! info "Tâches à réaliser"
    
    1. Créer les comptes pour les deux Karim Benali dans `OU=Users,OU=RH,OU=EU,DC=maxtec,DC=be` en évitant les conflits
    2. Documenter clairement dans chaque compte le poste occupé
    3. S'assurer que leurs adresses email restent professionnelles et cohérentes

### Exercice 7: Compte Temporaire

!!! example "Contexte"
    
    Un consultant externe, Marek Wojcik, arrive pour un audit informatique de 3 mois. Il travaillera depuis le poste de l'équipe IT.

!!! info "Tâches à réaliser"
    
    1. Créer un compte temporaire avec:
        - Date d'expiration automatique dans 90 jours
        - Accès limité à `ws-IT-01.maxtec.be` uniquement
        - Heures de connexion: 9h-17h, jours ouvrés
    
    2. Ajouter un préfixe "EXT-" dans la description

### Exercice 8: Vérification des Comptes Inactifs

!!! example "Rôle"
    
    En tant qu'administrateur, vous devez faire le ménage dans les comptes.

!!! info "Tâches à réaliser"
    
    1. Identifier les comptes qui n'ont pas été utilisés depuis 30 jours
    2. Pour chaque compte inactif:
        - Vérifier s'il s'agit d'un départ non signalé
        - Documenter le statut dans la description
        - Préparer une liste pour la direction

### Exercice 9: Mise à Jour des Informations

!!! example "Contexte"
    
    Suite à un déménagement interne, le département Comptabilité change d'étage. Charlotte, Cindy et Sophie doivent avoir leurs informations mises à jour.

!!! info "Tâches à réaliser"
    
    1. Mettre à jour les informations de bureau **pour Charlotte, Cindy et Sophie** (département Comptabilité):
        - Nouveau bureau: "Bâtiment B - 3e étage"
        - Nouveau téléphone: format "+32 2 123 XX YY"
    
    2. Vérifier que les chemins réseau sont toujours valides
    3. Documenter les changements effectués

### Exercice 10: Résolution des Problèmes de Connexion

!!! warning "Problème signalé"
    
    L'utilisatrice Ines (`ines@maxtec.be`, département IT) signale qu'elle ne peut plus se connecter.

!!! info "Tâches à réaliser"
    
    1. Vérifier l'état du compte (verrouillé, désactivé, expiré?)
    2. Examiner les restrictions de connexion:
        - Postes de travail autorisés
        - Plages horaires
        - Stratégie de mot de passe
    
    3. Résoudre le problème en documentant chaque étape

### Exercice 11: Gestion des Profils Itinérants `GPO`

!!! example "Objectif"
    
    Vous devez configurer des profils itinérants pour l'équipe Ventes qui se déplace entre plusieurs postes.

!!! info "Tâches à réaliser"
    
    1. Créer un partage réseau pour les profils itinérants sur le serveur (`\\dns1\Profiles$`)
    2. Configurer le profil itinérant pour trois commerciaux:
        - Vanessa
        - Victor
        - Valeria
    
    3. Vérifier que leurs paramètres personnels sont conservés entre les postes
    4. Configurer une limite de taille pour les profils (500 MB) via GPO:

        ```
        Configuration utilisateur
          → Modèles d'administration
            → Système
              → Profils utilisateur
                → Limiter la taille du profil → Activé → 512000 Ko
        ```

### Exercice 12: Délégation d'Administration

**Niveau** : 🟡 Intermédiaire · **Durée** : 30-45 min

!!! example "Objectif"

    Permettre aux responsables de département (Richard pour RH, Valentin pour Ventes) de gérer leur propre équipe **sans être Domain Admin**, en appliquant le principe du moindre privilège.

#### 📋 Prérequis

- Lab Maxtec déployé (structure du `creation_structure.ps1` en place)
- Groupes `GG-EU-RH-Admin` (contient Richard) et `GG-EU-Ventes-Admin` (contient Valentin) existants
- Au moins une VM cliente jointe au domaine (ex: `ws-RH-01` ou `ws-Ventes-01`)
- Session ouverte sur le DC ou sur un poste avec RSAT, en tant que `maxtec\Administrateur`

---

#### 🛠️ Installation préalable : RSAT sur le poste client

La délégation se **configure** depuis n'importe quel poste qui a `dsa.msc` (le DC l'a nativement). On l'**utilise** depuis le poste de la personne déléguée, qui doit donc disposer de RSAT.

!!! info "Pourquoi RSAT ?"

    `gpmc.msc` et `dsa.msc` ne tournent **pas sur le DC** : ce sont des consoles d'administration distantes qui parlent au DC par LDAP. RSAT (Remote Server Administration Tools) installe ces consoles sur un poste client Windows. Une fois RSAT installé, **les permissions viennent du compte qui ouvre la console**, pas de l'installation elle-même.

**Procédure (à exécuter sur le poste client, ex: `ws-RH-01`)** :

1. **Connectez-vous en tant qu'administrateur local** du poste (la cuenta créée à l'install Windows). RSAT est un composant Windows, son installation requiert des droits admin **locaux** (pas de domaine).
2. **Ouvrir le menu Fonctionnalités facultatives** : touche Windows → taper **`facultative`** → cliquer sur **Fonctionnalités facultatives**.
3. **Ajouter une fonctionnalité** :
   - Cliquer sur **Ajouter une fonctionnalité**
   - Dans la barre de recherche, taper **RSAT**
   - Cocher **RSAT : Outils Active Directory Domain Services et Services LDS** (inclut `dsa.msc`)
   - Cocher aussi **RSAT : Outils de gestion des stratégies de groupe** (inclut `gpmc.msc`) — utile pour les exercices GPO ultérieurs
   - Cliquer sur **Suivant** puis **Installer**
4. **Redémarrer** le poste si Windows le demande.

**Vérification — RSAT fonctionne** :

Ouvrir **PowerShell** (sans privilèges admin) sur le poste client et lancer :

```powershell
Get-ADUser -Filter * -SearchBase "OU=RH,OU=EU,DC=maxtec,DC=be" |
    Select-Object Name, SamAccountName
```

Vous devriez voir Richard, Rebecca et René. Si vous obtenez :

- *"Get-ADUser n'est pas reconnu"* → le module RSAT AD n'est pas installé, reprenez l'étape 3
- *"Impossible de contacter un serveur Active Directory"* → le poste n'est pas joint au domaine `maxtec.be`

**Bonus GUI** : tapez `dsa.msc` dans Démarrer. La console "Utilisateurs et ordinateurs Active Directory" doit s'ouvrir et afficher le domaine `maxtec.be` avec ses OUs.

---

#### 📖 Contexte / Scénario

Le manager IT de Maxtec, sous l'eau avec les demandes de support, vous résume la nouvelle politique :

> *"On reçoit 40 reset password par mois et 8 créations de comptes. Les chefs de service peuvent gérer ça eux-mêmes. À chacun son périmètre, et personne ne touche aux autres départements. Voici ce que je veux :"*

**Politique de délégation** :

| Délégué | Groupe AD | Périmètre | Permissions accordées | Permissions refusées |
|---------|-----------|-----------|----------------------|----------------------|
| **Richard** | `GG-EU-RH-Admin` | `OU=Users,OU=RH,OU=EU,DC=maxtec,DC=be` | Reset password<br>Déverrouillage compte | Création/suppression<br>Accès autres dépts |
| **Valentin** | `GG-EU-Ventes-Admin` | `OU=Users,OU=Ventes,OU=EU,DC=maxtec,DC=be` | Création utilisateurs<br>Modification propriétés<br>Reset password | Suppression utilisateurs<br>Accès autres dépts |

!!! tip "Bonne pratique : déléguer au groupe, pas à l'utilisateur"

    On délègue toujours à `GG-EU-RH-Admin`, **pas directement à Richard**. Si demain Richard est remplacé, il suffit d'ajouter le remplaçant au groupe sans toucher à la délégation. C'est la même logique que pour l'attribution de permissions NTFS via AGDLP.

---

#### 📌 Étape 1 : Déléguer à Richard (RH — périmètre restreint)

**Sur le DC**, en tant que `maxtec\Administrateur` :

1. Ouvrir **`dsa.msc`** (Utilisateurs et ordinateurs Active Directory)
2. Activer l'affichage avancé : menu **Affichage** → **Fonctionnalités avancées** (nécessaire pour voir l'onglet Sécurité plus tard)
3. Naviguer jusqu'à `EU > RH`
4. **Clic droit sur l'OU `Users`** (à l'intérieur de RH) → **Déléguer le contrôle…**
5. L'assistant s'ouvre → **Suivant**
6. **Sélectionner Users or Groups** :
   - **Ajouter…** → taper `GG-EU-RH-Admin` → **Vérifier les noms** → **OK**
   - **Suivant**
7. **Sélectionner les tâches à déléguer** → cocher :
   - ✅ **Réinitialiser les mots de passe utilisateur et forcer le changement de mot de passe à la prochaine ouverture de session**
   - ✅ **Lire toutes les informations utilisateur**
   - ❌ NE PAS cocher *Créer, supprimer et gérer les comptes utilisateur*
   - **Suivant**
8. **Terminer**

!!! info "Et le déverrouillage de compte ?"

    L'assistant standard ne propose pas explicitement "déverrouillage". Il est inclus indirectement quand on coche "Réinitialiser les mots de passe" (le déverrouillage est techniquement une modification de l'attribut `lockoutTime`, généralement autorisée avec le reset). Pour un déverrouillage explicite et séparé, il faut utiliser la délégation personnalisée (option **Créer une tâche personnalisée à déléguer**).

---

#### 📌 Étape 2 : Déléguer à Valentin (Ventes — périmètre étendu)

1. Toujours dans `dsa.msc`, naviguer jusqu'à `EU > Ventes`
2. **Clic droit sur l'OU `Users`** (à l'intérieur de Ventes) → **Déléguer le contrôle…**
3. Assistant → **Suivant**
4. **Ajouter** `GG-EU-Ventes-Admin` → **Vérifier les noms** → **OK** → **Suivant**
5. **Tâches à déléguer** → cocher :
   - ✅ **Créer, supprimer et gérer les comptes utilisateur** ⚠️ (l'assistant Microsoft regroupe création **et** suppression — voir la note ci-dessous)
   - ✅ **Réinitialiser les mots de passe utilisateur et forcer le changement de mot de passe à la prochaine ouverture de session**
   - ✅ **Lire toutes les informations utilisateur**
   - ✅ **Modifier l'appartenance d'un groupe**
   - **Suivant** → **Terminer**

!!! warning "Limitation de l'assistant standard"

    L'assistant regroupe **"Créer, supprimer et gérer"** dans une seule case. Si vous voulez vraiment **autoriser la création MAIS interdire la suppression**, il faut passer par **Créer une tâche personnalisée à déléguer** (option dans l'assistant à l'étape "Tâches"), puis sélectionner les attributs précis. Pour cet exercice, on accepte la limitation et on documente le compromis. C'est aussi l'occasion d'expliquer aux étudiants que les wizards Microsoft sont des raccourcis : pour du fine-grained, c'est `dsacls` ou PowerShell + `Set-Acl`.

---

#### 🧪 Étape 3 : Tester les délégations

**Test A — Richard (devrait réussir)** :

Sur `ws-RH-01` (avec RSAT installé) :

1. Se connecter en tant que `maxtec\richard`
2. Ouvrir `dsa.msc`
3. Naviguer jusqu'à `EU > RH > Users`
4. Clic droit sur **René** → **Réinitialiser le mot de passe** → définir un nouveau mot de passe → **OK**
5. ✅ Doit fonctionner

**Test B — Richard (devrait échouer)** :

1. Toujours connecté en tant que Richard, naviguer jusqu'à `EU > Comptabilite > Users`
2. Clic droit sur **Charlotte** → **Réinitialiser le mot de passe**
3. ❌ Doit échouer avec *"Accès refusé"*

**Test C — Richard (limite explicite)** :

1. Clic droit sur `OU=Users` (dans RH) → **Nouveau** → **Utilisateur**
2. ❌ L'option doit être grisée ou échouer — Richard n'a pas la délégation de création

**Test D — Valentin (création autorisée)** :

Sur `ws-Ventes-01` (ou via `runas /user:maxtec\valentin "mmc dsa.msc"` depuis le DC) :

1. Naviguer jusqu'à `EU > Ventes > Users`
2. Clic droit → **Nouveau** → **Utilisateur** → créer `vincent.test` avec mot de passe temporaire
3. ✅ Doit fonctionner

**Test E — Valentin (frontière respectée)** :

1. Valentin tente de créer un utilisateur dans `EU > IT > Users`
2. ❌ Doit échouer

---

#### ✅ Vérification PowerShell (audit de la délégation)

Pour confirmer que les ACLs ont bien été posées sur les OUs, exécuter sur le DC (ou un poste avec RSAT) en tant que Domain Admin :

```powershell
# Importer le module RSAT AD
Import-Module ActiveDirectory

# Audit de l'OU Users de RH
$ouRH = "AD:\OU=Users,OU=RH,OU=EU,DC=maxtec,DC=be"
Get-Acl $ouRH | Select-Object -ExpandProperty Access |
    Where-Object { $_.IdentityReference -like "*GG-EU-RH-Admin*" } |
    Format-Table IdentityReference, ActiveDirectoryRights, AccessControlType -AutoSize

# Audit de l'OU Users de Ventes
$ouVentes = "AD:\OU=Users,OU=Ventes,OU=EU,DC=maxtec,DC=be"
Get-Acl $ouVentes | Select-Object -ExpandProperty Access |
    Where-Object { $_.IdentityReference -like "*GG-EU-Ventes-Admin*" } |
    Format-Table IdentityReference, ActiveDirectoryRights, AccessControlType -AutoSize
```

Vous devez voir des entrées `Allow` pour `MAXTEC\GG-EU-RH-Admin` et `MAXTEC\GG-EU-Ventes-Admin` avec des droits comme `ReadProperty`, `WriteProperty`, `ExtendedRight` (sur `User-Force-Change-Password`), etc.

---

#### ❓ Questions de réflexion

1. **Pourquoi déléguer à `GG-EU-RH-Admin` et pas directement à Richard ?** Que se passe-t-il si Richard part en congé maladie et que Rebecca doit le remplacer ?

2. **Que voit Richard dans `dsa.msc` ?** Voit-il les OUs des autres départements ? Pourquoi ?

3. **Limite de l'assistant** : pourquoi le wizard de Microsoft regroupe-t-il "création" et "suppression" ? Comment contourner cette limitation si la politique exige une séparation stricte ?

4. **Sécurité** : un délégué pourrait-il s'élever en privileges via sa délégation ? (Indice : peut-il modifier l'appartenance de son propre compte au groupe Domain Admins ?)

---

#### 💡 Pour aller plus loin

- **Délégation fine-grained** : `dsacls` en ligne de commande ou `Set-Acl` en PowerShell pour spécifier exactement quels attributs (ex: `mail`, `telephoneNumber`) peuvent être modifiés.
- **Délégation GPO** : voir `Exercices: GPO-2.md` Ex. 7 — c'est l'équivalent pour les GPOs (Security Filtering + onglet Delegation + droit de lier des GPOs à une OU).
- **Audit** : activer l'audit des modifications d'ACL (`auditpol /set /subcategory:"Directory Service Changes" /success:enable`) pour tracer qui modifie quoi.

### Exercice 13: Migration d'Utilisateurs

!!! example "Contexte"
    
    Suite à une restructuration, Ivan et Ines (département IT) rejoignent l'équipe Ventes. Irene reste seule responsable IT.

!!! info "Tâches à réaliser"
    
    1. Identifier les utilisateurs à déplacer (Ivan et Ines)
    2. Planifier la migration:
        - Nouveaux groupes nécessaires
        - Modifications des droits d'accès
    
    3. Déplacer les comptes vers `OU=Users,OU=Ventes,OU=EU,DC=maxtec,DC=be`
    4. Mettre à jour toutes les appartenances aux groupes:
        - Retirer de `GG-EU-IT-Users`
        - Ajouter à `GG-EU-Ventes-Users`
    5. Vérifier que les accès fonctionnent correctement

### Exercice 14: Gestion des Comptes de Service

!!! example "Objectif"
    
    Créer et sécuriser des comptes de service pour les applications internes de Maxtec.

!!! info "Tâches à réaliser"
    
    1. Créer trois comptes de service:
        - `svc-backup` (pour les sauvegardes)
        - `svc-monitoring` (pour la surveillance)
        - `svc-print` (pour le serveur d'impression)
    
    2. Configurer les paramètres de sécurité:
        - Mots de passe complexes
        - Pas d'expiration de mot de passe
        - Connexion limitée aux serveurs spécifiques (`dns1.maxtec.be`)
    
    3. Documenter les comptes dans un registre
