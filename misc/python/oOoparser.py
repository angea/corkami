print "<html><body>"
casts = {
58:'96bits',
44:'gs',
42:'smsw',
51:'pushret',
}


for i in xrange(74):
    with open("note%i.html" % i, "rt") as f:
        r = f.readlines()[8:-2:]
    for i1, j1 in enumerate(r):
        r[i1] = j1.replace(' style="direction:ltr;"', "")

    print
    print '<a name=slide%i />Slide %i: <a href=#slide%i>&lt;&lt; Previous</a> <a href=#slide%i>&gt;&gt; Next</a>' % (i, i, i - 1, i + 1)
    print '<table><tr><td>'
    if i in casts:
        print '<p>Demo</p>'
        print '<OBJECT CLASSID="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" WIDTH="800" HEIGHT="602" CODEBASE="http://active.macromedia.com/flash5/cabs/swflash.cab#version=7,0,0,0"><PARAM NAME=movie VALUE="%s.swf"><PARAM NAME=play VALUE=true><PARAM NAME=loop VALUE=false><PARAM NAME=wmode VALUE=transparent><PARAM NAME=quality VALUE=low><EMBED SRC="%s.swf" WIDTH=800 HEIGHT=602 quality=low loop=false wmode=transparent TYPE="application/x-shockwave-flash" PLUGINSPAGE="http://www.macromedia.com/shockwave/download/index.cgi?P1_Prod_Version=ShockwaveFlash"></EMBED></OBJECT><br/>' % (casts[i], casts[i])
    elif i == 49:
        print '<p>Demo in 32 bits (1/2)</p>'
        print '<OBJECT CLASSID="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" WIDTH="800" HEIGHT="602" CODEBASE="http://active.macromedia.com/flash5/cabs/swflash.cab#version=7,0,0,0"><PARAM NAME=movie VALUE="%s.swf"><PARAM NAME=play VALUE=true><PARAM NAME=loop VALUE=false><PARAM NAME=wmode VALUE=transparent><PARAM NAME=quality VALUE=low><EMBED SRC="%s.swf" WIDTH=800 HEIGHT=602 quality=low loop=false wmode=transparent TYPE="application/x-shockwave-flash" PLUGINSPAGE="http://www.macromedia.com/shockwave/download/index.cgi?P1_Prod_Version=ShockwaveFlash"></EMBED></OBJECT><br/>' % ('demo32', 'demo32')
        print '<p>Demo in 64 bits (2/2)</p>'
        print '<OBJECT CLASSID="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" WIDTH="800" HEIGHT="602" CODEBASE="http://active.macromedia.com/flash5/cabs/swflash.cab#version=7,0,0,0"><PARAM NAME=movie VALUE="%s.swf"><PARAM NAME=play VALUE=true><PARAM NAME=loop VALUE=false><PARAM NAME=wmode VALUE=transparent><PARAM NAME=quality VALUE=low><EMBED SRC="%s.swf" WIDTH=800 HEIGHT=602 quality=low loop=false wmode=transparent TYPE="application/x-shockwave-flash" PLUGINSPAGE="http://www.macromedia.com/shockwave/download/index.cgi?P1_Prod_Version=ShockwaveFlash"></EMBED></OBJECT><br/>' % ('demo64', 'demo64')

    else:
        print '<img src=img%i.png border=1 >' % (i)
    print '</td><td valign=top>'
    for i1 in r:
        print i1.strip()
    print '</td></tr></table>'

    print

print "</body></html>"
