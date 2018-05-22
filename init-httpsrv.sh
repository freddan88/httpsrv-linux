#!/bin/sh
# Date: 2017-09-09
# Author: www.leemann.se/fredrik - www.youtube.com/user/FreLee54
##
### BEGIN INIT INFO
# Provides:          httpsrv
# Required-Start:    $local_fs $network
# Required-Stop:     $local_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: httpsrv
# Description:       httpsrv - httpd (apache2) & php By: www.leemann.se/fredrik
### END INIT INFO
## Links:
## How to LSBize an Init Script: https://wiki.debian.org/LSBInitScripts
## Insserv: https://help.directadmin.com/item.php?id=379
## Configuration:
ROOT=/srv/httpsrv
##
## Do not edit bellow this line!!!
## To add this script as a system-service and autostart it at boot run:
## Command: 'update-rc.d init-httpsrv defaults' As root or sudo on Debian/ubuntu
## Command: 'chkconfig --add init-httpsrv && chkconfig init-httpsrv on' As root or sudo on CentOS
#################################################################################################
##
case $1 in

start)
	pkill -9 httpd 2>/dev/null
	rm -f $ROOT/logs/httpd.pid 2>/dev/null
	echo "Starting Apache2 HTTP Server - httpsrv"
	$ROOT/bin/apachectl start
;;

stop)
	pkill -9 httpd 2>/dev/null
	rm -f $ROOT/logs/httpd.pid 2>/dev/null
	echo "Stopping Apache2 HTTP Server - httpsrv"
;;

*)
echo " "
	echo "Argumets: start|stop"
	echo "--------------------"
;;

esac
exit