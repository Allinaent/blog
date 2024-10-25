+++
title = "在 linux 下使用 picgo 的最佳实践"
date = 2024-10-25T10:21:00+08:00
lastmod = 2024-10-25T11:25:54+08:00
categories = ["technology"]
draft = false
toc = true
image = "https://r2.guolongji.xyz/allinaent/2024/10/db1a780dae2885902e61196efd536955.png"
+++

## picgo 是什么？ {#picgo-是什么}

picgo 是一个可以上传图床的工具，用 nodejs electron 开发的。在 macos 和 window 上很好使用。但是在linux 当中我之前一直是直接用 appimage 运行。但这有一个缺点，就是不能后台运行。nohup ，disown 这些都没用。

尝试使用了 snap 安装 picgo ，问题是一样的。

后来经过各种尝试终于找到了好的起动方法。


## 与时俱进 nvm 很好用 {#与时俱进-nvm-很好用}

计算机的技术一直在发展，好的实践也在变化。比如 nodejs ，现在用 nvm 来管理。

安装 nvm ：

curl -o- <https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh> | bash

picgo 的文档当中没有说用的哪个版本的 node 和 npm 来开发的，我试了三个版本。

nvm ls-remote

nvm install v20.18.0

nvm install v18.20.4

nvm install v16.20.2

最终用 v16 可以成功的

nvm ls

git clone <https://github.com/Molunerfinn/PicGo.git>

cd 进入。

安装 yarn

```bash
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update
sudo apt install yarn
yarn --version
```

yarn install

npm run electron:build

能编译成功，运行一样会退出。


## node 工具 pm2 {#node-工具-pm2}

npm install pm2 -g

```bash
uos@guolongji:~/INSTALL/picgo$ tree
.
├── nohup.out
├── PicGo-2.4.0-beta.7.AppImage
├── PicGo-2.4.0-beta.8.AppImage
└── run.sh
```

run.sh

```bash
./PicGo-2.4.0-beta.8.AppImage --no-sandbox
```

.bashrc 中增加：

```bash
# picgo
alias picgo='pm2 start ~/INSTALL/picgo/run.sh'
nvm alias default v16.20.2 > /dev/null 2>&1
```

这样就可以一个命令 picgo ，直接在终端起动 picgo 软件了。再也不怕终端退出了，很清爽。


## picgo 的 db 一定要记得过段时间提交一下 {#picgo-的-db-一定要记得过段时间提交一下}

在 ~/.config/picgo/picgo.db 中存了 picgo 的文件名，我可以通过文件名搜索图片。这对以后有帮助。所以 picgo.db 这个文件可以上传到配置的 git 仓库中。这样我的长久搜集的好图片就不会找不到了。


## 其它 {#其它}

zotero 的工作流看 pdf 做笔记完美，但是现在的 linux 7.0.8 版本同步图片有问题。后续一定会修复的。目前使用 emacs 也不错。

另外，linux 环境复杂，如果环境问题解不掉。试试 nix ，snap 。如果不能用，再想其它办法。

比如有时候网不好， `nix-channel update --` 失败了，换个时间试试就成功了。（遇到 orgmode 当中两个连续的 hyphen 连字符，可以用两个等号标注并转义）

然后 nix-env -iA nixpkgs.nekoray 居然很快也安装成功了。这就很完美！
