#include "main.h"
#include "font.h"

//全局变量
KernelConfig kernelConfig;

void Start_Kernel(void)
{
	init();
	displayChar(kernelConfig.screenAddress, 0, 0, 'A', 0xFF, 0, 0, 0);
	displayString(kernelConfig.screenAddress, 20, 0, 'Hello', 0xFF, 0, 0, 0);
}

void init() {
	kernelConfig.screenMaxCol = 1400;
	kernelConfig.screenMaxRow = 960;
	kernelConfig.screenAddress = (char *)0xffff800000a00000;
}