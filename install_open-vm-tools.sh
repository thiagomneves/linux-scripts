#!/bin/bash
# Script de automação para compilação e instalação do VMware open-vm-tools

# Define o caminho do seu script de instalação da libmspack
SCRIPT_MSPACK="wget https://raw.githubusercontent.com/thiagomneves/linux-scripts/master/slackware/install_libmspack.sh -q -O -| bash"

# Acessa o diretório temporário do sistema para isolar a compilação
cd /tmp

# Verifica se o sistema operacional é o Slackware
if [ -f /etc/slackware-version ]; then
    echo "=========================================================="
    echo " Sistema Slackware detectado."
    echo " Executando o instalador da libmspack via GitHub..."
    echo "=========================================================="
    
    # Baixa e executa o seu script do repositório direto na memória do Bash
    wget https://githubusercontent.com -q -O - | bash
else
    # Se não for Slackware, apenas exibe o aviso e segue o fluxo do script
    echo "=========================================================="
    echo " Este sistema não é o Slackware. Pulando a libmspack..."
    echo "=========================================================="
fi

# Acessa o diretório temporário do sistema para isolar a compilação
cd /tmp

# Remove qualquer resquício de clonagens anteriores para evitar conflitos de arquivos
rm -rf open-vm-tools

# Clona apenas o último commit da branch estável do repositório oficial da VMware
git clone --depth 1 https://github.com/vmware/open-vm-tools.git

# Entra na subpasta interna onde residem os arquivos de código-fonte e do Autotools
cd open-vm-tools/open-vm-tools

# Inicializa as ferramentas de automação GNU (gera os scripts locais do ambiente de build)
autoreconf -i

# Configura o plano de build desativando módulos integrados ao kernel e plugins ausentes no Slackware
./configure --without-kernel-modules --without-x --without-xmlsec1 --enable-containerinfo=no --disable-salt-minion --disable-vgauth

# Compila o código C/C++, instala na raiz (/usr/local) e atualiza os links das bibliotecas dinâmicas
make && make install && ldconfig

# Cria de forma automatizada o script de inicialização no modelo tradicional BSD do Slackware
cat << 'EOF' > /etc/rc.d/rc.open-vm-tools
#!/bin/sh
# Inicializador nativo do open-vm-tools no Slackware

if [ -x /usr/local/bin/vmtoolsd ]; then
    echo "Iniciando VMware Open VM Tools..."
    /usr/local/bin/vmtoolsd -b /var/run/vmtoolsd.pid
fi
EOF

# Garante a permissão de execução indispensável para que o script seja lido pelo sistema operacional
chmod +x /etc/rc.d/rc.open-vm-tools

# Verifica se a chamada do serviço já existe no rc.local para impedir linhas duplicadas no arquivo
if ! grep -q "rc.open-vm-tools" /etc/rc.d/rc.local; then
    cat << 'EOF' >> /etc/rc.d/rc.local

# Inicializacao do VMware open-vm-tools oficial
if [ -x /etc/rc.d/rc.open-vm-tools ]; then
    /etc/rc.d/rc.open-vm-tools
fi
EOF
fi

# Inicializa o daemon na memória imediatamente para ativar os recursos sem precisar de reboot
/usr/local/bin/vmtoolsd -b /var/run/vmtoolsd.pid
