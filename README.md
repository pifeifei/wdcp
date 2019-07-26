#  wdcp 安装(非官方)

> 如需官方版本请移至 https://www.wdcp.net/install.html
>
> 本脚本主要针对软件升级使用（如 apache、nginx 升级）
>
> 基于 wdcp 3.3 制作



### 使用说明

```shell
# 克隆升级脚本
git clone https://github.com/pifeifei/wdcp.git
# 升级
cd wdcp
./update/apache_update.sh 2.4.30
./update/nginx_update.sh 1.16.0



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