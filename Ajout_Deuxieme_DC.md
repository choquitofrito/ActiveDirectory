# Ajout d'un Deuxième Contrôleur de Domaine pour Redondance et Équilibrage de Charge

## 1. 🔹 Introduction

L'ajout d'un deuxième contrôleur de domaine (DC) dans votre infrastructure Active Directory offre plusieurs avantages essentiels :

- **Haute disponibilité** : Si un contrôleur tombe en panne, le second continue à fournir les services d'authentification
- **Équilibrage de charge** : Distribution des requêtes entre plusieurs serveurs
- **Redondance des données** : Réplication automatique des données entre les contrôleurs
- **Tolérance aux pannes** : Maintien des services même en cas de défaillance d'un serveur

Dans ce document, nous allons voir comment ajouter un second contrôleur de domaine à votre infrastructure existante basée sur maxtec.be.

## 2. 🔹 Prérequis

Avant de commencer, assurez-vous de disposer des éléments suivants :

- Un serveur Windows Server (2016, 2019 ou 2022) installé avec :
  - Au moins 4 Go de RAM
  - 50 Go d'espace disque minimum
  - Une adresse IP statique dans le même réseau que votre DC principal
- Un compte administrateur du domaine
- Une connexion réseau stable entre les deux serveurs
- Le premier contrôleur de domaine (dns.maxtec.be) fonctionnel et accessible

## 3. 🔹 Planification

### Configuration réseau recommandée

| Serveur | Nom d'hôte | Adresse IP | Rôle |
|---------|------------|------------|------|
| DC1 (existant) | dns.maxtec.be | 192.168.0.2 | Contrôleur de domaine principal |
| DC2 (nouveau) | dns2.maxtec.be | 192.168.0.3 | Contrôleur de domaine secondaire |

### Points importants à considérer

- **Placement** : Idéalement, placez le second DC dans un emplacement physique différent du premier
- **Rôles FSMO** : Les rôles FSMO resteront sur le DC principal dans un premier temps
- **Réplication** : Configurez une planification de réplication adaptée à votre environnement
- **Sauvegarde** : Mettez en place une stratégie de sauvegarde pour les deux contrôleurs

## 4. 🔹 Procédure d'installation

### Étape 1 : Préparation du serveur

1. Installez Windows Server sur le nouveau serveur
2. Configurez l'adresse IP statique (ex: 192.168.0.3)
3. Définissez le nom du serveur (ex: dns2)
4. Configurez le serveur DNS pour pointer vers votre DC existant (192.168.0.2)

### Étape 2 : Joindre le serveur au domaine

1. Ouvrez les **Propriétés système** (clic droit sur **Ce PC** > **Propriétés**)
2. Cliquez sur **Modifier les paramètres** dans la section **Nom de l'ordinateur**
3. Dans l'onglet **Nom de l'ordinateur**, cliquez sur **Modifier**
4. Sélectionnez **Domaine** et entrez `maxtec.be`
5. Entrez les identifiants d'un compte administrateur du domaine
6. Redémarrez le serveur lorsque vous y êtes invité

### Étape 3 : Installation du rôle AD DS

1. Ouvrez le **Gestionnaire de serveur**
2. Cliquez sur **Gérer** > **Ajouter des rôles et fonctionnalités**
3. Suivez l'assistant jusqu'à la page **Rôles de serveurs**
4. Cochez **Services de domaine Active Directory**
5. Ajoutez les fonctionnalités requises lorsque vous y êtes invité
6. Continuez avec les valeurs par défaut jusqu'à la fin de l'assistant
7. Cliquez sur **Installer**

### Étape 4 : Promotion en contrôleur de domaine

1. Une fois l'installation terminée, cliquez sur le drapeau de notification
2. Cliquez sur **Promouvoir ce serveur en contrôleur de domaine**
3. Sélectionnez **Ajouter un contrôleur de domaine à un domaine existant**
4. Entrez le nom du domaine : `maxtec.be`
5. Entrez les identifiants d'un compte administrateur du domaine
6. Dans la page **Options du contrôleur de domaine** :
   - Cochez **Serveur DNS** et **Catalogue global** si nécessaire
   - Définissez un mot de passe de restauration des services d'annuaire (DSRM)
7. Pour l'emplacement de la base de données, vous pouvez conserver les chemins par défaut ou les personnaliser
8. Dans la page **Options de réplication** :
   - Sélectionnez **À partir de n'importe quel contrôleur de domaine**
   - Pour un petit réseau, cette option est généralement la plus simple
9. Continuez avec les vérifications préalables
10. Si les vérifications réussissent, cliquez sur **Installer**

Le serveur redémarrera automatiquement après l'installation.

## 5. 🔹 Vérification de l'installation

Après le redémarrage, vérifiez que le nouveau contrôleur de domaine fonctionne correctement :

1. Connectez-vous avec un compte administrateur du domaine
2. Ouvrez la **Console de gestion des stratégies de groupe** (gpmc.msc)
3. Vérifiez que vous pouvez voir et gérer les objets de stratégie de groupe
4. Ouvrez **Utilisateurs et ordinateurs Active Directory** (dsa.msc)
5. Vérifiez que vous pouvez voir et gérer les objets du domaine
6. Ouvrez **Sites et services Active Directory** (dssite.msc)
7. Vérifiez que le nouveau contrôleur apparaît dans le bon site

### Test de réplication

Pour vérifier que la réplication fonctionne correctement entre les deux contrôleurs :

1. Sur le nouveau DC, ouvrez une invite de commandes en tant qu'administrateur
2. Exécutez la commande : `repadmin /replsummary`
3. Vérifiez qu'il n'y a pas d'erreurs de réplication

## 6. 🔹 Configuration post-installation

### Configuration DNS

Pour une redondance DNS complète :

1. Sur chaque serveur, ouvrez le **Gestionnaire DNS**
2. Configurez les serveurs DNS pour qu'ils se référencent mutuellement :
   - DC1 (dns.maxtec.be) : DNS primaire = 127.0.0.1, DNS secondaire = 192.168.0.3
   - DC2 (dns2.maxtec.be) : DNS primaire = 127.0.0.1, DNS secondaire = 192.168.0.2

### Configuration des transferts de zone DNS

1. Sur le DC principal, ouvrez le **Gestionnaire DNS**
2. Faites un clic droit sur le serveur DNS et sélectionnez **Propriétés**
3. Allez à l'onglet **Transferts de zone**
4. Cochez **Autoriser les transferts de zone**
5. Sélectionnez **Uniquement vers les serveurs DNS suivants**
6. Ajoutez l'adresse IP du second contrôleur (192.168.0.3)

### Équilibrage de charge des clients

Pour distribuer la charge d'authentification :

1. Sur chaque poste client, configurez les serveurs DNS dans cet ordre :
   - DNS primaire : Le contrôleur le plus proche ou le moins chargé
   - DNS secondaire : L'autre contrôleur de domaine

## 7. 🔹 Considérations de sécurité

- **Pare-feu** : Assurez-vous que les ports nécessaires sont ouverts entre les contrôleurs de domaine
  - TCP/UDP 53 : DNS
  - TCP/UDP 88 : Kerberos
  - TCP/UDP 389 : LDAP
  - TCP 445 : SMB
  - TCP/UDP 135 : RPC
  - TCP 3268-3269 : Catalogue global
  - TCP/UDP 464 : Kerberos change/set password

- **Sauvegardes** : Mettez en place une stratégie de sauvegarde régulière pour les deux contrôleurs

- **Surveillance** : Configurez des alertes pour être informé des problèmes de réplication ou de disponibilité

## 8. 🔹 Bonnes pratiques

- **Rôles FSMO** : Envisagez de répartir les rôles FSMO entre les deux contrôleurs pour une meilleure résilience
- **Sites AD** : Si les contrôleurs sont dans des sites physiques différents, configurez correctement les sites AD pour optimiser la réplication
- **Maintenance** : Planifiez les mises à jour et les redémarrages de manière à ce qu'un seul contrôleur soit hors ligne à la fois
- **Documentation** : Documentez votre infrastructure, y compris les adresses IP, les noms d'hôtes et les rôles de chaque serveur

## 9. 🔹 Dépannage courant

### Problèmes de réplication

Si vous rencontrez des problèmes de réplication :

1. Vérifiez la connectivité réseau entre les contrôleurs
2. Exécutez `dcdiag /v` pour diagnostiquer les problèmes
3. Utilisez `repadmin /showrepl` pour voir l'état détaillé de la réplication

### Problèmes DNS

Pour les problèmes liés au DNS :

1. Vérifiez que les enregistrements SRV sont correctement créés
2. Exécutez `dcdiag /test:dns` pour diagnostiquer les problèmes DNS
3. Vérifiez que les transferts de zone fonctionnent correctement

## 10. 🔹 Conclusion

L'ajout d'un deuxième contrôleur de domaine est une étape essentielle pour améliorer la disponibilité et la résilience de votre infrastructure Active Directory. En suivant les étapes décrites dans ce document, vous pouvez mettre en place une solution robuste qui protège votre entreprise contre les pannes de serveur et améliore les performances globales du système d'authentification.

Avec deux contrôleurs de domaine correctement configurés, vous bénéficiez d'une redondance qui garantit la continuité des services critiques d'authentification et d'autorisation, même en cas de défaillance d'un des serveurs.
