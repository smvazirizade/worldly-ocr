# Arabic page segmentation experiments

## Cursive
Arabic as a cursive language presents a number of challenges.  Most
OCR algorithms use the BW ("binarized") form of page image.  One can
break up the page into connected components (4-connected or
8-connected, for example).

## Characters, ligatures and connected components
This does not identify characters. A larger unit is ligature. However,
ligatures consist of component characters and the diacritical marks
belonging to the components. The diacritical marks are identified as
separate objects by image processing. Therefore, a good algorithm
(based on proper heuristic) is needed to assign diacritical marks to
the major parts of ligatures.

## Isolated, Initial, Medial and Final Forms
Connecting Arabic characters into ligatures happens by using 3 forms
of each basic character (see file:://../Data-basic-arabic-letterforms.jpg).


## Lines of text
In this folder we also have an algorithm for breaking up text into
lines.  This algorithm fails if a page does not consist of purely
lines of text, but also includes images and oddly formatted text.

## Sample Result

See file://./SegmentedPageSample1.png