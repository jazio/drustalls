#t !/usr/bin/env bash
# author: Ovi Farcas.
# @todo adapt to github and starter-kit
echo -n "Type JIRA ticket e.g. MULTISITE-1234: "
read jira

echo -n "Type the stash repo machine-name: "
read stash_repo

echo -n "Type the svn repo machine-name ?: "
read svn_repo

# Configuration.
username="farcaov"
webroot="/home/farcaov/www/"
stash="${webroot}/stash"
svn="${webroot}/svn"
tmp="${webroot}/tmp"

echo "Initiating preparing $stash_repo under $jira ticket. "
echo "https://webgate.ec.europa.eu/CITnet/jira/browse/$jira"

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
   cd $webroot
   if [ ! -d "$tmp" ]; then
       mkdir $tmp
       chmod -R u+rwx $tmp
       cd $tmp
       mkdir $stash_repo
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
  if [ -d "$stash/${stash_repo}-reference" ]; then
    cd ${stash_repo}-reference
    git checkout master
    git reset --hard
    #git clean -fd -n
    git clean -fd
    git pull
    echo "${YELLOW}Updated repository. ${NO_COLOR}"
  else
    git clone https://${username}@webgate.ec.europa.eu/CITnet/stash/scm/multisite/${stash_repo}-reference.git
    cd ${stash_repo}-reference
    echo "${YELLOW}Reference repository cloned to $stash/${stash_repo}-reference ${NO_COLOR}"
  fi

  # Delay 2 seconds.
  sleep 2
  git status
  sleep 5
  git log -3 --oneline --decorate --graph
}

function prepare_what_to_deploy () 
{    

  if [ -d "$svn/${svn_repo}" ]; then
       rm -rf $svn/$svn_repo
  fi
 
  # Delete the tmp folder.
  rm -rf $tmp/$svn_repo
  mkdir $tmp/$svn_repo

  cd $stash/${stash_repo}-reference

  if [ -d "$stash/${stash_repo}-reference/themes" ]; then
    mkdir $tmp/$svn_repo/themes &&  cp -R themes/ $tmp/$svn_repo/
  fi
  if [ -d "$stash/${stash_repo}-reference/modules" ]; then
    mkdir $tmp/$svn_repo/modules && cp -R modules/ $tmp/$svn_repo/
  fi
  if [ -d "$stash/${stash_repo}-reference/libraries" ]; then
    mkdir $tmp/$svn_repo/libraries &&  cp -R libraries/ $tmp/$svn_repo/
  fi

  # When starterkit is available.
  if [ -d "$stash/${stash_repo}-reference/lib" ]; then
    mtkdir $tmp/$svn_repo/themes/
    cd $stash/${stash_repo}-reference/lib
    cp -R themes/ $tmp/$svn_repo
    mkdir $tmp/$stash_repo/modules
    cp -R modules/ $tmp/$svn_repo
    cp -R features $tmp/$svn_repo/modules
  fi
  
  # Run make file
  if [ -d "$stash/${stash_repo}-reference/resources" ] && [ -a "$stash/${stash_repo}-reference/resources/site.make"]; then
    echo "Run the make file."
    cd $stash/${stash_repo}-reference/resources
    drush make site.make --no-core
    mv -R ./site/all/modules/contrib $tmp/stash_repo/modules
  fi
  
}


function prepare_svn ()
{
   cd $svn
   svn co https://webgate.ec.europa.eu/CITnet/svn/MULTISITE/trunk/custom_subsites/${svn_repo}
   cd $svn/${svn_repo}

      # Cleanup of old svn junk.
      echo -e "${RED} ////////////////////////////////////////////////////////////////////////////////////////////////////////////////"
      echo -e "${RED} Remove files from svn before committing? Choose NO if unsure !!!!!!!!"
      echo -e "${RED} //////////////////////////////////////////////////////////////////////////////////////////////////////////////// ${NO_COLOR}"
      echo -n "${RED} WARNING Confirm svn remove y/n:"
      read delete

      if [ "$delete" == y ]; then
        svn rm *
        # Tip to resolve ! prefixed file in the svn status report.
        svn status | grep "^\!" | sed 's/^\! *//g' | xargs svn rm
      fi
    # IMPORTANT Copy stash_repo to svn folder.
    cp -fr $tmp/$svn_repo  $svn
}

function commit_svn ()
{
    # todo commit only after checking if the folder not empty.
    cd $svn/$svn_repo
    svn up
    svn add * --force
    echo "${CYAN}Here is what we do SVN commit...${NO_COLOR}"
    svn status
    #svn diff
    echo -n "${RED} Commit folder svn $svn/$svn_repo to server ? (y/n): ${NO_COLOR}"
    read answer

    if [ "$answer" == "y" ]; then
       svn commit -m "$jira"
    else
      cd $svn/$svn_repo
      echo "Project not deployed. Check $svn/$svn_repo folder"
      exit 1
    fi 
}

# Runtime. 
check_input "$stash_repo"
check_input "$jira"
check_input "$svn_repo"

git --version

create_directories
fetch_stash_repository
prepare_what_to_deploy
prepare_svn
commit_svn
echo -e "${GREEN} ////////////////////////////////////////////////////////////////////////////////////////////////////////////////"
echo -e "${GREEN} // Check your svn here: https://webgate.ec.europa.eu/CITnet/svn/MULTISITE/trunk/custom_subsites/$stash_repo"
echo -e "${GREEN} ////////////////////////////////////////////////////////////////////////////////////////////////////////////////"
svn status
