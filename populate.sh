#!/usr/bin/env bash
# Output executed commands. Useful for debug.
# set -x
# Fail one command all fail.
# set -e
# Load variables.
source config.sh

echo -e "${GREEN} ////////////////////////////////////////////////////"
echo -e "${GREEN} // This script will enable debug tools and will populate the Drupal 7 with dummy data"
echo -e "${GREEN} ////////////////////////////////////////////////////"

# Copy custom drush command into devel module folder
drush_command=publish.drush.inc

if [ -f $drush_command ];
    then
       echo "${CYAN} $drush_command will be copied in ~/.drush folder. ${NO_COLOR}"
       #cp -vf $drush_command $webroot/$drupal_subdir/sites/all/modules/devel
       if ! [ -d ~/.drush ];
          then
          mkdir ~/.drush
       fi
       cp -vf $drush_command ~/.drush
       drush cache-clear drush
    else
       echo "${CYAN} $drush_command does not exist. ${NO_COLOR}"
fi


cd $webroot/$drupal_subdir
drush dl devel -y
drush en devel -y
drush en realistic_dummy_content -y
drush en devel_generate -y
# Generate content
drush genc 20 10 --kill --types=article
# Publish content.
drush pc article




