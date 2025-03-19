+++
title = "使用 emacs 后悔过吗？"
date = 2025-03-18T09:24:00+08:00
lastmod = 2025-03-19T10:03:27+08:00
categories = ["emacs"]
draft = false
toc = true
image = "https://r2.guolongji.xyz/allinaent/2024/06/af960550dc8dbdc44674aa00e830fc90.png"
+++

## 使用 emacs 浪费了不少的时间 {#使用-emacs-浪费了不少的时间}

从“破烂流丢一口钟”到“堪可御寒的赛博单衣”，我在 emacs 上面花费的时间真的是太多了，多到我也经常怀疑这值得吗？说句心里话，能遇到别人遇不到的问题，能满足一下小小的虚荣心，能让自己经常感觉比较好玩，快乐。就像有人喜欢玩戴森球，乐趣就是折腾完后用起来的成就感，到最后就真能按照自己的意志改造一个 IDE 。


## emacs 直观吗？ {#emacs-直观吗}

emacs 是从不直观走向直观的。我说这句话的意思是 emacs 不经过一堆插件的使用和对插件的自定义修改，在一开始一点都不直观。经过大量的修改后才能好用。

直观性不如 vscode ，不如 jetbrain 的 idea ，不如 pycharm ，不如……

但是好像在熟练了之后能闭上眼睛，一溜的快捷键完成一系列的操作。可以把工作流全链条打通。


## 到目前为止，我在 emacs 哪些方面还不太会用？ {#到目前为止-我在-emacs-哪些方面还不太会用}

magit ，总是用命令行，magit 用的少，对 magit 的使用和配置太少了。

projectile ，这个插件结合 ggtags 可以做到对内核 git 多分支多 tag 的 gnu global tag 的管理。

ggtags ，这个我之前有写过一些函数来看内核代码，把代码的 tag 隐藏到了系统的路径下，这不是一个好方法，更好的方法下面再讲一下。

neotree/treemacs ， treemacs 这个插件可以经常升级一下，2025 1 月的 treemacs 挺好用的，像 eclipse 一样有工作区和项目。可以使用多个工作区。

说实话，用 emacs 看内核代码，搜、查、改，我还没有真正的用起来。对 tag 文件的管理，增、删，也没有真正的做好，之前写的函数还没有真正的能够用起来，主要是因为有很多的分支和 tag ，我需要经常地切换分支。而切换分支之前不同的 tag 要重新生成，就算是
global -u 速度仍然不够快。还有生成 tag 是否成功，没有一个提示。这也做的不够好。


## 什么带绐我成就感？ {#什么带绐我成就感}

每当我打开 emacs 的时候，一股快乐的心情就会油然而起，它只需要 2 秒就能打开；

每当用 emacs 写博客，就像是一种享受；

每当用 emacs 写数学公式，就像是一种享受；

现在想做到的是，一用它打开看内核代码分析代码逻辑就是一种享受。


## 现在要做的重大优化：ggtags {#现在要做的重大优化-ggtags}

我经常用 git clean -xdf 来清楚 git 下未跟踪的文件，我打算把 global 的 tag 文件统一放到源码当中的 .gtags 目录。在 .bashrc
下加上这个函数（全部由 deepseek 生成）。

```bash
# git 修改
git() {
    if [[ "$1" == "clean" && "$2" == "-xdf" ]]; then
        command git clean -xdf -e .gtags -e .dir-locals.el
    else
        command git "$@"
    fi
}
```

下面这条 shell 命令可以获取到分支名或者是 tag 名。

```bash
git describe --tags --exact-match 2>/dev/null ||  git rev-parse --abbrev-ref HEAD
```

既然是在我自己电脑的环境里面了，那么，还是用 gnu global 是最好的选择。要做到在 shell 下用命令行或者是在 emacs 里面用各种
lisp 插件的感觉是一样的。

下面是 shell 下增加 global tag 的方法：

```bash
function ljupdate_gtags() {
    # 获取当前 Git 引用（tag 或分支）
    ref=$(git describe --tags --exact-match 2>/dev/null || git rev-parse --abbrev-ref HEAD)
    if [ -z "$ref" ]; then
        echo "Not in a Git repository."
        return 1
    fi

    # 创建 tags 目录（如果不存在）
    gtags_dir=".gtags/$ref"
    mkdir -p "$gtags_dir"

    # 设置环境变量
    export GTAGSROOT=$PWD
    export GTAGSDBPATH=$PWD/$gtags_dir

    # 生成或更新 tags
    if [ -f "$GTAGSDBPATH/GTAGS" ]; then
        global -u
    else
        gtags "$GTAGSDBPATH"
    fi

    echo "Tags for ref '$ref' are ready in '$gtags_dir'."
}
```

下面是 shell 删除 global tag 的方法：

```bash
function ljclean_gtags() {
    # 删除超过 30 天的旧 tags 目录
    find .gtags -type d -mtime +30 -exec rm -rf {} +
    echo "Old GTAGS directories cleaned."
}
```

还有 shell 当中更改 global tag 的路径的方法：

```bash
# 切换到指定 tag 或分支并更新 tags
function ljswitch_and_update_gtags() {
    if [ -z "$1" ]; then
        echo "Usage: switch_and_update_gtags <tag_or_branch>"
        return 1
    fi
    git checkout "$1" && update_gtags
}
```


### 使用 projectile 或 .dir-locals.el {#使用-projectile-或-dot-dir-locals-dot-el}

```emacs-lisp
((nil . ((ggtags-mode . t)
         (eval . (let* ((ref (replace-regexp-in-string "\n" "" (shell-command-to-string "git describe --tags --exact-match 2>/dev/null || git rev-parse --abbrev-ref HEAD")))
                       (gtags-dir (concat (projectile-project-root) ".gtags/" ref)))
                   (setenv "GTAGSDBPATH" gtags-dir)
                   (setenv "GTAGSROOT" (projectile-project-root))
                   (message (concat "GTAGSDBPATH set to: " gtags-dir)))))))
```


### 将 .dir-locals.el 的模板增加到 yasnippet {#将-dot-dir-locals-dot-el-的模板增加到-yasnippet}

增加这个模板后，可以直接补全，让所有依赖 global 的内核仓库使用。加模板很简单，这里就不说了。


### 在 emacs 当中执行这个更新 global tag 的命令 {#在-emacs-当中执行这个更新-global-tag-的命令}

```emacs-lisp
(defun lj/update-gtags ()
  "create global tag for current branch"
  (interactive)
  (async-shell-command "ljupdate_gtags")
  )
```


## orgmode 的缺点 {#orgmode-的缺点}

orgmode 的优点很多，但是它有所有的标记文本的缺点。不能像 word 那样对关键的内容进行背景颜色标记。这个缺点靠它本身是很难弥补的了。但是我之前写过可以和 drawio 一起使用。用截图来弥补这个缺点，也还可以。


## 总结 {#总结}

堪堪可用的赛博单衣，无数的怪癖习已为常。工业反哺农业，现在可以弥补之前浪费的时间了。
