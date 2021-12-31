; 第一版
;     mov ax,0xb800
;     mov es,ax
;     mov byte [es:0x00],'H'
;     mov byte [es:0x01],0x07
;     mov byte [es:0x02],'e'
;     mov byte [es:0x03],0x07
;     mov byte [es:0x04],'l'
;     mov byte [es:0x05],0x07
;     mov byte [es:0x06],'l'
;     mov byte [es:0x07],0x07
;     mov byte [es:0x08],'o'
;     mov byte [es:0x09],0x07
;     mov byte [es:0x0a],' '
;     mov byte [es:0x0b],0x07
;     mov byte [es:0x0c],'w'
;     mov byte [es:0x0d],0x07
;     mov byte [es:0x0e],'o'
;     mov byte [es:0x0f],0x07
;     mov byte [es:0x10],'r'
;     mov byte [es:0x11],0x07
;     mov byte [es:0x12],'l'
;     mov byte [es:0x13],0x07
;     mov byte [es:0x14],'d'
;     mov byte [es:0x15],0x07
;     mov byte [es:0x16],'!'
;     mov byte [es:0x17],0x07
;     jmp $

; times 510-($-$$) db 0
; dw 0x55aa

; --------------------------------------------------------------------
; 第二版，数据段

; jmp main

; ; 数据段
; string db 'H',0x07,'e',0x07,'l',0x07,'l',0x07,'o',0x07,' ',0x07,'w',0x07,'o',0x07,'r',0x07,'l',0x07,'d',0x07,'!',0x07,' ',0x07,'S',0x07,'T',0x07,'W',0x07
; slen db $-string

; main: 
;     mov ax,0x07c0
;     mov ds,ax

;     mov ax,0xb800
;     mov es,ax
    
;     mov si,string
    
;     mov ax,0xb800
;     mov es,ax
;     mov di,0

;     cld
;     mov cx,slen
;     rep movsb ;movsb 从ds:si -> es:di

;     jmp $

; times 510-($-$$) db 0

; dw 0x55aa

; ------------------------------------------------------------------------
; 循环
; jmp main

; string db 'Hello world! Tianwen'
; slen equ $-string

; main:
;     mov ax,0x07c0
;     mov ds,ax

;     mov ax,0xb800
;     mov es,ax

;     mov si,string
;     mov di,0

;     mov cx,slen

; print:
;     mov al,[si]
;     mov [es:di],al
;     inc di
;     mov byte [es:di],0x07
;     inc di
;     inc si
;     loop print

; ; 计算1...100和
;     mov ax,0
;     mov cx,1
; add_loop:
;     add ax,cx
;     inc cx
;     cmp cx,100
;     jle add_loop

; ;translate sum to result
; ;初始化栈 ss:sp
; mov cx,0
; mov ss,cx
; mov sp,cx

; mov cx,0 ;入栈次数
; mov bx,0x0a ;除数

; translate:
;     inc cx
;     mov dx,0 ; 被除数[dx:ax]
;     div bx
;     ;商ax 余数dx
;     add dx,0x30; 转换成ascll
;     push dx
;     cmp ax,0
;     jne translate

; ;print
; print_sum:
;     pop dx
;     mov [es:di],dl
;     inc di
;     mov byte [es:di],0x07
;     inc di
;     loop print_sum

; jmp $
; times 510-($-$$) db 0
; dw 0x55aa

    org 0x7c00
    mov ax,cs
    mov ds,ax
    mov es,ax
    call showWelcome
    jmp $

showWelcome:
    mov ax, welcomeMsg
    mov bp, ax
    mov cx, slen
    mov ax, 0x1301
    mov bx, 0x0007
    mov dx, 0
    int 10h
    ret

welcomeMsg db 'Welcome to stw OS!'
slen equ $-welcomeMsg

times 510-($-$$) db 0
db 0x55,0xaa
