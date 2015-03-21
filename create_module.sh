#!/usr/bin/env bash
# Output executed commands. Useful for debug.
# set -x
# Fail one command all fail.
# set -e
# Load variables.
source config.sh

echo -e "${GREEN} ////////////////////////////////////////////////////"
echo -e "${GREEN} // This script will create a scaffold Drupal 7 module"
echo -e "${GREEN} //////////////////////////////////////////////////// ${NO_COLOR}"
      
      #Check if desired site exists
     if [ -d $webroot/$drupal_subdir ];
          then
          cd $webroot/$drupal_subdir/sites/all/modules
     else
          echo -e '$drupal_subdir does not exists. Run .drustall.sh to create it.'
          exit 1
     fi

echo -n 'Enter module name: '
read module

mkdir ${module}
cd ${module}

# Write info file.
function write_info
{
        echo "name = ${module}" > ${module}.info
        
        echo -n "description = "
        read description
        echo "description = ${description}" >> ${module}.info
        
        echo "core = 7.x" >> ${module}.info

        echo -n "package = "
        read package
        echo "package = ${package}" >> ${module}.info


        echo "configure = admin/config/content/${module}" >> ${module}.info

 }

 function write_module
 {
  echo "<?php" >> ${module}.module
 }

 function write_inc
 {
  echo "<?php" >> ${module}.inc
 }



function write_to_file
{
    # Read function parameters. 
    echo $1

     if [ ! -f "${module}.$1" ] ; then
         # if file does not exists create the file
         touch "${module}.$1"
     else
      echo "File ${module}.$1 exists and skipped."
     fi
     write_$1
     echo "File ${module}.$1 was written."
}


# Call function with parameter.
write_to_file info
write_to_file module
write_to_file inc


        # echo -e "dependencies = "
        # while true ; do
        # cat << DEPENDENCIES >> ${module}.info
             
        # mozilla
        # links
        # lynx
        # konqueror
        # opera
        # netscape
        # DEPENDENCIES

        #  if [ "$user_input" == ":q" ] ; then
        #      return # return from function
        #  fi
        #  done