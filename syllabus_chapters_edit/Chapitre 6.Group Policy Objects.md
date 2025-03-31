# Les Stratégies de Groupe (Group Policy Objects)

## 3.1 Introduction aux Stratégies de Groupe

### Qu'est-ce qu'une Stratégie de Groupe ?

Les stratégies de groupe (Group Policy Objects ou GPOs) sont un outil puissant d'Active Directory qui vous permet de :

- Gérer de manière centralisée les configurations des utilisateurs et des ordinateurs
- Appliquer des paramètres de sécurité
- Déployer des logiciels
- Configurer des scripts de démarrage/arrêt

### Types de Stratégies de Groupe

1. **Stratégies Locales (Local Group Policy)**
   - S'appliquent à un seul ordinateur
   - Ne nécessitent pas Active Directory
   - Accessibles via `gpedit.msc`

2. **Stratégies de Domaine (Domain Group Policy)**
   - S'appliquent à plusieurs ordinateurs/utilisateurs
   - Nécessitent Active Directory
   - Gérées via la console GPMC (Group Policy Management Console)

### Ordre d'Application des GPOs

Les GPOs s'appliquent dans l'ordre suivant (du plus faible au plus fort) :

1. Stratégies Locales
2. Stratégies de Site (Site Level)
3. Stratégies de Domaine (Domain Level)
4. Stratégies d'OU (OU Level)

> **Note importante** : Les stratégies au niveau OU s'appliquent de manière hiérarchique, de l'OU parent vers l'OU enfant.

Vous pouvez visualiser cet ordre avec la commande : `gpresult /r`

### Exemple Pratique

Prenons un exemple simple de l'ordre d'application :

```plaintext
Ordinateur : ws-compta-01.computerelectronics.be
Emplacement : OU=Comptabilité,OU=EU,DC=computerelectronics,DC=be

Ordre d'application :
1. Stratégie Locale de ws-compta-01
2. Stratégie du Site Default-First-Site-Name
3. Stratégie du Domaine computerelectronics.be
4. Stratégie de l'OU EU
5. Stratégie de l'OU Comptabilité
```

> **À retenir** : La dernière stratégie appliquée (la plus spécifique) remplace les paramètres des stratégies précédentes en cas de conflit.
