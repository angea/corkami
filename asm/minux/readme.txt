CorkaMInuX, an ELF/PDF/HTML/Java file

= Introduction =
CorkaMInuX is simultaneously a valid:
 * Linux ELF binary (x86)
 * Linux-compatible PDF (but *NOT* Adobe reader compatible)
 * Oracle Java JAR (a CLASS inside a ZIP)
 * HTML page with JavaScript

it can be downloaded at http://code.google.com/p/corkami/downloads/list (binary's sha256: e464eb75843901f3ed09dba0d3f53da21e6ac0229facd3845e306320c7826879)

= About =
It serves no purpose, except proving that file formats not starting at offset 0 are a bad idea.

Many files (known as _polyglot_) already combines various languages in one file, however it's most of the time at source level, not binary level.

If you're worried about malware, just remember that this file doesn't show anything new, and it doesn't provide a methodology or a tool, as it's made entirely by hand, from scratch. Besides, any file with such characteristics would be highly suspicious.

So, the technique to combine these formats is not new, not trivial to reproduce, and likely useless for malicious purposes.

= Technical details =

== Compiling ==
It's 100% written by hand in x86 assembly with YASM, including ZIP, CLASS and ELF structures. the tiny PDF is also hand-written.

to compile it, just run: `yasm -o corkaminux elf.asm`

== Formats ==
The ELF file format HAS to start at offset 0, which determines the file's header.

a PDF file theoretically HAS to start with a %PDF-1 signature (within 1024 bytes for Adobe reader), however that's *NOT* required for alternate (and linux', potentially MuPDF-based) readers - but a CR character is required before the first object. it also miss Tf parameters, and other things... check http://pdf.corkami.com for more information.

As Java doesn't check the validity of the ZIP (JAR)'s CRCs, they have been cleared on purpose (this makes the ZIP pseudo-invalid).

the x86 code contains a few 'undocumented' opcodes - check http://x86.corkami.com for more information.

PDF, HTML formats have to be renamed with correct extensions.

More formats could be added inside the ZIP, but this offers no technical challenge.

No widespread image format is allowed to start beyond offset 0 (EMF, GIF, JPG, PNG, TIF, TGA, PCX, BMP...) so none of them can be included directly as-is in the binary (ie, not in the HTML or the ZIP).

= Acknowledgments =
the ELF tricks are based on Brian Raiter's http://www.muppetlabs.com/~breadbox/software/tiny/teensy.html

the Binary+HTML trick is based on Michal Zalewski's http://lcamtuf.coredump.cx/squirrel/

Ange Albertini (@ange4771) - reverse engineer, author of Corkami
BSD licence, 2012
