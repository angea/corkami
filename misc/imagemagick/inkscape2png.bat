convert -density 300 %~n1.pdf -background white -flatten +matte -trim %~n1_1.png
convert %~n1_1.png -type palette %~n1_2.png