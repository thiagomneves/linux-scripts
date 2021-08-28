#!/bin/bash
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Author:   Thiago Neves
# Email :   thiagomneves@protonmail.com


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
