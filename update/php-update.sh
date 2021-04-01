#!/bin/bash

# kislong <pifeifei1989@qq.com>
########################################
# use (为指定php版本安装swooole)
# ./phps.sh all  # install all version
# ./phps.sh 7.2.34
# swoole v1.x    php-v5.3.10 or later
# swoole v2.0.x  php-v7.0.0  or later
# swoole v2.x    php-v7.0.0  or later
# swoole v4.x    php-v7.1.0  or later
########################################


#set -eo pipefail


. lib/common.conf
. lib/common.sh
. lib/apache.sh
. lib/nginx.sh
. lib/php.sh
. lib/libiconv.sh
. lib/na.sh
. lib/mhash.sh
. lib/mcrypt.sh
. lib/memcached.sh
. lib/zend.sh


# make sure source files dir exists.
[ -d $IN_SRC ] || mkdir $IN_SRC
[ -d $LOGPATH ] || mkdir $LOGPATH
[ -d $INF ] || mkdir $INF

###
[ $UID != 0 ] && echo -e "\n ERR: You must be root to run the install script.\n\n" && exit


# if [ -f $INF/php.txt -o -f $INF/zend.txt -o -f $INF/redisp.txt -o -f $INF/memcache.txt ]; then
if [ -f $INF/redisp.txt -o -f $INF/memcache.txt ]; then
	echo ""
	echo "To upgrade, please delete the following files first:"
	echo " $INF/php.txt"
	echo " $INF/redisp.txt"
	echo " $INF/memcache.txt"
	echo " $INF/zend.txt"
	echo -e "\033[31mrun shell script"
	echo -e "rm -f $INF/php.txt"
	echo -e "rm -f $INF/redisp.txt"
	echo -e "rm -f $INF/memcache.txt"
	echo -e "rm -f $INF/zend.txt"
    echo -e "      \033[0m"
	exit 0
fi


echo "Select Install
    1 LAMP (apache + php + mysql + zend +  pureftpd + phpmyadmin)
    2 LNMP (nginx + php + mysql + zend + pureftpd + phpmyadmin)
    3 LNAMP (nginx + apache + php + mysql + zend + pureftpd + phpmyadmin)
    4 install all service
    5 don't install is now
"
sleep 0.1
read -p "Please Input 1,3,4,5: " SERVER_ID

if [[ $SERVER_ID == 2 ]]; then
    echo "
Please use the following command to upgrade
    sh lib/phps.php
    "
    exit
    # SERVER="nginx"
elif [[ $SERVER_ID == 1 ]]; then
    SERVER="apache"
elif [[ $SERVER_ID == 3 ]]; then
    SERVER="na"
elif [[ $SERVER_ID == 4 ]]; then
    SERVER="all"
else
    exit
fi


if [ "$1" == "cus" ];then
echo

###php
# wdcp php version: 5.3.29 5.4.45 5.5.38 5.6.38 7.1.25 7.2.15 7.3.2
# latest php version: 5.3.29 5.4.45 5.5.38 5.6.40 7.1.33 7.2.34 7.3.27 7.4.16
echo -e "\033[31m   Select php version \033[0m"
echo "	1 5.3.29
        2 5.4.45
        3 5.5.38
        4 5.6.40
        5 7.1.33
        6 7.2.34
        7 7.3.27
        8 7.4.16"
read -p "   Please Input 1,2,3,4,5,6,7,8: " PHP_ID
[ $PHP_ID == 1 ] && PHP_VER="5.3.29"
[ $PHP_ID == 2 ] && PHP_VER="5.4.45"
[ $PHP_ID == 3 ] && PHP_VER="5.5.38"
[ $PHP_ID == 4 ] && PHP_VER="5.6.40"
[ $PHP_ID == 5 ] && PHP_VER="7.1.33" && P7=1
[ $PHP_ID == 6 ] && PHP_VER="7.2.34" && P7=1
[ $PHP_ID == 7 ] && PHP_VER="7.3.27" && P7=1
[ $PHP_ID == 7 ] && PHP_VER="7.4.16" && P7=1
fi


###
if [ $OS_RL == 2 ]; then
    apt-get update
    apt-get remove -y  php5 php5-fpm  2>/dev/null
    apt-get -y autoremove
    # [ -f /etc/mysql/my.cnf ] && mv /etc/mysql/my.cnf /etc/mysql/my.cnf.lanmpsave
    yun_apt_ins
    if [ $X86 == 1 ]; then
        ln -sf /usr/lib/x86_64-linux-gnu/libpng* /usr/lib/
        ln -sf /usr/lib/x86_64-linux-gnu/libjpeg* /usr/lib/
    else
        ln -sf /usr/lib/i386-linux-gnu/libpng* /usr/lib/
        ln -sf /usr/lib/i386-linux-gnu/libjpeg* /usr/lib/
    fi
else
    [ ! -f $INF/dag.txt ] && rpm --import conf/RPM-GPG-KEY.dag.txt && touch $INF/dag.txt
    [ $R6 == 1 ] && el="el6" || el="el5"
    [ ! -f $INF/gcc.txt ] && yum_apt_ins && touch $INF/gcc.txt
    if [ $X86 == 1 ]; then
        ln -sf /usr/lib64/libjpeg.so /usr/lib/
        ln -sf /usr/lib64/libpng.so /usr/lib/
    fi
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    ntpdate tiger.sina.com.cn
    hwclock -w
fi

[ $IN_DIR = "/www/wdlinux" ] || IN_DIR_ME=1

# function phps_ins {
# 	sh ./lib/phps.sh $PHP_VER 1
# 	sh ./lib/phps_zend.sh $PHP_VER
# 	sh ./lib/phps_memcache.sh $PHP_VER	
# 	sh ./lib/phps_redis.sh $PHP_VER	
# }

function redisp_ins {
    if [ ! -f $redisp_inf ];then
    cd $IN_SRC
    fileurl=$REDISP_URL && filechk
    unzip develop.zip
    cd phpredis-develop
    /www/wdlinux/php/bin/phpize
    ./configure --with-php-config=/www/wdlinux/php/bin/php-config
    make
    [ $? != 0 ] && err_exit "redis make err"
    make install
    [ $? != 0 ] && err_exit "redis install err"
    grep -q 'redis.so' /www/wdlinux/etc/php.ini
    if [ $? != 0 ]; then
    local ext_dir=`/www/wdlinux/php/bin/php-config --extension-dir`
    echo "
[redis]
extension_dir ="$ext_dir"
extension=redis.so" >> /www/wdlinux/etc/php.ini
    fi
    cd $IN_SRC
    rm -fr phpredis*
    touch $redisp_inf
    fi
}

# function in_all {
#     #na_ins
#     SERVER="nginx";phps_ins
#     #zend_ins
#     rm -f $php_inf $eac_inf $zend_inf
#     SERVER="apache"; php_ins
#     zend_ins
#     memcache_ins
#     redisp_ins
# }

# start services
function start_srv {
    [ -f $php_inf ] && return
    echo
    echo "starting..."
    
	if [ SERVER="nginx" ]; then
        echo "Can't just use nginx"
        exit
	elif [ SERVER="apache" ]; then
		service httpd restart
	else
		service httpd restart
	fi

    
	if [ $R7 == 1 ];then
	systemctl stop firewalld.service
	systemctl disable firewalld.service
	systemctl restart iptables.service
	systemctl enable iptables.service
    fi
}

function php_in_finsh {
    echo
    echo
    echo
    echo -e "      \033[31mCongratulations ,php update is complete"
    echo -e "      visit http://ip"
    echo -e "      wdCP http://ip:8080"
    echo -e "      more infomation please visit http://www.wdlinux.cn/bbs/\033[0m"
    echo
}

###install
geturl
# if [ $SERVER == "all" ]; then
#     in_all
# elif [ $SERVER == "nginx" ];then
#     NPD=${PHP_VER:0:1}${PHP_VER:2:1}
#     NPDS=${PHP_VER:0:1}${PHP_VER:1:1}${PHP_VER:2:1}
#     phps_ins
#     memcache_ins
# 	redisp_ins
#     NPS=1
# else

    [ -f $IN_DIR/apache/modules/libphp7.so ] && mv -f $IN_DIR/apache/modules/libphp7.so $IN_DIR/apache/modules/libphp7.so.bk
    [ -f $IN_DIR/apache/modules/libphp5.so ] && mv -f $IN_DIR/apache/modules/libphp5.so $IN_DIR/apache/modules/libphp5.so.bk
    [ "$SERVER" == "all" ] && SERVER='apache'
    php_ins
	[ -L $IN_DIR/apache_php ] && rm -f $IN_DIR/apache_php && ln -s $IN_DIR/apache_php-$PHP_VER  $IN_DIR/apache_php
	[ -L $IN_DIR/nginx_php ] && rm -f $IN_DIR/nginx_php && ln -s $IN_DIR/nginx_php-$PHP_VER  $IN_DIR/nginx_php
    zend_ins
    memcache_ins
    redisp_ins
# fi

start_srv
php_in_finsh
