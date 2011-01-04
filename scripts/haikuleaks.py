#! /usr/bin/env python
from haikufinder import HaikuFinder
import sys,glob
cpt=0
haikuleaks = open('haikuleaks', 'w')
for infile in glob.glob('*'):
    text = open(infile, "r").read()
    for haiku in HaikuFinder(text).find_haikus():
        haikuleaks.write('<li><div class="snip">\n')
	haikuleaks.write(haiku[0]+"<br>\n")
        haikuleaks.write("&nbsp;&nbsp;    %s<br>\n" % haiku[1])
	haikuleaks.write(haiku[2]+"<div><i>\n")
	haikuleaks.write('<a href="http://git.tetalab.org/index.php/p/cablegate/source/tree/master/cables/%s">\n\n' % infile)
	haikuleaks.write(infile)
	haikuleaks.write("</a></i></li>\n\n")
	cpt +=1
print "%s haikuleaks" % cpt



