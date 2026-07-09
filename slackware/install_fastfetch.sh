#!/bin/bash
#
# build_fastfetch_latest.sh - Compila e instala o Fastfetch no Slackware

PRGNAM=fastfetch
VERSION=2.65.2
BUILD=${BUILD:-1}
TAG=${TAG:-_custom}
ARCH=x86_64

# Pasta temporária para a compilação
CWD=$(pwd)
TMP=${TMP:-/tmp/SBo}
PKG=$TMP/package-$PRGNAM
OUTPUT=${OUTPUT:-/tmp}

# Garante que o script roda como root
if [ "$EUID" -ne 0 ]; then
    echo "[ERRO] Este script precisa ser executado como ROOT."
    exit 1
fi

# Configura as pastas limpas antes de começar
rm -rf $PKG
rm -rf $TMP/fastfetch-$VERSION
mkdir -p $TMP $PKG $OUTPUT
cd $TMP

echo "=========================================================="
echo " Baixando o código-fonte do Fastfetch v$VERSION "
echo "=========================================================="
# A URL correta mantida exatamente como você definiu
URL="https://github.com/fastfetch-cli/fastfetch/archive/2.65.2/fastfetch-2.65.2.tar.gz"
wget -c "$URL" -O "$TMP/fastfetch-$VERSION.tar.gz"

echo "=========================================================="
echo " Descompactando e preparando o ambiente "
echo "=========================================================="
# Descompacta o arquivo tar.gz real
tar -xvf fastfetch-$VERSION.tar.gz

# Entra na pasta extraída gerada por essa URL do GitHub
cd fastfetch-$VERSION

# Ajusta permissões padrão de segurança Unix
chown -R root:root .
find . \
  \( -perm 777 -o -perm 775 -o -perm 711 -o -perm 555 -o -perm 511 \) \
  -exec chmod 755 {} \+ -o \
  \( -perm 666 -o -perm 664 -o -perm 600 -o -perm 444 -o -perm 440 -o -perm 400 \) \
  -exec chmod 644 {} \+

echo "=========================================================="
echo " Compilando com o CMake "
echo "=========================================================="
mkdir -p build
cd build
cmake \
  -DCMAKE_C_FLAGS:STRING="$SLKCFLAGS" \
  -DCMAKE_CXX_FLAGS:STRING="$SLKCFLAGS" \
  -DCMAKE_INSTALL_PREFIX=/usr \
  -DCMAKE_BUILD_TYPE=Release \
  ..
make
make install DESTDIR=$PKG

echo "=========================================================="
echo " Criando o pacote nativo do Slackware (.txz) "
echo "=========================================================="
if [ -d "$PKG/usr/man" ]; then
    find $PKG/usr/man -type f -exec gzip -9 {} \+
    for i in $(find $PKG/usr/man -type l) ; do ln -s $(readlink $i).gz $i.gz ; rm $i ; done
fi

# Cria a pasta de metadados obrigatória do Slackware
mkdir -p $PKG/install
cat << EOF > $PKG/install/slack-desc
# HOW TO EDIT THIS FILE:
# The "handy ruler" below makes it easier to edit a package description.
# Line up your text with the first character after the '|' on the lines
# below, and it will format nicely when installed via installpkg.

         |-----handy-ruler------------------------------------------------------|
$PRGNAM: $PRGNAM (Like neofetch, but much faster)
$PRGNAM:
$PRGNAM: Fastfetch is a neofetch-like tool for fetching system information.
$PRGNAM: It is written mainly in C, with performance and customization
$PRGNAM: in mind.
$PRGNAM:
$PRGNAM: Website: https://github.com/fastfetch-cli/fastfetch
$PRGNAM:
$PRGNAM:
$PRGNAM: Packaged by: Thiago M. Neves / Custom Build
$PRGNAM:
EOF

# Gera o pacote binário definitivo (.txz)
cd $PKG
/sbin/makepkg -l y -c n $OUTPUT/$PRGNAM-$VERSION-$ARCH-$BUILD$TAG.txz

echo "=========================================================="
echo " Instalando o pacote gerado... "
echo "=========================================================="
/sbin/removepkg $PRGNAM 2>/dev/null
/sbin/installpkg $OUTPUT/$PRGNAM-$VERSION-$ARCH-$BUILD$TAG.txz

echo "=========================================================="
echo " Instalação Concluída! Digite 'fastfetch' para testar. "
echo "=========================================================="

