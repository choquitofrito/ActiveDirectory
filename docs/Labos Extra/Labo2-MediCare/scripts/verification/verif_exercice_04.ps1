# Vérification Exercice 04 : Nouveau Service Médical
Import-Module ActiveDirectory
Write-Host "========================================"  -ForegroundColor Cyan
Write-Host "Vérification Exercice 04" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
$errors = 0
$dermatoPath = "OU=Dermatologie,OU=Medical,OU=MediCare,DC=maxtec,DC=be"
if (Get-ADOrganizationalUnit -Filter {DistinguishedName -eq $dermatoPath} -ErrorAction SilentlyContinue) {
    Write-Host "`n✓ OU Dermatologie trouvée" -ForegroundColor Green
} else {
    Write-Host "`n✗ OU Dermatologie manquante" -ForegroundColor Red
    $errors++
}
$users = @("sarah", "lucas", "emma")
foreach ($u in $users) {
    if (Get-ADUser -Identity $u -ErrorAction SilentlyContinue) {
        Write-Host "✓ Utilisateur $u trouvé" -ForegroundColor Green
    } else {
        Write-Host "✗ Utilisateur $u manquant" -ForegroundColor Red
        $errors++
    }
}
if (Get-ADGroup -Identity "GG-MediCare-Dermato-Users" -ErrorAction SilentlyContinue) {
    Write-Host "✓ Groupe GG-MediCare-Dermato-Users trouvé" -ForegroundColor Green
} else {
    Write-Host "✗ Groupe Dermato-Users manquant" -ForegroundColor Red
    $errors++
}
if ($errors -eq 0) {
    Write-Host "`n✅ EXERCICE RÉUSSI!" -ForegroundColor Green
} else {
    Write-Host "`n✗ EXERCICE INCOMPLET: $errors erreur(s)" -ForegroundColor Red
}
