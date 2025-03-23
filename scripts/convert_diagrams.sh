#!/bin/bash

# Script to convert .drawio diagrams to PNG
# and update links in Markdown files

# Path to draw.io CLI (adjust according to your installation)
DRAWIO_PATH="/snap/bin/drawio"  # Path for snap installation

# Source and destination directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIAGRAMS_DIR="$SCRIPT_DIR/../diagrams"
MD_FILES_DIR="$SCRIPT_DIR/.."

# Create images directory if it doesn't exist
IMAGES_DIR="$DIAGRAMS_DIR/images"
mkdir -p "$IMAGES_DIR"

# Convert .drawio files to PNG
echo "Converting .drawio files to PNG..."
for drawio_file in "$DIAGRAMS_DIR"/*.drawio; do
    if [ -f "$drawio_file" ]; then
        filename=$(basename "$drawio_file")
        basename="${filename%.*}"
        png_file="$IMAGES_DIR/$basename.png"
        
        echo "Converting $filename to PNG..."
        "$DRAWIO_PATH" --export --format png --output "$png_file" "$drawio_file"
    fi
done

# Update links in Markdown files
echo "Updating links in Markdown files..."
find "$MD_FILES_DIR" -type f -name "*.md" | while read -r md_file; do
    # Create a temporary file
    temp_file=$(mktemp)
    
    # Process the file and replace .drawio links with .png links
    if sed -E 's/\[([^\]]+)\]\(diagrams\/([^)]+)\.drawio\)/[\1](diagrams\/images\/\2.png)/g' "$md_file" > "$temp_file"; then
        # Compare if there were any changes
        if ! cmp -s "$md_file" "$temp_file"; then
            echo "Updating links in $(basename "$md_file")..."
            mv "$temp_file" "$md_file"
        else
            rm "$temp_file"
        fi
    else
        rm "$temp_file"
        echo "Error processing $md_file"
    fi
done

echo "Conversion complete!"
