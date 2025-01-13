+++
title = "将 markdown 文本转换成 org 文本"
date = 2025-01-06T13:39:00+08:00
lastmod = 2025-01-08T09:56:45+08:00
categories = ["emacs"]
draft = false
toc = true
image = "https://r2.guolongji.xyz/allinaent/2024/06/af960550dc8dbdc44674aa00e830fc90.png"
+++

以后可能很多知识是通过 AI 来总结，直接写成博客了。

基本就是利用 pandoc 这个工具。 非常好用，将网页或者 ai 问答的内容转换成 markdown ，在用下面的这个方法，将markdown 转换成
orgmode ，然后看下格式有没有不太对的，可以手动调整一下，下面有一些链接可以提供参考方法：

<https://emacs-china.org/t/markdown-to-org-pandoc-filter/26424>

<https://baty.blog/2022/converting-markdown-to-org-mode-syntax-in-buffer>

<https://github.com/deathau/markdownload>

```lisp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; md convert to org
;; https://baty.blog/2022/converting-markdown-to-org-mode-syntax-in-buffer
;; https://github.com/deathau/markdownload
;; https://emacs-china.org/t/markdown-to-org-pandoc-filter/26424
;; 非常好用，将网页或者 ai 问答的内容转换成 markdown ，在用下面的这个方法，将
;; markdown 转换成 orgmode ，然后看下格式有没有不太对的，可以手动调整一下
;; nix-env -iA nixpkgs.pandoc_3_5 ，安装完这个就可以转换文件格式了。
;; gpt 3.5 可以将回答的内容直接复制出来 markdown 并包含 latex 的公式，现在有了机
;; 器，人真的不要太轻松了。
(defun lj/md-to-org-region (start end)
  "Convert region from markdown to org, replacing selection"
  (interactive "r")
  (shell-command-on-region start end "pandoc -f markdown -t org" t t))
```

上面的代码目前有两个问题，orgmode 当中 == 之间的还有 \*\* 之间的内容有时因为缺少左右的空格无法渲染准确，需要改动一下。

试了一些 lua 和 python 的 filter 我还没有试成功，这块后面再改吧。


## 除了代码部分自动折行 {#除了代码部分自动折行}

```lisp
(setq org-src-fontify-natively t)
(setq org-src-tab-acts-natively t)
```


## 用 linkding 来同步书签 {#用-linkding-来同步书签}

<https://github.com/sissbruecker/linkding>

这个东西长久来看是一个好东西。但是短期来说，更重要的往往不是长期的收益，而是短期的收益，哇哈哈哈哈哈。有这个鸡的时间不如学习一些之前完全不懂的深奥的东西，还是得数据结构和数学还有调试工具这些东西。
