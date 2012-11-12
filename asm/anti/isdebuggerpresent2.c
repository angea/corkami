#include <windows.h>
#include <stdio.h>

int mainCRTstartup(){
    printf("faked IsDebuggerPresent: ");

    __asm__ (
         "movl %fs:0x018 , %eax ;"
         "movl 0x30(%eax) , %eax ;"
         "addl $2, %eax;"
         "movb $1, (%eax)"
    );

    if (IsDebuggerPresent()) {
        printf("nothing found\n");
        return 0;
    } else {
        printf("anti-debugger FOUND\n");
        return 42;
    }
}
