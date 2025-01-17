#!/bin/sh
#
# This script produces an image with a sample of text in an available font.
# The font can be any Linux accessible font. For instance, we installed
# the font file Lunafreya.ttf in ~/.fonts and now we can typeset documents
# in it.

#We no longer need this, as we are using a heredoc as LaTeX input
#lualatex forpdflatex.tex

# Run LaTeX (must be lualatex!) on the here document

lualatex <<EOF
\documentclass{article}
% This is for LuaTeX or XeTeX
\usepackage{fontspec}
\setmainfont{[Lunafreya.ttf]}
\begin{document}
% Contains all letters of the English alphabet
\begin{LARGE}
The quick brown fox jumps over the lazy dog
\end{LARGE}
\end{document}
EOF

# Convert the document to PPM
pdftoppm -r 600 texput.pdf texput

# NOTE: The command below does not crop properly
#convert -trim forpdflatex-*.ppm forpdflatex_trimmed.ppm

# This implements GIMP zealous crop programmatically
#./crop.sh forpdflatex-1.ppm forpdflatex.tiff

# Run GIMP on texput.ppm to produce a file texput.tiff (a TIFF file)
input=texput-1.ppm
output=texput.tiff
gimp -i -b "(crop-ppm \"$input\" \"$output\")" -b "(gimp-quit 0)"

# Cleanup
rm texput.pdf texput-1.ppm texput.log texput.aux

