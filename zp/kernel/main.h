#ifndef MAIN_H
#define MAIN_H

typedef struct KernelConfig
{
	char *screenAddress; //显卡的地址
	int screenMaxRow;	//屏幕最大行
	int screenMaxCol;	//屏幕最大列
} KernelConfig;

extern KernelConfig kernelConfig;

#endif