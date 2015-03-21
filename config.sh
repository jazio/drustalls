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
GREEN=$'\e[1;32m'
YELLOW=$'\e[1;33m'
BLUE=$'\e[1;34m'
MAGENTA=$'\e[1;35m'
CYAN=$'\e[0;36m'
NO_COLOUR='\e[0m'
