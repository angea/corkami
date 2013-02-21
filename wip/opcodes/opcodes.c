#include <stdio.h>

int checkcpuid(char shift)
{
    int result = 1;
    int mask = 1 << shift;
    __asm{
        mov eax, 1
        cpuid
        ebx =
        and ecx, mask
    };
    __asm{
        jz good
bad:
        mov result, 1
        jmp end
good:
        mov result, 0

        end:
    };
    return result;    
}

int checkpopcnt()
{
    int result = 1;
    __asm{
        mov ebx, 0100101010010b
        db 0F3h, 00Fh, 0B8h, 0C3h   ;popcnt eax, ebx
        cmp eax, 5
    };
    __asm{
        jz good
bad:
        mov result, 1
        jmp end

good:
        mov result, 0

        end:
    };
    return result;
}

int checkcrc32()
{
    int result = 1;
    
    __asm{
        mov eax, 0
        mov ebx, 012345678h
        db 0F2h, 0Fh, 038h, 0F1h, 0c3h  ; crc32 eax, ebx
        cmp eax, 0fa745634h
    };
    __asm{
        jz good
bad:
        mov result, 1
        jmp end

good:
        mov result, 0

        end:
    };
    return result;
}

int checkadd()
{
    int result = 1;
    __asm{
        mov eax, 1
        add eax, 1
        cmp eax, 2
    };
    __asm{
        jz good
bad:
        mov result, 1
        jmp end

good:
        mov result, 0

        end:
    };
    return result;
}

int main()
{

    if (0 == checkcpuid(20)){
        printf("CRC32 not supported\n");
    }
    else{
        if (checkcrc32()){
            printf("Error: CRC32\n");
        }
    }

    if (0 == checkcpuid(23)){
        printf("POPCNT not supported\n");
    }
    else{
        if (checkpopcnt()){
            printf("Error: POPCNT\n");
        }
    }


    if (checkadd()){
        printf("Error: ADD\n");
    }
    return 0;
}
