 #!/bin/bash

source Functions.sh

current_dir=$PWD

echo "Enter source domain :"
read src_domain
src_domain_folder="/home/cloudpanel/htdocs/$src_domain"
src_db_name="${src_domain//./_}"

if [ ! -d $src_domain_folder ]; then
  echo "Source folder doesn't exist. Aborting."
  exit 1
fi

echo "Enter target domain :"
read tg_domain
tg_domain_folder="/home/cloudpanel/htdocs/$tg_domain"

if [ ! -d $tg_domain_folder ]; then
  echo "Target folder doesn't exist. Did you create it in CloudPanel ? Aborting."
  exit 1
fi

if [ "$(ls $tg_domain_folder 2> /dev/null)" != "" ]
then
  read -r -p "Archive files and database from $tg_domain ? [Y/n] " response
  if ! [[ "$response" =~ ^([nN][oO]|[nN])$ ]]; then
    backup_wp $tg_domain
  fi
fi

echo "Removing files from $tg_domain"
remove_wp_files $tg_domain

echo "Removing DB from $tg_domain"
remove_wp_db $tg_domain

echo "Copying files"
cd $src_domain_folder
sudo -u clp cp -r * "$tg_domain_folder"
cd $current_dir

db_exists=`mysql -h $db_ip -P $db_port -u $db_root_user -p$db_root_pwd -A -s -N -e "SHOW DATABASES LIKE '$src_db_name'"`

if [ "$db_exists" = "$src_db_name" ]; then
  tg_db_name="${tg_domain//./_}"
  tg_db_user=$tg_db_name 
  tg_db_password=$(openssl rand -base64 32)
  connection_string <<EOF
  CREATE USER '$tg_db_user'@'localhost' IDENTIFIED BY '$tg_db_password';
  CREATE DATABASE $tg_db_name DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci;
  GRANT ALL ON $tg_db_name.* TO '$tg_db_user'@'localhost';
  FLUSH PRIVILEGES;
EOF
  sudo -u clp wp db export "$tg_domain_folder/db.sql" --add-drop-table --path=$src_domain_folder
  sudo -u clp wp config set DB_NAME $tg_db_name --path=$tg_domain_folder
  sudo -u clp wp config set DB_USER $tg_db_user --path=$tg_domain_folder
  sudo -u clp wp config set DB_PASSWORD $tg_db_password --path=$tg_domain_folder
  sudo -u clp wp db import "$tg_domain_folder/db.sql" --path=$tg_domain_folder
  sudo -u clp wp search-replace "https://$src_domain" "https://$tg_domain" --recurse-objects --skip-columns=guid --skip-tables=wp_users --path=$tg_domain_folder
  sudo -u clp wp search-replace "http://$src_domain" "http://$tg_domain" --recurse-objects --skip-columns=guid --skip-tables=wp_users --path=$tg_domain_folder
else 
    echo "No matching DB, skipping DB transfer."
fi

