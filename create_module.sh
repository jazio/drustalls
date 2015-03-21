#!/usr/bin/env bash
# Output executed commands. Useful for debug.
# set -x
# Fail one command all fail.
# set -e
# Load variables.
source config.sh

echo -e "${GREEN} ////////////////////////////////////////////////////"
echo -e "${GREEN} // This script will create a scaffold Drupal 7 module"
echo -e "${GREEN} ////////////////////////////////////////////////////"

# Copy custom drush command into devel module folder

       if [ -d $webroot/$drupal_subdir ];
          then
          cd $webroot/$drupal_subdir/sites/all/modules
       else
          echo -e '$drupal_subdir does not exists. Run .drustall.sh to create it.'
          exit 1
       fi

echo 'Enter module name: '
read module

mkdir ${module}
cd ${module}


write_to_file()
{

     # initialize a local var
     local file="${module}.info"

     # check if file exists. this is not required as echo >> would 
     # would create it any way. but for this example I've added it for you
     # -f checks if a file exists. The ! operator negates the result
     if [ ! -f "$file" ] ; then
         # if not create the file
         touch "$file"
     fi

     # "open the file to edit" ... not required. echo will do

     # go in a while loop
     while true ; do
        # ask input from user. read will store the 
        # line buffered user input in the var $user_input
        # line buffered means that read returns if the user
        # presses return
        echo 'Start writing. Press :q when ready.'
        read user_input

        # until user types  ":q" ... using the == operator
        if [ "$user_input" == ":q" ] ; then
            return # return from function
        fi

        # write to the end of the file. if the file 
        # not already exists it will be created
        echo "$user_input" >> "$file"
     done
 }

