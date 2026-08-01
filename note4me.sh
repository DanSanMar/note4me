#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Configuración inicial y Variables Globales
# ----------------------------------------------------------------------
NOTES_DIR="$HOME/note4me"
mkdir -p "$NOTES_DIR"
version="v 1.4"

# Flag para prevenir ejecuciones múltiples del trap durante el exit
IS_EXITING=0

# ----------------------------------------------------------------------
# Control Seguro de Salida y Captura de Señales (TRAP)
# ----------------------------------------------------------------------
cleanup() {
    local exit_code=${1:-$?}
    
    # Prevenir bucles de salida o ejecuciones dobles
    [[ $IS_EXITING -eq 1 ]] && return
    IS_EXITING=1

    # Restaurar estado de la terminal (Cursor visible, eco de teclas)
    tput cnorm 2>/dev/null || true
    stty echo 2>/dev/null || true

    echo -e "\n\n\033[1;33m[!] Cerrando note4me de forma segura... ¡Bye Bye! 📝4me\033[0m"
    exit "$exit_code"
}

# Capturar Ctrl+C (SIGINT), Terminate (SIGTERM) y HUP
trap 'cleanup 130' INT
trap 'cleanup 143' TERM HUP

# ----------------------------------------------------------------------
# Logo
# ----------------------------------------------------------------------
logo() {
    echo "     ┌─────────────────────────────────────────────────────────────────────┐"
    echo "     │                                                                     │"
    echo "     │  ███╗  ██╗ ██████╗ ████████╗███████╗ ██╗  ██╗  ███╗   ███╗███████╗  │"
    echo "     │  ████╗ ██║██╔═══██╗╚══██╔══╝██╔════╝ ██║  ██║  ████╗ ████║██╔════╝  │"
    echo "     │  ██╔██╗██║██║   ██║   ██║   █████╗   ███████║  ██╔████╔██║█████╗    │"
    echo "     │  ██║╚████║██║   ██║   ██║   ██╔══╝   ╚════██║  ██║╚██╔╝██║██╔══╝    │"
    echo "     │  ██║ ╚███║╚██████╔╝   ██║   ███████╗      ██║  ██║ ╚═╝ ██║███████╗  │"
    echo "     │  ╚═╝  ╚══╝ ╚═════╝    ╚═╝   ╚══════╝      ╚═╝  ╚═╝     ╚═╝╚══════╝  │"
    echo "     │                                                                     │"
    echo "     ├─────────────────────────────────────────────────────────────────────┤"
    echo "                           CLI NOTE MANAGER $version                        "
    echo "     └─────────────────────────────────────────────────────────────────────┘"
    echo ""
}

# ----------------------------------------------------------------------
# 1. Autoinstalación de Dependencias
# ----------------------------------------------------------------------
check_and_install() {
    local missing_pkgs=()

    command -v fzf >/dev/null 2>&1 || missing_pkgs+=("fzf")
    command -v micro >/dev/null 2>&1 || missing_pkgs+=("micro")
    command -v rg >/dev/null 2>&1 || missing_pkgs+=("ripgrep")

    if [ ${#missing_pkgs[@]} -ne 0 ]; then
        echo "--> Faltan las siguientes dependencias: ${missing_pkgs[*]}"
        read -rp "¿Deseas instalarlas automáticamente? (s/N): " install_confirm
        if [[ "$install_confirm" =~ ^[Ss]$ ]]; then
            echo "--> Intentando instalar..."
        else
            echo "Instalación cancelada. Por favor, instala manualmente: ${missing_pkgs[*]}"
            sleep 2
            exit 1
        fi

        if [ -f /etc/os-release ]; then
            . /etc/os-release
            case "$ID" in
                debian|ubuntu|pop|mint|kali)
                    sudo apt update && sudo apt install -y "${missing_pkgs[@]}"
                    ;;
                fedora|rhel|centos)
                    sudo dnf install -y "${missing_pkgs[@]}"
                    ;;
                arch|manjaro|endeavouros)
                    sudo pacman -Sy --noconfirm "${missing_pkgs[@]}"
                    ;;
                *)
                    echo "Error: Distribución no soportada automáticamente ($ID)."
                    echo "Por favor, instala manualmente: ${missing_pkgs[*]}"
                    exit 1
                    ;;
            esac
        else
            echo "Error: No se pudo determinar el sistema operativo."
            exit 1
        fi
    fi
}

# Verificación inicial
check_and_install

# ----------------------------------------------------------------------
# 2. Menú Principal
# ----------------------------------------------------------------------
main_menu() {
    while true; do
        clear
        logo
        local help_msg="💡 ATAJOS Y NAVEGACIÓN:\n\n -EN MICRO:\n    Ctrl+S: Guardar\n    Ctrl+Q: Salir\n    Ctrl+F: Buscar\n    Ctrl+Z: Deshacer\n\n -EN EL MENÚ:\n    Esc/Ctrl+C: Volver/Salir"
        local choice
        
        # Ejecutar fzf
        choice=$(printf "📝 Crear\n📂 Editar\n🔍 Buscar\n🗑️ Eliminar\n🚪 Salir" | fzf \
            --header="NOTE4ME en: $NOTES_DIR" \
            --prompt="Selecciona una opción: " \
            --height=40% \
            --layout=reverse \
            --border \
            --preview-window="right:45%:border-rounded:wrap" \
            --preview="echo -e \"$help_msg\"")

        local fzf_exit=$?

        # Si el usuario presiona Esc o Ctrl+C en el menú principal (fzf devuelve 130 o >0 sin selección)
        if [ $fzf_exit -eq 130 ] || [ $fzf_exit -gt 0 ] && [ -z "$choice" ]; then
            cleanup 0
        fi

        case "$choice" in
            "📝 Crear")          create_note ;;
            "📂 Editar")         edit_note ;;
            "🔍 Buscar")         search_content ;;
            "🗑️ Eliminar")       delete_note ;;
            "🚪 Salir")          cleanup 0 ;;
        esac
    done
}

# ----------------------------------------------------------------------
# 3. Funciones de Gestión
# ----------------------------------------------------------------------
search_content() {
    local selected
    # (cd ...) ejecuta dentro del directorio sin cambiar el directorio actual del script principal
    selected=$( (cd "$NOTES_DIR" && rg --line-number --no-heading --color=always "" 2>/dev/null) | fzf \
        --ansi \
        --header="-BUSCAR EN: $NOTES_DIR" \
        --prompt="-Escribe para filtrar > " \
        --height=80% \
        --layout=reverse \
        --border \
        --delimiter=: \
        --preview-window="right:30%:border-rounded:wrap" \
        --preview="bat --style=numbers --color=always --highlight-line {2} '$NOTES_DIR/{1}' 2>/dev/null || head -n 30 '$NOTES_DIR/{1}'")

    if [ -n "$selected" ]; then
        local file line
        file=$(echo "$selected" | cut -d: -f1)
        line=$(echo "$selected" | cut -d: -f2)
        micro "+$line" "$NOTES_DIR/$file"
    fi
}
create_note() {
    echo ""
    local action
    action=$(printf "📄 Archivo rápido (Raíz)\n📂 Crear en Carpeta (Existente o Nueva)" | fzf \
        --header="--- CREAR NOTA ---" \
        --prompt="Selecciona opción > " \
        --height=30% \
        --layout=reverse \
        --border)

    [[ -z "$action" ]] && return

    local target_dir="$NOTES_DIR"

    if [ "$action" = "📂 Crear en Carpeta (Existente o Nueva)" ]; then
        # Obtener lista de subcarpetas existentes
        local folders
        folders=$(find "$NOTES_DIR" -mindepth 1 -type d 2>/dev/null | sed "s|^$NOTES_DIR/||")

        # Presentar las carpetas + la opción de crear una nueva al inicio
        local selected_folder
        selected_folder=$(printf "[ 📁 + Nueva Carpeta ]\n%s" "$folders" | fzf \
            --header="--- Selecciona o Crea una Carpeta ---" \
            --prompt="Carpeta > " \
            --height=50% \
            --layout=reverse \
            --border)

        [[ -z "$selected_folder" ]] && return

        if [ "$selected_folder" = "[ 📁 + Nueva Carpeta ]" ]; then
            read -rp "Nombre de la nueva carpeta: " new_folder_name
            if [ -z "$new_folder_name" ]; then
                echo "Nombre de carpeta inválido."
                sleep 1
                return
            fi
            target_dir="$NOTES_DIR/$new_folder_name"
            mkdir -p "$target_dir"
            echo "Carpeta '$new_folder_name' lista."
        else
            target_dir="$NOTES_DIR/$selected_folder"
        fi
    fi

    # Flujo continuo: Creación del archivo en target_dir
    echo ""
    read -rp "Nombre del archivo (ej. nota.txt): " filename
    if [ -z "$filename" ]; then
        echo "Nombre de archivo inválido."
        sleep 1
        return
    fi

    # Asegurar extensión .txt si no tiene extensión
    [[ "$filename" != *.* ]] && filename="${filename}.txt"

    # Abrir directamente en el editor
    micro "$target_dir/$filename"
}

edit_note() {
    local selected
    selected=$(find "$NOTES_DIR" -type f 2>/dev/null | sed "s|^$NOTES_DIR/||" | fzf \
        --header="--- Selecciona una nota para EDITAR ---" \
        --prompt="Nota > " \
        --height=60% \
        --layout=reverse \
        --border \
        --preview="cat '$NOTES_DIR/{}'")

    if [ -n "$selected" ]; then
        micro "$NOTES_DIR/$selected"
    fi
}

delete_note() {
    local selected
    selected=$(find "$NOTES_DIR" -type f 2>/dev/null | sed "s|^$NOTES_DIR/||" | fzf \
        --header="--- Selecciona una nota para ELIMINAR ---" \
        --prompt="Eliminar > " \
        --height=60% \
        --layout=reverse \
        --border \
        --preview="cat '$NOTES_DIR/{}'")

    if [ -n "$selected" ]; then
        read -rp "¿Estás seguro de eliminar '$selected'? (s/N): " confirm
        if [[ "$confirm" =~ ^[Ss]$ ]]; then
            local full_path="$NOTES_DIR/$selected"
            local parent_dir
            parent_dir=$(dirname "$full_path")

            # Eliminar el archivo
            rm -f "$full_path"
            echo "Nota eliminada."

            # Verificar si el archivo estaba dentro de una subcarpeta (diferente a $NOTES_DIR)
            if [ "$parent_dir" != "$NOTES_DIR" ]; then
                # Comprobar si la carpeta quedó completamente vacía
                if [ -z "$(ls -A "$parent_dir" 2>/dev/null)" ]; then
                    local folder_name
                    folder_name=$(basename "$parent_dir")
                    echo ""
                    read -rp "La carpeta '$folder_name' ha quedado vacía. ¿Deseas eliminarla también? (s/N): " del_folder_confirm
                    if [[ "$del_folder_confirm" =~ ^[Ss]$ ]]; then
                        rmdir "$parent_dir" 2>/dev/null && echo "Carpeta '$folder_name' eliminada." || echo "No se pudo eliminar la carpeta."
                    fi
                fi
            fi

            sleep 1
        fi
    fi
}

# Lanzar aplicación
main_menu