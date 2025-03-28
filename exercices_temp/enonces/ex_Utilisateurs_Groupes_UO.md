# Exercices Pratiques : Gestion des Utilisateurs, Groupes et UO

## Exercice 1 : Mise en place d'une structure départementale (30 minutes)

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



## Exercice 2 : Gestion des Ressources Humaines (45 minutes)

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



## Exercice 3 : Projet Marketing (1 heure)

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

## Scripts de configuration

### Script de création des ressources (à exécuter sur le DC)
```powershell
# Création des partages et dossiers
New-Item -Path "C:\Shares\Audit2025" -ItemType Directory -Force
New-Item -Path "C:\Shares\Recrutement" -ItemType Directory -Force
New-Item -Path "C:\Shares\Marketing" -ItemType Directory -Force

# Création des sous-dossiers
$folders = @(
    "C:\Shares\Audit2025\Rapports",
    "C:\Shares\Audit2025\Documents_Source",
    "C:\Shares\Audit2025\Archives",
    "C:\Shares\Recrutement\Candidatures",
    "C:\Shares\Recrutement\Contrats",
    "C:\Shares\Recrutement\Evaluations",
    "C:\Shares\Marketing\Campagne2025\Visuels",
    "C:\Shares\Marketing\Campagne2025\Presentations",
    "C:\Shares\Marketing\Campagne2025\Rapports_Ventes",
    "C:\Shares\Marketing\Resources\Templates",
    "C:\Shares\Marketing\Resources\Logos",
    "C:\Shares\Marketing\Resources\Photos"
)

foreach ($folder in $folders) {
    New-Item -Path $folder -ItemType Directory -Force
}

# Création des partages réseau
New-SmbShare -Name "Audit2025" -Path "C:\Shares\Audit2025" -FullAccess "Administrateurs"
New-SmbShare -Name "Recrutement" -Path "C:\Shares\Recrutement" -FullAccess "Administrateurs"
New-SmbShare -Name "Marketing" -Path "C:\Shares\Marketing" -FullAccess "Administrateurs"
\`\`\`

### Script de nettoyage (à exécuter sur le DC)
\`\`\`powershell
# Suppression des partages
Remove-SmbShare -Name "Audit2025" -Force
Remove-SmbShare -Name "Recrutement" -Force
Remove-SmbShare -Name "Marketing" -Force

# Suppression des dossiers
Remove-Item -Path "C:\Shares" -Recurse -Force

# Suppression des groupes
$groups = @(
    "GG-EU-Audit-Lecture",
    "GG-EU-Audit-ModificationRapports",
    "GG-EU-Audit-Admin",
    "GG-EU-RH-Direction",
    "GG-EU-RH-Assistants",
    "GG-EU-RH-Recruteurs",
    "GG-EU-Marketing-Designers",
    "GG-EU-Marketing-Managers",
    "GG-EU-Ventes-Analystes"
)

foreach ($group in $groups) {
    Remove-ADGroup -Identity $group -Confirm:$false
}

# Suppression des utilisateurs
$users = @(
    "marie.dupont",
    "sophie.martin",
    "pierre.dubois",
    "lucas.bernard",
    "emma.petit",
    "thomas.richard"
)

foreach ($user in $users) {
    Remove-ADUser -Identity $user -Confirm:$false
}

# Suppression des UOs
Get-ADOrganizationalUnit -Filter * | Where-Object {$_.Name -in @("Auditeurs", "Consultants", "Comptabilité")} | Remove-ADOrganizationalUnit -Recursive -Confirm:$false
```

## Notes importantes
- Exécutez d'abord le script de nettoyage pour vous assurer que l 'environnement est propre
- Les scripts doivent être exécutés avec des privilèges d'administrateur
- Vérifiez que les partages sont accessibles depuis les postes clients
- Documentez toute erreur ou comportement inattendu pendant les exercices

## Exercice 4 : Gestion du Service Technique (45 minutes)

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

## Exercice 5 : Projet R&D (1 heure)

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

## Exercice 6 : Gestion de la Communication (30 minutes)

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

### Scripts complémentaires

```powershell
# Ajout aux scripts de création
$additional_folders = @(
    "C:\Shares\Support\Tickets",
    "C:\Shares\Support\Documentation",
    "C:\Shares\Support\Procedures",
    "C:\Shares\Support\Outils",
    "C:\Shares\RD\Projet2025\Specs",
    "C:\Shares\RD\Projet2025\Tests",
    "C:\Shares\RD\Projet2025\Resultats",
    "C:\Shares\RD\Projet2025\External",
    "C:\Shares\Communication\Presse",
    "C:\Shares\Communication\Media",
    "C:\Shares\Communication\Templates",
    "C:\Shares\Communication\Archives"
)

foreach ($folder in $additional_folders) {
    New-Item -Path $folder -ItemType Directory -Force
}

# Création des nouveaux partages
New-SmbShare -Name "Support" -Path "C:\Shares\Support" -FullAccess "Administrateurs"
New-SmbShare -Name "RD" -Path "C:\Shares\RD" -FullAccess "Administrateurs"
New-SmbShare -Name "Communication" -Path "C:\Shares\Communication" -FullAccess "Administrateurs"
```

```powershell
# Ajout au script de nettoyage
$additional_groups = @(
    "GS-Support-N1",
    "GS-Support-N2",
    "GS-Support-Admin",
    "GS-RD-Chercheurs",
    "GS-RD-Testeurs",
    "GS-RD-External",
    "GS-Com-Redacteurs",
    "GS-Com-MediaTeam",
    "GS-Com-Stagiaires"
)

$additional_users = @(
    "alex.martin",
    "julie.blanc",
    "marc.dubois",
    "sarah.leroy",
    "paul.martin",
    "john.smith",
    "claire.dupont",
    "david.martin",
    "leo.blanc"
)

foreach ($group in $additional_groups) {
    Remove-ADGroup -Identity $group -Confirm:$false
}

foreach ($user in $additional_users) {
    Remove-ADUser -Identity $user -Confirm:$false
}

# Suppression des partages additionnels
Remove-SmbShare -Name "Support" -Force
Remove-SmbShare -Name "RD" -Force
Remove-SmbShare -Name "Communication" -Force
```
