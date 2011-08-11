include paths.inc

all: temp pe.pdf packers.pdf opcodes.pdf cm.pdf

clean:
	rd temp /s /q & del opcodes.pdf pe.pdf packers.pdf cm.pdf

temp:
	mkdir temp

temp\packers_starts.pdf : packers_starts.svg
	$(inkpath)/inkscape.exe -A $(CURDIR)/$@ $(CURDIR)/$<
temp\packers_features.pdf: packers_features.svg
	$(inkpath)/inkscape.exe -A $(CURDIR)/$@ $(CURDIR)/$<
temp\packers_models.pdf: packers_models.svg
	$(inkpath)/inkscape.exe -A $(CURDIR)/$@ $(CURDIR)/$<
temp\packers_algos.pdf: packers_algos.svg
	$(inkpath)/inkscape.exe -A $(CURDIR)/$@ $(CURDIR)/$<
temp\packers_landscape.pdf: packers_landscape.svg
	$(inkpath)/inkscape.exe -A $(CURDIR)/$@ $(CURDIR)/$<
temp\packers_details.pdf: packers_details.tex
	cd temp & $(texify) ..\$< & cd ..
temp\packers_fp.pdf: packers_fp.tex
	cd temp & $(texify) ..\$< & cd ..


temp\opcodes_1.pdf: opcodes_1.svg
	$(inkpath)/inkscape.exe -A $(CURDIR)/$@ $(CURDIR)/$<
temp\opcodes_2.pdf: opcodes_2.svg
	$(inkpath)/inkscape.exe -A $(CURDIR)/$@ $(CURDIR)/$<
temp\opcodes64_1.pdf: opcodes64_1.svg
	$(inkpath)/inkscape.exe -A $(CURDIR)/$@ $(CURDIR)/$<
temp\opcodes_desc.pdf: opcodes_desc.tex
	$(texify) $< & move opcodes_desc.pdf temp
temp\opcodes_fp.pdf: opcodes_fp.tex
	$(texify) $< & move opcodes_fp.pdf temp
temp\opcodes1.pdf: opcodes1.tex
	cd temp & $(texify) ..\$< & cd ..

temp\pe-headers.pdf: pe-headers.svg
	$(inkpath)/inkscape.exe -A $(CURDIR)/$@ $(CURDIR)/$<
temp\pe-unusual.pdf: pe-unusual.svg
	$(inkpath)/inkscape.exe -A $(CURDIR)/$@ $(CURDIR)/$<
temp\pe-layout.pdf: pe-layout.svg
	$(inkpath)/inkscape.exe -A $(CURDIR)/$@ $(CURDIR)/$<
temp\pe-rules.pdf: pe-rules.svg
	$(inkpath)/inkscape.exe -A $(CURDIR)/$@ $(CURDIR)/$<
temp\pe-directories.pdf: pe-directories.svg
	$(inkpath)/inkscape.exe -A $(CURDIR)/$@ $(CURDIR)/$<
temp\pe-directories-2.pdf: pe-directories-2.svg
	$(inkpath)/inkscape.exe -A $(CURDIR)/$@ $(CURDIR)/$<
temp\pe_fp.pdf: pe_fp.tex
	cd temp & $(texify) ..\$< & cd ..

cm.pdf: cm.tex
	$(texify) $<

temp\pe-raw.pdf: temp\pe_fp.pdf temp\pe-headers.pdf temp\pe-layout.pdf temp\pe-directories.pdf temp\pe-directories-2.pdf
	pdftk temp\pe_fp.pdf temp\pe-layout.pdf temp\pe-headers.pdf temp\pe-directories.pdf temp\pe-directories-2.pdf output temp\pe-raw.pdf dontask

temp\pe-book.pdf: temp\pe-raw.pdf
	$(jpdf) -w YES temp\pe-raw.pdf -o temp\pe-book.pdf

pe.pdf: temp\pe-book.pdf pe.txt
	$(jpdf) -a pe.txt temp\pe-book.pdf -o pe.pdf

packers.pdf: temp\packers_fp.pdf temp\packers_features.pdf temp\packers_landscape.pdf temp\packers_details.pdf temp\packers_starts.pdf temp\packers_models.pdf temp\packers_algos.pdf
	pdftk temp\packers_fp.pdf temp\packers_models.pdf temp\packers_features.pdf temp\packers_landscape.pdf temp\packers_details.pdf temp\packers_starts.pdf temp\packers_algos.pdf output packers.pdf dontask

opcodes.pdf: temp\opcodes_fp.pdf temp\opcodes_1.pdf temp\opcodes_2.pdf temp\opcodes_desc.pdf temp\opcodes64_1.pdf 
	pdftk temp\opcodes_fp.pdf temp\opcodes_1.pdf temp\opcodes_2.pdf temp\opcodes64_1.pdf temp\opcodes_desc.pdf output opcodes.pdf dontask