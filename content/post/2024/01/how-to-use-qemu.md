+++
title = "如何命令行使用qemu 和为调试增加串口输出到终端"
date = 2024-01-30T16:33:00+08:00
lastmod = 2024-06-06T13:18:52+08:00
categories = ["kernel"]
draft = false
toc = true
image = "https://r2.guolongji.xyz/allinaent/2024/06/92a1feeab471b12646b9c76edccc1546.jpg"
+++

## 查找的一些资料 {#查找的一些资料}

命令安装 qemu 虚拟机。

sudo apt -y install libvirt0 libvirt-daemon qemu virt-manager bridge-utils libvirt-clients
python-libvirt qemu-efi uml-utilities virtinst qemu-system-mips

<https://unix.stackexchange.com/questions/587045/convert-libvirt-xml-into-qemu-command-line>

<https://blog.csdn.net/YuZhiHui_No1/article/details/53909925>

```bash
virsh domxml-to-native qemu-argv /etc/libvirt/qemu/generic.xml
```

这个命令可以将 xml 配置的起动命令导出成命令行。

当然也可以这么启动：

virsh list --all

virsh generic

virsh console generic


### ps -fA | cat {#ps-fa-cat}

这个命令可以看到程序起动时的信息。也是一个常用的命令。


## mips 虚拟机最终的启动命令 {#mips-虚拟机最终的启动命令}

```bash
qemu-system-mips64el -m 4G -smp 2 -cpu Loongson-3A4000-COMP -machine loongson7a_v1.0 \
-enable-kvm \
-bios /usr/share/qemu/ls3a_bios.bin \
-device nec-usb-xhci,id=xhci,addr=0x1b \
-device usb-tablet,id=tablet,bus=xhci.0,port=1 \
-device usb-kbd,id=keyboard,bus=xhci.0,port=2 \
-device ahci,id=ahci \
-device ide-hd,drive=disk,bus=ahci.0 \
-drive id=disk,file=/var/lib/libvirt/images/generic.qcow2,if=none -vga qxl -serial stdio
```

起动后，要手动修改起动的盘 vda3 变成 sda3 ，还有 console=ttyS0,115200 。

好了，这样就能够图形和串口同时起动了。

在虚拟机中 root 用户 echo 1 &gt; /dev/ttyS0 ，这样就能看到机器的串口，同时也起动图形程序了。

还有学会去别的官网找到东西：

<http://docs.loongnix.cn/kvm/kvm/loongarch-kvm/use-qemu-command/qemu%E5%91%BD%E4%BB%A4%E5%90%AF%E5%8A%A8%E8%99%9A%E6%8B%9F%E6%9C%BA.html>


## 另一篇文档总结 pgv-虚拟机使用指导 {#另一篇文档总结-pgv-虚拟机使用指导}

1.安装系统

PanguV-WBY0B-5.7.0.50_c233.iso

2.更新固件

双击安装 hw-pv-updateapp_1.0.101_arm64.deb，按提示进行固件更新。

安装完成后，重启；

重启后，终端执行 ls /dev/kvm，如果没有这个文件，则需要替换/boot/kernel

3.替换 kernel

开启 sudo 权限，终端执行以下命令：

sudo mount -o remount,rw /boot

sudo su

rm /boot/kernel

cp /home/uos/kernel /boot/kernel

chmod +x /boot/kernel

重启

4.安装虚拟机

1)准备文件

将 QEMU_EFI_orig.fd、qemu-7.0.0.tar.xz、uniontechos-desktop-20-professional-1050-update4-arm64.iso 这三个文件放在用户目录下

{{< figure src="/ox-hugo/img_20240131_144137.jpg" alt="Caption not used as alt text" caption="<span class=\"figure-number\">Figure 1: </span>_准备_" link="t" class="fancy" width="900" target="_blank" >}}

2)安装依赖组件

sudo apt -y install libvirt0 libvirt-daemon qemu virt-manager bridge-utils libvirt-clients python-libvirt
qemu-efi uml-utilities virtinst qemu-system ninja-build make gcc g++

ps: 需要激活系统后执行命令，如果无法下载，将/etc/apt/source.list 中的 eagle/sp2 改为 eagle-pro，然后执行 sudo apt update 之后，再进行上述安装命令。

3)安装 QEMU

解压源码包：tar xvJf qemu-7.0.0.tar.xz

编译 qemu，依次执行：

cd qemu-7.0.0

./configure --target-list=aarch64-softmmu

make -j8

4)安装 vncviewer

执行 sudo apt install xtightvncviewer，安装 vncviewer。此工具可提供 guest 虚拟机窗口。

5)创建 qcow2 镜像

执行如下命令创建一个 qcow2 镜像：

qemu-img create -f qcow2 test.qcow2 80G

此命令创建一个 80G 的空间供 guest 虚拟机使用。

6)向 qcow2 镜像中安装 arm 系统

打开终端，执行：

./qemu-7.0.0/build/qemu-system-aarch64 -nodefaults -m 4G -machine virt,virtualization=off,its=off,gic-version=3
-enable-kvm -cpu host -smp 8 -bios ./QEMU_EFI_orig.fd -device nec-usb-xhci -device usb-kbd -device usb-tablet
-device usb-storage,drive=install -drive if=none,id=install,format=raw,media=cdrom,
file=./uniontechos-desktop-20-professional-1050-update4-arm64.iso -device ramfb -vnc :1 -serial stdio
-device ahci,id=ahci -device ide-hd,drive=disk,bus=ahci.0 -drive id=disk,if=none,file="./test.qcow2"

执行完上述命令后，尽快新打开一个终端窗口，输入：xtightvncviewer -bgr233 localhost:1，可显示系统安装的图形化界面。

按照安装提示进行系统安装，安装完成后，点击重启，然后按 ctrl + c，

退出 qemu-system-aarch64 命令

5.启动虚拟机

终端执行：

./qemu-7.0.0/build/qemu-system-aarch64 -nodefaults -m 4G -machine virt,virtualization=off,its=off,
gic-version=3  -enable-kvm -cpu host -smp 8 -bios ./QEMU_EFI_orig.fd -device nec-usb-xhci
-device usb-kbd -device usb-tablet -device usb-storage,drive=install -drive if=none,id=install,format=qcow2,
file=./test.qcow2 -device ramfb -vnc :1 -serial stdio

执行完上述命令后，尽快新打开一个终端窗口，输入：xtightvncviewer -bgr233 localhost:1，可显示系统的图形化界面。


## iso 替换内核 {#iso-替换内核}

修改镜像内核包方法(下述以 mips 为例)


### 准备一个原始镜像文件并解压 {#准备一个原始镜像文件并解压}

```nil
uos@uos-PC:~/work1$ ls
uos-desktop-20-professional-1061-mips64el.iso
```

安装 xorriso 命令，将镜像解压

```nil
uos@uos-PC:~/work1$ xorriso -osirrox on -indev uos-desktop-20-professional-1061-mips64el.iso -extract / work

uos@uos-PC:~/work1$ ls
uos-desktop-20-professional-1061-mips64el.iso  work
```


### 更换内核 {#更换内核}

安装 squashfs-tools 命令

注意：

执行此步骤需要通过 chroot 命令进入解压出来的模板镜像中的系统环境，在里面执行的命令都是环境中的二进制文件，所以需要保证执行这一步的时候需要在对应的平台上进行，否则无法正常操作，如 ARM64 需要在飞腾或者鲲鹏设备上进行。

内核包应该有三个文件文件名分别为： linux-image-**、 linux-headers-** 、 linux-libc-dev-\*。更新替换内核时请使用相同的版本。

inux-image-dbg-\*这个包如非必要，请不要装上。


### 解压磁盘镜像数据并挂载 {#解压磁盘镜像数据并挂载}

```nil
#进入live目录
uos@uos-PC:~/work1$ cd work/live/
uos@uos-PC:~/work1/work/live$ ls
filesystem.packages  filesystem.packages-remove  filesystem.size  filesystem.squashfs  filesystem.squashfs_sign

#对 squashfs 格式的镜像数据操作需要在root权限下操作，需要先提权：
uos@uos-PC:~/work1/work/live$ sudo su

#解压磁盘镜像数据,解压数据会释放到 squashfs-root 目录中
root@uos-PC:/home/uos/work1/work/live# unsquashfs filesystem.squashfs

#进入 squashfs-root 目录中
root@uos-PC:/home/uos/work1/work/live# cd squashfs-root

#挂载系统关键挂载点(按顺序)
root@uos-PC:/home/uos/work1/work/live/squashfs-root# mount --bind /dev dev
root@uos-PC:/home/uos/work1/work/live/squashfs-root# mount --bind /dev/pts dev/pts
root@uos-PC:/home/uos/work1/work/live/squashfs-root# mount --bind /sys sys
root@uos-PC:/home/uos/work1/work/live/squashfs-root# mount --bind /proc proc

#切换到解压出来的系统环境中,此时 squashfs-root 变成了我们的根目录，也就是 / ，至此我们就可以开始对目录中的系统进行修改
root@uos-PC:/home/uos/work1/work/live/squashfs-root# chroot .
root@uos-PC:/#
```


### 更新内核包 {#更新内核包}

```nil
#卸载deepin-iso-standard
root@uos-PC:/# apt purge deepin-iso-standard

#将需要安装的内核包拷贝到 squashfs-root/tmp/ 下(安装前拷贝过去就行)，因为这个目录不需要其他特别操作就有写入权限
uos@uos-PC:~/6304_6306$ cp ./*6304*_mips64el.deb /home/uos/work1/work/live/squashfs-root/tmp
#安装内核包(mips非性能内核)
root@uos-PC:/# dpkg -i /tmp/*.deb

#4000的内核(mips性能内核)更新到/var/cache/KernelSelect下边
uos@uos-PC:~/kernel_deb$ sudo cp *6306*.deb /home/uos/work1/work/live/squashfs-root//var/cache/KernelSelect
#删除目录下原有的旧4000内核
root@uos-PC:/var/cache/KernelSelect# rm *6302*.deb
```


### 卸载之前挂载数据 {#卸载之前挂载数据}

```nil
#按序卸载挂载点
root@uos-PC:~# umount proc
root@uos-PC:~# exit
exit
root@uos-PC:/home/uos/work1/work/live/squashfs-root# umount sys
root@uos-PC:/home/uos/work1/work/live/squashfs-root# umount dev/pts
root@uos-PC:/home/uos/work1/work/live/squashfs-root# umount dev

#安装完成后，进行清场
root@uos-PC:/home/uos/work1/work/live/squashfs-root# rm -f /tmp/*.deb
root@uos-PC:/home/uos/work1/work/live/squashfs-root# echo -n > root/.bash_history

#退出squashfs-root目录
root@uos-PC:/home/uos/work1/work/live/squashfs-root# cd ..
```


### 重新生成磁盘镜像数据 {#重新生成磁盘镜像数据}

```nil
#将内核启动文件 vmlinuz 和 initrd.img 替换掉光盘镜像自带的内核启动文件
root@uos-PC:/home/uos/work1/work/live# cp -fv squashfs-root/boot/vmlinuz-4.19.0-loongson-3-desktop ../boot/vmlinuz
'squashfs-root/boot/vmlinuz-4.19.0-loongson-3-desktop' -> '../boot/vmlinuz'
root@uos-PC:/home/uos/work1/work/live# cp -fv squashfs-root/boot/initrd.img-4.19.0-loongson-3-desktop ../boot/initrd.img
'squashfs-root/boot/initrd.img-4.19.0-loongson-3-desktop' -> '../boot/initrd.img'

#重新制作压缩系统模板磁盘镜像文件，由于压缩过程需要较多计算能力，所以此步骤耗时较长
root@uos-PC:/home/uos/work1/work/live# mksquashfs squashfs-root filesystem1.squashfs -comp xz

#修改文件权限，保证后面能够正常访问
root@uos-PC:/home/uos/work1/work/live# chown ${SUDO_USER}: filesystem1.squashfs

#执行如下命令删除解压出来的文件：
root@uos-PC:/home/uos/work1/work/live# rm -rf squashfs-root

#使用我们新生成的 filesystem1.squashfs 替换原来的 filesystem.squashfs：
root@uos-PC:/home/uos/work1/work/live# mv filesystem1.squashfs filesystem.squashfs

#退出root用户,退出work/live目录：
root@uos-PC:/home/uos/work1/work/live# exit
exit
uos@uos-PC:~/work1/work/live$ cd ../..
```


### 生成镜像文件 {#生成镜像文件}

将 work 文件夹押回镜像

```nil
uos@uos-PC:~/work1$ xorriso -as mkisofs -V "UOS 20" -R -r -J -joliet-long -l -cache-inodes -appid "UOS 20" -publisher "UOS <http://www.uniontech.com>" -V "UOS 20"   -o "uos-desktop-20-professional-1061_6304-mips64el.iso" "work"
```


### REFERENCE {#reference}

<https://wikidev.uniontech.com/OEM%E9%95%9C%E5%83%8F%E5%AE%9A%E5%88%B6%E8%AF%B4%E6%98%8E>


## hwe 内核增加 radeon 驱动和上游 6.1 内核有什么区别 {#hwe-内核增加-radeon-驱动和上游-6-dot-1-内核有什么区别}

git diff hwe-6.1 remotes/origin/6.1.y drivers/gpu/drm/radeon/

这个一眼就看出来了。

```diff
diff --git a/drivers/gpu/drm/radeon/ci_dpm.c b/drivers/gpu/drm/radeon/ci_dpm.c
index 8ef25ab305ae..b8f4dac68d85 100644
--- a/drivers/gpu/drm/radeon/ci_dpm.c
+++ b/drivers/gpu/drm/radeon/ci_dpm.c
@@ -5517,6 +5517,7 @@ static int ci_parse_power_table(struct radeon_device *rdev)
        u8 frev, crev;
        u8 *power_state_offset;
        struct ci_ps *ps;
+       int ret;

        if (!atom_parse_data_header(mode_info->atom_context, index, NULL,
                                   &frev, &crev, &data_offset))
@@ -5546,11 +5547,15 @@ static int ci_parse_power_table(struct radeon_device *rdev)
                non_clock_array_index = power_state->v2.nonClockInfoIndex;
                non_clock_info = (struct _ATOM_PPLIB_NONCLOCK_INFO *)
                        &non_clock_info_array->nonClockInfo[non_clock_array_index];
-               if (!rdev->pm.power_state[i].clock_info)
-                       return -EINVAL;
+               if (!rdev->pm.power_state[i].clock_info) {
+                       ret = -EINVAL;
+                       goto err_free_ps;
+               }
                ps = kzalloc(sizeof(struct ci_ps), GFP_KERNEL);
-               if (ps == NULL)
-                       return -ENOMEM;
+               if (ps == NULL) {
+                       ret = -ENOMEM;
+                       goto err_free_ps;
+               }
                rdev->pm.dpm.ps[i].ps_priv = ps;
                ci_parse_pplib_non_clock_info(rdev, &rdev->pm.dpm.ps[i],
                                              non_clock_info,
@@ -5590,6 +5595,12 @@ static int ci_parse_power_table(struct radeon_device *rdev)
        }

        return 0;
+
+err_free_ps:
+       for (i = 0; i < rdev->pm.dpm.num_ps; i++)
+               kfree(rdev->pm.dpm.ps[i].ps_priv);
+       kfree(rdev->pm.dpm.ps);
+       return ret;
 }

 static int ci_get_vbios_boot_values(struct radeon_device *rdev,
@@ -5678,25 +5689,26 @@ int ci_dpm_init(struct radeon_device *rdev)

        ret = ci_get_vbios_boot_values(rdev, &pi->vbios_boot_state);
        if (ret) {
-               ci_dpm_fini(rdev);
+               kfree(rdev->pm.dpm.priv);
                return ret;
        }

        ret = r600_get_platform_caps(rdev);
        if (ret) {
-               ci_dpm_fini(rdev);
+               kfree(rdev->pm.dpm.priv);
                return ret;
        }

        ret = r600_parse_extended_power_table(rdev);
        if (ret) {
-               ci_dpm_fini(rdev);
+               kfree(rdev->pm.dpm.priv);
                return ret;
        }

        ret = ci_parse_power_table(rdev);
        if (ret) {
-               ci_dpm_fini(rdev);
+               kfree(rdev->pm.dpm.priv);
+               r600_free_extended_power_table(rdev);
                return ret;
        }

diff --git a/drivers/gpu/drm/radeon/cypress_dpm.c b/drivers/gpu/drm/radeon/cypress_dpm.c
index fdddbbaecbb7..72a0768df00f 100644
--- a/drivers/gpu/drm/radeon/cypress_dpm.c
+++ b/drivers/gpu/drm/radeon/cypress_dpm.c
@@ -557,8 +557,12 @@ static int cypress_populate_mclk_value(struct radeon_device *rdev,
                                                     ASIC_INTERNAL_MEMORY_SS, vco_freq)) {
                        u32 reference_clock = rdev->clock.mpll.reference_freq;
                        u32 decoded_ref = rv740_get_decoded_reference_divider(dividers.ref_div);
-                       u32 clk_s = reference_clock * 5 / (decoded_ref * ss.rate);
-                       u32 clk_v = ss.percentage *
+                       u32 clk_s, clk_v;
+
+                       if (!decoded_ref)
+                               return -EINVAL;
+                       clk_s = reference_clock * 5 / (decoded_ref * ss.rate);
+                       clk_v = ss.percentage *
                                (0x4000 * dividers.whole_fb_div + 0x800 * dividers.frac_fb_div) / (clk_s * 625);

                        mpll_ss1 &= ~CLKV_MASK;
diff --git a/drivers/gpu/drm/radeon/ni_dpm.c b/drivers/gpu/drm/radeon/ni_dpm.c
index 672d2239293e..3e1c1a392fb7 100644
--- a/drivers/gpu/drm/radeon/ni_dpm.c
+++ b/drivers/gpu/drm/radeon/ni_dpm.c
@@ -2241,8 +2241,12 @@ static int ni_populate_mclk_value(struct radeon_device *rdev,
                                                     ASIC_INTERNAL_MEMORY_SS, vco_freq)) {
                        u32 reference_clock = rdev->clock.mpll.reference_freq;
                        u32 decoded_ref = rv740_get_decoded_reference_divider(dividers.ref_div);
-                       u32 clk_s = reference_clock * 5 / (decoded_ref * ss.rate);
-                       u32 clk_v = ss.percentage *
+                       u32 clk_s, clk_v;
+
+                       if (!decoded_ref)
+                               return -EINVAL;
+                       clk_s = reference_clock * 5 / (decoded_ref * ss.rate);
+                       clk_v = ss.percentage *
                                (0x4000 * dividers.whole_fb_div + 0x800 * dividers.frac_fb_div) / (clk_s * 625);

                        mpll_ss1 &= ~CLKV_MASK;
diff --git a/drivers/gpu/drm/radeon/radeon_cs.c b/drivers/gpu/drm/radeon/radeon_cs.c
index 446f7bae54c4..e3664f65d1a9 100644
--- a/drivers/gpu/drm/radeon/radeon_cs.c
+++ b/drivers/gpu/drm/radeon/radeon_cs.c
@@ -270,7 +270,8 @@ int radeon_cs_parser_init(struct radeon_cs_parser *p, void *data)
 {
        struct drm_radeon_cs *cs = data;
        uint64_t *chunk_array_ptr;
-       unsigned size, i;
+       u64 size;
+       unsigned i;
        u32 ring = RADEON_CS_RING_GFX;
        s32 priority = 0;

diff --git a/drivers/gpu/drm/radeon/radeon_gem.c b/drivers/gpu/drm/radeon/radeon_gem.c
index 261fcbae88d7..75d79c311038 100644
--- a/drivers/gpu/drm/radeon/radeon_gem.c
+++ b/drivers/gpu/drm/radeon/radeon_gem.c
@@ -459,7 +459,6 @@ int radeon_gem_set_domain_ioctl(struct drm_device *dev, void *data,
        struct radeon_device *rdev = dev->dev_private;
        struct drm_radeon_gem_set_domain *args = data;
        struct drm_gem_object *gobj;
-       struct radeon_bo *robj;
        int r;

        /* for now if someone requests domain CPU -
@@ -472,13 +471,12 @@ int radeon_gem_set_domain_ioctl(struct drm_device *dev, void *data,
                up_read(&rdev->exclusive_lock);
                return -ENOENT;
        }
-       robj = gem_to_radeon_bo(gobj);

        r = radeon_gem_set_domain(gobj, args->read_domains, args->write_domain);

        drm_gem_object_put(gobj);
        up_read(&rdev->exclusive_lock);
-       r = radeon_gem_handle_lockup(robj->rdev, r);
+       r = radeon_gem_handle_lockup(rdev, r);
        return r;
 }

diff --git a/drivers/gpu/drm/radeon/rv740_dpm.c b/drivers/gpu/drm/radeon/rv740_dpm.c
index d57a3e1df8d6..4464fd21a302 100644
--- a/drivers/gpu/drm/radeon/rv740_dpm.c
+++ b/drivers/gpu/drm/radeon/rv740_dpm.c
@@ -249,8 +249,12 @@ int rv740_populate_mclk_value(struct radeon_device *rdev,
                                                     ASIC_INTERNAL_MEMORY_SS, vco_freq)) {
                        u32 reference_clock = rdev->clock.mpll.reference_freq;
                        u32 decoded_ref = rv740_get_decoded_reference_divider(dividers.ref_div);
-                       u32 clk_s = reference_clock * 5 / (decoded_ref * ss.rate);
-                       u32 clk_v = 0x40000 * ss.percentage *
+                       u32 clk_s, clk_v;
+
+                       if (!decoded_ref)
+                               return -EINVAL;
+                       clk_s = reference_clock * 5 / (decoded_ref * ss.rate);
+                       clk_v = 0x40000 * ss.percentage *
                                (dividers.whole_fb_div + (dividers.frac_fb_div / 8)) / (clk_s * 10000);

                        mpll_ss1 &= ~CLKV_MASK;
```

对比一下哪个分支的 patch 更新一些？两个分支分别看一下 git log --oneline ，这种方式最为直观。


## 总结 {#总结}

上面的方法，不仅适用于 mips ，基它架构应该也一样。

我和另一个同事与纸 尝试把 4.19 kvm 移到 5.10 上，感觉工作量有一些大。目前的方法是覆盖 arch/mips/kvm , virt/ 目录，然后根据报错修改 arch/mips/asm ，include/linux/ kvm 相关的代码，解决编译报错的方式做。

4.19 和 5.10 有不少的修改，中间还涉及 mm ，mmu ，kernel/hardirq 的报错问题。

mips 将 4.19 内核中的 kvm 移植到 5.10 上的工作量很大。cpu 厂家那边移植 loongarch kvm 虚拟化从 4。19 到 5。10， 花了两个人三个月的时候，中间一直调试 debug 。

内核当中的工作主要是细致和经验的积累。对一个操作系统了解的多了之后就会知道复杂的事物，有时候就像是现实世界。逻辑因为量的增长，导致很多奇异的事会常常发生。

ssh 编内核最好加 nohup 。防止编译过程因为网络失败。 linux-libc-dev_4.19.90-3_mips64el.deb
这类的包里面都是头文件，不需要安装，替换内核也是正常的。

编内核的过程中，如果不需要 dbg 包的话，debian 脚本打包 dbg 的 deb 包会很慢，也是最后做的可以直接 C-c 停止。节约一点时间。

有时候多思考可以节约时间。

最终这些问题能够顺利解决，靠的是另外两个同事的思考还有我一起不断的尝试和思考
