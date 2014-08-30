#!/bin/bash

# How to read the input from command line variable=$1 or $2, $3 etc. 
# $0 is considered the command itself
#  if [ $# -ne 2 ]; then
#   echo "Usage: $0 [arg1] [arg2]"
#   exit
# fi

# Install folder
docroot=''
# Main destination
drupal_dir='/var/www/html'
# Specific destination. Leave blank if desired to install in root
drupal_subdir='drupal8'

site_name='Drupal 8'

# Database
db_user='root'
db_pass='dev'
db_host='localhost'
db_port='3306'

db_name='drupal8'

# Poweruser uid=1
user_name='admin'
user_pass='pass'
user_mail='admin@example.com'

# Make file
make_file='drupal-org8.make'
