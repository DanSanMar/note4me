#!/usr/bin/env bash

# Configuración básica
NOTES_DIR="$HOME/note4me"
mkdir -p "$NOTES_DIR"
version="v 1.0"

# 0. Logo - note4me Claro con Subtítulo
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
# 1. Función de autoinstalación para Debian, Fedora y Arch
# ----------------------------------------------------------------------
check_and_install() {
    local missing_pkgs=()

    command -v fzf >/dev/null 2>&1 || missing_pkgs+=("fzf")
    command -v micro >/dev/null 2>&1 || missing_pkgs+=("micro")

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

# Ejecutar verificación de dependencias
check_and_install

# ----------------------------------------------------------------------
# 2. Menú Principal interactivo
# ----------------------------------------------------------------------
main_menu() {
    while true; do
        clear
		logo
		local help_msg="💡 ATAJOS Y NAVEGACIÓN:\n\n -EN MICRO:\n    Ctrl+S: Guardar\n    Ctrl+Q: Salir\n    Ctrl+F: Buscar\n    Ctrl+Z: Deshacer\n\n -EN EL MENÚ:\n    Esc/Ctrl+C: Volver o Salir"
        local choice
        choice=$(printf "📝 Crear\n📂 Editar\n🗑️ Eliminar\n🚪 Salir" | fzf \
            --header="NOTE4ME en: $NOTES_DIR" \
            --prompt="Selecciona una opción: " \
            --height=40% \
            --layout=reverse \
            --border \
			--preview-window="right:45%:border-rounded:wrap" \
            --preview="echo -e \"$help_msg\"")
			
        case "$choice" in
            "📝 Crear")
                create_note
                ;;
            "📂 Editar")
                edit_note
                ;;
            "🗑️ Eliminar")
                delete_note
                ;;
            "🚪 Salir"|"")
                echo "¡Bye Bye 📝4me!"
                exit 0
                ;;
        esac
    done
}

# ----------------------------------------------------------------------
# 3. Funciones de gestión de notas
# ----------------------------------------------------------------------

create_note() {
    echo ""
    read -rp "Nombre de la nueva nota sin espacios (ej. idea.txt): " filename
    if [ -z "$filename" ]; then
        echo "Nombre inválido."
        sleep 1
        return
    fi

    # Asegurar extensión .txt si no se ingresa una
    [[ "$filename" != *.* ]] && filename="${filename}.txt"

    micro "$NOTES_DIR/$filename"
}

edit_note() {
    local selected
    # fzf con Vista Previa (Preview) usando micro o cat
    selected=$(ls -1 "$NOTES_DIR" 2>/dev/null | fzf \
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
    selected=$(ls -1 "$NOTES_DIR" 2>/dev/null | fzf \
        --header="--- Selecciona una nota para ELIMINAR ---" \
        --prompt="Eliminar > " \
        --height=60% \
        --layout=reverse \
        --border \
        --preview="cat '$NOTES_DIR/{}'")

    if [ -n "$selected" ]; then
        read -rp "¿Estás seguro de eliminar '$selected'? (s/N): " confirm
        if [[ "$confirm" =~ ^[Ss]$ ]]; then
            rm "$NOTES_DIR/$selected"
            echo "Nota eliminada."
            sleep 1
        fi
    fi
}

# Lanzar programa
main_menu