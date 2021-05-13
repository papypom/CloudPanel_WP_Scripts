 #!/bin/bash
source Functions.sh

echo "Enter domain of website to remove :"
read domain

read -r -p "Archive files and database from $domain ? [Y/n] " response
if ! [[ "$response" =~ ^([nN][oO]|[nN])$ ]] ; then
  backup_wp $domain
fi

echo "Removing files from $domain"
remove_wp_files $domain

echo "Removing DB from $domain"
remove_wp_db $domain

read -r -p "Also remove backups ? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]] ; then
  remove_wp_backups $domain
fi

read -r -p "Also remove folders ? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]] ; then
  remove_domain_folders $domain
fi