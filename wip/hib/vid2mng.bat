rem <video> <outputname> <start> <frames> <rate>
mplayer %1 -vo png -ao pcm:file=%2.wav -ss %3 -frames %4

mkdir %2
move *.png %2
advmng -a %5 %2.mng %2\*.png

call wav2mp3 %2.wav
move %2.wav %2
move %2.mp3 _slides
move %2.mng _slides
