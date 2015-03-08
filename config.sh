#!/bin/bash

# Install folder
docroot=''
# Main destination
htdocs='/var/www'
drupal_subdir='x2'
drupal_package='drupal-8.0.0-beta7'
file="${drupal_package}.tar.gz"

site_name='Drupal 8'

# Database
db_host='localhost'
db_name='x2'
db_user='root'
db_pass='dev'
db_port='3306'


# Poweruser uid=1
user_name='admin'
user_pass='pass'
user_mail='admin@example.com'
