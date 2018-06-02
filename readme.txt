Links:
------
WebPage: http://www.leemann.se/fredrik
Donate: https://www.paypal.me/freddan88
YouTube: https://www.youtube.com/user/FreLee54
GitHub: https://github.com/freddan88/httpsrv-linux

Tutorial: http://www.leemann.se/fredrik/tutorials/project-httpsrv-v2-deb-rpm-based-linux
Httpsrv Video: https://www.youtube.com/watch?v=MNd9_oKGK9I
Chroot Video: https://www.youtube.com/watch?v=edp476SotZ8

Description:
------------
Easy to use script to compile and install Apache2 and PHP7 from Source
This script will also help you manage the service, stare/stop/restart etc.

I take no responsibility for this script, use at your own risk
Security and bugs shall be reported to apache php or mysql
This script is only tested with softwareversions found in httpsrv.sh
The script is only tested with: CentOS6, CentOS7 and Ubuntu 16.04 Linux

-----------------------------------------------------------------------------

1. Install dependencies and other software (Copy and paste one line at a time)

Ubuntu:	
	apt-get install libpcre3-dev libbz2-dev libfreetype6-dev libicu-dev g++ libxslt-dev -y
	apt-get install gcc make nano libjpeg-dev libpng-dev libxml2-dev libcurl4-openssl-dev -y
	apt-get install libssl-dev libmcrypt-dev libreadline-dev pkg-config unzip wget -y

CentOS:
	yum install gcc make openssl-devel nano epel-release libjpeg-devel libpng-devel lynx -y
	yum install libxml2-devel libcurl-devel libmcrypt-devel readline-devel freetype-devel -y
	yum install bzip2-devel libicu-devel pcre-devel gcc-c++ libxslt-devel unzip wget -y

2. Download and install MySQL

Ubuntu:
	cd /tmp && wget -O mysql-apt.deb https://repo.mysql.com/mysql-apt-config_0.8.6-1_all.deb && dpkg -i mysql-apt.deb
	apt-get update && apt-get install mysql-client mysql-server -y
	
CentOS6:
	cd /tmp && wget -O mysql-el6.rpm https://repo.mysql.com/mysql57-community-release-el6-10.noarch.rpm && rpm -Uvh mysql-el6.rpm
	yum install mysql-community-server -y && service mysqld start && grep 'temporary password' /var/log/mysqld.log
	mysql_secure_installation

CentOS7:
	cd /tmp && wget -O mysql-el7.rpm https://repo.mysql.com/mysql57-community-release-el7-10.noarch.rpm && rpm -Uvh mysql-el7.rpm
	yum install mysql-community-server -y && service mysqld start && grep 'temporary password' /var/log/mysqld.log
	mysql_secure_installation
	
3. Download httpsrv using wget
	cd /tmp && wget http://leemann.se/fredrik/downloads/httpsrv_linux-server_2.0.zip
	unzip httpsrv_linux-server_2.0.zip -d /srv
	
4. Edit and configure variables in /srv/httpsrv/tmp/httpsrv.sh
	Uncomment the 'SOCK'-variable depending on system in use
	Ubuntu: #SOCK=/run/mysqld/mysqld.sock => SOCK=/run/mysqld/mysqld.sock
	CentOS: #SOCK=/var/lib/mysql/mysql.sock => SOCK=/var/lib/mysql/mysql.sock
	chmod -R 777 /srv/httpsrv && nano /srv/httpsrv/tmp/httpsrv.sh

5. configure and build httpsrv, httpd (Apache) + PHP and phpMyAdmin
	/srv/httpsrv/tmp/httpsrv.sh web_conf
	/srv/httpsrv/tmp/httpsrv.sh web_make
	/srv/httpsrv/tmp/httpsrv.sh php_conf
	/srv/httpsrv/tmp/httpsrv.sh php_make
	/srv/httpsrv/tmp/httpsrv.sh finalize
	mysql -u root -p < /srv/httpsrv/phpmyadmin/sql/create_tables.sql
	
6. Edit: /srv/httpsrv/conf/httpd.conf:
	
	Define a new variable called 'root_path' on the row bellow the "ServerRoot" directive
	Example:
		ServerRoot "/srv/httpsrv"
		Define root_path /srv/httpsrv
		
7. Edit and change bellow in httpd.conf:
	
	LoadModule rewrite_module modules/mod_rewrite.so
	
	User httpsrv
	Group httpsrv
	
	ServerName httpsrv:80
	
    # AllowOverride controls what directives may be placed in .htaccess files.
	# This directive is for the directory: /srv/httpsrv/htdocs
    AllowOverride All
	
	DirectoryIndex index.html index.htm index.php

	AddType application/x-httpd-php .php
	AddType application/x-httpd-php-source .phps

	# Add this line to the bottom of your configuration.
	# Configurationfile for phpmyadmin, aliases and permissions:
	Include conf/extra/phpmyadmin.conf
	
8. Restart httpsrv and configure autostart:

Ubuntu:
	update-rc.d init-httpsrv defaults && httpsrv restart

CentOS:
	chkconfig --add init-httpsrv && chkconfig init-httpsrv on && httpsrv restart
	
--------------------------------------------------------------------------------
More actions in script:
	
start the webserver
	httpsrv start
	
stop the webserver
	httpsrv stop
	
Restart the webserver
	httpsrv restart
	
Display active processes
	httpsrv stats
	
Display executabes and there versions
	httpsrv info
	
Display were configurationfiles are:
	httpsrv conf
	
Change permissions, owner and group on /srv/httpsrv/htdocs	
	httpsrv perm
	
Change permissions, owner and group on /srv/httpsrv
	httpsrv perm_all
	
Validate configurationfile for Apache2 (httpd)
	httpsrv conftest
	
Create a new empty directory in /srv
	httpsrv update_all
	
Uninstall and remove /srv/httpsrv
	httpsrv remove_all
