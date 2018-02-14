(TeX-add-style-hook
 "report"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("article" "12pt" "letterpaper")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("fontenc" "T1") ("inputenc" "utf8") ("babel" "frenchb") ("hyperref" "pdftex" "hidelinks")))
   (TeX-run-style-hooks
    "latex2e"
    "article"
    "art12"
    "fontenc"
    "inputenc"
    "babel"
    "gensymb"
    "latexsym"
    "titlesec"
    "marvosym"
    "enumitem"
    "hyperref"))
 :latex)

