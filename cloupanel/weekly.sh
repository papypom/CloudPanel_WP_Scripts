#!/bin/bash

for domain in "$@"
do
  backup_folder="/home/cloudpanel/backups/${domain//./_}"
  cd $backup_folder
  latest=`ls -t | head -n1`
  echo "Copying $latest to weekly folder"
  cp $latest weekly/$latest
done