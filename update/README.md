# 本脚本只升级单个软件

> 如若升级多个版本, 请分别执行升级脚本
> 如升级 apache, 请先设置 nginx 服务，否则升级过程会造成网站无法访问



### 使用说明

```shell
# 升级 apache，并指定安装版本
./update/apache-update.sh cus

# 升级 nginx，并指定安装版本
./update/nginx-update.sh cus

# PHP + nginx 可安装 ./lib/phps.sh 5.6.38, 指定版本号，不知道安装所有版本
# php + apache 中升级 php TODO

```