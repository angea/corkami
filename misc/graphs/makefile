inkpath = c:/Program Files/Inkscape

all: pe.pdf packers.pdf opcodes.pdf

clean:
	del opcodes_fp.pdf opcodes_1.pdf opcodes_2.pdf opcodes_desc.pdf opcodes.pdf pe_fp.pdf pe-layout.pdf pe-headers.pdf pe-directories.pdf pe-directories-2.pdf pe.pdf packers_fp.pdf packers_models.pdf packers_features.pdf packers_landscape.pdf packers_details.pdf packers_starts.pdf packers_algos.pdf packers.pdf

packers_starts.pdf : packers_starts.svg
	$(inkpath)/inkscape.exe -A $(CURDIR)/$@ $(CURDIR)/$<
packers_features.pdf: packers_features.svg
	$(inkpath)/inkscape.exe -A $(CURDIR)/$@ $(CURDIR)/$<
packers_models.pdf: packers_models.svg
	$(inkpath)/inkscape.exe -A $(CURDIR)/$@ $(CURDIR)/$<
packers_algos.pdf: packers_algos.svg
	$(inkpath)/inkscape.exe -A $(CURDIR)/$@ $(CURDIR)/$<
packers_landscape.pdf: packers_landscape.svg
	$(inkpath)/inkscape.exe -A $(CURDIR)/$@ $(CURDIR)/$<

opcodes_1.pdf: opcodes_1.svg
	$(inkpath)/inkscape.exe -A $(CURDIR)/$@ $(CURDIR)/$<
opcodes_2.pdf: opcodes_2.svg
	$(inkpath)/inkscape.exe -A $(CURDIR)/$@ $(CURDIR)/$<
opcodes64_1.pdf: opcodes64_1.svg
	$(inkpath)/inkscape.exe -A $(CURDIR)/$@ $(CURDIR)/$<

pe-headers.pdf: pe-headers.svg
	$(inkpath)/inkscape.exe -A $(CURDIR)/$@ $(CURDIR)/$<
pe-unusual.pdf: pe-unusual.svg
	$(inkpath)/inkscape.exe -A $(CURDIR)/$@ $(CURDIR)/$<
pe-layout.pdf: pe-layout.svg
	$(inkpath)/inkscape.exe -A $(CURDIR)/$@ $(CURDIR)/$<
pe-rules.pdf: pe-rules.svg
	$(inkpath)/inkscape.exe -A $(CURDIR)/$@ $(CURDIR)/$<
pe-directories.pdf: pe-directories.svg
	$(inkpath)/inkscape.exe -A $(CURDIR)/$@ $(CURDIR)/$<
pe-directories-2.pdf: pe-directories-2.svg
	$(inkpath)/inkscape.exe -A $(CURDIR)/$@ $(CURDIR)/$<
 

pe.pdf: pe_fp.pdf pe-headers.pdf pe-layout.pdf pe-directories.pdf pe-directories-2.pdf
	pdftk pe_fp.pdf pe-layout.pdf pe-headers.pdf pe-directories.pdf pe-directories-2.pdf output pe.pdf dontask

packers.pdf: packers_fp.pdf packers_features.pdf packers_landscape.pdf packers_details.pdf packers_starts.pdf packers_models.pdf packers_algos.pdf
	pdftk packers_fp.pdf packers_models.pdf packers_features.pdf packers_landscape.pdf packers_details.pdf packers_starts.pdf packers_algos.pdf output packers.pdf dontask

opcodes.pdf: opcodes_fp.pdf opcodes_1.pdf opcodes_2.pdf opcodes_desc.pdf
	pdftk opcodes_fp.pdf opcodes_1.pdf opcodes_2.pdf opcodes_desc.pdf output opcodes.pdf dontask