# Laboratoire : Test de basculement entre contrôleurs de domaine

## 1. 🔹 Objectif du laboratoire

Ce laboratoire vous permettra de tester la haute disponibilité d'Active Directory en simulant une panne du contrôleur de domaine principal et en vérifiant que le contrôleur de domaine secondaire prend correctement le relais.

## 2. 🔹 Prérequis

- Domaine Active Directory : maxtec.be
- Contrôleur de domaine principal : dns1.maxtec.be (192.168.0.2)
- Contrôleur de domaine secondaire : dns2.maxtec.be (192.168.0.3)
- Au moins un poste client joint au domaine : ws-client-01.maxtec.be

## 3. 🔹 Vérification de l'infrastructure

Avant de commencer les tests, vérifiez que votre infrastructure est correctement configurée :

1. **Vérifiez que les deux contrôleurs de domaine sont opérationnels**
   - Sur chaque contrôleur, ouvrez une invite de commande et exécutez :
   ```
   dcdiag /v
   ```
   - Vérifiez qu'il n'y a pas d'erreurs critiques

2. **Vérifiez la réplication entre les contrôleurs**
   - Sur le contrôleur principal, exécutez :
   ```
   repadmin /showrepl
   ```
   - Assurez-vous que toutes les réplications sont réussies

3. **Vérifiez les rôles FSMO**
   - Sur l'un des contrôleurs, ouvrez une invite PowerShell et exécutez :
   ```powershell
   Get-ADDomainController -Filter * | Select-Object Name, Domain, Forest, OperationMasterRoles
   ```
   - Notez quel contrôleur détient quels rôles FSMO

## 4. 🔹 Test 1 : Authentification après arrêt du contrôleur principal

### Étape 1 : Vérifier le comportement normal

1. Sur le poste client, ouvrez une invite de commande et exécutez :
   ```
   nltest /dsgetdc:maxtec.be
   ```
   - Notez quel contrôleur de domaine répond à la requête

2. Déconnectez-vous puis reconnectez-vous au domaine pour vérifier que l'authentification fonctionne normalement.

### Étape 2 : Simuler une panne du contrôleur principal

1. Sur le contrôleur principal (dns1.maxtec.be), ouvrez le Gestionnaire de serveur.
2. Cliquez sur **Outils** > **Services**.
3. Arrêtez les services suivants dans cet ordre :
   - Service DNS (DNS Server)
   - Service Kerberos Key Distribution Center
   - Service Intersite Messaging
   - Service NetLogon
   - Service Active Directory Domain Services

   > ⚠️ **Alternative** : Pour simuler une panne complète, vous pouvez simplement arrêter la machine virtuelle du contrôleur principal.

### Étape 3 : Vérifier le basculement

1. Sur le poste client, attendez environ 1 minute puis exécutez à nouveau :
   ```
   nltest /dsgetdc:maxtec.be
   ```
   - Vérifiez que le contrôleur secondaire (dns2) répond maintenant à la requête

2. Déconnectez-vous puis reconnectez-vous au domaine pour vérifier que l'authentification fonctionne toujours.

3. Testez la résolution DNS :
   ```
   nslookup dns2.maxtec.be
   ```

## 5. 🔹 Test 2 : Création d'objets pendant la panne

### Étape 1 : Créer un nouvel utilisateur

1. Sur le contrôleur secondaire (dns2.maxtec.be), ouvrez le Centre d'administration Active Directory.
2. Créez un nouvel utilisateur :
   - Prénom : Test
   - Nom : Basculement
   - Nom d'ouverture de session : test.basculement
   - Mot de passe : Password1!

### Étape 2 : Créer un nouveau groupe

1. Toujours sur le contrôleur secondaire, créez un nouveau groupe global de sécurité :
   - Nom : GG-Test-Basculement

### Étape 3 : Redémarrer le contrôleur principal

1. Redémarrez le contrôleur principal (dns1.maxtec.be) ou réactivez les services arrêtés précédemment.
2. Attendez environ 5 minutes pour que la réplication s'effectue.

### Étape 4 : Vérifier la réplication

1. Sur le contrôleur principal, ouvrez le Centre d'administration Active Directory.
2. Vérifiez que l'utilisateur et le groupe créés pendant la panne sont bien présents.
3. Vérifiez la réplication avec la commande :
   ```
   repadmin /showrepl
   ```

## 6. 🔹 Test 3 : Basculement des rôles FSMO

> 💡 **Note** : Ce test est optionnel et plus avancé. Il permet de vérifier le comportement du domaine lorsque les contrôleurs détenant les rôles FSMO sont indisponibles.

### Étape 1 : Identifier les rôles FSMO

1. Sur l'un des contrôleurs, exécutez :
   ```powershell
   Get-ADDomainController -Filter * | Select-Object Name, Domain, Forest, OperationMasterRoles
   ```

### Étape 2 : Tester l'impact de l'indisponibilité

1. Arrêtez le contrôleur qui détient la majorité des rôles FSMO.
2. Essayez de réaliser les opérations suivantes sur l'autre contrôleur :
   - Créer un nouvel utilisateur
   - Modifier le schéma (si vous avez le rôle Schema Master)
   - Ajouter un nouveau contrôleur de domaine (si vous avez le rôle Infrastructure Master)

### Étape 3 : Transférer les rôles FSMO

Si nécessaire, vous pouvez transférer les rôles FSMO vers le contrôleur disponible :

1. Sur le contrôleur disponible, ouvrez PowerShell en tant qu'administrateur.
2. Pour transférer tous les rôles du domaine :
   ```powershell
   Move-ADDirectoryServerOperationMasterRole -Identity "dns2" -OperationMasterRole PDCEmulator,RIDMaster,InfrastructureMaster
   ```
3. Pour transférer les rôles de la forêt :
   ```powershell
   Move-ADDirectoryServerOperationMasterRole -Identity "dns2" -OperationMasterRole SchemaMaster,DomainNamingMaster
   ```

## 7. 🔹 Nettoyage du laboratoire

Une fois les tests terminés, assurez-vous que :

1. Les deux contrôleurs de domaine sont opérationnels.
2. Les services sont correctement démarrés sur les deux contrôleurs.
3. La réplication fonctionne correctement.
4. Les rôles FSMO sont attribués aux contrôleurs appropriés.

## 8. 🔹 Observations et conclusion

Dans ce laboratoire, vous avez pu observer :

1. **La haute disponibilité d'Active Directory** : Le domaine continue de fonctionner même si un contrôleur est indisponible.
2. **Le mécanisme de basculement automatique** : Les clients se connectent automatiquement au contrôleur disponible.
3. **La réplication multi-maître** : Les modifications effectuées sur un contrôleur sont répliquées vers les autres.
4. **L'importance des rôles FSMO** : Certaines opérations nécessitent des rôles FSMO spécifiques.

Cette expérience démontre l'importance d'avoir au moins deux contrôleurs de domaine dans un environnement de production pour assurer la continuité du service.

## 9. 🔹 Pour aller plus loin

- Testez la récupération après une panne prolongée (plus de 60 jours)
- Configurez la réplication entre sites AD
- Mettez en place une surveillance des contrôleurs de domaine
- Testez la restauration d'un contrôleur de domaine à partir d'une sauvegarde
