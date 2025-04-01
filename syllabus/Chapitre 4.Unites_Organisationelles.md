# Chapitre 4: Unités d'Organisation (OUs)

> 📚 **Dans ce chapitre:**
> 1. 🏢 [Structure Organisationnelle](#1-introduction-aux-unités-dorganisation-ous)
>    - Concepts fondamentaux
>    - Hiérarchie des OUs
> 2. ⚙️ [Administration](#2-gestion-des-ous)
>    - Création et configuration
>    - Bonnes pratiques
> 3. 🔐 [Sécurité et Délégation](#3-délégation-administrative)
>    - Stratégies de gestion
>    - Contrôle d'accès

---

## 1. 📙 Objectifs Pédagogiques

À la fin de ce chapitre, vous serez capable de :
1. 🏢 Structurer votre organisation dans Active Directory
2. ⚙️ Gérer efficacement les OUs et leurs objets
3. 🔐 Implémenter une stratégie de sécurité par délégation

---

## 2. 🏢 Structure Organisationnelle

### 📂 Concept des Unités d'Organisation

Une **Unité d'Organisation** (OU) est un **conteneur Active Directory** offrant :

1. 🏢 **Organisation Logique**
   - 📂 Regroupement d'objets AD
   - 📊 Structure hiérarchique
   - 🏢 Reflet de l'entreprise

2. ⚙️ **Gestion Administrative**
   - 🔐 Délégation de droits
   - 📂 Gestion des ressources
   - 🔒 Application des GPOs

> 💡 **Analogie** : Une OU est un **dossier intelligent** combinant organisation et gestion.

## 3. 📂 Structure des OUs

### 3.1 📊 Hiérarchie des Contenus

```
OU
├── Utilisateurs (ex: jean.dupont)
├── Groupes (ex: GG-EU-Compta-Users)
├── Ordinateurs (ex: ws-compta-01)
├── Autres OUs
└── Autres objets (imprimantes, contacts)
```

### 3.2 Avantages vs Conteneurs par Défaut

| Fonctionnalité | Conteneur par Défaut | OU |
|-----------------|---------------------|----|
| Organisation | Fixe | **Flexible** |
| GPOs | Non | **Oui** |
| Délégation | Limitée | **Complète** |
| Structure | Plate | **Hiérarchique** |

## 4. 🔧 Création d'une OU

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

## 5. 🗑️ Suppression d'une OU Protégée

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
  - Clique sur OK pour appliquer les modifications.

3. **Supprimer l'OU** 


## 6. ⚙️ Gestion des OUs

### 6.1 Flexibilité de la Structure

1. **Déplacement d'Objets**
   ```
   Source OU → Glisser-Déposer → Destination OU
   ```

2. **Application des GPOs**
   ```
   OU → Clic droit → Lier une GPO
   ```

### 6.2 Exemples de GPOs par Département

| Département | GPO | Objectif |
|--------------|-----|----------|
| Comptabilité | GPO-Compta-USB | Bloquer USB |
| IT | GPO-IT-USB | Autoriser USB |
| RH | GPO-RH-Screen | Verrouillage 5min |

## 7. 🏢 Structure pour computerelectronics.be

### 7.1 Hiérarchie Géographique (EU et USA)


```
EU
├── Comptabilité
│   ├── Users
│   │   ├── jean.dupont
│   │   └── marie.martin
│   ├── Computers
│   │   ├── ws-compta-01
│   │   └── ws-compta-02
│   └── Groups
│       └── GG-EU-Compta-Users
├── RH
│   ├── Users
│   │   └── sophie.lambert
│   ├── Computers
│   │   └── ws-rh-01
│   └── Groups
│       └── GG-EU-RH-Users
└── Ventes
    ├── Users
    │   └── pierre.durand
    ├── Computers
    │   └── ws-ventes-01
    └── Groups
        └── GG-EU-Ventes-Users
```

> USA a une structure identique à EU

### 7.2 Hiérarchie Environnement (DEV et PROD)

```
Dev
├── Applications
│   ├── app-dev-01
│   └── app-dev-02
├── Databases
│   ├── db-dev-01
│   └── db-dev-02
├── Servers
│   ├── srv-dev-01
│   └── srv-dev-02
└── Groups
    ├── GG-Dev-Admins
    └── GG-Dev-Users
```

> Prod a une structure identique à Dev

### 7.3 Conventions de Nommage

#### 7.3.1 Règles Générales

- Utiliser des noms descriptifs et cohérents
- Éviter les abréviations (sauf standards)
- Pas de caractères spéciaux
- Respecter la casse selon le type d'objet

#### 7.3.2. Exemples par Type

1. **OUs**
   - Format: PascalCase
   - Exemples: `Comptabilité`, `RH`, `Ventes`

2. **Groupes**
   - Format: GG-[Location]-[Dept]-[Function]
   - Exemples: 
     * `GG-EU-Compta-Users`
     * `DL-EU-Compta-Admin`

3. **Ordinateurs**
   - Format: ws-[dept]-[##]
   - Exemples: 
     * `ws-compta-01`
     * `ws-rh-01`

#### 7.3.3 Bonnes Pratiques

1. **Structure**
   ```
   # Profondeur maximale
   computerelectronics.be (domaine AD)
   ├── EU                    # Niveau 1
   │   ├── Comptabilité     # Niveau 2
   │   │   ├── Users      # Niveau 3
   │   │   └── Computers  # Niveau 3
   │   └── RH             # Niveau 2
   └── Dev                   # Niveau 1
   ```

2. **Groupement**
   ```
   # Par type d'objet
   EU/Comptabilité
   ├── Users      # Utilisateurs uniquement
   ├── Computers  # Ordinateurs uniquement
   └── Groups     # Groupes uniquement
   ```

3. **Séparation**
   ```
   # Par environnement
   computerelectronics.be (domaine AD)
   ├── Dev
   │   ├── Applications
   │   └── Databases
   └── Prod
       ├── Applications
       └── Databases
   ```

## 8. Conteneurs vs OUs

### 8.1 Comparaison

| Fonctionnalité | Conteneur | OU |
|-----------------|-----------|----|
| Création | Automatique | Manuelle |
| GPOs | ❌ | ✅ |
| Délégation | ❌ | ✅ |
| Flexibilité | ❌ | ✅ |

### 8.2 Exemples d'Utilisation

1. **Unités d'Organisation**
   ```
   # Création manuelle
   EU/Stagiaires
   ├── GPO: Restrictions Internet
   ├── Délégation: GG-EU-RH-Admins
   └── Flexibilité: Déplacement Users
   ```

2. **Conteneurs par Défaut**
   ```
   # Création automatique
   computerelectronics.be (domaine AD)
   ├── Users         # Conteneur standard
   └── Computers     # Conteneur standard
   ```

### 8.3 Principes de Conception

#### 8.3.1 Facteurs Clés

1. **Administration**
   ```
   # Délégation par département
   EU/RH → GG-EU-RH-Admins
   EU/IT → GG-EU-IT-Admins
   ```

2. **Sécurité**
   ```
   # GPOs par fonction
   EU/Compta/Users → GPO-Compta-Security
   EU/IT/Dev → GPO-Dev-Tools
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

2. **Besoins en GPO** :
   - Quelles politiques doivent être appliquées ?
   - À quels groupes d'objets ?

3. **Exigences de Sécurité** :
   - Quels sont les niveaux d'accès requis ?
   - Quelles sont les ressources sensibles ?

4. **Organisation Géographique vs Fonctionnelle** :
   - Structure par lieu ou par fonction ?
   - Hybride des deux approches ?

### 8.4 Meilleures Pratiques

1. **Structure Simple et Claire**
   La structure doit être facilement compréhensible et maintenable. Chaque département suit la même organisation:
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
   Pour maintenir la performance et la simplicité, limitez la profondeur à 4 niveaux maximum:
   ```
   # Hiérarchie optimale
   computerelectronics.be (domaine AD)    # Niveau 0 (Racine)
   ├── EU                 # Niveau 1 (Géographie)
   │   ├── RH             # Niveau 2 (Département)
   │   │   └── Users      # Niveau 3 (Objets)
   │   └── [Autres...]
   └── Dev                # Branche parallèle
   ```
   Une structure plus profonde peut compliquer la gestion des GPOs et l'héritage des permissions.

3. **Alignement avec l'Organisation**
   La structure des OUs doit refléter l'organisation de l'entreprise tout en facilitant l'administration:
   ```
   # Structure fonctionnelle
   EU
   ├── Comptabilité         # Données financières sécurisées
   │   └── GPO: Restrictions USB
   ├── RH                   # Gestion du personnel
   │   └── GPO: Verrouillage 5min
   └── Ventes               # Équipe commerciale
       └── GPO: Accès CRM
   ```
   Cette organisation permet d'appliquer des politiques spécifiques à chaque service tout en maintenant une cohérence globale.

## 9. Délégation de Contrôle

Avant de continuer ce chapitre vous devez vous familiariser avec les concept de GPO (Group Policy Object). Passez alors au chapitre [6.Group Policy Objects](./Chapitre%206.Group%20Policy%20Objects.md)

### 9.1 Concept et Stratégies

La **délégation de contrôle** permet de décentraliser l'administration d'Active Directory en attribuant des droits spécifiques à des groupes sur des OUs.

#### 9.1.1 Objectifs et Bénéfices

**Avantages** :
- **Décentralisation** : Répartition des tâches administratives
- **Sécurité** : Application du principe du moindre privilège
- **Efficacité** : Gestion locale plus rapide et adaptée

#### 9.1.2 Stratégies de Délégation

1. **AGLP** (Petites Organisations)
   
   **Example**: Le service RH a besoin de gérer ses propres utilisateurs. Sophie Lambert, administratrice RH, doit pouvoir créer des comptes, réinitialiser les mots de passe et modifier les propriétés des utilisateurs, mais uniquement dans l'OU RH.

   **Structure de l'organisation**:
   ```
   # Structure AGLP Simple
   EU (OU)
   ├── RH (OU)
   │   ├── Users (OU)           # Contient sophie.lambert (et peut-être d'autres utilisateurs)
   │   ├── Groups (OU)          # Contient GG-EU-RH-Admins
   │   └── Computers (OU)       # Postes de travail RH
   └── Autres services...
   ```

   **Avec cette structure mais sans délégation**, le service RH **aurait ses propres OUs mais ne pourrait pas les gérer** :
   - **Malgré l'existence d'une OU RH dédiée, seuls les administrateurs globaux d'Active Directory pourraient y créer ou modifier des comptes**, jamais des users comme sophie.lambert. Il faudra passer toujours par les administrateurs AD!
   - La structure organisationnelle serait en place mais sans l'autonomie opérationnelle correspondante

   La délégation permet de **déléguer** des droits sur des OUs **à des groupes** (ici on aura un groupe `GG-EU-RH-Admins`), permettant ainsi une gestion locale et plus efficace.

   **Mise en place de la délégation**:
   1. Créer le compte `sophie.lambert` dans EU/RH/Users
   2. Créer le groupe `GG-EU-RH-Admins` dans EU/RH/Groups
   3. Ajouter sophie.lambert au groupe GG-EU-RH-Admins
   4. Déléguer les droits sur EU/RH/Users au groupe GG-EU-RH-Admins

   Qu'est-ce qu'on gagne?

   Cette approche AGLP nous apporte plusieurs avantages :
   - **Sécurité** : Les droits sont limités uniquement à l'OU Users du service RH
   - **Flexibilité** : On peut facilement ajouter d'autres administrateurs RH en les ajoutant au groupe , **sans devoir modifier chaque groupe ou compte**
   - **Simplicité** : Une structure claire avec les utilisateurs et leurs groupes dans des OUs séparées
   - **Maintenance** : La gestion des droits se fait via le groupe, pas individuellement par utilisateur

2. **AGDLP** (Grandes Organisations)

   **Example**: L'entreprise a plusieurs sites (EU, US) avec des équipes RH locales. Pierre Dupont, administrateur RH senior, doit pouvoir gérer les comptes, les groupes et les stratégies de sécurité pour toute l'équipe RH européenne.

   **Structure de l'organisation**:
   ```
   # Structure AGDLP Multi-sites
   EU (OU)
   ├── RH (OU)
   │   ├── Users (OU)           # Contient pierre.dupont et autres utilisateurs RH
   │   ├── Groups (OU)
   │   │   ├── GG-EU-RH-Admins   # Groupe global (rôles)
   │   │   └── DL-EU-RH-Admin   # Groupe local (droits)
   │   └── Computers (OU)
   ├── IT (OU)
   └── Ventes (OU)
   ```

   **Avec cette structure mais sans délégation**, nous aurions un problème de **gestion multi-sites** :
   - Les administrateurs RH locaux ne pourraient pas gérer leurs propres équipes malgré la structure hiérarchique en place
   - La gestion centralisée ne serait pas adaptée aux besoins spécifiques de chaque site
   - Les droits ne pourraient pas être délégués de manière granulaire entre les différents niveaux d'administration

   La stratégie AGDLP permet de **déléguer les droits de manière hiérarchique** en utilisant des groupes locaux comme intermédiaires, idéal pour les organisations multi-sites.

   **Mise en place de la délégation**:
   1. Créer les groupes dans EU/RH/Groups:
      - `GG-EU-RH-Admins`: groupe global pour le rôle d'admin RH
      - `DL-EU-RH-Admin`: groupe local qui reçoit les droits
   2. Créer le compte `pierre.dupont` dans EU/RH/Users
   3. Ajouter pierre.dupont au groupe GG-EU-RH-Admins
   4. Ajouter GG-EU-RH-Admins comme membre de DL-EU-RH-Admin
   5. Déléguer les droits sur EU/RH au groupe DL-EU-RH-Admin

   Qu'est-ce qu'on gagne?

   Dans notre exemple du service RH, cette approche AGDLP nous permet :
   - **Gestion par niveau** : Pierre peut gérer toute l'équipe RH européenne via `GG-EU-RH-Admins`, tandis que d'autres administrateurs locaux peuvent avoir des droits plus limités
   - **Flexibilité des rôles** : On peut facilement ajouter d'autres administrateurs RH seniors dans `GG-EU-RH-Admins` sans modifier les droits déjà configurés sur `DL-EU-RH-Admin`
   - **Sécurité améliorée** : Les droits sont attribués via le groupe local `DL-EU-RH-Admin`, ce qui permet un meilleur contrôle et audit des permissions
   
   

La stratégie **AGDLP** offre plus de flexibilité mais demande plus de maintenance. La stratégie **AGLP** est plus simple à mettre en place mais moins flexible pour les grandes organisations.

### 9.2 Droits Délégables

#### 9.2.1 Gestion des Utilisateurs

```
Permissions de Base d'une délégation
├── Comptes
│   ├── Création          # Nouveau compte
│   ├── Réinit MDP       # Sécurité
│   └── Désactivation    # Temporaire/Définitif
├── Propriétés
│   ├── Informations     # Profil
│   └── Restrictions    # Accès
└── Groupes
    ├── Création         # Nouveaux groupes
    └── Membres         # Gestion
```

#### 9.2.2 Gestion des Ressources

```
Permissions Avancées
├── Ordinateurs
│   ├── Intégration      # ws-[dept]-[##]
│   └── Maintenance     # Réparation
├── Impression
│   ├── Files           # Queue
│   └── Pilotes         # Config
└── Services
    ├── Démarrage       # Start/Stop
    └── Configuration   # Paramètres
```

### 9.3. Tests et Validation de la Délégation

#### 9.3.1. Préparation de l'Environnement

Pour tester la délégation, nous devons d'abord préparer l'environnement :

1. **Création des comptes de test**
   ```
   sophie.lambert    # Compte administrateur RH
   pierre.dupont     # Utilisateur pour les tests
   `

2. **Configuration des accès**
   - Activer les connexions locales : voir l'annexe à la fin du document du Chapitre 1.
   - Vérifier que les comptes sont dans les bons groupes selon la stratégie choisie

#### 9.3.2. Validation des Droits

1. **Tests de Base (AGLP)**
   ```
   # Se connecter avec sophie.lambert
   - Créer un nouvel utilisateur dans EU/RH/Users
   - Réinitialiser le mot de passe de pierre.dupont
   - Modifier les informations de profil (téléphone, titre)
   ```

2. **Tests Avancés (AGDLP)**
   ```
   # Vérifier la séparation des droits
   - Réinitialiser MDP avec DL-EU-RH-PWReset
   - Gérer comptes avec DL-EU-RH-UserAdmin
   - Tester l'ajout d'autres admins RH
   ```

3. **Vérification des Limites**
   ```
   # Tester les restrictions
   - Essayer d'accéder à EU/IT/Users (refusé)
   - Tenter de modifier une GPO (refusé)
   - Essayer de gérer les groupes (refusé)
   ```

4. **Validation Multi-sites**
   ```
   # Pour AGDLP uniquement
   - Vérifier droits sur EU/RH et sous-OUs
   - Tester ajout admin local avec droits limités
   - Confirmer isolation entre sites (EU vs US)
   ```

## 10. Bonnes Pratiques

### 10.1. Sécurité

1. **Principe du Moindre Privilège**
   - Déléguer uniquement les droits nécessaires
   - Réviser régulièrement les permissions
   - Documenter les délégations

2. **Structure des Groupes**
   - Utiliser AGDLP
   - Éviter les permissions directes
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

## 10.3 Héritage dans les OUs

### 10.3.1 Concept d'Héritage

L'héritage dans AD détermine **comment les paramètres et les permissions se propagent à travers la hiérarchie** des OUs.

### 10.3.2 Types d'Héritage

#### Héritage des GPOs

1. **Propagation**
   - Les paramètres se propagent **automatiquement** vers le bas
   - Affecte toutes les OUs enfants
   - Exemple: GPO de sécurité appliquée à `EU` affecte `EU/RH` et `EU/RH/Users`

2. **Contrôle**
   - **Bloquer l'héritage**: empêcher la propagation
   - **Forcer l'héritage**: ignorer les blocages
   - Exemple: `EU/IT` peut bloquer les GPOs de `EU` pour des besoins spécifiques

#### Héritage des Permissions

1. **ACLs (Access Control Lists)**
   - Définissent les droits d'accès
   - Se propagent aux objets enfants
   - Exemple: Droits de lecture sur `EU/RH` s'appliquent à `EU/RH/Users`

2. **Types de Permissions**
   - **Explicites**: définies directement sur l'objet
   - **Héritées**: reçues du parent
   - Exemple: `DL-EU-RH-Admins` avec droits explicites sur `EU/RH`

3. **Gestion**
   - Possibilité de bloquer l'héritage
   - Option de remplacer les permissions héritées
   - Exemple: Bloquer les permissions héritées pour `EU/IT/Dev`

## 11. Groupes vs OUs

### 11.1. Tableau Comparatif

| Caractéristique | Groupes | OUs |
|-----------------|---------|-----|
| **Objectif Principal** | Gérer les **permissions** | Gérer la **structure** et les **GPOs** |
| **Flexibilité** | Membres d'autres groupes | Structure hiérarchique fixe |
| **Permissions** | Reçoivent des droits | Reçoivent des GPOs |
| **Utilisation** | Accès aux ressources | Organisation administrative |
| **Adaptabilité** | Flexibles et réutilisables | Hiérarchiques et structurés |

### 11.2 Utilisation des Groupes

Les groupes sont utilisés pour **gérer les accès aux ressources et les rôles fonctionnels**.

#### 11.2.1 Accès aux Ressources 

On peut créer de groupes qui contiennent des **permissions directes sur des ressources**.

**Description** : Dans un environnement mono-domaine AD comme `computerelectronics.be`, la stratégie AGLP simplifie la gestion des accès en accordant les permissions directement aux groupes globaux.

1. **Ressources Partagées**
   ```plaintext
   # Groupes avec permissions directes
   GG-EU-Compta-Finance-RW → Dossier Financier (R/W)
   GG-EU-Compta-Finance-R  → Dossier Financier (R)
   GG-EU-RH-Salaires-RW    → App Salaires (Admin)
   ```

2. **Applications Métier**
   ```plaintext
   # Accès directs aux applications
   GG-EU-Ventes-CRM-Users  → CRM (Utilisateur)
   GG-EU-Ventes-CRM-Admin  → CRM (Admin)
   GG-EU-IT-Tools-Support  → Outils Support (Full)
   ```

**Note** : Cette approche est plus simple mais moins flexible que AGDLP. Elle est recommandée uniquement pour les petites structures avec un seul domaine.

#### 10.2.2 Rôles Fonctionnels

On peut **créer de groupes selon le rôle fonctionnel des utilisateurs** qui l'occupent.

1. **Support Technique**
   ```
   GG-EU-IT-Helpdesk    # Techniciens support niveau 1
   GG-EU-IT-Support     # Support niveau 2
   GG-EU-IT-Admins      # Administrateurs système
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

La structure en OUs permet de **déléguer des droits administratifs** à différents niveaux, donnant aux équipes locales l'autonomie nécessaire pour gérer leurs ressources.

1. **Par Département**
   ```plaintext
   # Droits d'administration par département
   GG-EU-Ventes-Admin → EU/Ventes (Full Control)
   GG-EU-IT-Admin    → EU/IT (Full Control)
   ```

2. **Par Fonction**
   ```plaintext
   # Droits spécifiques par fonction
   GG-EU-RH-Users-Admin  → EU/RH/Users (User Management)
   GG-EU-IT-Dev-Admin   → EU/IT/Dev (GPO Management)
   ```

## 12.4. Exemples de combinaison des deux approches (OU + GPO)

### 12.4.1. Gestion des Stagiaires

1. **Structure OU**
   ```
   EU
   ├── Stagiaires
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

3. **Stratégie AGLP** (petites organisations)
   ```
   # Groupes globaux
   GG-EU-Stagiaires          # Tous les stagiaires
   GG-EU-Stagiaires-IT       # Stagiaires IT
   GG-EU-Stagiaires-RH       # Stagiaires RH

   # Permissions directes
   GG-EU-Stagiaires-IT → Outils Développement
   GG-EU-Stagiaires-RH → Base CV
   ```

4. **Stratégie AGDLP** (grandes organisations)
   ```
   # Groupes globaux (rôles)
   GG-EU-Stagiaires-IT
   GG-EU-Stagiaires-RH

   # Groupes domain local (permissions)
   DL-EU-Stagiaires-Dev      # Accès outils dev
   DL-EU-Stagiaires-Docs     # Accès documentation
   DL-EU-Stagiaires-Apps     # Accès applications

   # Association
   GG-EU-Stagiaires-IT → DL-EU-Stagiaires-Dev
   GG-EU-Stagiaires-RH → DL-EU-Stagiaires-Apps
   ```

### 12.4.2 Département Commercial

1. **Structure OU**
   ```
   EU
   ├── Ventes
       ├── Users
       └── Computers
   ```

2. **Stratégie AGLP**
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

3. **Stratégie AGDLP**
   ```
   # Groupes globaux (rôles)
   GG-EU-Ventes-Vendeurs     # Vendeurs
   GG-EU-Ventes-Managers     # Managers

   # Groupes domain local (permissions)
   DL-EU-Ventes-Catalogues   # Accès catalogues
   DL-EU-Ventes-Devis        # Gestion devis
   DL-EU-Ventes-CRM          # Accès CRM

   # Associations
   GG-EU-Ventes-Vendeurs → DL-EU-Ventes-Catalogues
   GG-EU-Ventes-Managers → DL-EU-Ventes-CRM
   ```

### 12.4.3 Projet Multi-Départemental

1. **Structure Existante**
   ```
   EU
   ├── Compta
   ├── IT
   └── RH
   ```

2. **Stratégie AGLP**
   ```
   # Groupe projet unique
   GG-EU-Projet-ERP          # Accès direct aux ressources

   # Permissions
   GG-EU-Projet-ERP → Ressources Projet
   ```

3. **Stratégie AGDLP**
   ```
   # Groupes globaux (rôles)
   GG-EU-Projet-ERP-Dev      # Développeurs
   GG-EU-Projet-ERP-Test     # Testeurs
   GG-EU-Projet-ERP-Admin    # Administrateurs

   # Groupes domain local (permissions)
   DL-EU-Projet-ERP-Code     # Accès code source
   DL-EU-Projet-ERP-Docs     # Accès documentation
   DL-EU-Projet-ERP-Test     # Accès env. test

   # Associations
   GG-EU-Projet-ERP-Dev → DL-EU-Projet-ERP-Code
   GG-EU-Projet-ERP-Test → DL-EU-Projet-ERP-Test
   GG-EU-Projet-ERP-Admin → [Tous les DL]
   ```
