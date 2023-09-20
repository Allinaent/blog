+++
title = "内核一次日志问题的分析"
date = 2023-09-18T21:01:00+08:00
lastmod = 2023-09-18T21:42:31+08:00
tags = ["kernel", "linux"]
categories = ["technology"]
draft = false
toc = true
+++

## 文韬分享，一次日志分析问题，20230810 {#文韬分享-一次日志分析问题-20230810}

{{< figure src="/ox-hugo/img_20230918_210808.png" >}}

这次分享呢我认为可能有一点收获。

关抢占，原子上下文。在 kernel/sched/core.c 当中。不允许别人打断我的执行。关抢占之后不允许调度。但是中断是可以的。关抢占之后不用在加锁。不能防止 cpu 之间的并行。必须要执行完。不能够托太久。

关中断则不再允许中断的执行。preempt_count。

CONFIG_PREEMPT_RCU，这个是个配置导致的一个 bug。内核不会有缺页异常。内核页表在 0 号进程。所有的更改都是改 0 号如果改进程的第一个页，其它进程会对比一下和 0 号进程页表第一个页，这时会报 do_page_fault。但是新的内核好像这个
case 取消了。好像增加了一个新的 case，改权限位。不是因为真正的缺页，只是改一些 flag，做一些同步的事。和用户态的缺页异常是不一样的。不会像用户态的缺页异常从硬盘获取到内存当中去。内核段是不会交换出去的。内核和用户态是不太一样的。这一点要清楚，让我理解了更底层的一些东西。

首先，page 的大数组去找，不会出现在可回收的链表里面。vm 的也不可以交换出去。

通过 path_openat 这一行。看到了什么？+0xC0，而另一个 do_flip_open+0x78/0xf0，这一行，这个个指令是 core 指令的位置吗？不是，是 core 的下一行指令，函数调用约定，这个和架构相关。从数字到汇编到源代码来看一下。

用 gdb 进去。gdb vmlinux。gdb 下的 ptype 函数。用 p &amp;(((struct nameidata \*)0)-&gt;flags)。

用 p &amp;(((struct nameidata \*)0)-&gt;last_type)。

python3 中直接输入：0x30，可以直接显示出来十进制的数。

这是流程化的，工业化的一套流程。挺好用的哈。negitive 的 dentry 的话，dir-&gt;d_inode 就是空的。有正面分析的能力，本来此处就可能是空的。这块这文件系统的子系统，比较熟悉。lru，之类的东西。

去一个网站 bootlin，看 4.19 最新的代码。对比一下 fs/namei.c，上游的代码是个什么样子的状态。和我们的代码不一样，再切到 5.4。上游的代码是最新的。去 linux stable git。github 中的 gregkh/linux 切到 4.19 分支。直接开一下
blame。直接找到了 patch。上游的代码有新的 patch 修复一些的问题。

./scripts/faddr2line vmlinux path_openat+0xc0/0x13c0，非常非常的准，基于 gdb 的反汇编，这个工具是非常的准的。厉害啊。直接复制进去，从 log 直接定位到出错的代码的位置。正向分析其实就没有什么用处了。

disa 命令，0x78，开一个 python，这个是十进制的 120。从汇编反汇编：disa /s path_openat，看到了吧，gdb 就是这么的强大。help disa，可以看到 gdb 的好多用法。这个函数被内联了，有时候 call_trace 显示的是不同的函数名。

调用 might_sleep，mutex_lock()，也会检查这个。这个是个预警的机制。通过一些好用的工具。

assert(!in_atomic\*())，空指针引发缺页。balabala。rcu 为什么不等于零呢？在 do_flip_open 当中，确保在查的时候不会有人把他删掉。path_init 中就会用 rcu 的读锁。vmlinux 的解析是一个很复杂的东西。
