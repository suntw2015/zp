#include "font.h"
#include "main.h"

int getPointAddressOffset(int x, int y) {
    return (x * kernelConfig.screenMaxCol + y) * 4;
}

//显示一个点
void displayPoint(char* addr, int x, int y, char r, char g, char b, char alpha) {
    int offset = getPointAddressOffset(x, y);
    *(addr+offset+0) = b;
    *(addr+offset+1) = g;
    *(addr+offset+2) = r;
    *(addr+offset+3) = alpha;
}

//显示一个字符
void displayChar(char* addr, int x, int y, char c,char r, char g, char b, char alpha) {
    char *map = font_ascii[c];
    int i,j;

    for (i=0;i<FONT_DEFAULT_HEIGHT;i++) {
        for (j=0;j<FONT_DEFAULT_WIDTH;j++) {
            if ((map[i] >> j) & 1) {
                displayPoint(addr, x+i, y+j, r, g, b, alpha);
            }
        }
    }
}

void displayString(char* addr, int x, int y, char* str,char r, char g, char b, char alpha) {
    int i;
    for (i=0;str[i] != '\0';i++) {
        displayChar(addr, x, y, str[i], r, g, b, alpha);
        y+=FONT_DEFAULT_WIDTH;
    }
}