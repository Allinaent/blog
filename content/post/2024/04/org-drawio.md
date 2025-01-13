+++
title = "orgmode 使用drawio 画图"
date = 2024-04-02T22:09:00+08:00
lastmod = 2025-01-13T12:51:01+08:00
categories = ["emacs"]
draft = false
toc = true
image = "https://r2.guolongji.xyz/allinaent/2024/06/af960550dc8dbdc44674aa00e830fc90.png"
+++

## 画图测试 {#画图测试}

下载的 drawio 的 deb 包，命令名字是 drawio ，而插件用的是 draw.io ，做一个软链接，可以解决org-drawio-open 的调用。插件自己的代码是在 win 上使用的，不太适合 gnu/linux 环境，显然没有进行过真正的适配和调试，有一些问题。做一些修改，现在适合在
linux 上面使用了。

<https://github.com/kimim/org-drawio>

{{< figure src="/ox-hugo/sample1.svg" >}}


## 有错误在 emacs 下如何调试 {#有错误在-emacs-下如何调试}

M-x edebug-defun 单步执行 emacs 函数。

M-x toggle-debug-on-error emacs 出错的时候进入 debug 。


## 我的方案 {#我的方案}

高质量的插件是需要大量测试覆盖的，开源的东西没有有那么多精力把所有的细节都调整好，很多时候都是用户理解思路并做一些小的修改。add 函数是为了创建 drawio 的源文件并刷新。open 是为了调用外部的 drawio 应用。但是这两个函数都不适合 linux 下的环境。emacs 使用者的环境可以说千奇百怪。

下面对函数做一下修改：

```lisp
(use-package org-drawio
  :commands (org-drawio-add
             org-drawio-open)
  :custom ((org-drawio-input-dir "./draws")
           (org-drawio-output-dir "./images")
           (org-drawio-output-page "0")
           ;; set to t, if you want to crop the image.
           (org-drawio-crop nil)))

(require 'org-drawio)

(defun lj/org-drawio-new-if-not-exist (dir file)
  "If a FILE or DIR not exsit, create an empty drawio diagram."
  (let ((path (concat dir "/" file)))
    (when (not (file-exists-p path))
      (when (not (file-exists-p dir))
        (make-directory dir))
      ;;(make-empty-file file dir)
      (write-region
       "<mxfile host=\"Electron\" agent=\"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) draw.io/24.1.0 Chrome/120.0.6099.109 Electron/28.1.0 Safari/537.36\" version=\"24.1.0\" type=\"device\">
  <diagram name=\"第 1 页\" >
    <mxGraphModel dx=\"2074\" dy=\"1203\" grid=\"1\" gridSize=\"10\" guides=\"1\" tooltips=\"1\" connect=\"1\" arrows=\"1\" fold=\"1\" page=\"1\" pageScale=\"1\" pageWidth=\"827\" pageHeight=\"583\" math=\"0\" shadow=\"0\">
      <root>
        <mxCell id=\"0\" />
        <mxCell id=\"1\" parent=\"0\" />
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>"
       nil path)
     )))

(defun lj/org-drawio-open ()
  "Open .drawio file in current line of #+drawio keyword."
  (interactive)
  (let* ((keyword-plist (org-drawio-keyword-string-to-plist))
         (dio-input (file-name-with-extension
                     (plist-get keyword-plist :input) "drawio"))
         (dio-input-dir (or (plist-get keyword-plist :input-dir)
                            org-drawio-input-dir))
         (_ (lj/org-drawio-new-if-not-exist dio-input-dir dio-input))
         (path (concat dio-input-dir "/" dio-input)))
    (cond
     ;; ensure that draw.io.exe is in execute PATH
     ((string-equal system-type "windows-nt")
      (if (fboundp 'w32-shell-execute)
          (w32-shell-execute "open" path)))
     ;; TODO: need some test for other systems
     ((string-equal system-type "darwin")
      (start-process "" nil "open" "-a"
                     (or org-drawio-command-drawio
                         "draw.io")
                     path))
     ((string-equal system-type "gnu/linux")
      (progn
        (set 'cmd0 (concat "drawio " path))
        (message cmd0)
        (my-sh-send-command cmd0)
      )
      ;;(start-process "" nil "xdg-open"
      ;;               (or org-drawio-command-drawio
      ;;                   "draw.io")
      ;;               path)
      )
     ((string-equal system-type "cygwin")
      (start-process "" nil "xdg-open" (or org-drawio-command-drawio
                                           "draw.io")
                     path)))))
;;;;;
(defun lj/org-drawio-add ()
  "Convert .drawio file to .svg file, and insert svg to orgmode."
  (interactive)
  (save-excursion
    (let* ((keyword-plist (org-drawio-keyword-string-to-plist))
           (dio-input-dir (or (plist-get keyword-plist :input-dir)
                              org-drawio-input-dir))
           (dio-input (file-name-with-extension
                       (plist-get keyword-plist :input) "drawio"))
           (_ (lj/org-drawio-new-if-not-exist dio-input-dir dio-input))
           (dio-page (or (plist-get keyword-plist :page)
                         org-drawio-page))
           (dio-output-dir (or (plist-get keyword-plist :output-dir)
                               org-drawio-output-dir))
           (dio-output (plist-get keyword-plist :output))
           ;; if output file specified, use it, otherwise append page to it.
           (dio-output-svg (if dio-output
                               (file-name-with-extension dio-output "svg")
                             (file-name-with-extension
                              (concat (file-name-sans-extension dio-input)
                                      "-" dio-page)
                              "svg")))
           (dio-output-pdf (file-name-with-extension dio-output-svg "pdf"))
           ;; create output dir if non exist
           (_ (when (not (file-exists-p dio-output-dir))
                (make-directory dio-output-dir)))
           (script (format "%s -x %s%s/%s -p %s -o %s/%s >/dev/null 2>&1 && \
%s %s/%s %s/%s >/dev/null 2>&1"
                           (file-truename
                            (executable-find (or org-drawio-command-drawio "draw.io")))
                           (if org-drawio-crop "--crop " "")
                           (shell-quote-argument dio-input-dir)
                           (shell-quote-argument dio-input) dio-page
                           (shell-quote-argument dio-output-dir)
                           (shell-quote-argument dio-output-pdf)
                           (or org-drawio-command-pdf2svg
                               "pdf2svg")
                           (shell-quote-argument dio-output-dir)
                           (shell-quote-argument dio-output-pdf)
                           (shell-quote-argument dio-output-dir)
                           (shell-quote-argument dio-output-svg)))
           ;; special handling, home path should not be backquoted
           (script (string-replace "\\~" "~" script)))
      ;; skip #+caption, #+name of image
      (if (org-next-line-empty-p)
          (progn (end-of-line) (insert-char ?\n))
        (while (string-prefix-p "#+" (org-current-line-string))
          (forward-line)))
      ;; convert from drawio to svg asynchronously, thanks to twiddling
      (let ((process (start-process-shell-command "org-drawio" nil script)))
        (set-process-sentinel
         process `(lambda (process event)
                    (message event)
                    (when (string-match-p "finished" event)
                      ;; trash pdf file
                      (delete-file ,(concat dio-output-dir "/" dio-output-pdf) t)
                      ;; refresh image
                      (org-redisplay-inline-images)))))
      (when (string-prefix-p "[[" (org-current-line-string))
        ;; when it is image link
        (kill-whole-line 0))
      (insert "[[file:" dio-output-dir "/" dio-output-svg "]]"))))

```


## emacs 的画图 {#emacs-的画图}

之前尝试过 emacs 用 tikz 来画图，比较麻烦。适合没事的时候边学边练，有了足够的熟练度之后才能享受到如臂使指。而 drawio 是一个上手难度极低，而且功能也足够强的一个工具。做为一个程序员，称手的工具很重要，但是更重要的是内功。

练好内功，学习一些更有价值的东西，切记。


## 补充 {#补充}

之前的插件是用的 svg 转 pdf ，后来使用发现在 emacs 当中使用 jpg 是更好的选择和方式，对插件的代码做了一下修改，如下：

```lisp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; drawio 这个插件不好用，试一下下面那个
(use-package org-drawio
  :commands (org-drawio-add
             org-drawio-open)
  :custom ((org-drawio-input-dir "./draws")
           (org-drawio-output-dir "./images")
           (org-drawio-output-page "0")
           ;; set to t, if you want to crop the image.
           (org-drawio-crop nil)))

(require 'org-drawio)

(defun lj/org-drawio-new-if-not-exist (dir file)
  "If a FILE or DIR not exsit, create an empty drawio diagram."
  (let ((path (concat dir "/" file)))
    (when (not (file-exists-p path))
      (when (not (file-exists-p dir))
        (make-directory dir))
      ;;(make-empty-file file dir)
      (write-region
       "<mxfile host=\"Electron\" agent=\"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) draw.io/24.1.0 Chrome/120.0.6099.109 Electron/28.1.0 Safari/537.36\" version=\"24.1.0\" type=\"device\">
  <diagram name=\"第 1 页\" >
    <mxGraphModel dx=\"2074\" dy=\"1203\" grid=\"1\" gridSize=\"10\" guides=\"1\" tooltips=\"1\" connect=\"1\" arrows=\"1\" fold=\"1\" page=\"0\" pageScale=\"1\" pageWidth=\"827\" pageHeight=\"583\" math=\"0\" shadow=\"0\">
      <root>
        <mxCell id=\"0\" />
        <mxCell id=\"1\" parent=\"0\" />
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>"
       nil path)
     )))

(defun lj/org-drawio-open ()
  "Open .drawio file in current line of #+drawio keyword."
  (interactive)
  (let* ((keyword-plist (org-drawio-keyword-string-to-plist))
         (dio-input (file-name-with-extension
                     (plist-get keyword-plist :input) "drawio"))
         (dio-input-dir (or (plist-get keyword-plist :input-dir)
                            org-drawio-input-dir))
         (_ (lj/org-drawio-new-if-not-exist dio-input-dir dio-input))
         (path (concat dio-input-dir "/" dio-input)))
    (cond
     ;; ensure that draw.io.exe is in execute PATH
     ((string-equal system-type "windows-nt")
      (if (fboundp 'w32-shell-execute)
          (w32-shell-execute "open" path)))
     ;; TODO: need some test for other systems
     ((string-equal system-type "darwin")
      (start-process "" nil "open" "-a"
                     (or org-drawio-command-drawio
                         "draw.io")
                     path))
     ((string-equal system-type "gnu/linux")
      (progn
        (set 'cmd0 (concat "drawio " path))
        (message cmd0)
        (my-sh-send-command cmd0)
      )
      ;;(start-process "" nil "xdg-open"
      ;;               (or org-drawio-command-drawio
      ;;                   "draw.io")
      ;;               path)
      )
     ((string-equal system-type "cygwin")
      (start-process "" nil "xdg-open" (or org-drawio-command-drawio
                                           "draw.io")
                     path)))))
;;;;;
(defun lj/org-drawio-add ()
  "Convert .drawio file to .svg file, and insert svg to orgmode."
  (interactive)
  (save-excursion
    (let* ((keyword-plist (org-drawio-keyword-string-to-plist))
           (dio-input-dir (or (plist-get keyword-plist :input-dir)
                              org-drawio-input-dir))
           (dio-input (file-name-with-extension
                       (plist-get keyword-plist :input) "drawio"))
           (_ (lj/org-drawio-new-if-not-exist dio-input-dir dio-input))
           (dio-page (or (plist-get keyword-plist :page)
                         org-drawio-page))
           (dio-output-dir (or (plist-get keyword-plist :output-dir)
                               org-drawio-output-dir))
           (dio-output (plist-get keyword-plist :output))
           ;; if output file specified, use it, otherwise append page to it.
           (dio-output-svg (if dio-output
                               (file-name-with-extension dio-output "svg")
                             (file-name-with-extension
                              (concat (file-name-sans-extension dio-input)
                                      "-" dio-page)
                              "svg")))
           ;;(dio-output-pdf (file-name-with-extension dio-output-svg "pdf"))
           (dio-output-pdf (file-name-with-extension dio-output-svg "jpg"))
           ;; create output dir if non exist
           (_ (when (not (file-exists-p dio-output-dir))
                (make-directory dio-output-dir)))
;;           (script (format "%s -x -a %s%s/%s -p %s -o %s/%s >/dev/null 2>&1 && \
;;%s %s/%s %s/%s >/dev/null 2>&1"
;;                           (file-truename
;;                            (executable-find (or org-drawio-command-drawio "draw.io")))
;;                           (if org-drawio-crop "--crop " "")
;;                           (shell-quote-argument dio-input-dir)
;;                           (shell-quote-argument dio-input) dio-page
;;                           (shell-quote-argument dio-output-dir)
;;                           (shell-quote-argument dio-output-pdf)
;;                           (or org-drawio-command-pdf2svg
;;                               "pdf2svg")
;;                           (shell-quote-argument dio-output-dir)
;;                           (shell-quote-argument dio-output-pdf)
;;                           (shell-quote-argument dio-output-dir)
;;                           (shell-quote-argument dio-output-svg)))

                      (script (format "%s -x -a %s%s/%s -p %s -o %s/%s >/dev/null 2>&1 &"
                           (file-truename
                            (executable-find (or org-drawio-command-drawio "draw.io")))
                           (if org-drawio-crop "--crop " "")
                           (shell-quote-argument dio-input-dir)
                           (shell-quote-argument dio-input) dio-page
                           (shell-quote-argument dio-output-dir)
                           (shell-quote-argument dio-output-pdf)
                           ))

           ;; special handling, home path should not be backquoted
           (script (string-replace "\\~" "~" script)))
      (message script)
      ;; skip #+caption, #+name of image
      (if (org-next-line-empty-p)
          (progn (end-of-line) (insert-char ?\n))
        (while (string-prefix-p "#+" (org-current-line-string))
          (forward-line)))
      ;; convert from drawio to svg asynchronously, thanks to twiddling
      (let ((process (start-process-shell-command "org-drawio" nil script)))
        (set-process-sentinel
         process `(lambda (process event)
                    (message event)
                    (when (string-match-p "finished" event)
                      (progn
                        ;;(message "haha")
                        ;; trash pdf file
                        ;;(delete-file ,(concat dio-output-dir "/" dio-output-pdf) t)
                        (sleep-for 0.5)
                        ;; refresh image
                        (org-redisplay-inline-images)
                        ;;(message "aoao")
                      )
                      ))))
      (when (string-prefix-p "[[" (org-current-line-string))
        ;; when it is image link
        (kill-whole-line 0))
      (insert "[[file:" dio-output-dir "/" dio-output-pdf "]]"))))
```

后面这个插件可以做的更完善，后面再说。
