#!/bin/bash


# Main destination.
webroot='/var/www'
drupal_subdir='x3'
drupal_package='drupal-8.0.0-beta7'
file="${drupal_package}.tar.gz"

site_name='Drupal'

# Database.
db_host='localhost'
# Don't use - in database name.
db_name='x3'
db_user='root'
db_pass='dev'
db_port='3306'


# Poweruser uid=1
user_name='admin'
user_pass='pass'
user_mail='admin@example.com'

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

