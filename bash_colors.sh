#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

UserConfig="
##
# LR:Personalizando o prompt do sistema
##
if [[ $UID -ne 0 ]]; then
   export PS1='\[\e[1;32m\]\u\[\e[m\]@\[\e[1;33m\]\h\[\e[m\]:\[\e[1;34m\]\W\[\e[m\]\[\e[0;37m\]\$\[\e[m\] '
else
   export PS1='\[\e[1;32m\]\u\[\e[m\]@\[\e[1;33m\]\h\[\e[m\]:\[\e[1;34m\]\W\[\e[m\]\[\e[0;31m\]\$\[\e[m\] '
fi
"
RootConfig="

##
# LR:Personalizando o prompt do sistema
##if [[ $UID -ne 0 ]]; then
   export PS1='\[\e[1;31m\]\u\[\e[m\]@\[\e[1;33m\]\h\[\e[m\]:\[\e[1;34m\]\W\[\e[m\]\[\e[0;37m\]\$\[\e[m\] '
else
   export PS1='\[\e[1;31m\]\u\[\e[m\]@\[\e[1;33m\]\h\[\e[m\]:\[\e[1;34m\]\W\[\e[m\]\[\e[0;31m\]\$\[\e[m\] '
fi
"
HumanUsers=`cut -d: -f1,3 /etc/passwd | egrep ':[0-9]{4}$' | cut -d: -f1`

for user in $HumanUsers; do
    UserDir=`cat /etc/passwd | grep $user | awk -F ':' '{print $6}'`
    if [ -d "$UserDir" ]; then
        echo "$UserConfig" >> $UserDir/.bashrc
    fi
done
echo "$UserConfig" >> /etc/skel/.bashrc
echo "$UserConfig" >> /root/.bashrc
