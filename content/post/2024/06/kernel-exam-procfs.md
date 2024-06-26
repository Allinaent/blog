+++
title = "procfs 内核考试题"
date = 2024-06-20T14:16:00+08:00
lastmod = 2024-06-26T17:31:12+08:00
categories = ["kernel"]
draft = false
toc = true
image = "https://r2.guolongji.xyz/allinaent/2024/06/92a1feeab471b12646b9c76edccc1546.jpg"
+++

在procfs里实现一个接口/proc/uos/param1，能对该接口进行读写。

此题 GPT 完很简单，先易后难，找找自信。

procfs_example.c

```c
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/proc_fs.h>
#include <linux/uaccess.h>  // for copy_to_user and copy_from_user

#define BUF_SIZE 1024

static char param1_buf[BUF_SIZE];
static struct proc_dir_entry *proc_entry;

// 读取函数
ssize_t param1_read(struct file *file, char __user *buf, size_t count, loff_t *ppos) {
    return simple_read_from_buffer(buf, count, ppos, param1_buf, strlen(param1_buf));
}

// 写入函数
ssize_t param1_write(struct file *file, const char __user *buf, size_t count, loff_t *ppos) {
    if (count > BUF_SIZE)
        return -EINVAL;

    if (copy_from_user(param1_buf, buf, count))
        return -EFAULT;

    param1_buf[count] = '\0';  // Null-terminate the buffer

    return count;
}

// 文件操作结构体
static const struct file_operations param1_fops = {
    .owner = THIS_MODULE,
    .read = param1_read,
    .write = param1_write,
};

static int __init uos_param_init(void) {
    proc_entry = proc_create("uos/param1", 0666, NULL, &param1_fops);
    if (!proc_entry) {
        return -ENOMEM;
    }
    return 0;
}

static void __exit uos_param_exit(void) {
    proc_remove(proc_entry);
}

module_init(uos_param_init);
module_exit(uos_param_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Your Name");
MODULE_DESCRIPTION("A simple procfs interface for /proc/uos/param1");
```

Makefile

```makefile
obj-m += procfs_example.o

all:
        make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

clean:
        make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean
```

make all;

sudo insmod procfs_example.ko

sudo -s; echo 1 &gt; /proc/uos/param1; cat /proc/uos/param1;
