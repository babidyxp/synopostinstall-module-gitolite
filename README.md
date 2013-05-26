synopostinstall-module-gitolite
===============

Script d'installation de gitolite via ipkg sur un NAS Synology

## Description
Ce script s'exécute en tant que module de synopostinstall (voir <http://github.com/Benoit-DunandLaisin/synopostinstall>)

Pour fonctionner correctemennt, il est nécessaire de stocker dans le répertoire du module, la clé publique de l'administateur de gitolite.
La clé doit se nommer gitolite.pub

## Liens sources
Ce script a été créé à partir des guides ci-dessous:

- <http://www.bluevariant.com/2012/05/comprehensive-guide-git-gitolite-synology-diskstation/>
- <http://ti57.blogspot.fr/2013/01/how-to-setup-git-server-on-synology-nas.html>

## Détail des branches
- master : Branche contenant des scripts stables (source à préférer donc)
- testing : Dépôt contenant des scripts non testé (sources à éviter, sauf pour les retravailler)
