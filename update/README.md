# 本脚本只升级单个软件

> 如若升级多个版本, 请分别执行升级脚本
> 如升级 apache, 请先设置 nginx 服务，否则升级过程会造成网站无法访问

## 使用说明

```shell
# 升级 apache，并指定安装版本
./update/apache-update.sh cus

# 升级 nginx，并指定安装版本
./update/nginx-update.sh cus

# PHP 安装 (nginx), 不指定版本将安装所有 PHP 版本
./lib/phps.sh 5.6.40

# PHP 升级 (apache), 不指定版本将安装默认 PHP 版本, 详见 ./lib/common.conf
./update/php.sh 5.6.40


```
