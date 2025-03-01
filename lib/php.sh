# php install function
function php_ins {
    local IN_LOG=$LOGPATH/${logpre}_php_install.log
    [ $MHASHIN == 1 ] && mhash_ins
    [ $MCRYPTIN == 1 ] && mcrypt_ins
    echo
    echo "installing php..."
    cd $IN_SRC
    fileurl=$PHP_URL && filechk
    tar xf php-$PHP_VER.tar.gz
    if [ $OS_RL == 2 ]; then
        if [ $X86 == 1 ]; then
            ln -sf /usr/lib/x86_64-linux-gnu/libssl.* /usr/lib/
        else
            ln -sf /usr/lib/i386-linux-gnu/libssl.* /usr/lib/
        fi
    fi
    NV=""
    if [ $SERVER == "nginx" ]; then
        NV="--enable-fpm --with-fpm-user=www --with-fpm-group=www"
    fi
    [ $SERVER == "apache" -o $SERVER == "na" ] && NV="--with-apxs2=$IN_DIR/apache/bin/apxs"
    cd php-$PHP_VER/
    make clean
    if [ $SERVER == "apache" -o $SERVER == "na" ]; then
        PHP_DIR="apache_php-$PHP_VER"
        PHP_DIRS="apache_php"
    elif [ $SERVER == "nginx" ];then
        PHP_DIR="nginx_php-$PHP_VER"
        PHP_DIRS="nginx_php"
    else
        PHP_DIR="def_php-$PHP_VER"
        PHP_DIRS="def_php"
    fi
    [ ! -f configure ] && ./buildconf --force
    if [ $PHP_VER == "8.2.13"]; then
        ./configure --prefix=$IN_DIR/$PHP_DIR --with-config-file-path=$IN_DIR/$PHP_DIR/etc \
            --with-config-file-scan-dir=$IN_DIR/$PHP_DIR/etc/php.d \
            --with-fpm-user=${run_user} --with-fpm-group=${run_group} --enable-fpm --enable-opcache --disable-fileinfo \
            --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd \
            --with-iconv=/usr/local --with-freetype --with-jpeg --with-zlib \
            --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-exif \
            --enable-sysvsem --with-openssl --enable-mbregex \
            --enable-mbstring --with-password-argon2 --with-sodium=/usr/local --enable-gd --with-openssl \
            --with-mhash --enable-pcntl --enable-sockets --enable-ftp --enable-intl --with-xsl \
            --with-gettext --with-zip=/usr/local --enable-soap --disable-debug
    else
        ./configure --prefix=$IN_DIR/$PHP_DIR \
        --with-config-file-path=$IN_DIR/$PHP_DIR/etc \
        --enable-mysqlnd --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd \
        --with-iconv-dir=/usr \
        --with-freetype-dir --with-jpeg-dir \
        --with-png-dir --with-zlib \
        --with-libxml-dir=/usr --enable-xml \
        --disable-rpath \
        --enable-inline-optimization --with-curl \
        --enable-mbregex --enable-mbstring \
        --with-mcrypt=/usr --with-gd \
        --with-xmlrpc --with-gettext \
        --enable-gd-native-ttf --with-openssl \
        --with-mhash --enable-ftp --enable-intl \
        --enable-bcmath --enable-exif --enable-soap \
        --enable-shmop --enable-pcntl \
        --disable-ipv6 --disable-debug \
        --enable-sockets --enable-zip --enable-opcache $NV
    fi
    [ $? != 0 ] && err_exit "php configure err"
    make ZEND_EXTRA_LIBS='-liconv' -j $CPUS
    [ $? != 0 ] && err_exit "php make err"
    make install
    [ $? != 0 ] && err_exit "php install err"
    ln -sf $IN_DIR/$PHP_DIR $IN_DIR/$PHP_DIRS
    rm -rf $IN_DIR/php
    ln -sf $IN_DIR/$PHP_DIRS $IN_DIR/php
    mkdir -p $IN_DIR/$PHP_DIR/etc
    cp php.ini-production $IN_DIR/$PHP_DIR/etc/php.ini
    rm -f $IN_DIR/etc/php.ini
    ln -sf $IN_DIR/$PHP_DIR/etc/php.ini $IN_DIR/etc/php.ini
    sed -i 's@^short_open_tag = Off@short_open_tag = On@' $IN_DIR/$PHP_DIR/etc/php.ini
    sed -i 's@^;date.timezone.*@date.timezone = Asia/Shanghai@' $IN_DIR/$PHP_DIR/etc/php.ini
    sed -i 's@^post_max_size = 8M@post_max_size = 30M@g' $IN_DIR/$PHP_DIR/etc/php.ini
    sed -i 's@^upload_max_filesize = 2M@upload_max_filesize = 30M@g' $IN_DIR/$PHP_DIR/etc/php.ini
    sed -i 's@^expose_php = On@expose_php = Off@g' $IN_DIR/$PHP_DIR/etc/php.ini

    if [ $SERVER == "nginx" ]; then
        /bin/cp -f sapi/fpm/init.d.php-fpm $IN_DIR/init.d/php-fpm
        /bin/cp -f sapi/fpm/php-fpm.conf $IN_DIR/$PHP_DIR/etc/php-fpm.conf
	[ $P7 == 1 ] && cp -f $IN_DIR/$PHP_DIR/etc/php-fpm.d/www.conf.default $IN_DIR/$PHP_DIR/etc/php-fpm.d/www.conf
        ln -s $IN_DIR/$PHP_DIR/etc/php-fpm.conf $IN_DIR/etc/php-fpm.conf

        chmod 755 $IN_DIR/init.d/php-fpm
	Checkinitd php-fpm
        if [ $OS_RL == 2 ]; then
            file_cp nginxd.fpm-ubuntu /www/wdlinux/init.d/nginxd
        else
            file_cp nginxd.fpm /www/wdlinux/init.d/nginxd
        fi
        chmod 755 /www/wdlinux/init.d/nginxd
    fi

    if [ $SERVER_ID == 4 ]; then
        sed -i 's/service/#service/g' /www/wdlinux/init.d/nginxd
    fi
    touch $php_inf
    #opcache
    cd $IN_SRC
    rm -fr php-$PHP_VER
    if [ $PHP_VER == "8.2.13"]; then
        cd /www/wdlinux/php/etc/php-fpm.d
        cp www.conf.default www.conf
        /www/wdlinux/php/sbin/php-fpm
    fi
}

