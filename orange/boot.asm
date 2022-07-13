; boot.asm
org	0x7c00
;内核基础地址
kernelBase equ 0x1000
;内核目标偏移地址
kernelOffset equ 0x000
;内核大小
kernelSecCount equ 10 
jmp Label_Start

Label_Start:
	mov	ax,	cs
	mov	ds,	ax
	mov	es,	ax
	mov	ss,	ax

;=======	clear screen
	mov	ax,	0600h
	mov	bx,	0700h
	mov	cx,	 0 ;ch起始行数 cl起始列数
	mov	dx,	184fh ;dh 结束行数 dl结束列数
	int	10h
;======= print message
	mov ax, 0x1301
	mov bx, 0x000f
	mov cx, 10 ;长度
	mov dx, 0x0000 ;dh行 dl列
	mov bp, StartBootMessage
	int 10h

;======= load kernel & jump
; int13h ah=02 读扇区 参数如下 https://en.wikipedia.org/wiki/INT_13H#INT_13h_AH=02h:_Read_Sectors_From_Drive  http://c.biancheng.net/view/3606.html
; al=扇区数 ch=柱面 cl=扇区 dh=磁头 dl=驱动器
; 出参 cf=0成功 ah=00, al=传输的扇区数 ah=其他，错误
	mov ah, 2
	mov al, kernelSecCount
	mov ch, 0
	mov cl, 2
	mov dh, 0
	mov dl, 0

	;数据存放es:bx
	mov bx, kernelBase
	mov es, bx
	mov bx, kernelOffset
	int 13h

	;跳转至内核
	jmp kernelBase:kernelOffset

;=======	display messages
StartBootMessage:	db	"Start boot"

;=======	fill zero until whole sector

	times	510 - ($ - $$)	db	0
	dw	0xaa55