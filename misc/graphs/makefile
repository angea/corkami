all: pe.pdf packers.pdf opcodes.pdf

pe.pdf: pe_fp.pdf pe-headers.pdf pe-layout.pdf pe-directories.pdf pe-directories-2.pdf
	pdftk pe_fp.pdf pe-layout.pdf pe-headers.pdf pe-directories.pdf pe-directories-2.pdf output pe.pdf

packers.pdf: packers_fp.pdf packers_features.pdf packers_landscape.pdf packers_details.pdf packers_starts.pdf packers_models.pdf packers_algos.pdf
	pdftk packers_fp.pdf packers_models.pdf packers_features.pdf packers_landscape.pdf packers_details.pdf packers_starts.pdf packers_algos.pdf output packers.pdf

opcodes.pdf: opcodes_fp.pdf opcodes_1.pdf opcodes_2.pdf opcodes_desc.pdf
	pdftk opcodes_fp.pdf opcodes_1.pdf opcodes_2.pdf opcodes_desc.pdf output opcodes.pdf