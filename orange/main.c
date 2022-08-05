#include "help.h"
#include <string.h>

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
    kernelConfig.screenMaxCol = 200;
    kernelConfig.screenMaxRow = 100;

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
    u8 count = *((u8*)0x7e00);
    MemoryArds *ards = 0x7e01;
    for (int i=0;i<count;i++) {
        log(sprintf("base: %ld, length: %ld , type:%d \n", ards->addr, ards->length, ards->type));
    }
}