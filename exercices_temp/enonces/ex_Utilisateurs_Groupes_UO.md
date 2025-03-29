# Exercices Pratiques : Gestion des Utilisateurs, Groupes et UO

## Exercice 1 : Mise en place d'une structure départementale

### Contexte
Le département Comptabilité a besoin d'organiser ses ressources pour un nouveau projet d'audit.

### Tâches
1. Créer un partage réseau `\\dns1\Audit2025` sur le contrôleur de domaine
2. Créer la structure suivante :
   - UO: `EU`
     - UO: `Comptabilité`
       - Users
       - Computers
       - Groups
3. Créer les groupes suivants :
   - `GG-EU-Audit-Lecture` (Groupe Global)
   - `GG-EU-Audit-ModificationRapports` (Groupe Global)
   - `GG-EU-Audit-Admin` (Groupe Global)
4. Créer les dossiers suivants dans le partage :
   - `\\dns1\Audit2025\Rapports`
   - `\\dns1\Audit2025\Documents_Source`
   - `\\dns1\Audit2025\Archives`

### Configuration des permissions
- `GS-Audit-Lecture` : Lecture sur tous les dossiers
- `GS-Audit-ModificationRapports` : Modification sur `Rapports`, Lecture sur les autres
- `GS-Audit-Admin` : Contrôle total sur tous les dossiers

### Test pratique
1. Se connecter sur client1 avec sophie.dubois
2. Créer un document dans chaque dossier
3. Se connecter sur client2 avec jean.martin
4. Vérifier les accès selon les permissions



## Exercice 2 : Gestion des Ressources Humaines

### Contexte
Le département RH doit gérer un processus de recrutement avec des documents confidentiels.

### Tâches
1. Créer un partage `\\dns1\Recrutement` avec les sous-dossiers :
   - `Candidatures`
   - `Contrats`
   - `Evaluations`
2. Créer les utilisateurs :
   - marie.dupont (Responsable RH)
   - sophie.martin (Assistante RH)
   - pierre.dubois (Recruteur)
3. Créer les groupes :
   - `GG-EU-RH-Direction` (pour marie.dupont)
   - `GG-EU-RH-Assistants` (pour sophie.martin)
   - `GG-EU-RH-Recruteurs` (pour pierre.dubois)
4. Configurer les permissions :
   - Direction : Contrôle total sur tous les dossiers
   - Assistants : Modification sur Candidatures, Lecture sur Contrats
   - Recruteurs : Modification sur Candidatures et Evaluations

### Test pratique
1. Se connecter sur client1 avec marie.dupont
2. Créer un document dans chaque dossier
3. Se connecter sur client2 avec sophie.martin
4. Vérifier les accès selon les permissions



## Exercice 3 : Projet Marketing 

### Contexte
L'équipe Marketing lance une nouvelle campagne publicitaire nécessitant une collaboration étroite avec les Ventes.

### Structure à créer
1. Partages réseau :
   - `\\dns1\Marketing\Campagne2025`
     - `Visuels`
     - `Presentations`
     - `Rapports_Ventes`
   - `\\dns1\Marketing\Resources`
     - `Templates`
     - `Logos`
     - `Photos`

2. Groupes :
   - `GG-EU-Marketing-Designers`
   - `GG-EU-Marketing-Managers`
   - `GG-EU-Ventes-Analystes`

3. Utilisateurs à créer :
   - lucas.bernard (Designer)
   - emma.petit (Manager Marketing)
   - thomas.richard (Analyste Ventes)

### Configuration des accès
1. Designers :
   - Modification sur Visuels
   - Lecture sur Templates, Logos, Photos
2. Managers :
   - Contrôle total sur tous les dossiers Marketing
   - Modification sur Rapports_Ventes
3. Analystes Ventes :
   - Modification sur Rapports_Ventes
   - Lecture sur Presentations

### Test de validation
1. Créer des fichiers test dans chaque dossier
2. Vérifier les accès avec chaque compte
3. Tester le partage de documents entre équipes


## Exercice 4 : Gestion du Service Technique

### Contexte
Le service technique doit gérer les tickets d'incidents et la documentation technique.

### Structure à créer
1. Partages réseau :
   - `\\dns1\Support`
     - `Tickets`
     - `Documentation`
     - `Procedures`
     - `Outils`

2. Groupes et rôles :
   - `GS-Support-N1` (Support niveau 1)
   - `GS-Support-N2` (Support niveau 2)
   - `GS-Support-Admin` (Administrateurs support)

3. Utilisateurs :
   - alex.martin (Support N1)
   - julie.blanc (Support N2)
   - marc.dubois (Admin Support)

### Configuration
1. Permissions par niveau :
   - N1 :
     * Lecture sur Documentation et Procedures
     * Modification sur Tickets
   - N2 :
     * Modification sur Documentation et Procedures
     * Modification sur Tickets
     * Lecture sur Outils
   - Admin :
     * Contrôle total sur tous les dossiers

### Test pratique
1. Créer des tickets test avec alex.martin
2. Modifier la documentation avec julie.blanc
3. Vérifier les restrictions d'accès aux Outils

## Exercice 5 : Projet R&D

### Contexte
L'équipe R&D travaille sur un nouveau projet confidentiel avec des prestataires externes.

### Structure
1. Partages :
   - `\\dns1\RD\Projet2025`
     - `Specs`
     - `Tests`
     - `Resultats`
     - `External`

2. UOs et Groupes :
   - OU: `R&D`
     - Sous-OU: `Internes`
     - Sous-OU: `Prestataires`
   - Groupes :
     - `GS-RD-Chercheurs`
     - `GS-RD-Testeurs`
     - `GS-RD-External`

3. Utilisateurs :
   - sarah.leroy (Chercheuse)
   - paul.martin (Testeur)
   - john.smith (Prestataire)

### Configuration
1. Chercheurs :
   - Contrôle total sur Specs
   - Modification sur Tests et Resultats
2. Testeurs :
   - Modification sur Tests et Resultats
   - Lecture sur Specs
3. Prestataires :
   - Modification sur External
   - Lecture sur Specs

## Exercice 6 : Gestion de la Communication

### Contexte
L'équipe Communication gère les ressources médias et les communiqués de presse.

### Structure
1. Partages :
   - `\\dns1\Communication`
     - `Presse`
     - `Media`
     - `Templates`
     - `Archives`

2. Groupes :
   - `GS-Com-Redacteurs`
   - `GS-Com-MediaTeam`
   - `GS-Com-Stagiaires`

3. Utilisateurs :
   - claire.dupont (Rédactrice)
   - david.martin (Media Manager)
   - leo.blanc (Stagiaire)

### Configuration
1. Rédacteurs :
   - Modification sur Presse et Templates
   - Lecture sur Media
2. MediaTeam :
   - Contrôle total sur Media
   - Modification sur Templates
3. Stagiaires :
   - Lecture sur Templates
   - Modification sur dossier spécifique Media/EnCours

