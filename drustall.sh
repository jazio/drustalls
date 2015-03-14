#!/usr/bin/env bash

# Load variables.
source config.sh

if [ -d "$webroot/$drupal_subdir" ]; then
    echo "$RED Folder $drupal_subdir already exists. Please choose another one."
    exit 1
fi

function download_archive ()
{
  echo -n "$CYAN Drupal 8 -dev version? y/n: "
  read dev
      if [ "$dev" == "y" ]; then
        # Clone the latest git repository = Drupal 8 dev version.
        git clone --branch 8.0.x http://git.drupal.org/project/drupal.git $webroot/$drupal_subdir;
      else
        # Fetch latest Drupal 8 version.
        wget http://ftp.drupal.org/files/projects/$file
        # Unpack.
        tar xzf $file
        # Rename folder.
        mv $drupal_package $drupal_subdir
        # Move it out of script folder.
        mv -f $drupal_subdir $webroot/
      fi
 }

echo -n "$CYAN Drupal version: "
read version

# Prerequisites.
if [ "$version" == "7" ]; then
     
     drush dl -y --destination=$webroot --drupal-project-rename=$drupal_subdir;
     
     cd $webroot/$drupal_subdir;
     make_file='drupal-org7.make'
     sudo chmod a+w sites/default
     cp sites/default/default.settings.php sites/default/settings.php
     chmod a+w sites/default/settings.php
     mkdir sites/default/files
     sudo chmod 777 -R sites/default/files
elif [ "$version" == "8" ]; then
        # Don't fetch archive if was already downloaded. Use the local archive.
         if [ -f $file ];
                      then
                        echo "$CYAN Archive $file exists and will use it."
                        archive=1
                      else
                        echo "$CYAN Archive $file does not exist and will download it."
                        archive=0
                        download_archive
         fi
                    cd $webroot/$drupal_subdir
                    
                    # TEMPORARY PERMISSIONS - see INSTALL.txt.

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
    echo "$CYAN Enter either version 7 or 8: "
    exit 1
fi

# Install // profile = standard.
drush si -y standard --account-mail=$user_mail --account-name=$user_name --account-pass=$user_pass --site-name=$site_name --site-mail=$user_mail --db-url=mysql://$db_user:$db_pass@$db_host/$db_name;

# Modules and themes.
if [ "$version" == "7" ]; then
  drush make -v --no-core $make_file;
  #todo study --no-core
  #drush make -v $make_file $drupal_subdir;
  drush -y en \
    ctools \
    views \
    views_ui \
    token \
    jquery_update;

    # Disabled
  drush -y dis \
    color \
    shortcut \
    search;

  # Revoke group and other write permissions.
  chmod go-w sites/default/settings.php
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
        chmod 775 -R sies/all/default
fi
echo -e "$GREEN ////////////////////////////////////////////////////"
echo -e "$GREEN // Install Completed"
echo -e "$GREEN ////////////////////////////////////////////////////"
