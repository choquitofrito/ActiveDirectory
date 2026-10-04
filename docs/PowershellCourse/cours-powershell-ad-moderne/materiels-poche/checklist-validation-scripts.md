# Checklist de validation des scripts PowerShell AD
*Format A4, à imprimer*

---

## Sécurité (obligatoire)

### Avant d'exécuter un script
- [ ] **Source fiable ?** (documentation Microsoft > Stack Overflow > forums)
- [ ] **`-WhatIf`** présent sur toutes les commandes qui modifient ?
- [ ] **Portée limitée** avec `-SearchBase` ou un `-Filter` précis ?
- [ ] **Gestion d'erreurs** (`try/catch` avec `-ErrorAction Stop`) ?
- [ ] **Variables vérifiées** (pas de `$null`, pas de faute de frappe) ?

### Commandes à haut risque
- [ ] **`Remove-*`** : `-WhatIf` + vérification de la portée + exclusion des comptes critiques
- [ ] **`Set-*` en masse** : `-WhatIf` + nombre d'objets limité
- [ ] **`Move-ADObject`** : chemin de destination vérifié
- [ ] **`-Recursive`** : contenu vérifié deux fois
- [ ] **`-Filter *`** : limité avec `-ResultSetSize` ou `-SearchBase`

---

## Adaptation à l'environnement

### maxtec.be
- [ ] **Domaine correct ?** `DC=maxtec,DC=be` (pas `contoso.com`)
- [ ] **Structure des OUs ?** `OU=EU,DC=maxtec,DC=be`
- [ ] **Noms de groupes ?** `GG-EU-*`
- [ ] **Utilisateurs de test ?** Richard, Irene, Ivan… (pas John, Jane)

### Paramètres
- [ ] **Chemins en dur** remplacés par des variables ?
- [ ] **Identifiants** protégés (pas de mot de passe en clair) ?
- [ ] **Dates** relatives plutôt qu'absolues ?
- [ ] **Logs** écrits dans le bon répertoire ?

---

## Logique métier

### Compréhension
- [ ] Chaque ligne du script est comprise ?
- [ ] L'objectif du script est clair ?
- [ ] **Cas limites** : que se passe-t-il si l'utilisateur n'existe pas, si le groupe est vide ?
- [ ] **Retour arrière** : comment annuler en cas d'erreur ?

### Tests progressifs
- [ ] **1 objet** d'abord (avec `-WhatIf`)
- [ ] **5 objets** ensuite
- [ ] **Résultat vérifié** avant de continuer
- [ ] **Logs relus** après chaque lot

---

## Signaux d'arrêt

Si l'un de ces points est présent, on n'exécute pas tant qu'il n'est pas corrigé.

### Dans le code
- [ ] Pas de `-WhatIf` sur un `Remove-*` ou un `Set-*` en masse
- [ ] `-Confirm:$false` sans validation préalable
- [ ] `Get-ADUser -Filter *` sans limitation
- [ ] Mot de passe en clair dans le script
- [ ] `catch` vide qui masque les erreurs

### Dans les commentaires et l'historique
- [ ] « TODO : tester » dans un script présenté comme prêt
- [ ] « Temporaire » dans un script utilisé en permanence
- [ ] Aucune gestion d'erreur prévue
- [ ] Source inconnue ou douteuse
- [ ] Dernière modification il y a plus de 6 mois, sans revalidation

---

## Tests à faire

### Phase 1 : simulation
```powershell
# Toujours commencer par :
[COMMANDE] -WhatIf
# Lire la sortie ligne par ligne
```

### Phase 2 : test réduit
```powershell
# Puis sur 1 à 3 objets maximum (-ResultSetSize existe sur les Get-AD*) :
Get-ADUser [FILTRE] -ResultSetSize 3 | [COMMANDE QUI MODIFIE]
# Vérifier le résultat avant de continuer
```

### Phase 3 : production par lots
```powershell
# Ensuite par lots de 10 maximum :
Get-ADUser [FILTRE] | Select-Object -First 10 | [COMMANDE QUI MODIFIE]
# Vérifier après chaque lot
```

---

## Documentation

### Avant l'exécution
- [ ] Date et heure prévues
- [ ] Objectif métier du script
- [ ] Nombre estimé d'objets affectés
- [ ] Plan de retour arrière

### Pendant l'exécution
- [ ] Logs activés et écrits dans un fichier
- [ ] Progression notée par lot
- [ ] Erreurs capturées et analysées
- [ ] Résultats intermédiaires vérifiés

### Après l'exécution
- [ ] Résultat final documenté
- [ ] Objets traités comptés et vérifiés
- [ ] Problèmes rencontrés listés
- [ ] Actions correctives appliquées

---

## En cas d'erreur grave

1. **Arrêter** — ne pas relancer ni « corriger » dans la foulée.
2. **Documenter** l'erreur exacte et la commande.
3. **Évaluer l'impact** (combien d'objets affectés ?).
4. **Prévenir le superviseur** si plus de 10 objets sont touchés.
5. **Ne pas réparer seul.**
6. **Attendre la validation** de l'équipe avant d'agir.

### Contacts maxtec.be
- **Admin principal** : irene@maxtec.be
- **Superviseur IT** : responsable.it@maxtec.be
- **Astreinte** : +32 4XX XX XX XX

---

## À retenir

1. `-WhatIf` n'est jamais optionnel pour une commande qui modifie.
2. En cas de doute, on s'arrête et on demande.
3. Cinq minutes de vérification coûtent moins cher que cinq heures de récupération.

L'ordre de travail : **lire, comprendre, simuler avec `-WhatIf`, vérifier la portée, exécuter par petits lots en documentant chaque étape.**
