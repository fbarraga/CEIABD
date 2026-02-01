#!/bin/bash

# Script de migració per centralitzar totes les carpetes downloads
# en un únic directori /downloads a l'arrel del projecte

set -eu

# Obtenir el directori arrel del projecte (on està aquest script)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CENTRAL_DOWNLOADS_DIR="$PROJECT_ROOT/downloads"

echo "================================================"
echo "🔄 Migració de downloads a directori central"
echo "================================================"
echo ""
echo "📁 Directori central: $CENTRAL_DOWNLOADS_DIR"
echo ""

# Crear directori central si no existeix
mkdir -p "$CENTRAL_DOWNLOADS_DIR"

# Funció per copiar fitxers d'un directori a un altre
migrate_files() {
    local source_dir="$1"
    local files_moved=0
    local files_skipped=0

    if [ ! -d "$source_dir" ]; then
        return 0
    fi

    # Cercar tots els fitxers al directori source (no directoris)
    # Inclou: .tar.gz, .tgz, .sha512, .asc, i qualsevol altre fitxer
    set +e  # Desactivar exit on error per al find
    while IFS= read -r -d '' file; do
        [ -z "$file" ] && continue
        local filename=$(basename "$file")
        local dest_file="$CENTRAL_DOWNLOADS_DIR/$filename"

        if [ -f "$dest_file" ]; then
            # Verificar si són el mateix fitxer (mateixa mida)
            if [ -f "$file" ] && [ -f "$dest_file" ]; then
                local source_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
                local dest_size=$(stat -f%z "$dest_file" 2>/dev/null || stat -c%s "$dest_file" 2>/dev/null || echo "0")

                if [ "$source_size" = "$dest_size" ] && [ "$source_size" != "0" ]; then
                    echo "  ⏭️  Saltant $filename (ja existeix al destí amb la mateixa mida)"
                    ((files_skipped++))
                    continue
                fi
            fi
        fi

        # Copiar el fitxer
        if cp "$file" "$dest_file" 2>/dev/null; then
            echo "  ✅ Copiat: $filename"
            ((files_moved++))
        else
            echo "  ⚠️  Error copiant: $filename"
        fi
    done < <(find "$source_dir" -maxdepth 1 -type f -print0 2>/dev/null || true)
    set -e  # Reactivar exit on error

    echo "  📊 Resum: $files_moved copiats, $files_skipped saltats"
    return $files_moved
}

# Directoris a migrar
DOWNLOAD_DIRS=(
    "$PROJECT_ROOT/modul0/Base/downloads"
    "$PROJECT_ROOT/modul1/Base/downloads"
    "$PROJECT_ROOT/modul2/Base/downloads"
)

total_moved=0
total_skipped=0

# Migrar cada directori
set +e  # Desactivar exit on error temporalment
for dir in "${DOWNLOAD_DIRS[@]}"; do
    if [ -d "$dir" ] && [ "$(ls -A "$dir" 2>/dev/null)" ]; then
        echo "📂 Migrant: $dir"
        migrate_files "$dir" || true
        echo ""
    fi
done
set -e  # Reactivar exit on error

echo "================================================"
echo "✅ Migració completada"
echo "================================================"
echo ""
echo "📁 Fitxers al directori central:"
set +e  # Desactivar exit on error temporalment
if [ -d "$CENTRAL_DOWNLOADS_DIR" ] && [ "$(ls -A "$CENTRAL_DOWNLOADS_DIR" 2>/dev/null)" ]; then
    ls -lh "$CENTRAL_DOWNLOADS_DIR" 2>/dev/null || echo "  (error al llistar)"
else
    echo "  (buit)"
fi
set -e  # Reactivar exit on error
echo ""

# Eliminar carpetes downloads locals després de la migració
echo "🗑️  Eliminant carpetes downloads locals..."
set +e  # Desactivar exit on error temporalment per a l'eliminació
for dir in "${DOWNLOAD_DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        continue
    fi

    # Verificar que tots els fitxers existeixen al destí
    all_migrated=true
    file_count=0

    # Comptar fitxers i verificar que tots són al destí
    files_found=$(find "$dir" -maxdepth 1 -type f 2>/dev/null)
    if [ -n "$files_found" ]; then
        while IFS= read -r file; do
            [ -z "$file" ] && continue
            file_count=$((file_count + 1))
            filename=$(basename "$file" 2>/dev/null || echo "")
            [ -z "$filename" ] && continue
            dest_file="$CENTRAL_DOWNLOADS_DIR/$filename"
            if [ ! -f "$dest_file" ]; then
                all_migrated=false
                break
            fi
        done <<< "$files_found"
    fi

    if [ "$file_count" -eq 0 ]; then
        echo "  ✅ Eliminant: $dir (buit)"
        rmdir "$dir" 2>/dev/null || true
    elif [ "$all_migrated" = true ] && [ "$file_count" -gt 0 ]; then
        echo "  ✅ Eliminant: $dir (tots els $file_count fitxers migrats)"
        rm -rf "$dir" 2>/dev/null || true
    else
        echo "  ⚠️  No s'elimina: $dir (alguns fitxers no van ser migrats)"
    fi
done
set -e  # Reactivar exit on error
echo ""

echo "💡 Propers passos:"
echo "   1. Els scripts download-cache.sh ara usaran /downloads"
echo "   2. Les carpetes downloads locals han estat eliminades automàticament"
echo ""

