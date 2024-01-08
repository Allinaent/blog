(TeX-add-style-hook
 "tty-x-switch-beamer"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("beamer" "8pt" "aspectratio=43" "mathserif" "table")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("algorithm2e" "ruled" "linesnumbered")))
   (add-to-list 'LaTeX-verbatim-environments-local "lstlisting")
   (add-to-list 'LaTeX-verbatim-environments-local "semiverbatim")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "lstinline")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "href")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperref")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperimage")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperbaseurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "nolinkurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "lstinline")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "path")
   (TeX-run-style-hooks
    "latex2e"
    "beamer"
    "beamer10"
    "graphicx"
    "animate"
    "hyperref"
    "amsmath"
    "bm"
    "amsfonts"
    "amssymb"
    "enumerate"
    "epsfig"
    "bbm"
    "calc"
    "color"
    "ifthen"
    "capt-of"
    "multimedia"
    "xeCJK"
    "algorithm2e"
    "fancybox"
    "xcolor"
    "times"
    "listings"
    "booktabs"
    "colortbl")
   (TeX-add-symbols
    "Console")
   (LaTeX-add-labels
    "fig:campus"
    "figure3_debug")
   (LaTeX-add-xcolor-definecolors
    "mygreen"
    "mymauve"
    "mygray"
    "mypink"
    "mycyan"))
 :latex)

