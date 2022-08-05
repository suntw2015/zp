#ifndef HELP_H
#define HELP_H

//定义基础数据类型
typedef __signed__ char s8;
typedef unsigned char u8;
typedef __signed__ short s16;
typedef unsigned short u16;
typedef __signed__ int s32;
typedef unsigned int u32;
typedef __signed__ long long s64;
typedef unsigned long long u64;

typedef struct
{
	u64 addr;
	u64 length;
	u32 type;
} MemoryArds;

typedef struct KernelConfig
{
	int screenMaxRow;	//屏幕最大行
	int screenMaxCol;	//屏幕最大列
    int cursorCurrentRow; //光标目前行
    int cursorCurrentCol; //光标目前列
} KernelConfig;

extern KernelConfig kernelConfig;

/**
 * @brief 向某个端口输出一个字节
 * 
 * @param value 输出的值
 * @param port 输出端口
 */
static inline void outb(u8 value, u16 port)
{
    asm volatile("outb %0,%1" : : "a" (value), "dN" (port));
}

static inline u8 inb(u16 port)
{
	u8 value;
	asm volatile("inb %1,%0" : "=a" (value) : "dN" (port));
	return value;
}



#endif