#!/bin/bash

set -eo pipefail

. lib/common.conf
. lib/common.sh
. lib/apache.sh
. lib/pcre.sh
. lib/perl.sh



# make sure source files dir exists.
[ -d $IN_SRC ] || mkdir $IN_SRC
[ -d $LOGPATH ] || mkdir $LOGPATH
[ -d $INF ] || mkdir $INF


if [ -f $INF/apache.txt -o -f $INF/na.txt  ]; then
    echo ""
    echo "To upgrade, delete the $INF/apache.txt and $INF/na.txt file first"
    echo -e "\033[31mrun shell script"
    echo -e "rm -f $INF/apache.txt"
    echo -e "rm -f $INF/na.txt"
    echo -e "      \033[0m"
    exit 0
fi
###
###
echo "Select Install
    1 LAMP (apache + php + mysql + zend +  pureftpd + phpmyadmin)
    3 LNAMP (nginx + apache + php + mysql + zend + pureftpd + phpmyadmin)
    4 install all service
    5 don't install is now
"
sleep 0.1
read -p "Please Input 1,3,4,5: " SERVER_ID
if [[ $SERVER_ID == 1 ]]; then
    SERVER="apache"
elif [[ $SERVER_ID == 3 ]]; then
    SERVER="na"
elif [[ $SERVER_ID == 4 ]]; then
    SERVER="all"
else
    exit
fi
#SERVER="na"
#SERVER_ID=3
if [ "$1" == "cus" ];then
echo
if [ "$SERVER_ID" != 2 ];then
###apache
echo -e "\033[31m   Select apache version \033[0m"
echo "	1 2.2.34
	2 2.4.41"
read -p "   Please Input 1,2: " APA_ID
[ $APA_ID == 1 ] && APA_VER="2.2.34"
[ $APA_ID == 2 ] && APA_VER="2.4.41"
echo
fi
fi


if [ $OS_RL == 1 ]; then
    sed -i 's/^exclude=/#exclude=/g' /etc/yum.conf
fi


###
if [ $OS_RL == 2 ]; then
    service apache2 stop 2>/dev/null
    apt-get update
    apt-get remove -y apache2 apache2-utils apache2.2-common apache2.2-bin \
        apache2-mpm-prefork apache2-doc apache2-mpm-worker  2>/dev/null
    apt-get -y autoremove

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
    ntpdate tiger.sina.com.cn > /dev/null 2>&1 && echo
    hwclock -w
fi

cd $IN_SRC

[ $IN_DIR = "/www/wdlinux" ] || IN_DIR_ME=1

if [ $SERVER == "apache" ]; then
    wget_down $HTTPD_DU
elif [ $SERVER == "nginx" ]; then
    echo "mast be is apache. "
    exit
fi

function na_ins {
    [ -f $na_inf ] && return
    echo
    #nginx_ins
    apache_ins
    sed -i 's/Listen 80/Listen 88/g' /www/wdlinux/apache/conf/httpd.conf
    sed -i 's/NameVirtualHost \*:80/NameVirtualHost \*:88/g' /www/wdlinux/apache/conf/httpd.conf
    sed -i 's/VirtualHost \*:80/VirtualHost \*:88/g' /www/wdlinux/apache/conf/vhost/00000.default.conf
    if [ $APA_ID == 1 ];then
    cd $IN_SRC
    fileurl=$RPAF_URL && filechk
    tar xf mod_rpaf-0.6.tar.gz
    cd mod_rpaf-0.6/
    /www/wdlinux/apache/bin/apxs -i -c -a mod_rpaf-2.0.c >/dev/null 2>&1
    file_cp rpaf.conf /www/wdlinux/apache/conf/rpaf.conf
    fi
    [ $APA_ID == 2 ] && file_cp rpaf2.conf /www/wdlinux/apache/conf/rpaf.conf
    #file_cp naproxy.conf /www/wdlinux/nginx/conf/naproxy.conf
    file_cp defaultna.conf $IN_DIR/wdcp_bk/conf/defaultna.conf
    #file_cpv defaultna.conf /www/wdlinux/nginx/conf/vhost/00000.default.conf
    #file_cp wdlinux_na.php /www/web/default/index.php
    echo 'Include conf/rpaf.conf' >> /www/wdlinux/apache/conf/httpd.conf
    touch $na_inf
}

function in_all {
    na_ins
    #SERVER="nginx";phps_ins
    #zend_ins
    #rm -f $php_inf $eac_inf $zend_inf
    #SERVER="apache"; php_ins
    #zend_ins
    #memcache_ins
    #redis_ins
}

function cp_config_file {
    [ -f $apache_old/conf/vhost/00000.default.conf ] && rm -f "$IN_DIR/httpd-${APA_VER}/conf/vhost/00000.default.conf"
    [ ! -d "$IN_DIR/httpd-${APA_VER}/conf/vhost/" ] && mkdir -p "$IN_DIR/httpd-${APA_VER}/conf/vhost/"
    [ -d $apache_old ] && cp -rf $apache_old/conf/vhost/* "$IN_DIR/httpd-${APA_VER}/conf/vhost/"
    mkdir -p "$IN_DIR/httpd-${APA_VER}/conf/cert/"
    [ -d $apache_old ] && cp -rf $apache_old/conf/cert/* "$IN_DIR/httpd-${APA_VER}/conf/cert/"
    [ -f $apache_old/modules/libphp5.so ] && PHP_OLD_VER=5 && cp $apache_old/modules/libphp5.so "$IN_DIR/httpd-${APA_VER}/modules"
    [ -f $apache_old/modules/libphp7.so ] && PHP_OLD_VER=7 && cp $apache_old/modules/libphp7.so "$IN_DIR/httpd-${APA_VER}/modules"

    sed -i "s/LoadModule \+php\([57]\)/#\0/g" $IN_DIR/httpd-${APA_VER}/conf/httpd.conf
    if [ "$PHP_OLD_VER" == 5 ] ; then
        sed -i "/rewrite_module/a\LoadModule php5_module        modules/libphp5.so" $IN_DIR/httpd-${APA_VER}/conf/httpd.conf
    elif [ "$PHP_OLD_VER" == 7 ] ; then
        sed -i "/rewrite_module/a\LoadModule php7_module        modules/libphp7.so" $IN_DIR/httpd-${APA_VER}/conf/httpd.conf
    fi

    rm -f /www/web/default/phpinfo.php
    rm -f /www/web/default/iProber2.php
    rm -f /www/web/default/index.php
}

# start services
function start_srv {
    [ -f $conf_inf ] && return
    echo
    echo "starting..."

    service httpd start

    if [ $R7 == 1 ];then
    systemctl stop firewalld.service
    systemctl disable firewalld.service
    systemctl restart iptables.service
    systemctl enable iptables.service
    fi
}

function apache_in_finsh {
    echo
    echo
    echo
    echo -e "      \033[31mCongratulations, apache install is complete"
    echo -e "      visit http://ip"
    echo -e "      wdCP http://ip:8080"
    echo -e "      more infomation please visit http://www.wdlinux.cn/bbs/\033[0m"
    echo
}


###install
geturl
apache_old=`ls -l $IN_DIR/apache`
apache_old=${apache_old##*>}
# echo $apache_old
if [ $SERVER == "all" ]; then
    in_all
else
    ${SERVER}_ins
    #php_ins
    ##zend_ins
    #memcache_ins
    #redis_ins
fi

cp_config_file
start_srv
apache_in_finsh

