+++
title = "显卡测试的一些命令记录"
date = 2024-01-03T15:28:00+08:00
lastmod = 2024-01-03T15:41:44+08:00
categories = ["technology"]
draft = false
toc = true
+++

很多东西，每用一次都要查一遍，非常的麻烦。需要把常用的东西记录下来。

sudo apt install libegl1 libgl1 libgles2 libglvnd0 libglx0

sudo apt install libdrm-amdgpu1 libdrm-common libdrm-nouveau2 libdrm-radeon1  libdrm2

sudo apt install libegl-mesa0 libgbm1 libgl1-mesa-dri libglapi-mesa libglx-mesa0 mesa-va-drivers
mesa-vdpau-drivers


## 安装 glmark2 {#安装-glmark2}

sudo apt install g++ libpng-dev libjpeg-dev libx11-dev

unzip glmark2.zip

cd glmark2/

./waf configure --with-flavors=x11-gl

./waf build -j4

sudo ./waf install

sudo strip -s /usr/local/bin/glmark2


## 测试命令 {#测试命令}

x11perf -all

glmark2 --run-forever

glxgears

三个同时跑，glxgears 可以显示帧率。
