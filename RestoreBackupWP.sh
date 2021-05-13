#!/bin/bash

#### Restores a backup (files and DB)
#### Usage : ./RestoreBackupWP.sh domain_name backup_file

source Functions.sh

domain=$1
file=$2

if [ ! -d "/home/cloudpanel/htdocs/$domain" ]; then
  echo "Folder doesn't exist. Please create the domain using CloudPanel. Aborting."
  exit 1
fi

if [ "$(ls /home/cloudpanel/htdocs/$domain 2> /dev/null)" != "" ]; then
  echo "Folder not empty. Please delete using RemoveWP.sh"
  exit 1
fi

db_exists=`mysql -h $db_ip -P $db_port -u $db_root_user -p$db_root_pwd -A -s -N -e "SHOW DATABASES LIKE '$db_name'"`

if [ "$db_exists" = "$db_name" ]; then
  read -r -p "Database exists. Please delete using RemoveWP.sh " response
  exit 1
fi

filename=`basename $file`
folder=`dirname $file`

if [ $folder = "." ]; then
  folder="/home/cloudpanel/backups/${domain//./_}"
fi

if [ ! -f "$folder/$filename" ]; then
  echo "Could not find save file. Aborting."
  exit 1
fi

restore_wp_files $domain $folder $filename

restore_wp_db $domain "db.sql"