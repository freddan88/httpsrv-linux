#!/bin/sh
## Date: 2017-09-28
## Author: www.leemann.se/fredrik - www.youtube.com/user/FreLee54
## Configuration:
##
USER=httpsrv
GROUP=httpsrv
##
## Not recomended to change ROOT:
##
ROOT=/srv/httpsrv
##
## Download Sources from:
##
APR1_SRC=http://archive.apache.org/dist/apr/apr-1.5.2.tar.gz
APT2_SRC=http://archive.apache.org/dist/apr/apr-util-1.5.4.tar.gz
WEB_SRC=https://archive.apache.org/dist/httpd/httpd-2.4.26.tar.gz
PHP_SRC=http://us.php.net/get/php-7.1.6.tar.gz/from/this/mirror
##
## MySQL Socket
## Default (apt) Ubuntu: /run/mysqld/mysqld.sock
## Default (yum) CentOS: /var/lib/mysql/mysql.sock
##
#SOCK=/run/mysqld/mysqld.sock
#SOCK=/var/lib/mysql/mysql.sock
##
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
		$ROOT/bin/apachectl start && sleep 0.5
	fi
echo " "
;;

stop)
echo " "
	echo "Stopping Apache2 HTTP Server"
	pkill -9 httpd && sleep 0.5
	rm -f $ROOT/logs/httpd.pid
echo " "
;;

restart)
echo " "
	echo "Stopping Apache2 HTTP Server"
	$ROOT/tmp/httpsrv.sh stop >/dev/null
	$ROOT/tmp/httpsrv.sh start
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
	echo "Apache executable: $ROOT/bin/apachectl|httpd"
	echo "Apache / httpd Version:"
		$ROOT/bin//httpd -V
	echo ""
	echo "php executable: $ROOT/bin/php"
	echo "php Version:"
		$ROOT/bin//php -v
	echo ""
	echo "php Compiled in Modules:"
		$ROOT/bin//php -m
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
	echo "$ROOT/conf/httpd.conf"
	echo " "
	echo "Filename for PHP Config:"
		$ROOT/bin/php --ini
	echo " "
	echo "Filename for phpMyAdmin Config:"
	echo "$ROOT/phpmyadmin/config.inc.php"
	echo " "
	echo "Filename for MySQL Configs:"
		find /etc -name my.cnf
echo " "
;;

conftest)
echo " "
	echo "Testing configuration file for Apache2:"
	$ROOT/bin/httpd -t
	ERROR=$?
echo " "
;;

perm)
echo " "
	chmod -R 755 $ROOT/htdocs $ROOT/chroot/htdocs $ROOT/phpmyadmin
	chown -R $USER:$GROUP $ROOT/htdocs $ROOT/phpmyadmin $ROOT/chroot/htdocs
	echo "Changed permissions, user and group on public-folders"
echo " "
;;

perm_all)
echo " "
	chown -R root:root $ROOT
	find $ROOT -type d -exec chmod 0755 {} \;
	find $ROOT -type f -exec chmod 0754 {} \;
	find $ROOT/tmp -type f -exec chmod 0755 {} \;
	echo "Changed permissions, user and group on $ROOT"
	$ROOT/tmp/httpsrv.sh perm >/dev/null
echo " "
;;

web_conf)
echo " "
	rm -rf $ROOT/tmp/src
	echo "Will now configure apache, httpd server"
	mkdir -p $ROOT/tmp/src/build && cd $ROOT/tmp/src
####
	if ! [ -f $ROOT/tmp/src/httpd.tar.gz ]; then
		wget -O httpd.tar.gz $WEB_SRC 2>/dev/null
	fi
		tar -zxf httpd.tar.gz && mv httpd-* httpd
		mv $ROOT/tmp/src/httpd $ROOT/tmp/src/build
####
	if ! [ -f $ROOT/tmp/src/apr.tar.gz ]; then
		wget -O apr.tar.gz $APR1_SRC 2>/dev/null
	fi
		tar -zxf apr.tar.gz -C $ROOT/tmp/src/build/httpd/srclib
		mv $ROOT/tmp/src/build/httpd/srclib/apr-* $ROOT/tmp/src/build/httpd/srclib/apr
####
	if ! [ -f $ROOT/tmp/src/apr-util.tar.gz ]; then
		wget -O apr-util.tar.gz $APT2_SRC 2>/dev/null
	fi
		tar -zxf apr-util.tar.gz -C $ROOT/tmp/src/build/httpd/srclib
		mv $ROOT/tmp/src/build/httpd/srclib/apr-util-* $ROOT/tmp/src/build/httpd/srclib/apr-util
####
	cd $ROOT/tmp/src/build/httpd
	./configure --prefix=$ROOT --with-included-apr --enable-so --enable-ssl

echo " "
	rm -f $ROOT/tmp/src/*.tar.gz
	echo "Run 'web_make' to compile and install apache"
	echo "--------------------------------------------"
;;

web_make)
echo " "
	echo "Will now compile and install httpd in $ROOT"
	sleep 2 && cd $ROOT/tmp/src/build/httpd
	make && make install
	rm -rf $ROOT/tmp/src
echo " "
;;

php_conf)
echo " "
	echo "Will now configure php"
	rm -rf $ROOT/tmp/src
	mkdir -p $ROOT/tmp/src/build && cd $ROOT/tmp/src

	if ! [ -f $ROOT/tmp/src/php.tar.gz ]; then
		wget -O php.tar.gz $PHP_SRC 2>/dev/null
	fi
		tar -zxf php.tar.gz && mv php-* php
		mv $ROOT/tmp/src/php $ROOT/tmp/src/build

	cd $ROOT/tmp/src/build/php
	./configure --prefix=$ROOT --with-apxs2=$ROOT/bin/apxs --with-config-file-path=$ROOT/etc --with-pear --with-zlib --with-bz2 --with-openssl --with-curl --with-readline --with-mcrypt --with-gd --with-freetype-dir --with-jpeg-dir --with-png-dir --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-mysql-sock=$SOCK --with-mhash --with-xsl --enable-zip --enable-mbstring --enable-sockets --enable-gd-native-ttf --enable-soap --enable-bcmath --enable-intl
echo " "
	rm -f $ROOT/tmp/src/*.tar.gz
	echo "Run 'php_make' to compile and install php"
	echo "-----------------------------------------"
;;

php_make)
echo " "
	echo "Will now compile and install php in $ROOT"
	sleep 2 && cd $ROOT/tmp/src/build/php
	make && make install
	$ROOT/build/libtool --finish $ROOT/tmp/src/build/php/libs
	cp -f $ROOT/tmp/src/build/php/php.ini-development $ROOT/tmp/src/build/php/php.ini-production $ROOT/etc
	rm -rf $ROOT/tmp/src
echo " "
;;

finalize)
echo " "
	echo "Finalizing installation in $ROOT"
	useradd -r -U -c "httpsrv" -d $ROOT -s /bin/false httpsrv
	mkdir -p $ROOT/tmp/src && cd $ROOT/tmp/src

		if ! [ -f $ROOT/tmp/src/phpMyAdmin.tar.gz ]; then
			wget -O phpMyAdmin.tar.gz https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-english.tar.gz 2>/dev/null
		fi
			tar -zxf phpMyAdmin.tar.gz && mv phpMyAdmin-* phpmyadmin && mv phpmyadmin $ROOT
		
		mkdir -p $ROOT/chroot/htdocs
		cp -f $ROOT/tmp/files/test/index.html $ROOT/chroot/htdocs
		cp -f $ROOT/tmp/files/phpmyadmin.conf $ROOT/conf/extra/phpmyadmin.conf
		cp -f $ROOT/tmp/files/config.inc.php $ROOT/phpmyadmin/config.inc.php
		cp -f $ROOT/etc/php.ini-production $ROOT/etc/php.ini
		
		cp -fr $ROOT/tmp/files/test $ROOT/chroot/htdocs
		cp -fr $ROOT/tmp/files/test $ROOT/htdocs 
		rm -f $ROOT/phpmyadmin/config.sample.inc.php
		cp -f $ROOT/tmp/init-httpsrv.sh /etc/init.d/init-httpsrv
		chmod 764 /etc/init.d/init-httpsrv

	ln -sf $ROOT/tmp/httpsrv.sh /usr/local/sbin/httpsrv
	ln -sf $ROOT/bin/htcacheclean $ROOT/bin/htdigest $ROOT/bin/htpasswd $ROOT/bin/php $ROOT/bin/phpize /usr/local/sbin
echo " "
		echo "You can change 'blowfish_secret' in $ROOT/phpmyadmin/config.inc.php"
		echo "Created symbolic links for some executable files in /usr/local/sbin"
		echo "Scripted by: www.leemann.se/fredrik"

	$ROOT/tmp/httpsrv.sh perm_all
	rm -rf $ROOT/tmp/src 2>/dev/null
;;

update_all)
	echo " "
		pkill -9 httpd && rm -rf $ROOT/tmp/src
		rm -f $ROOT/logs/httpd.pid 2>/dev/null
		rm -rf ${ROOT}_backup 2>/dev/null

		mkdir -p ${ROOT}_backup/phpmyadmin
		mv -f $ROOT/etc ${ROOT}_backup/etc 2>/dev/null
		cp -r $ROOT/tmp ${ROOT}_backup/tmp 2>/dev/null
		mv -f $ROOT/conf ${ROOT}_backup/conf 2>/dev/null
		
		mv -f $ROOT/htdocs ${ROOT}_backup/htdocs 2>/dev/null
		mv -f $ROOT/chroot ${ROOT}_backup/chroot 2>/dev/null
		
		mv -f $ROOT/phpmyadmin/config.inc.php ${ROOT}_backup/phpmyadmin/config.inc.php 2>/dev/null

		$ROOT/tmp/httpsrv.sh init_remove
		$ROOT/tmp/httpsrv.sh unlink_all
		rm -rf $ROOT 2>/dev/null

		mkdir -p $ROOT
		mv -f ${ROOT}_backup/tmp $ROOT
		chmod -R 777 $ROOT 2>/dev/null
		rm -rf $ROOT/tmp/src

		chown -R root:root ${ROOT}_backup
		find ${ROOT}_backup -type d -exec chmod 0775 {} \;
		find ${ROOT}_backup -type f -exec chmod 0664 {} \;
		echo "Removed symlinks and created new directory for httpsrv"
	echo " "
;;

remove_all)
echo " "
	pkill -9 httpd && rm -f $ROOT/logs/httpd.pid
	rm -rf ${ROOT}_backup 2>/dev/null
	
	mkdir -p ${ROOT}_backup/phpmyadmin
	mv -f $ROOT/etc ${ROOT}_backup/etc 2>/dev/null
	mv -f $ROOT/conf ${ROOT}_backup/conf 2>/dev/null
	mv -f $ROOT/htdocs ${ROOT}_backup/htdocs 2>/dev/null
	mv -f $ROOT/chroot ${ROOT}_backup/chroot 2>/dev/null
	
	mv -f $ROOT/phpmyadmin/config.inc.php ${ROOT}_backup/phpmyadmin/config.inc.php 2>/dev/null

	$ROOT/tmp/httpsrv.sh unlink_all
	$ROOT/tmp/httpsrv.sh init_remove
	cd /srv && userdel -fr httpsrv 2>/dev/null

	chown -R root:root ${ROOT}_backup
	find ${ROOT}_backup -type d -exec chmod 0775 {} \;
	find ${ROOT}_backup -type f -exec chmod 0664 {} \;
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