; HelloWorld - shorter, one method - in jasmin

; java -jar jasmin.rar HelloWorldshort.j
; java HelloWorldshort


.class public HelloWorldshort
.super java/lang/Object


.method public static main([Ljava/lang/String;)V
   .limit stack 2   ; up to two items can be pushed

   getstatic java/lang/System/out Ljava/io/PrintStream;
   ldc "Hello World!"
   invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V
   return
.end method
