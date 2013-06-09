#!/bin/sh
# Author: Benoît Dunand-Laisin
################
# Installe gitolite via ipkg sur un Nas synology
# Ce script a besoin de la clé publique de l'administrateur gitolite dans ./gitolite.pub

curmod="gitolite par ipkg"
curshell=`basename $0`
curdir=`dirname $0`

git_user=git
git_cmd=/tmp/git_$$.sh

if [ "${curshell}" != "synopostinstall.sh" ]
then
    echo "ERROR: Ce module (${curmod}) ne devrait pas être exécuté directement"
    exit 1
fi

golog "Installation de ${curmod}"
gocheck ipkg || exit $?
ipkg install coreutils || exit $?
ipkg install git || exit $?

for f in `ls /opt/bin/git*`
do
    ln -s $f /usr/bin     
done

if [ `synouser --get ${git_user} 2>&1 1>/dev/null` = 0 ]
then
    golog "Création de l'utilisateur ${git_user}"
    synouser --add ${git_user} ${git_user} ${git_user} 0 ${git_user}@localhost.com 0 || exit $?
else
    golog "Utilisateur ${git_user} déjà présent"
fi

golog "Paramétrage de l'utilisateur ${git_user}"
git_home=/var/services/homes/${git_user}
sed 's#HOME=.*$#HOME='${git_home}'#' ~/.profile > ${git_home}/.profile
chmod 644 ${git_home}/.profile
chown ${git_user}:users ${git_home}/.profile
chmod 700 ${git_home}

cp /etc/passwd /etc/passwd.synopostinstall.backup
sed 's#^git:\([^:]*\):\([^:]*\):\([^:]*\):\([^:]*\):\([^:]*\):\([^:]*\)$#git:\1:\2:\3:\4:\5:/bin/ash#' /etc/passwd.synopostinstall.backup > /etc/passwd || exit $?

cp ${curdir}/gitolite.pub ${git_home}/
chown ${git_user}:users ${git_home}/gitolite.pub

golog "Connexion à l'utilisateur ${git_user} pour initialisation de gitolite"

echo "#!/bin/sh
    mkdir ${git_home}/bin 2>/dev/null
    git clone git://github.com/sitaramc/gitolite
    ${git_home}/gitolite/install -ln
    if [ -f ${git_home}/gitolite.pub ]
    then
        ${git_home}/bin/gitolite setup -pk ${git_home}/gitolite.pub
        rm -f ${git_home}/gitolite.pub
    else
        echo \"WARNING: gitolite.pub absent\"
        echo \"> Il faut la copier sur le syno puis exécuter la commande suivante:\"
        echo \"> gitolite setup -pk gitolite.pub\"
    fi
    exit 0
" > ${git_cmd}
su - ${git_user} < ${git_cmd}
rm -f ${git_cmd}
exit 0

