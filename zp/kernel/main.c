#include "main.h"
#include "font.h"

//全局变量
KernelConfig kernelConfig;

void init() {
	kernelConfig.screenMaxCol = 1440;
	kernelConfig.screenMaxRow = 960;
	kernelConfig.screenAddress = (char *)0xffff800000a00000;
	kernelConfig.cursorCurrentRow = 0;
	kernelConfig.cursorCurrentCol = 0;
}

void Start_Kernel(void)
{
	init();
	char * addr = (char *)0xffff800000a00000;

	displayChar(addr, 0, 0, 'A', 0xFF, 0x00, 0x00, 0x00);
	displayString(addr, 100, 0, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", 0xff, 0, 0, 0);

	while (1) {}
}

void displaySmart(char *str)
{
	displayString(kernelConfig.screenAddress, kernelConfig.cursorCurrentRow, kernelConfig.cursorCurrentCol,str,0xff,0x00,0x00,0x00);
}