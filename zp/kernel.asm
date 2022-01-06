org 0x100000
jmp Label_Start
Label_Start:
    mov	ax,	cs
    mov	ds,	ax
    mov	es,	ax
    mov	ax,	0x00
    mov	ss,	ax
    mov	sp,	0x7c00

    mov bp, StartKernel
    mov dh, 20
    mov dl, 0
    mov ax, 1301h
    mov bx, 000fh
    int 10h
    jmp $

;--------message-----------

StartKernel: db "start kernel"