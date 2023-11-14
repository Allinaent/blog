+++
title = "软考考前突击"
date = 2023-11-01T19:04:00+08:00
lastmod = 2023-11-02T15:09:03+08:00
tags = ["examination"]
categories = ["exam"]
draft = false
toc = true
+++

## 准备 {#准备}

```bash
git pull
./install-eaf.py -i mindmap
./install-eaf.py --install-core-deps

```

sudo vim ~/.pip/pip.conf

```nil
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
[install]
trusted-host = https://pypi.tuna.tsinghua.edu.cn  # trusted-host 此参数是为了避免麻烦，否则使用的时候可能会提示不受信任
```

题目类型：

上午选择题:75 道，共 75 空，每空是 1 分;满分:75 分;时间:150 分钟；选择题 2min 一道题。

下午案例题:考核时间:90 分钟满分:75 分，5道大题(第 1 题必做，后 4 题选做 2 题)，一个半小时，半小时一道题。

论文:系统架构设计论文，考试时间为 120 分钟，笔试，论文题。从给出的 4 道试题(试题一至试题四)中任选 1 道题解答。满分 75 分。论文要写 2000 到 3000 字，3篇 800 字作文的字数。

45 x 3 = 135 分。也就是说。9/25 的成绩，也就是 100 分满分，只需要考 36 分吗？

总共 32 小时，第一个小时没有什么考点。

一、计算机系统

{{< figure src="/ox-hugo/1.png" alt="Caption not used as alt text" caption="<span class=\"figure-number\">Figure 1: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}

1.存储器按照与存储器的矩离可分为：片上缓存，片外缓存，主存，外存

2.并行总线：多条双向总线；串行总线：一条双向数据线或者两条单向数据线

3.操作系统分类：批处理操作系统，分时操作系统，实时操作系统，网络操作系统，分布式操作系统，嵌入式操作系统。

4.网络协议包含：局域网协议，广域网协议，无线网协议，移动网协议

5.中间件包含：消息中间件，通信中间件，数据存取管理中间件，Web 服务中间件，安全中间件，跨平台和架构的中间件，专用平台中间件，网络中间件。

6.DSP 处理器采用哈佛结构。

二、嵌入式

{{< figure src="/ox-hugo/2.png" alt="Caption not used as alt text" caption="<span class=\"figure-number\">Figure 2: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}

1.嵌入式系统的分类：嵌入式实时系统，嵌入式非实时系统

2.实时系统：强实时系统，指能够在规定时间内完成系统功能和做出响应的系统。

3.安全攸关系统：指其不正确的功能或者失效会导致人员伤亡、财产损失等严重后果的计算机系统。

4.嵌入式系统分为：硬件层，抽象层，操作系统层，中间件层，应用层

5.嵌入式软件的特点：可裁减性，可配置性，强实时性，安全性，可靠性，高确定性。

6.嵌入式系统的组成结构：嵌入式微处理器，存储器，总线逻辑，定时器，看门狗电路，I/O 接口，外部设备

7.嵌入式微处理器分类：微处理器，微控制器，数字信号处理器，图形处理器，片上系统。

8.存储器分类：随机存储器（不受存储位置的影响），只读存储器。EEPROM 的读取速度快，擦除速度慢。flash，擦写次数多，擦的速度快，但是读的速度慢。

9.总线分类：数据总线（用于传输数据），地址总线（用于指定 RAM 之中存储数据的地址），控制总线（将微处理器控制单元信号传送到周边设备）；又可分为片内总线，系统总线，局部总线，通信总线；又可分为单工总线，双工总线；又可分为串行总线，并行总线。

10.看门狗电路：是嵌入式系统必须具备的一种系统恢复能力，可防止程序出错或者死锁。

11.易错点：嵌入式系统不需要支持多任务，错，选择题考认知细节。

三、网络

{{< figure src="/ox-hugo/3.png" alt="Caption not used as alt text" caption="<span class=\"figure-number\">Figure 3: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}

1.性能指标：速率，带宽，吞吐率，时延来度量

2.非性能指标：从费用，质量，标准化，可靠性，可扩展性，可升级性，易管理性，可维护性来度量。

3.通信技术分为：数据与信道，复用技术，多址技术，5G 通信技术。

4.网络分为：局域网，以太网，无线局域网，广域网，城域网，移动通信网。

5.5G 的主要特征：服务化架构，网络切片技术（可在单个物理网络中切分出多个分离的的逻辑网络）

6.网络设备：集线器，中继器于物理层；网桥和交换机于数据链路层；路由器和防火墙于网络层

7.网络协议：应用层，表示层，会话层，传输层，网络层，数据链路层，物理层。

8.应用层协议：FTP，TFTP，HTTP，HTTPS，DHCP，DNS

9.传输层协议：TCP，UDP，

10.网络层协议：IPv4，IPv6

11.IPv4 to IPv6 的过渡技术：双协议栈技术，隧道技术，NAT-PT 技术。

12.交换机的功能：集线功能，中继功能，桥接功能，隔离冲突域功能。

13.交换机的协议有：生成树协议（STP，解决链路回环问题），链路骤合协议（提升与邻接交换设备之间的端口带宽和提高链路可靠性）。

14.路由器功能：异种网络互连，子网协议转换，数据路由，速率适配，隔离网络，报文分片和重组，备份和流量控制

15.路由器的协议：内部网关协议（IGP），外部网关协议（EGP），边界网关协议（BGP）

16.网络建设工程：分为网络设计，网络规划和网络实施 3 个环节。

17.网络分层设计：接入层，汇骤层，核心层

18.网络中的最小帧长是由网络检测冲突中的最长时间来定的。

19.覆盖范围：bluetooth &lt; ZigBee &lt; 802.11n &lt; 802.16m

四、信息系统

{{< figure src="/ox-hugo/4.png" alt="Caption not used as alt text" caption="<span class=\"figure-number\">Figure 4: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}

1.TPS：（transaction processing system）业务处理系统

2.EDPS：（electronic data processing system）电子数据处理系统

3.IPO：（input processing output）；BP：批处理；OLTP：联机事务处理。

4.MIS：管理信息系统

5.DSS：（decision support system）

6.ES：专家系统

五、信息安全技术基础知识

{{< figure src="/ox-hugo/5.png" alt="Caption not used as alt text" caption="<span class=\"figure-number\">Figure 5: </span>_\"caption\"_" link="t" class="fancy" width="900" target="_blank" >}}

对称加密：

1.DES：（Data Encryption Standard），明文切分为 64 位的块，由 56 位的密钥加密成 64 位的密文

2.三重 DES：（Triple-DES），使用两把 56 的密钥对明文做三次 DES。

3.IDEA：国际密钥加密算法（International Data Encryption Algorithm），分组长度为 64 位，密钥长度为 128 位

4.AES：高级加密标准（Advanced Encryption Standard），分组长度 128 位，支持密钥长度 128，192，256 三种

5.SM4：分组长度和密钥长都是 128 位。

非对称加密：

6.RSA：（三个人名），密钥长度可选

7.SM2：椭园曲线离散对数问题。相同安全程度下，密钥长度和安全规模比 RSA 小。

8.控制密钥的安全性：密钥标签，控制矢量

9.KDC：密钥分配中心

10.数字签名：可信，不可伪造，不可重用，不可改变，不可抵赖。

11.访问控制的实现技术：访问控制矩阵，访问控制表（ACL），能力表（Capabilities），授权关系表（Authorization
Relation）

12.密钥分为：数据加密密钥（DK），密钥加密密钥（KK）

13.DoS：（Denial of Service），防御手段有特征识别，防火墙，通信数据量统计，修正问题和漏洞四种方法

14.欺骗攻击：ARP，DNS，IP 欺骗

15.端口扫描：是入侵者搜集信息的几种常用手法

16.针对 TCP/IP 堆栈的攻击方式：同步包风暴（SYN Flooding），ICMP 攻击，SNMP 攻击。

17.系统漏洞扫描：基于网络，基于主机两种

18.常见的安全协议：SSL，PGP（一种加密软件），IPSec，SET 协议（信用卡支付），HTTPS

19.风险评估：基于脆弱性，资产，威胁，风险，安全措施

六、系统工程
