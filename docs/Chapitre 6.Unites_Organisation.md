# Chapitre 6 : Unités d'organisation (UOs)

## 🧭 Navigation du Cours
[⏮️ Chapitre Précédent: DNS Pratique avec AD](Chapitre%205.DNS-Pratique-avec-AD.md) | [🏠 Retour au Syllabus](index.md) | [⏭️ Chapitre Suivant: Gestion des Utilisateurs](Chapitre%207.Gestion_des_Utilisateurs.md)


!!! example "Exercices associés"
    Après la théorie, passez à la pratique :

    - **[Exercice OUs Départements](Labo%20et%20Exercices/Exercices:%20OUs_Departements_Complementaires.md)** - Créer des OUs et utilisateurs pour les départements complémentaires de maxtec.be
    - **[Exercice 12 : Délégation d'administration](Labo%20et%20Exercices/Exercices:%20Gestion_des_Utilisateurs.md#exercice-12-delegation-dadministration)** - Déléguer la gestion des comptes RH et Ventes (à faire après ce chapitre et le chapitre 7)

---

!!! info "📚 Dans ce chapitre :"

    1. [Structure organisationnelle](#2-structure-organisationnelle)
       - Concepts fondamentaux
       - Hiérarchie des UOs

    2. [Administration](#6-gestion-des-ous)
       - Création et configuration
       - Bonnes pratiques

    3. [Délégation de contrôle](#9-delegation-de-controle)
       - Principe et mise en place
       - Test depuis le poste client

---

## 1. 📙 Objectifs pédagogiques

À la fin de ce chapitre, vous serez capable de :

1. Créer, déplacer et supprimer une OU (y compris une OU protégée) dans ADUC
2. Expliquer en une phrase la différence entre une OU et un conteneur par défaut (`Users`, `Computers`)
3. Justifier la structure `EU/<Département>/{Users,Computers,Groups}` du lab Maxtec
4. Déléguer une tâche précise (réinitialisation de mot de passe) sur une OU à un groupe `GG-`, puis tester cette délégation depuis un poste client

---

## 2. 🏢 Structure organisationnelle

### 📂 Concept des unités d'organisation

Une **unité d'organisation** (UO) est un **conteneur Active Directory** offrant :

1. 🏢 **Organisation Logique**
   - 📂 Regroupement d'objets AD
   - 📊 Structure hiérarchique
   - 🏢 Reflet de l'entreprise

2. ⚙️ **Gestion Administrative**
   - 🔐 Délégation de droits
   - 📂 Gestion des ressources
   - 🔒 Application des GPOs

!!! tip "Analogie"

    Une UO ressemble à un dossier sur votre disque : elle range des objets. La différence, c'est qu'on peut lui **lier des GPOs** et lui **attacher des permissions** (délégation), qui s'appliquent à tout ce qu'elle contient.

## 3. 📂 Structure des OUs

### 3.1 📊 Hiérarchie des Contenus

```
OU
├── Utilisateurs (ex: rebecca)
├── Groupes (ex: GG-EU-Compta-Users)
├── Ordinateurs (ex: ws-RH-01)
├── Autres OUs
└── Autres objets (imprimantes, contacts)
```

### 3.2 Avantages vs Conteneurs par Défaut

| Fonctionnalité | Conteneur par Défaut | OU |
|-----------------|---------------------|----|
| Organisation | Fixe | **Flexible** |
| GPOs | Non | **Oui** |
| Délégation | Limitée | **Complète** |
| Structure | Plate | **Hiérarchique** (arbre d'OUs et héritage) |

## 🎯 Checkpoint: Concept des UOs

!!! info "Vérification de compréhension"

    Avant de créer vos premières UOs, vérifiez votre compréhension :

    - [ ] Une UO est un conteneur sur lequel on peut lier des GPOs et déléguer des droits
    - [ ] Elle peut contenir utilisateurs, groupes, ordinateurs et d'autres OUs
    - [ ] On ne peut **pas** lier de GPO aux conteneurs par défaut `Users` et `Computers`
    - [ ] Savoir pourquoi un poste resté dans `CN=Computers` ne reçoit aucune GPO d'OU

## 4. 🔧 Création d'une OU

!!! example "Procédure de création"

    1. **Ouvrir la Console**
       ```
       Utilisateurs et ordinateurs d'Active Directory
       ```

    2. **Créer l'OU**
       ```
       Domaine AD ou OU parent → Clic droit
       ├── Nouveau
       └── Unité d'organisation
       ```

    3. **Nommage**
       ```
       Format: [Location]/[Département]
       Exemple: EU/Comptabilite
       ```

    4. **Protection**
       ```
       ☑ Protéger contre la suppression
       ```

!!! tip "Nommage"

    Utilisez des noms simples et clairs, sans espaces, accents ni caractères spéciaux (d'où `Comptabilite` sans accent dans le lab).

!!! warning "Protection contre la suppression : production vs lab"

    - **En production** : cochez toujours cette option. Une OU supprimée par erreur emporte tous les comptes qu'elle contient.
    - **Dans le lab** : le script `creation_structure.ps1` crée les OUs **sans** protection (`-ProtectedFromAccidentalDeletion $false`), pour que `suppression_structure.ps1` puisse tout remettre à zéro. Si vous créez une OU à la main dans le lab, vous pouvez cocher la case, mais il faudra la décocher avant de la supprimer (voir ci-dessous).

## 5. 🗑️ Suppression d'une OU Protégée

!!! warning "Procédure de suppression"

    ### 5.1 Activation des Fonctionnalités Avancées

    1. **Ouvrir ADUC**
       ```
       Active Directory Users and Computers
       ```

    2. **Activer les Options Avancées**
       ```
       Menu View → Advanced Features
       ```

    ### 5.2 Désactivation de la Protection

    1. **Accéder aux Propriétés**
       ```
       OU cible → Clic droit → Properties
       ```

    2. **Modifier la Protection**
       ```
       Onglet Object
       ☐ Protect object from accidental deletion
       ```
       - Cliquez sur OK pour appliquer les modifications.

    3. **Supprimer l'OU**


## 6. ⚙️ Gestion des OUs

!!! info "Flexibilité de la Structure"

    ### 6.1 Opérations de Base

    1. **Déplacement d'Objets**
       ```
       Source OU → Glisser-Déposer → Destination OU
       ```

    2. **Application des GPOs**
       ```
       OU → Clic droit → Lier une GPO
       ```

!!! example "Exemples de GPOs par Département"

    | Département | GPO | Objectif |
    |--------------|-----|----------|
    | Comptabilite | GPO-Compta-USB | Bloquer USB |
    | IT | GPO-IT-USB | Autoriser USB |
    | RH | GPO-RH-Screen | Verrouillage 5min |

## 7. 🏢 Structure pour maxtec.be

### 7.1 Hiérarchie Géographique

Extrait de la structure créée par le script du lab (la liste complète est dans la [Référence du lab Maxtec](Labo%20et%20Exercices/Labo/Reference_Lab_Maxtec.md)) :

```
EU
├── Comptabilite
│   ├── Users
│   │   ├── charlotte
│   │   ├── cindy
│   │   └── charles
│   ├── Computers
│   └── Groups
│       ├── GG-EU-Compta-Admin
│       └── GG-EU-Compta-Users
├── RH
│   ├── Users
│   │   ├── richard
│   │   ├── rebecca
│   │   └── rene
│   ├── Computers
│   │   └── ws-RH-01
│   └── Groups
│       ├── GG-EU-RH-Admin
│       └── GG-EU-RH-Users
├── Ventes
│   ├── Users
│   │   └── vanessa, valeria, victor, valentin
│   ├── Computers
│   └── Groups
│       ├── GG-EU-Ventes-Admin
│       └── GG-EU-Ventes-Users
└── IT
    ├── Users
    │   └── ivan, ines, irene
    ├── Computers
    │   └── ws-IT-01
    └── Groups
        ├── GG-EU-IT-Admin
        └── GG-EU-IT-Users
```

!!! note "Et les États-Unis ?"

    Le lab ne contient que l'OU `EU`. Une filiale américaine suivrait exactement le même modèle (`USA/<Département>/…`) : c'est l'intérêt d'une structure standardisée.

### 7.2 Conventions de Nommage

#### 7.2.1 Règles Générales

- Utiliser des noms descriptifs et cohérents
- Éviter les abréviations (sauf standards)
- Pas de caractères spéciaux
- Respecter la casse selon le type d'objet

#### 7.2.2. Exemples par Type

1. **OUs**
   - Format: PascalCase, sans accent
   - Exemples: `Comptabilite`, `RH`, `Ventes`

2. **Groupes**
   - Format: [Portée]-[Location]-[Dept]-[Fonction]
   - Exemples:
     * `GG-EU-Compta-Users` (global)
     * `DL-Ventes-Documents-Modification` (domaine local)

3. **Ordinateurs**
   - Format: ws-[dept]-[##]
   - Exemples:
     * `ws-IT-01`
     * `ws-RH-01`

#### 7.2.3 Bonnes Pratiques

1. **Structure**
   ```
   # Profondeur maximale
   maxtec.be (domaine AD)
   ├── EU                    # Niveau 1
   │   ├── Comptabilite     # Niveau 2
   │   │   ├── Users      # Niveau 3
   │   │   └── Computers  # Niveau 3
   │   └── RH             # Niveau 2
   ```

2. **Groupement**
   ```
   # Par type d'objet
   EU/Comptabilite
   ├── Users      # Utilisateurs uniquement
   ├── Computers  # Ordinateurs uniquement
   └── Groups     # Groupes uniquement
   ```


## 8. Conteneurs vs OUs

### 8.1 Comparaison

| Fonctionnalité | Conteneur | OU |
|-----------------|-----------|----|
| Création | Automatique | Manuelle |
| GPOs | ❌ | ✅ |
| Délégation | ❌ | ✅ |
| Flexibilité | ❌ | ✅ |


### 8.2 Principes de Conception


1. **Administration**
   ```
   # Délégation par département
   EU/RH → GG-EU-RH-Admin
   EU/IT → GG-EU-IT-Admin
   ```

2. **Sécurité**
   ```
   # GPOs par fonction
   EU/Comptabilite/Users → GPO-Compta-Security
   EU/IT/Computers       → GPO-IT-Tools
   ```

3. **Évolutivité**
   ```
   # Structure modulaire
   EU
   ├── Département1    # Ajout facile
   ├── Département2    # de nouveaux
   └── Département3    # départements
   ```
   - Qui gère quoi ?
   - Quelles sont les responsabilités de chaque équipe ?

4. **Besoins en GPO** :
   - Quelles politiques doivent être appliquées ?
   - À quels groupes d'objets ?

5. **Exigences de Sécurité** :
   - Quels sont les niveaux d'accès requis ?
   - Quelles sont les ressources sensibles ?

6. **Organisation Géographique vs Fonctionnelle** :
   - Structure par lieu ou par fonction ?
   - Hybride des deux approches ?

### 8.3 Meilleures Pratiques

1. **Structure Simple et Claire**
   La structure doit être facilement compréhensible et maintenable. Chaque département suit la même organisation :
   ```
   # Organisation standardisée
   EU
   ├── Département
   │   ├── Users      # Comptes utilisateurs
   │   ├── Computers  # Postes de travail
   │   └── Groups     # Groupes de sécurité
   └── [Autres Départements...]
   ```
   Cette organisation permet une gestion efficace des droits et des stratégies de groupe.

2. **Limitation des Niveaux d'Imbrication**
   AD supporte sans problème des arborescences profondes : la limite n'est pas une question de performance. Elle est **humaine** : au-delà de 3-4 niveaux, on ne sait plus quelle GPO ou quelle permission héritée s'applique où. Visez une profondeur que vous pouvez expliquer au tableau :
   ```
   # Hiérarchie lisible
   maxtec.be (domaine AD)    # Niveau 0 (Racine)
   ├── EU                 # Niveau 1 (Géographie)
   │   ├── RH             # Niveau 2 (Département)
   │   │   └── Users      # Niveau 3 (Objets)
   │   └── [Autres...]
   └── Serveurs           # Branche parallèle (hors départements)
   ```
   Une structure plus profonde complique le diagnostic des GPOs et de l'héritage des permissions.

3. **Alignement avec l'Organisation**
   La structure des OUs doit refléter l'organisation de l'entreprise tout en facilitant l'administration :
   ```
   # Structure fonctionnelle
   EU
   ├── Comptabilite         # Données financières sécurisées
   │   └── GPO: Restrictions USB
   ├── RH                   # Gestion du personnel
   │   └── GPO: Verrouillage 5min
   └── Ventes               # Équipe commerciale
       └── GPO: Accès CRM
   ```
   Cette organisation permet d'appliquer des politiques spécifiques à chaque service tout en maintenant une cohérence globale.

## 9. Délégation de contrôle

!!! info "Prérequis"

    - La structure du lab est en place (`creation_structure.ps1`) : OUs `EU/<Département>/…` et groupes `GG-EU-…`.
    - Pour déléguer, il suffit de savoir ce qu'est un groupe global (`GG-`). Les **portées de groupe** (global, domaine local, universel) et la stratégie **AGDLP** sont expliquées au [chapitre 7](Chapitre%207.Gestion_des_Utilisateurs.md#4-gestion-des-groupes). Vous pouvez faire cette section maintenant et y revenir après le chapitre 7.
    - Aucune notion de GPO n'est nécessaire.

### 9.1 Principe

Sans délégation, seuls les membres de `Admins du domaine` (ou équivalent) peuvent créer ou modifier les comptes, même s'il existe une OU `RH` bien rangée. Chaque réinitialisation de mot de passe passe par l'équipe IT.

La **délégation de contrôle** consiste à ajouter des **entrées de permission (ACE) sur une OU** pour qu'un groupe puisse effectuer des tâches précises **sur les objets AD** de cette OU (et, par héritage, de ses sous-OUs) :

- **Décentralisation** : les responsables de service gèrent les tâches courantes
- **Moindre privilège** : on donne une tâche précise, pas « admin »
- **Traçabilité** : la délégation est portée par un groupe, donc visible et documentable

!!! tip "Toujours déléguer à un groupe"

    On délègue à `GG-EU-Compta-Admin`, **pas** à `charlotte`. Si Charlotte change de poste, on retire son compte du groupe ; la délégation posée sur l'OU ne bouge pas.

### 9.2 Exemple pratique : Charlotte réinitialise les mots de passe de la Comptabilité

**Besoin** : `charlotte` (responsable Comptabilite, membre de `GG-EU-Compta-Admin`) doit pouvoir réinitialiser les mots de passe de `cindy` et `charles`, et rien d'autre.

**Sur le DC**, en tant que `MAXTEC\Administrateur` :

1. Ouvrir **ADUC** (`dsa.msc`)
2. Naviguer vers `EU > Comptabilite`, **clic droit sur l'OU `Users`** → **Déléguer le contrôle…**
3. **Suivant** dans l'assistant
4. **Ajouter…** → taper `GG-EU-Compta-Admin` → **Vérifier les noms** → **OK** → **Suivant**
5. Cocher uniquement :
    - **Réinitialiser les mots de passe utilisateur et forcer le changement de mot de passe à la prochaine ouverture de session**
    - **Lire toutes les informations sur l'utilisateur**
6. **Suivant** → **Terminer**

!!! note "Et le déverrouillage de compte ?"

    La tâche « Réinitialiser les mots de passe » donne le droit de reset et d'écrire `pwdLastSet`. Pour déverrouiller un compte sans changer son mot de passe, il faut aussi pouvoir écrire l'attribut `lockoutTime` : dans l'assistant, choisissez **Créer une tâche personnalisée à déléguer** → **Objets Utilisateur** → propriétés **Lire lockoutTime** et **Écrire lockoutTime**.

### 9.3 Tester la délégation depuis le poste client

On teste **depuis `ws-IT-01` (ou `ws-RH-01`)**, pas en ouvrant une session sur le DC. Par défaut, les utilisateurs du domaine n'ont pas le droit d'ouvrir une session sur un DC, et c'est très bien ainsi : un responsable de service n'a rien à faire sur un contrôleur de domaine. La délégation se teste avec les consoles d'administration à distance (RSAT).

**Préparation (une fois)** : installez RSAT sur le client. La procédure est détaillée dans l'[Exercice 12, section RSAT](Labo%20et%20Exercices/Exercices:%20Gestion_des_Utilisateurs.md#exercice-12-delegation-dadministration).

**Deux façons de tester** :

- **Option A — session de Charlotte** : ouvrez une session sur `ws-IT-01` avec `MAXTEC\charlotte`, puis lancez `dsa.msc`.
- **Option B — sans changer de session** : depuis une session administrateur sur le client, lancez la console avec les identifiants de Charlotte pour le réseau :

    ```cmd
    runas /netonly /user:MAXTEC\charlotte "mmc dsa.msc"
    ```

    `/netonly` utilise les identifiants de Charlotte uniquement pour les connexions réseau (ici LDAP vers le DC). C'est exactement ce que fait un technicien pour tester les droits d'un compte.

**Tests à réaliser** :

| Action (en tant que Charlotte) | Résultat attendu |
|---|---|
| `EU > Comptabilite > Users` → clic droit sur `cindy` → **Réinitialiser le mot de passe** | Réussit |
| Même action sur `rebecca` (`EU > RH > Users`) | **Accès refusé** |
| Clic droit sur `EU > Comptabilite > Users` → **Nouveau > Utilisateur** | Refusé (tâche non déléguée) |
| Modifier le numéro de téléphone de `charles` | Refusé (on a délégué la lecture, pas l'écriture) |

**En PowerShell** (aperçu, vu au chapitre 9 ; module AD installé avec RSAT) :

```powershell
$cred = Get-Credential MAXTEC\charlotte
Set-ADAccountPassword -Identity cindy -Reset `
    -NewPassword (ConvertTo-SecureString "Password1!" -AsPlainText -Force) -Credential $cred   # OK
Set-ADAccountPassword -Identity rebecca -Reset `
    -NewPassword (ConvertTo-SecureString "Password1!" -AsPlainText -Force) -Credential $cred   # Accès refusé
```

### 9.4 Ce que la délégation donne… et ce qu'elle ne donne pas

**Ce qu'elle donne** : des droits sur des **objets de l'annuaire** situés dans l'OU (comptes utilisateurs, groupes, comptes ordinateurs) : créer, supprimer, réinitialiser un mot de passe, modifier un attribut, modifier l'appartenance d'un groupe, joindre un poste au domaine dans cette OU, lier une GPO à l'OU.

**Ce qu'elle ne donne pas** : l'administration **des machines** elles-mêmes. Déléguer la gestion de `EU/IT/Computers` ne permet ni d'installer un logiciel sur `ws-IT-01`, ni de redémarrer un service, ni de gérer une file d'impression. Pour cela il faut être **administrateur local** du poste, ce qui se configure par GPO (Groupes restreints ou Préférences > Utilisateurs et groupes locaux, voir chapitre 8), pas par la délégation d'OU.

!!! warning "La limite porte sur l'objet modifié, pas sur les membres ajoutés"

    Si l'on délègue à `GG-EU-RH-Admin` la tâche **Modifier l'appartenance d'un groupe** sur `EU/RH/Groups`, Richard peut ajouter **n'importe quel compte du domaine** (par exemple `victor`, de Ventes) aux groupes de cette OU. Ce qui est protégé, ce sont les objets hors de l'OU : Richard ne peut pas modifier `victor` lui-même, ni les groupes de `EU/Ventes/Groups`.

    Conséquence : le droit de modifier les membres d'un groupe qui donne accès à une ressource sensible est un droit sensible.

### 9.5 Tâches courantes à déléguer

| Tâche (assistant) | Exemple Maxtec |
|-------|-------------|
| Réinitialiser les mots de passe | `GG-EU-Compta-Admin` sur `EU/Comptabilite/Users` |
| Créer, supprimer et gérer les comptes d'utilisateurs | `GG-EU-Ventes-Admin` sur `EU/Ventes/Users` |
| Modifier l'appartenance d'un groupe | `GG-EU-RH-Admin` sur `EU/RH/Groups` |
| Joindre un ordinateur au domaine (tâche personnalisée : créer/supprimer des objets Ordinateur) | `GG-EU-IT-Admin` sur `EU/*/Computers` |

!!! warning "Bonnes pratiques"

    - Déléguer au **groupe**, jamais à l'utilisateur
    - Déléguer une **tâche précise** sur la **plus petite OU** possible (`EU/RH/Users` plutôt que `EU/RH`)
    - Ne jamais déléguer sur la racine du domaine
    - Éviter **Contrôle total** : il permet notamment de modifier les permissions de l'OU elle-même
    - Documenter chaque délégation (qui, quelle OU, quelle tâche, pourquoi)

!!! note "Délégation et AGDLP"

    Ici on délègue directement à un groupe global, ce qui est courant et suffisant dans un seul domaine. Pour les **permissions sur les ressources** (dossiers partagés), la bonne pratique est **AGDLP** : Comptes → Groupe Global → Groupe Domaine Local → Permission. Elle est expliquée au [chapitre 7, §5.2](Chapitre%207.Gestion_des_Utilisateurs.md#52-strategie-agdlp) et mise en pratique dans l'exercice AGDLP.

## 10. Bonnes Pratiques

### 10.1. Sécurité

1. **Principe du Moindre Privilège**
   - Déléguer uniquement les droits nécessaires
   - Réviser régulièrement les permissions
   - Documenter les délégations

2. **Structure des Groupes**
   - Utiliser AGDLP pour les ressources (voir chapitre 7)
   - Éviter les permissions directes aux utilisateurs
   - Maintenir une nomenclature cohérente

### 10.2. Maintenance

1. **Documentation**
   - Cartographier les délégations
   - Noter les justifications
   - Maintenir un historique

2. **Audit Régulier**
   - Vérifier les permissions
   - Nettoyer les délégations obsolètes
   - Valider les accès

### 10.3 Héritage dans les OUs

#### 10.3.1 Concept d'Héritage

L'héritage dans AD détermine **comment les paramètres et les permissions se propagent à travers la hiérarchie** des OUs.

#### 10.3.2 Types d'Héritage

##### Héritage des GPOs

1. **Propagation**
   - Les paramètres se propagent **automatiquement** vers le bas
   - Affecte toutes les OUs enfants
   - Exemple : GPO de sécurité liée à `EU` affecte `EU/RH` et `EU/RH/Users`

2. **Contrôle**
   - **Bloquer l'héritage** (sur une OU) : l'OU ne reçoit plus les GPOs des niveaux supérieurs
   - **Appliqué** (*Enforced*, sur un lien de GPO) : la GPO passe malgré un blocage et gagne en cas de conflit
   - Exemple : `EU/IT` peut bloquer les GPOs de `EU` pour des besoins spécifiques ; une GPO de sécurité liée au domaine en mode Appliqué passera quand même
   - Détails au chapitre 8

##### Héritage des Permissions

1. **ACLs (Access Control Lists)**
   - Définissent les droits d'accès
   - Se propagent aux objets enfants
   - Exemple : une délégation posée sur `EU/RH` s'applique aussi à `EU/RH/Users`

2. **Types de Permissions**
   - **Explicites** : définies directement sur l'objet
   - **Héritées** : reçues du parent
   - Exemple : `GG-EU-Compta-Admin` a une permission explicite sur `EU/Comptabilite/Users` (délégation du §9.2), héritée par les comptes `cindy` et `charles`

3. **Gestion**
   - Possibilité de désactiver l'héritage sur un objet
   - Option de remplacer les permissions héritées
   - Exemple : une OU sensible (ex. une OU `Serveurs` que vous créeriez) peut désactiver l'héritage pour ne pas recevoir les délégations du niveau supérieur

## 11. Groupes vs OUs

### 11.1. Tableau Comparatif

| Caractéristique | Groupes | OUs |
|-----------------|---------|-----|
| **Objectif Principal** | Gérer les **permissions** | Gérer la **structure** et les **GPOs** |
| **Flexibilité** | Membres d'autres groupes | Structure hiérarchique fixe |
| **Permissions** | Reçoivent des droits | Reçoivent des GPOs |
| **Utilisation** | Accès aux ressources | Organisation administrative |
| **Adaptabilité** | Flexibles et réutilisables | Hiérarchiques et structurés |

Un objet est dans **une seule OU**, mais peut être membre de **plusieurs groupes**. On range avec les OUs, on donne des droits avec les groupes.

### 11.2 Utilisation des Groupes

Les groupes sont utilisés pour **gérer les accès aux ressources et les rôles fonctionnels**.

#### 11.2.1 Accès aux Ressources

**Variante simple (« AGP »)** : on donne les permissions sur la ressource **directement au groupe global**. Ce n'est **pas** AGLP : dans AGLP comme dans AGDLP, le groupe global est placé dans un groupe local (L = groupe local de la machine qui porte la ressource, DL = groupe domaine local) et c'est ce groupe local qui reçoit la permission.

1. **Ressources Partagées**
   ```plaintext
   # Permissions directes aux groupes globaux (AGP)
   GG-EU-Compta-Users → Dossier Factures (R/W)
   GG-EU-RH-Admin     → App Salaires (Admin)
   ```

2. **Applications Métier**
   ```plaintext
   # Accès directs aux applications
   GG-EU-Ventes-Users  → CRM (Utilisateur)
   GG-EU-Ventes-Admin  → CRM (Admin)
   ```

**Note** : l'AGP marche dans un petit domaine, mais chaque nouveau département oblige à retoucher les permissions de la ressource. AGDLP évite cela (chapitre 7, §5.2).

#### 11.2.2 Rôles Fonctionnels

On peut **créer des groupes selon le rôle fonctionnel des utilisateurs** qui l'occupent (exemples, ces groupes n'existent pas dans le lab) :

1. **Support Technique**
   ```
   GG-EU-IT-Helpdesk    # Techniciens support niveau 1
   GG-EU-IT-Support     # Support niveau 2
   GG-EU-IT-Admin       # Administrateurs système (existe dans le lab)
   ```

2. **Développement**
   ```
   GG-EU-IT-Devs        # Développeurs
   GG-EU-IT-DevOps      # Équipe DevOps
   GG-EU-IT-QA          # Testeurs
   ```


## 12. Utilisation des OUs

### 12.1 Structure Organisationnelle

Les OUs permettent de **créer une structure hiérarchique** qui reflète l'organisation de l'entreprise, facilitant ainsi la gestion des ressources par zone géographique et par département.

1. **Hiérarchie Géographique**
   ```
   EU
   ├── Comptabilite
   │   ├── Users
   │   └── Computers
   └── RH
       ├── Users
       └── Computers
   ```

### 12.2. Application des GPOs

Les OUs servent de points d'application pour les **stratégies de groupe (GPOs)**, permettant d'appliquer des **paramètres de sécurité et de configuration spécifiques** à différents niveaux de l'organisation.

1. **Sécurité**
   ```
   EU/Comptabilite/Computers
   ├── GPO: Désactivation USB
   └── GPO: Chiffrement obligatoire
   ```

2. **Conformité**
   ```
   EU/RH/Users
   ├── GPO: Verrouillage 5 min
   └── GPO: Audit renforcé
   ```

### 12.3. Délégation Administrative

La structure en OUs permet de **déléguer des droits administratifs** à différents niveaux (voir §9).

1. **Par Département**
   ```plaintext
   # Tâches précises par département
   GG-EU-Ventes-Admin → EU/Ventes/Users (créer et gérer les comptes)
   GG-EU-RH-Admin     → EU/RH/Users    (réinitialiser les mots de passe)
   ```

2. **Par Fonction**
   ```plaintext
   # Droits spécifiques par fonction
   GG-EU-IT-Admin → EU/*/Computers (joindre des postes au domaine)
   GG-EU-IT-Admin → EU (lier des GPOs existantes)
   ```

!!! warning "Et « Contrôle total » sur l'OU du département ?"

    On le voit souvent (`GG-EU-Ventes-Admin → EU/Ventes (Full Control)`), et c'est une **mauvaise pratique** : Contrôle total permet de supprimer l'OU, de modifier ses permissions et de s'accorder d'autres droits. Déléguez des tâches précises.

### 12.4. Exemples de combinaison OU + groupes

Les exemples suivants sont des scénarios de conception : ces OUs et groupes n'existent pas dans le lab.

#### 12.4.1. Gestion des Stagiaires

1. **Structure OU**
   ```
   EU
   └── Stagiaires
       ├── Users
       └── Computers
   ```

2. **GPOs**
   ```
   EU/Stagiaires
   ├── GPO: Restrictions Internet
   ├── GPO: Blocage Installation
   └── GPO: Audit Renforcé
   ```

3. **Variante simple (AGP, permissions directes)**
   ```
   # Groupes globaux
   GG-EU-Stagiaires          # Tous les stagiaires
   GG-EU-Stagiaires-IT       # Stagiaires IT
   GG-EU-Stagiaires-RH       # Stagiaires RH

   # Permissions directes
   GG-EU-Stagiaires-IT → Outils Développement
   GG-EU-Stagiaires-RH → Base CV
   ```

4. **AGDLP (recommandé)**
   ```
   # Groupes globaux (qui ?)
   GG-EU-Stagiaires-IT
   GG-EU-Stagiaires-RH

   # Groupes domaine local (quel accès à quelle ressource ?)
   DL-EU-Stagiaires-Dev      # Accès outils dev
   DL-EU-Stagiaires-Docs     # Accès documentation
   DL-EU-Stagiaires-Apps     # Accès applications

   # Association
   GG-EU-Stagiaires-IT → DL-EU-Stagiaires-Dev
   GG-EU-Stagiaires-RH → DL-EU-Stagiaires-Apps
   ```

#### 12.4.2 Département Commercial

1. **Structure OU**
   ```
   EU
   └── Ventes
       ├── Users
       └── Computers
   ```

2. **Variante simple (AGP)**
   ```
   # Groupes avec permissions directes
   GG-EU-Ventes-Lecture      # Lecture catalogues
   GG-EU-Ventes-Edition      # Édition devis
   GG-EU-Ventes-Admin        # Admin CRM

   # Permissions
   GG-EU-Ventes-Lecture → Catalogues (lecture)
   GG-EU-Ventes-Edition → Devis (lecture/écriture)
   GG-EU-Ventes-Admin → CRM (admin)
   ```

3. **AGDLP (recommandé)**
   ```
   # Groupes globaux (qui ?)
   GG-EU-Ventes-Vendeurs     # Vendeurs
   GG-EU-Ventes-Managers     # Managers

   # Groupes domaine local (quel accès ?)
   DL-EU-Ventes-Catalogues   # Accès catalogues
   DL-EU-Ventes-Devis        # Gestion devis
   DL-EU-Ventes-CRM          # Accès CRM

   # Associations
   GG-EU-Ventes-Vendeurs → DL-EU-Ventes-Catalogues
   GG-EU-Ventes-Managers → DL-EU-Ventes-CRM
   ```

#### 12.4.3 Projet Multi-Départemental

1. **Structure Existante**
   ```
   EU
   ├── Comptabilite
   ├── IT
   └── RH
   ```

2. **Variante simple (AGP)**
   ```
   # Groupe projet unique
   GG-EU-Projet-ERP          # Accès direct aux ressources

   # Permissions
   GG-EU-Projet-ERP → Ressources Projet
   ```

3. **AGDLP (recommandé)**
   ```
   # Groupes globaux (qui ?)
   GG-EU-Projet-ERP-Dev      # Développeurs
   GG-EU-Projet-ERP-Test     # Testeurs
   GG-EU-Projet-ERP-Admin    # Administrateurs

   # Groupes domaine local (quel accès ?)
   DL-EU-Projet-ERP-Code     # Accès code source
   DL-EU-Projet-ERP-Docs     # Accès documentation
   DL-EU-Projet-ERP-Test     # Accès env. test

   # Associations
   GG-EU-Projet-ERP-Dev → DL-EU-Projet-ERP-Code
   GG-EU-Projet-ERP-Test → DL-EU-Projet-ERP-Test
   GG-EU-Projet-ERP-Admin → [Tous les DL]
   ```

## 🎯 Checkpoint Final: Maîtrise des UOs

!!! info "Vérification finale"

    Avant de passer à la gestion des utilisateurs :

    - [ ] Savoir créer une UO, et supprimer une UO protégée
    - [ ] Savoir pourquoi on protège les OUs en production mais pas dans le lab
    - [ ] Comprendre la différence entre UO et conteneur par défaut
    - [ ] Avoir délégué une tâche précise sur une OU à un groupe `GG-` et l'avoir testée depuis un client
    - [ ] Savoir ce que la délégation d'OU ne donne pas (administration locale des postes)

---


### 🚀 Prochaine étape
La structure est en place. Le chapitre suivant crée et gère les **utilisateurs** et les **groupes** dans ces UOs.

!!! note "Pour aller plus loin (hors parcours)"

    Le dossier `Labos Extra` contient un scénario complémentaire (agence marketing *CreativeHub*) qui ne fait pas partie du parcours du cours : [Lab CreativeHub](Labos%20Extra/Labo1-CreativeHub/README.md).

## 🧭 Navigation
[⏮️ Chapitre Précédent: DNS Pratique avec AD](Chapitre%205.DNS-Pratique-avec-AD.md) | [🏠 Retour au Syllabus](index.md) | [⏭️ Chapitre 7: Gestion des Utilisateurs](Chapitre%207.Gestion_des_Utilisateurs.md)

---

**📚 Cours Active Directory - Unités d'organisation**
