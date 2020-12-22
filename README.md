#  wdcp 软件包升级(非官方)

> * 如需官方版本，请移至 [`wdcp`](https://www.wdcp.net/install.html)
> * 基于 wdcp 3.3 制作
> * 本脚本主要针对软件升级，升级版本包含：
>   * `nginx `
>   * `apache`
>   * `php`
>   * `swoole` 安装
>



### 使用说明

```shell
# 克隆升级脚本
git clone https://github.com/pifeifei/wdcp.git
cd wdcp

# 升级 apache
sh update/apache-update.sh cus

# 升级 nginx
sh update/nginx-update.sh cus

# 升级 php 到版本 7.2.29
# * 注: 仅针对 apache, 如需配合nginx, 请使用 sh lib/phps.sh 7.2.29
# 选择所安装版本（是 lnmp? lamp? lanmp?）
sh update/php-update.sh cus
sh update/php-update.sh 7.2.32

# 为 php 安装 swoole 扩展, 请根据当前 wdcp 安装版本选择
sh update/php-swoole-install.sh

# 为多版本 php 安装 swoole 扩展, 为 PHP(/www/wdlinux/phps) 安装swoole  扩展
sh update/phps-swoole-install.sh



# 原始版本安装
git clone https://github.com/pifeifei/wdcp.git
sh lanmp.sh cus

# 多版本PHP支持，可选安装，安装后可在后台切换所使用的版本
sh lib/phps.sh

# tomcat安装，可选安装，默认版本为8.5
sh lib/tomcat.sh

# nodejs应用环境，可选安装,默认版本为v10.13
sh lib/nodejs.sh

```

> 如果对你有帮助，请 `star` 支持下作者

## 其他说明

1. 升级后，可能会恢复部分默认文件，如下
   * `/www/web/default` 目录文件

## 已发现问题

- [] 安装 PHP 后,httpd 不会自动重启服务, 运行 `killall -9 httpd && service httpd restart` ,解决.

## 鸣谢

[wdcp](https://www.wdlinux.cn/bbs/thread-63477-1-1.html)