;zp os
org	0x7c00	

BaseOfStack	equ	0x7c00

BaseOfLoader	equ	0x1000
OffsetOfLoader	equ	0x0000

RootDirSectors	equ	14 ;目录占用的扇区数量 = 目录数量*结构体大小(32) / 每个扇区的字节数
SectorNumOfRootDirStart	equ	19 ;目录起始的扇区
SectorNumOfFAT1Start	equ	1
SectorBalance	equ	17	

	jmp	short Label_Start
	nop
	BS_OEMName	db	'MINEboot'
	BPB_BytesPerSec	dw	512 ;每个扇区的字节数
	BPB_SecPerClus	db	1	;给个簇对应的扇区数
	BPB_RsvdSecCnt	dw	1	;保留扇区数
	BPB_NumFATs	db	2		;fat表的数量
	BPB_RootEntCnt	dw	224	;根目录可容纳的目录项数
	BPB_TotSec16	dw	2880;总扇区数
	BPB_Media	db	0xf0	;介质类型
	BPB_FATSz16	dw	9		;每个fat占用的扇区数
	BPB_SecPerTrk	dw	18	;每个磁道的扇区数
	BPB_NumHeads	dw	2	;磁头数
	BPB_HiddSec	dd	0		;隐藏扇区数
	BPB_TotSec32	dd	0	;BPB_TotSec16为0话，记录总扇区数
	BS_DrvNum	db	0		;int13的驱动器号
	BS_Reserved1	db	0	;未使用
	BS_BootSig	db	0x29	;扩展引导标记
	BS_VolID	dd	0		;卷标序列
	BS_VolLab	db	'boot loader'	;卷标
	BS_FileSysType	db	'FAT12   '	;文件系统类型

Label_Start:

	mov	ax,	cs
	mov	ds,	ax
	mov	es,	ax
	mov	ss,	ax
	mov	sp,	BaseOfStack

;=======	clear screen

	mov	ax,	0600h
	mov	bx,	0700h
	mov	cx,	 0 ;ch起始行数 cl起始列数
	mov	dx,	184fh ;dh 结束行数 dl结束列数
	int	10h

;=======	set focus

	mov	ax,	0200h
	mov	bx,	0000h
	mov	dx,	0000h
	int	10h

;=======	display on screen : Start Booting......	
; es:bp 输出的内容地址 
; cx 长度
	mov bp, StartBootMessage
	call Func_Print_Message

;======= 开始读取fat12目录信息
;目录开始扇区SectorNumOfRootDirStart， 目录长度RootDirSectors
mov bp, StartSearchLoader
call Func_Print_Message

Label_Begion_Read_Root_Dir:
	;读取目录信息
	mov ax, 0
	mov al, RootDirSectors
	mov dx, SectorNumOfRootDirStart
	mov bx, 8000h
	call Func_Read_Sector_Data
	
	;从es:bx处开始对比
	mov bx, 8000h
	;总目录数 [BPB_RootEntCnt]
	mov ax, [BPB_RootEntCnt]

Label_Read_Root_Dir:
	mov si, bx
	;bp为要搜索的文件，dx为文件长度
	mov bp, LoaderFileName
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
	mov bp, SearchLoadFile
	call Func_Print_Message
	;文件的目录信息为  es:bx
	;开始读取文件内容 dx:si
	mov dx, BaseOfLoader
	mov si, OffsetOfLoader
	call Func_Load_File

	jmp BaseOfLoader: OffsetOfLoader

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
	mov bp, NoLoaderMessage
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
;https://www.eit.lth.se/fileadmin/eit/courses/eitn50/Literature/fat12_description.pdf fat cluster介绍 使用小端模式
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
	mov ax, ds
	mov es, ax
	;读取fat1
	mov ax, [BPB_FATSz16]
	mov dx, 1 ;fat从第一个扇区开始
	mov bx, 9000h
	call Func_Read_Sector_Data

	;每一个簇在fat1表中占12bit, 1.5byte
	pop ax
	mov bl, 3
	mul bl
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

;=======	tmp variable

RootDirSizeForLoop	dw	RootDirSectors
SectorNo		dw	0
PrintRow	db 0
PrintCol	db 0
PrintLastChar db 0

;=======	display messages

StartBootMessage:	db	"Start boot00"
NoLoaderMessage:	db	"No LOADER00"
LoaderFileName:		db	"LOADER  BIN" ;长度为11，中间是两个空格 4c 4f 41 44 45
SearchLoadFile:		db  "find loader00"
StartSearchLoader:  db  "start find loader00"

;=======	fill zero until whole sector

	times	510 - ($ - $$)	db	0
	dw	0xaa55