include paths.inc

all: frame1.html frame2.html frame3.html template.html

frame1.html: frame1.t2t
	$(python) txt2tags.py -t html frame1.t2t
frame2.html: frame2.t2t
	$(python) txt2tags.py -t html frame2.t2t
frame3.html: frame3.t2t
	$(python) txt2tags.py -t html frame3.t2t

template.html: template.t2t
	$(python) txt2tags.py -t html --toc --toc-level=10 template.t2t
