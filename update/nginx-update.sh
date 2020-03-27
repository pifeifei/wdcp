#!/bin/bash

set -eo pipefail

. lib/common.conf
. lib/common.sh
. lib/nginx.sh
. lib/pcre.sh
. lib/perl.sh



# make sure source files dir exists.
[ -d $IN_SRC ] || mkdir $IN_SRC
[ -d $LOGPATH ] || mkdir $LOGPATH
[ -d $INF ] || mkdir $INF


if [ -f $INF/nginx.txt -o -f $INF/na.txt  ]; then
	echo ""
	echo "To upgrade, delete the $INF/nginx.txt and $INF/na.txt file first"
	echo -e "\033[31mrun shell script"
	echo -e "rm -f $INF/nginx.txt"
	echo -e "rm -f $INF/na.txt"
    echo -e "      \033[0m"
	exit 0
fi
###
###
echo "Select Install
    2 LNMP (nginx + php + mysql + zend + pureftpd + phpmyadmin)
    3 LNAMP (nginx + apache + php + mysql + zend + pureftpd + phpmyadmin)
    4 install all service
    5 don't install is now
"
sleep 0.1
read -p "Please Input 2,3,4,5: " SERVER_ID
if [[ $SERVER_ID == 3 ]]; then
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

if [ "$SERVER_ID" != 1 ];then
###nginx
echo -e "\033[31m   Select nginx version \033[0m"
echo "	1 1.8.1
	2 1.10.3
	3 1.12.2
	4 1.14.2
	5 1.16.1"
read -p "   Please Input 1,2,3,4,5: " NGI_ID
[ $NGI_ID == 1 ] && NGI_VER="1.8.1"
[ $NGI_ID == 2 ] && NGI_VER="1.10.3"
[ $NGI_ID == 3 ] && NGI_VER="1.12.2"
[ $NGI_ID == 4 ] && NGI_VER="1.14.2"
[ $NGI_ID == 5 ] && NGI_VER="1.16.1"

echo
fi

fi


if [ $OS_RL == 1 ]; then
    sed -i 's/^exclude=/#exclude=/g' /etc/yum.conf
fi


###
if [ $OS_RL == 2 ]; then
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

function na_ins {
    [ -f $na_inf ] && return
    echo
    nginx_ins

    file_cp naproxy.conf $IN_DIR/nginx/conf/naproxy.conf
    #file_cp defaultna.conf $IN_DIR/wdcp_bk/conf/defaultna.conf
    file_cpv defaultna.conf $IN_DIR/nginx/conf/vhost/00000.default.conf
    #file_cp wdlinux_na.php /www/web/default/index.php
    #echo 'Include conf/rpaf.conf' >> $IN_DIR/apache/conf/httpd.conf
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
	[ -f $nginx_old/conf/vhost/00000.default.conf ] && rm -f "$IN_DIR/nginx-${NGI_VER}/conf/vhost/00000.default.conf"
	[ ! -d "$IN_DIR/nginx-${NGI_VER}/conf/vhost/" ] && mkdir -p "$IN_DIR/nginx-${NGI_VER}/conf/vhost/"
	[ -d $nginx_old ] && cp -rf $nginx_old/conf/vhost/* "$IN_DIR/nginx-${NGI_VER}/conf/vhost/"
}

function nginx_in_finsh {
    [ -f $conf_inf ] && return
    echo
    echo "starting..."
	port_use_80=`netstat -ant | grep :80 | wc -l`
    if [ $port_use_80 == 0 ]; then
        service nginxd start
	fi
	echo
    echo -e "      \033[31mCongratulations ,nginx install is complete"
	[[ $port_use_80 > 0 ]] && echo -e "      Port 80 is occupied, please switch nginx service manually"
    echo -e "      visit http://ip"
    echo -e "      more infomation please visit https://github.com/pifeifei/wdcp/ \033[0m"
    echo
    
}

###install
geturl
nginx_old=`ls -l $IN_DIR/nginx`
nginx_old=${nginx_old##*>}
# echo $nginx_old
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
nginx_in_finsh

