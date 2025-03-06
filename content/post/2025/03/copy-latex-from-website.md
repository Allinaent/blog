+++
title = "从网页上混合复制文本和 latex 公式"
date = 2025-03-06T21:32:00+08:00
lastmod = 2025-03-06T21:57:51+08:00
categories = ["latex"]
draft = false
toc = true
image = "https://r2.guolongji.xyz/allinaent/2024/06/e6104c843f0ccfcf964a9d1e4e42dca7.png"
+++

转载一篇文章：<https://www.cnblogs.com/bowen404/p/17923886.html>

先 f12 控制台， settings, debbuger, disable javascript. 显示出公式和文本混排后再用 console 的js 来做些替换修改。

非常棒的想法，绐所有的网页复制提供了可行的方案。

但是其中对知乎的复制，他用的是 $$ 扩起来的，我在 emacs 当中比较喜欢用 `\( \)` 来写。

```js
// 知乎处理公式
var a = document.getElementsByClassName("ztext-math")
for (let i of a) {
    i.innerHTML = "\\("+i.innerHTML+"\\)"
}
```

这个世界从来不缺少爱思考的人，没了姜萍，来了王虹。人家北大的，励志学数学，而且成功了。我的偶像又多了一个。

<https://zhuanlan.zhihu.com/p/27016791257>

世间多少人活的那么有追求，取得了那么多不俗的成绩。不要把自己的希望寄托在别人的身上。就算没有过人的天赋，也至少要有过人的追求。

求不到散，没环境创造环境。自己要啥？要诗和远方和一点苟且。
