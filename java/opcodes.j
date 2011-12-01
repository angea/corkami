.class public opcodes
.super java/lang/Object

.method public static main([Ljava/lang/String;)V
   .limit stack 6
   .limit locals 5
    nop

    aconst_null
    pop

    bipush 0
    pop

    sipush 0
    pop

    aconst_null
    dup
        dup_x1
            dup_x2
                pop2
        dup2
                dup2_x1
                        pop2
                dup2_x2
                            pop
                pop2
        pop2
    pop

;******************************************************************************

    iconst_0
    ifeq _ifeq
_ifeq:

    iconst_0
    ifne _ifne
_ifne:

    iconst_0
    iflt _iflt
_iflt:

    iconst_0
    ifge _ifge
_ifge:

    iconst_0
    ifgt _ifgt
_ifgt:

    iconst_0
    ifle _ifle
_ifle:

;   ifnonnull _ifeq

;   ifnull _ifeq

    goto _goto
_goto:
;******************************************************************************
    lconst_0
    l2d
    d2l
    l2f
    f2l
    l2i
    i2l
    pop2

    iconst_0
    i2f
    f2i
    i2b
    i2c
    i2s
    i2d
    d2i
    i2d
    d2f
    f2d
    d2i
    pop
;******************************************************************************

    iconst_m1
    istore 0

    iconst_m1
    istore_0

    iconst_m1
    istore_1

    iconst_m1
    istore_2
    iconst_m1
    istore_3


    iinc 0 0 ; jasmin still generates this as wide iinc :(

    iinc 0 65535

    iload 0
    pop
    iload_0
    pop
    iload_1
    pop
    iload_2
    pop
    iload_3
    pop

    lconst_0
    lstore 0

    lconst_0
    lstore_0

    lload 0
    pop2
    lload_0
    pop2


    lconst_0
    lstore_1
    lload_1
    pop2

    lconst_0
    lstore_2
    lload_2
    pop2

    lconst_0
    lstore_3
    lload_3
    pop2

    dconst_0
    dstore 0

    dconst_0
    dstore_0

    dload 0
    pop2
    dload_0
    pop2

    dconst_0
    dstore_1
    dload_1
    pop2

    dconst_0
    dstore_2
    dload_2
    pop2

    dconst_0
    dstore_3
    dload_3
    pop2



    lconst_0
    iconst_0
    lshr
    pop2

    lconst_0
    iconst_0
    lushr
    pop2

    lconst_0
    iconst_0
    lshl
    pop2

    lconst_0
    lneg
    pop2

    lconst_0
    lconst_0
    land
    pop2

    lconst_0
    lconst_0
    lor
    pop2

    lconst_0
    lconst_0
    lmul
    pop2

    lconst_0
    lconst_0
    lxor
    pop2

    lconst_0
    lconst_1
    lrem
    pop2

    lconst_0
    lconst_1
    ldiv
    pop2

    dconst_0
    dconst_0
    dmul
    pop2

    dconst_0
    dneg
    pop2

    dconst_0
    dconst_1
    drem
    pop2

    dconst_0
    dconst_1
    ddiv
    pop2

    dconst_0
    dconst_1
    dsub
    pop2

    dconst_0
    dconst_1
    dadd
    pop2

    lconst_0
    lconst_1
    lsub
    pop2

;******************************************************************************
; integers

    iconst_m1
    pop
    iconst_0
    pop
    iconst_1
    pop
    iconst_2
    pop
    iconst_3
    pop
    iconst_4
    pop
    iconst_5
    pop

    iconst_0
    ineg
    pop

    iconst_m1
    iconst_0
    iadd
    pop

    iconst_m1
    iconst_0
    isub
    pop

    iconst_1
    iconst_1
    idiv
    pop

    iconst_m1
    iconst_0
    imul
    pop

    iconst_m1
    iconst_0
    ishl
    pop

    iconst_m1
    iconst_0
    ishr
    pop

    iconst_m1
    iconst_0
    iushr
    pop

    iconst_m1
    iconst_0
    ior
    pop

    iconst_m1
    iconst_0
    iand
    pop

    iconst_m1
    iconst_0
    ixor
    pop

    iconst_1
    iconst_1
    irem
    pop

;******************************************************************************
; long

    lconst_0
    pop2
    lconst_1
    pop2

    lconst_0
    lconst_1
    lcmp
    pop

    lconst_1
    lconst_1
    ladd
    pop2

;******************************************************************************
    dconst_0
    pop2
    dconst_1
    pop2

    fconst_0
    fneg
    pop

    fconst_1
    fconst_1
    frem
    pop

    fconst_0
    fstore_0
    fload_0
    pop

    fconst_0
    fstore 0
    fload 0
    pop

    fconst_0
    fstore_1
    fload_1
    pop

    fconst_0
    fstore_2
    fload_2
    pop

    fconst_0
    fstore_3
    fload_3
    pop

    ldc "ldc"
    ldc_w "lc_w"
    ldc2_w 0
    pop2

    jsr subr
    goto next
subr:
    astore 0
    ret 0
next:

    jsr_w subr_w
    goto next_w
subr_w:
    astore 0
    ret 0
next_w:

    goto_w _goto_w
_goto_w:

    aconst_null
    astore_0
    aload_0
    pop

    aconst_null
    astore 0
    aload 0
    pop

    aconst_null
    astore_1
    aload_1
    pop

    aconst_null
    astore_2
    aload_2
    pop

    aconst_null
    astore_3
    aload_3
    pop

    ifnull ifnull_
ifnull_:

    ifnonnull ifnonnull_
ifnonnull_:

    iconst_0
    iconst_0
    if_icmpeq if_icmpeq_
if_icmpeq_:

    iconst_0
    iconst_0
    if_icmpne if_icmpne_
if_icmpne_:

    iconst_0
    iconst_0
    if_icmplt if_icmplt_
if_icmplt_:

    iconst_0
    iconst_0
    if_icmpge if_icmpge_
if_icmpge_:

    iconst_0
    iconst_0
    if_icmpgt if_icmpgt_
if_icmpgt_:

    iconst_0
    iconst_0
    if_icmple if_icmple_
if_icmple_:

    aconst_null
    aconst_null
    if_acmpeq if_acmpeq_
if_acmpeq_:

    aconst_null
    aconst_null
    if_acmpne if_acmpne_
if_acmpne_:

    aconst_null
    aconst_null
    swap
    pop2
    
;******************************************************************************
; floating
    fconst_0
    pop
    fconst_1
    pop
    fconst_2
    pop

    fconst_0
    fconst_1
    fcmpg
    pop

    dconst_0
    dconst_1
    dcmpl
    pop

    dconst_0
    dconst_1
    dcmpg
    pop

    fconst_0
    fconst_1
    fcmpl
    pop

    fconst_0
    fconst_1
    fadd
    pop

    fconst_0
    fconst_1
    fsub
    pop

    fconst_0
    fconst_1
    fdiv
    pop

    fconst_0
    fconst_1
    fmul
    pop


    getstatic java/lang/System/out Ljava/io/PrintStream;
    ldc " * all opcodes"
    invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V
    return
    
    nop
    nop
    
    aconst_null
    aload 0
    aload_0
    aload_1
    aload_2
    aload_3
    astore 0
    astore_0
    astore_1
    astore_2
    astore_3
    bipush 0
    d2f
    d2i
    d2l
    dadd
    dcmpg
    dcmpl
    dconst_0
    dconst_1
    ddiv
    dload 0
    dload_0
    dload_1
    dload_2
    dload_3
    dmul
    dneg
    drem
    dstore 0
    dstore_0
    dstore_1
    dstore_2
    dstore_3
    dsub
    dup
    dup2
    dup2_x1
    dup2_x2
    dup_x1
    dup_x2
    f2d
    f2i
    f2l
    fadd
    fcmpg
    fcmpl
    fconst_0
    fconst_1
    fconst_2
    fdiv
    fload 0
    fload_0
    fload_1
    fload_2
    fload_3
    fmul
    fneg
    frem
    fstore 0
    fstore_0
    fstore_1
    fstore_2
    fstore_3
    fsub
    goto _goto
    goto next
    goto next_w
    goto_w _goto_w
    i2b
    i2c
    i2d
    i2f
    i2l
    i2s
    iadd
    iand
    iconst_0
    iconst_1
    iconst_2
    iconst_3
    iconst_4
    iconst_5
    iconst_m1
    idiv
    if_acmpeq if_acmpeq_
    if_acmpne if_acmpne_
    if_icmpeq if_icmpeq_
    if_icmpge if_icmpge_
    if_icmpgt if_icmpgt_
    if_icmple if_icmple_
    if_icmplt if_icmplt_
    if_icmpne if_icmpne_
    ifeq _ifeq
    ifge _ifge
    ifgt _ifgt
    ifle _ifle
    iflt _iflt
    ifne _ifne
    ifnonnull ifnonnull_
    ifnull ifnull_
    iinc 0 0 ; jasmin still generates this as wide iinc :(
    iinc 0 65535
    iload 0
    iload_0
    iload_1
    iload_2
    iload_3
    imul
    ineg
    ior
    irem
    ishl
    ishr
    istore 0
    istore_0
    istore_1
    istore_2
    istore_3
    isub
    iushr
    ixor
    jsr subr
    jsr_w subr_w
    l2d
    l2f
    l2i
    ladd
    land
    lcmp
    lconst_0
    lconst_1
    ldc "ldc"
    ldc2_w 0
    ldc_w "lc_w"
    ldiv
    lload 0
    lload_0
    lload_1
    lload_2
    lload_3
    lmul
    lneg
    lor
    lrem
    lshl
    lshr
    lstore 0
    lstore_0
    lstore_1
    lstore_2
    lstore_3
    lsub
    lushr
    lxor
    nop
    pop
    pop2
    ret 0
    sipush 0
    swap
   
    nop
    nop
    new opcodes
    newarray int
    getfield java/lang/System/out Ljava/io/PrintStream;
    putfield java/lang/System/out Ljava/io/PrintStream;
    putstatic java/lang/System/out Ljava/io/PrintStream;
    iaload
    laload
    daload
    aaload
    baload
    caload
    saload
    faload
    iastore
    lastore
    dastore
    aastore
    bastore
    castore
    sastore
    fastore
    lookupswitch 
        0: lu0
        default: ludef
        
    lu0:
    ludef:
    
    tableswitch 0
        ts0
        default: tsdef
    ts0:
    tsdef:
    nop
    ireturn
    lreturn
    freturn
    dreturn
    areturn
    invokestatic java/io/PrintStream/println(Ljava/lang/String;)V
    anewarray int
    ;invokeinterface  foo/Baz/myMethod(I)V 1 ; broken for now
    ;invokespecial ; broken for now

    multianewarray [[[I 2
    arraylength
    athrow
    checkcast opcodes
    instanceof opcodes
    monitorenter
    monitorexit
    
.end method
