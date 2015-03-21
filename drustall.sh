#!/usr/bin/env bash
# Output executed commands. Useful for debug.
# set -x
# Fail one command all fail.
# set -e
# Load variables.
source config.sh

function delete_drupal ()
{
  if [ -d "$webroot/$drupal_subdir" ]; then
    echo -n "${RED} Folder $drupal_subdir already exists. Delete it? (y/n): ${NO_COLOR}"
    read answer
    if [ "$answer" == "y" ]; then
      cd $webroot/$drupal_subdir
      drush sql-drop
      cd ..
      chmod 777 -R $drupal_subdir
      rm -rf $drupal_subdir
    else
      exit 1
    fi
  fi
}


function download_archive ()
{
  echo -n "${CYAN}Drupal 8 -dev version? y/n: ${NO_COLOR}"
  read dev
      if [ "$dev" == "y" ]; then
        # Clone the latest git repository = Drupal 8 dev version.
        git clone --branch 8.0.x http://git.drupal.org/project/drupal.git $webroot/$drupal_subdir;
      else
        # Fetch latest Drupal 8 version.
        wget http://ftp.drupal.org/files/projects/$file
        prepare_archive
      fi
 }

 function prepare_archive () {
        # Unpack.
        tar xzf $file
        # Rename folder.
        mv $drupal_package $drupal_subdir
        # Move it out of script folder.
        mv -f $drupal_subdir $webroot/
 }

delete_drupal
echo -n "${CYAN}Drupal version: ${NO_COLOR}"
read version

# Prerequisites.
if [ "$version" == "7" ]; then
     
     drush dl -y --destination=$webroot --drupal-project-rename=$drupal_subdir;
     
     
     make_file='drupal-org7.make'
     cp $make_file $webroot/$drupal_subdir;
     cd $webroot/$drupal_subdir;
     sudo chmod a+w sites/default
     cp sites/default/default.settings.php sites/default/settings.php
     chmod a+w sites/default/settings.php
     mkdir sites/default/files
     sudo chmod 777 -R sites/default/files
elif [ "$version" == "8" ]; then
        # Don't fetch archive if was already downloaded. Use the local archive.
         if [ -f $file ];
                      then
                        echo "${CYAN} Archive $file exists and will use it. ${NO_COLOR}"
                        archive=1
                        prepare_archive
                      else
                        echo "${CYAN} Archive $file does not exist and will download it. ${NO_COLOR}"
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
    echo "${CYAN} Enter either version 7 or 8: "
    exit 1
fi

# Install // profile = standard.
drush si -y standard --account-mail=$user_mail --account-name=$user_name --account-pass=$user_pass --site-name=$site_name --site-mail=$user_mail --db-url=mysql://$db_user:$db_pass@$db_host/$db_name;

# Modules and themes.
if [ "$version" == "7" ]; then
  drush make -v --no-core $make_file $webroot/$drupal_subdir;
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
  drush cc all -y
  drush php-eval 'node_access_rebuild();'
  # Create an initial dump
  drush sql-dump > $db_name
fi

# Write permissions after install.
if [ "$version" == "8" ]; then
        chmod go-w sites/default/settings.php
        chmod go-w sites/default/services.yml
        chmod go-w sites/default
else
        chmod 775 -R sies/all/default
fi
echo -e "${GREEN} ////////////////////////////////////////////////////"
echo -e "${GREEN} // Install Completed"
echo -e "${GREEN} // Your installation folder is $webroot/$drupal_subdir"
echo -e "${GREEN} // Your credentials are: user: $user_name / pass: $user_pass"
echo -e "${GREEN} ////////////////////////////////////////////////////"
