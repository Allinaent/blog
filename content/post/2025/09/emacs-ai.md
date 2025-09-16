+++
title = "如何在 emacs 当中使用各种 ai 插件"
date = 2025-09-15T17:11:00+08:00
lastmod = 2025-09-16T15:03:37+08:00
draft = false
toc = true
image = "https://r2.guolongji.xyz/allinaent/2024/06/92a1feeab471b12646b9c76edccc1546.jpg"
+++

## 前言 {#前言}

先在利用大模型编程这么火，不是用 vscode 的就是用 cursor 的。难道在 emacs 下面就没有比较好体验的 ai 编程插件吗？

经过一番尝试，虽然目前 emacs 的 ai 插件相对于 vscode 和 cursor 实现的好像差一点，但是足够用了。


## 插件选择 {#插件选择}

| 插件名       | 好用度 |
|-----------|-----|
| gptel        | 5   |
| eca          | 5   |
| copilot      | 4   |
| copilot-chat | 4   |
| aider        | 2   |
| aidermacs    | 2   |
| claude code  | ?   |
| emigo        | ?   |
| mind-wave    | ?   |


### aider &amp; aidermacs {#aider-and-aidermacs}

aider 和 aidermacs 是基于 git 的，对于大项目，像 linux 内核这种没有做优化。做小项目感觉还行，但是不适合当下的我。这两个是结对编程工具，相比而言，我更喜欢 aider
而不是 aidermacs ，因为 aider 可以用命令控制文件范围，封装比较多的aidermacs没有让我感觉很清爽，我不知道。


### copilot &amp; copilot-chat {#copilot-and-copilot-chat}

copilot 和 copilot-chat 是可以的，但是 github 的 copilot 每个月的聊天额度实现是太低了。copilot 插件只是补全，copilot-chat 只有一个 api 支持。效果一般，但是如果每年充值 100 美金的话也不错。


### gptel （很棒，推荐） {#gptel-很棒-推荐}

```lisp
(use-package gptel
  :ensure t
  :config
  ;; 设置默认模型
  (setq gptel-model "gpt-5-nano-ca") ;gpt-4.1-nano
  ;; 创建并设置后端
  (setq chatkey (with-temp-buffer
                  (insert-file-contents "~/.config/chatanywhere/key.txt")
                  (string-trim (buffer-string))))
  (setq gptel-backend
        (gptel-make-openai "chatanywhere" ; 后端名称，可自定义
          :host "api.chatanywhere.tech"   ; API 主机地址
          :endpoint "/v1/chat/completions"
          :key chatkey   ; 你的 API 密钥，也可用函数获取
          :models '("gpt-4o-mini" "gpt-4.1-nano" "gpt-5-nano-ca") ; 可用的模型列表
          :stream t
          ))
  (with-eval-after-load 'gptel
    (setq gptel-default-mode 'org-mode)) ;; 设置默认模式为 org-mode
  (defun my-gptel-org-to-markdown (text)
    "Convert Org-mode input to Markdown for GPT prompt."
    (with-temp-buffer
      (insert text)
      (org-export-as 'markdown)
      (buffer-string)))

  (setq gptel-format-function #'my-gptel-org-to-markdown)
  (defun my/gptel-switch-to-higress ()
    "切换到 Higress 后端"
    (interactive)
    (setq uoskey (with-temp-buffer
                   (insert-file-contents "~/.config/uos/api.txt")
                   (string-trim (buffer-string))))
    (setq gptel-model "deepseek-3.1")
    (setq gptel-backend
          (gptel-make-openai "Higress"
            :host "ai.uniontech.com"
            :endpoint "/api/v1/chat/completions"
            :key uoskey
            :models '("deepseek-3.1" "kimi-k2")
            :stream nil))
    (message "已切换到 Higress 后端"))

  (defun my/gptel-switch-to-chatanywhere ()
    "切换到 ChatAnywhere 后端"
    (interactive)
    (setq chatkey (with-temp-buffer
                    (insert-file-contents "~/.config/chatanywhere/key.txt")
                    (string-trim (buffer-string))))
    (setq gptel-model "gpt-4o-mini")
    (setq gptel-backend
          (gptel-make-openai "chatanywhere"
            :host "api.chatanywhere.tech"
            :endpoint "/v1/chat/completions"
            :key chatkey
            :models '("gpt-4o-mini" "gpt-4.1-nano" "gpt-5-nano-ca")
            :stream t))
    (message "已切换到 ChatAnywhere 后端"))

  ;; 绑定快捷键
  (global-set-key (kbd "C-c g h") #'my/gptel-switch-to-higress)
  (global-set-key (kbd "C-c g c") #'my/gptel-switch-to-chatanywhere)

  (transient-define-prefix my/gptel-backend-selector ()
    "选择 GPTel 后端"
    ["请选择后端"
     ("h" "Higress" my/gptel-switch-to-higress)
     ("c" "ChatAnywhere" my/gptel-switch-to-chatanywhere)])

  ;; 绑定菜单快捷键
  (global-set-key (kbd "C-c g b") #'my/gptel-backend-selector)

  (transient-define-prefix my/gptel-model-selector ()
    "选择 GPTel 模型"
    ["请选择模型"
     ("d" "deepseek-3.1" (lambda () (interactive) (setq gptel-model "deepseek-3.1") (message "已切换至 deepseek-3.1")))
     ("k" "kimi-k2" (lambda () (interactive) (setq gptel-model "kimi-k2") (message "已切换至 kimi-k2")))])

  ;; 绑定菜单快捷键，例如 C-c g m
  (global-set-key (kbd "C-c g m") #'my/gptel-model-selector)
  )
```

gptel 的使用截图如下：

{{< figure src="https://r2.guolongji.xyz/allinaent/2025/09/fa939f64917d25d54ca53219e6fe798f.jpg" alt="Caption not used as alt text" caption="<span class=\"figure-number\">图 1: </span>/ gptel 使用截图 /" link="t" class="fancy" width="900" target="_blank" >}}


### eca （推荐） {#eca-推荐}

eca 有一个 server ，文档在： <https://eca.dev/> ，这是个支持 MCP 的 server ，可以让它帮忙写代码以及合入， eca 不是基于 git 的，用起来非常不错。这个 server 用的是
Clojure 来开发的，我觉得很有潜力！

```lisp
(use-package eca
  :ensure t
  :defer t
  :config
  ;;(setq eca-chat-custom-model "uos/kimi-k2") ;; deepseek-3.1 or kimi-k2
  (setq eca-chat-custom-model "uos/deepseek-3.1") ;; deepseek-3.1 or kimi-k2
  )
```

这个还需要配置一下 eca 的 server，~/.config/eca/config.json

```bash
{
  "providers": {
      "uos": {
              "api": "openai-chat",
              "key": "",
                 "url": "https://ai.uniontech.com/api/v1",
                 "models": {
                        "deepseek-3.1": {
                                "extraPayload": {
                                        "max_tokens": 16384,
                                        "max_output_tokens": 8192,
                                        "capabilities": {
                                                "tools": true,
                                                "images": false,
                                                "parallel_tool_calls": false,
                                                "prompt_cache_key": false
                                        }
                                }
                        },
                        "kimi-k2": {
                                "extraPayload": {
                                        "max_tokens": 32768,
                                        "max_output_tokens": 4096
                                }
                        }
                 }
      }
  },
  "defaultModel": "uos/deepseek-3.1",
  "rules" : [],
  "commands" : [],
  "disabledTools": [],
  "toolCall": {
    "approval": {
      "byDefault": "ask",
      "allow": {"eca_directory_tree": {},
                "eca_read_file": {},
                "eca_grep": {},
                "eca_preview_file_change": {},
                "eca_editor_diagnostics": {}},
      "ask": {},
      "deny": {}
    }
  },
  "mcpTimeoutSeconds" : 60,
  "lspTimeoutSeconds" : 30,
  "mcpServers" : {},
  "behavior" : {
    "agent": {"systemPromptFile": "prompts/agent_behavior.md",
              "disabledTools": ["eca_preview_file_change"]},
    "plan": {"systemPromptFile": "prompts/plan_behavior.md",
              "disabledTools": ["eca_edit_file", "eca_write_file", "eca_move_file"],
              "toolCall": {"approval": {"deny": {"eca_shell_command":
                                                 {"argsMatchers": {"command" : [".*>.*",
                                                                              ".*\\|\\s*(tee|dd|xargs).*",
                                                                              ".*\\b(sed|awk|perl)\\s+.*-i.*",
                                                                              ".*\\b(rm|mv|cp|touch|mkdir)\\b.*",
                                                                              ".*git\\s+(add|commit|push).*",
                                                                              ".*npm\\s+install.*",
                                                                              ".*-c\\s+[\"'].*open.*[\"']w[\"'].*",
                                                                              ".*bash.*-c.*>.*"]}}}}}}
  },
  "defaultBehavior": "agent",
  "welcomeMessage" : "Welcome to ECA!\n\nType '/' for commands\n\n",
  "index" : {
    "ignoreFiles" : [ {
      "type" : "gitignore"
    } ],
    "repoMap": {
      "maxTotalEntries": 800,
      "maxEntriesPerDir": 50
    }
  }
}
```

eca 的使用截图如下：

{{< figure src="https://r2.guolongji.xyz/allinaent/2025/09/288d05586d34a0191b81ab23dc3c1ce8.jpg" alt="Caption not used as alt text" caption="<span class=\"figure-number\">图 2: </span>_eca 的使用截图_" link="t" class="fancy" width="900" target="_blank" >}}


## 大模型选择 {#大模型选择}

大模型的提供商有：

| 公司/组织  | 代表性模型                            | 特点             |
|--------|----------------------------------|----------------|
| OpenAI     | GPT-4 Turbo / GPT-5                   | 行业标杆，多模态支持 |
| Google     | Gemini 1.5 / PaLM 2                   | 多模态，深度集成谷歌生态 |
| Anthropic  | Claude 4 /claude-3-sonnet （cursor 可选） | 长上下文，安全性优先 |
| Meta       | Llama 3（开源，可本地部署）           | 开源可商用，社区生态强大 |
| DeepSeek   | DeepSeek-R1                           | 免费开放，长上下文支持 |
| Mistral AI | Mixtral                               | 高效 MoE 架构，欧洲开源代表 |
| xAi        | Grok                                  | 响应速度快       |


### 选中间商还是出品商 {#选中间商还是出品商}

中间商 <https://api.chatanywhere.tech/> 的 api 价格相对低一些，且能解决一些网络不通的问题。

便宜的有 gpt-5-nano-ca 这个模型，问一个问题大概花一分钱。中间商不知道有没有价格或者模型上有黑幕，咱也不敢瞎猜，只能试试看看效果如何。目前 gpt-5-nano-ca 的返回速度有时有点慢，但是感觉价格还是比较便宜的。

coplit 包含很多可选的模型，每年100 美金价格不算贵，都能负担的起，但是选模型也是用用 claude 4 就不能用了，这个是同事试的，可能是他支付的途径是共享账号？不太清楚其中的水是不是很深。感觉水都比较深。

claude-opus-4 这个模型官网的费用太高了。不想用。


### 公司的模型 {#公司的模型}

公司提供了可用的 api 服务，目前有 kimi-k2 和 deepseek-3.1 可以选，但是返回速度有点慢，感觉模型也不是很好用，聊胜于无。


## 总结 {#总结}

想要真正用起来，并且比较好用，目前的想法是有钱人用 emacs 的claude code 插件加上
claude-opus-4的模型。不计成本，总能使用最高效的工具。

没钱的人就用 chatanywhere 里面的一些较为便宜的模型吧。后续通过 emacs 的基础能力，加上大模型的发展，相信以后可以编程越来越简单。真的就会变成是一个解迷游戏，经验和方向才会变成最有价值的竞争力。
