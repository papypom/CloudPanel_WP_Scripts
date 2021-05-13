# CloudPanel_WP_Scripts

This is a few scripts I'm using to improve my workflow with [CloudPanel.io](https://www.cloudpanel.io/)

They require to have a sudo ssh access, and WP CLI installed and given the 'wp' name - which can be done with the following commands :

```
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
```

Also, WP-CLI doesn't as of today support PHP 8.0, so PHP 7.4 has to be used at system level, which can be done with the following commands :

```
sudo update-alternatives --set php /usr/bin/php7.4
sudo update-alternatives --set phar /usr/bin/phar7.4
sudo update-alternatives --set phar.phar /usr/bin/phar.phar7.4
```

The files in the cloudpanel folder can be copied to the /home/cloudpanel folder and are destined to be used by CRON (which can be set in CloudPanel). The nightly file saves the whole Wordpress file folder in a single encrypted tar.gz.enc file, which can then be stored on your favorite cloud storage (Backblaze B2 works great). The monthly & weekly file save the latest file to the monthly and weekly folder, respectively.

