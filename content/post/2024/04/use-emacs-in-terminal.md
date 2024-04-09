+++
title = "在终端下使用 emacs"
date = 2024-04-08T23:08:00+08:00
lastmod = 2024-04-09T13:28:21+08:00
categories = ["emacs"]
draft = false
toc = true
+++

emacs 的插件简直太多了。很多没用到但是写了一堆无用代码，定位一个新的 bug 就难了。GUI 的 emacs
和 TUI 的 emacs 各有优劣。 GUI 下的 emacs 可以图文混排，latex ，orgmode ，公式，图片实时渲染。但是 GUI 的 emacs-vterm 终端模拟器用 tmux 有无法转义，体验的流畅性不足。

所以写博客，用 GUI 。

看代码，写代码，用 TUI 。

打开文件，用终端下的 emacsclient


## 错误修改 {#错误修改}

第一个错误：

```lisp
;; 这个会引起终端下鼠标划动不断出现转义序列导致无法使用！！！
;;(global-set-key (kbd "M-[") 'ggtags-find-tag-dwim)
```

第二个错误：

```lisp
;; 这个会导致终端下的 dired-mode 无法使用
;;'(dired-listing-switches "-alFh")
```

这两个错误都是通过代码二分找的，写在少数的配置文件当中就一点好处，好排错。


## 与 tmux 配合 {#与-tmux-配合}

快捷键定义无冲突即可。

emacs --daemon=foo 运行守护进程，但是有多个 global gtags 的情况下。一个 server 是不对的。emacsclient -nw -s foo  来指定 server 。

其实可以这样，桌面程序 server-name 用 server1 server2 server3 server4 server5 。用脚本 E1 E2 E3 E4 E5 来起动。

tui 的 server-name 用 s1 s2 s3 s4 s5 ，命令是 e1 e2 e3 e4 e5 。数量绝对够了。

多个 tmux 的 session ，session 名字和 tui 代码的 server-name 对应。这只是一个想法当然命令都可以手动来敲。


### 升级 {#升级}

比如我 p1 ~/gh/blog/ 打开一个项目，用 e1 就是对应的 server 用 emacsclient 打开。这是最好的方法，一键打开。tmux 的实力也能全部发挥出来了，非常棒！！！


### 现在阶段性的方案 {#现在阶段性的方案}

```bash
################################################################################
# 重大优化
myopenAmdKernel() {
    emacs -nw --eval "(setq server-name \"amd\")" --eval "(server-start)" \
          --eval "(find-file \"~/gg/x86-src/x86-kernel/\")" \
          --eval "(eval-after-load \"init\" (lambda()(kill-buffer \"*dashboard*\")))"
}
alias Eam=myopenAmdKernel
alias eam='emacsclient -tc -s amd'

myopenLaKernel() {
    emacs -nw --eval "(setq server-name \"la\")" --eval "(server-start)" \
          --eval "(find-file \"~/gg/loongarch-kernel/Loongarch-kernel\")" \
          --eval "(eval-after-load \"init\" (lambda()(kill-buffer \"*dashboard*\")))"
}
alias Ela=myopenLaKernel
alias ela='emacsclient -tc -s ela'

```

这样我可以非常方便的打开内核源码，并打开其中的文件。


### autojump {#autojump}

sudo apt install autojump

这个在终端下非常地好用。


### dirvish {#dirvish}

```elisp
(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "RET") 'dired-find-alternate-file)
  (define-key dired-mode-map (kbd "^") (lambda () (interactive) (find-alternate-file "..")))
  (define-key dired-mode-map (kbd "<left>") '(lambda () (interactive) (find-alternate-file "..")))
  (define-key dired-mode-map (kbd "<right>") 'dired-find-alternate-file)
  )  ; was dired-up-directory)
```

现在看代码和画图都完美了，没有什么理由再不去看代码逻辑了。虽说花屏的问题很难分析，但是还是可以找到分析的路径的。加油！


## dirvish {#dirvish}

这个插件在 tui 下没有问题。另外用“ (”来打开和关闭 dired 显示的细节，非常好。以后看代码的效率一定会非常地高。


## 总结 {#总结}

说起来很复杂，用起来可以不断优化。

事以密成，言以泄败。所以没有放下的，不要说出来。说出来多数是放下了。多领悟生活的智慧，或许有一天你真的会因此受益。
