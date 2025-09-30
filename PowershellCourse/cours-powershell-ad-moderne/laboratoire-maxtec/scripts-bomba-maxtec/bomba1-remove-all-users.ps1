# Script de nettoyage des comptes utilisateurs inactifs
# Auteur: Admin Senior (source fiable)
# Date: 2024-12-15
# Description: Supprime les comptes d'utilisateurs qui n'ont pas été utilisés depuis plus de 90 jours
#
# ⚠️  SCRIPT BOMBE ÉDUCATIF - NE PAS EXÉCUTER EN PRODUCTION ⚠️
# Ce script contient des erreurs volontaires à des fins pédagogiques

Import-Module ActiveDirectory

Write-Host "=== NETTOYAGE DES COMPTES INACTIFS ===" -ForegroundColor Green
Write-Host "Recherche des utilisateurs inactifs..." -ForegroundColor Yellow

# Configuration
$dateLimite = (Get-Date).AddDays(-90)
$domainBase = "DC=maxtec,DC=be"

Write-Host "Date limite pour inactivité: $dateLimite" -ForegroundColor Cyan

# Obtenir tous les utilisateurs du domaine avec leur date de dernière connexion
Write-Host "Récupération de la liste des utilisateurs..." -ForegroundColor Yellow

$utilisateursInactifs = Get-ADUser -Filter * -SearchBase $domainBase -Properties LastLogonDate |
    Where-Object {
        $_.LastLogonDate -lt $dateLimite -and
        $_.Enabled -eq $true
    }

Write-Host "Trouvé $($utilisateursInactifs.Count) utilisateurs inactifs" -ForegroundColor Yellow

# Afficher la liste des utilisateurs qui seront supprimés
Write-Host "`n=== UTILISATEURS À SUPPRIMER ===" -ForegroundColor Red
$utilisateursInactifs | ForEach-Object {
    Write-Host "- $($_.Name) (Dernière connexion: $($_.LastLogonDate))" -ForegroundColor Yellow
}

Write-Host "`nDébut de la suppression dans 5 secondes..." -ForegroundColor Red
Start-Sleep -Seconds 5

# TODO: Vérifier avec l'équipe avant de passer en production
# TODO: Ajouter exclusions pour les comptes de service

# ☢️ ERREURS CRITIQUES CACHÉES DANS CE SCRIPT:
# 1. LIGNE SUIVANTE: Aucune exclusion pour les comptes administrateurs ou de service
# 2. LIGNE SUIVANTE: Pas de validation supplémentaire (groupes critiques)
# 3. LIGNE SUIVANTE: Pas de -WhatIf pour prévisualiser
# 4. LIGNE SUIVANTE: Suppression directe sans désactivation préalable
# 5. LIGNE SUIVANTE: Pas de sauvegarde des données avant suppression

foreach ($utilisateur in $utilisateursInactifs) {
    Write-Host "Suppression de l'utilisateur: $($utilisateur.Name)" -ForegroundColor Red

    # ☠️ ERREUR MORTELLE: Suppression directe sans vérifications !
    Remove-ADUser -Identity $utilisateur.SamAccountName -Confirm:$false

    # ☠️ PROBLÈMES AVEC CETTE LIGNE:
    # - Pas de vérification si l'utilisateur est admin
    # - Pas de vérification si c'est un compte de service
    # - Pas de sauvegarde des données
    # - Pas de -WhatIf pour tester d'abord
    # - Suppression immédiate et irréversible
}

Write-Host "`n✅ Nettoyage terminé avec succès!" -ForegroundColor Green
Write-Host "Utilisateurs supprimés: $($utilisateursInactifs.Count)" -ForegroundColor Green

# ☢️ AUTRES PROBLÈMES CACHÉS:
# - Aucun logging des actions effectuées
# - Pas de notification à l'équipe
# - Pas de vérification des dépendances (groupes, permissions)
# - Script ne vérifie pas s'il tourne sur le bon environnement


# 🚨 COMMENT RÉPARER CE SCRIPT:
# 1. Ajouter -WhatIf partout
# 2. Ajouter exclusions pour comptes critiques
# 3. Désactiver d'abord, supprimer après 90 jours
# 4. Ajouter logging et notifications
# 5. Valider l'environnement avant exécution