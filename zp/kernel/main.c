#include "main.h"
#include "font.h"

//全局变量
KernelConfig kernelConfig;

void init() {
	kernelConfig.screenMaxCol = 1400;
	kernelConfig.screenMaxRow = 960;
	kernelConfig.screenAddress = (char *)0xffff800000a00000;
}

void Start_Kernel(void)
{
	char * addr = (char *)0xffff800000a00000;

	int i,j,offset;
	for (i=50;i<70;i++) {
		for (j=0;j<1400;j++) {
			offset = (i*1400+j) * 4;
			*(addr+offset+0) = (char)0x00;
			*(addr+offset+1) = (char)0x00;
			*(addr+offset+2) = (char)0xff;
			*(addr+offset+3) = (char)0x00;
		}
	}

	for (i=25;i<30;i++) {
		for (j=0;j<1400;j++) {
			displayPoint(addr, i, j, 0xff, 0x00, 0x00, 0x00);
		}
	}

	displayChar(addr, 0, 0, 'A', (char)0xFF, (char)0x00, (char)0x00, (char)0x00);

	char str[] = "hello";
	displayString(addr, 20, 0, str, (char)0xFF, (char)0x00, (char)0x00, (char)0x00);
}