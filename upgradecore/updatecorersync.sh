#!/bin/bash
#
# Upgrades/Installs Drupal core. Targeted at Drupal 6
# Script based on gopressflow.sh
# @see https://gist.github.com/zerolab/4733662
#
# * Run this script in your DRUPAL_ROOT
# * Backup your files before doing anything!
#

if [ -n "$1" ]; then
  curl -C - -O http://ftp.drupal.org/files/projects/drupal-$1.tar.gz
  tar -zxvf drupal-$1.tar.gz
  rm drupal-$1.tar.gz
else
  echo "You must specify a Drupal core version. (e.g. 6.27)"
  exit 1
fi
mv drupal-$1 drupal-core
# mv drupal-core/*.txt ./
mv drupal-core/*.php ./
mv .htaccess .htaccess.old
mv drupal-core/.htaccess ./
rsync -avzpP --delete drupal-core/includes ./
rsync -avzpP --delete drupal-core/misc ./
rsync -avzpP --delete drupal-core/modules ./
rsync -avzpP --delete drupal-core/profiles ./
rsync -avzpP --delete drupal-core/scripts ./
# rsync -avzpP drupal-core/sites ./
rsync -avzpP --delete drupal-core/themes ./
rm -rf drupal-core
