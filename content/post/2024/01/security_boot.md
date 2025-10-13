+++
title = "UOS 安全启动"
date = 2024-01-02T14:07:00+08:00
lastmod = 2025-10-13T13:15:27+08:00
categories = ["security"]
draft = true
toc = true
image = "https://r2.guolongji.xyz/allinaent/2024/06/1f2393d0488363e89799334dd190ce06.png"
+++

## bios 启动 {#bios-启动}

{{< figure src="/ox-hugo/img_20240102_140844.jpg" alt="Caption not used as alt text" caption="<span class=\"figure-number\">图 1: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}


## uefi 启动 {#uefi-启动}

{{< figure src="/ox-hugo/img_20240102_141054.jpg" alt="Caption not used as alt text" caption="<span class=\"figure-number\">图 2: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}

efibootmanager 这个工具可以修改启动项。


## 系统启动 {#系统启动}

{{< figure src="/ox-hugo/img_20240102_141647.jpg" alt="Caption not used as alt text" caption="<span class=\"figure-number\">图 3: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}


## 开源固件 {#开源固件}

{{< figure src="/ox-hugo/img_20240102_141928.jpg" alt="Caption not used as alt text" caption="<span class=\"figure-number\">图 4: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}

{{< figure src="/ox-hugo/img_20240102_142015.jpg" alt="Caption not used as alt text" caption="<span class=\"figure-number\">图 5: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}

{{< figure src="/ox-hugo/img_20240102_142203.jpg" alt="Caption not used as alt text" caption="<span class=\"figure-number\">图 6: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}

{{< figure src="/ox-hugo/img_20240102_142742.jpg" alt="Caption not used as alt text" caption="<span class=\"figure-number\">图 7: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}

{{< figure src="/ox-hugo/img_20240102_142852.jpg" alt="Caption not used as alt text" caption="<span class=\"figure-number\">图 8: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}

把 shim 提交绐微软，微软绐其它厂商提供签名。

{{< figure src="/ox-hugo/img_20240102_143521.jpg" alt="Caption not used as alt text" caption="<span class=\"figure-number\">图 9: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}

{{< figure src="/ox-hugo/img_20240102_143921.jpg" alt="Caption not used as alt text" caption="<span class=\"figure-number\">图 10: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}

{{< figure src="/ox-hugo/img_20240102_144328.jpg" alt="Caption not used as alt text" caption="<span class=\"figure-number\">图 11: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}

{{< figure src="/ox-hugo/img_20240102_144520.jpg" alt="Caption not used as alt text" caption="<span class=\"figure-number\">图 12: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}

昆仑，百敖，华为。

都封装成 PE 结构的列表，只要有一个验证通过就是可信的。这是一种保护安全性的手段。

shim-signed 这个包有一个我们自己的签名。

{{< figure src="/ox-hugo/img_20240102_145150.jpg" alt="Caption not used as alt text" caption="<span class=\"figure-number\">图 13: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}

TPM 是可信安全模块的意思，这个是芯片。变化太快，越来越多的系统服务，使得很难做到这个可信启动。做了 grub 的摘要值，TPM 做了。磁盘加密相关的。还有一个 TCM ，和 TPM 类似。
