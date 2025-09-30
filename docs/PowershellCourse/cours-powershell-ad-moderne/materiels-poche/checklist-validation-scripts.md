# ✅ Checklist Validation Scripts PowerShell AD
*À imprimer et plastifier - Format A4*

---

## 🔒 SÉCURITÉ CRITIQUE (Obligatoires)

### Avant d'Exécuter TOUT Script
- [ ] **Source fiable ?** (Microsoft docs > Stack Overflow > Forums)
- [ ] **-WhatIf ajouté** sur toutes commandes destructives ?
- [ ] **Scope limité** avec -SearchBase ou -Filter précis ?
- [ ] **Gestion d'erreurs** try-catch présente ?
- [ ] **Variables vérifiées** (pas de $null, pas de typos) ?

### Commandes à Haut Risque
- [ ] **Remove-*** : -WhatIf + vérification scope + exclusions critiques
- [ ] **Set-*** massif : -WhatIf + limitation nombre d'objets
- [ ] **Move-ADObject** : Vérification chemin destination
- [ ] **-Recursive** : Double vérification du contenu
- [ ] **-Filter \*** : Limitation avec -ResultSetSize ou -SearchBase

---

## ⚠️ VALIDATION ENVIRONNEMENT

### Adaptation maxtec.be
- [ ] **Domaine correct ?** DC=maxtec,DC=be (pas contoso.com)
- [ ] **Structure OU ?** OU=EU,DC=maxtec,DC=be
- [ ] **Noms groupes ?** GG-EU-* (pas format générique)
- [ ] **Utilisateurs test ?** Richard, Irene, Ivan... (pas John, Jane)

### Variables d'Environnement
- [ ] **Paths hardcodés** remplacés par variables ?
- [ ] **Credentials** sécurisées (pas en clair) ?
- [ ] **Dates** relatives (pas absolues) ?
- [ ] **Logs** dirigés vers bon répertoire ?

---

## 🔍 LOGIQUE MÉTIER

### Validation Business
- [ ] **Compréhension** : Je comprends chaque ligne du script ?
- [ ] **Objectif clair** : Que fait le script exactement ?
- [ ] **Edge cases** : Que si utilisateur n'existe pas / groupe vide ?
- [ ] **Rollback plan** : Comment annuler si erreur ?

### Tests Progressifs
- [ ] **1 objet test** d'abord (avec -WhatIf) ?
- [ ] **5 objets test** ensuite ?
- [ ] **Validation résultat** avant continuer ?
- [ ] **Logs vérifiés** après chaque lot ?

---

## 🚨 RED FLAGS - ARRÊT IMMÉDIAT

### Dans le Code
- [ ] ⛔ **Pas de -WhatIf** sur Remove-*, Set-* massif
- [ ] ⛔ **-Confirm:$false** sans validation préalable
- [ ] ⛔ **Get-ADUser -Filter \*** sans limitation
- [ ] ⛔ **Mots de passe** en clair dans script
- [ ] ⛔ **try-catch vide** qui masque erreurs

### Dans les Commentaires
- [ ] ⛔ **"TODO: tester"** dans script "prêt"
- [ ] ⛔ **"Temporaire"** dans script permanent
- [ ] ⛔ **Pas de gestion d'erreur** mentionnée
- [ ] ⛔ **Source inconnue** ou douteuse
- [ ] ⛔ **Dernière modif** > 6 mois sans validation

---

## 🎯 TESTS OBLIGATOIRES

### Phase 1: Simulation
```powershell
# Toujours commencer par:
[COMMANDE] -WhatIf
# Analyser l'output ligne par ligne
```

### Phase 2: Test Réduit
```powershell
# Puis tester sur 1-3 objets maximum:
[COMMANDE] -ResultSetSize 3
# Vérifier résultat avant continuer
```

### Phase 3: Production Contrôlée
```powershell
# Ensuite par lots de 10 maximum:
[COMMANDE] | Select-Object -First 10
# Validation après chaque lot
```

---

## 📋 DOCUMENTATION OBLIGATOIRE

### Avant Exécution
- [ ] **Date/heure** de prévue
- [ ] **Objectif** business du script
- [ ] **Nombre objets** estimés affectés
- [ ] **Plan de rollback** si problème

### Pendant Exécution
- [ ] **Logs activés** et dirigés vers fichier
- [ ] **Progression** documentée par lot
- [ ] **Erreurs** capturées et analysées
- [ ] **Résultats intermédiaires** vérifiés

### Après Exécution
- [ ] **Résultat final** documenté
- [ ] **Objets traités** comptés et vérifiés
- [ ] **Problèmes rencontrés** listés
- [ ] **Actions correctives** appliquées

---

## 🆘 PROCÉDURE D'URGENCE

### Si Erreur Critique
1. **STOP immédiatement** - ne pas continuer
2. **Documenter** erreur exacte + commande
3. **Évaluer impact** (combien d'objets affectés)
4. **Alerter superviseur** si > 10 objets
5. **NE PAS essayer** de réparer seul
6. **Attendre validation** équipe avant action

### Contacts Urgence maxtec.be
- **Admin Principal**: richard@maxtec.be
- **Superviseur IT**: responsable.it@maxtec.be
- **Urgence**: +33 6 XX XX XX XX

---

## 🎓 RAPPELS ESSENTIELS

### Les 3 Règles d'Or
1. **-WhatIf n'est jamais optionnel** pour commandes destructives
2. **Si doute = STOP et demander** aide
3. **Mieux vaut 5 min de vérification** que 5h de récupération

### Mantra à Réciter
*"Je lis, je comprends, je teste avec -WhatIf, je valide le scope, puis j'exécute par petits lots en documentant chaque étape."*

---

**✅ VALIDATION FINALE**: Cochez toutes les cases avant d'exécuter votre script !

**🛡️ REMEMBER**: Cette checklist peut sauver votre carrière.