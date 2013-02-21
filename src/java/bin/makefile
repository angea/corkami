all: jasmin python #java 

java:HWComment.class substs.class

jasmin:Helloworld.class Helloworldshort.class  tableswitch_.class opcodes.class

python: main.class Code.class

%.class: ..\%.java
	javac $<

%.class: ..\%.j
	java -jar jasmin.jar $<

main.class: ..\tiny.py
	c:\python26\python ..\tiny.py

Code.class: ..\static.py
	c:\python26\python ..\static.py
