#include "font.h"
#include "main.h"

extern KernelConfig kernelConfig;

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
                displayPoint(addr, x+i, y+FONT_DEFAULT_WIDTH-j, r, g, b, alpha);
            }
        }
    }
}

//显示字符串
void displayString(char* addr, int x, int y, char* str,char r, char g, char b, char alpha) {
    int i;
    for (i=0;str[i] != '\0';i++) {
        displayChar(addr, x, y, str[i], r, g, b, alpha);
        y+=FONT_DEFAULT_WIDTH;
    }
}

//字符是否可以打印
int isCharCanPrint(char c) {
    return c>=32 && c<=126;
}

//智能显示字符串
void displayStringSmart(char *str, enum FontColor color) {
    char r,g,b,a;

    r=g=b=a=(char)0x00;
    switch (color)
    {
        case RED:
            r = (char)0x55;
            break;
        case GREEN:
            g = (char)0x55;
            break;
        case BLUE:
            b = (char)0x55;
            break;
        default:
            break;
    }

    for (int i=0;str[i] != '\0';i++) {
        if (isCharCanPrint(str[i])) {
            //检查是否需要换行
            if (kernelConfig.cursorCurrentCol + FONT_DEFAULT_WIDTH > kernelConfig.screenMaxCol) {
                kernelConfig.cursorCurrentRow++;
                kernelConfig.cursorCurrentCol=0;
            }
            displayChar(kernelConfig.screenAddress, kernelConfig.cursorCurrentRow, kernelConfig.cursorCurrentCol, str[i], r, g, b, a);
        }
    }
}