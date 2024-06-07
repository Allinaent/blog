+++
title = "AppArmor"
date = 2024-01-03T14:03:00+08:00
lastmod = 2024-06-06T16:01:12+08:00
categories = ["technology"]
draft = false
toc = true
image = "https://r2.guolongji.xyz/allinaent/2024/06/1f2393d0488363e89799334dd190ce06.png"
+++

## 是什么？ {#是什么}

管控应用对资源的访问。对文件，网络，linux Capability ，D-Bus ，signal ，rlimit

通过配置文件。

{{< figure src="/ox-hugo/img_20240103_140715.jpg" alt="Caption not used as alt text" caption="<span class=\"figure-number\">Figure 1: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}


## 启用 {#启用}

sudo apt install apparmor apparmor-utils  apparmor-profiles apparmor-easyprof


## 查看状态 {#查看状态}

sudo aa-status

这个是基于路径的。


## 写策略 {#写策略}

写一个 /tmp/ls 来举个例子。

sudo vim /etc/apparmor.d/tmp.ls

```nil
/tmp/ls { # (complain) 去掉是强制模式。
        # rules 目录需要以 / 结尾
        /etc/ld.so.cache r,
        /usr/lib/x86_64-linux-gnu/libc-2.28.so rm,
        /usr/lib/x86_64-linux-gnu/* rm,
        /home/uos/ r,
        /proc/filesystems r,
        /usr/lib/locale/locale-archive r,
}
```

sudo apparmor_parser -r /etc/apparmor.d/tmp.ls 把规则加载到内核当中。

sudo systemctl start auditd

sudo tail -f 查看审计日志。

也可以自动生成规则：

sudo aa-gen


## 使用的技术 {#使用的技术}

{{< figure src="/ox-hugo/img_20240103_142639.jpg" alt="Caption not used as alt text" caption="<span class=\"figure-number\">Figure 2: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}

flex 举例， sudo apt install flex

vim test.flex

```nil
{%
        #include <stdio.h>
%}

[0-9]+ {printf("NUMBER\n");
[a-zA-Z] {printf("WORLD\n");}
exit (yy_terminate();)


int yy_wrap(){
        return 1;
}
int main() {
        yy_lex();
        return 1;
}
```

flex test.flex ，词法解析的结果会喂绐语法解析的程序。

vim parse.yacc

vim scan.lex

就会得到一个配置文件解析的工具。


## apparmor 使用的另外的技术 {#apparmor-使用的另外的技术}

状态机。

{{< figure src="/ox-hugo/img_20240103_144517.jpg" alt="Caption not used as alt text" caption="<span class=\"figure-number\">Figure 3: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}

状态机的性能非常好，可以对状态机生成的表格做一下压缩。

缺点：每个应用都需要配置，无法防止重命名，grub 中可以禁用 apparmor 。

apparmor 是设置应用的资源权限。UOS 做了简化，做了一个 filearmor ，对文件的权限做管控。

还可以对摄像头做管控。对 /dev/video0 做管控即可。

{{< figure src="/ox-hugo/img_20240103_145700.jpg" >}}
