#!/usr/bin/env bash

# source command executes the file passed as argument in the current argument.
# It has synonim in '.'
source config.sh


echo -n "Drupal version: "
read version

# Prerequisites.
# @todo test if archive is also in the upper directory.
if [ "$version" == "7" ]; then
     drush dl -y --destination=$htdocs --drupal-project-rename=$drupal_subdir;
     cd $htdocs/$drupal_subdir;
     make_file='drupal-org7.make'
     sudo chmod -R 777 $htdocs/$drupal_subdir/sites/default/settings.php;
     sudo chmod 777 -R sites/default/files
elif [ "$version" == "8" ]; then
      
      # Check if file has a
      if [ -f $file ];
        then
          echo "Archive $file exists and will use it."
        else
          echo "Archive $file does not exist and will download it."
          wget http://ftp.drupal.org/files/projects/$file
          # Alternative source git.
          #git clone --branch 8.0.x http://git.drupal.org/project/drupal.git $htdocs/$drupal_subdir;
      fi

      # Unpack.
      tar xzf $file
      # Rename folder.
      mv $drupal_package $drupal_subdir
      # Move it out of script folder.
      mv -f $drupal_subdir $htdocs/
      cd $htdocs/$drupal_subdir

      # TEMPORARY PERMISSIONS - see INSTALL.txt

      # Grant w permission to all.
      sudo chmod a+w sites/default

      # Create files folder.
      mkdir sites/default/files
      sudo chmod a+w sites/default/files
      
      # Missing settings and services files.
      cp sites/default/default.settings.php sites/default/settings.php
      cp sites/default/default.services.yml sites/default/services.yml
      sudo chmod a+w sites/default/settings.php
      sudo chmod a+w sites/default/services.yml
else
    echo "Enter either version 7 or 8"
    exit 1
fi


# Install // profile = standard.
drush si -y standard --account-mail=$user_mail --account-name=$user_name --account-pass=$user_pass --site-name=$site_name --site-mail=$user_mail --db-url=mysql://$db_user:$db_pass@$db_host/$db_name;

# Modules and themes.
if [ "$version" == "7" ]; then
  drush make -v $make_file;
  #todo study --no-core
  #drush make -v $make_file $drupal_subdir;
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

    # Flush cache and rebuild access.
    drush cc all
    drush php-eval 'node_access_rebuild();'
fi

# Write permissions after install.
if [ "$version" == "8" ]; then
        chmod go-w sites/default/settings.php
        chmod go-w sites/default/services.yml
        chmod go-w sites/default
else
        chmod 775 -R sites/all/default
fi
echo -e "////////////////////////////////////////////////////"
echo -e "// Install Completed"
echo -e "////////////////////////////////////////////////////"
