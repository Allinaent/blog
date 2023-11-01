(TeX-add-style-hook
 "main"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("elegantbook" "cn" "10pt")))
   (add-to-list 'LaTeX-verbatim-environments-local "minted")
   (add-to-list 'LaTeX-verbatim-environments-local "cppcode")
   (add-to-list 'LaTeX-verbatim-environments-local "cppcode*")
   (add-to-list 'LaTeX-verbatim-environments-local "javacode")
   (add-to-list 'LaTeX-verbatim-environments-local "javacode*")
   (add-to-list 'LaTeX-verbatim-environments-local "shellcode")
   (add-to-list 'LaTeX-verbatim-environments-local "shellcode*")
   (add-to-list 'LaTeX-verbatim-environments-local "rubycode")
   (add-to-list 'LaTeX-verbatim-environments-local "rubycode*")
   (add-to-list 'LaTeX-verbatim-environments-local "typescriptcode")
   (add-to-list 'LaTeX-verbatim-environments-local "typescriptcode*")
   (add-to-list 'LaTeX-verbatim-environments-local "jscode")
   (add-to-list 'LaTeX-verbatim-environments-local "jscode*")
   (add-to-list 'LaTeX-verbatim-environments-local "sqlcode")
   (add-to-list 'LaTeX-verbatim-environments-local "sqlcode*")
   (add-to-list 'LaTeX-verbatim-environments-local "common-lispcode")
   (add-to-list 'LaTeX-verbatim-environments-local "common-lispcode*")
   (add-to-list 'LaTeX-verbatim-environments-local "lispcode")
   (add-to-list 'LaTeX-verbatim-environments-local "lispcode*")
   (add-to-list 'LaTeX-verbatim-environments-local "yamlcode")
   (add-to-list 'LaTeX-verbatim-environments-local "yamlcode*")
   (add-to-list 'LaTeX-verbatim-environments-local "xmlcode")
   (add-to-list 'LaTeX-verbatim-environments-local "xmlcode*")
   (add-to-list 'LaTeX-verbatim-environments-local "texcode")
   (add-to-list 'LaTeX-verbatim-environments-local "texcode*")
   (add-to-list 'LaTeX-verbatim-environments-local "rustcode")
   (add-to-list 'LaTeX-verbatim-environments-local "rustcode*")
   (add-to-list 'LaTeX-verbatim-environments-local "pythoncode")
   (add-to-list 'LaTeX-verbatim-environments-local "pythoncode*")
   (add-to-list 'LaTeX-verbatim-environments-local "htmlcode")
   (add-to-list 'LaTeX-verbatim-environments-local "htmlcode*")
   (add-to-list 'LaTeX-verbatim-environments-local "groovycode")
   (add-to-list 'LaTeX-verbatim-environments-local "groovycode*")
   (add-to-list 'LaTeX-verbatim-environments-local "gocode")
   (add-to-list 'LaTeX-verbatim-environments-local "gocode*")
   (add-to-list 'LaTeX-verbatim-environments-local "c++code")
   (add-to-list 'LaTeX-verbatim-environments-local "c++code*")
   (add-to-list 'LaTeX-verbatim-environments-local "cmakecode")
   (add-to-list 'LaTeX-verbatim-environments-local "cmakecode*")
   (add-to-list 'LaTeX-verbatim-environments-local "makecode")
   (add-to-list 'LaTeX-verbatim-environments-local "makecode*")
   (add-to-list 'LaTeX-verbatim-environments-local "abapcode")
   (add-to-list 'LaTeX-verbatim-environments-local "abapcode*")
   (TeX-run-style-hooks
    "latex2e"
    "elegantbook"
    "elegantbook10"
    "fontspec"
    "minted")
   (LaTeX-add-labels
    "sec:org8b93644"
    "sec:org25a4229"
    "sec:org5e7385c"
    "sec:org5e56fb4"
    "sec:org1d80efa"
    "sec:orgba4a093"
    "sec:org3d7ede4"
    "sec:org491fd13"
    "sec:orgb86efdd"
    "sec:org59101cf"
    "sec:orgb160bf2"
    "sec:org6284f9a"
    "sec:orge483ae3"
    "sec:org00d8331")
   (LaTeX-add-environments
    '("abapcode*" LaTeX-env-args (TeX-arg-key-val LaTeX-minted-key-val-options-local))
    '("abapcode")
    '("makecode*" LaTeX-env-args (TeX-arg-key-val LaTeX-minted-key-val-options-local))
    '("makecode")
    '("cmakecode*" LaTeX-env-args (TeX-arg-key-val LaTeX-minted-key-val-options-local))
    '("cmakecode")
    '("c++code*" LaTeX-env-args (TeX-arg-key-val LaTeX-minted-key-val-options-local))
    '("c++code")
    '("gocode*" LaTeX-env-args (TeX-arg-key-val LaTeX-minted-key-val-options-local))
    '("gocode")
    '("groovycode*" LaTeX-env-args (TeX-arg-key-val LaTeX-minted-key-val-options-local))
    '("groovycode")
    '("htmlcode*" LaTeX-env-args (TeX-arg-key-val LaTeX-minted-key-val-options-local))
    '("htmlcode")
    '("pythoncode*" LaTeX-env-args (TeX-arg-key-val LaTeX-minted-key-val-options-local))
    '("pythoncode")
    '("rustcode*" LaTeX-env-args (TeX-arg-key-val LaTeX-minted-key-val-options-local))
    '("rustcode")
    '("texcode*" LaTeX-env-args (TeX-arg-key-val LaTeX-minted-key-val-options-local))
    '("texcode")
    '("xmlcode*" LaTeX-env-args (TeX-arg-key-val LaTeX-minted-key-val-options-local))
    '("xmlcode")
    '("yamlcode*" LaTeX-env-args (TeX-arg-key-val LaTeX-minted-key-val-options-local))
    '("yamlcode")
    '("lispcode*" LaTeX-env-args (TeX-arg-key-val LaTeX-minted-key-val-options-local))
    '("lispcode")
    '("common-lispcode*" LaTeX-env-args (TeX-arg-key-val LaTeX-minted-key-val-options-local))
    '("common-lispcode")
    '("sqlcode*" LaTeX-env-args (TeX-arg-key-val LaTeX-minted-key-val-options-local))
    '("sqlcode")
    '("jscode*" LaTeX-env-args (TeX-arg-key-val LaTeX-minted-key-val-options-local))
    '("jscode")
    '("typescriptcode*" LaTeX-env-args (TeX-arg-key-val LaTeX-minted-key-val-options-local))
    '("typescriptcode")
    '("rubycode*" LaTeX-env-args (TeX-arg-key-val LaTeX-minted-key-val-options-local))
    '("rubycode")
    '("shellcode*" LaTeX-env-args (TeX-arg-key-val LaTeX-minted-key-val-options-local))
    '("shellcode")
    '("javacode*" LaTeX-env-args (TeX-arg-key-val LaTeX-minted-key-val-options-local))
    '("javacode")
    '("cppcode*" LaTeX-env-args (TeX-arg-key-val LaTeX-minted-key-val-options-local))
    '("cppcode")))
 :latex)

