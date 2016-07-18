#!/usr/bin/env bash
# The script automatize some of the QA checkrules over Drupal projects.
# author: Ovi Farcas.
# version: 1.0

echo -n "Type the site machine-name: "
read project

echo "////////////////////////   Initiating preparing $project for QA. //////////////////////////////"

# Basic variables.
username="verbral"
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

# Commmenting alias
[ -z $BASH ] || shopt -s expand_aliases
alias BEGINCOMMENT="if [ ]; then"
alias ENDCOMMENT="fi"


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

    # Memorize the credentials in the session cache for two hours.
    git config --global credential.helper "cache --timeout=7200"

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
  chmod +x resources/scripts/composer/post-install.sh
  composer install
  chmod +x vendor/ec-europa/reps-platform/post-install.sh
  cp build.properties.dist build.properties.local
  sed -i 's/composer.phar/\/usr\/local\/bin\/composer/g' build.properties.local
  ./bin/phing build-dist
}


function checks ()
{
 cd $github/${project}-reference/build/
 echo -e "Switched to build folder."
 echo -e "\r"

 # QA modules and themes
 echo -e "${GREEN}QA modules and themes."
 echo -e "\r"
 for i in $(find ! -path "*/contrib/*" ! -path "*/contributed/*"  -name \*.info); do
   # Set variables.
   filename="${i##*/}"
   path=$(dirname "${i}")

   # Output header for module.
   echo -e "${NO_COLOR}======================================================================"
   echo -n "${NO_COLOR}${NO_COLOR}$path: " ;  grep -oP "name\s=\s\K.*" "$i"
   echo -e "${NO_COLOR}======================================================================"
   echo -e "${MAGENTA}$i${NO_COLOR}"

   # Check multisite_version.
   if ! grep -I 'multisite_version\s=\s' "$i" ; then echo -e "${RED}multisite_version property missing!${NO_COLOR}" ; fi

   # Check if mandatory properties are present.
   if ! grep -I 'name\s=\s' "$i" ; then echo -e "${RED}name property missing!${NO_COLOR}" ; fi
   if ! grep -I 'description\s=\s' "$i" ; then echo -e "${RED}description property missing!${NO_COLOR}" ; fi
   if ! grep -I 'core\s=\s' "$i" ; then echo -e "${RED}core property missing!${NO_COLOR}" ; fi
   if ! grep -I 'php\s=\s' "$i" ; then echo -e "${RED}php property missing!${NO_COLOR}" ; fi

   # Check features_api version.
   if test -f "$path/${filename%.*}.features.inc" ; then
     if ! grep -I 'features\[features_api\]\[\] = api\:[0-9]' "$i" ; then echo -e "${RED}features_api property missing!${NO_COLOR}" ; fi 
   fi

   # Check if project and version properties have been removed.
   echo -n "${RED}" ; grep -I '^project\s=\s*' "$i" | sed "s/$/ ${NO_COLOR}(needs to be removed) /"
   echo -n "${RED}" ; grep -I '^version\s=\s*' "$i" | sed "s/$/ ${NO_COLOR}(needs to be removed) /"

   # Check if menu and php dependencies have been removed. And the tags taxonomy.
   echo -n "${RED}" ; grep -I '^dependencies\[\]\s=\smenu$' "$i" | sed "s/$/ ${NO_COLOR}(needs to be removed) /"
   echo -n "${RED}" ; grep -I '^dependencies\[\]\s=\sphp$' "$i" | sed "s/$/ ${NO_COLOR}(needs to be removed) /"
   echo -n "${RED}" ; grep -I '^features\[taxonomy\]\[\]\s=\stags$' "$i" | sed "s/$/ ${NO_COLOR}(needs to be removed) /"
   echo -e "\r"

   # Check the theme.
   if grep -q "^./themes" <<< "$i" ; then

     # Look at the stylesheet and script names.
     echo -n "${NO_COLOR}" ; grep -I "^stylesheets*=*" "$i" ;
     echo -n "${NO_COLOR}" ; grep -I "^scripts*=*" "$i" ;

     # Check for hidden messages region.
     echo -e "${GREEN}Spot if error messages region was hidden. 5 line context included.${NO_COLOR}"
     echo -e "\r"
     grep -Irin -A 1 -B 1 --color '$message' --include="*.tpl.php" .
     echo -e "\r" ;

   # For non themes.
   else
     # Only test for fields, permissions if it is a feature.
     if test -f "$path/${filename%.*}.features.inc" ; then
       # Check if all fields are locked.
       if ! grep -qr "field_base.inc$" "$path" ; then echo -e "${NO_COLOR}Check if all fields are locked: ${YELLOW}no fields.${NO_COLOR}" ; else
         if ! grep -qr "'locked' => 0" --include="*field_base.inc" "$path" ; then echo -e "${NO_COLOR}Check if all fields are locked: ${GREEN}all locked.${NO_COLOR}" ; else echo -e "${NO_COLOR}Check if all fields are locked: " ; grep -Irin  --color "'locked' => 0" --include="*field_base.inc" "$path" ; fi
       fi ;
       # Check if all date fields are of type datestamp.
       if ! grep -qr "field_base.inc$" "$path" ; then echo -e "${NO_COLOR}Check if all date fields are datestamp: ${YELLOW}no fields.${NO_COLOR}" ; else
         if ! grep -Iinqr "'module' => 'date'" --include="*field_base.inc" "$path"; then
           echo -e "${NO_COLOR}Check if all date fields are datestamp: ${YELLOW}no date fields.${NO_COLOR}"
         else
           if ! grep -qr "'type' => 'datetime'" --include="*field_base.inc" "$path" ; then echo -e "${NO_COLOR}Check if all date fields are datestamp: ${GREEN}all datestamp." ; else echo -e "${NO_COLOR}Non Drupal wrapper functions: " ; grep -Irin --color=always "_cron() {" "$path" ; fi
         fi
       fi
       # Check there are no more risky permissions.
       if ! grep -qr ".features.user_permission.inc$" "$path" ; then echo -e "${NO_COLOR}Check for risky permissions: ${YELLOW}no permissions.${NO_COLOR}" ; else
         permissions='administer modules\|administer software updates\|administer permissions\|administer features\|manage features\|administer ckeditor lite\|administer jquery update\|access devel information\|execute php code'
         if ! grep -qr "$permissions" "$path" ; then echo -e "${NO_COLOR}Check for risky permissions: ${GREEN}none present.${NO_COLOR}" ; else echo -e "\n${RED}Check for risky permissions: " ; grep -Irin  --color "$permissions" "$path" ; echo -e "\r" ; fi       
       fi
     fi
     # Look for cron hook.
     if ! grep -qr "*_cron() {" "$path" ; then echo -e "${NO_COLOR}Cron implementation in module: ${GREEN}not found.${NO_COLOR}" ; else echo -e "\n${RED}Cron implementation in module: " ; grep -Irin --color "*_cron() {" "$path" ; read cron ; echo -e "\r" ; fi
   fi
   # Check for left behind debugging functions.
   debug='debug(\|dpm(\|dsm(\|dpq(\|kpr(\|print_r(\|var_dump(\|dps('
   if ! grep -qr --exclude=\*.js "$debug" "$path" ; then echo -e "${NO_COLOR}Debugging functions in code: ${GREEN}none found.${NO_COLOR}" ; else echo -e "\n${RED}Debugging functions in code: " ; grep -Irin --color --exclude=\*.js "$debug" "$path" ; fi

   # Check for non Drupal wrapped functions.
   wrapper='(?<!drupal_)basename\(|(?<!drupal_)chmod\(|(?<!drupal_)dirname\(|(?<!drupal_)http_build_query\(|(?<!drupal_)json_decode\(|(?<!drupal_)json_encode\(|(?<!drupal_)mkdir\(|(?<!drupal_)move_uploaded_file\(|(?<!drupal_)parse_url\(|(?<!drupal_)realpath\(|(?<!drupal_)register_shutdown_function\(|(?<!drupal_)rmdir\(|(?<!drupal_)session_regenerate\(|(?<!drupal_)session_start\(|(?<!drupal_)set_time_limit\(|(?<!drupal_)strlen\(|(?<!drupal_)strtolower\(|(?<!drupal_)strtoupper\(|(?<!drupal_)substr\(|(?<!drupal_)tempnam\(|(?<!drupal_)ucfirst\(|(?<!drupal_)unlink\(|(?<!drupal_)xml_parser_create\('
   if ! grep -Pqr "$wrapper" "$path" --exclude=\*.js ; then echo -e "${NO_COLOR}Non Drupal wrapper functions: ${GREEN}none found.${NO_COLOR}" ; else echo -e "\n${RED}Non Drupal wrapper functions: " ; grep -IPrin --color --exclude=\*.js "$wrapper" "$path" ; echo -e "\r" ; fi
   echo -e "\r"

   # PHPCS check
   .././bin/phpcs --standard=.././vendor/drupal/coder/coder_sniffer/Drupal "$path"
 done
 echo -e "\r"

 # Coding standards report.
 .././bin/phpcs . > ${reports}/${project}_${branch}_code_violations.report 2>&1
 
 echo -e "${GREEN}//// Your report has been generated to ${reports}/sniff_${project}_${branch}.report /// ${NO_COLOR}"
 echo -e "\r"

 # Inspect function prefixes.
 echo -e "${GREEN}Inspect function prefixes.${NO_COLOR}"
 echo -e "\r"
 grep -Irin --color 'function' --exclude="*.js" > ${reports}/${project}_functions.report 2>&1
 echo -e "\r"

 echo -e "${GREEN} ////////////////////////////////////////////////////////////////////////////////////////////////////////////////"
 echo -e "${CYAN}   Security checks.${NO_COLOR}"
 echo -e "${GREEN} ////////////////////////////////////////////////////////////////////////////////////////////////////////////////${NO_COLOR}"

 echo -e "${GREEN} Cross site scripting XSS.${NO_COLOR}"
 if ! grep --color -ir '\$_GET' * | grep "echo" ; then echo -e "${CYAN} No $_GET parameters found." ; fi 

 echo -e "${GREEN} Command injection.${NO_COLOR}"

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
