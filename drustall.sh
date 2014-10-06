#!/usr/bin/env bash

# source command executes the file passed as argument in the current argument.
# It has synonim in '.'
source config.sh

# Download Drupal 7
# ---------------------------------------------------------------------------
drush dl -y --destination=$drupal_dir --drupal-project-rename=$drupal_subdir;
cd $drupal_dir/$drupal_subdir;

# Install
# profile = standard
# @todo conditional in case credentials are wrong
drush si -y standard --account-mail=$user_mail --account-name=$user_name --account-pass=$user_pass --site-name=$site_name --site-mail=$user_mail --locale="en-GB" --db-url=mysql://$db_user:$db_pass@$db_host/$db_name;

# Modules and themes
drush make -v $make_file $drupal_subdir;

# Enabled
drush -y en \
views \
views_ui \
token \
admin_menu \
jquery_update;

# Disabled
drush -y dis \
color \
toolbar \
shortcut \
search;

# Settings
#
# disable user pictures
#drush vset -y user_pictures 0;
# allow only admins to register users
#drush vset -y user_register 0;
# set site slogan
#drush vset -y site_slogan $site_slogan;

# Configure JQuery update
#drush vset -y jquery_update_compression_type "min";
#drush vset -y jquery_update_jquery_cdn "google";
#drush -y eval "variable_set('jquery_update_jquery_version', strval(1.7));"
<<<<<<< HEAD
=======

# Flush cache and rebuild access
drush cc all
drush php-eval 'node_access_rebuild();'
>>>>>>> c3f68990b76cf10fd1a16d5cdb26c23e291a7149

echo -e "////////////////////////////////////////////////////"
echo -e "// Install Completed"
echo -e "////////////////////////////////////////////////////"
while true; do
    read -p "press enter to exit" yn
    case $yn in
        * ) exit;;
    esac
done
