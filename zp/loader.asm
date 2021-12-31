;/***************************************************
;		版权声明
;
;	本操作系统名为：MINE
;	该操作系统未经授权不得以盈利或非盈利为目的进行开发，
;	只允许个人学习以及公开交流使用
;
;	代码最终所有权及解释权归田宇所有；
;
;	本模块作者：	田宇
;	EMail:		345538255@qq.com
;
;
;***************************************************/

org	0xb000
jmp Label_Start

%inclue "fat12.inc"

[SECTION gdt]

LABEL_GDT:		dd	0,0
LABEL_DESC_CODE32:	dd	0x0000FFFF,0x00CF9A00
LABEL_DESC_DATA32:	dd	0x0000FFFF,0x00CF9200

GdtLen	equ	$ - LABEL_GDT
GdtPtr	dw	GdtLen - 1
	dd	LABEL_GDT

SelectorCode32	equ	LABEL_DESC_CODE32 - LABEL_GDT
SelectorData32	equ	LABEL_DESC_DATA32 - LABEL_GDT

[SECTION gdt64]

LABEL_GDT64:		dq	0x0000000000000000
LABEL_DESC_CODE64:	dq	0x0020980000000000
LABEL_DESC_DATA64:	dq	0x0000920000000000

GdtLen64	equ	$ - LABEL_GDT64
GdtPtr64	dw	GdtLen64 - 1
		dd	LABEL_GDT64

SelectorCode64	equ	LABEL_DESC_CODE64 - LABEL_GDT64
SelectorData64	equ	LABEL_DESC_DATA64 - LABEL_GDT64

[section .s16]
[bits 16]
Label_Start:
	mov	ax,	cs
	mov	ds,	ax
	mov	es,	ax
	mov	ax,	0x00
	mov	ss,	ax
	mov	sp,	0x7c00

;=======	display on screen : Start Loader......
	mv bp, StartLoaderMessage
	call Func_Print_Message

;突破1MB地址限制
	push ax
	in al, 92h
	or al, 00000010b
	out 92h, al
	pop ax

	cli
	lgdt [GdtPtr]

	mov	eax,	cr0
	or	eax,	1
	mov	cr0,	eax

	mov	ax,	SelectorData32
	mov	fs,	ax
	mov	eax,	cr0
	and	al,	11111110b
	mov	cr0,	eax

	sti
	jmp	$

;打印日志
;入参 
;es:bp 输出内容地址
;字符串以00结尾
Func_Print_Message:	
	push dx
	push ax
	push bx
	push bp
	;计算cx
	mov dx, 0
	mov ax, 0
	
Label_Cal_Length:
	mov al, [es:bp]
	inc bp
	cmp al, 0x30 ;0对应的0x30
	jnz Label_Cal_Length
Label_Zero_Inc: ;找到0
	inc dx
	cmp dx, 2	;是否是第二个0
	jnz Label_Cal_Length
Label_Find_End:
	mov cx, bp
	pop bp
	sub cx, bp ;减去字符串起始位置
	sub cx, 2 ;减去两个0的长度

	;计算打印位置 dh -> row dl->col	
	mov dh, [PrintRow]
	mov dl, [PrintCol]
	mov ax, 1301h
	mov bx, 000fh
	int 10h
	mov al, [PrintRow]
	inc al
	mov [PrintRow], al

	pop bx
	pop ax
	pop dx
	ret

;=======	display messages

StartLoaderMessage:	db	"Start Loader00"





