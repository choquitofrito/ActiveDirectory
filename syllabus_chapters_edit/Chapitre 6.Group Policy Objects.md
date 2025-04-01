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

### 🌐 Qu'est-ce qu'une Stratégie de Groupe ?

| 🛠️ Capacités | Description |
|------------|-------------|
| 💻 **Configuration** | Gérer de manière centralisée les configurations |
| 🔒 **Sécurité** | Appliquer des paramètres de sécurité |
| 💾 **Déploiement** | Déployer des logiciels |
| 🖥️ **Scripts** | Configurer des scripts de démarrage/arrêt |

> 💡 **Principe clé**: Modifier **un seul GPO** pour configurer **plusieurs machines ou utilisateurs**!NS

### 📊 Classifications des GPO

#### Par Portée (Scope)

| Type de Portée | Description | Exemple |
|----------------|-------------|----------|
| Locale | Stratégies configurées directement sur l'ordinateur, sans lien avec Active Directory. Stockées dans la base de registre locale. | Stratégies de sécurité locales, paramètres de pare-feu local |
| Domaine Active Directory | Stratégies créées et stockées dans Active Directory, pouvant être liées à différents niveaux de la hiérarchie AD. | GPO-MotDePasse-Domain, GPO-Securite-Entreprise |

#### Par Cible de Liaison (Link Target)

| Cible de Liaison | Périmètre d'Application | Exemple de GPO |
|------------------|------------------------|----------------|
| Site Active Directory | S'applique aux objets dans un site AD physique. Utile pour des configurations spécifiques à une localisation géographique (ex: serveurs proxy, imprimantes). | GPO-Proxy-EUSite, GPO-Imprimantes-ParisOffice |
| Domaine Active Directory | S'applique à tous les objets du domaine AD. Idéal pour les politiques de sécurité globales et les configurations d'entreprise. | GPO-Securite-Domain, GPO-MotDePasse-Complexite |
| Unité d'Organisation (OU) | S'applique aux objets dans l'OU spécifiée et ses sous-OUs. Permet une gestion granulaire par département ou fonction. | GPO-Apps-ComptabiliteOU, GPO-Restrictions-RH |
| Filtrage (WMI/Sécurité) | Affine l'application des GPO selon des critères spécifiques comme le type d'OS, le modèle de machine, ou les groupes de sécurité. | GPO-Windows11-Only, GPO-Laptops-Power |

#### Par Objectif

| Catégorie | Description Détaillée | Exemples |
|-----------|---------------------|----------|
| Sécurité | Implémente les politiques de sécurité de l'entreprise : complexité des mots de passe, restrictions d'accès, paramètres de pare-feu, etc. | GPO-ComplexiteMotDePasse, GPO-ParamParesFeu |
| Configuration Utilisateur | Configure l'environnement de travail des utilisateurs : fond d'écran, paramètres Office, mappages de lecteurs réseau. | GPO-FondEcran-Corporate, GPO-MapLecteurs-Dept |
| Configuration Système | Gère les paramètres système : services Windows, paramètres réseau, configuration des mises à jour. | GPO-Services-Windows, GPO-WSUS-Config |
| Déploiement | Automatise l'installation et la mise à jour des applications, pilotes et correctifs sur les postes clients. | GPO-Deploy-Office365, GPO-Update-Adobe |
| Restrictions | Contrôle l'accès aux fonctionnalités système et applications selon les besoins métier et la sécurité. | GPO-BlockUSB-RH, GPO-RestrictPowerShell |
| Automatisation | Automatise les tâches via des scripts exécutés à des moments spécifiques (connexion, démarrage, etc.). | GPO-Scripts-Logon, GPO-Backup-UserFiles |

> ⚠️ **Note**: Dans tous ces tableaux, "AD" ou "Active Directory" fait spécifiquement référence au domaine Active Directory, distinct des zones DNS.

## 2. Hiérarchie et Application






