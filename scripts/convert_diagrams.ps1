# Script de conversion des diagrammes .drawio en PNG
# et mise à jour des liens dans les fichiers Markdown

# Chemin vers draw.io en mode CLI (à adapter selon votre installation)
$DRAWIO_PATH = "C:\Program Files\draw.io\draw.io.exe"

# Dossiers source et destination
$DIAGRAMS_DIR = Join-Path $PSScriptRoot "..\diagrams"
$MD_FILES_DIR = Join-Path $PSScriptRoot ".."

# Création du dossier images s'il n'existe pas
$IMAGES_DIR = Join-Path $DIAGRAMS_DIR "images"
if (-not (Test-Path $IMAGES_DIR)) {
    New-Item -ItemType Directory -Path $IMAGES_DIR
}

# Conversion des fichiers .drawio en PNG
Get-ChildItem -Path $DIAGRAMS_DIR -Filter "*.drawio" | ForEach-Object {
    $drawioFile = $_.FullName
    $pngFile = Join-Path $IMAGES_DIR ($_.BaseName + ".png")
    
    Write-Host "Conversion de $($_.Name) en PNG..."
    & $DRAWIO_PATH --export --format png --output $pngFile $drawioFile
}

# Mise à jour des liens dans les fichiers Markdown
Get-ChildItem -Path $MD_FILES_DIR -Filter "*.md" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $modified = $false
    
    # Recherche des liens vers les fichiers .drawio
    $matches = [regex]::Matches($content, '\[([^\]]+)\]\(diagrams/([^)]+)\.drawio\)')
    
    foreach ($match in $matches) {
        $altText = $match.Groups[1].Value
        $diagramName = $match.Groups[2].Value
        $newLink = "[$altText](diagrams/images/$diagramName.png)"
        
        $content = $content.Replace($match.Value, $newLink)
        $modified = $true
    }
    
    # Sauvegarde du fichier si modifié
    if ($modified) {
        Write-Host "Mise à jour des liens dans $($_.Name)..."
        Set-Content -Path $_.FullName -Value $content
    }
}
