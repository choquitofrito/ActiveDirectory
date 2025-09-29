#!/bin/bash

# Répertoire contenant les fichiers Markdown
SYLLABUS_DIR="/home/bender/Documents/Trabajo/Cursos-Estudio//ActiveDirectory/syllabus"

# Fonction pour convertir un fichier Markdown en PDF
convert_file() {
    local file="$1"
    echo "Conversion de $file en PDF..."
    
    # Utiliser la commande VSCode pour exporter en PDF
    # Cette commande doit être exécutée depuis VSCode, ce script sert de guide
    echo "Pour convertir ce fichier, ouvrez-le dans VSCode et utilisez la commande:"
    echo "Markdown PDF: Export (pdf)"
}

# Trouver tous les fichiers .md dans le répertoire syllabus et ses sous-répertoires
find "$SYLLABUS_DIR" -name "*.md" | sort | while read -r file; do
    echo "---------------------------------------------"
    convert_file "$file"
done

echo "---------------------------------------------"
echo "INSTRUCTIONS:"
echo "1. Ce script liste tous les fichiers Markdown à convertir"
echo "2. Pour chaque fichier:"
echo "   a. Ouvrez-le dans VSCode"
echo "   b. Utilisez la palette de commandes (Ctrl+Shift+P)"
echo "   c. Tapez 'Markdown PDF: Export (pdf)'"
echo "   d. Le PDF sera généré dans le même répertoire que le fichier .md"
echo "---------------------------------------------"
echo "Note: VSCode ne permet pas d'automatiser cette conversion par script"
echo "Vous devez utiliser l'extension manuellement pour chaque fichier"
