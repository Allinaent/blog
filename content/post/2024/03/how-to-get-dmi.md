+++
title = "如何在内核当中获取dmi 信息"
date = 2024-03-06T16:24:00+08:00
lastmod = 2024-06-06T13:16:56+08:00
categories = ["kernel"]
draft = false
toc = true
image = "https://r2.guolongji.xyz/allinaent/2024/06/92a1feeab471b12646b9c76edccc1546.jpg"
+++

```diff
diff --git a/drivers/gpu/drm/amd/amdgpu/si.c b/drivers/gpu/drm/amd/amdgpu/si.c
index 4f902e1bcb6a..638df1739048 100644
--- a/drivers/gpu/drm/amd/amdgpu/si.c
+++ b/drivers/gpu/drm/amd/amdgpu/si.c
@@ -49,6 +49,7 @@
 #include "uvd/uvd_4_0_d.h"
 #include "bif/bif_3_0_d.h"
 #include "uvd_v3_1.h"
+#include <linux/dmi.h>

 static const u32 tahiti_golden_registers[] =
 {
@@ -2535,6 +2536,16 @@ int si_set_ip_blocks(struct amdgpu_device *adev)
                if (!pm_suspend_via_s2idle())
                        amdgpu_device_ip_block_add(adev, &uvd_v3_1_ip_block);
                /* amdgpu_device_ip_block_add(adev, &vce_v1_0_ip_block); */
+
+               char const *vendor, *version, *product;
+                const struct bios_settings *bt = NULL;
+
+                /* get BIOS data */
+                vendor  = dmi_get_system_info(DMI_SYS_VENDOR);
+                version = dmi_get_system_info(DMI_BIOS_VERSION);
+                product = dmi_get_system_info(DMI_PRODUCT_NAME);
+                printk("vendor:%s version:%s product:%s\n", vendor, version, product);
+
                break;
        case CHIP_HAINAN:
                amdgpu_device_ip_block_add(adev, &si_common_ip_block);
```

从内核当中拿到 dmi 信息很容易，内核当中的很多方法都是直接导出，只要加了头文件就很容易调用的。
