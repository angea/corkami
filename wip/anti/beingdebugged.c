#include <windows.h>
#include <stdio.h>

int mainCRTstartup(){
    int b;

    printf("BeingDebugged: ");
    __asm__ (
         "movl %%fs:0x018 , %%eax ;"
         "movl 0x30(%%eax) , %%eax ;"
         "movzxb 0x2(%%eax) , %0"
         : "=a"(b)
    );

    if (b) {
        printf("debugger FOUND\n");
        return 42;
    } else {
        printf("nothing found\n");
        return 0;
    }
}
