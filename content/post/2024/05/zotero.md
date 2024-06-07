+++
title = "如臂使指——构建自己的个人知识库"
date = 2024-05-16T14:31:00+08:00
lastmod = 2024-06-04T09:46:59+08:00
categories = ["emacs", "prose"]
draft = false
toc = true
image = "https://r2.guolongji.xyz/allinaent/2024/06/3ebba5ba2655501d082d485a73ba52fb.jpg"
+++

知识千千万，能写在博客里查询的只有一少部分。大量的知识在什么地方呢？在浏览器的收藏夹中，在笔记中，在电脑 pdf 的书籍中。那么做为一个想把自己的知识系统化的整理，放到一个地方的人，应该怎么做呢？

经过一些尝试，踩过一些小坑后。接触到了自己想要的软件 zotero ，开源，免费，可以和我的 emacs
工作流集成到一起。经过简单的调教后，一旦熟悉，相信能够如臂使指，做到一件事：

活到老，学到老。


## zotero {#zotero}

这个软件的安装很简单。它能整理 pdf 文档，绐 pdf 增加注释。还能保存流览器的链接。界面清爽，有 win ，linux ，mac 版本。手机 iOS 的有软件， android 的暂时没有软件，正在研发中，也许马上就要出了。

我一般不会在手机上面用。无所谓了。


## 同步方式 {#同步方式}

难点。坚果云花钱。我有 NAS ，有 ipv6 。想着用 NAS 的 webdav 来访问，刚开始以为就像管理 NAS
的 https 链接一样使用简单。然而我还是年轻了，中间尝试的方法各有各的坑，现在只是做到可用了。但是体验不是特别好（但能用，免费的，要啥自行车）。


### 方式一 cloudflare cdn 代理 ipv6 网络 {#方式一-cloudflare-cdn-代理-ipv6-网络}

使用我 cloudflare 的域名加 webdav 设置的 https 的端口号。这种方式可以访问，也可以同步，但是在同步较大的 pdf 文件（几十兆到 100 兆）的时候会报文件过大的错误。

<https://www.ztianzeng.com/posts/Cloudflare%E8%AE%A9IPV6%E4%B8%8D%E5%9C%A8%E9%B8%A1%E8%82%8B/>

这可能跟 CDN 服务器的 upload_max_filesize 设置有关系。总之，这个方法不行了。


### 方式二使用樱花的免费内网穿透地址来访问 {#方式二使用樱花的免费内网穿透地址来访问}

<https://www.natfrp.com/>

这个配置完成后，访问 ip 端口，webdav 的址，报错 501 。服务器未能识别请求的方法，原因未知，是内网穿透服务器的问题吗？

内网穿透的配置是不是有问题呢？我先配一个 ssh 的服务看看能不能访问题。


### 方式三成功的方法使用 qnap 自带的 ddns http {#方式三成功的方法使用-qnap-自带的-ddns-http}

使用 qnap 自带的 ddns 加上 let's encrypt 的 ssl 证书，用 https 来访问是有问题的。在 linux 的桌面版中
zotero 提示是自签名的证书，不让进行同步；但是在手机的 iOS 版本中能使用这个自签名的证书。桌面版用 http 的方式同步。因为公网 ip 是 ipv6 的，所以 ipv4 的网络无法访问。需要使用支持 ipv6 的代理服务器。


## nas 防止被黑 {#nas-防止被黑}

<https://zhongce.sina.com.cn/iframe/article/view/126199/>

我的防护比较弱，ipv6 都被阿拉伯的黑客登陆了。直接换一个复杂的密码。

<https://www.wangsu.com/news/content/productupdates/867>


## 购买 ipv4 的动态 ip 地址 {#购买-ipv4-的动态-ip-地址}

情况 1：家里有公网 ipv4，从其他网络（例如公司等地方）访问家里 nas 等设备，这时候是直连，速度是最快的，只受到家里上传带宽限制，通常是 50 兆。

提醒：假设你在公司下载家里 nas 的文件，是家里的宽带在上传，公司在下载，通常下行速度比上行快，也就是瓶颈是家里宽带上行速度；反过来把公司数据传回到家里，受限于公司的上行速度。

情况 2：家里有公网 ipv4 和 ipv6，则和情况 1 一样。

情况 3：家里只有公网 ipv6，没有公网 ipv4，公司也有启用 ipv6，则和情况 1 一样。

情况 4：家里只有公网 ipv6，没有公网 ipv4，公司也没有启用 ipv6，则不能连接。

情况 5：家里只有公网 ipv6，没有公网 ipv4，公司也没有启用 ipv6，但是自己部署了隧道服务器或者用上了 cdn 等，则速度同时受限于隧道服务器速度/cdn 速度和自己宽带上行速度（木桶效应）。

为了提高体验，我觉得这个钱还是要花的。确实 Nas 永远是小众的需求。但是小众可以让自己用起来非常爽。这是一定的。

更大的世界，更好的工具，更多的知识，更广阔的世界。

20240519，我去办理了 ipv4 的公网地址。威联通自带的域名有点长，且不能像 cloudflare 那样将非 80 443 8080
的端口映射到


### 公网 ipv4 能干什么？ {#公网-ipv4-能干什么}

-   远程唤醒家中的台式机。

可以将我的 ubuntu 环境的 u 盘放到家里面，从公司电脑 ssh 到自己的机器当中。测试一下公网的远程唤醒。linux
又可以用命令直接关机，这样子的话。我确实可以做一个好用的远程开发机器学习的环境了。

-   nas 中的 webdav

可以存下来一生的学习资料。

-   nas 可以挂载到家中的台式机下载一些数据集

当中重要的资料，可以多处备份。

总的来说还是自用，50m 带宽，一个人用是 50M，两个人用就是 25M 了。所以机器最多放一些开发，测试类的东西。一定不要把帐号绐别人。


## lucky 比 ddns-go 功能更多 {#lucky-比-ddns-go-功能更多}

<https://lucky666.cn/docs/modules/ddns>

设置 ipv4 的 ddns。为了获得绝佳的使用体验，购买一个 ipv4 。域名一年 70 块，公网 ipv4 一年
240 块。这样就一年花了 300 块钱。也不算很多。和一个百度云盘大会员的花费差不多，但是会变成一个可以随时访问的大硬盘。还能搞安防之类的。这块不是很重要的需求。


## zotero 的使用 {#zotero-的使用}

<https://www.bilibili.com/video/BV1gP4y1y7yH/>

这里面有介绍了 8 个插件。


### zotero 的插件网站 {#zotero-的插件网站}

<https://www.zotero.org/support/plugins>


### zotero 的插件 zotfile {#zotero-的插件-zotfile}

<https://zhuanlan.zhihu.com/p/570509743>

这篇讲的很全，其中 rename and move 的过程就是同步 pdf 到一个目录结构良好的目录。实际上机器上的 pdf
文件存了两份。但是还好，只是两份而已。

<https://blog.csdn.net/qq_46450354/article/details/128363917>


### 值得注意的事 {#值得注意的事}

<https://www.bilibili.com/video/BV1Lc411J7gQ/>

Zotero 是一个科研文献管理器，而不是扫描版野生 pdf 的管理器。所认不是论文什么的，不能用 helm-bibtex
搜到东西。这一点确实有一点不爽。那有没有什么方式能够补救呢？有的——直接右键可以生成简化的 bibtex
信息足够在 emacs 当中查找和使用了。


### 意外的发现 zotero-find {#意外的发现-zotero-find}

一个老熟人 dalanicolai 写的库，试一下看是不是好用的。看到这么多的插件，我意识到，这个软件可能要很长时间和 emacs 一起用。网盘最方便的使用方式就是 webdav 了吧。

我有了公网 ip，不需要配置 snycthing。完全的数据自由。常改的东西，也没有必要用 git 反复提交。这个工作流确实是更适合我的，但是这样做会增加我 nas 硬盘的读写。方便的地方就是完全无感的两台机器完全一致的上下文环境。完全可以沉浸在持续的一个思路当中。

这个不好用，不必看了！！！


### 小米金色飞贼 {#小米金色飞贼}

<https://www.bilibili.com/video/BV1Mg4y1j75u/>

zotero 使用 better Bibtex 导出文献数据

核心是使用 orgmode 来同时使用 org-roam 和 org-noter 的两种格式就可以了。这个方法不错。zotero 我是通过 webdav 来同步的，那这个笔记也放到 zotero 的 webdav 当中去同步吗？这块没有搞清楚。

那其实核心的两部分，一部是 pdf 在 zotero 当中，另一部分是 orgmode 的笔记，也在 zotero 当中。当然小米大神的配置可能要修改一下路径，他用的是坚果云，而我用的是家中 nas 搭建的 webdav。

核心是 org-roam 这个先看一下官网的链接是怎么写的。这个是双链笔记的地方。还有就是说，zotero 这个软件只提供同步和生成 bibtex 这两个功能。我的笔记和书最好放在一起，都放到 webdav 当中多好呀。

双链笔记 + orgmode + webdav 这个确实是非常适合现在的我的。

弄清楚一点 zotero 会新存一个文件，之前写的在哪里？或者说新建的在哪里？之前写的文件导入 zotero 之后就不要再写原来路径下的文件了，而要使用导入的路径。实际上管理的插件是用 emacs 的 org-roam 和
helm-bibx 。走通这条工作流。读书破万卷，下笔如有神。来吧，一个包一个包的配置，一个包一个包的使用。


### helm-bibtex {#helm-bibtex}

<https://github.com/tmalsburg/helm-bibtex/>

插件要一个一个用。不用是不会明白其中真实的东西的。不会变成属于自己的东西。


### zotxt 插件 {#zotxt-插件}

<https://zhuanlan.zhihu.com/p/351003732>


### pdfhelper 支持 OCR 的功能 {#pdfhelper-支持-ocr-的功能}

<https://sspai.com/post/78133>

这个才是一个爱读书的人。扫描的书籍也可以将文字复杂下来。


### 终于搞懂了 org-roam {#终于搞懂了-org-roam}

我之前没搞过科研，用这个 zotero 还是看的不明不白的，我以为它能很方便的管理 pdf 。原来管理
pdf 是用的 org-roam 。本质上，org-roam 就是用 sqlite 数据库做的一个双向链接的管理器。

因为一个 org 文件不能写的很大，这会影响公式的渲染速度。所以最好把笔记写在不同的 org 文件当中。

A complex system that works is invariably found to have evolved from a simple system that
worked. A complex system designed from scratch never works and cannot be patched up to make
make it work. You have to start over with a working simple system. -- Gall's Law

org-roam 用起来很简单，也确实解决了我之前的痛点。

“有效的简单系统，大道至简”——米神的总结非常棒。

<https://www.bilibili.com/video/BV1qV4y1Z7h9> ，非常赞的视频。学数学的果然都是思路清楚而且细腻的。学习，学习，学习。生命不息，学习不止。


### 小米大神的使用流程。 {#小米大神的使用流程}

先在 mydata/notes/ 下新建一个 org 的笔记文件。这个笔记是总览，然后呢，在这个笔记当中加入其它
org 笔记的引用。可以右键打开，也可以 C-c C-o 打开。这分开的 org 就很讲究了，这个 org 当中有支持 org-roam 的标签，也有支持 org-noter 的标签。

跟着米神做一遍，先在 ~/mydata/notes/demo 下创建一个 demo.org 。但是我的 orgmode 文件是包含图片的，那么最好 org 放到一个同名的文件夹当中。文件夹的组织形式就很重要了。因为双链笔记自带查找，那么是不是所有的 org 文件夹都放到一个里面最方便呢？防止文件夹太多，建议还是按照创建的日期来创建文件夹。年，月，日，然后再是主题。

我萌生了做产品的想法。如果真的是好的需求，那可以创业做一个网站。帮助大家方便的了解真正有价值的东西。google 解决的搜索的问题，在全与好之间做了平衡。要想做到有亮点，真的太难了。


### 总结一下 {#总结一下}

米神的实践是很好的，但是我刚开始确实没有看的很明白，有一些概念米神没有比较浅显，系统性的概括和总结。比如 zotfile 的设置，同步的逻辑是什么；又比如米神笔记是如何管理的。知识库最核心的部分是哪个文件夹。本地的笔记是不是通过 webdav 或者坚果云同步的？不是的话是用 git 同步的吗？

我认为应该也是 webdav 进行同步的，现在我还没有搞清楚是如何做到的。这个知识库我花了很长时间才逐渐理解。不过我觉得这个是十分值得的。一定会受用终生！！！


## emacs 使用的包 {#emacs-使用的包}

少数派上一个很厉害的读书的系统：

这个 pdf 助手支持 OCR 。

<https://github.com/yuchen-lea/pdfhelper>

可以大量收集书籍和论文，如果有能力，有时间就可以不断学习。


## 让我的网站可以被国内的搜索引擎搜到 {#让我的网站可以被国内的搜索引擎搜到}

<https://blog.csdn.net/l01011_/article/details/133349392>

百度上搜不到我的博客，这让我觉得稍微有些不开心。虽说写的东西大多质量一般。但是也许我写了一些东西恰好让别人有所启发呢。

<https://www.bilibili.com/read/cv26855009/>

cf 也被屏蔽了，估计国内直接搜是很难访问到了。seo 没办法。


### 什么是dns ？ {#什么是dns}

<https://www.akamai.com/zh/glossary/what-is-dns>

权威服务器的递归服务器。所以，ddns-go 或者 lucky 做的是实现了一个递归服务器。dns 只是做了一个人机接口。


## 什么是 orgmode 的 SETUPFILE {#什么是-orgmode-的-setupfile}

<https://www.youtube.com/watch?v=BHD6SclvbIs>

类似与头文件，可以把一些常用的头写成一个公共的 org 文件，方便引用。


## 折腾与易用性的增强是无穷无尽的 {#折腾与易用性的增强是无穷无尽的}

关键是平衡好折腾与实力增长两者的关系，如果能平衡好，才能更好地成长。


## 家中的电影海报墙解决 {#家中的电影海报墙解决}

这个最终放弃了 plex emby jellyfin 还有 kodi 这些东西。 Nas 只做存储文件，按 IMDB 和
TMDB 的格式要求来改一下目录和文件名即可。qnap 上直接有 Video station 。这个可以将视频流推到其它局域网设备，也可以网页上观看。

电视上用 nova-video-player ，这个软件一直在更新。搜刮速度对比 Video station 和 jellyfin
都快很多。只要开动大脑，一点一点排除文件夹和文件名的问题，最终我所有的电视和连续剧都刮削成功了。


## 百度搜不到我的博客解决 {#百度搜不到我的博客解决}

cloudflare 默认的防火墙规则是对百度的 spider 机器人有阻碍的。所以百度上搜不到我的博客。更别提做什么 SEO 的优化了。

参考了两篇博客，解没解决暂时不知道，但是防火墙的日志确实很快就看到了很多通过的 log ，我想大概率是能解决的吧。

用这两个来设置：

一个是开放所有中国的节点：

<https://www.imydl.com/wp/17236.html>

一个是跳过百度机器人的阻碍：

<https://xblog.cn/106.html>

站长工具，用这个可以查一下：

<https://tool.chinaz.com/baiduspider>


## 总结 {#总结}

至此这篇博客告一段落，在不断的优化过程，逐渐意识到了一件事，一个人可能真正欠缺的东西往往在自己的思维之外。如果能够快速地调整，则是适应能力强的表现。如果能发现自己的天赋，并且确定是社会需要的，那么才有一丝希望可以尝试创业或科研。人到中年逐渐意识到自己一个人有太多的事无能为力。人不是神，平时应该考虑自己目前的情况下能做什么。现实中成长，做不到最好也要做到足够好。
