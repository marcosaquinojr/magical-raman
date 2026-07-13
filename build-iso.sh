#!/usr/bin/env bash
# build-iso.sh - Compila a ISO do SakuraOS mesclando nossas customizações com a base releng.
# Deve ser executado em um ambiente Linux (Arch Linux) com privilégios root.

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
   echo "[✗] Este script precisa ser executado como root (sudo)." >&2
   exit 1
fi

# Diretório base do repositório
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

# Caminho do perfil de compilação
BUILD_DIR="/tmp/sakuraos-profile"
WORK_DIR="/tmp/sakuraos-work"
OUT_DIR="$REPO_DIR/out"

# Garantir que ferramentas necessárias estão instaladas
if ! command -v mkarchiso &>/dev/null; then
    echo "[!] mkarchiso não encontrado. Instalando..."
    pacman -Sy --noconfirm archiso
fi

# Limpar compilações anteriores
echo "[1/4] Limpando ambiente de build antigo..."
rm -rf "$BUILD_DIR" "$WORK_DIR"
mkdir -p "$OUT_DIR"

# Copiar o perfil padrão do Arch Linux (releng)
echo "[2/4] Copiando perfil base do Arch Linux (releng)..."
if [ ! -d /usr/share/archiso/configs/releng ]; then
    echo "[✗] Perfil releng não encontrado em /usr/share/archiso/configs/releng." >&2
    exit 1
fi
cp -r /usr/share/archiso/configs/releng "$BUILD_DIR"

# Customizar o profiledef.sh dinamicamente para preservar compatibilidade de bootmodes
echo "[3/4] Customizando profiledef.sh e adicionando pacotes..."
sed -i 's/iso_name=.*/iso_name="sakuraos"/' "$BUILD_DIR/profiledef.sh"
sed -i 's/iso_label=.*/iso_label="SAKURAOS_'"$(date +%Y%m)"'"/' "$BUILD_DIR/profiledef.sh"
sed -i 's/iso_publisher=.*/iso_publisher="SakuraOS Project"/' "$BUILD_DIR/profiledef.sh"
sed -i 's/iso_application=.*/iso_application="SakuraOS Live\/Installation Media"/' "$BUILD_DIR/profiledef.sh"

# Adicionar permissões de arquivos para nossos scripts executáveis
echo 'file_modes+=([/usr/local/bin/sakura-init.sh]="0:0:0755" [/usr/local/bin/sakura-setup.sh]="0:0:0755")' >> "$BUILD_DIR/profiledef.sh"

# Adicionar pacotes customizados ao final da lista padrão
cat "$REPO_DIR/archiso/packages-sakura.txt" >> "$BUILD_DIR/packages.x86_64"

# Sobrescrever airootfs com as nossas pastas e arquivos customizados
echo "[3/4] Sobrepondo arquivos do SakuraOS no airootfs..."
mkdir -p "$BUILD_DIR/airootfs"
cp -rf "$REPO_DIR/archiso/airootfs/"* "$BUILD_DIR/airootfs/"

# Executar o mkarchiso
echo "[4/4] Iniciando compilação da ISO..."
mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" "$BUILD_DIR"

echo "[✓] SakuraOS compilado com sucesso! Arquivo ISO disponível em: $OUT_DIR"
