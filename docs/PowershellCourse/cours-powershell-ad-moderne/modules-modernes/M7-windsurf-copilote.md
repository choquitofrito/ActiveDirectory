# Module 7: Windsurf comme Copilote — Écrire des Scripts avec l'IA ⚗️

> **⚗️ MODULE EXPÉRIMENTAL** — Ce module utilise Windsurf IDE (gratuit) comme assistant de codage.
> Les quotas et modèles disponibles peuvent changer. Si le chat IA n'est plus disponible,
> les exercices restent valables avec Google ou ChatGPT comme alternative.

*Durée: 1h30 | Prérequis: Modules 1-6 complétés | Lab Maxtec installé et Patch-UserDepartments.ps1 exécuté*

---

## 🎯 Objectif de ce Module

**À la fin**: Vous saurez utiliser un assistant IA pour construire des scripts PowerShell pas à pas, en comprenant chaque ligne — pas en copiant aveuglément.

---

## 🔥 La Règle du Module

```
❌ INTERDIT: Copier-coller un script sans lire
✅ OBLIGATOIRE: Comprendre chaque ligne avant d'exécuter

L'IA est votre pair de programmation, pas votre secrétaire.
```

---

## 🛠️ Configuration de Windsurf

### Avant de commencer

1. Créez un compte gratuit sur [windsurf.com](https://windsurf.com)
2. Installez Windsurf IDE
3. Ouvrez un nouveau fichier `.ps1`
4. Le chat IA s'ouvre avec `Ctrl+L` (Cascade)

### Comment utiliser le chat efficacement

```
✅ BON prompt:
"Je travaille sur le domaine maxtec.be avec PowerShell.
J'ai des utilisateurs dans les OUs RH, Ventes, Comptabilite et IT.
Je veux lister tous les utilisateurs du département RH avec leur statut
Enabled. Explique chaque ligne."

❌ MAUVAIS prompt:
"Écris-moi un script PowerShell AD"
```

**Règle d'or**: donnez contexte (maxtec.be), objectif précis, et demandez toujours une explication.

---

## 💻 Exercice 7.1 — Premiers Pas: Qui est dans RH ?

**Niveau**: Débutant | **Durée**: 15 min

### La Situation

Vous êtes nouvel admin chez Maxtec. Votre responsable vous demande:
> *"Envoie-moi la liste des comptes RH — je veux savoir lesquels sont actifs."*

### Votre Mission

Utilisez Windsurf pour construire ce script. Ne tapez pas le code vous-même.

**Prompt suggéré pour Windsurf:**
```
Je travaille sur le domaine maxtec.be. Les utilisateurs RH sont dans
OU=Users,OU=RH,OU=EU,DC=maxtec,DC=be et ont Department = "RH".
Je veux un script qui liste tous les utilisateurs RH avec leur nom,
SamAccountName et statut Enabled. Explique chaque ligne du script.
```

### Ce que vous devez faire AVANT d'exécuter

Pour chaque ligne du script généré, répondez:

1. **Qu'est-ce que cette ligne fait?**
2. **Si je la supprime, qu'est-ce qui change?**
3. **Quel paramètre puis-je modifier pour changer le résultat?**

### Résultat attendu

```
Name      SamAccountName  Enabled
----      --------------  -------
Richard   richard         True
Rebecca   rebecca         True
Rene      rene            True
```

### Point de Discussion

> Le script utilise `-Filter {Department -eq "RH"}` ou `-SearchBase`?
> Demandez à Windsurf: *"Quelle méthode est plus fiable et pourquoi?"*

---

## 💻 Exercice 7.2 — Ticket Réel: Compte Bloqué

**Niveau**: Débutant-Intermédiaire | **Durée**: 20 min

### La Situation

Ticket entrant:
> *"Bonjour, je suis Vanessa du département Ventes. Je n'arrive plus à me connecter depuis ce matin. Mon compte est peut-être bloqué?"*

### Votre Mission en Deux Temps

**Temps 1 — Diagnostic (avec Windsurf)**

Prompt:
```
Sur maxtec.be, je dois vérifier si l'utilisateur "vanessa" est bloqué.
Je veux voir: LockedOut, BadPwdCount, LastBadPasswordAttempt et Enabled.
Donne-moi le script avec explication de chaque paramètre -Properties.
```

**Temps 2 — Résolution (avec Windsurf)**

Prompt:
```
Le compte vanessa est bloqué (LockedOut = True). Écris le script pour
le débloquer sans réinitialiser son mot de passe. Explique la différence
entre Unlock-ADAccount et Set-ADAccountPassword.
```

### Validation Obligatoire

Avant d'exécuter la résolution:

```powershell
# Vérifiez avec -WhatIf si la commande l'accepte, sinon simulez manuellement:
Get-ADUser -Identity vanessa -Properties LockedOut | Select-Object Name, LockedOut
```

Comparez avant/après.

### Question de Réflexion

> L'IA a-t-elle proposé `-WhatIf` spontanément?
> Si non, demandez-lui: *"Comment tester cette commande sans risque avant de l'exécuter?"*

---

## 💻 Exercice 7.3 — Rapport de Département

**Niveau**: Intermédiaire | **Durée**: 25 min

### La Situation

Votre responsable veut un rapport mensuel:
> *"Chaque mois je veux voir par département: combien d'utilisateurs actifs,
> combien de désactivés, et la date de dernière connexion la plus récente."*

### Votre Mission

**Étape 1 — Construire avec Windsurf:**

Prompt:
```
Sur maxtec.be, je veux un script qui génère un rapport par département
(RH, Ventes, Comptabilite, IT). Pour chaque département: nombre
d'utilisateurs actifs, nombre désactivés, et date LastLogonDate la plus
récente. Les utilisateurs sont dans OU=EU,DC=maxtec,DC=be.
Utilise -Properties Department, Enabled, LastLogonDate.
Explique pourquoi LastLogonDate peut être vide ou incorrect.
```

**Étape 2 — Comprendre la réponse:**

L'IA vous expliquera probablement pourquoi `LastLogonDate` est peu fiable
(ne se réplique pas entre DCs en temps réel). Demandez-lui:

```
Quelle propriété est plus fiable que LastLogonDate pour savoir
quand un utilisateur s'est connecté pour la dernière fois?
```

**Étape 3 — Modifier le script:**

Adaptez le script pour utiliser la propriété recommandée par l'IA.

### Ce Qu'on Apprend Ici

Ce n'est pas juste un exercice technique — c'est un exemple de comment
l'IA peut enseigner des nuances que la documentation officielle noie
dans du jargon.

---

## 💻 Exercice 7.4 — Onboarding: Nouveau Collègue

**Niveau**: Intermédiaire-Avancé | **Durée**: 25 min

### La Situation

Email de RH:
> *"Nouvelle arrivée lundi: Sophie Renard, département Ventes.
> Merci de créer son compte et de l'ajouter aux groupes standards."*

### Votre Mission

**Étape 1 — Demandez les paramètres à l'IA:**

Prompt:
```
Sur maxtec.be, je dois créer un utilisateur pour le département Ventes.
Structure OU: OU=Users,OU=Ventes,OU=EU,DC=maxtec,DC=be.
Groupe à ajouter: GG-EU-Ventes-Users.
Prénom: Sophie, Nom: Renard, Email: sophie.renard@maxtec.be.
Crée un script avec -WhatIf d'abord, puis la version réelle.
Explique les paramètres ChangePasswordAtLogon et AccountPassword.
```

**Étape 2 — Identifiez les risques:**

Avant d'exécuter, posez cette question à l'IA:
```
Quels problèmes peut-il y avoir si j'exécute ce script deux fois?
Comment le rendre idempotent?
```

**Étape 3 — Exécutez en deux phases:**

```powershell
# Phase 1: simulation
.\onboarding-sophie.ps1 -WhatIf   # si le script accepte -WhatIf

# Phase 2: vérification manuelle de la commande critique
Get-ADUser -Filter "SamAccountName -eq 'sophie.renard'" -ErrorAction SilentlyContinue

# Phase 3: exécution réelle seulement si Phase 1 et 2 OK
```

### Critère de Réussite

```powershell
# Ce script doit retourner les bonnes valeurs:
Get-ADUser -Identity "sophie.renard" -Properties Department, MemberOf |
    Select-Object Name, Department, @{N="Groupes";E={($_.MemberOf | Get-ADGroup).Name}}
```

---

## 💻 Exercice 7.5 — Audit de Sécurité: Mots de Passe

**Niveau**: Avancé | **Durée**: 20 min

### La Situation

Audit trimestriel obligatoire:
> *"Identifiez tous les comptes dont le mot de passe n'a pas changé
> depuis plus de 90 jours et les comptes avec PasswordNeverExpires."*

### Votre Mission

**Prompt initial:**
```
Sur maxtec.be, je dois faire un audit de sécurité sur les mots de passe.
Je veux deux listes:
1. Comptes avec PasswordLastSet il y a plus de 90 jours
2. Comptes avec PasswordNeverExpires = True
Génère le script avec explication. Inclus -WhatIf sur toute action.
```

**Après avoir reçu le script, demandez:**
```
Ce script génère un rapport. Comment l'exporter en CSV proprement,
avec un nom de fichier qui inclut la date d'aujourd'hui automatiquement?
```

**Puis:**
```
Y a-t-il des comptes système ou de service qu'on devrait exclure
de cet audit? Comment les identifier dans AD?
```

### Réflexion Finale

Comparez le script final avec celui que l'IA a généré au départ.
Combien d'améliorations avez-vous obtenues en posant des questions
de suivi?

> C'est exactement comme ça que les admins expérimentés travaillent:
> ils savent quoi demander, pas forcément comment l'écrire.

---

## 🎓 Récapitulatif: Ce que vous avez appris

```
✅ Formuler des prompts précis avec contexte AD
✅ Lire et valider du code généré avant de l'exécuter
✅ Poser des questions de suivi pour améliorer un script
✅ Identifier les risques que l'IA ne mentionne pas spontanément
✅ Comprendre pourquoi -WhatIf est non-négociable
```

### 🤔 La Question Clé

> Si Windsurf n'est plus disponible demain,
> êtes-vous capable de retrouver ces scripts vous-même avec Google?

Si la réponse est oui, ce module a atteint son objectif.

---

## 🔧 Si le Chat IA ne Répond Plus (Quota Épuisé)

Le tier gratuit de Windsurf a une quota journalière. Si vous atteignez la limite:

1. **L'autocompletado Tab reste disponible** — tapez les premières lettres d'un cmdlet, Windsurf complète
2. **Utilisez ChatGPT ou Claude** avec les mêmes prompts — la logique est identique
3. **Référence rapide**: `scripts/Patch-UserDepartments.ps1` montre la structure type d'un script Maxtec

---

*🎯 **Fin du cours PowerShell Moderne** — Vous avez maintenant les outils pour survivre et progresser dans n'importe quel environnement AD réel.*
