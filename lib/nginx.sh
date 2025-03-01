# nginx install function
###
 # @Author: kis龍 pifeifei1989@qq.com
 # @Date: 2020-07-21 11:01:07
 # @LastEditors: kis龍 pifeifei1989@qq.com
 # @LastEditTime: 2025-02-26 15:53:13
 # @FilePath: \wdcp\lib\nginx.sh
 # @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
###
function nginx_ins {
    local IN_LOG=$LOGPATH/${logpre}_nginx_install.log
    [ -f $nginx_inf ] && return
    pcre_ins
    echo
    echo "installing nginx..."
    cd $IN_SRC
    fileurl=$NGI_URL && filechk
    tar xvf nginx-$NGI_VER.tar.gz
    cd nginx-$NGI_VER
    #make_clean
    sed -i 's@CFLAGS="$CFLAGS -g"@#CFLAGS="$CFLAGS -g"@' auto/cc/gcc
    ./configure --user=www --group=www \
        --prefix=$IN_DIR/nginx-$NGI_VER \
        --conf-path=$IN_DIR/nginx-$NGI_VER/conf/nginx.conf \
        --with-http_stub_status_module \
        --with-ipv6 \
        --with-http_gzip_static_module \
        --with-http_realip_module \
        --with-http_ssl_module
    [ $? != 0 ] && err_exit "nginx configure err"
    make -j $CPUS
    [ $? != 0 ] && err_exit "nginx make err"
    make install
    [ $? != 0 ] && err_exit "nginx install err"
    [ -e $IN_DIR/nginx ] && [ -L $IN_DIR/nginx ] && rm -f $IN_DIR/nginx
    ln -sf $IN_DIR/nginx-$NGI_VER $IN_DIR/nginx
    mkdir -p $IN_DIR/nginx/conf/{vhost,rewrite,cert}
    mkdir -p /www/{web/default,web_logs}
    file_cp phpinfo.php /www/web/default/phpinfo.php
    file_cp iProber2.php /www/web/default/iProber2.php
    file_cp wdlinux_n.php /www/web/default/index.php
    chown -R www.www /www/web
    file_cp fcgi.conf $IN_DIR/nginx/conf/fcgi.conf
    file_cp nginx.conf $IN_DIR/nginx/conf/nginx.conf
    #file_cp wdcp_n.conf $IN_DIR/nginx/conf/wdcp.conf
    [ ! -d $IN_DIR/wdcp_bk/conf ] && mkdir -p $IN_DIR/wdcp_bk/conf
    file_cp defaultn.conf $IN_DIR/wdcp_bk/conf/defaultn.conf
    file_cpv defaultn.conf $IN_DIR/nginx/conf/vhost/00000.default.conf
    file_cp dz7_nginx.conf $IN_DIR/nginx/conf/rewrite/dz7_nginx.conf
    file_cp dzx15_nginx.conf $IN_DIR/nginx/conf/rewrite/dzx15_nginx.conf
    mkdir -p $IN_DIR/nginx/conf/vhost
    if [ ! -z $NPD ] && [ $NPD != "55" ];then
    sed -i 's/-55-/-'$NPD'-/g' $IN_DIR/nginx/conf/vhost/00000.default.conf
    fi
    if [ $OS_RL == 2 ]; then
        file_cp init.nginxd-ubuntu $IN_DIR/init.d/nginxd
    else
        file_cp init.nginxd $IN_DIR/init.d/nginxd
    fi
    chmod 755 $IN_DIR/init.d/nginxd
    #ln -sf $IN_DIR/php/sbin/php-fpm $IN_DIR/init.d/php-fpm
    #chmod 755 $IN_DIR/init.d/php-fpm
    #ln -sf $IN_DIR/php/sbin/php-fpm /etc/rc.d/init.d/php-fpm
    file_rm /etc/init.d/nginxd
    Checkinitd nginxd
    if [ $OS_RL == 2 ]; then
        update-rc.d -f nginxd defaults
    else
        chkconfig --add nginxd
        chkconfig --level 35 nginxd on
    fi
    if [ $IN_DIR_ME == 1 ]; then
        sed -i "s#/www/wdlinux#$IN_DIR#g" /etc/init.d/nginxd
        sed -i "s#/www/wdlinux#$IN_DIR#g" /etc/init.d/php-fpm
        sed -i "s#/www/wdlinux#$IN_DIR#g" $IN_DIR/nginx/conf/nginx.conf
    fi
    touch $nginx_inf
    cd $IN_SRC
    rm -fr nginx-$NGI_VER
}

