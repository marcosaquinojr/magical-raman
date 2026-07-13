#!/usr/bin/env bash
# build-docker.sh - Compila a ISO do SakuraOS usando Docker no macOS (ou Linux).
# Requer o Docker Desktop instalado e rodando.

set -euo pipefail

# Diretório base
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

echo "=== SakuraOS Docker Builder ==="
echo "Verificando se o Docker está rodando..."

if ! docker info &>/dev/null; then
    echo "[✗] Docker não está rodando. Por favor, inicie o Docker Desktop e tente novamente." >&2
    exit 1
fi

echo "[✓] Docker detectado!"
echo "Iniciando a compilação no container Arch Linux (isso pode levar de 5 a 15 minutos)..."

# Executa o container com privilégios para permitir montagem de loopback
# Força plataforma amd64 para garantir compatibilidade se estiver em um Mac M1/M2/M3
docker run --privileged \
    --platform linux/amd64 \
    --rm \
    -v "$REPO_DIR":/workspace \
    -w /workspace \
    archlinux:latest \
    bash -c "pacman -Syu --noconfirm && pacman -S --noconfirm archiso && ./build-iso.sh"

echo "=========================================="
if [ -d "$REPO_DIR/out" ] && [ "$(ls -A "$REPO_DIR/out")" ]; then
    echo "[✓] ISO Compilada com sucesso usando Docker!"
    echo "Sua ISO está em: $REPO_DIR/out/"
else
    echo "[✗] Ocorreu um erro e a ISO não foi gerada."
fi
echo "=========================================="
