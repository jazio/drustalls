#!/bin/bash

echo -n "Hello. This is a Drupal installation script. "
echo -n "Downloading Drupal..."
drush dl drupal -y
mv drupal-* drupal
cd drupal
echo -n "Please type the database login: "
read login
echo -n "... and database password: "
read pass
echo -n "Table name: "
read table
echo -n
drush si --account-pass=admin --db-url=mysql://$login:$pass@localhost/$table -y
drush dl bueditor colorbox ctools devel jquery_update pathauto token views zen -y
drush en bueditor colorbox ctools devel* jquery_update pathauto token views views_ui zen -y
drush dis color overlay -y
drush colorbox-plugin
chmod a+w sites/default/files sites/default/files/styles
drush zen dev
