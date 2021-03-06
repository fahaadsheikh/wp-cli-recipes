#!/bin/bash
# Usage: ./wc-base.sh sitedir
# This script will create a local wordpress installation and install some commonly used plugins. 
# Tested on MAMP. 
# Author: Fahad Sheikh (https://github.com/fahaadsheikh)


# Change these variables to suit your environment 


WEBROOT='C:/xampp/htdocs' 
BASE_PLUGINS='wordfence wordpress-seo wordpress-importer contact-form-7'



##### DO NOT EDIT BELOW THIS LINE UNLESS YOU KNOW WHAT YOU'RE DOING !!!! #####

EXPECTED_ARGS=1
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: $WEBROOT sitedir"
  exit $E_BADARGS
fi

#check that wordpress-cli is installed 
# asssumes you have installed wp-cli into your path and renamed it to wp and it is in your $PATH
checkwpcli() {
    if hash wp 2>/dev/null; then
        echo 'wp-cli installed.'; 
    else
        echo 'wp-cli is required. Download and install available from http://wp-cli.org/'; 
        exit 0; 
    fi
}



INSTALLDIR=$1
SITEURL='http://localhost/'$INSTALLDIR
SITEDIR=$WEBROOT/$INSTALLDIR

echo '---------------------------------------------'
echo 'Creating new site.....'
echo '---------------------------------------------'

# Does the directory already exist? 
if [[ -d "${SITEDIR}" && ! -L "${SITEDIR}" ]] ; then
    echo "This sites directory already exists, exiting..."
    exit 0;
fi

mkdir -p $SITEDIR; 
echo "Site directory created in $WEBROOT"; 

cd $SITEDIR; 

wp core download
rm -rf wp-config-sample.php
printf "Please enter your Database Details: \n"
printf "\n"
printf "Database Name: \n"
read DBNAME
printf "Database User: \n"
read DBUSER
printf "Database Password: \n"
read DBPASS
wp core config --dbname=$DBNAME --dbuser=$DBUSER --dbpass=$DBPASS --dbhost=localhost
IFS='%'


printf "Wordpress Username: \n"
read ADMINUSER
printf "Wordpress Password: \n"
read ADMINPASS


wp core install --url=""$SITEURL"" --title="Wordpress Fresh Install" --admin_user="$ADMINUSER" --admin_password="$ADMINPASS" --admin_email="johndoe@sample.com"
unset IFS
echo 'Base Wordpress configuration completed....'

wp plugin install --activate $BASE_PLUGINS
wp plugin delete hello akismet
wp post delete 2
echo 'Common plugins install completed....'

printf 'Do you want to generate dummy data? Y/N \n'
read dummydata

if [[ "$dummydata" == [yY] ]]; then
	wp post generate --count=10 --post_type=page
fi

echo "---------------------------------------------"
echo "New site created."
echo "Link $SITEURL"
echo "Username: $ADMINUSER"
echo "Password: $ADMINPASS"
echo "---------------------------------------------"