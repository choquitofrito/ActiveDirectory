# Dépannage : tickets sur le lab Maxtec

!!! info "Principe"

    Le formateur a introduit une panne sur votre lab. Vous recevez un ticket tel qu'un utilisateur l'écrirait : un symptôme, pas une cause. Votre travail : trouver la **cause racine**, la corriger, prouver que c'est réparé, et expliquer en deux phrases ce qui s'est passé.

    Il peut y avoir **plusieurs causes** derrière un même symptôme. Un ticket n'est clos que lorsque le symptôme a disparu **et** que vous savez pourquoi.

    Valeurs du lab : [Référence du lab Maxtec](Labo/Reference_Lab_Maxtec.md).

| Ticket | Thème | Durée | Moment conseillé |
|--------|-------|-------|------------------|
| [D1](#d1-le-lecteur-reseau-a-disparu-pour-lit) | GPO | 30 min | Fin du jour 3 (variante courte), après GPO-1 et GPO-2 Ex7 |
| [D2](#d2-ines-ne-peut-plus-se-connecter) | Compte utilisateur | 45 min | Fin du jour 4, après le chapitre 10 |
| [D3](#d3-acces-refuse-au-dossier-ventes) | Permissions / AGDLP | 45 min | En réserve (idéal : juste après l'exercice AGDLP) |
| [D4](#d4-le-poste-ne-trouve-plus-le-domaine) | DNS / réseau | 45 min | Fin du jour 2 |

Total : 2 h au programme (D4, D1, D2), plus 45 min en réserve (D3).

---

## Méthode

Même démarche pour chaque ticket. Elle paraît lente la première fois ; c'est elle qui fait gagner du temps ensuite.

1. **Reproduire** : constatez le symptôme vous-même, avec le compte et le poste indiqués dans le ticket. Notez le message d'erreur exact.
2. **Délimiter** : un seul utilisateur ou tous ? un seul poste ou tous ? depuis quand ? qu'est-ce qui marche encore ?
3. **Remonter la chaîne** : pour qu'un utilisateur ouvre une session et accède à un partage, il faut (dans l'ordre) : réseau → DNS → localisation du DC → authentification → jeton de groupes → GPO → permissions. Testez chaque maillon, du bas vers le haut.
4. **Corriger une chose à la fois**, puis retester. Si vous changez trois paramètres d'un coup, vous ne saurez pas lequel a réparé.
5. **Prouver** : une commande ou une capture qui montre que c'est réparé (`gpresult`, onglet **Compte** dans `dsa.msc`, accès effectif, `nslookup`...).
6. **Consigner** : cause racine, correction, comment éviter que ça revienne.

!!! warning "Ce qu'on ne fait pas"

    - Ajouter l'utilisateur en Contrôle total "pour voir si ça marche". Vous masquez la panne et en créez une autre.
    - Supprimer et recréer un objet (GPO, groupe, compte) : son SID change, et tout ce qui le référençait casse.
    - Redémarrer le DC. Ça ne résout aucun des tickets ci-dessous.

---

## D1. Le lecteur réseau a disparu pour l'IT

!!! example "Ticket #2026-0412"

    - **Demandeur** : Irene Iserbyt (`irene`), administratrice système, poste `ws-IT-01`
    - **Priorité** : haute

    > Depuis ce matin, je n'ai plus mon lecteur réseau avec les documents IT-Admin. Hier tout marchait.
    > Je n'ai rien changé sur mon PC.

    Variante complète, le ticket continue :

    > Autre chose bizarre : l'écran ne se verrouille plus tout seul et je n'ai plus le message d'avertissement
    > au démarrage.

!!! note "Variante courte (programme J3 : `Break-D1 -Fautes Lien,Filtrage`)"

    Le poste reste dans son OU ; seul le lecteur disparaît ; causes 2 et 3 seulement. La variante complète ajoute la cause 1 (poste sorti de son OU) et les symptômes côté ordinateur (verrouillage, message de connexion).

**Durée** : 30 min (variante courte), 50 min (variante complète)

**Prérequis** : GPO-1 §4.1 réalisée (lecteur réseau `\\dns1\IT-Admin` pour l'IT). Pour la variante complète, aussi §2.1 (message de connexion) et §2.2 (verrouillage) : la GPO de verrouillage doit toujours être liée et active, et `ws-IT-01` ne doit pas être dans le groupe d'exception de §2.2.2, sinon le symptôme "l'écran ne se verrouille plus" n'est pas observable.

**Outils autorisés** : console **Gestion des stratégies de groupe** (`gpmc.msc` : onglets **Étendue** > **Liaisons**, **Délégation** > **Avancé**, **Objets de stratégie de groupe liés**, Modélisation et Résultats de stratégie de groupe), `dsa.msc`, `gpresult` et `gpupdate` sur le poste. En aperçu, si vous connaissez déjà : PowerShell (`Get-GPInheritance`, `Get-GPPermission`, `Get-GPO`, `Get-ADComputer`). Pas de modification du contenu des GPO : les paramètres eux-mêmes sont corrects.

??? tip "Indice 1"

    Si le ticket signale aussi le verrouillage et le message (variante complète), il y a deux familles de symptômes : le lecteur (paramètre **utilisateur**) et le verrouillage/message (paramètres **ordinateur**). Une seule cause peut-elle expliquer les deux ? Dans tous les cas, lancez sur le poste, dans une session d'`irene` :

    ```cmd
    gpresult /r
    ```

    Regardez les deux parties séparément : *Paramètres de l'ordinateur* et *Paramètres utilisateur*. Pour chaque GPO attendue, est-elle dans "appliquées", dans "filtrées" (avec quelle raison), ou absente ?

??? tip "Indice 2"

    Une GPO absente de `gpresult` n'est pas forcément filtrée : elle peut ne jamais avoir été "vue" parce que l'objet n'est pas dans l'OU où elle est liée, ou parce que le lien est inactif.

    - **Où est le poste ?** `dsa.msc` > clic droit sur le domaine > **Rechercher…** > **Ordinateurs** > `ws-IT-01` > **Rechercher maintenant** > double-clic sur le résultat > onglet **Objet** (visible avec **Affichage > Fonctionnalités avancées**) : **Nom canonique de l'objet** donne son emplacement. Il doit être `maxtec.be/EU/IT/Computers/ws-IT-01`.
    - **Le lien est-il actif ?** La GPO du lecteur est une GPO utilisateur : elle est liée à l'OU des utilisateurs IT. GPMC > sélectionnez `EU\IT\Users` > onglet **Objets de stratégie de groupe liés** : regardez la colonne **Lien activé**. Autre chemin : sélectionnez la GPO > onglet **Étendue** > section **Liaisons**, qui liste toutes les OU où elle est liée, avec l'état de chaque lien. Un lien désactivé apparaît aussi grisé dans l'arborescence.

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    Get-ADComputer ws-IT-01 | Select-Object DistinguishedName
    # La GPO du lecteur est une GPO utilisateur : elle est liée à l'OU des utilisateurs IT
    Get-GPInheritance -Target "OU=Users,OU=IT,OU=EU,DC=maxtec,DC=be" | Select-Object -ExpandProperty GpoLinks
    ```

    Dans la sortie de `Get-GPInheritance`, regardez la colonne `Enabled`. `GpoLinks` ne montre que les liens posés **directement** sur l'OU interrogée : si la GPO n'y apparaît pas, interrogez aussi `OU=IT,OU=EU,…` et `OU=EU,…`.

    Si vous avez fait GPO-2 Ex5, le lien de `GPO-IT-LoginRestreint` (sur `EU\IT\Computers`) est désactivé ou supprimé **volontairement** : ne le réactivez pas, il n'a rien à voir avec ce ticket et bloquerait les autres utilisateurs sur `ws-IT-01`.

??? tip "Indice 3"

    Si la GPO du lecteur est bien liée, bien activée, et qu'elle n'apparaît toujours pas, allez voir **qui a le droit de la lire** : GPMC → la GPO → onglet **Étendue** → **Filtrage de sécurité**, puis onglet **Délégation** → **Avancé** (cases **Lecture** et **Appliquer la stratégie de groupe** pour chaque entrée).

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    Get-GPPermission -Name "<nom de la GPO>" -All | Select-Object @{n='Qui';e={$_.Trustee.Name}}, Permission
    ```

    Depuis 2016 (correctif MS16-072), une GPO **utilisateur** est lue avec le compte de l'**ordinateur**. Qui doit donc au minimum avoir la Lecture ?

    Pour un rapport complet, sur le poste : `gpresult /h C:\Temp\rsop.html` puis ouvrez le fichier ; ou côté DC, GPMC → **Résultats de stratégie de groupe** → assistant → `ws-IT-01` / `irene`.

??? success "Solution"

    **Deux causes (variante courte) ou trois (variante complète), cumulées.**

    **1. Le poste est sorti de son OU (variante complète seulement).** `ws-IT-01` est dans le conteneur `CN=Computers`. Un conteneur n'est pas une OU : aucune GPO d'OU ne s'y applique. D'où la perte du verrouillage et du message de connexion (GPO ordinateur liées à `EU` et à l'IT).

    Correction : `dsa.msc` → `Computers` → clic droit sur `ws-IT-01` → **Déplacer…** → `EU > IT > Computers` → **OK**. Puis redémarrez le poste.

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    Get-ADComputer ws-IT-01 | Move-ADObject -TargetPath "OU=Computers,OU=IT,OU=EU,DC=maxtec,DC=be"
    ```

    **2. Le lien de la GPO du lecteur est désactivé.** Dans GPMC, onglet **Étendue** de la GPO → **Liaisons** : `Lien activé` = `Non` sur `IT/Users` (le lien apparaît grisé sous l'OU). La GPO existe, elle est intacte, mais elle n'est plus appliquée nulle part. Ne réactivez que ce lien-là : celui de `GPO-IT-LoginRestreint` (GPO-2 Ex5) reste désactivé ou supprimé, c'est voulu.

    Correction : GPMC → `EU > IT > Users` (là où GPO-1 §4.1 l'a liée) → clic droit sur le lien → cocher **Lien activé**.

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    # Là où GPO-1 §4.1 l'a liée (adaptez -Target si vous l'aviez liée ailleurs)
    Set-GPLink -Name "<nom de la GPO>" -Target "OU=Users,OU=IT,OU=EU,DC=maxtec,DC=be" -LinkEnabled Yes
    ```

    **3. Le filtrage de sécurité a été fait à moitié.** Quelqu'un a voulu réserver le lecteur aux administrateurs IT (variation de GPO-1 §4.1) : il a ajouté `GG-EU-IT-Admin` et **supprimé** `Utilisateurs authentifiés`. Résultat : les ordinateurs ne peuvent plus lire la GPO, donc même `irene` ne la reçoit pas. `gpresult /h` l'indique comme refusée (accès refusé / sécurité) ou ne la montre pas.

    Correction : garder `GG-EU-IT-Admin` en **Appliquer**, et remettre `Utilisateurs authentifiés` en **Lecture seule** (pas Appliquer, sinon le filtrage n'a plus d'effet) : GPMC → la GPO → onglet **Délégation** → **Ajouter…** → `Utilisateurs authentifiés` → permission **Lecture** → **OK**. Contrôle : **Avancé…** → `Utilisateurs authentifiés` : **Lecture** autorisé, **Appliquer la stratégie de groupe** non coché.

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    # Sur un système en anglais : "Authenticated Users"
    Set-GPPermission -Name "<nom de la GPO>" -TargetName "Utilisateurs authentifiés" -TargetType Group -PermissionLevel GpoRead
    ```

    **Preuve** : sur le poste, `gpupdate /force`, fermeture puis réouverture de session d'`irene`, puis `gpresult /r` : la GPO du lecteur est dans les GPO utilisateur appliquées (variante complète : les GPO de verrouillage et de message aussi, dans les GPO ordinateur appliquées). Le lecteur est visible dans l'Explorateur.

!!! abstract "Ce qu'il faut retenir"

    - `gpresult /r` d'abord : il sépare ordinateur et utilisateur, et dit *pourquoi* une GPO n'est pas appliquée.
    - Trois questions dans l'ordre : l'objet est-il dans la bonne OU ? le lien est-il actif ? l'objet a-t-il le droit de lire (et d'appliquer) la GPO ?
    - Filtrage de sécurité : on remplace **Appliquer**, on ne retire jamais la **Lecture** des ordinateurs.
    - Un poste qui vient de rejoindre le domaine est dans `CN=Computers`. C'est la première chose à vérifier quand "plus aucune GPO ordinateur ne marche".

---

## D2. Ines ne peut plus se connecter

!!! example "Ticket #2026-0415"

    - **Demandeur** : Ivan Istace (`ivan`), pour sa collègue Ines Installe (`ines`)
    - **Priorité** : normale

    > Ines n'arrive plus à ouvrir sa session sur le PC de l'IT. Elle dit qu'elle tape le bon mot de passe.
    > Elle a essayé plusieurs fois. Moi j'y arrive sans problème sur le même poste.

**Durée** : 45 min (fin du jour 4, après le chapitre 10)

**Outils autorisés** : `dsa.msc` (onglet **Compte** en particulier), Observateur d'événements sur le DC, PowerShell (`Search-ADAccount`, `Get-ADUser`, `Get-WinEvent`, `Get-ADUserResultantPasswordPolicy`). Interdit : réinitialiser le mot de passe d'`ines` (ce n'est pas le problème, et vous le changeriez sans son accord).

??? tip "Indice 1"

    Reproduisez sur `ws-IT-01` et **lisez le message exact** : "compte verrouillé", "restrictions d'horaires", "pas autorisé à se connecter depuis cet ordinateur" et "mot de passe incorrect" sont quatre problèmes différents. Puis, sur le DC :

    ```powershell
    Search-ADAccount -LockedOut | Select-Object SamAccountName, LockedOut, LastLogonDate
    Get-ADUser ines -Properties LockedOut, badPwdCount, AccountLockoutTime
    ```

??? tip "Indice 2"

    Un verrouillage laisse une trace sur le DC : l'événement **4740** (journal Sécurité). Il indique **d'où** venaient les échecs.

    ```powershell
    Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4740} -MaxEvents 5 |
        Select-Object TimeCreated, @{n='Message';e={$_.Message}} | Format-List
    ```

    Qui applique un seuil de verrouillage à ce compte ? Dans la stratégie du domaine, le seuil vaut 0 (désactivé) par défaut ; le chapitre 10 le passe à 5 puis le remet à 0 à la fin du lab. Comparez la stratégie du domaine et celle qui s'applique réellement à `ines` :

    ```powershell
    Get-ADDefaultDomainPasswordPolicy | Select-Object LockoutThreshold, LockoutDuration
    Get-ADUserResultantPasswordPolicy ines
    ```

??? tip "Indice 3"

    Une fois le compte déverrouillé, s'il reste un refus, ce n'est plus le mot de passe. Regardez les restrictions portées par le compte lui-même :

    ```powershell
    Get-ADUser ines -Properties logonHours, LogonWorkstations | Select-Object Name, logonHours, LogonWorkstations
    ```

    GUI : `dsa.msc` → `ines` → **Propriétés** → onglet **Compte** → boutons **Horaires d'accès…** et **Se connecter à…**.

??? success "Solution"

    **Trois restrictions empilées sur le compte.**

    **1. Compte verrouillé.** Une stratégie de mot de passe affinée (PSO) dédiée, `PSO-Depannage-ines`, avec un seuil de 3 échecs, s'applique à `ines` (`Get-ADUserResultantPasswordPolicy`). Elle gagne sur la stratégie du domaine, quel que soit le seuil de celle-ci. Après plusieurs mauvais mots de passe, le compte est verrouillé pour 2 heures. L'événement 4740 donne l'heure et l'ordinateur appelant (ici `DNS1` : les échecs ont été générés depuis le serveur ; en production, ce serait typiquement un smartphone ou un lecteur réseau qui garde un ancien mot de passe).

    ```powershell
    Unlock-ADAccount -Identity ines
    ```

    GUI : `dsa.msc` → `ines` → onglet **Compte** → cocher **Déverrouiller le compte**.

    Puis supprimez la PSO de dépannage, sinon `ines` reste verrouillable au bout de 3 échecs jusqu'à la fin de la semaine :

    ```powershell
    Remove-ADFineGrainedPasswordPolicy -Identity PSO-Depannage-ines -Confirm:$false
    Get-ADUserResultantPasswordPolicy ines     # ne renvoie plus rien : la stratégie du domaine s'applique
    ```

    GUI : `dsac.exe` → `maxtec (local)` → `System` → `Password Settings Container` → `PSO-Depannage-ines` → **Supprimer** (décochez d'abord la protection contre la suppression accidentelle si elle est cochée).

    **2. Horaires d'accès restreints.** `logonHours` n'autorise que la nuit (01:00-05:00 UTC). Probablement un profil "équipe de nuit" copié par erreur. Retour à 24 h/24 :

    ```powershell
    Set-ADUser -Identity ines -Clear logonHours
    ```

    GUI : onglet **Compte** → **Horaires d'accès…** → tout sélectionner → **Connexion autorisée**.

    **3. Poste autorisé inexistant.** `LogonWorkstations` = `ws-IT-99`, un poste qui n'existe pas. `ines` ne peut se connecter nulle part.

    ```powershell
    Set-ADUser -Identity ines -Clear userWorkstations
    ```

    GUI : onglet **Compte** → **Se connecter à…** → **Tous les ordinateurs**.

    **Preuve** : `Get-ADUser ines -Properties LockedOut, logonHours, LogonWorkstations` montre `LockedOut : False` et les deux autres attributs vides ; `Get-ADUserResultantPasswordPolicy ines` ne renvoie plus rien ; `ines` ouvre sa session sur `ws-IT-01`.

    **Pour que ça ne revienne pas** : si le verrouillage se répète, retrouvez la source dans l'événement 4740 (ordinateur appelant) avant de déverrouiller une deuxième fois.

!!! abstract "Ce qu'il faut retenir"

    - Le message d'erreur exact vaut une demi-heure de recherche. Faites-le lire, ou lisez-le vous-même.
    - Verrouillage : `Search-ADAccount -LockedOut`, puis événement **4740** sur le DC (celui qui a le rôle PDC) pour trouver la source. Déverrouiller sans chercher la source, c'est rouvrir le ticket demain.
    - Le compte lui-même peut porter des restrictions (horaires, postes, expiration) indépendantes du mot de passe et des GPO.
    - Une PSO appliquée à un utilisateur ou à un groupe remplace la stratégie du domaine pour ce compte. `Get-ADUserResultantPasswordPolicy` montre laquelle gagne.

---

## D3. Accès refusé au dossier Ventes

!!! example "Ticket #2026-0419"

    - **Demandeur** : Valentin Vanderlinden (`valentin`), responsable Ventes
    - **Priorité** : haute (fin de trimestre)

    > Je n'ai plus accès au partage Ventes-Documents, "accès refusé". Mes commerciaux (Vanessa, Victor)
    > voient bien le partage mais pas le dossier Contrats. Et la compta (Cindy) m'appelle aussi : elle ne peut
    > plus consulter les contrats facturés. Quelqu'un de l'IT a "fait du ménage dans les groupes" hier soir.

**Durée** : 45 min

**Prérequis** : [exercice AGDLP](./Exercices:%20AGDLP_Partage_Fichiers.md) terminé, y compris l'étape 8 (Compta en lecture). Le sous-dossier `Contrats` n'existe pas dans l'exercice AGDLP : le formateur le crée en injectant la panne.

**Outils autorisés** : Explorateur (Propriétés > **Partage** > **Partage avancé** > **Autorisations** ; **Sécurité** > **Avancé** > **Accès effectif**), `dsa.msc` (propriétés des groupes : **Général** > **Étendue du groupe**, **Membres**, **Membre de**), `whoami /groups` et `klist` sur le client, `icacls` sur le serveur. En aperçu, si vous connaissez déjà : PowerShell (`Get-Acl`, `Get-ADGroup`, `Get-ADGroupMember`, `Get-ADPrincipalGroupMembership`, `Get-SmbShareAccess`). Contrainte : la correction doit respecter AGDLP (aucun utilisateur ni groupe global dans les ACL).

??? tip "Indice 1"

    Trois plaintes, trois utilisateurs, trois groupes différents. Traitez-les séparément. Pour chacun, **Accès effectif** (Propriétés du dossier → Sécurité → Avancé → Accès effectif) sur la racine du partage et sur `Contrats`.

    Regardez la liste des entrées de la racine : y en a-t-il une qui ne ressemble pas aux autres ?

??? tip "Indice 2"

    Une entrée affichée comme **"Compte inconnu (S-1-5-21-…)"** désigne un objet supprimé. Si un groupe du même nom existe toujours, c'est qu'il a été **recréé** : nouveau SID, donc l'ACL ne le connaît pas.

    - Liste des entrées : Explorateur → Propriétés de `C:\Shares\Ventes-Documents` → **Sécurité** → **Avancé** (ou `icacls C:\Shares\Ventes-Documents` en invite de commandes)
    - Groupes : `dsa.msc` → `EU > Ventes > Groups` (ou **Rechercher…** `DL-Ventes-Documents`) → propriétés de chaque groupe `DL-Ventes-Documents-*` → onglet **Général** → **Étendue du groupe** ; avec l'affichage avancé, onglet **Objet** → **Créé le** : une date récente trahit une recréation

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    Get-ADGroup -Filter "Name -like 'DL-Ventes-Documents-*'" -Properties whenCreated |
        Select-Object Name, GroupScope, whenCreated, SID
    (Get-Acl C:\Shares\Ventes-Documents).Access | Select-Object IdentityReference, FileSystemRights, AccessControlType, IsInherited
    ```

    Regardez aussi l'**étendue** de chaque groupe.

??? tip "Indice 3"

    Sur `Contrats`, comparez les entrées **héritées** et **explicites** : Propriétés → **Sécurité** → **Avancé**, colonne **Hérité de** (« Aucun » = entrée explicite). Un **Refuser** explicite l'emporte sur une autorisation héritée.

    Pour Cindy : de quel groupe tient-elle son accès, en théorie ? Ce groupe est-il toujours là où il doit être (`dsa.msc` → propriétés du DL de lecture → onglet **Membres**) ? Et après correction, si elle est toujours refusée, comparez sur son poste :

    ```cmd
    whoami /groups | findstr /i "DL-"
    klist
    ```

    Les groupes d'une session sont figés à l'ouverture de session.

??? success "Solution"

    **Trois causes, toutes des écarts à AGDLP.**

    **1. DL recréé en Global.** `DL-Ventes-Documents-Modification` a été supprimé puis recréé, en étendue **Globale** (défaut de la console). Deux conséquences :

    - son **SID a changé** : l'ACL NTFS contient toujours l'ancien SID ("Compte inconnu"), le nouveau groupe n'y figure pas → `valentin` (membre de `GG-EU-Ventes-Admin` seulement) n'a plus aucun accès ;
    - son étendue ne correspond plus à son préfixe `DL-`.

    Correction dans `dsa.msc` : propriétés de `DL-Ventes-Documents-Modification` → onglet **Général** → **Étendue du groupe** : **Universelle** → **Appliquer** (Global → Domaine local n'est pas direct, l'option est grisée) ; puis **Domaine local** → **OK**. Onglet **Membres** : `GG-EU-Ventes-Admin` doit y être, sinon **Ajouter…**.

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    # Global -> Domaine local n'est pas direct : on passe par Universel
    Set-ADGroup DL-Ventes-Documents-Modification -GroupScope Universal
    Set-ADGroup DL-Ventes-Documents-Modification -GroupScope DomainLocal
    Get-ADGroupMember DL-Ventes-Documents-Modification    # GG-EU-Ventes-Admin doit y être
    ```

    Puis dans l'Explorateur : supprimer l'entrée "Compte inconnu", ajouter `DL-Ventes-Documents-Modification` en **Modification**.

    **2. Refuser explicite sur `Contrats`.** Une entrée **Refuser – Lecture et exécution** pour `GG-EU-Ventes-Users` a été posée sur le sous-dossier. Double faute : un groupe global dans une ACL, et un Deny qui écrase l'autorisation héritée de `DL-Ventes-Documents-Lecture`. Correction : supprimer l'entrée (Propriétés de `Contrats` → Sécurité → Avancé → sélectionner l'entrée **Refuser** → **Supprimer**). Ne rien ajouter à la place : l'héritage suffit.

    **3. Compta sortie du DL de lecture.** `GG-EU-Compta-Users` n'est plus membre de `DL-Ventes-Documents-Lecture` (le "ménage" de la veille). On le remet : `dsa.msc` → propriétés de `DL-Ventes-Documents-Lecture` → onglet **Membres** → **Ajouter…** → `GG-EU-Compta-Users` → **Vérifier les noms** → **OK**.

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    Add-ADGroupMember -Identity DL-Ventes-Documents-Lecture -Members GG-EU-Compta-Users
    ```

    Cindy reste refusée juste après : sa session porte encore l'ancien jeton (`whoami /groups` ne montre pas le DL). Elle doit **fermer et rouvrir sa session**. `klist purge` force de nouveaux tickets Kerberos et suffit souvent, mais une connexion SMB déjà ouverte vers `dns1` peut garder l'ancien jeton : la fermeture de session reste la méthode sûre.

    **Preuve** : Accès effectif sur la racine et sur `Contrats` pour `valentin` (Modification), `vanessa` (Lecture), `cindy` (Lecture), `irene` (Contrôle total) ; la liste des entrées de la racine ne contient que `SYSTEM`, `Administrateurs`, `CREATEUR PROPRIETAIRE` éventuellement, et les trois `DL-Ventes-Documents-*`.

!!! abstract "Ce qu'il faut retenir"

    - Une ACL référence des **SID**, pas des noms. Supprimer puis recréer un groupe "avec le même nom" casse tous les accès qu'il portait. Si un groupe a été supprimé par erreur, on le restaure (corbeille AD), on ne le recrée pas.
    - L'étendue se vérifie : un `DL-` en Global est une erreur, même si ça "marche" aujourd'hui.
    - Un **Refuser** explicite gagne sur une autorisation héritée. Dans un modèle AGDLP propre, on n'en a presque jamais besoin.
    - Changement de groupe → nouvelle session. Tant que l'utilisateur n'a pas rouvert sa session, votre correction est invisible pour lui.

---

## D4. Le poste ne trouve plus le domaine

!!! example "Ticket #2026-0422"

    - **Demandeur** : Ivan Istace (`ivan`), poste `ws-IT-01`
    - **Priorité** : haute

    > J'ai pu ouvrir ma session, mais plus rien ne marche : pas d'accès à `\\dns1`, `gpupdate` plante avec une
    > erreur, et l'intranet (`intranet.maxtec.be`) ne répond plus depuis qu'il a été déplacé sur le serveur
    > principal. J'ai peut-être touché à la carte réseau hier en voulant accéder à Internet.

**Durée** : 45 min

**Outils autorisés** : sur le poste : `ncpa.cpl` (propriétés de la carte réseau), `ipconfig /all`, `nslookup`, `ping`, `nltest /dsgetdc:maxtec.be`, l'Explorateur (`\\dns1\NETLOGON`) ; sur le DC : **Gestionnaire DNS** (`dnsmgmt.msc`). En aperçu, si vous connaissez déjà : PowerShell (`Resolve-DnsName`, `Test-NetConnection`, `Get-DnsServerResourceRecord`). Interdit : sortir le poste du domaine et le rejoindre à nouveau.

??? tip "Indice 1"

    "J'ai pu ouvrir ma session" ne prouve rien : Windows garde les identifiants en cache et ouvre une session même sans DC. Premier maillon de la chaîne :

    ```cmd
    ipconfig /all
    ```

    Quel serveur DNS le poste interroge-t-il ? Est-il joignable depuis le réseau interne du lab ?

??? tip "Indice 2"

    Une fois le poste revenu sur le bon DNS, testez chaque nom séparément et comparez avec ce que dit le serveur :

    ```cmd
    nslookup dns1.maxtec.be
    nslookup -type=SRV _ldap._tcp.dc._msdcs.maxtec.be
    nslookup intranet.maxtec.be
    ```

    Le nom se résout-il ? Puis la machine répond-elle ? Testez l'adresse obtenue : `ping <adresse>`, et dans l'Explorateur `\\<adresse>` (partage de fichiers, port 445). Sur le DC : **Gestionnaire DNS** → `Zones de recherche directe` → `maxtec.be` → enregistrement `intranet`. L'adresse correspond-elle à une machine qui existe ?

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    Resolve-DnsName dns1.maxtec.be
    Resolve-DnsName _ldap._tcp.dc._msdcs.maxtec.be -Type SRV
    Resolve-DnsName intranet.maxtec.be
    Test-NetConnection intranet.maxtec.be -Port 445
    ```

    Sur le DC : `Get-DnsServerResourceRecord -ZoneName maxtec.be -Name intranet`.

??? tip "Indice 3"

    Testez aussi la résolution **inverse** du poste. Ne supposez pas `192.168.0.10` : si le poste est passé en DHCP (lab Anatomie), il a une adresse de l'étendue. Prenez l'adresse IPv4 de `ws-IT-01` affichée par `ipconfig` (ou `nslookup ws-IT-01.maxtec.be`), puis :

    ```cmd
    nslookup <adresse de ws-IT-01>
    ```

    Côté DC : **Gestionnaire DNS** → `Zones de recherche inversée` → `0.168.192.in-addr.arpa` : le pointeur de `ws-IT-01` est-il là ?

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    $ip = (Resolve-DnsName ws-IT-01.maxtec.be -Type A).IPAddress
    nslookup $ip
    Resolve-DnsName $ip
    ```

    Un poste Windows enregistre lui-même son A et son PTR dans le DNS... à condition de pouvoir joindre le bon serveur DNS.

??? success "Solution"

    **Trois causes, du bas vers le haut de la chaîne.**

    **1. Mauvais serveur DNS sur le client.** `ipconfig /all` montre `Serveurs DNS : 8.8.8.8`. Le réseau du lab est interne, 8.8.8.8 est injoignable ; et même joignable, un DNS public ne connaît pas `maxtec.be` ni ses enregistrements SRV. Sans eux, le poste ne trouve pas de DC : pas de `gpupdate`, pas de Kerberos, pas de `\\dns1`.

    Correction sur le poste, en administrateur :

    1. **Win+R** → `ncpa.cpl` → clic droit sur la carte `Ethernet` → **Propriétés**
    2. **Protocole Internet version 4 (TCP/IPv4)** → **Propriétés**
    3. **Utiliser l'adresse de serveur DNS suivante** : Serveur DNS préféré `192.168.0.2`, serveur auxiliaire vide → **OK** → **Fermer**. Si le poste est en DHCP (lab Anatomie), cochez plutôt **Obtenir les adresses des serveurs DNS automatiquement** : le DHCP distribue `192.168.0.2` (option 006)
    4. Invite de commandes : `ipconfig /flushdns` (en DHCP : `ipconfig /renew` avant), puis `nltest /dsgetdc:maxtec.be`, qui doit renvoyer `dns1.maxtec.be`

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    Get-NetAdapter
    Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 192.168.0.2
    ipconfig /flushdns
    nltest /dsgetdc:maxtec.be          # doit renvoyer dns1.maxtec.be
    ```

    Si le poste est en DHCP (lab Anatomie), ne fixez pas d'adresse : rendez la main au DHCP, qui distribue `192.168.0.2` (option 006).

    ```powershell
    Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ResetServerAddresses
    ipconfig /renew
    ```

    Règle : un membre du domaine n'interroge **que** les DNS du domaine. C'est le DC qui résout les noms Internet, pas un DNS public configuré sur le client.

    **2. Enregistrement `intranet` obsolète.** Sur le DC, `intranet.maxtec.be` pointe vers `192.168.0.250`, l'ancien serveur décommissionné : `nslookup` répond, mais `\\192.168.0.250` est injoignable (`Test-NetConnection` échoue aussi). Correction dans le **Gestionnaire DNS** : `Zones de recherche directe` → `maxtec.be` → double-clic sur `intranet` → **Adresse IP** `192.168.0.2` → **OK**.

    **En PowerShell** (aperçu, vu au chapitre 9) :

    ```powershell
    $ancien = Get-DnsServerResourceRecord -ZoneName maxtec.be -Name intranet -RRType A
    $nouveau = $ancien.Clone(); $nouveau.RecordData.IPv4Address = [ipaddress]'192.168.0.2'
    Set-DnsServerResourceRecord -ZoneName maxtec.be -OldInputObject $ancien -NewInputObject $nouveau
    ```

    Côté client, `ipconfig /flushdns` : l'ancienne réponse peut rester en cache jusqu'à expiration de son TTL.

    **3. PTR du poste absent.** `nslookup` sur l'adresse de `ws-IT-01` (`ipconfig`) ne trouve pas de nom. La zone inverse existe mais l'enregistrement a disparu, et le poste ne pouvait pas le recréer tant qu'il interrogeait 8.8.8.8. Une fois le DNS corrigé :

    ```cmd
    ipconfig /registerdns              # sur le poste, en administrateur
    ```

    ou création manuelle dans la console DNS (zone `0.168.192.in-addr.arpa` → Nouveau pointeur).

    **Preuve** : `nltest /dsgetdc:maxtec.be` OK, `gpupdate /force` sans erreur, `\\dns1\NETLOGON` s'ouvre dans l'Explorateur, `nslookup intranet.maxtec.be` → `192.168.0.2`, `nslookup <adresse de ws-IT-01>` → `ws-IT-01.maxtec.be`. (En PowerShell : `Resolve-DnsName`.)

!!! abstract "Ce qu'il faut retenir"

    - "Plus rien ne marche" sur un poste de domaine : commencez par `ipconfig /all` et le serveur DNS. C'est la cause la plus fréquente.
    - Une session ouverte ne prouve pas que le DC est joignable (identifiants en cache).
    - Un enregistrement statique (créé à la main) ne se met jamais à jour tout seul. Quand un service déménage, on met le DNS à jour dans la même opération.
    - Deux questions séparées : "le nom se résout-il ?" (`nslookup`) et "la machine répond-elle ?" (`ping`, ouverture de `\\adresse`). En PowerShell : `Resolve-DnsName` et `Test-NetConnection`.
