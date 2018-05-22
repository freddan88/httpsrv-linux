#!/bin/sh
## Date: 2017-09-09
## Author: www.leemann.se/fredrik - www.youtube.com/user/FreLee54
## Configuration:
USER=httpsrv
GROUP=httpsrv
ROOT=/srv/httpsrv
EXE_DIR=$ROOT/bin
TMP_DIR=$ROOT/tmp
PID_DIR=$ROOT/logs
SRC_DIR=$ROOT/tmp/src
#####################
##
## Download Sources from:
APR1_SRC=http://archive.apache.org/dist/apr/apr-1.5.2.tar.gz
APT2_SRC=http://archive.apache.org/dist/apr/apr-util-1.5.4.tar.gz
WEB_SRC=https://archive.apache.org/dist/httpd/httpd-2.4.26.tar.gz
PHP_SRC=http://us.php.net/get/php-7.1.6.tar.gz/from/this/mirror
##
## MySQL Socket
## Default (apt) Debian: /run/mysqld/mysqld.sock
## Default (yum) CentOS: /var/lib/mysql/mysql.sock
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
		echo "Service already running!"
	else
		echo "Starting Apache2 HTTP Server"
		$EXE_DIR/apachectl start && sleep 0.5
	fi
echo " "
;;

stop)
echo " "
	echo "Stopping Apache2 HTTP Server"
	pkill -9 httpd && sleep 0.5
	rm -f $PID_DIR/httpd.pid
echo " "
;;

restart)
	$0 stop 2>/dev/null
	$0 start
;;

stats)
echo " "
	echo "Active processes:"
		ps -e | grep httpd
		ps -e | grep mysqld
echo " "
;;

info)
echo " "
	echo "Apache executable: $ROOT/bin/apachectl|httpd"
	echo "Apache / httpd Version:"
		$EXE_DIR/httpd -V
	echo ""
	echo "php executable: $ROOT/bin/php"
	echo "php Version:"
		$EXE_DIR/php -v
	echo ""
	echo "php Compiled in Modules:"
		$EXE_DIR/php -m
	echo ""
	echo "MySQL Version:"
		mysql -h localhost -V
	echo ""
	echo "Scripted by: www.leemann.se/fredrik"
echo " "
;;

conftest)
echo " "
	echo "Testing configuration file for Apache2:"
	$EXE_DIR/httpd -t
	ERROR=$?
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

web_conf)
echo " "
	mkdir -p $SRC_DIR/build
	echo "Will now configure apache, httpd server"
	cd $SRC_DIR && wget -O httpd.tar.gz $WEB_SRC 2>/dev/null
	tar -zxf httpd.tar.gz && mv httpd-* httpd && mv httpd $SRC_DIR/build
	cd $SRC_DIR && wget -O apr.tar.gz $APR1_SRC 2>/dev/null
	tar -zxf apr.tar.gz && mv apr-* apr && mv apr $SRC_DIR/build/httpd/srclib
	cd $SRC_DIR && wget -O apr-util.tar.gz $APT2_SRC 2>/dev/null
	tar -zxf apr-util.tar.gz && mv apr-util-* apr-util && mv apr-util $SRC_DIR/build/httpd/srclib
echo " "
	cd $SRC_DIR/build/httpd && ./configure --prefix=$ROOT --with-included-apr --enable-so --enable-ssl
	echo "Run 'web_make' to compile and install apache"
	echo "--------------------------------------------"
;;

web_make)
echo " "
	echo "Will now compile and install httpd in $ROOT" && sleep 2
	cd $SRC_DIR/build/httpd && make && make install
echo " "
;;

php_conf)
echo " "
	mkdir -p $SRC_DIR/build
	echo "Will now configure php"
	cd $SRC_DIR && wget -O php.tar.gz $PHP_SRC 2>/dev/null
	tar -zxf php.tar.gz && mv php-* php && mv php $SRC_DIR/build && cd $SRC_DIR/build/php
	./configure --prefix=$ROOT --with-apxs2=$ROOT/bin/apxs --with-config-file-path=$ROOT/etc --with-pear --with-zlib --with-bz2 --with-openssl --with-curl --with-readline --with-mcrypt --with-gd --with-freetype-dir --with-jpeg-dir --with-png-dir --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-mysql-sock=$SOCK --with-mhash --with-xsl --enable-zip --enable-mbstring --enable-sockets --enable-gd-native-ttf --enable-soap --enable-bcmath --enable-intl
echo " "
	echo "Run 'php_make' to compile and install php"
	echo "-----------------------------------------"
;;

php_make)
echo " "
	echo "Will now compile and install php in $ROOT" && sleep 2
	cd $SRC_DIR/build/php && make && make install
	$ROOT/build/libtool --finish $SRC_DIR/build/php/libs
echo " "
;;

finalize)
echo " "
	useradd -r -U -c "httpsrv" -d $ROOT -s /bin/false httpsrv 2>/dev/null
	cd $SRC_DIR && wget -O phpMyAdmin.tar.gz https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-english.tar.gz 2>/dev/null
		tar -zxf phpMyAdmin.tar.gz && mv phpMyAdmin-* phpmyadmin && mv phpmyadmin $ROOT 2>/dev/null
		cp -f $SRC_DIR/build/php/php.ini-development $SRC_DIR/build/php/php.ini-production $ROOT/etc 2>/dev/null
		cp -f $ROOT/etc/php.ini-production $ROOT/etc/php.ini 2>/dev/null
		cp -f $TMP_DIR/files/phpmyadmin.conf $ROOT/conf/extra/phpmyadmin.conf 2>/dev/null
		cp -f $TMP_DIR/files/config.inc.php $ROOT/phpmyadmin/config.inc.php 2>/dev/null
		cp -fr $TMP_DIR/files/test $ROOT/htdocs 2>/dev/null
		rm -f $ROOT/phpmyadmin/config.sample.inc.php 2>/dev/null
		cp -f $TMP_DIR/init-httpsrv.sh /etc/init.d/init-httpsrv && chmod 774 /etc/init.d/init-httpsrv 2>/dev/null
	ln -sf $EXE_DIR/htcacheclean $EXE_DIR/htdigest $EXE_DIR/htpasswd $EXE_DIR/php $EXE_DIR/phpize /usr/local/sbin 2>/dev/null
		ln -sf $TMP_DIR/httpsrv.sh /usr/local/sbin/httpsrv 2>/dev/null
echo " "
		echo "Created symbolic links for some executable files in /usr/local/sbin"
		echo "You can change 'blowfish_secret' in $ROOT/phpmyadmin/config.inc.php"
		echo "Scripted by: www.leemann.se/fredrik"
echo " "
	$TMP_DIR/httpsrv.sh perm_all 2>/dev/null
	rm -rf $SRC_DIR 2>/dev/null
;;

perm_all)
echo " "
	chown -R $USER:$GROUP $ROOT
	find $ROOT -type d -exec chmod 0765 {} \; 2>/dev/null
	find $ROOT -type f -exec chmod 0764 {} \; 2>/dev/null
	find $ROOT/htdocs -type d -exec chmod 0775 {} \; 2>/dev/null
	echo "Changed permissions, user and group on $ROOT"
echo " "
;;

perm)
echo " "
	chown -R $USER:$GROUP $ROOT/htdocs
	find $ROOT/htdocs -type d -exec chmod 0775 {} \; 2>/dev/null
	find $ROOT/htdocs -type f -exec chmod 0774 {} \; 2>/dev/null
	echo "Changed permissions, user and group on $ROOT/htdocs"
echo " "
;;

update)
	echo " "
		mv -f $ROOT ${ROOT}_old 2>/dev/null
		cp -Rf ${ROOT}_old/tmp $TMP_DIR 2>/dev/null
		echo "Created new directory for httpsrv"
		echo "---------------------------------"
$0 perm_all 2>/dev/null
;;

remove_all)
echo " "
	pkill -9 httpd && rm -f $PID_DIR/httpd.pid 2>/dev/null
	cd /srv && userdel -fr httpsrv 2>/dev/null
	unlink /usr/local/sbin/htcacheclean 2>/dev/null
	unlink /usr/local/sbin/htpasswd 2>/dev/null
	unlink /usr/local/sbin/htdigest 2>/dev/null
	unlink /usr/local/sbin/httpsrv 2>/dev/null
	unlink /usr/local/sbin/phpize 2>/dev/null
	unlink /usr/local/sbin/php 2>/dev/null
	echo "Removed symlinks for httpsrv"
echo " "
;;

*)
echo " "
	echo "Argumets: start|stop|restart|stats|info|conf|conftest|perm|web_conf|web_make|php_conf|php_make|finalize|update|perm_all|remove_all"
echo " "
;;

esac
exit