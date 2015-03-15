#!/bin/bash
# Colors.
RED=$'\e[1;31m'
GREEN=$'\e[1;32m'
YELLOW=$'\e[1;33m'
BLUE=$'\e[1;34m'
MAGENTA=$'\e[1;35m'
CYAN=$'\e[1;36m'

# Install folder.
docroot=''

# Main destination.
webroot='/var/www'
drupal_subdir='z4'
drupal_package='drupal-8.0.0-beta7'
file="${drupal_package}.tar.gz"

site_name='Drupal 8'

# Database.
db_host='localhost'
# Don't use - in database name.
db_name='z4'
db_user='root'
db_pass='dev'
db_port='3306'


# Poweruser uid=1
user_name='admin'
user_pass='pass'
user_mail='admin@example.com'
