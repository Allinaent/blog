+++
title = "丁至宣小伙伴教我diy键盘"
date = 2023-10-11T11:18:00+08:00
lastmod = 2024-06-06T16:14:54+08:00
tags = ["diy"]
categories = ["keyboard"]
draft = false
toc = true
image = "https://r2.guolongji.xyz/allinaent/2024/06/d35ab6283245f69bcfdf80eaf6c89c18.jpg"
+++

## 材料准备 {#材料准备}

-   3D 打印的壳子：

{{< figure src="/ox-hugo/img_20231012_095601.jpg" alt="Caption not used as alt text" caption="<span class=\"figure-number\">Figure 1: </span>_\"壳子\"_" class="fancy" width="800" target="_blank" >}}

-   一大堆的芯片、线还有电池

{{< figure src="/ox-hugo/img_20231012_095307.jpg" alt="Caption not used as alt text" caption="<span class=\"figure-number\">Figure 2: </span>_\"芯片和线\"_" class="fancy" width="800" target="_blank" >}}

-   其他

还需要电烙铁，钳子，一些额外的杜邦线，键轴键帽,除了轨迹球和键轴键帽，其它的东西都是丁至宣小伙伴资助的，万分感谢。

选键帽的话有，xda，moa，dsa，sa几种类型的键帽。那选哪个好呢？

<https://www.sohu.com/a/578885131_100293026>

键盘分为qmk，zmk。我们做的键盘是zmk的。zmk的官网在这里：

<https://zmk.dev/>


## 开始动工 {#开始动工}


## 关于qmk，tmk，zmk {#关于qmk-tmk-zmk}

-   zmk

zmk是zephyr这个嵌入式的os的基础上开发的。
zephyr的文档和内核的一样，看起来也都是挺全面的。
<https://zephyr-doc.readthedocs.io/>

-   qmk

而qmk可以理解为一个嵌入式的程序，只是这个程序执行开始之后永远不会退出。
<https://docs.qmk.fm/#/understanding_qmk>

-   tmk

<https://github.com/tmk/tmk_keyboard/wiki>
而tmk同qmk类似，也是一个嵌入式程序。AVR单片机芯片或者是arm架构的mcu。构建系统和芯片可能用的不一样。

从学习的角度讲，看更现代更主流的firmware代码当然更有利。学习一些rtos，ros，外设可以用的zephyr os，这些都是很好的。有助于你的成长。无非涉及到一些硬件和软件的概念，和linux通用的台式机和笔记本没有本质的区别。


## ox-hugo image resize {#ox-hugo-image-resize}

<https://corra.fi/posts/ox-hugo-friendly-resize/>

{{< figure src="/ox-hugo/img_20231011_174251.jpg" >}}

{{< figure src="/ox-hugo/img_20231011_175457.jpg" >}}

<https://wiki.archlinux.org/title/Screen_capture>

要我自己写一个压缩工具吗？大可不必：
nix-env -iA nixpkgs.shutter

shutter这个工具完全比任何其它的截图工具好用，超过 Deepin Screenshot。

arch的wiki上对这个软件也没有重点突出出来。这个软件最好。

{{< figure src="/ox-hugo/img_20231012_094223.jpg" >}}

设置完快捷键。

但是还是有问题的，需要shutter截图后再手动拖一下。不过已经不太影响使用了。
