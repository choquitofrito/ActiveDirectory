# Exercices Pratiques : Active Directory Domain Services (AD DS)

> 📚 **Dans ce document :**
> 1. 🔍 [Préparation à l'installation d'AD DS](#1--préparation-à-linstallation-dad-ds)
> 2. 🛠️ [Installation et configuration d'AD DS](#2--installation-et-configuration-dad-ds)
> 3. 🏗️ [Structure du domaine et sites AD](#3--structure-du-domaine-et-sites-ad)
> 4. 🧪 [Tests et validation](#4--tests-et-validation)

## 1. 🔹 Préparation à l'installation d'AD DS

### Exercice 1.1 : Vérification des prérequis

**Objectif :** S'assurer que le serveur est correctement préparé pour l'installation d'AD DS.

<details>
<summary>📝 Instructions</summary>

1. Connectez-vous à votre serveur Windows Server 2022 (`dns1.computerelectronics.be`) avec un compte administrateur.
2. Vérifiez que le serveur dispose d'une adresse IP statique :
   - Ouvrez PowerShell en tant qu'administrateur
   - Exécutez la commande : `Get-NetIPConfiguration`
   - Vérifiez que l'adresse IP est bien `192.168.0.2` avec le masque de sous-réseau `255.255.255.0`

3. Vérifiez que le nom du serveur est correctement configuré :
   - Exécutez la commande : `hostname`
   - Le résultat doit être `dns1`
   - Exécutez la commande : `Get-ComputerInfo | Select-Object CsDNSHostName, CsDomain`
   - Vérifiez que le nom d'hôte DNS est `dns1` et que le domaine est bien configuré

4. Vérifiez que le service DNS est installé :
   - Ouvrez le Gestionnaire de serveur
   - Vérifiez que le rôle "Serveur DNS" est installé
   - Si ce n'est pas le cas, installez-le via "Ajouter des rôles et fonctionnalités"

5. Vérifiez les paramètres réseau avancés :
   - Assurez-vous que le serveur DNS principal pointe vers lui-même (`127.0.0.1` ou `192.168.0.2`)
   - Ouvrez les propriétés TCP/IPv4 de votre carte réseau et vérifiez les paramètres

</details>

### Exercice 1.2 : Configuration du pare-feu Windows

**Objectif :** Configurer le pare-feu Windows pour permettre le trafic AD DS.

<details>
<summary>📝 Instructions</summary>

1. Ouvrez le "Pare-feu Windows Defender avec fonctions avancées de sécurité" :
   - Recherchez "pare-feu" dans le menu Démarrer
   - Sélectionnez "Pare-feu Windows Defender avec fonctions avancées de sécurité"

2. Vérifiez les règles de trafic entrant pour Active Directory :
   - Cliquez sur "Règles de trafic entrant" dans le panneau de gauche
   - Recherchez les règles liées à "Active Directory" et "DNS"
   - Assurez-vous que ces règles sont activées (colonne "Activé" = "Oui")

3. Si nécessaire, activez les règles de groupe prédéfinies pour AD DS :
   - Faites un clic droit sur chaque règle désactivée liée à AD DS
   - Sélectionnez "Activer la règle"

4. Vérifiez que les ports suivants sont ouverts :
   - TCP/UDP 53 (DNS)
   - TCP/UDP 88 (Kerberos)
   - TCP/UDP 389 (LDAP)
   - TCP 445 (SMB)
   - TCP/UDP 135 (RPC)
   - TCP 3268-3269 (LDAP GC)

5. Pour simplifier le test initial, vous pouvez temporairement désactiver le pare-feu pour le profil de domaine :
   - Dans le panneau de gauche, cliquez sur "Propriétés du Pare-feu Windows Defender"
   - Dans l'onglet "Profil de domaine", définissez "État du pare-feu" sur "Désactivé"
   - Cliquez sur "Appliquer" puis "OK"
   - **Note :** Cette étape est temporaire et uniquement pour le test initial. Dans un environnement de production, le pare-feu doit rester activé.

</details>

## 2. 🔹 Installation et configuration d'AD DS

### Exercice 2.1 : Installation du rôle AD DS

**Objectif :** Installer le rôle Active Directory Domain Services sur le serveur.

<details>
<summary>📝 Instructions</summary>

1. Ouvrez le Gestionnaire de serveur si ce n'est pas déjà fait.

2. Cliquez sur "Gérer" puis "Ajouter des rôles et fonctionnalités".

3. Dans l'Assistant d'ajout de rôles et fonctionnalités :
   - Cliquez sur "Suivant" jusqu'à la page "Sélectionner des rôles de serveurs"
   - Cochez la case "Services de domaine Active Directory"
   - Une fenêtre s'affiche pour vous demander d'ajouter les fonctionnalités requises, cliquez sur "Ajouter des fonctionnalités"
   - Cliquez sur "Suivant" jusqu'à la page de confirmation
   - Cochez la case "Redémarrer automatiquement le serveur de destination si nécessaire"
   - Cliquez sur "Installer"

4. Attendez que l'installation se termine.

5. Une fois l'installation terminée, notez la notification dans le Gestionnaire de serveur indiquant que la configuration post-déploiement est requise.

</details>

### Exercice 2.2 : Promotion du serveur en contrôleur de domaine

**Objectif :** Promouvoir le serveur en contrôleur de domaine et créer une nouvelle forêt.

<details>
<summary>📝 Instructions</summary>

1. Dans le Gestionnaire de serveur, cliquez sur le drapeau de notification, puis sur "Promouvoir ce serveur en contrôleur de domaine".

2. Dans l'Assistant de configuration des services de domaine Active Directory :
   - Sélectionnez "Ajouter une nouvelle forêt"
   - Dans "Nom de domaine racine", entrez `computerelectronics.be`
   - Cliquez sur "Suivant"

3. Dans la page "Options du contrôleur de domaine" :
   - Sélectionnez le niveau fonctionnel de la forêt et du domaine : "Windows Server 2016"
   - Assurez-vous que les options "Serveur DNS" et "Catalogue global" sont cochées
   - Entrez un mot de passe DSRM (Directory Services Restore Mode) : `Password1!`
   - Cliquez sur "Suivant"

4. Dans la page "Options DNS", cliquez sur "Suivant" (acceptez les avertissements éventuels).

5. Dans la page "Options supplémentaires" :
   - Le nom NetBIOS du domaine sera automatiquement rempli (COMPUTERELEC)
   - Cliquez sur "Suivant"

6. Dans la page "Chemins d'accès", conservez les emplacements par défaut et cliquez sur "Suivant".

7. Dans la page "Vérification des prérequis" :
   - Examinez les avertissements (les avertissements concernant DNS sont normaux)
   - Cliquez sur "Installer"

8. Le serveur redémarrera automatiquement après l'installation.

9. Après le redémarrage, connectez-vous avec le compte administrateur du domaine :
   - Nom d'utilisateur : `COMPUTERELEC\Administrator`
   - Mot de passe : le mot de passe que vous avez défini précédemment

</details>

### Exercice 2.3 : Vérification de l'installation d'AD DS

**Objectif :** Vérifier que l'installation d'AD DS s'est correctement déroulée.

<details>
<summary>📝 Instructions</summary>

1. Après vous être connecté en tant qu'administrateur du domaine, ouvrez le Gestionnaire de serveur.

2. Vérifiez que le rôle "AD DS" est maintenant affiché dans le tableau de bord.

3. Ouvrez la console "Utilisateurs et ordinateurs Active Directory" :
   - Dans le Gestionnaire de serveur, cliquez sur "Outils"
   - Sélectionnez "Utilisateurs et ordinateurs Active Directory"

4. Explorez la structure par défaut du domaine :
   - Développez le domaine `computerelectronics.be`
   - Examinez les conteneurs par défaut : Builtin, Computers, Domain Controllers, Users, etc.
   - Vérifiez que votre serveur apparaît dans le dossier "Domain Controllers"

5. Vérifiez les zones DNS créées automatiquement :
   - Dans le Gestionnaire de serveur, cliquez sur "Outils" puis "DNS"
   - Développez votre serveur DNS, puis "Zones de recherche directe"
   - Vérifiez que les zones suivantes ont été créées :
     * `computerelectronics.be`
     * `_msdcs.computerelectronics.be`
   - Développez "Zones de recherche inversée" et vérifiez que la zone inverse pour votre réseau a été créée

6. Vérifiez les enregistrements SRV dans la zone DNS :
   - Dans la zone `computerelectronics.be`, recherchez les dossiers `_tcp` et `_udp`
   - Vérifiez la présence d'enregistrements SRV pour les services AD comme `_kerberos`, `_ldap`, etc.

</details>
