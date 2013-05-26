#!/bin/ sh
# Author: Benoît Dunand-Laisin
# Version: 0.1
################
# Installe gitolite via ipkg sur un Nas synology
# Ce script a besoin de la clé publique de l'administrateur gitolite dans ./gitolite.pub

if [ "`basename $0`" != "synopostinstall.sh" ]
then
    echo "ERROR: Ce script ne devrait pas être exécuté directement"
    exit 1
fi

curdir=`dirname $0`

gocheck ipkg || exit $?
ipkg install coreutils || exit $?
ipkg install git || exit $?

for f in `ls /opt/bin/git*`
do
    ln -s $f /usr/bin     
done

synouser --add git git git 0 git@localhost.com 0 || exit $?

sed 's#HOME=.*$#HOME=/homes/git#' ~/.profile > /var/services/homes/git/.profile
chmod 644 /var/services/homes/git/.profile
chown git:users /var/services/homes/git/.profile
chmod 700 /var/services/homes/git

cp /etc/passwd /etc/passwd.synopostinstall.backup
sed 's#^git:\([^:]*\):\([^:]*\):\([^:]*\):\([^:]*\):\([^:]*\):\([^:]*\)$#git:\1:\2:\3:\4:\5:/bin/ash#' /etc/passwd.synopostinstall.backup > /etc/passwd || exit $?

cp $curdir/gitolite.pub /var/services/homes/git/
chown git:users /var/services/homes/git/gitolite.pub

su - git
(
    mkdir $HOME/bin
    git clone git://github.com/sitaramc/gitolite
    $HOME/gitolite/install -ln
    if [ -f $HOME/gitolite.pub ]
    then
        gitolite setup -pk $HOME/gitolite.pub
        rm -f $HOME/gitolite.pub
    else
        echo "ERROR: gitolite.pub absent"
        echo "> Il faut la copier sur le syno puis exécuter la commande suivante:"
        echo "> gitolite setup -pl gitolite.pub"
    fi
    exit 0
)
exit 0

