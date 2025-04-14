# Exercices de Dépannage GPO - Scénarios Service Desk

> 📝 **Environnement de Lab**:
> - DC Principal: dns1.computerelectronics.be
> - Postes Clients:
>   * ws-RH-01.computerelectronics.be
>   * ws-IT-01.computerelectronics.be

## 1. 🔹 "Impossible d'accéder aux dossiers RH !"

**Contexte**: Marie (marie.dupont) du service RH signale qu'elle ne peut plus accéder au dossier `\dns1\Shares\RH` depuis son poste ws-RH-01.

**État Initial à Créer**:
1. Créez un dossier `C:\Shares\RH` sur dns1
2. Partagez-le avec les permissions suivantes:
   - Partage: Tout le monde (Lecture)
   - NTFS: 
     * SYSTEM (Contrôle total)
     * Administrateurs (Contrôle total)
     * GG-RH-Users (Lecture)
3. Créez une GPO nommée `GPO-RH-Folders` avec:
   - Mappage du lecteur incorrect (utilisez Z: au lieu de R:)
   - Mauvais chemin UNC (`\dns1\Share\RH` au lieu de `\dns1\Shares\RH`)

**Tâche**: Un stagiaire helpdesk a créé cette configuration. Trouvez et corrigez les erreurs.

**Solution**:
<details>
<summary>Cliquez pour voir la solution</summary>

1. Vérifiez l'application des GPOs:
   ```
   gpresult /r /scope user /user marie.dupont
   ```

2. Dans la console GPMC:
   - Ouvrez la GPO `GPO-RH-Folders`
   - Allez dans "Configuration utilisateur > Préférences > Mappages de lecteurs"
   - Corrigez:
     * Lettre de lecteur: R:
     * Chemin: `\dns1\Shares\RH`
     * Action: Remplacer

3. Vérifiez les permissions NTFS:
   ```
   icacls "C:\Shares\RH"
   ```

4. Testez:
   ```
   gpupdate /force
   ```
</details>

## 2. 🔹 "La configuration de sécurité bloque tout !"

**Contexte**: Thomas (thomas.martin) de l'équipe IT ne peut plus utiliser certains outils d'administration sur ws-IT-01.

**État Initial à Créer**:
1. Créez une GPO nommée `GPO-IT-Security` liée à l'OU IT
2. Configurez des paramètres trop restrictifs:
   - Désactivez l'accès à cmd.exe
   - Désactivez l'accès à regedit.exe
   - Désactivez le Gestionnaire des tâches

**Tâche**: Identifiez les paramètres trop restrictifs et ajustez-les pour l'équipe IT.

**Solution**:
<details>
<summary>Cliquez pour voir la solution</summary>

1. Analysez la GPO:
   ```
   gpresult /h C:\rapport.html
   ```

2. Dans la console GPMC:
   - Ouvrez `GPO-IT-Security`
   - Allez dans "Configuration utilisateur > Stratégies > Modèles d'administration > Système"
   - Modifiez:
     * "Empêcher l'accès à l'invite de commandes" -> Non configuré
     * "Empêcher l'accès aux outils d'édition du Registre" -> Non configuré
     * "Empêcher l'accès au Gestionnaire des tâches" -> Non configuré

3. Créez un groupe de sécurité `GG-IT-AdminTools` et ajoutez-y Thomas
4. Appliquez un filtrage WMI à la GPO pour exclure ce groupe

5. Testez:
   ```
   gpupdate /force
   ```
</details>

## 3. 🔹 "Les raccourcis sont en double !"

**Contexte**: Les utilisateurs RH signalent des raccourcis en double sur leur bureau.

**État Initial à Créer**:
1. Créez deux GPOs qui créent les mêmes raccourcis:
   - `GPO-RH-Shortcuts` liée à l'OU RH
   - `GPO-ALL-Shortcuts` liée au niveau du domaine

**Tâche**: Résolvez le conflit de GPOs.

**Solution**:
<details>
<summary>Cliquez pour voir la solution</summary>

1. Identifiez les GPOs en conflit:
   ```
   gpresult /r /scope user
   ```

2. Dans la console GPMC:
   - Vérifiez l'ordre de traitement (plus petit numéro = priorité plus élevée)
   - Pour `GPO-RH-Shortcuts`:
     * Définissez une priorité d'application plus élevée
     * Ou utilisez l'option "Appliquer" dans les options de liaison

3. Alternative:
   - Modifiez les paramètres de `GPO-ALL-Shortcuts` pour exclure l'OU RH
   - Utilisez le filtrage de sécurité pour éviter le conflit

4. Vérifiez:
   ```
   gpupdate /force
   ```
</details>

> ⚠️ **Important**: Après chaque exercice, n'oubliez pas de :
> 1. Documenter les changements effectués
> 2. Tester avec les utilisateurs concernés
> 3. Vérifier qu'aucun autre service n'est impacté
