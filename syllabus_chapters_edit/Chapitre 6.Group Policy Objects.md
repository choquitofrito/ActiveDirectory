# Chapitre 6: Les Stratégies de Groupe (GPO)

> 📚 **Dans ce chapitre:**
> 1. 🌐 [Introduction aux GPO](#1-introduction-aux-gpo)
>    - Concepts de base
>    - Types de stratégies
> 2. 🔰 [Hiérarchie et Application](#2-hiérarchie-et-application)
>    - Niveaux d'application
>    - Ordre de traitement
> 3. 💻 [Configuration des GPO](#3-configuration-des-gpo)
>    - Outils de gestion
>    - Exemples pratiques

---

## 📑 Objectifs Pédagogiques

À la fin de ce chapitre, vous serez capable de :
1. Comprendre le rôle et l'utilité des GPO
2. Maîtriser la hiérarchie des stratégies
3. Configurer et gérer des GPO

---

## 1. Introduction aux GPO

### 🌐 1.1. Qu'est-ce qu'une Stratégie de Groupe ?

Une GPO est aussi un objet qu'on peut créer dans la base de données de AD-DS et qui a les capacités suivantes:

| 🛠️ Capacités | Description |
|------------|-------------|
| 💻 **Configuration** | Gérer de manière centralisée les configurations |
| 🔒 **Sécurité** | Appliquer des paramètres de sécurité |
| 💾 **Déploiement** | Déployer des logiciels |
| 🖥️ **Scripts** | Configurer des scripts de démarrage/arrêt |

> 💡 **Principe clé**: Modifier **un seul GPO** pour configurer **plusieurs machines ou utilisateurs**!

### 1.2. Exemples d'application


| Catégorie | Description Détaillée | Exemples |
|-----------|---------------------|----------|
| **Sécurité** | Implémente les politiques de sécurité de l'entreprise : complexité des mots de passe, restrictions d'accès, paramètres de pare-feu, etc. | Obligation de mots de passe complexes (12 caractères min.), configuration du pare-feu d'entreprise |
| **Configuration Utilisateur** | Configure l'environnement de travail des utilisateurs : fond d'écran, paramètres Office, mappages de lecteurs réseau. | Application du fond d'écran d'entreprise, mappage automatique des lecteurs réseau par département |
| **Configuration Système** | Gère les paramètres système : services Windows, paramètres réseau, configuration des mises à jour. | Activation/désactivation des services Windows essentiels, configuration du serveur de mises à jour WSUS |
| **Déploiement** | Automatise l'installation et la mise à jour des applications, pilotes et correctifs sur les postes clients. | Installation automatique de la suite Office 365, mise à jour automatique des logiciels Adobe |
| **Restrictions** | Contrôle l'accès aux fonctionnalités système et applications selon les besoins métier et la sécurité. | Désactivation des ports USB pour le service RH, restriction de l'accès à PowerShell |
| **Automatisation** | Automatise les tâches via des scripts exécutés à des moments spécifiques (connexion, démarrage, etc.). | Exécution de scripts de connexion pour mapper les lecteurs, sauvegarde automatique des fichiers utilisateurs |


### 1.3. Qui est affecté par les GPOs? Definition de site AD

Les **stratégies de groupe peuvent être liées à différents niveaux** de la hiérarchie AD: un ordinateur, un **site**, un domaine AD, une OU...

Un **site est un ou plusieurs ensemble d'ips (sous-réseaux) qui représentent une localisation physique** dans le réseau. 

**Exemple**: nous allons avoir un site lié à la **zone EU** (ips `192.168.10.x`) et un autre site lié à la **zone USA** (ips `192.168.20.x`)

[structure_geographique_zones_basic](../diagrams/images/structure_reseau_geographic_zones_basic.png)

On avait accordé que les deux sites/zones sont gérés par un seul DC (`dns1`, le DC du labo) et, en théorie, un autre de réplication (`dns2`). 

Ces serveurs doivent gérer les 2 sites et se trouvent physiquement **chez nous**.

**Dans la réalité on aurait au moins deux autres DCs**: les 'dns3' et 'dns4' qui se trouveraient physiquement en USA.

Tous les serveurs de la forêt (les deux ou les quatre) **seront chargés de gérer les 2 sites et contiendront la même base de données AD**.


#### Et alors on doit re-créer la BD d'active Directory partout??

**NON!**

La **séparation** en sites n'a **pas d'impact** sur la BD.

Pourquoi? Car **les objets AD (comme les OU) sont stockés dans la base de données du DC**, qui est **la même** (copie) dans tous les DCs de la même forêt, ce qui implique que **la configuration des OUs est la même dans tous les DCs, peu importe le site.**.

**En gros:** On peut créer toute la structure (EU et USA) des OUs dans le DC de notre labo. Si on rajoutait un autre DC (`dns3`) pour le site USA il aurait la même configuration AD que le DC du site EU (on ne devrait pas la ré-creer sur le nouveau DC).

Notre site porte le nom `Default First Site Name` (Barre de tache->`Server Manager`->`Sites`->`Sites et services`->`Sites`) , nom donnée par AD-DS lors la création du domaine. 

Ce sera notre site pour l'Europe, **alors renommez-le à `Site-EU`** (click droit sur le site->`Rename`)
On pourrait créer un autre site si on avait un autre adaptateur réseau, chacun associé a un sous-réseau. 

Connaissant la notion de site, continuons maintenant avec la classification des GPOs.

### 📊 1.2.1. Classifications des GPO

#### 1. Par Portée (Scope)

| Type de Portée | Description | Exemple |
|----------------|-------------|----------|
| **Locale** | Stratégies **configurées directement sur l'ordinateur**, sans lien avec le domaine AD. Stockées dans la base de registre locale. | Configuration du **pare-feu pour un PC spécifique**, paramètres de sécurité pour un poste isolé |
| **Domaine Active Directory** | Stratégies créées et stockées dans le domaine AD, pouvant être **liées à différents niveaux de la hiérarchie AD - plusieurs Users, Ordinateurs, OU...**. | Complexité des mots de passe pour tout le domaine AD, pare-feu et antivirus pour tous les PCs |

#### 2. Par Cible de Liaison (Link Target)





De plus large à plus petit:

| Cible de Liaison | Périmètre d'Application | Exemple de GPO |
|------------------|------------------------|----------------|
| **Site** Active Directory | Un domaine AD peut avoir plusieurs sites (EU, USA). Ce type de GPO **s'applique aux objets dans un site AD physique** (exemple: Site-EU, comme notre labo). Utile pour des configurations spécifiques à une localisation géographique | Configuration du proxy pour le site de Paris, paramètres d'impression pour le bâtiment Europe |
| **Domaine** Active Directory | S'applique à tous les objets du domaine AD. Idéal pour les politiques de sécurité globales et les configurations d'entreprise du domaine AD. | Règles de sécurité pour tout le domaine (antivirus, pare-feu), politique de mot de passe pour tous les utilisateurs |
| **Unité d'Organisation (OU)** | S'applique aux objets dans l'OU spécifiée et ses sous-OUs. Permet une gestion granulaire par département ou fonction. | Installation des logiciels comptables pour l'OU Comptabilité, restrictions d'accès pour l'OU RH |
| **Filtrage (WMI/Sécurité)** | **Affine l'application** des GPO selon **des critères spécifiques** comme le type d'OS, le modèle de machine, ou les groupes de sécurité. | Automatiosations, paramètres spécifiques pour Windows, gestion d'énergie pour les ordinateurs portables uniquement |







## 3. Création des GPOs


### Exemple pratique: changer le fond d'écran des clients du site EU




- Ouvrir la console de GPOs: `Gestionnaire de serveur` > `Outils` > `Gestion des groupes de stratégie` ou lancer `gpmc.msc` depuis la barre des tâches

- Cliquer (droit) sur le nom du domain
- Cliquer `Lier un objet de stratégie de groupe`
- 





