+++
title = "开发环境的定时启动脚本"
date = 2024-04-03T11:21:00+08:00
lastmod = 2024-06-06T14:44:52+08:00
categories = ["technology"]
draft = false
toc = true
image = "https://r2.guolongji.xyz/allinaent/2024/06/e6104c843f0ccfcf964a9d1e4e42dca7.png"
+++

## 开机启动并且定时运行 {#开机启动并且定时运行}

shell 的 jq 脚本真的是太难用了，调了半天才能用，文档看不懂。

完成的这个重启脚本非常有用：

cat nekoray.sh

```bash
#!/bin/bash
cd /opt/nekoray/config/profiles/;
port=`expr 0 + "6"$(date "+%m%d")`;
jq --indent 4 --argjson port "$port" '.bean.port |= $port'  0.json > tmp;
cp tmp 0.json;
ID=`ps -ef | grep nekoray | grep -v "$0" | grep -v "grep" | awk '{print $2}'`
echo $ID;
echo "---------------"
for id in $ID
do
kill -9 $id
echo "killed $id"
done
echo "---------------"
sleep 5;
nohup sh -c "PATH=/opt/nekoray:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin /opt/nekoray/nekoray" > /dev/null 2>&1 &
exit
```

以 root 的方式做重启：

cat startneko.sh

```bash
#!/bin/bash
echo "1"|sudo -S /home/uos/.script/nekoray.sh
```


### 自动更新配置的定时任务 {#自动更新配置的定时任务}

sudo vim /etc/crontab

```bash
0  0    * * *   root    /home/uos/.script/nekoray.sh
```

sudo systemctl restart cron

现在就做到无感知的定时重启了。


### 开机启动的方法 {#开机启动的方法}

```bash
sudo ln -s ~/.script/startneko.sh /etc/profile.d/
```

这个 qt 程序的开机自起一直有 xcb 的报错，不弄了。用 nekoup 写个 alias 非常地好用。


### 发现了一个好办法 {#发现了一个好办法}

vim ~/.config/autostart/nekoray.desktop

```nil
[Desktop Entry]
Type=Application
Exec=/home/uos/.script/startneko.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Nekoray
```

chmod +x nekoray.desktop

亲测可用，这样开机启动是没有问题了。并且确实是以 root 权限做的启动。qt-gui 的程序估计是不能用 daemon 的方式运行的。qt-core 的程序才能以 root 的方式运行。


### 关闭 ubuntu 的错误报告 {#关闭-ubuntu-的错误报告}

永久关闭 。
sudo gedit /etc/default/apport
修改 enabled=0 ，重启生效


## 启用代理和关闭代理的脚本 {#启用代理和关闭代理的脚本}

如果不是用的 tun 模式的话而是用的代理模式，那么上面只解决了一部分协议的问题，后面可以参考这个项目做一个一键切换的脚本。

setProxy: <https://github.com/dabrign/setProxy>

simple bash script to set and remove proxy from the command line

-   Supported services
    -   Bash

    -   Apt in /etc/apt/apt.conf Acquire::<http::Proxy> "<http://%7B%7Buser%7D%7D:%7B%7Bpasword%7D%7D@{{proxyurl:port>}}" ;

    -   Gnome

-   Other needed services

    -   NPM

    npm config set proxy <http://proxy.company.com:8080>
    npm config set https-proxy <http://proxy.company.com:8080>
    npm config delete proxy npm config delete https-proxy

    -   PIP &amp; CONDA

    Env var works for pip

    -   GIT

    git config --global http.proxy {{url}}
    git config --global https.proxy {{url}}
    git config --global --unset https.proxy
    git config --global --unset http.proxy

    -   docker File

    http-proxy.conf in /etc/systemd/system/docker.service.d with:
    [Service] Environment="HTTP_PROXY= "

    -   maven .m2/settings

<!--listend-->

```bash
#!/bin/bash
HTTP_PROXY="export http_proxy"
HTTPS_PROXY="export https_proxy"
FTP_PROXY="export ftp_proxy"
APTCONF="/etc/apt/apt.conf"
if grep -Fxq "$HTTP_PROXY" ~/.bashrc
then
    echo "Already set"
        read -r -p "do you wanna remove? [y/n]" response
        if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
        then
                sed -i '/no_proxy/d' ~/.bashrc
                sed -i '/http_proxy/d' ~/.bashrc
                sed -i '/https_proxy/d' ~/.bashrc
                sed -i '/ftp_proxy/d' ~/.bashrc
                sudo sed -i '/Acquire::http::Proxy/d' $APTCONF
                gsettings set org.gnome.system.proxy mode 'none'
        else
        echo "ok, no exception then!"
        fi
else
        gsettings set org.gnome.system.proxy mode 'manual'
    echo "you can set it now"
        read -r -p "Set your proxy in form http://user:pwd@proxy:port : " response
        echo "http_proxy=$response" >> ~/.bashrc
        echo "https_proxy=$response" >> ~/.bashrc
        echo "ftp_proxy=$response" >> ~/.bashrc
        echo "export http_proxy" >> ~/.bashrc
        echo "export https_proxy" >> ~/.bashrc
        echo "export ftp_proxy" >> ~/.bashrc
        if [ -f $APTCONF ];
        then
                echo "appending"
        else
                echo "creating..."
                sudo touch $APTCONF

        fi
        sudo sh -c " echo 'Acquire::http::Proxy \"$response\" ;' >> $APTCONF"

        read -r -p "do you wanna add exceptions? [y/n]" response
        if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
        then
        read -r -p "Set your proxy exceptions in form ip_add,host1,host2" response
                echo "no_proxy=$response" >> ~/.bashrc
                echo "export no_proxy" >> ~/.bashrc
        else
        echo "ok, no exception then!"
        fi
        source ~/.bashrc
fi
```


## 透明代理 {#透明代理}

这个是最优的解决方式，但是这个需要一个硬路由器或者软路由支持。家里还行，其他地方不方便。

红米 ax6000 软路由：

<https://www.youtube.com/watch?v=zMQfO3AezgM>

clash 的使用：

<https://www.youtube.com/watch?v=2iwuriJAmW0>

clash 配置 frojan ：

<https://v2xtls.org/clash-for-windows%E9%85%8D%E7%BD%AEtrojan%E6%95%99%E7%A8%8B/>

clash 已经不更新了。

没必要把红米 ax6000 刷机。任何局域网内的电脑设备都可以充当软路由。


## 知识积累 {#知识积累}


### 基础知识和原理 {#基础知识和原理}

<https://github.com/XTLS/Xray-core/discussions/237>

-   简单理解 IP Packet、TCP Connection、五元组、端口、User Datagram Protocol
-   那么 FullCone、Symmetric 又是什么？
-   Xray-core 和一些代理协议中的 UDP 细节讲解
-   透明代理 TPROXY UDP 的原理


### 一些文档 {#一些文档}

<https://www.v2fly.org/>

看过这些知识就会明白软路由和透明代理的一些原理，虽说用起来不是很复杂，但是有大量的细节一般人其实是不清楚的。这些知识对于认识网络和通讯的原理是十分有用的。

TUN Mode 是通过创建虚拟网卡的方式来代理所有流量，而 System Proxy 是通过设置系统代理的方式上网。所以二者只要选择一个就可以，一般推荐 TUN。


### sing-box 和 tun 模式的讲解 {#sing-box-和-tun-模式的讲解}

<https://www.rultr.com/tutorials/68415.html>


## 最终选择 {#最终选择}

root 权限运行 nekoray ，选用 sing-box 内核，开启 tun 模式。设置分流模式。勾选程序——记住最后的配置。测试了一段时间，现在看是稳如一条老狗。

最后，其实好用的工具不是最终目的。人最关键是在什么年龄能学到什么知识，创造什么价值。有不少人年少成名，甚至都成名后死掉了。而普通人，就算现在还普通，也要抗争，争取一个大器晚成也算是亡羊补牢。成熟的晚的人也比一辈子不成熟好。共勉。
