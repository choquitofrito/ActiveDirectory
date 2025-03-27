# Organisation des OUs et Groupes - Exemple Multi-Sites

Voici un exemple d'organisation des OUs et des groupes pour une entreprise avec des départements Ventes, Comptabilité, et Ressources Humaines (RH), répartie sur deux sites géographiques : Siège aux USA et Siège en EU. Cette structure permet de gérer les utilisateurs, groupes et ressources en fonction des sites géographiques tout en maintenant une organisation centralisée.

## 1. Organisation des OUs

La structure est divisée en sites géographiques, puis en départements pour chaque site. Cette organisation permet une gestion spécifique des objets de chaque site, tout en maintenant une structure logique à travers l'entreprise.

### Structure des OUs

```
Entreprise (root)
├── USA
│   ├── Ventes
│   │   ├── Utilisateurs
│   │   ├── Groupes
│   │   └── Ordinateurs
│   ├── Comptabilité
│   │   ├── Utilisateurs
│   │   ├── Groupes
│   │   └── Ordinateurs
│   └── RH
│       ├── Utilisateurs
│       ├── Groupes
│       └── Ordinateurs
└── EU
    ├── Ventes
    │   ├── Utilisateurs
    │   ├── Groupes
    │   └── Ordinateurs
    ├── Comptabilité
    │   ├── Utilisateurs
    │   ├── Groupes
    │   └── Ordinateurs
    └── RH
        ├── Utilisateurs
        ├── Groupes
        └── Ordinateurs
```

## 2. Organisation des Groupes

Les groupes sont structurés par site géographique et département pour une meilleure gestion des permissions selon l'emplacement des utilisateurs.

### Siège USA

- **GG_Ventes_USA** : Groupe global pour les utilisateurs du département des ventes aux États-Unis
- **GG_Comptabilite_USA** : Groupe global pour les utilisateurs du département comptabilité aux États-Unis
- **GG_RH_USA** : Groupe global pour les utilisateurs du département RH aux États-Unis

### Siège EU

- **GG_Ventes_EU** : Groupe global pour les utilisateurs du département des ventes en Europe
- **GG_Comptabilite_EU** : Groupe global pour les utilisateurs du département comptabilité en Europe
- **GG_RH_EU** : Groupe global pour les utilisateurs du département RH en Europe

### Groupes locaux de domaine (DL)

- **DL_Ventes_Fichiers_USA** : Ressources de ventes aux États-Unis
- **DL_Ventes_Fichiers_EU** : Ressources de ventes en Europe
- **DL_Comptabilite_Fichiers_USA** : Ressources comptables aux États-Unis
- **DL_Comptabilite_Fichiers_EU** : Ressources comptables en Europe
- **DL_RH_Fichiers_USA** : Ressources RH aux États-Unis
- **DL_RH_Fichiers_EU** : Ressources RH en Europe

## 3. Attribution des Permissions

### Accès aux ressources de Ventes

- `GG_Ventes_USA` → `DL_Ventes_Fichiers_USA` : Accès aux fichiers commerciaux USA
- `GG_Ventes_EU` → `DL_Ventes_Fichiers_EU` : Accès aux fichiers commerciaux EU

### Accès aux dossiers Comptabilité

- `GG_Comptabilite_USA` → `DL_Comptabilite_Fichiers_USA` : Accès aux fichiers financiers USA
- `GG_Comptabilite_EU` → `DL_Comptabilite_Fichiers_EU` : Accès aux fichiers financiers EU

### Accès aux ressources RH

- `GG_RH_USA` → `DL_RH_Fichiers_USA` : Accès aux fichiers RH USA
- `GG_RH_EU` → `DL_RH_Fichiers_EU` : Accès aux fichiers RH EU

## 4. Gestion des Stratégies de Groupe (GPO)

Les stratégies de groupe peuvent être appliquées spécifiquement à chaque site géographique:

- **GPO par région** : Politiques de sécurité et paramètres de bureau différents entre USA et EU
- **Personnalisation** : Paramètres et gestion des utilisateurs adaptés à chaque emplacement