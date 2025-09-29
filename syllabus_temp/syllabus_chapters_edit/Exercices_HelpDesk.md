# Exercices de Dépannage AD - Scénarios Service Desk

> 📝 **Environnement de Lab**:
> - DC Principal: dns1.maxtec.be
> - Postes Clients:
>   * ws-compta-01.maxtec.be
>   * ws-rh-01.maxtec.be
>   * ws-ventes-01.maxtec.be

## 1. 🔹 "Mon mot de passe a expiré pendant mes congés !"

**Contexte**: Sophie (sophie.lambert) du service Comptabilité revient de 3 semaines de congés et ne peut plus se connecter à son poste ws-compta-01. Message d'erreur : "Votre mot de passe a expiré il y a 5 jours".

**État Initial à Créer**:
1. Créez un utilisateur `sophie.lambert`
2. Définissez une date d'expiration du mot de passe à 30 jours
3. Modifiez la date de dernier changement de mot de passe à il y a 35 jours

**Tâche**: 
1. Vérifiez la politique de mot de passe actuelle
2. Réinitialisez le mot de passe de Sophie
3. Expliquez comment éviter ce problème à l'avenir

**Solution**:
<details>
<summary>Cliquez pour voir la solution</summary>

1. Vérifiez la politique de mot de passe:
   ```
   net accounts
   ```

2. Dans "Utilisateurs et ordinateurs Active Directory":
   - Trouvez l'utilisateur sophie.lambert
   - Clic droit > Réinitialiser le mot de passe
   - Nouveau mot de passe: "Password1!"
   - Cochez "L'utilisateur doit changer le mot de passe à la prochaine ouverture de session"

3. Pour éviter ce problème:
   - Créez une GPO `GPO-PasswordPolicy` avec:
     * Durée de validité du mot de passe: 90 jours
     * Notification de changement: 14 jours avant expiration
   - Documentez la procédure pour les congés longs
</details>

## 2. 🔹 "Je ne vois plus mes fichiers partagés !"

**Contexte**: Pierre (pierre.dubois) des Ventes signale qu'il ne peut plus accéder au dossier `\\dns1\Shares\Ventes` depuis ce matin sur ws-ventes-01. Hier tout fonctionnait.

**État Initial à Créer**:
1. Créez le dossier partagé avec les permissions:
   - NTFS:
     * SYSTEM (Contrôle total)
     * Administrateurs (Contrôle total)
     * GG-Ventes-Users (Modification)
   - Partage:
     * GG-Ventes-Users (Contrôle total)
2. Ajoutez pierre.dubois au groupe GG-Ventes-Users
3. Simulez le problème en retirant temporairement pierre.dubois du groupe

**Tâche**: 
1. Vérifiez l'appartenance aux groupes de Pierre
2. Contrôlez les permissions effectives
3. Restaurez l'accès

**Solution**:
<details>
<summary>Cliquez pour voir la solution</summary>

1. Vérifiez les groupes:
   ```
   net user pierre.dubois /domain
   ```

2. Vérifiez les permissions effectives:
   ```
   icacls "\\dns1\Shares\Ventes"
   ```

3. Corrigez:
   - Ajoutez pierre.dubois au groupe GG-Ventes-Users
   - Faites-lui fermer/rouvrir sa session
   - Vérifiez l'accès

4. Documentez l'incident et la solution
</details>

## 3. 🔹 "Impossible d'installer l'imprimante du service !"

**Contexte**: Marie (marie.martin) des RH ne peut pas installer l'imprimante RH sur ws-rh-01. Message d'erreur : "Vous n'avez pas les droits suffisants pour installer une imprimante".

**État Initial à Créer**:
1. Créez une GPO `GPO-Printers-Restrictions` qui:
   - Empêche l'installation d'imprimantes
   - Est liée à l'OU RH
2. Créez le groupe GG-RH-PrinterAdmins

**Tâche**: 
1. Vérifiez les stratégies appliquées
2. Modifiez les restrictions pour permettre l'installation
3. Documentez la solution pour le futur

**Solution**:
<details>
<summary>Cliquez pour voir la solution</summary>

1. Analysez les GPOs:
   ```
   gpresult /r /scope user /user marie.martin
   ```

2. Dans la console GPMC:
   - Modifiez `GPO-Printers-Restrictions`
   - Ajoutez marie.martin au groupe GG-RH-PrinterAdmins
   - Configurez le filtrage de sécurité pour exclure GG-RH-PrinterAdmins

3. Appliquez les changements:
   ```
   gpupdate /force
   ```

4. Créez une documentation:
   - Procédure d'ajout d'utilisateurs au groupe
   - Liste des droits accordés
   - Processus de demande d'accès
</details>

## 4. 🔹 "Mon profil est corrompu !"

**Contexte**: Lucas (lucas.bernard) de la Comptabilité signale des erreurs à l'ouverture de session sur ws-compta-01 : "Impossible de charger votre profil".

**État Initial à Créer**:
1. Connectez-vous en tant que lucas.bernard
2. Créez quelques fichiers dans son profil
3. Déconnectez-vous
4. Corrompez le profil en modifiant la clé de registre ProfileImagePath

**Tâche**: 
1. Vérifiez l'état du profil
2. Créez un nouveau profil
3. Récupérez les données importantes

**Solution**:
<details>
<summary>Cliquez pour voir la solution</summary>

1. Vérifiez le profil:
   - Ouvrez l'Éditeur du Registre
   - Naviguez vers:
     ```
     HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList
     ```
   - Identifiez le SID corrompu

2. Sauvegardez les données:
   - Connectez-vous en administrateur
   - Copiez les données importantes:
     * Documents
     * Bureau
     * Favoris

3. Recréez le profil:
   - Renommez la clé de registre corrompue
   - Supprimez le dossier de profil corrompu
   - Faites se reconnecter l'utilisateur

4. Restaurez les données:
   - Copiez les données sauvegardées
   - Vérifiez les permissions
   - Testez l'accès
</details>

> ⚠️ **Important**: Pour chaque intervention :
> 1. Créez un ticket d'incident
> 2. Documentez la solution appliquée
> 3. Informez l'utilisateur des actions effectuées
> 4. Vérifiez que le problème est résolu
> 5. Mettez à jour la base de connaissances si nécessaire
