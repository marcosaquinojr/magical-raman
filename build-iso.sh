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
    echo "[✗] Perfil releng não encontrado em /usr/share/archiso/configs/releng. Certifique-se de que o pacote archiso está instalado corretamente." >&2
    exit 1
fi
cp -r /usr/share/archiso/configs/releng "$BUILD_DIR"

# Sobrescrever com nossas customizações
echo "[3/4] Sobrepondo customizações do SakuraOS..."
cp -rf "$REPO_DIR/archiso/"* "$BUILD_DIR/"

# Executar o mkarchiso
echo "[4/4] Iniciando compilação da ISO..."
mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" "$BUILD_DIR"

echo "[✓] SakuraOS compilado com sucesso! Arquivo ISO disponível em: $OUT_DIR"
