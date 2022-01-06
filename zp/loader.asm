;loader

org	10000h
jmp Label_Start

%include "fat12.inc"

BaseOfKernelFile	equ	0x00
OffsetOfKernelFile	equ	0x100000

BaseTmpOfKernelAddr	equ	0x00
OffsetTmpOfKernelFile	equ	0x7E00

MemoryStructBufferAddr	equ	0x7E00

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

[SECTION .s16]
[BITS 16]
Label_Start:
	mov	ax,	cs
	mov	ds,	ax
	mov	es,	ax
	mov	ax,	0x00
	mov	ss,	ax
	mov	sp,	0x7c00

;=======	display on screen : Start Loader......
	mov bp, StartLoaderMessage
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

;======= 开始读取fat12目录信息
;目录开始扇区SectorNumOfRootDirStart， 目录长度RootDirSectors

Label_Begion_Read_Root_Dir:
	;读取目录信息
	mov ax, 0
	mov al, RootDirSectors
	mov dx, SectorNumOfRootDirStart
	mov bx, 2000h
	call Func_Read_Sector_Data

	mov bp, StartSearchKernel
	call Func_Print_Message
	
	;从es:bx处开始对比
	mov bx, 2000h
	;总目录数 [BPB_RootEntCnt]
	mov ax, [BPB_RootEntCnt]

Label_Read_Root_Dir:
	mov si, bx
	;bp为要搜索的文件，dx为文件长度
	mov bp, KernelFileName
	mov cx, 11

Label_Search_File:
	mov dl, [es:si]
	;es:di 和 bp比对，长度为 dx
	cmp dl, [es:bp]
	jnz Label_File_Not_Cmp
	inc si
	inc bp
	dec cx
	cmp cx, 0
	jnz Label_Search_File
	;找到文件了
	mov bp, SearchedKernelFile
	call Func_Print_Message
	;文件的目录信息为  es:bx ，文件大小为es:bx+0x1c 4个字节
	;开始读取文件内容 dx:si
	mov dx, BaseTmpOfKernelAddr
	mov si, OffsetTmpOfKernelFile
	
	call Func_Load_File

	;kernel读取到临时空间了, 迁移kernel到1MB以上的空间
	push cx
	push eax
	push fs
	push edi
	push ds
	push esi
	;BaseTmpOfKernelAddr:OffsetTmpOfKernelFile 到 BaseOfKernelFile : OffsetOfKernelFile
	;获取kernel文件大小
	add bx, 0x1c
	mov ecx, [es:bx]
	mov ax, BaseTmpOfKernelAddr
	mov ds, ax
	mov esi, OffsetTmpOfKernelFile
	;KernelTmpFileOffset
Label_Mov_Kernel:
	mov al, [ds:esi]
	mov byte [fs:edi], al
	inc esi
	inc edi
	loop Label_Mov_Kernel

	pop	esi
	pop	ds
	pop	edi
	pop	fs
	pop	eax
	pop	cx

Label_Kernel_Mov_Success:
	mov	ax, 0B800h
	mov	gs, ax
	mov	ah, 0Fh				; 0000: 黑底    1111: 白字
	mov	al, 'G'
	mov	[gs:((80 * 0 + 39) * 2)], ax	; 屏幕第 0 行, 第 39 列。

	mov bp, SearchedKernelFile
	call Func_Print_Message

;=======	获取内存信息
	mov	bp,	StartGetMemStructMessage
	call Func_Print_Message
	push es
	mov	ebx,	0
	mov	ax,	0x00
	mov	es,	ax
	mov	di,	MemoryStructBufferAddr	

Label_Get_Mem_Struct:

	mov	eax,	0x0E820
	mov	ecx,	20
	mov	edx,	0x534D4150
	int	15h
	jc	Label_Get_Mem_Fail
	add	di,	20

	cmp	ebx,	0
	jne	Label_Get_Mem_Struct
	jmp	Label_Get_Mem_OK

Label_Get_Mem_Fail:
	pop es
	mov	bp,	GetMemStructErrMessage
	call Func_Print_Message
	jmp	$

Label_Get_Mem_OK:
	pop es
	mov	bp,	GetMemStructOKMessage
	call Func_Print_Message

;=======	获取SVGA显示信息
	mov	bp,	StartGetSVGAVBEInfoMessage
	call Func_Print_Message

	push es
	mov	ax,	0x00
	mov	es,	ax
	mov	di,	0x8000
	mov	ax,	4F00h

	int	10h

	pop es
	cmp	ax,	004Fh

	jz	.KO
	
;=======	Fail
	mov	bp,	GetSVGAVBEInfoErrMessage
	call Func_Print_Message

	jmp	$

.KO:
	mov	bp,	GetSVGAVBEInfoOKMessage
	call Func_Print_Message

;=======	Get SVGA Mode Info
	mov	bp,	StartGetSVGAModeInfoMessage
	call Func_Print_Message

	push es
	mov	ax,	0x00
	mov	es,	ax
	mov	si,	0x800e

	mov	esi,	dword	[es:si]
	mov	edi,	0x8200

Label_SVGA_Mode_Info_Get:

	mov	cx,	word	[es:esi]

;=======	display SVGA mode information

	push	ax
	
	mov	ax,	00h
	mov	al,	ch
	call	Label_DispAL

	mov	ax,	00h
	mov	al,	cl	
	call	Label_DispAL
	
	pop	ax

;=======
	
	cmp	cx,	0FFFFh
	jz	Label_SVGA_Mode_Info_Finish

	mov	ax,	4F01h
	int	10h

	cmp	ax,	004Fh

	jnz	Label_SVGA_Mode_Info_FAIL	

	add	esi,	2
	add	edi,	0x100

	jmp	Label_SVGA_Mode_Info_Get
		
Label_SVGA_Mode_Info_FAIL:
	pop es
	mov	bp,	GetSVGAModeInfoErrMessage
	call Func_Print_Message

Label_SET_SVGA_Mode_VESA_VBE_FAIL:
	pop es
	jmp $

Label_SVGA_Mode_Info_Finish:
	pop es
	mov	bp,	GetSVGAModeInfoOKMessage
	call Func_Print_Message

;=======	set the SVGA mode(VESA VBE)

	mov	ax,	4F02h
	mov	bx,	4180h	;========================mode : 0x180 or 0x143
	int 	10h

	cmp	ax,	004Fh
	jnz	Label_SET_SVGA_Mode_VESA_VBE_FAIL

;=======	init IDT GDT goto protect mode 

	cli			;======close interrupt

	db	0x66
	lgdt	[GdtPtr]

;	db	0x66
;	lidt	[IDT_POINTER]

	mov	eax,	cr0
	or	eax,	1
	mov	cr0,	eax	

	jmp	dword SelectorCode32:GO_TO_TMP_Protect

[SECTION .s32]
[BITS 32]

GO_TO_TMP_Protect:

;=======	go to tmp long mode

	mov	ax,	0x10
	mov	ds,	ax
	mov	es,	ax
	mov	fs,	ax
	mov	ss,	ax
	mov	esp,	7E00h

	call	support_long_mode
	test	eax,	eax

	jz	no_support

;=======	init temporary page table 0x90000

	mov	dword	[0x90000],	0x91007
	mov	dword	[0x90800],	0x91007		

	mov	dword	[0x91000],	0x92007

	mov	dword	[0x92000],	0x000083

	mov	dword	[0x92008],	0x200083

	mov	dword	[0x92010],	0x400083

	mov	dword	[0x92018],	0x600083

	mov	dword	[0x92020],	0x800083

	mov	dword	[0x92028],	0xa00083

;=======	load GDTR

	db	0x66
	lgdt	[GdtPtr64]
	mov	ax,	0x10
	mov	ds,	ax
	mov	es,	ax
	mov	fs,	ax
	mov	gs,	ax
	mov	ss,	ax

	mov	esp,	7E00h

;=======	open PAE

	mov	eax,	cr4
	bts	eax,	5
	mov	cr4,	eax

;=======	load	cr3

	mov	eax,	0x90000
	mov	cr3,	eax

;=======	enable long-mode

	mov	ecx,	0C0000080h		;IA32_EFER
	rdmsr

	bts	eax,	8
	wrmsr

;=======	open PE and paging

	mov	eax,	cr0
	bts	eax,	0
	bts	eax,	31
	mov	cr0,	eax

	jmp	SelectorCode64:OffsetOfKernelFile

;=======	test support long mode or not

support_long_mode:

	mov	eax,	0x80000000
	cpuid
	cmp	eax,	0x80000001
	setnb	al	
	jb	support_long_mode_done
	mov	eax,	0x80000001
	cpuid
	bt	edx,	29
	setc	al
support_long_mode_done:
	
	movzx	eax,	al
	ret

;=======	no support

no_support:
	jmp	$

[SECTION .s16lib]
[BITS 16]
Label_File_Not_Cmp:
	;es:di要增加32
	;剩余目录数减1
	add bx, 20h
	dec ax

	;如果目录都读完了，那就是没有这个文件
	cmp ax, 0
	jnz Label_Read_Root_Dir
;没有找到loader
Label_Not_Found_Loader:
	mov bp, NoKernelMessage
	call Func_Print_Message
	jmp	$

;加载文件内容
;文件的信息为 es:bx
;加载到的位置为 dx:si
Func_Load_File:
	push es
	push ax
	push bx
	push si
	;获取文件起始的簇号
	add bx, 1ah ;DIR_FstClus
	mov ax, [es:bx]
	cmp ax, 0
	jz Label_Read_Finish ;文件起始簇为0
	mov es, dx
Label_Read_File_Content:
	;开始读取
	add ax, 31 ;转换簇号->扇区号 数据区起始簇号为 31 = 1引导 + 9*2 (FAT) + 14目录 - 2保留
	mov dx, ax
	mov al, 1
	mov bx, si
	call Func_Read_Sector_Data

	;获取下一个簇号
	mov ax, dx
	sub ax, 31 ;减掉扇区逻辑
	call Func_Get_Next_Clue
	
	cmp ax, 0fffh
	jz Label_Read_Finish
	;没有读完
	add si, 512
	jmp Label_Read_File_Content

Label_Read_Finish:
	pop si
	pop bx
	pop ax
	pop es
	ret

;根据簇号获取下一个簇号
;https://www.eit.lth.se/fileadmin/eit/courses/eitn50/Literature/fat12_description.pdf fat cluster介绍
;入参
;ax 当前簇号
;出参
;ax
Func_Get_Next_Clue:
	push es
	push bx
	push dx
	push ax	
	;重置下es
	mov ax, 0
	mov es, ax
	;读取fat1
	mov ax, [BPB_FATSz16]
	mov dx, 1 ;fat从第一个扇区开始
	mov bx, 9000h
	call Func_Read_Sector_Data

	;每一个簇在fat1表中占12bit, 1.5byte
	pop ax
	mov bx, 3
	mul bx
	;dx保存 奇偶标志 0偶数 1基数
	mov dx, ax	
	and dx, 1
	shr ax, 1
	;至此簇在fat中的偏移位置为  9000 + ax
	add ax, 9000h
	mov bx, ax

	cmp dx, 0
	jnz Label_Odd
	;If n is even, then the physical location of the entry is the low four bits in location 1+(3*n)/2 and the 8 bits in location (3*n)/2
	;先一个完整的字节，后一半
	mov al, [es:bx]
	inc bx
	mov ah, [es:bx]
	and ah, 0fh
	jmp Label_Return

Label_Odd:
	;If n is odd, then the physical location of the entry is the high four bits in location (3*n)/2 and the 8 bits in location 1+(3*n)/2 
	mov al, [es:bx]
	inc bx
	mov ah, [es:bx]
	shr ax, 4
Label_Return:
	pop dx
	pop bx
	pop es
	ret

;======= 读取扇区数据
;参数
;al : 读取的扇区数量
;dx : 读取的扇区起始位置
;输出
;es:bx : 数据写入位置

; int13h ah=02 读扇区 参数如下 https://en.wikipedia.org/wiki/INT_13H#INT_13h_AH=02h:_Read_Sectors_From_Drive  http://c.biancheng.net/view/3606.html
; al=扇区数 ch=柱面 cl=扇区 dh=磁头 dl=驱动器
; 出参 cf=0成功 ah=00, al=传输的扇区数 ah=其他，错误

;=======lba转换成chs c:柱面 h:磁头 s:扇区
;c = 逻辑扇区号ax / (每个磁道的扇区数*磁头数量)
;h = 逻辑扇区号ax / 每个磁道的扇区数
;s = 逻辑扇区号ax % 每个磁道的扇区数 ， 由于s从1开始，所以要加+1
;反着来就是
;s = (逻辑扇区号ax % 每个磁道的扇区数) + 1, 商为Q
;h = Q % 磁头数量 , 商为W
;c = W
Func_Read_Sector_Data:
	;ax后面要用到所以先入栈保存下
	push dx
	push ax
	push bx
	;转换lba -> chs
	mov ax, dx
	mov	bl,	[BPB_SecPerTrk]
	div	bl; 商al,余数ah

	;确定s扇区号
	mov cl, ah
	inc cl
	;确定h磁头号
	mov dh, al
	and dh, 1

	;确定磁柱
	shr al, 1
	mov ch, al
	;确定驱动器号
	mov	dl,	[BS_DrvNum]
	;先弹出bx
	pop bx ;数据输出位置
	pop ax ;al读取的扇区数量
	mov ah, 02h ;读磁盘
	;至此准备工作就绪，要开始读了
	int 13h
	pop dx
	ret

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
;=======	display num in al

Label_DispAL:

	push	ecx
	push	edx
	push	edi
	
	mov	edi,	[DisplayPosition]
	mov	ah,	0Fh
	mov	dl,	al
	shr	al,	4
	mov	ecx,	2
.begin:

	and	al,	0Fh
	cmp	al,	9
	ja	.1
	add	al,	'0'
	jmp	.2
.1:

	sub	al,	0Ah
	add	al,	'A'
.2:

	mov	[gs:edi],	ax
	add	edi,	2
	
	mov	al,	dl
	loop	.begin

	mov	[DisplayPosition],	edi

	pop	edi
	pop	edx
	pop	ecx
	
	ret

;=======	tmp IDT

IDT:
	times	0x50	dq	0
IDT_END:

IDT_POINTER:
		dw	IDT_END - IDT - 1
		dd	IDT

PrintRow	db 0x07
PrintCol	db 0
PrintLastChar db 0
KernelTmpFileOffset dd OffsetOfKernelFile
DisplayPosition		dd	0

;=======	display messages
StartLoaderMessage:	db	"Start Loader00"
KernelFileName: db "KERNEL  BIN"
StartSearchKernel: db "Start Search Kernel00"
NoKernelMessage:	db	"No Kernel00"
SearchedKernelFile: db "find kernel1100"
StartGetMemStructMessage:	db	"Start Get Memory Struct00"
GetMemStructErrMessage:	db	"Get Memory Struct ERROR00"
GetMemStructOKMessage:	db	"Get Memory Struct SUCCESSFUL00"

StartGetSVGAVBEInfoMessage:	db	"Start Get SVGA VBE Info00"
GetSVGAVBEInfoErrMessage:	db	"Get SVGA VBE Info ERROR00"
GetSVGAVBEInfoOKMessage:	db	"Get SVGA VBE Info SUCCESSFUL00"

StartGetSVGAModeInfoMessage:	db	"Start Get SVGA Mode Info00"
GetSVGAModeInfoErrMessage:	db	"Get SVGA Mode Info ERROR00"
GetSVGAModeInfoOKMessage:	db	"Get SVGA Mode Info SUCCESSFUL00"