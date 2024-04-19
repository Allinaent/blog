+++
title = "简化的哲学"
date = 2024-04-18T15:43:00+08:00
lastmod = 2024-04-19T14:19:35+08:00
categories = ["emacs"]
draft = false
toc = true
+++

## 简单的东西更好用 {#简单的东西更好用}

emacs 是复杂的，关注了一下懒猫大佬。我发现他的技术栈很是深厚，且 python，lisp 做到了非常精通的地步。lsp-bridge 是个很好的包。大佬一定是个执行力很强且精力十分充沛的人。

我想要带着我的 U 盘系统，关闭 emacs 恢复之前的打开的文件和位置。试用了很多的插件，发现没有一个好用的。多实例的情况下更是如此。

最终决定，用最简单的方法来做。我为什么不直接写个 lisp 函数 shell 打开的时候选择调用一下呢？我的目的非常简单。


## emacs 的修改 {#emacs-的修改}

修改 emacs 很容易横生一些枝节，因为 emacs 版本的升级，可能有一些包就会报错，经常在加一些新功能后，出现各种新的问题。关键很多时候，像没头苍蝇一样乱找，浪费了很多时间不说，也让自己的心情变得很糟糕。

```lisp
;; saveplace-pdf-view
(require 'bookmark)
(require 'saveplace-pdf-view)
(save-place-mode 1)
```

现在可以记录 emacs 打开 pdf 的位置，关闭再打开也可以重新跳到之前的位置。

```lisp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 打开我的考研学习界面
(defun openmath()
  (interactive)
  (progn
    (find-file "~/mydata/orgmode/gtd/2021李永乐复习全书【数学二】.pdf")
    (find-file-other-window "~/gh/blog/org/2024/")
    (select-window-1)
    (pdf-view-center-in-window)
    (select-window-2)
    )
  )
(global-set-key (kbd "M-<f1>") 'openmath)
```

最后在 .bashrc 当中加入下面的内容，测试有问题，可以后面再看。

```bash
myopenmath() {
    emacs -nw --eval "(eval-after-load \"init\" (openmath))"
}
alias Ema=myopenmath
```

后面再优化一些快捷键，C-1 定义的是 counsel-fzf ；C-2 定义的是 helm-ag 或者 helm-rg ；


## enjoy {#enjoy}

M-&lt;f1&gt; 即可打开我的复习环境，C-1 即可搜之前的博客或者笔记。
