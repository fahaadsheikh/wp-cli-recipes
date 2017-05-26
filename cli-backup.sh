#!/bin/bash
# Usage: ./wc-base.sh sitedir oldurl newurl
# This script will create a backup a local wordpress installation.
# Tested on XAMP. 
# Author: Fahad Sheikh (https://github.com/fahaadsheikh)


# Change these variables to suit your environment 


WEBROOT='C:/xampp/htdocs'

##### DO NOT EDIT BELOW THIS LINE UNLESS YOU KNOW WHAT YOU'RE DOING !!!! #####

EXPECTED_ARGS=3
E_BADARGS=500

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: $WEBROOT sitedir oldurl newurl"
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



BACKUPDIR=$1
SITEURL='http://localhost/'$BACKUPDIR
SITEDIR=$WEBROOT/$BACKUPDIR
DATE=`date +"%Y-%m-%d"`

echo '---------------------------------------------'
echo 'Backing up Site.....'
echo '---------------------------------------------'

# Does the directory already exist? 
if [[ ! -d "${SITEDIR}" && ! -L "${SITEDIR}" ]] ; then
    echo "This sites directory does not exist, exiting..."
    exit 0;
fi

cd $SITEDIR; 
wp search-replace $2 $3 --export=database.sql

mv wp-config.php wp-config-temp.php
rm -rf wp-config.php

printf "Please enter your New Database Details: \n"
printf "\n"
printf "Database Name: \n"
read DBNAME
printf "Database User: \n"
read DBUSER
printf "Database Password: \n"
read DBPASS
wp core config --dbname=$DBNAME --dbuser=$DBUSER --dbpass=$DBPASS --dbhost=localhost --skip-check

tar cvzf  $DATE'-'$BACKUPDIR'-'backup.tar.gz .


rm -rf wp-config.php
rm -rf database.sql
mv wp-config-temp.php wp-config.php
mkdir -p backup
mv $DATE'-'$BACKUPDIR'-'backup.tar.gz backup/$DATE'-'$BACKUPDIR'-'backup.tar.gz

echo "---------------------------------------------"
echo "Site Backup Complete"
echo "Backup Directory: $SITEDIR/backup"
echo "---------------------------------------------"