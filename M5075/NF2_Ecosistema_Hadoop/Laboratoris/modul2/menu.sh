#!/bin/bash

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Función para imprimir el encabezado
print_header() {
    clear
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}       Módulo 2 - Menú Interactivo Make       ${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
}

# Función para extraer targets del Makefile
get_targets() {
    if [ ! -f "Makefile" ]; then
        echo -e "${RED}Error: No se encontró el archivo Makefile en el directorio actual.${NC}"
        exit 1
    fi
    # Extrae targets que tienen descripción (##)
    grep -E '^[a-zA-Z_-]+:.*?## .*$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "%s|%s\n", $1, $2}'
}

# Array para almacenar opciones
declare -a TARGETS
declare -a DESCRIPTIONS

# Cargar targets
while IFS='|' read -r target desc; do
    TARGETS+=("$target")
    DESCRIPTIONS+=("$desc")
done < <(get_targets)

# Loop principal
while true; do
    print_header
    
    echo -e "${YELLOW}Opciones disponibles:${NC}"
    
    # Listar opciones
    for i in "${!TARGETS[@]}"; do
        printf "  ${GREEN}%2d)${NC} %-20s %s\n" "$((i+1))" "${TARGETS[$i]}" "${DESCRIPTIONS[$i]}"
    done
    echo ""
    echo -e "  ${RED} 0)${NC} Salir"
    echo ""
    
    read -p "Seleccione una opción [0-${#TARGETS[@]}]: " choice
    
    if [[ "$choice" =~ ^[0-9]+$ ]]; then
        if [ "$choice" -eq 0 ]; then
            echo -e "${BLUE}¡Hasta luego!${NC}"
            exit 0
        elif [ "$choice" -ge 1 ] && [ "$choice" -le "${#TARGETS[@]}" ]; then
            target="${TARGETS[$((choice-1))]}"
            echo ""
            echo -e "${BLUE}Ejecutando: make $target${NC}"
            echo -e "${BLUE}------------------------------------------------${NC}"
            make "$target"
            
            echo ""
            echo -e "${BLUE}------------------------------------------------${NC}"
            read -p "Presione Enter para continuar..."
        else
            echo -e "${RED}Opción inválida.${NC}"
            sleep 1
        fi
    else
        echo -e "${RED}Por favor ingrese un número válido.${NC}"
        sleep 1
    fi
done
