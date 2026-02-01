#!/bin/bash

# Script de migración para centralizar todas las carpetas downloads
# en un único directorio /downloads en la raíz del proyecto

set -eu

# Obtener el directorio raíz del proyecto (donde está este script)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CENTRAL_DOWNLOADS_DIR="$PROJECT_ROOT/downloads"

echo "================================================"
echo "🔄 Migración de downloads a directorio central"
echo "================================================"
echo ""
echo "📁 Directorio central: $CENTRAL_DOWNLOADS_DIR"
echo ""

# Crear directorio central si no existe
mkdir -p "$CENTRAL_DOWNLOADS_DIR"

# Función para copiar archivos de un directorio a otro
migrate_files() {
    local source_dir="$1"
    local files_moved=0
    local files_skipped=0
    
    if [ ! -d "$source_dir" ]; then
        return 0
    fi
    
    # Buscar todos los archivos en el directorio source (no directorios)
    # Incluye: .tar.gz, .tgz, .sha512, .asc, y cualquier otro archivo
    set +e  # Desactivar exit on error para el find
    while IFS= read -r -d '' file; do
        [ -z "$file" ] && continue
        local filename=$(basename "$file")
        local dest_file="$CENTRAL_DOWNLOADS_DIR/$filename"
        
        if [ -f "$dest_file" ]; then
            # Verificar si son el mismo archivo (mismo tamaño)
            if [ -f "$file" ] && [ -f "$dest_file" ]; then
                local source_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
                local dest_size=$(stat -f%z "$dest_file" 2>/dev/null || stat -c%s "$dest_file" 2>/dev/null || echo "0")
                
                if [ "$source_size" = "$dest_size" ] && [ "$source_size" != "0" ]; then
                    echo "  ⏭️  Saltando $filename (ya existe en destino con mismo tamaño)"
                    ((files_skipped++))
                    continue
                fi
            fi
        fi
        
        # Copiar el archivo
        if cp "$file" "$dest_file" 2>/dev/null; then
            echo "  ✅ Copiado: $filename"
            ((files_moved++))
        else
            echo "  ⚠️  Error copiando: $filename"
        fi
    done < <(find "$source_dir" -maxdepth 1 -type f -print0 2>/dev/null || true)
    set -e  # Reactivar exit on error
    
    echo "  📊 Resumen: $files_moved copiados, $files_skipped saltados"
    return $files_moved
}

# Directorios a migrar
DOWNLOAD_DIRS=(
    "$PROJECT_ROOT/modulo1/Base/downloads"
    "$PROJECT_ROOT/modulo1simple/Base/downloads"
    "$PROJECT_ROOT/modulo2/Base/downloads"
)

total_moved=0
total_skipped=0

# Migrar cada directorio
set +e  # Desactivar exit on error temporalmente
for dir in "${DOWNLOAD_DIRS[@]}"; do
    if [ -d "$dir" ] && [ "$(ls -A "$dir" 2>/dev/null)" ]; then
        echo "📂 Migrando: $dir"
        migrate_files "$dir" || true
        echo ""
    fi
done
set -e  # Reactivar exit on error

echo "================================================"
echo "✅ Migración completada"
echo "================================================"
echo ""
echo "📁 Archivos en directorio central:"
set +e  # Desactivar exit on error temporalmente
if [ -d "$CENTRAL_DOWNLOADS_DIR" ] && [ "$(ls -A "$CENTRAL_DOWNLOADS_DIR" 2>/dev/null)" ]; then
    ls -lh "$CENTRAL_DOWNLOADS_DIR" 2>/dev/null || echo "  (error al listar)"
else
    echo "  (vacío)"
fi
set -e  # Reactivar exit on error
echo ""

# Eliminar carpetas downloads locales después de la migración
echo "🗑️  Eliminando carpetas downloads locales..."
set +e  # Desactivar exit on error temporalmente para la eliminación
for dir in "${DOWNLOAD_DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        continue
    fi
    
    # Verificar que todos los archivos existen en el destino
    all_migrated=true
    file_count=0
    
    # Contar archivos y verificar que todos están en el destino
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
        echo "  ✅ Eliminando: $dir (vacío)"
        rmdir "$dir" 2>/dev/null || true
    elif [ "$all_migrated" = true ] && [ "$file_count" -gt 0 ]; then
        echo "  ✅ Eliminando: $dir (todos los $file_count archivos migrados)"
        rm -rf "$dir" 2>/dev/null || true
    else
        echo "  ⚠️  No se elimina: $dir (algunos archivos no fueron migrados)"
    fi
done
set -e  # Reactivar exit on error
echo ""

echo "💡 Próximos pasos:"
echo "   1. Los scripts download-cache.sh ahora usarán /downloads"
echo "   2. Las carpetas downloads locales han sido eliminadas automáticamente"
echo ""

