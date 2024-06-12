+++
title = "1070 窗口黑屏问题分析"
date = 2024-06-12T11:08:00+08:00
lastmod = 2024-06-12T11:49:15+08:00
categories = ["kernel"]
draft = false
toc = true
image = "https://r2.guolongji.xyz/allinaent/2024/06/d3b65553a8f45ae50b1ffe00c35d6dfd.png"
+++

——聂诚、余昇锦、罗朝江

这个分析绐我上了生动的一课，看看别人是怎么分析问题的，一个问题的分析，你和别人会差在哪里？


## 一、问题概述 {#一-问题概述}

1070 较新版本使用过程中 会出现窗口黑块问题，在长时间使用后容易复现，复现一次后，后面出现黑块的概率会变高。

a)复现后桌面现象：

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/06/d3b65553a8f45ae50b1ffe00c35d6dfd.png" >}}

b)目前发现在企业微信打开的时候复现概率最高， 且只要频繁的进行窗口操作（变换、放大缩小，新建窗口等）就会出现黑块。

c)通过抓取xorg 端的pixelmap数据发现窗口是正常的，但是合成后就会显示黑色

合成前：

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/06/2a2f3a98f77f3a2470ce2a69f7f0a807.png" >}}

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/06/4bc793afb71433db74c37cf2e0578162.png" >}}

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/06/ffbaee08f6f2c1844e4f9d2108979f43.png" >}}


## 二、黑色窗口原因 {#二-黑色窗口原因}

通过北京窗管那边同事对kwin分析定位到是合成路径中 glXCreatePixmap失败，但是kwin中的代码并没有对返回值进行错误处理，继续合成才产生的黑屏。

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/06/b65b70fa3040d10680606abf8f9df4cc.png" >}}

分析代码调试kwin，创建pixmap失败的原因是申请的xid 冲突（申请的xid 对应的resource 有值）

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/06/c525c0d3dd126169ee6b0125c9f35901.png" >}}


## 三、xid 冲突分析 {#三-xid-冲突分析}

a)Xid 申请的原理如图：

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/06/7bf5b9ddda64e44395ab6da9ac334d1d.png" >}}

客户端通过Xallocid 申请id时，如果id没有用完则默认+1， 如果id不够了则向xserver 申请新的区域，xorg这边收到请求后使用算法检索一个没有使用过的连续区域返回。（一般区域大小为0x1fffff ，可以使用0x1fffff这么多资源，用完后重新向xorg 申请。）

b)一般短时间内不会用完，所以走左边流程直接++，

c)只有在客户端申请AddResource后，xorg 才会记录xid 已使用。

d)当xid 区域使用完， 向xorg申请新的区域时 会存在一个上游已知bug：线程1 向xorg 申请xid 区域且还没申请AddResource时， 线程2这时又去申请xid区域，此时返回的区域是一样的，会存在xid冲突。

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/06/04ef8e94db2405de612445140c89cac0.png" >}}

上游目前没有解这个bug，因为这里存在一个不可能：线程1申请xid区域到申请addresource 期间有0x1fffff多个可用窗口，不可能那么快用完。

只有上游这个bug才会导致xid冲突，最终导致创建pixmap失败而黑屏。但是是什么应用能这么快使用完这个窗口区域？

通过调试发现：正常申请xid 区域时， 返回的区域长度一般都是 0x1fffff 长，但是出现问题后返回的区域都是 1、或者2。

如果区域大小为1的时候，就很容易触发上游的bug： 线程1 申请xid，xid不够向xorg 申请xid 区域，还没来的及AddResource，此时线程2也申请xid，但是xid的可用数量不够，也去申请xid区域，那线程2获取的xid区域和线程1 是一样的，这个时候就有xid 冲突，后面就会导致创建pixmap失败，导致kwin黑屏。


## 四、为什么xserver 返回的xid区域变小了？ {#四-为什么xserver-返回的xid区域变小了}

Xserver 通过hash 桶来存储每个客户端的 资源，出现问题时发现 kwin客户端使用了 41111多个资源， 而其他客户端使用的资源数量很少，打印展开发现这41111多个资源的type=48 （damage类型），有4w多个 damage类型的资源都在

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/06/38f3f2f4a512eb3f3c0680266bc9673e.png" >}}

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/06/849104bde9415529f21e94b6ce719ee2.png" >}}

调试发现kwin 有的窗口（如unmanaged的窗口）存在资源泄露， 申请了资源，但是没有释放资源。

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/06/baabda8803f8b38f0f2d5ea50ca772e8.png" >}}

最终定位到是 有一处代码注释掉了？

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/06/cb96e3a48977508709b06d856f63c4be.png" >}}

在xorg 申请资源的时候 每个客户端可以申请的资源大小为 0x1fffff ， 明显 41111 远小于这个值，为什么xorg 最后返回的区域长度只有1 或者2 ，很小

分析xorg 申请xid区域的算法发现原因和kwin的资源泄露有关：

正常流程下，xorg 会返回一个连续连续区域，（不一定是最大，只要找到了就返回）

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/06/928bb0f411c43c239b82ae4ad9620fc7.png" >}}

正常使用情况下 都是和进程pid类似，慢慢增长，只有id数值达到max 才会向xorg申请新的，此时kwin之前申请id 没有释放对应的资源，存在id泄露，那么肯定不会申请到这个id，但是这个id会占一个位置，而有的资源又不存在泄露，就存在下面一个场景：

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/06/6238eb473d747b975d175f0d939d4485.png" >}}

Xorg 这不的资源桶就因为泄露变成这种类型，使用时间越久就越稀疏，所以很容易申请到长度为1的区域，触发上游bug，导致pixmap创建失败。

打印xorg 维护的资源信息如下：

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/06/bc7752142fba3241253b0cb8d69fd761.png" >}}


## 总结： {#总结}

1、窗口使用发黑的原因是因为kwin 这边没对glcreatepixmap 返回值做异常处理，导致后续流程异常

2、Glcreatepixmap 创建失败原因是因为xserver一个上游bug，而刚好kwin的资源泄露加大了复现概率。

3、Xserver 这边对id 的申请算法比较无脑，找到了就返回，且xid 和 客户使用的资源没办法保证原子性，所以才有上游这个bug。
