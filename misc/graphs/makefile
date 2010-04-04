all: pe.pdf packers.pdf opcodes.pdf

pe.pdf: pe-headers.pdf pe-layout.pdf
	pdftk pe-headers.pdf pe-layout.pdf output pe.pdf

packers.pdf: packers_features.pdf packers_landscape.pdf packers_details.pdf packers_starts.pdf packers_models.pdf
	pdftk packers_features.pdf packers_landscape.pdf packers_details.pdf packers_starts.pdf packers_models.pdf output packers.pdf

opcodes.pdf: opcodes_1.pdf opcodes_2.pdf opcodes_desc.pdf
	pdftk opcodes_1.pdf opcodes_2.pdf opcodes_desc.pdf output opcodes.pdf