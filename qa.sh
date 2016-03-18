#!/usr/bin/env bash
# author: Ovi Farcas.
echo -n "Type the site machine-name: "
read project

echo -n "Type the site branch name to perform qa on e.g feature/MULTISITE-1234, bugfix/WEBTOOLS2 or develop: "
read branch



username="farcaov"

echo "${CYAN}Initiating preparing $project for QA.${NO_COLOR}"

# Configure working directories
stash=~/www/stash
svn=~/www/svn
tmp=~/www/tmp

# Colors. 0 = Normal; 1 = Bold.
RED=$'\e[1;31m'
GREEN=$'\e[0;32m'
YELLOW=$'\e[0;33m'
BLUE=$'\e[0;34m'
MAGENTA=$'\e[0;35m'
CYAN=$'\e[0;36m'
NO_COLOR=$'\e[0m'


# Check there is a temp folder or create it.
function create_directories ()
{
   if [ ! -d "$tmp" ]; then
       mkdir $tmp
       chmod -R u+rwx $tmp
       cd $tmp
       mkdir $project
   elif [ ! -d "$svn" ]; then
       mkdir $svn
       chmod -R u+rwx $svn
   elif [ ! -d "$stash" ]; then
       mkdir $stash
       chmod -R u+rwx $stash
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


function fetch_stash_repository ()
{
  cd $stash
  if [ ! -d "$stash/${project}-dev" ]; then
    git clone https://${username}@webgate.ec.europa.eu/CITnet/stash/scm/multisite/${project}-dev.git
  fi
    cd ${project}-dev
    git branch -D ${branch}
    git reset --hard
    git clean -fd -n
    git clean -fd
    git branch -a | grep ${branch}
    git checkout -b ${branch} remotes/origin/${branch}
    git pull
    echo -e "${GREEN} ////////////////////////////////////////////////////////////////////////////////////////////////////////////////"
    echo "${YELLOW}Reference repository cloned to $stash/${project}-dev. We checkout the branch ${branch} ${NO_COLOR}"
    echo -e "${GREEN} ////////////////////////////////////////////////////////////////////////////////////////////////////////////////"
 }



function checks ()
{
echo -e "${CYAN}   Spot debug functions."
grep -Irin 'debug(\|dpm(\|dsm(\|dpq(\|kpr(\|print_r(\|var_dump(\|dps(' .

echo -e "${CYAN}   Inspect function prefixes.${NO_COLOR}"
grep -Irin 'function' > ~/check.function.report

echo -e "${CYAN}   Spot if error messages region was hidden. 5 line context included.${NO_COLOR}"
grep -Irin -A 2 -B 2 '$message' --include "*.tpl.php" .

echo -e "${CYAN}   Scan base fields declared in the features files.${NO_COLOR}"

declare -a arr=("$field_bases[" "locked" "datetime")

## now loop through the above array
for i in "${arr[@]}"
do
   # loop over code dangerous commands
   find . | grep "field_base.inc$" | xargs grep -Irins "$i"
done

#grep -Irin '$field_bases[' --include *field_base.inc .

echo -e "${GREEN} ////////////////////////////////////////////////////////////////////////////////////////////////////////////////"
echo -e "${CYAN}   Security checks.${NO_COLOR}"
echo -e "${GREEN} ////////////////////////////////////////////////////////////////////////////////////////////////////////////////${NO_COLOR}"

echo -e "${CYAN} Cross site scripting XSS.${NO_COLOR}"
grep -i -r "\$_GET" * | grep "echo"

echo -e "${CYAN} Command injection.${NO_COLOR}"
## declare an array variable
declare -a arr=("eval(" "fopen(" "passthru(" "exec(" "proc_" "dl(" "require($" "require_once($" "include($" "include_once($" "include($" "query(")

## now loop through the above array
for i in "${arr[@]}"
do
   # loop over code dangerous commands
   find . | grep "php$" | xargs grep -s "$i"
done

# You can access them using echo "${arr[0]}", "${arr[1]}" also

#grep -ir "exec\(" --exclude=*.min.js .
#grep -ir "eval\(" --exclude=*.min.js .


}

check_input "${project}"
check_input "${branch}"
git --version
grep -V
create_directories
fetch_stash_repository
checks
echo -e "${GREEN} ////////////////////////////////////////////////////////////////////////////////////////////////////////////////"
echo -e "${GREEN} // https://farcaov@webgate.ec.europa.eu/CITnet/stash/scm/multisite/${project}-dev.git"
echo -e "${GREEN} ////////////////////////////////////////////////////////////////////////////////////////////////////////////////"

