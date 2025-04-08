# Exercices GPO (Variations et Suppléments)

## 1. Modèles d'administration (Restrictions et Personnalisations)

---

### 1.4. GPO-Restriction-Explorateur. Supprimer l'accès à "Ce PC"
> (Config Utilisateur > Modèles d'administration > Composants Windows > Explorateur de fichiers > Supprimer l'icône Ordinateur du Bureau)

1.4.1. Appliquer à tous les utilisateurs sauf Comptabilité
1.4.2. Créer une exception pour le groupe "Formateurs"

---

## 2. Stratégies (Sécurité et Déploiement)


---

### 3.4. GPO-LecteurReseau. Connecter un lecteur réseau automatiquement
> (Config Utilisateur > Préférences > Paramètres Windows > Lecteurs réseau)

3.4.1. Connecter le lecteur `Z:` au dossier partagé `\\srv01\DocumentsRH` pour RH
3.4.2. Utiliser le filtrage pour l’appliquer uniquement aux membres de `RH-FullAccess`

---

## 4. Exceptions et Filtrage Avancé

### 4.2. Créer une GPO qui s'applique à tout RH sauf un utilisateur spécifique

4.2.1. Utiliser la délégation avancée pour refuser l'application à `julie.dupont`

---

### 4.3. Utiliser le filtrage de sécurité pour n'appliquer une GPO qu'à un groupe spécifique

4.3.1. Créer une GPO de désactivation du fond d'écran dynamique mais ne l’appliquer qu'au groupe `Stagiaires`

---

## 5. Divers et Défis Bonus

### 5.1. Déploiement de logiciels conditionnel

5.1.1. Déployer VLC Media Player uniquement sur les ordinateurs de `RH-Multimedia`
5.1.2. Vérifier que le chemin d’installation est toujours disponible en réseau au démarrage

---

### 5.2. Auditer l'application des GPO

5.2.1. Utiliser `gpresult /r` sur une machine client pour vérifier les GPO appliquées
5.2.2. Utiliser `rsop.msc` pour voir les paramètres effectifs sur un poste

---

### 5.3. Test de cohérence GPO

5.3.1. Créer deux GPOs contradictoires (ex: une autorise le Panneau de config, l’autre l’interdit) et observer la priorité
5.3.2. Modifier l’ordre de lien des GPOs dans l’OU pour observer l’impact

---

## Résumé
Ces exercices couvrent des aspects supplémentaires importants de la gestion des GPO : restrictions spécifiques, déploiement conditionnel, filtrage fin, et dépannage. Ils vous permettent d'aller plus loin dans la gestion centralisée d’un environnement Windows Server professionnel.

