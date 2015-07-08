(TeX-add-style-hook
 "Songbook"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("article" "twocolumn" "10pt")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("inputenc" "utf8") ("fontenc" "OT2" "T1") ("songs" "lyric")))
   (TeX-run-style-hooks
    "latex2e"
    "rules"
    "songs/index"
    "article"
    "art10"
    "inputenc"
    "emptypage"
    "fontenc"
    "hyperref"
    "songs"
    "musixtex")))

