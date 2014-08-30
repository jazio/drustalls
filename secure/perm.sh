#!/bin/bash

if [ $(id -u) != 0 ]; then
        printf "This script must be run as root.\n"
        exit 1
fi

#TODO: change these variables to be the apache user and a group consisting of all users who
#      need write access
drupal_path=${1%/}
drupal_user='[apache user]'
httpd_group='[group of users who need write access]'

# Help menu
print_help() {
cat <<-HELP

This script is used to fix permissions of a Drupal installation
you need to provide the following arguments:

1) Path to your Drupal installation.

Usage: (sudo) bash ${0##*/} --drupal_path=PATH

Example: (sudo) bash ${0##*/} --drupal_path=/usr/local/apache2/htdocs
HELP
exit 0
}

# Parse Command Line Arguments
while [ $# -gt 0 ]; do
        case "$1" in
                --drupal_path=*)
      drupal_path="${1#*=}"
      ;;
    --help) print_help;;
    *)
      printf "Invalid argument, run --help for valid arguments.\n";
      exit 1
  esac
  shift
done

if [ -z "${drupal_path}" ] || [ ! -d "${drupal_path}/sites" ] || [ ! -f "${drupal_path}/core/modules/system/system.module" ] && [ ! -f "${drupal_path}/modules/system/system.module" ]; then
  printf "Please provide a valid Drupal path.\n"
  print_help
  exit 1
fi

cd $drupal_path
printf "Changing ownership of all contents of \"${drupal_path}\":\n user => \"${drupal_user}\" \t group => \"${httpd_group}\"\n"
chown -R ${drupal_user}:${httpd_group} .

printf "Changing permissions of all directories inside \"${drupal_path}\" to \"rxrwx---\"...\n"
find . -type d -exec chmod u=rx,g=rwx,o= '{}' \;

printf "Changing permissions of all files inside \"${drupal_path}\" to \"r--rw----\"...\n"
find . -type f -exec chmod u=r,g=rw,o= '{}' \;

printf "Changing permissions of \"files\" directories in \"${drupal_path}/sites\" to \"rwxrwx---\"...\n"
cd ${drupal_path}/sites
find . -type d -name files -exec chmod ug=rwx,o= '{}' \;
printf "Changing permissions of all files inside all \"files\" directories in \"${drupal_path}/sites\" to \"rw-rw----\"...\n"
printf "Changing permissions of all directories inside all \"files\" directories in \"${drupal_path}/sites\" to \"rwxrwx---\"...\n"

for x in ./*/files; do
  ls ${x}
  find ${x} -type d -exec chmod ug=rwx,o= '{}' \;
  find ${x} -type f -exec chmod ug=rw,o= '{}' \;
  break;
done

echo "Done settings proper permissions on files and directories"
