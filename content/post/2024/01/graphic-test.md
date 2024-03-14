+++
title = "显卡测试的一些命令记录"
date = 2024-01-03T15:28:00+08:00
lastmod = 2024-03-14T15:59:30+08:00
categories = ["technology"]
draft = false
toc = true
+++

## glmark2 的测试 {#glmark2-的测试}

很多东西，每用一次都要查一遍，非常的麻烦。需要把常用的东西记录下来。

sudo apt install libegl1 libgl1 libgles2 libglvnd0 libglx0

sudo apt install libdrm-amdgpu1 libdrm-common libdrm-nouveau2 libdrm-radeon1  libdrm2

sudo apt install libegl-mesa0 libgbm1 libgl1-mesa-dri libglapi-mesa libglx-mesa0 mesa-va-drivers
mesa-vdpau-drivers


### 安装 glmark2 {#安装-glmark2}

sudo apt install g++ libpng-dev libjpeg-dev libx11-dev

unzip glmark2.zip

cd glmark2/

./waf configure --with-flavors=x11-gl

./waf build -j4

sudo ./waf install

sudo strip -s /usr/local/bin/glmark2


### 测试命令 {#测试命令}

x11perf -all

glmark2 --run-forever

glxgears

三个同时跑，glxgears 可以显示帧率。


## 编译 mesa {#编译-mesa}

如果要编包还要加上编包的源：

这个在日构建镜像的 report/iso-build-source/ 文件夹当中。

```nil
deb http://pools.uniontech.com/desktop-professional eagle main contrib non-free
deb http://pools.uniontech.com/ppa/dde-eagle eagle/1060 main contrib non-free
```


### 步骤 {#步骤}

compile X.Org

-   安装meson

sudo apt install meson

-   下载源码

git clone "<http://gerrit.uniontech.com/base/xorg-server>" &amp;&amp; (cd "xorg-server" &amp;&amp; mkdir -p .git/hooks &amp;&amp; curl -Lo \`git rev-parse --git-dir\`/hooks/commit-msg <http://gerrit.uniontech.com/tools/hooks/commit-msg>; chmod +x \`git rev-parse --git-dir\`/hooks/commit-msg)

sudo chown -R uos ./xorg-server

sudo chgrp -R uos ./xorg-server

-   下载依赖库

sudo apt build-dep ./

-   编译xorg

假设xserver的源目录为 /home/uos/code/xorg-xserver  编译后的目录为/home/uos/xorgdist

cd /home/uos/code/xorg-xserver

export PKG_CONFIG_PATH=/home/uos/xorgdist/share/pkgconfig:/home/uos/xorgdist/lib/pkgconfig:$PKG_CONFIG_PATH

meson build --prefix=/home/uos/xorgdist --debug

cd build

ninja

ninja install

如果meson编译失败，解决方案，建议使用2

则检查/usr/sbin/deepin-elf-verify这个文件，将其换个名字，然后kill掉它的进程。（一定要先下载依赖，然后再去替换这个文件）

去安全中心-安全工具-允许任意应用

如果没有安全中心-安全工具-允许任意应用，可以去这个网址下载<https://faq.uniontech.com/desktop/app/9f30> 其中的deb包，安装之后重启就可以解决问题

-   安装XKB

<!--listend-->

```bash
cp /usr/share/X11/xkb/ /home/uos/xorgdist/share/X11/ -r
```

复制这个目录到当前文件夹中

```bash
cd /home/uos/xorgdist/bin/
ln -s /usr/bin/xkbcomp ./xkbcomp
```

-   安装 video dirver

将  /usr/lib/xorg/modules/drivers 中的so复制到 /home/zzz/xorgdist/lib/x86_64-linux-gnu/xorg/modules/drivers 中  (平板上是arch64-linux-gnu)

```bash
cp /usr/lib/xorg/modules/drivers/* /home/uos/xorgdist/lib/x86_64-linux-gnu/xorg/modules/drivers/
```

-   安装 input driverps

将/usr/lib/xorg/modules/input 中的so复制到  /home/zzz/xorgdist/lib/x86_64-linux-gnu/xorg/modules/input/目录中

```bash
mkdir /home/uos/xorgdist/lib/x86_64-linux-gnu/xorg/modules/input/
cp /usr/lib/xorg/modules/input/* /home/uos/xorgdist/lib/x86_64-linux-gnu/xorg/modules/input/
```

-   log日志

创建/home/zzz/xorgdist/var/log日志目录

mkdir -p /home/uos/xorgdist/var/log

-   2d驱动配置

将/usr/share/X11/xorg.conf.d中配置复制到/home/zzz/xorgdist/share/X11/xorg.conf.d下

```bash
cp /usr/share/X11/xorg.conf.d/* /home/uos/xorgdist/share/X11/xorg.conf.d/
```

-   通过配置启动xorg启动

/etc/lightdm/lightdm.conf

xserver-command=/home/uos/xorgdist/bin/Xorg


## 下载所有依赖包 {#下载所有依赖包}

比如一个仓库下载地址有很多的deb 包，那么就可以用这个命令来下载所有的deb 包。

```bash
wget -c -r -np -k -L -p http://path/to/debs #递归下载网页内容，但是每个目录下会多一个index.thml文件
rm`find ./ -name index.html` #删除目录及子目录下所有index.html文件
```


## 测试性能，合成器的选择 {#测试性能-合成器的选择}

sudo vim /usr/bin/kwin_no_scale

选用不同的合成器渲染，性能是不一样的。

export KWIN_COMPOSE=N X 是xrender O是opengl N是kwin
