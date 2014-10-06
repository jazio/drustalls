#!/usr/bin/env bash

# source command executes the file passed as argument in the current argument.
# It has synonim in '.'
source config8.sh

# Download Drupal 8
# ---------------------------------------------------------------------------


git clone --branch 8.0.x http://git.drupal.org/project/drupal.git $drupal_dir/$drupal_subdir;
cd $drupal_dir/$drupal_subdir;
# Install
# profile = standard
# @todo conditional in case credentials are wrong
drush si -y standard --account-mail=$user_mail --account-name=$user_name --account-pass=$user_pass --site-name=$site_name --site-mail=$user_mail --db-url=mysql://$db_user:$db_pass@$db_host/$db_name;

sudo chmod -R 777 $drupal_dir/$drupal_subdir/sites/default/settings.php;
sudo chmod 777 -R sites/default/files

# Modules and themes
drush make -v $make_file;


# Settings
#
# disable user pictures
#drush vset -y user_pictures 0;
# allow only admins to register users
#drush vset -y user_register 0;
# set site slogan
#drush vset -y site_slogan $site_slogan;


echo -e "////////////////////////////////////////////////////"
echo -e "// Install Completed"
echo -e "////////////////////////////////////////////////////"
while true; do
    read -p "press enter to exit" yn
    case $yn in
        * ) exit;;
    esac
done
