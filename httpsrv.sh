#!/bin/sh
## Date: 2017-10-30
## Author: www.leemann.se/fredrik - www.youtube.com/user/FreLee54
## Configuration:

root_user=root
root_group=root

root_folder=/srv/httpsrv

service_user=httpsrv
service_group=httpsrv

## Download Sources from:
apr1_src=http://archive.apache.org/dist/apr/apr-1.5.2.tar.gz
apr2_src=http://archive.apache.org/dist/apr/apr-util-1.5.4.tar.gz
web_src=https://archive.apache.org/dist/httpd/httpd-2.4.26.tar.gz
php_src=http://us.php.net/get/php-7.1.6.tar.gz/from/this/mirror

## MySQL Socket
## Default (apt) Ubuntu: /run/mysqld/mysqld.sock
## Default (yum) CentOS: /var/lib/mysql/mysql.sock
## UNCOMMENT ONE OF BELOW DEPENDING ON SYSTEM IN USE:

#sock_file=/run/mysqld/mysqld.sock
#sock_file=/var/lib/mysql/mysql.sock

## Do not edit bellow this line!!!
#########################################################################################
if [ "$(id -u)" != "0" ]; then echo "PLEASE RUN THIS SCRIPT AS ROOT OR SUDO!" && exit; fi
case $1 in

start)
echo " "
	if ps -e | grep httpd ; then
		echo " "
		echo "Services already running!"
	else
		echo "Starting Apache2 HTTP Server"
		$root_folder/bin/apachectl start && sleep 0.5
	fi
echo " "
;;

stop)
echo " "
	echo "Stopping Apache2 HTTP Server"
	pkill -9 httpd && sleep 0.5
	rm -f $root_folder/logs/httpd.pid
echo " "
;;

restart)
echo " "
	echo "Stopping Apache2 HTTP Server"
	$root_folder/tmp/httpsrv.sh stop >/dev/null
	$root_folder/tmp/httpsrv.sh start
;;

stats)
echo " "
	echo "Active processes:"
	echo " "
		ps -e | grep httpd
		ps -e | grep mysqld
echo " "
;;

info)
echo " "
	echo "Apache executable: $root_folder/bin/apachectl|httpd"
	echo "Apache / httpd Version:"
		$root_folder/bin//httpd -V
	echo ""
	echo "php executable: $root_folder/bin/php"
	echo "php Version:"
		$root_folder/bin//php -v
	echo ""
	echo "php Compiled in Modules:"
		$root_folder/bin//php -m
	echo ""
	echo "MySQL Version:"
		mysql -h localhost -V
	echo ""
	echo "Scripted by: www.leemann.se/fredrik"
echo " "
;;

conf)
echo " "
	echo "Configuration Files can be found here:"
	echo "Filename for Apache Config:"
	echo "$root_folder/conf/httpd.conf"
	echo " "
	echo "Filename for PHP Config:"
		$root_folder/bin/php --ini
	echo " "
	echo "Filename for phpMyAdmin Config:"
	echo "$root_folder/phpmyadmin/config.inc.php"
	echo " "
	echo "Filename for MySQL Configs:"
		find /etc -name my.cnf
echo " "
;;

conftest)
echo " "
	echo "Testing configuration file for Apache2:"
	$root_folder/bin/httpd -t
	ERROR=$?
echo " "
;;

perm)
echo " "
	chown root:root $root_folder/chroot
	chmod -R 755 $root_folder/htdocs $root_folder/chroot/htdocs $root_folder/phpmyadmin
	chown -R $service_user:$service_group $root_folder/htdocs $root_folder/phpmyadmin 
	chown -R httpsrv:httpsrv $root_folder/chroot/htdocs
	echo "Changed permissions, user and group on public-folders"
echo " "
;;

perm_all)
echo " "
	chown -R $root_user:$root_group $root_folder
	find $root_folder -type d -exec chmod 0755 {} \;
	find $root_folder -type f -exec chmod 0754 {} \;
	find $root_folder/tmp -type f -exec chmod 0755 {} \;
	echo "Changed permissions, user and group on $root_folder"
	$root_folder/tmp/httpsrv.sh perm >/dev/null
echo " "
;;

web_conf)
echo " "
	rm -rf $root_folder/tmp/src
	echo "Will now configure apache, httpd server"
	mkdir -p $root_folder/tmp/src/build && cd $root_folder/tmp/src
####
	if ! [ -f $root_folder/tmp/src/httpd.tar.gz ]; then
		wget -O httpd.tar.gz $web_src 2>/dev/null
	fi
		tar -zxf httpd.tar.gz && mv httpd-* httpd
		mv $root_folder/tmp/src/httpd $root_folder/tmp/src/build
####
	if ! [ -f $root_folder/tmp/src/apr.tar.gz ]; then
		wget -O apr.tar.gz $apr1_src 2>/dev/null
	fi
		tar -zxf apr.tar.gz -C $root_folder/tmp/src/build/httpd/srclib
		mv $root_folder/tmp/src/build/httpd/srclib/apr-* $root_folder/tmp/src/build/httpd/srclib/apr
####
	if ! [ -f $root_folder/tmp/src/apr-util.tar.gz ]; then
		wget -O apr-util.tar.gz $apr2_src 2>/dev/null
	fi
		tar -zxf apr-util.tar.gz -C $root_folder/tmp/src/build/httpd/srclib
		mv $root_folder/tmp/src/build/httpd/srclib/apr-util-* $root_folder/tmp/src/build/httpd/srclib/apr-util
####
	cd $root_folder/tmp/src/build/httpd
	./configure --prefix=$root_folder --with-included-apr --enable-so --enable-ssl

echo " "
	rm -f $root_folder/tmp/src/*.tar.gz
	echo "Run 'web_make' to compile and install apache"
	echo "--------------------------------------------"
;;

web_make)
echo " "
	echo "Will now compile and install httpd in $root_folder"
	sleep 2 && cd $root_folder/tmp/src/build/httpd
	make && make install
	rm -rf $root_folder/tmp/src
echo " "
;;

php_conf)
echo " "
	echo "Will now configure php"
	rm -rf $root_folder/tmp/src
	mkdir -p $root_folder/tmp/src/build && cd $root_folder/tmp/src

	if ! [ -f $root_folder/tmp/src/php.tar.gz ]; then
		wget -O php.tar.gz $php_src 2>/dev/null
	fi
		tar -zxf php.tar.gz && mv php-* php
		mv $root_folder/tmp/src/php $root_folder/tmp/src/build

	cd $root_folder/tmp/src/build/php
	./configure --prefix=$root_folder --with-apxs2=$root_folder/bin/apxs --with-config-file-path=$root_folder/etc --with-pear --with-zlib --with-bz2 --with-openssl --with-curl --with-readline --with-mcrypt --with-gd --with-freetype-dir --with-jpeg-dir --with-png-dir --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-mysql-sock=$sock_file --with-mhash --with-xsl --enable-zip --enable-mbstring --enable-sockets --enable-gd-native-ttf --enable-soap --enable-bcmath --enable-intl
echo " "
	rm -f $root_folder/tmp/src/*.tar.gz
	echo "Run 'php_make' to compile and install php"
	echo "-----------------------------------------"
;;

php_make)
echo " "
	echo "Will now compile and install php in $root_folder"
	sleep 2 && cd $root_folder/tmp/src/build/php
	make && make install
	$root_folder/build/libtool --finish $root_folder/tmp/src/build/php/libs
	cp -f $root_folder/tmp/src/build/php/php.ini-development $root_folder/tmp/src/build/php/php.ini-production $root_folder/etc
	rm -rf $root_folder/tmp/src
echo " "
;;

finalize)
echo " "
	echo "Finalizing installation in $root_folder"
	useradd -r -U -c "httpsrv" -d $root_folder -s /bin/false httpsrv
	mkdir -p $root_folder/tmp/src && cd $root_folder/tmp/src

		if ! [ -f $root_folder/tmp/src/phpMyAdmin.tar.gz ]; then
			wget -O phpMyAdmin.tar.gz https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-english.tar.gz 2>/dev/null
		fi
			tar -zxf phpMyAdmin.tar.gz && mv phpMyAdmin-* phpmyadmin && mv phpmyadmin $root_folder
		
		mkdir -p $root_folder/chroot/htdocs
		cp -f $root_folder/tmp/files/test/index.html $root_folder/chroot/htdocs
		cp -f $root_folder/tmp/files/phpmyadmin.conf $root_folder/conf/extra/phpmyadmin.conf
		cp -f $root_folder/tmp/files/config.inc.php $root_folder/phpmyadmin/config.inc.php
		cp -f $root_folder/etc/php.ini-production $root_folder/etc/php.ini
		cp -fr $root_folder/tmp/files/test $root_folder/chroot/htdocs
		cp -fr $root_folder/tmp/files/test $root_folder/htdocs 
		rm -f $root_folder/phpmyadmin/config.sample.inc.php
		cp -f $root_folder/tmp/init-httpsrv.sh /etc/init.d/init-httpsrv
		chmod 764 /etc/init.d/init-httpsrv

	ln -sf $root_folder/tmp/httpsrv.sh /usr/local/sbin/httpsrv
	ln -sf $root_folder/bin/htcacheclean $root_folder/bin/htdigest $root_folder/bin/htpasswd $root_folder/bin/php $root_folder/bin/phpize /usr/local/sbin
echo " "
		echo "You can change 'blowfish_secret' in $root_folder/phpmyadmin/config.inc.php"
		echo "Created symbolic links for some executable files in /usr/local/sbin"
		echo "Scripted by: www.leemann.se/fredrik"

	$root_folder/tmp/httpsrv.sh perm_all
	rm -rf $root_folder/tmp/src 2>/dev/null
;;

update_all)
	echo " "
		pkill -9 httpd && rm -rf $root_folder/tmp/src
		rm -f $root_folder/logs/httpd.pid 2>/dev/null
		rm -rf ${root_folder}_backup 2>/dev/null

		mkdir -p ${root_folder}_backup/phpmyadmin
		mv -f $root_folder/etc ${root_folder}_backup/etc 2>/dev/null
		cp -r $root_folder/tmp ${root_folder}_backup/tmp 2>/dev/null
		mv -f $root_folder/conf ${root_folder}_backup/conf 2>/dev/null
		
		mv -f $root_folder/htdocs ${root_folder}_backup/htdocs 2>/dev/null
		mv -f $root_folder/chroot ${root_folder}_backup/chroot 2>/dev/null
		
		mv -f $root_folder/phpmyadmin/config.inc.php ${root_folder}_backup/phpmyadmin/config.inc.php 2>/dev/null

		$root_folder/tmp/httpsrv.sh init_remove
		$root_folder/tmp/httpsrv.sh unlink_all
		rm -rf $root_folder 2>/dev/null

		mkdir -p $root_folder
		mv -f ${root_folder}_backup/tmp $root_folder
		chmod -R 777 $root_folder 2>/dev/null
		rm -rf $root_folder/tmp/src

		chown -R root:root ${root_folder}_backup
		find ${root_folder}_backup -type d -exec chmod 0775 {} \;
		find ${root_folder}_backup -type f -exec chmod 0664 {} \;
		echo "Removed symlinks and created new directory for httpsrv"
	echo " "
;;

remove_all)
echo " "
	pkill -9 httpd && rm -f $root_folder/logs/httpd.pid
	rm -rf ${root_folder}_backup 2>/dev/null
	
	mkdir -p ${root_folder}_backup/phpmyadmin
	mv -f $root_folder/etc ${root_folder}_backup/etc 2>/dev/null
	mv -f $root_folder/conf ${root_folder}_backup/conf 2>/dev/null
	mv -f $root_folder/htdocs ${root_folder}_backup/htdocs 2>/dev/null
	mv -f $root_folder/chroot ${root_folder}_backup/chroot 2>/dev/null
	
	mv -f $root_folder/phpmyadmin/config.inc.php ${root_folder}_backup/phpmyadmin/config.inc.php 2>/dev/null

	$root_folder/tmp/httpsrv.sh unlink_all
	$root_folder/tmp/httpsrv.sh init_remove
	cd /srv && userdel -fr httpsrv 2>/dev/null

	chown -R root:root ${root_folder}_backup
	find ${root_folder}_backup -type d -exec chmod 0775 {} \;
	find ${root_folder}_backup -type f -exec chmod 0664 {} \;
	echo "Removed symlinks and user for httpsrv"
echo " "
;;

unlink_all)
	unlink /usr/local/sbin/htcacheclean 2>/dev/null
	unlink /usr/local/sbin/htpasswd 2>/dev/null
	unlink /usr/local/sbin/htdigest 2>/dev/null
	unlink /usr/local/sbin/httpsrv 2>/dev/null
	unlink /usr/local/sbin/phpize 2>/dev/null
	unlink /usr/local/sbin/php 2>/dev/null
;;

init_remove)
	chkconfig init-httpsrv off 2>/dev/null
	chkconfig --del init-httpsrv 2>/dev/null
	update-rc.d -f init-httpsrv remove 2>/dev/null
	rm -f /etc/init.d/init-httpsrv 2>/dev/null
;;

*)
echo " "
	echo "Argumets: start|stop|restart|stats|info|conf|conftest|perm|perm_all|web_conf|web_make|php_conf|php_make|finalize|update_all|remove_all"
echo " "
;;

esac
exit