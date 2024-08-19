+++
title = "服务器内核打包过程"
date = 2024-08-05T13:18:00+08:00
lastmod = 2024-08-06T10:56:22+08:00
categories = ["kernel"]
draft = false
toc = true
image = "https://r2.guolongji.xyz/allinaent/2024/06/92a1feeab471b12646b9c76edccc1546.jpg"
+++

## Linux操作系统使用RPMBUILD命令打包RPM的详细步骤 {#linux操作系统使用rpmbuild命令打包rpm的详细步骤}

<https://www.cnblogs.com/zhangxinglong/p/11904922.html>

<https://gerrit-dev.uniontech.com/admin/repos/Kernel-rpmbuild>

4.19.90.2407 e 版。

4.19.0.91.82 a 版。

4.19.0.91.77 c 版。源码与a 一样。

今天终于弄懂了 rpm 打包的大致流程。核心的原理是与 debian 差不多的。像是 automake autoconfig
这样的八股文。

rpm 和 dpkg 打包都不是基于 git 。问了一下 GPT ，它的回答是这样的：

Debian 和 Red Hat 打包的过程确实没有直接基于 Git，而是使用特定的工具和流程来管理和构建软件包。这种做法有其历史和技术原因：

稳定性和可靠性： Debian 和 Red Hat 等主流 Linux 发行版的软件包管理者通常更倾向于使用稳定、经过验证的软件版本。尽管 Git 是一个非常强大和流行的版本控制系统，但它的发展速度和更新频率可能会导致某些稳定性和可靠性的担忧。因此，软件包的管理者更倾向于使用稳定的软件版本发布作为构建和打包的基础，而不是直接从 Git 中获取。

打包工具和流程： Debian 使用的是 debhelper 和 dpkg，而 Red Hat 则使用 rpmbuild 和 rpm 等工具来构建和管理软件包。这些工具和流程已经深度集成到各个发行版的软件包管理系统中，包括依赖解析、版本控制、补丁管理等功能。尽管可以使用 Git 来管理软件源代码，但软件包的构建和发布流程通常独立于版本控制系统的使用。

稳定的软件库和更新策略： Debian 和 Red Hat 都有严格的软件包更新策略和安全政策，以确保软件包的稳定性和安全性。他们通常会选择已经经过验证和测试的软件版本，而不是直接使用开发中的 Git 版本。这种选择是为了降低软件包引入新问题和不稳定性的风险。

尽管如此，Git 仍然在开发过程中发挥着重要作用，特别是在软件开发团队中和开源社区中。开发者可以使用 Git 来管理和协作开发代码，然后将稳定版本发布到适当的软件包管理系统中。

因此，尽管 Git 很好用且广泛使用，但在构建和管理主流 Linux 发行版中的软件包时，传统的打包工具和流程仍然是首选，以确保软件包的稳定性、可靠性和安全性。


## 操作过程 {#操作过程}

打包过程需要源码和 patch ，为了这些 patch 创建了一个项目，叫 Kernel-rpmbuild ，里面的内容是这样的：

```nil
uos@guolongji:~/gg/Kernel-rpmbuild/lts-4.19/tyy-1060u1a/SOURCES$ ls
9001-Revert-UOS-add-SM2-SM3-SM4-support.patch  filter-s390x.sh                                   kernel-x86_64.config        Module.kabi_loongarch64
btf-encrypt-public-key.pem                     filter-x86_64.sh                                  kernel-x86_64-debug.config  Module.kabi_ppc64le
centos-ca-secureboot.der                       generate_all_configs.sh                           mod-extra-blacklist.sh      Module.kabi_s390x
centos.pem                                     generate_bls_conf.sh                              mod-extra.list              Module.kabi_x86_64
centossecureboot001.crt                        kernel-aarch64.config                             mod-extra.sh                Module.kabi_x86_64_cj7
check-kabi                                     kernel-aarch64-debug.config                       mod-sign.sh                 parallel_xz.sh
cpupower.config                                kernel-abi-whitelists-4.19.0-91.152.28.1.tar.bz2  Module.kabi_aarch64         process_configs.sh
cpupower.service                               kernel-kabi-dw-4.19.0-91.152.28.1.tar.bz2         Module.kabi_aarch64_cj7     uefi-db-rsa.crt
filter-aarch64.sh                              kernel-loongarch64.config                         Module.kabi_dup_aarch64     UOS-scripts-check-kabi-denpend-on-python3-on-centos8.patch
filter-loongarch64.sh                          kernel-loongarch64-debug.config                   Module.kabi_dup_ppc64le     UOS-UEFI-RSA.pem
filter-modules.sh                              kernel-ppc64le.config                             Module.kabi_dup_s390x       x509.genkey
filter-ppc64le.sh                              kernel-ppc64le-debug.config                       Module.kabi_dup_x86_64
```

而我还差的就是一个内核源码的压缩包。这个压缩包是这样来的。

```bash
git archive -o linux.tar --format=tar glj-tmp-1
mkdir linux-4.19.0-91.152.28.2
mv linux.tar linux-4.19.0-91.152.28.2; tar xvf -C linux-4.19.0-91.152.28.2;
tar -cJf linux-4.19.0-91.152.28.2.tar.xz linux-4.19.0-91.152.28.2/
```

然后这个 tar.xz 包就制做好了。

将这两个 kernel-abi-whitelists-4.19.0-91.152.28.1.tar.bz2 ，kernel-kabi-dw-4.19.0-91.152.28.1.tar.bz2 版本号改一下。

最后：rpmbuild -ba kernel.spec --define="_topdir /root/glj/tyy-1060u1a"

编包结束。

rpm -q --requires ./kernel-4.19.0-91.82.152.28.2.uelc20.loongarch64.rpm

原来 kernel 包是一个虚包，要替换内核只需要将生成 kernel-core 包和 kernel-headers 包就可以了。是不是需要更新 grub 呢？

vim /boot/grub/grubenv

修改其中的内核版本号。然后重起就会使用新的内核了。


## 想查看压缩包的目录结构 {#想查看压缩包的目录结构}

tar tJvf linux-4.19.0-91.152.28.2.tar.xz |head -n 10

J 换成 z 就是查看 tar.gz 的。

J 去掉就是查看 tar 包的。
