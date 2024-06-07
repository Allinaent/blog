+++
title = "高数第一章练习题"
date = 2024-04-28T14:56:00+08:00
lastmod = 2024-06-05T11:32:05+08:00
categories = ["exam"]
draft = false
toc = true
image = "https://r2.guolongji.xyz/allinaent/2024/06/fd73d15b3d78f6756f87c0b048d163a2.jpg"
+++

例一：求函数 \\(y=shx=\frac{e^{x}-e^{-x}}{2}\\) 的反函数

此题难点，初中基础知识，韦达定理。 \\(x\_{1},x\_{2}=\frac{-b\pm \sqrt{b^{2}-4ac}}{2a}\\)

\\(x\_{1}+x\_{2}=-\frac{b}{a}\\)

\\(x\_{1}x\_{2}=\frac{c}{a}\\)

这种题对我来说都有难度，说明我离开数学的时间太久了。

例二：设函数

\begin{equation\*}
f(x)=\left\\{\begin{aligned}
& 1-2x^{2},\quad  & x<-1  \\\\
& x^{3}, \quad  & -1 \leq x \leq 2 \\\\
& 12x-16, \quad & x>2
\end{aligned}
\right.
\end{equation\*}

 ，求它的反函数。此题无难点，直接分类讨论。但是无难点的题要做的又对又快。

上同的题就不是非常好，先做重要的题。这些题都很好，题海有了，现在的战术就是多看多做。

<https://askubuntu.com/questions/687295/how-to-purge-previously-only-removed-packages>

```bash
sudo apt-get purge $(dpkg -l | grep '^rc' | awk '{print $2}') # 这个命令太冒险了，用下面的
dpkg -l | grep '^rc'
dpkg -P xbyyunpan
```

从阿里云盘上找到了很多的 pdf ，如果看完绝对能过。这些资料这么多，从哪看起呢？

还有如果我要做三千道题，花半年也就是 180 天，那么一天要做多少道题呢？一天 20 道题，至少 10 道题，难度是很大的。

还有如果是熟练的题就没有必要看了，这可以提高学习的效率。所以时间至少还在一个可以接受的范围里面。练熟基本功。拿到基础分一样有很大的概率可以上岸。所以也不用太过担忧。


## 先看张宇高数 300 题 {#先看张宇高数-300-题}

1.1 D

1.2 这道题难住我了，看答案竟然是恒等式变形解决的，晕。

\\(f(x+\frac{1}{x})=\frac{x+x^{3}}{1+x^{4}}\\) ，求 \\(f(x)\\). 原式= \\(\frac{\frac{1}{x}+x}{\frac{1}{x^{2}}+x^{2}}\\)
即 \\(f(x)=\frac{x}{x^{2}-2}\\) ，数学有时候考点就是让人琢磨不清，以为要考换元计算，结果就是简单的恒等式变形。

1.3 已知 \\(f(x)=e^{x^{2}}\\) ， \\(f[\varphi(x)]=1-x\\) ，且 \\(\varphi(x) \leq 0\\) ，求 \\(\varphi(x)\\) 并写出它的定义域。

第一步代入， \\(e^{[\varphi(x)]^{2}}=1-x\\) ，得 \\(\varphi(x)=\sqrt{ln(1-x)}\\) ，由 \\(ln(1-x) \leq 0\\) 得
\\(1-x \geq 1\\) ，即 \\(x\leq 0\\) 。方法是直接代入并计算。

1.4 即最上面的李永乐的那道例题。分类讨论。

\begin{equation\*}
y=f^{-1}(x)=\left\\{
\begin{aligned}
& \sqrt\frac{1-x}{2}, & \quad x<1 \\\\
& \sqrt[3]{x}, & \quad -1 \leq x \leq 8 \\\\
& \frac{16+x}{12} & \quad 8 < x < +\infty
\end{aligned}
\right.
\end{equation\*}

这道题做错了第一个区间当中的正负号不对，y 在第一个区间是小于 0 的，所以加加一个负号啊。现在的能力确实弱爆了。

正确答案是：

\begin{equation\*}
y=f^{-1}(x)=\left\\{
\begin{aligned}
& -\sqrt\frac{1-x}{2}, \quad & x<-1 \\\\
& \sqrt[3]{x}, \quad & -1 \leq x \leq 8 \\\\
& \frac{16+x}{12} \quad & 8 < x < +\infty
\end{aligned}
\right.
\end{equation\*}

1.5 设 \\(f(x)=\frac{x}{\sqrt{1+x^{2}}}\\) ， \\(f\_{n+1}(x)=f[f\_{n}(x)\]\(n=1,2,3,...)\\) ，求 \\(f\_{n}(x)\\) 的表达式。

这道题有什么思路吗？

没有思路，看答案才知道这道题用的是数学归纳法。也就是答案是观察出来的，观察出来之后再证明一下。

\\(f\_{1+1}(x)=\frac{\frac{x}{\sqrt{1+x^{2}}}}{\sqrt{1+\frac{x^{2}}{1+x^{2}}}}=\frac{x}{1+2x^{2}}\\) ，用数学归纳法推理可得： \\(f\_{n}(x)=\frac{x}{\sqrt{1+(n+1)x^{2}}} \quad (n=1,2,3,...)\\)

好题，好思路。


## 数列极限 {#数列极限}

2.1 设 \\(\lim\limits\_{n \to \infty}a\_{n}=0, \lim\limits\_{n \to \infty}b\_{n}=1\\) ，则（）

这个选 B 存在正整数 N ，当 \\(n>N\\) 时，总有 \\(a\_{n}<b\_{n}\\)

2.2 设 \\(x\_{n}=\frac{1}{3}+\frac{1}{15}+...+\frac{1}{4n^{2}-1},n=1,2,...\quad\\)，则
\\(\lim\limits\_{n\to\infty}x\_{n}=\\) （）

\\(x\_{n}=[\frac{1}{(2\times 1-1)(2 \times 1+1)}+\frac{1}{(2\times 2-1)(2\times 2+1)}+...+\frac{1}{(2n-1)(2n+1)}]\\)
\\(x\_{n}=2(1-\frac{1}{3}+\frac{1}{3}-\frac{1}{5}+...-\frac{1}{2n+1})\\) 所以答案等于 2 。这种题真的是小学就学过。
30 多了还要学。没长进。

做错了，系数不是 2 是 \\(\frac{1}{2}\\) ，答案是 \\(\frac{1}{2}\\) 。

2.3 极限 \\(\lim\limits\_{n \to \infty}(\frac{n+1}{n-2})^{n}\\)

此题是基础极限公式的题，昨天做了一下，现在又忘记了，说明没有真正掌握。数学中的万千基础，可以认为弥补了自己不足的地方之后，就会做题了。考试是竞赛，研究是生活。

此题不会的原因是对换元法求极限部分不熟练。

\begin{equation\*}
\lim\limits\_{n \to \infty}(\frac{n+1}{n-2})^{n} = \lim\limits\_{n\to
\infty}\frac{(1+\frac{1}{n})^{n}}{(1-\frac{2}{n})^{n}}=\frac{e}{e^{-2}}=e^{3}
\end{equation\*}

此题乃是一道母题。 \\(\lim\limits\_{n \to \infty}(1+a \frac{1}{n})^{n}=e^{a}\\) 这个成立吗？可以用换元法

令 \\(t=\frac{n}{a}\\) ，则原式= \\(\lim\limits\_{t \to \infty}(1+ \frac{1}{t})^{at}=e^{a}\\) 没错就是这个简单的东西，我居然没什么印象，说明我高数学得也是不怎么样的。

2.4 求极限
