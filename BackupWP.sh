#!/bin/bash
source Functions.sh

echo "Enter domain of website to backup :"
read domain

backup_wp $domain
