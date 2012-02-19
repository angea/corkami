gswin32c.exe -dNOPAUSE -dBATCH -sDEVICE=pngalpha -r400 -sOutputFile=opcodes_tables%%02d.png opcodes_tables.pdf
convert opcodes_tables02.png -trim Java_onepage.png

convert ( ( opcodes_tables03.png -gravity West -background white -splice 1x0  -background black -splice 1x0 -trim  +repage -chop 0x1 ) ( opcodes_tables04.png -gravity East -background white -splice 1x0  -background black -splice 1x0 -trim  +repage -chop 0x1 ) +append ) Java.png
convert Java.png -trim Java.png

convert opcodes_tables05.png -trim DotNet_onepage.png

convert ( ( opcodes_tables06.png -gravity West -background white -splice 1x0  -background black -splice 1x0 -trim  +repage -chop 0x1 ) ( opcodes_tables07.png -gravity East -background white -splice 1x0  -background black -splice 1x0 -trim  +repage -chop 0x1 ) +append ) DotNet.png
convert DotNet.png -trim DotNet.png

convert opcodes_tables08.png -trim Android_onepage.png
convert opcodes_tables09.png -trim x86_onepage.png
convert opcodes_tables10.png -trim x64_onepage.png
