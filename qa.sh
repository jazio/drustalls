#!/bin/bash
# backup original database
#
feature=''
modulepath= 'site/all/modules/features/custom'
drupal_subdir='your_project_folder'
simpletest_class=''


drush sql-dump > original.sql
#flush cache and rebuild access
drush en devel -y
drush en devel_generate -y
drush en coder -y
drush en coder_review -y
drush en mail_logger -y
drush en simpletest -y

#watchdog
#Show a listing of most recent 10 messages
drush ws 2>&1 | tee watchdog.log

#run codesniffer
drush drupalcs ${modulepath}
# run test
drush test-run ${simpletest_class}
drush test-clean

#revert
drush fr ${feature}

#run updates
drush updb

#flush cache and rebuild access
drush cc all

#solr indexation
drush solr-index

#run cron
drush cron
