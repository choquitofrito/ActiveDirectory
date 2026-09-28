!!! info "Avant de commencer"

    - Lab de référence : [Référence du lab Maxtec](Labo/Reference_Lab_Maxtec.md). Convention du lab : login = prénom en minuscules, sans accent (`charlotte`, `ines`), UPN `prenom@maxtec.be`.
    - Les exercices **créent de nouveaux utilisateurs** qui n'existent pas dans le lab : Chloé Dumont (Comptabilite), Karim Benali (RH), Marek Wojcik (consultant externe).
    - Certains exercices **modifient des comptes du lab** (Charles, Ivan, Ines). Une étape de retour arrière est indiquée à chaque fois : ces comptes servent dans les exercices GPO et AGDLP.
    - Les tests de connexion se font sur `ws-IT-01`. Si la GPO de restriction d'ouverture de session de [GPO-2, exercice 5](./Exercices:%20GPO-2.md) est active, seuls les membres d'IT peuvent s'y connecter : supprimez son lien.

### Exercice 1: Création d'un Nouvel Employé

!!! example "Contexte"

    Le département Comptabilite de Maxtec accueille une nouvelle comptable junior, **Chloé Dumont**. Elle n'existe pas encore dans l'annuaire : vous créez son compte.

!!! info "Tâches à réaliser"

    1. Créer le compte en suivant la convention de nommage du lab (login = prénom sans accent)
    2. Définir un mot de passe temporaire qui respecte la politique de sécurité
    3. Configurer le compte pour que Chloé doive changer son mot de passe à la première connexion
    4. Remplir les informations de base :
        - Description : "Comptable Junior - Comptabilité"
        - Bureau : "Bâtiment A - 1er étage"
        - Téléphone : "+32 2 123 45 68"
        - Service (`Department`) : `Comptabilite`
        - Placer le compte dans `OU=Users,OU=Comptabilite,OU=EU,DC=maxtec,DC=be`

??? success "Solution"

    1. `dsa.msc` > `EU > Comptabilite > Users` > clic droit > **Nouveau > Utilisateur**
    2. Prénom `Chloé`, Nom `Dumont`, nom d'ouverture de session `chloe` (pas d'accent dans un login : certains outils et scripts les gèrent mal)
    3. Mot de passe temporaire (au moins 7 caractères et 3 types parmi majuscules, minuscules, chiffres, symboles avec la politique par défaut), cochez **L'utilisateur doit changer le mot de passe à la prochaine ouverture de session**
    4. Propriétés du compte : onglet **Général** (Description, Bureau, Téléphone), onglet **Organisation** (Service = `Comptabilite`)
    5. Pour qu'elle ait les accès de son équipe : onglet **Membre de** > **Ajouter…** > `GG-EU-Compta-Users` > **Vérifier les noms** > **OK**

    Le **Centre d'administration Active Directory** (`dsac.exe`) fait la même chose en un seul formulaire : `maxtec (local) > EU > Comptabilite > Users` > volet **Tâches** > **Nouveau > Utilisateur**.

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    New-ADUser -Name "Chloé Dumont" -GivenName "Chloé" -Surname "Dumont" -SamAccountName chloe -UserPrincipalName chloe@maxtec.be `
        -Path "OU=Users,OU=Comptabilite,OU=EU,DC=maxtec,DC=be" -Department Comptabilite -Description "Comptable Junior - Comptabilité" `
        -Office "Bâtiment A - 1er étage" -OfficePhone "+32 2 123 45 68" `
        -AccountPassword (Read-Host -AsSecureString "Mot de passe temporaire") -ChangePasswordAtLogon $true -Enabled $true
    Add-ADGroupMember GG-EU-Compta-Users -Members chloe
    ```

### Exercice 2: Restrictions d'Accès

!!! warning "Contraintes de sécurité"

    Pour des raisons de sécurité, Chloé ne doit pouvoir se connecter que :

    - Sur le poste `ws-Compta-01.maxtec.be` (ce poste n'existe pas encore : vous allez **pré-créer** son objet ordinateur)
    - Du lundi au vendredi, de 8h à 18h (choisissez une plage qui vous permet de tester)

!!! info "Tâches à réaliser"

    1. Pré-créer l'objet ordinateur `ws-Compta-01` dans `OU=Computers,OU=Comptabilite,OU=EU`
    2. Configurer les restrictions de connexion pour les postes de travail
    3. Définir les plages horaires autorisées
    4. Tester depuis `ws-IT-01` : la connexion doit être refusée, puis autorisée quand vous ajoutez `ws-IT-01` à la liste

??? success "Solution"

    **Pré-création du poste** : `dsa.msc` > `EU > Comptabilite` > clic droit sur l'OU `Computers` > **Nouveau > Ordinateur** > Nom de l'ordinateur `ws-Compta-01` > **OK**. Quand un vrai poste portant ce nom rejoindra le domaine, il réutilisera cet objet (et arrivera directement dans la bonne OU).

    **Restrictions** : propriétés de `chloe` > onglet **Compte** :

    - **Se connecter à…** > **Les ordinateurs suivants** > Nom de l'ordinateur `ws-Compta-01` > **Ajouter** > **OK**
    - **Horaires d'accès…** > sélectionnez à la souris les plages refusées (le week-end, avant 8h, après 18h) et cochez **Ouverture de session refusée** ; les plages autorisées restent en bleu > **OK**

    **Test** : sur `ws-IT-01`, connexion avec `chloe` → refusée (message indiquant que le compte ne peut pas utiliser cet ordinateur). Ajoutez `ws-IT-01` dans **Se connecter à…**, réessayez → OK. Même principe pour les horaires : réduisez la plage autorisée pour qu'elle exclue l'heure actuelle et réessayez.

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    New-ADComputer -Name ws-Compta-01 -Path "OU=Computers,OU=Comptabilite,OU=EU,DC=maxtec,DC=be"
    Set-ADUser chloe -LogonWorkstations "ws-Compta-01,ws-IT-01"
    ```

    Les horaires (`logonHours`) sont un tableau d'octets peu lisible : passez par l'interface graphique.

### Exercice 3: Audit de Sécurité `GPO`

!!! example "Objectif"

    Vous devez vérifier les paramètres de sécurité du compte de Chloé.

!!! info "Tâches à réaliser"

    1. Vérifier que le compte suit la politique de mot de passe
    2. Confirmer que le compte expire dans 6 mois (durée du contrat d'essai)
    3. Activer la journalisation des tentatives de connexion échouées

??? success "Solution"

    **Tâche 1 — Vérifier la politique de mot de passe**

    La politique s'applique automatiquement au niveau du domaine. Pour consulter la politique active :

    `Outils` → `Gestion des stratégies de groupe` → double-clic sur `Default Domain Policy` → onglet `Paramètres` → `Configuration ordinateur > Paramètres Windows > Paramètres de sécurité > Stratégies de compte`

    Pour vérifier si le compte a une politique spécifique (Fine-Grained) :

    `Centre d'administration Active Directory` → retrouvez `chloe` (`EU > Comptabilite > Users`) → clic droit → **Afficher les paramètres de mot de passe résultants…** (View resultant password settings). Si aucune PSO ne s'applique, la console l'indique : c'est la politique du domaine qui s'applique.

    En PowerShell (aperçu, vu au chapitre 9) : `Get-ADDefaultDomainPasswordPolicy`, et `Get-ADUserResultantPasswordPolicy chloe`, qui ne renvoie rien si seule la politique du domaine s'applique.

    ---

    **Tâche 2 — Expiration du compte dans 6 mois**

    `Utilisateurs et ordinateurs AD` → double-clic sur le compte → onglet **`Compte`**

    Dans la section **"Le compte expire"** : sélectionner `Fin de :` et saisir la date (aujourd'hui + 6 mois).

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    Set-ADAccountExpiration chloe -DateTime (Get-Date).AddMonths(6)
    ```

    ---

    **Tâche 3 — Journalisation des tentatives de connexion échouées**

    Cette configuration se fait par GPO, pas sur le compte. Une ouverture de session de domaine est **validée par le DC** : c'est donc sur les DC qu'on active l'audit, avec la **stratégie d'audit avancée** (la "Stratégie d'audit" classique sous `Stratégies locales` est l'ancienne méthode ; ne mélangez pas les deux).

    GPMC → `Domain Controllers` → clic droit sur `Default Domain Controllers Policy` → `Modifier` :

    ```
    Configuration ordinateur
      → Stratégies
        → Paramètres Windows
          → Paramètres de sécurité
            → Configuration avancée de la stratégie d'audit
              → Stratégies d'audit
                → Connexion de compte
                    → Auditer le service d'authentification Kerberos → Succès, Échec
                    → Auditer la validation des informations d'identification → Succès, Échec
                → Ouverture/Fermeture de session
                    → Auditer l'ouverture de session → Succès, Échec
                → Gestion des comptes
                    → Auditer la gestion des comptes d'utilisateur → Succès
                    → Auditer la gestion des groupes de sécurité → Succès
                → Accès DS
                    → Auditer les modifications du service d'annuaire → Succès
    ```

    Les deux dernières sous-catégories (Security Group Management, Directory Service Changes) ne servent pas à cette tâche, mais le chapitre 10 (monitoring) en a besoin : ajouts aux groupes (4728, 4732) et modifications d'objets AD (5136). Réglez-les maintenant. Dès qu'une GPO définit la stratégie d'audit avancée, elle **remplace** la configuration locale : un `auditpol /set` lancé à la main sur le DC sera écrasé au prochain rafraîchissement. Tout ce qu'on veut auditer sur les DC doit donc être dans cette GPO.

    Sur le DC : `gpupdate /force`, puis vérifiez avec `auditpol /get /category:*`.

    Événements utiles (`Observateur d'événements` → `Journaux Windows` → `Sécurité` du DC) :

    | ID | Signification |
    |----|---------------|
    | 4771 | Échec de pré-authentification Kerberos (mauvais mot de passe) |
    | 4776 | Validation d'identifiants NTLM (succès ou échec) |
    | 4625 | Échec d'ouverture de session — enregistré sur la **machine où l'on tente de se connecter** |
    | 4740 | Compte verrouillé (sert à l'exercice 10) |

### Exercice 4: Désactivation d'un Compte

!!! warning "Situation"

    Charles (`charles@maxtec.be`), comptable au département Comptabilite, quitte l'entreprise aujourd'hui.

!!! info "Tâches à réaliser"

    1. Désactiver son compte utilisateur
    2. Documenter la désactivation dans le champ "Description" des propriétés du compte avec :
        - Date de désactivation
        - Raison : "Départ de l'entreprise"
        - Date de suppression prévue (dans 90 jours)

        !!! note "Note"

            Le champ "Description" se trouve dans l'onglet "Général" des propriétés du compte

    3. Vérifier qu'il ne peut plus se connecter

??? success "Solution"

    1. `dsa.msc` > clic droit sur `Charles` (le nom de l'objet ; « Charles Cornet » n'est que le nom complet affiché, `DisplayName`) > **Désactiver le compte** (l'icône affiche une flèche vers le bas)
    2. Propriétés > **Général** > Description : `Désactivé le 2026-10-05 - Départ de l'entreprise - suppression prévue le 2027-01-03`
    3. Sur `ws-IT-01`, connexion avec `charles` → message "Votre compte a été désactivé"

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    Disable-ADAccount charles
    $auj = Get-Date
    Set-ADUser charles -Description ("Désactivé le {0:yyyy-MM-dd} - Départ de l'entreprise - suppression prévue le {1:yyyy-MM-dd}" -f $auj, $auj.AddDays(90))
    ```

    On désactive d'abord, on supprime plus tard : un compte supprimé perd son SID, et les permissions qui y étaient liées ne reviennent pas si on recrée un compte du même nom.

### Exercice 5: Nettoyage des Accès

!!! example "Contexte"

    Suite au départ de Charles :

!!! info "Tâches à réaliser"

    1. Identifier tous les groupes dont il est membre
    2. Le retirer de tous les groupes sauf "Utilisateurs du domaine"
    3. **Retour arrière** : Charles sert dans les exercices GPO-3 et AGDLP. Une fois l'exercice vérifié, réactivez son compte, videz la description et remettez-le dans `GG-EU-Compta-Users`

??? success "Solution"

    1. `dsa.msc` > propriétés de `Charles` > onglet **Membre de** : liste des groupes. En invite de commandes, `net user charles /domain` donne la même liste (ligne « Groupes globaux »).
    2. Sélectionnez chaque groupe sauf `Utilisateurs du domaine` > **Supprimer** > **Oui** > **OK**. `Utilisateurs du domaine` est son **groupe principal** : Windows refuse de le retirer tant qu'il l'est.

    **Retour arrière** (GUI) : clic droit sur `Charles` > **Activer le compte** ; Propriétés > **Général** > videz **Description** ; onglet **Membre de** > **Ajouter…** > `GG-EU-Compta-Users` > **OK**.

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    Get-ADPrincipalGroupMembership charles | Select-Object Name
    ```

    ```powershell
    # Le SID de "Utilisateurs du domaine" se termine toujours par -513, quelle que soit la langue
    Get-ADPrincipalGroupMembership charles | Where-Object { $_.SID.Value -notlike "*-513" } |
        ForEach-Object { Remove-ADGroupMember -Identity $_ -Members charles -Confirm:$false }
    ```

    Sur un serveur en anglais, le groupe s'appelle `Domain Users`. Retour arrière en PowerShell :

    ```powershell
    Enable-ADAccount charles
    Set-ADUser charles -Clear description
    Add-ADGroupMember GG-EU-Compta-Users -Members charles
    ```

### Exercice 6: Gestion des Homonymes

!!! example "Situation"

    Deux nouveaux employés arrivent dans le service RH :

    - Karim Benali (Recruteur Senior)
    - Karim Benali (Assistant RH)

!!! info "Tâches à réaliser"

    1. Créer les comptes pour les deux Karim Benali dans `OU=Users,OU=RH,OU=EU,DC=maxtec,DC=be` en évitant les conflits
    2. Documenter clairement dans chaque compte le poste occupé
    3. S'assurer que leurs adresses email restent professionnelles et cohérentes

??? success "Solution"

    Trois contraintes d'unicité s'appliquent :

    | Attribut | Doit être unique dans… |
    |----------|------------------------|
    | Nom (CN) | l'OU |
    | `SamAccountName` (login) | le domaine |
    | `UserPrincipalName` | la forêt |

    La convention du lab (login = prénom) casse dès le premier homonyme : `karim` ne peut servir qu'une fois. En production, on adopte une règle documentée, par exemple `prenom.nom`, puis un suffixe numérique en cas de doublon.

    | | Karim 1 | Karim 2 |
    |-|---------|---------|
    | Nom (CN) | `Karim Benali (Recrutement)` | `Karim Benali (Assistant RH)` |
    | Login | `karim.benali` | `karim.benali2` |
    | UPN / e-mail | `karim.benali@maxtec.be` | `karim.benali2@maxtec.be` |
    | Fonction (`Title`) | Recruteur Senior | Assistant RH |
    | Description | Recruteur Senior - RH | Assistant RH - RH |

    Le nom affiché distinct évite qu'un collègue choisisse le mauvais Karim dans un carnet d'adresses.

    Dans `dsa.msc` > `EU > RH` > clic droit sur `Users` > **Nouveau > Utilisateur** :

    1. Prénom `Karim`, Nom `Benali`, **Nom complet** : remplacez la valeur proposée par `Karim Benali (Recrutement)` ; nom d'ouverture de session `karim.benali` > **Suivant**, mot de passe temporaire + changement à la prochaine ouverture de session > **Terminer**
    2. Propriétés du compte > onglet **Général** : **Nom complet** (affiché) `Karim Benali (Recrutement)`, Description, **Adresse de messagerie** `karim.benali@maxtec.be` ; onglet **Organisation** : **Fonction** `Recruteur Senior`, **Service** `RH`
    3. Recommencez pour le second avec `Karim Benali (Assistant RH)` et `karim.benali2`. Si vous tapez un nom complet déjà pris dans l'OU, ou un login déjà utilisé, l'assistant refuse la création : c'est la contrainte d'unicité du tableau ci-dessus.

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    New-ADUser -Name "Karim Benali (Recrutement)" -GivenName Karim -Surname Benali -DisplayName "Karim Benali (Recrutement)" `
        -SamAccountName karim.benali -UserPrincipalName karim.benali@maxtec.be -EmailAddress karim.benali@maxtec.be `
        -Title "Recruteur Senior" -Department RH -Description "Recruteur Senior - RH" -Path "OU=Users,OU=RH,OU=EU,DC=maxtec,DC=be" `
        -AccountPassword (Read-Host -AsSecureString) -ChangePasswordAtLogon $true -Enabled $true
    ```

### Exercice 7: Compte Temporaire

!!! example "Contexte"

    Un consultant externe, Marek Wojcik, arrive pour un audit informatique de 3 mois. Il travaillera depuis le poste de l'équipe IT.

!!! info "Tâches à réaliser"

    1. Créer un compte temporaire avec :
        - Date d'expiration automatique dans 90 jours
        - Accès limité à `ws-IT-01.maxtec.be` uniquement
        - Heures de connexion : 9h-17h, jours ouvrés

    2. Ajouter un préfixe "EXT-" dans la description

??? success "Solution"

    1. Créez `marek` dans `EU > IT > Users` (mot de passe temporaire, changement à la première connexion)
    2. Onglet **Compte** : **Le compte expire** > **Fin de** : aujourd'hui + 90 jours ; **Se connecter à…** > `ws-IT-01` ; **Horaires d'accès…** > autorisé lun-ven 9h-17h, refusé le reste
    3. Onglet **Général** : Description `EXT- Consultant audit IT - fin de mission JJ/MM/AAAA`

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    New-ADUser -Name "Marek Wojcik" -GivenName Marek -Surname Wojcik -SamAccountName marek -UserPrincipalName marek@maxtec.be `
        -Path "OU=Users,OU=IT,OU=EU,DC=maxtec,DC=be" -Description "EXT- Consultant audit IT" -AccountExpirationDate (Get-Date).AddDays(90) `
        -AccountPassword (Read-Host -AsSecureString) -ChangePasswordAtLogon $true -Enabled $true
    Set-ADUser marek -LogonWorkstations "ws-IT-01"
    ```

    Ne l'ajoutez pas à `GG-EU-IT-Users` par réflexe : un consultant d'audit a besoin d'accès en lecture ciblés, pas des accès de l'équipe.

### Exercice 8: Vérification des Comptes Inactifs

!!! example "Rôle"

    En tant qu'administrateur, vous devez faire le ménage dans les comptes.

!!! info "Tâches à réaliser"

    Le lab vient d'être créé : aucun compte n'a 30 jours d'inactivité. On cherche donc les comptes **jamais utilisés** (`LastLogonDate` vide), qui sont en production les premiers suspects (compte créé pour quelqu'un qui n'est jamais arrivé, doublon, compte de test oublié).

    1. Lister les comptes utilisateurs activés qui ne se sont jamais connectés, avec leur date de création
    2. Pour chaque compte :
        - Vérifier s'il s'agit d'un départ non signalé ou d'un compte inutile
        - Documenter le statut dans la description
    3. Exporter la liste en CSV pour la direction
    4. Écrire la commande que vous utiliseriez en production pour les comptes inactifs depuis 90 jours

!!! note "Pourquoi `LastLogonDate` n'est pas précis"
    `LastLogonDate` est calculé à partir de l'attribut `lastLogonTimestamp`, qui est **répliqué** entre DC mais n'est mis à jour que si l'ancienne valeur a plus de 9 à 14 jours environ (pour limiter la réplication). Il sert à repérer des comptes inactifs depuis des semaines, pas à savoir qui s'est connecté hier. L'attribut `lastLogon` est exact mais **propre à chaque DC** et non répliqué.

??? success "Solution"

    **Avec `dsa.msc` : une requête enregistrée**

    1. Clic droit sur **Requêtes enregistrées** (en haut de l'arborescence) > **Nouveau > Requête**
    2. Nom : `Comptes jamais connectés` ; **Racine de la requête** : laissez `maxtec.be` (ou **Parcourir…** > `EU`) ; cochez **Inclure les sous-conteneurs**
    3. **Définir la requête…** > liste **Rechercher** : **Recherche personnalisée** > onglet **Avancé** > collez la requête LDAP :

        ```
        (&(objectCategory=person)(objectClass=user)(!(lastLogonTimestamp=*))(!(userAccountControl:1.2.840.113556.1.4.803:=2)))
        ```

        Elle se lit : utilisateurs, sans attribut `lastLogonTimestamp` (jamais connectés), et pas désactivés.

    4. **OK** > **OK** : la liste apparaît. **Affichage > Ajouter/Supprimer des colonnes…** pour ajouter **Service**. La date de création se lit dans les propriétés du compte > onglet **Objet** (affichage avancé activé) > **Créé le**.
    5. Documentez chaque compte : Propriétés > **Général** > Description, par exemple `Jamais connecté - vérifié le 2026-10-05 avec la responsable Ventes`
    6. Export : clic droit sur la requête > **Exporter la liste…** > type **Texte (délimité par des virgules) (*.csv)** > `C:\Scripts\comptes_jamais_connectes.csv`
    7. En production, pour les comptes inactifs depuis 90 jours : nouvelle requête > **Définir la requête…** > **Requêtes communes** > **Nombre de jours depuis la dernière ouverture de session** : `90`. Cette requête s'appuie aussi sur `lastLogonTimestamp` (voir l'encadré ci-dessus).

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    # 1. Comptes activés jamais connectés
    $jamais = Get-ADUser -Filter "Enabled -eq 'True'" -Properties LastLogonDate, whenCreated, Department |
        Where-Object { -not $_.LastLogonDate } |
        Select-Object SamAccountName, Name, Department, whenCreated
    $jamais | Format-Table

    # 2. Documenter (exemple pour un compte)
    Set-ADUser valeria -Description "Jamais connecté - vérifié le $(Get-Date -Format yyyy-MM-dd) avec la responsable Ventes"

    # 3. Export
    $jamais | Export-Csv C:\Scripts\comptes_jamais_connectes.csv -NoTypeInformation -Encoding UTF8

    # 4. En production : inactifs depuis 90 jours
    Search-ADAccount -AccountInactive -TimeSpan 90.00:00:00 -UsersOnly | Select-Object SamAccountName, LastLogonDate
    ```

    Pensez à exclure `krbtgt` et `Invité` (désactivés, donc déjà filtrés ici) et les comptes de service de la liste envoyée à la direction.

### Exercice 9: Mise à Jour des Informations

!!! example "Contexte"

    Suite à un déménagement interne, le département Comptabilite change d'étage. Charlotte, Cindy et Chloé doivent avoir leurs informations mises à jour.

!!! info "Tâches à réaliser"

    1. Mettre à jour les informations de bureau **pour Charlotte, Cindy et Chloé** :
        - Nouveau bureau : "Bâtiment B - 3e étage"
        - Nouveau téléphone : format "+32 2 123 XX YY"

    2. Vérifier que les chemins réseau utilisés par le département sont toujours accessibles depuis `ws-IT-01` : `\\dns1\IT-docs` (chapitre 7 §5) et, si vous avez fait GPO-3, `\\dns1\Compta-Docs`
    3. Documenter les changements effectués

??? success "Solution"

    1. **Avant** de modifier : dans `EU > Comptabilite > Users`, **Affichage > Ajouter/Supprimer des colonnes…** > ajoutez **Bureau** et **Numéro de téléphone** > **OK**, puis clic droit sur l'OU > **Exporter la liste…** > `C:\Scripts\compta_avant.csv` (format délimité par des virgules)
    2. `dsa.msc` : sélectionnez les trois comptes (Ctrl+clic) > **Propriétés** : la fenêtre multi-sélection permet de modifier **Bureau** en une fois (onglet **Général**, cochez la case devant **Bureau**). Le téléphone est propre à chacun : modifiez-le compte par compte (Propriétés > **Général** > **Numéro de téléphone**).
    3. Sur `ws-IT-01`, en administrateur : **Win+R** > `\\dns1\IT-docs` → le dossier s'ouvre (ou, en invite de commandes, `dir \\dns1\IT-docs`). Un déménagement physique ne change pas les chemins UNC : c'est l'intérêt de pointer vers un nom de serveur, et pas vers un poste ou une lettre de lecteur locale.
    4. **Après** : refaites l'export (`compta_apres.csv`). Les deux fichiers documentent le changement.

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    $comptes = "charlotte", "cindy", "chloe"
    Get-ADUser -Filter * -Properties Office, OfficePhone | Where-Object SamAccountName -in $comptes |
        Select-Object SamAccountName, Office, OfficePhone | Export-Csv C:\Scripts\compta_avant.csv -NoTypeInformation -Encoding UTF8
    $comptes | ForEach-Object { Set-ADUser $_ -Office "Bâtiment B - 3e étage" }
    Set-ADUser charlotte -OfficePhone "+32 2 123 30 01"
    Set-ADUser cindy     -OfficePhone "+32 2 123 30 02"
    Set-ADUser chloe     -OfficePhone "+32 2 123 30 03"
    ```

### Exercice 10: Résolution des Problèmes de Connexion

!!! warning "Problème signalé"

    L'utilisatrice Ines (`ines@maxtec.be`, département IT) signale qu'elle ne peut plus se connecter.

Dans un lab neuf, rien n'empêche Ines de se connecter : vous allez d'abord **reproduire la panne**, puis la diagnostiquer comme si vous ne la connaissiez pas. Si vous travaillez en binôme, l'un prépare la panne, l'autre diagnostique.

!!! info "Préparation (formateur ou binôme)"

    1. Sur le DC, ouvrez **Gestion des stratégies de groupe** (`gpmc.msc`) > `Forêt : maxtec.be > Domaines > maxtec.be` > clic droit sur **Default Domain Policy** > **Modifier…**
    2. Allez dans `Configuration ordinateur > Stratégies > Paramètres Windows > Paramètres de sécurité > Stratégies de comptes > Stratégie de verrouillage du compte`. **Notez les valeurs actuelles** (par défaut : seuil `0`, les deux durées « Non défini »).
    3. Activez un seuil de verrouillage (lab uniquement) :

        - **Seuil de verrouillage du compte** : `5` tentatives > **OK**. Windows propose de régler les deux autres valeurs à 30 minutes : acceptez.
        - Vérifiez : **Durée de verrouillage des comptes** = `30 minutes`, **Réinitialiser le compteur de verrouillages du compte après** = `30 minutes`

    4. Sur le DC, invite de commandes : `gpupdate /force`
    5. Sur `ws-IT-01`, tentez 5 connexions avec `ines` et un mauvais mot de passe. À la sixième tentative, même avec le bon mot de passe, le compte est refusé.

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    Get-ADDefaultDomainPasswordPolicy
    Set-ADDefaultDomainPasswordPolicy -Identity maxtec.be -LockoutThreshold 5 `
        -LockoutDuration 00:30:00 -LockoutObservationWindow 00:30:00
    ```

    La commande écrit directement sur l'objet domaine. La `Default Domain Policy` reste la référence : comme elle définit un seuil (`0` par défaut), elle réécrit votre valeur au prochain rafraîchissement. C'est pour cela qu'on règle le seuil dans la GPO.

!!! info "Tâches à réaliser (diagnostic)"

    1. Vérifier l'état du compte (verrouillé, désactivé, expiré, mot de passe expiré ?)
    2. Examiner les autres causes possibles :
        - Postes de travail autorisés (`Se connecter à…`)
        - Plages horaires
        - Stratégie de mot de passe (seuil de verrouillage)
    3. Retrouver **depuis quel poste** le compte a été verrouillé
    4. Débloquer le compte et documenter chaque étape

??? success "Solution"

    1. **État du compte** : `dsa.msc` > `EU > IT > Users` > propriétés d'`Ines` > onglet **Compte**. Si le compte est verrouillé, la case **Déverrouiller le compte** est accompagnée du texte « Ce compte est actuellement verrouillé sur ce contrôleur de domaine Active Directory ». Sur le même onglet, vérifiez **Le compte est désactivé**, **Le compte expire**, **Horaires d'accès…** et **Se connecter à…**.
    2. **En ligne de commande** (cmd) : `net user ines /domain` résume l'état : compte actif ou verrouillé, date d'expiration, dernier changement de mot de passe, heures d'accès autorisées, stations de travail autorisées.
    3. **Stratégie** : GPMC > `Default Domain Policy` > onglet **Paramètres** > `Stratégies de compte / Stratégie de verrouillage du compte` : seuil de 5.
    4. **Origine du verrouillage** : sur le DC, **Observateur d'événements** > `Journaux Windows > Sécurité` > **Filtrer le journal actuel…** > ID `4740`. Le champ **Nom de l'ordinateur appelant** donne le poste à l'origine des tentatives.
    5. **Déverrouiller** : propriétés d'Ines > onglet **Compte** > cochez **Déverrouiller le compte** > **OK**. Ines peut à nouveau se connecter avec son mot de passe.

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    # Qui est verrouillé ?
    Search-ADAccount -LockedOut | Select-Object SamAccountName, LastLogonDate

    # État détaillé d'Ines
    Get-ADUser ines -Properties Enabled, LockedOut, lockoutTime, badPwdCount, AccountExpirationDate,
        PasswordExpired, LogonWorkstations, logonHours |
        Select-Object SamAccountName, Enabled, LockedOut, badPwdCount, AccountExpirationDate, PasswordExpired, LogonWorkstations

    # D'où vient le verrouillage ? (événement 4740 sur le DC, champ "Nom de l'ordinateur appelant")
    Get-WinEvent -FilterHashtable @{ LogName = 'Security'; Id = 4740 } -MaxEvents 5 |
        Format-List TimeCreated, Message

    # Déverrouiller
    Unlock-ADAccount ines
    ```

    En production, un verrouillage qui revient sans cesse vient souvent d'un ancien mot de passe enregistré quelque part (lecteur réseau mappé, téléphone, tâche planifiée) : le poste indiqué dans l'événement 4740 est le point de départ.

    Fin d'exercice : dans la `Default Domain Policy`, remettez les valeurs notées au départ (**Seuil de verrouillage du compte** = `0`), puis `gpupdate /force` sur le DC. Ou gardez le seuil pour l'exercice 12.

### Exercice 11 (optionnel, avancé): Gestion des Profils Itinérants `GPO`

!!! warning "Exercice avancé"
    Il faut **deux postes clients** pour vérifier qu'un profil suit l'utilisateur (ou supprimer le profil local entre deux connexions sur le même poste). Les profils itinérants sont par ailleurs une technologie ancienne : en entreprise, on leur préfère souvent la redirection de dossiers ([GPO-3, exercice 1.1](./Exercices:%20GPO-3.md)).

!!! example "Objectif"

    Configurer des profils itinérants pour l'équipe Ventes qui se déplace entre plusieurs postes.

!!! info "Tâches à réaliser"

    1. Créer le dossier `C:\Shares\Profiles` sur le serveur et le partager sous le nom masqué `Profiles$` (`\\dns1\Profiles$` ; le `$` masque le partage dans la navigation réseau)
    2. Poser les permissions (voir ci-dessous)
    3. Configurer le profil itinérant pour trois commerciaux : Vanessa, Victor, Valeria
    4. Vérifier que leurs paramètres personnels sont conservés entre les postes
    5. Configurer une limite de taille pour les profils (500 MB) via GPO :

        ```
        Configuration utilisateur
          → Stratégies
            → Modèles d'administration
              → Système
                → Profils utilisateur
                  → Limiter la taille du profil → Activé → 512000 Ko
        ```

!!! info "Permissions du dossier des profils (même principe que la redirection de dossiers)"

    - **Partage** : `GG-EU-Ventes-Users` Contrôle total, `Administrateurs` Contrôle total (retirez `Tout le monde`)
    - **NTFS** (héritage désactivé) :
        - `SYSTEM` : Contrôle total — ce dossier, sous-dossiers et fichiers
        - `Administrateurs` : Contrôle total — ce dossier seulement
        - `CREATEUR PROPRIETAIRE` : Contrôle total — sous-dossiers et fichiers seulement
        - `GG-EU-Ventes-Users` : `Parcours du dossier / exécuter le fichier`, `Liste du dossier / lecture de données`, `Lecture des attributs`, `Lecture des attributs étendus`, `Création de dossiers / ajout de données`, `Autorisations de lecture` — ce dossier seulement

    Chaque commercial peut créer son dossier de profil, mais pas ouvrir celui des autres.

??? success "Solution"

    1. **Dossier et partage** : sur le DC, Explorateur > créez `C:\Shares\Profiles` > Propriétés > onglet **Partage** > **Partage avancé…** > cochez **Partager ce dossier**, nom `Profiles$` > **Autorisations** (voir l'encadré). Puis onglet **Sécurité** > **Avancé** > **Désactiver l'héritage** > **Convertir…**, et ajustez les entrées NTFS de l'encadré (colonne **S'applique à**).
    2. Pour chacun des trois comptes : propriétés > onglet **Profil** > Chemin du profil : `\\dns1\Profiles$\%username%`. Windows crée un dossier `vanessa.V6` (le suffixe dépend de la version du profil).
    3. Test : `vanessa` se connecte sur `ws-IT-01`, change son fond d'écran, se **déconnecte** (le profil est copié sur le serveur à la déconnexion). Elle se connecte sur `ws-RH-01` : le fond d'écran suit.
    4. GPO : créez `GPO-Profils-Ventes` liée à `EU\Ventes\Users` avec le paramètre ci-dessus.

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    # En PowerShell, on écrit le login en clair : c'est l'onglet Profil de la GUI qui remplace %username%
    "vanessa", "victor", "valeria" | ForEach-Object { Set-ADUser $_ -ProfilePath "\\dns1\Profiles`$\$_" }
    Get-ADUser vanessa -Properties ProfilePath | Select-Object ProfilePath
    ```

### Exercice 12: Délégation d'Administration

**Niveau** : Intermédiaire · **Durée** : 30-45 min

!!! example "Objectif"

    Permettre aux responsables de département (Richard pour RH, Valentin pour Ventes) de gérer leur propre équipe **sans être Domain Admin**, en appliquant le principe du moindre privilège.

#### Prérequis

- Lab Maxtec déployé (structure du `creation_structure.ps1` en place)
- Groupes `GG-EU-RH-Admin` (contient Richard) et `GG-EU-Ventes-Admin` (contient Valentin) existants
- `ws-IT-01` joint au domaine (et `ws-RH-01` si vous l'avez)
- Session ouverte sur le DC ou sur un poste avec RSAT, en tant que `maxtec\Administrateur`

---

#### Installation préalable : RSAT sur le poste client

La délégation se **configure** depuis n'importe quelle machine qui a `dsa.msc` (le DC l'a nativement). On l'**utilise** depuis le poste de la personne déléguée, qui doit donc disposer de RSAT.

!!! info "Pourquoi RSAT ?"

    `dsa.msc` et `gpmc.msc` sont installés d'office sur le DC. Mais un responsable de service n'a rien à faire sur le DC : il n'a d'ailleurs pas le droit d'y ouvrir une session. RSAT (Remote Server Administration Tools) installe les mêmes consoles sur un poste client Windows ; elles parlent au DC par le réseau (LDAP). C'est aussi la bonne pratique pour les administrateurs : on administre depuis un poste, sans ouvrir de session sur le DC. Une fois RSAT installé, **les permissions viennent du compte qui ouvre la console**, pas de l'installation elle-même.

!!! warning "Le poste du lab n'a pas d'accès Internet"
    Vérifiez d'abord si RSAT est déjà là : le formateur peut l'avoir préinstallé dans l'image du poste. **Paramètres > Applications > Fonctionnalités facultatives** : si **RSAT : Outils Active Directory Domain Services et Services LDS** figure dans la liste des fonctionnalités installées, passez directement à la vérification. En PowerShell (aperçu) : `Get-WindowsCapability -Online -Name Rsat.ActiveDirectory*` doit afficher `State = Installed`. Sinon :

    1. **Éteignez** `ws-IT-01`, puis dans VirtualBox ajoutez une **deuxième carte réseau en NAT** (Configuration > Réseau > Carte 2)
    2. Démarrez le poste, installez RSAT (procédure ci-dessous)
    3. **Éteignez** à nouveau le poste et **retirez la carte NAT**, puis redémarrez
    4. Dans une invite de commandes : `ipconfig /flushdns`, puis `nltest /dsgetdc:maxtec.be` doit renvoyer `dns1`

    Ne laissez pas la carte NAT active : elle apporte un second serveur DNS (celui de VirtualBox) qui ne connaît pas `maxtec.be`, et le poste ne trouve plus le domaine (ouvertures de session lentes, GPO non appliquées, `nltest` en échec).

**Procédure (à exécuter sur le poste client, ex : `ws-IT-01`)** :

1. **Connectez-vous avec un compte administrateur du poste** (le compte local créé à l'installation de Windows, ou un administrateur du domaine). L'installation d'un composant Windows demande des droits d'administration sur le poste. Les composants RSAT sont téléchargés depuis Windows Update : il faut un accès Internet **temporaire** (voir l'encadré ci-dessous).
2. **Ouvrir le menu Fonctionnalités facultatives** : touche Windows → taper **`facultative`** → cliquer sur **Fonctionnalités facultatives**.
3. **Ajouter une fonctionnalité** :
    - Cliquer sur **Ajouter une fonctionnalité** (ou **Afficher les fonctionnalités**)
    - Dans la barre de recherche, taper **RSAT**
    - Cocher **RSAT : Outils Active Directory Domain Services et Services LDS** (inclut `dsa.msc` et le module PowerShell)
    - Cocher aussi **RSAT : Outils de gestion des stratégies de groupe** (inclut `gpmc.msc`) — utile pour [GPO-2, exercice 7](./Exercices:%20GPO-2.md)
    - Cliquer sur **Suivant** puis **Installer**
4. **Redémarrer** le poste si Windows le demande.

**En PowerShell** (aperçu, vu au chapitre 9 ; console en administrateur) :

```powershell
Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
Add-WindowsCapability -Online -Name Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0
```

**Vérification — RSAT fonctionne** :

Tapez `dsa.msc` dans Démarrer (session utilisateur du domaine, sans privilèges admin). La console "Utilisateurs et ordinateurs Active Directory" doit s'ouvrir et afficher le domaine `maxtec.be` avec ses OUs ; dans `EU > RH > Users`, vous devriez voir Richard, Rebecca et Rene. Si :

- `dsa.msc` est introuvable → RSAT AD n'est pas installé, reprenez l'étape 3
- la console affiche une erreur du type *« Le domaine n'existe pas ou n'a pas pu être contacté »* → le poste n'est pas joint au domaine `maxtec.be` ou son DNS ne pointe pas vers `192.168.0.2` (vérifiez avec `ipconfig /all` et `nltest /dsgetdc:maxtec.be`)

**En PowerShell** (aperçu, vu au chapitre 9) :

```powershell
Get-ADUser -Filter * -SearchBase "OU=RH,OU=EU,DC=maxtec,DC=be" |
    Select-Object Name, SamAccountName
```

*"Get-ADUser n'est pas reconnu"* signifie que le module RSAT AD n'est pas installé ; *"Impossible de contacter un serveur Active Directory"* renvoie au problème de domaine/DNS ci-dessus.

---

#### Contexte / Scénario

Le manager IT de Maxtec, débordé par les demandes de support, vous résume la nouvelle politique :

> *"On reçoit 40 reset password par mois et 8 créations de comptes. Les chefs de service peuvent gérer ça eux-mêmes. À chacun son périmètre, et personne ne touche aux autres départements. Voici ce que je veux :"*

**Politique de délégation** :

| Délégué | Groupe AD | Périmètre | Permissions accordées | Permissions refusées |
|---------|-----------|-----------|----------------------|----------------------|
| **Richard** | `GG-EU-RH-Admin` | `OU=Users,OU=RH,OU=EU,DC=maxtec,DC=be` | Reset password<br>Déverrouillage compte | Création/suppression<br>Accès autres dépts |
| **Valentin** | `GG-EU-Ventes-Admin` | `OU=Users,OU=Ventes,OU=EU,DC=maxtec,DC=be` | Création utilisateurs<br>Modification propriétés<br>Reset password | Suppression utilisateurs<br>Accès autres dépts |

!!! tip "Bonne pratique : déléguer au groupe, pas à l'utilisateur"

    On délègue toujours à `GG-EU-RH-Admin`, **pas directement à Richard**. Si demain Richard est remplacé, il suffit d'ajouter le remplaçant au groupe sans toucher à la délégation. C'est la même logique que pour l'attribution de permissions NTFS via AGDLP.

---

#### Étape 1 : Déléguer à Richard (RH — périmètre restreint)

**Sur le DC**, en tant que `maxtec\Administrateur` :

1. Ouvrir **`dsa.msc`** (Utilisateurs et ordinateurs Active Directory)
2. Activer l'affichage avancé : menu **Affichage** → **Fonctionnalités avancées** (nécessaire pour voir l'onglet Sécurité plus tard)
3. Naviguer jusqu'à `EU > RH`
4. **Clic droit sur l'OU `Users`** (à l'intérieur de RH) → **Délégation de contrôle…**
5. L'assistant s'ouvre → **Suivant**
6. **Utilisateurs ou groupes** :
    - **Ajouter…** → taper `GG-EU-RH-Admin` → **Vérifier les noms** → **OK**
    - **Suivant**
7. **Tâches à déléguer** → cocher :
    - **Réinitialiser les mots de passe utilisateur et forcer le changement de mot de passe à la prochaine ouverture de session**
    - **Lire toutes les informations utilisateur**
    - NE PAS cocher *Créer, supprimer et gérer les comptes d'utilisateurs*
    - **Suivant**
8. **Terminer**

!!! info "Et le déverrouillage de compte ?"

    La tâche « Réinitialiser les mots de passe… » donne le droit de réinitialiser le mot de passe et d'écrire `pwdLastSet`, mais **pas** de modifier `lockoutTime`, l'attribut qui porte le verrouillage. Richard ne pourrait donc pas cocher « Déverrouiller le compte ». Ajoutez une seconde délégation :

    1. Clic droit sur `EU > RH > Users` → **Délégation de contrôle…** → `GG-EU-RH-Admin`
    2. **Créer une tâche personnalisée à déléguer** → **Seulement des objets suivants dans le dossier** → cochez **Objets Utilisateur** → **Suivant**
    3. Cochez **Spécifiques aux propriétés**, puis dans la liste **Lire lockoutTime** et **Écrire lockoutTime** → **Suivant** → **Terminer**

---

#### Étape 2 : Déléguer à Valentin (Ventes — périmètre étendu)

1. Toujours dans `dsa.msc`, naviguer jusqu'à `EU > Ventes`
2. **Clic droit sur l'OU `Users`** (à l'intérieur de Ventes) → **Délégation de contrôle…**
3. Assistant → **Suivant**
4. **Ajouter** `GG-EU-Ventes-Admin` → **Vérifier les noms** → **OK** → **Suivant**
5. **Tâches à déléguer** → cocher :
    - **Créer, supprimer et gérer les comptes d'utilisateurs** (l'assistant regroupe création **et** suppression — voir la note ci-dessous)
    - **Réinitialiser les mots de passe utilisateur et forcer le changement de mot de passe à la prochaine ouverture de session**
    - **Lire toutes les informations utilisateur**
    - **Suivant** → **Terminer**

!!! warning "Limitation de l'assistant standard"

    L'assistant regroupe **"Créer, supprimer et gérer"** dans une seule case. Pour **autoriser la création MAIS interdire la suppression**, il faut passer par **Créer une tâche personnalisée à déléguer**, puis cocher uniquement **Créer les objets sélectionnés dans ce dossier** (Objets Utilisateur) et les propriétés voulues. Pour cet exercice, on accepte la limitation et on documente le compromis. Retenez que l'assistant n'est qu'un raccourci : pour une délégation fine, on passe par la tâche personnalisée, `dsacls` ou PowerShell (`Set-Acl`).

!!! note "Et l'appartenance aux groupes ?"
    La tâche « Modifier l'appartenance d'un groupe » s'applique aux **groupes** situés dans l'OU déléguée. Les groupes de Ventes sont dans `OU=Groups,OU=Ventes`, pas dans `OU=Users` : si vous voulez que Valentin gère les membres de `GG-EU-Ventes-Users`, déléguez cette tâche sur `OU=Groups,OU=Ventes`. Réfléchissez avant : il pourrait aussi modifier `GG-EU-Ventes-Admin`.

---

#### Étape 3 : Tester les délégations

Les tests se font **depuis `ws-IT-01`** (ou `ws-RH-01`) avec RSAT : Richard et Valentin n'ont pas le droit d'ouvrir une session sur le DC.

**Test A — Richard (devrait réussir)** :

1. Sur `ws-IT-01`, se connecter en tant que `maxtec\richard`
2. Ouvrir `dsa.msc`
3. Naviguer jusqu'à `EU > RH > Users`
4. Clic droit sur **Rene** → **Réinitialiser le mot de passe** → définir un nouveau mot de passe → **OK**
5. Doit fonctionner
6. Si vous avez activé le seuil de verrouillage de l'exercice 10 : verrouillez `rebecca` (mauvais mots de passe), puis Richard la déverrouille (onglet **Compte** > **Déverrouiller le compte**)

**Test B — Richard (devrait échouer)** :

1. Toujours connecté en tant que Richard, naviguer jusqu'à `EU > Comptabilite > Users`
2. Clic droit sur **Charlotte** → **Réinitialiser le mot de passe**
3. Doit échouer avec *"Accès refusé"*

**Test C — Richard (limite explicite)** :

1. Clic droit sur `OU=Users` (dans RH) → **Nouveau** → **Utilisateur**
2. L'option doit être absente ou la création doit échouer — Richard n'a pas la délégation de création

**Test D — Valentin (création autorisée)** :

Sur `ws-IT-01`, session `valentin`, ou depuis une session existante sur le poste :

```cmd
runas /user:maxtec\valentin "mmc dsa.msc"
```

(Si l'ouverture de session locale de Valentin est bloquée sur le poste : `runas /netonly /user:maxtec\valentin "mmc dsa.msc"`.)

1. Naviguer jusqu'à `EU > Ventes > Users`
2. Clic droit → **Nouveau** → **Utilisateur** → créer `vincent.test` avec mot de passe temporaire
3. Doit fonctionner

**Test E — Valentin (frontière respectée)** :

1. Valentin tente de créer un utilisateur dans `EU > IT > Users`
2. Doit échouer

---

#### Vérification (audit de la délégation)

Pour confirmer que les ACLs ont bien été posées sur les OUs, sur le DC en tant qu'administrateur du domaine :

1. `dsa.msc` > **Affichage > Fonctionnalités avancées** (si ce n'est pas déjà fait)
2. Clic droit sur `EU > RH > Users` > **Propriétés** > onglet **Sécurité** > **Avancé**
3. Dans **Entrées d'autorisations**, repérez les lignes `GG-EU-RH-Admin` : **Réinitialiser le mot de passe** (type Autoriser, s'applique aux **Objets Utilisateur descendants**), lecture/écriture de `pwdLastSet` et `lockoutTime`. Double-cliquez sur une ligne pour voir le détail.
4. Même chose sur `EU > Ventes > Users` pour `GG-EU-Ventes-Admin` : vous y trouvez en plus **Créer des objets Utilisateur** / **Supprimer des objets Utilisateur** et **Contrôle total** sur les objets Utilisateur descendants.

En ligne de commande (cmd), `dsacls "OU=Users,OU=RH,OU=EU,DC=maxtec,DC=be"` affiche la même liste en texte.

**En PowerShell** (aperçu, vu au chapitre 9) :

```powershell
# Importer le module AD (chargé automatiquement dans les versions récentes)
Import-Module ActiveDirectory

# Audit de l'OU Users de RH
$ouRH = "AD:\OU=Users,OU=RH,OU=EU,DC=maxtec,DC=be"
Get-Acl $ouRH | Select-Object -ExpandProperty Access |
    Where-Object { $_.IdentityReference -like "*GG-EU-RH-Admin*" } |
    Format-Table IdentityReference, ActiveDirectoryRights, AccessControlType -AutoSize

# Audit de l'OU Users de Ventes
$ouVentes = "AD:\OU=Users,OU=Ventes,OU=EU,DC=maxtec,DC=be"
Get-Acl $ouVentes | Select-Object -ExpandProperty Access |
    Where-Object { $_.IdentityReference -like "*GG-EU-Ventes-Admin*" } |
    Format-Table IdentityReference, ActiveDirectoryRights, AccessControlType -AutoSize
```

Vous devez voir des entrées `Allow` pour `MAXTEC\GG-EU-RH-Admin` et `MAXTEC\GG-EU-Ventes-Admin` avec des droits comme `ReadProperty`, `WriteProperty`, `ExtendedRight` (sur `User-Force-Change-Password`), etc.

---

#### Questions de réflexion

1. **Pourquoi déléguer à `GG-EU-RH-Admin` et pas directement à Richard ?** Que se passe-t-il si Richard part en congé maladie et que Rebecca doit le remplacer ?

2. **Que voit Richard dans `dsa.msc` ?** Voit-il les OUs des autres départements ? Pourquoi ?

3. **Limite de l'assistant** : pourquoi l'assistant de Microsoft regroupe-t-il "création" et "suppression" ? Comment contourner cette limitation si la politique exige une séparation stricte ?

4. **Sécurité** : un délégué pourrait-il élever ses privilèges via sa délégation ? (Indice : peut-il modifier l'appartenance de son propre compte au groupe Admins du domaine ?)

---

#### Pour aller plus loin

- **Délégation fine** : `dsacls` en ligne de commande ou `Set-Acl` en PowerShell pour spécifier exactement quels attributs (ex : `mail`, `telephoneNumber`) peuvent être modifiés.
- **Délégation GPO** : voir [GPO-2, exercice 7](./Exercices:%20GPO-2.md) — c'est l'équivalent pour les GPOs (filtrage de sécurité, onglet Délégation, droit de lier des GPOs à une OU).
- **Audit** : activer l'audit des modifications de l'annuaire (`auditpol /set /subcategory:"Directory Service Changes" /success:enable`) pour tracer qui modifie quoi. Sur un Windows en français, les noms de sous-catégories sont traduits : `auditpol /list /subcategory:*` donne le nom exact.

### Exercice 13: Migration d'Utilisateurs

!!! example "Contexte"

    Suite à une restructuration, Ivan et Ines (département IT) rejoignent l'équipe Ventes. Irene reste seule responsable IT.

!!! info "Tâches à réaliser"

    1. Identifier les utilisateurs à déplacer (Ivan et Ines)
    2. Planifier la migration :
        - Nouveaux groupes nécessaires
        - Modifications des droits d'accès
        - Attributs à mettre à jour (`Department`, `Title`)

    3. Déplacer les comptes vers `OU=Users,OU=Ventes,OU=EU,DC=maxtec,DC=be`
    4. Mettre à jour toutes les appartenances aux groupes :
        - Retirer de `GG-EU-IT-Users`
        - Ajouter à `GG-EU-Ventes-Users`
    5. Vérifier que les accès fonctionnent correctement
    6. **Retour arrière** : Ivan et Ines servent dans les exercices GPO (tests des postes IT). Faites la migration inverse une fois la vérification terminée : c'est aussi un bon test de votre procédure.

??? success "Solution"

    **Plan** : aucun nouveau groupe (`GG-EU-Ventes-Users` existe). Les accès suivent les groupes : en changeant de groupe, ils perdent les accès IT et gagnent ceux de Ventes (partage `Ventes-Documents` via AGDLP). Les GPO utilisateur suivent l'OU : en changeant d'OU, ils reçoivent les GPO de `EU\Ventes\Users`.

    Dans `dsa.msc`, pour Ivan puis Ines :

    1. `EU > IT > Users` > clic droit sur le compte > **Déplacer…** > `EU > Ventes > Users` > **OK** (le glisser-déposer fonctionne aussi, avec une confirmation)
    2. Propriétés > onglet **Membre de** > sélectionnez `GG-EU-IT-Users` > **Supprimer** ; **Ajouter…** > `GG-EU-Ventes-Users` > **OK**
    3. Onglet **Organisation** > **Service** `Ventes`, **Fonction** `Commercial` > **OK**

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    foreach ($u in "ivan", "ines") {
        Get-ADUser $u | Move-ADObject -TargetPath "OU=Users,OU=Ventes,OU=EU,DC=maxtec,DC=be"
        Remove-ADGroupMember GG-EU-IT-Users -Members $u -Confirm:$false
        Add-ADGroupMember GG-EU-Ventes-Users -Members $u
        Set-ADUser $u -Department Ventes -Title "Commercial"
    }
    ```

    **Vérification** : dans `dsa.msc`, Ivan et Ines apparaissent dans `EU > Ventes > Users` ; propriétés > **Membre de** et **Organisation** montrent les nouvelles valeurs. Puis connexion d'Ivan sur `ws-IT-01` (après fermeture/réouverture de session) : `\\dns1\Ventes-Documents` accessible en lecture, `whoami /groups` liste `MAXTEC\GG-EU-Ventes-Users`, `gpresult /r /scope user` montre les GPO de Ventes. En PowerShell (aperçu) : `Get-ADUser ivan -Properties Department, MemberOf`.

    **Retour arrière** : mêmes étapes en sens inverse (déplacer vers `EU > IT > Users`, retirer `GG-EU-Ventes-Users`, ajouter `GG-EU-IT-Users`, Service `IT`, Fonction d'origine : Technicien / Technicienne), ou la même boucle PowerShell inversée.

### Exercice 14: Gestion des Comptes de Service

!!! warning "À faire après le chapitre 9"
    La création d'une gMSA (et de la clé racine KDS dont elle dépend) **se fait uniquement en PowerShell** : ni `dsa.msc` ni le Centre d'administration Active Directory ne proposent d'assistant pour la créer. Faites cet exercice une fois le chapitre 9 (PowerShell AD) vu. Le groupe de machines et le compte classique `svc-monitoring` se font, eux, en GUI.

!!! example "Objectif"

    Créer et sécuriser des comptes de service pour les applications internes de Maxtec.

Un compte de service classique (un utilisateur avec un mot de passe qui n'expire jamais) est une cible de choix : son mot de passe n'est presque jamais changé, il est souvent noté quelque part, et le compte a souvent trop de droits. La bonne pratique est le **compte de service administré de groupe** (gMSA) : son mot de passe (240 octets, soit 120 caractères) est généré et changé automatiquement par le domaine (tous les 30 jours par défaut), et seules les machines autorisées peuvent le récupérer. Personne ne le connaît.

!!! warning "Pas sur le DC"
    Un service applicatif ne tourne pas sur un contrôleur de domaine : toute application compromise sur un DC compromet le domaine entier. Dans le lab, `ws-IT-01` joue le rôle de serveur applicatif.

!!! info "Tâches à réaliser"

    1. Créer la clé racine KDS (une fois par domaine, nécessaire aux gMSA)
    2. Créer un groupe `GG-EU-IT-Computers-Backup` contenant `ws-IT-01` : ce sont les machines autorisées à utiliser le compte
    3. Créer la gMSA `svc-backup` et vérifier qu'elle fonctionne sur `ws-IT-01`
    4. Pour une application qui ne supporte pas les gMSA, créer un compte classique `svc-monitoring` sécurisé :
        - Mot de passe long (25 caractères ou plus) et aléatoire
        - Pas d'expiration de mot de passe, **avec une rotation manuelle planifiée et documentée**
        - Connexion limitée au serveur applicatif (`ws-IT-01`), jamais au DC
        - Membre d'aucun groupe d'administration
    5. Documenter les comptes dans un registre (nom, application, serveur, propriétaire, date de dernière rotation)

??? success "Solution"

    **Groupe de machines** (GUI possible) : `dsa.msc` > `EU > IT` > clic droit sur `Groups` > **Nouveau > Groupe** > nom `GG-EU-IT-Computers-Backup`, étendue **Globale**, type **Sécurité** > **OK**. Propriétés du groupe > **Membres** > **Ajouter…** > **Types d'objets…** > cochez **Ordinateurs** > `ws-IT-01` > **OK**.

    **gMSA** (sur le DC, PowerShell uniquement : la clé KDS et le compte n'ont pas d'assistant graphique ; les lignes `New-ADGroup`/`Add-ADGroupMember` refont en PowerShell le groupe ci-dessus) :

    ```powershell
    # LAB UNIQUEMENT : rend la clé utilisable immédiatement. En production : Add-KdsRootKey -EffectiveImmediately, puis attendre 10 h (réplication)
    Add-KdsRootKey -EffectiveTime ((Get-Date).AddHours(-10))

    New-ADGroup -Name GG-EU-IT-Computers-Backup -GroupScope Global -GroupCategory Security -Path "OU=Groups,OU=IT,OU=EU,DC=maxtec,DC=be"
    Add-ADGroupMember GG-EU-IT-Computers-Backup -Members (Get-ADComputer ws-IT-01)

    New-ADServiceAccount -Name svc-backup -DNSHostName svc-backup.maxtec.be `
        -PrincipalsAllowedToRetrieveManagedPassword GG-EU-IT-Computers-Backup
    ```

    La gMSA apparaît dans le conteneur `Managed Service Accounts` (affichage avancé dans `dsa.msc`). Son nom de connexion est `MAXTEC\svc-backup$`.

    Sur `ws-IT-01` : **redémarrez** d'abord (le poste doit voir sa nouvelle appartenance au groupe), puis, en administrateur, avec le module RSAT AD :

    ```powershell
    Install-ADServiceAccount svc-backup
    Test-ADServiceAccount svc-backup    # doit renvoyer True
    ```

    Pour l'utiliser : `services.msc` > propriétés d'un service > onglet **Connexion** > **Ce compte** : `MAXTEC\svc-backup$`, mots de passe **vides**.

    **Compte classique** `svc-monitoring` :

    1. OU dédiée : `dsa.msc` > clic droit sur `EU > IT` > **Nouveau > Unité d'organisation** > `ServiceAccounts`, **décochez** **Protéger le conteneur contre une suppression accidentelle** (lab)
    2. Clic droit sur `ServiceAccounts` > **Nouveau > Utilisateur** > `svc-monitoring`, mot de passe généré par un gestionnaire de mots de passe (25 caractères ou plus), décochez **L'utilisateur doit changer le mot de passe**, cochez **Le mot de passe n'expire jamais**
    3. Propriétés > onglet **Compte** : **Se connecter à…** > `ws-IT-01` ; dans **Options de compte**, cochez **Le compte est sensible et ne peut pas être délégué**
    4. Onglet **Membre de** : seulement `Utilisateurs du domaine`
    5. Consignez la date de prochaine rotation dans le registre.

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    Set-ADUser svc-monitoring -PasswordNeverExpires $true -LogonWorkstations "ws-IT-01" -AccountNotDelegated $true
    ```
