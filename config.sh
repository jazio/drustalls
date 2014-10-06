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
<<<<<<< HEAD
drupal_dir='/var/www/html'
# Specific destination. Leave blank if desired to install in root
drupal_subdir='drupal_review'

site_name='Multisite-Review'
=======
drupal_dir='/var/www'
# Specific destination. Leave blank if desired to install in root
drupal_subdir='drupal'

site_name='Demo Drupal'
>>>>>>> c3f68990b76cf10fd1a16d5cdb26c23e291a7149

# Database
db_user='root'
db_pass='dev'
db_host='localhost'
db_port='3306'

<<<<<<< HEAD
db_name='drupal_review'
=======
db_name='drupal'
>>>>>>> c3f68990b76cf10fd1a16d5cdb26c23e291a7149

# Poweruser uid=1
user_name='admin'
user_pass='pass'
user_mail='admin@example.com'
<<<<<<< HEAD
=======

# Make file
make_file='drupal-org.make'
>>>>>>> c3f68990b76cf10fd1a16d5cdb26c23e291a7149

# Make file
make_file='drupal-org.make'
