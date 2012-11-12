#include <windows.h>
#include <stdio.h>

int mainCRTstartup(){
    printf("IsDebuggerPresent: ");

    if (IsDebuggerPresent()) {
        printf("debugger FOUND\n");
        return 42;
    } else {
        printf("nothing found\n");
        return 0;
    }
}
