#!/usr/bin/env bash
# Main destination.
webroot='/var/www'
drupal_subdir='x3'
drupal_package='drupal-8.0.0'
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

function command_exists ()
{
  type "$1" &> /dev/null
}

