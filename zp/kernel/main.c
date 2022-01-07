#include "main.h"
#include "font.h"

//全局变量
// KernelConfig kernelConfig;

// void init() {
// 	kernelConfig.screenMaxCol = 1400;
// 	kernelConfig.screenMaxRow = 960;
// 	kernelConfig.screenAddress = (char *)0xffff800000a00000;
// }

void Start_Kernel(void)
{
	char * addr = (char *)0xffff800000a00000;
	displayChar(addr, 0, 0, 'A', (char)0xFF, (char)0x00, (char)0x00, (char)0x00);

	char str[] = "hello";
	displayString(addr, 20, 0, str, (char)0xFF, (char)0x00, (char)0x00, (char)0x00);
}