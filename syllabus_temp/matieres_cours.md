# Matières du Cours Active Directory

## Sujets Principaux

1. Introduction et Installation
   - Installation de Windows Server 2022 sur VirtualBox
     * Configuration matérielle requise
     * Activation de PAE/NX
     * Installation du système
   - Configuration du réseau
     * Adressage IP (192.168.0.0/24)
     * Configuration DNS
   - Préparation pour Active Directory

2. Services DNS (Domain Name System)
   - Architecture DNS pour Active Directory
     * Structure DNS plate vs sous-domaines
     * Intégration avec AD
   - Configuration DNS
     * Zones de recherche directe et inverse
     * Enregistrements DNS essentiels
   - Résolution des problèmes DNS

3. Active Directory Domain Services (AD DS)
   - Installation du domaine maxtec.be
   - Structure organisationnelle
     * Départements (Comptabilité, RH, Ventes)
     * Infrastructure IT
   - Configuration du contrôleur de domaine

4. Unités d'Organisation (OU)
   - Structure des OUs par département
     * Comptabilité (Utilisateurs, Ordinateurs)
     * RH (Utilisateurs, Ordinateurs)
     * Ventes (Utilisateurs, Ordinateurs)
     * Infrastructure (Serveurs, AdminComptes)
   - Délégation administrative
     * Gestion par département
     * Séparation des rôles
   - Bonnes pratiques

5. Gestion des Utilisateurs
   - Création et configuration des comptes
     * Convention de nommage
     * Emplacement dans les OUs
   - Gestion des profils
   - Stratégies de mot de passe

6. Gestion des Groupes
   - Types de groupes
     * Groupes globaux (GG-) par département
     * Groupes de domaine local (DL-) pour les ressources
   - Stratégie de nommage cohérente
   - Bonnes pratiques AGDLP

7. Partages et Permissions
   - Structure des partages départementaux
   - Permissions NTFS
   - Permissions de partage
   - Héritage et sécurité

8. Stratégies de Groupe (GPO)
   - GPOs par département
   - Sécurité des postes de travail
   - Déploiement de configurations
   - Résolution des problèmes

Environnement de formation :
- Domaine : maxtec.be
- Contrôleur de domaine : dns1.maxtec.be (192.168.0.2)
- Départements : Comptabilité, RH, Ventes
- Structure : OUs par département avec séparation Utilisateurs/Ordinateurs

Note : Ce cours utilise une approche pratique avec des exercices basés sur des scénarios réels d'entreprise.
