#!/bin/bash
echo -n "Type the project machine-name: "
read project
echo -n "Type JIRA ticket no. MULTISITE-: "
read jira

jira="MULTISITE-"$jira
echo "Initiating preparing $project under $jira ticket. "
echo "https://webgate.ec.europa.eu/CITnet/jira/browse/$jira"


# Configure working directories
# todo check if folder exists or else create them.
stash_directory=~/www/stash
svn_directory=~/www/svn
temp_directory=~/www/tmp

# Colors. 0 = Normal; 1 = Bold.
RED=$'\e[1;31m'
GREEN=$'\e[0;32m'
YELLOW=$'\e[0;33m'
BLUE=$'\e[0;34m'
MAGENTA=$'\e[0;35m'
CYAN=$'\e[0;36m'
NO_COLOR=$'\e[0m'

# Check there is a temp folder or create it.
 if [ ! -d "$temp_directory" ]; then
    mkdir -p $temp_directory
 fi



function command_exists ()
{
  type "$1" &> /dev/null ;
}

function check_input () {
 # Parameter #1 is zero length.
 args=("$@")
  if [ -z "$1" ]; then 
    echo "Parameter empty."
    exit 
  else
   echo "${CYAN} ${args[0]} OK. ${NO_COLOR}"
  fi
}


function fetch_stash_repository ()
{
  cd $stash_directory
  if [ -d "$stash_directory/${project}-reference" ]; then
    cd ${project}-reference
    git checkout master
    git reset --hard
    git clean -f -d
    git pull
    echo "${YELLOW}Updated repository. ${NO_COLOR}"
  else
    git clone https://farcaov@webgate.ec.europa.eu/CITnet/stash/scm/multisite/${project}-reference.git
    cd ${project}-reference
    echo "${YELLOW}Reference repository cloned to $stash_directory ${NO_COLOR}"
  fi



  # Delay 2 seconds
  sleep 2
  git status
  sleep 5
  #todo check coding standards
}

function prepare_what_to_deploy () 
{
 cp -R themes/ $temp_directory/$project
 cp -R modules/ $temp_directory/$project
 cp -R libraries/ $temp_directory/$project
 ls $temp_directory
 sleep 5
 #todo run make file
}

function prepare_svn ()
{
    cd svn_directory
    if [ -d "$project" ]; then
      svn up
    else
      mkdir -p $project
      svn co https://webgate.ec.europa.eu/CITnet/svn/MULTISITE/trunk/custom_subsites/$project
    fi
    
    cp -R temp_directory/$project  svn_directory/$project
    svn status

    #svn add * --force
    #svn commit -m "$jira" 
}
 


check_input "$project"
check_input "$jira"
command_exists "git"
fetch_stash_repository
#prepare_what_to_deploy
#prepare_svn
