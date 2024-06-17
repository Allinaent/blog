+++
title = "我的工作流增加mathjax extension 和一些新感悟"
date = 2024-04-26T16:35:00+08:00
lastmod = 2024-06-17T11:24:32+08:00
categories = ["emacs", "prose"]
draft = false
toc = true
image = "https://r2.guolongji.xyz/allinaent/2024/06/af960550dc8dbdc44674aa00e830fc90.png"
+++

## orgmode 的 xelatex 没有渲染 \xlongequal {#orgmode-的-xelatex-没有渲染-xlongequal}

解决方法：

```lisp
(setq org-latex-packages-alist
      (quote (("" "color" t)
          ("" "minted" t)
          ("" "parskip" t)
          ("" "tikz" t)
          ("" "pgfplots" t)
          ("" "amsmath" t)
          ("" "extarrows" t)
          )))
```

增加 extarrows 这个 latex 的 ctan 宏包。


## 博客里的 hugo 也无法渲染 \xlongequal {#博客里的-hugo-也无法渲染-xlongequal}

解决办法：

```diff
diff --git a/themes/hugo-theme-stack/layouts/partials/article/components/math.html b/themes/hugo-theme-stack/layouts/partials/article/components/math.html
index 818ccc6..ddd7295 100644
--- a/themes/hugo-theme-stack/layouts/partials/article/components/math.html
+++ b/themes/hugo-theme-stack/layouts/partials/article/components/math.html
@@ -11,4 +11,36 @@
             ignoredClasses: ["gist"]
         });})
 </script> -->
-<script src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.2/MathJax.js?config=TeX-MML-AM_SVG"></script>
+<script>
+MathJax = {
+    tex: {
+      inlineMath: [['$', '$'], ['\\(', '\\)']],
+      displayMath: [['$$','$$'], ['\\[', '\\]']],
+      processEscapes: true,
+      processEnvironments: true,
+      autoload: expandable({
+                action: ['toggle', 'mathtip', 'texttip'],
+                amscd: [[], ['CD']],
+                bbox: ['bbox'],
+                boldsymbol: ['boldsymbol'],
+                braket: ['bra', 'ket', 'braket', 'set', 'Bra', 'Ket', 'Braket', 'Set', 'ketbra', 'Ketbra'],
+                cancel: ['cancel', 'bcancel', 'xcancel', 'cancelto'],
+                color: ['color', 'definecolor', 'textcolor', 'colorbox', 'fcolorbox'],
+                enclose: ['enclose'],
+                extpfeil: ['xtwoheadrightarrow', 'xtwoheadleftarrow', 'xmapsto',
+                 'xlongequal', 'xtofrom', 'Newextarrow'],
+                html: ['href', 'class', 'style', 'cssId'],
+                mhchem: ['ce', 'pu'],
+                newcommand: ['newcommand', 'renewcommand', 'newenvironment', 'renewenvironment', 'def', 'let'],
+                unicode: ['unicode'],
+                verb: ['verb']
+        })
+    },
+    options: {
+      skipHtmlTags: ['script', 'noscript', 'style', 'textarea', 'pre']
+    }
+  };
+</script>
+<!-- <script src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.2/MathJax.js?config=TeX-MML-AM_SVG"></script> -->
+<script src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
```


## 从头条里看到的非常对的话 {#从头条里看到的非常对的话}

Before achieving great things, just study yourself first. What do you want, What do you want to get from
other person. What are you willing to offer in exchange, and what price are you willing to pay?
You just need to under stand your true needs. So, the first important thing in life is to put your feelings
frist. When we have enough energy ourselves, you can naturally love others and the world.

I have a tried-and-true way to stop internal struggle. That is, not to analyze the motives of the other
person. I also spent a long time in the past. Immersed in the quagmire of negative emotions, I couldn't pull
myself. I felt exhausted without doing anything. I would constantly ponder on other's opinions and
evaluations of me. Sensitivity, Inferiortiy, and anxiety almost drowned me. After moving from South Africa
to the United Status, it took me almost 10 years.

I've seen psychologists, reading a large number of psychology books. communicating with high-energy friends,
and tring many methods. I found that the most important thing is not to care about what other think. If
you focus all your energy on yourself, just taking care of yourself takes a lot of effort. Where else do
you have the space time and energy to care about others? So don't waste you energy analyzing the motives of
the other person. What the other one thinks is not important, really not important!

Elon mask once said.

孟子曰：“爱人不亲，反其仁；治人不治，反其智；礼人不答，反其敬——行有不得者皆反求诸己，其身正而天下归之。”

网友评论两个意思相近，在我看意思并不一样。马斯克的意思是说让人专注自己而不要去分析别人的看法和动机；而孟子的意思却是要从他人的反应中看到自己哪里做的还是不够好。不看方法看疗效，哪个能让我摆托困境哪个就是自己的金玉良言。我现在更喜欢马斯克的话，至少让我远离内耗，好吧。继续调整心态，并将自己的能量真正放到有用的事情上。道阻且长，行则将至。
