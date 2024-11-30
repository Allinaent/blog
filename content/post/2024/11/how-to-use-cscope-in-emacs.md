+++
title = "用服务器看内核代码的最小化实践"
date = 2024-11-27T21:26:00+08:00
lastmod = 2024-11-27T21:49:51+08:00
categories = ["kernel"]
draft = false
toc = true
image = "https://r2.guolongji.xyz/allinaent/2024/06/92a1feeab471b12646b9c76edccc1546.jpg"
+++

之前看代码需要自己本地的环境，但是这个环境太大了，不够轻便。而其实想办好不同的事要用很多不同的工具，适合的才是好的。不能杀鸡用牛刀。也不能用龙门吊砸核桃。


## 安装 {#安装}

在 rhel/centos 系的系统看内核代码，最简单的就是：

yum install xcscope

yum install ctags

yum install emacs

终端下 0 配置的 emacs 并不丑，请接受这一点。

在 .emacs.d/init.el 当中加入：

```lisp
(load-file "/usr/share/emacs/site-lisp/xcscope.el")                                                       |
(require 'xcscope)
```


## 使用 {#使用}

进入内核目录，执行：

make cscope tags

<https://www.linumiz.com/linux-kernel-source-browsing-using-cscope/>

就这么简简单单的一句话，就做完了，而且，只会索引机器的架构的代码；其它架构的直接过滤掉了。

C-c s s

C-c s c

C-c s g

就这三条命令，足以看代码。


## 其它 {#其它}

问我为什么没有用 global ？因为这个源中默认没有，需要找代码编译。就在机器上用一下，浪费时间不？

global 可以增量更新，增量更新的速度快，那请问我要写代码了，我为什么不先写个文档，把内核的东西的理顺了。快速看代码和写一个新功能本来就不是一个需求。我平时是看代码分析问题的时候更多，而不是搞懂一个子系统来写代码的时候多。而且，我可以复制一份新的代码来写，用 git 看修改，只读旧代码。

如果一定要写代码，我当然也不介意编一个 global 来用。这个等到再有需要的时候再写一个博客吧。
