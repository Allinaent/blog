+++
title = "置顶：博客计划与完成"
date = 2023-10-12T11:04:00+08:00
lastmod = 2024-04-10T13:40:13+08:00
categories = ["plan"]
draft = false
weight = 1
toc = true
image = "https://r2.guolongji.xyz/plan.jpg"
+++

## 计划的任务 {#计划的任务}

-   将开发环境装到 U 盘上随身携带，并借此机会优化和重构我的 emacs 配置。

全过程做一下记录吧。24 年 3 月 6 日。

时间不同步的问题：<https://blog.csdn.net/X_T_S/article/details/110142773>
sudo apt-get install ntpdate

sudo ntpdate time.windows.com

sudo hwclock --localtime --systohc

-   免费内网穿透

<https://www.natfrp.com/user/>

配合 nginx ，把我的 Nas 利用起来，这个 Nas 只为了同步文件。还有跑一些服务。有用的就是网站了。

<https://blog.csdn.net/qwex888/article/details/122968063>

利用 Zerotier 。这相当于，我下载了一个客户端之后，就能访问我的 NAS 且速度非常快。和 snycthing 有一些像吧。但是不一样。

我的 Network ID 是：856127940c697801

工作机的 ID 是：311fd05b42

ubuntutogo 的 ID 是：f59277a974

用法简单，速度也是很快。如果只是自己用的话，根本不需要花钱买公网 ip 或者花钱弄个服务器，搞内网穿透。加速的方法很多，而 p2p 是网络对等降低成本的好方法。

p2p 不好用，这个东西不稳定。

而使用 syncthing 这种东西的话，我设计一种目录规则，目录名称为 syncthing + 机器名 + 分类名。比如我工作中存了大量的文档。我可以把这些文档放在：syncthing_uos_work 当中。

我觉得我还是有必要把工作当中的文档存到 Nas 上的，这样以后离职了也随时都能看。

-   域名迁到国内，进行备案之后才能建站使用

这个太坑了。烦人。迁移可以不着急，下次记得买域名一定要

-   什么是内核的魔术键？

这个东西简单查了一下，看起来比较深奥。现在也不是很清楚有什么用，到底能解决什么问题，有什么用。希望有人能绐我一点通俗的解释，让我能够少费些力气来理解这个问题。

-   文韬大佬邮件中提到的一些有用的东西

-   git 常用命令

-   运维常用命令

-   网卡的一些问题解决方法

-   龙芯的交叉编译

-   有价值的之前的文档

-   etc

ai，math 和内核


## 完成的任务 {#完成的任务}

-   emacs 使用 mu4e

这个我本地用来读写 QQ 和 exmail 邮件，功能已经很好了，但是没总结。

-   trace-bpfcc 和 mesa 的调试方法

“这个问了洪奥大佬，还没有自己实践过。” 现在这个初步做过了。对于操作系统信号中断和调度的学习要深入。

-   小工具的网站

去水印，ai 问答
