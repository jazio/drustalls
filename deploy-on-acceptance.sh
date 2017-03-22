# Author: Ovi Farcas

# debug on/off.
set -x


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
echo -e "${GREEN} Proxy connection set. ${NO_COLOR}"


# Variables
home_path=/ec/local/home/fpfis-test
multisite_path=/ec/local/home/fpfis-test/reference/php-clusters/multisite/stresstest/cluster00/sources/multisite/multisite_master_test.2.2/sites/



echo "${GREEN}  ////////////////////////   Initiating preparing $project for Acceptance . //////////////////////////////"
echo -n "State your username: "
read username
echo -n "State your site name e.g. growth: "
read site

function create_directories ()
{
   cd $home_path
   if [ ! -d "$username" ]; then
       mkdir -p ${username}
       chmod u+rwx -R ${username}
   else
       echo "Required username folders already created."
   fi

   cd $home_path/$username

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
  cd ${site}

  git branch -a
  echo "State the develop branch name to build: "
  read deploybranch
  git checkout deploybranch
  echo -e "${GREEN} Build start. ${NO_COLOR}"
  composer install
  cp build.properties.dist build.properties.local

  sed -i "s|drupal.db.name = db_name|drupal.db.name = ${site}|g" build.properties.local
  sed -i 's|drupal.db.user = root|drupal.db.user = admin|g' build.properties.local
  sed -i 's|drupal.db.password =|drupal.db.password = password|g' build.properties.local
  sed -i 's|composer.phar|/usr/local/bin/composer|g' build.properties.local
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

    cp -fr ${home_path}/${username}/{site}-reference/build/modules/features/ ./modules/
    cp -fr ${home_path}/${username}/{site}-reference/build/libraries/ ./
    cp -fr ${home_path}/${username}/{site}-reference/build/themes/ ./
}

create_directories
build
copy_acceptance

# Push things to the balancers.
#gacp

echo -e "${GREEN} ////////////////////////////////////////////////////////////////////////////////////////////////////////////////"
echo -e "${GREEN}  https://webgate.acceptance.ec.europa.eu/multisite/${site} ${NO_COLOR}"
echo -e "${GREEN} ////////////////////////////////////////////////////////////////////////////////////////////////////////////////"