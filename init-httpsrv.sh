#!/bin/sh
# Date: 2018-06-02
# Author: www.leemann.se/fredrik - www.youtube.com/user/FreLee54
##
# WebPage: http://www.leemann.se/fredrik
# Donate: https://www.paypal.me/freddan88
# GitHub: https://github.com/freddan88/httpsrv-linux
##
# Tutorial: http://www.leemann.se/fredrik/tutorials/project-httpsrv-v2-deb-rpm-based-linux
# Httpsrv Video: https://www.youtube.com/watch?v=MNd9_oKGK9I
# Chroot Video: https://www.youtube.com/watch?v=edp476SotZ8
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
##
### LINKS:
# How to LSBize an Init Script: https://wiki.debian.org/LSBInitScripts
# Insserv: https://help.directadmin.com/item.php?id=379
##
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