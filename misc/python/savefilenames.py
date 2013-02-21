import os

w = []
for root, dirs, files in os.walk(u'.'):
    for file in files[:]:
        w.append(file[:-4].encode("utf-8"))
with open("filenames.txt", "wt") as f1:
    f1.write("\n".join(w))
