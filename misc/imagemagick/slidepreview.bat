convert %~n1.pdf [-resize 25%] %03d.jpg
montage *.jpg [-geometry +0+0] %~n1-map.jpg