 #!/bin/bash

# This is a sample secrets.sh file. In order to use it, you should:
# 1) Rename this file to secrets.sh
# 2) Obtain the DB password using the sudo clpctl db:show:credentials and copy it in the field hereunder
# 3) Select an password that will be used to encrypt your backup files if you use the nightly script

db_root_pwd="the_db_password"
openssl_pwd="encryption_password_of_your_choice"

db_ip="127.0.0.1"
db_port="3306"
db_root_user="root"