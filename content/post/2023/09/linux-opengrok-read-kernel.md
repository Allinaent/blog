+++
title = "linux上用docker搭建opengrok"
date = 2023-09-20T14:05:00+08:00
lastmod = 2024-06-06T15:36:22+08:00
tags = ["docker", "opengrok"]
categories = ["technology"]
draft = false
toc = true
image = "https://r2.guolongji.xyz/allinaent/2024/06/92a1feeab471b12646b9c76edccc1546.jpg"
+++

之前在 21 年底用 latex 写了这篇文章，导出了 pdf，后觉得有用，移到博客当中，方便以后查看。
23 年了 opengrok 可能有新的版本了，但是 21 年的版本也不算旧。折腾一次花的时间也挺长的。


## 主机搭建 {#主机搭建}

在物理机上搭建 opengrok 的过程比较简单。

```bash
sudo apt install openjdk-11-jdk
cd ~
mkdir opengrok-install
cd opengrok-install
sudo apt install universal-ctags
sudo apt install git
# 加速下载:
wget http://shrill-pond-3e81.hunsh.workers.dev/https://github.com/oracle/opengro
k/releases/download/1.7.26/opengrok-1.7.26.tar.gz
tar zxvf opengrok-1.7.26.tar.gz
wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.0.14/bin/apache-tomcat-10.0.1
4.tar.gz
tar zxvf apache-tomcat-10.0.14.tar.gz
sudo -s
cp -r apache-tomcat-10.0.14 /tomcat
cp -r opengrok-1.7.26 /opengrok
chown -R uos:uos tomcat/ opengrok/
exit
mkdir /opengrok/{src,data,dist,etc,log}
# 使用默认日志配置
cp /opengrok/doc/logging.properties /opengrok/etc
# 使用修改的日志配置
cat>/opengrok/etc/logging.properties<<EOF
handlers= java.util.logging.FileHandler, java.util.logging.ConsoleHandler
java.util.logging.FileHandler.pattern = /opengrok/log/opengrok%g.%u.log
java.util.logging.FileHandler.append = false
java.util.logging.FileHandler.limit = 0
java.util.logging.FileHandler.count = 30
java.util.logging.FileHandler.level = ALL
java.util.logging.FileHandler.formatter = org.opengrok.indexer.logger.formatter.SimpleFileLogFormatter
java.util.logging.ConsoleHandler.level = WARNING
java.util.logging.ConsoleHandler.formatter = org.opengrok.indexer.logger.formatter.
SimpleFileLogFormatter
org.opengrok.level = FINE
EOFcd /opengrok/lib
cp source.war /tomcat/webapps/
cd /tomcat/bin
sh startup.sh
# 此时,打开浏览器输入 http://ip:8080/source 会显示报错。但是已安装完成,需要索引项目代码。
cd /opengrok/
cat>index.sh<<EOF
#!/bin/bash
java -Xmx8g \
-Djava.util.logging.config.file=/opengrok/etc/logging.properties \
-DSYNC_PERIOD_MINUTES="60" \
-DOPENGROK_SCAN_REPOS=false \
-DOPENGROK_GENERATE_HISTORY=off \
-jar /opengrok/lib/opengrok.jar \
-c /usr/bin/ctags \
-s /opengrok/src/ -d /opengrok/data -H -P -S -G \
-W /opengrok/etc/configuration.xml -U http://localhost:8080/source \
-m 512
EOF
# SYNC_PERIOD_MINUTES这个环境变量是opengrok docker镜像的,上述命令中无用,可以去掉
# -Xmx8g:配置Java 最大堆内存为8g,防止内存溢出。
# -jar:指定opengrok.jar包。
# -c:指定universal-ctags的路径
# -s:指定源码路径,就是上面的新建的src。
# -d:指定索引文件存放路径,就是上面新建的data。
# -W:指定configuration.xml的路径,就是上面新建的etc。
# -m:指定opengrok索引时的缓存大小,默认只有16M。
### 注意此步骤需要手动修改后执行
# ln -s 内核代码目录 /opengrok/src/项目名称
# ...
# 多个项目必需使用符号链接,否则出错。
###
chmod u+x index.sh
./index.sh
# 等待若干时间后(日志记录在/opengrok/log/中,出现finish结束),打开浏览器输入
http://ip:8080/source
```

强烈建议有兴趣的同事研究以下 opengrok 这个项目的架构和实现。


## docker 搭建 {#docker-搭建}

使用 docker 搭建,opengrok 官网在 dockerhub(<https://hub.docker.com/>)提供了简化版本的镜像工具,可以通过:docker pull opengrok/docker 来拉取,实际上对于 linux kernel 和 AOSP(Android Open Source Project)不可用。

需要自己实现镜像,使用 dockerfile 或者 compose 编排工具。

有两个实现可以参考,但是这两个都是几年前的实现。

实现一:<https://github.com/ffgiff/opengrok-docker>

实现二:<https://github.com/thombashi/docker-opengrok>

另外,docker 的相关知识和 dockerfile 的多阶段构建可以参考:<https://yeasy.gitbook.io/docker_practice,%E5%81%9A%E5%A5%BD>
后可以镜像上传到 docker 仓库。

原材料是 tomcat:10.0-jre11-temurin-focal,安装 universal-ctags,git,opengrok 通用二进制包,配置 dockerfile
中的 CMD 和 VOLUME。docker build 生成镜像。拉取镜像,放入项目符号链接。启动 docker 容器,等待一段时间。完成。

安装 docker:

```bash
curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
sudo groupadd docker
sudo gpasswd -a ${USER} docker
sudo service docker restart
sudo chmod a+rw /var/run/docker.sock
sudo -s
cat>/etc/docker/daemon.json<<EOF
{
"registry-mirrors" : [
"https://registry.docker-cn.com",
"https://docker.mirrors.ustc.edu.cn",
"http://hub-mirror.c.163.com",
"https://cr.console.aliyun.com/"
]
}
EOF
# 重启docker服务使配置生效
systemctl restart docker.service
exit
# 验证
# docker pull tomcat:10.0-jre11-temurin-focal
# docker run -it tomcat:10.0-jre11-temurin-focal /bin/bash
```

docker 中的 EXPOSE 和 LABEL 分别是什么含义。

LABEL:添加元数据。

EXPOSE:暴露端口,只是声名。

WORKING:使用 WORKDIR 指令可以来指定工作目录(或者称为当前目录),以后各层的当前目录就被改为指定的目录,如该目录不存在,WORKDIR 会帮你建立目录。

universal_ctags_installer.sh 如下:

```bash
#!/usr/bin/env shset -ex
dist=$1
curr_dir=$(pwd)
work_dir=$(mktemp --directory)
cd "$work_dir"
git clone https://github.com.cnpmjs.org/universal-ctags/ctags.git
cd ctags
./autogen.sh
if [ "$dist" = "" ]; then
./configure
else
./configure --prefix="$dist"
fi
make -j2
make install
cd "$curr_dir"
rm -rf "$work_dir"
```

dockerfile 如下:

```bash
FROM buildpack-deps:stretch-scm AS ctags-builder
LABEL maintainer="Allinaent <1909943253@qq.com>"
LABEL envrefresh_date="2021-01-24"
RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
echo "deb http://mirrors.aliyun.com/debian/ stretch main non-free contrib" >>/etc/apt/sources.list
&& \
echo "deb-src http://mirrors.aliyun.com/debian/ stretch main non-free contrib" >>/etc/apt/sources.
list && \
echo "deb http://mirrors.aliyun.com/debian-security stretch/updates main" >>/etc/apt/sources.list
&& \
echo "deb-src http://mirrors.aliyun.com/debian-security stretch/updates main" >>/etc/apt/sources.
list && \
echo "deb http://mirrors.aliyun.com/debian/ stretch-updates main non-free contrib" >>/etc/apt/
sources.list && \
echo "deb-src http://mirrors.aliyun.com/debian/ stretch-updates main non-free contrib" >>/etc/apt/
sources.list && \
echo "deb http://mirrors.aliyun.com/debian/ stretch-backports main non-free contrib" >>/etc/apt/
sources.list && \
echo "deb-src http://mirrors.aliyun.com/debian/ stretch-backports main non-free contrib" >>/etc/
apt/sources.list
RUN apt-get update && apt-get install -y --no-install-recommends \autoconf \
automake \
gcc \
libc6-dev \
make \
pkg-config \
&& rm -rf /var/lib/apt/lists/*
COPY universal_ctags_installer.sh /usr/local/bin/universal_ctags_installer
RUN chmod 544 /usr/local/bin/universal_ctags_installer
# CMD ["universal_ctags_installer", "/dist"]
# dockerfile中的CMD命令 CMD ["<可执行文件或命令>","<param1>","<param2>",...]
RUN ["universal_ctags_installer", "/dist"]
# build universal ctags --------------------------------------------
# FROM thombashi/universal-ctags-installer:latest AS ctags-builder
# WORKDIR /dist
# RUN universal_ctags_installer /dist
# launch opengrok --------------------------------------------
From tomcat:jre11-temurin-focal
# LABEL maintainer="Allinaent <1909943253@qq.com>"
COPY --from=ctags-builder /dist/bin/ctags /usr/local/bin/ctags
ENV OPENGROK_VERSION 1.7.26
ENV OPENGROK_INSTANCE_BASE /opengrok
ENV OPENGROK_SRC_ROOT /opengrok/src
ENV OPENGROK_TOMCAT_BASE /usr/local/tomcat
ENV CATALINA_BASE /usr/local/tomcat
ENV CATALINA_HOME /usr/local/tomcat
ENV CATALINA_TMPDIR /usr/local/tomcat/temp
# ENV JRE_HOME /usr
ENV CLASSPATH /usr/local/tomcat/bin/bootstrap.jar:/usr/local/tomcat/bin/tomcat-juli.jar
# RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
# 换源
RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
echo "deb http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse" >>/etc/apt/
sources.list && \
echo "deb-src http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse" >>/etc/
apt/sources.list && \
echo "deb http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse"
>>/etc/apt/sources.list && \
echo "deb-src http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse" >>/etc/apt/sources.list && \
echo "deb http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse" >>/
etc/apt/sources.list && \
echo "deb-src http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse"
>>/etc/apt/sources.list && \
echo "deb http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse"
>>/etc/apt/sources.list && \
echo "deb-src http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse"
>>/etc/apt/sources.list && \
echo "deb http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse"
>>/etc/apt/sources.list && \
echo "deb-src http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe
multiverse" >>/etc/apt/sources.list
# RUN apt-get clean
RUN apt-get update && apt-get install --no-install-recommends -y \
git \
inotify-tools \
wget \
&& rm -rf /var/lib/apt/lists/*
# https://download.fastgit.org/ 这个下载镜像
# 正式使用
# wget --quiet -O - $OPENGROK_ARCHIVE_URL | tar zxf - ; \
WORKDIR $OPENGROK_INSTANCE_BASE
RUN set -eux ; \
mkdir data etc ; \
OPENGROK_ARCHIVE_FILE=opengrok-${OPENGROK_VERSION}.tar.gz ; \
OPENGROK_ARCHIVE_URL=https://download.fastgit.org/oracle/opengrok/releases/download/1.7.26/
opengrok-1.7.26.tar.gz;
# 测试使用
COPY opengrok-1.7.26.tar.gz /opengrok
RUN tar zxvf opengrok-1.7.26.tar.gz ; \
mv opengrok-${OPENGROK_VERSION}/* . ;
#
./bin/OpenGrok deploy ;
RUN rm -rf opengrok-1.7.26.tar.gz opengrok-1.7.26 ;
# 下面的步骤需要修改
# RUN mkdir /opengrok/{src,data,dist,etc,log} ; \
RUN bash -c ’mkdir -p /opengrok/{src,data,dist,etc,log}’ ; \
cp /opengrok/lib/source.war ${OPENGROK_TOMCAT_BASE}/webapps/
COPY logging.properties /opengrok/etc/logging.properties
COPY index.sh /opengrok/
RUN chmod u+x /opengrok/index.sh
COPY run_opengrok.sh /usr/local/bin/run_opengrok
RUN chmod 544 /usr/local/bin/run_opengrokENTRYPOINT ["/usr/local/bin/run_opengrok"]
EXPOSE 8080
# 使用:docker run -d -v <directory with files to be indexed>:/src -v <...>:<...> -p <PORT>:8080
thombashi/opengrok
# 用小项目测试
# docker查看日志:docker logs -f -t --tail 10 972a542ceb21
# docker run -d -v /home/uos/gg/abi/kabi-dw-src/kabi-dw:/opengrok/src -p 8080:8080 lj-opengrok:v1
```

index.sh 如下:

```bash
#!/bin/bash
java -Xmx8g \
-Djava.util.logging.config.file=/opengrok/etc/logging.properties \
-DOPENGROK_SCAN_REPOS=false \
-DOPENGROK_GENERATE_HISTORY=off \
-jar /opengrok/lib/opengrok.jar \
-c /usr/local/bin/ctags \
-s /opengrok/src/ -d /opengrok/data -H -P -S -G \
-W /opengrok/etc/configuration.xml -U http://127.0.0.1:8080/source \
-m 512
```

docker 启动的 ENTRY_POINT 如下(需要额外注意 tomcat 启动之后必须 sleep 几秒,否则后面 index 报错)：

```bash
#!/bin/sh
set -x
INOTIFY_CMD="inotifywait --recursive --event close_write /opengrok/src"
REINDEX_GRACE_PERIOD=10 # [secs]
REINDEX_INTERVAL=20 # [secs]
DATE_CMD="date --rfc-3339=seconds"
sh /usr/local/tomcat/bin/startup.sh
sleep 10
echo "----- $($DATE_CMD): source code indexing -----" 1>&2
sh /opengrok/index.sh
while true; do
while $INOTIFY_CMD ; do
echo "----- $($DATE_CMD): reindex grace period: $REINDEX_GRACE_PERIOD secs -----" 1>&2
sleep $REINDEX_GRACE_PERIOD
echo "----- $($DATE_CMD): reindexing -----" 1>&2
sh /opengrok/index.sh
# discard changes during the grace period and the reindexing
breakdone
echo "----- $($DATE_CMD): reindex interval: $REINDEX_INTERVAL secs -----" 1>&2
sleep $REINDEX_INTERVAL
done
```

docker 镜像的制作和上传如下:

```bash
docker build -t lj-opengrok:v1 .
docker tag 24d63cd01336 allinaent/lj-opengrok:v1.0
docker login
docker push allinaent/lj-opengrok:v1.0
```

启动 opengrok 的命令如下(注意-v 多个可以索引多个项目):

```bash
docker run -d -v host-src-path:/opengrok/src/project-name -p 8080:8080 allinaent/lj-opengrok:v1.0
# 查看日志
docker logs -f -t --tail 200 c4c57efb939871d3840a271741b1f9ea9bf454519b8e412e08a4aad513c9ee78
```


## 总结 {#总结}

阅读代码工具认识操作系统的开始,docker 值得一用。对于使用者而言只需要三个步骤:

-   安装 docker 工具。

<!--listend-->

```bash
curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
sudo groupadd docker
sudo gpasswd -a ${USER} docker
sudo service docker restart
sudo chmod a+rw /var/run/docker.sock
sudo -s
cat>/etc/docker/daemon.json<<EOF
{
"registry-mirrors" : [
"https://registry.docker-cn.com",
"https://docker.mirrors.ustc.edu.cn",
"http://hub-mirror.c.163.com",
"https://cr.console.aliyun.com/"
]
}
EOF
# 重启docker服务使配置生效
systemctl restart docker.service
exit
```

-   pull

<!--listend-->

```bash
docker pull allinaent/lj-opengrok:v1.0
```

-   运行

<!--listend-->

```bash
docker run -d -v ${host-src-path}:/opengrok/src/${project-name} -p 8080:8080 allinaent/lj-opengrok:v1.0
```
