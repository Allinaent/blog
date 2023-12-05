+++
author = ["郭隆基"]
date = 2023-09-25T10:31:00+08:00
lastmod = 2023-12-05T11:38:59+08:00
tags = ["gpu"]
categories = ["technology"]
draft = false
toc = true
+++

这篇文档可以在：<https://guolongji.xyz/post/tty-x-switch/> 这里看到更新。


## 概念 {#概念}

-   Console

Console 意即控制台。Console 出现在操作系统诞生之前，那个时候的老式计算机还只能通过按钮开关等方式控制计算机的运转，而 Console 就是将控制计算机器件集中起来的面板。由于现代计算机不再使用控制台来控制电脑，所以现代操作系统中的 Console 一般指控制台终端。

-   Terminal

Terminal 意即终端。顾名思义，是连接到计算机上的终端设备。当操作系统出现之后，不再使用控制台与计算机交互，而是使用命令，为了能够输入这些命令，出现了电传打字机（Teletype），程序输入输出可以通过电传打字机打印到屏幕上。所以 Terminal 其实是指一种监视计算机输入输出的硬件。但是现代操作系统中使用更多的是软件仿真终端。

-   TTY

TTY 即 TeleTYpe，意即电传打字机。TTY 与 Terminal 初期是同一个概念，电传打字机连接到计算机上便是一台终端设备。当时的 TTY 需要使用 UART 驱动来传输数据，而现代计算机中的 TTY 直接将输出数据渲染成视频信号，输出到显示器中，这些操作都运行在内核态。目前只能在连接键盘与显示器的计算机上使用 TTY。

-   PTY

PTY 即 Pseudo TeleTYpe，意即伪 TTY。PTY 是现代计算机中使用终端模拟软件或者 SSH 连接所使用的伪终端，运行在用户态。现代操作系统使用的终端都是伪终端，通过终端软件对终端进行模拟。PTY 为了保证能够与 TTY 兼容，采用了主从结构，分为 PTY slave side 与 PTY master side。

-   PTY slave side

PTY slave side 的通过 TTY 驱动实现。PTY slave side 与 PTY master side 进行连接，将程序输入输出发送给 PTY
master side 并显示出来。

-   PTY master side

PTY master side 会将程序的输入输出显示在终端模拟软件中。例如当时用 SSH 远程连接时，PTY master side 与 SSH 连接，交换数据。

-   PTMX

ptmx 是 Linux 操作系统中的一个特殊设备文件，它代表了伪终端（pseudo-terminal）主设备。伪终端是一种虚拟设备，用于提供交互式终端功能，让程序能够与终端进行通信。

ptmx 的全称是 "Pseudo Terminal Master for X"，它是伪终端机制的主控端，通过打开 ptmx 设备可以获得一个伪终端从设备文件（例如 /dev/pts/0）。

在 Linux 中，当一个程序打开 ptmx 设备并请求一个新的伪终端时，内核会创建一对相互连接的伪终端从设备（slave），然后把主设备（master）的文件描述符和从设备的路径返回给程序。程序可以使用这对从设备和主设备进行通信，就像在与真实终端进行交互一样。

伪终端在很多应用中非常有用，比如远程登录、终端模拟器、串口通信等。它提供了一个可编程的、终端兼容的接口，使得程序可以以交互的方式与其他终端应用或设备进行通信，而无需直接依赖物理终端。

总结来说，ptmx 是 Linux 中用于创建和管理伪终端的主设备文件，它为程序提供了与终端交互的接口，为终端模拟、远程登录等操作提供了基础支持。

说人话就是，每打开一个 terminal 的程序 ptmx 就会创建一个新的 "/dev/pts" 的下的设备。sysctl kernel.pty.max，能查到这个值是 4096。伪终端的数量也是有限制的。

-   dev 下的 ttyX

可以 chvt 进入，即终端，而 pts 目录下的是不能那么进去的。

VT 不需要显卡驱动的支持。framebuffer 相关的代码在内核的 drivers/video/fbdev/fbcon.c 当中。

VT 驱动的代码在 drivers/tty/vt/vt.c 当中。其中的 visual_init 函数中调用 con_init 函数。

流程是内核启动初始化。

{{< figure src="/ox-hugo/img_20230926_090023.png" alt="Caption not used as alt text" caption="<span class=\"figure-number\">Figure 1: </span>_tty 子系统架构图_" link="t" class="fancy" width="700" target="_blank" >}}


## 如何将一个 tty 和一个 xorg 关连起来？ {#如何将一个-tty-和一个-xorg-关连起来}

分配新用户的 TTY 涉及到内核中几个关键的函数。以下是其中的一些函数：

1.get_unused_tty_index()：用于获取一个未被使用的 TTY 索引。每个 TTY 都有一个唯一的索引号，内核使用这个索引号来标识不同的 TTY 设备。

2.tty_alloc_driver()：用于为新的 TTY 实例分配一个 TTY 驱动结构体。TTY 驱动结构体保存了与 TTY 设备相关的信息和操作。

3.tty_init_dev()：用于初始化新的 TTY 设备。这个函数会设置 TTY 的状态、配置串口传输参数以及注册 TTY 设备到系统中。

4.tty_open()：用于打开 TTY 设备。当一个用户切换到一个新的 TTY 时，内核会调用这个函数来打开对应的 TTY 设备。

5.vt_do_activate()：用于激活虚拟终端（Virtual Terminal，VT）。在 Linux 中，每个 TTY 都对应一个 VT，用于提供文本终端的功能。这个函数会激活新的 VT，并将其与对应的 TTY 关联起来。

这些函数位于内核的 TTY 子系统中，负责管理和处理 TTY 设备。通过调用这些函数，内核能够分配和管理多个 TTY 设备，并在用户切换到不同的 TTY 时分配适当的资源和处理相应的操作。

xorg 通过命令行参数 -vt 1 来绑定。


### vt 的切换流程 {#vt-的切换流程}

Ctrl-Alt-F2 在只有一个用户时，切换是切到 tty 的界面。但是如果有多个登陆的用户时就会切换到其它用户的图形界面。

当用户切换到新的 TTY 时，涉及到内核的一些操作来实现切换。下面是内核切换 TTY 的详细流程：

用户请求切换 TTY：用户可以通过按下 Ctrl+Alt+F1 到 F6（一般情况下，Linux 系统提供了 6 个 TTY 终端）的组合键来请求切换到相应的 TTY。

用户空间程序处理请求：当用户按下组合键后，一个特殊的信号（如 SIGINT）将发送给前台进程组中的所有进程。在这种情况下，TTY 驱动程序会接收到信号并执行相应的操作。

TTY 驱动程序检测信号并通知内核：TTY 驱动程序会检测到信号，并将其传递给内核。内核会响应该信号，并开始进行 TTY 切换的操作。

内核切换控制台：内核会根据信号中指定的 TTY 编号，将当前活动的 TTY 切换到新的 TTY。它会关闭当前 TTY 的输入和输出，并重新配置设备以与新的 TTY 关联。

内核执行 TTY 切换操作：内核会执行以下操作来完成 TTY 切换：

关闭当前 TTY 设备：内核将关闭当前 TTY 设备的输入和输出，在切换期间停止与 TTY 设备的通信。加载新 TTY 设备：内核会初始化和配置新的 TTY 设备，包括打开新 TTY 设备的输入和输出通道。切换虚拟终端结构：内核会更新虚拟终端结构，以反映当前活动的 TTY 设备。用户空间程序刷新屏幕：在 TTY 切换完成后，用户空间程序将被激活，并负责更新新 TTY 的屏幕内容。

总体而言，内核切换 TTY 的过程涉及到信号处理、设备配置和数据传输等操作。内核负责管理和控制 TTY 设备的状态，以确保正确的 TTY 切换和用户体验。这样，用户可以在不同的 TTY 中进行并发的文本模式会话。


## dbus {#dbus}

-   lightdm(org.freedesktop.DisplayManager)

登录管理：LightDM 提供用户界面，使用户能够输入用户名和密码登录系统。它支持不同的登录方式，如图形界面登录、远程登录和自动登录。

会话管理：LightDM 管理用户登录后的会话过程。它允许用户选择默认的窗口管理器或桌面环境，并为每个用户保存其首选设置。

多用户支持：LightDM 支持多个用户账号，并为每个用户提供独立的登录环境。这意味着多个用户可以同时登录到同一台计算机上，而不会相互干扰。

主题和样式定制：LightDM 允许用户自定义登录界面的外观和样式。用户可以选择不同的主题、背景图像、字体和颜色方案，以创建自己喜欢的登录界面。

扩展性和集成：LightDM 支持插件和扩展，可以与各种其他软件和服务集成。它可以与不同的窗口管理器、桌面环境和身份验证系统一起使用。

总的来说，LightDM 是一个灵活、可定制和易于使用的显示管理器，它提供了一个简单而强大的界面来管理用户登录会话。

-   greeter(lightdm-deepin-greeter)

-   deepin-authenticate(com.deepin.daemon.Authenticate)

-   systemd-logind(org.freedesktop.login1)

-   dde-lockservice(org.deepin.dde.LockService1)

-   dde-system-daemon(org.deepin.dde.Accounts1)

-   accounts-daemon(org.freedesktop.Accounts)

以上服务，基本都是 system bus，可以通过 d-feet 去看对应的接口。可以用 dbus-send，gdbus 和 qdus 来发送 dbus
信号，信号的


### dbus 接口的使用 {#dbus-接口的使用}

我们有一个服务 deepin-authenticate 是用 golang 来实现的。golang 的 dbus 库的文档在这里：

<https://pkg.go.dev/github.com/godbus/dbus>

Kwin 中用的是 qdbus 的库。

dbus 的核心概念就是总线消息。


## linux 图形学中的一些概念 {#linux-图形学中的一些概念}


### DM，WM 与 X Display Manager Control Protocol（XDMCP） {#dm-wm-与-x-display-manager-control-protocol-xdmcp}

-   显示管理器 DM
    又称为“登陆管理器”。有 lightdm，xdm（x display manager），sddm（Simple Desktop Display Manager），
    gdm（gnome Display manager）。

可以用登陆脚本代替 DM，比如 xinit + startx 的方式。xinit 程序允许用户手动启动 Xorg 显示服务器。startx 脚本是 xinit 的一个前端。

xorg-xinit 这个包切换用户最终调用的是：

-   窗口管理器

kwin（dde，支持 X11 和 wayland）、sway（支持 wayland）、wayfire（支持 wayland）、hyperland（现在最火的 wayland wm）、awesome、i3wm、mutter（gnome）......

在 uos 中可以安装 dde-dconfig-editor 可以选择用 kwin 来启动窗口管理器。

<https://www.x.org/releases/current/doc/>

man X，本地可以看到。关于 X11 的文档都在这个里面了，是英文，内容很多。

lightdm 的配置文件在： `/etc/lightdm/` 里；

xorg 的配置文件在这里： `/etc/X11/` 里；

通过 pstree 能看到图形的启动流程：

```nil
uos@guolongji:~$ pstree --ascii
systemd-+ ......
        |-lightdm-+-Xorg---3*[{Xorg}]
        |         |-lightdm-+-startdde-+-DeepinAIAssista---9*[{DeepinAIAssista}]
        |         |         |          |-DeepinVoiceWake---{DeepinVoiceWake}
        |         |         |          |-agent---2*[{agent}]
        |         |         |          |-bd-qimpanel.wat---sleep
        |         |         |          |-chrome-+-2*[cat]
        |         |         |          |        |-2*[chrome---7*[{chrome}]]
        |         |         |          |        |-chrome---chrome---24*[{chrome}]
        |         |         |          |        |-chrome-sandbox---chrome-+-chrome-+-19*[chrome---12*[{chrome}]]
        |         |         |          |        |                         |        |-3*[chrome---13*[{chrome}]]
        |         |         |          |        |                         |        |-chrome---14*[{chrome}]
        |         |         |          |        |                         |        |-chrome---4*[{chrome}]
        |         |         |          |        |                         |        |-2*[chrome---7*[{chrome}]]
        |         |         |          |        |                         |        `-chrome---15*[{chrome}]
        |         |         |          |        |                         `-chrome-sandbox---nacl_helper
        |         |         |          |        `-25*[{chrome}]
        |         |         |          |-dde-calendar-se---2*[{dde-calendar-se}]
        |         |         |          |-dde-clipboard---5*[{dde-clipboard}]
        |         |         |          |-dde-desktop---27*[{dde-desktop}]
        |         |         |          |-dde-dock---25*[{dde-dock}]
        |         |         |          |-dde-file-manage---28*[{dde-file-manage}]
        |         |         |          |-dde-launcher---24*[{dde-launcher}]
        |         |         |          |-dde-lock---24*[{dde-lock}]
        |         |         |          |-dde-osd---7*[{dde-osd}]
        |         |         |          |-dde-polkit-agen---5*[{dde-polkit-agen}]
        |         |         |          |-dde-printer-hel---9*[{dde-printer-hel}]
        |         |         |          |-dde-session-dae---50*[{dde-session-dae}]
        |         |         |          |-deepin-deepinid---30*[{deepin-deepinid}]
        |         |         |          |-deepin-defender---5*[{deepin-defender}]
        |         |         |          |-emacs-+-codeium_languag-+-codeium_languag---15*[{codeium_languag}]
        |         |         |          |       |                 `-15*[{codeium_languag}]
        |         |         |          |       |-epdfinfo
        |         |         |          |       |-python3---8*[{python3}]
        |         |         |          |       `-10*[{emacs}]
        |         |         |          |-emacs-+-codeium_languag-+-codeium_languag---17*[{codeium_languag}]
        |         |         |          |       |                 `-19*[{codeium_languag}]
        |         |         |          |       |-epdfinfo
        |         |         |          |       |-mu
        |         |         |          |       |-python3---8*[{python3}]
        |         |         |          |       |-python3
        |         |         |          |       `-5*[{emacs}]
        |         |         |          |-evince---4*[{evince}]
        |         |         |          |-kitty-+-bash---pstree
        |         |         |          |       `-3*[{kitty}]
        |         |         |          |-kwin_no_scale---kwin_x11---10*[{kwin_x11}]
        |         |         |          |-wps---wps---9*[{wps}]
        |         |         |          `-62*[{startdde}]
        |         |         `-2*[{lightdm}]
        |         `-2*[{lightdm}]
        |- ......
```


## AMD 显卡的架构演进 {#amd-显卡的架构演进}

<https://medium.com/high-tech-accessible/an-overview-of-amds-gpu-architectures-884432a717a6>

{{< figure src="/ox-hugo/img_20231101_111732.jpg" >}}

{{< figure src="/ox-hugo/img_20231101_111814.jpg" >}}

{{< figure src="/ox-hugo/img_20231101_111850.jpg" >}}

sudo apt install mesa-utils

```nil
uos@guolongji:~$ glxinfo -B
name of display: :0
display: :0  screen: 0
direct rendering: Yes
Extended renderer info (GLX_MESA_query_renderer):
    Vendor: X.Org (0x1002)
    Device: AMD CAICOS (DRM 2.50.0 / 4.19.0-amd64-desktop, LLVM 7.0.1) (0x6779)
    Version: 19.2.6
    Accelerated: yes
    Video memory: 2048MB
    Unified memory: no
    Preferred profile: core (0x1)
    Max core profile version: 3.3
    Max compat profile version: 3.1
    Max GLES1 profile version: 1.1
    Max GLES[23] profile version: 3.1
Memory info (GL_ATI_meminfo):
    VBO free memory - total: 2047 MB, largest block: 2047 MB
    VBO free aux. memory - total: 1021 MB, largest block: 1021 MB
    Texture free memory - total: 2047 MB, largest block: 2047 MB
    Texture free aux. memory - total: 1021 MB, largest block: 1021 MB
    Renderbuffer free memory - total: 2047 MB, largest block: 2047 MB
    Renderbuffer free aux. memory - total: 1021 MB, largest block: 1021 MB
Memory info (GL_NVX_gpu_memory_info):
    Dedicated video memory: 2048 MB
    Total available memory: 3069 MB
    Currently available dedicated video memory: 2047 MB
OpenGL vendor string: X.Org
OpenGL renderer string: AMD CAICOS (DRM 2.50.0 / 4.19.0-amd64-desktop, LLVM 7.0.1)
OpenGL core profile version string: 3.3 (Core Profile) Mesa 19.2.6
OpenGL core profile shading language version string: 3.30
OpenGL core profile context flags: (none)
OpenGL core profile profile mask: core profile

OpenGL version string: 3.1 Mesa 19.2.6
OpenGL shading language version string: 1.40
OpenGL context flags: (none)

OpenGL ES profile version string: OpenGL ES 3.1 Mesa 19.2.6
OpenGL ES profile shading language version string: OpenGL ES GLSL ES 3.10
```

-   Caicos 和 TeraScale 是什么关系？

Caicos 和 TeraScale 是 AMD 显卡架构中的两个不同概念，它们之间存在一定的关系。

TeraScale 是 AMD 显卡架构中的一个历史阶段，它首次于 2007 年推出，被广泛应用于 Radeon HD 3000、4000、5000 和
6000 系列显卡中。TeraScale 架构采用了传统的 VLIW（Very Long Instruction Word）设计，通过组合多个简单指令来实现复杂的计算任务。TeraScale 架构在当时是非常先进的，但随着计算单元的增多，复杂度也逐渐增加，导致处理器设计难度和功耗成倍提升。

而 Caicos 则是 TeraScale 2 架构中的一个代表，它是 AMD Radeon HD 6400 和 6500 系列显卡所采用的架构。
TeraScale 2 架构在 TeraScale 架构的基础上进行了一些优化，如引入了更高效的纹理单元和几何单元，并支持
DirectX 11 和 OpenGL 4.1 等新的标准。同时，TeraScale 2 架构还采用了更加先进的 40nm 制程工艺，使得功耗和热量控制得到了更好的平衡。

因此，可以说 Caicos 是 TeraScale 2 架构中的一个代表，是 AMD 在当时对 TeraScale 架构的改进和升级。虽然 Caicos 和 TeraScale 有所区别，但它们都是 AMD 显卡架构中的重要部分，并共同推动了 AMD 显卡技术的发展。


## AMD 驱动代码的模块划分和代码介绍 {#amd-驱动代码的模块划分和代码介绍}

-   DCE

AMD 的 DCE（Display Core Engine）模块是 AMD 显卡中的一个重要组件，它主要负责图形处理单元（GPU）和显示输出之间的通信和协调工作。DCE 模块具有以下功能：

1.显示控制：DCE 模块负责显卡的显示控制功能，包括显示输出的配置、分辨率管理、刷新率控制等。它能够接收来自 GPU
的图像数据，并将其转换为适当的格式并输出到连接的显示设备上。

2.多显示器支持：DCE 模块支持多显示器配置，可以同时驱动多个显示设备，例如多个显示器、投影仪等。它能够管理和控制多个显示输出，并确保它们按照用户的设置正确运行。

3.显示连接管理：DCE 模块负责检测和管理显示设备的连接状态。它能够自动检测连接的显示设备，并在需要时进行重新配置和重新协商，以确保正常的显示输出。

4.显示特性增强：DCE 模块还提供了一些显示特性的增强功能，例如色彩管理、色彩空间转换、多显示器融合等。这些功能可以提供更好的显示效果和用户体验。

总的来说，DCE 模块在 AMD 显卡中扮演着重要的角色，它是 GPU 与显示输出之间的桥梁，负责管理、控制和增强显示功能，使用户能够获得良好的图形和显示效果。

-   DCE 模块和 display 模块是什么关系？

display 模块包含了 DCE 模块的所有功能，同时还集成了其他相关的硬件和软件组件，例如视频解码器、视频编码器、色彩管理等。它提供了一种精简和高效的架构，以便更好地支持多显示器配置和多种显示输出配置。

除了 DCE 模块的主要功能外，display 模块还提供了其他的增强功能，例如：

1.包括 HDMI、DisplayPort 和 DVI 等多种显示输出标准的支持。

2.支持硬件加速的视频解码和编码功能，能够加速高清视频的播放和转码。

3.能够支持高分辨率和广色域的显示输出，以提供更好的画质和色彩表现效果。

总之，DCE 模块是 AMD 显卡中的一个核心组件，而 display 模块则是一个集成了 DCE 模块功能的子系统，并提供了其他相关的硬件和软件组件，以实现更好的画质和用户体验。

-   UVD

UVD（Unified Video Decoder）是一个硬件模块，用于在 AMD 显卡上进行视频解码的加速处理。UVD 模块主要用于解码高清视频和其他常见的视频格式，以减轻 CPU 的负担并提供更流畅的视频播放体验。

UVD 模块有以下主要功能：

1.视频解码加速：UVD 模块使用专门的硬件电路和算法来加速视频解码过程。它支持多种视频编码标准，包括
H.264、MPEG-2、VC-1 等，并能够快速解码高分辨率的视频内容。

2.解码负载分担：通过使用 UVD 模块进行视频解码，可以将解码任务从 CPU 转移至显卡，减轻 CPU 的负担。这样可以释放 CPU 资源用于其他计算任务，提高系统整体性能和响应速度。

3.节能和热量控制：UVD 模块在进行视频解码时，能够有效地管理功耗和热量产生。由于视频解码是一项相对固定的任务，UVD 模块可以根据需要动态调整功耗和频率，以提供最佳的性能和能效平衡。

总之，UVD 模块是 AMD 显卡中的一个硬件加速模块，用于视频解码任务。它能够减轻 CPU 负担，提供更流畅的视频播放体验，并具有节能和热量控制的优化功能。

-   GMC

GMC（Graphics Memory Controller）是一个重要的硬件模块，它负责显卡中的内存管理和数据传输。GMC 模块可以有效地管理 GPU 内部的显存，从而提高图形渲染性能和效率。

GMC 模块主要有以下功能：

1.内存分配和释放：GMC 模块可以管理 GPU 内部的显存，自动分配和释放内存，确保图形处理单元（GPU）能够快速访问并使用可用的显存。

2.数据传输：GMC 模块负责数据在 GPU 内部和显存之间的传输。它可以在 GPU 内部的不同模块之间进行高速数据传递，以实现更快的图形渲染和数据处理。

3.内存优化：GMC 模块能够对显存进行优化，以提高数据读写效率，减少延迟和提高响应速度。这些优化包括内存预取、内存压缩、数据压缩和解压等。

4.带宽管理：GMC 模块可以管理 GPU 和显存之间的数据带宽，确保数据能够快速传输，并根据需要动态调整带宽分配，以提供更好的性能和能效平衡。

总之，GMC 模块是 AMD 显卡中的一个核心组件，它负责显存管理和数据传输，并能够提供内存优化和带宽管理等功能，以提高图形渲染性能和效率。

切换用户的时候一定是内核重新获取了 edid 的，内核当中获取 edid 的时间比较长。amdgpu 获取
edid 主要涉及以下几个文件：

x86-kernel/drivers/gpu/drm/amd/amdgpu/amdgpu_atombios.c

x86-kernel/drivers/gpu/drm/amd/amdgpu/amdgpu_i2c.c

x86-kernel/drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm.c

因为 oland 显卡不用 display 的代码，所以要从前两个文件来分析代码的调用。

具体的调用过程我下次讲。

通过 dmesg|grep drm 可以查到：

```nil
[    0.920573] [drm] radeon kernel modesetting enabled.
[    0.965343] [drm] amdgpu kernel modesetting enabled.
[    0.965343] [drm] amdgpu version: 5.11.32.40512
[    0.965344] [drm] OS DRM version: 4.19.0
[    0.967268] [drm] initializing kernel modesetting (OLAND 0x1002:0x6611 0x1462:0x3740 0x87).
[    0.967277] [drm] register mmio base: 0xA0300000
[    0.967278] [drm] register mmio size: 262144
[    0.967283] [drm] add ip block number 0 <si_common>
[    0.967284] [drm] add ip block number 1 <gmc_v6_0>
[    0.967284] [drm] add ip block number 2 <si_ih>
[    0.967284] [drm] add ip block number 3 <gfx_v6_0>
[    0.967285] [drm] add ip block number 4 <si_dma>
[    0.967285] [drm] add ip block number 5 <si_dpm>
[    0.967286] [drm] add ip block number 6 <dce_v6_0>
[    0.967286] [drm] add ip block number 7 <uvd_v3_1>
[    0.975071] [drm] BIOS signature incorrect 5b 7
[    0.975303] [drm] vm size is 64 GB, 2 levels, block size is 10-bit, fragment size is 9-bit
[    0.975335] [drm] Detected VRAM RAM=2048M, BAR=256M
[    0.975335] [drm] RAM width 64bits GDDR5
[    0.975358] [drm] amdgpu: 2048M of VRAM memory ready
[    0.975359] [drm] amdgpu: 7898M of GTT memory ready.
[    0.975361] [drm] GART: num cpu pages 262144, num gpu pages 262144
[    0.975901] [drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
[    0.975902] [drm] Driver supports precise vblank timestamp query.
[    0.976076] [drm] Internal thermal controller with fan control
[    0.976082] [drm] amdgpu: dpm initialized
[    0.976096] [drm] AMDGPU Display Connectors
[    0.976096] [drm] Connector 0:
[    0.976097] [drm]   HDMI-A-1
[    0.976097] [drm]   HPD2
[    0.976098] [drm]   DDC: 0x1950 0x1950 0x1951 0x1951 0x1952 0x1952 0x1953 0x1953
[    0.976098] [drm]   Encoders:
[    0.976098] [drm]     DFP1: INTERNAL_UNIPHY
[    0.976099] [drm] Connector 1:
[    0.976099] [drm]   VGA-1
[    0.976099] [drm]   DDC: 0x194c 0x194c 0x194d 0x194d 0x194e 0x194e 0x194f 0x194f
[    0.976100] [drm]   Encoders:
[    0.976100] [drm]     CRT1: INTERNAL_KLDSCP_DAC1
[    0.976141] [drm] Found UVD firmware Version: 64.0 Family ID: 13
[    0.976809] [drm] PCIE gen 3 link speeds already enabled
[    1.530160] [drm] UVD initialized successfully.
```

oland 显卡用的是 dce_v6_0 这个模块：


### 激活 tty 的流程 {#激活-tty-的流程}

分配新用户的 TTY 涉及到内核中几个关键的函数。以下是其中的一些函数：

1.get_unused_tty_index()：用于获取一个未被使用的 TTY 索引。每个 TTY 都有一个唯一的索引号，内核使用这个索引号来标识不同的 TTY 设备。

2.tty_alloc_driver()：用于为新的 TTY 实例分配一个 TTY 驱动结构体。TTY 驱动结构体保存了与
TTY 设备相关的信息和操作。

3.tty_init_dev()：用于初始化新的 TTY 设备。这个函数会设置 TTY 的状态、配置串口传输参数以及注册 TTY 设备到系统中。

4.tty_open()：用于打开 TTY 设备。当一个用户切换到一个新的 TTY 时，内核会调用这个函数来打开对应的 TTY 设备。

5.vt_do_activate()：用于激活虚拟终端（Virtual Terminal，VT）。在 Linux 中，每个 TTY 都对应一个
VT，用于提供文本终端的功能。这个函数会激活新的 VT，并将其与对应的 TTY 关联起来。

这些函数位于内核的 TTY 子系统中，负责管理和处理 TTY 设备。通过调用这些函数，内核能够分配和管理多个 TTY 设备，并在用户切换到不同的 TTY 时分配适当的资源和处理相应的操作。

ioctl(fd, VT_ACTIVATE, vt)，通过这个调用内核。

对应的是内核的 drivers/tty/vt/vt_ioctl.c 里面的两个处理函数：

vt_ioctl 和 vt_compat_ioctl 两个处理函数：

```c
/*
 * ioctl(fd, VT_ACTIVATE, num) will cause us to switch to vt # num,
 * with num >= 1 (switches to vt 0, our console, are not allowed, just
 * to preserve sanity).
 */
case VT_ACTIVATE:
        if (!perm)
                return -EPERM;
        if (arg == 0 || arg > MAX_NR_CONSOLES)
                ret =  -ENXIO;
        else {
                arg--;
                console_lock();
                ret = vc_allocate(arg);
                console_unlock();
                if (ret)
                        break;
                set_console(arg);
        }
        break;

```

或者是：

```c
        {
        // ......

        case VT_ACTIVATE:
        case VT_WAITACTIVE:
        case VT_RELDISP:
        case VT_DISALLOCATE:
        case VT_RESIZE:
        case VT_RESIZEX:
                goto fallback;

        /*
         * the rest has a compatible data structure behind arg,
         * but we have to convert it to a proper 64 bit pointer.
         */
        default:
                arg = (unsigned long)compat_ptr(arg);
                goto fallback;
        }

        return ret;

fallback:
        return vt_ioctl(tty, cmd, arg);
```

黑屏并不是说这个系统调用导致的，而是切换至新的 xorg，新的 xorg 会从读 edid 导致的黑屏。这个我是花了一段时间才想明白的。上面的代码就不展开了。

通过 perf 找到的调用堆栈如下：

drm_ioctl

drm_ioctl_kernel

drm_mode_getconnector

drm_helper_probe_single_connector_modes

amdgpu_connector_dvi_detect

amdgpu_connector_get_edid

drm_get_edid

drm_do_get_edid

drm_do_probe_ddc_edid

bit_xfer

drivers/gpu/drm/amd/amdgpu/amdgpu_connectors.c

```C
static void amdgpu_connector_get_edid(struct drm_connector *connector)
{
        struct drm_device *dev = connector->dev;
        struct amdgpu_device *adev = dev->dev_private;
        struct amdgpu_connector *amdgpu_connector = to_amdgpu_connector(connector);

        if (amdgpu_connector->edid)
                return;

        /* on hw with routers, select right port */
        if (amdgpu_connector->router.ddc_valid)
                amdgpu_i2c_router_select_ddc_port(amdgpu_connector);

        if ((amdgpu_connector_encoder_get_dp_bridge_encoder_id(connector) !=
             ENCODER_OBJECT_ID_NONE) &&
            amdgpu_connector->ddc_bus->has_aux) {
                amdgpu_connector->edid = drm_get_edid(connector,
                                                      &amdgpu_connector->ddc_bus->aux.ddc);
        } else if ((connector->connector_type == DRM_MODE_CONNECTOR_DisplayPort) ||
                   (connector->connector_type == DRM_MODE_CONNECTOR_eDP)) {
                struct amdgpu_connector_atom_dig *dig = amdgpu_connector->con_priv;

                if ((dig->dp_sink_type == CONNECTOR_OBJECT_ID_DISPLAYPORT ||
                     dig->dp_sink_type == CONNECTOR_OBJECT_ID_eDP) &&
                    amdgpu_connector->ddc_bus->has_aux)
                        amdgpu_connector->edid = drm_get_edid(connector,
                                                              &amdgpu_connector->ddc_bus->aux.ddc);
                else if (amdgpu_connector->ddc_bus)
                        amdgpu_connector->edid = drm_get_edid(connector,
                                                              &amdgpu_connector->ddc_bus->adapter);
        } else if (amdgpu_connector->ddc_bus) {
                amdgpu_connector->edid = drm_get_edid(connector,
                                                      &amdgpu_connector->ddc_bus->adapter);
        }

        if (!amdgpu_connector->edid) {
                /* some laptops provide a hardcoded edid in rom for LCDs */
                if (((connector->connector_type == DRM_MODE_CONNECTOR_LVDS) ||
                     (connector->connector_type == DRM_MODE_CONNECTOR_eDP)))
                        amdgpu_connector->edid = amdgpu_connector_get_hardcoded_edid(adev);
        }
}
```

drivers/gpu/drm/drm_edid.c

```c
/**
 * drm_get_edid - get EDID data, if available
 * @connector: connector we're probing
 * @adapter: I2C adapter to use for DDC
 *
 * Poke the given I2C channel to grab EDID data if possible.  If found,
 * attach it to the connector.
 *
 * Return: Pointer to valid EDID or NULL if we couldn't find any.
 */
struct edid *drm_get_edid(struct drm_connector *connector,
                          struct i2c_adapter *adapter)
{
        struct edid *edid;

        if (connector->force == DRM_FORCE_OFF)
                return NULL;

        if (connector->force == DRM_FORCE_UNSPECIFIED && !drm_probe_ddc(adapter))
                return NULL;

        edid = drm_do_get_edid(connector, drm_do_probe_ddc_edid, adapter);
        if (edid)
                drm_get_displayid(connector, edid);
        return edid;
}
EXPORT_SYMBOL(drm_get_edid);
```

drivers/gpu/drm/drm_edid.c

```c
/**
 * drm_do_get_edid - get EDID data using a custom EDID block read function
 * @connector: connector we're probing
 * @get_edid_block: EDID block read function
 * @data: private data passed to the block read function
 *
 * When the I2C adapter connected to the DDC bus is hidden behind a device that
 * exposes a different interface to read EDID blocks this function can be used
 * to get EDID data using a custom block read function.
 *
 * As in the general case the DDC bus is accessible by the kernel at the I2C
 * level, drivers must make all reasonable efforts to expose it as an I2C
 * adapter and use drm_get_edid() instead of abusing this function.
 *
 * The EDID may be overridden using debugfs override_edid or firmare EDID
 * (drm_load_edid_firmware() and drm.edid_firmware parameter), in this priority
 * order. Having either of them bypasses actual EDID reads.
 *
 * Return: Pointer to valid EDID or NULL if we couldn't find any.
 */
struct edid *drm_do_get_edid(struct drm_connector *connector,
        int (*get_edid_block)(void *data, u8 *buf, unsigned int block,
                              size_t len),
        void *data)
{
        int i, j = 0, valid_extensions = 0;
        u8 *edid, *new;
        struct edid *override;

        override = drm_get_override_edid(connector);
        if (override)
                return override;

        if ((edid = kmalloc(EDID_LENGTH, GFP_KERNEL)) == NULL)
                return NULL;

        /* base block fetch */
        for (i = 0; i < 4; i++) {
                if (get_edid_block(data, edid, 0, EDID_LENGTH))
                        goto out;
                if (drm_edid_block_valid(edid, 0, false,
                                         &connector->edid_corrupt))
                        break;
                if (i == 0 && drm_edid_is_zero(edid, EDID_LENGTH)) {
                        connector->null_edid_counter++;
                        goto carp;
                }
        }
        if (i == 4)
                goto carp;

        /* if there's no extensions, we're done */
        valid_extensions = edid[0x7e];
        if (valid_extensions == 0)
                return (struct edid *)edid;

        new = krealloc(edid, (valid_extensions + 1) * EDID_LENGTH, GFP_KERNEL);
        if (!new)
                goto out;
        edid = new;

        for (j = 1; j <= edid[0x7e]; j++) {
                u8 *block = edid + j * EDID_LENGTH;

                for (i = 0; i < 4; i++) {
                        if (get_edid_block(data, block, j, EDID_LENGTH))
                                goto out;
                        if (drm_edid_block_valid(block, j, false, NULL))
                                break;
                }

                if (i == 4)
                        valid_extensions--;
        }

        if (valid_extensions != edid[0x7e]) {
                u8 *base;

                connector_bad_edid(connector, edid, edid[0x7e] + 1);

                edid[EDID_LENGTH-1] += edid[0x7e] - valid_extensions;
                edid[0x7e] = valid_extensions;

                new = kmalloc_array(valid_extensions + 1, EDID_LENGTH,
                                    GFP_KERNEL);
                if (!new)
                        goto out;

                base = new;
                for (i = 0; i <= edid[0x7e]; i++) {
                        u8 *block = edid + i * EDID_LENGTH;

                        if (!drm_edid_block_valid(block, i, false, NULL))
                                continue;

                        memcpy(base, block, EDID_LENGTH);
                        base += EDID_LENGTH;
                }

                kfree(edid);
                edid = new;
        }

        return (struct edid *)edid;

carp:
        connector_bad_edid(connector, edid, 1);
out:
        kfree(edid);
        return NULL;
}
EXPORT_SYMBOL_GPL(drm_do_get_edid);
```

drivers/gpu/drm/drm_edid.c

```c
/**
 * drm_do_probe_ddc_edid() - get EDID information via I2C
 * @data: I2C device adapter
 * @buf: EDID data buffer to be filled
 * @block: 128 byte EDID block to start fetching from
 * @len: EDID data buffer length to fetch
 *
 * Try to fetch EDID information by calling I2C driver functions.
 *
 * Return: 0 on success or -1 on failure.
 */
static int
drm_do_probe_ddc_edid(void *data, u8 *buf, unsigned int block, size_t len)
{
        struct i2c_adapter *adapter = data;
        unsigned char start = block * EDID_LENGTH;
        unsigned char segment = block >> 1;
        unsigned char xfers = segment ? 3 : 2;
        int ret, retries = 5;

        /*
         * The core I2C driver will automatically retry the transfer if the
         * adapter reports EAGAIN. However, we find that bit-banging transfers
         * are susceptible to errors under a heavily loaded machine and
         * generate spurious NAKs and timeouts. Retrying the transfer
         * of the individual block a few times seems to overcome this.
         */
        do {
                struct i2c_msg msgs[] = {
                        {
                                .addr	= DDC_SEGMENT_ADDR,
                                .flags	= 0,
                                .len	= 1,
                                .buf	= &segment,
                        }, {
                                .addr	= DDC_ADDR,
                                .flags	= 0,
                                .len	= 1,
                                .buf	= &start,
                        }, {
                                .addr	= DDC_ADDR,
                                .flags	= I2C_M_RD,
                                .len	= len,
                                .buf	= buf,
                        }
                };

                /*
                 * Avoid sending the segment addr to not upset non-compliant
                 * DDC monitors.
                 */
                ret = i2c_transfer(adapter, &msgs[3 - xfers], xfers);

                if (ret == -ENXIO) {
                        DRM_DEBUG_KMS("drm: skipping non-existent adapter %s\n",
                                        adapter->name);
                        break;
                }
        } while (ret != xfers && --retries);

        return ret == xfers ? 0 : -1;
}
```

drm/amd/amdgpu/amggpu_i2c.c

```c
static void amdgpu_i2c_post_xfer(struct i2c_adapter *i2c_adap)
{
        struct amdgpu_i2c_chan *i2c = i2c_get_adapdata(i2c_adap);
        struct amdgpu_device *adev = i2c->dev->dev_private;
        struct amdgpu_i2c_bus_rec *rec = &i2c->rec;
        uint32_t temp;

        /* unmask the gpio pins for software use */
        temp = RREG32(rec->mask_clk_reg) & ~rec->mask_clk_mask;
        WREG32(rec->mask_clk_reg, temp);
        temp = RREG32(rec->mask_clk_reg);

        temp = RREG32(rec->mask_data_reg) & ~rec->mask_data_mask;
        WREG32(rec->mask_data_reg, temp);
        temp = RREG32(rec->mask_data_reg);

        mutex_unlock(&i2c->mutex);
}

```

之前高英杰的分享中 VGA 会隔 10s 循环读一下 edid。

gpu/drm/drm_probe_helper.c

```c
static void output_poll_execute(struct work_struct *work)
{

        drm_connector_list_iter_begin(dev, &conn_iter);
        drm_for_each_connector_iter(connector, &conn_iter) {

                repoll = true;

                connector->status = drm_helper_probe_detect(connector, NULL, false);
                if (old_status != connector->status) {
                        const char *old, *new;

                        if (connector->status == connector_status_unknown) {
                                connector->status = old_status;
                                continue;
                        }
                      changed = true;
                }
        }
        drm_connector_list_iter_end(&conn_iter);

        mutex_unlock(&dev->mode_config.mutex);

out:
        if (changed)
                drm_kms_helper_hotplug_event(dev);

        if (repoll)
                schedule_delayed_work(delayed_work, DRM_OUTPUT_POLL_PERIOD);
}

```

我对 edid 不太了解， **现在怀疑是 VGA 的循环读 edid 和切换用户时读 edid 同时进行的情况下在 i2c 的层面有了干扰**


## 用户与系统 xorg 进程对应方法 {#用户与系统-xorg-进程对应方法}

通过 pstree 可以查看系统的服务启动流程。系统的启动流程大体描述一下：

创建多个用户，有的登陆，有的不登陆。

```nil
uos@uos-PC:~$ loginctl list-sessions
SESSION  UID USER    SEAT  TTY
      1 1000 uos     seat0
     10 1004 test4   seat0
     12 1007 test7   seat0
     16 1006 test6   seat0
     19 1008 test8   seat0
     32 1000 uos           pts/2
      4 1002 test2   seat0
      7 1001 test1   seat0
     c7  116 lightdm seat0

9 sessions listed.

uos@uos-PC:~$ loginctl show-session 1
Id=1
User=1000
Name=uos
Timestamp=Tue 2023-10-24 10:44:15 CST
TimestampMonotonic=4856519
VTNr=1
Seat=seat0
Display=:0
Remote=no
Service=lightdm-autologin
Desktop=deepin
Scope=session-1.scope
Leader=1137
Audit=1
Type=x11
Class=user
Active=no
State=online
IdleHint=no
IdleSinceHint=0
IdleSinceHintMonotonic=0
LockedHint=no

uos@uos-PC:~$ ps -ef|grep xorg|grep -v grep
root       987   839  0 10月24 tty1   00:00:17 /usr/lib/xorg/Xorg -background none :0
root      3108   839  0 10月24 tty2   00:00:10 /usr/lib/xorg/Xorg -background none :1
root      5265   839  0 10月24 tty3   00:00:04 /usr/lib/xorg/Xorg -background none :2
root      6921   839  0 10月24 tty4   00:00:05 /usr/lib/xorg/Xorg -background none :3
root      8327   839  0 10月24 tty5   00:00:04 /usr/lib/xorg/Xorg -background none :4
root      9802   839  0 10月24 tty6   00:00:07 /usr/lib/xorg/Xorg -background none :5
root     25787   839  0 10月24 tty7   00:00:05 /usr/lib/xorg/Xorg -background none :6
root     27291   839  0 10月24 tty8   00:00:05 /usr/lib/xorg/Xorg -background none :7
```

上面的“:0” 是 X Display Server 的名字。


## 使用 perf 来调试 {#使用-perf-来调试}

关于 perf 的使用可以看另一篇博客： <https://guolongji.xyz/post/use-perf-and-flame-graph/>

目的是找两个己经登陆的用户的两个不同的 Xorg 进程，对这两个不同的进程用 perf 工具进行统计。这两个进程都是在运行当中的，如果 perf 能够同时对两个 xorg 的进程进行分析，那么就可以打到耗时的地方。

```nil
uos@uos-PC:~$ ps -ef|grep kwin|grep -v grep
uos       1331  1172  0 10月24 ?      00:00:00 /bin/sh /usr/bin/kwin_no_scale
uos       1387  1331  0 10月24 ?      00:00:18 kwin_x11 -platform dde-kwin-xcb:appFilePath=/usr/bin/kwin_no_scale
test2     4171  3977  0 10月24 ?      00:00:00 /bin/sh /usr/bin/kwin_no_scale
test2     4261  4171  0 10月24 ?      00:00:09 kwin_x11 -platform dde-kwin-xcb:appFilePath=/usr/bin/kwin_no_scale
test1     5701  5541  0 10月24 ?      00:00:00 /bin/sh /usr/bin/kwin_no_scale
test1     5809  5701  0 10月24 ?      00:00:01 kwin_x11 -platform dde-kwin-xcb:appFilePath=/usr/bin/kwin_no_scale
test4     7353  7196  0 10月24 ?      00:00:00 /bin/sh /usr/bin/kwin_no_scale
test4     7463  7353  0 10月24 ?      00:00:01 kwin_x11 -platform dde-kwin-xcb:appFilePath=/usr/bin/kwin_no_scale
test7     8726  8572  0 10月24 ?      00:00:00 /bin/sh /usr/bin/kwin_no_scale
test7     8822  8726  0 10月24 ?      00:00:01 kwin_x11 -platform dde-kwin-xcb:appFilePath=/usr/bin/kwin_no_scale
test6    24815 24625  0 10月24 ?      00:00:00 /bin/sh /usr/bin/kwin_no_scale
test6    24891 24815  0 10月24 ?      00:00:00 kwin_x11 -platform dde-kwin-xcb:appFilePath=/usr/bin/kwin_no_scale
test8    26225 26070  0 10月24 ?      00:00:00 /bin/sh /usr/bin/kwin_no_scale
test8    26316 26225  0 10月24 ?      00:00:01 kwin_x11 -platform dde-kwin-xcb:appFilePath=/usr/bin/kwin_no_scale

uos@uos-PC:~$ cat /proc/1387/environ |grep -a --color DISPLAY
```

观察两个变量分别是 :0 和 :6

那么对应的两个进程号就是 987 和 25787。

用 perf 来监视的话，分别在两个目录下运行：

perf record -p 987 -g  -- sleep 30

perf record -p 25787 -g  -- sleep 30

测试部步是先两个 ssh 在两个不同的目录运行两个进程的采样任务。手动在被测试的机器上切换 uos 和 test8 两个用户，现象是经过 6 到 7 次，没有黑屏，最后一次黑屏。经过 10s 之后采样结束。

生成的图如下：

{{< figure src="/ox-hugo/img_20231026_172216.jpg" >}}

xorg 的时钟占比为 94%，而 drm_get_edid 的时钟占比高达 32%。

显然被测试的 oland 显卡 drm_do_probe_ddc_edid 这个过程是有时候比较慢的。一直切换会由“经常不黑屏”的状态变为经常黑屏的状态。所以猜测是存在什么循环。


## 为什么 xorg 的数量比登陆的用户数多一个？ {#为什么-xorg-的数量比登陆的用户数多一个}

因为 lightdm-deepin-greeter 也会创建一个 xorg 用于过渡。

```nil
uos@uos-PC:~$ ps -ef|grep greeter|grep -v grep
lightdm  27361 27344  0 10月24 ?      00:00:00 /bin/bash /usr/bin/deepin-greeter
lightdm  27376 27361  0 10月24 ?      00:00:00 /bin/bash /usr/share/dde-session-shell/greeters.d/x/lightdm-deepin-greeter
lightdm  27377 27376  0 10月24 ?      00:00:02 /usr/lib/deepin-daemon/greeter-display-daemon
lightdm  27379 27376  0 10月24 ?      00:00:00 /bin/bash /usr/share/dde-session-shell/greeters.d/launch-binary
lightdm  27407 27379  0 10月24 ?      00:00:33 /usr/bin/lightdm-deepin-greeter
```


## 能不能写一个切换用户的脚本呢？ {#能不能写一个切换用户的脚本呢}

```bash
while true; do qdbus --system org.freedesktop.login1 /org/freedesktop/login1/seat/seat0 \
org.freedesktop.login1.Seat.SwitchToNext; sleep 2; qdbus --system org.freedesktop.login1 \
/org/freedesktop/login1/seat/seat0 org.freedesktop.login1.Seat.SwitchToPrevious; sleep 2; done
```

用 dbus 信号去切 tty 是没有问题的。与窗管的同事沟通了解到。dde-dock 可能是会刷新 edid 的状态，而用上面的命令不会刷新 edid 的状态，那么也就不会出现黑屏的问题了。那现在这个问题的的原因就基本上清晰了。

之前廖元用的脚本是这个：

```bash
#!/bin/bash
n=0
while (($n<100))
do
        sh -c "gdbus call --system --dest org.freedesktop.login1 --object-path /org/freedesktop/login1 \
--method org.freedesktop.login1.Manager.ActivateSession 2"
        echo $n
        n=$((n+1))
        sleep 2
        sh -c "gdbus call --system --dest org.freedesktop.login1 --object-path /org/freedesktop/login1 \
--method org.freedesktop.login1.Manager.ActivateSession c2"
        sleep 2
done
```


## 其它的相关 bug {#其它的相关-bug}

机缘巧合之下，在 4.19 内核里发现了 radeon 驱动一个很神奇的问题，插拔 hdmi 线时候，先拔出一半等 10s 左右再全部拔出。这时候，在 sys 下读到的 hdmi 连接状态还是 connected。这个感觉还是很神奇的。切到 amdgpu 之后，也有这个问题。

<https://blog.51cto.com/u_15155099/2767298>

HDMI 拔出正常逻辑应该是：HPD 探测到电压变化触发中断，接下来 DDC 读取显示器 EDID 返回失败，最终到 dvi_detect 函数中，通过 DDC 返回的失败，设置显示器连接状态为 disconnected。

在这个问题中，HDMI 拔出，HPD 探测到电压变化中断触发，DDC 读取显示器 EDID 返回成功，detect 函数设置显示器连接状态是 connected。那真正出错的位置是 DDC 不应该读取到 EDID。

oland 显卡读取 edid 的逻辑有大问题。


## 什么是 EDID？ {#什么是-edid}

edid 核心的内容都在这里了：

<https://www.graniteriverlabs.com.cn/technical-blog/edid-overview/>

<https://en.wikipedia.org/wiki/Extended_Display_Identification_Data>

<https://www.wpgdadatong.com.cn/blog/detail/72670>

{{< figure src="/ox-hugo/img_20231027_145247.jpg" >}}

而目前我们所采用的是 EDID1.3 版本，EDID1.0、EDID1.1、EDID1.2 均已在 2001 年 1 月 1 日停止使用。

```nil
cat /sys/class/drm/card0-VGA-1/edid |hexdump -C
# 或者：cat /sys/class/drm/card0-HDMI-A-1/edid | hexdump -C
```

view sonic 的显示器举例：

-   下面是 VGA 的 edid：

<!--listend-->

```nil
00000000  00 ff ff ff ff ff ff 00  5a 63 22 3a 01 01 01 01  |........Zc":....|
00000010  29 1e 01 03 08 35 1d 78  2e e0 f5 a5 55 52 a0 27  |)....5.x....UR.'|
00000020  0c 50 54 bf ef 80 b3 00  a9 40 a9 c0 95 00 90 40  |.PT......@.....@|
00000030  81 80 81 40 81 c0 02 3a  80 18 71 38 2d 40 58 2c  |...@...:..q8-@X,|
00000040  45 00 0f 29 21 00 00 1e  00 00 00 ff 00 57 36 38  |E..)!........W68|
00000050  32 30 34 31 32 30 30 39  33 0a 00 00 00 fd 00 32  |204120093......2|
00000060  4b 18 52 11 00 0a 20 20  20 20 20 20 00 00 00 fc  |K.R...      ....|
00000070  00 56 41 32 34 33 31 2d  48 2d 32 0a 20 20 00 74  |.VA2431-H-2.  .t|
00000080
```

-   下面是 HDMI 的 edid：

<!--listend-->

```nil
00000000  00 ff ff ff ff ff ff 00  5a 63 3a c6 01 01 01 01  |........Zc:.....|
00000010  1e 1e 01 03 80 35 1d 78  2e b4 85 a3 56 50 a0 26  |.....5.x....VP.&|
00000020  0f 50 54 bf ef 80 b3 00  a9 40 a9 c0 95 00 90 40  |.PT......@.....@|
00000030  81 80 81 40 81 c0 02 3a  80 18 71 38 2d 40 58 2c  |...@...:..q8-@X,|
00000040  45 00 0f 28 21 00 00 1e  00 00 00 fd 00 32 4b 18  |E..(!........2K.|
00000050  52 11 00 0a 20 20 20 20  20 20 00 00 00 fc 00 56  |R...      .....V|
00000060  41 32 34 36 32 2d 48 0a  20 20 20 20 00 00 00 ff  |A2462-H.    ....|
00000070  00 57 42 31 32 30 33 30  30 35 33 34 34 0a 00 17  |.WB1203005344...|
00000080
```

重点看：

1.12h 和 13h，分别是 01 和 03。这就表明是 edid 1.3 版本，且不包含括展块。

2.23h 至 25h 为 Established timing，早期的分辨率信息。上面的是 bf ef 80，即：

1011 1111
1110 1111
1000 0000

{{< figure src="/ox-hugo/img_20231027_152110.jpg" >}}

通过 xrandr 看能对应上显示器的信息：

```nil
uos@guolongji:~/Desktop$ xrandr
Screen 0: minimum 320 x 200, current 1920 x 1080, maximum 16384 x 16384
HDMI-0 disconnected (normal left inverted right x axis y axis)
DVI-0 disconnected (normal left inverted right x axis y axis)
VGA-0 connected primary 1920x1080+0+0 (normal left inverted right x axis y axis) 527mm x 297mm
   1920x1080     60.00*+
   1600x1200     60.00     1680x1050     59.95
   1400x1050     59.98     1600x900      60.00
   1280x1024     75.02    60.02     1440x900      59.89
   1280x960      60.00     1152x864      75.00
   1280x720      60.00     1024x768      75.03    70.07    60.00
   832x624       74.55
   800x600       72.19    75.00    60.32    56.25
   640x480       75.00    72.81    66.67    59.94
   720x400       70.08
```

3.从 26h 到 35h，16 个 bit，每两个 bit 表示一个标准分辨率，即：b3 00 a9 40 a9 c0 95 00 90 40 81 80 81 40 81 c0

10110011 00000000

10100110 01000000

10100110 11010000

01100101 00000000

01100000 01000000

10000001 10000000

10000001 01000000

10000001 11010000

拿 10110011 00000000 来举例：10110011 即 b3， 179，加上 31 即 210，乘以 8，即 1680，这个是 1680 的那个分辨率的信息。

4.那么 1920 那个分辨率的信息是怎么拿到的呢？

02 3a  80 18 71 38 2d 40 58 2c 45 00 0f 28 21 00 00 1e

从 established timing 到 standard timing 到 Detailed timing descriptor，分辨率的解析就很麻烦。

这个的解析比较麻烦，可以参考：

<https://winddoing.github.io/post/47714.html>

有一个站可以解析 edid： <http://www.edidreader.com/>

开源的解析工具很多，<https://github.com/dgallegos/edidreader> ，供参考。

-   是不是 e-edid

edid 可能是 128 个 bit，也可能是 256 个 bit。分为 block0 和 block1 两部分。block1 叫 Extension block。

block1 可以没有。Block0 已对显示器的功能进行基本的描述，像是产品信息和支持的分辨率等等，但如果显示器要额外支持一些 HDMI 进阶功能：如色深、音讯格式、3D，此时就需要使用 Extension block 来描述。Extension block 的格式总共有下列几种，但在 HDMI 规范中必须至少使用一个 CEA-EXT。

倒数第二个字节是 Extension Block(s)  : 0，就不是 e-edid，非 0 就是。


## FQA {#fqa}

-   为什么系统下和芯片中都需要包含固件代码？（显卡 vbios 和系统下的 bin）

在很多硬件设备中，特别是芯片、固件和驱动程序之间的关系非常紧密。固件代码通常被设计用于与硬件交互，并为操作系统或其他软件提供硬件相关的功能和操作。因此，在某些情况下，固件代码需要同时存在于硬件设备中和操作系统文件系统中。

具体来说，设备固件通常存储在硬件设备的非易失性存储器中，例如闪存、EEPROM 或 ROM 芯片中。这些固件代码包含了设备的基本操作和配置信息，以及一些初始化程序和驱动程序。

然而，在某些情况下，固件代码需要在操作系统中使用。例如，在 Linux 系统中，设备驱动程序通常需要使用固件代码才能正确地初始化和配置设备，从而使设备在操作系统中正常工作。因此，固件代码必须以某种方式从设备中传输到操作系统中。

为此，Linux 等操作系统提供了一种机制，允许将固件代码复制到操作系统文件系统中的某个位置，以便设备驱动程序在需要时可以加载并使用它。这就是为什么在系统中也需要包含固件代码。操作系统中的这些固件文件通常放置在/lib/firmware 目录中。

总之，固件代码需要同时存在于硬件设备中和操作系统文件系统中，因为它们在共同协作以使设备得以正常工作。


## 分析有误，继续 {#分析有误-继续}

不是问题，之前分析有误，加一些打印就能发现，读取 edid 的时间根本就不长。要分析什么时候会调用和产生黑屏。这个黑屏遮罩的方法的调用者都有谁，这个问窗管应该就可以了。不行再问题闫博文。

找到这些项目，申请代码树权限。后续，分析什么情况下调用黑屏遮罩的方法。


## 继续 {#继续}

lightdm-gtk-greeter（即是包名也是程序名）；dde-session-shell 的 dde-lock。看不懂这些应用是怎么放到一起组合起来的。系统是怎么组合起来的，这个是个相当复杂的问题。

xset dpms force off，这个命令可以设置黑屏。

```bash
cat /sys/class/drm/card*/dpms
sudo nano /etc/default/grub
GRUB_CMDLINE_LINUX="quiet splash drm.debug=0x04"
sudo update-grub
```

在 Linux 内核中，drm.debug 参数用于控制 DRM（Direct Rendering Manager）子系统的调试输出。这个参数可以接受不同数值，每个数值代表一种不同的调试级别，通常使用十六进制表示。

常见的 drm.debug 参数取值包括：

0x01：启用基本的 DRM 调试信息

0x04：启用详细的 DRM 调试信息

0x10：启用扩展的 DRM 调试信息

0x40：启用更多的 DRM 调试信息

0x100：启用所有可用的 DRM 调试信息

你可以根据需要将这些数值进行组合，以启用多个级别的调试信息。例如，如果你想同时启用基本的调试信息和详细的调试信息，可以将数值相加，如 0x01 + 0x04 = 0x05。

在实际使用中，根据需求选择合适的调试级别，以便获取所需的调试信息，同时避免产生过多无关的日志输出。

现在要做的事就是打开 drm 的调整试信息，然后做测试，这个还是很简单的。

打开了调式之后，发现 amdgpu_atombios_encoder_dpms 这个函数调用的次数是有区别的，没问题的时候调用一次，而有问题的时个会调用多次。

打印的日志是：

[ 1268.188110] [drm:amdgpu_atombios_encoder_dpms [amdgpu]] encoder dpms 30 to mode 3, devices 00000008,
active_devices 00000008

为什么打印一次的时候就闪一下屏，而打印多次的时候就会有黑屏的现象？是什么导致了这个日志有时候会打印多次呢？

现在要分析一下什么情况下会调用 amdgpu_atombios_encoder_dpms ，或者直接加上一个 WARN_ON(1) 来分析这个问题。

调用的地方并不多，如下：

```nil
drivers/gpu/drm/amd/amdgpu/dce_v6_0.c:3089:	amdgpu_atombios_encoder_dpms(encoder, DRM_MODE_DPMS_OFF);
drivers/gpu/drm/amd/amdgpu/dce_v6_0.c:3147:	amdgpu_atombios_encoder_dpms(encoder, DRM_MODE_DPMS_ON);
drivers/gpu/drm/amd/amdgpu/dce_v6_0.c:3158:	amdgpu_atombios_encoder_dpms(encoder, DRM_MODE_DPMS_OFF);
drivers/gpu/drm/amd/amdgpu/dce_v6_0.c:3217:	.dpms = amdgpu_atombios_encoder_dpms,
drivers/gpu/drm/amd/amdgpu/dce_v6_0.c:3227:	.dpms = amdgpu_atombios_encoder_dpms,
```

下面这个函数是设置 mode set 的：

```c
static void
dce_v6_0_encoder_mode_set(struct drm_encoder *encoder,
                          struct drm_display_mode *mode,
                          struct drm_display_mode *adjusted_mode)
{

        struct amdgpu_encoder *amdgpu_encoder = to_amdgpu_encoder(encoder);
        int em = amdgpu_atombios_encoder_get_encoder_mode(encoder);

        amdgpu_encoder->pixel_clock = adjusted_mode->clock;

        /* need to call this here rather than in prepare() since we need some crtc info */
        amdgpu_atombios_encoder_dpms(encoder, DRM_MODE_DPMS_OFF);

        /* set scaler clears this on some chips */
        dce_v6_0_set_interleave(encoder->crtc, mode);

        if (em == ATOM_ENCODER_MODE_HDMI || ENCODER_MODE_IS_DP(em)) {
                dce_v6_0_afmt_enable(encoder, true);
                dce_v6_0_afmt_setmode(encoder, adjusted_mode);
        }
}
```

下面这个函数是提交的，难道设置完成之后需要再提交一下吗？

```c
static void dce_v6_0_encoder_commit(struct drm_encoder *encoder)
{

        struct drm_device *dev = encoder->dev;
        struct amdgpu_device *adev = dev->dev_private;

        /* need to call this here as we need the crtc set up */
        amdgpu_atombios_encoder_dpms(encoder, DRM_MODE_DPMS_ON);
        amdgpu_atombios_scratch_regs_lock(adev, false);
}
```

encoder disable ，这个 encoder 是什么东西？

```c
static void dce_v6_0_encoder_disable(struct drm_encoder *encoder)
{

        struct amdgpu_encoder *amdgpu_encoder = to_amdgpu_encoder(encoder);
        struct amdgpu_encoder_atom_dig *dig;
        int em = amdgpu_atombios_encoder_get_encoder_mode(encoder);

        amdgpu_atombios_encoder_dpms(encoder, DRM_MODE_DPMS_OFF);

        if (amdgpu_atombios_encoder_is_digital(encoder)) {
                if (em == ATOM_ENCODER_MODE_HDMI || ENCODER_MODE_IS_DP(em))
                        dce_v6_0_afmt_enable(encoder, false);
                dig = amdgpu_encoder->enc_priv;
                dig->dig_encoder = -1;
        }
        amdgpu_encoder->active_device = 0;
}
```

dig_helper 这个又是什么东西？

```c
static const struct drm_encoder_helper_funcs dce_v6_0_dig_helper_funcs = {
        .dpms = amdgpu_atombios_encoder_dpms,
        .mode_fixup = amdgpu_atombios_encoder_mode_fixup,
        .prepare = dce_v6_0_encoder_prepare,
        .mode_set = dce_v6_0_encoder_mode_set,
        .commit = dce_v6_0_encoder_commit,
        .disable = dce_v6_0_encoder_disable,
        .detect = amdgpu_atombios_encoder_dig_detect,
};
```

dac_helper ，这个又是什么东西？

```c
static const struct drm_encoder_helper_funcs dce_v6_0_dac_helper_funcs = {
        .dpms = amdgpu_atombios_encoder_dpms,
        .mode_fixup = amdgpu_atombios_encoder_mode_fixup,
        .prepare = dce_v6_0_encoder_prepare,
        .mode_set = dce_v6_0_encoder_mode_set,
        .commit = dce_v6_0_encoder_commit,
        .detect = amdgpu_atombios_encoder_dac_detect,
};
```

-   drm_encoder

drm_encoder 在 Linux 系统中用于表示显示控制器的硬件模块，负责管理和控制显示信号的生成和传输，以确保图形数据能够正确地显示在相应的显示设备上。

在这个 amdgpu_atombios_encoder_dpms 的函数里面加上 WARN_ON(1) 查看不同情况下的调用者是否有什么不同。

使用 WARN_ON(1) 没有显示出来新的调用信息，难道这块不是内核的内容就无法打开吗？记的不对，那换成 dump_stack();
这个重新编译一个内核试试。

上层用的是这个函数设置的：

extern Status DPMSForceLevel(Display \*, CARD16);

是 libxext 这个包。下载包，看这个函数的实现：

在 src/DPMS.c 这个文件下：

```c
Status
DPMSForceLevel(Display *dpy, CARD16 level)
{
    XExtDisplayInfo *info = find_display (dpy);
    register xDPMSForceLevelReq *req;

    DPMSCheckExtension (dpy, info, 0);

    if ((level != DPMSModeOn) &&
        (level != DPMSModeStandby) &&
        (level != DPMSModeSuspend) &&
        (level != DPMSModeOff))
        return BadValue;

    LockDisplay(dpy);
    GetReq(DPMSForceLevel, req);
    req->reqType = info->codes->major_opcode;
    req->dpmsReqType = X_DPMSForceLevel;
    req->level = level;

    UnlockDisplay(dpy);
    SyncHandle();
    return 1;
}
```

这里面的 SyncHandle 在 X11/Xlibint.h 这个头文件当中：

```c
#define SyncHandle() \
        if (dpy->synchandler) (*dpy->synchandler)(dpy)

```

有 SyncHandle 那么是不是还有 AsyncHandle 呢？确实是有的：

有两个，一个是 \_XDeqAsyncHandler ，另外一个是 DeqAsyncHandler 这两个一看就是出队列的。那谁是入队列的呢？

我可以把 X11 的代码放到一个地方，用 tag 来查一下。所有的相关的代码包含哪些？

在 X11 协议中，"dpmsReqType" 是用于控制显示器电源管理的请求类型。根据协议文档，有以下几种 dpmsReqType 的取值：

DPMSGetVersion：获取 DPMS 扩展的版本信息。

DPMSCapable：检查服务器是否支持 DPMS 扩展。

DPMSGetTimeouts：获取当前的 DPMS 超时设置（激活、关闭和关闭后重新打开的超时时间）。

DPMSSetTimeouts：设置 DPMS 的超时时间。

DPMSEnable：启用 DPMS 功能。

DPMSDisable：禁用 DPMS 功能。

DPMSForceLevel：强制设置显示器的电源状态。

DPMSInfo：获取关于显示器电源状态的信息。

这些请求类型用于控制显示器的电源管理行为，例如启用或禁用 DPMS 功能、查询支持的功能和状态、设置超时时间以及强制改变显示器的电源状态等。

需要注意的是，具体实现可能会有所不同，不同的 X11 服务器可能支持不同的请求类型或者有其他自定义的扩展类型。因此，对于特定的 X11 服务器或库，最好参考其相关文档以了解支持的 dpmsReqType 类型。

设置显示器黑屏除了 DPMSForceLevel 外还有别的方法吗？有的。

除了使用 DPMS 扩展的 DPMSForceLevel 命令外，还可以通过其他方式控制显示器黑屏。下面列出几种可能的方法。

调用 XResetScreenSaver 函数：这个函数可以重置屏幕保护程序的计时器，防止显示器进入屏幕保护模式。如果需要让显示器立即停止显示内容，可以反复调用该函数并传入一个较小的时间值，例如 1 秒。

使用 X11 的 RandR 扩展：RandR（Resize and Rotate）是 X11 的一个扩展，它可以让客户端程序在运行时改变显示器的分辨率和方向。RandR 扩展中包含了一些控制显示器电源管理的命令，例如 RROutputSetDPMSMode
和 RROutputSetProperty。通过调用这些命令，可以实现关闭显示器或者使其进入省电模式。

调用显卡驱动程序提供的 API：显卡驱动程序通常会提供一些 API，用于控制显示器的电源管理行为。例如，NVIDIA
 的 Linux 显卡驱动程序提供了 nvidia-settings 命令行工具，可以用于配置和控制 NVIDIA 显卡的各种设置，包括显示器电源管理。

需要注意的是，这些方法的实现可能会因操作系统、显卡驱动程序和硬件配置等因素而异。在实际开发中，应该根据具体的需求选择最合适的方法，并参考相关文档以确保其在目标平台上的可用性。

看现象有可能是调用了 XResetScreenSaver 这个函数。但是有的时候不调用，有的时候调用。

x_all 下搜 XSetScreenSaver 这个函数：

```c
/** Initialize DPMS support.  We save the current settings and turn off
 * DPMS.  The settings are restored in #dmxDPMSTerm. */
int
dmxDPMSInit(DMXScreenInfo * dmxScreen)
{
    int interval, preferBlanking, allowExposures;

    /* Turn off DPMS */
    if (!_dmxDPMSInit(dmxScreen))
        return FALSE;

    if (!dmxScreen->beDisplay)
        return FALSE;

    /* Turn off screen saver */
    XGetScreenSaver(dmxScreen->beDisplay, &dmxScreen->savedTimeout, &interval,
                    &preferBlanking, &allowExposures);
    XSetScreenSaver(dmxScreen->beDisplay, 0, interval,
                    preferBlanking, allowExposures);
    XResetScreenSaver(dmxScreen->beDisplay);
    dmxSync(dmxScreen, FALSE);
    return TRUE;
}
```

Distributed Multihead X（dmx）服务器是 X Window System 的一个组件，用于将多个物理显示器组合成一个虚拟的大显示器。它允许用户在多个计算机上连接多个显示器，并将它们视为一个逻辑上连续的显示区域。

我怀疑是这里走到了不同的分支了，所以有时候黑屏，有时候不黑屏。那可以加个日志看看，但是 xorg 我不知道怎么编译和加日志，先尝试一下看看。

xserver-xorg-core 这个是有 debug 包的，那我能不能安装了 debug 包用 gdb 来调试一下看看是进入了哪个分支呢？理论上应该是可以的。那能不能用 bpf-trace 呢？这个和内核有关，好像没什么关系。

方向不对，这个 xdmx 这个是个 x11 的插件，并没有安装，方向是错的。

在从 startdde 看一下：

{{< figure src="/ox-hugo/img_20231122_175228.jpg" >}}

dde_wldpms 这个东西不是在 X11 下使用的，这个也排除了。

就省下一个函数要看了：

```go
func setDPMSMode(on bool) {
        var err error
        if _useWayland {
                if !on {
                        _, err = exec.Command("dde_wldpms", "-s", "Off").Output()
                } else {
                        _, err = exec.Command("dde_wldpms", "-s", "On").Output()
                }
        } else {
                var mode = uint16(dpms.DPMSModeOn)
                if !on {
                        mode = uint16(dpms.DPMSModeOff)
                }
                err = dpms.ForceLevelChecked(_xConn, mode).Check(_xConn)
        }

        if err != nil {
                logger.Warning("Failed to set dpms mode:", on, err)
        }
}
```

ForceLevelChecked 这个函数。这个函数调用了多次，可以在这个地方加一下打印？

{{< figure src="/ox-hugo/img_20231122_175958.jpg" >}}

看了 syslog 的日志中有 startdde 的，但是感觉又不像是上层导致的内核出现多次的打印，再继续分析 drm
框架的调用过程吧。

```c
#ifdef CONFIG_LOCKDEP
static struct lockdep_map connector_list_iter_dep_map = {
        .name = "drm_connector_list_iter"
};
#endif

// ......

/**
 * drm_connector_list_iter_begin - initialize a connector_list iterator
 * @dev: DRM device
 * @iter: connector_list iterator
 *
 * Sets @iter up to walk the &drm_mode_config.connector_list of @dev. @iter
 * must always be cleaned up again by calling drm_connector_list_iter_end().
 * Iteration itself happens using drm_connector_list_iter_next() or
 * drm_for_each_connector_iter().
 */
void drm_connector_list_iter_begin(struct drm_device *dev,
                                   struct drm_connector_list_iter *iter)
{
        iter->dev = dev;
        iter->conn = NULL;
        lock_acquire_shared_recursive(&connector_list_iter_dep_map, 0, 1, NULL, _RET_IP_);
}
EXPORT_SYMBOL(drm_connector_list_iter_begin);
```

```c
/**
 * drm_crtc_helper_set_config - set a new config from userspace
 * @set: mode set configuration
 * @ctx: lock acquire context, not used here
 *
 * The drm_crtc_helper_set_config() helper function implements the of
 * &drm_crtc_funcs.set_config callback for drivers using the legacy CRTC
 * helpers.
 *
 * It first tries to locate the best encoder for each connector by calling the
 * connector @drm_connector_helper_funcs.best_encoder helper operation.
 *
 * After locating the appropriate encoders, the helper function will call the
 * mode_fixup encoder and CRTC helper operations to adjust the requested mode,
 * or reject it completely in which case an error will be returned to the
 * application. If the new configuration after mode adjustment is identical to
 * the current configuration the helper function will return without performing
 * any other operation.
 *
 * If the adjusted mode is identical to the current mode but changes to the
 * frame buffer need to be applied, the drm_crtc_helper_set_config() function
 * will call the CRTC &drm_crtc_helper_funcs.mode_set_base helper operation.
 *
 * If the adjusted mode differs from the current mode, or if the
 * ->mode_set_base() helper operation is not provided, the helper function
 * performs a full mode set sequence by calling the ->prepare(), ->mode_set()
 * and ->commit() CRTC and encoder helper operations, in that order.
 * Alternatively it can also use the dpms and disable helper operations. For
 * details see &struct drm_crtc_helper_funcs and struct
 * &drm_encoder_helper_funcs.
 *
 * This function is deprecated.  New drivers must implement atomic modeset
 * support, for which this function is unsuitable. Instead drivers should use
 * drm_atomic_helper_set_config().
 *
 * Returns:
 * Returns 0 on success, negative errno numbers on failure.
 */
int drm_crtc_helper_set_config(struct drm_mode_set *set,
                               struct drm_modeset_acquire_ctx *ctx)
{
        struct drm_device *dev;
        struct drm_crtc **save_encoder_crtcs, *new_crtc;
        struct drm_encoder **save_connector_encoders, *new_encoder, *encoder;
        bool mode_changed = false; /* if true do a full mode set */
        bool fb_changed = false; /* if true and !mode_changed just do a flip */
        struct drm_connector *connector;
        struct drm_connector_list_iter conn_iter;
        int count = 0, ro, fail = 0;
        const struct drm_crtc_helper_funcs *crtc_funcs;
        struct drm_mode_set save_set;
        int ret;
        int i;

        DRM_DEBUG_KMS("\n");

        BUG_ON(!set);
        BUG_ON(!set->crtc);
        BUG_ON(!set->crtc->helper_private);

        /* Enforce sane interface api - has been abused by the fb helper. */
        BUG_ON(!set->mode && set->fb);
        BUG_ON(set->fb && set->num_connectors == 0);

        crtc_funcs = set->crtc->helper_private;

        if (!set->mode)
                set->fb = NULL;

        if (set->fb) {
                DRM_DEBUG_KMS("[CRTC:%d:%s] [FB:%d] #connectors=%d (x y) (%i %i)\n",
                              set->crtc->base.id, set->crtc->name,
                              set->fb->base.id,
                              (int)set->num_connectors, set->x, set->y);
        } else {
                DRM_DEBUG_KMS("[CRTC:%d:%s] [NOFB]\n",
                              set->crtc->base.id, set->crtc->name);
                drm_crtc_helper_disable(set->crtc);
                return 0;
        }

        dev = set->crtc->dev;

        drm_warn_on_modeset_not_all_locked(dev);

        /*
         * Allocate space for the backup of all (non-pointer) encoder and
         * connector data.
         */
        save_encoder_crtcs = kcalloc(dev->mode_config.num_encoder,
                                sizeof(struct drm_crtc *), GFP_KERNEL);
        if (!save_encoder_crtcs)
                return -ENOMEM;

        save_connector_encoders = kcalloc(dev->mode_config.num_connector,
                                sizeof(struct drm_encoder *), GFP_KERNEL);
        if (!save_connector_encoders) {
                kfree(save_encoder_crtcs);
                return -ENOMEM;
        }

        /*
         * Copy data. Note that driver private data is not affected.
         * Should anything bad happen only the expected state is
         * restored, not the drivers personal bookkeeping.
         */
        count = 0;
        drm_for_each_encoder(encoder, dev) {
                save_encoder_crtcs[count++] = encoder->crtc;
        }

        count = 0;
        drm_connector_list_iter_begin(dev, &conn_iter);
        drm_for_each_connector_iter(connector, &conn_iter)
                save_connector_encoders[count++] = connector->encoder;
        drm_connector_list_iter_end(&conn_iter);

        save_set.crtc = set->crtc;
        save_set.mode = &set->crtc->mode;
        save_set.x = set->crtc->x;
        save_set.y = set->crtc->y;
        save_set.fb = set->crtc->primary->fb;

        /* We should be able to check here if the fb has the same properties
         * and then just flip_or_move it */
        if (set->crtc->primary->fb != set->fb) {
                /* If we have no fb then treat it as a full mode set */
                if (set->crtc->primary->fb == NULL) {
                        DRM_DEBUG_KMS("crtc has no fb, full mode set\n");
                        mode_changed = true;
                } else if (set->fb->format != set->crtc->primary->fb->format) {
                        mode_changed = true;
                } else
                        fb_changed = true;
        }

        if (set->x != set->crtc->x || set->y != set->crtc->y)
                fb_changed = true;

        if (!drm_mode_equal(set->mode, &set->crtc->mode)) {
                DRM_DEBUG_KMS("modes are different, full mode set\n");
                drm_mode_debug_printmodeline(&set->crtc->mode);
                drm_mode_debug_printmodeline(set->mode);
                mode_changed = true;
        }

        /* take a reference on all unbound connectors in set, reuse the
         * already taken reference for bound connectors
         */
        for (ro = 0; ro < set->num_connectors; ro++) {
                if (set->connectors[ro]->encoder)
                        continue;
                drm_connector_get(set->connectors[ro]);
        }

        /* a) traverse passed in connector list and get encoders for them */
        count = 0;
        drm_connector_list_iter_begin(dev, &conn_iter);
        drm_for_each_connector_iter(connector, &conn_iter) {
                const struct drm_connector_helper_funcs *connector_funcs =
                        connector->helper_private;
                new_encoder = connector->encoder;
                for (ro = 0; ro < set->num_connectors; ro++) {
                        if (set->connectors[ro] == connector) {
                                new_encoder = connector_funcs->best_encoder(connector);
                                /* if we can't get an encoder for a connector
                                   we are setting now - then fail */
                                if (new_encoder == NULL)
                                        /* don't break so fail path works correct */
                                        fail = 1;

                                if (connector->dpms != DRM_MODE_DPMS_ON) {
                                        DRM_DEBUG_KMS("connector dpms not on, full mode switch\n");
                                        mode_changed = true;
                                }

                                break;
                        }
                }

                if (new_encoder != connector->encoder) {
                        DRM_DEBUG_KMS("encoder changed, full mode switch\n");
                        mode_changed = true;
                        /* If the encoder is reused for another connector, then
                         * the appropriate crtc will be set later.
                         */
                        if (connector->encoder)
                                connector->encoder->crtc = NULL;
                        connector->encoder = new_encoder;
                }
        }
        drm_connector_list_iter_end(&conn_iter);

        if (fail) {
                ret = -EINVAL;
                goto fail;
        }

        count = 0;
        drm_connector_list_iter_begin(dev, &conn_iter);
        drm_for_each_connector_iter(connector, &conn_iter) {
                if (!connector->encoder)
                        continue;

                if (connector->encoder->crtc == set->crtc)
                        new_crtc = NULL;
                else
                        new_crtc = connector->encoder->crtc;

                for (ro = 0; ro < set->num_connectors; ro++) {
                        if (set->connectors[ro] == connector)
                                new_crtc = set->crtc;
                }

                /* Make sure the new CRTC will work with the encoder */
                if (new_crtc &&
                    !drm_encoder_crtc_ok(connector->encoder, new_crtc)) {
                        ret = -EINVAL;
                        drm_connector_list_iter_end(&conn_iter);
                        goto fail;
                }
                if (new_crtc != connector->encoder->crtc) {
                        DRM_DEBUG_KMS("crtc changed, full mode switch\n");
                        mode_changed = true;
                        connector->encoder->crtc = new_crtc;
                }
                if (new_crtc) {
                        DRM_DEBUG_KMS("[CONNECTOR:%d:%s] to [CRTC:%d:%s]\n",
                                      connector->base.id, connector->name,
                                      new_crtc->base.id, new_crtc->name);
                } else {
                        DRM_DEBUG_KMS("[CONNECTOR:%d:%s] to [NOCRTC]\n",
                                      connector->base.id, connector->name);
                }
        }
        drm_connector_list_iter_end(&conn_iter);

        /* mode_set_base is not a required function */
        if (fb_changed && !crtc_funcs->mode_set_base)
                mode_changed = true;

        if (mode_changed) {
                if (drm_helper_crtc_in_use(set->crtc)) {
                        DRM_DEBUG_KMS("attempting to set mode from"
                                        " userspace\n");
                        drm_mode_debug_printmodeline(set->mode);
                        set->crtc->primary->fb = set->fb;
                        if (!drm_crtc_helper_set_mode(set->crtc, set->mode,
                                                      set->x, set->y,
                                                      save_set.fb)) {
                                DRM_ERROR("failed to set mode on [CRTC:%d:%s]\n",
                                          set->crtc->base.id, set->crtc->name);
                                set->crtc->primary->fb = save_set.fb;
                                ret = -EINVAL;
                                goto fail;
                        }
                        DRM_DEBUG_KMS("Setting connector DPMS state to on\n");
                        for (i = 0; i < set->num_connectors; i++) {
                                DRM_DEBUG_KMS("\t[CONNECTOR:%d:%s] set DPMS on\n", set->connectors[i]->base.id,
                                              set->connectors[i]->name);
                                set->connectors[i]->funcs->dpms(set->connectors[i], DRM_MODE_DPMS_ON);
                        }
                }
                __drm_helper_disable_unused_functions(dev);
        } else if (fb_changed) {
                set->crtc->x = set->x;
                set->crtc->y = set->y;
                set->crtc->primary->fb = set->fb;
                ret = crtc_funcs->mode_set_base(set->crtc,
                                                set->x, set->y, save_set.fb);
                if (ret != 0) {
                        set->crtc->x = save_set.x;
                        set->crtc->y = save_set.y;
                        set->crtc->primary->fb = save_set.fb;
                        goto fail;
                }
        }

        kfree(save_connector_encoders);
        kfree(save_encoder_crtcs);
        return 0;

fail:
        /* Restore all previous data. */
        count = 0;
        drm_for_each_encoder(encoder, dev) {
                encoder->crtc = save_encoder_crtcs[count++];
        }

        count = 0;
        drm_connector_list_iter_begin(dev, &conn_iter);
        drm_for_each_connector_iter(connector, &conn_iter)
                connector->encoder = save_connector_encoders[count++];
        drm_connector_list_iter_end(&conn_iter);

        /* after fail drop reference on all unbound connectors in set, let
         * bound connectors keep their reference
         */
        for (ro = 0; ro < set->num_connectors; ro++) {
                if (set->connectors[ro]->encoder)
                        continue;
                drm_connector_put(set->connectors[ro]);
        }

        /* Try to restore the config */
        if (mode_changed &&
            !drm_crtc_helper_set_mode(save_set.crtc, save_set.mode, save_set.x,
                                      save_set.y, save_set.fb))
                DRM_ERROR("failed to restore config after modeset failure\n");

        kfree(save_connector_encoders);
        kfree(save_encoder_crtcs);
        return ret;
}
EXPORT_SYMBOL(drm_crtc_helper_set_config);
```

{{< figure src="/ox-hugo/img_20231123_104321.jpg" >}}

现在就是要找什么时个会调用多次，这个很重要。

```c
static void dce_v6_0_crtc_dpms(struct drm_crtc *crtc, int mode)
{
        struct drm_device *dev = crtc->dev;
        struct amdgpu_device *adev = dev->dev_private;
        struct amdgpu_crtc *amdgpu_crtc = to_amdgpu_crtc(crtc);
        unsigned type;

        switch (mode) {
        case DRM_MODE_DPMS_ON:
                amdgpu_crtc->enabled = true;
                amdgpu_atombios_crtc_enable(crtc, ATOM_ENABLE);
                amdgpu_atombios_crtc_blank(crtc, ATOM_DISABLE);
                /* Make sure VBLANK and PFLIP interrupts are still enabled */
                type = amdgpu_display_crtc_idx_to_irq_type(adev,
                                                amdgpu_crtc->crtc_id);
                amdgpu_irq_update(adev, &adev->crtc_irq, type);
                amdgpu_irq_update(adev, &adev->pageflip_irq, type);
                drm_crtc_vblank_on(crtc);
                dce_v6_0_crtc_load_lut(crtc);
                break;
        case DRM_MODE_DPMS_STANDBY:
        case DRM_MODE_DPMS_SUSPEND:
        case DRM_MODE_DPMS_OFF:
                drm_crtc_vblank_off(crtc);
                if (amdgpu_crtc->enabled)
                        amdgpu_atombios_crtc_blank(crtc, ATOM_ENABLE);
                amdgpu_atombios_crtc_enable(crtc, ATOM_DISABLE);
                amdgpu_crtc->enabled = false;
                break;
        }
        /* adjust pm to dpms */
        amdgpu_pm_compute_clocks(adev);
}
```

我看的代码是内核的代码，而机器上使用的是 amdgpu_dkms 的代码，在内核当中搜不到，那么从 dkms 的代码当中看看。如果还是没有，那就非常的奇怪了。

最诡异的是找不到 drm_crtc_helper_set_config 这个函数的调用者是谁。

使用 bpftrace 来分析一下这个工具。

```nil
uos@uos-PC:~$ sudo stackcount-bpfcc drm_crtc_helper_set_config
请输入密码:
验证成功
Tracing 1 functions for "drm_crtc_helper_set_config"... Hit Ctrl-C to end.
^C
  drm_crtc_helper_set_config
  amdgpu_display_crtc_set_config
  __drm_mode_set_config_internal
  drm_mode_setcrtc
  drm_ioctl_kernel
  drm_ioctl
  amdgpu_drm_ioctl
  do_vfs_ioctl
  ksys_ioctl
  __x64_sys_ioctl
  do_syscall_64
  entry_SYSCALL_64_after_hwframe
  ioctl
  [unknown]
    Xorg [3966]
    1

  drm_crtc_helper_set_config
  amdgpu_display_crtc_set_config
  __drm_mode_set_config_internal
  drm_mode_setcrtc
  drm_ioctl_kernel
  drm_ioctl
  amdgpu_drm_ioctl
  do_vfs_ioctl
  ksys_ioctl
  __x64_sys_ioctl
  do_syscall_64
  entry_SYSCALL_64_after_hwframe
  ioctl
  [unknown]
    Xorg [972]
    1

  drm_crtc_helper_set_config
  amdgpu_display_crtc_set_config
  __drm_mode_set_config_internal
  drm_mode_setcrtc
  drm_ioctl_kernel
  drm_ioctl
  amdgpu_drm_ioctl
  do_vfs_ioctl
  ksys_ioctl
  __x64_sys_ioctl
  do_syscall_64
  entry_SYSCALL_64_after_hwframe
  ioctl
  [unknown]
    Xorg [972]
    1

Detaching...
```

有问题的时候是这样的：

```nil
uos@uos-PC:~$ sudo stackcount-bpfcc drm_crtc_helper_set_config
Tracing 1 functions for "drm_crtc_helper_set_config"... Hit Ctrl-C to end.
^C
  drm_crtc_helper_set_config
  amdgpu_display_crtc_set_config
  __drm_mode_set_config_internal
  drm_mode_setcrtc
  drm_ioctl_kernel
  drm_ioctl
  amdgpu_drm_ioctl
  do_vfs_ioctl
  ksys_ioctl
  __x64_sys_ioctl
  do_syscall_64
  entry_SYSCALL_64_after_hwframe
  ioctl
  [unknown]
    Xorg [3966]
    1

  drm_crtc_helper_set_config
  amdgpu_display_crtc_set_config
  __drm_mode_set_config_internal
  drm_crtc_force_disable
  drm_framebuffer_remove
  drm_mode_rmfb_work_fn
  process_one_work
  worker_thread
  kthread
  ret_from_fork
    kworker/7:0 [14323]
    1

  drm_crtc_helper_set_config
  amdgpu_display_crtc_set_config
  __drm_mode_set_config_internal
  drm_mode_setcrtc
  drm_ioctl_kernel
  drm_ioctl
  amdgpu_drm_ioctl
  do_vfs_ioctl
  ksys_ioctl
  __x64_sys_ioctl
  do_syscall_64
  entry_SYSCALL_64_after_hwframe
  ioctl
  [unknown]
    Xorg [972]
    1

  drm_crtc_helper_set_config
  amdgpu_display_crtc_set_config
  __drm_mode_set_config_internal
  drm_mode_setcrtc
  drm_ioctl_kernel
  drm_ioctl
  amdgpu_drm_ioctl
  do_vfs_ioctl
  ksys_ioctl
  __x64_sys_ioctl
  do_syscall_64
  entry_SYSCALL_64_after_hwframe
  ioctl
  [unknown]
    Xorg [3966]
    1

Detaching...
```

经过多次测试，很明确的是 kworker 导致了多次的调用。drm_mode_rmfb_work_fn ，这个函数在什么情况下会触发？这个函数的调用者是 drm_mode_rmfb 和 drm_fb_release 这两个函数。再往上找应该就是真正的原因了。

drm_mode_rmfb 的调用栈也可以用 bpftrace 来试一下。也可以 emacs 看代码分析一下。要不还 bpf 试一下吧。

drm_client_buffer_rmfb

drm_client_framebuffer_delete

drm_fbdev_cleanup

drm_fbdev_release 和 drm_fbdev_client_hotplug ，显然用的是 release 这个。

drm_fbdev_fb_destroy

```nil
uos@uos-PC:~$ sudo stackcount-bpfcc drm_fb_release
Tracing 1 functions for "drm_fb_release"... Hit Ctrl-C to end.
^C
  drm_fb_release
  drm_file_free.part.5
  drm_release
  __fput
  task_work_run
  exit_to_usermode_loop
  do_syscall_64
  entry_SYSCALL_64_after_hwframe
  __close
    dde-blackwidget [9780]
    1

  drm_fb_release
  drm_file_free.part.5
  drm_release
  __fput
  task_work_run
  exit_to_usermode_loop
  do_syscall_64
  entry_SYSCALL_64_after_hwframe
  __close
  [unknown]
  [unknown]
  [unknown]
    dde-blackwidget [9780]
    1

Detaching...
```

现在现象有三种，不闪烁，闪一下，和黑屏一段时间，上面的这种是后两种情况出现的。看起来和 dde-blackwidget 这个有关系。

通过 gdb 调试，发现多次调用 drmModeRmFB ，这个函数是 libdrm 的函数。调用者往前找是

{{< figure src="/ox-hugo/img_20231124_164822.jpg" alt="Caption not used as alt text" caption="<span class=\"figure-number\">Figure 2: </span>/ 第一次调用 /" link="t" class="fancy" width="1500" target="_blank" >}}

{{< figure src="/ox-hugo/img_20231124_165440.jpg" alt="Caption not used as alt text" caption="<span class=\"figure-number\">Figure 3: </span>/ 第二次调用 /" link="t" class="fancy" width="1500" target="_blank" >}}

为什么会多次调用，我的目的始终是找到这个问题的源头。

看代码，对比。

问题好像找到了，if (!info-&gt;shadow_fb) 这个判断可能是问题的根因。在没有出错的情况下没有这个调用的话。
AMDGPULeaveVT_KMS 每次离开的时候都会调用一次。这个怀疑的点是很好的，现在就是怎么编译一套代码做替换，这个不仅仅是 xorg ，还有别的包。有人绐了我一个编译的脚本，研究一下。

编译 xserver-xorg-video-amdgpu 时报了一个奇怪的错误，syntax error near unexpected token \`RANDR,' ，这个错误居然是没有装 xorg-dev ，参见下面：

<https://github.com/merge/xf86-input-tslib/issues/9>

```bash
CPU_PLATFORM="x86_64-linux-gnu"
BIN_DEPLOY_PATH="/home/uos/xorg-deploy"
modules_DEPLOY_PATH=$BIN_DEPLOY_PATH/lib/$CPU_PLATFORM/xorg/modules
DRIVER_PATH=$modules_DEPLOY_PATH/drivers
INPUT_PATH=$modules_DEPLOY_PATH/input

SRC_PATH="/home/uos/wangxinbo/src/xorg-server"

echo ">>>>>> modules_DEPLOY_PATH "$modules_DEPLOY_PATH
echo ">>>>>> DRIVER_PATH "$DRIVER_PATH
echo ">>>>>> INPUT_PATH "$INPUT_PATH

#  编译xorg
cd $SRC_PATH
export PKG_CONFIG_PATH=$BIN_DEPLOY_PATH/share/pkgconfig:$BIN_DEPLOY_PATH/lib/pkgconfig:$PKG_CONFIG_PATH
meson build --prefix=$BIN_DEPLOY_PATH
cd build
ninja
ninja install

echo ">>>>>> xorg build finished"

# 安装XKB
if [ ! -d "$BIN_DEPLOY_PATH/share/X11/" ]; then
mkdir -p $BIN_DEPLOY_PATH/share/X11/
cp -r /usr/share/X11/xkb/ $BIN_DEPLOY_PATH/share/X11/
cd $BIN_DEPLOY_PATH/bin/
ln -s /usr/bin/xkbcomp  ./xkbcomp
echo ">>>>>> XKB installing finished"
fi



# 安装video driver
if [ ! -d "$DRIVER_PATH" ]; then
mkdir -p $DRIVER_PATH
cp /usr/lib/xorg/modules/drivers/* $DRIVER_PATH
echo ">>>>>> video driver installing finished"
fi

# 安装input driver
if [ ! -d "$INPUT_PATH" ]; then
mkdir -p $INPUT_PATH
cp /usr/lib/xorg/modules/input/* $INPUT_PATH
echo ">>>>>> input driver installing finished"
fi

# 创建log日志
if [ ! -f "$BIN_DEPLOY_PATH" ]; then
mkdir -p $BIN_DEPLOY_PATH/var/log
echo ">>>>>> log path created"
fi

# 安装ddx驱动配置
if [ ! -f "$BIN_DEPLOY_PATH/share/X11/xorg.conf.d" ]; then
mkdir -p $BIN_DEPLOY_PATH/share/X11/xorg.conf.d
cp /usr/share/X11/xorg.conf.d/* $BIN_DEPLOY_PATH/share/X11/xorg.conf.d
echo ">>>>>> ddx config file installing finished"
fi
```

用编译完成的 amdgpu_drv.so 替换系统下原有的：

/usr/lib/xorg/modules/drivers/amdgpu_drv.so ，这样的话应该就能够对应的上代码了吧。

替换完成后重启。用 gdb 调试，每次的调用是否是一样的呢？只针对 AMDGPULeaveVT_KM 这个函数确实每次都是一样的。

intel 集显也会偶尔出现黑屏的现象。签于 amd 显卡测试的现象不稳定，可以用 intel 的分析一下。还有一个思路就是换早期版本的 UOS 镜像，下载下来测试一下，看看有没有问题。

intel 显卡没有测试出来黑屏一段时间。

回到之间的思路，还是一个问题。

```nil
uos@uos-PC:~$ sudo stackcount-bpfcc drm_crtc_helper_set_config
Tracing 1 functions for "drm_crtc_helper_set_config"... Hit Ctrl-C to end.
^C
  drm_crtc_helper_set_config
  amdgpu_display_crtc_set_config
  __drm_mode_set_config_internal
  drm_crtc_force_disable
  drm_framebuffer_remove
  drm_mode_rmfb_work_fn
  process_one_work
  worker_thread
  kthread
  ret_from_fork
    kworker/4:3 [8160]
    1

  drm_crtc_helper_set_config
  amdgpu_display_crtc_set_config
  __drm_mode_set_config_internal
  drm_mode_setcrtc
  drm_ioctl_kernel
  drm_ioctl
  amdgpu_drm_ioctl
  do_vfs_ioctl
  ksys_ioctl
  __x64_sys_ioctl
  do_syscall_64
  entry_SYSCALL_64_after_hwframe
  ioctl
  [unknown]
    Xorg [893]
    11

  drm_crtc_helper_set_config
  amdgpu_display_crtc_set_config
  __drm_mode_set_config_internal
  drm_mode_setcrtc
  drm_ioctl_kernel
  drm_ioctl
  amdgpu_drm_ioctl
  do_vfs_ioctl
  ksys_ioctl
  __x64_sys_ioctl
  do_syscall_64
  entry_SYSCALL_64_after_hwframe
  ioctl
  [unknown]
    Xorg [4491]
    11

  drm_crtc_helper_set_config
  amdgpu_display_crtc_set_config
  __drm_mode_set_config_internal
  drm_mode_setcrtc
  drm_ioctl_kernel
  drm_ioctl
  amdgpu_drm_ioctl
  do_vfs_ioctl
  ksys_ioctl
  __x64_sys_ioctl
  do_syscall_64
  entry_SYSCALL_64_after_hwframe
  ioctl
  [unknown]
    Xorg [893]
    22

  drm_crtc_helper_set_config
  amdgpu_display_crtc_set_config
  __drm_mode_set_config_internal
  drm_mode_setcrtc
  drm_ioctl_kernel
  drm_ioctl
  amdgpu_drm_ioctl
  do_vfs_ioctl
  ksys_ioctl
  __x64_sys_ioctl
  do_syscall_64
  entry_SYSCALL_64_after_hwframe
  ioctl
  [unknown]
    Xorg [4491]
    22

Detaching...
```


## 关于 mesa 和 amdgpu umd 驱动 {#关于-mesa-和-amdgpu-umd-驱动}

<https://cloud.tencent.com/developer/article/2206046>

umd 的驱动在哪里？

amdgpu 的 umd 驱动有两个包，一个是 libdrm 中的 amdgpu 部分，一个是 xserver-xorg-video-amdgpu 这个部分。切换用户的时候不会从新加载驱动程序，只会只需要进行与 UMD 驱动的交互，以获取 GPU 访问权限并使用已初始化好的 UMD 库进行图形操作。


## 这个函数的 WARN 没有显示出来新的调用信息 {#这个函数的-warn-没有显示出来新的调用信息}

```c
void drm_framebuffer_remove(struct drm_framebuffer *fb)
{
        struct drm_device *dev;

        if (!fb)
                return;

        dev = fb->dev;

        WARN_ON(!list_empty(&fb->filp_head));

        /*
         * drm ABI mandates that we remove any deleted framebuffers from active
         * useage. But since most sane clients only remove framebuffers they no
         * longer need, try to optimize this away.
         *
         * Since we're holding a reference ourselves, observing a refcount of 1
         * means that we're the last holder and can skip it. Also, the refcount
         * can never increase from 1 again, so we don't need any barriers or
         * locks.
         *
         * Note that userspace could try to race with use and instate a new
         * usage _after_ we've cleared all current ones. End result will be an
         * in-use fb with fb-id == 0. Userspace is allowed to shoot its own foot
         * in this manner.
         */
        if (drm_framebuffer_read_refcount(fb) > 1) {
                if (drm_drv_uses_atomic_modeset(dev)) {
                        int ret = atomic_remove_fb(fb);
                        WARN(ret, "atomic remove_fb failed with %i\n", ret);
                } else
                        legacy_remove_fb(fb);
        }

        drm_framebuffer_put(fb);
}
EXPORT_SYMBOL(drm_framebuffer_remove);
```


## 模拟错误的产生 {#模拟错误的产生}

(1) 看看是不是走到了这个分支里面去，理解代码。

```c
static void legacy_remove_fb(struct drm_framebuffer *fb)
{
        struct drm_device *dev = fb->dev;
        struct drm_crtc *crtc;
        struct drm_plane *plane;

        drm_modeset_lock_all(dev);
        /* remove from any CRTC */
        drm_for_each_crtc(crtc, dev) {
                if (crtc->primary->fb == fb) {
                        /* should turn off the crtc */
                        if (drm_crtc_force_disable(crtc))
                                DRM_ERROR("failed to reset crtc %p when fb was deleted\n", crtc);
                }
        }

        drm_for_each_plane(plane, dev) {
                if (plane->fb == fb)
                        drm_plane_force_disable(plane);
        }
        drm_modeset_unlock_all(dev);
}
```

(2) 看看是不是走到了分支 legacy_remove_fb(fb) 这里去了，加一下打印。是的。

```c
void drm_framebuffer_remove(struct drm_framebuffer *fb)
{
        struct drm_device *dev;

        if (!fb)
                return;

        dev = fb->dev;

        WARN_ON(!list_empty(&fb->filp_head));

        /*
         * drm ABI mandates that we remove any deleted framebuffers from active
         * useage. But since most sane clients only remove framebuffers they no
         * longer need, try to optimize this away.
         *
         * Since we're holding a reference ourselves, observing a refcount of 1
         * means that we're the last holder and can skip it. Also, the refcount
         * can never increase from 1 again, so we don't need any barriers or
         * locks.
         *
         * Note that userspace could try to race with use and instate a new
         * usage _after_ we've cleared all current ones. End result will be an
         * in-use fb with fb-id == 0. Userspace is allowed to shoot its own foot
         * in this manner.
         */
        if (drm_framebuffer_read_refcount(fb) > 1) {
                if (drm_drv_uses_atomic_modeset(dev)) {
                        int ret = atomic_remove_fb(fb);
                        WARN(ret, "atomic remove_fb failed with %i\n", ret);
                } else
                        legacy_remove_fb(fb);
        }

        drm_framebuffer_put(fb);
}
EXPORT_SYMBOL(drm_framebuffer_remove);
```

bpf 查一下 legacy_remove_fb 这个函数的调用。不能查，加打印，发现确实是调用的 legacy 接口。

问题是解释清楚这个过程出现的原因。这样这个 bug 才能说明清楚。


## 用加延时的方法来测试 {#用加延时的方法来测试}

(1) 加延时的意思是什么？

(2) 删除所有的 fb 的原因是什么？

```c
static void drm_mode_rmfb_work_fn(struct work_struct *w)
{
        struct drm_mode_rmfb_work *arg = container_of(w, typeof(*arg), work);

        while (!list_empty(&arg->fbs)) {
                struct drm_framebuffer *fb =
                        list_first_entry(&arg->fbs, typeof(*fb), filp_head);

                list_del_init(&fb->filp_head);
                drm_framebuffer_remove(fb);
        }
}
```

正常的情况下只会删除自己的一个 fb 。异常的时候才会删除所有的 fb 。

把这些 fb 打印出来，找到这些 fb 的上层是谁在持有。

(3) gdb 调试的时候 xorg 会收到信号，是什么信号呢？

Thread 1 "Xorg" received signal SIGUSR1, User defined signal 1.
0x00007f662a834aff in epoll_wait (epfd=3, events=0x7ffdbe20c8b0, maxevents=256, timeout=-1)
    at ../sysdeps/unix/sysv/linux/epoll_wait.c:30
30	in ../sysdeps/unix/sysv/linux/epoll_wait.c

这个信号是 xorg 重新加载配置的信号。这个时候要看 xorg 的代码了。

(4) 怎么模拟 xorg 处理信号？

kill -SIGUSR1 915

用这个命令有的时候可以模拟出来黑屏的效果，可以认为是这个信号调用有时候会引起黑屏。

用 CRASH 来处理一下。或者用 gdb 跟一下看一下这个信号来怎么处理的，内核态返回用户态的时候会有信号。

(5) 再往下分析的话要分析，什么情况下会出现“信号”处理不过来的情况。

是真的信号处理不过来了吗？还是其它的原因？

在 Linux 内核中，work_struct 结构体是表示工作队列（work queue）中的一个工作项（work item）。工作队列是一种异步执行任务的机制，在后台执行耗时的操作或延迟处理。它是内核中非常常用的一种机制，广泛应用于各种驱动程序和子系统中。

一直搞不清楚，rm 的 fb 到底是哪里来的。先不管怎么来的，先打印一下，看看有几个 fb ，这之后再分析。也是一个 fb ，并没有多个 fb 需要销毁。所以应该和个数没有什么关系。

内核进程销毁是通过调用这三行：

```c
struct drm_framebuffer *fb =
                        list_first_entry(&arg->fbs, typeof(*fb), filp_head);

                list_del_init(&fb->filp_head);
                drm_framebuffer_remove(fb);
```

这个函数： void drm_framebuffer_put(struct drm_framebuffer \*fb); 他的作用是将 framebuffer 的引用计数加 1 ，如果引用计数是 0 的话就释放 framebuffer 。

上面的逻辑看清楚了之后，就明白了。

如何找到 fb 的引用者？这个信息怎么获取到？

占老板让看：/sys/kernel/debug/dri/0/clients 这个文件。

GPT 让我看： _sys/kernel/debug/fb_ 但是这个文件没有找到。

又查到可以用 SystemTap 来追踪 fb 的引用者。需要安装内核的 debug 包。

这个追踪遇到了一点问题。

用 drgn 或者 gdb 的调试脚本，找一下，可能申请 fb 引用的地方，这些地方还是看代码。

用 systemtap 调试要写一些调试脚本，不是太好用的样子，尝试 probe 写了几个 drm fb 相关的函数都不能用。

/sys/kernel/debug/dri/0/framebuffer 这个中的内容看起来很像是有东西。

sudo apt-get install inotify-tools

用这个工具来监视文件的变化。inotifywait -m -r _sys/kernel_ ，发现在切换用户的时候这个文件没有变化。

那要想其它的办法了。

能通过 gdb 或都 ebpf 找到更多的信息吗？gdb 加脚本，或者是
