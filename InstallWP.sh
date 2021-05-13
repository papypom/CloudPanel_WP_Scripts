#!/bin/bash

# If CP_functions.sh exists, then include it
source Functions.sh

echo "Enter domain name :"
read domain
db_name="${domain//./_}"
db_user=$db_name
db_password=$(openssl rand -base64 32)

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

echo "Creating DB"
connection_string <<EOF
CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_password';
CREATE DATABASE $db_name DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci;
GRANT ALL ON $db_name.* TO '$db_user'@'localhost';
FLUSH PRIVILEGES;
EOF

echo "Downloading and installing Wordpress"
cd /home/cloudpanel/htdocs/$domain
sudo -u clp wp core download --locale=fr_FR
sudo -u clp wp config create --dbname=$db_name --dbuser=$db_user --dbpass=$db_password --extra-php <<PHP
define('DISABLE_WP_CRON', true);
define('FS_METHOD','direct');
PHP

echo "Done"
