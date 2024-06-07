+++
title = "使用 emacs 和 orgzly 来gtd"
date = 2024-05-06T16:53:00+08:00
lastmod = 2024-06-04T09:47:29+08:00
categories = ["emacs"]
draft = false
toc = true
image = "https://r2.guolongji.xyz/allinaent/2024/06/9a83df14d8b03d6344c68386e59dbdf2.jpg"
+++

写在前面，适合自己的就是最好的。我们大多数人往往陷入一种错误的状态当中，认为做什么事一定要做到一种最好的结果。或者自己能达到的最好的结果，殊不知这个世界“最好”只是数学上的极限，是一种过程，而不是一个结果。

在趋近于的过程当中，如果才能显得帅气而优雅。往往是退而求其次，先掌握一般的，简单的能力，再上一层楼，去追求更高一层的能力。更好的结果。


## orgzly {#orgzly}

手机下载这个软件。

下载地址：<https://github.com/orgzly-revived/orgzly-android-revived>


## termux {#termux}

手机下载这个软件。

下载地址：<https://github.com/termux/termux-app>

org 日程的文档我没有选择用 syncthing，而是选择有 git，各有利弊，我是比较喜欢这种 git
的同步方式。

使用 termux 安装 git 和 openssl，然后生成 rsa 的 ssh-key。在 git 的仓库中做了 git
的免密钥，这块没啥可说的。

但是用 termux 我不能找到这个软件的工作目录。经过查看才知道，可以通过这个命令：

```bash
termux-setup-storage
```

这样就会在 termux 的工作目录：/data/data/com.termux/files/home 生成一个 storage 文件夹，在其中的 shared 目录，就是 android 手机的内部存储根目录了。这样就能访问到我共享的文件了。


### orgzly 的设置 {#orgzly-的设置}

这个软件用起来也很坑。

不能使用导入 org 文件。识别不到 org 文件，也不能在手机的文件管理器当中使用 orgzly 来打开 org 文件。而要选择右上角的三个点，同步，选择本地文件来导入笔记本。

现在导入完成了，又看到了一个想吐的地方，每个笔记本都会显示出来路径和最后的修改动作，并且最后的修改也显示路径。按照我内部存储的目录，那是一个长长的一长串。

找了半天，终于在“设置——笔记 &amp; 笔记本——详情”当中找到了关闭的选项。现在这个 orgzly
终于可以使用了。


## emacs 的设置 {#emacs-的设置}

我之前已经在电脑端的 emacs 当中做了用 orgmode 做日程管理的设置。这部分内容网上有很多人已经做了很好的分享，我就不啰嗦了。

但是有一点我想强调，对我而言，别人的好的实现我刚开始用觉得过于复杂。而对于时间表，计划表这类的东西，是用于中长期的规划的。很短时间可以完成的任务写在计划当中就是浪费时间，而不会对人生起到辅助的作用。

如果短期的任务也需要记录，那一定是一个大忙人，我觉得那样的人 emacs 肯定是帮不了他了，多少得整个秘书才行。
