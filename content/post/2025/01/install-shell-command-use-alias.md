+++
title = "用 alias 安装一常用脚本的例子"
date = 2025-01-13T11:43:00+08:00
lastmod = 2025-01-13T15:13:40+08:00
categories = ["kernel"]
draft = false
toc = true
image = "https://r2.guolongji.xyz/allinaent/2024/06/e6104c843f0ccfcf964a9d1e4e42dca7.png"
+++

faddr2line 这个脚本分析内核函数栈的时候经常使用：

```bash
alias ljfaddr2line="sudo bash -c 'if ! [ -f /usr/bin/faddr2line ];then wget -P /usr/bin https://r2.guolongji.xyz/faddr2line;chmod +x /usr/bin/faddr2line; else :; fi'"
```

把这个写成 alias 的话，我可以在任意通过 ssh 连接的机器上使用 ljfaddr2line 来安装脚本，非常地方便。

调试的时候发现：

```nil
faddr2line vmlinux memcg_numa_stat_show+0x16f/0x1f0
memcg_numa_stat_show+0x16f/0x1f0:
?? ??:0
```

找不到符号。但是用对应版本的 script/faddr2line 是能解析对的：

```nil
./faddr2line vmlinux memcg_numa_stat_show+0x16f/0x1f0
memcg_numa_stat_show+0x16f/0x1f0:
memcg_numa_stat_show 于 mm/memcontrol.c:4396 (discriminator 2)
```

看来这个脚本并不能通用，失败了。但是一些通用的脚本是可以像上面的方法那样子做一个远程安装的。还是有一些意义的。
