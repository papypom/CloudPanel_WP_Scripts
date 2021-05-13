 #!/bin/bash

source secrets.sh

connection_string () {
  mysql -h $db_ip -P $db_port -u $db_root_user -p$db_root_pwd -A
}

remove_wp_files () {
  local domain=$1
  local domain_folder="/home/cloudpanel/htdocs/$domain"
  local backup_folder="/home/cloudpanel/backups/${domain//./_}"
  if [ "$(ls $domain_folder 2> /dev/null)" != "" ]; then
    sudo -u clp rm -r $domain_folder/*
  else 
    echo "Folder empty, skipping."
  fi
}

remove_wp_db () {
  local domain=$1
  local db_name="${domain//./_}"

  local db_exists=`mysql -h $db_ip -P $db_port -u $db_root_user -p$db_root_pwd -A -s -N -e "SHOW DATABASES LIKE '$db_name'"`
  if [ "$db_exists" = "$db_name" ]; then
    connection_string <<EOF
      DROP DATABASE $db_name;
      DROP USER '$db_name'@'localhost';
EOF
  else 
    echo "No matching DB, skipping."
  fi
}

remove_wp_backups () {
  local domain=$1
  local domain_folder="/home/cloudpanel/htdocs/$domain"
  local backup_folder="/home/cloudpanel/backups/${domain//./_}"
  if [ "$(ls $backup_folder 2> /dev/null)" != "" ]; then
    sudo -u clp rm -r $backup_folder/*
  else 
    echo "Folder empty, skipping."
  fi
}

remove_domain_folders () {
  local domain=$1
  local domain_folder="/home/cloudpanel/htdocs/$domain"
  local backup_folder="/home/cloudpanel/backups/${domain//./_}"
  sudo -u clp rm -r $domain_folder
  sudo -u clp rm -r $backup_folder
}

backup_wp () {
  local actual_folder=$PWD
  local domain=$1
  local domain_folder="/home/cloudpanel/htdocs/$domain"
  local backup_folder="/home/cloudpanel/backups/${domain//./_}"
  local filename=`date +%Y%m%d_%H%M`
  cd $domain_folder
  sudo -u clp wp db export $backup_folder/db.sql --add-drop-table
  sudo -u clp tar -cf $backup_folder/$filename.tar * 
  cd $backup_folder
  sudo -u clp tar -rf $filename.tar db.sql
  sudo -u clp rm db.sql
  sudo -u clp gzip $filename.tar
  echo "Archive created : $backup_folder/$filename.tar.gz"
  cd $actual_folder
}

restore_wp_files () {
  local domain=$1
  local folder=$2
  local filename=$3
  local actual_folder=$PWD
  local domain_folder="/home/cloudpanel/htdocs/$domain"
  local backup_folder="/home/cloudpanel/backups/${domain//./_}"
  sudo -u clp cp "$folder/$filename" "$domain_folder/$filename"
  cd $domain_folder
  sudo chown clp $filename
  sudo -u clp tar -xf $filename
  sudo rm $filename
  cd $actual_folder
}

restore_wp_db () {
  local domain=$1
  local db_file=$2
  local domain_folder="/home/cloudpanel/htdocs/$domain"
  local db_name=${domain//./_}
  local db_user=$db_name
  sudo -u clp wp config set DB_NAME $db_name --path=$domain_folder
  sudo -u clp wp config set DB_USER $db_user --path=$domain_folder
  local db_password=`wp config get DB_PASSWORD --path=$domain_folder`
  echo db_name
  echo "Creating DB"
  connection_string <<EOF
  CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_password';
  CREATE DATABASE $db_name DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci;
  GRANT ALL ON $db_name.* TO '$db_user'@'localhost';
  FLUSH PRIVILEGES;
EOF
  wp db import "$domain_folder/$db_file" --path=$domain_folder
}
