# Guide Instructeur - Labo 3 : MonitoringLab

## MonitoringTech SPRL - Monitoring, Audit et Sécurité Active Directory

**Public cible** : Étudiants en formation AD (4 jours / 28h), profils variés incluant des non-techniciens
**Niveau** : Exercices 1-2 (Débutant), Exercices 3-4 (Intermédiaire), Exercices 5-6 (Avancé)
**Durée totale** : 7h00 - 7h30

---

## Avant de Commencer : Checklist Instructeur

### Préparation du Lab (à faire la veille)

- [ ] Exécuter `MonitoringLab_Setup.ps1` sur le DC et vérifier qu'il se termine sans erreurs
- [ ] Confirmer la présence des 4 départements dans ADUC (ITOperations, Security, RH, Finance)
- [ ] Vérifier que les 4 comptes de service existent dans `OU=ServiceAccounts`
- [ ] Exécuter `2_Generate-Events.ps1` pour pré-peupler les journaux d'événements
- [ ] Vérifier que les journaux Security contiennent des événements 4624 et 4625
- [ ] S'assurer que GPMC est installée sur le DC (normalement inclus avec AD DS)
- [ ] Préparer `C:\Temp\` sur le DC pour les exports de rapports des étudiants

### Règles Critiques à Rappeler aux Étudiants

!!! danger "Règle GPO - JAMAIS Set-GPRegistryValue pour politiques Windows standard"
    Insistez lourdement sur ce point avant l'Exercice 03. La tentative la plus commune des étudiants est de chercher des commandes PowerShell "qui font tout". Expliquez que les politiques Windows standard (audit, restrictions utilisateur) DOIVENT être configurées via GPMC, pas via `Set-GPRegistryValue`.

!!! warning "Convention de nommage GG- obligatoire"
    Tout groupe créé par un étudiant DOIT commencer par `GG-`. Refusez toute solution qui ne respecte pas cette convention.

!!! warning "OUs sans protection"
    Si un étudiant crée une OU dans ses exercices, elle DOIT être créée avec `-ProtectedFromAccidentalDeletion $false` pour que le cleanup script fonctionne.

---

## Exercice 01 : Exploration de la Structure AD

### Notes Pédagogiques

**Objectif principal** : Familiariser les étudiants avec ADUC et PowerShell de base. Cet exercice ne doit générer aucun stress.

**Points de blocage courants** :

1. Les étudiants confondent les "Conteneurs" (CN=Users, CN=Computers) avec les OUs. Montrez la différence visuelle dans ADUC : les OUs ont une icône de dossier jaune avec un livre.
2. Certains ne trouvent pas l'OU MONITORING car ils cherchent dans CN=Users plutôt que directement sous DC=maxtec,DC=be.

**Questions pédagogiques à poser en classe** :

- "Pourquoi les comptes de service sont-ils dans leur propre OU plutôt que mélangés avec les utilisateurs normaux ?"
- "Que signifie le préfixe `GG-` sur les groupes ?"
- "Quelle est la différence entre un compte actif et un compte désactivé dans ADUC ?"

**Durée recommandée** : 45 minutes. Ne laissez pas cet exercice s'étirer. Avancez si les étudiants sont bloqués sur un détail mineur.

### Solution de Référence

```powershell
# Inventaire rapide pour démonstration instructor
Import-Module ActiveDirectory
Get-ADOrganizationalUnit -Filter * -SearchBase "OU=MONITORING,DC=maxtec,DC=be" |
    Sort-Object DistinguishedName | Select-Object Name, DistinguishedName | Format-Table -AutoSize
```

---

## Exercice 02 : Analyse des Événements de Sécurité

### Notes Pédagogiques

**Objectif principal** : Les étudiants doivent comprendre que les journaux Windows sont une source d'information essentielle, pas juste un outil de débogage.

**Points de blocage courants** :

1. "Mon journal est vide" : Souvent car le script `2_Generate-Events.ps1` n'a pas été exécuté, ou la taille du journal est trop petite. Solution : exécuter le script, augmenter la taille du journal.
2. L'extraction XML avec `$event.ToXml()` peut dérouter les débutants. Montrez d'abord l'onglet Général de l'Observateur d'événements avant d'introduire PowerShell.
3. Certains étudiants cherchent l'Event ID dans le mauvais journal (Application au lieu de Security).

**Concepts clés à expliciter** :

- La différence entre Event ID 4624 (succès) et 4625 (échec) : dessinez un diagramme au tableau
- Le Logon Type : montrez un tableau des types courants (2=interactif, 3=réseau, 10=RDP)
- L'importance de l'heure : un pic de 4625 à 03h00 du matin est un signal d'alerte clair

**Démonstration recommandée** :
Montrez en direct comment filtrer dans l'Observateur, puis montrez la même chose via PowerShell. Les étudiants comprennent mieux l'outil GUI avant le PowerShell.

### Solution de Référence

```powershell
# Top 5 des comptes avec le plus d'échecs de connexion
Get-WinEvent -LogName Security -MaxEvents 10000 |
    Where-Object { $_.Id -eq 4625 } |
    ForEach-Object {
        $xml = [xml]$_.ToXml()
        ($xml.Event.EventData.Data | Where-Object { $_.Name -eq "TargetUserName" }).'#text'
    } |
    Where-Object { $_ -ne "-" } |
    Group-Object | Sort-Object Count -Descending | Select-Object -First 5 |
    Format-Table Name, Count -AutoSize
```

---

## Exercice 03 : Configuration des GPOs

### Notes Pédagogiques

**Objectif principal** : Comprendre que les GPOs Windows standard se configurent EXCLUSIVEMENT via GPMC pour les paramètres d'audit et restrictions. La règle "no Set-GPRegistryValue" est fondamentale.

**Points de blocage courants** :

1. La navigation dans GPMC est complexe avec de nombreux niveaux d'arborescence. Faites une démonstration lente et claire avant de laisser les étudiants travailler seuls.
2. "Je ne trouve pas Configuration avancée de la stratégie d'audit" : Il y a deux chemins : l'un "Local Policies" (basique) et l'autre "Advanced Audit Policy Configuration" (avancé). Pour ce lab, utilisez le chemin avancé.
3. La politique de mots de passe via PowerShell est souvent réussie, mais les étudiants oublient de vérifier avec `Get-ADDefaultDomainPasswordPolicy`.

**Point pédagogique critique** :
Montrez ce qui se passe quand on utilise `Set-GPRegistryValue` incorrectement : ouvrez GPMC, cherchez la GPO, et montrez le message "Le nom convivial de certains paramètres est introuvable". Cela marque durablement les étudiants.

**Navigation GPMC exacte** (à écrire au tableau) :

Pour la GPO d'audit :
```
GPMC > Forest:maxtec.be > Domaines > maxtec.be > Objets de stratégie de groupe >
[Clic droit sur la GPO] > Modifier >
Configuration ordinateur > Paramètres Windows > Paramètres de sécurité >
Configuration avancée de la stratégie d'audit > Stratégies d'audit >
Ouverture/Fermeture de session > Auditer l'ouverture de session
```

Pour la GPO de restrictions :
```
GPMC > [...] > Modifier >
Configuration utilisateur > Stratégies > Modèles d'administration > Panneau de configuration >
Interdire l'accès au Panneau de configuration et aux paramètres du PC
```

### Vérification Manuelle Instructeur

Après que les étudiants ont terminé, vérifiez dans GPMC :

1. Ouvrez la GPO "MONITORING - Configuration Journaux Événements" > Paramètres > Configuration ordinateur
2. Vérifiez que les paramètres d'Event Log Service (taille des journaux) apparaissent SANS le message "nom convivial introuvable"
3. Si le message apparaît : la GPO a été configurée via Set-GPRegistryValue et doit être recréée
4. Faire de même pour "MONITORING - Restrictions Stations Sensibles" (USB) et "MONITORING - Verrouillage Session Automatique" (inactivité)

---

## Exercice 04 : Gestion des Comptes de Service

### Notes Pédagogiques

**Objectif principal** : Comprendre le concept du moindre privilège appliqué aux comptes de service. Les comptes de service sont des vecteurs d'attaque fréquents.

**Points de blocage courants** :

1. `Add-ADGroupMember -Identity "Event Log Readers"` : le nom peut varier selon la langue du serveur. En français : "Lecteurs du journal des événements". Solution : utiliser le SID `S-1-5-32-573` ou chercher avec `Get-ADGroup -Filter { Name -like "*Event Log*" }`.
2. La création du groupe avec `New-ADGroup` : les étudiants oublient souvent `-Path` ou spécifient un chemin incorrect.
3. `CannotChangePassword` ne fonctionne pas directement avec `Set-ADUser` dans toutes les versions. Montrez l'alternative via ADUC si PowerShell échoue.

**Discussion pédagogique** :
Posez la question : "Pourquoi ne donne-t-on pas les droits Domain Admin au compte de service de monitoring ?" Guidez vers la réponse : si le compte est compromis, l'attaquant n'a pas les clés du royaume.

**Note sur Event Log Readers** :

```powershell
# Si le nom en anglais ne fonctionne pas, cherchez par SID
$elr = Get-ADGroup -Filter * | Where-Object { $_.SID -like "S-1-5-32-573" }
Add-ADGroupMember -Identity $elr -Members "svc_audit"
```

---

## Exercice 05 : Audit Personnalisé Finance

### Notes Pédagogiques

**Objectif principal** : Comprendre la différence entre audit système (`auditpol`) et audit NTFS (SACL). Les deux sont nécessaires pour que l'Event ID 4663 soit généré.

**Le piège classique** :
Les étudiants configurent les ACL d'audit NTFS mais oublient `auditpol`. Résultat : aucun événement 4663 n'est généré même si les ACL sont correctement configurées. Faites insister sur le fait que les DEUX doivent être activés.

**Explication visuelle** :
```
Fichier accédé
     |
     v
ACL NTFS (SACL) : "Dois-je auditer cet accès ?" --> OUI
     |
     v
auditpol "File System" : "Puis-je écrire dans le journal Security ?" --> OUI
     |
     v
Event ID 4663 généré dans le journal Security
```

**Points de blocage courants** :

1. La manipulation des SACL avec .NET peut être intimidante. Si un étudiant bloque, montrez-lui l'alternative via l'interface graphique : clic droit sur le dossier > Propriétés > Sécurité > Avancé > onglet Audit.
2. Les événements 4663 peuvent mettre quelques secondes à apparaître après l'accès au fichier. Dites aux étudiants d'attendre 30 secondes avant de vérifier.
3. Sur un DC, il peut y avoir un déluge de 4663 pour les fichiers système. Filtrez toujours sur `ObjectName -like "*FinanceData*"`.

### Démonstration de la GUI alternative (si PowerShell bloque)

```
Clic droit sur C:\FinanceData > Propriétés > Sécurité > Avancé > Onglet Audit >
Ajouter > Sélectionnez un principal : Tout le monde >
Type : Tout > S'applique à : Ce dossier, les sous-dossiers et les fichiers >
Autorisations de base : cocher Lecture, Écriture, Suppression > OK
```

---

## Exercice 06 : Investigation d'Incident

### Notes Pédagogiques

**Objectif principal** : Appliquer une méthodologie structurée sous pression simulée. Cet exercice teste toutes les compétences acquises dans les exercices précédents.

**Gestion de la classe** :
Lisez l'alerte email à voix haute comme si vous étiez le système de supervision. Créez un sentiment d'urgence modéré pour simuler la réalité professionnelle.

**Points de blocage courants** :

1. Les étudiants veulent tout analyser avant de confinement. Insistez : **d'abord confinement, ensuite analyse**. C'est la règle de base en incident response.
2. L'extraction XML des événements (`$event.ToXml()`) est complexe. Si un étudiant bloque, donnez-lui le template du fichier exercice directement.
3. La chronologie peut être difficile à construire si les journaux ne contiennent pas d'événements liés à `svc_monitoring`. Utilisez `2_Generate-Events.ps1` si nécessaire.

**Points à souligner dans le debriefing** :

- La documentation au moment du confinement (description du compte) est souvent oubliée dans la réalité, mais est cruciale pour les audits ultérieurs
- Un bon rapport d'incident doit être compréhensible par quelqu'un qui n'a pas participé à l'investigation
- La réactivation du compte doit être délibérée et documentée, pas simplement "undone"

**Debriefing de fin d'exercice** :
Demandez à un étudiant de présenter sa chronologie à la classe. Comparez les résultats entre groupes. Discutez des lacunes potentielles si les journaux n'étaient pas assez riches.

### Notes sur le Scénario Fictif

Le scénario mentionne une IP `192.168.100.250` qui n'est pas répertoriée. Dans le lab, cette IP peut ne pas apparaître dans les journaux (car l'attaque est simulée). Dites aux étudiants de rechercher tout événement lié à `svc_monitoring` sans se focaliser sur une IP spécifique.

---

## Calendrier Suggéré pour une Session de 7h30

| Heure | Activité | Durée |
|-------|----------|-------|
| 09h00 | Briefing, vérification du setup, présentation du scénario MonitoringTech | 15 min |
| 09h15 | Exercice 01 - Exploration | 45 min |
| 10h00 | Exercice 02 - Événements de Sécurité | 60 min |
| 11h00 | Pause | 15 min |
| 11h15 | Exercice 03 - Configuration GPOs | 75 min |
| 12h30 | Déjeuner | 60 min |
| 13h30 | Exercice 04 - Comptes de Service | 60 min |
| 14h30 | Exercice 05 - Audit Personnalisé | 90 min |
| 16h00 | Pause | 15 min |
| 16h15 | Exercice 06 - Investigation d'Incident | 90 min |
| 17h45 | Debriefing, questions/réponses | 15 min |
| 18h00 | Fin |  |

---

## Points d'Évaluation Suggérés

Si vous souhaitez évaluer formellement les étudiants :

### Évaluation Pratique (60 min max)

Donnez une des tâches suivantes à réaliser de façon autonome :

**Niveau Débutant** : "Listez tous les utilisateurs du département Finance avec leur dernière connexion via PowerShell. Exportez le résultat en CSV."

**Niveau Intermédiaire** : "Créez un groupe `GG-MONITORING-Superviseurs` dans l'OU Finance et ajoutez-y 3 utilisateurs Finance. Vérifiez la configuration avec Get-ADGroup."

**Niveau Avancé** : "Un utilisateur signale ne pas avoir pu se connecter ce matin. Identifiez dans les journaux les 3 derniers échecs de connexion pour cet utilisateur et donnez la raison de chaque échec."

### Grille d'Évaluation Compétences Clés

| Compétence | Non acquis | En cours | Acquis |
|------------|-----------|----------|--------|
| Naviguer dans ADUC | | | |
| Utiliser Get-ADUser / Get-ADGroup | | | |
| Filtrer les journaux Security par Event ID | | | |
| Configurer Set-ADDefaultDomainPasswordPolicy | | | |
| Créer un groupe GG- avec les bons paramètres | | | |
| Activer auditpol pour File System | | | |
| Désactiver un compte compromis en urgence | | | |
| Appliquer le principe du moindre privilège | | | |

---

## Ressources de Référence pour l'Instructeur

- **Event IDs complets** : [Microsoft - Security Audit Events](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/appendix-l--events-to-monitor)
- **GPO Reference** : Voir `.claude/gpo-reference.md` dans ce projet
- **Get-ADUser paramètres** : [Microsoft Learn - Get-ADUser](https://learn.microsoft.com/en-us/powershell/module/activedirectory/get-aduser)
- **auditpol documentation** : [Microsoft - auditpol](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/auditpol)
- **FileSystemAuditRule** : [Microsoft .NET - FileSystemAuditRule](https://learn.microsoft.com/en-us/dotnet/api/system.security.accesscontrol.filesystemauditrule)
