#!/bin/bash
#
# fix_vim_paste.sh - Desativa o controle agressivo de mouse do Vim no Slackware
# Autor: Thiago M. Neves (Adaptado)
#
# Este script resolve o erro de colagem (Paste) varrendo o sistema e
# injetando 'set mouse=' nos arquivos .vimrc individuais de todos os usuários.

# Cores para feedback visual no terminal
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Segurança: Exige execução como ROOT
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[ERRO] Este script precisa ser executado como ROOT.${NC}"
    exit 1
fi

LINE_TO_ADD="set mouse="

# Função auxiliar para aplicar a regra sem duplicar linhas no arquivo
apply_vimrc() {
    local TARGET_FILE="$1"
    local OWNER_USER="$2"

    # Cria o arquivo se ele não existir
    if [ ! -f "$TARGET_FILE" ]; then
        touch "$TARGET_FILE"
    fi

    # Verifica se a regra já existe para não poluir o arquivo
    if grep -q "^set mouse=" "$TARGET_FILE"; then
        echo -e "${YELLOW}[AVISO] Configuração já existe em '$TARGET_FILE'. Pulado.${NC}"
    else
        echo "$LINE_TO_ADD" >> "$TARGET_FILE"
        echo -e "${GREEN}[OK] Correção aplicada em: $TARGET_FILE${NC}"
        
        # Ajusta o dono do arquivo se for um usuário comum
        if [ -n "$OWNER_USER" ]; then
            chown "$OWNER_USER":"$OWNER_USER" "$TARGET_FILE"
        fi
    fi
}

echo "=========================================================="
echo " Corrigindo o Paste do Vim para todos os usuários "
echo "=========================================================="

# 1. Aplicar no ROOT
apply_vimrc "/root/.vimrc" "root"

# 2. Aplicar no Esqueleto (/etc/skel) para novos usuários futuros
apply_vimrc "/etc/skel/.vimrc" ""

# 3. Descobrir dinamicamente os usuários reais do sistema (/etc/passwd)
# Filtro: UID >= 1000 e que não terminam com /false ou /nologin
awk -F: '$3 >= 1000 && $7 !~ /nologin|false/ {print $1 ":" $6}' /etc/passwd | while IFS=":" read -r USERNAME HOMEDIR; do
    
    # Garante que o diretório home do usuário realmente existe antes de escrever
    if [ -d "$HOMEDIR" ]; then
        apply_vimrc "$HOMEDIR/.vimrc" "$USERNAME"
    fi
done

echo "=========================================================="
echo -e "${GREEN}Configuração concluída! O colar do Vim foi liberado para todos.${NC}"
