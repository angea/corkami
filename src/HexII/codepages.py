#!/usr/bin/env python3

# Codepages for authentic bytes display

def dump_table(table):
	for i, j in enumerate(table):
		if i % 16 == 0:
			print("%02x: " % i, end="")
		print("%04x " % j, end="")
		if i % 16 == 15:
			print("")
	assert len((set([x for x in table if table.count(x) > 1]))) == 0


cpascii = [None] * 256
for i in range(0x20, 0x7f):
	cpascii[i] = i


###############################################################################

cp437 = [
	0x0000, 0x263A, 0x263B, 0x2665, 0x2666, 0x2663, 0x2660, 0x2022, 0x25D8, 0x25CB, 0x25D9, 0x2642, 0x2640, 0x266A, 0x266B, 0x263C,
	0x25BA, 0x25C4, 0x2195, 0x203C, 0x00B6, 0x00A7, 0x25AC, 0x21A8, 0x2191, 0x2193, 0x2192, 0x2190, 0x221F, 0x2194, 0x25B2, 0x25BC] + \
	cpascii[0x20:0x7F] + [
	                                                                                                                        0x2302, # 7F
	0x00C7, 0x00FC, 0x00E9, 0x00E2, 0x00E4, 0x00E0, 0x00E5, 0x00E7, 0x00EA, 0x00EB, 0x00E8, 0x00EF, 0x00EE, 0x00EC, 0x00C4, 0x00C5, # 80
	0x00C9, 0x00E6, 0x00C6, 0x00F4, 0x00F6, 0x00F2, 0x00FB, 0x00F9, 0x00FF, 0x00D6, 0x00DC, 0x00A2, 0x00A3, 0x00A5, 0x20A7, 0x0192, # 90
	0x00E1, 0x00ED, 0x00F3, 0x00FA, 0x00F1, 0x00D1, 0x00AA, 0x00BA, 0x00BF, 0x2310, 0x00AC, 0x00BD, 0x00BC, 0x00A1, 0x00AB, 0x00BB, # A0
	0x2591, 0x2592, 0x2593, 0x2502, 0x2524, 0x2561, 0x2562, 0x2556, 0x2555, 0x2563, 0x2551, 0x2557, 0x255D, 0x255C, 0x255B, 0x2510, # B0
	0x2514, 0x2534, 0x252C, 0x251C, 0x2500, 0x253C, 0x255E, 0x255F, 0x255A, 0x2554, 0x2569, 0x2566, 0x2560, 0x2550, 0x256C, 0x2567, # C0
	0x2568, 0x2564, 0x2565, 0x2559, 0x2558, 0x2552, 0x2553, 0x256B, 0x256A, 0x2518, 0x250C, 0x2588, 0x2584, 0x258C, 0x2590, 0x2580, # D0
	0x03B1, 0x00DF, 0x0393, 0x03C0, 0x03A3, 0x03C3, 0x00B5, 0x03C4, 0x03A6, 0x0398, 0x03A9, 0x03B4, 0x221E, 0x03C6, 0x03B5, 0x2229, # E0
	0x2261, 0x00B1, 0x2265, 0x2264, 0x2320, 0x2321, 0x00F7, 0x2248, 0x00B0, 0x2219, 0x00B7, 0x221A, 0x207F, 0x00B2, 0x25A0, 0x00A0, # F0
]

cp437[0] = None # to avoid null chars to be displayed ?


###############################################################################

cp852 = cp437[:0x80] + [
	0x00C7, 0x00FC, 0x00E9, 0x00E2, 0x00E4, 0x016F, 0x0107, 0x00E7, 0x0142, 0x00EB, 0x0150, 0x0151, 0x00EE, 0x0179, 0x00C4, 0x0106, # 80
	0x00C9, 0x0139, 0x013A, 0x00F4, 0x00F6, 0x013D, 0x013E, 0x015A, 0x015B, 0x00D6, 0x00DC, 0x0164, 0x0165, 0x0141, 0x00D7, 0x010D, # 90
	0x00E1, 0x00ED, 0x00F3, 0x00FA, 0x0104, 0x0105, 0x017D, 0x017E, 0x0118, 0x0119, 0x00AC, 0x017A, 0x010C, 0x015F, 0x00AB, 0x00BB, # A0
	0x2591, 0x2592, 0x2593, 0x2502, 0x2524, 0x00C1, 0x00C2, 0x011A, 0x015E, 0x2563, 0x2551, 0x2557, 0x255D, 0x017B, 0x017C, 0x2510, # B0
	0x2514, 0x2534, 0x252C, 0x251C, 0x2500, 0x253C, 0x0102, 0x0103, 0x255A, 0x2554, 0x2569, 0x2566, 0x2560, 0x2550, 0x256C, 0x00A4, # C0
	0x0111, 0x00D0, 0x010E, 0x00CB, 0x010F, 0x0147, 0x00CD, 0x00CE, 0x011B, 0x2518, 0x250C, 0x2588, 0x2584, 0x0162, 0x016E, 0x2580, # D0
	0x00D3, 0x00DF, 0x00D4, 0x0143, 0x0144, 0x0148, 0x0160, 0x0161, 0x0154, 0x00DA, 0x0155, 0x0170, 0x00FD, 0x00DD, 0x0163, 0x00B4, # E0
	0x00AD, 0x02DD, 0x02DB, 0x02C7, 0x02D8, 0x00A7, 0x00F7, 0x00B8, 0x00B0, 0x00A8, 0x02D9, 0x0171, 0x0158, 0x0159, 0x25A0, 0x00A0, # F0
]


###############################################################################

cpkoi8r = cp437[:0x80] + [
	0x2500, 0x2502, 0x250C, 0x2510, 0x2514, 0x2518, 0x251C, 0x2524, 0x252C, 0x2534, 0x253C, 0x2580, 0x2584, 0x2588, 0x258C, 0x2590, # 80
	0x2591, 0x2592, 0x2593, 0x2320, 0x25A0, 0x2219, 0x221A, 0x2248, 0x2264, 0x2265, 0x00A0, 0x2321, 0x00B0, 0x00B2, 0x00B7, 0x00F7, # 90
	0x2550, 0x2551, 0x2552, 0x0451, 0x2553, 0x2554, 0x2555, 0x2556, 0x2557, 0x2558, 0x2559, 0x255A, 0x255B, 0x255C, 0x255D, 0x255E, # A0
	0x255F, 0x2560, 0x2561, 0x0401, 0x2562, 0x2563, 0x2564, 0x2565, 0x2566, 0x2567, 0x2568, 0x2569, 0x256A, 0x256B, 0x256C, 0x00A9, # B0
# cyrillic lowercase
	0x044E, 0x0430, 0x0431, 0x0446, 0x0434, 0x0435, 0x0444, 0x0433, 0x0445, 0x0438, 0x0439, 0x043A, 0x043B, 0x043C, 0x043D, 0x043E, # C0
	0x043F, 0x044F, 0x0440, 0x0441, 0x0442, 0x0443, 0x0436, 0x0432, 0x044C, 0x044B, 0x0437, 0x0448, 0x044D, 0x0449, 0x0447, 0x044A, # D0
# cyrillic uppercase
	0x042E, 0x0410, 0x0411, 0x0426, 0x0414, 0x0415, 0x0424, 0x0413, 0x0425, 0x0418, 0x0419, 0x041A, 0x041B, 0x041C, 0x041D, 0x041E, # E0
	0x041F, 0x042F, 0x0420, 0x0421, 0x0422, 0x0423, 0x0416, 0x0412, 0x042C, 0x042B, 0x0417, 0x0428, 0x042D, 0x0429, 0x0427, 0x042A, # F0
]


###############################################################################

cp737 = cp437[:0x80] + [
	0x0391, 0x0392, 0x0393, 0x0394, 0x0395, 0x0396, 0x0397, 0x0398, 0x0399, 0x039A, 0x039B, 0x039C, 0x039D, 0x039E, 0x039F, 0x03A0, # 80
	0x03A1, 0x03A3, 0x03A4, 0x03A5, 0x03A6, 0x03A7, 0x03A8, 0x03A9, 0x03B1, 0x03B2, 0x03B3, 0x03B4, 0x03B5, 0x03B6, 0x03B7, 0x03B8, # 90
	0x03B9, 0x03BA, 0x03BB, 0x03BC, 0x03BD, 0x03BE, 0x03BF, 0x03C0, 0x03C1, 0x03C3, 0x03C2, 0x03C4, 0x03C5, 0x03C6, 0x03C7, 0x03C8, # A0
	0x2591, 0x2592, 0x2593, 0x2502, 0x2524, 0x2561, 0x2562, 0x2556, 0x2555, 0x2563, 0x2551, 0x2557, 0x255D, 0x255C, 0x255B, 0x2510, # B0
	0x2514, 0x2534, 0x252C, 0x251C, 0x2500, 0x253C, 0x255E, 0x255F, 0x255A, 0x2554, 0x2569, 0x2566, 0x2560, 0x2550, 0x256C, 0x2567, # C0
	0x2568, 0x2564, 0x2565, 0x2559, 0x2558, 0x2552, 0x2553, 0x256B, 0x256A, 0x2518, 0x250C, 0x2588, 0x2584, 0x258C, 0x2590, 0x2580, # D0
	0x03C9, 0x03AC, 0x03AD, 0x03AE, 0x03CA, 0x03AF, 0x03CC, 0x03CD, 0x03CB, 0x03CE, 0x0386, 0x0388, 0x0389, 0x038A, 0x038C, 0x038E, # E0
	0x038F, 0x00B1, 0x2265, 0x2264, 0x03AA, 0x03AB, 0x00F7, 0x2248, 0x00B0, 0x2219, 0x00B7, 0x221A, 0x207F, 0x00B2, 0x25A0, 0x00A0, # F0
]


###############################################################################

cp1252 = cp437[:0x80] + [
	0x20AC,   None, 0x201A, 0x0192, 0x201E, 0x2026, 0x2020, 0x2021, 0x02C6, 0x2030, 0x0160, 0x2039, 0x0152,   None, 0x017D,   None, # 80
	  None, 0x2018, 0x2019, 0x201C, 0x201D, 0x2022, 0x2013, 0x2014, 0x02DC, 0x2122, 0x0161, 0x203A, 0x0153,   None, 0x017E, 0x0178, # 90

	0x00A0, 0x00A1, 0x00A2, 0x00A3, 0x00A4, 0x00A5, 0x00A6, 0x00A7, 0x00A8, 0x00A9, 0x00AA, 0x00AB, 0x00AC, 0x00AD, 0x00AE, 0x00AF, # A0
	0x00B0, 0x00B1, 0x00B2, 0x00B3, 0x00B4, 0x00B5, 0x00B6, 0x00B7, 0x00B8, 0x00B9, 0x00BA, 0x00BB, 0x00BC, 0x00BD, 0x00BE, 0x00BF, # B0
# uppercase accents
	0x00C0, 0x00C1, 0x00C2, 0x00C3, 0x00C4, 0x00C5, 0x00C6, 0x00C7, 0x00C8, 0x00C9, 0x00CA, 0x00CB, 0x00CC, 0x00CD, 0x00CE, 0x00CF, # C0
	0x00D0, 0x00D1, 0x00D2, 0x00D3, 0x00D4, 0x00D5, 0x00D6, 0x00D7, 0x00D8, 0x00D9, 0x00DA, 0x00DB, 0x00DC, 0x00DD, 0x00DE, 0x00DF, # D0
# lowercase accents
	0x00E0, 0x00E1, 0x00E2, 0x00E3, 0x00E4, 0x00E5, 0x00E6, 0x00E7, 0x00E8, 0x00E9, 0x00EA, 0x00EB, 0x00EC, 0x00ED, 0x00EE, 0x00EF, # E0
	0x00F0, 0x00F1, 0x00F2, 0x00F3, 0x00F4, 0x00F5, 0x00F6, 0x00F7, 0x00F8, 0x00F9, 0x00FA, 0x00FB, 0x00FC, 0x00FD, 0x00FE, 0x00FF, # F0
]


###############################################################################

cpange = cp437[:0x80] + [
# cyrillic lowercase (from Koi8r)
	0x044E, 0x0430, 0x0431, 0x0446, 0x0434, 0x0435, 0x0444, 0x0433, 0x0445, 0x0438, 0x0439, 0x043A, 0x043B, 0x043C, 0x043D, 0x043E, # 80
	0x043F, 0x044F, 0x0440, 0x0441, 0x0442, 0x0443, 0x0436, 0x0432, 0x044C, 0x044B, 0x0437, 0x0448, 0x044D, 0x0449, 0x0447, 0x044A, # 90
# cyrillic uppercase (from Koi8r)
	0x042E, 0x0410, 0x0411, 0x0426, 0x0414, 0x0415, 0x0424, 0x0413, 0x0425, 0x0418, 0x0419, 0x041A, 0x041B, 0x041C, 0x041D, 0x041E, # A0
	0x041F, 0x042F, 0x0420, 0x0421, 0x0422, 0x0423, 0x0416, 0x0412, 0x042C, 0x042B, 0x0417, 0x0428, 0x042D, 0x0429, 0x0427, 0x042A, # B0
# uppercase accent (from 1252)
	0x00C0, 0x00C1, 0x00C2, 0x00C3, 0x00C4, 0x00C5, 0x00C6, 0x00C7, 0x00C8, 0x00C9, 0x00CA, 0x00CB, 0x00CC, 0x00CD, 0x00CE, 0x00CF, # C0
	0x00D0, 0x00D1, 0x00D2, 0x00D3, 0x00D4, 0x00D5, 0x00D6, 0x00D7, 0x00D8, 0x00D9, 0x00DA, 0x00DB, 0x00DC, 0x00DD, 0x00DE, 0x00DF, # D0
# lowercase accents (from 1252)
	0x00E0, 0x00E1, 0x00E2, 0x00E3, 0x00E4, 0x00E5, 0x00E6, 0x00E7, 0x00E8, 0x00E9, 0x00EA, 0x00EB, 0x00EC, 0x00ED, 0x00EE, 0x00EF, # E0
	0x00F0, 0x00F1, 0x00F2, 0x00F3, 0x00F4, 0x00F5, 0x00F6, 0x00F7, 0x00F8, 0x00F9, 0x00FA, 0x00FB, 0x00FC, 0x00FD, 0x00FE, 0x00FF, # F0
]

# a non-space looking to avoid confusion
cpange[0] = 0x2591
# a full square for 255
cpange[0xff] = 0x2588
# overwriting 1252 math symbols that don't match
cpange[0xd7] = 0x0147 # N with caron
cpange[0xd7 + 0x20] = 0x0148

# replacing latin-looking cyrillic with greek
def greekcyl(c, g):
	cpange[c], cpange[c + 16*2] = cp737[g+24], cp737[g]

greekcyl(0x81, 0x82) # cyrillic 'a'
greekcyl(0x85, 0x83) # cyrillic 'e'
greekcyl(0x88, 0x87) # cyrillic 'x'
greekcyl(0x8b, 0x8a) # cyrillic 'k'
greekcyl(0x8e, 0x8d) # cyrillic 'h'
greekcyl(0x8f, 0x8f) # cyrillic 'o'
greekcyl(0x92, 0x91) # cyrillic 'p'
greekcyl(0x93, 0x94) # cyrillic 'c'
greekcyl(0x94, 0x96) # cyrillic 't'
greekcyl(0x97, 0x97) # cyrillic 'b'

cpange[0x8d] = 0x11b # e with caron
cpange[0x8d+32] = 0x11a # E with caron


###############################################################################

# direct braille
cpbraille = [i + 0x2800 for i in range(256)]

# reordered braille extended charset:
# - upper square shows highest nibble in a visual form,
# - lower square shows lowest nibble in binary.
cpbraille = cp437[:0x80] + [
  0x2800, 0x2840, 0x2880, 0x28c0, 0x2820, 0x2860, 0x28a0, 0x28e0, 0x2804, 0x2844, 0x2884, 0x28c4, 0x2824, 0x2864, 0x28a4, 0x28e4, # 0
  0x2801, 0x2841, 0x2881, 0x28c1, 0x2821, 0x2861, 0x28a1, 0x28e1, 0x2805, 0x2845, 0x2885, 0x28c5, 0x2825, 0x2865, 0x28a5, 0x28e5, # 1
  0x2803, 0x2843, 0x2883, 0x28c3, 0x2823, 0x2863, 0x28a3, 0x28e3, 0x2807, 0x2847, 0x2887, 0x28c7, 0x2827, 0x2867, 0x28a7, 0x28e7, # |
  0x2809, 0x2849, 0x2889, 0x28c9, 0x2829, 0x2869, 0x28a9, 0x28e9, 0x280d, 0x284d, 0x288d, 0x28cd, 0x282d, 0x286d, 0x28ad, 0x28ed, # -
  0x280a, 0x284a, 0x288a, 0x28ca, 0x282a, 0x286a, 0x28aa, 0x28ea, 0x280e, 0x284e, 0x288e, 0x28ce, 0x282e, 0x286e, 0x28ae, 0x28ee, # /
  0x2811, 0x2851, 0x2891, 0x28d1, 0x2831, 0x2871, 0x28b1, 0x28f1, 0x2815, 0x2855, 0x2895, 0x28d5, 0x2835, 0x2875, 0x28b5, 0x28f5, # \
  0x281a, 0x285a, 0x289a, 0x28da, 0x283a, 0x287a, 0x28ba, 0x28fa, 0x281e, 0x285e, 0x289e, 0x28de, 0x283e, 0x287e, 0x28be, 0x28fe, # _|
  0x281b, 0x285b, 0x289b, 0x28db, 0x283b, 0x287b, 0x28bb, 0x28fb, 0x281f, 0x285f, 0x289f, 0x28df, 0x283f, 0x287f, 0x28bf, 0x28ff, # #
# 0x2819, 0x2859, 0x2899, 0x28d9, 0x2839, 0x2879, 0x28b9, 0x28f9, 0x281d, 0x285d, 0x289d, 0x28dd, 0x283d, 0x287d, 0x28bd, 0x28fd, # -|
# 0x2813, 0x2853, 0x2893, 0x28d3, 0x2833, 0x2873, 0x28b3, 0x28f3, 0x2817, 0x2857, 0x2897, 0x28d7, 0x2837, 0x2877, 0x28b7, 0x28f7, # |_
# 0x280b, 0x284b, 0x288b, 0x28cb, 0x282b, 0x286b, 0x28ab, 0x28eb, 0x280f, 0x284f, 0x288f, 0x28cf, 0x282f, 0x286f, 0x28af, 0x28ef, # |-
# 0x2810, 0x2850, 0x2890, 0x28d0, 0x2830, 0x2870, 0x28b0, 0x28f0, 0x2814, 0x2854, 0x2894, 0x28d4, 0x2834, 0x2874, 0x28b4, 0x28f4,
# 0x2808, 0x2848, 0x2888, 0x28c8, 0x2828, 0x2868, 0x28a8, 0x28e8, 0x280c, 0x284c, 0x288c, 0x28cc, 0x282c, 0x286c, 0x28ac, 0x28ec,
# 0x2818, 0x2858, 0x2898, 0x28d8, 0x2838, 0x2878, 0x28b8, 0x28f8, 0x281c, 0x285c, 0x289c, 0x28dc, 0x283c, 0x287c, 0x28bc, 0x28fc,
# 0x2802, 0x2842, 0x2882, 0x28c2, 0x2822, 0x2862, 0x28a2, 0x28e2, 0x2806, 0x2846, 0x2886, 0x28c6, 0x2826, 0x2866, 0x28a6, 0x28e6,
# 0x2812, 0x2852, 0x2892, 0x28d2, 0x2832, 0x2872, 0x28b2, 0x28f2, 0x2816, 0x2856, 0x2896, 0x28d6, 0x2836, 0x2876, 0x28b6, 0x28f6,
]

# 2800 is just an empty char like space.
cpbraille[0x00] = 0x2591
cpbraille[0x80] = 0x2588


###############################################################################

# box characters
cpbox = cp437[:0x80] + [i + 0x2500 for i in range(128)]
 

###############################################################################

codepages = {
	"437":      cp437,     # IBM PC
	"737":      cp737,     # Greek
	"852":      cp852,     # Central europe
	"1252":     cp1252,    # Windows
	"koi8r":    cpkoi8r,   # Russian
	"ange":     cpange,    # Ange's custom
	"braille":  cpbraille,
	"box":      cpbox,

	"ascii": cpascii,
}
