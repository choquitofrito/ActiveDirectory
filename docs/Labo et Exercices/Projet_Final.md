# Projet final : Maxtec ouvre le département Logistique

!!! info "Cadre"

    - **Durée** : environ 5 h (jour 5), **en binôme**.
    - **Évaluation** : note sur 20, [grille](#grille-devaluation-20) ci-dessous.
    - **Point de départ** : votre lab Maxtec tel qu'il est à la fin du jour 4 (structure, AGDLP Ventes, GPO-1). Valeurs de référence : [Référence du lab Maxtec](Labo/Reference_Lab_Maxtec.md).

    Tout ce qui est demandé ici a déjà été fait une fois pendant la semaine, sur un autre département. La difficulté n'est pas technique : il s'agit de tout faire **proprement, dans l'ordre, et de le prouver**.

## Le contexte

Maxtec ouvre un entrepôt et crée un département **Logistique** de quatre personnes. Le responsable, Louis Lambert, arrive lundi avec son équipe. La direction IT vous confie la mise en service complète : comptes, groupes, dossier partagé, poste de travail, stratégies, délégation au responsable, sécurité, et un rapport pour l'audit interne.

Contrainte de la direction : **tout doit pouvoir être redéployé** sur un autre site par un script, sans casser l'existant s'il est relancé.

## Conventions imposées

Les noms ci-dessous sont **obligatoires** : le script de vérification et le formateur s'appuient dessus.

| Objet | Nom |
|-------|-----|
| OU du département | `OU=Logistique,OU=EU,DC=maxtec,DC=be`, avec `Users`, `Computers`, `Groups` |
| Groupes globaux | `GG-EU-Logistique-Users`, `GG-EU-Logistique-Admin` (dans `OU=Groups,OU=Logistique`) |
| Groupes domaine local | `DL-Logistique-Lecture`, `DL-Logistique-Modification`, `DL-Logistique-ControleTotal` |
| Dossier / partage | `C:\Shares\Logistique` → `\\dns1\Logistique` |
| Poste | `ws-LOG-01` (ou `ws-RH-01` / `ws-IT-01` déplacé temporairement, voir étape 3) |
| GPO ordinateur | `GPO-Logistique-Verrouillage`, liée à `OU=Computers,OU=Logistique` |
| GPO utilisateur | `GPO-Logistique-Utilisateurs`, liée à `OU=Users,OU=Logistique` |
| Stratégie de mot de passe affinée | `PSO-Logistique-Admin`, appliquée à `GG-EU-Logistique-Admin` |
| Script de déploiement | `C:\Scripts\Deploy-Logistique.ps1` |
| Rapport | `C:\Rapports\Logistique_AAAA-MM-JJ.csv` |

## Planning

| Étape | Contenu | Durée |
|-------|---------|-------|
| 1 | Structure : OUs, utilisateurs, groupes, par script | 45 min |
| 2 | Ressources : partage et AGDLP | 60 min |
| 3 | Poste et GPO | 45 min |
| 4 | Délégation au responsable | 30 min |
| 5 | Sécurité et exploitation : PSO, rapport | 45 min |
| 6 | Incident surprise et post-mortem | 45 min |
| — | Documentation et préparation de la démo | 30 min |

Démo en fin de journée : 5 à 10 min par binôme.

---

## Étape 1. Structure (45 min)

!!! example "À réaliser"

    Écrire la première partie de `Deploy-Logistique.ps1`, qui crée :

    1. `OU=Logistique` sous `OU=EU`, et ses trois sous-OUs `Users`, `Computers`, `Groups`. **Toutes** avec `-ProtectedFromAccidentalDeletion $false`.
    2. Les deux groupes globaux de sécurité, dans `OU=Groups,OU=Logistique`.
    3. Les quatre utilisateurs du fichier CSV ci-dessous, dans `OU=Users,OU=Logistique`, avec : `SamAccountName` = login, UPN `login@maxtec.be`, `GivenName`, `Surname`, `DisplayName`, `Title`, `Department = Logistique`, `Company = Maxtec`, mot de passe de lab `Password1!`, compte activé.
    4. Les appartenances : `louis` dans `GG-EU-Logistique-Admin` ; `lea`, `lucas`, `laura` dans `GG-EU-Logistique-Users` (même règle que les autres départements : le responsable n'est pas dans le groupe `-Users`).

    Enregistrez ce fichier sous `C:\Scripts\logistique.csv` (encodage UTF-8) :

    ```text
    Prenom,Nom,Login,Titre
    Louis,Lambert,louis,Responsable Logistique
    Lea,Leclercq,lea,Gestionnaire de stock
    Lucas,Lemaire,lucas,Magasinier
    Laura,Laurent,laura,Planificatrice transport
    ```

    **Exigences sur le script** (elles valent pour tout le projet) :

    - garde-fou en tête : arrêt si le domaine n'est pas `maxtec.be` ;
    - `[CmdletBinding(SupportsShouldProcess)]` : le script doit pouvoir être lancé en `-WhatIf` **avant** la vraie exécution ;
    - idempotent : chaque objet est testé avant création ; une deuxième exécution n'affiche que des "existe déjà", sans erreur rouge ;
    - compatible Windows PowerShell 5.1 (celui du DC).

??? tip "Indices"

    - Squelette possible, repris de `creation_structure.ps1` :

        ```powershell
        [CmdletBinding(SupportsShouldProcess)]
        param([string]$Csv = 'C:\Scripts\logistique.csv')

        Import-Module ActiveDirectory
        if ((Get-ADDomain).DNSRoot -ne 'maxtec.be') { Write-Host "Mauvais domaine. Arrêt." -ForegroundColor Red; return }

        $ouDept = 'OU=Logistique,OU=EU,DC=maxtec,DC=be'
        if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ouDept'")) {
            New-ADOrganizationalUnit -Name 'Logistique' -Path 'OU=EU,DC=maxtec,DC=be' -ProtectedFromAccidentalDeletion $false
            Write-Host "OU Logistique créée" -ForegroundColor Green
        } else { Write-Host "OU Logistique existe déjà" -ForegroundColor Yellow }
        # ... sous-OUs, groupes, utilisateurs (Import-Csv $Csv | ForEach-Object { ... }), membres
        ```

    - Les cmdlets AD (`New-ADUser`, `New-ADGroup`, `Add-ADGroupMember`...) respectent `-WhatIf` automatiquement grâce à `SupportsShouldProcess`. Pour ceux qui ne le gèrent pas, entourez l'appel de `if ($PSCmdlet.ShouldProcess('cible', 'action')) { ... }`.
    - En `-WhatIf`, rien n'est créé : un test "le groupe existe-t-il ?" plus loin dans le script répondra non. C'est normal ; évitez simplement que ça provoque une erreur.
    - Pour les membres : comparez avec `(Get-ADGroupMember $g).SamAccountName` avant d'ajouter.

---

## Étape 2. Ressources : partage et AGDLP (60 min)

!!! example "Cahier des charges"

    | Qui | Besoin sur `\\dns1\Logistique` |
    |-----|-------------------------------|
    | Équipe Logistique (`GG-EU-Logistique-Users`) et responsable (`GG-EU-Logistique-Admin`) | Modification |
    | Comptabilité (`GG-EU-Compta-Users`) | Lecture (bons de livraison, pour rapprocher les factures) |
    | Administrateurs IT (`GG-EU-IT-Admin`) | Contrôle total |

    À réaliser (script ou GUI, au choix ; le script est valorisé) :

    1. Créer les trois groupes **domaine local** `DL-Logistique-Lecture`, `DL-Logistique-Modification`, `DL-Logistique-ControleTotal` (dans `OU=Groups,OU=Logistique` ou dans `OU=Groups,OU=Resources,OU=EU`, au choix, justifiez).
    2. Imbriquer les bons groupes globaux dans chaque DL. **Aucun utilisateur** dans un DL.
    3. Créer `C:\Shares\Logistique`, désactiver l'héritage, ne garder que `SYSTEM` et `Administrateurs` (et `CREATEUR PROPRIETAIRE` si vous le souhaitez), puis ajouter les trois DL avec les droits NTFS correspondants.
    4. Partager en SMB sous le nom `Logistique`, `Everyone` (ou `Utilisateurs authentifiés`) en Modifier : la sécurité réelle est portée par NTFS.
    5. Vérifier avec **Accès effectif** pour `lea`, `louis`, `cindy`, `irene` et un utilisateur sans droit (`vanessa`).

    Mettez dans votre documentation la table AGDLP complète (compte → GG → DL → droit NTFS).

??? tip "Indices"

    - Même démarche que l'[exercice AGDLP](./Exercices:%20AGDLP_Partage_Fichiers.md), sur un autre dossier.
    - PowerShell pour NTFS : `Get-Acl` / `Set-Acl`, ou `icacls` (plus court) :

        ```powershell
        icacls C:\Shares\Logistique /inheritance:d
        icacls C:\Shares\Logistique /grant "MAXTEC\DL-Logistique-Modification:(OI)(CI)M"
        ```

        Avec `icacls`, pensez à retirer ensuite `Utilisateurs` et `Utilisateurs authentifiés` (`/remove`). Sur un système français, les noms des groupes intégrés sont localisés.
    - Partage : `New-SmbShare -Name Logistique -Path C:\Shares\Logistique -ChangeAccess "Tout le monde"`, contrôle avec `Get-SmbShareAccess -Name Logistique`.

---

## Étape 3. Poste et GPO (45 min)

!!! example "Le poste"

    Il faut un ordinateur dans `OU=Computers,OU=Logistique`. Deux options :

    - **Vous avez une VM cliente libre** : renommez-la `ws-LOG-01`, joignez-la au domaine, déplacez-la dans l'OU. Seule cette option permet de prouver les GPO ordinateur avec `gpresult`.
    - **Sinon** : déplacez **temporairement** `ws-RH-01` dans `OU=Computers,OU=Logistique` (et remettez-le dans `OU=Computers,OU=RH` à la fin de la journée), ou `ws-IT-01` déplacé temporairement dans `OU=Computers,OU=Logistique`, puis remis dans `OU=Computers,OU=IT` à la fin (LAPS et GPO IT en dépendent), ou pré-créez l'objet `ws-LOG-01` sans machine : `New-ADComputer -Name ws-LOG-01 -Path "OU=Computers,OU=Logistique,OU=EU,DC=maxtec,DC=be"`. Dans ce dernier cas, la preuve se fait par **Modélisation de stratégie de groupe** dans GPMC.

!!! example "Les GPO"

    Le script crée les deux GPO **vides** et leurs liens (`New-GPO`, `New-GPLink`), en testant d'abord leur existence (`Get-GPO -Name ... -ErrorAction SilentlyContinue`). Le contenu se configure ensuite **à la main dans GPMC**, et le script affiche les chemins à suivre.

    !!! danger "Pas de Set-GPRegistryValue"

        Écrire directement les clés de registre des stratégies Windows avec `Set-GPRegistryValue` produit des paramètres que GPMC affiche comme "nom convivial introuvable". C'est éliminatoire pour le critère GPO de la grille.

    **`GPO-Logistique-Verrouillage`** (Configuration ordinateur), liée à `OU=Computers,OU=Logistique` :

    - `Configuration ordinateur > Stratégies > Paramètres Windows > Paramètres de sécurité > Stratégies locales > Options de sécurité`
    - **Ouverture de session interactive : limite d'inactivité de l'ordinateur** = `300` secondes (vous pouvez descendre à 30 s pour la démo).

    **`GPO-Logistique-Utilisateurs`** (Configuration utilisateur), liée à `OU=Users,OU=Logistique` :

    - `Configuration utilisateur > Préférences > Paramètres Windows > Mappages de lecteurs > Nouveau > Lecteur mappé` : action **Mettre à jour**, emplacement `\\dns1\Logistique`, libellé `Logistique`, lettre **L:**.
    - `Configuration utilisateur > Stratégies > Modèles d'administration > Panneau de configuration` : **Interdire l'accès au Panneau de configuration et à l'application Paramètres du PC** = Activé.

    **Preuve attendue** : sur le poste, session de `lea`, `gpupdate /force`, puis `gpresult /r` (capture des deux sections) et `gpresult /h C:\Temp\lea.html`. Le lecteur L: est visible, le Panneau de configuration est bloqué.

!!! question "À expliquer dans votre documentation"

    Une GPO de verrouillage est déjà liée à `OU=EU` depuis GPO-1 (§2.2). Laquelle s'applique au poste Logistique, et pourquoi ? Montrez-le avec `gpresult /h` (colonne "GPO gagnante").

??? tip "Indices"

    Modèle pour le script (à compléter pour la deuxième GPO) :

    ```powershell
    $gpo = 'GPO-Logistique-Verrouillage'
    $cible = 'OU=Computers,OU=Logistique,OU=EU,DC=maxtec,DC=be'
    if (-not (Get-GPO -Name $gpo -ErrorAction SilentlyContinue)) {
        if ($PSCmdlet.ShouldProcess($gpo, 'Créer la GPO')) {
            New-GPO -Name $gpo -Comment "Verrouillage après inactivité - postes Logistique" | Out-Null
        }
    }
    $lie = (Get-GPInheritance -Target $cible).GpoLinks | Where-Object DisplayName -eq $gpo
    if (-not $lie -and $PSCmdlet.ShouldProcess($cible, "Lier $gpo")) {
        New-GPLink -Name $gpo -Target $cible -LinkEnabled Yes | Out-Null
    }
    Write-Host "Configuration manuelle dans GPMC :" -ForegroundColor Yellow
    Write-Host "  Configuration ordinateur > Stratégies > Paramètres Windows > Paramètres de sécurité" -ForegroundColor Gray
    Write-Host "  > Stratégies locales > Options de sécurité" -ForegroundColor Gray
    Write-Host "  > Ouverture de session interactive : limite d'inactivité de l'ordinateur = 300" -ForegroundColor White
    ```

---

## Étape 4. Délégation (30 min)

!!! example "À réaliser"

    Louis doit pouvoir **réinitialiser les mots de passe** et **déverrouiller les comptes** de son équipe, et **rien d'autre**.

    1. Sur `OU=Users,OU=Logistique`, déléguer à `GG-EU-Logistique-Admin` (assistant **Délégation de contrôle** dans `dsa.msc`) :
        - tâche courante **Réinitialiser les mots de passe utilisateur et forcer le changement de mot de passe à la prochaine ouverture de session** ;
        - tâche personnalisée : objets **Utilisateur**, autorisations de propriété **Lire lockoutTime** et **Écrire lockoutTime** (c'est ce qui permet de déverrouiller).
    2. Tester, en tant que `louis` :
        - **positif** : réinitialiser le mot de passe de `lea` ; déverrouiller `lucas` (verrouillez-le d'abord avec quelques mauvais mots de passe si un seuil est en place, sinon testez seulement la réinitialisation) ;
        - **négatif** : réinitialiser le mot de passe de `vanessa` (Ventes) → refusé ; désactiver le compte de `lea` → refusé.

    Capturez les deux résultats, positif et négatif.

??? tip "Comment tester en tant que louis"

    **Depuis le client avec RSAT** (recommandé) : ouvrez une session `louis` sur le poste client, lancez `dsa.msc` ou PowerShell avec le module ActiveDirectory. Si RSAT n'est pas installé sur Windows 10 : **Paramètres > Système > Fonctionnalités facultatives > Ajouter** → *RSAT : outils Active Directory Domain Services et Lightweight Directory Services*, ou en administrateur :

    ```powershell
    Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
    ```

    L'installation télécharge depuis Windows Update : il faut un accès Internet temporaire (carte NAT).

    **Sans RSAT**, depuis le DC en administrateur, en passant les identifiants de louis à chaque commande :

    ```powershell
    $louis = Get-Credential MAXTEC\louis
    $nouveau = Read-Host "Nouveau mot de passe" -AsSecureString
    Set-ADAccountPassword -Identity lea -Reset -NewPassword $nouveau -Credential $louis        # doit réussir
    Set-ADAccountPassword -Identity vanessa -Reset -NewPassword $nouveau -Credential $louis    # doit échouer : accès refusé
    Disable-ADAccount -Identity lea -Credential $louis                                         # doit échouer
    ```

---

## Étape 5. Sécurité et exploitation (45 min)

!!! example "a) Stratégie de mot de passe affinée"

    Les comptes du groupe `GG-EU-Logistique-Admin` ont des droits sur d'autres comptes : ils méritent une politique plus stricte que le reste du domaine. Créez `PSO-Logistique-Admin` :

    | Paramètre | Valeur |
    |-----------|--------|
    | Précédence | 10 |
    | Longueur minimale | 14 |
    | Complexité | activée |
    | Historique | 24 |
    | Seuil de verrouillage | 5 échecs, fenêtre et durée 30 min |
    | S'applique à | `GG-EU-Logistique-Admin` |

    Via le **Centre d'administration Active Directory** (`dsac.exe` → `maxtec (local)` → `System` → `Password Settings Container`) ou `New-ADFineGrainedPasswordPolicy` + `Add-ADFineGrainedPasswordPolicySubject`. Preuve : `Get-ADUserResultantPasswordPolicy louis`.

    Question pour la documentation : que devient le mot de passe actuel de `louis` (`Password1!`, 10 caractères) ? Est-il refusé immédiatement ou au prochain changement ?

!!! example "b) Rapport pour l'audit"

    Un script (dans `Deploy-Logistique.ps1` ou séparé) produit `C:\Rapports\Logistique_AAAA-MM-JJ.csv`, avec une ligne par constat et au minimum les colonnes `Controle`, `SamAccountName`, `Nom`, `Detail`. Trois contrôles :

    1. comptes de `OU=Logistique` **jamais connectés** ;
    2. comptes de `OU=Logistique` dont le mot de passe a **plus de 90 jours** (le seuil est un paramètre du script) ;
    3. **membres** de chaque groupe `GG-EU-Logistique-*` et `DL-Logistique-*` (y compris les groupes imbriqués).

    Dans un lab neuf, le contrôle 2 sera vide : montrez qu'il fonctionne en relançant avec un seuil de 0 jour.

??? tip "Indices"

    ```powershell
    $base = 'OU=Logistique,OU=EU,DC=maxtec,DC=be'
    Get-ADUser -SearchBase $base -Filter * -Properties LastLogonDate, PasswordLastSet
    # jamais connecté : LastLogonDate vide
    # mot de passe ancien : PasswordLastSet -lt (Get-Date).AddDays(-$Jours)
    Get-ADGroupMember -Identity DL-Logistique-Modification -Recursive
    ```

    Construisez des `[PSCustomObject]@{ Controle = '...'; SamAccountName = ...; Nom = ...; Detail = ... }`, collectez-les dans un tableau, puis `Export-Csv -Path ... -NoTypeInformation -Encoding UTF8 -Delimiter ';'` (le `;` facilite l'ouverture dans Excel en français).

    `LastLogonDate` est calculée à partir de `lastLogonTimestamp`, qui n'est mis à jour que tous les 9 à 14 jours environ : suffisant pour "jamais connecté" ou "inactif depuis 90 jours", pas pour "connecté ce matin".

---

## Étape 6. Incident surprise (45 min)

!!! warning "Déroulement"

    Pendant la pause qui précède cette étape, le formateur introduit **deux pannes** sur votre lab, dans le périmètre Logistique (du type des tickets [D1 et D2](./Exercices:%20Depannage.md)). Vous recevez ce ticket :

    > **Ticket #2026-0501** — Louis Lambert (`louis`), Logistique
    > Plus personne dans l'équipe n'a le lecteur L:, et moi je ne peux plus ouvrir ma session.

    Diagnostiquez, corrigez, prouvez, puis rédigez le post-mortem ci-dessous. Vous pouvez utiliser tous les outils vus pendant la semaine. Vous ne pouvez pas supprimer et recréer les objets concernés.

!!! note "Modèle de post-mortem (10 lignes)"

    ```text
    1. Incident       : (titre court, date, heure de début)
    2. Impact         : (qui était touché, qu'est-ce qui ne marchait plus)
    3. Détection      : (comment le problème a été signalé / constaté)
    4. Diagnostic     : (commandes utilisées et ce qu'elles ont montré, en 2-3 étapes)
    5. Cause racine 1 : (la vraie cause, pas le symptôme)
    6. Cause racine 2 :
    7. Correction     : (ce qui a été modifié, exactement)
    8. Preuve         : (commande / capture qui montre que c'est réparé)
    9. Prévention     : (ce qui éviterait que ça se reproduise, ou le détecterait plus tôt)
    10. Leçon         : (une phrase)
    ```

---

## Livrables

| Livrable | Contenu |
|----------|---------|
| `Deploy-Logistique.ps1` | Étapes 1, 2 et 3 au minimum (structure, DL et partage, GPO vides + liens + instructions). Délégation et PSO en bonus. Exécution en `-WhatIf`, puis réelle, puis deuxième exécution sans erreur. |
| Document technique | 2 à 4 pages, modèle ci-dessous. |
| Post-mortem | 10 lignes, modèle de l'étape 6. |
| Démo | 5 à 10 min : relance du script (idempotence), accès effectif, `gpresult`, test de délégation, incident. |

!!! note "Modèle de document technique"

    ```text
    Projet Logistique — binôme : ............ / ............     Date : ..........

    1. Structure
       - Arborescence des OUs (capture dsa.msc)
       - Utilisateurs : login, titre, groupe

    2. AGDLP
       | Compte(s) | Groupe global | Groupe DL | Droit NTFS |
       |-----------|---------------|-----------|------------|
       | lea, lucas, laura | GG-EU-Logistique-Users | ... | ... |
       | ...       | ...           | ...       | ...        |
       - Capture de l'onglet Sécurité > Avancé de C:\Shares\Logistique
       - Capture Accès effectif pour un utilisateur autorisé et un non autorisé

    3. GPO
       | GPO | Liée à | Paramètre | Valeur |
       |-----|--------|-----------|--------|
       - Captures gpresult /r (ordinateur et utilisateur) ou Modélisation GPMC
       - Réponse : quelle GPO de verrouillage gagne, et pourquoi

    4. Délégation
       - Droits délégués, OU, groupe
       - Captures test positif / test négatif

    5. Sécurité
       - PSO : paramètres, cible, Get-ADUserResultantPasswordPolicy louis
       - Extrait du rapport CSV

    6. Limites connues / ce que vous feriez en production
    ```

---

## Grille d'évaluation /20

| Critère | Points | Insuffisant | Attendu | Excellent |
|---------|:------:|-------------|---------|-----------|
| **Structure et conventions** | 3 | OUs ou groupes mal nommés/placés, `Department` absent, OUs protégées | Tous les objets aux noms et emplacements imposés, `Department = Logistique`, OUs non protégées (2 pts) | Idem, utilisateurs créés depuis le CSV, attributs complets (UPN, titre, société) (3 pts) |
| **AGDLP correct** | 4 | Un utilisateur ou un GG dans l'ACL NTFS, ou un DL en étendue Globale (0-1 pt) | 3 DL domaine local, GG imbriqués correctement, ACL = DL + comptes système uniquement, héritage coupé (3 pts) | Idem + vérification par **Accès effectif** pour 4 comptes dont un refusé, documentée (4 pts) |
| **GPO appliquées et prouvées** | 4 | GPO absentes, non liées, ou configurées par `Set-GPRegistryValue` (0-1 pt) | Les 2 GPO liées aux bonnes OUs et configurées dans GPMC ; `gpresult` ou Modélisation montre qu'elles s'appliquent (3 pts) | Idem + explication correcte de la GPO de verrouillage gagnante (EU vs Logistique) (4 pts) |
| **Délégation testée** | 2 | Délégation absente, ou sur la mauvaise OU, ou donne Contrôle total (0 pt) | Réinitialisation déléguée sur `OU=Users,OU=Logistique`, test positif montré (1 pt) | Réinitialisation + déverrouillage, tests positif **et** négatif montrés (2 pts) |
| **Sécurité et reporting** | 3 | PSO absente ou appliquée à un utilisateur au lieu du groupe ; pas de rapport (0-1 pt) | PSO correcte et prouvée ; rapport CSV avec les 3 contrôles (2 pts) | Idem + seuil paramétrable démontré, groupes imbriqués résolus, réponse juste sur le mot de passe actuel de louis (3 pts) |
| **Incident** | 3 | Symptôme contourné sans cause identifiée (0-1 pt) | Les deux causes racines trouvées et corrigées (2 pts) | Idem + post-mortem clair, preuve de réparation, prévention pertinente (3 pts) |
| **Script idempotent** | 1 | Erreurs à la deuxième exécution, ou pas de `-WhatIf` (0 pt) | Exécution `-WhatIf` propre, deuxième exécution sans erreur (1 pt) | — |

---

## Script de vérification

À lancer sur le DC, PowerShell 5.1 en administrateur. Il ne modifie rien. Les points affichés sont **indicatifs** : ils couvrent ce qu'un script peut constater (environ 11,5 points sur 20). Le reste (preuves `gpresult`, tests de délégation, incident, idempotence) s'évalue pendant la démo.

Enregistrez-le sous `C:\Scripts\Verify-ProjetFinal.ps1`.

Enregistrez en UTF-8 avec BOM (VS Code : barre d'état > UTF-8 > Enregistrer avec l'encodage > UTF-8 with BOM ; le Bloc-notes : Enregistrer sous > Encodage UTF-8 avec BOM).

```powershell
# Verify-ProjetFinal.ps1 - Vérification du projet Logistique (lecture seule)
# Compatible Windows PowerShell 5.1. À exécuter sur le DC en administrateur.
[CmdletBinding()]
param(
    [string]$Chemin  = 'C:\Shares\Logistique',
    [string]$Rapports = 'C:\Rapports'
)

Import-Module ActiveDirectory -ErrorAction Stop
Import-Module GroupPolicy -ErrorAction Stop
if ((Get-ADDomain).DNSRoot -ne 'maxtec.be') { Write-Host "Domaine inattendu. Arrêt." -ForegroundColor Red; return }

$script:points = 0.0
$script:max    = 0.0
$script:erreurs = 0
function Test-Point {
    param([string]$Libelle, [double]$Pts, [scriptblock]$Test, [string]$Conseil = '')
    $script:max += $Pts
    try { $ok = [bool](& $Test) } catch { $ok = $false; $Conseil = "$Conseil (erreur : $($_.Exception.Message))" }
    if ($ok) {
        $script:points += $Pts
        Write-Host ("  [OK] {0} [+{1}]" -f $Libelle, $Pts) -ForegroundColor Green
    } else {
        $script:erreurs++
        Write-Host ("  [KO] {0} [0/{1}]" -f $Libelle, $Pts) -ForegroundColor Red
        if ($Conseil) { Write-Host "      -> $Conseil" -ForegroundColor Yellow }
    }
}

$ouDept   = 'OU=Logistique,OU=EU,DC=maxtec,DC=be'
$ouUsers  = "OU=Users,$ouDept"
$ouComp   = "OU=Computers,$ouDept"
$ouGroups = "OU=Groups,$ouDept"
$attendus = @{ louis = 'GG-EU-Logistique-Admin'; lea = 'GG-EU-Logistique-Users'; lucas = 'GG-EU-Logistique-Users'; laura = 'GG-EU-Logistique-Users' }
$SidType  = [System.Security.Principal.SecurityIdentifier]

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Vérification du projet Logistique" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# ---------------------------------------------------------------- 1. Structure (3)
Write-Host "`n[1] Structure et conventions" -ForegroundColor Cyan
Test-Point "OU Logistique + Users/Computers/Groups, non protégées" 1 {
    $ous = foreach ($dn in @($ouDept, $ouUsers, $ouComp, $ouGroups)) {
        Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$dn'" -Properties ProtectedFromAccidentalDeletion
    }
    (@($ous).Count -eq 4) -and -not ($ous | Where-Object { $_.ProtectedFromAccidentalDeletion })
} "New-ADOrganizationalUnit ... -ProtectedFromAccidentalDeletion `$false"

Test-Point "4 utilisateurs dans OU=Users,OU=Logistique avec Department = Logistique" 1 {
    $ko = 0
    foreach ($login in $attendus.Keys) {
        $u = Get-ADUser -Filter "SamAccountName -eq '$login'" -Properties Department
        if (-not $u) { Write-Host "      absent : $login" -ForegroundColor Yellow; $ko++; continue }
        if ($u.DistinguishedName -notlike "*,$ouUsers") { Write-Host "      mauvaise OU : $login" -ForegroundColor Yellow; $ko++ }
        if ($u.Department -ne 'Logistique') { Write-Host "      Department incorrect : $login ($($u.Department))" -ForegroundColor Yellow; $ko++ }
    }
    $ko -eq 0
}

Test-Point "Groupes GG-EU-Logistique-* globaux, dans OU=Groups, membres corrects" 1 {
    $ko = 0
    foreach ($g in @('GG-EU-Logistique-Users', 'GG-EU-Logistique-Admin')) {
        $grp = Get-ADGroup -Filter "Name -eq '$g'"
        if (-not $grp) { Write-Host "      absent : $g" -ForegroundColor Yellow; $ko++; continue }
        if ($grp.GroupScope -ne 'Global' -or $grp.GroupCategory -ne 'Security') { Write-Host "      $g : étendue/type incorrect" -ForegroundColor Yellow; $ko++ }
        if ($grp.DistinguishedName -notlike "*,$ouGroups") { Write-Host "      $g : pas dans $ouGroups" -ForegroundColor Yellow; $ko++ }
        $membres = @(Get-ADGroupMember $g | Select-Object -ExpandProperty SamAccountName)
        $voulus  = @($attendus.Keys | Where-Object { $attendus[$_] -eq $g })
        if ((($membres | Sort-Object) -join ',') -ne (($voulus | Sort-Object) -join ',')) {
            Write-Host "      $g : membres = $($membres -join ', ') (attendu : $($voulus -join ', '))" -ForegroundColor Yellow; $ko++
        }
    }
    $ko -eq 0
}

# ---------------------------------------------------------------- 2. AGDLP (4)
Write-Host "`n[2] AGDLP" -ForegroundColor Cyan
$dlDef = @{
    'DL-Logistique-Lecture'  = @{ Membres = @('GG-EU-Compta-Users');                              Droit = 'ReadAndExecute' }
    'DL-Logistique-Modification' = @{ Membres = @('GG-EU-Logistique-Admin', 'GG-EU-Logistique-Users'); Droit = 'Modify' }
    'DL-Logistique-ControleTotal' = @{ Membres = @('GG-EU-IT-Admin');                                   Droit = 'FullControl' }
}
Test-Point "3 DL en domaine local, ne contenant que les bons groupes globaux" 1 {
    $ko = 0
    foreach ($dl in $dlDef.Keys) {
        $grp = Get-ADGroup -Filter "Name -eq '$dl'"
        if (-not $grp) { Write-Host "      absent : $dl" -ForegroundColor Yellow; $ko++; continue }
        if ($grp.GroupScope -ne 'DomainLocal') { Write-Host "      $dl : étendue $($grp.GroupScope)" -ForegroundColor Yellow; $ko++ }
        $m = @(Get-ADGroupMember $dl)
        if ($m | Where-Object { $_.objectClass -ne 'group' }) { Write-Host "      $dl : contient un utilisateur ou un ordinateur" -ForegroundColor Yellow; $ko++ }
        $noms = @($m | Select-Object -ExpandProperty SamAccountName)
        if ((($noms | Sort-Object) -join ',') -ne (($dlDef[$dl].Membres | Sort-Object) -join ',')) {
            Write-Host "      $dl : membres = $($noms -join ', ')" -ForegroundColor Yellow; $ko++
        }
    }
    $ko -eq 0
}

$acl = $null
if (Test-Path $Chemin) { $acl = (Get-Item $Chemin).GetAccessControl('Access') }
Test-Point "ACL NTFS : héritage coupé, uniquement DL-Logistique-* + SYSTEM/Administrateurs/CREATEUR PROPRIETAIRE" 1.5 {
    if (-not $acl) { return $false }
    $autorises = @('S-1-5-18', 'S-1-5-32-544', 'S-1-3-0')
    foreach ($dl in $dlDef.Keys) { $g = Get-ADGroup -Filter "Name -eq '$dl'"; if ($g) { $autorises += $g.SID.Value } }
    $intrus = @($acl.GetAccessRules($true, $true, $SidType) | Where-Object { $autorises -notcontains $_.IdentityReference.Value })
    foreach ($i in $intrus) {
        $nom = $i.IdentityReference.Value
        try { $nom = $i.IdentityReference.Translate([System.Security.Principal.NTAccount]).Value } catch { }
        Write-Host "      entrée non autorisée : $nom" -ForegroundColor Yellow
    }
    $acl.AreAccessRulesProtected -and $intrus.Count -eq 0
} "Aucun GG-, aucun utilisateur, ni Utilisateurs/Utilisateurs authentifiés dans l'ACL"

Test-Point "Droits NTFS : Lecture = Lecture et exécution, Modification = Modification, ControleTotal = Contrôle total" 1 {
    if (-not $acl) { return $false }
    $ko = 0
    foreach ($dl in $dlDef.Keys) {
        $g = Get-ADGroup -Filter "Name -eq '$dl'"
        if (-not $g) { $ko++; continue }
        $voulu = [System.Security.AccessControl.FileSystemRights]$dlDef[$dl].Droit
        $ok = $acl.GetAccessRules($true, $true, $SidType) | Where-Object {
            $_.IdentityReference.Value -eq $g.SID.Value -and $_.AccessControlType -eq 'Allow' -and
            (($_.FileSystemRights -band $voulu) -eq $voulu) }
        if (-not $ok) { Write-Host "      $dl : droit $($dlDef[$dl].Droit) absent" -ForegroundColor Yellow; $ko++ }
    }
    $ko -eq 0
}

Test-Point "Partage SMB 'Logistique' sur $Chemin" 0.5 {
    $s = Get-SmbShare -Name 'Logistique' -ErrorAction SilentlyContinue
    if (-not $s) { return $false }
    Get-SmbShareAccess -Name 'Logistique' | ForEach-Object {
        Write-Host "      SMB : $($_.AccountName) = $($_.AccessRight) ($($_.AccessControlType))" -ForegroundColor Gray }
    $s.Path.TrimEnd('\') -eq $Chemin.TrimEnd('\')
}

# ---------------------------------------------------------------- 3. GPO (2 automatiques / 4)
Write-Host "`n[3] Poste et GPO" -ForegroundColor Cyan
Test-Point "Au moins un ordinateur dans OU=Computers,OU=Logistique" 0.5 {
    @(Get-ADComputer -SearchBase $ouComp -Filter *).Count -ge 1
} "Joindre/déplacer ws-LOG-01 (ou déplacer ws-RH-01 ou ws-IT-01 temporairement)"

foreach ($def in @(@{ Gpo = 'GPO-Logistique-Verrouillage'; Cible = $ouComp }, @{ Gpo = 'GPO-Logistique-Utilisateurs'; Cible = $ouUsers })) {
    Test-Point "$($def.Gpo) existe et est liée (lien actif) à $($def.Cible.Split(',')[0..1] -join ',')" 0.75 {
        if (-not (Get-GPO -Name $def.Gpo -ErrorAction SilentlyContinue)) { return $false }
        $l = (Get-GPInheritance -Target $def.Cible).GpoLinks | Where-Object { $_.DisplayName -eq $def.Gpo }
        $l -and $l.Enabled
    } "New-GPO / New-GPLink, puis configuration dans GPMC"
}

# ---------------------------------------------------------------- 4. Délégation (1 automatique / 2)
Write-Host "`n[4] Délégation" -ForegroundColor Cyan
$aclOu = Get-Acl -Path "AD:\$ouUsers"
$aces  = @($aclOu.Access | Where-Object { $_.IdentityReference.Value -like '*\GG-EU-Logistique-Admin' })
Test-Point "GG-EU-Logistique-Admin : droit étendu Réinitialiser le mot de passe" 0.5 {
    [bool]($aces | Where-Object {
        $_.ObjectType -eq [guid]'00299570-246d-11d0-a768-00aa006e0529' -and
        $_.ActiveDirectoryRights -match 'ExtendedRight' -and $_.AccessControlType -eq 'Allow' })
} "Assistant Délégation de contrôle sur OU=Users,OU=Logistique"
Test-Point "GG-EU-Logistique-Admin : écriture de lockoutTime (déverrouillage)" 0.5 {
    [bool]($aces | Where-Object {
        $_.ObjectType -eq [guid]'28630ebf-41d5-11d1-a9c1-0000f80367c1' -and
        $_.ActiveDirectoryRights -match 'WriteProperty' -and $_.AccessControlType -eq 'Allow' })
} "Tâche personnalisée : objets Utilisateur > Écrire lockoutTime"
if ($aces | Where-Object { $_.ActiveDirectoryRights -match 'GenericAll' }) {
    Write-Host "  ! Attention : GG-EU-Logistique-Admin a Contrôle total sur l'OU (trop large)" -ForegroundColor Yellow
}

# ---------------------------------------------------------------- 5. Sécurité (1,5 automatique / 3)
Write-Host "`n[5] Sécurité et reporting" -ForegroundColor Cyan
Test-Point "Une PSO s'applique au groupe GG-EU-Logistique-Admin" 1 {
    $gdn = (Get-ADGroup 'GG-EU-Logistique-Admin').DistinguishedName
    $pso = Get-ADFineGrainedPasswordPolicy -Filter * | Where-Object { $_.AppliesTo -contains $gdn }
    if ($pso) { $pso | ForEach-Object { Write-Host "      $($_.Name) : longueur $($_.MinPasswordLength), seuil $($_.LockoutThreshold), précédence $($_.Precedence)" -ForegroundColor Gray } }
    [bool]$pso
} "New-ADFineGrainedPasswordPolicy + Add-ADFineGrainedPasswordPolicySubject -Subjects GG-EU-Logistique-Admin"
Test-Point "Rapport CSV présent dans $Rapports" 0.5 {
    [bool](Get-ChildItem -Path $Rapports -Filter 'Logistique_*.csv' -ErrorAction SilentlyContinue)
}

# ---------------------------------------------------------------- Bilan
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host ("Points automatiques : {0} / {1}" -f $script:points, $script:max) -ForegroundColor Cyan
Write-Host "Évalués pendant la démo : preuves gpresult (2), tests de délégation (1), rapport et PSO (1,5)," -ForegroundColor Gray
Write-Host "incident et post-mortem (3), idempotence du script (1)." -ForegroundColor Gray
if ($script:erreurs -eq 0) { Write-Host "Aucun écart détecté." -ForegroundColor Green }
else { Write-Host "$($script:erreurs) point(s) à revoir." -ForegroundColor Red }
```
