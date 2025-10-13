+++
title = "从欧拉 510 内核中找到调度低延时的补丁"
date = 2024-07-29T17:30:00+08:00
lastmod = 2025-10-13T13:05:45+08:00
categories = ["kernel"]
draft = true
toc = true
image = "https://r2.guolongji.xyz/allinaent/2024/06/92a1feeab471b12646b9c76edccc1546.jpg"
+++

这个问题是从欧拉的内核当中找到金融相关低延时的补丁。


## 补丁整理 {#补丁整理}

（1
0002-loop-use-lo-lo_disk-for-kobject_uevent.patch

这个是 loop_device 的 bugfix 与低延时无关。

（2
0009-driver-core-Fix-kabi-broken.patch

这个是防止 kabi 被破坏的一个修改，与低延时无关。

（3
0011-iomap-update-ki_pos-a-little-later-in-iomap_dio_comp.patch

open 一个文件的时候带了 O_SYNC,后续所有的 io 在返回用户态的时候都会同步的把数据和元数据落盘上述说的这个现象在 ext4 的 dio 切到 iomap 后，元数据不再同步刷新，进而导致如果出现断电时，会导致数据落盘，但是元数据没落盘，出现数据丢失现象最主要的原因是因为当前 sync 的时机点不对，此时的文件 size 还没更新

与低延时无关

（4
0012-ext4-properly-sync-file-size-update-after-O_SYNC-dir.patch

同 0011 补丁一样

与低延时无关。

（5
0013-ext4-fix-warning-in-ext4_dio_write_end_io.patch
同 0011 0012 补丁一样

与低延时无关。

（6
0015-memcg-fix-input-of-try_to_free_mem_cgroup_pages.patch

修改异步回收中try_to_free_mem_cgroup_pages入参

与低延时无关。

（7
0022-drm-phytium-Replace-default-efi-fb0-with-dc-fb.patch

飞腾显示相关补丁

与低延时无关。

（8
0024-mm-dynamic_hugetlb-simplify-the-refcount-code.patch

dynamic hugetlb对hpool增加rcu锁保护，解决UAF（Use-After-Free）问题，bugfix

与低延时无关。

（9
0025-mm-dynamic_hugetlb-use-rcu-lock-to-protect-hpool.patch

同0024 补丁一样。

与低延时无关

（10
0030-arm64-mm-Replace-global-variable-in-pbha-with-static.patch

解决PBHA 导致的 lmbench 带宽下降问题。修改的hisi 的PBHA 驱动代码，这个和内存调试有关系。

PBHA 是指 "Probe Based Heap Allocator"，是一种在 Linux 内核中用于动态追踪和调试的技术。它允许开发者在运行时动态地分配和释放内存，同时跟踪和记录这些操作，以帮助分析内核代码中的内存管理问题和性能瓶颈。

在 lmbench 测试期间，观察到bw_mem经历了降低性能8%或更多。为了解决这个问题，将全局具有静态键的变量。

可能和低延时有关系。

（11
0036-sched-fair-Optimize-test_idle_cores-for-SMT.patch

优化 kunpeng 920 test_idle_cores()

update_idle_core（） 仅适用于 sched_smt_present 的情况。但是 test_idle_cores（） 适用于所有机器，即使是那些没有的机器
SMT。

这可能会导致高达 8%+ 的 hackbench 性能损失像昆鹏920这样的机器，没有SMT。 此修补程序删除了冗余 test_idle_cores（）让没有 SMT 的 kunpeng 效率更高。

什么是 SMT ？

在操作系统和计算机体系结构的上下文中，SMT 是 "Simultaneous Multi-Threading" 的缩写，意味着同时多线程。这是一种在处理器设计中使用的技术，旨在提高处理器核心的利用率和性能。

具体来说，SMT 技术允许单个物理处理器核心同时执行多个线程。这意味着每个物理核心可以表现为多个逻辑核心，每个逻辑核心都有自己的寄存器集和执行状态。在这种技术下，多个线程可以并发地在同一个物理核心上运行，共享该核心的执行资源（如指令执行单元、缓存等），从而更有效地利用处理器的资源。

SMT 的主要优势包括：

a.提高处理器利用率：通过在物理核心上同时执行多个线程，可以充分利用处理器的执行单元，减少因资源空闲而导致的性能浪费。

b.增强系统响应能力：在操作系统中，SMT 可以帮助提升多任务处理的效率，尤其是在负载变化和多任务环境下，能够更快速地响应和处理多个线程的请求。

c.优化能效比：相比于传统的单线程执行方式，SMT 在相同功耗下可以达到更高的性能水平，因为它能够更充分地利用处理器资源，减少资源空闲导致的能源浪费。

总体而言，SMT 技术已经被广泛应用于现代处理器设计中，例如 Intel 的超线程技术（Hyper-Threading），
AMD 的 Simultaneous Multi-Threading 技术等，它们在提升处理器性能和效率方面发挥了重要作用。

可能和低延时有关系。

（12
0037-irqchip-gic-v3-Use-dsb-ishst-to-order-writes-with-IC.patch

dsb（ishst） 障碍应该足以对以前的写入进行排序生成 SGI 的系统寄存器，因为我们只需要保证数据对内部可共享域中其他 CPU 的可见性在我们发送 SGI 之前。

编写一个微基准测试来验证对kunpeng920机器有2个（socket）插座，每个插座有2个（die）模具，并且每个芯片有 24 个 CPU，因此系统总共有 2 \* 2 \* 24 = 96 CPU。通过此基准测试可以看出 ~2% 的性能改进。

dsb （Data Synchronization Barrier）数据同步屏障。

"寄存器生成SGI"（Register-generated SGI）是一种与计算机处理器和指令集架构相关的概念，特别是在ARM处理器的上下文中可能会遇到。

SGI（Software Generated Interrupt）：

SGI 是指由软件生成的中断（interrupt），通常用于在多处理器系统（如ARM处理器中的多核心系统）中进行内部通信和协调。SGI可以通过特殊的指令触发，并且有专门的中断编号范围，通常在0到15之间。每个SGI中断都有一个唯一的编号，可以用来向其他核心发送信号或者触发特定的处理。

寄存器生成（Register-generated）：

在某些上下文中，特定的SGI中断可以通过写入特定的寄存器来生成或触发。这种方式允许软件通过操作寄存器来发起SGI中断，而不是通过常规的中断控制器或外部信号线。

综合起来，"寄存器生成SGI"指的是一种机制，通过在特定的寄存器中写入特定的值或者命令，来生成或触发一个SGI中断。这种方法通常用于处理器内部的通信或者调度控制，允许软件直接控制和调度处理器核心之间的交互。

可能和低延时有关系。

（13
0038-thread_info-Add-helpers-to-snapshot-thread-flags.patch

优化kunpeng 920 的系统调用开销。

如下主线补丁将

3b7142752e4b arm64: convert native/compat syscall entry to C

f37099b6992a arm64: convert syscall trace logic to C

4141c857fd09 arm64: convert raw syscall invocation to C

将系统调用trace逻辑转换成c语言实现，并在el0_svc_common()中检查thread flags前执行local_daif_mask()，

而在linux upstream 合入342b38087865 arm64: Snapshot thread flags后， read_thread_flags()可以原子地读取thread flags，所以如下这对local daif mask restore操作是冗余的，去掉以优化syscall开销。

可能和低延时有关系。

（14
0039-x86-Snapshot-thread-flags.patch

同上面的补丁，这个是 x86 架构的，与 kunpeng 有关。可以不打上。

与低延时无关。

（15
0040-entry-Snapshot-thread-flags.patch

（16
0041-sched-Snapshot-thread-flags.patch

（17
0042-arm64-Snapshot-thread-flags.patch

（18
0043-arm64-syscall-unmask-DAIF-for-tracing-status.patch

与上面的13 是一个问题。

可能有低延时有关系。

（19
0044-arm64-armv8_deprecated-Fix-warning-in-isndep-cpuhp-s.patch

函数 run_all_insn_set_hw_mode（） 被注册为启动回调的 CPUHP_AP_ARM64_ISNDEP_STARTING“，它调用 set_hw_mode（） 方法所有模拟指令。

由于 STARTING 回调预计不会失败，因此如果
set_hw_mode（） 失败，例如由于 el0 不支持混合端序
'setend'，它将报告一个警告：

要修复它，请添加对INSN_UNAVAILABLE状态的检查并跳过该过程。bugfix

与低延时无关。

（20
0050-xfs-don-t-use-current-journal_info.patch

xfs在copy_to_user的前后文设置current-&gt;journal_info导致ext4 page fault后误用触发page fault ，bugfix

与低延时无关。

（21
0051-genirq-introduce-handle_fasteoi_edge_irq-flow-handle.patch

新增handle_fasteoi_edge_ir修复中断亲和性设置失败问题。

最近，我们在 ARM SMP 平台上遇到了 LPI 迁移问题。

例如，NIC 设备生成 MSI 并通过 ITS 将 LPI 发送到 CPU0，同时在 CPU1 上运行的 irqbalance 设置 NIC 对 CPU1 的 irq 关联，下一个中断将被发送到 CPU2，因为 irq 的状态为仍在进行中，内核最终不会在CPU2，这会导致一些用户空间服务超时，序列的事件显示如下：

```nil
NIC                     CPU0                    CPU1

Generate IRQ#1          READ_IAR
                        Lock irq_desc
                        Set IRQD_IN_PROGRESS
                        Unlock irq_desc
                                                Lock irq_desc
                                                Change LPI Affinity
                                                Unlock irq_desc
                        Call irq_handler
Generate IRQ#2
                                                READ_IAR
                                                Lock irq_desc
                                                Check IRQD_IN_PROGRESS
                                                Unlock irq_desc
                                                Return from interrupt#2
                        Lock irq_desc
                        Clear IRQD_IN_PROGRESS
                        Unlock irq_desc
                        return from interrupt#1
```

对于此方案，IRQ#2 将丢失。这确实会导致一些异常。

此补丁引入了一种新的流量处理程序，它结合了 fasteoi 和 edge 键入作为解决方法。如果已设置IRQS_PENDING，将执行额外的循环。

"LPI 迁移"（LPI Migration）通常指的是在 Linux 系统中，从传统的 IRQ（中断请求）方式向 LPI（Linux 定时中断）方式的转变过程。这种转变涉及到 IRQ 到 LPI 的映射和管理，是针对现代 ARM 处理器架构（如ARMv8）上的中断管理优化。

具体来说：

-   LPI（Linux 定时中断）：

LPI 是 ARM 处理器上的一种中断管理机制，相比传统的 IRQ 机制具有更高效的处理能力和更灵活的配置选项。LPI 中断可以在系统启动时动态分配，而不需要像传统 IRQ 那样静态分配。

-   IRQ（中断请求）：

传统的 IRQ 是较早期的中断管理方式，它们在系统启动时静态分配给设备和驱动程序，通常受限于固定数量的中断线。

-   LPI 迁移：

LPI 迁移是指将 Linux 内核的中断管理从 IRQ 转向 LPI 的过程。这涉及到更新设备树（Device Tree）中的中断控制器描述以支持 LPI，修改驱动程序代码以适应 LPI 的分配和管理方式，以及确保内核能够正确地处理和映射 LPI 中断。
LPI 迁移的主要目的是优化系统资源的利用和灵活性，使得在现代 ARM 架构上能够更好地支持动态分配和管理中断。

很有可能是降低延时的关键补丁。

（22
0052-genirq-introduce-handle_fasteoi_edge_irq-for-phytium.patch

同上，与低延时有关系，是飞腾平台上同一个问题的补丁。

（23
0053-mm-HVO-introduce-helper-function-to-update-and-flush.patch

hugetlb vmemmap 元数据优化特性在ARM64平台上违反了ARM架构规范。

<https://lore.kernel.org/linux-arm-kernel/8f91df80-203b-3ff0-7189-7cb0810c678b@arm.com/T/>

社区提了补丁在ARM64上关掉了HUGETLB VMEMMAP OPTIMIZE特性，其分析的潜在问题如上述链接中所述：

The reason for the revert is that the generic vmemmap_remap_pte()
function changes both the permissions (writeable to read-only) and the
output address (pfn) of the vmemmap ptes. This is deemed UNPREDICTABLE
by the Arm architecture without a break-before-make sequence (make the
PTE invalid, TLBI, write the new valid PTE). However, such sequence is
not possible since the vmemmap may be concurrently accessed by the
kernel. Disable the optimisation until a better solution is found.

我们需要解决该补丁中提到的问题。这个补丁解决了这个问题。

在更新页面中添加 pmd/pte update 和 tlb flush helper 功能表。此重构补丁旨在促进每个架构实现自己的特殊逻辑在准备中为了让 ARM64 架构遵循必要的 break-before-make更新页表时的顺序。

内存页表相关。

与低延时有关系。

（24
0054-arm64-mm-kfence-only-handle-translation-faults.patch

与上面是同一个问题。

与低延时有关系。

（25
0055-arm64-mm-HVO-support-BBM-of-vmemmap-pgtable-safely.patch

与上面是同一个问题。

与低延时有关系。

（26
0056-ARM-9278-1-kfence-only-handle-translation-faults.patch

与上面是同一个问题。

与低延时有关系。

（27
0057-ubifs-Fix-spelling-mistakes.patch

拼写错误，无关

（28
0058-ubifs-Fix-some-kernel-doc-comments.patch

注释修改，无关

（29
0059-ubifs-Fix-unattached-xattr-inode-if-powercut-happens.patch

当删除文件后发生断电时，xattr inode 可能是单独存在于 TNC 中，但在 TNC 中找不到其 xattr 条目。删除后，文件 inode 和 xattr inode 被添加到孤立列表中文件，文件 inode 的 nlink 为 0，但 xattr inode 的 nlink 不是 0 （PS：零 nlink xattr inode 在逐出过程中写入磁盘，由
ubifs_jnl_write_inode）。因此，可能会发生以下过程：

```nil
 1.touch file
 2.setxattr(file)
 3.unlink file
    // inode(nlink=0), xattr inode(nlink=1) are added into orphan list
 4.commit
    // write inode inum and xattr inum into orphan area
 5.powercut
 6.mount
    do_kill_orphans
     // inode(nlink=0) is deleted from TNC by ubifs_tnc_remove_range,
     // xattr entry is deleted too.
     // xattr inode(nlink=1) is not deleted from TNC

Finally we could see following error while debugging UBIFS:
 UBIFS error (ubi0:0 pid 1093): dbg_check_filesystem [ubifs]: inode 66
 nlink is 1, but calculated nlink is 0
 UBIFS (ubi0:0): dump of the inode 66 sitting in LEB 12:2128
   node_type      0 (inode node)
   group_type     1 (in node group)
   len            197
   key            (66, inode)
   size           37
   nlink          1
   flags          0x20
   xattr_cnt      0
   xattr_size     0
   xattr_names    0
   data len       37
```

通过在重播孤立项时删除带有 xattrs 的整个 inode 来修复它，只需用ubifs_tnc_remove_ino替换函数ubifs_tnc_remove_range即可。 bugfix

与低延时无关。

（30
0060-ubifs-Don-t-add-xattr-inode-into-orphan-area.patch

同上，无关

（31
0061-ubifs-Remove-insert_dead_orphan-from-replaying-orpha.patch

同上，无关

（32
0062-ubifs-Fix-adding-orphan-entry-twice-for-the-same-ino.patch

同上，无关

（33
0063-ubifs-Move-ui-data-initialization-after-initializing.patch

同上，无关

（34
0064-ubifs-Fix-space-leak-when-powercut-happens-in-linkin.patch

同上，无关

（35
0065-ubifs-Fix-unattached-inode-when-powercut-happens-in-.patch

同上，无关

（36
0066-ubifs-dbg_orphan_check-Fix-missed-key-type-checking.patch

同上，无关

（37
0078-sched-smart_grid-fix-potential-NULL-pointer-derefere.patch

因为从一个 cgroup 中删除任务时没有保护任务唤醒，所以我们需要检查auto_affinity 是不是NULL 在task_prefer_cpus.

There is a low probability that kernel panic will occur when we test
with smart_grid. 这里并不清楚 smart_grid 是什么？bugfix

与低延时无关。

（38
0079-memcg-attach-memcg-async-reclaim-worker-to-curcpu.patch

追加支持per-memcg异步回收水线绑核功能

将 memcg async relcaim worker 附加到 curcpu，这将确保
memcg 异步回收工作器将被安排在 CPUMASK 所属的到当前的 cpuset。

与低延时可能相关。

（39
0081-RDMA-hiroce3-Fix-allmodconfig-build-frame-size-error.patch

hiroce3驱动在arm64 clang allmodconfig编译时有报错，bugfix

无关

（40
0082-rcu-Defer-RCU-kthreads-wakeup-when-CPU-is-dying.patch

当 CPU 在 CPU 关闭热插拔期间最后一次空闲时过程中，RCU 会报告当前 CPU 的最终静止状态。如果这种静态状态会传播到顶部，然后可能会有一些任务醒来完成宽限期：主要宽限期 kthread
和/或加急主工作队列（或 kworker）。

如果这些 kthread 具有SCHED_FIFO策略，则唤醒可以间接地将 RT bandwith 定时器连接到本地离线 CPU。由于这种情况发生在CPUHP_AP_HRTIMERS_DYING阶段迁移 HRTimers 后，计时器被忽略。因此，如果 RCU kthreads 正在等待 RT
带宽可用，它们可能永远不会实际调度。bugfix

无关

（41
0083-entry-rcu-Check-TIF_RESCHED-<span class="underline">after</span>-delayed-RCU-wake.patch

同上，无关

（42
0084-srcu-Fix-callbacks-acceleration-mishandling.patch

同上，无关

（43
0085-ima-Fix-violation-digests-extending-issue-in-cvm.patch

ima度量时，设置默认策略ima_policy="tcb"，系统panic

添加特殊处理的 IMA 违规摘要，该摘要随着所有0xff被扩展。bugfix

无关

（44
0086-ksmbd-no-response-from-compound-read.patch

ksmbd 不支持复合读取。如果客户端发送读入与 ksmbd 复合时，读取缓冲区可能会发生内存泄漏。
Windows 和 Linux 客户端尚未将其发送到服务器。目前，复合读取没有响应。复合读取将很快得到支持。

ksmbd 这个网络文件服务的 bugfix

无关

（45
0087-Fix-token-error-issue-when-concurrent-calls.patch

用户态并发调用获取token接口时，前一个调用生成的token会被被覆盖导致token数据错误。

arch/arm64/include/uapi/asm/cvm_tsi.h |  6 ~~~~-
arch/arm64/kernel/cvm_tsi.c           | 66 ~~~~++~~~~~~~~-------------------

不清楚是什么token ，但这是个 bugfix

无关

（46
0088-urma-cannot-uninstall-uburma-driver.patch

电流复位停止流将导致 uburma 的 refcnt 非 0 ，用不等于 0 判断是不对的。

bugfix

无关。

（47
0091-hns3-udma-kernel-support-non-share-jfr-mode-in-UM-mo.patch

HNS3 UDMA特性性能优化，HNS3 是kunpeng 920 的板载网卡，

此补丁内核支持 UM 模式下的非共享 jfr 模式。
Rq模式可以提高消息速率。

【特性描述】
UDMA特性性能指标包括时延、带宽、IOPS等。【特性竞争力】
UDMA目标做到低时延、高带宽、高吞吐率。【特性约束】
NA
【涉及仓库】
kernel/drivers/ub/hw/hns3
umdk

很有可能是需要的补丁，有关系。

（48
0101-Revert-sched-fair-ARM64-enables-SIS_UTIL-and-disable.patch

arm64 默认使用SIS_PROP

("sched/fair:ARM64 enables
SIS_UTIL and disables SIS_PROP 导致性能下降使用 Unixbench pipe-base contextswich 案例在鲲鹏 920B 上进行了测试。

调度相关的补丁回退。后面又被回退

有关系，大概率无关。

（49
0106-sched-ARM64-enables-SIS_PROP-and-disables-SIS_UTIL.patch

同上，有关系，大概率无关。

（50
0107-tracing-Fix-permissions-for-the-buffer_percent-file.patch

回合补丁修复buffer_percent文件的权限问题，bugfix

无关

（51
0114-fs-Use-CHECK_DATA_CORRUPTION-when-kernel-bugs-are-de.patch

目前，filp_close（） 和 generic_shutdown_super（） 使用 printk（） 来记录检测到 Bug 时的消息。这是有问题的，因为基础设施就像 Syzkaller 不知道此消息表示错误一样。此外，有些人明确希望他们的内核在内核已检测到数据损坏 （CONFIG_BUG_ON_DATA_CORRUPTION）。最后，当 generic_shutdown_super（） 检测到没有CONFIG_BUG_ON_DATA_CORRUPTION的系统，如果以后会很好对繁忙的 inode 的访问至少会在某种程度上干净地崩溃，而不是穿越释放的记忆。

要解决这三个问题，请在出现内核错误时使用 CHECK_DATA_CORRUPTION（）检测。

提升unix bench 跑分：多核UnixBench跑分对比

```nil
System Benchmarks Index Values           without patch    with patch      VS
File Copy 1024 bufsize 2000 maxblocks       1246.3         1384.2         11.1%
File Copy 256 bufsize 500 maxblocks         819.0          956.9          16.8%
File Copy 4096 bufsize 8000 maxblocks       3131.7         3279.5         4.7%
Process Creation                            4574.3         4664.8         2.0%
Shell Scripts (1 concurrent)                20825.0        21773.4        4.6%
Shell Scripts (8 concurrent)                20161.8        20946.7        3.9%

System Benchmarks Index Score                                             4.2%
```

能提升性能。

有关系。后面又关了，大概率无关。

（52
0118-block-fix-WARNING-in-init_blk_queue_async_dispatch.patch

openeuler支持io切换到指定cpu异步下发，这个补丁解决了

当\__kmalloc超过 1 页时，将触发警告
GFP_NOFAIL.在具有大量 CPU 的系统上，
init_blk_queue_async_dispatch（） 可能会尝试分配更大的内存超过 1 页，导致 WARING：

如果分配失败，通过删除标志GFP_NOFAIL和panic内核来修复它。bugfix

无关。

（53
0123-cvm-delete-dead-code-and-resolve-macro-definition-ho.patch

virtCCA机密虚机安全加固相关，删除死代码并解决巨集定义漏洞

无关。

（54
0138-Revert-sched-ARM64-enables-SIS_PROP-and-disables-SIS.patch

arm64 默认使用SIS_PROP 。调度相关的性能优化。同 101 106 139 补丁。

有关系，大概率无关。

（55
0139-Revert-Revert-sched-fair-ARM64-enables-SIS_UTIL-and-.patch

101 106 138 139 不懂为什么开了又关。

有关系。大概率无关

（56
0140-sched-numa-Fix-numa-imbalance-in-load_balance.patch

调度负载均衡优化.

执行负载均衡时，允许 NUMA 不均衡如果繁忙的 CPU 小于最大阈值，则保持一对通信任务处于当前状态当目标负载较轻时时的节点。

1.但是，calculate_imbalance（）使用 local-&gt;sum_nr_running，它可能不准确，因为通信任务是在最繁忙的组中，因此应该是 busiest-&gt;sum_nr_running。

2.同时，使用空闲的CPU进行计算不平衡，但group_weight可能不一样在本地和最繁忙的团体之间。在这种情况下，即使两组都非常闲置，将计算不平衡非常大，所以不平衡是通过计算来计算的组间繁忙 CPU 的差异。

有关系，很有可能是这个。

（57
0141-config-Disable-COBFIG_ARCH_CUSTOM_NUMA_DISTANCE-for-.patch

支持根据芯片model修改node_reclaim_distance.

Disable COBFIG_ARCH_CUSTOM_NUMA_DISTANCE for arm64.

NUMA 配置

有关系。

（58
0142-Revert-fs-Use-CHECK_DATA_CORRUPTION-when-kernel-bugs.patch

打开后又关闭了这个检查。开了又关的大概率不是。

有关系，大概率无关。

（59
0143-blk-throttle-factor-out-code-to-calculate-ios-bytes_.patch

没有功能变化，新的 API 将在以后的补丁中使用到计算新配置时受限制的 BIOS 的等待时间提交。

注意到此补丁还将 tg_with_in_iops/bps_limit（） 重命名为
tg_within_iops/bps_limit（）。

修复 bug: cgroup v1 io先限速再放大限制后机器重启

复现步骤：

```nil
mount /dev/sda /home/io_test/
mkdir -p /sys/fs/cgroup/blkio/throt
echo "8:0 1000" > /sys/fs/cgroup/blkio/throt/blkio.throttle.write_bps_device
echo $$ > /sys/fs/cgroup/blkio/throt/cgroup.procs
dd if=/dev/zero of=/home/io_test/test.file bs=1M count=10 oflag=direct &
echo "8:0 8375319363688624583" > /sys/fs/cgroup/blkio/throt/blkio.throttle.write_bps_device
```

无关。

（60
0144-blk-throttle-use-calculate_io-bytes_allowed-for-thro.patch

同上，无关

（61
0145-blk-throttle-check-for-overflow-in-calculate_bytes_a.patch

同上，无关

（62
0169-cgroup-fix-uaf-when-proc_cpuset_show.patch

KASAN（Kernel Address Sanitizer）是 Linux 内核中的一种内存错误检测工具。它主要用于检测内核中的内存使用错误，例如使用已释放的内存、访问越界等问题。具体来说，KASAN通过在运行时插入额外的代码和数据结构来实现内存错误检测，这些额外的内容用于跟踪内存分配和释放操作，以及标记内存块的状态。当程序访问未分配或已释放的内存时，KASAN会检测到并报告错误，帮助开发人员诊断和修复内存相关的问题。

总体而言，KASAN是 Linux 内核中用于内存安全检测的一种工具，有助于提高内核代码的稳定性和安全性。

解决 UAF 的问题，bugfix

无关

（63
0181-net-hinic3-Add-pcie-device-ID-adaption-for-DPU_NIC-c.patch

增加华为的网卡 devid

无关

（64
0189-bpf-Fix-memory-leaks-in-\__check_func_call.patch

内核主线的bpf 内存泄露的补丁。

回合如下bugfix补丁：

```nil
eb86559a691cea5fa63e57a03ec3dc9c31e97955 bpf: Fix memory leaks in __check_func_call
261f4664caffdeb9dff4e83ee3c0334b1c3a552f bpf: Clobber stack slot when writing over spilled PTR_TO_BTF_ID
ab333edccc43f47f726ad094e962f906879d2084 bpf: ensure main program has an extable
3f23934fd70ef8c1fbfc1dedcddfadc1ecfbea56 bpf: Don't EFAULT for {g,s}setsockopt with wrong optlen
7be14c1c9030f73cc18b4ff23b78a0a081f16188 bpf: Fix __reg_bound_offset 64->32 var_off subreg propagation
```

无关

（65
0190-bpf-Clobber-stack-slot-when-writing-over-spilled-PTR.patch

同上，无关

（66
0191-bpf-Fix-\__reg_bound_offset-64-32-var_off-subreg-prop.patch

同上，无关

（67
0192-bpf-Don-t-EFAULT-for-g-s-setsockopt-with-wrong-optle.patch

同上，无关

（68
0193-bpf-ensure-main-program-has-an-extable.patch

同上，无关

（69
0197-arm64-arm_pmuv3-Correctly-extract-and-check-the-PMUV.patch

正确提取并检查PMUVer ，使用“ubfx”而不是“sbfx”来提取PMUVer

目前，我们正在使用“sbfx”从ID_AA64DFR0_EL1中提取PMUVer
如果提取的 PMUVer 时不存在 PMU，则跳过初始化/重置负数或为零。但是，对于 PMUv3p8，PMUVer 将为 0b1000，并且“sbfx”提取的 PMUVer 将始终为负数，我们将跳过在 __init_el2_debug/reset_pmuserenr_el0 中意外初始化/重置。

因此，此补丁使用“ubfx”而不是“sbfx”来提取PMUVer。如果
PMUVer 已定义实现 （0b1111） 或未实现 （0b0000）然后跳过 reset/init。以前，我们还将跳过初始化/重置如果 PMUVer 高于我们已知的版本（当前为 PMUv3p9），使用此补丁，我们仅在未实现 PMU 或定义实现。这与我们的探测方式保持一致驱动器中的 PMU 带有 pmuv3_implemented（）。

PMU 指的是 "Performance Monitoring Unit"，即性能监测单元。它是一种硬件设备或功能，通常集成在现代处理器或系统芯片中，用于监测和收集系统在运行时的性能数据和统计信息。PMU 的主要功能包括：

事件计数器（Event Counters）：用于计算特定事件（例如指令执行、缓存命中、分支预测等）发生的次数或频率。这些计数器可以帮助分析程序的执行效率和各种硬件资源的利用情况。

性能事件（Performance Events）：可以监测和记录多种硬件性能事件，如缓存命中率、指令执行延迟、分支预测准确率等。这些事件可以帮助开发人员和系统管理员优化程序性能和资源使用。

性能计数器（Performance Counters）：PMU 提供了一组可配置的性能计数器，可以捕获各种事件的统计数据。这些计数器通常可以通过软件编程接口（如操作系统提供的接口或特定性能分析工具）进行配置和访问。

PMU 的主要作用是帮助开发人员和系统管理员分析和优化软件程序的性能特征，从而改进系统的整体效率和响应能力。

无关

（70
0203-iomap-Don-t-finish-dio-under-irq-when-there-exists-p.patch

ext4: xfstests generic/451失败

复现方式，运行xfstests generic/451

问题原因：48774b90b5677bdb4 ("ext4: Optimize endio process for DIO overwrites")之后，ext4 dio完成IO可以在irq下执行，但是io完成后invalidate_inode_pages2_range不会再执行。451用例在并发做dio write和buffer read，然后每个dio write完成都在同线程内read page检查内容，由于invalidate_inode_pages2_range不会再执行导致后台buffer read任务在IO完成前读取到stale data，使得read page检查失效。

bugfix

无关。

（71
0209-net-fix-one-NULL-pointer-dereference-bug-in-net_rshi.patch

修复net_rship模块中空指针问题

bugfix

无关。

（72
0212-arm64-mm-Pass-pbha-performance-only-bit-under-chosen.patch

针对 arch_vm_get_page_prot 的 Bug 修复替换PROT_PBHA_BIT0以避免冲突

将 pbha-performance-only 传递到到所选节点下来解决启动问题。

bugfix ，

"PBHA" 在这里可能是指 "Protected Branch History Analysis"，它通常涉及版本控制系统中的一个功能或策略。具体来说，PBHA 可能是一种在软件开发过程中用来管理和审查分支（Branch）历史记录的方法或工具。在某些情况下，PBHA 可能指向一种特定的软件工具或操作流程，用于早期开发阶段（stage1 early）的分支管理和版本控制。

另外，“FD” 可能是文件描述符（File Descriptor）的缩写，它是在 Unix/Linux 系统中用于访问文件或其他 I/O 设备的抽象概念。

因此，您提到的句子可能在讨论如何通过文件描述符（FD）来启用早期阶段（stage1 early）的 PBHA 功能或策略。这可能涉及到特定的软件开发环境或工具链中的配置或命令操作。

性能优化相关。

有关系

（73
0218-cgroup-Fix-AA-deadlock-caused-by-cgroup_bpf_release.patch

【hulk-5.10欧拉OS】【X86/arm 】【SIT-EulerOS_basic-kernel-调度专项】去除cfs限流操作，不安装cfs_wdt，反复修改watchdog_thresh，执行调度专项物理机出现hungtask

bugfix

无关。

（74
0223-cifs-Fix-deadlock-in-cifs_writepages-during-reconnec.patch

拔网线cifs写文件的进程stuck住无法退出。

bugfix

无关。

（75
0226-roh-core-Support-macvlan-in-roh.patch

ROH支持macvlan

【特性描述】

ROH支持macvlan

【特性竞争力】

同一ROH网卡可配置多个macvlan设备

【硬件架构】

鲲鹏服务器板载网卡

【特性约束】

仅支持默认brige模式，private，vepa，passthru模式不支持

【涉及仓库】

driver/roh/core

【交付个人/团队】

鲲鹏服务器板载网卡ROH团队

新特性

无关。

（76
0227-fs-improve-dump_mapping-robustness.patch

我们在运行 stress-ng 测试时遇到了内核崩溃问题，并且在 dump_mapping（） 中打印 dentry 名称时系统崩溃。

fs 的bugfix

无关

（77
0228-iommu-arm-smmu-v3-Change-the-style-to-identify-the-t.patch

使用IORT和DTS更加准确的识别HISI设备，而不是用ARCH_HISI。

iommu 驱动匹配

相关。

（78
0239-nvdimm-pmem-use-add_disk-error-handling.patch

nvdimm bugfix补丁

现在 device_add_disk（） 支持返回错误，请使用那。我们必须在错误时解开 alloc_dax（）。

NVDIMM 是 "Non-Volatile Dual In-line Memory Module" 的缩写，即非易失性双列直插内存模块。它是一种结合了内存和存储功能的硬件设备，具有内存操作速度和持久存储数据不丢失的特性。

具体来说，NVDIMM 结合了动态随机存取存储器（DRAM）和非易失性存储（通常是闪存或者电阻随机存取存储器（ReRAM）），使得它在系统断电时能保持数据不丢失。这使得 NVDIMM 在需要快速数据访问且需要数据持久性的应用中非常有用，比如数据库、缓存加速、虚拟化环境等。

总结来说，NVDIMM 提供了高速的内存访问速度，同时具备存储设备的持久性，因此在需要结合内存和存储功能的应用场景中有广泛的应用。

Direct Attached Storage (DAX): 直接连接存储，是一种存储体系结构，将存储设备直接连接到计算机或服务器，而不通过网络。

bugfix

无关。

（79
0240-dax-alloc_dax-return-ERR_PTR-EOPNOTSUPP-for-CONFIG_D.patch

同上，无关

（80
0251-xfs-fix-mount-hung-while-sb-recover-fail.patch

当我挂载损坏的 xfs 镜像时，挂载过程一直挂起，堆栈如下：

```nil
[root@testvm ~]# cat /proc/425/stack
[<0>] xfs_wait_buftarg+0x5a/0x360
[<0>] xfs_mountfs+0x591/0xc90
[<0>] xfs_fc_fill_super+0x792/0xc80
[<0>] get_tree_bdev+0x1ec/0x3a0
[<0>] xfs_fc_get_tree+0x19/0x30
[<0>] vfs_get_tree+0x2f/0x110
[<0>] path_mount+0x8ab/0x1150
[<0>] do_mount+0x91/0xc0
[<0>] __se_sys_mount+0x14a/0x220
[<0>] __x64_sys_mount+0x29/0x40
[<0>] do_syscall_64+0x6c/0xe0
[<0>] entry_SYSCALL_64_after_hwframe+0x62/0xc7
```

在缓冲区恢复过程中，如果修改了超级块缓冲区，我们也会需要更新挂载点 （MP） 的内容。在这种情况下，如果遇到错误，我们会去out_release并发布
xfs_buf。但是，这还不够，因为 xfs_buf 的日志项已初始化并由 中的缓冲区日志项持有
xlog_recover_do_reg_buffer（）.

解决这个问题很简单：我们需要设置错误并添加在这种情况下，xfs_buf buffer_list。这使得它成为由正常的缓冲区写入过程处理。文件系统将被关闭在 xlog_do_recovery_pass（） 中提交之前关闭，因为日志恢复遇到错误。因此，xfs_buf将被正确释放。

bugfix

无关

（81
0261-nfs-nfs_file_write-should-check-for-writeback-errors.patch

nfs 客户端返回报错码不准确

NFS客户端写入数据超过磁盘配额时，期待失败的返回值是-EDQUOT，但是在5.10上返回了-EIO。

bugfix

无关

（82
0262-nfs-ensure-correct-writeback-errors-are-returned-on-.patch

同上无关

（83
0263-NFS-Use-of-mapping_set_error-results-in-spurious-err.patch

同上无关

（84
0264-NFS-Don-t-report-ENOSPC-write-errors-twice.patch

同上无关

（85
0265-nfs-Ensure-write-and-flush-consume-writeback-errors.patch

同上无关

（86
0268-ipvlan-Dont-Use-skb-sk-in-ipvlan_process_v-4-6-_outb.patch

packet_snd中调用packet_alloc_skb分配skb并在skb_set_owner_w中设置skb-&gt;sk为packet sock

之后报文被发送至l3s模式的ipvlan设备， 然后转至ip6_finish_output2中处理，并最终在sk_mc_loop触发告警

在 ipvlan 中使用 NULL sk 调用 ip6_local_out（） 作为其他隧道来解决此问题。

bugfix

产生警告时是否会效率降低？

有关。

（87
0269-Revert-RDMA-hns-Add-mutex_destroy.patch

RDMA/hns some bugfix

RDMA 是 "Remote Direct Memory Access" 的缩写，即远程直接内存访问。它是一种网络数据传输技术，允许计算机系统在不涉及主机 CPU 的情况下，直接在内存之间进行数据传输。这种技术通过绕过操作系统的数据传输路径和协议栈，显著降低了传输延迟和 CPU 使用率。

关键特点包括：

低延迟: RDMA 允许数据在主机之间直接传输，而无需涉及主机 CPU 的处理，因此可以实现非常低的传输延迟。

高带宽: RDMA 技术利用了现代网络设备的高带宽特性，能够以非常高的速度传输数据。

CPU 消耗低: 由于数据传输不涉及主机 CPU 的参与，RDMA 能够显著减少主机 CPU 的使用率，释放其用于其他计算任务。

RDMA 通常用于需要高性能网络数据传输的场景，例如数据中心的分布式计算、存储系统、高性能计算（HPC）、虚拟化环境等。主要的 RDMA 技术包括 InfiniBand 和 RoCE（RDMA over Converged Ethernet）等。

bugfix ，SDMA 相关

有关

（88
0270-Revert-RDMA-hns-Fix-UAF-for-cq-async-event.patch

同上有关

（89
0271-RDMA-hns-Add-mutex_destroy.patch

同上有关

（90
0272-RDMA-hns-Fix-UAF-for-cq-async-event.patch

同上有关

（91
0290-net-openvswitch-fix-race-on-port-output.patch

openvswitch触发软锁，在云计算场景中，使用ovs作为网络插件，在物理服务器上触发软锁问题

缺陷简述：在物理服务器上触发软锁问题，通过查看内核日志，确认是openvswitch模块触发

【环境信息】

硬件信息

System Information

Manufacturer: Inspur

Product Name: CS5280F3

软件信息

OS版本及分支信息：openEuler22.03LTS-SP1

内核信息：5.10.0-136.37.0.113.oe2203sp1.aarch64

【问题复现步骤】

在物理服务器上安装ovs，使用vxlan方式支持虚拟机网络，运行一周左右，出现openvswitch软锁

【实际结果】

由于出现软锁，系统运行效率下降，待所有cpu锁住后，系统卡死。

bugfix

无关。

（92
0293-sched-fair-Take-the-scheduling-domain-into-account-i.patch

调度选核过程中，没有考虑隔离核场景.

在任务唤醒时选择 CPU 时，select_idle_core（） 必须采取考虑到函数查找 CPU 的调度域。

这是因为“isolcpus”内核命令行选项可以删除 CPU
从域中将它们与其他 SMT 同级隔离开来。

此更改替换了允许从中运行任务的 CPU 集
P-&gt;cpus_ptr和sched_domain_span（SD）交叉的P-&gt;cpus_ptr
它存储在 select_idle_cpu（） 提供的 'cpus' 参数中。

bugfix

相关。

（93
0296-hns3-udma-functions-related-to-CQ-bank-IDs-are-suppo.patch

HNS3 UDMA特性问题修复，代码优化。此补丁支持cq bank id的功能现在与端口 ID 相关。

UDMA（Ultra DMA）是一种用于计算机硬盘驱动器（HDD）和光盘驱动器（如CD-ROM、DVD-ROM）的数据传输模式。它是一种高效的数据传输协议，旨在提高数据传输速度和效率。

UDMA技术主要特点包括：

高速传输: UDMA通过增加数据总线宽度和提高传输速率，显著提高了硬盘驱动器和光盘驱动器的数据传输速度。

减少CPU负担: UDMA减少了对CPU的依赖，通过使用直接内存访问（DMA）技术，使数据传输更加高效，同时减少了主机处理器的负载。

向后兼容性: UDMA技术设计上具有向后兼容性，可以与早期的ATA（Advanced Technology Attachment）标准兼容，如ATA-66、ATA-100、ATA-133等。

总体来说，UDMA技术通过提供高速、高效的数据传输方式，显著改善了计算机存储设备的性能，特别是在早期和中期的计算机硬件中得到了广泛应用。

硬盘效率提升

相关。

（94
0299-drm-amdgpu-Fix-kabi-breakage-in-struct-amdgpu_hive_i.patch

drm 相关 amdgpu 显卡的 kabi 补丁

无关

（95
0306-RDMA-hns-Check-atomic-wr-length.patch

RDMA 相关的bugfix

相关

（96
0307-RDMA-hns-Fix-unmatch-exception-handling-when-init-eq.patch

同上，相关

（97
0308-RDMA-hns-Fix-missing-pagesize-and-alignment-check-in.patch

同上，相关

（98
0309-RDMA-hns-Fix-shift-out-bounds-when-max_inline_data-i.patch

同上，相关

（99
0310-RDMA-hns-Fix-undifined-behavior-caused-by-invalid-ma.patch

同上，相关

（100
0311-RDMA-hns-Fix-insufficient-extend-DB-for-VFs.patch

同上，相关

（101
0312-RDMA-hns-Fix-mbx-timing-out-before-CMD-execution-is-.patch

同上，相关

（102
0316-media-dvb-usb-Fix-unexpected-infinite-loop-in-dvb_us.patch

修复dvb_usb_read_remote_control()中非预期的死循环问题

通过分析相应的 USB 描述符，可以看出
bNumEndpoints 的接口描述符为 0，但“generic_bulk_ctrl_endpoint”是 1，表示用户不配置“generic_bulk_ctrl_endpoint”的有效端点，因此此“无效”的 USB 设备在调用之前应被拒绝
dvb_usb_read_remote_control（）.

要修复它，我们需要添加“generic_bulk_ctrl_endpoint”的端点检查。正如肖恩所建议的那样，应该对“generic_bulk_ctrl_endpoint_response”。所以介绍一下
dvb_usb_check_bulk_endpoint（） 为他们俩都做。

DVB 是数字视频广播（Digital Video Broadcasting）的缩写，是一种用于数字电视传输的国际标准。它涵盖了一系列用于通过卫星、有线和地面广播网络传输数字视频、音频和数据的技术规范。DVB 标准旨在提供更高的传输效率、更好的音视频质量以及更多的互动功能，取代了传统的模拟电视传输方式。

DVB 标准包括多种子标准，例如：

DVB-S: 用于通过卫星传输数字电视的标准。包括一系列不同的规范，如DVB-S, DVB-S2等，每个版本都有不同的特性和改进。

DVB-C: 用于通过有线电视网络传输数字电视的标准，涵盖了不同的传输和解调规范。

DVB-T: 用于通过地面传输网络（地面波传输）传输数字电视的标准，通常称为地面数字电视。

DVB-H: 专门设计用于移动接收设备（如手机和便携式电视）的标准，提供高效的移动接收和视频传输。

DVB 标准由欧洲电信标准化协会（ETSI）管理，被广泛应用于全球范围内的数字电视和广播网络。

usb bugfix

无关

（103
0573-drivers-misc-sdma-dae-fix-interrupt-handle-logic.patch

SDMA概率性触发中断无法清除

SDMA-DAE的中断处理逻辑是根据虚拟中断号获取对应的通道id，从而找到中断源并清理，该逻辑依赖OS分配给SDMA-DAE的所有中断号是连续的。然而在OS启动阶段并不保序，从而概率导致SDMA-DAE在触发中断的情况下，中断源寻找错误无法清除中断源并导致刷屏中断打印的情况。

偶现问题 bugfix

有关

（104
0663-sched-Add-cfs_preferred_nid_init-hook.patch

为调度器添加cfs_preferred_nid_init钩子，允许用户为进程多线程初始化相同的numa_preferred_nid。

鲲鹏920支持自适应NUMA需求

【特性描述】随着摩尔定律的失效，硬件架构Scale-up收益空间收窄，Scale-out是硬件架构主要发展的方向，但软件的性能并不能随着CPU核数增多而线性增长，需要解决资源“locality”的问题。鲲鹏服务器属于NUMA架构，跨NUMA访存时延相比本地访存时延大大增加，而linux操作系统以吞吐为中心，强调负载均衡，会因为负载均衡的约束，而打破全局跨NUMA访存最优的状态。

本特性是以亲缘关系为中心的负载均衡机制： 突破linux调度模型中负载均衡的约束，以亲缘关系为中心，在资源未达到瓶颈时，将具有亲缘关系的任务packing在一起，减少跨NUMA访存。

1）感知亲缘关系：通过软硬协同，感知线程间网络、内存的亲缘关系；

2）感知资源瓶颈：基于NUMA维度的资源瓶颈感知，感知NUMA资源是否达到瓶颈；

3）优化选核和负载均衡机制：突破linux原有负载均衡约束，在没有资源瓶颈前提下，将具有亲缘关系的任务选核在一起；

【特性竞争力】

提升Mysql、redis、ceph 等业务性能。

【硬件架构】

ARM

【特性约束】

NA

【涉及仓库】

全路径，包括增量修改和新增仓库

【交付个人/团队】

请明确交付责任人，如果有团队支撑，请一并填写团队信息

NUMA 相关，调度相关。

相关。

（105
0664-BMA-edma_drv-Fix-DMA-reset-problem-and-change-the-ve.patch

iBMA去虚拟化网卡驱动低概率造成softlockup问题、veth驱动低概率造成软中断循环、dma引擎复位时寄存器配置与通信数据传输方向不匹配导致复位不符合预期问题.

Enhanced Direct Memory Access (eDMA): 这是一种计算机系统中用于数据传输的技术，通常用于微控制器和嵌入式系统中。eDMA 允许数据在设备之间或设备与内存之间直接传输，而无需 CPU 的干预，从而提高了系统效率和性能。

BMA: Baseband Management Architecture (BMA): 在计算机网络中，BMA 可能指基带管理架构，用于管理和监控网络设备的基带传输和管理。

bugfix

网卡，edma.

相关。

（106
0665-BMA-cdev_drv-Change-the-version-number.patch

同上，相关。

（107
0666-BMA-veth_drv-Change-the-version-number.patch

同上，相关。

（108
0667-BMA-kbox_drv-Change-the-version-number.patch

同上，相关。
