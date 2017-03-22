#!/usr/bin/env bash
#############################################################
# Scope: Deploy a specific project's branch into acceptance
# Author: @jazio
#############################################################

# debug on/off.
# set -x


# Colors. 0 = Normal; 1 = Bold.
RED=$'\e[1;31m'
GREEN=$'\e[0;32m'
YELLOW=$'\e[0;33m'
BLUE=$'\e[0;34m'
MAGENTA=$'\e[0;35m'
CYAN=$'\e[0;36m'
NO_COLOR=$'\e[0m'

# Set up connection.
source ~/.proxyrc
echo -e "${CYAN} Proxy connection set. ${NO_COLOR}"

echo "${GREEN}  ////////////////////////   Initiating preparing project for Acceptance. ////////////////////////////// ${NO_COLOR}"




echo -n "State your username: "
read username

echo -n "State your site name e.g. growth: "
read site

# Create user specific folder.
function create_directories ()
{
   cd $home_path
   if [ ! -d "$username" ]; then
       mkdir -p ${username}
       chmod u+rwx -R ${username}
   else
       echo "${GREEN} Required $username folder already created. ${NO_COLOR}"
   fi
}


# Configuration file.

  home_path=$(echo $HOME)
  my_home_path = ${home_path}/${username}
  echo "Your current home is ${my_home_path}"

  # Default variables.
  multisite_path=/ec/local/home/fpfis-test/reference/php-clusters/multisite/stresstest/cluster00/sources/multisite/multisite_master_test.2.2/sites/
  my_branch=master
  github_username=ec-europa

  # /ec/local/home/fpfis/util/php/current/bin/composer

  composer_path=$(which composer)

  cd ${my_home_path}

  # Create and construct configuration.
  if [ ! -f acceptance.conf ]; then
         touch -p acceptance.conf
         chmod u+rwx -R ${username}
         echo username=${username} > acceptance.conf
         echo site=${site} >> acceptance.conf
         echo my_home_path=${my_home_path} >> acceptance.conf
         echo multisite_path=${multisite_path} >> acceptance.conf
         echo my_branch=${my_branch} >> acceptance.conf
         echo github_username=${github_username} >> acceptance.conf
         echo composer_path=${composer_path} >> acceptance.conf
  else
       echo "Your configuration is as follows"
       cat acceptance.conf
  fi

  echo "Do you want to edit your configuration file? y/N"
  read edit

    if [ "$edit" == "y" ]; then
            echo "Edit configuration and relaunch the script"
            exit
    else
      # Load configuration.
      source acceptance.conf
    fi



function clone()
{
   cd ${my_home_path}

   if [ ! -d "$site" ]; then
        git clone https://github.com/ec-europa/${site}-reference.git ${site}
        cd ${site}
    else
        cd ${site}
        git pull
    fi
}


# Build platform.
function build ()
{
  cd ${my_home_path}/${site}

  git checkout  ${branch}

  echo -e "${GREEN} Build start. ${NO_COLOR}"
  composer install

  # Set permission on platform post-install.
  chmod -R 777 vendor/ec-europa/reps-platform/post-install.sh

  cp build.properties.dist build.properties.local

  sed -i "s|drupal.db.name = db_name|drupal.db.name = ${site}|g" build.properties.local
  sed -i 's|drupal.db.user = root|drupal.db.user = admin|g' build.properties.local
  sed -i 's|drupal.db.password =|drupal.db.password = password|g' build.properties.local
  sed -i 's|composer.phar|{$composer_path}|g' build.properties.local
  sed -i 's|subsite.install.modules = myproject_core|subsite.install.modules = devel|g' build.properties.local

  alias phing='./bin/phing'
  ./bin/phing
  ./bin/phing build-dist
}

function copy_acceptance ()
{
    cd ${multisite_path}/${site}
    echo "Do you want to remove existing features, themes? Y/n: "
    read remove_folder

    if [ "$remove_folder" == "y" ]; then
            rm -rf ""
    fi

    cp -fr ${my_home_path}/{site}/build/modules/ ./modules/
    cp -fr ${my_home_path}/{site}/build/libraries/ ./
    cp -fr ${my_home_path}/{site}/build/themes/ ./

    git status
    # Push to the load balancers.
    gacp
}


function clean_cache () {
 cd ${multisite_path}/${site}
 drush rr
 echo -e "${GREEN} ////////////////////////////////////////////////////////////////////////////////////////////////////////////////"
 echo -e "${GREEN}  Your site is ready at https://webgate.acceptance.ec.europa.eu/multisite/${site} ${NO_COLOR}"
 echo -e "${GREEN} ////////////////////////////////////////////////////////////////////////////////////////////////////////////////"
}

# Run time.
create_configuration
clone
build
copy_acceptance
clean_cache



