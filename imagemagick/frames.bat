..\convert %1%2.png +level-colors Green, 0.png
..\convert %1%3.png +level-colors Red, z.png
..\convert %1%3.png +level-colors Red, zz.png
..\convert -delay 125 -page +0+0 *.png final.gif