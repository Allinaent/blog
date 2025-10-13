+++
title = "一次软锁问题的分析"
date = 2025-01-13T14:40:00+08:00
lastmod = 2025-10-13T13:41:53+08:00
categories = ["kernel"]
draft = true
toc = true
image = "https://r2.guolongji.xyz/allinaent/2024/06/92a1feeab471b12646b9c76edccc1546.jpg"
+++

杂谈：大数据用 <https://emacs-china.org/t/ms-office-spread-sheet/22771/4>

python pandas 或者 R 的 data.frame ，可以处理 CSV 。

小数据用 wps ，截图就很好的。


## call trace 1 {#call-trace-1}

```nil
Jan  5 03:41:25 cc-cdfusion-obwind-x86-compute-4 kernel: watchdog: BUG: soft lockup - CPU#30 stuck for 23s! [kubelet:810499]
Jan  5 03:41:25 cc-cdfusion-obwind-x86-compute-4 kernel: Modules linked in: ebt_arp ebt_among ip6table_raw xt_CT xt_mac ebtable_nat xt_physdev xt_multiport ipt_rpfilter iptable_raw ip_set_hash_ip ip_set_hash_net veth ipip tunnel4 ip_tunnel wireguard ip6_udp_tunnel udp_tunnel nf_conntrack_netlink xt_addrtype xt_set ip_set_hash_ipportnet ip_set_hash_ipportip ip_set_bitmap_port ip_set_hash_ipport ip_set nbd rbd libceph dns_resolver dummy nf_tables nfnetlink ip6t_MASQUERADE ip6table_nat nf_nat_ipv6 ip6table_mangle xt_mark xt_comment fuse xt_CHECKSUM iptable_mangle ipt_MASQUERADE iptable_nat nf_nat_ipv4 nf_nat xt_conntrack ipt_REJECT nf_reject_ipv4 ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter overlay 8021q garp mrp bonding ib_isert iscsi_target_mod ib_srpt target_core_mod ib_srp scsi_transport_srp amd64_edac_mod edac_mce_amd
Jan  5 03:41:25 cc-cdfusion-obwind-x86-compute-4 kernel: kvm_amd rpcrdma sunrpc rdma_ucm ib_iser ib_umad rdma_cm ib_ipoib iw_cm ipmi_ssif libiscsi kvm scsi_transport_iscsi ib_cm irqbypass crct10dif_pclmul crc32_pclmul ghash_clmulni_intel rapl bcache pcspkr joydev crc64 ses enclosure scsi_transport_sas ccp sg i2c_piix4 k10temp sm3_generic ipmi_si ipmi_devintf ipmi_msghandler mlx5_ib acpi_cpufreq ib_uverbs ib_core vhost_net tun tap vhost_vsock vmw_vsock_virtio_transport_common vhost vsock br_netfilter bridge stp llc ip_vs_sh ip_vs_wrr ip_vs_rr ip_vs nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 ip_tables sd_mod ast i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm mlx5_core ixgbe crc32c_intel ahci drm nvme libahci nvme_core libata megaraid_sas dca mlxfw dm_mirror dm_region_hash dm_log dm_mod
Jan  5 03:41:25 cc-cdfusion-obwind-x86-compute-4 kernel: CPU: 30 PID: 810499 Comm: kubelet Kdump: loaded Tainted: G             L    4.19.0-91.77.77.5.uelc20.x86_64 #1
Jan  5 03:41:25 cc-cdfusion-obwind-x86-compute-4 kernel: Hardware name:  SH201-D12RE/62DB32 Rev 1.0, BIOS SXYH041040 07/15/2024
Jan  5 03:41:25 cc-cdfusion-obwind-x86-compute-4 kernel: RIP: 0010:mem_cgroup_node_nr_lru_pages+0x99/0xf0
Jan  5 03:41:25 cc-cdfusion-obwind-x86-compute-4 kernel: Code: 41 89 dc bf ff ff ff ff 45 31 ff 49 c1 e4 03 eb 19 48 63 d7 4c 89 e0 48 03 85 88 00 00 00 48 8b 14 d5 a0 77 b7 99 4c 03 3c 10 <48> c7 c6 e0 fb e7 99 e8 5b 5f 6b 00 3b 05 b9 88 1c 01 89 c7 72 d1
Jan  5 03:41:25 cc-cdfusion-obwind-x86-compute-4 kernel: RSP: 0018:ffff9ffb351f7e00 EFLAGS: 00000246 ORIG_RAX: ffffffffffffff13
Jan  5 03:41:25 cc-cdfusion-obwind-x86-compute-4 kernel: RAX: 000033a0aaa037a0 RBX: 0000000000000004 RCX: ffffffffffffff80
Jan  5 03:41:25 cc-cdfusion-obwind-x86-compute-4 kernel: RDX: ffff8b793efc0000 RSI: 0000000000000080 RDI: 0000000000000047
Jan  5 03:41:25 cc-cdfusion-obwind-x86-compute-4 kernel: RBP: ffff8bf44f8d7800 R08: 0000000000000001 R09: 0000000000000000
Jan  5 03:41:25 cc-cdfusion-obwind-x86-compute-4 kernel: R10: 0000000000000000 R11: ffff9ffb351f7d18 R12: 0000000000000020
Jan  5 03:41:25 cc-cdfusion-obwind-x86-compute-4 kernel: R13: 0000000000000010 R14: 0000000000000000 R15: 0000000000000000
Jan  5 03:41:25 cc-cdfusion-obwind-x86-compute-4 kernel: FS:  00007f6ba8ff9700(0000) GS:ffff8bd93f980000(0000) knlGS:0000000000000000
Jan  5 03:41:25 cc-cdfusion-obwind-x86-compute-4 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Jan  5 03:41:25 cc-cdfusion-obwind-x86-compute-4 kernel: CR2: 000000c000220000 CR3: 000000fcfb0c0000 CR4: 00000000003506e0
Jan  5 03:41:25 cc-cdfusion-obwind-x86-compute-4 kernel: Call Trace:
Jan  5 03:41:25 cc-cdfusion-obwind-x86-compute-4 kernel: memcg_numa_stat_show+0x16f/0x1f0
Jan  5 03:41:25 cc-cdfusion-obwind-x86-compute-4 kernel: seq_read+0x14a/0x3e0
Jan  5 03:41:25 cc-cdfusion-obwind-x86-compute-4 kernel: vfs_read+0x89/0x130
Jan  5 03:41:25 cc-cdfusion-obwind-x86-compute-4 kernel: ksys_read+0x5a/0xd0
Jan  5 03:41:25 cc-cdfusion-obwind-x86-compute-4 kernel: do_syscall_64+0x5b/0x1e0
Jan  5 03:41:25 cc-cdfusion-obwind-x86-compute-4 kernel: entry_SYSCALL_64_after_hwframe+0x44/0xa9
Jan  5 03:41:25 cc-cdfusion-obwind-x86-compute-4 kernel: RIP: 0033:0x42348e
Jan  5 03:41:25 cc-cdfusion-obwind-x86-compute-4 kernel: Code: 48 89 6c 24 38 48 8d 6c 24 38 e8 0d 00 00 00 48 8b 6c 24 38 48 83 c4 40 c3 cc cc cc 49 89 f2 48 89 fa 48 89 ce 48 89 df 0f 05 <48> 3d 01 f0 ff ff 76 15 48 f7 d8 48 89 c1 48 c7 c0 ff ff ff ff 48
Jan  5 03:41:25 cc-cdfusion-obwind-x86-compute-4 kernel: RSP: 002b:000000c001324318 EFLAGS: 00000202 ORIG_RAX: 0000000000000000
Jan  5 03:41:25 cc-cdfusion-obwind-x86-compute-4 kernel: RAX: ffffffffffffffda RBX: 0000000000000034 RCX: 000000000042348e
Jan  5 03:41:25 cc-cdfusion-obwind-x86-compute-4 kernel: RDX: 0000000000001000 RSI: 000000c00217f000 RDI: 0000000000000034
Jan  5 03:41:25 cc-cdfusion-obwind-x86-compute-4 kernel: RBP: 000000c001324358 R08: 0000000000000000 R09: 0000000000000000
Jan  5 03:41:25 cc-cdfusion-obwind-x86-compute-4 kernel: R10: 0000000000000000 R11: 0000000000000202 R12: 000000c0013245b8
Jan  5 03:41:25 cc-cdfusion-obwind-x86-compute-4 kernel: R13: 0000000000000000 R14: 000000c000a49520 R15: 0000000000000080
```

软死锁的问题，没有 coredump ，先分析一下日志，和相关代码的上下文，并画一些图理清一下思路。

rpm2cpio kernel-debuginfo-xxx.x86_64.rpm|cpio -idv

在 orgmode 当中可以用 begin_quote 来写类似 markdown &gt; 的引用文本。<https://emacs-china.org/t/markdown-org/28323>

```nil
./faddr2line vmlinux memcg_numa_stat_show+0x16f/0x1f0
memcg_numa_stat_show+0x16f/0x1f0:
memcg_numa_stat_show 于 mm/memcontrol.c:4396 (discriminator 2)
```

```c { linenos=true, linenostart=4358 }
static int memcg_numa_stat_show(struct seq_file *m, void *v)
{
        struct numa_stat {
                const char *name;
                unsigned int lru_mask;
        };

        static const struct numa_stat stats[] = {
                { "total", LRU_ALL },
                { "file", LRU_ALL_FILE },
                { "anon", LRU_ALL_ANON },
                { "unevictable", BIT(LRU_UNEVICTABLE) },
        };
        const struct numa_stat *stat;
        int nid;
        unsigned long nr;
        struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));

        for (stat = stats; stat < stats + ARRAY_SIZE(stats); stat++) {
                nr = mem_cgroup_nr_lru_pages(memcg, stat->lru_mask);
                seq_printf(m, "%s=%lu", stat->name, nr);
                for_each_node_state(nid, N_MEMORY) {
                        nr = mem_cgroup_node_nr_lru_pages(memcg, nid,
                                                          stat->lru_mask);
                        seq_printf(m, " N%d=%lu", nid, nr);
                }
                seq_putc(m, '\n');
        }

        for (stat = stats; stat < stats + ARRAY_SIZE(stats); stat++) {
                struct mem_cgroup *iter;

                nr = 0;
                for_each_mem_cgroup_tree(iter, memcg)
                        nr += mem_cgroup_nr_lru_pages(iter, stat->lru_mask);
                seq_printf(m, "hierarchical_%s=%lu", stat->name, nr);
                for_each_node_state(nid, N_MEMORY) {
                        nr = 0;
                        for_each_mem_cgroup_tree(iter, memcg)
                                nr += mem_cgroup_node_nr_lru_pages(
                                        iter, nid, stat->lru_mask);
                        seq_printf(m, " N%d=%lu", nid, nr);
                }
                seq_putc(m, '\n');
        }

        return 0;
}
#endif /* CONFIG_NUMA */
```

for_each_mem_cgroup_tree(iter, memcg) ，这个是在 4396 行。

RIP: 0010:mem_cgroup_node_nr_lru_pages+0x99/0xf0

-   0x0010 — 内核代码段（Kernel Code Segment）

这是最常见的段选择符之一，通常用于内核代码段。它是内核代码执行时使用的段选择符，用于指向操作系统的内核代码部分。

-   0x0020 — 内核数据段（Kernel Data Segment）

这个段选择符指向内核数据段，通常用于访问内核中的全局变量、静态数据和堆栈等。

-   0x0030 — 内核堆栈段（Kernel Stack Segment）

用于指向内核堆栈区域。每个内核线程或进程都有独立的堆栈，用于存储函数调用信息、局部变量等。

-   0x0040 — 用户代码段（User Code Segment）

这个段选择符通常用于用户空间的代码段。尽管现代操作系统大多采用平坦的内存模型（没有显式的段界限），这个选择符依然可能出现在一些历史代码或特定的段模型中。

-   0x0050 — 用户数据段（User Data Segment）

类似于用户代码段，这个选择符指向用户空间的数据段，通常用于访问进程的全局变量、堆数据等。

-   0x0060 — 用户堆栈段（User Stack Segment）

这个段选择符指向用户空间的堆栈区域，用于存储进程的堆栈数据。

-   0x08 — TSS（任务状态段，Task State Segment）

在操作系统中，TSS 用于存储任务的状态，包括寄存器的保存和恢复等。当发生任务切换时，操作系统使用 TSS 来保存和加载任务的上下文。段选择符 0x08 通常指向 TSS。

```nil
./faddr2line vmlinux mem_cgroup_node_nr_lru_pages+0x99/0xf0
mem_cgroup_node_nr_lru_pages+0x99/0xf0:
lruvec_page_state_local 于 include/linux/memcontrol.h:772
(已内连入)mem_cgroup_node_nr_lru_pages 于 mm/memcontrol.c:4339
```

是在内核代码段出的问题。

```c { linenos=true, linenostart=4327 }
static unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
                                           int nid, unsigned int lru_mask)
{
        struct lruvec *lruvec = mem_cgroup_lruvec(memcg, NODE_DATA(nid));
        unsigned long nr = 0;
        enum lru_list lru;

        VM_BUG_ON((unsigned)nid >= nr_node_ids);

        for_each_lru(lru) {
                if (!(BIT(lru) & lru_mask))
                        continue;
                nr += lruvec_page_state_local(lruvec, NR_LRU_BASE + lru);
        }
        return nr;
}
```

函数调用关系： nr += lruvec_page_state_local(lruvec, NR_LRU_BASE + lru); 这一行出的问题。

```c { linenos=true, linenostart=761 }
static inline unsigned long lruvec_page_state_local(struct lruvec *lruvec,
                                                    enum node_stat_item idx)
{
        struct mem_cgroup_per_node *pn;
        long x = 0;
        int cpu;

        if (mem_cgroup_disabled())
                return node_page_state(lruvec_pgdat(lruvec), idx);

        pn = container_of(lruvec, struct mem_cgroup_per_node, lruvec);
        for_each_possible_cpu(cpu)
                x += per_cpu(pn->lruvec_stat_local->count[idx], cpu);
#ifdef CONFIG_SMP
        if (x < 0)
                x = 0;
#endif
        return x;
}
```

```nil
memcg_numa_stat_show
  for_each_node_state(nid, N_MEMORY)
    mem_cgroup_node_nr_lru_pages(iter, nid, stat->lru_mask);
      lruvec_page_state_local(lruvec, NR_LRU_BASE + lru);
        for_each_possible_cpu(cpu);
```

RIP 是卡在了：for_each_possible_cpu(cpu) 这一行。

```c
#define for_each_cpu(cpu, mask)                 \
        for ((cpu) = 0; (cpu) < 1; (cpu)++, (void)mask)
...

#define for_each_possible_cpu(cpu) for_each_cpu((cpu), cpu_possible_mask)


```

关系图像：

让 AI 帮忙解析一下两个 code 处的汇编代码：

-   一

<!--listend-->

```nil
41 89 dc            -> mov    DWORD PTR [r12-0x24], ebx
bf ff ff ff ff       -> mov    edi, 0xffffffff
45 31 ff             -> xor    r15d, r15d
49 c1 e4 03          -> shl    r12, 0x3
eb 19                -> jmp    0x19
48 63 d7             -> movsxd rbx, edi
4c 89 e0             -> mov    rax, r12
48 03 85 88 00 00 00 -> add    rax, QWORD PTR [rbp+0x88]
48 8b 14 d5 a0 77 b7 99  -> mov    rdx, QWORD PTR [rbp+0x99b777a0]
4c 03 3c 10          -> add    r15, QWORD PTR [rsi+rdx]
48 c7 c6 e0 fb e7 99 -> mov    rsi, 0x99e7fbe0
e8 5b 5f 6b 00       -> call   0x6b5f5b
3b 05 b9 88 1c 01    -> cmp    eax, DWORD PTR [0x1c88b9]
89 c7                -> mov    edi, eax
72 d1                -> jb     0xd1

1.mov DWORD PTR [r12-0x24], ebx：将 ebx 寄存器的值存储到 [r12-0x24] 位置。
2.mov edi, 0xffffffff：将 0xffffffff 的值加载到 edi 寄存器。
3.xor r15d, r15d：将 r15d 寄存器清零。
4.shl r12, 0x3：将 r12 寄存器的值左移 3 位（乘以 8）。
5.jmp 0x19：跳转到偏移量 0x19 处继续执行。
6.movsxd rbx, edi：将 edi 寄存器的符号扩展值加载到 rbx 中。
7.mov rax, r12：将 r12 寄存器的值加载到 rax。
8.add rax, QWORD PTR [rbp+0x88]：将 [rbp+0x88] 中的值加到 rax 寄存器中。
9.mov rdx, QWORD PTR [rbp+0x99b777a0]：将 [rbp+0x99b777a0] 中的值加载到 rdx 寄存器中。
10.add r15, QWORD PTR [rsi+rdx]：将 [rsi+rdx] 中的值加到 r15 寄存器。
11.mov rsi, 0x99e7fbe0：将 0x99e7fbe0 的值加载到 rsi 寄存器。
12.call 0x6b5f5b：调用偏移地址 0x6b5f5b 的函数。
13.cmp eax, DWORD PTR [0x1c88b9]：将 eax 寄存器的值与地址 0x1c88b9 中的值进行比较。
14.mov edi, eax：将 eax 寄存器的值移动到 edi 寄存器。
15.jb 0xd1：如果上一个比较结果小于（below），则跳转到 0xd1。
```

-   二

<!--listend-->

```nil
48 89 6c 24 38        -> mov    QWORD PTR [rsp+0x38], rbp
48 8d 6c 24 38        -> lea    rbx, [rsp+0x38]
e8 0d 00 00 00        -> call   0x0d
48 8b 6c 24 38        -> mov    rbp, QWORD PTR [rsp+0x38]
48 83 c4 40           -> add    rsp, 0x40
c3                     -> ret
cc cc cc               -> int3 (断点指令)
49 89 f2               -> mov    r10, rsi
48 89 fa               -> mov    rdx, rdi
48 89 ce               -> mov    rsi, rcx
48 89 df               -> mov    rdi, rbx
0f 05                  -> syscall
48 3d 01 f0 ff ff      -> cmp    rax, 0xfffff001
76 15                  -> jbe    0x15
48 f7 d8               -> neg    rax
48 89 c1               -> mov    rcx, rax
48 c7 c0 ff ff ff ff    -> mov    rax, 0xffffffff
48                     -> (该字节为机器码中的单个字节)

1.mov 指令：将数据从一个位置移动到另一个位置。例如，mov [rsp+0x38], rbp 表示将 rbp 的值存储到 rsp + 0x38 地址。
2.lea 指令：获取有效地址，lea rbx, [rsp+0x38] 表示将 rsp + 0x38 的地址加载到 rbx 中。
3.call：调用函数或子程序，call 0x0d 表示调用偏移量为 0x0d 的函数。
4.add 和 mov：修改寄存器值或操作堆栈指针（rsp）。
5.syscall：系统调用，syscall 指令触发系统调用。
6.cmp 和 jbe：比较两个寄存器的值，并根据条件进行跳转，cmp rax, 0xfffff001 比较 rax 寄存器与 0xfffff001，jbe 在比较结果满足条件时跳转。
7.neg：对寄存器的值取反，即求负值
```


## call trace 2 {#call-trace-2}

出问题的机器不停的在报 call trace ，出现的 call trace 主要就两个栈，还有一种是下面这个，cpu_stop_queue_work+0xf0/0xf0 的情况，可以看一下3155 行这个 call trace ，它打印的：

```nil
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: watchdog: BUG: soft lockup - CPU#16 stuck for 22s! [migration/16:92]
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: Modules linked in: ebt_arp ebt_among ip6table_raw xt_CT xt_mac ebtable_nat xt_physdev xt_multiport ipt_rpfilter iptable_raw ip_set_hash_ip ip_set_hash_net veth ipip tunnel4 ip_tunnel wireguard ip6_udp_tunnel udp_tunnel nf_conntrack_netlink xt_addrtype xt_set ip_set_hash_ipportnet ip_set_hash_ipportip ip_set_bitmap_port ip_set_hash_ipport ip_set nbd rbd libceph dns_resolver dummy nf_tables nfnetlink ip6t_MASQUERADE ip6table_nat nf_nat_ipv6 ip6table_mangle xt_mark xt_comment fuse xt_CHECKSUM iptable_mangle ipt_MASQUERADE iptable_nat nf_nat_ipv4 nf_nat xt_conntrack ipt_REJECT nf_reject_ipv4 ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter overlay 8021q garp mrp bonding ib_isert iscsi_target_mod ib_srpt target_core_mod ib_srp scsi_transport_srp amd64_edac_mod edac_mce_amd
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: kvm_amd rpcrdma sunrpc rdma_ucm ib_iser ib_umad rdma_cm ib_ipoib iw_cm ipmi_ssif libiscsi kvm scsi_transport_iscsi ib_cm irqbypass crct10dif_pclmul crc32_pclmul ghash_clmulni_intel rapl bcache pcspkr joydev crc64 ses enclosure scsi_transport_sas ccp sg i2c_piix4 k10temp sm3_generic ipmi_si ipmi_devintf ipmi_msghandler mlx5_ib acpi_cpufreq ib_uverbs ib_core vhost_net tun tap vhost_vsock vmw_vsock_virtio_transport_common vhost vsock br_netfilter bridge stp llc ip_vs_sh ip_vs_wrr ip_vs_rr ip_vs nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 ip_tables sd_mod ast i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm mlx5_core ixgbe crc32c_intel ahci drm nvme libahci nvme_core libata megaraid_sas dca mlxfw dm_mirror dm_region_hash dm_log dm_mod
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: CPU: 16 PID: 92 Comm: migration/16 Kdump: loaded Tainted: G             L    4.19.0-91.77.77.5.uelc20.x86_64 #1
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: Hardware name:  SH201-D12RE/62DB32 Rev 1.0, BIOS SXYH041040 07/15/2024
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: RIP: 0010:multi_cpu_stop+0x41/0xf0
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: Code: 67 9c 58 0f 1f 44 00 00 49 89 c5 48 8b 47 18 48 85 c0 0f 84 95 00 00 00 45 89 e4 4c 0f a3 20 41 0f 92 c4 45 31 f6 31 d2 f3 90 <8b> 5d 20 39 d3 74 45 83 fb 02 74 55 83 fb 03 75 05 45 84 e4 75 5b
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: RSP: 0018:ffff9ffb18fe3e88 EFLAGS: 00000246 ORIG_RAX: ffffffffffffff13
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: RAX: ffffffff99832758 RBX: 0000000000000001 RCX: dead000000000200
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: RDX: 0000000000000001 RSI: 0000000000000286 RDI: ffff9ffb35aa7bc0
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: RBP: ffff9ffb35aa7bc0 R08: 0000000000013b13 R09: 0000000000000003
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: R13: 0000000000000282 R14: 0000000000000000 R15: ffff8bb93f81d890
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: FS:  0000000000000000(0000) GS:ffff8bb93f800000(0000) knlGS:0000000000000000
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: CR2: 000056315bdc9000 CR3: 000000298860a000 CR4: 00000000003506e0
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: Call Trace:
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: ? cpu_stop_queue_work+0xf0/0xf0
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: cpu_stopper_thread+0x86/0x100
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: smpboot_thread_fn+0x10e/0x160
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: kthread+0xf8/0x130
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: ? sort_range+0x20/0x20
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: ? kthread_bind+0x10/0x10
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: ret_from_fork+0x22/0x40
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: watchdog: BUG: soft lockup - CPU#111 stuck for 22s! [kubelet:819644]
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: Modules linked in: ebt_arp ebt_among ip6table_raw xt_CT xt_mac ebtable_nat xt_physdev xt_multiport ipt_rpfilter iptable_raw ip_set_hash_ip ip_set_hash_net veth ipip tunnel4 ip_tunnel wireguard ip6_udp_tunnel udp_tunnel nf_conntrack_netlink xt_addrtype xt_set ip_set_hash_ipportnet ip_set_hash_ipportip ip_set_bitmap_port ip_set_hash_ipport ip_set nbd rbd libceph dns_resolver dummy nf_tables nfnetlink ip6t_MASQUERADE ip6table_nat nf_nat_ipv6 ip6table_mangle xt_mark xt_comment fuse xt_CHECKSUM iptable_mangle ipt_MASQUERADE iptable_nat nf_nat_ipv4 nf_nat xt_conntrack ipt_REJECT nf_reject_ipv4 ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter overlay 8021q garp mrp bonding ib_isert iscsi_target_mod ib_srpt target_core_mod ib_srp scsi_transport_srp amd64_edac_mod edac_mce_amd
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: kvm_amd rpcrdma sunrpc rdma_ucm ib_iser ib_umad rdma_cm ib_ipoib iw_cm ipmi_ssif libiscsi kvm scsi_transport_iscsi ib_cm irqbypass crct10dif_pclmul crc32_pclmul ghash_clmulni_intel rapl bcache pcspkr joydev crc64 ses enclosure scsi_transport_sas ccp sg i2c_piix4 k10temp sm3_generic ipmi_si ipmi_devintf ipmi_msghandler mlx5_ib acpi_cpufreq ib_uverbs ib_core vhost_net tun tap vhost_vsock vmw_vsock_virtio_transport_common vhost vsock br_netfilter bridge stp llc ip_vs_sh ip_vs_wrr ip_vs_rr ip_vs nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 ip_tables sd_mod ast i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm mlx5_core ixgbe crc32c_intel ahci drm nvme libahci nvme_core libata megaraid_sas dca mlxfw dm_mirror dm_region_hash dm_log dm_mod
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: CPU: 111 PID: 819644 Comm: kubelet Kdump: loaded Tainted: G             L    4.19.0-91.77.77.5.uelc20.x86_64 #1
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: Hardware name:  SH201-D12RE/62DB32 Rev 1.0, BIOS SXYH041040 07/15/2024
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: RIP: 0010:mem_cgroup_node_nr_lru_pages+0x99/0xf0
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: Code: 41 89 dc bf ff ff ff ff 45 31 ff 49 c1 e4 03 eb 19 48 63 d7 4c 89 e0 48 03 85 88 00 00 00 48 8b 14 d5 a0 77 b7 99 4c 03 3c 10 <48> c7 c6 e0 fb e7 99 e8 5b 5f 6b 00 3b 05 b9 88 1c 01 89 c7 72 d1
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: RSP: 0018:ffff9ffb37107e00 EFLAGS: 00000246 ORIG_RAX: ffffffffffffff13
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: RAX: 000033a089211820 RBX: 0000000000000004 RCX: fe00000000000000
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: RDX: ffff8c594ba40000 RSI: 0000000000000080 RDI: 0000000000000079
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: RBP: ffff8c4f51019800 R08: 0000000000000001 R09: 0000000000000000
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: R10: 0000000000000000 R11: ffff9ffb37107d18 R12: 0000000000000020
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: R13: 0000000000000010 R14: 0000000000000000 R15: 0000000000000000
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: FS:  00007f6b137fe700(0000) GS:ffff8c193fbc0000(0000) knlGS:0000000000000000
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: CR2: 000055dbec29f000 CR3: 000000fcfb0c0000 CR4: 00000000003506e0
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: Call Trace:
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: memcg_numa_stat_show+0x16f/0x1f0
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: seq_read+0x14a/0x3e0
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: vfs_read+0x89/0x130
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: ksys_read+0x5a/0xd0
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: do_syscall_64+0x5b/0x1e0
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: entry_SYSCALL_64_after_hwframe+0x44/0xa9
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: RIP: 0033:0x42348e
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: Code: 48 89 6c 24 38 48 8d 6c 24 38 e8 0d 00 00 00 48 8b 6c 24 38 48 83 c4 40 c3 cc cc cc 49 89 f2 48 89 fa 48 89 ce 48 89 df 0f 05 <48> 3d 01 f0 ff ff 76 15 48 f7 d8 48 89 c1 48 c7 c0 ff ff ff ff 48
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: RSP: 002b:000000c001872318 EFLAGS: 00000202 ORIG_RAX: 0000000000000000
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: RAX: ffffffffffffffda RBX: 0000000000000033 RCX: 000000000042348e
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: RDX: 0000000000001000 RSI: 000000c000ae9000 RDI: 0000000000000033
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: RBP: 000000c001872358 R08: 0000000000000000 R09: 0000000000000000
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: R10: 0000000000000000 R11: 0000000000000202 R12: 000000c0018725b8
Jan  5 04:01:17 cc-cdfusion-obwind-x86-compute-4 kernel: R13: 0000000000000000 R14: 000000c000a49520 R15: 0000000000000080
```

这个的调用关系如下：

```nil
ret_from_fork
  kthread_bind
    smpboot_thread_fn
      cpu_stopper_thread
        cpu_stop_queue_work
          stop_machine
```

先看一下 rip 卡住的地方：RIP: 0010:multi_cpu_stop+0x41/0xf0
./faddr2line vmlinux multi_cpu_stop+0x41/0xf0
multi_cpu_stop+0x41/0xf0:
multi_cpu_stop 于 kernel/stop_machine.c:210

卡在：if (msdata-&gt;state != curstate) { 这一行当中。

```c { linenos=true, linenostart=186 }
/* This is the cpu_stop function which stops the CPU. */
static int multi_cpu_stop(void *data)
{
        struct multi_stop_data *msdata = data;
        enum multi_stop_state curstate = MULTI_STOP_NONE;
        int cpu = smp_processor_id(), err = 0;
        unsigned long flags;
        bool is_active;

        /*
         * When called from stop_machine_from_inactive_cpu(), irq might
         * already be disabled.  Save the state and restore it on exit.
         */
        local_save_flags(flags);

        if (!msdata->active_cpus)
                is_active = cpu == cpumask_first(cpu_online_mask);
        else
                is_active = cpumask_test_cpu(cpu, msdata->active_cpus);

        /* Simple state machine */
        do {
                /* Chill out and ensure we re-read multi_stop_state. */
                cpu_relax_yield();
                if (msdata->state != curstate) {
                        curstate = msdata->state;
                        switch (curstate) {
                        case MULTI_STOP_DISABLE_IRQ:
                                local_irq_disable();
                                hard_irq_disable();
#ifdef CONFIG_ARM64
                                gic_arch_disable_irqs();
                                sdei_mask_local_cpu();
#endif
                                break;
                        case MULTI_STOP_RUN:
                                if (is_active)
                                        err = msdata->fn(msdata->data);
                                break;
                        default:
                                break;
                        }
                        ack_state(msdata);
                } else if (curstate > MULTI_STOP_PREPARE) {
                        /*
                         * At this stage all other CPUs we depend on must spin
                         * in the same loop. Any reason for hard-lockup should
                         * be detected and reported on their side.
                         */
                        touch_nmi_watchdog();
                }
        } while (curstate != MULTI_STOP_EXIT);

#ifdef CONFIG_ARM64
        sdei_unmask_local_cpu();
        gic_arch_restore_irqs(flags);
#endif
        local_irq_restore(flags);
        return err;
}
```

往上找堆栈：cpu_stop_queue_work+0xf0/0xf0

./faddr2line vmlinux cpu_stop_queue_work+0xf0/0xf0
cpu_stop_queue_work+0xf0/0xf0:
multi_cpu_stop 于 kernel/stop_machine.c:188

卡在 { ，这个看起来很奇怪。

```c { linenos=true, linenostart=187 }
/* This is the cpu_stop function which stops the CPU. */
static int multi_cpu_stop(void *data)
{
        struct multi_stop_data *msdata = data;
        enum multi_stop_state curstate = MULTI_STOP_NONE;
        int cpu = smp_processor_id(), err = 0;
        unsigned long flags;
        bool is_active;

        /*
         * When called from stop_machine_from_inactive_cpu(), irq might
         * already be disabled.  Save the state and restore it on exit.
         */
        local_save_flags(flags);
        ...
```

卡在函数的第一行。

再往上找堆栈，（其实越往上看意义越小，只是为了理解上文的流程）：

./faddr2line vmlinux smpboot_thread_fn+0x10e/0x160
smpboot_thread_fn+0x10e/0x160:
smpboot_thread_fn 于 kernel/smpboot.c:164

卡在 ht-&gt;thread_fn(td-&gt;cpu); 这一行。

```c
/**
 * smpboot_thread_fn - percpu hotplug thread loop function
 * @data:       thread data pointer
 *
 * Checks for thread stop and park conditions. Calls the necessary
 * setup, cleanup, park and unpark functions for the registered
 * thread.
 *
 * Returns 1 when the thread should exit, 0 otherwise.
 */
static int smpboot_thread_fn(void *data)
{
        struct smpboot_thread_data *td = data;
        struct smp_hotplug_thread *ht = td->ht;

        while (1) {
                set_current_state(TASK_INTERRUPTIBLE);
                preempt_disable();
                if (kthread_should_stop()) {
                        __set_current_state(TASK_RUNNING);
                        preempt_enable();
                        /* cleanup must mirror setup */
                        if (ht->cleanup && td->status != HP_THREAD_NONE)
                                ht->cleanup(td->cpu, cpu_online(td->cpu));
                        kfree(td);
                        return 0;
                }

                if (kthread_should_park()) {
                        __set_current_state(TASK_RUNNING);
                        preempt_enable();
                        if (ht->park && td->status == HP_THREAD_ACTIVE) {
                                BUG_ON(td->cpu != smp_processor_id());
                                ht->park(td->cpu);
                                td->status = HP_THREAD_PARKED;
                        }
                        kthread_parkme();
                        /* We might have been woken for stop */
                        continue;
                }

                BUG_ON(td->cpu != smp_processor_id());

                /* Check for state change setup */
                switch (td->status) {
                case HP_THREAD_NONE:
                        __set_current_state(TASK_RUNNING);
                        preempt_enable();
                        if (ht->setup)
                                ht->setup(td->cpu);
                        td->status = HP_THREAD_ACTIVE;
                 continue;

                case HP_THREAD_PARKED:
                        __set_current_state(TASK_RUNNING);
                        preempt_enable();
                        if (ht->unpark)
                                ht->unpark(td->cpu);
                        td->status = HP_THREAD_ACTIVE;
                        continue;
                }

                if (!ht->thread_should_run(td->cpu)) {
                        preempt_enable_no_resched();
                        schedule();
                } else {
                        __set_current_state(TASK_RUNNING);
                        preempt_enable();
                        ht->thread_fn(td->cpu);
                }
        }
}
```


## call trace 3 {#call-trace-3}

还有一个堆栈可以分析一下：

```nil
Jan  5 04:00:37 cc-cdfusion-obwind-x86-compute-4 kernel: RIP: 0010:find_next_bit+0x23/0x60
Jan  5 04:00:37 cc-cdfusion-obwind-x86-compute-4 kernel: Code: 0f 1f 80 00 00 00 00 48 39 d6 76 3b 49 89 d0 89 d1 48 c7 c0 ff ff ff ff 49 c1 e8 06 48 d3 e0 48 83 e2 c0 4a 23 04 c7 48 89 c1 <74> 12 eb 1d 48 89 d1 48 c1 e9 06 48 8b 0c cf 48 85 c9 75 0d 48 83
Jan  5 04:00:37 cc-cdfusion-obwind-x86-compute-4 kernel: RSP: 0018:ffff9ffb19983df0 EFLAGS: 00000286 ORIG_RAX: ffffffffffffff13
Jan  5 04:00:37 cc-cdfusion-obwind-x86-compute-4 kernel: RAX: fffffffffffffff0 RBX: 0000000000000004 RCX: fffffffffffffff0
Jan  5 04:00:37 cc-cdfusion-obwind-x86-compute-4 kernel: RDX: 0000000000000000 RSI: 0000000000000080 RDI: ffffffff99e7fbe0
Jan  5 04:00:37 cc-cdfusion-obwind-x86-compute-4 kernel: RBP: ffff8bf526e0c000 R08: 0000000000000000 R09: 0000000000000000
Jan  5 04:00:37 cc-cdfusion-obwind-x86-compute-4 kernel: R10: 0000000000000000 R11: ffff9ffb19983d18 R12: 0000000000000020
Jan  5 04:00:37 cc-cdfusion-obwind-x86-compute-4 kernel: R13: 0000000000000010 R14: 0000000000000000 R15: 0000000000000000
Jan  5 04:00:37 cc-cdfusion-obwind-x86-compute-4 kernel: FS:  00007f6bc3fff700(0000) GS:ffff8bd93fbc0000(0000) knlGS:0000000000000000
Jan  5 04:00:37 cc-cdfusion-obwind-x86-compute-4 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Jan  5 04:00:37 cc-cdfusion-obwind-x86-compute-4 kernel: CR2: 000000c003be9000 CR3: 000000fcfb0c0000 CR4: 00000000003506e0
Jan  5 04:00:37 cc-cdfusion-obwind-x86-compute-4 kernel: Call Trace:
Jan  5 04:00:37 cc-cdfusion-obwind-x86-compute-4 kernel: cpumask_next+0x17/0x20
Jan  5 04:00:37 cc-cdfusion-obwind-x86-compute-4 kernel: mem_cgroup_node_nr_lru_pages+0xa5/0xf0
Jan  5 04:00:37 cc-cdfusion-obwind-x86-compute-4 kernel: memcg_numa_stat_show+0x16f/0x1f0
Jan  5 04:00:37 cc-cdfusion-obwind-x86-compute-4 kernel: seq_read+0x14a/0x3e0
Jan  5 04:00:37 cc-cdfusion-obwind-x86-compute-4 kernel: vfs_read+0x89/0x130
Jan  5 04:00:37 cc-cdfusion-obwind-x86-compute-4 kernel: ksys_read+0x5a/0xd0
Jan  5 04:00:37 cc-cdfusion-obwind-x86-compute-4 kernel: do_syscall_64+0x5b/0x1e0
Jan  5 04:00:37 cc-cdfusion-obwind-x86-compute-4 kernel: entry_SYSCALL_64_after_hwframe+0x44/0xa9
Jan  5 04:00:37 cc-cdfusion-obwind-x86-compute-4 kernel: RIP: 0033:0x42348e
Jan  5 04:00:37 cc-cdfusion-obwind-x86-compute-4 kernel: Code: 48 89 6c 24 38 48 8d 6c 24 38 e8 0d 00 00 00 48 8b 6c 24 38 48 83 c4 40 c3 cc cc cc 49 89 f2 48 89 fa 48 89 ce 48 89 df 0f 05 <48> 3d 01 f0 ff ff 76 15 48 f7 d8 48 89 c1 48 c7 c0 ff ff ff ff 48
Jan  5 04:00:37 cc-cdfusion-obwind-x86-compute-4 kernel: RSP: 002b:000000c000dc6318 EFLAGS: 00000202 ORIG_RAX: 0000000000000000
Jan  5 04:00:37 cc-cdfusion-obwind-x86-compute-4 kernel: RAX: ffffffffffffffda RBX: 0000000000000033 RCX: 000000000042348e
Jan  5 04:00:37 cc-cdfusion-obwind-x86-compute-4 kernel: RDX: 0000000000001000 RSI: 000000c00167a000 RDI: 0000000000000033
Jan  5 04:00:37 cc-cdfusion-obwind-x86-compute-4 kernel: RBP: 000000c000dc6358 R08: 0000000000000000 R09: 0000000000000000
Jan  5 04:00:37 cc-cdfusion-obwind-x86-compute-4 kernel: R10: 0000000000000000 R11: 0000000000000202 R12: 000000c000dc65b8
Jan  5 04:00:37 cc-cdfusion-obwind-x86-compute-4 kernel: R13: 0000000000000000 R14: 000000c000a49520 R15: 0000000000000080
```

```c { linenos=true, linenostart=9 }
/**
 * cpumask_next - get the next cpu in a cpumask
 * @n: the cpu prior to the place to search (ie. return will be > @n)
 * @srcp: the cpumask pointer
 *
 * Returns >= nr_cpu_ids if no further cpus set.
 */
unsigned int cpumask_next(int n, const struct cpumask *srcp)
{
        /* -1 is a legal arg here. */
        if (n != -1)
                cpumask_check(n);
        return find_next_bit(cpumask_bits(srcp), nr_cpumask_bits, n + 1);
}
EXPORT_SYMBOL(cpumask_next);
```

卡在 22 行括号那一行。

```bash
#!/bin/bash
output_file="/var/log/rt_log.txt"
while true; do
  timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  echo "----------- $timestamp -------------" >> "$output_file"
  ps -eo pid,comm,policy|grep FF >> "$output_file";
  #ps -eLfc|grep " FF "|grep -v "grep"|awk '{print $2}'|while read line;do echo "chrt -p -o 0 "$line >> "$output_file";done
  sleep 15
done
```


## 结论 {#结论}

最终证明是这个补丁可以解决问题，看来是内核函数执行效率低导致的 softlock ，这种问题是一种很典型的软锁问题！

```nil
commit e2ab04ccd47860da26895878c3a6eebed873d2cd
Author: Shakeel Butt <shakeelb@google.com>
Date:   Fri Aug 6 15:29:31 2021 +0800

    mm/memcg: optimize memory.numa_stat like memory.stat

    mainline inclusion
    from mainline-v5.8-rc1
    commit dd8657b6c1cb5e65b13445b4a038736e81cf80ea
    CVE: NA
    BugFix: UBXC000117

    --------------------------------

    Currently reading memory.numa_stat traverses the underlying memcg tree
    multiple times to accumulate the stats to present the hierarchical view of
    the memcg tree.  However the kernel already maintains the hierarchical
    view of the stats and use it in memory.stat.  Just use the same mechanism
    in memory.numa_stat as well.

    I ran a simple benchmark which reads root_mem_cgroup's memory.numa_stat
    file in the presense of 10000 memcgs.  The results are:

    Without the patch:
    $ time cat /dev/cgroup/memory/memory.numa_stat > /dev/null

    real    0m0.700s
    user    0m0.001s
    sys     0m0.697s

    With the patch:
    $ time cat /dev/cgroup/memory/memory.numa_stat > /dev/null

    real    0m0.001s
    user    0m0.001s
    sys     0m0.000s

    [akpm@linux-foundation.org: avoid forcing out-of-line code generation]
    Signed-off-by: Shakeel Butt <shakeelb@google.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
    Acked-by: Johannes Weiner <hannes@cmpxchg.org>
    Cc: Roman Gushchin <guro@fb.com>
    Cc: Michal Hocko <mhocko@kernel.org>
    Link: http://lkml.kernel.org/r/20200304022058.248270-1-shakeelb@google.com
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

    Conflicts:
            mm/memcontrol.c

    Signed-off-by: Jing Xiangfeng <jingxiangfeng@huawei.com>
    Reviewed-by: Kefeng Wang <wangkefeng.wang@huawei.com>
    Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
```
