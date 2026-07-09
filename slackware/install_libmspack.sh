cd /tmp
wget https://slackbuilds.org/slackbuilds/15.0/libraries/libmspack.tar.gz
tar -xvf libmspack.tar.gz
cd libmspack
source libmspack.info
wget $DOWNLOAD
chmod +x libmspack.SlackBuild
./libmspack.SlackBuild
installpkg /tmp/libmspack-*.tgz

rm -rf /tmp/libmspack*