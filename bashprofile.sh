#!/bin/bash
#
# append_bash_profile.sh - Garante o carregamento do .bashrc em todos os perfis
# Autor: Thiago M. Neves (Adaptado)
#
# Este script deve ser executado obrigatoriamente como ROOT.
# Ele cria ou adiciona a chamada do .bashrc no .bash_profile do root,
# de todos os usuários em /home e no esqueleto do sistema (/etc/skel).

# Cores básicas usando a lógica ANSI (para feedback visual)
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificação de segurança: Executado como root?
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[ERRO] Este script precisa ser executado como ROOT.${NC}"
    exit 1
fi

# Bloco de texto que será injetado
BLOCK=$(cat << 'EOF'

# Carrega o .bashrc caso ele exista (Adicionado via script)
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
EOF
)

# Função auxiliar para aplicar as alterações com segurança
apply_profile() {
    local TARGET_FILE="$1"
    local OWNER_USER="$2"
    
    # 1. Se o arquivo não existir, cria. Se existir, verifica se já tem o bloco para não duplicar.
    if [ ! -f "$TARGET_FILE" ]; then
        touch "$TARGET_FILE"
    fi

    if grep -q "if \[ -f ~/.bashrc \]; then" "$TARGET_FILE"; then
        echo -e "${YELLOW}[AVISO] O .bash_profile em '$TARGET_FILE' já possui esta configuração. Pulado.${NC}"
    else
        echo "$BLOCK" >> "$TARGET_FILE"
        echo -e "${GREEN}[OK] Configuração adicionada com sucesso em: $TARGET_FILE${NC}"
        
        # 2. Ajusta as permissões se for um arquivo de usuário para evitar problemas de acesso
        if [ -n "$OWNER_USER" ]; then
            chown "$OWNER_USER":"$OWNER_USER" "$TARGET_FILE"
        fi
    fi
}

echo "=========================================================="
echo " Atualizando o .bash_profile no Sistema "
echo "=========================================================="

# 1. Aplicar no ROOT (~/)
apply_profile "/root/.bash_profile" "root"

# 2. Aplicar no esqueleto do sistema (/etc/skel) para novos usuários futuros
apply_profile "/etc/skel/.bash_profile" ""

# 3. Aplicar em todos os usuários reais existentes dentro de /home
for USER_DIR in /home/*; do
    # Garante que é um diretório válido e ignora se o /home estiver vazio
    if [ -d "$USER_DIR" ]; then
        # Extrai o nome do usuário baseando-se no nome da pasta
        USERNAME=$(basename "$USER_DIR")
        apply_profile "$USER_DIR/.bash_profile" "$USERNAME"
    fi
done

echo "=========================================================="
echo -e "${GREEN}Processo concluído! Deslogue e logue novamente para testar.${NC}"
