#preliminary junk code skipper

def getDword(data, offset):
    return struct.unpack("L", data[offset:offset + 4])[0]

def mid(b):
    return (b >> 3) & 7

def parse_instruction(data, offset):
    """ return non 0 if instruction is accepted"""
    byte = ord(data[offset])
    if byte in [
        0x64, 0x65, 0xf2, 0xf3, 0x2e, 0x3e, 0x26, 0x36, # prefixes
        0x40, 0x41, 0x42, 0x43, 0x45, 0x46, 0x47,       # inc
        0x48, 0x49, 0x4A, 0x4B, 0x4d, 0x4E, 0x4f,       # dec
        0x90,                                           # nop
        0xFD, 0xFC,                                     # std/cld
        ]:
        return 1

    if byte in [
        0x04, 0x14, 0x24, 0x34,
        0x0c, 0x1c, 0x2c, 0x3c,
        0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7,
        ]:
        return 1 + 1

    if byte in [
        0xb8, 0xb9, 0xba, 0xbb, 0xbd, 0xbe, 0xbf,
        0x05, 0x15, 0x25, 0x35,
        0x0d, 0x1d, 0x2d, 0x3d,
        ]:
        return 1 + 4

    if (byte in [
        0x00, 0x01, 0x02, 0x03, 0x08, 0x09, 0x0a, 0x0b,
        0x10, 0x11, 0x12, 0x13, 0x18, 0x19, 0x1a, 0x1b,
        0x20, 0x21, 0x22, 0x23, 0x28, 0x29, 0x2a, 0x2b,
        0x30, 0x31, 0x32, 0x33, 0x38, 0x39, 0x3a, 0x3b,
        0xFF, # not perfect
        0xd0, 0xd1, 0xd2, 0xd3,
        0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8b,

        ] and \
        ((ord(data[offset + 1]) & 0xc0) == 0xc0)):
        return 2

    if (byte in [
        0x80, # grp add/or/adc/sbb/and/sub/xor/cmp r8, i8
        0xc0, # grp rol/ror/rcl/rcr/shl/shr/sal/sar r8, i8
        0xc1, # grp rol/ror/rcl/rcr/shl/shr/sal/sar r32, i8
        0xc6, # not perfect
        ] and \
        ((ord(data[offset + 1]) & 0xc0) == 0xc0)):
        return 3

    if (byte in [
        0x69, # imul r32, r32, imm32
        0xc7, # mov r32, im32 # not perfect
        0x81, # grp add/or/adc/sbb/and/sub/xor/cmp r32, i32
        ] and \
        ((ord(data[offset + 1]) & 0xc0) == 0xc0)):
        return 2 + 4

    if byte in [
        0x8d,
        ] and \
        ((ord(data[offset + 1]) & 0xc7) == 0x05):
        return 2 + 4

    if byte in [
        0xf6,
        ] and \
        ((ord(data[offset + 1]) & 0xc0) == 0xc0):
        if mid(ord(data[offset + 1])) in [0, 1]:
            return 2 + 1
        else:
            return 2

    if byte in [
        0xf7,
        ] and \
        ((ord(data[offset + 1]) & 0xc0) == 0xc0):
        if mid(ord(data[offset + 1])) in [0, 1]:
            return 2 + 4
        else:
            return 2

    if byte == 0xfe and \
        (ord(data[offset + 1]) & 0xc0) == 0xc0 and \
        mid(ord(data[offset + 1])) < 2:
        return 2

    # add/sub/xor
    if (byte in [0x8a, 3, 0x2b, 0x33]) and \
        ((ord(data[offset + 1]) & 0xc0) == 0xc0): # ???? <reg32>, <reg32>
        return 2
#
#    # group, mul <reg32>
#    if byte == 0xf7 and ((ord(data[offset + 1]) & 0xFC == 0xE0)):
#        return 2

    if byte == 0xe9:
        if getDword(data, offset + 1) == 0:
            return 5
        else:
            return 0

    if byte == 0x0f:
        off2 = offset + 1
        byte = ord(data[off2])

        if byte in [
            0xc8, 0xc9, 0xca, 0xcb, 0xcd, 0xce, 0xcf # bswap
            ]:
            return 1 + 1

        if byte in [
            0xab, 0xad, 0xaf, 0xa3, 0xa5,
            0xb3,
            0xb6, 0xb7, 0xbc, 0xbb, 0xbd,  0xbe, 0xbf, # b?? r32, 32 / movsx
            0xc0, 0xc1, # xadd
            ] and \
            ((ord(data[off2 + 1]) & 0xc0) == 0xc0):
            return 1 + 2

        if byte in [
            0xba
            ] and \
            ((ord(data[off2 + 1]) & 0xc0) == 0xc0) and \
            (mid(ord(data[off2 + 1])) >= 4):
            return 1 + 2 + 1


        if byte in [
            0xa4, #shld r32, r32, i8
            0xac, #shrd r32, r32, i8
            ] and \
            ((ord(data[off2 + 1]) & 0xc0) == 0xc0):
            return 1 + 2 + 1

        if byte in [ # jumps, should handle the offset
            # 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8a, 0x8b, 0x8c, 0x8d, 0x8e, 0x8f
            0x85,
            ]:
            return 1 + 1 + 4

    return 0


