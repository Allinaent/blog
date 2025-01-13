+++
title = "用 alias 安装一常用脚本的例子"
date = 2025-01-13T11:43:00+08:00
lastmod = 2025-01-13T12:45:04+08:00
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
