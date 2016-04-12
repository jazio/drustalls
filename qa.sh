#!/usr/bin/env bash
# author: Ovi Farcas.
echo -n "Type the site machine-name: "
read project

echo -n "Is it on stash or github: "
read repoplace

echo -n "Type the complete branch name to perform qa on e.g feature/MULTISITE-1234, or develop: "
read branch

echo "${CYAN}Initiating preparing $project for QA.${NO_COLOR}"

source config.sh

function fetch_stash_repository ()
{
  cd $stash
  if [ ! -d "$stash/${project}-dev" ]; then
    if [ $repoplace == *"github"* ]; then
       git clone https://github.com/ec-europa/${project}-dev.git -v
    else
       git clone https://${username}@webgate.ec.europa.eu/CITnet/stash/scm/multisite/${project}-dev.git -v
    fi
  fi
    cd ${project}-dev
    git pull
    echo -e "${GREEN} /////////////////////////////////////////////////////////////${repoplace}////////////////////////////////////////////////////////////////////"
    git clean -fd
    git branch -a | grep ${branch}
    git checkout -b ${branch}-local remotes/origin/${branch}
    git pull
    echo -e "${GREEN} ////////////////////////////////////////////////////////////////////////////////////////////////////////////////"
    echo "${YELLOW}Reference repository cloned to $stash/${project}-dev. We checkout the branch ${branch} ${NO_COLOR}"
    echo -e "${GREEN} ////////////////////////////////////////////////////////////////////////////////////////////////////////////////"
 }



function checks ()
{
echo -e "${CYAN}   Spot debug functions."
grep -Irin --color --exclude-dir="contrib" 'debug(\|dpm(\|dsm(\|dpq(\|kpr(\|print_r(\|var_dump(\|dps(' . 

echo -e "${CYAN}   Inspect function prefixes.${NO_COLOR}"
grep -Irin --color 'function' > ~/check.function.report

echo -e "${CYAN}   Spot if error messages region was hidden. 5 line context included.${NO_COLOR}"
grep -Irin -A 1 -B 1 --color '$message' --include="*.tpl.php" .

echo -e "${CYAN}   Scan base fields declared in the features files.${NO_COLOR}"

declare -a arr=("$field_bases[" "locked" "datetime")

## now loop through the above array
for i in "${arr[@]}"
do
   # Search inside field bases the arr values
   find . | grep "field_base.inc$" | xargs grep -Irins "$i"
done

# Function prefixes
grep -Irin '$field_bases[' --color --include *field_base.inc .

echo -e "${GREEN} ////////////////////////////////////////////////////////////////////////////////////////////////////////////////"
echo -e "${CYAN}   Security checks.${NO_COLOR}"
echo -e "${GREEN} ////////////////////////////////////////////////////////////////////////////////////////////////////////////////${NO_COLOR}"

echo -e "${CYAN} Cross site scripting XSS.${NO_COLOR}"
grep --color -i -r "\$_GET" * | grep "echo"

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

#grep -ir "exec\(" --exclude="*.min.js" .
#grep -ir "eval\(" --exclude="*.min.js" .


}

check_input "${project}"
check_input "${branch}"
git --version

create_directories
fetch_stash_repository
checks
echo -e "${GREEN} ////////////////////////////////////////////////////////////////////////////////////////////////////////////////"
echo -e "${GREEN} // https://farcaov@webgate.ec.europa.eu/CITnet/stash/scm/multisite/${project}-dev.git"
echo -e "${GREEN} ////////////////////////////////////////////////////////////////////////////////////////////////////////////////"

