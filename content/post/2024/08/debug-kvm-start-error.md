+++
title = "Intel机器510内核环境虚拟机安装完成后无法启动根因——另附庖丁解牛13式"
date = 2024-08-19T09:34:00+08:00
lastmod = 2025-10-13T13:03:26+08:00
categories = ["kernel"]
draft = true
toc = true
image = "https://r2.guolongji.xyz/allinaent/2024/06/92a1feeab471b12646b9c76edccc1546.jpg"
+++

uos 的庖丁解牛13 招：

[下载链接](https://r2.guolongji.xyz/%E5%BA%96%E4%B8%81%E8%A7%A3%E7%89%9B%E5%8D%81%E4%B8%89%E5%88%805.13.pdf)

这部分有时间总结一下，调试能力确实重要。


## 环境 {#环境}

```nil
[root@localhost ~]# uosinfo
#################################################
Release:  UOS Server release 20 (kongzi)Kernel :  5.10.0-46.31.uelc20.x86_64Build  :  UOS Server 20 (1060a) 20231130 amd64
#################################################

```


## 问题现象 {#问题现象}

在1060u1a版本5.10内核系统上安装虚拟机，安装完成后，重启出现如下现象，虚拟机起不来。

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/08/002651624c0ffe43da5c197ab06b0dbf.png" alt="Caption not used as alt text" caption="<span class=\"figure-number\">图 1: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/08/a594f0141d058c646597cd5577f76f75.png" alt="Caption not used as alt text" caption="<span class=\"figure-number\">图 2: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}


## 复现方法 {#复现方法}

按照pms bug单描述的复现方法步骤如下：

1、部署虚拟化环境

2、virt-manager安装虚拟机，具体安装步骤如下：

1）UEFI固件选择如下：

A版本：

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/08/8433d84ae168be126cf241603991a80c.png" >}}

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/08/be18877847ee742dd07a498bb4cddbec.png" alt="Caption not used as alt text" caption="<span class=\"figure-number\">图 3: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/08/156913582c073d7ac3ca5d453e92b50a.png" alt="Caption not used as alt text" caption="<span class=\"figure-number\">图 4: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/08/8a9783de1fa436c20824b517a126d279.png" alt="Caption not used as alt text" caption="<span class=\"figure-number\">图 5: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}

3、虚拟机安装完成以后，虚拟机无法启动，具体现象如下：

legacy模式-重启-选择510内核进系统--之后报错如下：

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/08/002651624c0ffe43da5c197ab06b0dbf.png" alt="Caption not used as alt text" caption="<span class=\"figure-number\">图 6: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}

UEFI模式-重启-选择510内核进系统--之后报错如下：

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/08/a594f0141d058c646597cd5577f76f75.png" alt="Caption not used as alt text" caption="<span class=\"figure-number\">图 7: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}

4、虚拟化对比测试如下：

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/08/d4f739a14dc41e6cefff8cb41379ed41.png" alt="Caption not used as alt text" caption="<span class=\"figure-number\">图 8: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}


## 日志分析 {#日志分析}

从问题现象我们可以看到，内核出现了启动初期阶段，报了panic，如下图：

<div link class="fancy">

<img src="https://r2.guolongji.xyz/allinaent/2024/08/a46967e37804817e5e059c377e7330f2.png" alt="Caption not used as alt text" link="t" class="fancy" width="900" />
往上看可以看到最后调用的函数栈，最后函数位置 fpu\__init_cpu_xstate+0x63 ，这个函数看着是浮点state初始化,
看一下这个函数的内容如下：

</div>

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/08/b8fd8dc0cf3311caaccd088a1adf2058.png" >}}

可以看到基本都是操作寄存器相关操作，我们反汇编看一下具体死在了哪行代码:

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/08/8d619b135b415f9385e7d12610237586.png" alt="Caption not used as alt text" caption="<span class=\"figure-number\">图 10: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}

可以看到正好是xsetbv指令，我们将xsetbv设置的值打印出来可以看到目前出现问题时，他的值是0x202e7，该指令是将EDX:EAX中的值写入ECX指定的XCR。这时候就需要看看intel手册关于这条指令的详细信息了，这个值是否有异常。

在Intel® 64 and IA-32 Architectures Software Developer’s Manual, Volume 1的13.3章节描述了关系XSTATE的相关内容：

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/08/566ecd9010581012efccd8d72a97a399.png" alt="Caption not used as alt text" caption="<span class=\"figure-number\">图 11: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}

可以看到，当XCR0的bit18-17是01,10时候会报GP错误，而0x202e7的bit18-17确实是10，到现在报GP问题根因找到了，接下来的问题就是找到为什么EDA:EAX的值低32bit的bit18-17不是00或者11了。

下面我们梳理一下，GUEST、HOST、QEMU交互流程，如下图：

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/08/61ea0931fa1a6a7071ae74cc71b34b11.png" alt="Caption not used as alt text" caption="<span class=\"figure-number\">图 12: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}

接下来我们需要调试一下②流程：

执行：gdb /usr/libexec/qemu-kvm，进入gdb后执行设置参数，命令如下：

```nil
set args -smp 4 -m 4096 -cpu host,migratable=on -machine pc-i440fx-rhel7.6.0 -enable-kvm -kernel /root/bzImage -append
"console=ttyS0,115200 loglevel=8 nokaslr" -nographic -initrd ./myrootfs.cpio.gz
```

然后打断点到main、kvm_arch_get_supported_cpuid：

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/08/72df934c98b435598cbdb4a79d463292.png" >}}

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/08/483f848a89a3a9c89dc13f5e44cbdf25.png" alt="Caption not used as alt text" caption="<span class=\"figure-number\">图 13: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}

```nil
bpftrace -e 'kprobe:kvm_arch_vcpu_ioctl {printf("ioctl args: flip %x, ioctl %x, arg %lx\n", arg0, arg1, arg2);}'
```

开始debug，执行run，观察function，当等于13时候，n单步执行，观察，kvm_ioctl返回结果：

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/08/64fba0b39741081fae8326aa39c2ad0f.png" >}}

查看此时的host kvm ioctl，没有抓到任何信息，由此可见，是qemu:kvm_ioctl-&gt;host出了问题，那接下来需要看一下qemu的kvm_ioctl使用的fd是否合host一致，查看代码发现，qemu中kvm_ioctl使用的fd是open /dev/kvm时候创建的，如下图：

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/08/275cec134a2ccb48622101879876e691.png" >}}

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/08/337ba188fcf5862fcb7c7b511c540597.png" >}}

下面我们看一下host内核KVM_GET_DEVICE_ATTR所使用的ioctl是否是/dev/kvm

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/08/1f3ed1d6e91fb6019671317b7a0bcfe7.png" >}}

从代码可以看出，KVM_GET_DEVICE_ATTR属于kvm_vcpu_ioctl的，怎么会这样呢，上游搞错了？于是看了这几行补丁的提交记录，发现是回合anolis的commit，而anolis的这个补丁也是回合上游的补丁，最后发现是anolis回合上游补丁错误导致的。

anolis回合上游补丁部分代码如下：

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/08/9826a62b62d74966d2789f9f75cf7399.png" >}}

实际上游补丁部分代码如下：

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/08/9fa3c6c59ddf3fccda1ace62628898b5.png" >}}

可以看到KVM_GET_DEVICE_ATTR命令应该加到kvm_arch_dev_ioctl下面，而不是kvm_arch_vcpu_ioctl里，修改代码合入修正补丁，再次测试发现，host dev_ioctl可以抓到qemu发送的KVM_GET_DEVICE_ATTR(0xAEE2)了，如图：

{{< figure src="https://r2.guolongji.xyz/allinaent/2024/08/f688fe246b99fc947a333eb9173fde02.png" >}}

此时虚拟机可以正常启动了。


## 解决方案 {#解决方案}

由于anolis在回合上游补丁时候，补丁与上游补丁不一致，导致qemu与kvm交互异常，因此最终解决方案如下：

修复回合上游补丁32eb80465a51 ("KVM: x86: add system attribute to retrieve
full set of supported xsave states"的错误，将kvm_dev_ioctl命令KVM_GET_DEVICE_ATTR由kvm_arch_vcpu_ioct()l函数移动到kvm_arch_dev_ioctl()函数里。


## 参考资料 {#参考资料}

1、<https://gitee.com/anolis/cloud-kernel/pulls/1532>

2、A-32 Intel Architecture Software Developer's Manual Volume.3:System Programming Guide

3、kernel-server 5.10 source code
