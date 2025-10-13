+++
title = "一个usb导致开机流程无限阻塞的问题"
date = 2024-04-24T16:18:00+08:00
lastmod = 2025-10-13T13:31:47+08:00
categories = ["kernel"]
draft = true
toc = true
image = "https://r2.guolongji.xyz/allinaent/2024/06/92a1feeab471b12646b9c76edccc1546.jpg"
+++

## 问题背景 {#问题背景}

文韬大佬做的分析，在这里做一下记录。

今年 3.20 的时候，前场报告了一个开机卡死问题：（严重程度 2,优先级 2）：

BUG #248175 UBXC004802 华为擎云 W515 1060U3 华为 w515 前置 usb 口插入两个 u 盘后开机卡在 uos 的 log 界面无法进入系统 - 桌面专业版 V20 - 禅道

大概的现象是：

-   前置 usb 口插入多个 u 盘，启动可能会卡死。
-   插入后置 usb 口，没有问题。（所以看起来像是 hub 相关，而非 u 盘原因）

3.25 的时候邵阳做了初步的分析：（见 pms 单）

-   异常的时候，U盘干扰了磁盘控制器，日志中缺了一部分，像是根本就没有落盘。
-   根据华为复现日志分析，异常的时候，U盘 mount 异常，ufs 磁盘没有完成 mount，拔掉 U 盘后面就正常了。磁盘没有正常挂的话，后续都不会走的。

上面的分析没有什么问题，描述得很准确，u盘并没有正常完成 mount，拔掉 u 盘之后，系统启动流程就正常往下走了。——换而言之，系统并没有卡死，而是阻塞在开机的某个流程里了。

后面问题单应该经过一些部门间的流转讨论，最后在 4 月初的时候，邵阳在问题复现时，抓到了详细的日志，联系到了我，做了进一步的根因分析。


## D 状态日志以及分析 {#d-状态日志以及分析}

首先这是一个在软件卡死死锁问题里，一个非常好用的抓取日志的方式：通过 sysrq 打印出所有处于 D 状态的进程及其堆栈。

操作上很简单：

```nil
# 可以直接修改 /etc/sysctl.conf 以持久有效
sysctl kernel.sysrq=1
echo w > /proc/sysrq-trigger
```

下面的日志涉及 4 个进程，我们挨个进行分析：（技术向，不感兴趣的同事跳过此节）


### kworker: {#kworker}

```nil
[26676.730957s][pid:0,cpu0,in irq,9]Workqueue: events_unbound async_run_entry_fn
[26676.730957s][pid:0,cpu0,in irq,0]Call trace:
[26676.730987s][pid:0,cpu0,in irq,1] __switch_to+0xe8/0x130
[26676.730987s][pid:0,cpu0,in irq,2] __schedule+0x378/0xb38
[26676.730987s][pid:0,cpu0,in irq,3] schedule+0x38/0xa0
[26676.731018s][pid:0,cpu0,in irq,4] io_schedule+0x18/0x38
[26676.731018s][pid:0,cpu0,in irq,5] wait_on_page_bit+0x13c/0x210
[26676.731018s][pid:0,cpu0,in irq,6] do_read_cache_page+0x1dc/0x368
[26676.731018s][pid:0,cpu0,in irq,7] read_cache_page+0x10/0x18
[26676.731048s][pid:0,cpu0,in irq,8] read_dev_sector+0x2c/0xb0
[26676.731048s][pid:0,cpu0,in irq,9] read_lba.isra.0+0xc8/0x198
[26676.731048s][pid:0,cpu0,in irq,0] efi_partition+0xd0/0x630
[26676.731079s][pid:0,cpu0,in irq,1] check_partition+0x110/0x218
[26676.731079s][pid:0,cpu0,in irq,2] rescan_partitions+0xc4/0x388
[26676.731079s][pid:0,cpu0,in irq,3] __blkdev_get+0x368/0x4b0
[26676.731109s][pid:0,cpu0,in irq,4] blkdev_get+0x138/0x328
[26676.731109s][pid:0,cpu0,in irq,5] __device_add_disk+0x20c/0x460
[26676.731109s][pid:0,cpu0,in irq,6] device_add_disk+0x10/0x18
[26676.731140s][pid:0,cpu0,in irq,7] sd_probe_async+0xd0/0x188
[26676.731140s][pid:0,cpu0,in irq,8] async_run_entry_fn+0x40/0x160
[26676.731140s][pid:0,cpu0,in irq,9] process_one_work+0x208/0x498
[26676.731170s][pid:0,cpu0,in irq,0] worker_thread+0x40/0x440
[26676.731170s][pid:0,cpu0,in irq,1] kthread+0x154/0x160
```

可以看到它的 comm 信息是 workqueue: events_unbound，这是一个内核里非常常用的 wq，比如典型的 async_schedule()底下就是使用了它。在堆栈里我们可以看到 work 的主函数是 async_run_entry_fn
，实际上它仅仅是 async-work 框架里的一个 wrap 函数，使用者真正传入的是内部的 sd_probe_async。——大家感兴趣的可以在 4.19 内核里搜索 async_schedule()系列函数。

sd_probe_async()是在 sd_probe()里被 queue 到 wq 里去的，是实际干活的函数。在它内部会完成 disk 相关的各种初始化工作，其中一个非常重要的部分就是扫描磁盘的分区，为每一个分区建立一个块设备。——还记得我们之前提到过的，磁盘的分区表扫描是在内核里完成的，其他的磁盘格式，比如 fs、lvm、luks 等等都是在用户空间完成的解析。

看上面的堆栈，可以看到它在扫描分区表，目前在尝试 efi 格式（它内部相当于是一个枚举循环，一个一个格式试）。而它在读取 lba 的时候（可以猜到很有可能是读第一个扇区），已经成功完成了 io 的申请，现在在 page 上等待。

所以最终停留的位置是：wait_on_page_bit()。——在等待哪个 bit？page 的 lock bit。当 page
读取完成后，会在从中断上来的 io 完成路径里，将其唤醒。


### usb-storage {#usb-storage}

如果是直接连接的 sata 盘，那可能就是在上面的 kworker 里，将 bio 转换为 request，通过 scsi 驱动就发出去了。但是如果是 u 盘呢？相当于 scsi 的后端是 usb storage 设备，最终 bio/request 要通过 usb 的数据包发出去，要转交给 usb 的相关内核线程来处理，所以我们可以看到下面的 D 进程：

```nil
[26676.731536s][pid:0,cpu0,in irq,9]usb-storage     D    0   408      2 0x000000
08
[26676.731567s][pid:0,cpu0,in irq,0]Call trace:
[26676.731567s][pid:0,cpu0,in irq,1] __switch_to+0xe8/0x130
[26676.731567s][pid:0,cpu0,in irq,2] __schedule+0x378/0xb38
[26676.731567s][pid:0,cpu0,in irq,3] schedule+0x38/0xa0
[26676.731597s][pid:0,cpu0,in irq,4] schedule_timeout+0x26c/0x450
[26676.731597s][pid:0,cpu0,in irq,5] wait_for_common+0x140/0x168
[26676.731597s][pid:0,cpu0,in irq,6] wait_for_completion+0x14/0x20
[26676.731628s][pid:0,cpu0,in irq,7] usb_sg_wait+0x13c/0x190
[26676.731628s][pid:0,cpu0,in irq,8] usb_stor_bulk_transfer_sglist.part.3+0x94/0x130
[26676.731628s][pid:0,cpu0,in irq,9] usb_stor_bulk_srb+0x48/0x80
[26676.731658s][pid:0,cpu0,in irq,0] usb_stor_Bulk_transport+0x110/0x358
[26676.731658s][pid:0,cpu0,in irq,1] usb_stor_invoke_transport+0x38/0x548
[26676.731658s][pid:0,cpu0,in irq,2] usb_stor_transparent_scsi_command+0xc/0x18
[26676.731658s][pid:0,cpu0,in irq,3] usb_stor_control_thread+0x1d4/0x268
[26676.731689s][pid:0,cpu0,in irq,4] kthread+0x154/0x160
[26676.731689s][pid:0,cpu0,in irq,5] ret_from_fork+0x10/0x1c
```

通过它中间的函数名字，usb_stor_invoke_transport()，大概就可以猜到它的功能：真正地发起 usb 的 io 传输，并等待它的完成。

可以猜到，当它完成后（在 wait_for_completion 中返回），它将会设置相关 page 的 lock bit，唤醒上面的 sd probe worker，让一切得以继续。而在我们的问题里，它阻塞了，它在等待的 io 一直没有得到回应，所以导致了一系列的执行流的阻塞。

到这里我们可以总结：它是阻塞问题的根源所在。

内核线程自己阻塞了没关系，顶多就是这个 u 盘没法完成分区扫描，理当不会造成任何可见影响。那又是如何导致开机阻塞的呢？


### lvm {#lvm}

```nil
[26676.731689s][pid:0,cpu0,in irq,6]lvm             D    0   500      1 0x000000
00
[26676.731719s][pid:0,cpu0,in irq,7]Call trace:
[26676.731719s][pid:0,cpu0,in irq,8] __switch_to+0xe8/0x130
[26676.731719s][pid:0,cpu0,in irq,9] __schedule+0x378/0xb38
[26676.731750s][pid:0,cpu0,in irq,0] schedule+0x38/0xa0
[26676.731750s][pid:0,cpu0,in irq,1] schedule_preempt_disabled+0x20/0x38
[26676.731750s][pid:0,cpu0,in irq,2] __mutex_lock.isra.1+0x1e4/0x540
[26676.731750s][pid:0,cpu0,in irq,3] __mutex_lock_slowpath+0x10/0x18
[26676.731781s][pid:0,cpu0,in irq,4] mutex_lock+0x38/0x40
[26676.731781s][pid:0,cpu0,in irq,5] __blkdev_get+0x7c/0x4b0
[26676.731781s][pid:0,cpu0,in irq,6] blkdev_get+0x138/0x328
[26676.731811s][pid:0,cpu0,in irq,7] blkdev_open+0x8c/0xa0
[26676.731811s][pid:0,cpu0,in irq,8] do_dentry_open+0x110/0x3a0
[26676.731811s][pid:0,cpu0,in irq,9] vfs_open+0x28/0x30
[26676.731842s][pid:0,cpu0,in irq,0] path_openat+0x30c/0x13c8
[26676.731842s][pid:0,cpu0,in irq,1] do_filp_open+0x78/0xf0
[26676.731842s][pid:0,cpu0,in irq,2] do_sys_open+0x170/0x278
[26676.731842s][pid:0,cpu0,in irq,3] __arm64_sys_openat+0x20/0x28
[26676.731872s][pid:0,cpu0,in irq,4] el0_svc_common+0x90/0x158
[26676.731872s][pid:0,cpu0,in irq,5] el0_svc_handler+0x6c/0x88
[26676.731872s][pid:0,cpu0,in irq,6] el0_svc+0x8/0xc
```

首先，为什么 lvm 的这个流程会阻塞？可以看到它在 open，穿过 vfs 走到了 blkde_open，毫无疑问它是在打开 devtmpfs，也就是/dev/sda 之类的设备。

等等，我上面不是还在做 disk 的分区扫描吗？你怎么就打开设备了？这是因为内核会将整个 disk 作为/dev/sda，然后将扫描到的分区作为 sda1,sda2,……而且它的流程是先添加了 disk 的 device（在它的流程里就会将/dev/sda 添加到 devtmpfs），然后再去做分区扫描，然后因为 u 盘 io 问题而阻塞……

也就是说，它会导致这样一个局面：/dev/sda 可见了，但是其实它是不可访问的，它还在做分区扫描。

那如何防止有人访问它呢？内核在做分区扫描之前，持有了 disk/bdev 相关的 mutex。而其他任何人想要 open 这个设备，都需要先持有一下这个 mutex。

所以，lvm 被阻塞了……（让我们先不要讨论内核的这个时序是否合理，其实它在这个过程里 suspend 了这个磁盘的 udev 事件，所以如果你是正常地通过 udev 的通知然后再去访问设备，是不会有问题的~oh yeah!）

ok，那下一个问题是，lvm 为什么要去 open 这个设备？我们留给下一节，先把 D 进程看完。


### scsi error handler {#scsi-error-handler}

```nil
[26676.731414s][pid:0,cpu0,in irq,5]scsi_eh_4       D    0   406      2 0x000000
08
[26676.731414s][pid:0,cpu0,in irq,6]Call trace:
[26676.731445s][pid:0,cpu0,in irq,7] __switch_to+0xe8/0x130
[26676.731445s][pid:0,cpu0,in irq,8] __schedule+0x378/0xb38
[26676.731445s][pid:0,cpu0,in irq,9] schedule+0x38/0xa0
[26676.731475s][pid:0,cpu0,in irq,0] schedule_preempt_disabled+0x20/0x38
[26676.731475s][pid:0,cpu0,in irq,1] __mutex_lock.isra.1+0x1e4/0x540
[26676.731475s][pid:0,cpu0,in irq,2] __mutex_lock_slowpath+0x10/0x18
[26676.731475s][pid:0,cpu0,in irq,3] mutex_lock+0x38/0x40
[26676.731506s][pid:0,cpu0,in irq,4] device_reset+0x20/0x50
[26676.731506s][pid:0,cpu0,in irq,5] scsi_eh_ready_devs+0x558/0xad8
[26676.731506s][pid:0,cpu0,in irq,6] scsi_error_handler+0x488/0x5c8
[26676.731536s][pid:0,cpu0,in irq,7] kthread+0x154/0x160
[26676.731536s][pid:0,cpu0,in irq,8] ret_from_fork+0x10/0x1c
```

eh 的意思就是 error handler，这是 scsi 层的基础设施。可以看到它在尝试做 device_reset，然后它自己也被阻塞了……


## lvm2-monitor.service {#lvm2-monitor-dot-service}

邵阳提供了另外的一份很重要的日志：在拔掉 u 盘，系统启动流程继续往下走完之后，用
systemd-analyze 抓取了各个服务的执行时间，然后就看到了执行了 7 天的 lvm2-monitor.service。

service

```nil
[Unit]
Description=Monitoring of LVM2 mirrors, snapshots etc. using dmeventd or progress polling
Documentation=man:dmeventd(8) man:lvcreate(8) man:lvchange(8) man:vgchange(8)
Requires=dm-event.socket
After=dm-event.socket dm-event.service
Before=local-fs-pre.target shutdown.target
DefaultDependencies=no
Conflicts=shutdown.target

[Service]
Type=oneshot
Environment=LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES=1
ExecStart=/usr/sbin/lvm vgchange --monitor y
ExecStop=/usr/sbin/lvm vgchange --monitor n
RemainAfterExit=yes

[Install]
WantedBy=sysinit.target
```

可以看到它最终会执行 lvm vgchange --monitor y 的命令，而且是和 dmeventd 相关的。

在依赖关系上，它在 dm-event 之后，在 local-fs.target 之前。而且会被 sysinit.target 所依赖。

lvm2-monitor/dmeventd

这个服务是做什么的？dmeventd 是什么？

内核的 device mapper 提供了 event 机制，用户进程可以通过 ioctl 去等待某个设备的某个事件。典型的使用场景是 dm-snapshot，因为它会有存储空间超限的问题，所以如果可以在阈值到来时得到通知，及时对相关的 dm 设备扩容，那岂不是很好？同理还有 dm-thin，也就是做超卖的时候，也需要关注是否空间要超限了。

所以 dmeventd 就是做这个事情的，负责所有 dm 设备的 event 事件的等待和处理。它相当于这个功能的 server 端。

而 lvm2-monitor.service 呢，则相当于是 client 端，它会通过读取 lvm.conf 这个文件的配置，确认要关注哪些事件，将其作为请求发送给 dmeventd。

在实现上，它也是 lvm vgchange 命令的一部分，而 lvm 命令在通用流程上，就是会扫描 sys、udev、dev 下的各种设备设备，open 它们，stat/fcntl 确认它们的相关属性比如设备大小，甚至还会读取它们的前 128K 来确认是不是真的 lvm pv。

而当它扫描到/dev/sda 时，它在 open 时就阻塞了，进而阻塞了整个的开机流程。

是否可以规避？

从系统角度而言，可以认为这是不合理的：

-   u 盘 hub 不应该挂死，那是当然的，应该 fix。
-   但即使 u 盘有问题，也不太应该影响系统开机流程啊……

而之所以会阻塞，是因为以下几点撞在了一起：

-   disk 初始化时，会先创建/dev/sda，再扫描分区，然后在 io 中卡死，且此时持有了 mutex。
-   lvm 会直接扫描 dev 下的设备，尝试 open 时因为等待 mutex 而进入 D。
-   sysinit.target 依赖于 lvm 服务。

内核的 disk 初始化流程可以改吗？那是在最里面的 device_add()……emmm。

lvm 的流程好改吗？这是 lvm 的通用流程，emmm……

lvm2-monitor 这个服务呢？它目前的 type 是 oneshot，所以会阻塞等待，如果是 simple 就不会有这个问题了（simple 只要启动了就返回，不需要等待它执行完成）。——我不知道是不是可，所以发了邮件问上游。

上游维护者的意见

link：

lvm2-monitor.servcie block boot process due to bad storage device

<https://lore.kernel.org/lvm-devel/0df2eac5-c8ad-4e32-ac06-248b7edb8858@redhat.com/T/#t>

我的提问：

```nil
\* lvm2-monitor.servcie block boot process due to bad storage device

Hi,

If a device's IO does not respond, it will block in the path of
partition scanning. But at this point, it has already created the
part0, like /dev/sda, in devtmpfs, but the mutex of the device has been
held by the partition scanning code, so all processes attempting to
open it will enter a wait.

lvm scans and opens block devices under /dev/ during startup, so if
there are any bad devices mentioned above, lvm2-monitor.server will be
blocked, and because its type is oneshot, it will block the boot
process, even if the poor device is not using lvm.

May I ask if there is a way to avoid it? For example, can the
type of this service be changed from oneshot to simple? Or is there
any other better way?

Thanks!
```

Zdenek 的回复：

```nil
Hi

We are aware of this weakness and we are thinking about the solution for this.

However - for booting -  you should not be actually monitoring things in ramdisk

(lvm.conf should use  monitoring=0)  - so the boot is monitore-less.


Once system is switch to rootfs - monitoring should be enabled with

vgchange --monitor y  (if enabled in /etc/lvm/lvm.conf)


But we need to rethink some caching strategy - as the code for plain lvm2
command is now causing some troubles within dmeventd instance.
```

因为我在上面表述为 boot process，所以 Zdenek 可能误以为我是卡在了 initramfs 阶段，其实我是卡在了 systemd 阶段，也就是已经切换到 rootfs 了。

同时他们似乎也遇到了类似的问题，所以在关注这一块，但是貌似还没有具体的解决办法。而且他最后的表述我没有看太懂……


## 结论 {#结论}

ok，到这里，我们大概清楚了这个问题的来龙去脉，以及我们能做什么。——事实上我们能做的非常有限，我现在也不太具备去给 lvm 的这种问题做 fix 的能力。（也许如果以后有时间的话可以深入研究一下，其实这样的点是参与上游最好的契机呀！这是维护者也在头疼的问题……但确实好难哈哈哈，除非很了解相关代码，不然都不知道怎么动手）

所以，那怎么办呢？

push 厂商吧先……

这个问题，要知道什么是 D 死锁，什么是 R 死锁。

<https://blog.csdn.net/wylfengyujiancheng/article/details/89636183>

为什么会存在开关中断的情况出现？

<https://blog.csdn.net/Int321/article/details/108261053>
