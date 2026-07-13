#!/usr/bin/env bash

# setup-sakura.sh - Script de Instalação e Ricing para o SakuraOS
# Transforma um sistema Arch Linux com GNOME em uma área de trabalho estilo macOS com tema Anime.

set -euo pipefail

# Cores para o output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # Sem cor

log() {
    echo -e "${BLUE}[SakuraOS]${NC} $1"
}

success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

error() {
    echo -e "${RED}[✗]${NC} $1" >&2
}

# 1. Validações de Ambiente
if [[ $EUID -eq 0 ]]; then
   error "Este script NÃO deve ser executado como root diretamente. Por favor, execute como usuário comum (com privilégios de sudo)."
   exit 1
fi

log "Iniciando a instalação e customização do SakuraOS..."

# Verificar se estamos no Arch Linux (ou derivados)
if [ ! -f /etc/arch-release ]; then
    error "Este script foi projetado para o Arch Linux. Outros sistemas não são suportados nativamente."
    exit 1
fi

# 2. Instalação de Dependências Básicas
log "Instalando pacotes e dependências essenciais via pacman..."
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm \
    git \
    wget \
    curl \
    unzip \
    dconf \
    dconf-editor \
    gnome-shell-extensions \
    gnome-tweaks \
    fastfetch \
    kitty \
    sassc \
    gtk-murrine-engine \
    gtk-engines

success "Pacotes do sistema instalados com sucesso!"

# Criar estrutura de diretórios do usuário
mkdir -p "$HOME/.local/share/themes"
mkdir -p "$HOME/.local/share/icons"
mkdir -p "$HOME/.local/share/backgrounds"
mkdir -p "$HOME/.local/share/gnome-shell/extensions"
mkdir -p "$HOME/.config/kitty"
mkdir -p "$HOME/.config/fastfetch"

# 3. Copiar e Aplicar o Wallpaper Padrão
log "Configurando papel de parede do SakuraOS..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/assets/anime_wallpaper.jpg" ]; then
    cp "$SCRIPT_DIR/assets/anime_wallpaper.jpg" "$HOME/.local/share/backgrounds/sakura_wallpaper.jpg"
    success "Wallpaper copiado para o diretório de mídias."
else
    # Fallback se executado fora do repositório
    log "Wallpaper local não encontrado. Baixando wallpaper de fallback..."
    wget -qO "$HOME/.local/share/backgrounds/sakura_wallpaper.jpg" "https://raw.githubusercontent.com/vinceliuice/WhiteSur-wallpapers/main/WhiteSur-dark.png"
fi

# 4. Baixar e Instalar o Tema WhiteSur GTK (macOS style)
log "Baixando e compilando o tema WhiteSur GTK..."
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

git clone --depth 1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git "$TEMP_DIR/whitesur-gtk"
cd "$TEMP_DIR/whitesur-gtk"
# Executar script instalando tema escuro com blur e barra macOS
./install.sh -t all -N -b -i apple -p 10 -d
./tweaks.sh -g
success "Tema WhiteSur GTK instalado com sucesso!"

# 5. Baixar e Instalar o Tema de Ícones WhiteSur
log "Baixando o tema de ícones WhiteSur..."
git clone --depth 1 https://github.com/vinceliuice/WhiteSur-icon-theme.git "$TEMP_DIR/whitesur-icons"
cd "$TEMP_DIR/whitesur-icons"
./install.sh -a -i apple
success "Ícones WhiteSur instalados com sucesso!"

# 6. Instalar Extensões do GNOME cruciais
install_gnome_extension() {
    local uuid=$1
    local url=$2
    log "Instalando extensão GNOME: $uuid..."
    
    local ext_dir="$HOME/.local/share/gnome-shell/extensions/$uuid"
    if [ -d "$ext_dir" ]; then
        log "A extensão $uuid já está instalada. Pulando."
        return
    fi

    mkdir -p "$ext_dir"
    wget -qO "$TEMP_DIR/ext.zip" "$url"
    unzip -q "$TEMP_DIR/ext.zip" -d "$ext_dir"
    rm -f "$TEMP_DIR/ext.zip"
    
    # Habilitar extensão via comando
    gnome-extensions enable "$uuid" || true
    success "Extensão $uuid instalada!"
}

# Dash to Dock (Versão genérica para GNOME 45+, caso use outra versão ela é atualizada)
log "Configurando extensões do GNOME Shell..."

# Dash to Dock
install_gnome_extension \
    "dash-to-dock@micxgx.gmail.com" \
    "https://github.com/micheleg/dash-to-dock/releases/download/extensions-v90/dash-to-dock@micxgx.gmail.com.v90.shell-extension.zip"

# Blur My Shell
install_gnome_extension \
    "blur-my-shell@aunetx" \
    "https://github.com/aunetx/blur-my-shell/releases/download/v47/blur-my-shell@aunetx.v47.shell-extension.zip"

# User Themes (Vem pré-instalado em gnome-shell-extensions, mas garantimos a ativação)
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com || true

# 7. Aplicar Configurações no GNOME com dconf
log "Aplicando configurações visuais do macOS no GNOME..."

# Posicionar botões de fechar/minimizar/maximizar na esquerda (estilo macOS)
dconf write /org/gnome/desktop/wm/preferences/button-layout "'close,minimize,maximize:'"

# Definir Temas
dconf write /org/gnome/desktop/interface/gtk-theme "'WhiteSur-Dark'"
dconf write /org/gnome/desktop/interface/icon-theme "'WhiteSur-dark'"
dconf write /org/gnome/desktop/interface/cursor-theme "'WhiteSur'"
dconf write /org/gnome/desktop/shell/extensions/user-theme/name "'WhiteSur-Dark'"

# Definir Wallpaper
dconf write /org/gnome/desktop/background/picture-uri "'file://$HOME/.local/share/backgrounds/sakura_wallpaper.jpg'"
dconf write /org/gnome/desktop/background/picture-uri-dark "'file://$HOME/.local/share/backgrounds/sakura_wallpaper.jpg'"
dconf write /org/gnome/desktop/screensaver/picture-uri "'file://$HOME/.local/share/backgrounds/sakura_wallpaper.jpg'"

# Configurações do Dash to Dock (Estilo macOS Dock)
dconf write /org/gnome/shell/extensions/dash-to-dock/dock-position "'BOTTOM'"
dconf write /org/gnome/shell/extensions/dash-to-dock/dash-max-icon-size 48
dconf write /org/gnome/shell/extensions/dash-to-dock/custom-theme-shrink true
dconf write /org/gnome/shell/extensions/dash-to-dock/extend-height false
dconf write /org/gnome/shell/extensions/dash-to-dock/background-opacity 0.2
dconf write /org/gnome/shell/extensions/dash-to-dock/multi-monitor true
dconf write /org/gnome/shell/extensions/dash-to-dock/click-action "'focus-minimize-or-previews'"
dconf write /org/gnome/shell/extensions/dash-to-dock/show-apps-at-top false
dconf write /org/gnome/shell/extensions/dash-to-dock/intellihide false

# Configurações de Fontes (Inter/Outfit se instaladas, senão padrão do sistema adaptada)
dconf write /org/gnome/desktop/interface/font-name "'Cantarell 11'"
dconf write /org/gnome/desktop/interface/document-font-name "'Cantarell 11'"
dconf write /org/gnome/desktop/interface/monospace-font-name "'Fira Code 10'"

success "Configurações do dconf aplicadas com sucesso!"

# 8. Customizar o Terminal Kitty
log "Configurando o Terminal Kitty com estilo macOS/Anime..."
cat <<EOF > "$HOME/.config/kitty/kitty.conf"
# Tema Minimalista SakuraOS
foreground            #f8f8f2
background            #1e1e2e
background_opacity     0.85
dynamic_background_opacity yes

# Fontes
font_family      Fira Code
bold_font        auto
italic_font      auto
bold_italic_font auto
font_size        11.0

# Margens e Bordas estilo Mac
window_padding_width 15
hide_window_decorations yes
confirm_os_window_close 0

# Cores Pastel (Tema Sakura/Catppuccin)
color0  #1e1e2e
color8  #585b70
color1  #f38ba8
color9  #f38ba8
color2  #a6e3a1
color10 #a6e3a1
color3  #f9e2af
color11 #f9e2af
color4  #89b4fa
color12 #89b4fa
color5  #f5c2e7
color13 #f5c2e7
color6  #94e2d5
color14 #94e2d5
color7  #bac2de
color15 #a6adc8
EOF
success "Terminal Kitty configurado com sucesso!"

# 9. Configurar o Fastfetch com Arte Anime ASCII
log "Configurando tela de boas-vindas do terminal (Fastfetch)..."
cat <<EOF > "$HOME/.config/fastfetch/config.jsonc"
{
  "\$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
  "logo": {
    "type": "small",
    "color": {
      "1": "magenta"
    }
  },
  "modules": [
    "title",
    "separator",
    "os",
    "host",
    "kernel",
    "uptime",
    "packages",
    "shell",
    "display",
    "de",
    "terminal",
    "cpu",
    "gpu",
    "memory",
    "colors"
  ]
}
EOF

# Configurar o Bash/Zsh para rodar o fastfetch automaticamente
if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "fastfetch" "$HOME/.bashrc"; then
        echo -e "\n# Boas vindas do SakuraOS\nif [ -x \$(command -v fastfetch) ]; then fastfetch; fi" >> "$HOME/.bashrc"
    fi
fi

success "Fastfetch configurado para inicializar com o terminal!"

# 10. Conclusão
echo -e "\n${PURPLE}====================================================${NC}"
echo -e "${GREEN}     SAKURAOS CONFIGURADO COM SUCESSO!              ${NC}"
echo -e "${PURPLE}====================================================${NC}"
echo -e "Instalação concluída. Para ver o resultado final:"
echo -e "1. Faça logout e login novamente para aplicar as extensões GNOME."
echo -e "2. Abra as configurações do GNOME e certifique-se de que os temas"
echo -e "   e as extensões (Blur my Shell, Dash to Dock) estão ativos."
echo -e "3. Divirta-se com seu novo desktop estilo macOS e Anime!\n"
