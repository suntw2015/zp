#include "help.h"
#include "string.h"

KernelConfig kernelConfig;

void init_console();
void init_heap();
void init_kernel();
void init_memery();
void init_video();
void log(char *s);

int main() {
    char *video = (char*)0xB8000;

    *video = 'X';

    kernelConfig.cursorCurrentCol = 0;
    kernelConfig.cursorCurrentRow = 0;
    kernelConfig.screenMaxCol = 80;
    kernelConfig.screenMaxRow = 50;

    init_memery();

    while (1) {
    };

    return 0;
}

void log(char *s)
{
    char *video = (char*)0xB8000 + (kernelConfig.cursorCurrentRow*kernelConfig.screenMaxCol+kernelConfig.cursorCurrentCol)*2;
    
    for (int i=0; s[i] != '\0'; i++) {
        *video = s[i];
        video += 2;
    }
    kernelConfig.cursorCurrentRow++;
}

void init_console()
{}

void init_heap()
{}

void init_kernel()
{}

void init_memery()
{
    char a[100];
    char b[100];
    u8 count = *((u8*)0x7e00);
    long long t;

    memset(a, 0, 100);
    strcat(a, "ards count:");
    itoa(count, b, 10);
    strcat(a,b);
    log(a);

    MemoryArds *ards = 0x7e01;
    for (int i=0;i<count;i++) {
        ards = 0x7e01 + i*20;
        memset(a, 0, 100);
        strcat(a, "base:");
        itoa(ards->addr, b, 16);
        strcat(a, b);
        strcat(a, ", length:");
        itoa(ards->length, b , 16);
        strcat(a, b);
        strcat(a, ", type:");
        itoa(ards->type, b , 10);
        strcat(a, b);
        log(a);
    }
}