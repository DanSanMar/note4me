# 📝 NOTE4Me (v1.6)

> Un gestor de notas CLI rápido, intuitivo y moderno para la terminal impulsado por Bash, `fzf` y `micro`.

---

## 📖 Descripción

**NOTE4ME** es un script ejecutable que transforma la gestión de notas locales en una experiencia fluida dentro de la terminal. Permite crear, buscar por contenido completo, editar y organizar notas en carpetas utilizando menús interactivos, vista previa en tiempo real con resaltado de sintaxis y autoinstalación de dependencias.

---

## ✨ Características Principales

- **🖥️ Interfaz CLI Interactiva:** Menús dinámicos con soporte para teclado alimentados por `fzf`.
- **🔍 Búsqueda de Texto Completo:** Localiza frases o palabras dentro de cualquier nota con `ripgrep` y salta directamente a la línea exacta en el editor.
- **👁️ Vista Previa en Tiempo Real:** Visualiza el contenido de tus notas antes de abrirlas o eliminarlas mediante `bat`.
- **📁 Organización por Carpetas:** Crea notas en la raíz o dentro de subcarpetas (nuevas o existentes).
- **🧹 Limpieza Inteligente:** Detecta cuando una carpeta queda vacía tras eliminar una nota y propone borrarla automáticamente.
- **🛠️ Autoinstalación de Dependencias:** Detecta el sistema operativo (`apt`, `dnf`, `pacman`) e instala las herramientas faltantes con previa confirmación.
- **🛡️ Salida Confiable:** Atrapa señales de interrupción (`Ctrl+C`, `SIGTERM`) para restaurar la terminal sin dejar el cursor oculto o con errores de eco.

---

## 🛠️ Requisitos de Software

El script utiliza las siguientes herramientas CLI:

| Herramienta | Descripción |
|-------------|-------------|
| [fzf](https://github.com/junegunn/fzf) | Búsqueda difusa interactiva |
| [micro](https://micro-editor.github.io/) | Editor de texto moderno de terminal |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Motor de búsqueda ultra rápido (`rg`) |
| [bat](https://github.com/sharkdp/bat) | Clon de `cat` con resaltado de sintaxis (usa `cat` como fallback si no está disponible) |

---

## ⌨️ Guía de Atajos

### 🟢 En la Navegación y Menús (fzf)

| Tecla | Acción |
|-------|--------|
| Flecha Arriba / Flecha Abajo | Moverse por las opciones |
| Enter | Seleccionar / Abrir archivo |
| Esc o Ctrl + C | Cancelar / Salir |

### 🟡 En el Editor (micro)

| Tecla | Acción |
|-------|--------|
| Ctrl + S | Guardar cambios |
| Ctrl + Q | Salir del editor |
| Ctrl + F | Buscar en el archivo actual |
| Ctrl + Z | Deshacer |

---

## ⚡ Instalación y Uso Rápido

1. **Clonar el repositorio o descargar el script:**
   ```bash
   git clone https://github.com/DanSanMar/note4me.git
   cd note4me
   ```

2. **Otorgar permisos de ejecución:**
   ```bash
   chmod +x note4me.sh
   ```

3. **Ejecutar la aplicación:**
   ```bash
   ./note4me.sh
   ```

4. **(Opcional) Acceso global:** Muévelo a tu directorio de binarios locales para ejecutarlo tecleando `note4me` desde cualquier lugar:
   ```bash
   mv note4me.sh ~/.local/bin/note4me
   ```
5. **(Recomendación) Uso de alias simplificado:** 
    ```bash
    echo "alias note='~/.local/bin/note4me'" >> ~/.bashrc && source ~/.bashrc
    ```

