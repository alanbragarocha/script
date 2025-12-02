#!/bin/bash

# Função para mostrar o uso do script
usage() {
    echo "Uso: $0 [DIRETÓRIO_DESTINO]"
    echo "Se nenhum diretório for especificado, será usado ~/backups"
    exit 1
}

# Diretório de destino do backup
BACKUP_DIR="${1:-$HOME/backups}"

# Criar diretório de backups se não existir
mkdir -p "$BACKUP_DIR"

# Nome do arquivo de backup com timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/config_backup_$TIMESTAMP.zip"

# Pastas para backup
FOLDERS=(
    ".claude"
    ".cursor"
    ".gemini"
    ".config/Cursor"
)

# Mudar para o diretório home para preservar paths relativos no zip
cd "$HOME"

# Verificar se as pastas existem antes de tentar fazer backup
VALID_FOLDERS=()
for folder in "${FOLDERS[@]}"; do
    if [ -d "$folder" ]; then
        VALID_FOLDERS+=("$folder")
    else
        echo "Pasta não encontrada: $folder"
    fi
done

# Fazer backup das pastas
if [ ${#VALID_FOLDERS[@]} -gt 0 ]; then
    echo "Criando backup das seguintes pastas:"
    printf '%s\n' "${VALID_FOLDERS[@]}"

    # Usar zip com opções para preservar simbolic links e paths relativos
    zip -r "$BACKUP_FILE" "${VALID_FOLDERS[@]}"

    echo "Backup criado em: $BACKUP_FILE"
else
    echo "Nenhuma pasta válida encontrada para backup."
    exit 1
fi
