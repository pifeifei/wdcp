#  wdcp 安装(非官方)

> * 如需官方版本请移至 https://www.wdcp.net/install.html
>
> * 本脚本主要针对软件升级使用（如 apache、nginx 升级）
>
> * 基于 wdcp 3.3 制作
>





### 使用说明

```shell
# 克隆升级脚本
git clone https://github.com/pifeifei/wdcp.git
# 升级
cd wdcp
./update/apache_update.sh cus
./update/nginx_update.sh cus
# 如无法升级, 请手动删除文件夹 inf 对应软件的 txt 文件, 
# 如升级 apache, rm inf/apache.txt; 升级 lanmp 中的apache, rm inf/na.txt



# 原始版本安装
git clone https://github.com/pifeifei/wdcp.git
sh lanmp.sh cus

# 多版本PHP支持，可选安装，安装后可在后台切换所使用的版本
sh lib/phps.sh

# tomcat安装，可选安装，默认版本为8.5
sh lib/tomcat.sh

# nodejs应用环境，可选安装,默认版本为v10.13
sh lib/nodejs.sh

# 升级 apache
sh update/apache-update.sh

# 升级 nginx
sh update/nginx-update.sh

# 升级 php 到版本 7.2.22
sh php-update.sh 7.2.22

# 为 php 安装 swoole 扩展, 请根据当前 wdcp 安装版本选择
sh update/php-swoole-install.sh

# 为 php 安装 swoole 扩展2, 为目录 /www/wdlinux/phps/ 安装swoole  扩展
sh update/phps-swoole-install.sh
```