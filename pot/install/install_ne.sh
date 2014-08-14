#!/bin/bash
if [ "$#" -lt 1 ];
then
  echo "usage: $0 <profile> <site name>"
  exit 42
fi

usage="
Installation of PROJECT instance\n
Syntax : $(basename $0) [ARGS] SITE-NAME\n
\t-i, \tDefine the installation profile to use\n
\t-s, \tsvn tag to use or trunk\n
"


function __echo {
	if [ "${verbose}" = 1 ] ; then
		echo $@
	fi
}

while getopts ":i:s:" o; do
    case "${o}" in
        s)
            svn_tag=${OPTARG}
            ;;
        i)
            install_profile=${OPTARG}
            ;;
        *)
            echo -e $usage
            ;;
    esac
done


source config_ne.sh


site_name=$BASH_ARGV
if [ -z "${site_name}" ];
then
  echo "WARNING: no site name was given !!"
  exit 42
fi

db_url="mysqli://${db_user}:${db_pass}@${db_host}:${db_port}/${site_name}"
__echo "Set DB URL to ${db_url}"

# Get current configuration
current_dir=$(pwd)
__echo "Set current directory to ${current_dir}"
working_dir="${current_dir}/${site_name}"
__echo "Set working directory to ${working_dir}"

# Remove existing working directory
if [ -d "${working_dir}" ] ; then
	__echo -n "Removing existing working directory..."
	rm -rf ${working_dir}
	__echo "done"
fi

# Set up the drush option
if [ "${force}" = 1 ] ; then
	drush_options="${drush_options} -y"
fi
__echo "Set drush options: ${drush_options}"


#-------------------------------------------------#
#     GET PROFILE, CREATE DRUPAL ARBORESCENCE     #
#-------------------------------------------------#

if [ -z ${svn_tag} ] || [ ${svn_tag} == 'trunk' ]; then
  svn_tag="trunk"
else
  svn_tag="tag/${svn_tag}"
fi

#export svn repository
echo "Export from https://svn/PROJECT/trunk ${site_name}_tmp"
svn export https://svn/PROJECT/$svn_tag ${site_name}_tmp

#build the drupal instance
set -x
drush ${drush_options} make --force-complete ${site_name}_tmp/profiles/${install_profile}/${install_profile}.make ${site_name} 1>&2
echo "drush make exited with code $?"
set +x

chmod -R u+w ${site_name}/sites/default
cp -R ${site_name}_tmp/profiles/$install_profile ${site_name}/profiles
rm -Rf ${site_name}_tmp



#-------------------------#
#     CREATE DATABASE     #
#-------------------------#

mysql -h ${db_host} -P ${db_port} -u $db_user --password="$db_pass" -e "drop database ${site_name};" 1>&2
mysql -h ${db_host} -P ${db_port} -u $db_user --password="$db_pass" -e "create database ${site_name};" 1>&2




#-----------------#
#     INSTALL     #
#-----------------#

cd ${site_name}

if [ $? != 0 ] ; then
	__echo "Unable to change directory to ${site_name}"
	exit 20
fi

#install and configure the drupal instance
drush --php="/usr/bin/php" ${drush_options} si $install_profile --db-url=$db_url --account-name=$account_name --account-pass=$account_pass --site-name=${site_name} --site-mail=$site_mail  1>&2

#set the PROJECT version
drush vset PROJECT_version "${PROJECT_version}" --format=string

#set FPFIS_common libraires path
#drush php-eval "define('FPFIS_COMMON_LIBRARIES_PATH',${FPFIS_common_libraries});"

if [ -d "${webroot}/${site_name}" ] ; then
	__echo -n "Removing the folder $webroot/${site_name}..."
  chmod -R 777 "${webroot}/${site_name}"
	rm -rf "${webroot}/${site_name}";
	__echo done
fi

mv "${working_dir}" $webroot

cd "${webroot}/${site_name}"

#solr indexation
drush solr-index

#run cron
drush cron
