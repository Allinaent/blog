+++
title = "tty和x的切换流程"
date = 2023-09-25T10:31:00+08:00
lastmod = 2023-09-26T17:02:41+08:00
tags = ["gpu"]
categories = ["technology"]
draft = false
toc = true
+++

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

{{< figure src="/ox-hugo/img_20230926_090023.png" >}}


## X 切换到 tty 花的时间比较长 {#x-切换到-tty-花的时间比较长}

dde 调用: dde-switchtogreeter uos

等同直接调用

gdbus call --system --dest org.freedesktop.DisplayManager --object-path /org/freedesktop/DisplayManager/Seat0 --method org.freedesktop.DisplayManager.Seat.SwitchToGreeter
