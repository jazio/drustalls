#!/usr/bin/env bash
# The script automatize some of the QA checkrules over Drupal projects.
# author: Ovi Farcas.
# version: 1.0

echo -n "Type the site machine-name: "
read project

echo "////////////////////////   Initiating preparing $project for QA. //////////////////////////////"

# Basic variables.
username="farcaov"
webroot="/home/${username}/www"
github="${webroot}/github"
reports="${webroot}/reports"

# Colors. 0 = Normal; 1 = Bold.
RED=$'\e[1;31m'
GREEN=$'\e[0;32m'
YELLOW=$'\e[0;33m'
BLUE=$'\e[0;34m'
MAGENTA=$'\e[0;35m'
CYAN=$'\e[0;36m'
NO_COLOR=$'\e[0m'


# Projects are being check inside a folder therefore you can launch the script from any place.
function create_directories ()
{
   cd $webroot
   if [ ! -d "$github" ]; then
       mkdir -p ${github}
       chmod u+rwx -R ${github}
   elif [ ! -d "$reports" ]; then
       mkdir -p ${reports}
       chmod u+rwx -R ${reports}
   else
       echo "All required folders are created."
   fi
}

function check_input () {
 # Parameter #1 is zero length.
 args=("$@")
  if [ -z "$1" ]
    then
    echo "Parameter empty."
    exit
  else
   echo "${CYAN} ${args[0]}. ${NO_COLOR}"
  fi
}

function fetch_github_repository ()
{
  cd $github
    
  if [ ! -d "$github/${project}-reference" ]; then
       git clone https://github.com/ec-europa/${project}-reference.git
  fi
    cd ${project}-reference

    # Memorize the credentials in the session cache.
    git config --global credential.helper cache

    # Update master.
    git pull origin master

    # Configuration for including originated pull request branch in your local repository.
    git config --global --add remote.origin.fetch "+refs/pull/*/head:refs/remotes/origin/pr/*"
     
    # Now you can see originated[remote] pull requests.
    git remote show origin

    # Please choose which one is under QA analysis.
    echo -n "${GREEN}Select from the above refs/pull/NUM/head which pull request NUM is under your QA analysis: ${NO_COLOR}"
    read branch
    
    # Get the requested pullrequest and park it under local repository.
    git fetch origin 
    ${branch}=pr/${branch}
    git checkout pr/${branch}

    git branch -a | grep ${branch}
    git branch -d ${branch}-local
    git checkout -b ${branch}-local
    git log -3 --oneline --decorate --graph

    echo -e "${GREEN} ////////////////////////////////////////////////////////////////////////////////////////////////////////////////"
    echo -e "${YELLOW}  Cloned $github/${project}-reference then we parked the originated branch to be analysed: ${branch} ${NO_COLOR}"
    echo -e "${GREEN} ////////////////////////////////////////////////////////////////////////////////////////////////////////////////"
 }

function build ()
{
  cd $github/${project}-reference/
  composer install
  chmod +x vendor/ec-europa/reps-platform/post-install.sh
  cp build.properties.dist build.properties.local
  sed -i 's/composer.phar/\/usr\/bin\/composer/g' build.properties.local
  ./bin/phing build-dist
}


function checks ()
{
 cd $github/${project}-reference/build/
 echo -e "Switched to build folder."

 # Coding standards report.
 .././bin/phpcs . > ${reports}/${project}_${branch}_code_violations.report 2>&1
 
 echo -e "${GREEN}//// Your report has been generated to ${reports}/sniff_${project}_${branch}.report /// ${NO_COLOR}"

 echo -e "${CYAN}   Spot debug functions."
 grep -Irin --color --exclude-dir="contrib" 'debug(\|dpm(\|dsm(\|dpq(\|kpr(\|print_r(\|var_dump(\|dps(' . 

 echo -e "${CYAN}   Inspect function prefixes.${NO_COLOR}"
 grep -Irin --color 'function' --exclude="*.js" > ${reports}/${project}_functions.report 2>&1

 #todo check for the info files

 echo -e "${CYAN}   Spot if error messages region was hidden. 5 line context included.${NO_COLOR}"
 grep -Irin -A 1 -B 1 --color '$message' --include="*.tpl.php" .

 echo -e "${CYAN}   Scan base fields declared in the features files.${NO_COLOR}"
 
 # Check the field lock status and spot the non-timestamp date type fields
 declare -a arr=("$field_bases[" "locked" "datetime")

 for i in "${arr[@]}"
 do
   find . | grep "field_base.inc$" | xargs grep -Irins "$i"
 done

 grep -Irin '$field_bases[' --color --include="*field_base.inc" .

 echo -e "${GREEN} ////////////////////////////////////////////////////////////////////////////////////////////////////////////////"
 echo -e "${CYAN}   Security checks.${NO_COLOR}"
 echo -e "${GREEN} ////////////////////////////////////////////////////////////////////////////////////////////////////////////////${NO_COLOR}"

 echo -e "${CYAN} Cross site scripting XSS.${NO_COLOR}"
 grep --color -ir '\$_GET' * | grep "echo"

 echo -e "${CYAN} Command injection.${NO_COLOR}"

  declare -a arr=("eval(" "fopen(" "passthru(" "exec(" "proc_" "dl(" "require($" "require_once($" "include($" "include_once($" "include($" "query(")
  # Note. You can access them using echo "${arr[0]}", "${arr[1]}"...
  for i in "${arr[@]}"
    do
      # Spot dangerous commands.
      find . | grep "php$" | xargs grep -s "$i"
    done
}

# Runtime.
check_input "${project}"
create_directories
fetch_github_repository
build
checks


echo -e "${GREEN} ////////////////////////////////////////////////////////////////////////////////////////////////////////////////"
echo -e "${GREEN} // End of job."
echo -e "${GREEN} ////////////////////////////////////////////////////////////////////////////////////////////////////////////////"
