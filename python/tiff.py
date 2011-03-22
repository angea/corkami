# tiny tiff parser

# Ange Albertini, BSD Licence, 2011

import struc
import sys

tags_types = [
 ('ACTIVEAREA', 50829),
 ('ANALOGBALANCE', 50727),
 ('ANTIALIASSTRENGTH', 50738),
 ('ARTIST', 315),
 ('ASSHOTICCPROFILE', 50831),
 ('ASSHOTNEUTRAL', 50728),
 ('ASSHOTPREPROFILEMATRIX', 50832),
 ('ASSHOTWHITEXY', 50729),
 ('BADFAXLINES', 326),
 ('BASELINEEXPOSURE', 50730),
 ('BASELINENOISE', 50731),
 ('BASELINESHARPNESS', 50732),
 ('BAYERGREENSPLIT', 50733),
 ('BESTQUALITYSCALE', 50780),
 ('BITSPERSAMPLE', 258),
 ('BLACKLEVEL', 50714),
 ('BLACKLEVELDELTAH', 50715),
 ('BLACKLEVELDELTAV', 50716),
 ('BLACKLEVELREPEATDIM', 50713),
 ('CALIBRATIONILLUMINANT1', 50778),
 ('CALIBRATIONILLUMINANT2', 50779),
 ('CAMERACALIBRATION1', 50723),
 ('CAMERACALIBRATION2', 50724),
 ('CAMERASERIALNUMBER', 50735),
 ('CELLLENGTH', 265),
 ('CELLWIDTH', 264),
 ('CFALAYOUT', 50711),
 ('CFAPLANECOLOR', 50710),
 ('CHROMABLURRADIUS', 50737),
 ('CLEANFAXDATA', 327),
 ('CLIPPATH', 343),
 ('COLORMAP', 320),
 ('COLORMATRIX1', 50721),
 ('COLORMATRIX2', 50722),
 ('COLORRESPONSEUNIT', 300),
 ('COMPRESSION', 259),
 ('CONSECUTIVEBADFAXLINES', 328),
 ('COPYRIGHT', 33432),
 ('CURRENTICCPROFILE', 50833),
 ('CURRENTPREPROFILEMATRIX', 50834),
 ('DATATYPE', 32996),
 ('DATETIME', 306),
 ('DCSBALANCEARRAY', 65552),
 ('DCSCALIBRATIONFD', 65556),
 ('DCSCLIPRECTANGLE', 65559),
 ('DCSCORRECTMATRIX', 65553),
 ('DCSGAMMA', 65554),
 ('DCSHUESHIFTVALUES', 65535),
 ('DCSIMAGERTYPE', 65550),
 ('DCSINTERPMODE', 65551),
 ('DCSTOESHOULDERPTS', 65555),
 ('DEFAULTCROPORIGIN', 50719),
 ('DEFAULTCROPSIZE', 50720),
 ('DEFAULTSCALE', 50718),
 ('DNGBACKWARDVERSION', 50707),
 ('DNGPRIVATEDATA', 50740),
 ('DNGVERSION', 50706),
 ('DOCUMENTNAME', 269),
 ('DOTRANGE', 336),
 ('EXIFIFD', 34665),
 ('EXTRASAMPLES', 338),
 ('FAXDCS', 34911),
 ('FAXFILLFUNC', 65540),
 ('FAXMODE', 65536),
 ('FAXRECVPARAMS', 34908),
 ('FAXRECVTIME', 34910),
 ('FAXSUBADDRESS', 34909),
 ('FEDEX_EDR', 34929),
 ('FILLORDER', 266),
 ('FRAMECOUNT', 34232),
 ('FREEBYTECOUNTS', 289),
 ('FREEOFFSETS', 288),
 ('GPSIFD', 34853),
 ('GRAYRESPONSECURVE', 291),
 ('GRAYRESPONSEUNIT', 290),
 ('GROUP3OPTIONS', 292),
 ('GROUP4OPTIONS', 293),
 ('HALFTONEHINTS', 321),
 ('HOSTCOMPUTER', 316),
 ('ICCPROFILE', 34675),
 ('IMAGEDEPTH', 32997),
 ('IMAGEDESCRIPTION', 270),
 ('IMAGELENGTH', 257),
 ('IMAGEWIDTH', 256),
 ('INDEXED', 346),
 ('INKNAMES', 333),
 ('INKSET', 332),
 ('INTEROPERABILITYIFD', 40965),
 ('IT8BITSPEREXTENDEDRUNLENGTH', 34021),
 ('IT8BITSPERRUNLENGTH', 34020),
 ('IT8BKGCOLORINDICATOR', 34024),
 ('IT8BKGCOLORVALUE', 34026),
 ('IT8CMYKEQUIVALENT', 34032),
 ('IT8COLORCHARACTERIZATION', 34029),
 ('IT8COLORSEQUENCE', 34017),
 ('IT8COLORTABLE', 34022),
 ('IT8HCUSAGE', 34030),
 ('IT8HEADER', 34018),
 ('IT8IMAGECOLORINDICATOR', 34023),
 ('IT8IMAGECOLORVALUE', 34025),
 ('IT8PIXELINTENSITYRANGE', 34027),
 ('IT8RASTERPADDING', 34019),
 ('IT8SITE', 34016),
 ('IT8TRANSPARENCYINDICATOR', 34028),
 ('IT8TRAPINDICATOR', 34031),
 ('JBIGOPTIONS', 34750),
 ('JPEGACTABLES', 521),
 ('JPEGCOLORMODE', 65538),
 ('JPEGDCTABLES', 520),
 ('JPEGIFBYTECOUNT', 514),
 ('JPEGIFOFFSET', 513),
 ('JPEGLOSSLESSPREDICTORS', 517),
 ('JPEGPOINTTRANSFORM', 518),
 ('JPEGPROC', 512),
 ('JPEGQTABLES', 519),
 ('JPEGQUALITY', 65537),
 ('JPEGRESTARTINTERVAL', 515),
 ('JPEGTABLES', 347),
 ('JPEGTABLESMODE', 65539),
 ('LENSINFO', 50736),
 ('LINEARIZATIONTABLE', 50712),
 ('LINEARRESPONSELIMIT', 50734),
 ('LOCALIZEDCAMERAMODEL', 50709),
 ('MAKE', 271),
 ('MAKERNOTESAFETY', 50741),
 ('MASKEDAREAS', 50830),
 ('MATTEING', 32995),
 ('MAXSAMPLEVALUE', 281),
 ('MINSAMPLEVALUE', 280),
 ('MODEL', 272),
 ('NUMBEROFINKS', 334),
 ('OPIIMAGEID', 32781),
 ('OPIPROXY', 351),
 ('ORIENTATION', 274),
 ('ORIGINALRAWFILEDATA', 50828),
 ('ORIGINALRAWFILENAME', 50827),
 ('OSUBFILETYPE', 255),
 ('PAGENAME', 285),
 ('PAGENUMBER', 297),
 ('PHOTOMETRIC', 262),
 ('PHOTOSHOP', 34377),
 ('PIXARLOGDATAFMT', 65549),
 ('PIXARLOGQUALITY', 65558),
 ('PIXAR_FOVCOT', 33304),
 ('PIXAR_IMAGEFULLLENGTH', 33301),
 ('PIXAR_IMAGEFULLWIDTH', 33300),
 ('PIXAR_MATRIX_WORLDTOCAMERA', 33306),
 ('PIXAR_MATRIX_WORLDTOSCREEN', 33305),
 ('PIXAR_TEXTUREFORMAT', 33302),
 ('PIXAR_WRAPMODES', 33303),
 ('PLANARCONFIG', 284),
 ('PREDICTOR', 317),
 ('PRIMARYCHROMATICITIES', 319),
 ('RAWDATAUNIQUEID', 50781),
 ('REDUCTIONMATRIX1', 50725),
 ('REDUCTIONMATRIX2', 50726),
 ('REFERENCEBLACKWHITE', 532),
 ('REFPTS', 32953),
 ('REGIONAFFINE', 32956),
 ('REGIONTACKPOINT', 32954),
 ('REGIONWARPCORNERS', 32955),
 ('RESOLUTIONUNIT', 296),
 ('RICHTIFFIPTC', 33723),
 ('ROWSPERSTRIP', 278),
 ('SAMPLEFORMAT', 339),
 ('SAMPLESPERPIXEL', 277),
 ('SGILOGDATAFMT', 65560),
 ('SGILOGENCODE', 65561),
 ('SHADOWSCALE', 50739),
 ('SMAXSAMPLEVALUE', 341),
 ('SMINSAMPLEVALUE', 340),
 ('SOFTWARE', 305),
 ('STONITS', 37439),
 ('STRIPBYTECOUNTS', 279),
 ('STRIPOFFSETS', 273),
 ('SUBFILETYPE', 254),
 ('SUBIFD', 330),
 ('T4OPTIONS', 292),
 ('T6OPTIONS', 293),
 ('TARGETPRINTER', 337),
 ('THRESHHOLDING', 263),
 ('TILEBYTECOUNTS', 325),
 ('TILEDEPTH', 32998),
 ('TILELENGTH', 323),
 ('TILEOFFSETS', 324),
 ('TILEWIDTH', 322),
 ('TRANSFERFUNCTION', 301),
 ('UNIQUECAMERAMODEL', 50708),
 ('WHITELEVEL', 50717),
 ('WHITEPOINT', 318),
 ('WRITERSERIALNUMBER', 33405),
 ('XCLIPPATHUNITS', 344),
 ('XMLPACKET', 700),
 ('XPOSITION', 286),
 ('XRESOLUTION', 282),
 ('YCBCRCOEFFICIENTS', 529),
 ('YCBCRPOSITIONING', 531),
 ('YCBCRSUBSAMPLING', 530),
 ('YCLIPPATHUNITS', 345),
 ('YPOSITION', 287),
 ('YRESOLUTION', 283),
 ('ZIPQUALITY', 65557),
 ]

TAGS = dict([(i[1], i[0]) for i in tags_types] + tags_types)
for i,j in TAGS.iteritems():
	TAGS[j] = i


_file = open(sys.argv[1], "rb")
s  = struc.struc(_file)

#TODO
# * extract information from valoff
# * go to next directory

import struct
def ReadEndianness(v):
    global _C
    Little = {"II":True, "MM":False}[struct.pack("H", v)]
    _C = {True:"<", False:">"}[Little]

def Check42(v):
    if v != 42:
        print v
        
    return


s.handle(["H,ByteOrder", ReadEndianness])
if s.handle([_C + "H,_42", None]) != 42:
    raise(BaseException("Wrong Magic"))

diroffset = s.handle([_C + "I,Offset", None])
while (diroffset != 0):
    s.seek(diroffset)    
    nbdir = s.handle([_C + "H,Number", None])

    s.levelup()
    for _ in xrange(nbdir):
        tag = s.handle([_C + "H,Tag", None])
	print TAGS[tag]
        type_ = s.handle([_C + "H,type_", None])
        typename = {1:"Byte", 2:"Ascii", 3:"Short", 4:"Long", 5:"Rational"}[type_]
        typesize = {1:1,2:1,3:2,4:4,5:8}[type_]
        count_ =  s.handle([_C + "I,Count", None])
        valoff = s.handle([_C + "I,ValOffset", None]) # if Count*Size(type_) > 4 then offset else val
        print
    s.leveldown()

    diroffset = s.handle([_C + "I,Offset", None])
