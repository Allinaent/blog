+++
title = "在 qemu 当中打开串口日志"
date = 2025-01-08T17:01:00+08:00
lastmod = 2025-01-08T17:21:43+08:00
categories = ["kernel"]
draft = false
toc = true
image = "https://r2.guolongji.xyz/allinaent/2024/06/92a1feeab471b12646b9c76edccc1546.jpg"
+++

在 qemu 中添加串口的问题遇到过很多次了，总是忘记，这里做一下记录。

一个是qemu 的外设当中添加一个串口，写到文件 file 或者使用本机的串口。例如 /dev/tty14 这样。在 kvm 虚拟机的 grub 当中增加
console=ttyS0,115200 这样的像是串口的配置就可以了。

另外如果虚拟机安装过程中卡在某个图形界面，一定要认真看英文的小字，例如 rhel 6.5 安装时卡住了，仔细看会发再用 f12 会进入下一屏，就可以继续安装了。
