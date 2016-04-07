#!/usr/bin/env bash
# author: Ovi Farcas.
echo -n "Type the stash repo machine-name: "
read project
echo -n "Type JIRA ticket e.g. MULTISITE-1234: "
read jira

username="farcaov"

echo "Initiating preparing $project under $jira ticket. "
echo "https://webgate.ec.europa.eu/CITnet/jira/browse/$jira"


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


function command_exists ()
{
  type "$1" &> /dev/null
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
  if [ -d "$stash/${project}-reference" ]; then
    cd ${project}-reference
    git checkout master
    git reset --hard
    #git clean -fd -n
    git clean -fd
    git pull
    echo "${YELLOW}Updated repository. ${NO_COLOR}"
  else
    git clone https://${username}@webgate.ec.europa.eu/CITnet/stash/scm/multisite/${project}-reference.git
    cd ${project}-reference
    echo "${YELLOW}Reference repository cloned to $stash/${project}-reference ${NO_COLOR}"
  fi

  # Delay 2 seconds.
  sleep 2
  git status
  sleep 5
  git log -3 --oneline --decorate --graph
  #todo check coding standards
}

function prepare_what_to_deploy () 
{    

  if [ -d "$svn/${project}" ]; then
       rm -rf $svn/$project
  fi
 
  # Delete the tmp folder.
  rm -rf $tmp/$project
  mkdir $tmp/$project
  cd $stash/${project}-reference

  if [ -d "$stash/${project}-reference/themes" ]; then
    mkdir $tmp/$project/themes
    cp -R themes/ $tmp/$project/
  fi
  if [ -d "$stash/${project}-reference/modules" ]; then
    mkdir $tmp/$project/modules
    cp -R modules/ $tmp/$project/
  fi
  if [ -d "$stash/${project}-reference/libraries" ]; then
    mkdir $tmp/$project/libraries
    cp -R libraries/ $tmp/$project/
  fi
  # When starterkit is available.
  if [ -d "$stash/${project}-reference/lib" ]; then
    mtkdir $tmp/$project/themes/
    cd $stash/${project}-reference/lib
    cp -R themes/ $tmp/$project
    mkdir $tmp/$project/modules
    cp -R modules/ $tmp/$project
    cp -R features $tmp/$project/modules
  fi
  # Run make file
  if [ -d "$stash/${project}-reference/resources" ] && [ -a "$stash/${project}-reference/resources/site.make"]; then
    cd $stash/${project}-reference/resources
    drush make site.make --no-core
    mv -R ./site/all/modules/contrib $tmp/project/modules
  fi
  
}


function prepare_svn ()
{
     cd $svn
     echo -n "${GREEN} What is the svn repo name ? (y/n): ${NO_COLOR}"
     read svn_repo
      svn co https://webgate.ec.europa.eu/CITnet/svn/MULTISITE/trunk/custom_subsites/${svn_repo}
      cd $svn/${svn_repo}

      # Cleanup of old svn junk.
      echo -e "${RED} ////////////////////////////////////////////////////////////////////////////////////////////////////////////////"
      echo -e "${RED} Do you want to remove project from svn before committing? Choose no if unsure."
      echo -e "${RED} //////////////////////////////////////////////////////////////////////////////////////////////////////////////// ${NO_COLOR}"
      echo -n "${RED} WARNING Confirm svn remove y/n:"
      read delete
      if [ "$delete" == y ]; then
        svn rm *
        # Tip to resolve ! prefixed file in the svn status report.
        svn status | grep "^\!" | sed 's/^\! *//g' | xargs svn rm
      fi
    # IMPORTANT Copy project to svn folder.
    cp -fr $tmp/$project  $svn
}

function commit_svn ()
{
    # todo commit only after checking if the folder not empty.
    cd $svn/$project
    svn add * --force
    echo "${RED}You are about to SVN commit:${NO_COLOR}"
    svn status
    echo -n "${GREEN} Commit folder svn $svn/$project to server ? (y/n): ${NO_COLOR}"
    read answer

    if [ "$answer" == "y" ]; then
       svn commit -m "$jira"
    else
      echo "Project not deployed. Check $svn/$project folder"
      exit 1
    fi
}
 
check_input "$project"
check_input "$jira"
git --version
create_directories
fetch_stash_repository
prepare_what_to_deploy
prepare_svn
commit_svn
echo -e "${GREEN} ////////////////////////////////////////////////////////////////////////////////////////////////////////////////"
echo -e "${GREEN} // Check your svn here: https://webgate.ec.europa.eu/CITnet/svn/MULTISITE/trunk/custom_subsites/$project"
echo -e "${GREEN} ////////////////////////////////////////////////////////////////////////////////////////////////////////////////"
