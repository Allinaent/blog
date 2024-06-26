+++
title = "实现一个杂项设备 mmap ioctl"
date = 2024-06-26T17:01:00+08:00
lastmod = 2024-06-26T17:26:11+08:00
categories = ["kernel"]
draft = false
toc = true
image = "https://r2.guolongji.xyz/allinaent/2024/06/92a1feeab471b12646b9c76edccc1546.jpg"
+++

## 题目 {#题目}

实现一个杂项设备/dev/uosmisc，并实现它的mmap、ioctl接口。要求：
mmap时，写入的数据，在下次映射时能读出来。
ioctl实现命令：UOS_IOC_SETINFO:设置一些信息，UOS_IOC_GETINFO：读取设置的信息。


## 答案 {#答案}

moudle.c

```c
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/errno.h>
#include <linux/slab.h>
#include <linux/mm.h>
#include <linux/io.h>
#include <linux/device.h>
#include <linux/miscdevice.h>

#define GMEM_ORDER 3
#define GMEM_PAGES 8
#define GMEM_SIZE (GMEM_PAGES*PAGE_SIZE)

#define UOS_IOCTL_NUM 'U'

#define UOS_IOC_SETINFO _IOWR(UOS_IOCTL_NUM, 4, void *)
#define UOS_IOC_GETINFO _IOWR(UOS_IOCTL_NUM, 9, void *)

static int uos_info;

static uint8_t *gmem_buf;
static int gmem_init(void)
{
        gmem_buf = (uint8_t *)__get_free_pages(GFP_KERNEL, GMEM_ORDER);
        if (gmem_buf == NULL)
                return -1;
        return 0;
}


int uos_file_setinfo(unsigned long arg)
{
        int info;
        copy_from_user(&info, (void __user *)arg, sizeof(info));

        uos_info = info;
        printk(KERN_ERR "setinfo uos_info=%d\n", uos_info);

        return 0;
}

unsigned long uos_file_getinfo(unsigned long arg)
{
        int info = uos_info;
        printk(KERN_ERR "getinfo:uos_info=%d\n", info);
        return copy_to_user((void __user *)arg, &info, sizeof(info));
}

static long uos_file_unlocked_ioctl(struct file *file, unsigned int req,
                                        unsigned long arg)
{
        int ret = 0;

        switch(req) {
        case UOS_IOC_SETINFO:
                ret = uos_file_setinfo(arg);
                break;
        case UOS_IOC_GETINFO:
                ret = uos_file_getinfo(arg);
                break;
        }

        return ret;
}

static int uos_file_mmap(struct file *file, struct vm_area_struct *vma)
{
        int ret = 0;

        /*
         * we use reserved mem, gmem_buf, as the mmap phyiscal addr,
         * so we can keep the written contents, and can read data next mapping.
         */
        //get offset from user space
        unsigned long offset = vma->vm_pgoff << PAGE_SHIFT;

        //based on gmem, get the virtual addr
        unsigned long map_offset = (unsigned long)gmem_buf + offset;

        //convert virtual addr to physical page frame
        unsigned long pfn_start = virt_to_phys((void *)map_offset) >> PAGE_SHIFT;

        //get map size
        unsigned long size = vma->vm_end - vma->vm_start;

        if ((size % PAGE_SIZE) != 0)
                size = (size+PAGE_SIZE)/PAGE_SIZE * PAGE_SIZE;

        if (size > GMEM_SIZE)
                size = GMEM_SIZE;

        vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);

        //do memory map
        ret = remap_pfn_range(vma, vma->vm_start, pfn_start, size, vma->vm_page_prot);

        return 0;
}

struct file_operations uos_misc_fops = {
        .owner = THIS_MODULE,
        .unlocked_ioctl = uos_file_unlocked_ioctl,
        .mmap = uos_file_mmap,
};

struct miscdevice uos_misc = {
        .minor = MISC_DYNAMIC_MINOR,
        .name  = "uos-misc",
        .fops  = &uos_misc_fops,
};

static int __init misc_dev_init(void)
{
        int ret;

        ret = gmem_init();
        if (ret)
                return -1;

        ret = misc_register(&uos_misc);
        if (ret) {
                return -1;
        }


        return 0;
}

static void __exit misc_dev_exit(void)
{
        misc_deregister(&uos_misc);
}

module_init(misc_dev_init);
module_exit(misc_dev_exit);

MODULE_LICENSE("GPL");
```

test.c

```c
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <errno.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/ioctl.h>


#define UOS_IOCTL_NUM 'U'

#define UOS_IOC_SETINFO _IOWR(UOS_IOCTL_NUM, 4, void *)
#define UOS_IOC_GETINFO _IOWR(UOS_IOCTL_NUM, 9, void *)


int main() {
    int fd;
    char *start;
    int info = 10;
    char buf[32];
    int ret = -1;

    fd = open("/dev/uos-misc", O_RDWR);
    if (fd == -1) {
        perror("open");
        exit(EXIT_FAILURE);
    }

    start = mmap(NULL, 32, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
    if (start == MAP_FAILED) {
            close(fd);
            return -1;
    }
    //start[0] = 'a';
    //start[1] = '3';
    //start[2] = 'd';
    //start[3] = '\0';

    printf("%s\n", start);

    ret = ioctl(fd, UOS_IOC_SETINFO, &info);
    if (ret) {
            printf("UOS_IOC_SETINFO failed");
    }

    ret = ioctl(fd, UOS_IOC_GETINFO, &info);
    if (ret) {
            printf("UOS_IOC_GETINFO failed");
    } else {
            printf("UOS_IOC_GETINFO, info=%d\n", info);
    }

    munmap(start, 32);
    close(fd);

    return 0;
}
```

```makefile
obj-m := misc_uos.o
misc_uos-objs := module.o

kdir := /lib/modules/$(shell uname -r)/build
cwd := $(shell pwd)

default:
        make -C $(kdir) M=$(cwd) modules

clean:
        make -C $(kdir) M=$(cwd) clean
```
