.globl begtext,begdata,bedbss,endtext,enddata,endbss

;
.text
begtext:

.data
begdata:

.bss
begbss:

.text
BOOTSEG = 0x7c0

entry app_lba_start
start:
    jmpi go, BOOTSEG
go: mov ax, cs
    mov ds, ax
    mov es, ax
    mov [msg1+17], ah
    mov cs, #20
    mov dx, #0x1004
    mov bx, #0x000c
    mov bp, #msg1
    mov ax, @0x1301
    int 0x10
loop0: jmp loop0
msg1: .ascill "Loading system ..."
      .byte 13, 10

.org 510
    .word 0xAA55
.text
endtext:
.data
enddata:
.bss
endbss: