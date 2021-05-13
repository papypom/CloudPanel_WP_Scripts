#!/bin/bash

source secrets.sh

for domain in "$@"
do
  domain_folder="/home/cloudpanel/htdocs/$domain"
  backup_folder="/home/cloudpanel/backups/${domain//./_}"
  if [ ! -d "$backup_folder" ]; then
    echo "Backups folder doesn't exist. Creating."
    mkdir "$backup_folder"
  fi
  filename=`date +%Y%m%d_%H%M`
  cd $domain_folder
  wp db export $backup_folder/db.sql --add-drop-table
  tar -cf $backup_folder/$filename.tar * 
  cd $backup_folder
  if [ ! -d "monthly" ]; then
    echo "Monthly folder doesn't exist. Creating."
    mkdir "monthly"
  fi
  if [ ! -d "weekly" ]; then
    echo "Weekly folder doesn't exist. Creating."
    mkdir "weekly"
  fi
  tar -rf $filename.tar db.sql
  rm db.sql
  gzip $filename.tar
  openssl enc -aes-256-cbc -salt -pbkdf2 -pass pass:$openssl_pwd -in $filename.tar.gz -out $filename.tar.gz.enc
  rm $filename.tar.gz
  find . -type f -not -path "./weekly/*" -not -path "./monthly/*" -mtime +10 -delete
done
