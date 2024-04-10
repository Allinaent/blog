+++
title = "xorg 代码琉理"
date = 2024-04-01T14:26:00+08:00
lastmod = 2024-04-09T13:40:59+08:00
categories = ["graphic"]
draft = false
toc = true
+++

遇到了一个 S3 后切 tty 或者关机或者重启会出现短暂的白屏的现象。但是只要不做 S3 就不会有问题。

现在通过 kill 掉所有的其它显示的组件，比如 dde 的应用 startdde ， dde-greeter ， kwin_x11 （窗口管理器）。这样的话，重启 lightdm 进程，也不会出现。可以用 startx 来手动打开 xorg 来接管进程。

这样子测试，已经确定了问题出在驱动。去掉 xorg 的执行权限，startdde 会起动 kwin_wayland ，同样有白屏的问题。肯定是显卡驱动的问题了，现在的问题是这个短暂的白屏问题应该如何解决呢？

虽然问题是驱动的，但是出问题的时候，xorg 是否已经成功退出了呢？这块可以绐 xorg 下一个断点来看看。如果是 xorg 完全退出了，那就看内核的显卡驱动由 amdgpu 切换为 tty 驱动的过程；如果 xorg 没有完全退出，那就看内核退出部分的上下文。这样也是能够缩小范围的。

现在的问题是不知道 xorg 退出时执行的代码在哪里，从哪里下断点。那么就先来学习一下 xorg 的代码吧。

总结一下相关的应用：

-   kwin_x11
-   dde_lock
-   startdde
-   kwin_wayland
-   deepin-greeter
-   xorg

xorg 的合成器可以选 xrandr ， opengl 和无三个选项。这些判断条件作为很多问题的排查手段是足够了的。内核负责的是 xorg 部分的代码和内核显示驱动部分的代码。熟练掌握 xorg 的调试也是必须要会的。


## xorg 的代码目录 {#xorg-的代码目录}

```bash
uos@guolongji:~/gg/xorg-server$ tree -d -L 1
.
├── composite
├── config
├── damageext
├── dbe
├── debian
├── dix
├── doc
├── dri3
├── exa
├── fb
├── glamor
├── glx
├── hw
├── include
├── m4
├── man
├── mi
├── miext
├── os
├── present
├── pseudoramiX
├── randr
├── record
├── render
├── test
├── Xext
├── xfixes
├── Xi
└── xkb

```

从重要到不重要，一个一个来说：

dix 目录，这个是最重要的，是 xorg 的 server 的核心代码实现的部分。

mi 目录，这个是与平台无关的绘制基础图形的目录代码。

miext 目录，是 mi 的扩展，如伸缩绘图等，应该是稍微复杂一点的绘图函数。

hw 上目录，与硬件操作有关联的代码。

os： 这个目录包含了与操作系统相关的代码，例如对不同操作系统的抽象接口、进程管理、时间等。

randr： 这个目录包含了与 Xorg 的 Resize and Rotate 扩展相关的代码，该扩展允许动态调整显示器分辨率和旋转屏幕方向。

xkb： 这个目录包含了与 X 键盘布局相关的代码，包括键盘布局的解析、管理等。

xcb： 这个目录包含了 XCB（X protocol C-language Binding）库的代码，XCB 是一个轻量级的 X 协议库，用于与 X 服务器通信。

config: 这个目录包含了 Xorg 的配置文件，包括默认的 Xorg 配置文件、模块加载配置文件等。

include: 这个目录包含了 Xorg 的头文件，用于在开发中引用 Xorg 的数据结构和函数接口。

programs: 这个目录包含了一些 Xorg 相关的工具和程序，例如 Xorg 服务器本身、X 窗口管理器等。

doc: 这个目录包含了 Xorg 的文档和说明，用于帮助开发者理解 Xorg 的设计和使用方法。

看完这部分，感觉 xorg 退出部分的代码应该在 dix 部分，也就是核心部分。


### dix/main.c 部分 {#dix-main-dot-c-部分}

dix_main 这个函数就是了。可以在这里打一个断点。之前调试过 xorg 。不知道能不能直接使用 dbgsym 包来调试，如果不能的话至少可以重新编译一个 xorg ，用 ssh 来做调试。

为了方便调试，我把之前的环境恢复一下。全部变成可以执行，重命名的文件也恢复回来。

todo ...

这是一个尝试，还有一些


## tty 部分的怀疑 {#tty-部分的怀疑}

```nil
commit ccf8a6af43ac4b34a388e222e71f9c15a6962563
Author: wenlunpeng <wenlunpeng@uniontech.com>
Date:   Thu Dec 8 18:09:07 2022 +0800

    fbcon: support Chinese charset in tty

    task: https://pms.uniontech.com/task-view-218695.html

    apply cjktty-4.19.patch, 为tty显示中文字符添加支持

    Signed-off-by: wenlunpeng <wenlunpeng@uniontech.com>
    Change-Id: If85aa3a0a074e341a3b02bbfc20ac0dd1041bf68
```

我认为这个 patch 导致了 tty 的页面刷新的速度非常地慢。切换过程当中的白屏也有类似的刷白屏现从上到下刷出来，黑屏再从上到下刷出来的一个过程。


## 解 bug 过程记录 {#解-bug-过程记录}

<https://pms.uniontech.com/bug-view-235603.html>

【问题场景】【1070 第二轮】【浪潮 CE720F 】待机唤醒后重启会闪现绿屏现象

【概率问题】必现

【问题影响】体验

【问题根因】

1 、1060U2 也有同样问题存在，但 1060 版本正常

2 、需求修改暴露问题：原本在关机的时候 startdde 会调用

org.freedesktop.login1.Manager.Reboot(0) 调用

org.freedesktop.login1.Session.Terminate() 将自身退出；后面就改成调用 .Reboot(0) 后，不再调用 Terminate(). 让 systemd 自行处理关闭进程；

3 、1060 待机唤醒后，进入桌面直接执行 org.freedesktop.login1.Manager.Reboot(0) ，也会出现这个现象

4 、modesetting 不能复现，对比 modesetting 和 amdgpu_drv 的实现可能是一个思吃点，但短时间无法解决此问题；

【评审结论】遗留

【评审人员】

【评审时间】2024.04.02


### 把思路汇总一下 {#把思路汇总一下}

-   明哥的思路是对的。他找到了代码的不同之处，这些地方的实验是要做的。
-   x86 下的安装也要试一下。可以简化分析（xorg 不复现，无法分析）

1.同样的显卡使用 x86 超翔 E500 不会有花屏的现象。arm 使用世恒 KF716-Y（GREATWALL GW001M1A-FTF）是概率性的，而 loongarch M540Z 则必现。分析问题最好用 loongarch，但是 loongarch 只能用 ftrace 和加日志来分析。

2.现在尝试加一些打印，找到出现花屏的时候是在哪个函数的执行过程当中。

通过对准秒表可以用延时加打印的方式来做。

{{< figure src="/ox-hugo/process.svg" >}}

是在这个函数的后面出现的花屏，针对这个函数做分析，是不是内核当中的做了 S3 之后 fb_helper-&gt;delayed_hotplug
的这个状态的值发生了变化呢？这个值的作用是什么呢？最好的方法是按照明哥的方法。对好秒表，然后看看是从哪个函数到哪个函数调用的中间出现的黑屏。

可以桌面开一个终端看着内核日志，tty 也同时打开一个内核日志，然后，切换的过程在不同的地方加 msleep(2000) ，这样的话通过代码二分的方法可以找到内核函数执行到哪里出现了花屏。

但是首先要弄清楚 s3 到 tty 的过程用到了哪些函数，这个过程可以用 x86 的机器来试（因为驱动的流程应该是一致的），最好再找一块 radeon 520 的显卡。这样子就比较好了，或者至少也是一块 a 卡。用 bpftrace 来分析。只有一块卡的话就先在 x86 上搞清楚流程，搞清楚了之后，再用 loongarch 来二分。


### 代码流程梳理 {#代码流程梳理}


## 路由器的高级使用方法 {#路由器的高级使用方法}

安装 Alist 可以方便的使用网盘。

使用 nekoray 可以方便的代理。使用非全局配置，默认就分的很好了。


## 我的 ubuntu-to-go 的优化 {#我的-ubuntu-to-go-的优化}

关闭 ubuntu 当中的辅助特效，可以减少撕裂。

关闭硬盘的显示。设置外观中配置 dock 行为，关闭显示卷和设备。

ubuntu 使用一个好看的 xorg 主题（没必要）。

输入法把中州韵放到第一位，再添加一个键盘英语放到第二位，这样的话，默认使用英文，可以方便打开命令。

B 站当中的一分钟变最简洁桌面，去掉顶部状态栏与左边面板。很简单，就是 setting 用鼠标点一点。会了命令也不要放弃使用简单的 UI 工具，哪个容易使用，就用哪个。关键的问题是用，而不是单纯为了炫技。


## emacs 的画图 {#emacs-的画图}


### 方案一 {#方案一}

<https://excalidraw.com/>

和 org-excalidraw 这两个重新用起来。因为看到了高英杰画的图非常地好看，我也想画出一些有价值的图。这些高级的图和文档可以让我的思路更加的清晰。让我的效率更高。


### 方案二 {#方案二}

<https://emacs-china.org/t/org-drawio-drawio-svg-orgmode-buffer/26456>

<https://github.com/kimim/org-drawio>

<https://www.bilibili.com/video/BV1Gg4y1279s/?vd_source=e0fc96fdd47a5495cc13b102051c8234>

综合来看，第二个方案更好，也集成在了 melpa 的源当中。需要下载一个 drawio 的应用程序，有 deb 的包可以直接下载现。

综合来看好用的东西，evince ，drawio 。emacs 和其它的应用程序分屏使用没有什么问题，而且以后一定会有类似 eaf 的更为好用的程序出现。一个东西可以用一辈子。人的一辈子是很短的，这当然是一个好的选择。

这个方案太完美了，可以在 orgmode 当中指定导出图片的位置，这样子的话应该可以和我 ox-hugo 写的博客完美的集成到一起。而且这个生成的图片也非常小。以后不管是写算法还是画图都解决了。


## emacs 的日程管理 {#emacs-的日程管理}

之前的日程管理方案有些复杂，主要是文件太多了，这样就会非常地让人头晕。后面只用 mydata/orgmode/gtd/_next.org
这个文件。只用一个文件会让我思路更清晰。人要选择长路大道，这样会随着时间的增长，人的能力会逐渐提高。年轻的时候可能因为懒散，智力一般没有取得什么了不起的成就，但是随着年龄的增长，一定能超越平常人。

有的事需要取巧，有些事需要漫长的积累。找到符和实际的方法，一定能得道。


## emacs 的 recentf {#emacs-的-recentf}

这个是很有用的，但是被污染了。 ~/.emacs.d/bookmarks 文件和 ~/.elfeed/index 这两个文件要过滤掉，是干扰。


## AI 编程 {#ai-编程}

<https://www.zelinai.com/model>


## 定时任务 {#定时任务}

写一个晚上 12 更新代理配置的脚本，并重启程序。当然 12 点如果没有开机也是不生效的。再写一个开机启动的脚本，和这个类似。有了这两个东西可以做到开机无感知的使用代理。有白嫖的服务可以用，真是不好意思呢。
