hw = """
"88  88           888     888                   88   88                   888        88    88    "
"88  88            88      88                   88   88                    88        88    88    "
"88  88   8888     88      88     8888          88   88   8888   88888     88     88888    88    "
"888888  88  88    88      88    88  88         88 8 88  88  88  88  88    88    88  88    88    "
"88  88  888888    88      88    88  88         8888888  88  88  88        88    88  88    88    "
"88  88  88        88      88    88  88         888 888  88  88  88        88    88  88          "
"88  88   8888    8888    8888    8888          88   88   8888   88       8888    88888    88    "
"""

bmp = hw.strip().replace('"', "")

bmp = "".join((bmp.splitlines()[::-1])) # padding
data = []
for i in range(len(bmp) / 8):
    byte = 0
    bit = 128
    for c in bmp[i * 8: (i + 1) * 8]:
        if c != " ":
            byte |= bit
        bit /= 2
    data.append(chr(byte))
with open("bmpdata", "wb") as f:
    f.write("".join(data))

png = [s[:-4] for s in hw.replace('"', "").replace('8', "\0").replace(' ', "\1").splitlines()][1:]
with open("pngdata", "wb") as f:
    f.write("\0".join(png))
